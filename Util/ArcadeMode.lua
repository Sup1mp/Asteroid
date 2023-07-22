ArcadeMode = Class{}

require 'Util/Button'
require 'Util/Textbox'
require 'Util/Scores'

function ArcadeMode:init(title, font, bigFont)

    self.title = title          -- game title
    self.font = font            -- font used
    self.bigFont = bigFont      -- big font used

    -- gamemodes
    self.gamemode = {
        menu = 'Menu',
        play = 'Play',
        pause = 'Pause',
        gameover = 'GameOver',
        higscore = 'Highscore',
        control = 'Controles',
        restart = 'Restart',
        save = 'Save'
    }

    self.call = self.gamemode.menu      -- initial gamemode

    -- buttons
    self.Buttons = {
        [self.gamemode.menu] = {
            Button(self.gamemode.play, self.font ,WINDOW_WIDTH/2, WINDOW_HEIGHT/2),
            Button(self.gamemode.higscore, self.font ,WINDOW_WIDTH/2, WINDOW_HEIGHT/2 + 50),
            Button(self.gamemode.control, self.font ,WINDOW_WIDTH/2, WINDOW_HEIGHT/2 + 100)
        },
        [self.gamemode.pause] = {
            Button(self.gamemode.menu, self.font, WINDOW_WIDTH/2 - 80, WINDOW_HEIGHT - 50),
        },
        [self.gamemode.higscore] = {
            Button(self.gamemode.menu, self.font, WINDOW_WIDTH/2, WINDOW_HEIGHT - 50)
        },
        [self.gamemode.gameover] = {
            Button(self.gamemode.menu, self.font, WINDOW_WIDTH/2 - 80, WINDOW_HEIGHT - 50),
            Button(self.gamemode.save, self.font, WINDOW_WIDTH/2, WINDOW_HEIGHT - 50),
            Button(self.gamemode.restart, self.font, WINDOW_WIDTH/2 + 100, WINDOW_HEIGHT - 50)
        },
        [self.gamemode.control] = {
            Button(self.gamemode.menu, self.font, WINDOW_WIDTH/2, WINDOW_HEIGHT - 50)
        },
    }

    -- score and higscore
    self.scores = Scores()

    -- text to enter
    self.textBox = Textbox(self.bigFont, WINDOW_WIDTH/2, WINDOW_HEIGHT/2, 3)
end

function ArcadeMode:update()
    if not self:isGamemode(self.gamemode.save) then
        for i, butt in ipairs(self.Buttons[self:getGamemode()]) do
            if butt:isPressed() then
                self:set2Gamemode(butt.text)
                return
            end
        end
    else
        self.textBox:update()   -- get the text input
        if not self.textBox.inputActive then
            self.scores:save(self.textBox:getInput())
            self:set2Gamemode(self.gamemode.higscore)
            self.textBox.inputActive = true
        end
    end

    if self:isGamemode(self.gamemode.gameover) then
        self.scores:addHighscore()
    end
end

function ArcadeMode:keypressed(key)
    self.textBox:keypressed(key)
    if key == 'f1' and not self:isGamemode(self.gamemode.play) then
        love.event.quit()
    end
end

function ArcadeMode:render()
    love.graphics.setFont(self.bigFont)     -- calls big font
    love.graphics.setColor(1, 1, 1, 1)      -- sets color white

    -- Gaming ----------------------------------------------------------------------------------------------------------------------------------------------------------
    if self:isGamming() then

        love.graphics.setFont(self.font)
        love.graphics.print("Score: "..tostring(self.scores.score), 0, 10)  -- score
        if self.scores.highscore > 0 then
            love.graphics.print("HighScore: "..tostring(self.scores.highscore), 300, 10)    -- highscore
        end

        if self:isGamemode(self.gamemode.pause) then
            -- bras dimensions
            local width = 20
            local height = 58
            local spacing = 10
    
            love.graphics.setColor(0.6,0.4,0.8,1)
            --love.graphics.printf('PAUSE', WINDOW_WIDTH/2 - 128, WINDOW_HEIGHT/2 - 32, 216, 'center')
            love.graphics.rectangle('fill', WINDOW_WIDTH/2 - width - spacing/2, WINDOW_HEIGHT/2 - height/2, width, height)
            love.graphics.rectangle('fill', WINDOW_WIDTH/2 + spacing/2 , WINDOW_HEIGHT/2 - height/2, width, height)
            love.graphics.circle('line', WINDOW_WIDTH/2, WINDOW_HEIGHT/2, 60)
        end
    -- Menu ------------------------------------------------------------------------------------------------------------------------------------------------------------
    elseif self:isGamemode(self.gamemode.menu) then
        love.graphics.print(self.title, WINDOW_WIDTH/2 - self.bigFont:getWidth(self.title)/2, 10 )
    
    -- Gameover --------------------------------------------------------------------------------------------------------------------------------------------------------
    elseif self:isGamemode(self.gamemode.gameover) then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.printf('GAME OVER', WINDOW_WIDTH/2 - 380, WINDOW_HEIGHT/2 - 80, 800, 'center')

        local text = ""
        if self.scores.highscore < 0 then
            -- nice incentive to improviment
            text = "Puta merda em, nem sabia que tinha como conseguir isso"
        elseif self.scores.highscore == 0 then
            text = "Parabéns pelo equilíbrio"
        else
            text = "Mandou bem"
        end

        love.graphics.setFont(self.font)
        love.graphics.setColor(0.3, 0.5, 0.7, 1)
        love.graphics.print(text, WINDOW_WIDTH/2 - self.font:getWidth(text)/2, WINDOW_HEIGHT/2 + 30)
        love.graphics.setFont(self.bigFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(tostring(self.scores.highscore), WINDOW_WIDTH/2 - self.bigFont:getWidth(tostring(self.scores.highscore))/2, WINDOW_HEIGHT/2 + 100)

        -- love.graphics.setFont(self.font)
        -- love.graphics.setColor(1, 1, 0, 1)
        -- love.graphics.print('press           to restart', WINDOW_WIDTH/2 - 80, WINDOW_HEIGHT/2 + 30)
        -- love.graphics.setColor(1, 0, 1, 1)
        -- love.graphics.printf('space', WINDOW_WIDTH/2 - 60, WINDOW_HEIGHT/2 + 30, 100, 'center')
    -- HighScore -------------------------------------------------------------------------------------------------------------------------------------------------------
    elseif self:isGamemode(self.gamemode.higscore) then

        love.graphics.print('HighScore', WINDOW_WIDTH/2 - self.bigFont:getWidth("HighScore")/2, 10)
        
        love.graphics.setFont(self.font)
        
        local general_y = 200
        local name_y = self.font:getHeight("AAA") + 15
        local i = 1

        for k, v in spairs(self.scores.allHighscores, function(t,a,b) return t[b] < t[a] end) do
            love.graphics.print(k, WINDOW_WIDTH/2 - self.font:getWidth("AAA") - 100, general_y + name_y*i)
            love.graphics.print(v, WINDOW_WIDTH/2 + self.font:getWidth("AAA")/2 + 100, general_y + name_y*i)
            i = i+1
        end

    -- Control ---------------------------------------------------------------------------------------------------------------------------------------------------------
    elseif self:isGamemode(self.gamemode.control) then
    
    -- Save ------------------------------------------------------------------------------------------------------------------------------------------------------------
    elseif self:isGamemode(self.gamemode.save) then
        love.graphics.print('Nome', WINDOW_WIDTH/2 - self.bigFont:getWidth("Nome")/2, 10)
        self.textBox:render({1, 1, 1})
    end
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- render current buttons
    if not self:isGamming() and not self:isGamemode(self.gamemode.save) and not self:isGamemode(self.gamemode.restart) then
        for i, butt in ipairs(self.Buttons[self:getGamemode()]) do
            butt:render({1, 1, 1}, true)
        end
    end

    -- resets main color and font
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Utils
function ArcadeMode:addScore(value)
    self.scores:addScore(value)
end

function ArcadeMode:isGamming()
    -- checks if current gamemode is pause or play (in game)
    if self:isGamemode(self.gamemode.play) or self:isGamemode(self.gamemode.pause) then
        return true
    end
    return false
end

function ArcadeMode:getGamemode()
    -- gets the current gamemode
    return self.call
end

function ArcadeMode:isGamemode(gamemode)
    -- compares if a gamemode is what you want
    if self.call == gamemode then
        return true
    end
    return false
end

function ArcadeMode:set2Gamemode(new_mode)
    -- sets the current gamemode to another one
    self.call = new_mode
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end