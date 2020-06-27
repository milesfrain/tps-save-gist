module MyHooksExtra where

import Prelude

import Data.Tuple (Tuple)
import Halogen.Hooks (Hook, HookM)
import Halogen.Hooks as Hooks
import Halogen.Hooks.Extra.Hooks (UseStateFn, useStateFn)

-- | Just like `useState`, but provides a convenience function for updating state, rather than a state index to pass to `Hooks.modify_`.
-- |
-- | Example:
-- | ```
-- | count /\ modifyCount <- useModifyState_ 42
-- | modifyCount (add 1)
-- | ```
-- |
-- | Instead of:
-- | ```
-- | count /\ countIdx <- useState 42
-- | Hooks.modify_ countIdx (add 1)
-- | ```
-- |
-- | Shorthand for:
-- | ```
-- | useStateFn Hooks.modify_
-- | ```
-- |
useModifyState_
  :: forall m a
   . a
  -> Hook m (UseStateFn a) (Tuple a ((a -> a) -> HookM m Unit))
useModifyState_ =
  useStateFn Hooks.modify_

-- | Just like `useState`, but provides a convenience function for updating state, rather than a state index to pass to `Hooks.modify`.
-- |
-- | Example:
-- | ```
-- | count /\ modifyCount <- useModifyState 42
-- | modifyCount (add 1)
-- | ```
-- |
-- | Instead of:
-- | ```
-- | count /\ countIdx <- useState 42
-- | Hooks.modify countIdx (add 1)
-- | ```
-- |
-- | Shorthand for:
-- | ```
-- | useStateFn Hooks.modify
-- | ```
-- |
useModifyState
  :: forall m a
   . a
  -> Hook m (UseStateFn a) (Tuple a ((a -> a) -> HookM m a))
useModifyState =
  useStateFn Hooks.modify

-- | Just like `useState`, but provides a convenience function for setting state, rather than a state index to pass to `Hooks.put`.
-- |
-- | Example:
-- | ```
-- | count /\ putCount <- usePutState 42
-- | putCount 0
-- | ```
-- |
-- | Instead of:
-- | ```
-- | count /\ countIdx <- useState 42
-- | Hooks.put countIdx 0
-- | ```
-- |
-- | Shorthand for:
-- | ```
-- | useStateFn Hooks.put
-- | ```
-- |
usePutState
  :: forall m a
   . a
  -> Hook m (UseStateFn a) (Tuple a (a -> HookM m Unit))
usePutState =
  useStateFn Hooks.put