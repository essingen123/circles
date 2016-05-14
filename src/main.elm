import Model
import Html.App as Html
import Time
import View


subscriptions _ =
  Time.every (16.667 * Time.millisecond) Model.Tick


main =
  Html.program
    { init = Model.init
    , view = View.view
    , update = Model.update
    , subscriptions = subscriptions
    }


