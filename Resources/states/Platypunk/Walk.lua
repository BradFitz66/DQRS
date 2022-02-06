local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Walk")
local Grid = require ("Resources.lib.Rocket_Engine.Systems.jumper.grid")
local Pathfinder = require ("Resources.lib.Rocket_Engine.Systems.jumper.pathfinder") -- The pathfinder class 
State.Enter=function(owner)
	owner:load_tree("walk",false,false)
	
end

State.Update=function(owner,dt)
	if(owner.position.dist(owner.position,owner.walkDest)<1) then
		if(love.math.random(1,40)==32) then
			owner:change_state("Stretch")
		else
			owner:change_state("Idle")
		end
	end
	owner.move_vectorrr=(owner.walkDest-owner.position):normalized()*owner.speed
	owner.position=owner.position + owner.move_vectorrr * dt
	if(owner.move_vectorrr~=vector.new(0,0))then
		owner.current_tree:set_vector(owner.move_vectorrr:normalized())
	end
end

State.Exit=function(owner)
end


return State