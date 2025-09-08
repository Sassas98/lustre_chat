import birl
import gleam/bool
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import lustre/effect.{type Effect}
import plinth/browser/document
import plinth/browser/element
import rsvp
import types

@external(javascript, "./app.ffi.mjs", "get_profile")
fn get_profile() -> Result(Dynamic, Nil) {
  Error(Nil)
}

@external(javascript, "./app.ffi.mjs", "set_profile")
fn set_profile(_username: String, _token: String, _email: String) -> Nil {
  Nil
}

@external(javascript, "./app.ffi.mjs", "remove_profile")
fn remove_profile() -> Nil {
  Nil
}

pub fn get_stored_profile() -> types.Profile {
  let result =
    result.try(get_profile(), fn(dyn) {
      let decoder = {
        use username <- decode.field("username", decode.string)
        use token <- decode.field("token", decode.string)
        use email <- decode.field("email", decode.string)
        decode.success(types.LoggedUser(username:, token:, email:))
      }
      case decode.run(dyn, decoder) {
        Ok(todos) -> Ok(todos)
        Error(_) -> Error(Nil)
      }
    })
  case result {
    Ok(p) -> p
    _ -> types.Unlogged
  }
}

pub fn set_stored_profile(
  username: String,
  token: String,
  email: String,
) -> types.Profile {
  set_profile(username, token, email)
  types.LoggedUser(username:, token:, email:)
}

pub fn remove_stored_profile() -> types.Profile {
  remove_profile()
  types.Unlogged
}

pub fn format_dt(dt: birl.Time) -> String {
  let iso = birl.to_iso8601(dt)
  let pair = case string.split(iso, "T") {
    [a, b] -> #(a, b)
    _ -> #("", "")
  }
  let date = case string.split(pair.0, "-") {
    [_, b, c] -> #(c, b)
    _ -> #("", "")
  }
  let time = case string.split(pair.1, ":") {
    [a, b, _, _] -> #(a, b)
    [a, b, _] -> #(a, b)
    _ -> #("", "")
  }

  string.concat([time.0, ":", time.1, " ", date.0, "/", date.1])
}

fn get_url(env: String) {
  case env {
    "dev" -> "https://localhost:7174/api/v1/chat/"
    _ -> "/api/v1/chat/"
  }
}

pub fn submit_registration(
  env: String,
  lm: types.RegistrationModel,
) -> Effect(types.Msg) {
  let body =
    json.object([
      #("username", json.string(lm.username)),
      #("password", json.string(lm.password)),
      #("email", json.string(lm.email)),
    ])

  let url = get_url(env) <> "registration"

  let decoder = {
    use success <- decode.field("success", decode.bool)
    decode.success(success)
  }

  let handler = rsvp.expect_json(decoder, types.RegistrationSubmit)

  rsvp.post(url, body, handler)
}

pub fn submit_login(env: String, lm: types.LoginModel) -> Effect(types.Msg) {
  let body =
    json.object([
      #("username", json.string(lm.username)),
      #("password", json.string(lm.password)),
    ])

  let url = get_url(env) <> "login"

  let decoder = {
    use success <- decode.field("success", decode.bool)
    use token <- decode.field("token", decode.string)
    use username <- decode.field("username", decode.string)
    use email <- decode.field("email", decode.string)
    decode.success(case success {
      True -> types.LoggedUser(username:, token:, email:)
      False -> types.Unlogged
    })
  }

  let handler = rsvp.expect_json(decoder, types.LoginSubmit)

  rsvp.post(url, body, handler)
}

pub fn send_message(
  profile: types.Profile,
  env: String,
  msg: types.Message,
) -> Effect(types.Msg) {
  let body =
    json.object([
      #(
        "token",
        json.string(case profile {
          types.LoggedUser(_, _, token: token) -> token
          _ -> ""
        }),
      ),
      #("text", json.string(msg.text)),
      #("from", json.string(msg.from)),
      #("to", json.string(msg.to)),
    ])

  let url = get_url(env) <> "send"

  let decoder = {
    use success <- decode.field("success", decode.bool)
    decode.success(case success {
      True -> [types.Message(..msg, read: True)]
      False -> []
    })
  }

  let handler = rsvp.expect_json(decoder, types.MessageSended)

  rsvp.post(url, body, handler)
}

pub fn update_msgs(model: types.Model, msgs: List(types.Message)) -> types.Model {
  let username = case model.profile {
    types.LoggedUser(username: user, token: _, email: _) -> user
    _ -> ""
  }
  let chats =
    msgs
    |> list.group(fn(m) {
      case m.from == username {
        True -> m.to
        _ -> m.from
      }
    })
    |> dict.map_values(fn(k, v) {
      types.Chat(k, v |> list.any(fn(m) { !m.read }), v)
    })
    |> dict.values
    |> list.append(model.chats)
    |> list.group(fn(c) { c.with })
    |> dict.map_values(fn(k, v) {
      types.Chat(
        k,
        v
          |> list.flat_map(fn(x) { x.messages })
          |> list.any(fn(m) { !m.read }),
        v
          |> list.flat_map(fn(x) { x.messages })
          |> set.from_list
          |> set.to_list
          |> list.sort(fn(a, b) { birl.compare(a.time, b.time) }),
      )
    })
    |> dict.values

  types.Model(..model, chats: chats, in_loading: False)
}

@external(javascript, "./app.ffi.mjs", "set_timeout")
fn set_timeout(_delay: Int, _cb: fn() -> a) -> Nil {
  Nil
}

pub fn tick_combined() -> Effect(types.Msg) {
  effect.batch([scroll_to_bottom(), tick()])
}

pub fn tick() -> Effect(types.Msg) {
  use dispatch <- effect.from
  use <- set_timeout(10_000)
  dispatch(types.MessageRequest)
}

pub fn get_messages(
  profile: types.Profile,
  env: String,
  only_new: Bool,
) -> Effect(types.Msg) {
  let decoder = {
    use time_str <- decode.field("time", decode.string)
    use text <- decode.field("text", decode.string)
    use from <- decode.field("from", decode.string)
    use to <- decode.field("to", decode.string)
    use read <- decode.field("read", decode.bool)
    case birl.parse(time_str) {
      Error(_) -> panic
      Ok(time) -> decode.success(types.Message(text:, from:, to:, read:, time:))
    }
  }
  let url =
    get_url(env)
    <> "get?token="
    <> case profile {
      types.LoggedUser(_, _, token: token) -> token
      _ -> ""
    }
    <> "&onlyNew="
    <> bool.to_string(only_new)
  let handler =
    rsvp.expect_json(decode.list(decoder), fn(msgs) {
      types.ReceiveNewMessage(msgs, only_new)
    })
  case profile {
    types.LoggedUser(_, _, _) -> rsvp.get(url, handler)
    _ -> effect.from(fn(dispatch) { dispatch(types.StopLoading) })
  }
}

pub fn search_username(env: String, s: String) -> Effect(types.Msg) {
  let decoder = {
    use text <- decode.field("usernames", decode.list(decode.string))
    decode.success(text)
  }
  let url = get_url(env) <> "search?username=" <> s
  let handler = rsvp.expect_json(decoder, types.HandleUsernamesReturn)

  rsvp.get(url, handler)
}

pub fn scroll_to_bottom() {
  effect.before_paint(fn(_, _) {
    case document.get_element_by_id("chat-div") {
      Ok(elem) -> {
        element.set_scroll_top(elem, element.scroll_height(elem))
      }
      Error(_) -> Nil
    }
  })
}
