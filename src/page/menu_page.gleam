import component/button
import component/util
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import types

pub fn menu_view(model: types.Model) -> Element(types.Msg) {
  util.card([
    html.div(
      [
        attribute.class(
          "md:h-12 flex items-center flex-col-reverse md:flex-row md:justify-between gap-4",
        ),
      ],
      [
        html.div([attribute.class("font-bold text-3xl")], [
          html.text(case model.profile {
            types.LoggedUser(username, _) -> "<<" <> username <> ">>"
            _ -> ""
          }),
        ]),
        html.div([attribute.class("flex flex-row gap-4")], [
          button.secondary_btn(types.UserLogout, "Logout"),
          button.primary_btn(
            types.ChangePage(types.SearchPage),
            "Cerca da username",
          ),
        ]),
      ],
    ),
    html.div(
      [attribute.class("flex flex-col gap-2")],
      model.chats
        |> list.map(fn(c) {
          html.div(
            [
              attribute.class(
                "p-2 cursor-pointer font-bold text-center text-xl rounded-full mx-[10%] md:mx-[25%] transition-all ease-in duration-200 "
                <> case c.has_new {
                  True ->
                    "text-black bg-yellow-300/70 hover:bg-black hover:text-yellow-300"
                  False -> "text-black bg-white hover:bg-black hover:text-white"
                },
              ),
              event.on_click(types.ChangePage(types.ChatPage(c.with))),
            ],
            [html.text("<<" <> c.with <> ">>")],
          )
        }),
    ),
  ])
}
