-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 14
config.font = wezterm.font 'Iosevka'
config.color_scheme = 'AdventureTime'

config.keys = {-- This will create a new split and run your default program inside it
  {
    key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}
  },  
  {
    key = "j",
    mods = 'SUPER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = "h",
    mods = 'SUPER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  }, 
  {
    key = 'PageUp',
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        -- Alt screen is active (helix, vim, etc.) - send key to the application
        window:perform_action(wezterm.action.SendKey { key = 'PageUp' }, pane)
      else
        -- Normal terminal - use for scrolling
        window:perform_action(wezterm.action.ScrollByPage(-1), pane)
      end
    end),
  },
  {
    key = 'PageDown',
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      if pane:is_alt_screen_active() then
        -- Alt screen is active - send key to the application
        window:perform_action(wezterm.action.SendKey { key = 'PageDown' }, pane)
      else
        -- Normal terminal - use for scrolling
        window:perform_action(wezterm.action.ScrollByPage(1), pane)
      end
    end),
  },
  {
    key = 'n',
    mods = 'SUPER',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain'
  },
  {
    key = 'm',
    mods = 'SUPER',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain'
  }
}


-- Finally, return the configuration to wezterm:
return config


