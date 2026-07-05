# Dotfiles (macOS M1)

Dotfiles gestionados con **jj** + **GNU Stow** + **nix-darwin**.

## Stow

- Paquetes activos: `shell terminals cli editors`
- Desde la raíz del repo: `stow <package>` para crear/enlaces, `stow -D <package>` para remover
- Si modificas algo dentro de un paquete (ej. `shell/.zshrc`), **debes** re-stowearlo (`stow -R shell`) para que los cambios se reflejen en `$HOME`

## jj (control de versiones)

- NO uses `git` — usa `jj` siempre
- No hagas `jj describe` ni `jj squash` sin preguntar
- **No intentes sincronizar con remotos** (`jj git push`, `jj git remote`, etc.) — estrictamente local

## nix-darwin

- `nix-darwin/.config/nix-darwin/` tiene un flake Nix para paquetes y config del sistema
- Comandos útiles (desde ese directorio):
  - `just darwin` — aplicar configuración
  - `just darwin-debug` — aplicar con trazas
  - `just up` — `nix flake update`
  - `just gc` — recolector de basura
  - `just fmt` — formatear `.nix`

## Comportamiento del agente

- Pide confirmación antes de alterar archivos críticos del sistema
- Si no estás seguro de un flag de `jj` o `stow`, corre `--help` primero
- Sé conciso y responde corto
