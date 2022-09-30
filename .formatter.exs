# Used by "mix format"

[
  import_deps: [:protobuf],
  inputs:
    Enum.flat_map(
      ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
      &Path.wildcard(&1, match_dot: true)
    ) --
      Enum.flat_map(
        ["{config,lib,test}/**/*.pb*ex"],
        &Path.wildcard(&1, match_dot: true)
      )
]
