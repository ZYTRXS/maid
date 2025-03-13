--!strict
--[[
-- @ZYTRXS

Maid Class
Useful for working with temporary objects or classes.

Maid:GiveTask(...) supports the following:

- RBXScriptConnection (Disconnected on cleanup)
- Instance (Destroyed on cleanup)
- Function (Called on cleanup)
- Class/Table with :Destroy() method (:Destroy() method called on cleanup)
- Maid (:CleanUp() method called, meaning you can nest Maids!)
- Signals (Because Winbloo likes using those, they're supported as well!)
  - Note for Signals; disable the strict metatable checking for Signal internally, otherwise they'll error when Maid tries checking for possible cleanup methods.
- Threads
]]

export type _MaidPrototype = {
	__index: _MaidPrototype,
	
	--PUBLIC:
	new: () -> Maid,
	
	GiveTask: (self: Maid, _task: MaidTask) -> (),
	CleanUp: (self: Maid) -> (),
	
	--PRIVATE:
}

export type Maid = typeof(setmetatable({}::{
	Tasks: {MaidTask},
}, {}::_MaidPrototype))

export type MaidTask = RBXScriptConnection|(any)->(any)|Instance|{Destroy: (any)->(any)}|Maid|{Disconnect: (any)->(any)}

local Maid: _MaidPrototype = {}::_MaidPrototype
Maid.__index = Maid

-- Creates a new maid class.
function Maid.new(): Maid
	local self: Maid = setmetatable({}, Maid)::Maid
	
	self.Tasks = {}
	
	return self
end

-- Gives the Maid a task to clean up when :CleanUp() is initiated.
function Maid:GiveTask(_task: MaidTask)
	if typeof(_task)=="table" and not _task.Destroy and not _task.CleanUp and not _task.Disconnect and not _task.DisconnectAll then
		error("Invalid MaidTask, class/table must contain at least one of the following methods for cleanup: :Destroy(), :CleanUp(), :DisconnectAll() or :Disconnect().")
		return
	end
	
	table.insert(self.Tasks, _task)
end

-- Cleans up all current tasks, can still be reused after this operation.
function Maid:CleanUp()
	for _, _task: MaidTask in pairs(self.Tasks) do
		
		if typeof(_task)=="function" then
			_task()
		elseif typeof(_task)=="RBXScriptConnection" then
			_task:Disconnect()
		elseif typeof(_task)=="Instance" then
			_task:Destroy()
		elseif typeof(_task)=="thread" then
			task.cancel(_task)
		else
			if _task.Destroy then
				_task:Destroy()
			end
			
			if _task.CleanUp then
				_task:CleanUp()
			end
			
			if _task.Disconnect then
				_task:Disconnect()
			end

			if _task.DisconnectAll then
				_task:DisconnectAll()
			end
		end
		
	end
	
	table.clear(self.Tasks)
end

return Maid
