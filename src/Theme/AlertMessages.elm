module Theme.AlertMessages exposing (viewAlertMessages)

import ClientTypes exposing (..)
import Html exposing (Html, br, div, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import TranslationHelper exposing (getInLanguage)


viewAlertMessages : List String -> String -> Html ClientTypes.Msg
viewAlertMessages lAlertMessages lgId =
    if List.length lAlertMessages /= 0 then
        div [ class "alert" ] <|
            ((lAlertMessages
                |> List.map (\x -> text <| getInLanguage lgId x)
                |> List.intersperse (br [] [])
             )
                ++ [ span [ class "close", onClick CloseAlert ] [ text "X" ] ]
            )

    else
        text ""
