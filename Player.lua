Player = Class{}

function Player:init(zawarudo)
    self.world = zawarudo
    self.body = love.physics.newBody(zawarudo, WINDOW_WIDTH/2, WINDOW_HEIGHT/2, 'dynamic')
    
    -- velocidade do player
    self.impulso = 50              -- impulso de velocidade dado no comando
    self.ang_vel = 4             -- velocidade angular
    
    self:resetPlayer()  -- sets position of the player

    local l = 25
    local h = l*math.sqrt(3)/2

    self.live_graph = {
        ['1'] = {0, -2*h/3},
        ['2'] = {l/2, h/3},
        ['3'] = {0, 0},
        ['4'] = {-l/2, h/3}
    }     -- for drawing the lives icons

    self:reShape()
    -- cola o self.shape no corpo
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)

    self.hitbox = 40*self.shape:getRadius()
    self:resetAll()
end

function Player:update(dt)

    -- boundaries=======================================================================================
    if self.body:getX() > WINDOW_WIDTH then
        self.body:setX(0)
    elseif self.body:getX() < 0 then
        self.body:setX(WINDOW_WIDTH)
    end

    if self.body:getY() > WINDOW_HEIGHT then
        self.body:setY(0)
    elseif self.body:getY() < 0 then
        self.body:setY(WINDOW_HEIGHT)
    end
    -- Movimentação=====================================================================================

    -- aumento da velocidade (incremento)
    if love.keyboard.isDown('w') or love.keyboard.isDown('up') then   -- para frente
        self.body:applyLinearImpulse(self.impulso * self.direcao[1] * dt, self.impulso * self.direcao[2] * dt)
    end
    if love.keyboard.isDown('s') or love.keyboard.isDown('down') then   -- para trás
        self.body:applyLinearImpulse(-self.impulso * self.direcao[1] * dt, -self.impulso * self.direcao[2] * dt)
    end

    -- limite de velocidade
    local dx, dy = self.body:getLinearVelocity()
    local mod = math.sqrt(dx^2 + dy^2)  -- modulo velocidade

    if mod >= 300 then
        self.body:setLinearVelocity(300*dx/mod, 300*dy/mod) -- limita a velocidade a 300
    end

    -- gira o corpo do player
    if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        self:rotate('direita', self.ang_vel*dt)  -- para direita
    elseif love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        self:rotate('esquerda', self.ang_vel*dt) -- para esquerda
    end

    -- tiro ============================================================================================
    self.shot_cooldown = self.shot_cooldown - dt

    if love.keyboard.wasPressed('space') and self.shot_cooldown <= 0 then
        self.shot_cooldown = self.shot_cooldown_reset   -- resets shot cooldown

        -- cria o tiro e insere no array de tiros
        table.insert(self.shot,  Shot(self.world, self.body, self.direcao))
    end
    -- atualização dos tiros existentes no array
    for i, bullet in ipairs(self.shot) do
        bullet:update(dt)
        if bullet.fade <= 0 then
            bullet.body:destroy()
            table.remove(self.shot, i)
        end
    end
    --==================================================================================================

    -- takes care of the respawn feature
    if self.respawn then
        self.respawn_timer = self.respawn_timer - dt    -- respawn timer
        self.blink_timer = self.blink_timer - dt        -- blink animation
        

        if self.respawn_timer <= 0 then
            self.respawn_timer = self.respawn_timer_reset
            self.respawn = false
        end
    end
end


function Player:render()
    if self.respawn then
        if self.blink_timer <= 0 then
            self.blink_timer = self.blink_timer_reset   -- reset blink "animation"

            -- blink feeling
            if self.draw then       -- if yes then no
                self.draw = false
            else                    -- if no then yes
                self.draw = true
            end
        end
    elseif not self.draw then
        self.draw = true    -- makes player visible aways
        self.blink_timer = self.blink_timer_reset   -- reset blink "animation"
    end

    if self.draw then

        love.graphics.setColor(1,1,1,1)
        love.graphics.line(
            self.body:getX() + self.vertices['1'][1], self.body:getY() + self.vertices['1'][2],
            self.body:getX() + self.vertices['2'][1], self.body:getY() + self.vertices['2'][2],
            self.body:getX() + self.vertices['3'][1], self.body:getY() + self.vertices['3'][2],
            self.body:getX() + self.vertices['4'][1], self.body:getY() + self.vertices['4'][2],
            self.body:getX() + self.vertices['1'][1], self.body:getY() + self.vertices['1'][2]
        )
        --love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
        love.graphics.line(
            self.body:getX() + self.vertices['1'][1], self.body:getY() + self.vertices['1'][2],
            self.body:getX() + self.vertices['3'][1], self.body:getY() + self.vertices['3'][2]
        )
    end

    -- draw number of lives
    local dx = 50
    local spacing = 30
    local dy = 25
    for i = 1, self.health, 1 do
        love.graphics.line(
            WINDOW_WIDTH - dx - spacing*i - self.live_graph['1'][1], dy + self.live_graph['1'][2],
            WINDOW_WIDTH - dx - spacing*i - self.live_graph['2'][1], dy + self.live_graph['2'][2],
            WINDOW_WIDTH - dx - spacing*i - self.live_graph['3'][1], dy + self.live_graph['3'][2],
            WINDOW_WIDTH - dx - spacing*i - self.live_graph['4'][1], dy + self.live_graph['4'][2],
            WINDOW_WIDTH - dx - spacing*i - self.live_graph['1'][1], dy + self.live_graph['1'][2]
        )
        --love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
        love.graphics.line(
            WINDOW_WIDTH - dx - spacing*i - self.live_graph['1'][1], dy + self.live_graph['1'][2],
            WINDOW_WIDTH - dx - spacing*i - self.live_graph['3'][1], dy + self.live_graph['3'][2]
        )
    end


    for i, bullet in ipairs(self.shot) do
        bullet:render(dt)
        if debug then
            bullet:Debug()
        end
    end
end

function Player:rotate(dir, ang)
    -- função para mudar a direção do player

    -- define a direção para qual irá girar
    if dir == 'direita' then
        ang = -ang
    end

    -- matriz de rotação
    local R = {{math.cos(ang), -math.sin(ang)},
    {math.sin(ang), math.cos(ang)}}

    -- rotação do vetor direção
    local standby = {0, 0}
    for i = 1, 2 do
        local soma = 0
        for j = 1, 2 do
            soma = soma + self.direcao[j]*R[j][i]
        end
        standby[i] = soma
    end
    
    self.direcao = standby  -- coloca nova direção no vetor direção

    -- rotação dos pontos da espaço-nave
    for index = 1, 4 do         -- iteração de cada ponto
        local standby = {0, 0}
        for i = 1, 2 do
            local soma = 0
            for j = 1, 2 do
                soma = soma + self.vertices[tostring(index)][j]*R[j][i]     -- rotaciona os pontos
            end
            standby[i] = soma
        end
        self.vertices[tostring(index)] = standby    -- salva posição rotacionada
    end
    -- coloca os novos pontos na forma e depois cola no corpo
    self:reShape()
    return
end

function Player:Debug()
    love.graphics.setColor(0,0,1,1)
    love.graphics.circle('line', self.body:getX(), self.body:getY(), self.hitbox)   -- hitbox
    love.graphics.setColor(1,0,0,1)
    love.graphics.circle('line', self.body:getX(), self.body:getY(), 2)   -- centro
    love.graphics.setColor(1,1,1,1)
end

function Player:reShape()
    -- atualiza os pontos 
    self.shape = love.physics.newPolygonShape(
        self.vertices['1'][1], self.vertices['1'][2],
        self.vertices['2'][1], self.vertices['2'][2],
        self.vertices['3'][1], self.vertices['3'][2],
        self.vertices['4'][1], self.vertices['4'][2],
        self.vertices['1'][1], self.vertices['1'][2]
    )
    return
end

function Player:resetPlayer()

    self.body:setPosition(WINDOW_WIDTH/2, WINDOW_HEIGHT/2)
    self.body:setLinearVelocity(0, 0)
    self.direcao = {0, -1}      -- direção do bico da nave
    local l = 25
    local h = l*math.sqrt(3)/2
    
    -- vertices que formam o player
    self.vertices = {
        ['1'] = {0, -2*h/3},
        ['2'] = {l/2, h/3},
        ['3'] = {0, 0},
        ['4'] = {-l/2, h/3}
    }
end

function Player:resetAll()
    self:resetPlayer()

    -- bullets things
    self.shot_cooldown = 0.1
    self.shot_cooldown_reset = self.shot_cooldown
    self.shot = {}  -- matriz com balas do player

    -- life things
    self.live = true
    self.health = 3

    -- respawn things
    self.respawn = false
    self.respawn_timer = 5                          -- gives imunity to player after it died
    self.respawn_timer_reset = self.respawn_timer

    -- blinking things
    self.blink_timer = 0.1
    self.blink_timer_reset = self.blink_timer
    self.draw = true
end

function Player:collision()

    self.health = self.health - 1

    self:resetPlayer()
    self.respawn = true

    if self.health <= 0 then
        self.live = false
    end
end