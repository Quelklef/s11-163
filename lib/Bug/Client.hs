{-# LANGUAGE TypeApplications #-}

module Bug.Client where

import           Bug.SPA                      (API, route2model, routes, view)
import           Shpadoinkle                  (JSM)
import           Shpadoinkle.Backend.Snabbdom (runSnabbdom, stage)
import           Shpadoinkle.Router           (fullPageSPA, withHydration)
import           Shpadoinkle.Run (runJSorWarp)

app :: JSM ()
app = fullPageSPA @(API JSM) id runSnabbdom (withHydration route2model) view stage route2model routes

main :: IO ()
main = runJSorWarp 8080 Bug.Client.app
