import birl
import gleam/bool
import gleam/dynamic/decode
import login.{login_view}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import rsvp
import types

//----------------- MAIN

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_args) -> #(types.Model, Effect(types.Msg)) {
  let model =
    types.Model(
      profile: types.Profile("", "", types.Unlogged),
      page: types.LoginPage,
      chats: [],
    )
  #(model, tick())
}

fn update(
  model: types.Model,
  msg: types.Msg,
) -> #(types.Model, Effect(types.Msg)) {
  case msg {
    types.UserLogin(_) -> #(model, effect.none())
    types.UserLogout -> #(model, effect.none())
    types.SendMessage(_) -> #(model, effect.none())
    types.ChangePage(p) -> #(types.Model(..model, page: p), effect.none())
    types.ReceiveNewMessage(Ok(msg)) -> #(types.Model(..model), effect.none())
    types.ReceiveNewMessage(Error(_)) -> #(model, effect.none())
    types.MessageRequest -> #(model, get_messages(model.profile, True))
  }
}

fn view(model: types.Model) -> Element(types.Msg) {
  case model.page {
    types.LoginPage -> login_view(model)
    _ ->
      html.div(
        [attribute.class("bg-gradient-to-b from-slate-500 to-slate-800")],
        [
          html.div([], [html.p([], [html.text("Test")])]),
        ],
      )
  }
}

//----------------- UTILITY

fn update_msgs(model: types.Model, msgs: List(types.Message)) -> types.Model {
  model
}

@external(javascript, "./app.ffi.mjs", "set_timeout")
fn set_timeout(_delay: Int, _cb: fn() -> a) -> Nil {
  Nil
}

fn tick() -> Effect(types.Msg) {
  use dispatch <- effect.from
  use <- set_timeout(10_000)

  dispatch(types.MessageRequest)
}

fn get_messages(profile: types.Profile, only_new: Bool) -> Effect(types.Msg) {
  let decoder = {
    use time_str <- decode.field("time", decode.string)
    use text <- decode.field("text", decode.string)
    use link <- decode.field("link", decode.string)
    use from <- decode.field("from", decode.string)
    use to <- decode.field("to", decode.string)
    use read <- decode.field("read", decode.bool)
    case birl.parse(time_str) {
      Error(_) -> panic
      Ok(time) ->
        decode.success(types.Message(text:, link:, from:, to:, read:, time:))
    }
  }
  let url =
    "http://www.url.com?token="
    <> profile.token
    <> "&onlyNew="
    <> bool.to_string(only_new)
  let handler = rsvp.expect_json(decode.list(decoder), types.ReceiveNewMessage)

  rsvp.get(url, handler)
}
