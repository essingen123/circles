module View where

import Circle exposing (Circle)
import Json.Decode as Json
import Model exposing (Model, Action)
import Html exposing (Html, text)
import Html.Attributes
import Html.Events exposing (on)
import Signal exposing (Address)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (..)

view : Address Action -> Model -> Html
view address model =
  let
    (w, h) = (toString model.dimensions.x, toString model.dimensions.y)
  in
    svg
      [ width w, height h, viewBox ("0 0 " ++ w ++ " " ++ h) ]
      ( rect
          [ fill "#333333"
          , x "0"
          , y "0"
          , width w
          , height h
          , on "click" getClickPos (Signal.message address << Model.AddCircle)
          ] []
        :: List.map (viewCircle address) model.circles
      )


viewCircle : Address Action -> Circle -> Svg
viewCircle address circle =
    Svg.circle
      [ fill "#0ef311"
      , opacity "0.5"
      , stroke "#ffffff"
      , strokeWidth "1.5"
      , cx (toString circle.x)
      , cy (toString circle.y)
      , r (toString circle.radius)
      , onClick (Signal.message (Signal.forwardTo address Model.RemoveCircle) circle.id)
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
