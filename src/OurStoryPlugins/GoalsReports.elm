module OurStoryPlugins.GoalsReports exposing (LanguageId, generateGoalsStatusReport)

import Dict exposing (Dict)
import Engine exposing (aDictStringListString, aDictStringString, astring, setAttributeValue)
import Engine.Manifest as EngineManifest
import TypeConverterHelper as Tconverter
import Types exposing (ChangeWorldCommand, InteractionExtraInfo, Manifest)


type alias LanguageId =
    String


generateGoalsStatusReport : List String -> List String -> List LanguageId -> Types.InteractionExtraInfo -> Manifest -> List ChangeWorldCommand
generateGoalsStatusReport questionIds optionIds llgIds extraInfo manifest =
    let
        questionStatusById qId =
            EngineManifest.getAttributeByIdAndInteractableId "isCorrectlyAnswered" qId manifest
                |> Tconverter.mbAttributeToMbBool True
                |> (\( x, y ) -> ( Maybe.withDefault False x, y ))
                |> Tuple.first

        getQuestionNamesDict : String -> Dict String String
        getQuestionNamesDict qId =
            EngineManifest.getAttributeByIdAndInteractableId "name" qId manifest
                |> Tconverter.mbAttributeToDictStringString True
                |> Tuple.first

        outputForQuestion : String -> LanguageId -> String
        outputForQuestion qId lgId =
            (Dict.get lgId (getQuestionNamesDict qId)
                |> Maybe.withDefault ("question_" ++ qId)
            )
                ++ "  :  "
                ++ (if questionStatusById qId then
                        "Done"

                    else
                        "To Do"
                   )

        outputForAllQuestions : LanguageId -> List String
        outputForAllQuestions lgId =
            List.map (\qId -> outputForQuestion qId lgId) questionIds

        outputForAllDoneQuestions : LanguageId -> List String
        outputForAllDoneQuestions lgId =
            List.filter (\qId -> questionStatusById qId) questionIds
                |> List.map (\qId -> outputForQuestion qId lgId)

        outputForAllToDoQuestions : LanguageId -> List String
        outputForAllToDoQuestions lgId =
            List.filter (\qId -> not (questionStatusById qId)) questionIds
                |> List.map (\qId -> outputForQuestion qId lgId)

        optionStatusById oId =
            EngineManifest.choiceHasAlreadyBeenMade oId manifest

        getOptionNamesDict : String -> Dict String String
        getOptionNamesDict oId =
            EngineManifest.getAttributeByIdAndInteractableId "name" oId manifest
                |> Tconverter.mbAttributeToDictStringString True
                |> Tuple.first

        outputForOption : String -> LanguageId -> String
        outputForOption oId lgId =
            (Dict.get lgId (getOptionNamesDict oId)
                |> Maybe.withDefault ("option_" ++ oId)
            )
                ++ "  :  "
                ++ (if optionStatusById oId then
                        "Done"

                    else
                        "To Do"
                   )

        outputForAllOptions : LanguageId -> List String
        outputForAllOptions lgId =
            List.map (\oId -> outputForOption oId lgId) optionIds

        outputForAllDoneOptions : LanguageId -> List String
        outputForAllDoneOptions lgId =
            List.filter (\oid -> optionStatusById oid) optionIds
                |> List.map (\oId -> outputForOption oId lgId)

        outputForAllToDoOptions : LanguageId -> List String
        outputForAllToDoOptions lgId =
            List.filter (\oid -> not (optionStatusById oid)) optionIds
                |> List.map (\oId -> outputForOption oId lgId)

        outputForAllQuestionsAndOptions : LanguageId -> List String
        outputForAllQuestionsAndOptions lgId =
            List.append (outputForAllQuestions lgId) (outputForAllOptions lgId)

        outputForAllQuestionsAndOptionsSplitDoneAndToDo : LanguageId -> List String
        outputForAllQuestionsAndOptionsSplitDoneAndToDo lgId =
            outputForAllDoneOptions lgId
                |> List.append (outputForAllDoneQuestions lgId)
                |> List.append (outputForAllToDoOptions lgId)
                |> List.append (outputForAllToDoQuestions lgId)

        reportLgDict =
            List.map (\lgId -> ( lgId, outputForAllQuestionsAndOptionsSplitDoneAndToDo lgId )) llgIds
                |> Dict.fromList
    in
    [ setAttributeValue (aDictStringListString reportLgDict) "additionalTextDict" "goalsStatusPaper" ]
