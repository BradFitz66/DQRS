--[[
    Tank shell. Basic ammo type for testing.

    May create a specific base class ontop of entity for ammo pieces.
]]
local ammo=require("Resources.lib.Rocket_Engine.Objects.Ammo")
local shuriken_ammo=class("Tank_Shell",ammo)

function shuriken_ammo:initialize(start_pos,collider_pos,collider_size)
    ammo.initialize(self,start_pos,collider_pos,collider_size)
    self.hold_offset=vector.new(-10,-5)
    self.type="ammo"
    self.can_pickup=true
    self.picked_up=false
    self.name="shuriken"
    self.going_into_cannon=false
    self.bounciness=0.3
    self.max_bounces=2
    self.sprite_image=love.graphics.newImage("Resources/graphics/Shuriken.png")
    self.rotation=0
    self.scale=vector.new(1,1)
    self.color={math.random(1,255)/255,math.random(1,255)/255,math.random(1,255)/255}
    self.wall_hit_debounce=false
    self.hitObjects={}
    self.damage=16
    self.rank=2
    return self
end

function shuriken_ammo:handle_collision(dt)
    if(not self.picked_up) then
        ammo.handle_collision(self,dt)
    end
    --Handle collision with player
    if(self.physics_data.collider:collidesWith(player.physics_data.collider)) then
		if(player.statemachine.current_state.Name=="Blasting" and not self.hit_debounce and self.held_by==nil) then
			local normalizedBlast=player.blast_velocity:normalized()
			self.can_pickup=false
			local initialVel = (vector3(player.blast_velocity.x,player.blast_velocity.y,0))
			initialVel.z=initialVel.y;
			initialVel.y=0;
			initialVel=initialVel+vector3(0,3,0)
			self:add_force(initialVel)
			hit_debounce=true
			timer.after(.7,function() hit_debounce=false self.can_pickup=true end)
		end
	end
end

function shuriken_ammo:update(dt)
    ammo.update(self,dt)
    --Old collision code (will be reworked and reimplemented at some point)

    -- self.sprite:update(dt,nil--[[function()
    --     for shape, delta in pairs(collider_world:collisions(self.sprite.collider)) do
    --         local absoluteDelta=vector.new(math.abs(delta.x),math.abs(delta.y))
    --         for _, actor in pairs(actors) do
    --             if(actor.sprite.collider==shape and actor.type=="ammo") then
    --                 local heightDiff = self.sprite.local_position.y - actor.sprite.local_position.y 
    --                 local speed=vector3.getLength(self.sprite.velocity)/16
    --                 if(actor.sprite.physics_data.in_air==false and not table.index_of(self.hitObjects,actor) and not actor.sprite.picked_up and heightDiff <= 35 and speed>4) then
    --                     table.insert(self.hitObjects,actor)
    --                     table.insert(actor.hitObjects,self)
    --                     local initialVel = (vector3(self.sprite.velocity.x/2,self.sprite.velocity.z,0))
    --                     initialVel.z=initialVel.y;
    --                     initialVel.y=0;
    --                     initialVel=initialVel+vector3(0,3,0)
    --                     actor.sprite:add_force_xyz(initialVel)
    --                     timer.after(1,function()
    --                         table.clear(self.hitObjects)
    --                         table.clear(actor.hitObjects)
    --                     end)
    --                 end
    --             end
    --         end
    --         if(table.index_of(currentMap.map.collider_shapes,shape)~=nil and not self.wall_hit_debounce and not (delta.x==0 and delta.y==0)) then
    --             self.position=self.position+vector.new(delta.x,delta.y)
    --             local cA=math.abs((math.round((math.deg(math.atan2(absoluteDelta.y,absoluteDelta.x))))))
    --             local hA=math.abs(math.round((math.deg(math.atan2(math.abs(self.sprite.velocity.z),math.abs(self.sprite.velocity.x))))))
    --             local rounded=round(cA)
    --             --Very ugly. This is the 'bounce rules' that determine whether the player cna bounce or not
    --             local can_bounce = (rounded==90 and hA<=90) or (rounded==45 and hA== 45) or (rounded==0 and hA<=45)
                
    --             cA= cA==45 and -cA or cA
    --             --Here we check if there's a separation delta and if the angle of collision is divisible by 180 with no remainder or is within 10 degrees of it or 90 degrees (some flat wall aren't perfectly flat due to float precision)
    --             if(not can_bounce) then
    --                 return
    --             end
    --             self.wall_hit_debounce=true;
    --             local newDelta = vector.new(math.cos(math.rad(cA)),math.sin(math.rad(cA)))
    --             local y = -self.sprite.velocity.y;
    --             local startingSpeed = -self.sprite.velocity
    --             startingSpeed.y=y
    --             self.sprite.physics_data.in_air=false
    --             local wallHitNormal=vector.new(round_to_Nth_decimal(newDelta.y,1),round_to_Nth_decimal(newDelta.x,1)):normalized()
    --             local reflectionVector = startingSpeed:mirrorOn(vector3(wallHitNormal.y,0,wallHitNormal.x))
    --             self.sprite:add_force_xyz(reflectionVector)
    --             timer.after(.05,function()
    --                 self.wall_hit_debounce=false;
    --             end)
    --         end
    --     end    
    -- end--]])
end

function shuriken_ammo:draw()
    if(debug_mode) then
		love.graphics.setColor(0,1,0,.5)
		self.physics_data.collider:draw("fill")
	end

    love.graphics.setColor(self.color)
    love.graphics.draw(self.sprite_image,math.floor(self.position.x),math.floor(self.position.z-self.position.y),self.rotation,self.scale.x,self.scale.y,0,math.floor(self.sprite_image:getHeight()/2))
    love.graphics.setColor(255,255,255)
end

return shuriken_ammo