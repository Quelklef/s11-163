{-# LANGUAGE LambdaCase, TypeApplications #-}

module Bug.Server where

import           Bug.SPA                   (API, route2model, routes, template,
                                            view)
import           Data.Proxy                (Proxy (Proxy))
import           Network.Wai.Handler.Warp  as Wai (run)
import           Servant.Server            (Handler, runHandler, serve)
import           Shpadoinkle.Router.Server (serveUI)


main :: IO ()
main = do
  putStrLn "Starting Server..."
  Wai.run 8080 $
    serve
      (Proxy @(API Handler))
      (
        serveUI
          @(API Handler)
          "./client/bin/client.jsexe"
          (\route -> toIO $ do
              model <- route2model route
              pure $ template model (view model))
          routes
      )

  where

  toIO :: Handler a -> IO a
  toIO a = runHandler a >>= \case
      Left err -> error $ show err
      Right x  -> pure x
