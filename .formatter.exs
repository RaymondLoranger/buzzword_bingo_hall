# Used by "mix format"
wildcard = fn glob -> Path.wildcard(glob, match_dot: true) end
matches = fn globs -> Enum.flat_map(globs, &wildcard.(&1)) end

# except = ["config/config.exs"]
except = []
inputs = ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"]

[
  import_deps: [:phoenix, :phx_formatter],
  inputs: matches.(inputs) -- matches.(except),
  line_length: 80
]
