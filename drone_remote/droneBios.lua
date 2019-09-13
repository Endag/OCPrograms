m=component.proxy(component.list("modem")())
d=component.proxy(component.list("drone")())
m.setWakeMessage("RISE")
local CMD_PORT = 2412
m.open(CMD_PORT)
computer.beep(2000)
local eventStack = {}
local listeners = {}
event = {}
function event.listen(evtype,callback)
 if listeners[evtype] ~= nil then
  table.insert(listeners[evtype],callback)
  return #listeners
 else
  listeners[evtype] = {callback}
  return 1
 end
end
function event.ignore(evtype,id)
 table.remove(listeners[evtype],id)
end
function event.pull(filter)
 if not filter then return table.remove(eventStack,1)
 else
  for _,v in pairs(eventStack) do
   if v == filter then
    return v
   end
  end
  repeat
   t=table.pack(computer.pullSignal())
   evtype = table.remove(t,1)
   if listeners[evtype] ~= nil then
    for k,v in pairs(listeners[evtype]) do
     local evt,rasin = pcall(v,evtype,table.unpack(t))
     if not evt then
      print("stdout_write","ELF: "..tostring(evtype)..":"..tostring(k)..":"..rasin)
     end
    end
   end
  until evtype == filter
  return evtype, table.unpack(t)
 end
end
function print(...)
 local args=table.pack(...)
 pcall(function() m.broadcast(CMD_PORT, table.unpack(args)) end)
end
function sleep(n)
  local t0 = computer.uptime()
  while computer.uptime() - t0 <= n do computer.pushSignal("wait") computer.pullSignal() end
end
function error(...)
 print(...)
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
prg = ""
print("Deep Bios v1.0")
print("BOOTME")
while true do
	m.close()
	m.open(CMD_PORT)
	evt = {event.pull("modem_message")}
	if evt[1] == "modem_message" and evt[4] == CMD_PORT then
		cmd = evt[6]
		--print(dump(evt))
		if cmd == "a" then
			if evt[7] then
				prg = prg.."\n"..evt[7]
			end
		elseif cmd == "c" then
			prg = ""
		elseif cmd == "r" then
			print(pcall(load(prg)))
		elseif cmd == "e" then
			print(pcall(load(evt[7])))
		else
			print("unknown cmd "..cmd)
		end
	end
end