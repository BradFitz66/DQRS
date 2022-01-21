local State={}
State.__index=State

---Create a new state
---@param name string
---@return table
function State.new(name)
	local s=setmetatable({},State)
	s.Name=name and name or "UnnamedState"
	s.Enter=function(owner) end
	s.Update=function(owner,dt) end
	s.Exit=function(owner) end
	return s
end



return State
