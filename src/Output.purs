module Output where

import Prelude
import Data.Argonaut (Json, (.:))
import Data.Argonaut.Decode (decodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Foreign.Object (Object)
import Try.Types (JS(..))

{-
Manages compiled code output
-}
-- Todo, are many attempts required to communicate with iframe?
foreign import postMessage :: Object JS -> Effect Unit
