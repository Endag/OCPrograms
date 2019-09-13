local event = require("event")	
local component = require "component"
local shell = require "shell"
local modem = component.proxy(component.list("modem")())
local io = require("io")
local listen = function(evt,_,_,_,_,...) print(tostring(...)) end -- here.
-- helps when restarting the client to prevent event listener duplicates
event.ignore("modem_message",listen)
event.listen("modem_message",listen) -- and here.
modem.open(2412)

 local script = [[  
function mv(xx,yy,zz) 
d.move(xx, yy, zz);
while(d.getVelocity()> 0.001) do print("V:"..d.getVelocity()) end
computer.beep(500)
print("O:"..d.getOffset())
end
 
print("Hello!")
d=component.proxy(component.list("drone")()) 

d.setLightColor(0x00FFE8)
d.setStatusText("Lulz")

computer.beep(1000)
computer.beep(1500)
computer.beep(2000)

mv(0, 3,0)
--mv(10,0,0)
--mv(0,0,10)
--mv(-10,0,0)
--mv(0,0,-10)
--mv(0,-10,0)

computer.beep(2000)
	
return "bye!"
 ]]
 
local args, ops = shell.parse(...)
if ops.e then
	modem.broadcast(2412,"e", args[1])
	os.sleep(5)
elseif ops.c then
	modem.broadcast(2412,"c")
elseif ops.r then
	modem.broadcast(2412,"r")
	os.sleep(5)
elseif #args > 0 and ops.l then
	local name = args[1]	
	print("Preparing to send file "..args[1])
	local fileSendInitial = assert(io.open(args[1],"r"),"Failed to open existing file to send.")
	local sendString = fileSendInitial:read("*a") --reads the entire file into one gigantic string

	modem.broadcast(2412,"a", sendString)
	--modem.broadcast(2412,"r")
	--modem.broadcast(2412,"c")
	
	--os.sleep(5)
else
print("Specify file")
end

 

event.ignore("modem_message",listen)
 
function sleep(n)
local t0 = computer.uptime()
while computer.uptime() - t0 <= n do computer.pushSignal("wait") computer.pullSignal() end
end

  function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
 
