module Model
  ( Model
  , Action (..)
  , init
  , update
  , soundSignal
  ) where

import Circle exposing (Circle)
import Debug
import Effects exposing (Effects)
import List
import List.Extra
import Point exposing (Point)
import SoundAnimation exposing (SoundAnimation)


type Action
  = AddCircle (Int, Int)
  | RemoveCircle Int
  | Tick Float
  | Dimensions (Int, Int)
  | Noop


type alias Model =
  { circles : List Circle
  , nextId : Int
  , dimensions : Point
  , sounds : List String
  , soundAnimations : List SoundAnimation
  }


defaultModel : Model
defaultModel =
  { circles = []
  , nextId = 0
  , dimensions = Point.defaultPoint
  , sounds = []
  , soundAnimations = []
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
      Noop -> model
  ) |> triggerSounds


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
  , soundAnimations = List.filterMap SoundAnimation.tick model.soundAnimations
  }
  |> findCollisions


findCollisions : Model -> Model
findCollisions model =
  let
    findCollisions' circle (resultCircles, sounds, collisions, maybeCircles) =
      case maybeCircles of
        Just circles ->
          let
            collisions' =
              List.filterMap
              (\x -> if Circle.collisionTest circle x then Just x else Nothing)
              circles
            sounds' = getCollisionSounds circle collisions'
            circle' =
              if not (List.isEmpty collisions') || List.member circle collisions then
                Circle.doCollision circle
              else
                circle
          in
            ( circle' :: resultCircles
            , List.append sounds sounds'
            , List.append collisions collisions'
            , List.Extra.init circles
            )
        Nothing ->
          let
            circle' =
              if List.member circle collisions then
                Circle.doCollision circle
              else
                circle
          in
            (circle' :: resultCircles, sounds, [], Nothing)
    (circles, soundsAndAnimations, _, _) =
      List.foldr
      findCollisions'
      ([], [], [], List.Extra.init model.circles)
      model.circles
    (sounds, soundAnimations) = List.unzip soundsAndAnimations
  in
    { model
    | circles = circles
    , sounds = sounds
    , soundAnimations = List.append model.soundAnimations soundAnimations
    }


getCollisionSounds : Circle -> List Circle -> List (String, SoundAnimation)
getCollisionSounds circleA collisions =
  let
    getSound circleB =
      let
        circle = if circleA.radius >= circleB.radius then circleA else circleB
      in
        (circle.sound, SoundAnimation.fromCircle circle)
  in
    List.map getSound collisions


triggerSounds : Model -> (Model, Effects Action)
triggerSounds model =
  let
    sendSound sound =
      Signal.send sounds.address sound
      |> Effects.task
      |> Effects.map (always Noop)
  in
    ( { model | sounds = [] }
    , Effects.batch (List.map sendSound model.sounds)
    )


sounds : Signal.Mailbox String
sounds = Signal.mailbox ""


soundSignal : Signal String
soundSignal = sounds.signal

