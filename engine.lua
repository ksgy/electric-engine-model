local ITT_HEATING_FACTOR = 750
local ITT_HEAT_STEP = 0.002
local ITT_COOL_STEP = 0.0045
local ITT_TEMP_THRESHOLD = 0.1
local ITT_MAX_TEMP = 750

local IAS_COOLING_FACTOR = 0.0045

local engine = {
	state = {
		temp = {
			itt = 0,
		},
		ng = 10,
	}
}

engine.init = function(datarefs)
	engine.state.temp.itt = datarefs.itt
end

engine.update = function(datarefs)
	-- datarefs = {
	-- 	oat,
	-- 	fuel,
	--	battery_on
	-- 	throttle
	-- 	starter
	--  ias
	-- }

	------ ITT ----
	local ias = datarefs.ias
	if (ias <= 0) then ias = 1 end
	local ittTemp = datarefs.oat + datarefs.battery_on * datarefs.fuel * datarefs.starter * ITT_HEATING_FACTOR - (IAS_COOLING_FACTOR * ias)
	local ittTempDiff = math.abs(ittTemp - engine.state.temp.itt)

	-- Don't change temp if it's near final temp
	if (engine.state.temp.itt > ittTemp - ITT_TEMP_THRESHOLD) and (engine.state.temp.itt < ittTemp + ITT_TEMP_THRESHOLD) then
		engine.state.temp.itt = ittTemp
		return
	end

	if (ittTemp > engine.state.temp.itt) then
		engine.state.temp.itt = engine.state.temp.itt + (ittTempDiff * ITT_HEAT_STEP)
	else
		engine.state.temp.itt = engine.state.temp.itt - (ittTempDiff * ITT_COOL_STEP) - datarefs.engineOpen * 0.25
	end

	-- Cap at max temp
	if (engine.state.temp.itt > ITT_MAX_TEMP + datarefs.oat) then engine.state.temp.itt = ITT_MAX_TEMP + datarefs.oat end

end

return engine
