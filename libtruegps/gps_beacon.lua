local modem = component.proxy(component.list("modem")())
local eeprom = component.proxy(component.list("eeprom")())

function sleep(timeout)
  checkArg(1, timeout, "number", "nil")
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

local function trilaterate( A, B, C )
  local a2b = B.p - A.p
  local a2c = C.p - A.p

  if math.abs( a2b:normalize():dot( a2c:normalize() ) ) > 0.999 then
    return nil
  end

  local d = a2b:length()
  local ex = a2b:normalize( )
  local i = ex:dot( a2c )
  local ey = (a2c - (ex * i)):normalize()
  local j = ey:dot( a2c )
  local ez = ex:cross( ey )

  local r1 = A.d
  local r2 = B.d
  local r3 = C.d

  local x = (r1*r1 - r2*r2 + d*d) / (2*d)
  local y = (r1*r1 - r3*r3 - x*x + (x-i)*(x-i) + j*j) / (2*j)

  local result = A.p + (ex * x) + (ey * y)

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
  local dist1 = math.abs( (p1 - fix.p):length() - fix.d )
  local dist2 = math.abs( (p2 - fix.p):length() - fix.d )

  --print(dist1 .." / " .. dist2)

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
  modem = modem or component.modem
  timeout = timeout or 2


  if modem == nil then
    if debug then
    --  print( "No wireless modem attached" )
    end
    return nil
  end
  modem.open(PORT_GPS)

  if not modem.isOpen(PORT_GPS) then
    --print("error opening modem")
    return nil
  end

  local fixes = {}
  local pos1, pos2 = nil, nil

  while true do
    local e = {event.pull(timeout)}
    if e[1] == "modem_mm" then

      -- We received a mm from a modem
      local aa, from, port, d, header = table.unpack(e,2,6)
      local mm = {table.unpack(e,7,#e)}
      if header == "GPS" then
        -- Received the correct mm from the correct modem: use it to determine p
        if #mm == 3 then
          local fix = { p = vector.new( mm[1], mm[2], mm[3] ), d = d, src = from }
          if debug then
          --  print( fix.d.." meters from "..fix.p.x..", "..fix.p.y..", "..fix.p.z )
          end
          if fix.d == 0 then
            pos1, pos2 = fix.p, nil
          else
            smartInsert( fixes, fix )
            if debug then
            --  print ("Avaible fixes " .. #fixes)
            end
            if #fixes >= 3 then
              if not pos1 then
                pos1, pos2 = trilaterate( fixes[1], fixes[2], fixes[#fixes] )
              else
                pos1, pos2 = narrow( pos1, pos2, fix )
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
  modem.close( PORT_GPS )
  -- Return the response
  if pos1 and pos2 then
    if debug then
    --  print( "Ambiguous position" )
    --  print( "Could be "..pos1.x..","..pos1.y..","..pos1.z.." or "..pos2.x..","..pos2.y..","..pos2.z )
    end
    return nil
  elseif pos1 then
    if debug then
    --  print( "Position is "..pos1.x..","..pos1.y..","..pos1.z )
    end
    return pos1.x, pos1.y, pos1.z
  else
    if debug then
    --  print( "Could not determine position" )
    end
    return nil
  end
end


function gps.host(x,y,z,modem)
  -- Find a modem
  modem = modem or component.modem
  if modem == nil then
    --print( "No wireless modems found. One required." )
    return
  end
  -- Open a channel
 -- print( "Opening port on modem "..modem.address )
  local openedChannel = false
  if not modem.isOpen(PORT_GPS) then
    modem.open( PORT_GPS )
    openedChannel = true
  end
  -- Determine position
  if not x then
    -- Position is to be determined using locate
    x,y,z = gps.locate( 2, true )
    if not x then
     -- print( "Could not locate, set position manually" )
	 computer.beep(2000)
	 computer.beep(300)
	 computer.beep(2000)
      if openedChannel then
     --   print( "Closing GPS port" )
        modem.close( PORT_GPS )
      end
      return
    end
  end

  -- Serve requests indefinately
  while true do
    modem.broadcast(PORT_GPS, "GPS", x, y, z)
    sleep(2)
  end

 -- print( "Closing channel" )
  modem.close( PORT_GPS )
end


local function unserialize(data)
  checkArg(1, data, "string")
  local result, reason = load("return " .. data, "=data", nil, {math={huge=math.huge}})
  if not result then
    return nil, reason
  end
  local ok, output = pcall(result)
  if not ok then
    return nil, output
  end
  return output
end
local p = unserialize(eeprom.getData())
if(not p == nil) then
	computer.beep(1000)
	computer.beep(1000)
	gps.host(p[1],p[2],p[3])
else
	computer.beep(500)
	gps.host(nil,nil,nil)
end
