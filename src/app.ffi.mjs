import { Ok, Error } from "./gleam.mjs";

export function get_profile() {
  const json = window.localStorage.getItem("profile");
  if (json === null) return new Error(undefined);

  try {
    return new Ok(JSON.parse(json));
  } catch {
    return new Error(undefined);
  }
}

export function set_profile(username, token, email) {
  let json = JSON.stringify({
    username: username,
    token: token,
    email: email
  })
  window.localStorage.setItem("profile", json);
}

export function remove_profile() {
  window.localStorage.removeItem("profile");
}

export function set_timeout(delay, cb) {
  window.setTimeout(cb, delay);
}