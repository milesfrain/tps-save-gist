module Main where

import Prelude

import Ace as Ace
import Ace.Document as Document
import Ace.EditSession as Session
import Ace.Editor as Editor
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)

foreign import onLoad :: Effect Unit -> Effect Unit

main :: Effect Unit
main = onLoad $ do
  -- Create an editor
  editor <- Ace.edit "editor" Ace.ace
  session <- Editor.getSession editor
  document <- Session.getDocument session
  _ <- Editor.setValue "blablabla \n tr  test boo boo" Nothing editor

  -- Log some events
  editor `Editor.onCopy` \s -> log ("Text copied: " <> s)
  editor `Editor.onPaste` \_ -> log "Text pasted."
  editor `Editor.onBlur` log "Editor lost focus."
  editor `Editor.onFocus` log "Editor gained focus."

  document `Document.onChange` \(Ace.DocumentEvent {action: ty}) ->
    log ("Document changed: " <> Ace.showDocumentEventType ty)

  -- Move the cursor to start of file
  Editor.navigateFileStart editor

  pure unit