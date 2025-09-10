import birl.{type Time}
import rsvp.{type Error}

pub type LoginModel {
  LoginModel(username: String, password: String)
}

pub type RegistrationModel {
  RegistrationModel(username: String, password: String, email: String)
}

pub type Page {
  LoginPage
  RegisterPage
  MenuPage
  SearchPage
  ChatPage(String)
  EditProfile
}

pub type Msg {
  UserLogin(LoginModel)
  UserRegistration(RegistrationModel)
  EditProfileEvent
  EditProfileSubmit(Result(Bool, Error))
  LoadPictureEvent
  LoadPictureSubmit(String)
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
  StopLoading
  NoneEvent
}

pub type InputType {
  InputUsername
  InputPassword
  InputNewPassword
  InputSearch
  InputChat
  InputEmail
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
  Input(
    username: String,
    password: String,
    new_password: String,
    search: String,
    chat: String,
    email: String,
  )
}

pub type Profile {
  LoggedUser(username: String, token: String, email: String)
  Unlogged
}

pub type Chat {
  Chat(with: String, has_new: Bool, messages: List(Message))
}

pub type Message {
  Message(time: Time, text: String, from: String, to: String, read: Bool)
}
