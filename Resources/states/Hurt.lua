local State = require("Resources.scripts.State").new("Hurt")
local db=false;
State.Enter=function(owner)
    if(owner.sprite.inAir==false) then
        owner:changeState("Idle")
        return
    end
    owner:loadTree("hurt",true)
    print(vector.new(owner.sprite.velocity.x,owner.sprite.velocity.z):normalized())
    owner.currentTree.vector=vector.new(owner.sprite.velocity.x,owner.sprite.velocity.z):normalized()
    db=false
end

State.Update=function(owner,dt)
    if(owner.sprite.inAir==false) then
        timer.after(.25,function()
            if(db==true)then return end 
            db=true
            owner:changeState("Idle")
        end)
    end
end

State.Exit=function(owner) 

end


return State
