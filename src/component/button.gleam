import lustre/attribute
import lustre/element/html
import lustre/event
import types

fn btn(action: types.Msg, label: String, wind: String) {
  html.button(
    [
      attribute.class(
        "px-6 py-2 rounded-full transaction-color ease-in duration-200 font-bold cursor-pointer min-w-24 "
        <> wind,
      ),
      event.on_click(action),
    ],
    [
      html.text(label),
    ],
  )
}

pub fn primary_btn(action: types.Msg, label: String) {
  btn(
    action,
    label,
    "bg-violet-700 text-white hover:bg-white hover:text-violet-600",
  )
}

pub fn secondary_btn(action: types.Msg, label: String) {
  btn(
    action,
    label,
    "bg-gray-700 text-white hover:bg-white hover:text-gray-600",
  )
}

pub fn danger_btn(action: types.Msg, label: String) {
  btn(action, label, "bg-red-600 text-white hover:bg-whitehover:text-red-600")
}
