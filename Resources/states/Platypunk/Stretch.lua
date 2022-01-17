local State = require("Resources.scripts.State").new("Stretch")
local db=false;
State.Enter=function(owner)
	owner:loadTree("stretch",true,false)
	owner.currentTree.currentFrame=0
	owner.currentTree.vector=owner.moveVector
	db=false
end
local t=false
State.Update=function(owner,dt)
	if(owner.currentTree.currentAnimation.currentFrame==7) then
		if(db)then return end
		db=true
		
		timer.script(function(wait)
			for i=1,10 do
				if(owner.currentTree.name~="stretch")then
					break;
				end
				owner.currentTree.currentAnimation.paused=true
				t=not t
				local treeVec =owner.currentTree.vector
				owner.sprite.localPosition.x = t and 0.5 or -0.5
				wait(.025)

			end
			owner:loadTree("stretch",true,false)
			owner:changeState("Idle")
			owner.currentTree.currentAnimation.paused=false
			owner.sprite.localPosition.x = 0
			owner.sprite.localPosition.y  = 0
		end)
	end
end

State.Exit=function(owner)
end


return State