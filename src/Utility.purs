module Utility where

import Prelude
import Common (Compressed(..), Content(..), GistID, appDomain, appRootWithSlash, clientID)
import Effect (Effect)
import LzString (compressToEncodedURIComponent, decompressFromEncodedURIComponent)
import Web.HTML (window)
import Web.HTML.Location (setHref)
import Web.HTML.Window (location)

data ViewMode
  = SideBySide
  | Code
  | Output

-- Could alternatively derive if displaying "SideBySide" is okay.
instance showViewMode :: Show ViewMode where
  show SideBySide = "Side-by-side"
  show Code = "Code"
  show Output = "Output"

derive instance eqViewMode :: Eq ViewMode

type PushRoute
  = String -> Effect Unit

data GistStatus
  = NoGist
  | SavingGist
  | HaveGist GistID

compress :: Content -> Compressed
compress (Content c) = Compressed $ compressToEncodedURIComponent c

decompress :: Compressed -> Content
decompress (Compressed c) = Content $ decompressFromEncodedURIComponent c

ghAuthorize :: Content -> Effect Unit
ghAuthorize content = do
  win <- window
  loc <- location win
  -- I believe it's fine for client ID to be public information
  let
    authUrl =
      "https://github.com/login/oauth/authorize?"
        <> "client_id="
        <> clientID
        <> "&scope=gist"
        <> "&redirect_uri="
        <> appDomain
        <> appRootWithSlash
        <> "/?comp="
        <> (show $ compress content)
  setHref authUrl loc
