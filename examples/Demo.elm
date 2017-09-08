module Main exposing (..)

import Html exposing (..)
import Hello
import Http
import MockHttp exposing (Endpoint(..))
import Json.Decode as Decode exposing (string, Decoder, list)
import Json.Decode.Pipeline exposing (decode, required)
import Dict exposing (Dict, fromList)


type alias Model =
    { language : String
    , words : Dict String String
    , err : Maybe String
    }


type Msg
    = SetLanguage String
    | UpdateLanguages (Result Http.Error (List Language))


type alias Language =
    { language : String
    , hello : String
    }


mockConfig : MockHttp.Config
mockConfig =
    MockHttp.config
        [ Get
            { url = "https://mock.com/api/hello"
            , response = """
                [{"language":"es","hello":"Bienvenidos"},{"language":"en","hello":"Hello"},{"language":"fr","hello":"Bonjour"}]
              """
            , responseTime = 400
            }
        ]


decodeLanguage : Decoder Language
decodeLanguage =
    decode Language
        |> required "language" string
        |> required "hello" string


convertLanguageListToDict : List Language -> Dict String String
convertLanguageListToDict language_list =
    fromList <| List.map (\x -> ( x.language, x.hello )) language_list


loadLanguages : (Result Http.Error (List Language) -> msg) -> Cmd msg
loadLanguages msg =
    MockHttp.send mockConfig msg (MockHttp.get "https://mock.com/api/hello" (list decodeLanguage))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLanguage s ->
            ( { model | language = s }, Cmd.none )

        UpdateLanguages result ->
            case result of
                Ok ll ->
                    ( { model | words = convertLanguageListToDict ll }, Cmd.none )

                Err reason ->
                    ( { model | err = Just <| toString reason }, Cmd.none )


init : String -> ( Model, Cmd Msg )
init lang =
    ( Model lang (fromList []) Nothing, loadLanguages UpdateLanguages )


view : Model -> Html Msg
view { language, words, err } =
    let
        hello =
            case Dict.get language words of
                Just s ->
                    s

                Nothing ->
                    "I don't know this language"
    in
        case err of
            Just e ->
                text e

            Nothing ->
                div []
                    [ Hello.view hello language SetLanguage
                    , h5 [] [ text "available languages" ]
                    , ul [] (List.map (\x -> li [] [ text x ]) (Dict.keys words))
                    ]


main =
    Html.program
        { init = init "es"
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
