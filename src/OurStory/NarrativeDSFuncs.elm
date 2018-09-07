module OurStory.NarrativeDSFuncs exposing
    ( additionalTextIfAnswerCorrectDict
    , additionalTextIfAnswerIncorrectDict
    , getAllStageNrs
    , getDisplayOptionButtonsOptionParam
    , getFilteredStageMultiOptionIds
    , getFilteredStageMultiOptionNrs
    , getFilteredStageQuestionIds
    , getFilteredStageQuestionNrs
    , getLastStageId
    , getLastStageNr
    , getListOfStageIdWithQuestions
    , getListOfStageNrsWithQuestions
    , getMultiOptionAvailableChoicesDict
    , getMultiOptionAvailableChoicesValList
    , getMultiOptionBody
    , getMultiOptionBodyAsString
    , getMultiOptionName
    , getMultiOptionTextIfChosenDict
    , getNumberOfDesiredStages
    , getOptionId
    , getOptionIdsByStageNr
    , getOptionNrsByStageNr
    , getPenultimateStageId
    , getPenultimateStageNr
    , getQuestionAnswers
    , getQuestionAvailableChoicesDict
    , getQuestionBody
    , getQuestionBodyAsString
    , getQuestionId
    , getQuestionIdsByStageNr
    , getQuestionName
    , getQuestionNrsByStageNr
    , getQuestionsAndOrOptionsOnEveryStageExcept
    , getQuestionsMaxNrTries
    , getResetPossibleOptionParam
    , getStageId
    , getStageName
    , getStageOptionIds
    , getStageOptionNrs
    , getStageQuestionIds
    , getStageQuestionNrs
    , getStageRecord
    , getTheStageInfo
    , getTheStagesExtraInfo
    , interactingWithMultiOption
    , interactingWithMultiOptionDict
    , interactingWithQuestion
    , interactingWithQuestionDict
    , interactingWithStageN
    , interactingWithStageNDict
    )

import ClientTypes
import Dict exposing (Dict)
import OurStory.Narrative as Narrative exposing (desiredLanguages)
import OurStory.NarrativeDataStructures as NarrativeDataStructures
    exposing
        ( LanguageId
        , MultiOption
        , numberOfDesiredStages
        , questionsAndOrOptionsOnEveryStageExcept
        , theMultiOptionParams
        , theMultiOptionsDict
        , theQuestionsDict
        , theStagesDict
        )
import Set
import Types exposing (Manifest)


getTheStageInfo : Int -> LanguageId -> Maybe { stageNarrative : List String, stageName : String }
getTheStageInfo stageNr languageId =
    Dict.get ( stageNr, languageId ) theStagesDict


getTheStagesExtraInfo : Dict Int { questionsList : List Int, optionsList : List Int }
getTheStagesExtraInfo =
    NarrativeDataStructures.theStagesExtraInfo


getStageName : Int -> LanguageId -> String
getStageName stageNr languageId =
    getTheStageInfo stageNr languageId
        |> Maybe.map .stageName
        |> Maybe.withDefault ("Stage " ++ String.fromInt stageNr)


getStageRecord : Int -> LanguageId -> Maybe { withoutPreviousAnswered : List String, defaultStageDescription : List String, enteringFromHigherStage : List String, noQuestionOrNotMandatory : List String }
getStageRecord stageNr lgId =
    let
        theStageDescription : Maybe (List String)
        theStageDescription =
            getTheStageInfo stageNr lgId
                |> Maybe.map .stageNarrative

        getWithoutPreviousAnswered : List String
        getWithoutPreviousAnswered =
            if lgId == "pt" then
                [ "Deves responder a todas as perguntas e opções da etapa "
                    ++ String.fromInt (stageNr - 1)
                    ++ " antes de entrar na etapa "
                    ++ String.fromInt stageNr
                ]

            else
                [ "You have to answer all stage "
                    ++ String.fromInt (stageNr - 1)
                    ++ " questions and options "
                    ++ " before being allowed in stage "
                    ++ String.fromInt stageNr
                ]

        getEnteringFromHigherStage : String
        getEnteringFromHigherStage =
            if lgId == "pt" then
                "Para terminar o percurso deves seguir na direcção oposta"

            else
                "To finish the course you should move in the opposite direction"

        mbStandardQuestionRecord =
            case theStageDescription of
                Just stageDescription ->
                    Just
                        { withoutPreviousAnswered = getWithoutPreviousAnswered
                        , defaultStageDescription = stageDescription
                        , enteringFromHigherStage =
                            stageDescription
                                |> List.map (\x -> getEnteringFromHigherStage ++ "  \n" ++ x)
                        , noQuestionOrNotMandatory = stageDescription
                        }

                Nothing ->
                    Nothing
    in
    mbStandardQuestionRecord


interactingWithStageNDict : Int -> String -> Dict String (List String)
interactingWithStageNDict n fieldStr =
    Dict.fromList
        [ ( "pt", interactingWithStageN n "pt" fieldStr )
        , ( "en", interactingWithStageN n "en" fieldStr )
        ]


interactingWithStageN : Int -> LanguageId -> String -> List String
interactingWithStageN stageNr lgId fieldStr =
    let
        theRec =
            getStageRecord stageNr lgId
                |> Maybe.withDefault
                    { withoutPreviousAnswered = [ "" ]
                    , defaultStageDescription = [ "" ]
                    , enteringFromHigherStage = [ "" ]
                    , noQuestionOrNotMandatory = [ "" ]
                    }

        theListString =
            if fieldStr == "withoutPreviousAnswered" then
                theRec.withoutPreviousAnswered

            else if fieldStr == "defaultStageDescription" then
                theRec.defaultStageDescription

            else if fieldStr == "enteringFromHigherStage" then
                theRec.enteringFromHigherStage

            else
                theRec.noQuestionOrNotMandatory
    in
    theListString


getQuestionBody : Int -> LanguageId -> List String
getQuestionBody nr lgId =
    let
        questionsDict =
            theQuestionsDict

        question =
            Dict.get ( nr, lgId ) questionsDict
    in
    question
        |> Maybe.map .questionBody
        |> (\x ->
                case x of
                    Nothing ->
                        []

                    Just qbody ->
                        [ qbody ]
           )


getQuestionBodyAsString : Int -> LanguageId -> String
getQuestionBodyAsString nr lgId =
    getQuestionBody nr lgId
        |> String.join " , "


getQuestionAnswers : Int -> List String
getQuestionAnswers questionNr =
    let
        questionsDict =
            theQuestionsDict

        getLgAnswers : Int -> LanguageId -> List String
        getLgAnswers theQuestionNr lgId =
            Dict.get ( theQuestionNr, lgId ) questionsDict
                |> Maybe.map .questionAnswers
                |> (\x ->
                        case x of
                            Nothing ->
                                []

                            Just lans ->
                                lans
                   )

        validAnswers =
            List.map (\lgId -> getLgAnswers questionNr lgId) desiredLanguages
                |> List.concat
                |> Set.fromList
                |> Set.toList
    in
    validAnswers


getQuestionName : Int -> LanguageId -> String
getQuestionName nr lgId =
    let
        questionsDict =
            theQuestionsDict

        question =
            Dict.get ( nr, lgId ) questionsDict
    in
    question
        |> Maybe.map .questionName
        |> (\x ->
                case x of
                    Nothing ->
                        if lgId == "pt" then
                            "questão " ++ String.fromInt nr

                        else
                            "question " ++ String.fromInt nr

                    Just qname ->
                        qname
           )


getQuestionAvailableChoicesDict : Int -> Dict String (List ( String, String ))
getQuestionAvailableChoicesDict questionNr =
    let
        questionsDict =
            theQuestionsDict

        getLgOptions questionNrArg lgId =
            Dict.get ( questionNrArg, lgId ) questionsDict
                |> Maybe.map .availableChoices
                |> (\x ->
                        case x of
                            Nothing ->
                                []

                            Just lopt ->
                                lopt
                   )

        availableChoicesDict =
            List.foldl (\lgId d -> Dict.insert lgId (getLgOptions questionNr lgId) d) Dict.empty desiredLanguages
    in
    availableChoicesDict


interactingWithQuestionDict : Int -> Dict String (List String)
interactingWithQuestionDict nr =
    Dict.fromList
        [ ( "pt", interactingWithQuestion nr "pt" )
        , ( "en", interactingWithQuestion nr "en" )
        ]


interactingWithQuestion : Int -> LanguageId -> List String
interactingWithQuestion questionNr lgId =
    getQuestionBody questionNr lgId


{-| additionalTextIfAnswerCorrectDict : Int -> Dict String (List String)
additionalTextIfAnswerCorrectDict questionNr =
Dict.fromList
[ ( "pt", additionalTextIfAnswerCorrect questionNr "pt" )
, ( "en", additionalTextIfAnswerCorrect questionNr "en" )
]

additionalTextIfAnswerCorrect : Int -> LanguageId -> List String
additionalTextIfAnswerCorrect questionNr lgId =
Dict.get ( questionNr, lgId ) theQuestionsDict
|> Maybe.map .additionalTextIfCorrectAnswer
|> Maybe.withDefault [ "" ]

additionalTextIfAnswerIncorrectDict : Int -> Dict String (List String)
additionalTextIfAnswerIncorrectDict questionNr =
Dict.fromList
[ ( "pt", additionalTextIfAnswerIncorrect questionNr "pt" )
, ( "en", additionalTextIfAnswerIncorrect questionNr "en" )
]

additionalTextIfAnswerIncorrect : Int -> LanguageId -> List String
additionalTextIfAnswerIncorrect questionNr lgId =
Dict.get ( questionNr, lgId ) theQuestionsDict
|> Maybe.map .additionalTextIfIncorrectAnswer
|> Maybe.withDefault [ "" ]

-}
additionalTextIfAnswerCorrectDict : Int -> Dict String Types.FeedbackText
additionalTextIfAnswerCorrectDict questionNr =
    let
        getLgText : Int -> LanguageId -> Types.FeedbackText
        getLgText theNr lgId =
            Dict.get ( theNr, lgId ) NarrativeDataStructures.theQuestionsDict
                |> Maybe.map .additionalTextIfCorrectAnswer
                |> getLgTextHelper

        textOrFnDict : Dict String Types.FeedbackText
        textOrFnDict =
            List.foldl (\lgId d -> Dict.insert lgId (getLgText questionNr lgId) d) Dict.empty Narrative.desiredLanguages
    in
    textOrFnDict


getLgTextHelper : Maybe Types.FeedbackText -> Types.FeedbackText
getLgTextHelper mbftext =
    case mbftext of
        Nothing ->
            Types.NoFeedbackText

        Just s ->
            s


additionalTextIfAnswerIncorrectDict : Int -> Dict String Types.FeedbackText
additionalTextIfAnswerIncorrectDict questionNr =
    let
        getLgText : Int -> LanguageId -> Types.FeedbackText
        getLgText theNr lgId =
            Dict.get ( theNr, lgId ) NarrativeDataStructures.theQuestionsDict
                |> Maybe.map .additionalTextIfIncorrectAnswer
                |> getLgTextHelper

        textOrFnDict : Dict String Types.FeedbackText
        textOrFnDict =
            List.foldl (\lgId d -> Dict.insert lgId (getLgText questionNr lgId) d) Dict.empty Narrative.desiredLanguages
    in
    textOrFnDict


getQuestionsMaxNrTries : Int -> Maybe Int
getQuestionsMaxNrTries questionNr =
    let
        dictMaxTries =
            NarrativeDataStructures.questionsMaxNrTries
    in
    dictMaxTries
        |> Dict.get questionNr
        |> Maybe.withDefault Nothing


getMultiOptionBody : Int -> LanguageId -> List String
getMultiOptionBody nr lgId =
    let
        moptionDict =
            theMultiOptionsDict

        optionRec =
            Dict.get ( nr, lgId ) moptionDict
    in
    optionRec
        |> Maybe.map .optionBody
        |> (\x ->
                case x of
                    Nothing ->
                        []

                    Just obody ->
                        [ obody ]
           )


getMultiOptionBodyAsString : Int -> LanguageId -> String
getMultiOptionBodyAsString nr lgId =
    getMultiOptionBody nr lgId
        |> String.join " , "


getMultiOptionName : Int -> LanguageId -> String
getMultiOptionName nr lgId =
    let
        optionRec =
            theMultiOptionsDict
                |> Dict.get ( nr, lgId )
    in
    optionRec
        |> Maybe.map .optionName
        |> (\x ->
                case x of
                    Nothing ->
                        if lgId == "pt" then
                            "opção " ++ String.fromInt nr

                        else
                            "option " ++ String.fromInt nr

                    Just oname ->
                        oname
           )


getMultiOptionAvailableChoicesDict : Int -> Dict String (List ( String, String ))
getMultiOptionAvailableChoicesDict nr =
    let
        optionDict =
            theMultiOptionsDict

        getLgOptions theNr lgId optDict =
            Dict.get ( theNr, lgId ) optDict
                |> Maybe.map .availableChoices
                |> (\x ->
                        case x of
                            Nothing ->
                                []

                            Just lopt ->
                                List.map (\( k, v, stext ) -> ( k, v )) lopt
                   )

        availableChoicesDict =
            List.foldl (\lgId d -> Dict.insert lgId (getLgOptions nr lgId optionDict) d) Dict.empty desiredLanguages
    in
    availableChoicesDict


getMultiOptionTextIfChosenDict : Int -> String -> Dict String Types.FeedbackText
getMultiOptionTextIfChosenDict optionNr optKey =
    let
        optionDict : Dict ( Int, LanguageId ) MultiOption
        optionDict =
            NarrativeDataStructures.theMultiOptionsDict

        getLgText : Int -> LanguageId -> Dict ( Int, LanguageId ) MultiOption -> Types.FeedbackText
        getLgText theNr lgId optDict =
            Dict.get ( theNr, lgId ) optDict
                |> Maybe.map .availableChoices
                |> (\x ->
                        case x of
                            Nothing ->
                                Types.NoFeedbackText

                            Just lopt ->
                                List.filter (\( k, v, cfeedback ) -> k == optKey || k == "{__ANY__}") lopt
                                    |> List.map (\( k, v, cfeedback ) -> cfeedback)
                                    |> List.head
                                    |> Maybe.withDefault Types.NoFeedbackText
                   )

        textOrFnDict : Dict String Types.FeedbackText
        textOrFnDict =
            List.foldl (\lgId d -> Dict.insert lgId (getLgText optionNr lgId optionDict) d) Dict.empty Narrative.desiredLanguages
    in
    textOrFnDict


getMultiOptionAvailableChoicesValList : Int -> List String
getMultiOptionAvailableChoicesValList nr =
    let
        optionDict =
            theMultiOptionsDict

        getLgOptions theNr lgId optDict =
            Dict.get ( theNr, lgId ) optDict
                |> Maybe.map .availableChoices
                |> (\x ->
                        case x of
                            Nothing ->
                                []

                            Just lopt ->
                                List.map (\( k, v, stext ) -> k) lopt
                   )

        availableChoicesValList =
            List.map (\lgId -> getLgOptions nr lgId optionDict) desiredLanguages
                |> List.concat
                |> Set.fromList
                |> Set.toList
    in
    availableChoicesValList


interactingWithMultiOptionDict : Int -> Dict String (List String)
interactingWithMultiOptionDict nr =
    Dict.fromList
        [ ( "pt", interactingWithMultiOption nr "pt" )
        , ( "en", interactingWithMultiOption nr "en" )
        ]


interactingWithMultiOption : Int -> LanguageId -> List String
interactingWithMultiOption nr lgId =
    getMultiOptionBody nr lgId



-- Accessor Functions --


getNumberOfDesiredStages : Int
getNumberOfDesiredStages =
    NarrativeDataStructures.numberOfDesiredStages


getQuestionsAndOrOptionsOnEveryStageExcept : List Int
getQuestionsAndOrOptionsOnEveryStageExcept =
    NarrativeDataStructures.questionsAndOrOptionsOnEveryStageExcept


getAllStageNrs : List Int
getAllStageNrs =
    List.range 1 NarrativeDataStructures.numberOfDesiredStages


getLastStageId : String
getLastStageId =
    "stage" ++ String.fromInt NarrativeDataStructures.numberOfDesiredStages


getLastStageNr : Int
getLastStageNr =
    NarrativeDataStructures.numberOfDesiredStages


getPenultimateStageId : String
getPenultimateStageId =
    "stage" ++ String.fromInt (NarrativeDataStructures.numberOfDesiredStages - 1)


getPenultimateStageNr : Int
getPenultimateStageNr =
    NarrativeDataStructures.numberOfDesiredStages - 1


getQuestionId : Int -> String
getQuestionId nr =
    "question" ++ String.fromInt nr


getOptionId : Int -> String
getOptionId nr =
    "option" ++ String.fromInt nr


getStageId : Int -> String
getStageId nr =
    "stage" ++ String.fromInt nr


getQuestionNrsByStageNr : Int -> List Int
getQuestionNrsByStageNr stageNr =
    Dict.get stageNr getTheStagesExtraInfo
        |> Maybe.map .questionsList
        |> Maybe.withDefault []


getQuestionIdsByStageNr : Int -> List String
getQuestionIdsByStageNr stageNr =
    stageNr
        |> getQuestionNrsByStageNr
        |> List.map getQuestionId


getOptionNrsByStageNr : Int -> List Int
getOptionNrsByStageNr stageNr =
    Dict.get stageNr getTheStagesExtraInfo
        |> Maybe.map .optionsList
        |> Maybe.withDefault []


getOptionIdsByStageNr : Int -> List String
getOptionIdsByStageNr stageNr =
    stageNr
        |> getOptionNrsByStageNr
        |> List.map getOptionId


getStageQuestionIds : List String
getStageQuestionIds =
    getAllStageNrs
        |> List.map getQuestionIdsByStageNr
        |> List.concat


getFilteredStageQuestionIds : List String
getFilteredStageQuestionIds =
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
        |> List.map getQuestionIdsByStageNr
        |> List.concat


getStageQuestionNrs : List Int
getStageQuestionNrs =
    getAllStageNrs
        |> List.map getQuestionNrsByStageNr
        |> List.concat


getFilteredStageQuestionNrs : List Int
getFilteredStageQuestionNrs =
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
        |> List.map getQuestionNrsByStageNr
        |> List.concat


getStageOptionNrs : List Int
getStageOptionNrs =
    getAllStageNrs
        |> List.map getOptionNrsByStageNr
        |> List.concat


getStageOptionIds : List String
getStageOptionIds =
    getAllStageNrs
        |> List.map getOptionIdsByStageNr
        |> List.concat


getFilteredStageMultiOptionNrs : List Int
getFilteredStageMultiOptionNrs =
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
        |> List.map getOptionNrsByStageNr
        |> List.concat


getFilteredStageMultiOptionIds : List String
getFilteredStageMultiOptionIds =
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
        |> List.map getOptionIdsByStageNr
        |> List.concat


getListOfStageIdWithQuestions : List String
getListOfStageIdWithQuestions =
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
        |> List.map getStageId


getListOfStageNrsWithQuestions : List Int
getListOfStageNrsWithQuestions =
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))


getDisplayOptionButtonsOptionParam optionNr =
    Dict.get optionNr theMultiOptionParams
        |> Maybe.map (\x -> x.displayOptionButtons)


getResetPossibleOptionParam optionNr =
    Dict.get optionNr theMultiOptionParams
        |> Maybe.map (\x -> x.resetPossible)
