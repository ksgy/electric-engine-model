local secondElapsed = 0
local engine = require("engine")

local testDataRefs = {
    oat = 20,
    battery_on = 1,
    battery_v = 12,
    battery_a = 5,
    throttle = 0,
    engineOpen = 0,
    ias = 80,
}

function love.load()
    love.window.setMode(800, 800, {x=0,y=0})
    love.graphics.setBackgroundColor(1, 1, 1)
    engine.init({
        battery = 45,
        motor = 50,
        esc = 40
    });
end

graph = {}
stateColors = {
    battery = {255, 0, 0},
    esc = {0, 255, 0},
    motor = {0, 0, 255}
}

function drawTemperature(point)
    color = stateColors['battery']
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.line(point.x, 800, point.x, 800 - point.by*2)

    color = stateColors['motor']
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.line(point.x, 700, point.x, 700 - point.my*2)
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 0.5)

    for i = 1, secondElapsed do
        drawTemperature(graph[i])
        --print(graph[i].x)
    end
end

loaded = false

function love.update(dt)
    secondElapsed = secondElapsed + 1

    engine.update(testDataRefs)

    graph[secondElapsed] = {
        x = secondElapsed + 1,
        by = engine.state.temp.battery,
        my = engine.state.temp.motor
    }
end

