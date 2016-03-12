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
  let
    (w, h) = (toString model.dimensions.x, toString model.dimensions.y)
    background =
      rect
        [ class "background"
        , x "0"
        , y "0"
        , width w
        , height h
        , on "click" getClickPos (Signal.message address << Model.AddCircle)
        ] []
    svgElements =
      List.concat
        [ [background]
        , List.map (viewCircle address) model.circles
        , List.map viewSound model.soundAnimations
        ]
    circlesSvg =
      svg [ width w, height h, viewBox ("0 0 " ++ w ++ " " ++ h) ] svgElements
    circleTypeSelectors =
      List.map (viewCircleType address model.circleType) Circle.circleTypes
    sidebar =
      div [ class "sidebar" ] circleTypeSelectors
  in
    div []
      [ sidebar
      , div [class "circlesSvg"] [circlesSvg]
      ]


viewCircleType : Address Action -> Circle.Type -> Circle.Type -> Svg
viewCircleType address selectedType circleType =
  let
    selectedClass = if selectedType == circleType then " selected" else ""
  in
    svg [ class "circleType", width "100", height "100" ]
      [
      Svg.circle
        [ class ((Circle.classForType circleType) ++ selectedClass)
        , cx "50"
        , cy "50"
        , r "45"
        , onClick (Signal.message (Signal.forwardTo address Model.SelectCircleType) circleType)
        ]
        []
      ]


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
    (Json.object2 (-)
      (Json.at ["pageX"] Json.int)
      (Json.at ["target", "offsetLeft"] Json.int)
    )
    (Json.object2 (-)
      (Json.at ["pageY"] Json.int)
      (Json.at ["target", "offsetTop"] Json.int)
    )
