local State = require("Resources.scripts.State").new("Stretch")
local db=false;
State.Enter=function(owner)
	owner:load_tree("stretch",true,false)
	owner.current_tree.currentFrame=0
	owner.current_tree:setVector(owner.move_vectorr)
	db=false
end
local t=false
State.Update=function(owner,dt)
	if(owner.current_tree.current_animation.currentFrame==7) then
		if(db)then return end
		db=true
		
		timer.script(function(wait)
			for i=1,10 do
				if(owner.current_tree.name~="stretch")then
					break;
				end
				owner.current_tree.current_animation.paused=true
				t=not t
				owner.sprite.localPosition.x = t and 0.5 or -0.5
				wait(.025)
			end
			owner:load_tree("stretch",true,false)
			owner:change_state("Idle")
			owner.current_tree.current_animation.paused=false
			owner.sprite.localPosition.x = 0
			owner.sprite.localPosition.y  = 0
		end)
	end
end

State.Exit=function(owner)
end


return State