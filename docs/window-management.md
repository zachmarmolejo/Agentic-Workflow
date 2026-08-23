# Window management

Hammerspoon and PaperWM provide an Omarchy-like, horizontally scrolling window layout on macOS.

PaperWM tiles normal windows into columns that can extend beyond the visible screen.
Changing focus pans the strip, and three-finger horizontal swipes pan it directly.
Moving the pointer over a window focuses it.

## macOS settings

In **System Settings > Desktop & Dock > Mission Control**:

- Turn off **Automatically rearrange Spaces based on most recent use**.
- Turn on **Displays have separate Spaces**.

Log out and back in if **Displays have separate Spaces** was previously disabled.
The installer disables macOS's native horizontal Space-switching gestures and three-finger drag so PaperWM can use three-finger horizontal movement for panning.
It also disables Finder's `Command+Option+Space` search shortcut so Hammerspoon's keybinding reference keeps focus.
Use the numbered keyboard shortcuts below to switch Spaces.

Hammerspoon maintains at least four desktop Spaces whenever its configuration loads.
Mission Control will appear briefly while it does this.

Hammerspoon also needs permission under **System Settings > Privacy & Security > Accessibility**.
It does not require disabling System Integrity Protection.

## Keybindings

The table uses the literal macOS keys configured in Hammerspoon.

| Key | Action |
| --- | --- |
| `Command+Option+Return` | Open a new WezTerm shell window |
| `Command+Option+Shift+Return` | Open a new window in the default browser |
| `Command+Option+Arrow` | Focus and pan to the window in that direction |
| `Command+Option+Shift+Arrow` | Swap the focused window in that direction |
| `Command+Option+Control+Arrow` | Swap the focused window in that direction (macOS alias) |
| `Command+Option+J` | Cycle to the next window, wrapping at the end |
| `Command+Option+Shift+J` | Cycle to the previous window, wrapping at the start |
| `Command+Option+-/=` | Decrease or increase window width |
| `Command+Option+Shift+-/=` | Decrease or increase window height |
| `Command+Option+I/O` | Stack into or remove from the column on the left |
| `Command+Option+T` | Toggle floating |
| `Command+Option+F` | Toggle full width |
| `Command+Option+C` | Center the focused window |
| `Command+Option+1-4` | Switch Space |
| `Command+Option+Shift+1-4` | Move the focused window to a Space |
| `Command+Option+Control+Shift+1-4` | Move the focused window to a Space without following it |
| `Command+Option+,/.` | Switch to the previous or next Space |
| `Command+Option+Control+Tab` | Return to the formerly active Space |
| `Command+Option+Shift+R` | Refresh PaperWM's window state |
| `Command+Option+Control+Shift+R` | Force-refresh and retile all windows |
| `Command+Option+scroll` | Pan the window strip |
| Three-finger horizontal swipe | Pan the window strip |
| `Command+Option+Space` | Open the searchable keybinding reference |
| `Command+Option+K` | Open the searchable keybinding reference |

Hold `Command+Option` while dragging to pan the strip.
Hold `Command+Option+Shift` while dragging a window to lift and reposition it.
Selecting an exact command in the searchable keybinding reference runs that command.

## Maintenance

The PaperWM upstream revision is pinned in `setup/hammerspoon.sh`.
Update that commit deliberately after testing new PaperWM releases.
