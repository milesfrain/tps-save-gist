module Try.Types
  ( JS(..)
  ) where

import Data.Argonaut (class EncodeJson)
import Data.Newtype (class Newtype)
import Data.Show (class Show)

--import Foreign.Class (class Encode)
newtype JS
  = JS String

-- enable `unwrap`
derive instance newtypeJS :: Newtype JS _

derive newtype instance showJS :: Show JS
derive newtype instance encodeJsonJS :: EncodeJson JS


{-
instance showJS :: Show JS where
  show (JS str) = str
-}

--derive newtype instance encodeJS :: Encode JS
