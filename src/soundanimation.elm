module SoundAnimation
  ( SoundAnimation
  , fromCircle
  , tick
  ) where

import Circle exposing (Circle)


growSpeed = 0.2
alphaSpeed = -0.004


type alias SoundAnimation =
  { x : Int
  , y : Int
  , radius : Float
  , alpha : Float
  }


fromCircle : Circle -> SoundAnimation
fromCircle circle =
  { x = circle.x
  , y = circle.y
  , radius = circle.radius
  , alpha = 0.4
  }


tick : SoundAnimation -> Maybe SoundAnimation
tick sound =
  let
    sound' =
      { sound
      | radius = sound.radius + growSpeed
      , alpha = sound.alpha + alphaSpeed
      }
  in
    if sound'.alpha > 0.0 then
      Just sound'
    else
      Nothing

