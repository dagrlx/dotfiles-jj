
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
# >>> llmtrim >>>
export HTTPS_PROXY="http://127.0.0.1:43117"
export HTTP_PROXY="http://127.0.0.1:43117"
export NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16,fd00::/8,*.local"
export no_proxy="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16,fd00::/8,*.local"
export NODE_EXTRA_CA_CERTS="/Users/dgarciar/.llmtrim/ca.pem"
# <<< llmtrim <<<
