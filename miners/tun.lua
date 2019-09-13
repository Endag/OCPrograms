local stop = false
local robot = require("robot")
local computer = require("computer")
local cm = require("component")

local cl = cm.proxy(cm.get("","chunkloader"))


function checkInv()

  if  robot.count(16) > 0 then
     if robot.count(1) > 1 then

		robot.select(1)

		if robot.detectDown()  then
			robot.swingDown()
		end
		if robot.placeDown()  then
			local slot = 2
			while slot < 17 do
				robot.select(slot)
				robot.dropDown()
				slot = slot+1		
			end
			robot.select(2)
		else
			stop = true
			print("chest place fail")
		end
	else	
		stop = true
		print("running out of chests")
    end
  end
end

function digCol()

  if (robot.detectDown())  and (stop == false) then
    robot.swingDown()
    checkInv()
  end


  while robot.detectUp() and (stop == false) do
    robot.swingUp()
    checkInv()
    os.sleep(1)
  end

  while robot.detect()  and (stop == false) do
    robot.swing()
    checkInv()
	os.sleep(1)
  end	
end

function digger()

  local loops = 999
  local steps = 0

  print("Digger start")
  print(cl.setActive(true))

  while  (loops > 0) and (stop == false) do

    digCol()

    robot.forward() 

    if computer.energy() < computer.maxEnergy()* 0.05 then

      stop = true

      print("Need refuel\n") 
		computer.shutdown()
    end

  end

return 0
  
end


digger()
