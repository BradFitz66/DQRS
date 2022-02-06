local pathfinding_grid={
}

function pathfinding_grid:bake(width,height,grid_size)
    self.baked_grid={
    }
    local grid_cell_size=grid_size or 8
    for x=1,width,grid_cell_size do
        self.baked_grid[x]={}
        for y=1,height,grid_cell_size do
            local passable=collider_world:hash():inSameCells(x,y,x+grid_cell_size,y+grid_cell_size)
            if(passable~=nil)then
                for _, collider in pairs(passable) do
                    --Only consider colliders than aren't attached to the player/ammo/NPCs and also aren't triggers
                    if not (collider.attached_to ~= nil or (collider.flags and collider.flags.trigger)) then
                        self.baked_grid[x][y]=1 --1 means non-passable
                    else
                        self.baked_grid[x][y]=0
                    end
                    break
                end
            end
        end
    end
    return self.baked_grid
end

return pathfinding_grid