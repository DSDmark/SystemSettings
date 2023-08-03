# ====================================== custom code ================================================
# nvim env
export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/home/dsdmark/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# starship 
eval "$(starship init bash)"

# user bash shortcut file
source ~/bashCommands/main.sh

