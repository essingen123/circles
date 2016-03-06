module Point
  ( Point
  , defaultPoint
  ) where

type alias Point =
  { x : Int
  , y : Int
  }

defaultPoint : Point
defaultPoint =
  { x = 0, y = 0 }
