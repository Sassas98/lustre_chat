import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import types

pub fn card(body: List(Element(types.Msg))) {
  html.div(
    [
      attribute.class(
        "bg-gradient-to-b from-slate-50/90 to-slate-300/90 w-[100vw] md:w-[50vw] text-black md:mt-12 p-4 md:rounded-2xl flex flex-col gap-8 md:gap-4 h-[100vh] md:h-auto",
      ),
    ],
    body,
  )
}

pub fn title(text: String) {
  html.span(
    [
      attribute.class(
        "bg-gradient-to-b from-slate-800 to-violet-400 bg-clip-text text-transparent text-6xl font-bold",
      ),
    ],
    [html.text(text)],
  )
}
