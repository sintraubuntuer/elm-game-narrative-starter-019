module OurStory.Rules exposing
    ( rule
    , ruleWithAudioContent
    , ruleWithQuasiChange
    , rules
    , startingState
    )

import Audio
import ClientTypes exposing (AudioFileInfo)
import Components exposing (..)
import Dict exposing (Dict)
import Engine exposing (..)
import InfoForBkendApiRequests exposing (backendAnswerCheckerUrl)
import OurStory.Narrative as Narrative
import OurStory.NarrativeDSFuncs as NarrativeDSFuncs
    exposing
        ( getAllStageNrs
        , getFilteredStageMultiOptionIds
        , getFilteredStageMultiOptionNrs
        , getFilteredStageQuestionIds
        , getFilteredStageQuestionNrs
        , getLastStageId
        , getLastStageNr
        , getListOfStageIdWithQuestions
        , getListOfStageNrsWithQuestions
        , getNumberOfDesiredStages
        , getOptionId
        , getOptionIdsByStageNr
        , getOptionNrsByStageNr
        , getPenultimateStageId
        , getPenultimateStageNr
        , getQuestionId
        , getQuestionIdsByStageNr
        , getQuestionNrsByStageNr
        , getQuestionsAndOrOptionsOnEveryStageExcept
        , getStageId
        , getStageOptionIds
        , getStageOptionNrs
        , getStageQuestionIds
        , getStageQuestionNrs
        )
import OurStoryPlugins.GoalsReports exposing (..)


useGoalStatusReport : Bool
useGoalStatusReport =
    True


correctAnswerNotRequiredToMove : List Int
correctAnswerNotRequiredToMove =
    [ 3 ]



--import Types exposing (..)


{-| This specifies the initial story world model. At a minimum, you need to set a starting location with the `moveTo` command. You may also want to place various items and characters in different locations. You can also specify a starting scene if required.
-}
startingState : List Engine.ChangeWorldCommand
startingState =
    [ moveTo "onceUponAtime"
    , moveCharacterToLocation "playerOne" "onceUponAtime"
    , moveItemToLocation "gps" "stage1"
    , moveItemToLocationFixed "creditsInfo" ("stage" ++ String.fromInt getNumberOfDesiredStages)
    ]
        ++ moveQuestionsToStagesFixed
        ++ makeQuestionsAmultiChoice [ ( 201, True ), ( 202, True ), ( 301, True ), ( 401, True ), ( 402, True ), ( 701, True ) ]
        ++ makeStageQuestionsWritableExcept [ 201, 202, 301, 401, 402, 701 ]
        ++ moveMultiOptionsToStagesFixed
        ++ (if useGoalStatusReport then
                [ moveItemToCharacterInventory "playerOne" "goalsStatusPaper" ]

            else
                []
           )


startingStateQuasiChanges : List Engine.QuasiChangeWorldCommand
startingStateQuasiChanges =
    [ execute_CustomFuncUsingRandomElems 5 (\einfo lfloats manifest -> [ setAttributeValue (astring "niceone") "typeOfPlayer" "playerOne" ]) "playerOne" ]


moveQuestionsToStagesFixed : List Engine.ChangeWorldCommand
moveQuestionsToStagesFixed =
    let
        moveQuestionsToStageNr : Int -> List Engine.ChangeWorldCommand
        moveQuestionsToStageNr stageNr =
            let
                lquestionIds =
                    getQuestionIdsByStageNr stageNr

                stageId =
                    getStageId stageNr
            in
            List.map (\x -> moveItemToLocationFixed x stageId) lquestionIds
    in
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
        |> List.map moveQuestionsToStageNr
        |> List.concat


makeQuestionsAmultiChoice : List ( Int, Bool ) -> List Engine.ChangeWorldCommand
makeQuestionsAmultiChoice ltupQuestionNrs =
    let
        createForOneElem ( questionNr, bmakeUnwritable ) =
            [ createAmultiChoice (NarrativeDSFuncs.getQuestionAvailableChoicesDict questionNr) (getQuestionId questionNr) ]
                ++ (if bmakeUnwritable then
                        [ makeItemUnwritable (getQuestionId questionNr) ]

                    else
                        []
                   )
    in
    List.map createForOneElem ltupQuestionNrs
        |> List.concat


moveMultiOptionsToStagesFixed : List Engine.ChangeWorldCommand
moveMultiOptionsToStagesFixed =
    let
        moveMultiOptionsToStageNr : Int -> List Engine.ChangeWorldCommand
        moveMultiOptionsToStageNr stageNr =
            let
                loptionIds =
                    getOptionIdsByStageNr stageNr

                lIdAndNrs =
                    getOptionNrsByStageNr stageNr
                        |> List.map (\x -> ( getOptionId x, x ))

                stageId =
                    getStageId stageNr

                cwcmds1 =
                    loptionIds
                        |> List.map (\id -> moveItemToLocationFixed id stageId)

                cwcmds2 =
                    lIdAndNrs
                        |> List.map (\( id, nr ) -> createAmultiChoice (NarrativeDSFuncs.getMultiOptionAvailableChoicesDict nr) id)
            in
            List.append cwcmds2 cwcmds1
    in
    getAllStageNrs
        |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
        |> List.map moveMultiOptionsToStageNr
        |> List.concat


makeQuestionsWritableExcept : List Int -> List Engine.ChangeWorldCommand
makeQuestionsWritableExcept lnotWritable =
    let
        makeItWritable n =
            makeItemWritable (getQuestionId n)
    in
    getStageQuestionNrs
        |> List.filter (\x -> not (List.member x lnotWritable))
        |> List.map makeItWritable


makeStageQuestionsWritableExcept : List Int -> List Engine.ChangeWorldCommand
makeStageQuestionsWritableExcept lnotWritable =
    let
        makeItWritable n =
            makeItemWritable (getQuestionId n)
    in
    getFilteredStageQuestionNrs
        |> List.filter (\x -> not (List.member x lnotWritable))
        |> List.map makeItWritable


makeAllQuestionsWritable : List Engine.ChangeWorldCommand
makeAllQuestionsWritable =
    makeQuestionsWritableExcept []


{-| A simple helper for making rules, since I want all of my rules to include RuleData and Narrative components.
-}
rule : String -> Engine.Rule_ -> Dict String (List String) -> Entity
rule id ruleData narratives =
    entity id
        |> addRuleData (completeTheRule ruleData)
        |> addLanguageNarratives narratives


ruleWithQuasiChange : String -> Engine.Rule -> Dict String (List String) -> Entity
ruleWithQuasiChange id ruleData narratives =
    entity id
        |> addRuleData ruleData
        |> addLanguageNarratives narratives


ruleWithAudioContent : String -> Engine.Rule_ -> Dict String (List String) -> Dict String ClientTypes.AudioFileInfo -> Entity
ruleWithAudioContent id ruleData narratives audiodict =
    rule id ruleData narratives
        |> addAllLanguagesAudio audiodict


{-| The first parameter to `rule` is an id for that rule. It must be unique, but generally isn't used directly anywhere else (though it gets returned from `Engine.update`, so you could do some special behavior if a specific rule matches). I like to write a short summary of what the rule is for as the id to help me easily identify them.
Note that the ids used in the rules must match the ids set in `Manifest.elm`.
-}
standardRulesTryMoveToNplusOneAndFail : Int -> List Entity
standardRulesTryMoveToNplusOneAndFail stageNr =
    -- if one of the stage questions is not answered
    -- or one of the stage options is not chosen
    -- fails to move to the next stage
    let
        stageQuestionNrs =
            getQuestionNrsByStageNr stageNr

        stageOptionNrs =
            getOptionNrsByStageNr stageNr

        ruleForFailOnQuestionNr : Int -> Entity
        ruleForFailOnQuestionNr questionNr =
            rule ("interacting with higher Stage " ++ String.fromInt (stageNr + 1) ++ "  and failing because wrong answer on question " ++ String.fromInt questionNr)
                { interaction = with (getStageId (stageNr + 1))
                , conditions =
                    [ currentLocationIs (getStageId stageNr)
                    , characterIsInLocation "playerOne" (getStageId stageNr)
                    , itemIsNotCorrectlyAnswered (getQuestionId questionNr)
                    ]
                , changes =
                    []
                }
                (NarrativeDSFuncs.interactingWithStageNDict (stageNr + 1) "withoutPreviousAnswered")

        ruleForFailOnOptionNr : Int -> Entity
        ruleForFailOnOptionNr optionNr =
            rule ("interacting with higher Stage " ++ String.fromInt (stageNr + 1) ++ "  and failing because no choice made so far on option " ++ String.fromInt optionNr)
                { interaction = with (getStageId (stageNr + 1))
                , conditions =
                    [ currentLocationIs (getStageId stageNr)
                    , characterIsInLocation "playerOne" (getStageId stageNr)
                    , noChosenOptionYet (getOptionId optionNr)
                    ]
                , changes =
                    []
                }
                (NarrativeDSFuncs.interactingWithStageNDict (stageNr + 1) "withoutPreviousAnswered")
    in
    List.map ruleForFailOnQuestionNr stageQuestionNrs
        |> List.append (List.map ruleForFailOnOptionNr stageOptionNrs)


{-| type of rule we should use when we want the player to be able to move to stage N+1 only after
answering correctly to all the questions at stage N and also answering to the presented Options
-}
standardRuleMoveToNplusOneRestricted : Int -> Entity
standardRuleMoveToNplusOneRestricted stageNr =
    -- all stage questions must be answered
    -- all stage options must be answered
    rule ("interacting with Stage " ++ String.fromInt (stageNr + 1) ++ " from lower correct answer required")
        { interaction = with (getStageId (stageNr + 1))
        , conditions =
            getQuestionIdsByStageNr stageNr
                |> List.map itemIsCorrectlyAnswered
                |> List.append [ currentLocationIs (getStageId stageNr) ]
                |> List.append [ characterIsInLocation "playerOne" (getStageId stageNr) ]
                |> List.append
                    (getOptionIdsByStageNr stageNr
                        |> List.map choiceHasAlreadyBeenMade
                    )
        , changes =
            [ moveTo (getStageId (stageNr + 1))
            , moveCharacterToLocation "playerOne" (getStageId (stageNr + 1))
            ]
        }
        (NarrativeDSFuncs.interactingWithStageNDict (stageNr + 1) "defaultStageDescription")


{-| Same as above , but in this case no answer or correct answer to a question or option is required
-}
standardRuleMoveToNplusOneNotRestricted : Int -> Entity
standardRuleMoveToNplusOneNotRestricted stageNr =
    let
        currLocationId =
            if stageNr == 0 then
                "onceUponAtime"

            else
                getStageId stageNr
    in
    ruleWithQuasiChange ("interacting with Stage " ++ String.fromInt (stageNr + 1) ++ " from lower")
        { interaction = with (getStageId (stageNr + 1))
        , conditions =
            [ currentLocationIs currLocationId
            , characterIsInLocation "playerOne" currLocationId
            ]
        , changes =
            [ moveTo (getStageId (stageNr + 1))
            , moveCharacterToLocation "playerOne" (getStageId (stageNr + 1))
            ]
        , quasiChanges =
            if stageNr == 0 then
                startingStateQuasiChanges

            else
                []
        , quasiChangeWithBkend = noQuasiChangeWithBackend
        }
        (NarrativeDSFuncs.interactingWithStageNDict (stageNr + 1) "defaultStageDescription")


standardInteractionWithQuestionNr : Int -> Entity
standardInteractionWithQuestionNr questionNr =
    let
        correctAnswers =
            NarrativeDSFuncs.getQuestionAnswers questionNr

        --stageNr = questionNr
    in
    ruleWithQuasiChange ("view question" ++ String.fromInt questionNr)
        { interaction = with (getQuestionId questionNr)
        , conditions =
            []
        , changes = []
        , quasiChanges =
            [ check_IfAnswerCorrect
                correctAnswers
                (checkAnswerData
                    -- max number of tries to answer the Question
                    (NarrativeDSFuncs.getQuestionsMaxNrTries questionNr)
                    -- whether the answer checker should be case sensitive or case insensitive
                    caseInsensitiveAnswer
                    -- whether the answer checker should  pay attention to whitespaces
                    answerSpacesDontMatter
                    -- whether to show feedback about answer ( correct or incorrect )
                    headerAnswerAndCorrectIncorrect
                    -- Additional text dict ( in several languages) to show if question is correctly answered)
                    (NarrativeDSFuncs.additionalTextIfAnswerCorrectDict questionNr)
                    -- Additional text dict ( in several languages) to add if question is incorrectly answered
                    (NarrativeDSFuncs.additionalTextIfAnswerIncorrectDict questionNr)
                    -- List of attributes we want to create in the question ( Item ) if question is correctly answered
                    []
                    []
                )
                (getQuestionId questionNr)

            --simpleCheck_IfAnswerCorrect  correctAnswers (Just 5)  ( "question" ++ String.fromInt questionNr )
            ]
        , quasiChangeWithBkend = noQuasiChangeWithBackend
        }
        (NarrativeDSFuncs.interactingWithQuestionDict questionNr)


interactionWithQuestionNrAllQuestionsAndOptionsAnsweredButThisOne : ( Int, Int ) -> Entity
interactionWithQuestionNrAllQuestionsAndOptionsAnsweredButThisOne ( questionNr, stageNr ) =
    let
        correctAnswers =
            NarrativeDSFuncs.getQuestionAnswers questionNr

        lsuggestedInteractionIfLastStage =
            if stageNr == getLastStageNr then
                [ ( "suggestedInteraction", astring "finalPaper" ) ]

            else
                []

        additionalTextForStages =
            List.range 1 (getNumberOfDesiredStages - 1)
                |> List.map getStageId
                |> List.map (\x -> ( x, "additionalTextDict", aDictStringListString Narrative.additionalStageInfoAfterAllQuestionsAnsweredDict ))
    in
    ruleWithQuasiChange ("view question" ++ String.fromInt questionNr ++ " all questions answered but this one ")
        { interaction = with (getQuestionId questionNr)
        , conditions =
            getFilteredStageQuestionIds
                |> List.filter (\x -> x /= getQuestionId questionNr)
                |> List.map itemIsCorrectlyAnswered
                |> List.append [ itemIsOffScreen "finalPaper" ]
                |> List.append (getFilteredStageMultiOptionIds |> List.map choiceHasAlreadyBeenMade)
        , changes =
            []
        , quasiChanges =
            [ check_IfAnswerCorrect
                (NarrativeDSFuncs.getQuestionAnswers questionNr)
                (checkAnswerData
                    (NarrativeDSFuncs.getQuestionsMaxNrTries questionNr)
                    caseInsensitiveAnswer
                    answerSpacesDontMatter
                    headerAnswerAndCorrectIncorrect
                    (NarrativeDSFuncs.additionalTextIfAnswerCorrectDict questionNr)
                    (NarrativeDSFuncs.additionalTextIfAnswerIncorrectDict questionNr)
                    ([ ( "warningMessage", aDictStringListString Narrative.goodNewsMessageAfterAllQuestionsAnsweredDict ) ] ++ lsuggestedInteractionIfLastStage)
                    additionalTextForStages
                )
                (getQuestionId questionNr)

            --simpleCheck_IfAnswerCorrect  correctAnswers   ( NarrativeDSFuncs.getQuestionsMaxNrTries questionNr )  ( "question" ++ String.fromInt questionNr )
            ]
        , quasiChangeWithBkend = noQuasiChangeWithBackend
        }
        (NarrativeDSFuncs.interactingWithQuestionDict questionNr)


standardInteractionWithMultiOptionNr : Int -> Entity
standardInteractionWithMultiOptionNr optionNr =
    let
        lpossibleChoices =
            NarrativeDSFuncs.getMultiOptionAvailableChoicesValList optionNr

        optionId =
            getOptionId optionNr

        allCheckAndActs =
            List.map
                (\x ->
                    checkAndAct_IfChosenOptionIs
                        (checkOptionData
                            x
                            Dict.empty
                            []
                            []
                        )
                        optionId
                )
                lpossibleChoices
    in
    ruleWithQuasiChange ("view multi option" ++ String.fromInt optionNr)
        { interaction = with optionId
        , conditions =
            []
        , changes = []
        , quasiChanges =
            allCheckAndActs
        , quasiChangeWithBkend = noQuasiChangeWithBackend
        }
        (NarrativeDSFuncs.interactingWithMultiOptionDict optionNr)


interactionWithOptionNrAllQuestionsAndOptionsAnsweredButThisOne : ( Int, Int ) -> Entity
interactionWithOptionNrAllQuestionsAndOptionsAnsweredButThisOne ( optionNr, stageNr ) =
    let
        lpossibleChoices : List String
        lpossibleChoices =
            NarrativeDSFuncs.getMultiOptionAvailableChoicesValList optionNr

        optionId =
            getOptionId optionNr

        lsuggestedInteractionIfLastStage =
            if stageNr == getLastStageNr then
                [ ( "suggestedInteraction", astring "finalPaper" ) ]

            else
                []

        additionalTextForStages =
            List.range 1 (getNumberOfDesiredStages - 1)
                |> List.map getStageId
                |> List.map (\x -> ( x, "additionalTextDict", aDictStringListString Narrative.additionalStageInfoAfterAllQuestionsAnsweredDict ))

        allCheckAndActs =
            List.map
                (\x ->
                    checkAndAct_IfChosenOptionIs
                        (checkOptionData
                            x
                            Dict.empty
                            ([ ( "warningMessage", aDictStringListString Narrative.goodNewsMessageAfterAllQuestionsAnsweredDict ) ] ++ lsuggestedInteractionIfLastStage)
                            additionalTextForStages
                        )
                        optionId
                )
                lpossibleChoices
    in
    ruleWithQuasiChange ("view option" ++ String.fromInt optionNr ++ " all options chosen but this one ")
        { interaction = with optionId
        , conditions =
            getFilteredStageMultiOptionIds
                |> List.filter (\x -> x /= optionId)
                |> List.map choiceHasAlreadyBeenMade
                |> List.append [ itemIsOffScreen "finalPaper" ]
                |> List.append (getFilteredStageQuestionIds |> List.map itemIsCorrectlyAnswered)
        , changes =
            []
        , quasiChanges =
            allCheckAndActs
        , quasiChangeWithBkend = noQuasiChangeWithBackend
        }
        (NarrativeDSFuncs.interactingWithMultiOptionDict optionNr)


standardRuleMoveToNminusOne : Int -> Entity
standardRuleMoveToNminusOne stageNr =
    let
        ntype =
            "enteringFromHigherStage"
    in
    rule ("interacting with Stage " ++ String.fromInt (stageNr - 1) ++ " from higher")
        { interaction = with (getStageId (stageNr - 1))
        , conditions =
            [ currentLocationIs (getStageId stageNr)
            ]
        , changes =
            [ moveTo (getStageId (stageNr - 1))
            , moveCharacterToLocation "playerOne" (getStageId (stageNr - 1))
            ]
        }
        (NarrativeDSFuncs.interactingWithStageNDict (stageNr - 1) ntype)


lRulesInteractingWithGps : List Entity
lRulesInteractingWithGps =
    [ rule "taking gps"
        { interaction = with "gps"
        , conditions =
            [ characterIsInLocation "playerOne" "stage1"
            , itemIsInLocation "gps" "stage1"
            ]
        , changes =
            [ moveItemToCharacterInventory "playerOne" "gps" ]
        }
        Narrative.takeGpsDict
    , ruleWithQuasiChange "looking at gps"
        { interaction = with "gps"
        , conditions =
            []
        , changes =
            []
        , quasiChanges =
            [ write_GpsInfoToItem "gps" ]
        , quasiChangeWithBkend = noQuasiChangeWithBackend
        }
        Narrative.lookAtGpsDict
    ]


lRulesInteractingWithCreditsInfo : List Entity
lRulesInteractingWithCreditsInfo =
    [ rule "view creditsInfo"
        { interaction = with "creditsInfo"
        , conditions =
            [-- characterIsInLocation "playerOne" ( getLastStageId )
             -- , itemIsInLocation "creditsInfo"  ( getLastStageId )
            ]
        , changes =
            []
        }
        Narrative.theCreditsInformationDict
    ]


lRulesMakeFinalPaperAppearAfterAllQuestionsAnswered : List Entity
lRulesMakeFinalPaperAppearAfterAllQuestionsAnswered =
    [ rule "final paper appears player moving from penultimate stage to last stage"
        { interaction = with getLastStageId
        , conditions =
            getFilteredStageQuestionIds
                |> List.map itemIsCorrectlyAnswered
                |> List.append (getFilteredStageMultiOptionIds |> List.map choiceHasAlreadyBeenMade)
                |> List.append [ itemIsOffScreen "finalPaper" ]
                |> List.append [ currentLocationIs getPenultimateStageId ]
                |> List.append [ characterIsInLocation "playerOne" getPenultimateStageId ]
        , changes =
            [ moveTo getLastStageId
            , moveCharacterToLocation "playerOne" getLastStageId
            , moveItemToLocation "finalPaper" getLastStageId
            ]
        }
        (NarrativeDSFuncs.interactingWithStageNDict getLastStageNr "defaultStageDescription")
    ]


lRuleInteractingWithFinalPaper : List Entity
lRuleInteractingWithFinalPaper =
    [ rule "interaction With Final Paper"
        { interaction = with "finalPaper"
        , conditions =
            getFilteredStageQuestionIds
                |> List.map itemIsCorrectlyAnswered
        , changes =
            [ setAttributeValue (abool True) "gameHasEnded" "gameStateItem"
            , moveItemToCharacterInventory "playerOne" "finalPaper"
            ]
        }
        Narrative.interactingWithFinalPaperDict
    ]


lRulesInteractingWithGoalsStatusPaper : List Entity
lRulesInteractingWithGoalsStatusPaper =
    let
        questionIds =
            --getAllStageNrs |> List.concatMap getQuestionIdsByStageNr
            getFilteredStageQuestionIds

        optionIds =
            --getAllStageNrs |> List.concatMap getOptionIdsByStageNr
            getFilteredStageMultiOptionIds

        llgIds =
            [ "pt", "en" ]
    in
    [ rule "taking goals status paper"
        { interaction = with "goalsStatusPaper"
        , conditions =
            [ characterIsInLocation "playerOne" "stage1"
            , itemIsInLocation "goalsStatusPaper" "stage1"
            ]
        , changes =
            [ moveItemToCharacterInventory "playerOne" "goalsStatusPaper" ]
        }
        --Narrative.takeGoalsStatusPaperDict -- ToDo : To Write
        Dict.empty
    , ruleWithQuasiChange "looking at goals status paper"
        { interaction = with "goalsStatusPaper"
        , conditions =
            []
        , changes =
            []
        , quasiChanges =
            [ execute_CustomFunc (OurStoryPlugins.GoalsReports.generateGoalsStatusReport questionIds optionIds llgIds) "goalsStatusPaper"
            ]
        , quasiChangeWithBkend = noQuasiChangeWithBackend
        }
        --Narrative.lookAtGpsDict
        (Dict.fromList
            [ ( "pt", [ "" ] ), ( "en", [ "" ] ) ]
        )
    ]


lRuleGameHasEnded : List Entity
lRuleGameHasEnded =
    [ rule "game has ended"
        { interaction =
            withAnyLocationAnyCharacterAfterGameEnded

        --withAnythingAfterGameEnded
        , conditions =
            [ attrValueIsEqualTo (abool True) "gameHasEnded" "gameStateItem"
            ]
        , changes =
            [ endStory "notFreezingEnd" "The End"
            ]
        }
        Narrative.gameHasEndedDict
    ]


{-| All of the rules that govern your story.
Order does not matter, but I like to organize the rules by the story objects they are triggered by. This makes it easier to ensure I have set up the correct criteria so the right rule will match at the right time.
Note that the ids used in the rules must match the ids set in `Manifest.elm`.
-}
rules : Dict String Components
rules =
    let
        listOfStageNrs =
            getAllStageNrs

        lRulesToTryMoveToNextStageAndFail =
            List.take (List.length listOfStageNrs - 1) listOfStageNrs
                |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
                |> List.filter (\x -> not (List.member x correctAnswerNotRequiredToMove))
                |> List.map standardRulesTryMoveToNplusOneAndFail
                |> List.concat

        lRulesToMoveToNextStageRestricted =
            List.take (List.length listOfStageNrs - 1) listOfStageNrs
                |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
                |> List.filter (\x -> not (List.member x correctAnswerNotRequiredToMove))
                |> List.map standardRuleMoveToNplusOneRestricted

        lRulesToMoveToNextStageNotRestricted =
            List.take (List.length listOfStageNrs - 1) listOfStageNrs
                |> List.filter
                    (\x ->
                        List.member x getQuestionsAndOrOptionsOnEveryStageExcept
                            || List.member x correctAnswerNotRequiredToMove
                    )
                -- theres's no restriction when moving from stage0 ("onceuponatime") to stage1
                |> List.append [ 0 ]
                |> List.map standardRuleMoveToNplusOneNotRestricted

        lRulesToMoveToPreviousStage =
            List.tail listOfStageNrs
                |> Maybe.withDefault []
                |> List.map standardRuleMoveToNminusOne

        lRulesAboutQuestions =
            getAllStageNrs
                |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
                |> List.map getQuestionNrsByStageNr
                |> List.concat
                |> List.map standardInteractionWithQuestionNr

        lRulesAboutMultiOptions =
            getAllStageNrs
                |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
                |> List.map getOptionNrsByStageNr
                |> List.concat
                |> List.map standardInteractionWithMultiOptionNr

        lRulesAboutQuestionsAllQuestionsAndOptionsAnsweredButOne =
            getAllStageNrs
                |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
                |> List.map (\x -> ( x, getQuestionNrsByStageNr x ))
                |> List.map (\( x, ly ) -> List.map (\yelem -> ( yelem, x )) ly)
                |> List.concat
                |> List.map interactionWithQuestionNrAllQuestionsAndOptionsAnsweredButThisOne

        lRulesAboutOptionsAllQuestionsAndOptionsAnsweredButOne =
            getAllStageNrs
                |> List.filter (\x -> not (List.member x getQuestionsAndOrOptionsOnEveryStageExcept))
                |> List.map (\x -> ( x, getOptionNrsByStageNr x ))
                |> List.map (\( x, ly ) -> List.map (\yelem -> ( yelem, x )) ly)
                |> List.concat
                |> List.map interactionWithOptionNrAllQuestionsAndOptionsAnsweredButThisOne

        lRules =
            List.append lRulesToMoveToNextStageRestricted lRulesToMoveToPreviousStage
                |> List.append lRulesToTryMoveToNextStageAndFail
                |> List.append lRulesToMoveToNextStageNotRestricted
                |> List.append lRulesAboutQuestions
                |> List.append lRulesAboutMultiOptions
                |> List.append lRulesInteractingWithGps
                |> List.append lRulesInteractingWithCreditsInfo
                |> List.append lRulesMakeFinalPaperAppearAfterAllQuestionsAnswered
                -- warns that player should move to final stage after final question is correctly answered
                |> List.append lRulesAboutQuestionsAllQuestionsAndOptionsAnsweredButOne
                |> List.append lRulesAboutOptionsAllQuestionsAndOptionsAnsweredButOne
                |> List.append lRuleInteractingWithFinalPaper
                |> List.append lRulesInteractingWithGoalsStatusPaper
                |> List.append lRuleGameHasEnded
    in
    lRules
        |> Dict.fromList
