import birl
import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import lustre/effect.{type Effect}
import rsvp
import types

fn get_url(env: String) {
  case env {
    "dev" -> "http://localhost:8001/api/v1/"
    _ -> "/api/v1/"
  }
}

pub fn submit_registration(
  env: String,
  lm: types.LoginModel,
) -> Effect(types.Msg) {
  let body =
    json.object([
      #("username", json.string(lm.username)),
      #("password", json.string(lm.password)),
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
    decode.success(case success {
      True -> types.LoggedUser(username:, token:)
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
          types.LoggedUser(_, token: token) -> token
          _ -> ""
        }),
      ),
      #("text", json.string(msg.text)),
      #("from", json.string(msg.from)),
      #("to", json.string(msg.to)),
      #("read", json.bool(msg.read)),
      #("time", json.string(birl.to_iso8601(msg.time))),
    ])

  let url = get_url(env) <> "send"

  let decoder = {
    use success <- decode.field("success", decode.bool)
    decode.success(case success {
      True -> [msg]
      False -> []
    })
  }

  let handler = rsvp.expect_json(decoder, types.MessageSended)

  rsvp.post(url, body, handler)
}

pub fn update_msgs(model: types.Model, msgs: List(types.Message)) -> types.Model {
  let username = case model.profile {
    types.LoggedUser(username: user, token: _) -> user
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
    |> dict.map_values(fn(k, v) { types.Chat(k, v) })
    |> dict.values
    |> list.append(model.chats)
    |> list.group(fn(c) { c.with })
    |> dict.map_values(fn(k, v) {
      types.Chat(k, list.flat_map(v, fn(x) { x.messages }))
    })
    |> dict.values
  types.Model(..model, chats: chats, in_loading: False)
}

@external(javascript, "./app.ffi.mjs", "set_timeout")
fn set_timeout(_delay: Int, _cb: fn() -> a) -> Nil {
  Nil
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
      types.LoggedUser(_, token: token) -> token
      _ -> ""
    }
    <> "&onlyNew="
    <> bool.to_string(only_new)
  let handler =
    rsvp.expect_json(decode.list(decoder), fn(msgs) {
      types.ReceiveNewMessage(msgs, only_new)
    })
  case profile {
    types.LoggedUser(_, _) -> rsvp.get(url, handler)
    _ -> effect.none()
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
