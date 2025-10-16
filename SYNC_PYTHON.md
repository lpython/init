# Config Sync Tool Specification

A Python script to manage dotfiles/configuration synchronization between a repository and the local filesystem.

## Overview

Replace this basic bash pattern:
```bash
cp ./config/.wezterm.lua ~/
cp ./sh/zsh/alias.zsh ~/.oh-my-zsh/custom/
```

With a Python tool that provides safe, bidirectional sync with conflict detection.

---

## Config File Format

**File:** `config/sync_map.txt`

**Format:**
- Each path on its own line
- 2 or 3 paths form a connection (separated by blank lines)
- Comments start with `#`
- Blank lines separate path groups

**Example:**
```
# WezTerm configuration
config/.wezterm.lua
~/.wezterm.lua

# Zsh aliases
sh/zsh/alias.zsh
~/.oh-my-zsh/custom/alias.zsh

# Zsh shortcuts with optional 3rd path
sh/zsh/shortcuts.zsh
~/.oh-my-zsh/custom/shortcuts.zsh
/backup/shortcuts.zsh

# Ubuntu-specific zshrc
sh/zsh/.zshrc.ubuntu
~/.zshrc
```

**Rules:**
- Lines starting with `#` are comments (attached to next path group)
- Empty lines separate path groups
- First path = repo path (relative to repo root)
- Second path = local filesystem path (supports `~` expansion)
- Third path = optional additional path

---

## Data Structure

### FileConnection Dataclass

```python
from dataclasses import dataclass
from pathlib import Path

@dataclass
class FileConnection:
    """Represents a connection between repo file and local filesystem file(s)"""
    comment: str | None        # Optional comment from line above
    repo_path: Path            # Source path in repository
    local_path: Path           # Destination path on filesystem
    third_path: Path | None    # Optional third path
```

### Parser Function

```python
def parse_sync_map(sync_map_path: Path) -> list[FileConnection]:
    """
    Parse sync_map.txt and return list of FileConnection objects.

    Returns:
        List of FileConnection dataclasses
    """
    pass
```

---

## Subcommands

### `init`

**Purpose:** Initialize local filesystem from repo (one-way copy)

**Behavior:**
- Copy files from `repo_path` → `local_path`
- Skip if destination file already exists (safe mode)
- Also copy to `third_path` if specified
- Print what was copied and what was skipped

**Example:**
```bash
python sync.py init
```

**Output:**
```
✓ Copied: config/.wezterm.lua → ~/.wezterm.lua
⊘ Skipped: sh/zsh/alias.zsh → ~/.oh-my-zsh/custom/alias.zsh (already exists)
✓ Copied: sh/zsh/shortcuts.zsh → ~/.oh-my-zsh/custom/shortcuts.zsh
```

---

### `diff`

**Purpose:** Show differences between repo and local files

**Behavior:**
- Compare `repo_path` vs `local_path` content
- Use Python's `difflib` for unified diff output
- Show which files are only on one side
- Exit code 0 if identical, 1 if differences found

**Example:**
```bash
python sync.py diff
```

**Output:**
```
Comparing: config/.wezterm.lua ↔ ~/.wezterm.lua
--- repo: config/.wezterm.lua
+++ local: /home/alex/.wezterm.lua
@@ -14,7 +14,7 @@
 config.font_size = 14
-config.font = wezterm.font 'Iosevka'
+config.font = wezterm.font 'JetBrains Mono'

================================================================================

No difference: sh/zsh/alias.zsh ↔ ~/.oh-my-zsh/custom/alias.zsh
```

---

### `sync`

**Purpose:** Bidirectional sync with strict safety constraints

**Behavior:**
- Compare files in both directions
- **Abort if ANY deletions detected** (file exists one side, missing on other)
- **Abort if changes are bidirectional** (both files modified differently)
- **Only proceed if:**
  - Changes are unidirectional (only additions/modifications in one direction)
  - No files were deleted on either side

**Safety Checks:**
1. Check if files exist on both sides
2. Compare file content (via hash)
3. Determine direction of changes:
   - Repo → Local only
   - Local → Repo only
   - Both modified (CONFLICT - abort)
   - File missing on one side (DELETION - abort)

**Example:**
```bash
python sync.py sync
```

**Success case:**
```
Analyzing changes...
✓ repo → local: config/.wezterm.lua (modified in repo only)
✓ No deletions detected
✓ Changes are unidirectional

Syncing 1 file(s)...
✓ Synced: config/.wezterm.lua → ~/.wezterm.lua
```

**Conflict case:**
```
Analyzing changes...
✗ CONFLICT: sh/zsh/alias.zsh modified on both sides
✗ Aborting sync - resolve conflicts manually

Repo changes:
  - Added alias 'gst'

Local changes:
  - Added alias 'gl'
```

**Deletion case:**
```
Analyzing changes...
✗ DELETION detected: config/.wezterm.lua exists in repo but missing locally
✗ Aborting sync - deletions not allowed in sync mode

Use 'init' to restore deleted files or resolve manually.
```

---

## Implementation Requirements

### Python Standard Library Only
- `argparse` - CLI argument parsing
- `pathlib` - Path handling
- `difflib` - File comparison and diff output
- `hashlib` - File content hashing for change detection
- `dataclasses` - FileConnection structure

### File Comparison Strategy
```python
def file_hash(path: Path) -> str:
    """Return SHA256 hash of file content"""
    return hashlib.sha256(path.read_bytes()).hexdigest()

def files_identical(path1: Path, path2: Path) -> bool:
    """Check if two files have identical content"""
    return file_hash(path1) == file_hash(path2)
```

### Change Detection
```python
@dataclass
class SyncStatus:
    """Status of a file pair"""
    exists_in_repo: bool
    exists_locally: bool
    repo_hash: str | None
    local_hash: str | None

    def is_identical(self) -> bool:
        return self.repo_hash == self.local_hash

    def is_deletion(self) -> bool:
        return (self.exists_in_repo != self.exists_locally)

    def is_modified_both(self) -> bool:
        return (self.exists_in_repo and self.exists_locally and
                not self.is_identical())
```

---

## CLI Interface (Simple)

```bash
# Initialize local files from repo
python sync.py init

# Show differences
python sync.py diff

# Sync with safety constraints
python sync.py sync
```

---

## Example sync_map.txt

```
# WezTerm terminal configuration
config/.wezterm.lua
~/.wezterm.lua

# Zsh custom aliases
sh/zsh/alias.zsh
~/.oh-my-zsh/custom/alias.zsh

# Zsh keyboard shortcuts
sh/zsh/shortcuts.zsh
~/.oh-my-zsh/custom/shortcuts.zsh

# Ubuntu-specific zshrc
sh/zsh/.zshrc.ubuntu
~/.zshrc

# Pet snippet tool config
config/pet/snippet.toml
~/.config/pet/snippet.toml
```

---

## Error Handling

- Missing `sync_map.txt` → clear error message
- Invalid path format → show line number and error
- Permission denied → show which file and reason
- Broken symlinks → warn and skip

---

## Future Enhancements (Not in MVP)

- Backup before overwrite
- Interactive conflict resolution
- Partial sync (filter by pattern)
- Verbose/quiet modes
- Dry-run flag
