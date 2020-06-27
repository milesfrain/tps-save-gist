module HooksHelper where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Halogen.HTML (IProp)
import Halogen.HTML.Events as HE
import Halogen.Hooks (HookM)
import Web.Event.Event (stopPropagation)
import Web.UIEvent.MouseEvent as ME

-- An example use case for this function is to prevent dropdowns
-- from automatically closing when interacting with the dropdown
-- if a clicks propagated to the window would otherwise close the
-- dropdown.
onClickNoPropagation :: forall r m. MonadAff m => HookM m Unit -> IProp ( onClick :: ME.MouseEvent | r ) (HookM m Unit)
onClickNoPropagation act =
  HE.onClick (\evt -> Just $ do
      -- stopPropagation is necessary so button click not also interpreted as window click.
      liftEffect $ stopPropagation $ ME.toEvent evt
      act)
