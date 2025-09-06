import component/button
import fun
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import page/login.{login_view}
import page/registration.{registration_view}
import types

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", "dev")

  Nil
}

fn init(env: String) -> #(types.Model, Effect(types.Msg)) {
  let model =
    types.Model(
      profile: types.Unlogged,
      page: types.LoginPage,
      chats: [],
      search_chat: [],
      in_loading: False,
      input: types.Input("", "", "", ""),
      env:,
      error: "",
    )
  #(model, fun.tick())
}

fn update(
  model: types.Model,
  msg: types.Msg,
) -> #(types.Model, Effect(types.Msg)) {
  case msg {
    types.UserRegistration(m) -> #(
      types.Model(..model, in_loading: True),
      fun.submit_registration(model.env, m),
    )
    types.UserLogin(m) -> #(
      types.Model(..model, in_loading: True),
      fun.submit_login(model.env, m),
    )
    types.LoginSubmit(Ok(p)) ->
      case p {
        types.LoggedUser(_, _) -> #(
          types.Model(
            ..model,
            profile: p,
            page: types.MenuPage,
            in_loading: False,
            input: types.Input("", "", "", ""),
          ),
          fun.get_messages(model.profile, model.env, False),
        )
        types.Unlogged -> #(model, effect.none())
      }
    types.UserLogout -> init(model.env)
    types.SendMessage(msg) -> #(
      types.Model(..model, in_loading: True, input: types.Input("", "", "", "")),
      fun.send_message(model.profile, model.env, msg),
    )
    types.ChangePage(p) -> #(
      types.Model(..model, page: p, input: types.Input("", "", "", "")),
      effect.none(),
    )
    types.ReceiveNewMessage(Ok(msg), continue) -> #(
      fun.update_msgs(model, msg),
      case continue {
        True -> fun.tick()
        False -> effect.none()
      },
    )
    types.ReceiveNewMessage(Error(e), continue) -> #(
      types.Model(..model, in_loading: False, error: string.inspect(e)),
      case continue {
        True -> fun.tick()
        False -> effect.none()
      },
    )
    types.MessageRequest -> #(
      types.Model(..model, in_loading: True),
      fun.get_messages(model.profile, model.env, True),
    )
    types.MessageSended(Ok(msgs)) -> #(
      fun.update_msgs(model, msgs),
      effect.none(),
    )
    types.HandleUsernamesReturn(Ok(list)) -> #(
      types.Model(..model, search_chat: list, in_loading: False),
      effect.none(),
    )
    types.SearchUsername(s) -> #(
      types.Model(..model, in_loading: False),
      fun.search_username(model.env, s),
    )
    types.InputEvent(s, t) -> #(
      case t {
        types.InputChat ->
          types.Model(..model, input: types.Input(..model.input, chat: s))
        types.InputPassword ->
          types.Model(..model, input: types.Input(..model.input, password: s))
        types.InputSearch ->
          types.Model(..model, input: types.Input(..model.input, search: s))
        types.InputUsername ->
          types.Model(..model, input: types.Input(..model.input, username: s))
      },
      effect.none(),
    )
    types.RegistrationSubmit(Ok(True)) -> #(
      types.Model(
        ..model,
        in_loading: False,
        input: types.Input("", "", "", ""),
      ),
      effect.none(),
    )
    types.HandleUsernamesReturn(Error(e)) -> #(
      types.Model(..model, in_loading: False, error: string.inspect(e)),
      effect.none(),
    )
    types.LoginSubmit(Error(e)) -> #(
      types.Model(..model, in_loading: False, error: string.inspect(e)),
      effect.none(),
    )
    types.MessageSended(Error(e)) -> #(
      types.Model(..model, in_loading: False, error: string.inspect(e)),
      effect.none(),
    )
    types.RegistrationSubmit(Error(e)) -> #(
      types.Model(..model, in_loading: False, error: string.inspect(e)),
      effect.none(),
    )
    types.RegistrationSubmit(Ok(False)) -> #(
      types.Model(
        ..model,
        in_loading: False,
        error: "Username inserito già presente",
      ),
      effect.none(),
    )
    types.ErrorAccept -> #(types.Model(..model, error: ""), effect.none())
  }
}

fn view(model: types.Model) -> Element(types.Msg) {
  case model.error {
    "" ->
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
              types.RegisterPage -> registration_view(model)
              _ -> html.span([], [html.text("Test")])
            },
          ]),
        ],
      )
    ex ->
      html.div(
        [
          attribute.class(
            "bg-black text-red-500 text-4xl h-[100vh] flex justify-center items-center font-mono flex-col gap-10",
          ),
        ],
        [
          html.span([], [html.text("Si è verificato un errore: " <> ex)]),
          button.danger_btn(types.ErrorAccept, "Chiudi"),
        ],
      )
  }
}
