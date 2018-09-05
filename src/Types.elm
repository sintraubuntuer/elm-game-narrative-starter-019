module Types exposing
    ( AnswerCase(..)
    , AnswerFeedback(..)
    , AnswerInfo
    , AnswerSpaces(..)
    , AnswerStatus(..)
    , AttrTypes(..)
    , BackendAnswerStatus(..)
    , ChangeWorldCommand(..)
    , CharacterData
    , CharacterPlacement(..)
    , CheckAnswerData
    , CheckBkendAnswerData
    , CheckOptionData
    , Condition(..)
    , EndingType(..)
    , ExtraInfoWithPendingChanges
    , Fixed
    , ID
    , Interactable(..)
    , InteractionExtraInfo
    , InteractionMatcher(..)
    , IsWritable
    , ItemData
    , ItemPlacement(..)
    , LocationData
    , Manifest
    , MoreInfoNeeded(..)
    , QuasiChangeWorldCommand(..)
    , QuasiChangeWorldCommandWithBackendInfo(..)
    , Rule
    , Rule_
    , Rules
    , Shown
    , Story
    , The_End(..)
    , WrittenContent
    )

import Dict exposing (Dict)



--import Geolocation
-- Model


type alias Story =
    { currentLocation : ID
    , currentScene : ID
    , history : List ( ID, InteractionExtraInfo )
    , manifest : Manifest
    , playerId : String
    , rules : Rules
    , choiceLanguages : Dict String String -- key : LanguageId , val : language as string
    , lprandomfloats : List Float
    , theEnd : Maybe The_End
    }


type alias ID =
    String


type The_End
    = TheEnd EndingType String


type EndingType
    = FreezingEnd
    | NotFreezingEnd



-- Manifest


type alias Manifest =
    Dict ID Interactable


type alias Shown =
    Bool


type CharacterPlacement
    = CharacterInLocation ID
    | CharacterOffScreen


type ItemPlacement
    = ItemInLocation ID
    | ItemInCharacterInventory ID
    | ItemOffScreen


type AnswerStatus
    = NotAnswerable
    | NotAnswered
    | CorrectlyAnswered
    | IncorrectlyAnswered


type AttrTypes
    = Astring String
    | AListString (List String)
    | AListStringString (List ( String, String ))
    | ADictStringString (Dict String String)
    | ADictStringListString (Dict String (List String))
    | ADictStringLSS (Dict String (List ( String, String )))
    | AnInt Int
    | Abool Bool


type alias ItemData =
    { interactableId : String
    , fixed : Bool
    , itemPlacement : ItemPlacement
    , isWritable : Bool
    , writtenContent : Maybe String
    , attributes : Dict String AttrTypes
    , interactionErrors : List String
    , interactionWarnings : List String
    }


type alias CharacterData =
    { interactableId : String
    , characterPlacement : CharacterPlacement
    , attributes : Dict String AttrTypes
    , interactionErrors : List String
    , interactionWarnings : List String
    }


type alias LocationData =
    { interactableId : String
    , shown : Bool
    , attributes : Dict String AttrTypes
    , interactionErrors : List String
    , interactionWarnings : List String
    }


type alias Fixed =
    Bool


type alias IsWritable =
    Bool


type alias WrittenContent =
    Maybe String


type Interactable
    = Item ItemData
    | Location LocationData
    | Character CharacterData


type MoreInfoNeeded
    = NoInfoNeeded
    | AnswerInfoToQuestionNeeded String


type BackendAnswerStatus
    = NoInfoYet
    | WaitingForInfoRequested
    | Ans AnswerInfo
    | CommunicationFailure


type alias AnswerInfo =
    { maxTriesReached : Bool
    , interactableId : String
    , questionBody : String
    , playerAnswer : String
    , answered : Bool
    , correctAnswer : Bool
    , incorrectAnswer : Bool
    , secretTextList : List { lgId : String, text : String }
    , successTextList : List { lgId : String, text : String }
    , insuccessTextList : List { lgId : String, text : String }
    }


type alias InteractionExtraInfo =
    { mbInputText : Maybe String
    , mbInputTextForBackend : Maybe String
    , geolocationInfoText : String
    , currentLocation : String
    , bkAnsStatus : BackendAnswerStatus
    , mbMatchedRuleId : Maybe String
    }


type alias ExtraInfoWithPendingChanges =
    { interactionExtraInfo : InteractionExtraInfo
    , pendingChanges : List ChangeWorldCommand
    , mbQuasiCwCmdWithBk : Maybe QuasiChangeWorldCommandWithBackendInfo
    }


type alias Rules =
    Dict ID Rule


type alias Rule_ =
    { interaction : InteractionMatcher
    , conditions : List Condition
    , changes : List ChangeWorldCommand
    }


type alias Rule =
    { interaction : InteractionMatcher
    , conditions : List Condition
    , changes : List ChangeWorldCommand
    , quasiChanges : List QuasiChangeWorldCommand
    , quasiChangeWithBkend : QuasiChangeWorldCommandWithBackendInfo
    }


type InteractionMatcher
    = WithAnything
    | WithAnyItem
    | WithAnyLocation
    | WithAnyCharacter
    | WithAnyLocationAnyCharacterAfterGameEnded
    | WithAnythingAfterGameEnded
    | WithAnythingHighPriority
    | With ID


type Condition
    = ItemIsInCharacterInventory ID ID -- characterId ItemId
    | CharacterIsInLocation ID ID
    | CharacterIsNotInLocation ID ID
    | CurrentLocationIs ID
    | CurrentLocationIsNot ID
    | ItemIsInLocation ID ID
    | ItemIsNotInCharacterInventory ID ID -- characterId ItemId
    | ItemIsNotInLocation ID ID
    | ItemIsOffScreen ID
    | ItemIsInAnyLocationOrCharacterInventory ID ID -- characterId ItemId
    | ItemIsInAnyLocationOrAnyCharacterInventory ID -- ItemId
    | ItemIsCorrectlyAnswered ID
    | ItemIsNotCorrectlyAnswered ID
    | HasPreviouslyInteractedWith ID
    | HasNotPreviouslyInteractedWith ID
    | CurrentSceneIs ID
    | CounterExists String ID --nameIDofCounter InteractableID
    | CounterLessThen Int String ID
    | CounterGreaterThenOrEqualTo Int String ID
    | AttrValueIsEqualTo AttrTypes ID ID
    | ChosenOptionIsEqualTo String ID
    | NoChosenOptionYet ID
    | ChoiceHasAlreadyBeenMade ID


type ChangeWorldCommand
    = NoChange
    | MoveTo ID
    | AddLocation ID
    | RemoveLocation ID
    | RemoveChooseOptions ID
    | MoveItemToLocationFixed ID ID
    | MoveItemToLocation ID ID
    | MoveItemToCharacterInventory ID ID -- characterId itemId
    | MakeItemWritable ID
    | MakeItemUnwritable ID
    | MakeItUnanswerable ID
    | WriteTextToItem String ID
    | WriteForceTextToItemFromGivenItemAttr String ID ID -- nameOfAttributeId GivenInteractableId InteractableId
    | WriteGpsLocInfoToItem String ID
    | ClearWrittenText ID
    | CheckIfAnswerCorrect (List String) String CheckAnswerData ID
    | CreateCounterIfNotExists String ID --nameIdOfCounter InteractableID
    | CreateAttributeIfNotExists AttrTypes String (Maybe String) ID -- value nameOfAttributeId  InteractableID
    | SetAttributeValue AttrTypes String (Maybe String) ID
    | CreateAttributeIfNotExistsAndOrSetValue AttrTypes String (Maybe String) ID
    | CreateOrSetAttributeValueFromOtherInterAttr String String ID ID -- nameOfAttributeId otherInteractableAttributeId otherInteractableId InteractableID
    | CreateAMultiChoice (Dict String (List ( String, String ))) ID
    | RemoveMultiChoiceOptions ID
    | RemoveAttributeIfExists String ID
    | IncreaseCounter String ID
    | MoveItemOffScreen ID
    | MoveCharacterToLocation ID ID
    | MoveCharacterOffScreen ID
    | LoadScene String
    | SetChoiceLanguages (Dict String String)
    | AddChoiceLanguage String String -- lgId lgName
    | EndStory EndingType String
    | CheckAndActIfChosenOptionIs String CheckOptionData ID
    | ProcessChosenOptionEqualTo CheckOptionData ID
    | ExecuteCustomFunc (InteractionExtraInfo -> Manifest -> List ChangeWorldCommand) InteractionExtraInfo ID
    | ExecuteCustomFuncUsingRandomElems (InteractionExtraInfo -> List Float -> Manifest -> List ChangeWorldCommand) InteractionExtraInfo (List Float) ID



-- QuasiChangeWorldCommand have an underscore _ .  quasi cwcommmands  come from the config rules
-- and are the  ones that wont reach Engine.Manifest because they
-- will get replaced by ChangeWorldCommands -> the version with no underscore in Engine.update


type QuasiChangeWorldCommand
    = NoQuasiChange
    | Check_IfAnswerCorrect (List String) CheckAnswerData ID
    | CheckAndAct_IfChosenOptionIs CheckOptionData ID
    | Write_GpsInfoToItem ID
    | Write_InputTextToItem ID
    | Execute_CustomFunc (InteractionExtraInfo -> Manifest -> List ChangeWorldCommand) ID
    | Execute_CustomFuncUsingRandomElems Int (InteractionExtraInfo -> List Float -> Manifest -> List ChangeWorldCommand) ID


type QuasiChangeWorldCommandWithBackendInfo
    = NoQuasiChangeWithBackend
    | Check_IfAnswerCorrectUsingBackend String CheckBkendAnswerData ID


type alias CheckOptionData =
    { valueToMatch : String
    , successTextDict : Dict String (List String)
    , lnewAttrs : List ( String, AttrTypes )
    , lotherInterAttrs : List ( String, String, AttrTypes )
    }


type alias CheckAnswerData =
    { mbMaxNrTries : Maybe Int
    , answerCase : AnswerCase
    , answerSpaces : AnswerSpaces
    , answerFeedback : AnswerFeedback
    , correctAnsTextDict : Dict String (List String)
    , incorrectAnsTextDict : Dict String (List String)
    , lnewAttrs : List ( String, AttrTypes )
    , lotherInterAttrs : List ( String, String, AttrTypes )
    }


type alias CheckBkendAnswerData =
    { mbMaxNrTries : Maybe Int
    , answerFeedback : AnswerFeedback
    , lnewAttrs : List ( String, AttrTypes )
    , lotherInterAttrs : List ( String, String, AttrTypes )
    }


type AnswerFeedback
    = NoFeedback
    | JustHeader
    | JustPlayerAnswer
    | HeaderAndAnswer
    | HeaderAnswerAndCorrectIncorrect


type AnswerCase
    = CaseSensitiveAnswer
    | CaseInsensitiveAnswer


type AnswerSpaces
    = AnswerSpacesMatter
    | AnswerSpacesDontMatter
