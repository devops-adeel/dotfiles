# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io) and 1Password CLI.

## Installation

```bash
chezmoi init --apply https://github.com/devops-adeel/dotfiles.git
```

## Requirements

- [chezmoi](https://www.chezmoi.io/install/)
- [1Password CLI](https://developer.1password.com/docs/cli/get-started#install)
## Plain configs (symlinked, no chezmoi)

Files under `.config/` are the live configs, symlinked into place:

```bash
ln -s ~/Developer/dotfiles/.config/cmux/cmux.json ~/.config/cmux/cmux.json
ln -s ~/Developer/dotfiles/.config/ghostty/config ~/.config/ghostty/config
```

cmux reads both (`cmux reload-config` after edits; `cmux config check` to validate).
