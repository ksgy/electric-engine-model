local BATTERY_HEATING_FACTOR = 45
local BATTERY_HEAT_STEP = 0.0016
local BATTERY_COOL_STEP = 0.0009
local BATTERY_TEMP_THRESHOLD = 0.5

local IAS_COOLING_FACTOR = 0.0045

local MOTOR_HEATING_FACTOR = 50
local MOTOR_HEAT_STEP = 0.005
local MOTOR_COOL_STEP = 0.0065
local MOTOR_TEMP_THRESHOLD = 0.1
local MOTOR_MAX_TEMP = 60

local engine = {
	state = {
		temp = {
			esc = 0,
			motor = 0,
			battery = 0,
		}
	}
}

engine.init = function(datarefs)
	engine.state.temp.battery = datarefs.battery
	engine.state.temp.motor = datarefs.motor
	engine.state.temp.esc = datarefs.esc
end

engine.update = function(datarefs)
	-- datarefs = {
	-- 	oat,
	--	battery_on
	--	battery_v
	--	battery_a
	-- 	throttle
	-- 	engineOpen
	-- 	ias
	-- }

	------ Battery -----
	local batteryTemp = datarefs.oat + datarefs.battery_on * datarefs.engineOpen * datarefs.throttle * BATTERY_HEATING_FACTOR
	local batteryTempDiff = math.abs(batteryTemp - engine.state.temp.battery)

	-- Don't change temp if it's near final temp
	if (engine.state.temp.battery > batteryTemp - BATTERY_TEMP_THRESHOLD) and (engine.state.temp.battery < batteryTemp + BATTERY_TEMP_THRESHOLD) then
		engine.state.temp.battery = batteryTemp
		return
	end

	if (batteryTemp > engine.state.temp.battery) then
		engine.state.temp.battery = engine.state.temp.battery + (batteryTempDiff * BATTERY_HEAT_STEP)
	else
		engine.state.temp.battery = engine.state.temp.battery - (batteryTempDiff * BATTERY_COOL_STEP) - datarefs.engineOpen * 0.05
	end

	------ Motor -----
	local motorTemp = datarefs.oat + datarefs.battery_on * datarefs.throttle * MOTOR_HEATING_FACTOR - (IAS_COOLING_FACTOR * datarefs.ias)
	local motorTempDiff = math.abs(motorTemp - engine.state.temp.motor)

	-- Don't change temp if it's near final temp
	if (engine.state.temp.motor > motorTemp - MOTOR_TEMP_THRESHOLD) and (engine.state.temp.motor < motorTemp + MOTOR_TEMP_THRESHOLD) then
		engine.state.temp.motor = motorTemp
		return
	end

	if (motorTemp > engine.state.temp.motor) then
		engine.state.temp.motor = engine.state.temp.motor + (motorTempDiff * MOTOR_HEAT_STEP)
	else
		engine.state.temp.motor = engine.state.temp.motor - (motorTempDiff * MOTOR_COOL_STEP) - datarefs.engineOpen * 0.25
	end

	-- Top at max temp
	if (engine.state.temp.motor > MOTOR_MAX_TEMP) then engine.state.temp.motor = MOTOR_MAX_TEMP end


end

return engine
