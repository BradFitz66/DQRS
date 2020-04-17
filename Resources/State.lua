State={}
State.__index=State

function State.new(name)
	s=setmetatable({},State)
	s.Name=name and name or "UnnamedState"
	s.Enter=function(owner) end
	s.Update=function(owner,dt) end
	s.Exit=function(owner) end
	return s
end
return State
