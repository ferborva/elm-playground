module Main exposing (..)

import Html exposing (text, div)

type alias Dog =
  { name : String
  , age : Int
  }


dog =
  { name = "Spock"
  , age = 3
  }


renderDog : Dog -> String
renderDog dog =
   dog.name ++ ", " ++ (toString dog.age)


politely : String -> String
politely phrase =
  "Excuse me, "
     ++ phrase


ask : String -> String -> String
ask thing place =
  "is there a "
     ++ thing
     ++ " in the "
     ++ place
     ++ "?"


askPolitelyAboutFish : String -> String
askPolitelyAboutFish =
  politely << (ask "fish")


main =
  div []
    [ text
       <| askPolitelyAboutFish "sock",
      text
       <| renderDog dog 
    ]
