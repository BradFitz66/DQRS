local tankshell={}
tankshell.__index=tankshell
local entity=require("Resources/scripts/Entity")
function tankshell.new()
    local ts=setmetatable({}, tankshell)
    ts.sprite=entity.new(10,5,10,10)
    ts.sprite.holdOffset=vector.new(-10,-10)
    ts.sprite.maxBounces=2
    ts.spriteImage=love.graphics.newImage("Resources/graphics/TankShell.png")
    ts.sprite.parent=ts
    ts.position=vector.new(256,300)
    ts.rotation=0
    ts.scale=vector.new(1,1)
    ts.type="ammo"
    ts.name="tankshell"
    ts.color={math.random(1,255)/255,math.random(1,255)/255,math.random(1,255)/255}
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
        for shape, delta in pairs(collider_world:collisions(self.sprite.collider)) do
            local absoluteDelta=vector.new(math.abs(delta.x),math.abs(delta.y))
            for _, actor in pairs(actors) do
                if(actor.sprite.collider==shape and actor.type=="ammo") then
                    local heightDiff = self.sprite.localPosition.y - actor.sprite.localPosition.y 
                    local speed=vector3.getLength(self.sprite.velocity)/16
                    if(actor.sprite.in_airr==false and not table.index_of(self.hitObjects,actor) and not actor.sprite.pickedUp and heightDiff <= 35 and speed>4) then
                        table.insert(self.hitObjects,actor)
                        table.insert(actor.hitObjects,self)
                        local initialVel = (vector3(self.sprite.velocity.x/2,self.sprite.velocity.z,0))
                        initialVel.z=initialVel.y;
                        initialVel.y=0;
                        initialVel=initialVel+vector3(0,3,0)
                        actor.sprite:add_force_xyzyz(initialVel)
                        timer.after(1,function()
                            table.clear(self.hitObjects)
                            table.clear(actor.hitObjects)
                        end)
                    end
                end
            end
            if(table.index_of(currentMap.map.colliderShapes,shape)~=nil and not self.wallHitDebounce and not (delta.x==0 and delta.y==0)) then
                self.position=self.position+vector.new(delta.x,delta.y)
                local cA=math.abs((math.round((math.deg(math.atan2(absoluteDelta.y,absoluteDelta.x))))))
                local hA=math.abs(math.round((math.deg(math.atan2(math.abs(self.sprite.velocity.z),math.abs(self.sprite.velocity.x))))))
                local rounded=round(cA)
                --Very ugly. This is the 'bounce rules' that determine whether the player cna bounce or not
                local canBounce = (rounded==90 and hA<=90) or (rounded==45 and hA== 45) or (rounded==0 and hA<=45)
                
                cA= cA==45 and -cA or cA
                --Here we check if there's a separation delta and if the angle of collision is divisible by 180 with no remainder or is within 10 degrees of it or 90 degrees (some flat wall aren't perfectly flat due to float precision)
                if(not canBounce) then
                    return
                end
                self.wallHitDebounce=true;
                local newDelta = vector.new(math.cos(math.rad(cA)),math.sin(math.rad(cA)))
                local y = -self.sprite.velocity.y;
                local startingSpeed = -self.sprite.velocity
                startingSpeed.y=y
                self.sprite.in_airr=false
                local wallHitNormal=vector.new(round_to_Nth_decimal(newDelta.y,1),round_to_Nth_decimal(newDelta.x,1)):normalized()
                local reflectionVector = startingSpeed:mirrorOn(vector3(wallHitNormal.y,0,wallHitNormal.x))
                self.sprite:add_force_xyzyz(reflectionVector)
                timer.after(.05,function()
                    self.wallHitDebounce=false;
                end)
            end
        end    
    end)
end

function tankshell:draw()
    love.graphics.setColor(self.color)
    love.graphics.draw(self.spriteImage,math.floor(self.sprite.position.x),math.floor(self.sprite.position.y),self.rotation,self.scale.x,self.scale.y,0,math.floor(self.spriteImage:getHeight()/2))
    self.sprite:draw()
    love.graphics.setColor(255,255,255)
end

return tankshell