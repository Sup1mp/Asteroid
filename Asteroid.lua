Asteroid = Class{}

function Asteroid:init(zawarudo, player_body)
    
    -- parametros de criação---------------------------------------------------------------------------------------
    local d = math.random(5, 10)        -- offset do raio inicial
    local raio = math.random(30, 75)    -- raio inicial

    -- vertices do asteroide
    -- self.vertices_direcao = {   -- direção do centro de cada vertice
    --     ['1'] = { 0, -1},
    --     ['2'] = {0.866025, -0.5},
    --     ['3'] = {0.866025, 0.5},
    --     ['4'] = {0, 1},
    --     ['5'] = {-0.866025, 0.5},
    --     ['6'] = {-0.866025, -0.5}
    -- }
    self.vertices = {   -- posição de cada vertice
        ['1'] = {0, -(raio + math.random(-d, d))},
        ['2'] = {0.866025*(raio + math.random(-d, d)),  - 0.5*(raio + math.random(-d, d))},
        ['3'] = {0.866025*(raio + math.random(-d, d)),  0.5*(raio + math.random(-d, d))},
        ['4'] = {0, (raio + math.random(-d, d))},
        ['5'] = {-0.866025*(raio + math.random(-d, d)),  0.5*(raio + math.random(-d, d))},
        ['6'] = {-0.866025*(raio + math.random(-d, d)),  - 0.5*(raio + math.random(-d, d))}
    }

    -- normais do formato
    -- self.normais = {
    --     {-(self.vertices['2'][2] - self.vertices['1'][2]), (self.vertices['2'][1] - self.vertices['1'][1])}, -- 1-2
    --     {-(self.vertices['3'][2] - self.vertices['2'][2]), (self.vertices['3'][1] - self.vertices['2'][1])}, -- 2-3
    --     {-(self.vertices['4'][2] - self.vertices['3'][2]), (self.vertices['4'][1] - self.vertices['3'][1])}, -- 3-4
    --     {-(self.vertices['5'][2] - self.vertices['4'][2]), (self.vertices['5'][1] - self.vertices['4'][1])}, -- 4-5
    --     {-(self.vertices['6'][2] - self.vertices['5'][2]), (self.vertices['6'][1] - self.vertices['5'][1])}, -- 5-6
    --     {-(self.vertices['1'][2] - self.vertices['6'][2]), (self.vertices['1'][1] - self.vertices['6'][1])}  -- 6-1
    -- }
    ---------------------------------------------------------------------------------------------------------------------

    local x, y = 0, 0

    -- posição===================================================================================================================
    -- randomiza a posição
    while (0 <= x+raio+d and x-raio-d <= WINDOW_WIDTH) and (0 <= y+raio+d and y-raio-d <= WINDOW_HEIGHT) do
        x = math.random(-WINDOW_WIDTH/2, WINDOW_WIDTH*3/2)
        y = math.random(-WINDOW_HEIGHT/2, WINDOW_HEIGHT*3/2)
    end

    -- body
    self.body = love.physics.newBody(zawarudo, x, y, "dynamic")
    self.body:setMass(10)

    --===========================================================================================================================

    -- cria o formato para o asteroide
    self.shape = love.physics.newPolygonShape(
        self.vertices['1'][1], self.vertices['1'][2],
        self.vertices['2'][1], self.vertices['2'][2],
        self.vertices['3'][1], self.vertices['3'][2],
        self.vertices['4'][1], self.vertices['4'][2],
        self.vertices['5'][1], self.vertices['5'][2],
        self.vertices['6'][1], self.vertices['6'][2],
        self.vertices['1'][1], self.vertices['1'][2]
    )
    -- cola o formato no asteroide
    self.fixture = love.physics.newFixture(self.body, self.shape, 5)

    -- velocidade
    -- determinar a direção do vetor velocidade e seu modulo
    local vel_mod = math.sqrt((player_body:getX() - self.body:getX())^2 + (player_body:getY() - self.body:getY())^2)
    local vel_limit_max = 250
    local vel_limit_min = 100

    self.incremento = {(player_body:getX() - self.body:getX())/vel_mod, (player_body:getY() - self.body:getY())/vel_mod}

    -- muda o alcance
    vel_mod = vel_mod*0.5

    -- limitação de velocidade
    if vel_mod <= vel_limit_min then
        self.velocidade = vel_limit_min     -- menor velocidade

    elseif vel_limit_min < vel_mod and vel_mod <= vel_limit_max then
        self.velocidade = vel_mod           -- velocidade variada
    else
        self.velocidade = vel_limit_max     -- maior velocidade
    end

    self.body:setLinearVelocity(self.velocidade * self.incremento[1], self.velocidade * self.incremento[2])

    -- dados do asteroide
    self.live = true                    -- status do asteroid
    self.life_time = 10                  -- tempo que o asteroide vai ficar vivo
    self.health = math.random(1, 1)     -- gera um numero pra vida
    self.onScene = false                -- se o asteroide esta ou não em cena

    local soma = 0
    -- calcula a média dos tamanhos
    for i = 1, 6, 1 do
        soma = soma + math.sqrt(self.vertices[tostring(i)][1]^2 + self.vertices[tostring(i)][2]^2)
    end

    self.hitbox = soma/2 * self.shape:getRadius()  -- aproximação par circulo
end

function Asteroid:update(dt)

    if self.live then
        -- conta a vida do asteroide
        self.life_time = self.life_time - dt

        if (0 <= self.body:getX() + self.hitbox and self.body:getX() - self.hitbox <= WINDOW_WIDTH) and
        (0 <= self.body:getY() + self.hitbox and self.body:getY() - self.hitbox <= WINDOW_HEIGHT) then
            self.onScene = true
        else
            self.onScene = false
        end
        
        if self.life_time <= 0 and not self.onScene then
            self.live = false  -- executa o asteoide (sem sofrer)
        end
    end
end

function Asteroid:render()
    --desenha os vertices do asteroid
        love.graphics.setColor(1,1,1,1)
        love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
end

function Asteroid:Debug()
    -- debug view
    love.graphics.setColor(1,0,0,1)
    love.graphics.circle('line', self.body:getX(), self.body:getY(), self.hitbox)   -- hitbox
    love.graphics.setColor(0,0,1,1)
    love.graphics.circle('fill',self.body:getX(), self.body:getY(), 2)              -- center
    love.graphics.setColor(1,1,1,1)
end

function Asteroid:death()
    self.fixture:destroy()
    self.body:destroy()
end

function Asteroid:collision(other)

    local mod = math.sqrt((self.body:getX() - other.body:getX())^2 + (self.body:getY() - other.body:getY())^2)

    if mod <= self.hitbox + other.hitbox then

        self.health = self.health - 1

        if self.health <= 0 then
            self.live = false
        end
        return true
    end
    return false
end