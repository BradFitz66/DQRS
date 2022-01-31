local StateMachine={}
StateMachine.__index=StateMachine

---Create a new statemachine. This is meant for AI or similar and an owner must be specified (used to get external variables)
---@param owner table
---@return table
function StateMachine.new(owner)
	local sM=setmetatable({},StateMachine)
	sM.current_state=nil
	sM.owner=owner~=nil and owner or error("Owner is null")
	sM.states={}
	return sM
end
---Add a new state
---@param new_state table
---@return table
function StateMachine:add_state(new_state)
	if(new_state.Enter==nil or new_state.Update==nil or new_state.Exit==nil)then
		error("Given state is invalid. Make sure the state is a valid state")
	end
	self.states[new_state.Name]=new_state
	return new_state
end

---Change current state
---@param changing_to table
function StateMachine:change_state(changing_to)
	if(self.states[changing_to]~=nil) then
		if(self.current_state~=nil) then
			if(self.current_state.Name==changing_to)then
				return;
			end	
			self.current_state.Exit(self.owner)
		end
		self.current_state=self.states[changing_to]
		self.current_state.Enter(self.owner)
	else
		error("Couldn't not find state "..changing_to..". Make sure the state is a valid state of this statemachine (add it with StateMachine:add_state)")
	end
end
---Update statemachine and current running state
---@param dt number
function StateMachine:update(dt)
	if(self.current_state~=nil) then
		self.current_state.Update(self.owner,dt)
	end
end



return StateMachine