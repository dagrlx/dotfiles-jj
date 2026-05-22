#!/bin/zsh -l -i

echo "Select your shell:"
echo "1) Zsh (stay here)"
echo "2) Fish (inherit from Zsh)"
echo "3) Nushell (inherit from Zsh)"
read "choice?Enter choice [1-3]: "

case $choice in
    1)
        exec zsh -l -i
        ;;
    2)
        exec fish -l
        ;;
    3)
        exec nu -l
        ;;
    *)
        echo "Invalid choice, defaulting to Zsh"
        exec zsh -l -i
        ;;
esac

