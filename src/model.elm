module Model
  ( Model
  , Action (..)
  , init
  , update
  ) where

import Circle exposing (Circle)
import Effects exposing (Effects)
import List
import List.Extra
import Point exposing (Point)


type Action
  = AddCircle (Int, Int)
  | RemoveCircle Int
  | Tick Float
  | Dimensions (Int, Int)


type alias Model =
  { circles : List Circle
  , nextId : Int
  , dimensions : Point
  }


defaultModel : Model
defaultModel =
  { circles = []
  , nextId = 0
  , dimensions = Point.defaultPoint
  }


init : (Model, Effects Action)
init =
  (defaultModel, Effects.none)


update : Action -> Model -> (Model, Effects Action)
update action model =
  ( case action of
      AddCircle (x, y) -> addCircle (x, y) model
      RemoveCircle id -> removeCircle id model
      Tick _ -> tickCircles model
      Dimensions (w, h) -> { model | dimensions = { x = w, y = h } }
  , Effects.none
  )


addCircle : (Int, Int) -> Model -> Model
addCircle (x, y) model =
  let
    circle = Circle.newCircle model.nextId x y
  in
    { model
    | circles = circle :: model.circles
    , nextId = model.nextId + 1
    }


removeCircle : Int -> Model -> Model
removeCircle id model =
  { model
  | circles = List.filter (\circle -> id /= circle.id) model.circles
  }


tickCircles : Model -> Model
tickCircles model =
  { model
  | circles = List.map Circle.tick model.circles
  }
  |> findCollisions

findCollisions : Model -> Model
findCollisions model =
  let
    collisionTest a b =
      a.id /= b.id && Circle.collisionTest a b
    checkForCollisions circle =
      if List.any (collisionTest circle) model.circles then
        Circle.doCollision circle
      else
        circle
    circles = List.map checkForCollisions model.circles
  in
    { model | circles = circles }
