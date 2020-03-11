local test = {}
test.passedTests = 0
test.failedTests = 0

function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

test.testValue = function(testvalue, value, shouldBe, threshold)
	local passed = "FAIL"
	local check = false
	local testColourPre
	local sbtext = ''
	local th = ''

	if threshold then
		check = value >= shouldBe - threshold and value <= shouldBe + threshold
		th = " +/- "..threshold
	else
		check = round2(value, 1) == round2(shouldBe, 1)
	end

	if check then
		passed = "PASS"
		testColourPre = "\27[32m"
		test.passedTests = test.passedTests+1
	else
		testColourPre = "\27[31m"
		test.failedTests = test.failedTests+1
		sbtext = "should be (" .. shouldBe .. ")"
	end

	print(testColourPre .. string.format("  %-70s %-30s %s", testvalue, value .. th .. " " .. sbtext, passed) .. "\27[m")
end

test.testAll = function ()
	print ("---------------")
	print (test.passedTests .. " tests passed, " .. test.failedTests .. " failed of " .. test.failedTests + test.passedTests .. " tests")
end

return test
