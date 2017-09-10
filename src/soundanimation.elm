module SoundAnimation
    exposing
        ( SoundAnimation
        , fromCircle
        , tick
        )

import Circle exposing (Circle)


growSpeed =
    0.2


alphaSpeed =
    -0.004


type alias SoundAnimation =
    { x : Int
    , y : Int
    , radius : Float
    , alpha : Float
    , class : String
    }


fromCircle : Circle -> SoundAnimation
fromCircle circle =
    { x = circle.x
    , y = circle.y
    , radius = circle.radius
    , alpha = 0.4
    , class = circle.class.sound
    }


tick : SoundAnimation -> Maybe SoundAnimation
tick sound =
    let
        sound_ =
            { sound
                | radius = sound.radius + growSpeed
                , alpha = sound.alpha + alphaSpeed
            }
    in
        if sound_.alpha > 0.0 then
            Just sound_
        else
            Nothing
