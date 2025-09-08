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
  enter_event: types.Msg,
) {
  html.div([attribute.class(div_wind)], [
    html.label([attribute.class("text-lg")], [
      html.text(label),
    ]),
    only_input(tipology, action, value, enter_event),
  ])
}

fn only_input(
  tipology: String,
  action: fn(String) -> types.Msg,
  value: String,
  enter_event: types.Msg,
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
  html.input([
    attribute.type_(tipology),
    event.on_input(action),
    attribute.class(input_class),
    attribute.value(value),
    event.on_keydown(fn(s) {
      case s {
        "Enter" -> enter_event
        _ -> types.NoneEvent
      }
    }),
  ])
}

pub fn only_text_input(
  input_type: types.InputType,
  value: String,
  enter_event: types.Msg,
) {
  only_input(
    "text",
    fn(x) { types.InputEvent(x, input_type) },
    value,
    enter_event,
  )
}

pub fn text_input(
  label: String,
  input_type: types.InputType,
  div_wind: String,
  value: String,
  enter_event: types.Msg,
) {
  input(
    "text",
    label,
    fn(x) { types.InputEvent(x, input_type) },
    div_wind,
    value,
    enter_event,
  )
}

pub fn password_input(
  label: String,
  input_type: types.InputType,
  div_wind: String,
  value: String,
  enter_event: types.Msg,
) {
  input(
    "password",
    label,
    fn(x) { types.InputEvent(x, input_type) },
    div_wind,
    value,
    enter_event,
  )
}
