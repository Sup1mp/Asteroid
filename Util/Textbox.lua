Textbox = Class{}

local utf8 = require("utf8")

function Textbox:init(font, x, y, size)
    
    self.font = font                -- font used
    self.text = ""                  -- text writen
    self.inputActive = true        -- if is ready to get the input

    self.boxOffset_x = 2            -- the box offset
    self.upperCase = true           -- if is true than forces all letters upper case
    self.centered = true            -- if is true than the text will start from the center of the box
    self.character_limit = size     -- limits the number of characters
    self.auto_enter = false

    -- hitbox of the box
    self.hitbox = {
        x = self.font:getWidth("A")*self.character_limit*1.2,
        y = self.font:getHeight("A")*2
    }

    -- centerd position of the box
    self.position = {
        x = x - self.hitbox.x/2,
        y = y - self.hitbox.y/2
    }

    -- enable key repeat so backspace can be held down to trigger love.keypressed multiple times.
    love.keyboard.setKeyRepeat(true)
end

function Textbox:isPressed()
    -- check if the button is pressed
    if love.mouse.isDown(1) then

        -- mouse position of click
        local x = love.mouse.getX()
        local y = love.mouse.getY()

        if (self.position.x <= x and x <= self.position.x + self.hitbox.x) and (
            self.position.y - self.hitbox.y/3 <= y and y <= self.position.y + self.hitbox.y*2/3) then
                self.inputActive = true
                return true
        end
        self.inputActive = false
    end
    return false
end

function Textbox:update()
    -- when is active
    if self.inputActive or self:isPressed() then
        -- gets text input
        function love.textinput(text)
            if string.len(self.text) < self.character_limit then
                if self.upperCase then
                    text = string.upper(text)
                end
                self.text = self.text..text
            elseif self.auto_enter then
                self.inputActive = false
            end
        end
    end
end

function Textbox:keypressed(key)
    -- verify inf Enter was pressed for send message
    if key == "return" then
        self.inputActive = not self.inputActive
    end
    if key == "backspace" and self.inputActive then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(self.text, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            self.text = string.sub(self.text, 1, byteoffset - 1)
        end
    end
end

function Textbox:getInput()
    local input = self.text
    self.text = ""
    return input
end

function Textbox:render(RGB)
    love.graphics.setFont(self.font)
    love.graphics.setColor(RGB[1], RGB[2], RGB[3], 1)

    love.graphics.rectangle('line', self.position.x - self.boxOffset_x, self.position.y - self.hitbox.y/3, self.hitbox.x + self.boxOffset_x*2, self.hitbox.y)

    if self.centered then
        love.graphics.print(self.text, self.position.x + self.hitbox.x/2 - self.font:getWidth(self.text)/2, self.position.y)
    else
        love.graphics.printf(self.text, self.position.x , self.position.y, self.hitbox.x, "center")
    end
end