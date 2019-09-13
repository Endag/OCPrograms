
local gps = require "libtruegps"
local component = require "component"
print(gps.locate(50,component.modem,true))