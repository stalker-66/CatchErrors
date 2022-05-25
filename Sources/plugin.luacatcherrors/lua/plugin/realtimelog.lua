-- init
local publisherId = "com.narkoz"
local pluginName = "realtimelog"

local public = require "CoronaLibrary":new{ name=pluginName, publisherId=publisherId }

-- add modules/optimization
local mime = require "mime"
local mime_b64 = mime.b64
local mime_unb64 = mime.unb64
local json = require "json"
local json_prettify = json.prettify
local json_decode = json.decode
local json_encode = json.encode
local table_remove = table.remove
local string_find = string.find
local string_match = string.match
local string_gsub = string.gsub
local string_len = string.len
local string_format = string.format
local math_random = math.random
local os_time = os.time
local os_date = os.date

-- private
local private = {
	init = false,
	list = {},
	order = true,
	typeList = {
		["Info"] = 0,
		["Warning"] = 1,
		["Error"] = 2,
		["NewSession"] = 3,
	}
}

local _print = print
private.print = function(...)
	if not private.init then return false end

	local args = {...}
	local date = os_date("%x").." "..os_date("%X")

	if #args>0 then
		private.list[#private.list+1] = ""
		for i=1,#args do
			local v = args[i]
			if type(v)=="table" then
				v = json_prettify(v)
			end
			if i==1 then
				private.list[#private.list] = tostring(v)
			else
				private.list[#private.list] = private.list[#private.list]..' '..tostring(v)
			end
		end

		local str = private.list[#private.list]
		if not private.debug then
			if string_find(str, "@type=") then
				local msgType = string_match(str,"@type=(%w+)@")
				str = string_gsub(str,"@type="..msgType.."@","")
			end
		end
		_print( str )

		if string_len(str)==0 then
			private.list[#private.list] = nil
		else
			private.list[#private.list] = "@date="..date.."@"..private.list[#private.list]
		end

		if private.offlineLog then
			private.save()
		end
	end
end

private.update = function()
	if not private.init then return false end

	if #private.list>0 and private.order then
		private.order = false

		local def_date = os_date("%x").." "..os_date("%X")
		local message = ""
		local index = 0
		for i=1,10 do
			local msg = private.list[i]
			if msg then
				local msgType = "Info"
				if string_find(msg, "@type=") then
					msgType = string_match(msg,"@type=(%w+)@")
					msg = string_gsub(msg,"@type="..msgType.."@","")
				end

				local date = def_date
				if string_find(msg, "@date=") then
					date = string_match(msg,"@date=(.+)@")
					msg = string_gsub(msg,"@date="..date.."@","")
				end

				if i==1 then
					message = "?p"..index.."="..mime_b64(msg)
				else
					message = message.."&p"..index.."="..mime_b64(msg)
				end

				msgType = private.typeList[msgType] and private.typeList[msgType] or 0
				message = message.."&t"..index.."="..msgType

				message = message.."&d"..index.."="..mime_b64(date)

				index = index+1
			end
		end

		local url = private.url..message.."&userId="..mime_b64(private.userId).."&platform="..mime_b64(private.platform)
		url = string_gsub(url,"+", "%%2B")
		if private.debug then
			_print( "RealTimeLog: Send Message:", url )
		end
		network.request( url, "GET", function(e)
			if e.isError then
				if private.debug then
					_print( "RealTimeLog: Log sending error. There is no internet connection or the server is unavailable.", json_prettify(e) )
				end
			else
				for i=index,1,-1 do
					if private.list[i] then
						table_remove(private.list,i)
					end
				end

				if private.offlineLog then
					private.save()
				end
			end
			private.order = true
		end)
	end
end

private.save = function()
	if not private.init then return false end

	local path = system.pathForFile( "realtimelog"..private.userId, system.DocumentsDirectory )
	local file, errorString = io.open( path, "w" )

	if not file then
	else
		file:write( json_encode( private.list ) )
		io.close( file )
	end
end

private.load = function()
	if not private.init then return false end

	local path = system.pathForFile( "realtimelog"..private.userId, system.DocumentsDirectory )
	local file, errorString = io.open( path, "r" )

	if not file then
		private.list = {}
	else
		local contents = file:read( "*a" )
		private.list = json_decode( contents )
		io.close( file )
	end
end

-- public
public.init = function(p)
	if private.init then return false end

	local p = p or {}
	if p.deploymentID==nil then
		if private.debug then
			_print( "RealTimeLog: Incorrect Deployment ID. The plugin stops working." )
		end
		return false
	end
	p.userID = p.userID or system.getInfo( "deviceID" )
	p.timeUpdate = p.timeUpdate or 250
	p.clearOldSession = p.clearOldSession
	p.offlineLog = p.offlineLog
	p.debug = p.debug
	
	print = private.print
	private.time = timer.performWithDelay( p.timeUpdate, private.update, 0 )
	private.url = "https://script.google.com/macros/s/"..p.deploymentID.."/exec"
	private.userId = p.userID
	private.debug = p.debug
	private.offlineLog = p.offlineLog
	private.platform = system.getInfo("platform").." "..system.getInfo("platformVersion")
	private.init = true

	if p.clearOldSession then
		public.clear()
	else
		private.update()
	end

	if private.debug then
		_print( "RealTimeLog: Initialization success." )
	end

	if private.offlineLog then
		private.load()
	end

	local unic = public.getUnic()
	print("@type=NewSession@RealTimeLog: New session: "..unic..".\nPlatform: "..private.platform..".\nUserId: "..private.userId..".")

	return true
end

public.clear = function()
	if not private.init then return false end

	private.order = false
	private.list = {}
	network.request( private.url.."?isClear=1", "GET", function(e)
		if e.isError or e.status~=200 then
			if private.debug then
				_print( "RealTimeLog: Log cleanup error. There is no internet connection or the server is unavailable." )
			end
		else
			if private.debug then
				_print( "RealTimeLog: Log cleared." )
			end
		end
		private.order = true
	end)
end

public.stop = function()
	if not private.init then return false end

	if private.time then
		timer.cancel(private.time)
	end
	private.init = false
	private.order = true
	private.url = nil
	private.userId = nil
	private.debug = nil
	private.offlineLog = nil
	private.platform = nil
	private.list = {}
end

public.getUnic = function(mask)
	local mask = mask~=nil and mask or "xxxx-xxxx-xxxx"
	return string_gsub(mask, "[xy]", function(c)
		local v = (c == "x") and math_random(0, 0xf) or math_random(8, 0xb)
		return string_format("%x", v)
	end)
end

return public
