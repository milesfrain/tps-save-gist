module TPS where

import Prelude
import Ace (Document)
import Ace as Ace
import Ace.Document as Document
import Ace.EditSession as Session
import Ace.Editor as Editor
import Classes (commonMenuClasses, dropdownItemClasses, menuTextClasses)
import Common (Content(..), GhToken, GistID(..), appRootWithSlash, imgPrefix)
import Data.Either (Either(..))
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class.Console (log)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.Hooks (useState)
import Halogen.Hooks as HK
import Halogen.Query.EventSource as ES
import HooksHelper (onClickNoPropagation)
import MyHooksExtra (useModifyState_, usePutState)
import MyRouting (MyRoute(..))
import Request (ghCreateGist, ghGetGist, ghRequestToken)
import Tailwind as T
import UseWindowClick (useWindowClick)
import Utility (GistStatus(..), PushRoute, ViewMode(..), compress, decompress, ghAuthorize)

type Input
  = PushRoute

-- Query must be (Type -> Type)
data Query a
  = Nav MyRoute a

component :: forall o m. MonadAff m => H.Component HH.HTML Query Input o m
component =
  -- No tokens for child slots or output
  HK.component \({ queryToken } :: HK.ComponentTokens Query _ o) input -> HK.do
    -- Annotations for initial values not required, but helps with clarity
    viewMode /\ putViewMode <- usePutState (SideBySide :: ViewMode)
    autoCompile /\ modifyAutoCompile <- useModifyState_ true
    showJS /\ modifyShowJS <- useModifyState_ false
    dropdownOpen /\ modifyDropdownOpen <- useModifyState_ false
    content /\ contentIdx <- useState $ Content ""
    document /\ putDocument <- usePutState (Nothing :: Maybe Document)
    route /\ putRoute <- usePutState (Nothing :: Maybe MyRoute)
    ghToken /\ putGhToken <- usePutState (Nothing :: Maybe GhToken)
    pushRoute /\ putPushRoute <- usePutState (input :: PushRoute)
    gistID /\ putGistID <- usePutState (NoGist :: GistStatus)
    --
    -- Helper functions to reduce code duplication
    let
      -- GhToken is a parameter rather than picked-up from state
      -- to ensure it is not Nothing
      doSaveGist gh_token = do
        -- Cannot just use `content` - will be stale
        currentContent <- HK.get contentIdx
        log $ "saving gist, content: " <> show currentContent
        log $ "example of stale content: " <> show content
        eitherId <- liftAff $ ghCreateGist gh_token $ currentContent
        case eitherId of
          Left err -> log err
          Right id -> do
            putGistID $ HaveGist id
            liftEffect $ pushRoute $ appRootWithSlash <> "/?gist=" <> (show id)

      -- update content in editor and state
      writeContent (Content ct) = do
        log $ "writing content: " <> ct
        HK.put contentIdx $ Content ct
        liftEffect $ traverse_ (Document.setValue ct) document
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
              let
                newContent = Content str
              ES.emit emitter do
                -- Compare content to prevent clearing gist status immediately upon gist load
                oldContent <- HK.get contentIdx
                if (newContent /= oldContent) then do
                  -- New content clears existing gistID
                  putGistID NoGist
                  writeContent newContent
                  liftEffect $ pushRoute $ appRootWithSlash <> "/?comp=" <> (show $ compress newContent)
                else do
                  -- Do nothing if content unchanged
                  pure unit
            -- No finalizer, so return mempty
            pure mempty
      putDocument $ Just doc
      pure Nothing
    --
    -- Handle routing queries
    HK.useQuery queryToken \(Nav rt a) -> do
      -- multiple state modifications, but not a performance issue now.
      putRoute $ Just rt
      case rt of
        AuthorizeCallback authCode compressed -> do
          log "in auth callback"
          -- Immediately show new content.
          -- This also requires setting saving flag again, since state
          -- is reset upon page refresh from callback.
          writeContent $ decompress compressed
          putGistID SavingGist
          -- Make ghToken request to private app server
          res <- liftAff $ ghRequestToken authCode
          case res of
            Left err -> log err
            Right gh_token -> do
              -- Save ghToken
              putGhToken $ Just gh_token
              -- Save gist
              doSaveGist gh_token
        LoadCompressed compressed -> do
          let
            ct = decompress compressed
          log $ "Got content from url: " <> show ct
          writeContent ct
        LoadGist gist_id -> do
          eitherContent <- liftAff $ ghGetGist gist_id
          let
            ct = case eitherContent of
              Left err -> Content $ "Failed to load Gist\nLikely missing\n" <> err
              Right c -> c
          log $ "Got content from gist: " <> show ct
          writeContent ct
          putGistID $ HaveGist gist_id
      -- Required response boilerplate for query
      pure (Just a)
    --
    -- Close dropdown when clicked in window outside of button
    useWindowClick $ modifyDropdownOpen (const false)
    --
    -- Helper functions for rendering
    let
      menu =
        HH.div
          [ HP.classes
              [ T.flex
              , T.bgTpsBlack
              ]
          ]
          [ HH.a
              --[ HP.href "/"
              [ HP.href $ appRootWithSlash <> "/?gist=6e49291fd9e7bac1bc5c811c93e072f3"
              , HP.title "Try PureScript!"
              , HP.classes commonMenuClasses
              ]
              -- Could also define image width/height in css
              [ HH.img
                  [ HP.src $ imgPrefix <> "img/favicon-white.svg"
                  , HP.width 40
                  , HP.width 40
                  ]
              ]
          , HH.div
              [ HP.classes
                  [ T.relative
                  ]
              ]
              [ mkClickButton
                  "View Mode ▾"
                  "Select a view mode"
                  false -- don't auto-close dropdown
                  $ modifyDropdownOpen not
              , dropdown
              ]
          , mkClickButton
              "Compile"
              "Compile Now"
              true -- close dropdown
              $ log "compiling"
          , mkToggleButton
              "Auto-Compile"
              "Compile on code changes"
              autoCompile
              $ modifyAutoCompile not
          , mkToggleButton
              "Show JS"
              "Show resulting JavaScript code instead of output"
              showJS
              $ modifyShowJS not
          , gistButtonOrLink
          ]

      mkClickButton text title propagate action =
        HH.button
          [ HP.classes $ menuTextClasses
          , HP.title title
          , if propagate then
              HE.onClick \_ -> Just action
            else
              onClickNoPropagation action
          ]
          [ HH.text text ]

      mkToggleButton text title enabled action =
        HH.button
          [ HP.classes $ menuTextClasses <> [ highlight ]
          , HP.title title
          , HE.onClick \_ -> Just action
          ]
          [ HH.text text ]
        where
        highlight = if enabled then T.textTpsEnabled else T.textTpsDisabled

      dropdown =
        if dropdownOpen then
          HH.div
            [ HP.classes
                [ T.absolute
                , T.z10
                , T.wFull
                ]
            ]
            $ map
                mkDropdownItem
                [ SideBySide, Code, Output ]
        else
          HH.div_ []

      mkDropdownItem vm =
        HH.button
          [ HP.classes $ dropdownItemClasses <> highlight
          , onClickNoPropagation $ putViewMode vm
          ]
          [ HH.text $ show vm ]
        where
        highlight = if vm == viewMode then [ T.textTpsEnabled ] else []

      gistButtonOrLink = case gistID of
        NoGist ->
          mkClickButton
            "Save Gist"
            "Save code to GitHub Gist (requires OAuth login)"
            true -- close dropdown
            ( do
                -- Immediately show "saving" status
                putGistID SavingGist
                case ghToken of
                  Nothing -> do
                    log "need token - authorizing"
                    liftEffect $ ghAuthorize content
                  Just gh_token -> do
                    log "have token"
                    doSaveGist gh_token
            )
        SavingGist ->
          HH.div
            [ HP.classes menuTextClasses ]
            [ HH.text "Saving Gist ..." ]
        HaveGist (GistID id) ->
          HH.a
            [ HP.href $ "https://gist.github.com/" <> id
            , HP.target "_blank" -- Open in new tab
            , HP.classes menuTextClasses
            ]
            [ HH.text "View Gist" ]
    --
    -- Render
    HK.pure do
      HH.div [ HP.classes [ T.flex, T.flexCol, T.hScreen ] ]
        [ menu
        , HH.div
            [ HP.classes [ T.flexGrow, T.bgRed200 ]
            , HP.id_ "editor"
            ]
            []
        , HH.div
            [ HP.classes [ T.bgGreen200 ] ]
            [ HH.text $ "bottom: " <> show content ]
        ]
