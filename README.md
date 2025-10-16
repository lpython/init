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

# Decompress all downloaded zip files using ouch (or fallback to unzip)
if command -v ouch &> /dev/null; then
  for file in *.zip; do
    [ -f "$file" ] && ouch decompress "$file"
  done
else
  unzip -o '*.zip'
fi

# Remove zip files to clean up
rm -f *.zip

cd ..

# Move into system fonts dir
sudo mkdir -p /usr/share/fonts/truetype
sudo mv iosevka /usr/share/fonts/truetype/

# Rebuild font cache
fc-cache -fv

cd "$D"

echo "Iosevka fonts installed successfully"
```

---

```
# Decompress all downloaded zip files using ouch (or fallback to unzip)
if type -q ouch
  # 'type -q' is the idiomatic way to check for a command's existence
  # Fish's glob expansion expands to an empty list if no files match (like nullglob)
  for file in *.zip
    # The 'test' command checks file attributes, and '-f' is for regular file
    # 'test -f $file' returns a 0 exit status (success) if true
    if test -f "$file"
      ouch decompress "$file"
    end
  end
else
  unzip -o '*.zip'
end
```


```
# Decompress all downloaded zip files using ouch (or fallback to unzip)
if (which ouch | is-empty | not) {
  # 'which ouch' outputs a table/list if found, or nothing if not.
  # '| is-empty | not' checks if the output is NOT empty, meaning 'ouch' exists.
  
  # 'glob' finds the files and outputs them as a list of path records.
  # 'each' iterates over the list, similar to a 'for' loop.
  glob '*.zip' | each {|file|
    # '$file.name' gives the path string from the glob record.
    # 'path type' returns a type string, e.g., "file", "dir", "symlink".
    # We check if the type is exactly "file" (regular file).
    if ($file.name | path type) == "file" {
      # The Nushell call to an external command uses the ^ prefix.
      ^ouch decompress $file.name
    }
  }
} else {
  # If 'ouch' is not found, run the external 'unzip' command directly.
  ^unzip -o '*.zip'
}
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

## Shell Integrations

For managing shell integrations (fzf, zoxide, starship, etc.) across bash and zsh, see:

**[SHELL_INTEGRATIONS.md](SHELL_INTEGRATIONS.md)** - Cross-shell integrations for bash/zsh

This generates `~/.shell_integrations.sh` with automatic shell detection that works on both Linux and macOS.

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
