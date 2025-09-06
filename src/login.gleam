import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import types

pub fn login_view(model: types.Model) -> Element(types.Msg) {
  let input_class =
    " w-[100%]
    rounded-xl
    border
    border-slate-300
    bg-white
    px-4
    py-2
    text-slate-800
    placeholder-slate-400
    shadow-sm
    focus:border-violet-500
    focus:shadow-[0_0_12px_2px_rgba(139,92,246,0.6)]
    focus:outline-none
    transition"
  html.div(
    [
      attribute.class(
        "bg-gradient-to-b from-slate-50 to-slate-300 w-[100vw] md:w-[50vw] text-black md:mt-12 p-4 md:rounded-2xl flex flex-col gap-8 md:gap-4 h-[100vh] md:h-auto",
      ),
    ],
    [
      html.span(
        [
          attribute.class(
            "bg-gradient-to-b from-slate-800 to-violet-400 bg-clip-text text-transparent text-6xl font-bold",
          ),
        ],
        [html.text("LOGIN")],
      ),
      html.div([attribute.class("md:w-[50%] md:mx-[25%]")], [
        html.label([attribute.class("flex flex-col gap-2 text-lg")], [
          html.text("Username"),
        ]),
        html.input([
          attribute.type_("text"),
          event.on_input(types.InputUsername),
          attribute.class(input_class),
        ]),
      ]),
      html.div([attribute.class("md:w-[50%] md:mx-[25%]")], [
        html.label([attribute.class("flex flex-col gap-2 text-lg")], [
          html.text("Password"),
        ]),
        html.input([
          attribute.type_("password"),
          event.on_input(types.InputUsername),
          attribute.class(input_class),
        ]),
      ]),
      html.div([attribute.class("flex justify-center")], [
        html.button(
          [
            attribute.class(
              "px-6 py-2 rounded-full bg-violet-700 text-white w-24 hover:bg-white hover:text-violet-700 transaction-color ease-in duration-200 font-bold cursor-pointer",
            ),
            event.on_click(
              types.UserLogin(types.LoginModel(
                model.input.username,
                model.input.password,
              )),
            ),
          ],
          [
            html.text("Accedi"),
          ],
        ),
      ]),
    ],
  )
}
