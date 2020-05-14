local ITT_COOL_STEP = 0.0045
local ITT_TEMP_THRESHOLD = 0.1
local ITT_MAX_TEMP = 750

local IAS_COOLING_FACTOR = 0.0045

local engine = {
	currentState = 1,
	states = {
		--
		{
			name = "1 cold",
			TARGET_ITT_TEMP = 0, -- gets updated by oat
			ITT_HEAT_STEP = 0,
		},
		--
		{
			name = "2 starter on",
			TARGET_ITT_TEMP = 0, -- gets updated by oat
			ITT_HEAT_STEP = 0,
		},
		--
		{
			name = "3 eng fuel burn",
			TARGET_ITT_TEMP = 200,
			ITT_HEAT_STEP = 0.01,
		},
		--
		{
			name = "4 eng accc",
			TARGET_ITT_TEMP = 400,
			ITT_HEAT_STEP = 0.01,
		},
		--
		{
			name = "5 ign off",
			TARGET_ITT_TEMP = 500,
			ITT_HEAT_STEP = 0.004,
		},
		--
		{
			name = "6 starter off",
			TARGET_ITT_TEMP = 650,
			ITT_HEAT_STEP = 0.003,
		},
		--
		{
			name = "7 eng stabize",
			TARGET_ITT_TEMP = 550,
			ITT_HEAT_STEP = 0.003,
		},
	},
	temp = {
		itt = 0,
		oat = 0,
	},
	ng = 0,
	burningFuel = 0,
}

engine.init = function(datarefs)
	engine.temp.itt = datarefs.oat
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

	---------- update OAT ---------
	engine.states[1].TARGET_ITT_TEMP = datarefs.oat
	engine.states[2].TARGET_ITT_TEMP = datarefs.oat
	-------------------------------

	engine.currentState = 1
	engine.burningFuel = 0
	-- set current state based on datarefs
	if (
		datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 0 and
		engine.burningFuel == 0
	) then
		engine.currentState = 2
	end

	if (
		datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 1 and
		engine.burningFuel == 0
	) then
		engine.currentState = 3
		engine.burningFuel = 1
	end

	if (datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 1 and
		engine.burningFuel == 1
	) then
		engine.currentState = 4
	end

	if (datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 1 and
		engine.burningFuel == 1 and
		engine.ng > 25
	) then
		engine.currentState = 5
	end

	if (datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 1 and
		engine.burningFuel == 1 and
		engine.ng > 45  -- TODO check ng when to turn off
	) then
		engine.currentState = 6
	end

	if (datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 1 and
		engine.burningFuel == 1 and
		engine.ng > 60 and -- TODO check idle ng
		engine.currentState == 6
	) then
		engine.currentState = 7
	end

	------ ITT ----
	local ias = datarefs.ias
	if (ias <= 0) then ias = 1 end
	local ittTemp = datarefs.oat + engine.states[engine.currentState].TARGET_ITT_TEMP - (IAS_COOLING_FACTOR * ias)
	local ittTempDiff = math.abs(ittTemp - engine.temp.itt)

	-- Don't change temp if it's near final temp
	if (engine.temp.itt > ittTemp - ITT_TEMP_THRESHOLD) and (engine.temp.itt < ittTemp + ITT_TEMP_THRESHOLD) then
		engine.temp.itt = ittTemp
		return
	end

	if (ittTemp > engine.temp.itt) then
		engine.temp.itt = engine.temp.itt + (ittTempDiff * engine.states[engine.currentState].ITT_HEAT_STEP)
	else
		engine.temp.itt = engine.temp.itt - (ittTempDiff * ITT_COOL_STEP) - (IAS_COOLING_FACTOR * IAS)
	end

	-- Cap at max temp
	if (engine.temp.itt > ITT_MAX_TEMP + datarefs.oat) then engine.temp.itt = ITT_MAX_TEMP + datarefs.oat end

	-- ng --
	engine.ng = engine.ng + 0.07
end

return engine
