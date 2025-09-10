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

export async function wireImageUploader(id, upload_url) {
  const input = document.getElementById(id);
  if (!input) {
    return "input not found";
  }

  const file = input.files?.[0];
  if (!file) {
    return "no file selected";
  }

  const formData = new FormData();
  formData.append("image", file);
  console.log(file)

  try {
    const res = await fetch(upload_url, {
      method: "POST",
      body: formData,
    });

    if (!res.ok) {
      return "upload failed: " + res.statusText;
    }

    const data = await res.json().catch(() => null);

    return data?.ascii
  } catch (err) {
    return "network error: " + err.message;
  }
}