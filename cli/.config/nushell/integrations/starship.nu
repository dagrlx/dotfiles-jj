mkdir ($nu.default-config-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.default-config-dir | path join "vendor/autoload/starship.nu")
