# CatchErrors
## Overview
The "CatchErrors" plugin allows you to remotely catch lua errors in an application built on the Solar2D engine and send errors to Google Spreadsheets with user files attached.
## Project Settings
To use this plugin, add an entry into the plugins table of ***build.settings***.
```lua

settings = 
{
	android =
	{
		usesPermissions =
		{
			"android.permission.INTERNET",
			"android.permission.WRITE_EXTERNAL_STORAGE",
		},
	},

	plugins = {
		["plugin.catcherrors"] = { publisherId = "com.narkoz" },
	},
}
```
> For **Android**, when using this plugin, don't forget to add the following permissions/features:
> * "android.permission.INTERNET"
> * "android.permission.WRITE_EXTERNAL_STORAGE"
## Require
```lua
local catcherrors = require "plugin.catcherrors"
```
