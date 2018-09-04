module GpsUtils exposing
    ( Direction(..)
    , GeolocationInfo
    , GpsZone
    , addLeftZeros
    , addRightZeros
    , bearingToDirection
    , calculateBearing
    , calculateBearingsFromList
    , checkIfInDistance
    , convertDecimalToGps
    , convertDecimalTupleToGps
    , directionToString
    , getCurrentGeoLocationAsText
    , getCurrentGeoReportAsText
    , getDistance
    , getDistanceTo
    , getDistancesTo
    , getDistancesToAsText
    , getMbGpsZoneLatLon
    , getTextDistancesFromListDistances
    , haversineInMeters
    , roundit
    )

--import Geolocation

import Dict exposing (Dict)
import Types as EngineTypes


type alias GeolocationInfo =
    --Geolocation.Location
    { latitude : Float
    , longitude : Float
    }


type alias GpsZone =
    { needsToBeIn : Bool
    , lat : Float
    , lon : Float
    , mbRadius : Maybe Float
    }


type Direction
    = North
    | NorthEast
    | NorthWest
    | South
    | SouthEast
    | SouthWest
    | East
    | West


getDistance : GeolocationInfo -> Maybe GpsZone -> Float
getDistance location mbGpsZone =
    case mbGpsZone of
        Nothing ->
            0.0

        Just gpszone ->
            case gpszone.needsToBeIn of
                True ->
                    haversineInMeters ( location.latitude, location.longitude ) ( gpszone.lat, gpszone.lon )

                False ->
                    0.0


getDistanceTo : GeolocationInfo -> ( String, Float, Float ) -> ( String, Float )
getDistanceTo location ( name, lat, lon ) =
    let
        theDistance =
            haversineInMeters ( location.latitude, location.longitude ) ( lat, lon )
    in
    ( name, theDistance )


getDistancesTo : Int -> GeolocationInfo -> List (Maybe ( String, Float, Float )) -> List ( String, Float )
getDistancesTo nrdistances location lmbnamecoordTuples =
    lmbnamecoordTuples
        |> List.map (Maybe.map (\x -> getDistanceTo location x))
        |> List.map (Maybe.withDefault ( "", -999999 ))
        |> List.filter (\( n, x ) -> x >= 0)
        |> List.sortBy (\x -> Tuple.second x)


getTextDistancesFromListDistances : Int -> List ( String, Float ) -> String
getTextDistancesFromListDistances nrdistances ldistances =
    ldistances
        |> List.map (\( name, distance ) -> " ___DISTANCE_TO___ " ++ name ++ " ___IS___ " ++ String.fromInt (round distance) ++ " ___METERS___ ")
        |> List.take nrdistances
        |> String.join "  \n"


getDistancesToAsText : Int -> GeolocationInfo -> List (Maybe ( String, Float, Float )) -> String
getDistancesToAsText nrdistances location lmbnamecoordTuples =
    getDistancesTo nrdistances location lmbnamecoordTuples
        |> getTextDistancesFromListDistances nrdistances


getCurrentGeoLocationAsText : Maybe GeolocationInfo -> String
getCurrentGeoLocationAsText mbGeolocationInfo =
    case mbGeolocationInfo of
        Nothing ->
            "\ngps info : not available ! "

        Just gInfo ->
            --"\nlatitude : " ++ toString gInfo.latitude ++ "\nlongitude : " ++ toString gInfo.longitude
            convertDecimalTupleToGps ( gInfo.latitude, gInfo.longitude )


getCurrentGeoReportAsText : Dict String ( String, Float, Float ) -> Maybe GeolocationInfo -> List ( String, Float ) -> Int -> String
getCurrentGeoReportAsText currLocNameAndCoords mbGeolocationInfo lnameDistances nrdistances =
    "  \n"
        ++ getCurrentGeoLocationAsText mbGeolocationInfo
        ++ "  \n"
        ++ getTextDistancesFromListDistances nrdistances lnameDistances
        ++ "  \n"
        ++ " ___center_coords_of_current_location___ "
        ++ "  \n"
        ++ (Dict.get "en" currLocNameAndCoords
                |> Maybe.map (\( name, lat, lon ) -> convertDecimalTupleToGps ( lat, lon ))
                |> Maybe.withDefault ""
           )


checkIfInDistance : Maybe GpsZone -> Float -> Float -> Bool
checkIfInDistance mbGpsZone theDistance defaultDistance =
    case mbGpsZone of
        Nothing ->
            True

        Just gpszone ->
            case gpszone.mbRadius of
                Just radius ->
                    if theDistance <= radius then
                        True

                    else
                        False

                Nothing ->
                    if theDistance <= defaultDistance then
                        True

                    else
                        False


getMbGpsZoneLatLon : Maybe GpsZone -> Maybe ( Float, Float )
getMbGpsZoneLatLon mbGpsZone =
    case mbGpsZone of
        Just gpszone ->
            Just ( gpszone.lat, gpszone.lon )

        Nothing ->
            Nothing


haversineInMeters : ( Float, Float ) -> ( Float, Float ) -> Float
haversineInMeters ( lat1, lon1 ) ( lat2, lon2 ) =
    let
        r =
            6372.8

        dLat =
            degrees (lat2 - lat1)

        dLon =
            degrees (lon2 - lon1)

        a =
            sin (dLat / 2)
                ^ 2
                + sin (dLon / 2)
                ^ 2
                * cos (degrees lat1)
                * cos (degrees lat2)
    in
    r * 2 * asin (sqrt a) * 1000


addLeftZeros : Int -> String -> String
addLeftZeros desiredlength theStr =
    if String.length theStr < desiredlength then
        "0"
            ++ theStr
            |> addLeftZeros desiredlength

    else
        theStr


addRightZeros : Int -> String -> String
addRightZeros desiredlength theStr =
    if String.length theStr < desiredlength then
        theStr
            ++ "0"
            |> addRightZeros desiredlength

    else
        theStr


roundit : Int -> Float -> String
roundit nrplaces nr =
    let
        intVal =
            floor nr

        strdecPlaces =
            (nr - toFloat intVal)
                * toFloat (10 ^ nrplaces)
                |> round
                |> toFloat
                |> String.fromFloat
                |> addRightZeros 3

        strintVal =
            String.fromInt intVal
    in
    strintVal ++ "." ++ strdecPlaces


convertDecimalToGps : String -> Float -> String
convertDecimalToGps theStr theVal =
    let
        charDir =
            if theStr == "latitude" && theVal >= 0 then
                "N"

            else if theStr == "longitude" && theVal >= 0 then
                "E"

            else if theStr == "latitude" && theVal < 0 then
                "S"

            else if theStr == "longitude" && theVal < 0 then
                "W"

            else
                "bad coordinate type"

        newVal =
            abs theVal

        deg =
            floor newVal

        minutes =
            (newVal - toFloat deg) * 60

        strDeg =
            if theStr == "longitude" then
                addLeftZeros 3 (String.fromInt deg)

            else
                String.fromInt deg

        fstr =
            charDir ++ " " ++ strDeg ++ "º " ++ roundit 3 minutes
    in
    fstr


convertDecimalTupleToGps : ( Float, Float ) -> String
convertDecimalTupleToGps ( decLat, decLon ) =
    let
        lat =
            convertDecimalToGps "latitude" decLat

        lon =
            convertDecimalToGps "longitude" decLon

        fstr =
            lat ++ " , " ++ lon
    in
    fstr


calculateBearing : ( Float, Float ) -> ( Float, Float ) -> Int
calculateBearing ( lat1, lon1 ) ( lat2, lon2 ) =
    let
        toDegrees rad =
            rad * 180 / pi

        longitude1 =
            lon1

        longitude2 =
            lon2

        latitude1 =
            degrees lat1

        latitude2 =
            degrees lat2

        longDiff =
            (longitude2 - longitude1)
                |> degrees

        y =
            sin longDiff * cos latitude2

        x =
            cos latitude1 * sin latitude2 - sin latitude1 * cos latitude2 * cos longDiff
    in
    atan2 y x
        |> toDegrees
        |> (+) 360
        |> round
        |> (\v -> remainderBy 360 v)


calculateBearingsFromList : List ( Float, Float ) -> List Int
calculateBearingsFromList lcoords =
    let
        l2 =
            List.drop 1 lcoords

        l1 =
            List.take (List.length lcoords - 1) lcoords

        lzips =
            List.map2 Tuple.pair l1 l2

        calcBearingsHelper : List ( ( Float, Float ), ( Float, Float ) ) -> List Int
        calcBearingsHelper lc =
            case lc of
                [] ->
                    []

                ( ( lat1, lon1 ), ( lat2, lon2 ) ) :: rest ->
                    calculateBearing ( lat1, lon1 ) ( lat2, lon2 ) :: calcBearingsHelper rest
    in
    calcBearingsHelper lzips


bearingToDirection : Float -> Direction
bearingToDirection angle =
    if angle >= 22.5 && angle < 67.5 then
        NorthEast

    else if angle >= 67.5 && angle < 112.5 then
        East

    else if angle >= 112.5 && angle < 157.5 then
        SouthEast

    else if angle >= 157.5 && angle < 202.5 then
        South

    else if angle >= 202.5 && angle < 247.5 then
        SouthWest

    else if angle >= 247.5 && angle < 292.5 then
        West

    else if angle >= 292.5 && angle < 337.5 then
        NorthWest

    else
        North


directionToString : Direction -> String
directionToString direction =
    case direction of
        North ->
            "North"

        NorthEast ->
            "NorthEast"

        NorthWest ->
            "NorthWest"

        South ->
            "South"

        SouthEast ->
            "SouthEast"

        SouthWest ->
            "SouthWest"

        East ->
            "East"

        West ->
            "West"
