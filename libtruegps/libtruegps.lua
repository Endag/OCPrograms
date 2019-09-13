local gps = {}
local vector = require "libvec"
local component = require "component"
local event = require "event"
local term = require "term"
local targetPort = 8192

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


local function trilaterate( A, B, C )
  local a2b = B.position - A.position
  local a2c = C.position - A.position

  if math.abs( a2b:normalize():dot( a2c:normalize() ) ) > 0.999 then
    return nil
  end

  local d = a2b:length()
  local ex = a2b:normalize( )
  local i = ex:dot( a2c )
  local ey = (a2c - (ex * i)):normalize()
  local j = ey:dot( a2c )
  local ez = ex:cross( ey )

  local r1 = A.distance
  local r2 = B.distance
  local r3 = C.distance

  local x = (r1*r1 - r2*r2 + d*d) / (2*d)
  local y = (r1*r1 - r3*r3 - x*x + (x-i)*(x-i) + j*j) / (2*j)

  local result = A.position + (ex * x) + (ey * y)

  local zSquared = r1*r1 - x*x - y*y
  if zSquared > 0 then
    local z = math.sqrt( zSquared )
    local result1 = result + (ez * z)
    local result2 = result - (ez * z)

    local rounded1, rounded2 = result1:round( 0.01 ), result2:round( 0.01 )
    if rounded1.x ~= rounded2.x or rounded1.y ~= rounded2.y or rounded1.z ~= rounded2.z then
      return rounded1, rounded2
    else
      return rounded1
    end
  end
  return result:round( 0.01 )
end

local function narrow( p1, p2, fix )
  local dist1 = math.abs( (p1 - fix.position):length() - fix.distance )
  local dist2 = math.abs( (p2 - fix.position):length() - fix.distance )

  if math.abs(dist1 - dist2) < 0.01 then
    return p1, p2
  elseif dist1 < dist2 then
    return p1:round( 0.01 )
  else
    return p2:round( 0.01 )
  end
end

local function smartInsert(tbl, entry)
  --print("Before " .. dump(tbl))
  --print("adding " .. dump(entry))
  local added = false;
  if #tbl > 0 then
    for k,v in pairs(tbl) do
      if v.src == entry.src then
        tbl[k] = entry
        added = true
      end
    end
  end
  if not added then
    table.insert( tbl, entry )
  end
 -- print("After " .. dump(tbl))
end

function gps.locate(timeout, modem, debug)

  modem.open(targetPort)

  if not modem.isOpen(targetPort) then
    print("error opening modem")
    return nil
  end

  local fixes = {}
  local pos1, pos2 = nil, nil

  while true do
  local e = {event.pull(timeout)}
  if e[1] == "modem_message" then

    -- We received a message from a modem
    local address, from, port, distance, header = table.unpack(e,2,6)
    local message = {table.unpack(e,7,#e)}
    if header == "GPS" then
      -- Received the correct message from the correct modem: use it to determine position
      if #message == 3 then
        local fix = { position = vector.new( message[1], message[2], message[3] ), distance = distance, src = from }
        if debug then
          print( fix.distance.." meters from "..fix.position.x..", "..fix.position.y..", "..fix.position.z )
        end
        if fix.distance == 0 then
          pos1, pos2 = fix.position, nil
        else
          smartInsert( fixes, fix )
          if #fixes >= 3 then
            if not pos1 then
              pos1, pos2 = trilaterate( fixes[1], fixes[2], fixes[#fixes] )
            else
              pos1, pos2 = narrow( pos1, pos2, fixes[#fixes] )
            end
          end
        end
        if pos1 and not pos2 then
          break
        end
      end
    end
  elseif e[1] == nil then
    break
  end


end
return pos1
end


return gps