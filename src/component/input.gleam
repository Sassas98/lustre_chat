import lustre/attribute
import lustre/element/html
import lustre/event
import types

fn input(
  tipology: String,
  label: String,
  action: fn(String) -> types.Msg,
  div_wind: String,
  value: String,
) {
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
  html.div([attribute.class(div_wind)], [
    html.label([attribute.class("text-lg")], [
      html.text(label),
    ]),
    html.input([
      attribute.type_(tipology),
      event.on_input(action),
      attribute.class(input_class),
      attribute.value(value),
    ]),
  ])
}

pub fn text_input(
  label: String,
  input_type: types.InputType,
  div_wind: String,
  value: String,
) {
  input(
    "text",
    label,
    fn(x) { types.InputEvent(x, input_type) },
    div_wind,
    value,
  )
}

pub fn password_input(
  label: String,
  input_type: types.InputType,
  div_wind: String,
  value: String,
) {
  input(
    "password",
    label,
    fn(x) { types.InputEvent(x, input_type) },
    div_wind,
    value,
  )
}
