function j
    set dir "$HOME/.dotfiles-jj/nix-darwin/.config/nix-darwin"
    if test -d "$dir"
        pushd "$dir" > /dev/null
        command just $argv
        popd > /dev/null
    else
        echo "Error: no se encontró el directorio $dir"
        return 1
    end
end
