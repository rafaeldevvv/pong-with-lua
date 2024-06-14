WINDOW_HEIGHT  = 720
WINDOW_WIDTH   = 1280

VIRTUAL_WIDTH  = 432
VIRTUAL_HEIGHT = 243

push           = require 'push'

PADDLE_SPEED   = 150
PADDLE_SIZE    = { 5, 20 }

Class          = require 'class'

require 'Ball'
require 'Paddle'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time());

    -- variables declared here are available everywhere, this is weird
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    leftPaddle = Paddle(10, 30, 5, 20)
    rightPaddle = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)
    servingPlayer = math.random(1, 2)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1score = 0
    player2score = 0
    winner = nil

    -- this is a table, the most important concept in Lua. everything in Lua is made out of a table
    -- which is equivalent to a dictionary in python and an object in javascript
    -- if you just provide values with no keys, indices are going to be implicitly created
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    }

    -- you can refer to the keys of a table with the dot or square bracket notation
    -- but keep in mind that the square bracket notation will not work if you put a space in yur key
    -- it's not best practice to use the dot notation in Lua if your keys are lined up like above

    -- Also, you can only generate dynamic keys with the square bracket syntax

    -- love acts as a state machine for a lot of things, so you
    -- need to set a new font every time you wanna use a different one
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = true,
        fullscreen = false,
        vsync = true,
    })

    love.window.setTitle('Pong')

    -- used to transition between different parts of the game
    gameState = 'start'
end

function love.resize(w,h) 
    push:resize(w, h)
end

function love.update(dt)
    -- player 1 (left) movement
    if love.keyboard.isDown('w') then
        -- move up
        leftPaddle.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        -- move down
        leftPaddle.dy = PADDLE_SPEED
    else
        leftPaddle.dy = 0
    end

    -- player 2 (right) movement
    if love.keyboard.isDown('up') then
        -- move up
        rightPaddle.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        -- move down
        rightPaddle.dy = PADDLE_SPEED
    else
        rightPaddle.dy = 0
    end

    -- using : is Lua's way of calling a method of a table or class
    leftPaddle:update(dt)
    rightPaddle:update(dt)

    if gameState == 'play' then
        ball:update(dt)

        if ball:collides(leftPaddle) then
            -- or sounds['paddle_hit']:play()
            sounds.paddle_hit:play()
            ball.dx = -ball.dx * 1.03
            ball.x = leftPaddle.x + leftPaddle.width

            if ball.dy > 0 then
                ball.dy = math.random(10, 150)
            else
                ball.dy = -math.random(10, 150)
            end
        elseif ball:collides(rightPaddle) then
            sounds.paddle_hit:play()
            ball.dx = -ball.dx * 1.03
            ball.x = rightPaddle.x - ball.width

            if ball.dy > 0 then
                ball.dy = math.random(10, 150)
            else
                ball.dy = -math.random(10, 150)
            end
        end

        if ball.y <= 0 then
            sounds['wall_hit']:play()
            ball.y = 0
            ball.dy = -ball.dy
        elseif ball.y >= VIRTUAL_HEIGHT - ball.height then
            sounds['wall_hit']:play()
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = -ball.dy
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1score = player1score + 1
            sounds['score']:play()

            if player1score == 10 then
                gameState = 'done'
                winner = 1
            else
                gameState = 'serve'
                ball:reset();
            end
        end

        if ball.x + 4 < 0 then
            servingPlayer = 1
            player2score = player2score + 1
            sounds['score']:play()

            if player2score == 10 then
                gameState = 'done'
                winner = 2
            else
                gameState = 'serve'
                ball:reset();
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            ball.dx = servingPlayer == 1 and math.random(140, 200) or -math.random(140, 200)
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()

            winner = nil
            player1score = 0
            player2score = 0
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf('Welcome to pong!', 0, 15, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. '\'s serve!', 0, 15, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winner) .. ' wins!', 0, 22, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to play again!', 0, 40, VIRTUAL_WIDTH, 'center')
    end

    -- PADDLES
    leftPaddle:render()
    rightPaddle:render()

    -- SCORES
    love.graphics.setFont(scoreFont)

    -- You could use love.graphics.print() instead, the difference between print and printf is that
    -- printf allows you to set the width of the text and align it, while print is fixed and only
    -- accepts the position of the text as parameters

    local gap = 40
    love.graphics.printf(tostring(player1score), 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH / 2 - gap / 2, 'right')
    love.graphics.printf(tostring(player2score), VIRTUAL_WIDTH / 2 + gap / 2, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH / 2,
        'left')

    -- ball
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS ' .. tostring(love.timer.getFPS()), 40, 10)
end
