module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

init : () -> (Model, Cmd Msg)
init _
  = ({ status = Loading
     , savedText = ""
     , currentText = "" }
    , getText "/welcome.txt")


-- UPDATE

type Msg
  = GotText (Result Http.Error String)
  | Input String
  | KeyDown Int
  | Clicked

type Status
  = Failure
  | Loading
  | Success String

type alias Model
  = { status : Status
    , savedText : String
    , currentText : String
    }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Clicked ->
      ({ model | status = Loading
               , currentText = ""
               }
      , getText model.currentText)
    Input newContent ->
      ({ model | currentText = newContent }, Cmd.none)

    KeyDown key ->
      if key == 13 then
        case model.currentText of
          ""  -> ({ model | status = Failure }, Cmd.none)
          "/" -> ({ model | status = Failure }, Cmd.none)
          _   -> ({ model | status = Loading
                  , currentText = ""
                  }
                 , getText model.currentText)
      else
        (model, Cmd.none)

    GotText res ->
      case res of
        Ok result ->
          ({ model | status = Success result }, Cmd.none)

        Err _ ->
          ({ model | status = Failure }, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


view : Model -> Html Msg
view model =
  div [ id "content" ]
    [ div [ id "input" ] [ input [ value model.currentText
                     , onKeyDown KeyDown
                     , onInput Input ] []
             , button [ onClick Clicked ] [ text "Get" ]
      ]
    , viewGet model
    ]


viewGet : Model -> Html Msg
viewGet model =
  case model.status of
    Failure ->
      pre [] [ text "could not get" ]

    Loading ->
      pre [] [ text "loading..." ]

    Success result ->
      pre [] [ text result ]


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
  on "keydown" (D.map tagger keyCode)


getText : String -> Cmd Msg
getText s =
  Http.get
    { url = s
    , expect = Http.expectString GotText
    }

