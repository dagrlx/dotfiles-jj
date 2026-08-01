# Dotfiles

Managed with:

- jj (Jujutsu git)
- GNU Stow
- mise
- Brew file

## Structure

- shell
- terminals
- cli
- editors
- archive
- nvim
- mise
- brew

## Setup

```bash
curl https://mise.run | sh

mise install stow@latest
mise install jujutsu@latest 

jj git clone https://github.com/dagrlx/dotfiles-jj.git ~/.dotfiles-jj
cd ~/.dotfiles-jj

stow -R shell terminals cli editors archive nvim mise brew

mise bootstrap --yes
```
