local secondElapsed = 0
local TEST_STATE = 1
local engine = require("engine")

local secondDivider = 66

local STATES = {
    -- init, engine off
    {
        oat = 20,
        fuel = 0,
        battery_on = 1,
        throttle = 0,
        starter = 0,
        ias = 0,
    },
    -- start engine
    {
        oat = 20,
        fuel = 1,
        battery_on = 1,
        throttle = 0,
        starter = 1,
        ias = 0,
    },
}

function love.load()
    love.window.setMode(1600, 800, {x=0,y=0})
    love.graphics.setBackgroundColor(1, 1, 1)
    engine.init({
        itt = STATES[1].oat,
    });
    ITT_IMAGE = love.graphics.newImage("itt.png")
    ITT_IMAGE_width = ITT_IMAGE:getWidth()
    ITT_IMAGE_height = ITT_IMAGE:getHeight()
end

graph = {}
stateColors = {
    ng = {1, 0.5, 0},
    itt = {0, 0, 1}
}

function drawTemperature(point)
    color = stateColors['itt']
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.line(point.x, 800, point.x, 800 - point.ittY/1.45)

    color = stateColors['ng']
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.line(point.x, 400, point.x, 400 - point.ngY)
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(ITT_IMAGE, 1650, 800, math.rad(0), 2.2, 1, ITT_IMAGE_width, ITT_IMAGE_height)

    for i = 1, secondElapsed do
        drawTemperature(graph[i])
    end
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Time " .. math.ceil(secondElapsed/secondDivider) .. "sec", 50, 50)
    love.graphics.print("oat " .. STATES[TEST_STATE].oat, 50, 70)
    love.graphics.print("battery_on " .. STATES[TEST_STATE].battery_on, 50, 90)
    love.graphics.print("throttle " .. STATES[TEST_STATE].throttle, 50, 110)
    love.graphics.print("fuel " .. STATES[TEST_STATE].fuel, 50, 130)
    love.graphics.print("starter " .. STATES[TEST_STATE].starter, 50, 150)
    love.graphics.setColor(stateColors.itt)
    love.graphics.print("ITT    " .. engine.state.temp.itt, 50, 250)
    love.graphics.setColor(stateColors.ng)
    love.graphics.print("ng    " .. engine.state.ng, 50, 270)
    --love.graphics.setColor(stateColors.esc)
    --love.graphics.print("ESC temp  " .. engine.state.temp.esc, 50, 290)
end

loaded = false

function love.update(dt)
    if secondElapsed > 25*secondDivider then return end
    secondElapsed = secondElapsed + 1

    engine.update(STATES[TEST_STATE])

    if (secondElapsed > 2*secondDivider) then
        TEST_STATE = 2
    end
    graph[secondElapsed] = {
        x = secondElapsed + 1,
        ittY = engine.state.temp.itt,
        ngY = engine.state.ng,
    }
end

