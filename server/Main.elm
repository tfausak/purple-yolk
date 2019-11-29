port module Main exposing ( main )

main : Program Flags Model Msg
main = Platform.worker
  { init = \ () -> ( (), log "Hello from Elm!" )
  , subscriptions = \ () -> Sub.none
  , update = \ () () -> ( (), Cmd.none )
  }

type alias Flags = ()

type alias Model = ()

type alias Msg = ()

port log : String -> Cmd msg
