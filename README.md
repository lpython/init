# Pop!_OS Development Environment Setup

Executable setup documentation using [mx](https://github.com/harehare/mx) - run tasks individually or all at once.

## List all tasks
```bash
mx
```

## Run a specific task
```bash
mx "Task Name"
```

---

## Environment Setup

Setup basic environment variables and directories.

```bash
#!/bin/sh

mkdir -p ~/bin
export DOWNLOADS=~/Downloads
export PATH="$HOME/bin:$PATH"
```

## Base APT Packages

Install essential build tools and base packages.

```bash
#!/bin/sh

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y build-essential curl file git clang pkg-config libssl-dev btop curl jq

echo "Base packages installed. Reset shell for changes to take effect."
```

## CLI Tools

Install essential command-line utilities.

```bash
#!/bin/sh

sudo apt-get install fd-find -y
sudo apt-get install tealdeer -y
tldr --update


```


This is removed for now, fzf goes to brew
```txt
# Add fzf shell integration to rc_patch.sh
cat >> init/rc_patch.sh << 'EOF'

# fzf shell integration
source <(fzf --zsh)
EOF

echo "Added fzf config to init/rc_patch.sh"

```


## IO Utilities

Install disk monitoring and benchmarking tools.

```bash
#!/bin/sh

sudo apt-get install smartmontools -y

# Example usage:
# lsblk
# sudo smartctl -a /dev/nvme0n1

sudo apt-get install fio -y

# Example fio commands:
# Sequential read test:
# sudo fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=1M --numjobs=1 --size=4G --runtime=60 --group_reporting --filename=/dev/nvme0n1
#
# Random read test:
# sudo fio --name=randread --rw=randread --direct=1 --ioengine=libaio --bs=4k --numjobs=4 --size=1G --runtime=60 --group_reporting --filename=/dev/nvme0n1
```



## Rust Toolchain

Install Rustup and Rust toolchain.

*https://rustup.rs/*

```bash
#!/bin/sh

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add $HOME/.cargo/bin to PATH
# Add to your .zshrc or .bashrc:
# export PATH="$HOME/.cargo/bin:$PATH"
```

## Fast Node Manager

Install fnm (Fast Node Manager) for managing Node.js versions.

*https://github.com/Schniz/fnm*

```bash
#!/bin/sh

curl -fsSL https://fnm.vercel.app/install | bash

# Add to your shell config (.zshrc or .bashrc):
# eval "$(fnm env --use-on-cd)"
```
## Zsh 

```bash
sudo apt install zsh -y
chsh -s $(which zsh)
```

## Oh My Zsh

Install Oh My Zsh framework for managing Zsh configuration.

*https://github.com/ohmyzsh/ohmyzsh/*

**Prerequisites:** Install Zsh first with `sudo apt install zsh` and set as default shell with `chsh -s $(which zsh)`

```bash
#!/bin/sh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Brave Browser

Install Brave web browser.

*https://brave.com/*

```bash
#!/bin/sh

curl -fsS https://dl.brave.com/install.sh | sh
```

## Visual Studio Code

Install Visual Studio Code editor.

*https://code.visualstudio.com/*

```bash
#!/bin/sh

curl -fSL -o /tmp/vscode.deb 'https://update.code.visualstudio.com/latest/linux-deb-x64/stable'
sudo dpkg -i /tmp/vscode.deb
sudo apt-get install -f -y  # Fix any dependencies

# Turn on sync and replace local config with uploaded one
```

## Helix Editor

Install Helix text editor via Homebrew.

*https://helix-editor.com/*

**Prerequisites:** Requires Homebrew to be installed first.

```bash
#!/bin/sh

brew install helix
```

## Iosevka Font

Install Iosevka font family from latest GitHub release.

*https://github.com/be5invis/Iosevka*

**Prerequisites:** Requires `jq` - install with `sudo apt install jq`

```bash
#!/bin/sh
set -e

D=$(pwd)
cd ~/Downloads

mkdir -p iosevka
cd iosevka

# Fetch all TTC packages from latest release
curl -s https://api.github.com/repos/be5invis/Iosevka/releases/latest \
  | jq -r '.assets[] | .browser_download_url' \
  | grep 'PkgTTC-Iosevka' \
  | xargs -n 1 curl -L --fail --silent --show-error -O

cd ..

# Move into system fonts dir
sudo mkdir -p /usr/share/fonts/truetype
sudo mv iosevka /usr/share/fonts/truetype/

# Rebuild font cache
fc-cache -fv

cd "$D"

echo "Iosevka fonts installed successfully"
```

## WezTerm Terminal

Install WezTerm terminal emulator.

*https://wezfurlong.org/wezterm/*

```bash
#!/bin/sh

curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
sudo apt update
sudo apt install wezterm -y

cp ./config/.wezterm.lua  ~/.wezterm.lua 
```

## Pet Snippet Manager

Install pet command-line snippet manager.

*https://github.com/knqyf263/pet*

**Prerequisites:** Requires `jq` - install with `sudo apt install jq`

```bash
#!/bin/sh

cd /tmp

# Download latest release
curl -s https://api.github.com/repos/knqyf263/pet/releases/latest \
  | jq -r '.assets[] | select(.name | test("amd64\\.deb$")) | .browser_download_url' \
  | xargs -r -n 1 curl -L --fail --silent --show-error -O

# Install
sudo dpkg -i pet_*_amd64.deb

# Cleanup
rm pet_*_amd64.deb

echo "Pet installed successfully"
```

## GNOME Keybinding Cleanup

Clear GNOME Super key conflicts with dash-to-dock extension.

*Removes Super+1-9 application shortcuts to allow custom workspace switching*

```bash
#!/bin/sh

# Disable dash-to-dock hot keys
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false

# Clear Super+1-9 application shortcuts
for i in $(seq 1 9); do
    gsettings set org.gnome.shell.keybindings switch-to-application-${i} '[]'
done

echo "GNOME keybindings cleaned up"
```

---

## Shell Configuration (rc_patch.sh)

Many installation tasks add configuration to `init/rc_patch.sh` instead of directly modifying your `.zshrc` or `.bashrc`. This gives you control over what gets added to your shell.

### How it works:

1. **Setup tasks append to rc_patch.sh** - As you run tasks (like "CLI Tools"), they add their shell configuration to `init/rc_patch.sh`
2. **Review the file** - Check what's been added: `cat init/rc_patch.sh`
3. **Source it in your shell config** - Add to your `.zshrc` or `.bashrc`:

```bash
# Source init/rc_patch.sh if it exists
[ -f "$HOME/repos/init_workspace/init/rc_patch.sh" ] && source "$HOME/repos/init_workspace/init/rc_patch.sh"
```

### Pattern for appending to rc_patch.sh:

Any task that needs shell configuration uses this pattern:

```bash
# Add configuration to rc_patch.sh
cat >> init/rc_patch.sh << 'EOF'

# Your config here
export PATH="$HOME/bin:$PATH"
EOF

echo "Added config to init/rc_patch.sh"
```

**Note:** `rc_patch.sh` is gitignored - it's generated locally and specific to your machine.

---

## Additional Configuration

After running the setup tasks, consider:

- Configure Git with your credentials:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```

- Install Zsh plugins (autosuggestions, syntax highlighting):
  ```bash
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  ```

- Setup SSH keys:
  ```bash
  ssh-keygen -t ed25519 -C "your.email@example.com"
  ```

## Notes

- Some tasks depend on others (e.g., Helix requires Homebrew)
- Run tasks in order for best results
- Some installers may require user interaction
- Review and customize each script before running
- After running tasks, review `init/rc_patch.sh` and source it in your shell config
