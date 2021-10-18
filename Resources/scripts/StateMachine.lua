local StateMachine={}
StateMachine.__index=StateMachine


function StateMachine.new(owner)
	local sM=setmetatable({},StateMachine)
	sM.currentState=nil
	sM.owner=owner~=nil and owner or error("Owner is null")
	sM.states={}
	return sM
end

function StateMachine:addState(newState)
	if(newState.Enter==nil or newState.Update==nil or newState.Exit==nil)then
		error("Given state is invalid. Make sure the state is a valid state")
	end
	self.states[newState.Name]=newState
	return newState
end

function StateMachine:changeState(changingTo)
	if(self.states[changingTo]~=nil) then
		if(self.currentState~=nil) then
			if(self.currentState.Name==changingTo)then
				return;
			end	
			self.currentState.Exit(self.owner)
		end
		self.currentState=self.states[changingTo]
		self.currentState.Enter(self.owner)
	else
		error("Couldn't not find state "..changingTo..". Make sure the state is a valid state of this statemachine (add it with StateMachine:addState)")
	end
end

function StateMachine:update(dt)
	if(self.currentState~=nil) then
		self.currentState.Update(self.owner,dt)
	end
end



return StateMachine