import birl.{type Time}
import rsvp.{type Error}

pub type LoginModel {
  LoginModel(username: String, password: String)
}

pub type Page {
  LoginPage
  MenuPage
  SearchPage
  ChatPage(String)
}

pub type Msg {
  UserLogin(LoginModel)
  LoginSubmit(Result(Profile, Error))
  UserLogout
  SendMessage(Message)
  MessageSended(Result(List(Message), Error))
  ChangePage(Page)
  ReceiveNewMessage(Result(List(Message), Error), Bool)
  MessageRequest
  SearchUsername(String)
  HandleUsernamesReturn(Result(List(String), Error))
  InputUsername(String)
  InputPassword(String)
  InputSearch(String)
  InputChat(String)
}

pub type Model {
  Model(
    profile: Profile,
    page: Page,
    chats: List(Chat),
    search_chat: List(String),
    in_loading: Bool,
    input: Input,
  )
}

pub type Input {
  Input(username: String, password: String, search: String, chat: String)
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
