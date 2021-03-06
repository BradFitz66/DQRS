local State = require("Resources.lib.Rocket_Engine.State Machine.State").new("Stretch")
State.Enter=function(owner)
	State.db=false
	State.org_pos=owner.position
	owner:load_tree("stretch",true,false)
	owner.current_tree.currentFrame=0
	owner.current_tree:set_vector(owner.move_vector)
end
local t=false
State.Update=function(owner,dt)
	if(owner.current_tree.current_animation.currentFrame==7) then
		if(State.db)then return end
		State.db=true
		timer.script(function(wait)
			for i=1,10 do
				if(owner.current_tree.name~="stretch")then
					break;
				end
				owner.current_tree.current_animation.paused=true
				t=not t
				owner.position.x = t and owner.position.x + 0.5 or owner.position.x + -0.5
				wait(.025)
			end
			owner:load_tree("stretch",true,false)
			owner:change_state("Idle")
			owner.current_tree.current_animation.paused=false
			owner.position.x = State.org_pos.x
			owner.position.z = State.org_pos.z
		end)
	end
end

State.Exit=function(owner)
end


return State