import component/button
import fun
import gleam/bool
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import page/chat.{chat_view}
import page/edit_profile.{edit_profile_view}
import page/login.{login_view}
import page/menu_page.{menu_view}
import page/registration.{registration_view}
import page/search.{search_view}
import types

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", "dev")

  Nil
}

fn init(env: String) -> #(types.Model, Effect(types.Msg)) {
  let profile = fun.get_stored_profile()
  let page = case profile {
    types.Unlogged -> types.LoginPage
    _ -> types.MenuPage
  }
  let f = case profile {
    types.Unlogged -> fun.tick
    _ -> fn() {
      [fun.get_messages(profile, env, False), fun.tick()] |> effect.batch()
    }
  }
  let model =
    types.Model(
      profile:,
      page:,
      chats: [],
      search_chat: [],
      in_loading: False,
      input: types.Input("", "", "", "", "", ""),
      env:,
      error: "",
    )
  #(model, f())
}

fn update(
  model: types.Model,
  msg: types.Msg,
) -> #(types.Model, Effect(types.Msg)) {
  case msg {
    types.LoadPictureEvent -> #(
      types.Model(..model, in_loading: True, error: string.inspect(e)),
      effect.none(),
    )
    types.LoadProfileSubmit(Ok(s)) -> #(
      types.Model(
        ..model,
        in_loading: False,
        input: types.Input(..model.input, chat: s),
      ),
      effect.none(),
    )
    types.LoadProfileSubmit(Error(e)) -> #(
      types.Model(..model, in_loading: False, error: string.inspect(e)),
      effect.none(),
    )
    types.EditProfileEvent -> #(
      types.Model(..model, in_loading: True),
      fun.edit_profile(model),
    )
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
        types.LoggedUser(username, token, email) -> #(
          types.Model(
            ..model,
            profile: fun.set_stored_profile(username, token, email),
            page: types.MenuPage,
            in_loading: True,
            input: types.Input("", "", "", "", "", ""),
          ),
          fun.get_messages(p, model.env, False),
        )
        types.Unlogged -> #(
          types.Model(..model, error: "Login fallito", in_loading: False),
          effect.none(),
        )
      }
    types.UserLogout -> #(
      types.Model(
        profile: fun.remove_stored_profile(),
        page: types.LoginPage,
        chats: [],
        search_chat: [],
        in_loading: False,
        input: types.Input("", "", "", "", "", ""),
        env: model.env,
        error: "",
      ),
      effect.none(),
    )
    types.SendMessage(msg) -> #(
      types.Model(
        ..model,
        in_loading: True,
        input: types.Input("", "", "", "", "", ""),
      ),
      fun.send_message(model.profile, model.env, msg),
    )
    types.ChangePage(p) -> #(
      types.Model(..model, page: p, input: case p {
        types.EditProfile ->
          types.Input(
            ..model.input,
            username: model.profile |> fun.get_username,
            email: model.profile |> fun.get_email,
          )
        _ -> types.Input("", "", "", "", "", "")
      }),
      fun.scroll_to_bottom(),
    )
    types.ReceiveNewMessage(Ok(msg), continue) -> #(
      fun.update_msgs(model, msg),
      case continue {
        True -> fun.tick_combined()
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
      model,
      fun.get_messages(model.profile, model.env, True),
    )
    types.MessageSended(Ok(msgs)) -> #(
      fun.update_msgs(model, msgs),
      fun.scroll_to_bottom(),
    )
    types.HandleUsernamesReturn(Ok(ls)) -> #(
      types.Model(
        ..model,
        search_chat: ls
          |> list.filter(fn(x) {
            let username = model.profile |> fun.get_username()
            x != username
          }),
        in_loading: False,
      ),
      effect.none(),
    )
    types.SearchUsername(s) -> #(
      types.Model(..model, in_loading: True),
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
        types.InputEmail ->
          types.Model(..model, input: types.Input(..model.input, email: s))
        types.InputNewPassword ->
          types.Model(
            ..model,
            input: types.Input(..model.input, new_password: s),
          )
      },
      effect.none(),
    )
    types.RegistrationSubmit(Ok(True)) -> #(
      types.Model(
        ..model,
        in_loading: False,
        input: types.Input("", "", "", "", "", ""),
        page: types.LoginPage,
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
    types.EditProfileSubmit(Error(e)) -> #(
      types.Model(..model, in_loading: False, error: string.inspect(e)),
      effect.none(),
    )

    types.EditProfileSubmit(Ok(True)) -> #(
      types.Model(
        ..model,
        in_loading: False,
        profile: types.LoggedUser(
          token: model.profile |> fun.get_token(),
          username: model.input.username,
          email: model.input.email,
        ),
        page: types.MenuPage,
      ),
      effect.from(fn(dispatch) {
        fun.set_stored_profile(
          model.input.username,
          model.profile |> fun.get_token,
          model.input.email,
        )
        types.NoneEvent |> dispatch
      }),
    )
    types.EditProfileSubmit(Ok(False)) -> #(
      types.Model(..model, in_loading: False, error: "Errore nel salvataggio"),
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
    types.StopLoading -> #(
      types.Model(..model, in_loading: False),
      fun.tick_combined(),
    )
    types.NoneEvent -> #(model, effect.none())
  }
}

fn view(model: types.Model) -> Element(types.Msg) {
  case model.error {
    "" ->
      html.div(
        [
          attribute.class(
            "text-white h-[100vh] overflow-auto flex justify-center md:pt-24 font-mono bg-[url('/bg.svg')] bg-no-repeat bg-center bg-cover",
          ),
        ],
        [
          html.div(
            [
              attribute.data("show", bool.to_string(model.in_loading)),
              attribute.class(
                "data-[show=False]:hidden absolute bg-slate-800/70 w-[100vw] h-[100vh] flex justify-center z-10 items-center cursor-wait",
              ),
            ],
            [
              html.div(
                [
                  attribute.class("loader"),
                ],
                [],
              ),
            ],
          ),
          html.div([attribute.class("")], [
            case model.page {
              types.LoginPage -> login_view(model)
              types.RegisterPage -> registration_view(model)
              types.ChatPage(u) -> chat_view(model, u)
              types.MenuPage -> menu_view(model)
              types.SearchPage -> search_view(model)
              types.EditProfile -> edit_profile_view(model)
            },
          ]),
        ],
      )
    ex ->
      html.div(
        [
          attribute.class(
            "bg-black text-red-500 text-lg px-4 md:text-4xl h-[100vh] flex justify-center items-center font-mono flex-col gap-10",
          ),
        ],
        [
          html.span([], [html.text("Si è verificato un errore: " <> ex)]),
          button.danger_btn(types.ErrorAccept, "Chiudi"),
        ],
      )
  }
}
