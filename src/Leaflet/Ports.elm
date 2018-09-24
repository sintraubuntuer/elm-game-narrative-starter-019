port module Leaflet.Ports exposing (filterMarkersCmdPort, setView)

import Leaflet.Types exposing (LatLng, ZoomPanOptions)


port setView : ( LatLng, Int, ZoomPanOptions ) -> Cmd msg


port filterMarkersCmdPort : { stageMarkerInfo : List { stageName : String, coords : LatLng, marker_type : String }, playerCoords : LatLng } -> Cmd msg
