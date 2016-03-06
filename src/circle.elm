module Circle
  ( Circle
  , defaultCircle
  , newCircle
  , tick
  ) where

growSpeed = 0.2

type alias Circle =
  { id : Int
  , x : Int
  , y : Int
  , radius : Float
  }

defaultCircle : Circle
defaultCircle =
  { id = 0
  , x = 0
  , y = 0
  , radius = 0
  }

newCircle : Int -> Int -> Int -> Circle
newCircle id x y =
  { defaultCircle
  | id = id
  , x = x
  , y = y
  }

tick : Circle -> Circle
tick circle =
  { circle
  | radius = circle.radius + growSpeed
  }
