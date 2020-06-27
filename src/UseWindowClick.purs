module UseWindowClick where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Halogen.Hooks (Hook, HookM, UseEffect)
import Halogen.Hooks as Hooks
import Halogen.Query.EventSource as ES
import Web.Event.Event (EventType(..))
import Web.HTML as HTML
import Web.HTML.Window as Window

newtype UseWindowClick hooks
  = UseWindowClick (UseEffect hooks)

derive instance newtypeUseWindowClick :: Newtype (UseWindowClick hooks) _

useWindowClick :: forall m. MonadAff m => HookM m Unit -> Hook m UseWindowClick Unit
useWindowClick handler =
  Hooks.wrap Hooks.do

    Hooks.useLifecycleEffect do
      window <- liftEffect HTML.window

      _ <- Hooks.subscribe do
        ES.eventListenerEventSource
          (EventType "click")
          (Window.toEventTarget window)
          (const $ Just handler)

      pure $ Just $ pure unit

    Hooks.pure unit