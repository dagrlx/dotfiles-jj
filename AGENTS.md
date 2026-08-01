# Dotfiles (macOS M1)

Dotfiles gestionados con **jj** + **GNU Stow** + **mise** + **Homebrew (Brewfile)**.

## Stow

- Paquetes activos: `shell terminals cli editors mise brew`
- Desde la raíz del repo:  
  - `stow <package>` → crear/enlazar  
  - `stow -D <package>` → remover  
- Si modificas algo dentro de un paquete (ej. `shell/.zshrc`), **debes** re-stowearlo (`stow -R shell`) para que los cambios se reflejen en `$HOME`.

## jj (control de versiones)

- Usa siempre **jj** para versionar, no `git` directo.  
- Evita `jj describe` o `jj squash` sin confirmación.  
- Para sincronizar:  
  - `jj commit -m "mensaje"`  
  - `jj bookmark move main --to @-`  
  - `jj git push --bookmark main`

## mise + Brewfile

- `mise/.config/mise/config.toml` define herramientas y tareas de bootstrap.  
- Comandos útiles:  
  - `mise install <tool>@latest` — instalar herramientas puntuales (ej. `jj`, `stow`).  
  - `mise bootstrap --yes` — aplicar todas las herramientas declaradas en `mise.toml`.  
  - `mise run brewfile` — aplicar el Brewfile (`brew/.config/homebrew/Brewfile`).  
  - `mise run macos` — ejecutar tareas de configuración del sistema (ej. defaults, loginwindow).
  - `mise upgrade` — Actualiza todos los paquetes que gestiona mise

## Comportamiento del agente

- Pide confirmación antes de alterar archivos críticos del sistema.  
- Si no estás seguro de un flag de `jj` o `stow`, corre `--help` primero.  
- Sé conciso y responde corto.
