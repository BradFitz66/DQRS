local State = require("Resources.scripts.State").new("Stretch")
local startScale=vector.new(1.1,.37);
local endScale=vector.new(1,1)
local angle,normamlTar,target,finalSpeed,newSpeed,distance,rX,rY
local obstruction=false;
State.Enter=function(owner)
    owner:loadTree("stretch",true)
    owner.scale=startScale
    local target= owner.position+owner.moveVector;
    local normalTar = (target - owner.position):normalized();
    angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --! 1/(math.pi * 2 / 360);
    owner.rotation=angle
end

State.Update=function(owner,dt) 
    if (owner.moveVector ~= vector.new(0,0)) then
        owner.currentTree.vector = owner.moveVector

        scaleProper=vector.new(owner.scale.x,(owner.scale.y+.5)*32)
        distance=owner.scale.dist(owner.scale,endScale);
        newSpeed = 1.5;
        finalSpeed = (distance / newSpeed);
        target= owner.position+owner.moveVector;
        -- get the angle
        normalTar = (target - owner.position):normalized();
        angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --* 1/(math.pi * 2 / 360);
        rX,rY=rotate_point(owner.position.x,owner.position.y,40*owner.scale.y,(angle-math.rad(90)))
    

        owner.headPosition=vector.new(owner.position.x,(owner.position.y + 40*owner.scale.y))
        --rotate the headCollider and check for obstruction before rotating the actual player. This avoids the player being able to rotate into walls
        owner.headPosition.x=rX
        owner.headPosition.y=rY
        owner.headCollider:moveTo(owner.headPosition.x,owner.headPosition.y)
    
        obstruction=false

        for _, v in pairs(currentMap.map.colliderShapes) do
            if(owner.headCollider:collidesWith(v))then
                obstruction=true;
            end
        end

        if(not obstruction) then
            owner.scale = vector.Lerp(owner.scale, endScale, dt/finalSpeed);
            -- rotate to angle
            owner.rotation = angle;
        end

    else
        local distance = owner.scale.dist(owner.scale,startScale);
        local newSpeed = 1.5;
        local finalSpeed = (distance / newSpeed);
        
        angle = math.atan2(normalTar.y, normalTar.x) + math.rad(90) --* 1/(math.pi * 2 / 360);
        rX,rY=rotate_point(owner.position.x,owner.position.y,40*owner.scale.y,(angle-math.rad(90)))

        owner.headPosition=vector.new(owner.position.x,(owner.position.y + 40*owner.scale.y))
        --rotate the headCollider and check for obstruction before rotating the actual player. This avoids the player being able to rotate into walls
        owner.headPosition.x=rX
        owner.headPosition.y=rY
        owner.headCollider:moveTo(owner.headPosition.x,owner.headPosition.y)
        
        owner.scale = vector.Lerp(owner.scale, startScale, dt / finalSpeed);
        headPosition=owner.position-scaleProper:rotated(owner.rotation);
        --State.collider:moveTo(headPosition.x,headPosition.y)

        if (owner.scale.dist(owner.scale,startScale)<=0.005) then
            owner.rotation=0
            owner.scale=vector.new(1,1)
            owner:changeState("Squished")
        end
    end
    if (owner.input:released("jump"))then
    
        --So rocket slime's full stretch elastoblast (not a charged one) moves the player 267 pixels roughly which translates to about 16 unity units (267/16) so that's what I'm basing this off of.

        --Scale the full power elastoblast by how much the player stretched
        local maxPower = vector.new(0, 9*16);
        local mag = maxPower:len();
        local maxPowerAligned=maxPower:rotated(owner.rotation);
        maxPowerAligned = -maxPowerAligned;
        owner.blastVelocity = vector.Lerp(vector.new(0,0), maxPowerAligned, (owner.scale - startScale):len() / (endScale - startScale):len());
        --print("Blast velocity: "..tostring(owner.blastVelocity))
        owner:changeState("Blasting")
        
    end
end

State.Exit=function(owner)
    owner.rotation=0
    owner.scale=vector.new(1,1)
    owner.headCollider:moveTo(-1000000,-10000000)
    --State.collider:moveTo(-1000000,-10000000)
end


return State