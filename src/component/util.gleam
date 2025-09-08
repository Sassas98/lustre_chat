import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import types

pub fn card(body: List(Element(types.Msg))) {
  html.div(
    [
      attribute.class(
        "w-[100vw] md:w-[50vw] text-slate-800 md:mt-12 p-4 md:rounded-2xl flex flex-col gap-8 md:gap-4 h-[100vh] md:h-auto bg-[url('/card.svg')] bg-no-repeat bg-center bg-cover",
      ),
    ],
    body,
  )
}

pub fn title(text: String) {
  html.span(
    [
      attribute.class("text-slate-800 text-6xl font-bold"),
    ],
    [html.text(text)],
  )
}
