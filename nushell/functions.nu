# alias la =  ls -la | select name type mode user group size modified | update modified {format date "%Y-%m-%d %H:%M:%S"}
# def la [] {
#     ls -la | select name type mode user group size modified | update modified {format date "%Y-%m-%d %H:%M:%S"}
# }

# def fzn [] {
#     fzf --preview '''bat --style=numbers --color=always {}''' | xargs -n1 nvim
# }

# list applications in Aerospace for selection
# def ff [] {
#     aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
# }

# # Para controladoras
# def sshtp [host] {
#     let TERM = "xterm-256color";
#     ^ssh -o ProxyJump=sabaext $host
# }
#
# # Para equipos que no tienen xterm-ghostty
# def ssht [host] {
#     let TERM = "xterm-256color";
#     ^ssh $host
# }

# Shell wrapper for yazi file managet
def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

# Update brew and widget brew in sketchybar --
# https://www.nushell.sh/book/custom_commands.html#rest-parameters-with-wrapped-external-commands
# If you want to pass arguments without Nushell trying to parse them as flags or options,
# use --wrapped so the parameters will be passed as raw strings.
def --wrapped brew-nu [...args: string] {
    ^brew ...$args

    if ($args | any { |arg| $arg in ["outdated", "upgrade", "update"] }) {
        sketchybar --trigger brew_update
    }
}

# Mata tmux server y luego ejecuta tmux
# def tmux-nu [] {
#   tmux kill-server | complete;
#   if (tmux | complete | is-not-ok) {
#     tmux
#   }
# }


# Tranforma Lb txt en csv
def parking-lb [archivo: path] {
    # Verificar si el archivo existe
    if not ( $archivo | path exists ) {
        print "Error: El archivo no existe en la ruta especificada: $archivo"
        return []
    }

    open $archivo
    | lines
    | skip 1
    | drop
    | par-each { |line|
        {
            tipo_registro: ($line | str substring 0..0),
            fecha: ($line | str substring 1..8),
            patente: ($line | str substring 9..14),
            tag: ($line | str substring 18..34),
            cit: ($line | str substring 36..51),
            cto: ($line | str substring 52..)
        }
    }

    # if $csv {
    #     $datos | to csv -p $csv
    # } else {
    #     $datos
    # }
}


