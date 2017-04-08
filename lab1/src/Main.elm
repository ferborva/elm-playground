import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

{-
  MODEL
  * Model type
  * Initialize model with empty values
-}

type alias Model =
  { quote: String
  , username: String
  , token: String
  , password: String
  , errorMsg: String
  }


init: (Model, Cmd Msg)
init =
  ( Model "" "" "" "" "", fetchRandomQuoteCmd )


{-
  UPDATE
  * API Routes
  * Encode Request body
  * Decode Response
  * GET
  * Messages
  * Update case
-}

api: String
api =
  "http://localhost:3001/"


registerUrl: String
registerUrl =
  api ++ "users"


randomQuoteUrl: String
randomQuoteUrl =
  api ++ "api/random-quote"


-- ENCODE DECODE code

userEncoder: Model -> Encode.Value
userEncoder model =
  Encode.object
    [ ("username", Encode.string model.username)
    , ("password", Encode.string model.password)
    ]    


-- POST registration / login request

authUser: Model -> String -> Http.Request String
authUser model authUrl =
  let
    body =
      model
      |> userEncoder
      |> Http.jsonBody
  in
    Http.post authUrl body tokenDecoder

-- Auth Command

authUserCmd: Model -> String -> Cmd Msg
authUserCmd model authUrl =
  Http.send GetTokenCompleted (authUser model authUrl)


-- Auth Token Completed Handler

getTokenCompleted : Model -> Result Http.Error String -> (Model, Cmd Msg)
getTokenCompleted model result =
  case result of
    Ok newToken ->
      ( { model | token = newToken, password = "", errorMsg = "" } |> Debug.log "Got a new token!", Cmd.none )

    Err error ->
      ( { model | errorMsg = (toString error) }, Cmd.none )


-- Token Decoder

tokenDecoder: Decoder String
tokenDecoder =
  Decode.field "id_token" Decode.string


fetchRandomQuote: Http.Request String
fetchRandomQuote =
  Http.getString randomQuoteUrl


fetchRandomQuoteCmd: Cmd Msg
fetchRandomQuoteCmd =
  Http.send FetchRandomQuoteCompleted fetchRandomQuote


fetchRandomQuoteCompleted: Model -> Result Http.Error String -> ( Model, Cmd Msg )
fetchRandomQuoteCompleted model result =
  case result of
    Ok newQuote ->
      ( { model | quote = newQuote }, Cmd.none )
    
    Err _ ->
      ( model, Cmd.none )


type Msg =
  GetQuote
  | FetchRandomQuoteCompleted (Result Http.Error String)
  | SetUsername String
  | SetPassword String
  | ClickRegisterUser
  | GetTokenCompleted (Result Http.Error String)

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetQuote ->
      ( model, fetchRandomQuoteCmd )

    FetchRandomQuoteCompleted result ->
      fetchRandomQuoteCompleted model result

    SetUsername newName ->
      ( { model | username = newName }, Cmd.none )

    SetPassword newPass ->
      ( { model | password = newPass }, Cmd.none )

    ClickRegisterUser ->
      ( model, authUserCmd model registerUrl )

    GetTokenCompleted result ->
      getTokenCompleted model result


{-
  VIEW
  * Hide sections of view depending on auth state
  * Get a quote
  * Register/login
-}

view: Model -> Html Msg
view model = 
  let
    -- Is user logged in?
    logged: Bool
    logged =
      if String.length model.token > 0 then
        True
      else
        False

    -- If the user is logged in, show greeting.
    -- If not logged show register/login form
    authBoxView = 
      let
        -- If there is an error on Auth: show alert
        showError: String
        showError =
          if String.isEmpty model.errorMsg then
            "hidden"
          else
            ""

        -- Greet a logged user with username
        greeting: String
        greeting =
          "Hello " ++ model.username ++ "!"

      in
        if logged then
          div [ id "greeting"]
            [ h3 [ class "text-center" ] [ text greeting ]
            , p [ class "text-center" ] [ text "You have super secret access to protected quotes :)" ]
            ]

        else
          div [ id "form" ]
            [ h2 [ class "text-center"] [ text "Log in or Register" ]
            , p [ class "help-block" ] [ text "If you already have and account, use your username and password. Otherwise, enter you desired account details and click Register." ] 
            , div [ class "showError" ]
              [ div [ class "alert alert-danget" ] [ text model.errorMsg ] ]
            , div [ class "form-group row" ]
              [ div [ class "col-md-offset-2 col-md-8" ]
                  [ label [ for "username" ] [ text "Username:" ]
                  , input [ id "username", type_ "username", class "form-control", Html.Attributes.value model.username, onInput SetUsername ] []
                  ]
              ]
            , div [ class "form-group row" ]
              [ div [ class "col-md-offset-2 col-md-8" ]
                  [ label [ for "password" ] [ text "Password:" ]
                  , input [ id "password", type_ "password", class "form-control", Html.Attributes.value model.password, onInput SetPassword ] []
                  ]
              ]
            , div [ class "text-center" ]
              [ button [ class "btn btn-link", onClick ClickRegisterUser ] [ text "Register" ]
              ]
            ]          


  in
    div [ class "container" ]
      [ h2 [ class "text-center" ] [ text "Chuck Norris Quotes" ]
      , p [ class "text-center" ]
        [ button [ class "btn btn-success", onClick GetQuote ]
          [ text "Grab a Quote!" ]
        ]
      , blockquote []
        [ p [] [ text model.quote ] ]
      , div [ class "jumbotron text-left" ]
        [ -- Login/Register form or user greeting
          authBoxView
        ]
      ]

main: Program Never Model Msg
main =
  Html.program
    { init = init
    , update = update
    , subscriptions = \_ -> Sub.none
    , view = view
    }
