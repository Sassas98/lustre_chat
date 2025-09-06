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
    types.Model(
      profile: types.Unlogged,
      page: types.LoginPage,
      chats: [],
      search_chat: [],
      in_loading: False,
      input: types.Input("", "", "", ""),
    )
  #(model, rest_function.tick())
}

fn update(
  model: types.Model,
  msg: types.Msg,
) -> #(types.Model, Effect(types.Msg)) {
  case msg {
    types.UserLogin(m) -> #(
      types.Model(..model, in_loading: True),
      rest_function.submit_login(m),
    )
    types.LoginSubmit(Ok(p)) ->
      case p {
        types.LoggedUser(_, _) -> #(
          types.Model(
            ..model,
            profile: p,
            page: types.MenuPage,
            in_loading: False,
          ),
          rest_function.get_messages(model.profile, False),
        )
        types.Unlogged -> #(model, effect.none())
      }
    types.UserLogout -> init(0)
    types.SendMessage(msg) -> #(
      types.Model(..model, in_loading: True),
      rest_function.send_message(model.profile, msg),
    )
    types.ChangePage(p) -> #(types.Model(..model, page: p), effect.none())
    types.ReceiveNewMessage(Ok(msg), continue) -> #(
      rest_function.update_msgs(model, msg),
      case continue {
        True -> rest_function.tick()
        False -> effect.none()
      },
    )
    types.ReceiveNewMessage(Error(_), continue) -> #(
      types.Model(..model, in_loading: False),
      case continue {
        True -> rest_function.tick()
        False -> effect.none()
      },
    )
    types.MessageRequest -> #(
      types.Model(..model, in_loading: True),
      rest_function.get_messages(model.profile, True),
    )
    types.MessageSended(Ok(msgs)) -> #(
      rest_function.update_msgs(model, msgs),
      effect.none(),
    )
    types.HandleUsernamesReturn(Ok(list)) -> #(
      types.Model(..model, search_chat: list, in_loading: False),
      effect.none(),
    )
    types.SearchUsername(s) -> #(
      types.Model(..model, in_loading: False),
      rest_function.search_username(s),
    )
    types.InputUsername(s) -> #(
      types.Model(..model, input: types.Input(..model.input, username: s)),
      effect.none(),
    )
    types.InputPassword(s) -> #(
      types.Model(..model, input: types.Input(..model.input, password: s)),
      effect.none(),
    )
    types.InputSearch(s) -> #(
      types.Model(..model, input: types.Input(..model.input, search: s)),
      effect.none(),
    )
    types.InputChat(s) -> #(
      types.Model(..model, input: types.Input(..model.input, chat: s)),
      effect.none(),
    )
    _ -> #(types.Model(..model, in_loading: False), effect.none())
    // x gli errori
  }
}

fn view(model: types.Model) -> Element(types.Msg) {
  html.div(
    [
      attribute.class(
        "bg-gradient-to-b from-slate-500 to-slate-800 md:p-4 text-white h-[100vh] overflow-auto flex justify-center font-mono",
      ),
    ],
    [
      html.div([], [
        case model.page {
          types.LoginPage -> login_view(model)
          _ -> html.span([], [html.text("Test")])
        },
      ]),
    ],
  )
}
