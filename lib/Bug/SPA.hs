{-# LANGUAGE DataKinds, LambdaCase, OverloadedStrings, TypeOperators #-}

module Bug.SPA where

import           Data.Text          (Text)
import           Prelude            hiding (div)
import           Servant.API        ((:<|>), (:>), QueryParam, Raw)
import           Servant.API        ((:<|>) ((:<|>)))
import           Shpadoinkle.Html   (Html)
import qualified Shpadoinkle.Html   as H
import           Shpadoinkle.Router (toHydration, View, HasRouter ((:>>)))
import           Shpadoinkle.Run    (Env (Prod), entrypoint)

default (Text)




type API m
  = "echo" :> QueryParam "text" Text :> View m Text
                -- QueryParam is necessary for error
                -- issue also manifests with Capture
  :<|> Raw


data Route = REcho (Maybe Text)

routes :: API m :>> Route
routes = REcho :<|> REcho (Just "fishy")


type Model = Maybe Text

view :: Model -> Html m Model
view = \case
  Just t  -> H.div_ [ H.text $ "Echo: " <> t ]
  Nothing -> H.div_ [ "Silence" ]

template :: Model -> Html m a -> Html m a
template m0 stage =
  H.html_
    [ H.head_
      [ toHydration m0  -- error changes if removed
      , H.script [ H.src $ entrypoint Prod ] []  -- necessary for error
      ]
    , H.body_
      [ stage
      ]
    ]


route2model :: Monad m => Route -> m Model
route2model (REcho mt) = pure mt

