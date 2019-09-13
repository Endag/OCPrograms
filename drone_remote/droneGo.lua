local event = require("event")	
local component = require "component"
local shell = require "shell"
local modem = component.proxy(component.list("modem")())
local io = require("io")
local gps = require "libtruegps"


print("Positioning")
local pos = {gps.locate(10, component.modem, true)}

print("My pos "..pos[1].." "..pos[2].." "..pos[3])

local cmd = "gotogps("..pos[1]..","..pos[2]..","..pos[3]..")"

modem.open(2412)
print("Sending cmd")
modem.broadcast(2412,"e", cmd)
modem.close()