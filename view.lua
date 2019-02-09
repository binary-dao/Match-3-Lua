--Visualization of the game, VIEW part

local ASCII_SHIFT = 65

local function numberToLetter(number)
	return string.char(number + ASCII_SHIFT)
end

--entry point
os.execute("cls")

--show caption
print("    0 1 2 3 4 5 6 7 8 9")
print("   --------------------")

--show field with prefixes
for i=0, MAX_ROWS-1 do
	outputString = i .. " |";
	for j=0, MAX_COLS-1 do
		outputString = outputString .. " " .. numberToLetter(chipArray[i][j])
	end
	print(outputString)
end

