import component/button
import component/input
import component/util
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import types

pub fn registration_view(model: types.Model) -> Element(types.Msg) {
  let submit =
    types.UserRegistration(types.RegistrationModel(
      model.input.username,
      model.input.password,
      model.input.email,
    ))

  util.card([
    util.title("REGISTRAZIONE"),
    input.text_input(
      "Username",
      types.InputUsername,
      "md:w-[50%] md:mx-[25%]",
      model.input.username,
      submit,
    ),
    input.text_input(
      "Email",
      types.InputEmail,
      "md:w-[50%] md:mx-[25%]",
      model.input.email,
      submit,
    ),
    input.password_input(
      "Password",
      types.InputPassword,
      "md:w-[50%] md:mx-[25%]",
      model.input.password,
      submit,
    ),
    html.div([attribute.class("flex justify-between md:w-[50%] md:mx-[25%]")], [
      button.secondary_btn(types.ChangePage(types.LoginPage), "Torna a Login"),
      button.primary_btn(submit, "Registrati"),
    ]),
  ])
}
