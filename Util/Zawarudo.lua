Zawarudo = Class{}

function Zawarudo:init()

    self.Dio = 1.5              -- the amount of 'time dilatation' (decay of 1/x)
    self.Jotaro = self.Dio      -- save for 'Dio'
    self.stop_counter = 1       -- timer for stopping time
    self.resume_counter = 1     -- timer for resuming time
    self.timer_reset = 1
    self.tokyo_run = true       -- status of time (running or stopped)

    self.pause_game = 'Pause'     -- name of the 'pause' mode
    self.resume_game = 'Play'     -- name of the 'play' mode

    self.sounds = {
        Pause = love.audio.newSource('Sons/Pause.mp3', 'stream'),
        stopTime = love.audio.newSource('Sons/Za Warudo.mp3', 'static'),
        resume = love.audio.newSource('Sons/time-resume.mp3', 'static')
    }

end

function Zawarudo:menuHandle(gamemode, key)
    -- gamemodes 'play' and 'pause'
    if gamemode == self.pause_game and self.stop_counter > 144 then  -- game resume
        love.audio.stop(self.sounds.Pause)  -- stop song from Dio's world

        self.sounds.resume:play()   -- play resume song

        gamemode = self.resume_game

    elseif gamemode == self.resume_game and self.resume_counter == 1 then  -- game pause
        self.sounds.stopTime:play()     -- play song to stop time

        gamemode = self.pause_game
    end
    return gamemode
end

function Zawarudo:isTimeRunning ()
    return self.tokyo_run
end

-- change the gamemode-------------------------------------
function Zawarudo:setPause()
    return self.pause
end
function Zawarudo:setPlay()
    return self.play
end
-----------------------------------------------------------
-- checks gamemode-----------------------------------------
function Zawarudo:isPause(gamemode)
    if gamemode == self.pause then
        return true
    end
    return false
end
function Zawarudo:isPlay(gamemode)
    if gamemode == self.play then
        return true
    end
    return false
end
-----------------------------------------------------------

function Zawarudo:update(gamemode, dt)

    -- Time stoping
    if gamemode == self.pause_game and self.tokyo_run then
        self.stop_counter = self.stop_counter + 1       -- stop timer
        dt = dt/self.Dio                                -- dilatation
        self.Dio = self.Dio + 0.22                      -- step of reduction

        if self.stop_counter > 144 then     -- complete time stop
            self.tokyo_run = false          -- stops time
        end
    end

    -- Time resuming
    if gamemode == self.resume_game and self.stop_counter > 1 then
        self.resume_counter = self.resume_counter + 1       -- resume timer
        self.tokyo_run = true                               -- releses time
        dt = dt / self.Dio                                  -- dilatation
        self.Dio = self.Dio - 0.22                          -- step of normalizing

        if self.resume_counter > 70 then    -- resume time complete
            
            self.resume_counter = self.timer_reset  -- reset resume timer
            self.stop_counter = self.timer_reset    -- reset stop timer

            self.Dio = self.Jotaro                  -- reset dilatation
            
        end
    end
    return dt
end

function Zawarudo:DiosWorld (gamemode)
    -- sound that plays while in Dio's world
    if gamemode == self.pause_game then
        self.sounds.Pause:setLooping(true)  -- creates loop
        self.sounds.Pause:play()            -- play song
    end
end

