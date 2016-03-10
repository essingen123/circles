module View where

import Circle exposing (Circle)
import Json.Decode as Json
import Model exposing (Model, Action)
import Html exposing (Html, text)
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
  in
    svg
      [ width w, height h, viewBox ("0 0 " ++ w ++ " " ++ h) ]
      ( rect
          [ fill "#2A4F6E"
          , x "0"
          , y "0"
          , width w
          , height h
          , on "click" getClickPos (Signal.message address << Model.AddCircle)
          ] []
        :: List.concat
        [ List.map (viewCircle address) model.circles
        , List.map viewSound model.soundAnimations
        ]
      )


viewCircle : Address Action -> Circle -> Svg
viewCircle address circle =
  Svg.circle
    [ fill "#A1BFD8"
    , opacity "0.5"
    , stroke "#567B99"
    , strokeWidth "1.0"
    , cx (toString circle.x)
    , cy (toString circle.y)
    , r (toString circle.radius)
    , onClick (Signal.message (Signal.forwardTo address Model.RemoveCircle) circle.id)
    ]
    []


viewSound : SoundAnimation -> Svg
viewSound sound =
  Svg.circle
    [ fill "none"
    , opacity (toString sound.alpha)
    , stroke "#ffffff"
    , strokeWidth "1.0"
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
