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

Disable show runtime errors in ***config.lua***.
```lua
application =
{
	showRuntimeErrors = false,
}
```

You can enable extended debug information for your application in ***build.settings***. See more - [neverStripDebugInfo](https://docs.coronalabs.com/guide/distribution/advancedSettings/index.html#build-control).
```lua
settings =
{
	    build =
	    {
			neverStripDebugInfo = true,
	    },
}
```
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
> `String`. Your Deployment ID. See more - [How to get Deployment ID](https://github.com/stalker-66/CatchErrors/blob/5bcc7221d9992b1fd2e451416b488a4a545584b2/Docs/How%20to%20get%20Deployment%20ID.md). <br/>
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
> * **appVersion** (optional) <br/>
> `String`. Your application version. Default is `appVersionString`. See more - [system.getInfo("appVersionString")](https://docs.coronalabs.com/api/library/system/getInfo.html#appversionstring). <br/>
> * **customParams** (optional) <br/>
> `Table`. List of custom parameters to upload with error message. Default is `nil`. <br/>
> The parameter table must have the format: `key = value`. <br/>
> Supported data type for ***key*** and ***value***: `string`, `number`, `boolean`. <br/>
> ***The parameter table must not contain nested tables***. <br/>
> 	`Example:` <br/>
> 	```lua
> 	{
> 		name = "John",
> 		email = "jh@jh.com",
> 	}
> * **workSimulator** (optional) <br/>
> `Boolean`. Enable/Disable automatic error catching on the simulator. Default is `false`. <br/>
> * **debug** (optional) <br/>
> `Boolean`. Includes additional debugging information for the plugin. Default is `false`. <br/>

> Call this function if the localization of the application has changed. This will allow you to change the localization of the error message.
> ```lua
> catcherrors.setLanguageMessage(value)
> ```
> * **value** (optional) <br/>
> `String`. Two language letters for ***ISO 639-1*** format. The localization must be present in the **listErrorMessage** table. Default is `Auto`. <br/>

> This function allows you to send custom error from anywhere in the application.
> ```lua
> catcherrors.send(params)
> ```
> The ***params*** table includes parameters for send a custom error. <br/>
> * **type** (optional) <br/>
> `String`. Type of custom error. Default is `Warning`. <br/> <br/>
> Supported values: <br/>
> `Warning` - Sending ***Warning*** errors. <br/>
> `Crash` - Sending ***Crash*** errors. <br/> <br/>
> * **errorCode** (optional) <br/>
> `Number`. Enter your error code. Default is `0`. <br/>
> The default runtime error code is `9999`. Please do not use this code. <br/>
> * **message** (optional) <br/>
> `String`. Enter your error message. Default is `NoMessage`. <br/>
> 
> `Example:` <br/>
> ```lua
> catcherrors.send({
> 	type = "Warning",
> 	errorCode = 10,
> 	message = "Test Warning",
> })
> ```

> Call this function if you need to replace the list of files that will be attached to the error after initialization.
> ```lua
> catcherrors.setFileList(fileList)
> ```
> * **fileList** (optional) <br/>
> `Table`. List of files to upload with the error message. Default is `nil`. <br/> <br/>
> By default, the file `log.catcherrors` will be sent, which contains all the ***print*** of the user. The `fileList` must include tables with parameters: ***filename*** and ***baseDir***. <br/>
> 
> `Example:` <br/>
> ```lua
> catcherrors.setFileList({
> 	{ filename = "myFile1.txt", baseDir = system.ResourceDirectory },
> 	{ filename = "myFile2.png", baseDir = system.DocumentsDirectory },
> })
> ```
> The file size directly affects the speed of sending errors. <br/>
> If you plan to upload files from ***system.ResourceDirectory***, be aware of Android limitations. See more - [system.ResourceDirectory](https://docs.coronalabs.com/api/library/system/ResourceDirectory.html). <br/>

> This function allows you to change the application version after initialization.
> ```lua
> catcherrors.setAppVersion(version)
> ```
> * **version** (optional) <br/>
> `String`. Your application version. Default is `appVersionString`. See more - [system.getInfo("appVersionString")](https://docs.coronalabs.com/api/library/system/getInfo.html#appversionstring). <br/> <br/>
> 
> `Example:` <br/>
> ```lua
> catcherrors.setAppVersion("1.002")
> ```

> Call this function if you need to set custom parameters that will be attached to the error after initialization.
> ```lua
> catcherrors.setCustomParams(paramsList)
> ```
> * **paramsList** (optional) <br/>
> `Table`. List of custom parameters to upload with error message. Default is `nil`. <br/> <br/>
> The parameter table must have the format: `key = value`. <br/>
> Supported data type for ***key*** and ***value***: `string`, `number`, `boolean`. <br/>
> ***The parameter table must not contain nested tables***. <br/>
> 
> `Example:` <br/>
> ```lua
> catcherrors.setCustomParams({
> 	name = "John",
> 	email = "jh@jh.com",
> })
> ```

## Usage
> * After the plugin is initialized, lua error catching starts. This completes the setup. You can use the ***catcherrors.send*** function in your application to send errors. <br/>
> * If the error is not sent after it occurs, the error will continue to be sent the next time the application is run. <br/>
> * The plugin is compatible with [RealTimeLog](https://github.com/stalker-66/RealTimeLog).
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
