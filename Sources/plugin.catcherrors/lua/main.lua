-- Sample app for the CatchErrors plugin for Solar2D
-- Documentation: https://github.com/stalker-66/CatchErrors/

local catcherrors = require "plugin.catcherrors"

catcherrors.init({
	deploymentID = "AKfycbzTEyM3B2x3wy4x1MoIEcSKOW6fkq3aQ4LXa2Ivyb1HvL1Ubwzg1_4rtZFpJh0GFYqqVg",
	fileList = {
		{ filename = "car.png.txt", baseDir = system.ResourceDirectory },
	},
	sendFiles = "All",
	delaySend = false,
	useErrorMessage = true,
	languageErrorMessage = "Auto",
	listErrorMessage = {
		es = {
			title = "¡Ups!",
			desc = "¡Algo salió mal! Nuestros expertos ya están lidiando con este problema. Pedimos disculpas por las molestias, la aplicación se cerrará.",
			button = "OK",
		}
	},
	-- appVersion = "1.002",
	-- customParams = { name = "Tester102" },
	workSimulator = true,
	debug = true,
})

catcherrors.setLanguageMessage("es")

-- title --
local title = display.newText{
	text = "Catch Errors Plugin",
	fontSize = display.contentHeight*.038
}
title.x = display.contentWidth*.5
title.y = display.contentHeight*.18

local auth = display.newText{
	text = "by narkoz",
	fontSize = display.contentHeight*.019
}
auth.x = title.x+title.width*.5-auth.width*.5
auth.y = title.y+title.height*.5+auth.height*.5
auth:setFillColor(1,0,0)

-- buttons --
local widget = require  "widget"
local size = display.contentWidth*.6

local sendWarning = widget.newButton(
	{
		shape = "roundedRect",
		width = size,
		height = size*.2,
		cornerRadius = size*.05,
		label = "Send Warning",
		fontSize = size*.08,
		fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onRelease  = function()
			catcherrors.send({
				type = "Warning",
				errorCode = 10,
				message = "Test Warning",
			})
		end
	}
)
sendWarning.x = display.contentWidth*.5
sendWarning.y = display.contentHeight*.35

local sendCrash = widget.newButton(
	{
		shape = "roundedRect",
		width = size,
		height = size*.2,
		cornerRadius = size*.05,
		label = "Send Crash",
		fontSize = size*.08,
		fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onRelease  = function()
			catcherrors.send({
				type = "Crash",
				errorCode = 10,
				message = "Test Crash",
			})
		end
	}
)
sendCrash.x = display.contentWidth*.5
sendCrash.y = sendWarning.y+sendWarning.height*.5+sendCrash.height

local fakeCrash = widget.newButton(
	{
		shape = "roundedRect",
		width = size,
		height = size*.2,
		cornerRadius = size*.05,
		label = "Fake Crash",
		fontSize = size*.08,
		fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onRelease  = function()
			getCrush()
		end
	}
)
fakeCrash.x = display.contentWidth*.5
fakeCrash.y = sendCrash.y+sendCrash.height*.5+fakeCrash.height

local setFileList = widget.newButton(
	{
		shape = "roundedRect",
		width = size,
		height = size*.2,
		cornerRadius = size*.05,
		label = "Set New File List",
		fontSize = size*.08,
		fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onRelease  = function()
			catcherrors.setFileList({
				{ filename = "data.json.txt", baseDir = system.ResourceDirectory }
			})
		end
	}
)
setFileList.x = display.contentWidth*.5
setFileList.y = fakeCrash.y+fakeCrash.height*.5+setFileList.height

local setAppVersion = widget.newButton(
	{
		shape = "roundedRect",
		width = size,
		height = size*.2,
		cornerRadius = size*.05,
		label = "Set App Version",
		fontSize = size*.08,
		fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onRelease  = function()
			catcherrors.setAppVersion("0.025")
		end
	}
)
setAppVersion.x = display.contentWidth*.5
setAppVersion.y = setFileList.y+setFileList.height*.5+setAppVersion.height

local setCustomParams = widget.newButton(
	{
		shape = "roundedRect",
		width = size,
		height = size*.2,
		cornerRadius = size*.05,
		label = "Set Custom Params",
		fontSize = size*.08,
		fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onRelease  = function()
			catcherrors.setCustomParams({
				name = "Pug",
				weight = 10.5
			})
		end
	}
)
setCustomParams.x = display.contentWidth*.5
setCustomParams.y = setAppVersion.y+setAppVersion.height*.5+setCustomParams.height

local printTable = widget.newButton(
	{
		shape = "roundedRect",
		width = size,
		height = size*.2,
		cornerRadius = size*.05,
		label = "Print Table",
		fontSize = size*.08,
		fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
		onRelease  = function()
			local list = {
				name = "John Doe",
				items = {
					{ id = "orange", count = 2, quality = "legend" },
					{ id = "banana", count = 8, quality = "legend" },
					{ id = "coconut", count = 14, quality = "legend" },
				}
			}

			print( list )
		end
	}
)
printTable.x = display.contentWidth*.5
printTable.y = setCustomParams.y+setCustomParams.height*.5+printTable.height

-- test print --
print( "Launch Catch Errors Example Project" )