import component/button
import component/input
import component/util
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import types

pub fn search_view(model: types.Model) -> Element(types.Msg) {
  util.card([
    html.div([], [
      button.secondary_btn(types.ChangePage(types.MenuPage), "Indietro"),
    ]),
    html.div(
      [attribute.class("flex flex-col items-center justify-center gap-4")],
      [
        input.text_input(
          "Cerca username",
          types.InputSearch,
          "",
          model.input.search,
          types.SearchUsername(model.input.search),
        ),
        button.primary_btn(types.SearchUsername(model.input.search), "Cerca"),
      ],
    ),
    html.div(
      [attribute.class("flex flex-col gap-2")],
      model.search_chat
        |> list.map(fn(c) {
          html.div(
            [
              attribute.class(
                "p-2 cursor-pointer text-center text-xl font-bold bg-white/70 hover:bg-black hover:text-white rounded-full mx-[10%] md:mx-[25%] transition-all ease-in duration-200",
              ),
              event.on_click(types.ChangePage(types.ChatPage(c))),
            ],
            [html.text(c)],
          )
        }),
    ),
  ])
}
