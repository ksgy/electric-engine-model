# Simplified electric-engine model

![Simplified electric-engine model](https://github.com/ksgy/electric-engine-model/blob/master/eem.png)

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

## Customising
You can customise each graph with the constants found at the beginning of `engine.lua`:
```lua
local BATTERY_HEATING_FACTOR = 45 -- basic heating factor
local BATTERY_HEAT_STEP = 0.0016 -- how fast batter heats
local BATTERY_COOL_STEP = 0.0009 -- how fast battery cools down
local BATTERY_TEMP_THRESHOLD = 0.5 
local IAS_COOLING_FACTOR = 0.0045 -- how much IAS affects the cool down

local MOTOR_HEATING_FACTOR = 50
local MOTOR_HEAT_STEP = 0.002
local MOTOR_COOL_STEP = 0.0045
local MOTOR_TEMP_THRESHOLD = 0.1
local MOTOR_MAX_TEMP = 50 -- maximum reachable temp (won't overheat above this temp) 

local ESC_HEATING_FACTOR = 50
local ESC_HEAT_STEP = 0.001
local ESC_COOL_STEP = 0.008
local ESC_TEMP_THRESHOLD = 0.1
local ESC_MAX_TEMP = 40
```

## Running test
You need [LÖVE](https://love2d.org/) to run test:
```shell script
love engine.love
```
