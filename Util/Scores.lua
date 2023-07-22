Scores = Class{}

require 'Util/Textbox'

function Scores:init()

    self.highscore = 670      -- HighScore of the current section
    self.score = 0          -- Score of the current section

    self.saveFileName = "highscores.lua"

    -- loads all highscores
    self.allHighscores = self:load() or {}--{names = {}, highscores = {}}
end

function Scores:load()
    if love.filesystem.getInfo(self.saveFileName) then
        return love.filesystem.load(self.saveFileName)()
    end
end

function Scores:save(name)
        
    -- table.insert(self.allHighscores.names, name)
    -- table.insert(self.allHighscores.highscores, self.highscore)
    
    self.allHighscores[name] = self.highscore
    table.sort(self.allHighscores)

    love.filesystem.write(self.saveFileName, "return "..tableToString(self.allHighscores))
end

function Scores:addHighscore()
    if self.highscore < self.score then
        self.highscore = self.score
    end
    self.score = 0
end

function Scores:addScore(value)
    self.score = self.score + value
end

function tableToString(data)
    -- transforms a table into a string
    local str = "{\n"
    for k, v in pairs(data) do
        str = str.."[\'"..tostring(k).."\']".." = "
        if type(v) == "table" then
            str = str..tableToString(v)..",\n"
        elseif type(v) == "string" then
            str = str.."\""..tostring(v).."\",\n"
        else
            str = str..tostring(v)..",\n"
        end
    end
    str = str.."}"
    return str
end