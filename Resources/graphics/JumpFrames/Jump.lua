local jumpAnim={
	frameAmount=7, --frame for each animation
	path="Resources/graphics/JumpFrames", -- path to frames
	animations={
		{1,10}, -- start and end frame index
		{11,20},
		{21,30},
		{31,40},
		{41,50},
		{51,60},
		{61,70},
		{71,80}
	}, --empty table to store the frames(each file)
	frames={},
	animIndex=1, -- current animation index. 
	frameIndex=1 -- current frame index
	frameDelta=0;
	play=function(this)
		if(this.loop) then
			
		else
			local curAnimation=this.animations[this.animIndex]
			local startFrame,endFrame=curAnimation[1],curAnimation[2]
			local amountOfFrames=(curAnimation[2]-curAnimation[1])+1
			for startFrame,endFrame do
				frameIndex=
			end
		end
	end,
	onEnd=function(this)
			
	end
}

function loadAnimation()
	local frames = love.filesystem.getDirectoryItems(jumpAnim.path)
	
	table.sort(frames,
	function(a,b) 
		local num1 = tonumber(string.sub(a,0,-5))
		local num2 = tonumber(string.sub(b,0,-5))
		return num1<num2
	end)
	
	for i,v in pairs(frames) do
		table.insert(jumpAnim.frames,love.graphics.newImage(jumpAnim.path.."/"..v))
	end
	return jumpAnim
end

return loadAnimation()