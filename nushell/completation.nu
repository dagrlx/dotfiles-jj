
let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

let zoxide_completer = {|spans|
    let query = zoxide query --list --exclude $env.PWD -- ...$spans | lines
    if ($query | is-empty) {
        []
    } else {
        $query | each { |it| { value: $it } }
    }
}

let external_completer = {|spans|
    let alias_expansion = (
        scope aliases
        | where name == $spans.0
        | get -i 0.expansion
    )

    let command = if $alias_expansion != null {
        $alias_expansion | split row ' ' | get 0
    } else {
        $spans.0
    }

    let adjusted_spans = if $alias_expansion != null {
        $spans | skip 1 | prepend $command
    } else {
        $spans
    }

    match $command {
        z | zi | __zoxide_z | __zoxide_zi => $zoxide_completer
        _ => $carapace_completer
    } | do $in $adjusted_spans
}

# 🧩 Menú que muestra alias, comandos y zoxide
$env.config.menus ++= [
    {
        name: "smart_menu"
        only_buffer_difference: false
        marker: "👉 "
        type: {
            layout: columnar
            columns: 1
            col_width: 30
            col_padding: 2
        }
        style: {
            text: white
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, _|
            let alias_matches = scope aliases
                | where name =~ $buffer
                | each { |it| { value: $it.name description: $it.expansion } }

            let command_matches = which $buffer
                | get path
                | path basename
                | each { |cmd| { value: $cmd description: "command" } }
                | default []

            let zoxide_matches = (
                zoxide query --list --exclude $env.PWD | lines
                | where $it =~ $buffer
                | each { |it| { value: $it description: "zoxide" } }
            )

            $alias_matches ++ $command_matches ++ $zoxide_matches
        }
    }
]

# 🔑 Keybinding para activar el menú
$env.config.keybindings ++= [
    {
        name: "smart_menu"
        modifier: none
        keycode: tab
        mode: [emacs, vi_insert, vi_normal]
        event: [
            { send: menu name: "smart_menu" }
        ]
    }
]

# Configuración en $env.config
$env.config = {
    completions: {
        external: {
            enable: true
            completer: $external_completer
        }
    }
}

