# Completador para rutas zoxide
def "nu-complete zoxide path" [context: string] {
  let parts = $context | split row " " | skip 1
  {
    options: {
      sort: false,
      completion_algorithm: fuzzy,
      positional: true,
      case_sensitive: false,
    },
    completions: (
      zoxide query --list --exclude $env.PWD -- ...$parts
      | lines
      | each {|it| { value: $it description: "zoxide match" }}
    )
  }
}

# Comando cd con completador
def --env --wrapped cd [...rest: string@"nu-complete zoxide path"] {
  __zoxide_z ...$rest
}

# Comando cdi con completador interactivo
def --env --wrapped cdi [...rest: string@"nu-complete zoxide path"] {
  __zoxide_zi ...$rest
}
