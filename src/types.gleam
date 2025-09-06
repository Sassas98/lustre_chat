import birl.{type Time}
import rsvp.{type Error}

pub type LoginModel {
  LoginModel(username: String, password: String)
}

pub type Page {
  LoginPage
  RegisterPage
  MenuPage
  SearchPage
  ChatPage(String)
}

pub type Msg {
  UserLogin(LoginModel)
  UserRegistration(LoginModel)
  LoginSubmit(Result(Profile, Error))
  RegistrationSubmit(Result(Bool, Error))
  UserLogout
  SendMessage(Message)
  MessageSended(Result(List(Message), Error))
  ChangePage(Page)
  ReceiveNewMessage(Result(List(Message), Error), Bool)
  MessageRequest
  SearchUsername(String)
  HandleUsernamesReturn(Result(List(String), Error))
  InputEvent(String, InputType)
  ErrorAccept
}

pub type InputType {
  InputUsername
  InputPassword
  InputSearch
  InputChat
}

pub type Model {
  Model(
    profile: Profile,
    page: Page,
    chats: List(Chat),
    search_chat: List(String),
    in_loading: Bool,
    input: Input,
    env: String,
    error: String,
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
