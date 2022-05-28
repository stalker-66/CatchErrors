-- [[ START ]] --
local publisherId = "com.narkoz"
local pluginName = "catcherrors"

local public = require "CoronaLibrary":new{ name=pluginName, publisherId=publisherId }

-- [[ ADD MODULES/OPTIMIZATION/SETTINGS ]] --
local mime = require "mime"
local mime_b64 = mime.b64
local json = require "json"
local json_prettify = json.prettify
local json_decode = json.decode
local json_encode = json.encode
local math_random = math.random
local string_gsub = string.gsub
local string_sub = string.sub
local string_format = string.format
local string_lower = string.lower
local os_date = os.date
local _pairs = pairs
local _print = print

-- [[ PRIVATE ]] --
local private = {
	fileList = {
		{ filename = "log.catcherrors", baseDir = system.DocumentsDirectory }
	},
	config = {},
	url = "https://script.google.com/macros/s/youDeploymentID/exec",
	platform = system.getInfo("platform").." "..system.getInfo("platformVersion"),
	workSimulator = false,
	debug = false,
	init = false,

	sendFiles = "All",
	delaySend = false,

	useErrorMessage = true,
	languageErrorMessage = "Auto",
	listErrorMessage = {
		en = {
			title = "Oops!",
			desc = "Something went wrong! Our experts are already dealing with this problem. We apologize for the inconvenience, the application will be closed.",
			button = "OK",
		},
		ru = {
			title = "Ошибка!",
			desc = "Что-то пошло не так! Наши специалисты уже занимаються решением данной проблемы. Просим прощения за неудобства, приложение будет закрыто.",
			button = "ОК",
		},
	},

	-- errorProcess = false,

	attemptCurSending = 0,
	attemptMaxSending = 3,
	milsecSending = 1000,
	timerSending = nil,
	isSending = false,
}

private.log = function(str)
	if not str then return false end

	local path = system.pathForFile( private.fileList[1].filename, private.fileList[1].baseDir )
	local file, errorString = io.open( path, "a" )

	if not file then
		if private.debug then
			_print( "CatchErrors: log - "..errorString )
		end
	else
		file:write( str, "\n" )
		io.close( file )
	end
end

private.saveConfig = function()
	local path = system.pathForFile( "config.catcherrors", system.DocumentsDirectory )
	local file, errorString = io.open( path, "w" )

	if not file then
		if private.debug then
			_print( "CatchErrors: saveConfig - "..errorString )
		end
	else
		file:write( json_encode( private.config ) )
		io.close( file )
	end
end

private.loadConfig = function()
	local path = system.pathForFile( "config.catcherrors", system.DocumentsDirectory )
	local file, errorString = io.open( path, "r" )

	if not file then
		private.config = {}
		if private.debug then
			_print( "CatchErrors: loadConfig - "..errorString )
		end
	else
		local contents = file:read( "*a" )
		private.config = json_decode( contents )
		io.close( file )
	end
end

private.packFile = function(p)
	local p = p or {}
	p.filename = p.filename or ""
	p.baseDir = p.baseDir or system.DocumentsDirectory

	local path = system.pathForFile( p.filename, p.baseDir )
	local file, errorString = io.open( path, "rb" )

	if file then
		file = file:read("*a")
	else
		file = ""
		if private.debug then
			_print( "CatchErrors: packFile - "..errorString )
		end
	end

	file = mime_b64(file)

	return file
end

private.getUnic = function()
	return string_gsub("xxxx-xxxx-xxxx", "[xy]", function(c)
		local v = (c == "x") and math_random(0, 0xf) or math_random(8, 0xb)
		return string_format("%x", v)
	end)
end

private.parsePrint = function(...)
	local str = ""
	local args = {...}
	if #args>0 then
		for i=1,#args do
			local v = args[i]
			if type(v)=="table" then
				v = json_prettify(v)
			end
			if i==1 then
				str = tostring(v)
			else
				str = str..' '..tostring(v)
			end
		end
	end
	return str
end

private.setTask = function(p)
	local p = p or {}
	p.type = p.type or "Warning"
	p.errorCode = p.errorCode or 0
	p.message = p.message or "NoMessage"

	local unic = private.getUnic()
	local body = {}

	if private.sendFiles=="All" 
		or (p.type=="Warning" and private.sendFiles=="Warning") 
		or (p.type=="Crash" and private.sendFiles=="Crash") then

		for i=1,#private.fileList do
			body["file"..i] = private.packFile(private.fileList[i]) 
			body["filename"..i] = private.fileList[i].filename
		end

		public.clearLog()
	end

	body.unic = mime_b64( unic )
	body.type = mime_b64( p.type )
	body.date = mime_b64( os_date("%x").." "..os_date("%X") )
	body.code = mime_b64( p.errorCode )
	body.message = mime_b64( p.message )
	body.platform = mime_b64( private.platform )

	private.config[#private.config+1] = {
		body = body,
		unic = unic
	}

	if private.debug then
		_print( "CatchErrors: setTask - ", unic )
	end

	private.saveConfig()
	if private.delaySend==false then
		private.sendToServer()
	end
end

private.sendToServer = function()
	if #private.config>0 and private.isSending==false then
		if private.timerSending then
			timer.cancel(private.timerSending)
			private.timerSending = nil
		end

		private.isSending = true
		local unic = private.config[#private.config].unic
		local body = private.config[#private.config].body

		if private.debug then
			_print( "CatchErrors: sendToServer - ", unic )
		end

		local request = network.request(private.url, "POST", function(e)
			if e.status~=200 or e.isError then
				private.attemptCurSending = private.attemptCurSending+1
				if private.debug then
					_print( "CatchErrors: sendToServer - error:", json_prettify(e) )
				end
			else
				-- fix broken error
				local response = json_decode(e.response)
				response = response or {}
				response.unic = response.unic or unic

				-- reset attempts
				private.attemptCurSending = 0

				-- reload config
				local new_config = {}
				for i=1,#private.config do
					if private.config[i].unic~=response.unic then
						new_config[#new_config+1] = private.config[i]
					end
				end
				private.config = new_config
				private.saveConfig()

				if private.debug then
					_print( "CatchErrors: sendToServer - success:", response.unic, json_prettify(response) )
				end
			end
			private.isSending = false
			if private.attemptCurSending<private.attemptMaxSending then
				private.timerSending = timer.performWithDelay( private.milsecSending, function()
					private.sendToServer()
				end )
			end

			-- if private.errorProcess then
			-- 	private.errorProcess = false
			-- 	native.setActivityIndicator(false)
			-- 	private.showMessage()
			-- end
		end, {
			headers = {
				["Content-Type"] = "application/json",
			},
			body = json_encode(body),
		})
	end
end

private.getLoc = function()
	local lng = "en"
	if system.getInfo("platform")=="ios" then
		lng = system.getPreference( "ui", "language" )
		lng = string_sub(lng,1,2)
	else
		lng = system.getPreference( "locale", "language" )
	end
	lng = string_lower(lng)

	-- ukrainian to russian
	if lng=="uk" or lng=="ua" then
		lng = "ru"
	end

	-- belarusian to russian
	if lng=="be" or lng=="by" then
		lng = "ru"
	end

	-- default language
	if private.listErrorMessage[lng]==nil then
		lng = "en"
	end

	return lng
end

private.showMessage = function()
	local msg = private.listErrorMessage[private.languageErrorMessage] and private.listErrorMessage[private.languageErrorMessage] or private.listErrorMessage.en
	native.showAlert(msg.title, msg.desc, { msg.button },function(e)
		if e.action=="clicked" then
			if e.index==1 then
				if system.getInfo("platform")=="ios" then
					os.exit()
				else
					native.requestExit()
				end
			end
		end
	end)
end

-- [[ PUBLIC ]] --
public.init = function(p)
	if private.init then return false end

	math.randomseed( os.time() )

	local p = p or {}
	if p.deploymentID==nil then
		if p.debug then
			_print( "CatchErrors: init - Incorrect Deployment ID. The plugin stops working." )
		end
		return false
	end
	p.fileList = p.fileList or {}
	p.sendFiles = p.sendFiles or private.sendFiles
	p.useErrorMessage = p.useErrorMessage
	if p.useErrorMessage==nil then
		p.useErrorMessage = private.useErrorMessage
	end
	p.delaySend = p.delaySend
	if p.delaySend==nil then
		p.delaySend = private.delaySend
	end
	p.workSimulator = p.workSimulator
	if p.workSimulator==nil then
		p.workSimulator = private.workSimulator
	end
	p.languageErrorMessage = p.languageErrorMessage or private.languageErrorMessage
	p.listErrorMessage = p.listErrorMessage or private.listErrorMessage
	p.debug = p.debug

	-- files
	for i=1,#p.fileList do
		local filename = p.fileList[i].filename or ""
		local baseDir = p.fileList[i].baseDir or system.DocumentsDirectory

		private.fileList[#private.fileList+1] = { filename = filename, baseDir = baseDir }
	end

	-- send files
	private.sendFiles = p.sendFiles

	-- params
	private.url = "https://script.google.com/macros/s/"..p.deploymentID.."/exec"
	private.debug = p.debug
	private.init = true

	-- delay send
	private.delaySend = p.delaySend

	-- message
	private.useErrorMessage = p.useErrorMessage
	private.languageErrorMessage = p.languageErrorMessage

	for k,v in _pairs(p.listErrorMessage) do
		private.listErrorMessage[k] = v
	end

	public.setLanguageMessage(private.languageErrorMessage)

	-- func
	private.loadConfig()
	private.sendToServer()

	-- work simulator
	private.workSimulator = p.workSimulator

	-- handle error
	local environment = system.getInfo("environment")
	if (environment=="simulator" and private.workSimulator) or environment~="simulator" then
		Runtime:addEventListener( "unhandledError", function(e)
			public.send({
				type = "Crash",
				errorCode = 9999,
				message = e.errorMessage.."\n"..e.stackTrace,
			})
		end )
	end
	
	-- global --
	_G.printEvents = _G.printEvents or {}
	_G.printEvents[#_G.printEvents+1] = function(str)
		local str = str or ""
		str = os_date("%x").." "..os_date("%X").." - "..str
		private.log(str)
	end
	if _G.narkozPrint~=true then
		_G.narkozPrint = true
		print = function(...)
			local str = private.parsePrint(...)
			for i=1,#_G.printEvents do
				local res = _G.printEvents[i](str)
				str = res and res or str
			end
			_print(str)
		end
	end

	if private.debug then
		_print( "CatchErrors: Plugin initialized." )
	end

	return true
end

public.clearLog = function()
	if not private.init then
		if private.debug then
			_print( "CatchErrors: clearLog - Plugin not initialized." )
		end
		return false
	end

	local path = system.pathForFile( private.fileList[1].filename, private.fileList[1].baseDir )
	local file, errorString = io.open( path, "w" )

	if not file then
		if private.debug then
			_print( "CatchErrors: "..errorString )
		end
		return false
	else
		file:write( "" )
		io.close( file )
		return true
	end
end

public.setLanguageMessage = function(language)
	if not private.init then
		if private.debug then
			_print( "CatchErrors: setLanguageMessage - Plugin not initialized." )
		end
		return false
	end

	if private.useErrorMessage then
		local language = language or "Auto"

		if language=="Auto" then
			language = private.getLoc()
		end

		private.languageErrorMessage = language

		if private.debug then
			_print( "CatchErrors: setLanguageMessage - "..private.languageErrorMessage )
		end
	else
		if private.debug then
			_print( "CatchErrors: setLanguageMessage - The error message is not used." )
		end
	end
end

public.send = function(p)
	if not private.init then
		if private.debug then
			_print( "CatchErrors: send - Plugin not initialized." )
		end
		return false
	end

	local p = p or {}
	p.type = p.type or "Warning"
	p.errorCode = p.errorCode or 0
	p.message = p.message or "NoMessage"

	print("type: "..tostring(p.type).."\nerrorCode: "..tostring(p.errorCode).."\nmessage:"..tostring(p.message))

	private.setTask(p)

	if p.type=="Crash" and private.useErrorMessage then
		-- private.errorProcess = true
		-- native.setActivityIndicator(true)
		private.showMessage()
	end
	return true
end

return public
