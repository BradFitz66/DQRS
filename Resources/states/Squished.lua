local State = require("Resources.scripts.State").new("Squished")
State.Enter=function(owner)
	owner.sprite.inAir=false;
    owner.sprite.localPosition=vector.zero
    owner:loadTree("squished",true)
    local t = true
    timer.script(function(wait)
        for i=1,5 do
            if(owner.currentTree.name~="squished")then
                break;
            end
            t=not t
            wait(.025)
            owner.sprite.localPosition.x = t and 2*owner.currentTree.vector.x or -2*owner.currentTree.vector.x
            owner.sprite.localPosition.y = t and 2*owner.currentTree.vector.y or -2*owner.currentTree.vector.y
        end
        owner.sprite.localPosition.x = 0
        owner.sprite.localPosition.y  = 0
    end)
    --owner.currentTree.currentAnimation:setPaused(true)
end

State.Update=function(owner,dt) 
	if(owner.moveVector~=vector.zero)then
		print("!!!")
		owner.statemachine:changeState("Stretch")
	end
end

State.Exit=function(owner) 
end


return State