module OurStory.NarrativeDataStructures exposing
    ( LanguageId
    , MultiOption
    , Question
    , numberOfDesiredStages
    , questionsAndOrOptionsOnEveryStageExcept
    , questionsMaxNrTries
    , theMultiOptionParams
    , theMultiOptionsDict
    , theQuestionsDict
    , theStagesDict
    , theStagesExtraInfo
    )

import ClientTypes
import Dict exposing (Dict)
import Types exposing (ChoiceMatches(..), FeedbackText(..), Manifest)


type alias LanguageId =
    String


type alias Question =
    { questionBody : String
    , questionName : String
    , additionalTextIfCorrectAnswer : FeedbackText
    , additionalTextIfIncorrectAnswer : FeedbackText
    , availableChoices : List ( String, String )
    , questionAnswers : List String
    }


type alias MultiOption =
    { optionBody : String
    , optionName : String
    , availableChoices : List ( String, String, FeedbackText )
    }


numberOfDesiredStages : Int
numberOfDesiredStages =
    10


questionsAndOrOptionsOnEveryStageExcept : List Int
questionsAndOrOptionsOnEveryStageExcept =
    []


theStagesDict : Dict ( Int, LanguageId ) { stageNarrative : List String, stageName : String }
theStagesDict =
    Dict.fromList
        [ ( ( 1, "pt" )
          , { stageNarrative = [ """
![pic500](img/entradaVilaSassetti.png)

Estás na bonita Vila de Sintra próximo da entrada do percurso pedestre
da Vila Sassetti ( Quinta da Amizade ) ...

"Este percurso pedestre permite o acesso ao Palácio Nacional da Pena e ao Castelo dos Mouros, desde o Centro Histórico de Sintra.

A Vila Sassetti está integrada na Paisagem Cultural de Sintra, classificada como Património da Humanidade pela UNESCO.

O jardim, concebido pelo arquiteto Luigi Manini, procura obedecer a uma estética naturalista, sendo estruturado por um caminho sinuoso que é atravessado por uma linha de água artificial. O jardim expressa a relação de harmonia entre a arquitetura e a paisagem, que assim parecem fundir-se naturalmente."

![pic500](img/entradaVilaSassetti2.png)

![pic500](img/entradaVilaSassetti3.png)
            """ ]
            , stageName = "Stage 1 - Inicio "
            }
          )
        , ( ( 1, "en" )
          , { stageNarrative = [ """
![pic500](img/entradaVilaSassetti.png)

You are in the beautiful village of Sintra near the start of Vila Sassetti Pedestrian Footpath ...

"The Footpath  provides access to the National Palace of Pena and the Moorish Castle from the Historical Centre of Sintra.

Villa Sassetti is integrated into the Cultural Landscape of Sintra, classified as UNESCO World Heritage.

The garden, designed by the architect Luigi Manini, strives to obey a naturalist aesthetic structured around a twisting pathway criss-crossed by an artificial watercourse. The garden expresses the harmonious relationship between architecture and the landscape that seem able to naturally merge into each other. "

![pic500](img/entradaVilaSassetti2.png)

![pic500](img/entradaVilaSassetti3.png)
    """ ]
            , stageName = "Stage 1 - Start"
            }
          )
        , ( ( 2, "pt" )
          , { stageNarrative = [ """
![pic500](img/largo.png)

Estás agora num pequeno largo ... À esquerda ( de quem sobe ) é possível observar um extenso banco com vários pequenos azulejos
e à direita ( de quem sobe ) é possível observar uma espécie de trono

![pic500](img/largo2.png)

          """ ]
            , stageName = "Stage 2 - o largo "
            }
          )
        , ( ( 2, "en" )
          , { stageNarrative = [ """
![pic500](img/largo.png)

you are now on a small round space ... To the left ( when going up ) one can observe a large bank with several small tiles
and to the right ( when going up ) one can observe a sort of throne chair ...

![pic500](img/largo2.png)

          """ ]
            , stageName = "Stage 2"
            }
          )
        , ( ( 3, "pt" )
          , { stageNarrative = [ """
![pic500](img/arcadas.png)
          """ ]
            , stageName = "Stage 3 - arcade"
            }
          )
        , ( ( 3, "en" )
          , { stageNarrative = [ """
![pic500](img/arcadas.png)
          """ ]
            , stageName = "Stage 3 - arcade "
            }
          )
        , ( ( 4, "pt" )
          , { stageNarrative = [ """Estás agora junto ao Edifício Principal ...

![pic500](img/casaPrincipal.png)

" O edifício principal distingue-se pela torre circular central de três pisos ,
a partir da qual se estendem outros corpos de geometria variável
, empregando o granito de Sintra como revestimento exterior principal
, as faixas de terracota características do estilo Românico Lombardo e diversas
peças da coleção de antiquária do comitente "

![pic500](img/casaPrincipalRelogio.png)
            """ ]
            , stageName = "Stage 4 - Edificio Principal"
            }
          )
        , ( ( 4, "en" )
          , { stageNarrative = [ """You are now next to the Main Building ...

![pic500](img/casaPrincipal.png)

"The main building stands out for its central circular tower spanning three storeys
, out of which extend other constructions with variable geometries
, applying Sintra granite as the main exterior finishing material with rows of terracotta
characteristic of the Lombard Romanesque
, alongside diverse pieces from the antiques collection of the owner"

![pic500](img/casaPrincipalRelogio.png)
          """ ]
            , stageName = "Stage 4 - Main Building"
            }
          )
        , ( ( 5, "pt" )
          , { stageNarrative = [ """Estás agora em 5 ... À tua volta vês ...

![pic500](img/camelliaJaponica.png)
            """ ]
            , stageName = "Stage 5 - a Planta"
            }
          )
        , ( ( 5, "en" )
          , { stageNarrative = [ """You are now in stage 5 ... You look around and see ...

![pic500](img/camelliaJaponica.png)
            """ ]
            , stageName = "Stage 5 - the Plant"
            }
          )
        , ( ( 6, "pt" )
          , { stageNarrative = [ """reparas que estás junto a uma enigmática cadeira ...

![pic500](img/cadeira.png)
            """ ]
            , stageName = "Stage 6 - a cadeira"
            }
          )
        , ( ( 6, "en" )
          , { stageNarrative = [ """You notice an enigmatic chair right next to you
![pic500](img/cadeira.png)
            """ ]
            , stageName = "Stage 6 - the Chair"
            }
          )
        , ( ( 7, "pt" )
          , { stageNarrative = [ """
![pic500](img/rochedo1.png)

![pic500](img/rochedo2.png)
          """ ]
            , stageName = "Stage 7 - o Rochedo"
            }
          )
        , ( ( 7, "en" )
          , { stageNarrative = [ """
![pic500](img/rochedo1.png)

![pic500](img/rochedo2.png)
          """ ]
            , stageName = "Stage 7 - the Rock"
            }
          )
        , ( ( 8, "pt" )
          , { stageNarrative = [ """
![pic500](img/portaSaida_.png)

![pic500](img/placardProximoSaida1.png)
             """ ]
            , stageName = "Stage 8 - placard informativo"
            }
          )
        , ( ( 8, "en" )
          , { stageNarrative = [ """
![pic500](img/portaSaida_.png)

![pic500](img/placardProximoSaida1.png)
          """ ]
            , stageName = "Stage 8 - info"
            }
          )
        , ( ( 9, "pt" )
          , { stageNarrative = [ """Estás agora junto a um topoguia sobre as vias de escalada do Penedo da Amizade

![pic500](img/viasPenedoDaAmizade.png)
          """ ]
            , stageName = "Stage 9 - Topoguia"
            }
          )
        , ( ( 9, "en" )
          , { stageNarrative = [ """You are now next to a rock climbing guide that presents some info about Penedo da Amizade climbing routes

![pic500](img/viasPenedoDaAmizade.png)
          """ ]
            , stageName = "Stage 9 - Rock climbing guide"
            }
          )
        , ( ( 10, "pt" )
          , { stageNarrative = [ """Passaste pela  última porta e encontras-te agora no Penedo da Amizade ...

![pic500](img/portaSaida.png)

À tua esquerda encontra-se um placard informativo com distâncias relativamente a alguns pontos de interesse

![pic500](img/placardProximoSaidaDistancias.png)
          """ ]
            , stageName = "Stage 10 - Penedo da Amizade"
            }
          )
        , ( ( 10, "en" )
          , { stageNarrative = [ """You've gone through the last door and are now in Penedo da Amizade ...

![pic500](img/portaSaida.png)

To your left there's info on distances to some Points of Interest

![pic500](img/placardProximoSaidaDistancias.png)
          """ ]
            , stageName = "Stage 10 - Penedo da Amizade"
            }
          )
        ]


theStagesExtraInfo : Dict Int { questionsList : List Int, optionsList : List Int }
theStagesExtraInfo =
    Dict.fromList
        [ ( 1
          , { questionsList = [ 101 ]
            , optionsList = [ 101 ]
            }
          )
        , ( 2
          , { questionsList = [ 201, 202 ]
            , optionsList = [ 201 ]
            }
          )
        , ( 3
          , { questionsList = [ 301 ]
            , optionsList = [ 301 ]
            }
          )
        , ( 4
          , { questionsList = [ 401, 402 ]
            , optionsList = [ 401 ]
            }
          )
        , ( 5
          , { questionsList = [ 501 ]
            , optionsList = []
            }
          )
        , ( 6
          , { questionsList = [ 601 ]
            , optionsList = [ 601 ]
            }
          )
        , ( 7
          , { questionsList = [ 701 ]
            , optionsList = []
            }
          )
        , ( 8
          , { questionsList = [ 801 ]
            , optionsList = []
            }
          )
        , ( 9
          , { questionsList = [ 901 ]
            , optionsList = []
            }
          )
        , ( 10
          , { questionsList = [ 1001 ]
            , optionsList = []
            }
          )
        ]


theQuestionsDict : Dict ( Int, LanguageId ) Question
theQuestionsDict =
    Dict.fromList
        [ ( ( 101, "pt" )
          , { questionBody = "Próximo da entrada da Vila Sassetti está também a entrada para um outro Parque. De que parque se trata ?"
            , questionName = "questão 1"
            , additionalTextIfCorrectAnswer = SimpleText [ """Muito Bem ! A entrada do parque das merendas fica de facto ao lado da entrada para Vila Sassetti !
              """ ]
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "Parque das Merendas", "Merendas" ]
            }
          )
        , ( ( 101, "en" )
          , { questionBody = "Near the entrance of Vila Sassetti is also the entrance to another Park . What's that Park ? "
            , questionName = "question 1"
            , additionalTextIfCorrectAnswer = SimpleText [ """Well Done ! The entrance to Parque das Merendas is located right next to the entrance to Vila Sassetti !
              """ ]
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []

            -- no need to duplicate answers . Just add the ones that eventually make sense in a different language
            -- program will "merge" all the answers lists and accept all as valid regardless of the language
            , questionAnswers = []
            }
          )
        , ( ( 201, "pt" )
          , { questionBody = "quantos azulejos observas no maior banco  ?"
            , questionName = "questão 2"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = SimpleText [ "Vá lá ... Não é uma pergunta difícil ! " ]
            , availableChoices = [ ( "18", "Dezoito (18)" ), ( "19", "Dezanove (19)" ), ( "20", "Vinte (20)" ), ( "21", "Vinte e um (21)" ), ( "22", "Vinte e dois (22)" ), ( "23", "Vinte e três (23)" ) ]
            , questionAnswers = [ "21", "vinte e um" ]
            }
          )
        , ( ( 201, "en" )
          , { questionBody = "How many tiles do you see on the biggest seat  ?"
            , questionName = "question 2"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = SimpleText [ "Come on ... That's is not a tough question ! " ]
            , availableChoices = [ ( "18", "Eighteen (18)" ), ( "19", "Nineteen (19)" ), ( "20", "Twenty (20)" ), ( "21", "Twenty One (21)" ), ( "22", "Twenty Two (22)" ), ( "23", "Twenty Three (23)" ), ( "24", "Twenty Four (24)" ), ( "25", "Twenty Five (25)" ) ]

            -- no need to duplicate answers . Just add the ones that eventually make sense in a different language
            -- program will "merge" all the answers lists (to the same question) and accept all as valid regardless of the language
            , questionAnswers = [ "twenty one" ]
            }
          )
        , ( ( 202, "pt" )
          , { questionBody = "quantos circulos estão sobre a coroa   ?"
            , questionName = "questão 22"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = SimpleText [ "Vá lá ... Não é uma pergunta difícil ! " ]
            , availableChoices = [ ( "2", "Dois (2)" ), ( "3", "Três (3)" ), ( "4", "Quatro (4)" ), ( "5", "Cinco (5)" ), ( "6", "Seis (6)" ) ]
            , questionAnswers = [ "5", "cinco" ]
            }
          )
        , ( ( 202, "en" )
          , { questionBody = "How many circles over the crown  ?"
            , questionName = "question 22"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = SimpleText [ "Come on ... That is not a tough question ! " ]
            , availableChoices = [ ( "2", "Two (2)" ), ( "3", "Three (3)" ), ( "4", "Four (4)" ), ( "5", "Five (5)" ), ( "6", "Six (6)" ) ]
            , questionAnswers = [ "five" ]
            }
          )
        , ( ( 301, "pt" )
          , { questionBody = """Quantos pilares consegues contar até ao placard que indica "Casa do Caseiro , Casa Principal , etc ..." """
            , questionName = "questão 3"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "9", "Nove (9)" ), ( "11", "Onze (11)" ), ( "13", "Treze (13)" ), ( "15", "Quinze (15)" ), ( "17", "Dezassete (17)" ) ]
            , questionAnswers = [ "15", "quinze" ]
            }
          )
        , ( ( 301, "en" )
          , { questionBody = """How many pillars can you count from here to the placard with "Casa do Caseiro , Casa Principal , etc ..." written on it """
            , questionName = "question 3"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "9", "Nine (9)" ), ( "11", "Eleven (11)" ), ( "13", "Thirteen (13)" ), ( "15", "Fifteen (15)" ), ( "17", "Seventeen (17)" ) ]
            , questionAnswers = [ "fifteen" ]
            }
          )
        , ( ( 401, "pt" )
          , { questionBody = """O relógio de sol indica de que horas a que horas (ex: 9 a 10)?"""
            , questionName = "questão 4"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "1 a 12", "1 a 12" ), ( "8 a 12", "8 a 12" ), ( "1 a 8", "1 a 8" ), ( "8 a 4", "8 a 4" ) ]
            , questionAnswers = [ "8 a 4", "8 as 4", "8-4" ]
            }
          )
        , ( ( 401, "en" )
          , { questionBody = """The sun clock tells the time from what hour of the day to what hour (ex: 9 to 10)?"""
            , questionName = "question 4"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "1 to 12", "1 to 12" ), ( "8 to 12", "8 to 12" ), ( "1 to 8", "1 to 8" ), ( "8 to 4", "8 to 4" ) ]
            , questionAnswers = [ "8 to 4" ]
            }
          )
        , ( ( 402, "pt" )
          , { questionBody = """Á tua direita quantos degraus podes observar ?"""
            , questionName = "questão 42"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "18", "Dezoito (18)" ), ( "19", "Dezanove (19)" ), ( "20", "Vinte (20)" ), ( "21", "Vinte e um (21)" ), ( "22", "Vinte e dois (22)" ), ( "23", "Vinte e três (23)" ) ]
            , questionAnswers = [ "21", "vinte e um" ]
            }
          )
        , ( ( 402, "en" )
          , { questionBody = """How many steps do you see to the right ?"""
            , questionName = "question 42"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "18", "Eighteen (18)" ), ( "19", "Nineteen (19)" ), ( "20", "Twenty (20)" ), ( "21", "Twenty One (21)" ), ( "22", "Twenty Two (22)" ), ( "23", "Twenty Three (23)" ) ]
            , questionAnswers = [ "twenty one" ]
            }
          )
        , ( ( 501, "pt" )
          , { questionBody = "Qual o nome da planta que se encontra indicado ?"
            , questionName = "questão 5"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "Camellia Japonica", "Camellia Japonica L.", "THEACEAE" ]
            }
          )
        , ( ( 501, "en" )
          , { questionBody = "What's the name of the plant ( written on the sign ) ?"
            , questionName = "question 5"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = []
            }
          )
        , ( ( 601, "pt" )
          , { questionBody = "Parece-te uma cadeira confortável ?"
            , questionName = "questão 6"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "sim", "não", "nao" ]
            }
          )
        , ( ( 601, "en" )
          , { questionBody = "Does it seem like a comfortable chair  ?"
            , questionName = "question 6"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "yes", "no" ]
            }
          )
        , ( ( 701, "pt" )
          , { questionBody = "Quantos troncos ( cortados ) podes observar junto ao rochedo ?"
            , questionName = "questão 7"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "2", "Dois (2)" ), ( "3", "Tres (3)" ), ( "4", "Quatro (4)" ), ( "5", "Cinco (5)" ) ]
            , questionAnswers = [ "2", "dois" ]
            }
          )
        , ( ( 701, "en" )
          , { questionBody = "how many ( chopped ) logs can you see near the big rock"
            , questionName = "question 7"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = [ ( "2", "Two (2)" ), ( "3", "Three (3)" ), ( "4", "Four (4)" ), ( "5", "Five (5)" ) ]
            , questionAnswers = [ "two" ]
            }
          )
        , ( ( 801, "pt" )
          , { questionBody = "Qual a distância indicada ( em metros ) para o Penedo da Amizade ?"
            , questionName = "questão 8"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "115", "cento e quinze" ]
            }
          )
        , ( ( 801, "en" )
          , { questionBody = "What's the distance ( in meters ) to Penedo da Amizade ( Cliff of Amizade ) shown on the sign  ?"
            , questionName = "question 8"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "hundred and fifteen" ]
            }
          )
        , ( ( 901, "pt" )
          , { questionBody = "No topoguia informativo sobre as vias de escalada no Penedo da Amizade qual o Nome da via Nº 7 ?"
            , questionName = "questão 9"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "Funk da Serra" ]
            }
          )
        , ( ( 901, "en" )
          , { questionBody = "What's the name of climbing route Nº 7 shown on  Penedo da Amizade Rock climbing guide  ?"
            , questionName = "question 9"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = []
            }
          )
        , ( ( 1001, "pt" )
          , { questionBody = "Logo após a porta de saída está um placard informativo. Qual a distância ( em metros ) para o Palácio da Pena ? "
            , questionName = "questão 10"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "495", "quatrocentos e noventa e cinco" ]
            }
          )
        , ( ( 1001, "en" )
          , { questionBody = "right after the door there's an informative sign. What's the distance ( in meters ) to Parque da Pena ( Park of Pena )  ?"
            , questionName = "question 10"
            , additionalTextIfCorrectAnswer = NoFeedbackText
            , additionalTextIfIncorrectAnswer = NoFeedbackText
            , availableChoices = []
            , questionAnswers = [ "four hundred and ninety five" ]
            }
          )
        ]


questionsMaxNrTries : Dict Int (Maybe Int)
questionsMaxNrTries =
    Dict.fromList
        [ ( 101, Just 5 )
        , ( 201, Nothing )
        , ( 301, Just 2 )
        , ( 401, Just 5 )
        , ( 402, Just 5 )
        , ( 501, Just 5 )
        , ( 601, Just 5 )
        , ( 701, Just 5 )
        , ( 801, Just 5 )
        , ( 901, Just 5 )
        , ( 1001, Just 5 )
        ]


theMultiOptionParams : Dict Int { displayOptionButtons : Bool, resetPossible : Bool }
theMultiOptionParams =
    Dict.fromList
        [ ( 101
          , { displayOptionButtons = True
            , resetPossible = True
            }
          )
        , ( 201
          , { displayOptionButtons = True
            , resetPossible = False
            }
          )
        , ( 301
          , { displayOptionButtons = True
            , resetPossible = False
            }
          )
        , ( 401
          , { displayOptionButtons = True
            , resetPossible = False
            }
          )
        , ( 601
          , { displayOptionButtons = True
            , resetPossible = False
            }
          )
        ]


theMultiOptionsDict : Dict ( Int, LanguageId ) MultiOption
theMultiOptionsDict =
    Dict.fromList
        [ ( ( 101, "pt" )
          , { optionBody = "o percurso de Vila Sassetti parece-te interessante ? "
            , optionName = "opcao1"
            , availableChoices =
                [ ( "yes", "Sim", SimpleText [ "boa escolha , o percurso de Vila Sassetti é muito interessante" ] )
                , ( "no", "Não", NoFeedbackText )
                , ( "maybe", "talvez", NoFeedbackText )
                ]
            }
          )
        , ( ( 101, "en" )
          , { optionBody = "Does the footpath seem interesting ? "
            , optionName = "option1"
            , availableChoices =
                [ ( "yes", "yes", NoFeedbackText )
                , ( "no", "no", NoFeedbackText )
                , ( "maybe", "maybe", NoFeedbackText )
                ]
            }
          )
        , ( ( 201, "pt" )
          , { optionBody = "a cadeira parece-te um pouco esquisita ?"
            , optionName = "opcao21"
            , availableChoices =
                [ ( "yes", "Sim", NoFeedbackText )
                , ( "no", "Não", NoFeedbackText )
                , ( "maybe", "talvez", NoFeedbackText )
                ]
            }
          )
        , ( ( 201, "en" )
          , { optionBody = "Do you find the seat a bit odd ?"
            , optionName = "option21"
            , availableChoices =
                [ ( "yes", "yes", NoFeedbackText )
                , ( "no", "no", NoFeedbackText )
                , ( "maybe", "maybe", NoFeedbackText )
                ]
            }
          )
        , ( ( 301, "pt" )
          , { optionBody = "estás a gostar do percurso ?"
            , optionName = "opcao31"
            , availableChoices =
                [ ( "yes", "Sim", NoFeedbackText )
                , ( "no", "Não", NoFeedbackText )
                , ( "maybe", "talvez", NoFeedbackText )
                ]
            }
          )
        , ( ( 301, "en" )
          , { optionBody = "Are you enjoying the trail ?"
            , optionName = "option31"
            , availableChoices =
                [ ( "yes", "yes", NoFeedbackText )
                , ( "no", "no", NoFeedbackText )
                , ( "maybe", "maybe", NoFeedbackText )
                ]
            }
          )
        , ( ( 401, "pt" )
          , { optionBody = "qual a tua opinião sobre o relógio"
            , optionName = "opcao41"
            , availableChoices =
                [ ( "fenomenal", "fenomenal", NoFeedbackText )
                , ( "engraçado", "engraçado", NoFeedbackText )
                , ( "esquisito", "esquisito", NoFeedbackText )
                ]
            }
          )
        , ( ( 401, "en" )
          , { optionBody = "What do you think about the clock ? "
            , optionName = "option41"
            , availableChoices =
                [ ( "phenomenal", "phenomenal", NoFeedbackText )
                , ( "nice", "nice", NoFeedbackText )
                , ( "weird", "weird", NoFeedbackText )
                ]
            }
          )
        , ( ( 601, "pt" )
          , { optionBody = "O que pensas da cadeira ?"
            , optionName = "opcao61"
            , availableChoices =
                [ ( "muito util", "muito útil", NoFeedbackText )
                , ( "artistica", "artística", NoFeedbackText )
                , ( "esquisita", "esquisita", NoFeedbackText )
                ]
            }
          )
        , ( ( 601, "en" )
          , { optionBody = "What do you think of the chair ?"
            , optionName = "option61"
            , availableChoices =
                [ ( "very useful", "very useful", NoFeedbackText )
                , ( "artistic", "artistic", NoFeedbackText )
                , ( "weird", "weird", NoFeedbackText )
                ]
            }
          )
        ]
