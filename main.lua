require "world"
require "player"
require "pqueue"
require "maze"

function loadTextures()
    env = {}
    env.tileset = love.graphics.newImage("assets/RogueEnvironment16x16.png")

    local quads = {
        {0,  5*16,  0*16}, -- floor v1
        {1,  6*16,  0*16}, -- floor v2
        {2,  7*16,  0*16}, -- floor v3
        {3,  0*16,  0*16}, -- upper left corner
        {4,  3*16,  0*16}, -- upper right corner
        {5,  0*16,  3*16}, -- lower left corner
        {6,  3*16,  3*16}, -- lower right corner
        {7,  2*16,  0*16}, -- horizontal
        {8,  0*16,  2*16}, -- vertical
        {9,  1*16,  2*16}, -- up
        {10, 2*16,  3*16}, -- down
        {11, 2*16,  1*16}, -- left
        {12, 1*16,  1*16}, -- right
        {13, 2*16,  2*16}, -- down cross
        {14, 1*16,  3*16}, -- up cross
        {15, 3*16,  1*16}, -- left cross
        {16, 0*16,  1*16}, -- right cross
        {17, 3*16, 14*16}, -- spikes
        {18, 5*16, 13*16} -- coin
    }
    env.textures = {}
    for i = 1, #quads do
        local q = quads[i]
        env.textures[q[1]] = love.graphics.newQuad(q[2], q[3], 16, 16, env.tileset:getDimensions())
    end

    pl = {}
    pl.tileset = love.graphics.newImage("assets/RoguePlayer_48x48.png")
    pl.textures = {}
    for i = 1, 6 do
        pl.textures[i] = love.graphics.newQuad((i - 1) * 48, 48 * 2, 48, 48, pl.tileset:getDimensions())
    end

end

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    loadTextures()

    world = World:create()
    scaleX = width / (world.width * 16)
    scaleY = height / (world.height * 16)

    world:placeObjects()
    player = world.player

-- Place code here

    mapPath = {}
    deadEndValue = 99999 -- value для тупика

    lastNeigbour = ""
    lastNeigbourHash = ""

end

function love.update(dt)
    player:update(dt, world)
    world:update(player)
    seek(world:getEnv())
end

function seek(env)
    print(env.position[1], env.position[2], env.left, env.right, env.up, env.down, env.coin)

    local temp = ___hash({x=env.position[1], y=env.position[2]})

    if temp ~= lastNeigbourHash then

        if mapPath[temp] ~= nil then
            print("current value -> " .. mapPath[temp])
        else
            print("nil")
        end

        markCurrent(env)

        local neigbours = getNeigbours(env)
        print("qNeigbours -> " .. #neigbours)

        local minValue = deadEndValue
        local neigbour = nil
        
        for i=1, #neigbours do
            print(neigbours[i].v .. " " .. neigbours[i].d)
            if neigbours[i].v <= minValue then
                neigbour = neigbours[i]
                minValue = neigbours[i].v
            else
                print("greater")
            end
        end

        print("instr -> " .. neigbour.d)
        lastNeigbourHash = temp
        lastNeigbour = neigbour

    end

    if env.coin then
        world:move(lastNeigbour.d)
    end
end

function love.draw()
    love.graphics.scale(scaleX, scaleY)
    world:draw()
    player:draw(world)
end

function love.keypressed(key)
    if key == "left" then
        world:move("left")
    end
    if key == "right" then
        world:move("right")
    end
    if key == "up" then
        world:move("up")
    end
    if key == "down" then
        world:move("down")
    end
end

-- myFunctions

function getNeigbours(env)

    local neigbours = {}
    
    if not env.left then
        local temp = ___hash({x=env.position[1] -1, y=env.position[2]})
        if mapPath[temp] == nil then
            mapPath[temp] = 0
        end
        table.insert(neigbours, {d="left", v=mapPath[temp]})
    end
    if not env.right then
        local temp = ___hash({x=env.position[1] +1, y=env.position[2]})
        if mapPath[temp] == nil then
            mapPath[temp] = 0
        end
        table.insert(neigbours, {d="right", v=mapPath[temp]})
    end
    if not env.up then
        local temp = ___hash({x=env.position[1], y=env.position[2] -1})
        if mapPath[temp] == nil then
            mapPath[temp] = 0
        end
        table.insert(neigbours, {d="up", v=mapPath[temp]})
    end
    if not env.down then -- down is down!?
        local temp = ___hash({x=env.position[1], y=env.position[2] +1})
        if mapPath[temp] == nil then
            mapPath[temp] = 0
        end
        table.insert(neigbours, {d="down", v=mapPath[temp]})
    end

    return neigbours
end

function markCurrent(env)

    local current = ___hash({x=env.position[1], y=env.position[2]})

    if mapPath[current] == nil then
        mapPath[current] = 0
    end

    mapPath[current] = mapPath[current] + 1
end

function ___hash(obj) 
    return obj.x .. " " .. obj.y
end