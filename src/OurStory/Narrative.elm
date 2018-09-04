module OurStory.Narrative exposing
    ( LanguageId
    , additionalStageInfoAfterAllQuestionsAnsweredDict
    , additionalStageInfoAfterQuestionAnsweredDict
    , creditsInformation
    , desiredLanguages
    , endScreenInfo
    , gameHasEnded
    , gameHasEndedDict
    , gameHasEndedEn
    , goodNewsMessageAfterAllQuestionsAnsweredDict
    , goodNewsMessageAfterAllQuestionsAnsweredEn
    , goodNewsMessageAfterAllQuestionsAnsweredPt
    , initialChoiceLanguages
    , interactingWithFinalPaperDict
    , interactingWithFinalPaperEn
    , interactingWithFinalPaperPt
    , interactingWithPlayerOne
    , interactingWithPlayerOneDict
    , interactingWithPlayerOneEn
    , lookAtGps
    , lookAtGpsDict
    , lookAtGpsEn
    , startScreenInfo
    , startingNarrative
    , startingNarrativeEn
    , startingNarratives
    , takeGps
    , takeGpsDict
    , takeGpsEn
    , theCreditsInformationDict
    )

import ClientTypes exposing (..)
import Dict exposing (Dict)
import Set



{- These are  the languages for which it is mandatory  to generate  narrative content regarding each interaction
   if  no narrative content exists some default is used
   like for instance the  entity description defined in the manifest
-}


desiredLanguages : List String
desiredLanguages =
    [ "pt", "en" ]



{- These are the languages that are displayed in the sidebar and the user can choose from
   These are  initial values , but they might eventually change along the narrative
-}


initialChoiceLanguages : Dict String String
initialChoiceLanguages =
    Dict.fromList
        [ ( "pt", "portuguese" )
        , ( "en", "english" )
        ]


{-| Info to be displayed on StartScreen
-}
startScreenInfo : StartScreenInfo
startScreenInfo =
    { mainImage = "introImage.png"
    , title_line1 = "A Guided Tour Through Vila Sassetti - Sintra"
    , title_line2 = ""
    , byLine = "An Interactive Story by Sintra Ubuntuer"
    , smallIntro = """ a guided tour through Vila Sassetti ( Quinta da Amizade ) - Sintra
                     """
    , tboxNamePlaceholder = "investigator"
    }


endScreenInfo : EndScreenInfo
endScreenInfo =
    { mainImage = "finalImage.png"
    , congratsMessage1 = "Congratulations ! You reached the End ! ..."
    , congratsMessage2 = "You are now a hiking trail Master  :)"
    , endScreenText = """....
                        """
    }



{- Here is where you can write all of your story text, which keeps the Rules.elm file a little cleaner.
   The narrative that you add to a rule will be shown when that rule matches.  If you give a list of strings, each time the rule matches, it will show the next narrative in the list, which is nice for adding variety and texture to your story.
   I sometimes like to write all my narrative content first, then create the rules they correspond to.
   Note that you can use **markdown** in your text!
-}


startingNarratives : Dict String (List StorySnippet)
startingNarratives =
    Dict.fromList
        [ ( "pt", [ startingNarrative ] )
        , ( "en", [ startingNarrativeEn ] )
        ]


{-| The text that will show when the story first starts, before the player interacts with anythin.
-}
startingNarrative : StorySnippet
startingNarrative =
    { interactableName = "Percurso Pedestre Vila Sassetti..."
    , interactableId = "onceUponAtime"
    , isWritable = False
    , interactableCssSelector = "opening"
    , narrative =
        """Num  dia luminoso de Setembro encontras-te na
            bela Vila de Sintra prestes a iniciar o percurso pedestre de Vila Sassetti
            ( Quinta da Amizade )
         """
    , mbAudio = Nothing
    , mbSuggestedInteractionId = Nothing
    , mbSuggestedInteractionName = Nothing
    , isLastInZipper = True
    }


startingNarrativeEn : StorySnippet
startingNarrativeEn =
    { interactableName = "Pedestrian Footpath..."
    , interactableId = "onceUponAtime"
    , isWritable = False
    , interactableCssSelector = "opening"
    , narrative =
        """On a shiny September day you find yourself in the magnificent Vila de Sintra
             about to start Vila Sassetti ( Quinta da Amizade ) pedestrian footpath ...
       """
    , mbAudio = Nothing
    , mbSuggestedInteractionId = Nothing
    , mbSuggestedInteractionName = Nothing
    , isLastInZipper = True
    }


interactingWithPlayerOneDict : Dict String (List String)
interactingWithPlayerOneDict =
    Dict.fromList
        [ ( "pt", interactingWithPlayerOne )
        , ( "en", interactingWithPlayerOneEn )
        ]


interactingWithPlayerOne : List String
interactingWithPlayerOne =
    [ """
. . .
      """
    ]


interactingWithPlayerOneEn : List String
interactingWithPlayerOneEn =
    [ """
. . .
      """
    ]


type alias LanguageId =
    String


additionalStageInfoAfterQuestionAnsweredDict : Dict String (List String)
additionalStageInfoAfterQuestionAnsweredDict =
    Dict.fromList
        [ ( "pt", [ "A questão deste nivel já está respondida ... " ] )
        , ( "en", [ "question on this stage is already  answered ... " ] )
        ]


additionalStageInfoAfterAllQuestionsAnsweredDict : Dict String (List String)
additionalStageInfoAfterAllQuestionsAnsweredDict =
    Dict.fromList
        [ ( "pt", [ "Todas as questões foram respondidas. Dirige-te para o ultimo nivel ... " ] )
        , ( "en", [ "All questions have been answered. Now move to the last stage ... " ] )
        ]


takeGpsDict : Dict String (List String)
takeGpsDict =
    Dict.fromList
        [ ( "pt", takeGps )
        , ( "en", takeGpsEn )
        ]


takeGps : List String
takeGps =
    [ "Guardas cuidadosamente o Gps " ]


takeGpsEn : List String
takeGpsEn =
    [ """
You carefully pick up and store the gps receiver !
     """ ]


lookAtGpsDict : Dict String (List String)
lookAtGpsDict =
    Dict.fromList
        [ ( "pt", lookAtGps )
        , ( "en", lookAtGpsEn )
        ]


lookAtGps : List String
lookAtGps =
    [ """
Consultas o aparelho receptor de gps :
    """
    ]


lookAtGpsEn : List String
lookAtGpsEn =
    [ """
You look at your gps receiver device :
    """ ]


goodNewsMessageAfterAllQuestionsAnsweredDict : Dict String (List String)
goodNewsMessageAfterAllQuestionsAnsweredDict =
    Dict.fromList
        [ ( "pt", goodNewsMessageAfterAllQuestionsAnsweredPt )
        , ( "en", goodNewsMessageAfterAllQuestionsAnsweredEn )
        ]


goodNewsMessageAfterAllQuestionsAnsweredPt : List String
goodNewsMessageAfterAllQuestionsAnsweredPt =
    [ """
Respondeste a todas as perguntas ... Procura o papiro no ultimo nivel
       """ ]


goodNewsMessageAfterAllQuestionsAnsweredEn : List String
goodNewsMessageAfterAllQuestionsAnsweredEn =
    [ """
All questions have been answered . Look for an old paper in last stage ...
       """ ]


interactingWithFinalPaperDict : Dict String (List String)
interactingWithFinalPaperDict =
    Dict.fromList
        [ ( "pt", interactingWithFinalPaperPt )
        , ( "en", interactingWithFinalPaperEn )
        ]


interactingWithFinalPaperPt : List String
interactingWithFinalPaperPt =
    [ """
Parabéns ! Superaste todos os desafios propostos.
Encontarás uma agradável surpresa em ...

 O jogo chegou ao fim !
      """
    ]


interactingWithFinalPaperEn : List String
interactingWithFinalPaperEn =
    [ """
Congratulations ! You overcome all challenges.
You will find a nice surprise located at ...

 Game has ended !
     """
    ]


theCreditsInformationDict : Dict String (List String)
theCreditsInformationDict =
    Dict.fromList
        [ ( "pt", creditsInformation )
        , ( "en", creditsInformation )
        ]


creditsInformation : List String
creditsInformation =
    [ """
### Location Info : ###
http://www.parquesdesintra.pt/


### Elm Language and package ecosystem ###

Evan Czaplicki ,  Richard Feldman , Werner de Groot , Dave Keen ...

### Elm Narrative Engine : ###

Jeff Schomay

( the persons above in no way endorse this particular extension or narrative)

### extensions to the Narrative Engine : ###

Nuno Torres

### Game-Narrative ###

Nuno Torres

    """
    ]


gameHasEndedDict : Dict String (List String)
gameHasEndedDict =
    Dict.fromList
        [ ( "pt", gameHasEnded )
        , ( "en", gameHasEndedEn )
        ]


gameHasEnded : List String
gameHasEnded =
    [ """
Este jogo acabou ! Podes consultar todos os items no teu inventário ,
mas o jogo chegou ao fim ! Diverte-te !
      """
    ]


gameHasEndedEn : List String
gameHasEndedEn =
    [ """
Game has Ended ! You can take a look at your inventory items ( but game has ended ) ! Have Fun !
      """
    ]
