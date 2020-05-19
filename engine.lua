-- TODO auto stop engine starting after 20s

local GRAPH_TYPES = {
	LINEAR = 1,
	HYPER = 2,
	PARAB = 3
}
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
			graph = GRAPH_TYPES.LINEAR,
			rate = 1,
		},
		--
		{
			name = "3 eng fuel burn",
			TARGET_ITT_TEMP = 400,
			ITT_HEAT_STEP = 0.01,
			graph = GRAPH_TYPES.LINEAR,
			rate = 1.7,
		},
		--
		{
			name = "4 eng accc",
			TARGET_ITT_TEMP = 450,
			ITT_HEAT_STEP = 0.01,
			graph = GRAPH_TYPES.LINEAR,
			rate = 1.7,
		},
		--
		{
			name = "5 ign off",
			TARGET_ITT_TEMP = 600,
			ITT_HEAT_STEP = 0.004,
			graph = GRAPH_TYPES.HYPER,
			rate = 1.2,
		},
		--
		{
			name = "6 starter off",
			TARGET_ITT_TEMP = 650,
			ITT_HEAT_STEP = 0.003,
			graph = GRAPH_TYPES.HYPER,
			rate = 1,
		},
		--
		{
			name = "7 eng stabize",
			TARGET_ITT_TEMP = 550,
			ITT_HEAT_STEP = 0.003,
			graph = GRAPH_TYPES.LINEAR,
			rate = 1,
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
		engine.ng > 20
	) then
		engine.currentState = 5
	end

	if (datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 1 and
		engine.burningFuel == 1 and
		engine.ng > 38
	) then
		engine.currentState = 6
	end

	if (datarefs.battery_on == 1 and
		datarefs.starter == 1 and
		datarefs.fuel == 1 and
		engine.burningFuel == 1 and
		engine.ng > 59 and
		engine.currentState == 6
	) then
		engine.currentState = 7
	end

	------ ITT ----
	local ias = datarefs.ias
	if (ias <= 0) then ias = 1 end
	local ittTemp = datarefs.oat + engine.states[engine.currentState].TARGET_ITT_TEMP - (IAS_COOLING_FACTOR * ias)
	local ittTempDiff = math.abs(ittTemp - engine.temp.itt) -- parabolic
	if (engine.states[engine.currentState].graph == GRAPH_TYPES.PARAB) then
		ittTempDiff = ittTemp - ittTempDiff
	end

	if engine.states[engine.currentState].rate then
		ittTempDiff = ittTempDiff * engine.states[engine.currentState].rate
	else
		engine.states[engine.currentState].rate = 1
	end

	if (ittTemp > engine.temp.itt) then
		-- heating
		if (engine.states[engine.currentState].graph == GRAPH_TYPES.HYPER or engine.states[engine.currentState].graph == GRAPH_TYPES.PARAB) then
			engine.temp.itt = engine.temp.itt + (ittTempDiff * engine.states[engine.currentState].ITT_HEAT_STEP)
		else
			engine.temp.itt = engine.temp.itt + (engine.states[engine.currentState].ITT_HEAT_STEP * engine.states[engine.currentState].rate * 100) -- linear
		end
	else
		-- cooling
		engine.temp.itt = engine.temp.itt - (ittTempDiff * ITT_COOL_STEP) - (IAS_COOLING_FACTOR * ias)
	end

	-- Cap at max temp
	if (engine.temp.itt > ITT_MAX_TEMP + datarefs.oat) then engine.temp.itt = ITT_MAX_TEMP + datarefs.oat end

	-- ng --
	if engine.currentState >= 2 then
		engine.ng = engine.ng + 0.06
		if engine.ng > 60 then
			engine.ng = 60
			--	TODO calc
		end
	end
end

return engine
