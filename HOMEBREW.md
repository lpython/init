# Homebrew Setup

Homebrew package manager setup and package installation using Brewfiles.

*https://brew.sh/*

---

## Install Homebrew

Install Homebrew package manager for Linux.

```bash
#!/bin/sh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow post-install instructions to add Homebrew to PATH
# Typically add to ~/.zshrc or ~/.bashrc:
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

## Shell settings

```bash

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

## Install Shared Packages

Install packages common across all machines.

```bash
#!/bin/sh

brew bundle install --file=init/brew/Brewfile.shared
```

**Included packages:**
- helix - modern text editor

## Install Zephyrus Packages

Install Asus Zephyrus laptop-specific packages.

```bash
#!/bin/sh

brew bundle install --file=init/brew/Brewfile.zephyrus
```



### Export Current Installation

Generate a Brewfile from currently installed packages.

```bash
#!/bin/sh

# Export to current directory
brew bundle dump --force

# Or export to specific location
# brew bundle dump --file=init/brew/Brewfile.backup --force
```

---

## Brewfile Management

### Location of Brewfiles

- `init/brew/Brewfile.shared` - Packages for all machines
- `init/brew/Brewfile.desktop` - Desktop/GUI applications
- `init/brew/Brewfile.zephyrus` - Laptop-specific packages

### Adding New Packages

Edit the appropriate Brewfile and add:

```ruby
# For CLI tools
brew "package-name"

# For GUI applications (casks)
cask "application-name"

# For fonts
cask "font-name"

# For taps (third-party repositories)
tap "user/repo"
```

Then install with:
```bash
brew bundle install --file=init/brew/Brewfile.shared
```

### Brewfile Syntax

```ruby
# Taps (third-party repositories)
tap "homebrew/cask-fonts"

# Formulae (CLI packages)
brew "git"
brew "neovim", args: ["HEAD"]

# Casks (GUI applications)
cask "visual-studio-code"
cask "wezterm"

# Mac App Store apps (macOS only)
mas "Xcode", id: 497799835
```

---

## Notes

- **First time setup:** Run tasks in order (Install Homebrew → Install Shared → Install Desktop)
- **Adding packages:** Edit the Brewfiles directly, don't use this markdown
- **Syncing machines:** Commit Brewfiles to git and pull on other machines
- **Removing packages:** Delete from Brewfile and run `brew bundle cleanup --file=...`
