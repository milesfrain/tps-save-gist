module Compile where

import Prelude
import Affjax as AX
import Affjax.RequestBody as AXRB
import Affjax.ResponseFormat as AXRF
import Common (Content(..), compileUrl)
import Control.Alternative ((<|>))
import Data.Argonaut (class DecodeJson, decodeJson)
import Data.Argonaut.Core as J
import Data.Argonaut.Decode.Generic.Rep (genericDecodeJsonWith)
import Data.Argonaut.Types.Generic.Rep (defaultEncoding)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log, logShow)

------- Compile API types -------
--
-- The result of calling the compile API.
data CompileResult
  = CompileSuccess SuccessResult
  | CompileFailed FailedResult

-- A successful compilation result
type SuccessResult
  = { js :: String
    , warnings :: Maybe (Array CompileWarning)
    }

-- A warning about the code found during compilation
type CompileWarning
  = { errorCode :: String
    , message :: String
    , position :: Maybe ErrorPosition
    , suggestion :: Maybe Suggestion
    }

-- The range of text associated with an error or warning
type ErrorPosition
  = { startLine :: Int
    , endLine :: Int
    , startColumn :: Int
    , endColumn :: Int
    }

-- A code suggestion
type Suggestion
  = { replacement :: String
    , replaceRange :: Maybe ErrorPosition
    }

-- A failed compilation result
type FailedResult
  = { error :: CompileError }

-- An error reported from the compile API
data CompileError
  = CompilerErrors (Array CompilerError)
  -- Examples of `OtherError` include:
  -- * Code is not "module Main"
  -- * The code snippet is too large
  | OtherError String

-- An error found with the code during compilation
type CompilerError
  = { message :: String
    , position :: Maybe ErrorPosition
    }

------- Json Decoding -------
--
-- The Compile API returns an object representing the contents of either:
-- * CompileSuccess
-- * CompileFailed
-- Decoding to CompileResult requires attempting to match each of these.
instance decodeJsonCompileResult :: DecodeJson CompileResult where
  decodeJson j =
    CompileSuccess <$> decodeJson j
      <|> CompileFailed
      <$> decodeJson j

derive instance genericCompileResult :: Generic CompileResult _

-- The Compile API encodes the CompileError tagged union differently than
-- argonaut's generic options, so we need to adjust the default encoding
-- options to successfully decode.
instance decodeJsonCompileError :: DecodeJson CompileError where
  decodeJson =
    genericDecodeJsonWith
      $ defaultEncoding
          { valuesKey = "contents"
          , unwrapSingleArguments = true
          }

derive instance genericCompileError :: Generic CompileError _

-- temp
instance showCompileResult :: Show CompileResult where
  show = genericShow

instance showCompileError :: Show CompileError where
  show = genericShow

-- | POST the specified code to the Try PureScript API, and wait for
-- | a response.
compile :: Content -> Aff (Either String CompileResult)
compile (Content ct) = do
  result <- AX.post AXRF.json (compileUrl <> "/compile") $ Just $ AXRB.string ct
  pure
    $ case result of
        Left err -> Left $ "POST compile response failed to decode: " <> AX.printError err
        Right response -> do
          let
            respStr = "POST /api response: " <> J.stringify response.body
          case decodeJson response.body of
            Left err -> Left $ "Failed to decode json response: " <> respStr <> ", Error: " <> show err
            Right (decoded :: CompileResult) -> Right decoded
