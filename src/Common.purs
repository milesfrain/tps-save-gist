module Common where

import Prelude

appDomain :: String
--appDomain = "https://milesfrain.github.io"
appDomain = "http://localhost:1234"

-- This is for compatibilty with gh-pages root.
-- May be empty string for local development.
appRootNoSlash :: String
--appRootNoSlash = ""
--appRootNoSlash = "gist-prototype"
appRootNoSlash = "tps-save-gist"

-- Appending needs the slash,
-- but routing matching cannot have the slash.
appRootWithSlash :: String
appRootWithSlash = case appRootNoSlash of
  "" -> ""
  r -> "/" <> r

-- Fix image paths
imgPrefix :: String
imgPrefix = if appRootNoSlash == "" then "" else "../"

--imgPrefix = ""
tokenServerUrl :: String
--tokenServerUrl = "http://localhost:7071/api/localtrigger"
--tokenServerUrl = "https://gistfunction.azurewebsites.net/api/localtrigger?code=bLvuwjDHG1EWLo7J1IOA8xTRUlHCTi52bm/pvnXBHdUuWovaU5eXHg=="
tokenServerUrl = "https://localgistfunction.azurewebsites.net/api/localtrigger?code=cQGVRL6DD7MPVEctYa8j1TTjnog5fJduLivuPBj4Uw0PUzMPFQzwTg=="

clientID :: String
--clientID = "bbaa8fdc61cceb40c899" -- gh
clientID = "6f4e10fd8cef6995ac09" -- local

newtype AuthCode
  = AuthCode String

instance showAuthCode :: Show AuthCode where
  show (AuthCode c) = c

newtype Compressed
  = Compressed String

instance showCompressed :: Show Compressed where
  show (Compressed c) = c

newtype Content
  = Content String

instance showContent :: Show Content where
  show (Content c) = c

derive instance eqContent :: Eq Content

newtype GistID
  = GistID String

instance showGistID :: Show GistID where
  show (GistID g) = g

newtype GhToken
  = GhToken String

instance showToken :: Show GhToken where
  show (GhToken t) = t
