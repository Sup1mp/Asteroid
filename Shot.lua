Shot = Class{}

function Shot:init(zawarudo, player_body, player_direcao)

    -- corpo do tiro
    self.body = love.physics.newBody(
        zawarudo,
        player_body:getX() + 18 * player_direcao[1],
        player_body:getY() + 18 * player_direcao[2],
        "dynamic"
    )
    self.body:setMass(5)

    -- Status do projetil
    self.body:setBullet(true)                                       -- define como tiro
    self.height = 9                                                -- comprimento do tiro
    self.width = 1                                                 -- largura do tiro
    self.direcao = player_direcao                                   -- direção que o projétil vai seguir
    self.velocidade = 100                                           -- modulo da velocidade do projetil
    self.fade = 1.5                                                   -- fade da cor com o tempo (fade < 1 começa a fazer efeito; fade > 1 delay de atuação)
    self.angle = math.atan2(self.direcao[2], self.direcao[1])       -- angulo em que o tiro está indo
    self.hitbox = self.height

    self.shape = love.physics.newEdgeShape(0, 0, 0, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape)
end

function Shot:update(dt)

    -- atualização da posição do tiro
    self.body:setLinearVelocity(
        300 * self.velocidade * self.direcao[1]*dt,
        300 * self.velocidade * self.direcao[2]*dt
    )
    -- self.body:setPosition(
    --     self.body:getX() + self.velocidade * self.direcao[1]*dt,
    --     self.body:getY() + self.velocidade * self.direcao[2]*dt
    -- )

    -- contagem de tempo
    self.fade = self.fade - dt      -- aplica o efeito de sumir do tiro
end

function Shot:render()
    -- reduz o brilho do tiro com o passar do tempo
    love.graphics.setColor(1,1,1,math.max(0, self.fade))

    -- rotação da tela para desenhar o tiro orientado de maneira correta
    love.graphics.rotate(self.angle)

    local new_pos = rotate({self.body:getWorldPoints(self.shape:getPoints())}, self.angle) -- rotação da posição corrigindo a rotação da tela

    love.graphics.rectangle('fill', new_pos[1], new_pos[2], self.height, self.width)  -- desenha o tiro

    love.graphics.origin()  -- retorna a tela para a orietnação inicial
    love.graphics.setColor(1,1,1,1)
end

function rotate(vector, ang)
    -- matriz de rotação
    local R = {{math.cos(ang), -math.sin(ang)},
    {math.sin(ang), math.cos(ang)}}

    -- rotaciona o vetor com o angulo ang
    local standby = {0, 0}  -- array resposta
    for i = 1, 2 do
        local soma = 0
        for j = 1, 2 do
            soma = soma + vector[j]*R[j][i]     -- rotação de vetor
        end
        standby[i] = soma   -- salva resultado
    end
    
    return standby  -- retorna o vetor rotacionado
end

function Shot:Debug()
    love.graphics.setColor(1,0,1,1)
    love.graphics.setColor(1,0,0,1)
    love.graphics.circle('fill', self.body:getX(), self.body:getY(), 2)
    love.graphics.setColor(1,1,1,1)
end