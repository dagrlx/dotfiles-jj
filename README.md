# Dotfiles

Managed with:

- jj (Jujutsu git)
- Mise
- Brew file (Homebrew)

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

mise install jujutsu@latest 

jj git clone https://github.com/dagrlx/dotfiles-jj.git ~/.dotfiles-jj

mise bootstrap --yes
```
