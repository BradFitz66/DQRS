local tankshell={}
tankshell.__index=tankshell
local entity=require("Resources/scripts/Entity")
function tankshell.new()
    local ts=setmetatable({}, tankshell)
    ts.sprite=entity.new(10,5,10,10)
    ts.sprite.maxBounces=2
    ts.spriteImage=love.graphics.newImage("Resources/graphics/TankShell.png")
    ts.sprite.parent=ts
    ts.position=vector.new(256,300)
    ts.rotation=0
    ts.scale=vector.new(1,1)
    ts.type="ammo"
    ts.name="tankshell"
    ts.wallHitDebounce=false
    ts.hitObjects={}
    return ts
end

--!AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
local validDiffs ={

}
local halfRotations={
	45,
	225,
	135
}

function tankshell:update(dt)
    self.sprite:update(dt,function()
        for shape, delta in pairs(colliderWorld:collisions(self.sprite.collider)) do
            -- for _, actor in pairs(actors) do
            --     if(actor.sprite.collider==shape and actor.type=="ammo") then
            --         local heightDiff = self.sprite.localPosition.y - actor.sprite.localPosition.y 
            --         print("Height diff: "..tostring(heightDiff))
            --         if(actor.sprite.inAir==false and not table.index_of(self.hitObjects,actor)) then
            --             table.insert(self.hitObjects,actor)
            --             table.insert(actor.hitObjects,self)
            --             local initialVel = (vector3(self.sprite.velocity.x/2,self.sprite.velocity.z,0))
            --             initialVel.z=initialVel.y;
            --             initialVel.y=0;
            --             initialVel=initialVel+vector3(0,2+self.sprite.velocity:len(),0)
            --             actor.sprite:AddForceXYZ(initialVel)
            --         end
            --     end
            -- end
            if(contains(currentMap.map.colliderShapes,shape) and not self.wallHitDebounce and not (delta.x==0 and delta.y==0)) then
                local collisionAngle=(math.round((math.deg(math.atan2(delta.y,delta.x)))))
                local headingAngle=math.round((math.deg(math.atan2(self.sprite.velocity.x,self.sprite.velocity.z))))
                print("headingAngle:"..headingAngle)
                local isHalfRotation=contains(halfRotations,math.abs(headingAngle))
                --Here we check if there's a separation delta and if the angle of collision is divisible by 180 with no remainder or is within 10 degrees of it or 90 degrees (some flat wall aren't perfectly flat due to float precision)
                self.position=self.position+vector.new(delta.x,delta.y)
                if(not isHalfRotation) then
                    if(contains(halfRotations,math.abs(collisionAngle))) then
                        break;
                    end
                    self.wallHitDebounce=true
                    local y = -self.sprite.velocity.y;
                    local startingSpeed = -self.sprite.velocity
                    startingSpeed.y=y
                    self.sprite.inAir=false
                    local wallHitNormal=vector.new(roundToNthDecimal(delta.y,1),roundToNthDecimal(delta.x,1)):normalized()
                    local reflectionVector = startingSpeed:mirrorOn(vector3(wallHitNormal.y,0,wallHitNormal.x))
                    self.sprite:AddForceXYZ(reflectionVector)
                    timer.after(.1,function()
                        self.wallHitDebounce=false;
                    end)            		
                end
            end
        end    
    end)
end

function tankshell:draw()
    love.graphics.draw(self.spriteImage,self.sprite.position.x,self.sprite.position.y,self.rotation,self.scale.x,self.scale.y,0,self.spriteImage:getHeight()/2)
    self.sprite:draw()
end

return tankshell