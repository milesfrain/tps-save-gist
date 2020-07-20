{ name = "my-project"
, dependencies =
  [ "ace"
  , "console"
  , "css"
  , "effect"
  , "halogen"
  , "halogen-css"
  , "halogen-hooks"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
