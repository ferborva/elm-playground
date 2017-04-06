module Funcs exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing (..)

numbers =
  [ 1, 2, 3, 4, 5 ]

fruits =
  [ { name = "Orange"}
  , { name = "Banana" }
  ]

printThings : thing -> Html msg
printThings thing =
  li []
    [ text <| toString thing ]

main =
  ul []
    (List.map printThings fruits)
