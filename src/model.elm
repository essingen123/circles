module Model
    exposing
        ( Model
        , Msg(..)
        , init
        , update
        )

import Circle exposing (Circle)
import Debug
import List
import List.Extra
import PlaySound
import SoundAnimation exposing (SoundAnimation)


type Msg
    = AddCircle ( Int, Int )
    | RemoveCircle Int
    | SelectCircleType Circle.Type
    | Tick Float
    | Noop


type alias Model =
    { circles : List Circle
    , circleType : Circle.Type
    , nextId : Int
    , sounds : List String
    , soundAnimations : List SoundAnimation
    }


defaultModel : Model
defaultModel =
    { circles = []
    , circleType = Circle.A
    , nextId = 0
    , sounds = []
    , soundAnimations = []
    }


init : ( Model, Cmd Msg )
init =
    ( defaultModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    (case action of
        AddCircle ( x, y ) ->
            addCircle ( x, y ) model

        RemoveCircle id ->
            removeCircle id model

        SelectCircleType circleType ->
            { model | circleType = circleType }

        Tick _ ->
            tickCircles model

        Noop ->
            model
    )
        |> triggerSounds


addCircle : ( Int, Int ) -> Model -> Model
addCircle ( x, y ) model =
    let
        circle =
            Circle.newCircle model.circleType model.nextId x y
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
        findCollisions_ circle ( resultCircles, sounds, collisions, maybeCircles ) =
            case maybeCircles of
                Just circles ->
                    let
                        collisions_ =
                            List.filterMap
                                (\x ->
                                    if Circle.collisionTest circle x then
                                        Just x
                                    else
                                        Nothing
                                )
                                circles

                        sounds_ =
                            getCollisionSounds circle collisions_

                        circle_ =
                            if not (List.isEmpty collisions_) || List.member circle collisions then
                                Circle.doCollision circle
                            else
                                circle
                    in
                        ( circle_ :: resultCircles
                        , List.append sounds sounds_
                        , List.append collisions collisions_
                        , List.Extra.init circles
                        )

                Nothing ->
                    let
                        circle_ =
                            if List.member circle collisions then
                                Circle.doCollision circle
                            else
                                circle
                    in
                        ( circle_ :: resultCircles, sounds, [], Nothing )

        ( circles, soundsAndAnimations, _, _ ) =
            List.foldr
                findCollisions_
                ( [], [], [], List.Extra.init model.circles )
                model.circles

        ( sounds, soundAnimations ) =
            List.unzip soundsAndAnimations
    in
        { model
            | circles = circles
            , sounds = sounds
            , soundAnimations = List.append model.soundAnimations soundAnimations
        }


getCollisionSounds : Circle -> List Circle -> List ( String, SoundAnimation )
getCollisionSounds circleA collisions =
    let
        getSound circleB =
            let
                circle =
                    if circleA.radius >= circleB.radius then
                        circleA
                    else
                        circleB
            in
                ( circle.sound, SoundAnimation.fromCircle circle )
    in
        List.map getSound collisions


triggerSounds : Model -> ( Model, Cmd Msg )
triggerSounds model =
    ( { model | sounds = [] }
    , Cmd.batch (List.map (\sound -> PlaySound.playSound sound) model.sounds)
    )
