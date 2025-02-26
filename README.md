# maid
Simple maid for roblox LuaU with easy to understand documentation

This was made specifically for [Timebomb Madness](https://timebombmadness.com/) but since it's so versatile I decided to upload it here for future use.

## Usage

Example code:
```luau

-- Making random throwaway objects to let the maid clean up
local instance = Instance.new("Part")
instance.Parent = workspace

local func = function()
  print("function called")
end

local customClass = {}
function customClass:Destroy() -- :Disconnect() works too, as well as :CleanUp() (for maid nesting)
  print("class destroy method called")
end

local connection = workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
  print("new workspace gravity: "..tostring(workspace.Gravity))
end)

-- Maid
local Maid = require(pathtomaid)

local newMaid = Maid.new()

newMaid:GiveTask(instance)
newMaid:GiveTask(func)
newMaid:GiveTask(customClass)
newMaid:GiveTask(connection)

task.wait(1)

workspace.Gravity = 100 -- triggers gravity connection

task.wait(1)

newMaid:CleanUp()

task.wait(1)

workspace.Gravity = 125 -- does not trigger gravity connection, as it was disconnected by the Maid instance

-- output:
-- new workspace gravity: 100
-- function called
-- class destroy method called

-- (the instance inside of workspace was destroyed as well)
```

## Why use this over (insert other maid module here)?

That is for you to decide. I uploaded this here for my own sake.
