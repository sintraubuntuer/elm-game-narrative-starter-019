module TypeConverterHelper exposing
    ( mbAttributeToBool
    , mbAttributeToDictStringListString
    , mbAttributeToDictStringListStringString
    , mbAttributeToDictStringString
    , mbAttributeToListString
    , mbAttributeToListStringString
    , mbAttributeToMbBool
    , mbAttributeToMbDictStringListString
    , mbAttributeToMbDictStringListStringString
    , mbAttributeToMbDictStringString
    , mbAttributeToMbListString
    , mbAttributeToMbListStringString
    , mbAttributeToMbString
    , mbAttributeToString
    )

import Dict exposing (Dict)
import Types exposing (AttrTypes(..))



{- }
   sendToDebug : Bool -> String -> a -> a
   sendToDebug doDebug valStr returnVal =
       case doDebug of
           True ->
               let
                   _ =
                       Debug.log valStr returnVal
               in
               returnVal

           False ->
               returnVal
-}


addConversionFailureMessage : Bool -> String -> a -> ( a, String )
addConversionFailureMessage doDebug valStr returnVal =
    case doDebug of
        True ->
            ( returnVal, valStr )

        False ->
            ( returnVal, "" )


mbAttributeToMbBool : Bool -> Maybe AttrTypes -> ( Maybe Bool, String )
mbAttributeToMbBool doDebug mbAttrVal =
    case mbAttrVal of
        Nothing ->
            ( Nothing, "" )

        Just (Abool b) ->
            ( Just b, "" )

        _ ->
            Nothing
                |> addConversionFailureMessage doDebug "Trying to convert an attribute which is not of type Astring to a string"


mbAttributeToBool : Bool -> Maybe AttrTypes -> ( Bool, String )
mbAttributeToBool doDebug mbAttrVal =
    mbAttributeToMbBool doDebug mbAttrVal
        |> (\( x, y ) -> ( Maybe.withDefault False x, y ))


mbAttributeToMbString : Bool -> Maybe AttrTypes -> ( Maybe String, String )
mbAttributeToMbString doDebug mbAttrVal =
    case mbAttrVal of
        Nothing ->
            ( Nothing, "" )

        Just (Astring theStr) ->
            ( Just theStr, "" )

        _ ->
            Nothing
                |> addConversionFailureMessage doDebug "Trying to convert an attribute which is not of type Astring to a string"


mbAttributeToString : Bool -> Maybe AttrTypes -> ( String, String )
mbAttributeToString doDebug mbAttrVal =
    mbAttributeToMbString doDebug mbAttrVal
        |> (\( x, y ) -> ( Maybe.withDefault "" x, y ))


mbAttributeToMbListString : Bool -> Maybe AttrTypes -> ( Maybe (List String), String )
mbAttributeToMbListString doDebug mbAttrVal =
    case mbAttrVal of
        Nothing ->
            ( Nothing, "" )

        Just (AListString lstrs) ->
            ( Just lstrs, "" )

        _ ->
            Nothing
                |> addConversionFailureMessage doDebug "Trying to convert an attribute which is not of type AListString to a List of strings"


mbAttributeToListString : Bool -> Maybe AttrTypes -> ( List String, String )
mbAttributeToListString doDebug mbAttrVal =
    mbAttributeToMbListString doDebug mbAttrVal
        |> (\( x, y ) -> ( Maybe.withDefault [] x, y ))


mbAttributeToMbListStringString : Bool -> Maybe AttrTypes -> ( Maybe (List ( String, String )), String )
mbAttributeToMbListStringString doDebug mbAttrVal =
    case mbAttrVal of
        Nothing ->
            ( Nothing, "" )

        Just (AListStringString lstrstrs) ->
            ( Just lstrstrs, "" )

        _ ->
            Nothing
                |> addConversionFailureMessage doDebug "Trying to convert an attribute which is not of type AListStringString to a List of tuples (string , string )"


mbAttributeToListStringString : Bool -> Maybe AttrTypes -> ( List ( String, String ), String )
mbAttributeToListStringString doDebug mbAttrVal =
    mbAttributeToMbListStringString doDebug mbAttrVal
        |> (\( x, y ) -> ( Maybe.withDefault [] x, y ))


mbAttributeToMbDictStringString : Bool -> Maybe AttrTypes -> ( Maybe (Dict String String), String )
mbAttributeToMbDictStringString doDebug mbAttrVal =
    case mbAttrVal of
        Nothing ->
            ( Nothing, "" )

        Just (ADictStringString dstrstr) ->
            ( Just dstrstr, "" )

        _ ->
            Nothing
                |> addConversionFailureMessage doDebug "Trying to convert an attribute which is not of type ADictStringString to a Dict String String"


mbAttributeToDictStringString : Bool -> Maybe AttrTypes -> ( Dict String String, String )
mbAttributeToDictStringString doDebug mbAttrVal =
    mbAttributeToMbDictStringString doDebug mbAttrVal
        |> (\( x, y ) -> ( Maybe.withDefault Dict.empty x, y ))


mbAttributeToMbDictStringListString : Bool -> Maybe AttrTypes -> ( Maybe (Dict String (List String)), String )
mbAttributeToMbDictStringListString doDebug mbAttrVal =
    case mbAttrVal of
        Nothing ->
            ( Nothing, "" )

        Just (ADictStringListString dstrlstr) ->
            ( Just dstrlstr, "" )

        _ ->
            Nothing
                |> addConversionFailureMessage doDebug "Trying to convert an attribute which is not of type ADictStringListString to a Dict String (List String)"


mbAttributeToDictStringListString : Bool -> Maybe AttrTypes -> ( Dict String (List String), String )
mbAttributeToDictStringListString doDebug mbAttrVal =
    mbAttributeToMbDictStringListString doDebug mbAttrVal
        |> (\( x, y ) -> ( Maybe.withDefault Dict.empty x, y ))


mbAttributeToMbDictStringListStringString : Bool -> Maybe AttrTypes -> ( Maybe (Dict String (List ( String, String ))), String )
mbAttributeToMbDictStringListStringString doDebug mbAttrVal =
    case mbAttrVal of
        Nothing ->
            ( Nothing, "" )

        Just (ADictStringLSS ds) ->
            ( Just ds, "" )

        _ ->
            Nothing
                |> addConversionFailureMessage doDebug "Trying to convert an attribute which is not of type ADictStringLSS to a Dict String (List (String , String )) "


mbAttributeToDictStringListStringString : Bool -> Maybe AttrTypes -> ( Dict String (List ( String, String )), String )
mbAttributeToDictStringListStringString doDebug mbAttrVal =
    mbAttributeToMbDictStringListStringString doDebug mbAttrVal
        |> (\( x, y ) -> ( Maybe.withDefault Dict.empty x, y ))
