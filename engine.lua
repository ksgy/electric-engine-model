local BATTERY_HEATING_FACTOR = 45
local BATTERY_HEAT_STEP = 0.0016
local BATTERY_COOL_STEP = 0.0009
local BATTERY_TEMP_THRESHOLD = 0.5

local IAS_COOLING_FACTOR = 0.0045

local MOTOR_HEATING_FACTOR = 50
local MOTOR_HEAT_STEP = 0.002
local MOTOR_COOL_STEP = 0.0045
local MOTOR_TEMP_THRESHOLD = 0.1
local MOTOR_MAX_TEMP = 50

local ESC_HEATING_FACTOR = 50
local ESC_HEAT_STEP = 0.001
local ESC_COOL_STEP = 0.008
local ESC_TEMP_THRESHOLD = 0.1
local ESC_MAX_TEMP = 40

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

	-- Cap at max temp
	if (engine.state.temp.motor > MOTOR_MAX_TEMP) then engine.state.temp.motor = MOTOR_MAX_TEMP end

	------ Electronic Speed Controller -----
	local escTemp = datarefs.oat + datarefs.battery_on * datarefs.throttle * ESC_HEATING_FACTOR
	local escTempDiff = math.abs(escTemp - engine.state.temp.esc)

	-- Don't change temp if it's near final temp
	if (engine.state.temp.esc > escTemp - ESC_TEMP_THRESHOLD) and (engine.state.temp.esc < escTemp + ESC_TEMP_THRESHOLD) then
		engine.state.temp.esc = escTemp
		return
	end

	if (escTemp > engine.state.temp.esc) then
		engine.state.temp.esc = engine.state.temp.esc + (escTempDiff * ESC_HEAT_STEP)
	else
		engine.state.temp.esc = engine.state.temp.esc - (escTempDiff * ESC_COOL_STEP)
	end

	-- Cap at max temp
	if (engine.state.temp.esc > ESC_MAX_TEMP) then engine.state.temp.esc = ESC_MAX_TEMP end


end

return engine
