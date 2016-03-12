module Circle
  ( Circle
  , Class
  , defaultCircle
  , newCircle
  , tick
  , doCollision
  , collisionTest
  , checkForCollisions
  ) where

import List
import Vec2

growSpeed = 0.2

type alias Class =
  { circle : String
  , sound : String
  }

type Direction
  = Grow
  | Shrink

type Mode
  = A
  | B
  | C

type alias Circle =
  { id : Int
  , class : Class
  , sound : String
  , x : Int
  , y : Int
  , radius : Float
  , direction : Direction
  , collision : Bool
  }


defaultCircle : Circle
defaultCircle =
  { id = 0
  , class = { circle = "", sound = ""}
  , sound = ""
  , x = 0
  , y = 0
  , radius = 0
  , direction = Grow
  , collision = False
  }


soundsCount = 8


newCircle : Int -> Int -> Int -> Circle
newCircle id x y =
  let
    mode =
      case id % 3 of
        0 -> A
        1 -> B
        _ -> C
    modeString =
      case mode of
        A -> "a"
        B -> "b"
        C -> "c"
    class =
      { circle = "circle-" ++ modeString
      , sound = "sound-" ++ modeString
      }
    sound = "circle " ++ modeString ++ " " ++ (toString (id % soundsCount))
  in
    { defaultCircle
    | id = id
    , x = x
    , y = y
    , class = class
    , sound = sound
    }


tick : Circle -> Circle
tick circle =
  let
    radius = max 0.0 (circle.radius +
      case circle.direction of
        Grow -> growSpeed
        Shrink -> -growSpeed)
    direction = if radius == 0.0 then Grow else circle.direction
  in
    { circle
    | radius = radius
    , direction = direction
    , collision = False
    }


doCollision : Circle -> Circle
doCollision circle =
  { circle
  | direction = Shrink
  , collision = True
  }


checkForCollisions : Circle -> List Circle -> Bool
checkForCollisions circle circles =
  List.any (\circle' -> collisionTest circle circle') circles


collisionTest : Circle -> Circle -> Bool
collisionTest a b =
  (distanceBetweenCircles a b) - a.radius - b.radius <= 0.0


distanceBetweenCircles : Circle -> Circle -> Float
distanceBetweenCircles a b =
  Vec2.distance
    { x = toFloat a.x, y = toFloat a.y }
    { x = toFloat b.x, y = toFloat b.y }
