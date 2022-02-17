local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Walk")
local Grid = require ("Resources.lib.Rocket_Engine.Systems.jumper.grid")
local Pathfinder = require ("Resources.lib.Rocket_Engine.Systems.jumper.pathfinder") -- The pathfinder class 
State.Enter=function(owner)
	owner:load_tree("walk",true)
	owner.walkDest=1
	print("Length of path:",#owner.current_path,"At point",owner.walkDest)
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
	if(owner.current_path[owner.walkDest]~=nil and owner.position.dist(owner.position,owner.current_path[owner.walkDest])<1) then
		print("Length of path:",#owner.current_path,"At point",owner.walkDest)
		owner.walkDest=owner.walkDest+1
	end
	local going_to_pos=owner.current_path[owner.walkDest]
	if(going_to_pos~=nil) then
		owner.move_vector=(going_to_pos-owner.position):normalized()*owner.speed
		owner.position=owner.position + owner.move_vector * dt

		if(owner.move_vector~=vector.new(0,0))then
			--update animation tree vector so the correct directional animation is played
			owner.current_tree:set_vector(owner.move_vector:normalized())
		end
	end	
end

State.Exit=function(owner)
end


return State