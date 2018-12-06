module OurStory.Manifest exposing (characters, items, locations, playerId)

import Components exposing (..)
import Dict exposing (Dict)
import GpsUtils exposing (Direction(..))
import OurStory.Narrative as Narrative
import OurStory.NarrativeDSFuncs as NarrativeDSFuncs
    exposing
        ( getOptionId
        , getQuestionId
        , getStageId
        )
import OurStory.Rules as Rules



{- Here is where you define your manifest -- all of the items, characters, and locations in your story. You can add what ever components you wish to each entity.  Note that the first argument to `entity` is the id for that entity, which is the id you must refer to in your rules.
   In the current theme, the description in the display info component is only used as a fallback narrative if a rule does not match with a more specific narrative when interacting with that story object.
-}


{-| make sure this is the same as defined below on characters
-}
playerId : String
playerId =
    "playerOne"


initialItems : List Entity
initialItems =
    [ entity "gameStateItem"
    , entity "gps"
        |> addDisplayInfo "GPSr" "Magical Instrument that helps you navigate"
        |> addLgDisplayInfo "pt" "GPSr" "Instrumento mágico que te ajuda a navegar no terreno."
        |> addNeedsGpsInfo True
    , entity "goalsStatusPaper"
        |> addDisplayInfo "goals report" "goals report"
        |> addLgDisplayInfo "pt" "goals report" "goals report"
    , entity "standardQuestion"
        |> addDisplayInfo "question" "question Description"
        |> addLgDisplayInfo "pt" "questão" "descrição da questão"
    , entity "creditsInfo"
        |> addDisplayInfo "credits" "credits Info"
        |> addLgDisplayInfo "pt" "credits" "credits Info"
    , entity "finalPaper"
        |> addDisplayInfo "old paper" "old paper with some info written in it"
        |> addLgDisplayInfo "pt" "papiro" "papiro com alguma informação escrita"
    ]


getListOfItems : List Entity -> List Int -> List Int -> List Entity
getListOfItems initItems lQuestionNrs lMultiOptionNrs =
    let
        createQuestionEntity : Int -> Entity
        createQuestionEntity nr =
            entity (NarrativeDSFuncs.getQuestionId nr)
                |> addDisplayInfo (NarrativeDSFuncs.getQuestionName nr "en") (NarrativeDSFuncs.getQuestionBodyAsString nr "en")
                |> addLgDisplayInfo "pt" (NarrativeDSFuncs.getQuestionName nr "pt") (NarrativeDSFuncs.getQuestionBodyAsString nr "pt")

        createMultiOptionEntity : Int -> Entity
        createMultiOptionEntity nr =
            entity (NarrativeDSFuncs.getOptionId nr)
                |> addDisplayInfo (NarrativeDSFuncs.getMultiOptionName nr "en") (NarrativeDSFuncs.getMultiOptionBodyAsString nr "en")
                |> addLgDisplayInfo "pt" (NarrativeDSFuncs.getMultiOptionName nr "pt") (NarrativeDSFuncs.getMultiOptionBodyAsString nr "pt")

        createResetMultiOptionEntity : Int -> Int -> Entity
        createResetMultiOptionEntity index nr =
            entity ("reset_" ++ NarrativeDSFuncs.getOptionId nr)
                |> addDisplayInfo ("reset_" ++ NarrativeDSFuncs.getMultiOptionName nr "en") ("reset_" ++ NarrativeDSFuncs.getMultiOptionBodyAsString nr "en")
                |> addDisplayInfo ("reset_" ++ NarrativeDSFuncs.getMultiOptionName nr "pt") ("reset_" ++ NarrativeDSFuncs.getMultiOptionBodyAsString nr "pt")

        moreQuestionItems : List Entity
        moreQuestionItems =
            lQuestionNrs
                |> List.map createQuestionEntity

        moreMultiOptionItems : List Entity
        moreMultiOptionItems =
            lMultiOptionNrs
                |> List.map createMultiOptionEntity

        multiOptionResets : List Entity
        multiOptionResets =
            lMultiOptionNrs
                |> List.indexedMap (\index nr -> createResetMultiOptionEntity index nr)
    in
    List.append initItems moreQuestionItems
        |> List.append moreMultiOptionItems
        |> List.append multiOptionResets


items : List Entity
items =
    getListOfItems initialItems NarrativeDSFuncs.getFilteredStageQuestionNrs NarrativeDSFuncs.getFilteredStageMultiOptionNrs


characters : List Entity
characters =
    [ entity "playerOne"
        |> addDisplayInfo "investigator" "You ..."
        |> addLgDisplayInfo "pt" "investigador" "Tu ..."
    ]


initialLocations : List Entity
initialLocations =
    [ entity "onceUponAtime"
        |> addDisplayInfo "Once Upon a Time" "Once Upon a Time"
        |> addLgDisplayInfo "pt" "Era Uma Vez ..." "Era Uma Vez ..."
        |> addConnectingLocations [ ( West, "stage1" ) ]
    ]


getStageCoordInfo : Int -> Maybe { latitude : Float, longitude : Float, mbRadius : Maybe Float, bRequiredToBeIn : Bool }
getStageCoordInfo stageNr =
    let
        dictCoordInfo : Dict Int { latitude : Float, longitude : Float, mbRadius : Maybe Float, bRequiredToBeIn : Bool }
        dictCoordInfo =
            Dict.fromList
                [ ( 1, { latitude = 38.7952, longitude = -9.391733, mbRadius = Nothing, bRequiredToBeIn = False } )
                , ( 2, { latitude = 38.795033, longitude = -9.391517, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 3, { latitude = 38.79475, longitude = -9.3914, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 4, { latitude = 38.7943, longitude = -9.391567, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 5, { latitude = 38.79395, longitude = -9.391267, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 6, { latitude = 38.793717, longitude = -9.391167, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 7, { latitude = 38.793733, longitude = -9.39095, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 8, { latitude = 38.793367, longitude = -9.391167, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 9, { latitude = 38.792367, longitude = -9.391267, mbRadius = Nothing, bRequiredToBeIn = True } )
                , ( 10, { latitude = 38.7922, longitude = -9.3913, mbRadius = Nothing, bRequiredToBeIn = True } )
                ]
    in
    dictCoordInfo
        |> Dict.get stageNr


getListOfLocations : List Entity -> Int -> List Entity
getListOfLocations initLocations nrLocations =
    let
        getDirection : Int -> Int -> GpsUtils.Direction
        getDirection s1 s2 =
            case ( getStageCoordInfo s1, getStageCoordInfo s2 ) of
                ( Just coordsRec1, Just coordsRec2 ) ->
                    GpsUtils.calculateBearing ( coordsRec1.latitude, coordsRec1.longitude ) ( coordsRec2.latitude, coordsRec2.longitude )
                        |> toFloat
                        |> GpsUtils.bearingToDirection

                ( _, _ ) ->
                    if s2 >= s1 then
                        West

                    else
                        East

        getConnectingLocations stageNr =
            if stageNr == 1 then
                [ ( getDirection 1 2, "stage2" ) ]

            else if stageNr == nrLocations then
                [ ( getDirection nrLocations (nrLocations - 1), NarrativeDSFuncs.getStageId (nrLocations - 1) ) ]

            else
                [ ( getDirection stageNr (stageNr + 1), NarrativeDSFuncs.getStageId (stageNr + 1) )
                , ( getDirection stageNr (stageNr - 1), NarrativeDSFuncs.getStageId (stageNr - 1) )
                ]

        mbAddCoordInfo stageNr entity =
            case getStageCoordInfo stageNr of
                Nothing ->
                    entity

                Just coordsRec ->
                    entity
                        |> addNeedsToBeInGpsZone coordsRec.bRequiredToBeIn coordsRec.latitude coordsRec.longitude coordsRec.mbRadius

        createEntity nr =
            entity (NarrativeDSFuncs.getStageId nr)
                |> addDisplayInfo (NarrativeDSFuncs.getStageName nr "en") (NarrativeDSFuncs.interactingWithStageN nr "en" "defaultStageDescription" |> String.join " , ")
                |> addLgDisplayInfo "pt" (NarrativeDSFuncs.getStageName nr "pt") (NarrativeDSFuncs.interactingWithStageN nr "pt" "defaultStageDescription" |> String.join " , ")
                |> addConnectingLocations (getConnectingLocations nr)
                |> mbAddCoordInfo nr

        moreLocations =
            List.range 1 nrLocations
                |> List.map createEntity
    in
    List.append initLocations moreLocations


locations : List Entity
locations =
    getListOfLocations initialLocations NarrativeDSFuncs.getNumberOfDesiredStages
