import login.{login_view}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import rest_function
import types

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_args) -> #(types.Model, Effect(types.Msg)) {
  let model =
    types.Model(profile: types.Unlogged, page: types.LoginPage, chats: [])
  #(model, rest_function.tick())
}

fn update(
  model: types.Model,
  msg: types.Msg,
) -> #(types.Model, Effect(types.Msg)) {
  case msg {
    types.UserLogin(_) -> #(model, effect.none())
    types.LoginSubmit(Ok(p)) ->
      case p {
        types.LoggedUser(_, _) -> #(
          types.Model(profile: p, page: types.MenuPage, chats: []),
          rest_function.get_messages(model.profile, False),
        )
        types.Unlogged -> #(model, effect.none())
      }
    types.UserLogout -> init(0)
    types.SendMessage(msg) -> #(
      model,
      rest_function.send_message(model.profile, msg),
    )
    types.ChangePage(p) -> #(types.Model(..model, page: p), effect.none())
    types.ReceiveNewMessage(Ok(msg)) -> #(
      rest_function.update_msgs(model, msg),
      effect.none(),
    )
    types.MessageRequest -> #(
      model,
      rest_function.get_messages(model.profile, True),
    )
    types.MessageSended(Ok(msgs)) -> #(
      rest_function.update_msgs(model, msgs),
      effect.none(),
    )
    _ -> #(model, effect.none())
    // x gli errori
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
