import lustre
import lustre/attribute
import lustre/element/html

pub fn main() {
  let app =
    lustre.element(
      html.span([attribute.class("text-slate-500 bg-green-300")], [
        html.text("Hello, world!"),
      ]),
    )
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
