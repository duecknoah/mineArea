print("Help: mineArea <depth> <width> <1=useTorches>")

args = {...}
depth = args[1]
width = args[2]
useTorches = args[3]

print("Depth: " .. depth)
print("Width: " .. width)
print("Use torches?: " .. useTorches)

function checkFuel()
  if (turtle.getFuelLevel() < 5) then
    print("Refuelling ... ")
    -- Cycle through until fuel found
    for i=1,16 do
      turtle.select(i)
      if (turtle.refuel()) then
        -- reset and return
        turtle.select(1)
        return true
      end
    end
    print("Not enough Fuel! Please insert fuel and type 'Y' or 'N' to continue or stop: ")
    local answer = read()  
    if (answer == "N") then
      os.exit()
    end
    print("Continueing in 5 seconds ...")
    sleep(5)
    turtle.refuel()
  end
end

function digForwardUntilClear()
  while (turtle.inspect()) do
    turtle.dig()
    sleep(0.25)
  end
end

function digUpUntilClear()
  while (turtle.inspectUp()) do
    turtle.digUp()
    sleep(0.25)
  end
end

local widthCovered = 1
local xPos = 0
local zPos = 0

while (true) do
  checkFuel()
  for i=1,depth do
    digForwardUntilClear()
    digUpUntilClear()
    turtle.forward()
    zPos = zPos + 1
    checkFuel()
  end
  digUpUntilClear()
  -- Finished column
  -- Now go back all the way
  for i=1,depth do
    turtle.back()
    zPos = zPos - 1
    -- Torch placing
    if (useTorches) then
      if (xPos % 5 == 0 and zPos % 5 == 0) then
        turtle.select(2)
        turtle.place()
      end
    end
    checkFuel()
  end
  print("Column done")
  print("WidthCovered: " .. widthCovered)
  print("Width: " .. width)
  -- Check if we are all the way
  -- To the left, if so
  -- get out of the loop
  if (widthCovered == tonumber(width)) then
    break
  end
  turtle.turnRight()
  digForwardUntilClear()
  turtle.forward()
  xPos = xPos + 1
  digUpUntilClear()
  turtle.turnLeft()
  
  widthCovered = widthCovered + 1
end

print("Going to chest!")

turtle.turnLeft()
for i=1,width do
  turtle.forward()
  xPos = xPos - 1
end

for i=1,16 do
  turtle.select(i)
  turtle.drop()
end

-- Reset slot we are selecting
turtle.select(1)

print("Done!")