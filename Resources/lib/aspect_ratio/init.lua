-- AspectRatio
-- MIT License

local AspectRatio = {
    win_w = 0, win_h = 0,
    dig_w = 0, dig_h = 0,
    game_w = 0, game_h = 0,
    scale = 0,
    x = 0, y = 0
}

function AspectRatio:init(win_w, win_h, dig_w, dig_h)
    self.win_w, self.win_h = win_w, win_h
    self.dig_w, self.dig_h = dig_w, dig_h

    self:calc_values(self)
end

function AspectRatio:resize(w, h)
    self.win_w, self.win_h = w, h
    self:calc_values()
end

function AspectRatio:calc_values()
    local scale_w, scale_h = self.win_w / self.dig_w, self.win_h / self.dig_h
    self.scale = math.min(scale_w, scale_h)

    self.game_w = self.dig_w * self.scale
    self.game_h = self.dig_h * self.scale
    
    self.x = math.floor((self.win_w / 2) - (self.game_w / 2))
    self.y = math.floor((self.win_h / 2) - (self.game_h / 2))
end

function AspectRatio:window_to_game_position( x, y )
     x, y = x - self.x, y - self.y
     return math.floor( x / self.scale ), math.floor( y / self.scale )
end

return AspectRatio

