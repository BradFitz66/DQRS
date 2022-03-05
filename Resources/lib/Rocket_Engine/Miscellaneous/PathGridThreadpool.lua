--Code mostly from: https://github.com/speakk/overseer/tree/6b631e8189507b6705eba529ce67522dd9ecd5ea

require("love.system")
local processorCount = love.system.getProcessorCount()
local threadPool = {}
local currentPoolIndex = 1

local function initializePoolfunction()
	for _ = 1, processorCount do
		local thread = love.thread.newThread("PathGridThread.lua")
		local channelMain = love.thread.newChannel()
		local channelThread = love.thread.newChannel()
		table.insert(threadPool, {
			thread = thread,
			channelMain = channelMain,
			channelThread = channelThread
		})
		thread:start(channelMain, channelThread)
	end
end

local function getNextAvailableThreadObjectfunction()
	local threadObject = threadPool[currentPoolIndex]
	currentPoolIndex = currentPoolIndex + 1
	if currentPoolIndex > (#threadPool) then
		currentPoolIndex = 1
	end
	return threadObject
end

local function getPathThreadfunction(map, fromX, fromY, toX, toY, searchNeighbours)
	local threadObject = getNextAvailableThreadObject()
	threadObject.channelMain:push()
	return threadObject
end

return {
	getPathThread = getPathThread,
	initializePool = initializePool
}
