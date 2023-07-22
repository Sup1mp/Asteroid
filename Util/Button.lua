Button = Class{}

function Button:init(text, font, x, y)
    
    self.text = text        -- text that goes on the button
    self.font = font        -- font used

    -- box for the text
    self.hitbox = {
        x = self.font:getWidth(self.text)*1.6,
        y = self.font:getHeight(self.text)*2
    }

    self.position = {
        x = x - self.hitbox.x/2,
        y = y - self.hitbox.y/2
    }

end

function Button:isPressed()
    -- check if the button is pressed
    if love.mouse.isDown(1) then

        -- mouse position of click
        local x = love.mouse.getX()
        local y = love.mouse.getY()

        if (self.position.x <= x and x <= self.position.x + self.hitbox.x) and (
            self.position.y - self.hitbox.y/3 <= y and y <= self.position.y + self.hitbox.y*2/3) then
                return true
        end
    end
    return false
end

function Button:render(RGB, border)

    love.graphics.setFont(self.font)
    love.graphics.setColor(RGB[1], RGB[2], RGB[3], 1)
    love.graphics.printf(self.text, self.position.x, self.position.y, self.hitbox.x, "center")
    
    if border then
        love.graphics.rectangle('line', self.position.x, self.position.y - self.hitbox.y/3, self.hitbox.x, self.hitbox.y)
    end

    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.circle('fill', self.position.x, self.position.y, 2)
    -- love.graphics.circle('fill', self.position.x + self.hitbox.x, self.position.y + self.hitbox.y, 2)

    -- love.graphics.setColor(0, 0, 1, 1)
    -- love.graphics.circle('fill', self.position.x, self.position.y - self.hitbox.y/3, 2)
    -- love.graphics.circle('fill', self.position.x + self.hitbox.x, self.position.y + self.hitbox.y*2/3, 2)
    
    -- love.graphics.setColor(0, 1, 0, 1)
    -- love.graphics.circle('fill', self.position.x, self.position.y - self.hitbox.y/3, 2)
    -- love.graphics.circle('fill', self.position.x + self.hitbox.x, self.position.y + self.hitbox.y*2/3, 2)


end