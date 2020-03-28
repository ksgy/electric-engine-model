local secondElapsed = 0
local TEST_STATE = 1
local engine = require("engine")

local STATES = {
    -- init, engine on
    {
        oat = 20,
        battery_on = 1,
        throttle = 0.2,
        engineOpen = 1,
        ias = 80,
    },
    -- power off, close engine
    {
        oat = 5,
        battery_on = 1,
        throttle = 0,
        engineOpen = 0,
        ias = 80,
    },
}

function love.load()
    love.window.setMode(1600, 800, {x=0,y=0})
    love.graphics.setBackgroundColor(1, 1, 1)
    engine.init({
        battery = 20,
        motor = 20,
        esc = 20
    });
end

graph = {}
stateColors = {
    battery = {1, 0, 0},
    esc = {1, 0.5, 0},
    motor = {0, 0, 1}
}

function drawTemperature(point)
    color = stateColors['battery']
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.line(point.x, 800, point.x, 800 - point.by*2)

    color = stateColors['motor']
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.line(point.x, 600, point.x, 600 - point.my*2)

    color = stateColors['esc']
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.line(point.x, 400, point.x, 400 - point.ey*2)
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 0.5)

    for i = 1, secondElapsed do
        drawTemperature(graph[i])
    end
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Time  " .. math.ceil(secondElapsed/60) .. "min", 50, 50)
    love.graphics.print("oat " .. STATES[TEST_STATE].oat, 50, 70)
    love.graphics.print("battery_on " .. STATES[TEST_STATE].battery_on, 50, 90)
    love.graphics.print("throttle " .. STATES[TEST_STATE].throttle, 50, 110)
    love.graphics.print("engineOpen " .. STATES[TEST_STATE].engineOpen, 50, 130)
    love.graphics.print("ias, " .. STATES[TEST_STATE].ias, 50, 150)
    love.graphics.setColor(stateColors.motor)
    love.graphics.print("Motor temp  " .. engine.state.temp.motor, 50, 250)
    love.graphics.setColor(stateColors.battery)
    love.graphics.print("Battery temp  " .. engine.state.temp.battery, 50, 270)
    love.graphics.setColor(stateColors.esc)
    love.graphics.print("ESC temp  " .. engine.state.temp.esc, 50, 290)
end

loaded = false

function love.update(dt)
    secondElapsed = secondElapsed + 1

    engine.update(STATES[TEST_STATE])

    if (secondElapsed > 10 * 60) then
        TEST_STATE = 2
    end
    graph[secondElapsed] = {
        x = secondElapsed + 1,
        by = engine.state.temp.battery,
        my = engine.state.temp.motor,
        ey = engine.state.temp.esc,
    }
end

