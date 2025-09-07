import birl
import component/button
import component/input
import component/util
import fun
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import types

pub fn chat_view(model: types.Model, to: String) -> Element(types.Msg) {
  let user = case model.profile {
    types.LoggedUser(username, _) -> username
    _ -> ""
  }
  let chat = case
    model.chats
    |> list.find(fn(c) { c.with == to })
  {
    Ok(c) -> c.messages
    _ -> []
  }
  util.card([
    html.div([], [
      button.secondary_btn(types.ChangePage(types.MenuPage), "Indietro"),
    ]),
    html.div([attribute.class("font-bold text-xl md:text-3xl")], [
      html.text(
        case model.profile {
          types.LoggedUser(username, _) -> "<<" <> username <> ">>"
          _ -> ""
        }
        <> " : "
        <> "<<"
        <> to
        <> ">>",
      ),
    ]),
    html.div(
      [
        attribute.id("chat-div"),
        attribute.class(
          "bg-black w-[100%] m-2 p-4 h-64 overflow-auto rounded-lg flex flex-col gap-1",
        ),
      ],
      chat
        |> list.map(fn(m) {
          html.div(
            [
              attribute.class(
                "w-[100%] flex "
                <> case m.from == to {
                  True -> "justify-start"
                  False -> "justify-end"
                },
              ),
            ],
            [
              html.div(
                [
                  attribute.class(
                    "p-2 rounded "
                    <> case m.read {
                      True -> "bg-white"
                      False -> "bg-yellow-300/70"
                    },
                  ),
                ],
                [
                  html.div([attribute.class("text-xs text-right")], [
                    html.text(fun.format_dt(m.time)),
                  ]),
                  html.div([attribute.class("text-lg")], [html.text(m.text)]),
                ],
              ),
            ],
          )
        }),
    ),
    html.div([attribute.class("flex flex-row gap-1")], [
      input.only_text_input(types.InputChat, model.input.chat),
      button.primary_btn(
        types.SendMessage(types.Message(
          birl.now(),
          model.input.chat,
          user,
          to,
          False,
        )),
        "Invia",
      ),
    ]),
  ])
}
