module Hello exposing (view)

{-| This is a demo of a parrot component which shows the text of an input field in the title

@docs view

-}

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (defaultValue, class)


{-| Renders the hello view
-}
view : String -> String -> (String -> msg) -> Html msg
view hello_str current_lang msgInput =
    div [ class "hello" ]
        [ h1 [] [ text hello_str ]
        , input [ onInput msgInput, defaultValue current_lang ] []
        ]
