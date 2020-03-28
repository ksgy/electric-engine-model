# Simplified electric-engine model

## Usage

Init engine with OAT
```lua
local engine = require("engine")
local OAT = 20

-- Set all values to OAT
engine.init({
    battery = OAT,
    motor = OAT,
    esc = OAT
});
```

Call `engine.update()` every second with eg. SASL timer:
```lua
local testTimerID = sasl.createTimer()
sasl.startTimer(testTimerID)
local previousTime = 0

function update()
    local time = sasl.getElapsedSeconds(testTimerID)
    if time > previousTime then
        engine.update({
            oat = get(dataref_OAT),
            battery_on = get(dataref_battery_on),
            throttle = get(dataref_throttle),
            engineOpen = get(dataref_engine_open),
            ias = get(dataref_ias),
        })   
        previousTime = time 
    end
end
```

## Running test
You need [LÖVE](https://love2d.org/) to run test:
```shell script
love engine.love
```
