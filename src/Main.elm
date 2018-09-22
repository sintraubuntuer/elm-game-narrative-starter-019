port module Main exposing
    ( Flags
    , LgTxt
    , Model
    , backendAnswerDecoder
    , convertToListIdExtraInfo
    , findEntity
    , getBackendAnswerInfo
    , getExtraInfoFromModel
    , getHistoryFromStorage
    , getNewModelAndInteractionExtraInfoByEngineUpdate
    , helperEmptyStringToNothing
    , init
    , loaded
    , main
    , playerAnswerEncoder
    , saveHistoryToStorage
    , saveHistoryToStorageHelper
    , sendRequestForStoredHistory
    , subscriptions
    , textInLanguagesDecoder
    , update
    , updateInterExtraInfoWithGeoInfo
    , view
    , viewMainGame
    , viewStartScreen
    )

--import Audio
--import Geolocation

import Browser
import ClientTypes exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import Engine exposing (..)
import GpsUtils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import InfoForBkendApiRequests
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import List.Zipper as ListZipper
import OurStory.Manifest as Manifest
import OurStory.Narrative as Narrative
import OurStory.Rules as Rules
import Random
import Regex
import SomeTests
import Task
import Theme.AnswerBox as AnswerBox exposing (Model, init)
import Theme.EndScreen
import Theme.Layout
import Theme.Settings as Settings
import Theme.StartScreen
import TranslationHelper exposing (getInLanguage)
import Tuple
import TypeConverterHelper as Tconverter exposing (..)
import Types as EngineTypes exposing (AnswerInfo, BackendAnswerStatus(..), InteractionExtraInfo, MoreInfoNeeded(..))
import TypesUpdateHelper exposing (updateNestedBkAnsStatus, updateNestedMbInputTextBk)



--import Update.Extra


{-| This is the kernel of the whole app. It glues everything together and handles some logic such as choosing the correct narrative to display.
You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}



-- MODEL


type alias Model =
    { engineModel : Engine.Model
    , debugMode : Bool
    , baseImgUrl : String
    , baseSoundUrl : String
    , itemsLocationsAndCharacters : List Components.Entity
    , playerName : String
    , answerBoxModel : AnswerBox.Model
    , settingsModel : Settings.Model
    , mbSentText : Maybe String
    , alertMessages : List String
    , geoLocation : Maybe GpsUtils.GeolocationInfo
    , geoDistances : List ( String, Float )
    , defaultZoneRadius : Float
    , bkendAnswerStatusDict : Dict String EngineTypes.BackendAnswerStatus
    , loaded : Bool
    , languageStoryLines : Dict String (List StorySnippet)
    , languageNarrativeContents : Dict String (Dict String (ListZipper.Zipper String))
    , languageAudioContents : Dict String (Dict String ClientTypes.AudioFileInfo)
    , lallgeneretedRandomFloats : List Float
    , displayStartScreen : Bool
    , startScreenInfo : StartScreenInfo
    , displayEndScreen : Bool
    , endScreenInfo : EndScreenInfo
    }


getInteractableInfo : Components.Entity -> Dict String EngineTypes.AttrTypes
getInteractableInfo interactableEntity =
    Dict.fromList [ ( "name", Engine.aDictStringString (Components.getDictLgNames (Dict.keys Narrative.initialChoiceLanguages) interactableEntity) ) ]


init : Flags -> ( Model, Cmd ClientTypes.Msg )
init flags =
    initWithMbPlayerNameAndMbHistoryList flags True [] Nothing []


initWithMbPlayerNameAndMbHistoryList : Flags -> Bool -> List Float -> Maybe String -> List ( String, InteractionExtraInfo ) -> ( Model, Cmd ClientTypes.Msg )
initWithMbPlayerNameAndMbHistoryList flags displayStartScreen_ lPrandomFloats mbPlayerName historyList =
    let
        dictEntities =
            Rules.rules

        engineModel =
            Engine.init
                { items = List.map (\( id, comp ) -> ( id, getInteractableInfo ( id, comp ) )) Manifest.items
                , locations = List.map (\( id, comp ) -> ( id, getInteractableInfo ( id, comp ) )) Manifest.locations
                , characters = List.map (\( id, comp ) -> ( id, getInteractableInfo ( id, comp ) )) Manifest.characters
                }
                Manifest.playerId
                Narrative.initialChoiceLanguages
                (Dict.map (\a b -> getRuleData ( a, b )) dictEntities)
                []

        answerboxmodel =
            AnswerBox.init

        settingsmodel =
            Settings.init Narrative.initialChoiceLanguages

        displaylanguage =
            settingsmodel.displayLanguage

        debugMode_ =
            True

        newModel =
            { engineModel = engineModel
            , debugMode = debugMode_
            , baseImgUrl = flags.baseImgUrl
            , baseSoundUrl = flags.baseSoundUrl
            , itemsLocationsAndCharacters = Manifest.items ++ Manifest.locations ++ Manifest.characters
            , playerName = mbPlayerName |> Maybe.withDefault "___investigator___" -- default
            , answerBoxModel = answerboxmodel
            , settingsModel = settingsmodel
            , mbSentText = Nothing
            , alertMessages = []
            , geoLocation = Nothing
            , geoDistances = []
            , defaultZoneRadius = 50.0
            , bkendAnswerStatusDict =
                (Manifest.items ++ Manifest.locations ++ Manifest.characters)
                    |> List.map Tuple.first
                    |> List.map (\interactableId -> ( interactableId, EngineTypes.NoInfoYet ))
                    |> Dict.fromList
            , loaded = True
            , languageStoryLines = Narrative.startingNarratives

            -- dictionary that associates ruleIds to a dict languageId (narrative : ZipperString)
            , languageNarrativeContents = Dict.map (\a b -> getLanguagesNarrativeDict ( a, b )) dictEntities
            , languageAudioContents = Dict.map (\a b -> getLanguagesAudioDict ( a, b )) dictEntities
            , lallgeneretedRandomFloats = []
            , displayStartScreen = displayStartScreen_
            , startScreenInfo = Narrative.startScreenInfo
            , displayEndScreen = False
            , endScreenInfo = Narrative.endScreenInfo
            }
                |> mbSetPlayerName mbPlayerName
    in
    if List.length historyList == 0 then
        ( newModel, cmdForGeneratingListOfRandomFloats )
        --Cmd.none

    else
        getNewModelAfterGameStartRandomElems lPrandomFloats newModel
            |> update (ProcessLoadHistory historyList newModel.settingsModel)


cmdForGeneratingListOfRandomFloats : Cmd ClientTypes.Msg
cmdForGeneratingListOfRandomFloats =
    Random.generate NewRandomElemsAtGameStart (Random.list 100 (Random.float 0 1))


getNewModelAfterGameStartRandomElems : List Float -> Model -> Model
getNewModelAfterGameStartRandomElems lfloats model =
    let
        engineModel_ =
            Engine.setRandomFloatElems lfloats model.engineModel

        ( newEngineModel, lincidents ) =
            engineModel_
                |> Engine.changeWorld Rules.startingState

        startLincidents =
            [ ( "startingState ", lincidents ) ]

        allPossibleIncidentsAboutCwcmds =
            SomeTests.getAllPossibleIncidentsAboutCwcmds newEngineModel startLincidents

        alertMessages_ =
            if model.debugMode then
                allPossibleIncidentsAboutCwcmds

            else
                []

        newModel =
            { model
                | engineModel = newEngineModel
                , lallgeneretedRandomFloats = lfloats
                , alertMessages = model.alertMessages ++ alertMessages_
            }
    in
    --update (ProcessLoadHistory historyList model.settingsModel) newModel
    newModel


findEntity : Model -> String -> Entity
findEntity model id =
    model.itemsLocationsAndCharacters
        |> List.filter (Tuple.first >> (==) id)
        |> List.head
        |> Maybe.withDefault (entity id)


mbSetPlayerName : Maybe String -> Model -> Model
mbSetPlayerName mbPlayerName model =
    case mbPlayerName of
        Nothing ->
            model

        Just playerName ->
            setPlayerName playerName model


setPlayerName : String -> Model -> Model
setPlayerName playerNameStr model =
    if playerNameStr == "" then
        model

    else
        let
            newPlayerOneEntity =
                findEntity model "playerOne"
                    |> Components.updateAllLgsDisplayName playerNameStr

            newEntities =
                model.itemsLocationsAndCharacters
                    |> List.map
                        (\x ->
                            if Tuple.first x == "playerOne" then
                                newPlayerOneEntity

                            else
                                x
                        )

            newAnswerBoxModel =
                AnswerBox.update "" model.answerBoxModel

            newModel =
                { model
                    | itemsLocationsAndCharacters = newEntities
                    , playerName = playerNameStr
                    , answerBoxModel = newAnswerBoxModel
                }
        in
        newModel



-- UPDATE


update :
    ClientTypes.Msg
    -> Model
    -> ( Model, Cmd ClientTypes.Msg )
update msg model =
    let
        _ =
            Debug.log "update was called with msg : " msg
    in
    case Engine.hasFreezingEnd model.engineModel of
        True ->
            -- no-op if story has ended and it has a FreezingType End
            ( model, Cmd.none )

        False ->
            -- if it hasn't ended or the endtype is not a freezingend
            case msg of
                StartMainGame ->
                    ( { model | displayStartScreen = False }, Cmd.none )

                StartMainGameNewPlayerName playerNameStr ->
                    if playerNameStr /= "" then
                        let
                            newModel =
                                setPlayerName playerNameStr model
                        in
                        update StartMainGame newModel

                    else
                        update StartMainGame model

                InteractSendingText interactableId theText ->
                    let
                        --clear the Text Box
                        newAnswerBoxModel =
                            AnswerBox.update "" model.answerBoxModel

                        newModel =
                            { model
                                | mbSentText = Just (String.trim theText)
                                , answerBoxModel = newAnswerBoxModel
                            }
                    in
                    update (Interact interactableId) newModel

                Interact interactableId ->
                    let
                        needCoords =
                            findEntity model interactableId |> getNeedsGpsCoords

                        mbGpsZone =
                            findEntity model interactableId |> getNeedsToBeInGpsZone

                        needsToBeInZone =
                            Maybe.withDefault False (Maybe.map .needsToBeIn mbGpsZone)
                                && not model.settingsModel.dontNeedToBeInZone

                        interactionExtraInfo =
                            getExtraInfoFromModel model interactableId

                        nModel =
                            { model
                                | alertMessages = []
                                , mbSentText = Nothing
                            }

                        ( newModel, cmds ) =
                            if needCoords && not needsToBeInZone then
                                ( nModel, sendRequestForGeolocation interactableId )

                            else if needsToBeInZone then
                                ( nModel, sendRequestForGeolocation interactableId )

                            else
                                update (InteractStepTwo interactableId interactionExtraInfo) nModel
                    in
                    ( newModel, cmds )

                NewCoordsForInterId locationAndInteractableIdRecord ->
                    if locationAndInteractableIdRecord.latitude == -999 && locationAndInteractableIdRecord.longitude == -999 then
                        update (NewCoordsForInterIdFailed locationAndInteractableIdRecord.interactableId) model

                    else
                        let
                            ( interactableId, latitude, longitude ) =
                                ( locationAndInteractableIdRecord.interactableId, locationAndInteractableIdRecord.latitude, locationAndInteractableIdRecord.longitude )

                            location =
                                GpsUtils.GeolocationInfo latitude longitude

                            mbGpsZone =
                                findEntity model interactableId |> getNeedsToBeInGpsZone

                            needsToBeInZone =
                                Maybe.withDefault False (Maybe.map .needsToBeIn mbGpsZone)
                                    && not model.settingsModel.dontNeedToBeInZone

                            interactionExtraInfo =
                                getExtraInfoFromModel model interactableId

                            theDistance =
                                getDistance location mbGpsZone

                            distanceToClosestLocations =
                                Manifest.locations
                                    |> List.map (getDictLgNamesAndCoords [ model.settingsModel.displayLanguage ])
                                    |> List.map (Dict.get model.settingsModel.displayLanguage)
                                    |> GpsUtils.getDistancesTo 1000 location

                            inDistance =
                                checkIfInDistance mbGpsZone theDistance model.defaultZoneRadius

                            newModel =
                                { model
                                    | geoLocation = Just location
                                    , geoDistances = distanceToClosestLocations
                                }

                            updatedInteractionExtraInfo =
                                updateInterExtraInfoWithGeoInfo interactionExtraInfo model
                        in
                        if not needsToBeInZone || (needsToBeInZone && inDistance) then
                            update (InteractStepTwo interactableId updatedInteractionExtraInfo) newModel

                        else
                            update (NotInTheZone interactableId mbGpsZone location theDistance) newModel

                NewCoordsForInterIdFailed interactableId ->
                    let
                        newModel =
                            { model
                                | geoLocation = Nothing
                                , geoDistances = []
                                , alertMessages = [ "Failed to get gps coordinates" ]
                            }

                        mbGpsZone =
                            findEntity model interactableId |> getNeedsToBeInGpsZone

                        needsToBeInZone =
                            Maybe.withDefault False (Maybe.map .needsToBeIn mbGpsZone)
                                && not model.settingsModel.dontNeedToBeInZone

                        interactionExtraInfo =
                            getExtraInfoFromModel model interactableId

                        updatedInteractionExtraInfo =
                            updateInterExtraInfoWithGeoInfo interactionExtraInfo model
                    in
                    if not needsToBeInZone then
                        update (InteractStepTwo interactableId updatedInteractionExtraInfo) newModel

                    else
                        ( newModel, Cmd.none )

                NotInTheZone interactableId mbGpsZone location theDistance ->
                    let
                        zoneCoordsStr =
                            getMbGpsZoneLatLon mbGpsZone
                                --|> Maybe.map toString
                                |> Maybe.map GpsUtils.convertDecimalTupleToGps
                                |> Maybe.withDefault ""

                        theName =
                            findEntity model interactableId
                                |> getSingleLgDisplayInfo model.settingsModel.displayLanguage
                                |> .name

                        linfoStr =
                            [ " Trying to move to  " ++ theName ++ " failed . "
                            , "you're not close enough."
                            , "You are at : " ++ GpsUtils.convertDecimalTupleToGps ( location.latitude, location.longitude )
                            , "Please move closer to " ++ zoneCoordsStr
                            , "Your distance to where you should be is : "
                                ++ String.fromInt (round theDistance)
                                ++ " meters"
                            ]

                        newModel =
                            { model | alertMessages = linfoStr }
                    in
                    ( newModel, Cmd.none )

                InteractStepTwo interactableId interactionExtraInfo ->
                    -- only allow interaction if this interactable isnt waiting for some backend answer confirmation
                    if Dict.get interactableId model.bkendAnswerStatusDict == Just EngineTypes.WaitingForInfoRequested then
                        -- Interactable is awaiting for some backend confirmation. No interaction possible at this time
                        ( { model | alertMessages = "Please Wait ... \n" :: model.alertMessages }, Cmd.none )

                    else
                        let
                            engResp1 =
                                Engine.update
                                    (PreUpdate interactableId interactionExtraInfo)
                                    model.engineModel

                            ( newEngineModel, extraInfoWithPendingChanges, infoNeeded ) =
                                case engResp1 of
                                    EnginePreResponse ( newEngineModel_, extraInfoWithPendingChanges_, infoNeeded_ ) ->
                                        ( newEngineModel_, extraInfoWithPendingChanges_, infoNeeded_ )

                                    _ ->
                                        -- pattern matching needs to deal with all cases but this can't really happen
                                        ( model.engineModel, EngineTypes.ExtraInfoWithPendingChanges interactionExtraInfo [] Nothing, NoInfoNeeded )

                            newInteractionExtraInfo =
                                extraInfoWithPendingChanges.interactionExtraInfo

                            newModel =
                                { model | engineModel = newEngineModel }
                        in
                        case infoNeeded of
                            NoInfoNeeded ->
                                let
                                    ( newEngineModel2, lInteractionIncidents ) =
                                        case Engine.update (CompleteTheUpdate interactableId extraInfoWithPendingChanges) newEngineModel of
                                            EngineUpdateCompleteResponse ( newEngineModel2_, lInteractionIncidents_ ) ->
                                                ( newEngineModel2_, lInteractionIncidents_ )

                                            _ ->
                                                -- pattern matching needs to deal with all cases but this can't really happen
                                                ( newEngineModel, [] )

                                    interactionIncidents =
                                        if model.debugMode then
                                            lInteractionIncidents

                                        else
                                            []
                                in
                                update (InteractStepThree interactableId newInteractionExtraInfo)
                                    { newModel
                                        | engineModel = newEngineModel2
                                        , bkendAnswerStatusDict = Dict.update interactableId (\x -> Just EngineTypes.NoInfoYet) model.bkendAnswerStatusDict
                                        , alertMessages = interactionIncidents
                                    }

                            AnswerInfoToQuestionNeeded strUrl ->
                                if interactionExtraInfo.bkAnsStatus == NoInfoYet then
                                    let
                                        -- clear the text box so the text can't be used by any other interactable.
                                        newAnswerBoxModel =
                                            AnswerBox.update "" model.answerBoxModel

                                        newInteractionExtraInfoTwo =
                                            { newInteractionExtraInfo | bkAnsStatus = EngineTypes.WaitingForInfoRequested }

                                        newExtraInfoWithPendingChanges : EngineTypes.ExtraInfoWithPendingChanges
                                        newExtraInfoWithPendingChanges =
                                            { interactionExtraInfo = newInteractionExtraInfoTwo
                                            , pendingChanges = extraInfoWithPendingChanges.pendingChanges
                                            , mbQuasiCwCmdWithBk = extraInfoWithPendingChanges.mbQuasiCwCmdWithBk
                                            }

                                        getTheUrl strUrl_ =
                                            strUrl_

                                        -- ++ Maybe.withDefault "" interactionExtraInfo.mbInputTextForBackend ++ "/"
                                    in
                                    ( { newModel
                                        | bkendAnswerStatusDict = Dict.update interactableId (\x -> Just EngineTypes.WaitingForInfoRequested) model.bkendAnswerStatusDict
                                        , alertMessages = [ "___Checking_Answer___" ]
                                        , answerBoxModel = newAnswerBoxModel
                                      }
                                    , getBackendAnswerInfo interactableId newExtraInfoWithPendingChanges (getTheUrl strUrl)
                                    )

                                else
                                    ( model, Cmd.none )

                AnswerChecked interactableId extraInfoWithPendingChanges (Ok bresp) ->
                    let
                        nModel =
                            { model
                                | bkendAnswerStatusDict = Dict.update interactableId (\val -> Just (EngineTypes.Ans bresp)) model.bkendAnswerStatusDict
                                , alertMessages = []
                            }

                        newExtraInfoWithPendingChanges =
                            updateNestedBkAnsStatus extraInfoWithPendingChanges (Ans bresp)

                        ( newInteractionExtraInfo_, newModel ) =
                            getNewModelAndInteractionExtraInfoByEngineUpdate interactableId newExtraInfoWithPendingChanges nModel
                    in
                    update (InteractStepThree interactableId newInteractionExtraInfo_) newModel

                AnswerChecked interactableId extraInfoWithPendingChanges (Err error) ->
                    let
                        nModel =
                            { model
                                | bkendAnswerStatusDict = Dict.update interactableId (\val -> Just CommunicationFailure) model.bkendAnswerStatusDict
                                , alertMessages = [ "___Couldnt_check_Answer___" ]
                            }

                        newExtraInfoWithPendingChanges =
                            updateNestedBkAnsStatus extraInfoWithPendingChanges CommunicationFailure

                        ( newInteractionExtraInfo_, newModel ) =
                            getNewModelAndInteractionExtraInfoByEngineUpdate interactableId newExtraInfoWithPendingChanges nModel
                    in
                    update (InteractStepThree interactableId newInteractionExtraInfo_) newModel

                InteractStepThree interactableId interactionExtraInfo ->
                    let
                        maybeMatchedRuleId =
                            interactionExtraInfo.mbMatchedRuleId

                        displayLanguage =
                            model.settingsModel.displayLanguage

                        newEngineModel =
                            model.engineModel

                        {- Helper function  called by narrativesForThisInteraction -}
                        getTheNarrativeHeaderAndIncident : String -> ( String, String )
                        getTheNarrativeHeaderAndIncident languageId =
                            Engine.getInteractableAttribute "narrativeHeader" interactableId newEngineModel
                                |> Tconverter.mbAttributeToString model.debugMode
                                |> (\( x, y ) -> ( String.split " " x, y ))
                                |> (\( ls, y ) -> ( List.map (\x -> getInLanguage languageId x) ls, y ))
                                |> (\( ls, y ) -> ( String.join " " ls, y ))

                        {- Helper function called by  narrativesForThisInteraction -}
                        getTheWrittenContent languageId =
                            Engine.getItemWrittenContent interactableId newEngineModel
                                |> Maybe.withDefault ""
                                |> String.split " "
                                |> List.map (\x -> getInLanguage languageId x)
                                |> String.join " "

                        {- Helper function called by  narrativesForThisInteraction -}
                        isLastZip : ListZipper.Zipper String -> Bool
                        isLastZip val =
                            if ListZipper.next val == Nothing then
                                True

                            else
                                False

                        ( additionalTextDict, incidentOnGetAdditionalTextDict ) =
                            Engine.getInteractableAttribute "additionalTextDict" interactableId model.engineModel
                                |> Tconverter.mbAttributeToDictStringListString model.debugMode

                        {- Helper function called by  narrativesForThisInteraction -}
                        wrapWithHeaderWrittenContentAndAdditionalText : String -> String -> ( String, String )
                        wrapWithHeaderWrittenContentAndAdditionalText lgId mainContent =
                            let
                                ( header, incident ) =
                                    getTheNarrativeHeaderAndIncident lgId
                            in
                            ( header
                                ++ ("\n" ++ mainContent)
                                ++ ("\n" ++ getTheWrittenContent lgId)
                                ++ "  \n"
                                ++ (Dict.get lgId additionalTextDict |> Maybe.withDefault [ "" ] |> String.join " ,  \n  ")
                            , incident
                            )

                        temporaryHackToSubstitueImgUrl : String -> String -> String
                        temporaryHackToSubstitueImgUrl baseImgUrl theStr =
                            if baseImgUrl /= "" then
                                --Regex.replace Regex.All (Regex.regex "\\(img\\/") (\_ -> "(" ++ baseImgUrl) theStr
                                regexUserReplace "\\(img\\/" (\_ -> "(" ++ baseImgUrl) theStr

                            else
                                theStr

                        getMbsuggestInteractionId : ( Maybe String, String )
                        getMbsuggestInteractionId =
                            Engine.getInteractableAttribute "suggestedInteraction" interactableId model.engineModel
                                |> Tconverter.mbAttributeToMbString model.debugMode

                        ( mbsuggestInteractionId, incidentOnGetsuggestedInteraction ) =
                            getMbsuggestInteractionId

                        suggestInteractionCaption : String -> String
                        suggestInteractionCaption lgId =
                            Engine.getInteractableAttribute "suggestedInteractionCaption" interactableId newEngineModel
                                |> Tconverter.mbAttributeToDictStringString model.debugMode
                                |> (\( x, y ) -> Dict.get lgId x)
                                |> Maybe.withDefault (getInLanguage lgId "___SUGGESTED_INTERACTION___")

                        ( theNarratives, lincidentsOnNarratives ) =
                            let
                                dict1Temp =
                                    -- is a Dict String (String , Bool , String ) last String is an incident that might have occurred
                                    maybeMatchedRuleId
                                        |> Maybe.andThen (\ruleId -> Dict.get ruleId model.languageNarrativeContents)
                                        |> Maybe.withDefault Dict.empty
                                        |> Dict.map
                                            (\lgId val ->
                                                (ListZipper.current val
                                                    |> temporaryHackToSubstitueImgUrl model.baseImgUrl
                                                    |> wrapWithHeaderWrittenContentAndAdditionalText lgId
                                                )
                                                    |> (\( x, y ) -> ( x, isLastZip val, y ))
                                            )

                                dictFromTemp thedict =
                                    thedict
                                        |> Dict.map
                                            (\lgId val ->
                                                let
                                                    ( x, y, z ) =
                                                        val
                                                in
                                                ( x, y )
                                            )

                                getIncidentsOnDict thedict =
                                    Dict.foldl
                                        (\key val acc ->
                                            let
                                                ( x, y, incidentmsg ) =
                                                    val
                                            in
                                            incidentmsg :: acc
                                        )
                                        []
                                        thedict

                                dict2Temp =
                                    findEntity model interactableId
                                        |> getDictLgDescriptions Narrative.desiredLanguages
                                        |> Dict.map (\lgId val -> wrapWithHeaderWrittenContentAndAdditionalText lgId val |> (\( x, y ) -> ( x, True, y )))

                                incidentsOnDict1 =
                                    getIncidentsOnDict dict1Temp

                                dict1 =
                                    dictFromTemp dict1Temp

                                incidentsOnDict2 =
                                    getIncidentsOnDict dict2Temp

                                dict2 =
                                    dictFromTemp dict2Temp
                            in
                            ( Components.mergeDicts dict2 dict1, incidentsOnDict1 ++ incidentsOnDict2 )

                        {- If the engine found a matching rule, look up the narrative content component for that rule if possible.  The description from the display info component for the entity that was interacted with is used as a default. -}
                        narrativesForThisInteraction =
                            { interactableNames =
                                findEntity model interactableId
                                    |> getDictLgNames Narrative.desiredLanguages
                            , interactableCssSelector = findEntity model interactableId |> getClassName
                            , narratives =
                                theNarratives
                            , audios =
                                maybeMatchedRuleId
                                    |> Maybe.andThen (\ruleId -> Dict.get ruleId model.languageAudioContents)
                                    |> Maybe.withDefault Dict.empty
                                    |> Dict.map (\lgId val -> { val | fileName = model.baseSoundUrl ++ val.fileName })
                            , mbSuggestedInteractionId = mbsuggestInteractionId
                            , suggestedInteractionCaption = \lgId -> suggestInteractionCaption lgId
                            , suggestedInteractionNameDict =
                                if mbsuggestInteractionId /= Nothing then
                                    findEntity model (Maybe.withDefault "" mbsuggestInteractionId) |> getDictLgNames Narrative.desiredLanguages

                                else
                                    Dict.empty
                            }

                        {- If a rule matched, attempt to move to the next associated narrative content for next time.
                           This is a helper function used in updateNarrativeLgsDict in a Dict.map
                        -}
                        updateNarrativeContent : Maybe (ListZipper.Zipper String) -> Maybe (ListZipper.Zipper String)
                        updateNarrativeContent =
                            Maybe.map (\narrative -> ListZipper.next narrative |> Maybe.withDefault narrative)

                        {- If a rule matched, attempt to move to the next associated narrative content for next time.
                           This is a helper function used by  Dict.update in updatedContent
                        -}
                        updateNarrativeLgsDict : Maybe (Dict String (ListZipper.Zipper String)) -> Maybe (Dict String (ListZipper.Zipper String))
                        updateNarrativeLgsDict mbDict =
                            case mbDict of
                                Just dict ->
                                    Dict.map (\lgid val -> updateNarrativeContent (Just val) |> Maybe.withDefault val) dict
                                        |> Just

                                Nothing ->
                                    Nothing

                        {- If a rule matched, attempt to move to the next associated narrative content for next time. -}
                        updatedContent =
                            maybeMatchedRuleId
                                |> Maybe.map (\id -> Dict.update id updateNarrativeLgsDict model.languageNarrativeContents)
                                |> Maybe.withDefault model.languageNarrativeContents

                        {- Helper function called by  newLanguageStoryLines -}
                        mergeToDictStoryLine : ( String, StorySnippet ) -> Dict String (List StorySnippet) -> Dict String (List StorySnippet)
                        mergeToDictStoryLine tup storyLinesDict =
                            let
                                languageId =
                                    Tuple.first tup

                                mbExistingStorySnippets =
                                    Dict.get languageId storyLinesDict

                                newStorySnippet =
                                    Tuple.second tup

                                mbNewval =
                                    Just (newStorySnippet :: Maybe.withDefault [] mbExistingStorySnippets)
                            in
                            Dict.update languageId (\mbval -> mbNewval) storyLinesDict

                        {- updates the languages StoryLines dict with the narrative contents ( in several languages )
                           for this interaction
                        -}
                        newLanguageStoryLines =
                            let
                                nfti =
                                    narrativesForThisInteraction

                                llgssnippets =
                                    Dict.keys narrativesForThisInteraction.narratives
                                        |> List.map
                                            (\lgId ->
                                                ( lgId
                                                , { interactableName =
                                                        Dict.get lgId nfti.interactableNames
                                                            |> Maybe.withDefault (Maybe.withDefault "noName" (Dict.get "en" nfti.interactableNames))
                                                  , interactableId = interactableId
                                                  , isWritable =
                                                        Engine.isWritable interactableId model.engineModel
                                                            && (interactionExtraInfo.currentLocation
                                                                    == Engine.getCurrentLocation model.engineModel
                                                               )
                                                  , interactableCssSelector = nfti.interactableCssSelector
                                                  , narrative =
                                                        Dict.get lgId nfti.narratives
                                                            |> Maybe.map Tuple.first
                                                            |> Maybe.withDefault ""
                                                  , mbAudio = Dict.get lgId nfti.audios
                                                  , mbSuggestedInteractionId = nfti.mbSuggestedInteractionId
                                                  , suggestedInteractionCaption = nfti.suggestedInteractionCaption lgId
                                                  , mbSuggestedInteractionName = Dict.get lgId nfti.suggestedInteractionNameDict
                                                  , isLastInZipper =
                                                        Dict.get lgId nfti.narratives
                                                            |> Maybe.map Tuple.second
                                                            |> Maybe.withDefault True
                                                  }
                                                )
                                            )
                            in
                            List.foldl (\x y -> mergeToDictStoryLine x y) model.languageStoryLines llgssnippets

                        -- after an interaction clear the TextBox
                        newAnswerBoxModel =
                            AnswerBox.update "" model.answerBoxModel

                        getAlertMessage1 =
                            case Dict.get displayLanguage narrativesForThisInteraction.narratives of
                                Nothing ->
                                    [ "No narrative content for this interaction in the current language. Maybe you want to try channging language !" ]

                                _ ->
                                    []

                        ( getAlertMessage2, incidentOnGetAlertMessage2 ) =
                            let
                                ( thedict, incidentOnGetDict ) =
                                    Engine.getInteractableAttribute "warningMessage" interactableId model.engineModel
                                        |> Tconverter.mbAttributeToDictStringListString model.debugMode
                            in
                            ( thedict
                                |> Dict.get displayLanguage
                                |> Maybe.withDefault [ "" ]
                            , incidentOnGetDict
                            )

                        --updateChoiceLanguages
                        newSettingsModel =
                            Settings.update (ClientTypes.SetAvailableLanguages (getChoiceLanguages newEngineModel)) model.settingsModel

                        -- check if ended
                        ( hasEnded, incidentOnHasEndedConversion ) =
                            Engine.getInteractableAttribute "gameHasEnded" "gameStateItem" model.engineModel
                                |> Tconverter.mbAttributeToBool model.debugMode

                        newSettingsModel2 =
                            if hasEnded && not model.settingsModel.showExitToFinalScreenButton then
                                Settings.update ClientTypes.SettingsShowExitToFinalScreenButton newSettingsModel

                            else
                                newSettingsModel

                        getAlertMessages3 =
                            [ incidentOnHasEndedConversion, incidentOnGetsuggestedInteraction, incidentOnGetAdditionalTextDict, incidentOnGetAlertMessage2 ]

                        _ =
                            Debug.log "current location is now  : " (Engine.getCurrentLocation model.engineModel)

                        _ =
                            Debug.log "characters in current location are  : " (Engine.getCharactersInCurrentLocation newEngineModel)

                        _ =
                            getExits (Engine.getCurrentLocation model.engineModel |> findEntity model)
                                |> Debug.log "exits are : "
                    in
                    ( { model
                        | engineModel = newEngineModel --  |> checkEnd
                        , alertMessages = getAlertMessage1 ++ getAlertMessage2 ++ getAlertMessages3 ++ lincidentsOnNarratives
                        , answerBoxModel = newAnswerBoxModel
                        , languageStoryLines = newLanguageStoryLines
                        , languageNarrativeContents = updatedContent
                        , settingsModel = newSettingsModel2
                      }
                    , Cmd.none
                    )

                NewRandomElemsAtGameStart lfloats ->
                    let
                        newModel =
                            getNewModelAfterGameStartRandomElems lfloats model
                    in
                    ( newModel, Cmd.none )

                NewUserSubmitedText theText ->
                    let
                        newAnswerBoxModel =
                            AnswerBox.update theText model.answerBoxModel
                    in
                    ( { model | answerBoxModel = newAnswerBoxModel }, Cmd.none )

                ChangeOptionDisplayLanguage theLanguage ->
                    let
                        newSettingsModel =
                            Settings.update (ClientTypes.SetDisplayLanguage theLanguage) model.settingsModel
                    in
                    ( { model | settingsModel = newSettingsModel }, Cmd.none )

                ChangeOptionDontCheckGps bdontcheck ->
                    let
                        newSettingsModel =
                            Settings.update (ClientTypes.SetDontNeedToBeInZone bdontcheck) model.settingsModel
                    in
                    ( { model | settingsModel = newSettingsModel }, Cmd.none )

                CloseAlert ->
                    ( { model | alertMessages = [] }, Cmd.none )

                ChangeOptionAudioAutoplay bautoplay ->
                    let
                        newSettingsModel =
                            Settings.update (ClientTypes.SettingsChangeOptionAutoplay bautoplay) model.settingsModel
                    in
                    ( { model | settingsModel = newSettingsModel }, Cmd.none )

                LayoutWithSideBar bWithSidebar ->
                    let
                        newSettingsModel =
                            Settings.update (ClientTypes.SettingsLayoutWithSidebar bWithSidebar) model.settingsModel
                    in
                    ( { model | settingsModel = newSettingsModel }, Cmd.none )

                ToggleShowExpandedSettings ->
                    let
                        newSettingsModel =
                            Settings.update ClientTypes.SettingsToggleShowExpanded model.settingsModel
                    in
                    ( { model | settingsModel = newSettingsModel }, Cmd.none )

                ToggleShowHideSaveLoadBtns ->
                    let
                        newSettingsModel =
                            Settings.update ClientTypes.SettingsToggleShowHideSaveLoadBtns model.settingsModel
                    in
                    ( { model | settingsModel = newSettingsModel }, Cmd.none )

                SaveHistory ->
                    saveHistoryToStorageHelper model

                RequestForStoredHistory ->
                    ( model, sendRequestForStoredHistory "" )

                LoadHistory obj ->
                    let
                        playerName =
                            obj.playerName

                        newlist =
                            convertToListIdExtraInfo obj.lInteractions

                        lPrandomFloats =
                            obj.lPrandomFloats

                        savedSettings =
                            Settings.update ClientTypes.SettingsHideExitToFinalScreenButton model.settingsModel

                        ( newModel, cmds ) =
                            initWithMbPlayerNameAndMbHistoryList (Flags model.baseImgUrl model.baseSoundUrl) False lPrandomFloats (Just playerName) newlist

                        newModel_ =
                            if List.length newlist == 0 then
                                { newModel | alertMessages = "Nothing To Load !" :: newModel.alertMessages }

                            else
                                { newModel | alertMessages = [] }

                        --( newNewModel, newCmds ) =
                        --    ( newModel_, cmds )
                        --        |> updateExtraAndThen update (StartMainGameNewPlayerName playerName)
                        --        |> updateExtraAndThen update (ProcessLoadHistory newlist savedSettings)
                        --  _ =
                        --      Debug.log "after  load history . model current location is now : " (Engine.getCurrentLocation newNewModel.engineModel)
                    in
                    ( newModel_, cmds )

                ProcessLoadHistory ltups savedSettings ->
                    let
                        ( newModel, cmds ) =
                            case ltups of
                                [] ->
                                    ( model, Cmd.none )

                                head :: rest ->
                                    ( model, Cmd.none )
                                        |> updateExtraAndThen update (InteractStepTwo (Tuple.first head) (Tuple.second head))
                                        |> updateExtraAndThen update (ProcessLoadHistory rest savedSettings)

                        _ =
                            Debug.log "processing load history . model current location is now : " (Engine.getCurrentLocation newModel.engineModel)
                    in
                    ( { newModel | settingsModel = savedSettings }, cmds )

                ExitToFinalScreen ->
                    ( { model | displayEndScreen = True }, Cmd.none )

                Loaded ->
                    ( { model | loaded = True }
                    , Cmd.none
                    )


{-| this is taken from ccapndave/elm-update-extra package while not yet upgraded to Elm 0.19 version
-}
updateExtraAndThen : (msg -> Model -> ( Model, Cmd a )) -> msg -> ( Model, Cmd a ) -> ( Model, Cmd a )
updateExtraAndThen updatefunc msg ( model, cmd ) =
    let
        ( model_, cmd_ ) =
            updatefunc msg model
    in
    ( model_, Cmd.batch [ cmd, cmd_ ] )


regexUserReplace : String -> (Regex.Match -> String) -> String -> String
regexUserReplace userRegex replacer string =
    case Regex.fromString userRegex of
        Nothing ->
            string

        Just regex ->
            Regex.replace regex replacer string


port saveHistoryToStorage : { playerName : String, lInteractions : List SaveHistoryRecord, lPrandomFloats : List Float } -> Cmd msg


port sendRequestForStoredHistory : String -> Cmd msg


port getHistoryFromStorage : ({ playerName : String, lInteractions : List SaveHistoryRecord, lPrandomFloats : List Float } -> msg) -> Sub msg


port sendRequestForGeolocation : String -> Cmd msg


port getGeolocationFromBrowser : ({ interactableId : String, latitude : Float, longitude : Float } -> msg) -> Sub msg



-- This was used with Elm  0.18
--Task.attempt (NewCoordsForInterId interactableId mbGpsZone bval interactionExtraInfo) Geolocation.now


subscriptions : a -> Sub Msg
subscriptions a =
    Sub.batch
        [ getHistoryFromStorage LoadHistory
        , getGeolocationFromBrowser NewCoordsForInterId
        ]


convertToListIdExtraInfo : List SaveHistoryRecord -> List ( String, InteractionExtraInfo )
convertToListIdExtraInfo lobjs =
    List.map
        (\x ->
            ( x.interactableId
            , EngineTypes.InteractionExtraInfo
                (helperEmptyStringToNothing x.inputText)
                (helperEmptyStringToNothing x.inputTextForBackend)
                x.geolocationInfoText
                x.currentLocation
                EngineTypes.CommunicationFailure
                (helperEmptyStringToNothing x.mbMatchedRuleId)
            )
        )
        lobjs


helperEmptyStringToNothing : String -> Maybe String
helperEmptyStringToNothing theStr =
    if theStr == "" then
        Nothing

    else
        Just theStr


saveHistoryToStorageHelper : Model -> ( Model, Cmd ClientTypes.Msg )
saveHistoryToStorageHelper model =
    let
        storyHistory =
            Engine.getHistory model.engineModel

        lToSave =
            List.map
                (\x ->
                    { interactableId = Tuple.first x
                    , inputText = Tuple.second x |> .mbInputText |> Maybe.withDefault ""
                    , inputTextForBackend = Tuple.second x |> .mbInputTextForBackend |> Maybe.withDefault ""
                    , geolocationInfoText = Tuple.second x |> .geolocationInfoText
                    , currentLocation = Engine.getCurrentLocation model.engineModel
                    , mbMatchedRuleId = Tuple.second x |> .mbMatchedRuleId |> Maybe.withDefault ""
                    }
                )
                storyHistory

        infoToSave =
            { playerName = getInLanguage model.settingsModel.displayLanguage model.playerName
            , lInteractions = lToSave
            , lPrandomFloats = model.lallgeneretedRandomFloats
            }
    in
    ( model, saveHistoryToStorage infoToSave )


getExtraInfoFromModel : Model -> String -> InteractionExtraInfo
getExtraInfoFromModel model interactableId =
    let
        currLocationStrId =
            Engine.getCurrentLocation model.engineModel

        currLocNameAndCoords =
            currLocationStrId |> findEntity model |> getDictLgNamesAndCoords Narrative.desiredLanguages
    in
    InteractionExtraInfo
        model.mbSentText
        model.mbSentText
        (GpsUtils.getCurrentGeoReportAsText currLocNameAndCoords model.geoLocation model.geoDistances 3)
        currLocationStrId
        (Dict.get interactableId model.bkendAnswerStatusDict |> Maybe.withDefault EngineTypes.NoInfoYet)
        Nothing


updateInterExtraInfoWithGeoInfo : EngineTypes.InteractionExtraInfo -> Model -> InteractionExtraInfo
updateInterExtraInfoWithGeoInfo extraInforecord model =
    let
        currLocNameAndCoords =
            Engine.getCurrentLocation model.engineModel |> findEntity model |> getDictLgNamesAndCoords Narrative.desiredLanguages
    in
    { extraInforecord
        | geolocationInfoText =
            GpsUtils.getCurrentGeoReportAsText currLocNameAndCoords model.geoLocation model.geoDistances 3
    }



-- Elm 0.18 old code ( using module elm-lang/geolocation )
--getNewCoords : String -> Maybe GpsZone -> Bool -> EngineTypes.InteractionExtraInfo -> Cmd ClientTypes.Msg
--getNewCoords interactableId mbGpsZone bval interactionExtraInfo =
--    Task.attempt (NewCoordsForInterId interactableId mbGpsZone bval interactionExtraInfo) Geolocation.now


type alias LgTxt =
    { lgId : String
    , text : String
    }


textInLanguagesDecoder : Json.Decode.Decoder LgTxt
textInLanguagesDecoder =
    Json.Decode.map2 LgTxt
        (Json.Decode.field "lgId" Json.Decode.string)
        (Json.Decode.field "text" Json.Decode.string)


backendAnswerDecoder : String -> String -> Json.Decode.Decoder EngineTypes.AnswerInfo
backendAnswerDecoder interactableId playerAnswer =
    Json.Decode.succeed AnswerInfo
        |> Json.Decode.Pipeline.required "maxTriesReached" Json.Decode.bool
        |> Json.Decode.Pipeline.hardcoded interactableId
        |> Json.Decode.Pipeline.required "questionBody" Json.Decode.string
        |> Json.Decode.Pipeline.hardcoded playerAnswer
        |> Json.Decode.Pipeline.required "answered" Json.Decode.bool
        |> Json.Decode.Pipeline.required "correctAnswer" Json.Decode.bool
        |> Json.Decode.Pipeline.required "incorrectAnswer" Json.Decode.bool
        |> Json.Decode.Pipeline.required "lSecretTextDicts" (Json.Decode.list textInLanguagesDecoder)
        |> Json.Decode.Pipeline.required "lSuccessTextDicts" (Json.Decode.list textInLanguagesDecoder)
        |> Json.Decode.Pipeline.required "lInsuccessTextDicts" (Json.Decode.list textInLanguagesDecoder)


playerAnswerEncoder : String -> String -> Json.Encode.Value
playerAnswerEncoder interactableId playerAnswer =
    let
        attributes =
            [ ( "interactableId", Json.Encode.string interactableId )
            , ( "playerAnswer", Json.Encode.string playerAnswer )
            ]
    in
    Json.Encode.object attributes


getBackendAnswerInfo : String -> EngineTypes.ExtraInfoWithPendingChanges -> String -> Cmd ClientTypes.Msg
getBackendAnswerInfo interactableId extraInfoWithPendingChanges strUrl =
    let
        apiKey =
            InfoForBkendApiRequests.getApiKey

        request =
            Http.request
                { method = "POST"
                , headers =
                    [ Http.header "x-api-key" apiKey
                    ]
                , url = strUrl
                , body =
                    extraInfoWithPendingChanges.interactionExtraInfo.mbInputTextForBackend
                        |> Maybe.withDefault ""
                        |> playerAnswerEncoder interactableId
                        |> Http.jsonBody

                --Http.emptyBody
                , expect = Http.expectJson (backendAnswerDecoder interactableId (Maybe.withDefault "" extraInfoWithPendingChanges.interactionExtraInfo.mbInputTextForBackend))
                , timeout = Nothing
                , withCredentials = False
                }

        newExtraInfoWithPendingChanges =
            updateNestedMbInputTextBk extraInfoWithPendingChanges Nothing
    in
    Http.send (AnswerChecked interactableId newExtraInfoWithPendingChanges) request


getNewModelAndInteractionExtraInfoByEngineUpdate : String -> EngineTypes.ExtraInfoWithPendingChanges -> Model -> ( EngineTypes.InteractionExtraInfo, Model )
getNewModelAndInteractionExtraInfoByEngineUpdate interactableId extraInfoWithPendingChanges model =
    -- only allow interaction if this interactable isnt waiting for some backend answer confirmation
    if Dict.get interactableId model.bkendAnswerStatusDict == Just EngineTypes.WaitingForInfoRequested then
        -- Interactable is awaiting for some backend confirmation. No interaction possible at this time
        ( extraInfoWithPendingChanges.interactionExtraInfo, { model | alertMessages = "Please Wait ... \n" :: model.alertMessages } )

    else
        let
            ( newEngineModel, lInteractionIncidents ) =
                case Engine.update (CompleteTheUpdate interactableId extraInfoWithPendingChanges) model.engineModel of
                    EngineUpdateCompleteResponse ( newEngineModel_, lInteractionIncidents_ ) ->
                        ( newEngineModel_, lInteractionIncidents_ )

                    _ ->
                        -- pattern matching needs to deal with all cases but this can't really happen
                        ( model.engineModel, [] )

            newInteractionExtraInfo =
                extraInfoWithPendingChanges.interactionExtraInfo

            interactionIncidents =
                if model.debugMode then
                    lInteractionIncidents

                else
                    []

            newModel =
                { model
                    | engineModel = newEngineModel
                    , bkendAnswerStatusDict = Dict.update interactableId (\x -> Just EngineTypes.NoInfoYet) model.bkendAnswerStatusDict
                    , alertMessages = interactionIncidents
                }
        in
        ( newInteractionExtraInfo, newModel )



-- VIEW


view : Model -> Html ClientTypes.Msg
view model =
    if model.displayStartScreen then
        viewStartScreen model.baseImgUrl model

    else if model.displayEndScreen then
        Theme.EndScreen.view model.baseImgUrl model.endScreenInfo

    else
        viewMainGame model


viewMainGame :
    Model
    -> Html ClientTypes.Msg
viewMainGame model =
    let
        currentLocation =
            Engine.getCurrentLocation model.engineModel
                |> Debug.log "current location string in view is : "
                |> findEntity model
                |> Debug.log "current location in view is : "

        theStoryLine =
            Dict.get model.settingsModel.displayLanguage model.languageStoryLines
                |> Maybe.withDefault []

        mbInteactableIdAtTop =
            List.head theStoryLine |> Maybe.map .interactableId

        ( mbTextBoxPlaceholderText_, incidentOnPlaceholderTextConversion ) =
            case mbInteactableIdAtTop of
                Nothing ->
                    ( Nothing, "" )

                Just interactableId ->
                    Engine.getInteractableAttribute "placeholderText" interactableId model.engineModel
                        |> Tconverter.mbAttributeToMbString model.debugMode

        ( answerOptionsDict_, incidentOnGetAnswerOptionsDict ) =
            Maybe.map (\x -> Engine.getInteractableAttribute "answerOptionsList" x model.engineModel) mbInteactableIdAtTop
                |> Maybe.map (Tconverter.mbAttributeToDictStringListStringString model.debugMode)
                |> Maybe.withDefault ( Dict.empty, "" )

        displayState =
            { currentLocation = currentLocation
            , itemsInCurrentLocation =
                Engine.getItemsInCurrentLocation model.engineModel
                    |> List.map (findEntity model)
            , charactersInCurrentLocation =
                Engine.getCharactersInCurrentLocation model.engineModel
                    |> List.map (findEntity model)
            , exits =
                getExits currentLocation
                    |> Debug.log "exits in view are : "
                    |> List.map
                        (\( direction, id ) ->
                            ( direction, findEntity model id )
                        )
            , itemsInInventory =
                Engine.getItemsInInventory model.engineModel
                    |> List.map (findEntity model)
            , answerBoxMbText = model.answerBoxModel.answerBoxText
            , mbAudioFileInfo =
                List.head theStoryLine
                    |> Maybe.map .mbAudio
                    |> Maybe.withDefault Nothing
            , audioAutoplay = model.settingsModel.audioAutoplay
            , answerOptionsDict =
                answerOptionsDict_
            , layoutWithSidebar = model.settingsModel.layoutWithSidebar
            , boolTextBoxInStoryline =
                case mbInteactableIdAtTop of
                    Nothing ->
                        False

                    Just interactableId ->
                        Engine.isWritable interactableId model.engineModel
                            && Dict.get interactableId model.bkendAnswerStatusDict
                            /= Just EngineTypes.WaitingForInfoRequested
            , mbTextBoxPlaceholderText = mbTextBoxPlaceholderText_
            , settingsModel = model.settingsModel
            , alertMessages =
                model.alertMessages
                    ++ [ incidentOnPlaceholderTextConversion, incidentOnGetAnswerOptionsDict ]
                    |> List.filter (\x -> x /= "")
            , ending =
                Engine.getEndingText model.engineModel
            , storyLine =
                theStoryLine
            }
    in
    if not model.loaded then
        div [ class "Loading" ] [ text "Loading..." ]

    else
        Theme.Layout.view displayState


viewStartScreen : String -> Model -> Html ClientTypes.Msg
viewStartScreen baseImgUrl model =
    Theme.StartScreen.view baseImgUrl model.startScreenInfo model.answerBoxModel


port loaded : (Bool -> msg) -> Sub msg


type alias Flags =
    { baseImgUrl : String
    , baseSoundUrl : String
    }


main : Program Flags Model ClientTypes.Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
