Class = require 'Util/class'
push = require 'Util/push'
require 'Util/Zawarudo'
require 'Util/ArcadeMode'

require 'Asteroid'
require 'Shot'
require 'Player'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 940 --423
VIRTUAL_HEIGHT = 540 --243

function love.load()

    -- randomiza dos numeros
    math.randomseed(os.time())

    -- configurações da tela
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        centered = true,
        vsync = true
    })

    love.window.setTitle("Asteroid")
    love.graphics.setDefaultFilter('nearest', 'nearest')

    font = love.graphics.newFont('Fonts/Minecraft.ttf', 16)       -- normal font 
    bigFont = love.graphics.newFont('Fonts/Minecraft.ttf', 128)    -- big font for menu and gameover

    zawarudo = love.physics.newWorld(0, 0, true)  -- mundo do jogo para engine de fisicadawd
    player = Player(zawarudo)   -- player

    DioBrando = Zawarudo()                  -- pause feature
    gamemode = ArcadeMode("Asteroid", font, bigFont)  -- gamemode

    debug = true                -- debug mode

    love.gameInit()
    love.keyboard.keyPressed = {}
end

function love.keypressed(key)

    switch (key) {
        ['escape'] = function()
            gamemode:set2Gamemode(DioBrando:menuHandle(gamemode:getGamemode(), key))  -- pause menu
        end,
        ['f3'] = function() -- turn on or off debug mode
            if debug then
                debug = false
            else
                debug = true
            end
        end
    }

    gamemode:keypressed(key)
    --key pressed
    love.keyboard.keyPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keyPressed[key]
end

function love.update(dt)

    if gamemode:isGamming() then   -- not gameover

        dt = DioBrando:update(gamemode:getGamemode(), dt)     -- modifica o dt quando precisar

        if DioBrando:isTimeRunning() then   -- time is running

            gameTime = gameTime + dt                -- avança o tempo de jogo
            local int_time = math.floor(gameTime)   -- torna inteiro

            if int_time % 10 == 0 and int_time ~= time_aproximation then
                gamemode:addScore(50)     -- 50 pontos a cada 10 segundos
                time_aproximation = int_time
            end

            -- limita o numero de asteroids em tela
            if #asteroids < 5 then
                asteroid_timer = asteroid_timer - dt
                -- geração de asteroids
                if asteroid_timer <= 0 then
                    asteroid_timer = 2
                    table.insert(asteroids, Asteroid(zawarudo, player.body))
                end
            end

            for a, asteroid in ipairs(asteroids) do
                
                asteroid:update(dt)     -- asteroid

                -- check player collision
                if asteroid:collision(player) and not player.respawn then
                    player:collision()
                    gamemode:addScore(-100)     -- score por perder uma vida

                    if not player.live then    -- game over
                        gamemode:set2Gamemode(gamemode.gamemode.gameover)
                    end
                end

                -- check bullet collision
                for i, bullet in ipairs(player.shot) do
                    if asteroid:collision(bullet) then

                        gamemode:addScore(200)    -- score por acertar um asteroide

                        bullet.body:destroy()
                        table.remove(player.shot, i)
                        
                        if not asteroid.live then       -- destroys asteroid if is dead
                            break
                        end
                    end
                end

                if not asteroid.live then
                    asteroid:death()
                    table.remove(asteroids, a)
                end
            end
            player:update(dt)
            zawarudo:update(dt)     -- world update
        else
            DioBrando:DiosWorld(gamemode:getGamemode())   -- what happens in Dio's world
        end
    
    elseif gamemode:isGamemode(gamemode.gamemode.restart) then
        gamemode:set2Gamemode(gamemode.gamemode.play)    -- começa o jogo
    else
        if gamemode:isGamemode(gamemode.gamemode.gameover) then
            love.gameInit()     -- reseta as variaveis do jogo
        end
        gamemode:update()
    end
    love.keyboard.keyPressed = {}       -- clear list of keys
end

function love.draw()

    if gamemode:isGamming() then   -- checks if it's not gameOver
        
        for i, asteroid in ipairs(asteroids) do     -- renders asteroids
            asteroid:render()   

            if debug then
                asteroid:Debug()
            end
        end
        
        player:render()     -- renders player
        if debug then
            player:Debug()
        end
    end

    gamemode:render()
        
    -- Debug mode
    if debug then
        love.graphics.setColor(0,1,0,1)
        love.graphics.print('Asteroids: '..tostring(#asteroids))
        love.graphics.print('dilatation: '..tostring(DioBrando.Dio), 0, 16)
        love.graphics.print('stop_count: '..tostring(DioBrando.stop_counter), 0, 32)
        love.graphics.print('resume_count: '..tostring(DioBrando.resume_counter), 0, 48)
        love.graphics.print('Shots: '..tostring(#player.shot), 0, 64)
        love.graphics.print('Blink: '..tostring(player.blink_timer), 0, 96)
        love.graphics.print('GameMode: '..gamemode:getGamemode(), 0, 115)
        love.graphics.print("save: "..gamemode.scores.saveFileName, 0, 130)
        love.graphics.setColor(1,1,1,1)
    end
end

function love.gameInit()
    -- todas as variaveis de inicio de jogo para gameplay
    asteroids = {}              -- array com todos os asteroids
    asteroid_timer = 2          -- tempo de spawn de asteroids em segundos
    player:resetAll()

    gameTime = 0                -- in game timer
    time_aproximation = 0       -- timer rounded
end

function switch (value)
    return function (cases)
        local f = cases[value]
        if f then
            f()
        end
    end
        
end