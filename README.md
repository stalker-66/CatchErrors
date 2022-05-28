# CatchErrors
## Overview
The "CatchErrors" plugin allows you to remotely catch lua errors in an application built on the Solar2D engine and send errors to Google Spreadsheets with user files attached.
## Project Settings
To use this plugin, add an entry into the plugins table of ***build.settings***.
```lua
settings = 
{
	android = {
		usesPermissions = {
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
## Functions
> Initializes the **catcherrors** plugin. This call is required and must be executed before making other **catcherrors** calls.
> ```lua
> catcherrors.init(params)
> ```
> The ***params*** table includes parameters for **catcherrors** initialization. <br/>
> * **deploymentID** (required) <br/>
> `String`. Your Deployment ID. See more - [How to get Deployment ID](https://github.com/stalker-66/RealTimeLog/blob/87fbaddbe90e5688e710bcd2040e7bfd80627f17/Docs/How%20to%20get%20Deployment%20ID.md). <br/>
> * **fileList** (optional) <br/>
> `Table`. List of files to upload with the error message. Default is `nil`. <br/> <br/>
> By default, the file `log.catcherrors` will be sent, which contains all the ***print*** of the user. The `fileList` must include tables with parameters: ***filename*** and ***baseDir***. <br/>
> `Example:` <br/>
> 	```lua
> 	fileList = {
> 		{ filename = "myFile1.txt", baseDir = system.ResourceDirectory },
> 		{ filename = "myFile2.png", baseDir = system.DocumentsDirectory },
> 	}
> 	```
> 	The file size directly affects the speed of sending errors. <br/>
> 	If you plan to upload files from ***system.ResourceDirectory***, be aware of Android limitations. See more - [system.ResourceDirectory](https://docs.coronalabs.com/api/library/system/ResourceDirectory.html). <br/> <br/>
> * **sendFiles** (optional) <br/>
> `String`. Specifies when to send files. Default is `All`. <br/> <br/>
> Supported values: <br/>
> `All` - Sending files after ***Warning*** and ***Crash*** errors. <br/>
> `Warning` - Sending files after ***Warning*** errors. <br/>
> `Crash` - Sending files after ***Crash*** errors. <br/> <br/>
> * **delaySend** (optional) <br/>
> `Boolean`. Forward errors and files to the next session. Default is `false`. <br/>
> Use this feature if you doubt that all files will be sent before the application closes. <br/>
> * **useErrorMessage** (optional) <br/>
> `Boolean`. Enable/Disable error message. Default is `true`. <br/>
> Only works for ***Crash*** errors. <br/>
> * **languageErrorMessage** (optional) <br/>
> `String`. The active language of the error message. Default is `Auto`. <br/> <br/>
> Supported values: <br/>
> `Auto` - The language will be selected automatically depending on the language of the device. By default, the plugin only supports 2 languages: *Russian* and *English*. If the desired localization is not found, *English* will be selected by default. For *Belarusians* and *Ukrainians*, *Russian* will be selected by default. <br/>
> `two-letter` - Two language letters for ***ISO 639-1*** format. The localization must be present in the **listErrorMessage** table. The default values supported are: `en`, `ru`. <br/> <br/>
> * **listErrorMessage** (optional) <br/>
> `Table`. Custom table to localize the error message. Default is `nil`. <br/> <br/>
> You can add your own localization for error messages. Your localization will be added to the plugin default localization. <br/>
>	`Example:` <br/>
> 	```lua
>	listErrorMessage = {
>		es = {
>			title = "¡Ups!",
>			desc = "¡Algo salió mal! Nuestros expertos ya están lidiando con este problema. Pedimos disculpas por las molestias, la aplicación se cerrará.",
>			button = "OK",
>		}
>	},
> 	```
> 	After the plugin is initialized, your message localization table will look like this: <br/>
> 	```lua
> 	listErrorMessage = {
> 		en = {
>			title = "Oops!",
>			desc = "Something went wrong! Our experts are already dealing with this problem. We apologize for the inconvenience, the application will be closed.",
>			button = "OK",
>		},
>		ru = {
>			title = "Ошибка!",
>			desc = "Что-то пошло не так! Наши специалисты уже занимаються решением данной проблемы. Просим прощения за неудобства, приложение будет закрыто.",
>			button = "ОК",
>		},
>		es = {
>			title = "¡Ups!",
>			desc = "¡Algo salió mal! Nuestros expertos ya están lidiando con este problema. Pedimos disculpas por las molestias, la aplicación se cerrará.",
>			button = "OK",
>		},
>	},
> 	```
> * **debug** (optional) <br/>
> `Boolean`. Includes additional debugging information for the plugin. Default is `false`. <br/>

> Calling this function clears the log.
> ```lua
> realtimelog.clear()
> ```

> Plugin stop. After calling this function, initialization is required to work with the plugin.
> ```lua
> realtimelog.stop()
> ```
## Usage
> The **realtimelog** plugin modifies the standard ***print*** function. You must use ***print*** in your app. The printout will be sent to the ***console*** and your ***Spreadsheet***. <br/>
> `Example:` <br/>
> ```lua
> print( "My Test Print" )
> ```
> `Output:` <br/>
> **Corona Simulator Console:** <br/>
> ![Make a copy](https://github.com/stalker-66/RealTimeLog/blob/20b18143cffcd82e2599e3c6f2ad99c2998b466d/Docs/res/16.png?raw=true)
> **You Spreadsheet:** <br/>
> ![Make a copy](https://github.com/stalker-66/RealTimeLog/blob/20b18143cffcd82e2599e3c6f2ad99c2998b466d/Docs/res/17.png?raw=true)

> The **realtimelog** plugin supports **3 types of messages**:
> * **Info** - standard message on a white background. Default for `all messages`.
> * **Warning** - message on a yellow background.
> * **Error** - message on a red background.
> 
> To specify the message type you need to use the `"@type=YOU_TYPE@"` modifier. Where **YOU_TYPE** is the name of the message type.  <br/>
> `Example:` <br/>
> ```lua
> print( "@type=Info@My message about Info" )
> print( "@type=Warning@My message about Warning" )
> print( "@type=Error@My message about Error" )
> ```
> `Output:` <br/>
> **Corona Simulator Console:** <br/>
> ![Make a copy](https://github.com/stalker-66/RealTimeLog/blob/765803458b09547daceb45a6a604536e399687e3/Docs/res/18.png?raw=true)
> **You Spreadsheet:** <br/>
> ![Make a copy](https://github.com/stalker-66/RealTimeLog/blob/765803458b09547daceb45a6a604536e399687e3/Docs/res/19.png?raw=true)
## Extras
> The ***print*** function now supports output lua tables. <br/>
> `Example:` <br/>
> ```lua
> local items = {
> 	{ id = "orange", count = 2, quality = "legend" },
> 	{ id = "banana", count = 8, quality = "legend" },
> 	{ id = "coconut", count = 14, quality = "legend" },
> }
> print( items )
> ```
> `Output:` <br/>
> ```json
>   [{
>     "id":"orange",
>     "count":2,
>     "quality":"legend"
>   },{
>     "id":"banana",
>     "count":8,
>     "quality":"legend"
>   },{
>     "id":"coconut",
>     "count":14,
>     "quality":"legend"
>   }]
> ```
## Example
See more - [Solar2DExample](https://github.com/stalker-66/CatchErrors/tree/main/Solar2DExample)
## Support
stalker66.production@gmail.com
