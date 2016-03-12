import Effects exposing (Never)
import Model
import Primer
import StartApp
import Task
import Time
import View
import Window


inputSignals =
  [ Signal.map Model.Dimensions (Primer.prime Window.dimensions)
  , Signal.map Model.Tick (Time.fps 60)
  ]


app =
  StartApp.start
    { init = Model.init
    , update = Model.update
    , view = View.view
    , inputs = inputSignals
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


port sounds : Signal String
port sounds =
  Model.soundSignal

