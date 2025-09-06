import birl.{type Time}
import rsvp.{type Error}

pub type LoginModel {
  LoginModel(username: String, password: String)
}

pub type Page {
  LoginPage
  MenuPage
  SearchPage
  ChatPage
}

pub type Msg {
  UserLogin(LoginModel)
  LoginSubmit(Result(Profile, Error))
  UserLogout
  SendMessage(Message)
  MessageSended(Result(List(Message), Error))
  ChangePage(Page)
  ReceiveNewMessage(Result(List(Message), Error))
  MessageRequest
}

pub type Model {
  Model(profile: Profile, page: Page, chats: List(Chat))
}

pub type Profile {
  LoggedUser(username: String, token: String)
  Unlogged
}

pub type Chat {
  Chat(with: String, messages: List(Message))
}

pub type Message {
  Message(time: Time, text: String, from: String, to: String, read: Bool)
}
