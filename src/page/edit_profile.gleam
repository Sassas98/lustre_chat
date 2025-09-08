import component/button
import component/input
import component/util
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import types

pub fn edit_profile_view(model: types.Model) -> Element(types.Msg) {
  util.card([
    input.text_input(
      "Username",
      types.InputUsername,
      "md:w-[50%] md:mx-[25%]",
      model.input.username,
      types.EditProfileEvent,
    ),
    input.text_input(
      "Email",
      types.InputEmail,
      "md:w-[50%] md:mx-[25%]",
      model.input.email,
      types.EditProfileEvent,
    ),
    input.password_input(
      "Vecchia Password",
      types.InputPassword,
      "md:w-[50%] md:mx-[25%]",
      model.input.password,
      types.EditProfileEvent,
    ),
    input.password_input(
      "Nuova Password",
      types.InputNewPassword,
      "md:w-[50%] md:mx-[25%]",
      model.input.new_password,
      types.EditProfileEvent,
    ),
    html.div([attribute.class("flex justify-between md:w-[50%] md:mx-[25%]")], [
      button.secondary_btn(types.ChangePage(types.MenuPage), "Indietro"),
      button.primary_btn(types.EditProfileEvent, "Salva account"),
    ]),
  ])
}
