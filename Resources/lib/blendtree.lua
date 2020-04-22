local Blendtree={}
Blendtree.__index=Blendtree

function Blendtree.new(BlendTreeAnimations,BlendTreeVector,Name,owner,StartEvent,EndEvent,loop)
    local bT=setmetatable({},Blendtree)
    bT.animations=BlendTreeAnimations
    bT.name=Name
    bT.vector=vector.new(0,0)
    bT.lastvector=bT.vector
    bT.currentAnimation=bT.animations[1][1]
    bT.currentAnimation:setPauseAtEnd(not loop)
    bT.currentAnimation:setLooping(loop)
    bT.startEvent=StartEvent and StartEvent or function() print("Ended") end
    bT.owner=owner
    bT.endEvent= function() print("Ended") end
    bT.currentAnimation:setOnAnimationEnd(bT.endEvent)
    bT.loopAnim=loop;
    return bT
end

function Blendtree:draw()

end



function Blendtree:update(dt)
    if(self.lastvector~=self.vector) then
        self.lastvector=self.vector
        local VectorTable={}
        for _, v in pairs(self.animations) do
            table.insert(VectorTable,v);
        end
        table.sort(VectorTable,function(a,b)
            return (a[2].dist2(a[2],self.vector))<(b[2].dist2(b[2],self.vector)) 
        end)
        --No difference between top and bottom sorting algorithm (although I have to change less than to greater than). Bottom might even be slower due to the use of square root
        -- table.sort(VectorTable,function(a,b)
        --     return (CosineSim(a[2],self.vector))>(CosineSim(b[2],self.vector)) 
        -- end)
        local frames = #self.currentAnimation.frames
        local frame = self.currentAnimation:getFrame()+1 < frames and self.currentAnimation:getFrame()+1 or 1
        local prevAnim=self.currentAnimation;
        self.currentAnimation=VectorTable[1][1]
        self.currentAnimation:setLooping(self.loopAnim)
        self.currentAnimation:setPauseAtEnd(not self.loopAnim)
        print("Pause at end on "..self.name..": "..tostring(self.currentAnimation:getPauseAtEnd()))
        self.currentAnimation:setOnAnimationEnd(self.endEvent)
        if(frame==1)then
            self.currentAnimation:onLoop()
        end
        self.currentAnimation:setFrame(frame)
    end
    self.currentAnimation:update(dt)
end   
function CosineSim(a, b)

    local dotProduct = vector.dot(a, b);
    local norm1 = math.sqrt(vector.dot(a, a));
    local norm2 = math.sqrt(vector.dot(b, b));

    return dotProduct / (norm1 * norm2);
end

return Blendtree