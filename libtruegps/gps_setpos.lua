
local component = require "component"
local serialization = require "serialization"
local shell = require "shell"
local eeprom = component.eeprom
local args, ops = shell.parse(...)

print(args)

if #args < 3 then

	print("You need to specify all 3 coords (x,y,z order)")
	
	os.exit()
end

local pos = serialization.serialize({args[1],args[2],args[3]})

print("Writing to EEPROM" .. tostring(pos))

eeprom.setData(pos)
local lbl = eeprom.getLabel();

eeprom.setLabel(lbl .. " " .. args[1] .. "/" .. args[2] .. "/" ..args[3])


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


--print(dump(eeprom.getData()))