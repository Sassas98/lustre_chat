import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import types

pub fn login_view(model: types.Model) -> Element(types.Msg) {
  html.div([attribute.class("")], [
    html.span([attribute.class("")], [html.text("LOGIN")]),
  ])
}
