#!/bin/zsh -l -i

echo "Select your shell:"
echo "1) Zsh (stay here)"
echo "2) Fish (inherit from Zsh)"
echo "3) Nushell (inherit from Zsh)"
read "choice?Enter choice [1-3]: "

case $choice in
    1)
        # Ya estás en Zsh, no hay que cambiar $SHELL
        exec zsh -l -i
        ;;
    2)
        # Buscamos la ruta real de fish y la exportamos
        export SHELL=$(which fish)
        exec fish -l
        ;;
    3)
        # Buscamos la ruta real de nu (Nushell) y la exportamos
        export SHELL=$(which nu)
        exec nu -l
        ;;
    *)
        echo "Invalid choice, defaulting to Zsh"
        exec zsh -l -i
        ;;
esac
