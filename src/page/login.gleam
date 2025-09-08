import component/button
import component/input
import component/util
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import types

pub fn login_view(model: types.Model) -> Element(types.Msg) {
  util.card([
    util.title("LOGIN"),
    input.text_input(
      "Username",
      types.InputUsername,
      "md:w-[50%] md:mx-[25%]",
      model.input.username,
      types.UserLogin(types.LoginModel(
        model.input.username,
        model.input.password,
      )),
    ),
    input.password_input(
      "Password",
      types.InputPassword,
      "md:w-[50%] md:mx-[25%]",
      model.input.password,
      types.UserLogin(types.LoginModel(
        model.input.username,
        model.input.password,
      )),
    ),
    html.div([attribute.class("flex justify-between md:w-[50%] md:mx-[25%]")], [
      button.secondary_btn(types.ChangePage(types.RegisterPage), "Registrati"),
      button.primary_btn(
        types.UserLogin(types.LoginModel(
          model.input.username,
          model.input.password,
        )),
        "Accedi",
      ),
    ]),
  ])
}
