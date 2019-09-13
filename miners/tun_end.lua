local stop = false
local robot = require("robot")
local computer = require("computer")
local cm = require("component")
local start_energy = 0
local steps = 0
local back = false

local cl = cm.proxy(cm.get("","chunkloader"))

function flush(last)

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
			if last then
				robot.select(10)
			else
				robot.select(1)
			end
			robot.swingDown()
			robot.select(2)
			
		else
			stop = true
			print("chest place fail")
		end

end


function checkInv()
	robot.suck()
	robot.suckUp()
	robot.suckDown()
  if  robot.count(16) > 0 then   
		flush(false)	
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


	print(cl.setActive(true))

	start_energy = computer.energy()
	
  local loops = 999
  local steps = 0

  print("Digger start")

  while  (loops > 0) and (stop == false) do

    digCol()

    if robot.forward() then
	
		if back == false then
			steps = steps + 1
		else
			steps = steps - 1
		end
	end

	if computer.energy() < start_energy * 0.53 and back == false then
		print("Going back\n")
		back = true

		robot.swingDown()
		robot.down()
			  
		robot.swingDown()
		robot.down()
			  
		robot.swingDown()
		robot.down()
			  
		robot.turnLeft()
		robot.turnLeft()	
	  
    end
	
	if (back == true) and (steps == 1) then
		print("Home position\n")
		stop = true
		
		robot.swingUp()
		robot.up()
			  
		robot.swingUp()
		robot.up()
			  
		robot.swingUp()
		robot.up()
			  
		robot.turnLeft()
		robot.turnLeft()
		flush(true)
		
		robot.use(0,true)
		--robot.use(0,true)
		
		print(cl.setActive(false))
	end
  end

return 0
  
end


digger()
print(cl.setActive(false))
computer.shutdown()