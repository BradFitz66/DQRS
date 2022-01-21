local Blendtree={}
Blendtree.__index=Blendtree

function Blendtree.new(blend_tree_animations,blend_tree_vector,Name,owner,start_event,end_event,loop,persist_frame)
    local bT=setmetatable({},Blendtree)
    bT.animations=blend_tree_animations
    bT.name=Name
    bT.persist_frame = persist_frame --Persist frame means that when we switch between two animations in the blendtree, the animation frame should stay the same (eg: if we switch between two walk animation directions at frame 4, the animation we switch to will be at frame 4)
    bT.vector=vector.new(0,-1)
    bT.last_vector=bT.vector
    bT.current_animation=bT.animations[1][1]
    bT.current_animation:setPauseAtEnd(not loop)
    bT.current_animation:setLooping(loop)
    bT.start_event=start_event and start_event or function() end
    bT.owner=owner
    bT.end_event= end_event and end_event or function() end
    bT.current_animation:setOnAnimationEnd(bT.end_event)
    bT.loopAnim=loop;
    bT.frame_offset=bT.animations[1][3]
    bT.switch_animation_flag=false
    return bT
end

function Blendtree:set_vector(new_vector)
    if(new_vector~=vector.new(0,0) and new_vector~=self.vector) then
        self.last_vector=self.vector
        self.vector=new_vector
        self.switch_animation_flag=true;
    end
end

function Blendtree:update(dt)
    self.last_vector=self.last_vector:normalized()
    self.vector=self.vector:normalized()
    if(self.switch_animation_flag) then
        self.switch_animation_flag=false
        self.last_vector=self.vector
        local vector_table={}
        for _, v in pairs(self.animations) do
            table.insert(vector_table,v);
        end
        table.sort(vector_table,function(a,b)
            return (a[2].dist2(a[2],self.vector))<(b[2].dist2(b[2],self.vector)) 
        end)
        

        local frames = #self.current_animation.frames
        local frame = self.current_animation:getFrame()
        local delay_timer = self.current_animation.delayTimer
        local prev_anim=self.current_animation;
        --Switch to new animation
        self.current_animation=vector_table[1][1]
        --Offset from the origin of the sprite when drawing 
        self.frame_offset=vector_table[1][3]
        self.current_animation:setLooping(self.loopAnim)
        self.current_animation:setPauseAtEnd(not self.loopAnim)
        self.current_animation:setOnAnimationEnd(self.end_event)
        if(frame==1)then
            self.current_animation:onLoop()
        end
        self.current_animation:setFrame(frame)
        self.current_animation.delayTimer=delay_timer
    end
    self.current_animation:update(dt)
end

function cosine_sim(a, b)
    local dotProduct = vector.dot(a, b);
    local norm1 = math.sqrt(vector.dot(a, a));
    local norm2 = math.sqrt(vector.dot(b, b));

    return dotProduct / (norm1 * norm2);
end

return Blendtree