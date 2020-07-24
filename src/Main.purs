module Main where

import Prelude

import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)

import Ace (Document)
import Ace as Ace
import Ace.Document as Document
import Ace.EditSession as Session
import Ace.Editor as Editor
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Hooks as HK
import Halogen.Query.EventSource as ES
import Tailwind as T

main :: Effect Unit
main =
  HA.runHalogenAff do
    body <- HA.awaitBody
    void $ runUI component unit body

component :: forall q i o m. MonadAff m => H.Component HH.HTML q i o m
component =
  HK.component \_ input -> HK.do
    document /\ documentId <- HK.useState (Nothing :: Maybe Document)
    --
    -- Initialize Ace editor and subscribe to text changes
    HK.useLifecycleEffect do
      doc <-
        liftEffect do
          -- Create an editor
          editor <- Ace.edit "editor" Ace.ace
          session <- Editor.getSession editor
          docInner <- Session.getDocument session
          pure docInner
      -- Handle changes within editor
      -- Ignoring subscription ID
      _ <-
        HK.subscribe do
          ES.effectEventSource \emitter -> do
            -- Ignoring DocumentEvent
            Document.onChange doc \_ -> do
              str <- Document.getValue doc
              ES.emit emitter do
                log $ "Editor content: " <> str
            -- No finalizer, so return mempty
            pure mempty
      HK.put documentId $ Just doc
      pure Nothing
    --
    -- Render
    HK.pure do
      HH.div [ HP.classes [ T.flex, T.flexCol, T.hScreen ] ]
        [ HH.img
            [ HP.src "./img/favicon-white.svg"
            , HP.width 40
            , HP.width 40
            , HP.classes [ T.bgGreen200 ]
            ]
        , HH.button
            [ HP.classes [ T.bgGreen200 ]
            -- Clear editor content
            , HE.onClick \_ ->
                Just
                  $ liftEffect
                  $ traverse_ (Document.setValue "") document
            ]
            [ HH.text "Clear" ]
        , HH.div
            [ HP.classes [ T.flexGrow, T.bgGray200 ]
            , HP.id_ "editor"
            ]
            []
        ]