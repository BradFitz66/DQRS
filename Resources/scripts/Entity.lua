--Base module for entities (players, ammo, enemies, etc)
local Entity={}
Entity.__index=Entity
function Entity.new(colliderPX,colliderPY,colliderSX,colliderSY)
    local e=setmetatable({},Entity)
    e.position=vector.new(0,0)
    e.localPosition=vector.new(0,0) --position when we have a parent
    e.groundPos=vector.new(0,0) --for keeping the relative ground position when the player is in the air
    e.velocity=vector3(0,0,0)
    e.startingVelocity=vector3(0,0,0)
    e.inAir=false -- is the entity in the air?
    e.bounciness=.7
    e.colliderSize=(colliderSX and colliderSY) and vector.new(colliderSX,colliderSY) or vector.new(0,0)
    e.colliderPos=vector.new(colliderPX or 0,colliderPY or 0)
    e.collider=colliderWorld:rectangle(0,0,colliderSX or 20,colliderSY or 20)
    e.maxBounces=0;
    e.bouncesLeft=0;
    e.parent=nil
    e.name=""
    e.ZValue=0
    e.holdOffset=vector.new(0,0)
    e.pickedUp=false;
    e.canPickup=true;
    return e
end

function Entity:AddForce(y)
    if(self.inAir)then
        return;
    end
    self.inAir = true;
    self.startingVelocity =vector3(0,y,0)
    self.velocity=vector3(0,y,0)
    self.bouncesLeft=self.maxBounces
end

function Entity:AddForceXYZ(vec)
    if(self.inAir)then
        return;
    end
    self.inAir = true;
    self.startingVelocity=vec
    self.velocity=vec
    self.bouncesLeft=self.maxBounces
end

function math.Clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function Entity:draw()
    if(debug) then
        love.graphics.setColor(0,255,0)
        self.collider:draw("line")
        love.graphics.setColor(255,255,255)
    end
end



function Entity:update(dt,collisionOverride)
    
    if(self.parent==nil) then
        self.position = self.position + self.velocity * dt;
        self.collider:moveTo(self.position.x,self.position.y)
    else
        self.position=(self.parent.position+-self.localPosition)
        
        self.localPosition=(self.localPosition+vector.new(0,self.velocity.y));
        self.collider:moveTo(((math.round(self.parent.position.x+self.colliderPos.x))),((math.round(self.parent.position.y+self.colliderPos.y))))
        --self.collider:setRotation((self.parent.rotation))
    end

    if(self.inAir and (self.bouncesLeft > 0 and self.velocity.y ~= 0)) then
        self.velocity = self.velocity + vector3(0, -9.81, 0) * dt;
        local BounceDelta = vector.new(0,1) * self.velocity.y * dt;
        local Xdelta = ((vector3(1,0,0) * self.velocity.x) + (vector3(0,1,0) * self.velocity.z));
        if ((self.localPosition + BounceDelta).y <= 0) then
            
            --we hit the ground
            self.velocity.y = self.velocity.y * -1
            self.velocity.y = self.velocity.y*self.bounciness;
            self.velocity.x = self.velocity.x - (self.startingVelocity.x / self.maxBounces);
            self.velocity.z = self.velocity.z - (self.startingVelocity.z / self.maxBounces);

            --pos += Vector3.up * self.velocity * Time.deltaTime;
            self.bouncesLeft = self.bouncesLeft - 1;
        end
        local spritePos = self.localPosition + BounceDelta * dt;
        spritePos.y = math.Clamp(spritePos.y, 0, math.huge);
        local mainPos = self.parent.position + vector.new(Xdelta.x,Xdelta.y)*dt;
        
        self.localPosition = spritePos;
        self.parent.position = mainPos;
    else
        self.inAir=false
        self.velocity=vector3(0,0,0)
        self.localPosition=vector.new(0,0)
    end
    if(self.pickedUp) then
        return
    end
    self.ZValue=self.position.y+self.localPosition.y
    if(collisionOverride~=nil) then
        collisionOverride()
    else
        for shape, delta in pairs(colliderWorld:collisions(self.collider)) do
            if(table.index_of(currentMap.map.colliderShapes,shape)~=nil) then
                self.parent.position=self.parent.position+vector.new(delta.x,delta.y)
            end
        end
    end
end

return Entity