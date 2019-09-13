local component = require "component"
local event = require "event"
local modem = component.modem
local chat = nil

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

if #component.list("chat") > 0 then
	chat = component.chat
end

local targetPort = 8192
local args = {...}

if #args > 0 then
	targetPort = tonumber(args[1])
end

modem.close()
if not modem.open(targetPort) then
	print("error opening modem")
end

print("Starting capture on ".. targetPort)
while modem.isOpen(targetPort) do
	
	--local _, _, from, port, _, message = event.pull("modem_message")
	
	--if chat then
	--	chat.say(">>" .. from .. ": " .. dump(message))
	--else
	--	print(">>" .. from .. ": " .. dump(message))
	--end
	
	local e = {event.pull("modem_message")}
	print(dump(e))
	--print(tostring(e))
	--if e[1] == "modem_message" then
		
	--end
end

