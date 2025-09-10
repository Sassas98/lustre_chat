import birl
import component/button
import component/input
import component/util
import fun
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import types

pub fn chat_view(model: types.Model, to: String) -> Element(types.Msg) {
  let user = case model.profile {
    types.LoggedUser(username, _, _) -> username
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
          types.LoggedUser(username, _, _) -> "<<" <> username <> ">>"
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
          "bg-[url('/chat.svg')] bg-no-repeat bg-center bg-cover w-[100%] md:m-2 p-4 h-[50vh] overflow-auto rounded-lg flex flex-col gap-1",
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
                    "p-2 rounded max-w-[80vw] overflow-auto "
                    <> case m.read, m.from == to {
                      _, False -> "bg-sky-300/70"
                      False, True -> "bg-orange-300/70"
                      True, True -> "bg-violet-300/70"
                    },
                  ),
                ],
                [
                  html.div([attribute.class("text-xs text-right")], [
                    html.text(fun.format_dt(m.time)),
                  ]),
                  html.div(
                    [
                      attribute.class(case string.length(m.text) / 40 {
                        0 -> "text-lg md:test-xl"
                        1 -> "text-base md:text-lg"
                        2 -> "text-sm md:text-base"
                        3 -> "text-xs md:text-sm"
                        _ -> "text-[8px] md:text-xs"
                      }),
                    ],
                    m.text
                      |> string.split("\n")
                      |> list.flat_map(fn(s) { [html.text(s), html.br([])] }),
                  ),
                ],
              ),
            ],
          )
        }),
    ),
    html.div([attribute.class("flex flex-row gap-1")], [
      html.label(
        [
          attribute.for("input_file"),
          attribute.class(
            "flex items-center pr-3 pl-1 justify-center w-12 h-12 rounded-full bg-blue-500 text-white cursor-pointer shadow-md transition bg-violet-700 hover:bg-violet-600",
          ),
        ],
        [
          html.img([
            attribute.src("/molletta.svg"),
            attribute.class("w-6 h-6"),
          ]),
        ],
      ),
      html.input([
        attribute.class("hidden"),
        attribute.id("input_file"),
        attribute.type_("file"),
        event.on_change(fn(_f) { types.LoadPictureEvent }),
        attribute.accept(["image/*"]),
      ]),
      input.only_text_input(
        types.InputChat,
        model.input.chat,
        types.SendMessage(types.Message(
          birl.now(),
          model.input.chat,
          user,
          to,
          False,
        )),
      ),
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
