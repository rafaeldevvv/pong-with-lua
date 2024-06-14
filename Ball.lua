Ball = Class {}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- velocity
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

function Ball:reset()
    -- reset ball's position and velocity

    -- start in the middle of the screen
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2

    -- reset ball velocity, giving them random
    -- the and/or pattern is Lua's ternary operator
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

function Ball:update(dt)
    -- update ball's position
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:collides(obj)
    return self.x < obj.x + obj.width and 
        self.x + self.width > obj.x and 
        self.y < obj.y + obj.height and
        self.y + self.height > obj.y
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
