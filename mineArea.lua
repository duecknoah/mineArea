print("Help: mineArea <depth> <width> <1=useTorches>")

args = {...}
depth = args[1]
width = args[2]
useTorches = args[3]

print("Depth: " .. depth)
print("Width: " .. width)
print("Use torches?: " .. useTorches)

local xPos = 0
local zPos = 0

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

-- If full inventory, go back to chest
-- to dump, then go back to position
function inventoryManage()
  turtle.select(16)
  local lastItem = turtle.getItemDetail()
  turtle.select(1) -- reset
  -- If there is an item in last slot,
  -- Go to chest
  if (lastItem) then
    -- save position to go back to
    local savedXPos = xPos
    local savedZPos = zPos
    
    -- Move all the way back
    for iz=1,savedZPos do
      turtle.back()
    end
    checkFuel()
    turtle.turnLeft()
    -- Move all the way to chest
    for ix=1,savedXPos do
      turtle.forward()
    end
    -- Dump inventory into chest
    dumpInventory(true)
    -- Return to saved location
    -- Make the x val the same
    for ix=1,savedXPos do
      turtle.back()
    end
    turtle.turnRight()
    -- Make the z val the same
    for iz=1,savedZPos do
      turtle.forward()
    end    
  end
  turtle.select(1)  
end

-- This will dump this turtles
-- Entire inventory in the chest in
-- Front of it.
-- set excludeItems to true to not input
-- torches and coal to the chest
function dumpInventory(excludeItemsUsed)
  for i=1,16 do
    turtle.select(i)
    local doDrop = true
    if (excludeItemsUsed) then
      local item = turtle.getItemDetail()
      if (item) then
        if (item.name == "minecraft:torch" or item.name == "minecraft:coal") then
          doDrop = false
        end
      end 
    end
    if (doDrop) then
      turtle.drop()
    end
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

function digDownUntilClear()
  while (turtle.inspectDown()) do
    turtle.digDown()
    sleep(0.25)
  end
end

local widthCovered = 1

while (true) do
  checkFuel()
  for i=1,depth do
    digForwardUntilClear()
    digUpUntilClear()
    digDownUntilClear()
    turtle.forward()
    zPos = zPos + 1
    checkFuel()
    inventoryManage()
  end
  digUpUntilClear()
  digDownUntilClear()
  -- Finished column
  -- Now go back all the way
  for i=1,depth do
    turtle.back()
    zPos = zPos - 1
    -- Torch placing
    if (useTorches) then
      if (xPos % 5 == 0 and zPos % 5 == 0) then
        turtle.select(2)
        turtle.placeDown()
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

dumpInventory(true)

-- Reset slot we are selecting
turtle.select(1)

print("Done!")