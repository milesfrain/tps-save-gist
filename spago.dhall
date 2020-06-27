{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "ace"
  , "affjax"
  , "argonaut"
  , "console"
  , "css"
  , "effect"
  , "halogen"
  , "halogen-css"
  , "halogen-hooks"
  , "halogen-hooks-extra"
  , "psci-support"
  , "routing"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
