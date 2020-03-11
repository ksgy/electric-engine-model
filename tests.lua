local engine = require("engine")
local test = require("unit-test")

local testDataRefs = {
	oat = 20,
	battery_on = 1,
	battery_v = 12,
	battery_a = 5,
	throttle = 0,
	engineOpen = 0,
	ias = 80,
}

----- TESTS -------

-- Test init

	print("Test init")
	engine.init({
		battery = 45,
		motor = 50,
		esc = 40
	})

	test.testValue("At  0 min - MOTOR temp", engine.state.temp.motor, 50)
	test.testValue("At  0 min - BATTERY temp", engine.state.temp.battery, 45)
	print('')


-- Test cool down to OAT in 5 mins

	print("Test cool down to OAT in 5 mins ")
	for i = 1, 5*60 do
		engine.update(testDataRefs)
	end

	test.testValue("At  5 min cool down - MOTOR temp", engine.state.temp.motor, 23, 1)
	test.testValue("At 10 min cool down - BATTERY temp", engine.state.temp.battery, 37, 1)
	print('')

-- Test cool down to OAT in another 5 mins
	print("Test cool down to OAT in another 5 mins")
	for i = 1, 5*60 do
		engine.update(testDataRefs)
	end

	test.testValue("At 10 min cool down - MOTOR temp", engine.state.temp.motor, 20, 1)
	test.testValue("At 10 min cool down - BATTERY temp", engine.state.temp.battery, 28, 1)
	print('')

-- Test cool down to OAT in another 5 mins (battery)
	print("Test cool down to OAT in another 5 mins")
	for i = 1, 5*60 do
		engine.update(testDataRefs)
	end

	test.testValue("At 10 min cool down - MOTOR temp", engine.state.temp.motor, 20, 1)
	test.testValue("At 10 min cool down - BATTERY temp", engine.state.temp.battery, 20, 1)
	print('')

-- 10 min full power test, then cutoff
	print("10 min full power test, then cutoff")
	testDataRefs.oat = 20
	testDataRefs.battery = 1
	testDataRefs.throttle = 1
	testDataRefs.engineOpen = 1
	engine.init({
		battery = 20,
		motor = 20,
		esc = 20
	})

	test.testValue("At 0 min - BATTERY temp", engine.state.temp.battery, 20)
	test.testValue("At 0 min - MOTOR temp", engine.state.temp.motor, 20)

	for j = 1, 10 do
		for i = 1, 60 do
			engine.update(testDataRefs)
		end
		local testValue = 20 + j * 6, 1
		if (testValue > 60) then
			testValue = 60
		end
		test.testValue("At ".. j .. " min - BATTERY temp", engine.state.temp.battery, 20 + j * 2.5, 1)
		test.testValue("At ".. j .. " min - MOTOR temp", engine.state.temp.motor, testValue, 2)
		-- print('  --')
	end
	print('')

	testDataRefs.throttle = 0

	for j = 11, 35 do
		for i = 1, 60 do
			engine.update(testDataRefs)
		end
		local testValue = 45 - (j - 10) * 1.5
		if (testValue < 20) then
			testValue = tonumber(testDataRefs.oat)
		end

		test.testValue("At ".. j .. " min - BATTERY temp", engine.state.temp.battery, testValue, 2)
	end
	print('')

-- -- 20 min full power test
-- 	print("20 min full power test")
-- 	testDataRefs.oat = 20
-- 	testDataRefs.battery = 1
-- 	testDataRefs.throttle = 1
-- 	testDataRefs.engineOpen = 1
-- 	engine.init({
-- 		oat = 20
-- 	})

-- 	test.testValue("At 0 min - BATTERY temp", engine.state.temp.battery, 20)

-- 	for j = 1, 20 do
-- 		for i = 1, 60 do
-- 			engine.update(testDataRefs)
-- 		end
-- 		local testValue = 20 + j * 2.5
-- 		if testValue > 60 then testValue = 60 end
-- 		test.testValue("At ".. j .. " min - BATTERY temp", engine.state.temp.battery, testValue)
-- 	end
test.testAll()
