module Theme.Locations exposing (view)

import ClientTypes exposing (..)
import Components exposing (..)
import GpsUtils
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import TranslationHelper exposing (getInLanguage)
import Tuple


view :
    List ( GpsUtils.Direction, Entity )
    -> Entity
    -> String
    -> Bool
    -> Html Msg
view exits currentLocation lgId bWithSidebar =
    let
        interactableView msg entity direction =
            span []
                [ span
                    [ class "CurrentSummary__StoryElement u-selectable"
                    , onClick <| msg <| Tuple.first entity
                    ]
                    [ text <|
                        (.name <| getSingleLgDisplayInfo lgId entity)
                    ]
                , text (" is to the " ++ GpsUtils.directionToString direction)
                ]

        formatIt bWithSidebarArg list =
            let
                interactables =
                    if bWithSidebarArg then
                        List.intersperse (br [] []) list

                    else
                        List.intersperse (text ", ") list
            in
            if bWithSidebarArg then
                interactables
                    |> p []

            else
                interactables
                    ++ [ text "." ]
                    |> (::) (text <| getInLanguage lgId "Connecting locations : ")
                    |> p []

        theExitsList =
            if not <| List.isEmpty exits then
                exits
                    |> List.map (\( direction, entity ) -> interactableView Interact entity direction)
                    |> formatIt bWithSidebar
                --|> if ( bWithSidebar ) then p[] else (formatToSpan bWithSidebar)

            else
                span [] []

        locationsClass =
            if bWithSidebar then
                "Locations"

            else
                "Locations__NoSidebar"
    in
    div [ class locationsClass ]
        [ if bWithSidebar then
            h3 [] [ text "Connecting locations" ]

          else
            text ""
        , div [ class "Locations__list" ]
            [ {- }
                 if ( not bWithSidebar ) then
                     text "Connecting locations"
                 else
                     text ""
              -}
              theExitsList
            ]
        ]
