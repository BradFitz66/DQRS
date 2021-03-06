local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Walk")
local Grid = require ("Resources.lib.Rocket_Engine.Systems.jumper.grid")
local Pathfinder = require ("Resources.lib.Rocket_Engine.Systems.jumper.pathfinder") -- The pathfinder class 
State.Enter=function(owner)
	owner:load_tree("walk",true)
	owner.walkDest=1
end

State.Update=function(owner,dt)
	--Are we at the end of the path?
	if(owner.walkDest>#owner.current_path) then
		--Random chance to stretch. Ugly way to do it. Need to revise
		if(love.math.random(1,40)==32) then
			owner:change_state("Stretch")
		else
			owner:change_state("Idle")
		end
		--owner.move_vector=vector.zero
	end

	if(owner.current_path[owner.walkDest]~=nil)then
		local dist=owner.planar_position.dist(owner.planar_position,owner.current_path[owner.walkDest])
		if(dist<=4) then
			owner.walkDest=owner.walkDest+1
		end
	end
	local going_to_pos=owner.current_path[owner.walkDest]
	if(going_to_pos~=nil) then
		owner.move_vector=(going_to_pos-vector.new(owner.position.x,owner.position.z)):normalized()

		owner:set_position_planar(vector.new(
			owner.position.x+((owner.move_vector.x*owner.speed)*dt),
			owner.position.z+((owner.move_vector.y*owner.speed)*dt))
		);

		if(owner.move_vector~=vector.new(0,0))then
			--update animation tree vector so the correct directional animation is played
			owner.current_tree:set_vector(owner.move_vector:normalized())
		end
	end	
end


State.Exit=function(owner)
end


return State