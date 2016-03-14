module View where

import Circle exposing (Circle)
import Graphics.Element exposing (flow, right, show)
import Json.Decode as Json
import Model exposing (Model, Action)
import Html exposing (Html, text, div)
import Html.Attributes
import Html.Events exposing (on)
import Signal exposing (Address)
import SoundAnimation exposing (SoundAnimation)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (..)


view : Address Action -> Model -> Html
view address model =
  div [class "main"]
    [ viewCircles address model
    , viewBottomBar address model
    ]


viewCircles : Address Action -> Model -> Html
viewCircles address model =
  let
    svgBackground =
      rect
        [ class "circles-background"
        , x "0px"
        , y "0px"
        , width "100%"
        , height "100%"
        , on "click" getClickPos (Signal.message address << Model.AddCircle)
        ]
        []
    svgElements =
      List.concat
        [ [svgBackground]
        , List.map (viewCircle address) model.circles
        , List.map viewSound model.soundAnimations
        ]
  in
    Svg.svg [class "circles-svg"] svgElements


viewBottomBar : Address Action -> Model -> Html
viewBottomBar address model =
  let
    circleTypeSelectors =
      List.map (viewCircleType address model.circleType) Circle.circleTypes
    selectors =
      div [ class "selectors" ] circleTypeSelectors
  in
    div [ class "bottombar" ] [selectors]


viewCircleType : Address Action -> Circle.Type -> Circle.Type -> Html
viewCircleType address selectedType circleType =
  let
    selectedClass = if selectedType == circleType then " selected" else ""
    selectorClass = "selector-" ++ (Circle.typeString circleType)
  in
    div
      [ class (selectorClass ++ selectedClass)
      , onClick (Signal.message (Signal.forwardTo address Model.SelectCircleType) circleType)
      ]
      []


viewCircle : Address Action -> Circle -> Svg
viewCircle address circle =
  Svg.circle
    [ class circle.class.circle
    , cx (toString circle.x)
    , cy (toString circle.y)
    , r (toString circle.radius)
    , onClick (Signal.message (Signal.forwardTo address Model.RemoveCircle) circle.id)
    ]
    []


viewSound : SoundAnimation -> Svg
viewSound sound =
  Svg.circle
    [ class sound.class
    , opacity (toString sound.alpha)
    , cx (toString sound.x)
    , cy (toString sound.y)
    , r (toString sound.radius)
    ]
    []


getClickPos : Json.Decoder (Int,Int)
getClickPos =
  Json.object2 (,)
    (Json.at ["offsetX"] Json.int)
    (Json.at ["offsetY"] Json.int)
