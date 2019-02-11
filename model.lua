--Logic of the game, MODEL part

--constants and variables
MAX_ROWS = 10
MAX_COLS = 10
BASE_CHIP_TYPES = 6

chipArray = {}

--variables for chips temporary exchange
local tempCol1 = -1
local tempRow1 = -1
local tempCol2 = -1
local tempRow2 = -1
--is two chips justExchanged?
isMoved = false

isWaitUntilNoMatches = false

--for debug purposes
local inspect = require('inspect')

function Dump()
	dofile("view.lua")
end

local function CollectLine(dotLine)
	
	for i=1, #dotLine do
		chipArray[dotLine[i][1]][dotLine[i][2]] = -1
	end
end

local function HasValue (tab, val)
    for i=0, #tab do
        if tab[i]==val then
            return true
        end
    end
    return false
end

--generate one of the random number [0, maxNumber) but except excludes, DON'T try to use it if excludes more than maxNumber or equal
local function GetRandomWithExcludes(maxNumber, excludes)
	if (#excludes >= maxNumber) then
		print("GetRandomWithExcludes can't be done with so much excludes!");
		return -1
	end

	answer = math.random(maxNumber);
	for i=1, #excludes do
		if HasValue(excludes, answer) then
			answer = answer + 1
			if (answer >= maxNumber) then
				answer = 0
		end else
			return answer;
		end
	end

	return answer;
end

local function IsFullMatchCheck()
	local isNewCombinations = false
	local collectedLine = {}

	--uses to generate bonus for both horizontal and vertical line at once
	horizontalLine = {}

	local currentType = -2

	local bonusRow = {}

	--horizontal check
	for i = 0, MAX_ROWS - 1 do
		for j=0, MAX_COLS - 1 do
			--new line
			if (j == 0 or currentType < 0 or currentType ~= chipArray[i][j]) then
				if (#collectedLine >= 3) then
					--BONUS functionality, turned off
					--for k=0, #line do
						---foreach (var iterChip in line) horizontalLine.Add(iterChip);
					--if (line.Count >= 4) bonusRow[j] = ChipBehaviour.BOMB_TYPE;
					isNewCombinations = true;
					CollectLine(collectedLine)
				end

				collectedLine = {}
				currentType = chipArray[i][j];
			end
			local dot = {i,j}
			table.insert(collectedLine, dot)
		end
	end
	
		--vertical check
	for i = 0, MAX_ROWS - 1 do
		for j=0, MAX_COLS - 1 do
			--//new line
			if (chipArray[i][j]==-1 or i == 0 or currentType < 0 or currentType ~= chipArray[i][j]) then
				if (#collectedLine >= 3) then
					print("Enough to collect: vertical")
					--BONUS functionality, turned off
					--[[if (line.Count >= 4) bonusRow[j] = ChipBehaviour.ROCKET_TYPE;
					foreach (var iterChip in horizontalLine)
						if (line.Contains(iterChip))
							bonusRow[j] = ChipBehaviour.RAINBOW_TYPE;]]--
					isNewCombinations = true;
					CollectLine(collectedLine)
				end

				collectedLine = {}
				currentType = chipArray[i][j];
			end
			local dot = {i,j}
			table.insert(collectedLine, dot)
		end
	end
	
	return isNewCombinations;
end

function TryMove(col,row,direction)
	changeCol = -1
	changeRow = -1
	
	if(direction == "l") then
		changeCol = col - 1
		changeRow = row
	end
	
	if(direction == "r") then
		changeCol = col + 1
		changeRow = row
	end
	
	if(direction == "u") then
		changeCol = col
		changeRow = row - 1
	end
	
	if(direction == "d") then
		changeCol = col
		changeRow = row + 1
	end
	
	print("changeRow " .. changeRow)
	print("changeCol " .. changeCol)
	
	if not (chipArray[changeRow][changeCol]) then
		print("There is no chip at "..changeRow..";"..changeCol)
		return
	end
	
	tempType = chipArray[row][col]
	chipArray[row][col] = chipArray[changeRow][changeCol]
	chipArray[changeRow][changeCol] = tempType
	
	tempCol1 = col
	tempRow1 = row
	tempCol2 = changeCol
	tempRow2 = changeRow
	
	print("isMoved = true")
	isMoved = true
end

--looking for 3 same chips recursively
local function GetAnySameChips(currentType)
	local sameChips = {}
	for i = 0, MAX_ROWS-1 do
		for j = 0, MAX_COLS-1 do
			if (chipArray[i][j] and chipArray[i][j] == currentType) then
				table.insert(sameChips, chipArray[i][j])
				if (#sameChips >= 3) then
					return sameChips
				end
			end
		end
	end

	--did not find enough chips of this type, search next recursively
	return GetAnySameChips(currentType + 1);
end

--2D to linear: row*MAX_ROWS+col
local function GetLinearIndex(row, col)
	return row * MAX_ROWS + col;
end


--linear to 2D: row = index / MAX_ROWS; col = index % MAX_ROWS
function GetRowOfLinear(index)
	return index // MAX_ROWS;
end

function GetColOfLinear(index)
	return index % MAX_ROWS;
end

function Mix()
		local sameChips = GetAnySameChips(0)
        local excludes = {}

        --linear array is much better to randomize
        local linear = {}

		for i = 0, MAX_ROWS*MAX_COLS-1 do
			table.insert(linear, 1)
		end
		
		--print("#linear: " .. #linear)
		
        --move 3 found close to each other to make sure of one turn
        linear[GetLinearIndex(1, 0)] = sameChips[1];
		table.insert(excludes, GetLinearIndex(1, 0))

        linear[GetLinearIndex(1, 1)] = sameChips[2];
		table.insert(excludes, GetLinearIndex(1, 1))

        linear[GetLinearIndex(2, 2)] = sameChips[3];
        table.insert(excludes, GetLinearIndex(2, 2))

        for i = 0, MAX_ROWS-1 do
			for j = 0, MAX_COLS-1 do
				if not HasValue(sameChips, chipArray[i][j]) then
					local randomPlace = GetRandomWithExcludes(MAX_ROWS * MAX_COLS, excludes);
					linear[randomPlace] = chipArray[i][j];
					table.insert(excludes, randomPlace)
				end
			end
		end

        --move
        --[[for (int i = 0; i < linear.Length; i++)
            linear[i].row = GetRowOfLinear(i);
            linear[i].col = GetColOfLinear(i);
            linear[i].MoveTo(chipArray[GetRowOfLinear(i), GetColOfLinear(i)].gameObject.transform.position);
        end]]--

		--print("#linear: " .. #linear)
		
        --move linear array back to 2D
        for i = 1, #linear do
			--[[print("i "..i)
			print("linear[i] "..linear[i])
			print("GetRowOfLinear(i) "..GetRowOfLinear(i))
			print("GetColOfLinear(i) "..GetColOfLinear(i))
			print("chipArray[GetRowOfLinear(i)] "..inspect(chipArray[GetRowOfLinear(i)]))]]--
			if(linear[i] and GetRowOfLinear(i) and GetColOfLinear(i) and chipArray[GetRowOfLinear(i)] and chipArray[GetRowOfLinear(i)][GetColOfLinear(i)]) then
				chipArray[GetRowOfLinear(i)][GetColOfLinear(i)] = linear[i];
			end
		end
end

local function IsEmptyCells()
	for i=0, MAX_ROWS-1 do
		for j=0, MAX_COLS-1 do
			if chipArray[i][j] == -1 then
				return true
			end
		end
	end
	return false
end

local function DropNew()
	for i=0, MAX_ROWS-1 do
		for j=0, MAX_COLS-1 do
			if chipArray[i][j] == -1 then
				chipArray[i][j] = math.random(BASE_CHIP_TYPES)
			end
		end
	end
end

local function DropColumn(col)
	--only real chips, no whitespaces
	local realColumn = {}
	for i=0, MAX_ROWS-1 do
		if(chipArray[i][col] ~= -1) then
			table.insert(realColumn, chipArray[i][col])
		end
		chipArray[i][col] = -1
	end
	colShift = MAX_ROWS - #realColumn
	print("colShift " .. colShift)
	for i=1, #realColumn do
		chipArray[i + colShift - 1][col] = realColumn[i]
	end
end

local function DropHanging()
	for j=0, MAX_COLS-1 do
		DropColumn(j)
	end
end

local function MoveBack()
	local tempType = chipArray[tempRow1][tempCol1]
	chipArray[tempRow1][tempCol1] = chipArray[tempRow2][tempCol2]
	chipArray[tempRow2][tempCol2] = tempType
	isMoved = false
end

local function SafeGetType(row, col)
	if row < 0 or row >= MAX_ROWS or col < 0 or col >= MAX_COLS then
		return -1
	end
	if chipArray[row][col] then
		return chipArray[row][col]
	end
	return -1
end


local function VirtualMoveCheck(newRow, newCol, initRow, initCol)
	--HORIZONTAL CHECK
	if newRow ~= initRow then
		--CENTRAL HORIZONTAL
		if SafeGetType(initRow, initCol) == SafeGetType(newRow, newCol - 1) and SafeGetType(initRow, initCol) == SafeGetType(newRow, newCol + 1) then
			return true
		end

		--LEFT HORIZONTAL
		if SafeGetType(initRow, initCol) == SafeGetType(newRow, newCol - 1) and	SafeGetType(initRow, initCol) == SafeGetType(newRow, newCol - 2) then
			return true
		end

		--RIGHT HORIZONTAL
		if SafeGetType(initRow, initCol) == SafeGetType(newRow, newCol + 1) and
			SafeGetType(initRow, initCol) == SafeGetType(newRow, newCol + 2) then
			return true;
		end
	end

	--VERTICAL CHECK
	if newCol ~= initCol then
		--CENTRAL VERTICAL
		if SafeGetType(initRow, initCol) == SafeGetType(newRow - 1, newCol) and
			SafeGetType(initRow, initCol) == SafeGetType(newRow + 1, newCol) then
			return true;
		end

		--DOWN VERTICAL
		if SafeGetType(initRow, initCol) == SafeGetType(newRow + 1, newCol) and
			SafeGetType(initRow, initCol) == SafeGetType(newRow + 2, newCol) then
			return true;
		end

		--UP VERTICAL
		if SafeGetType(initRow, initCol) == SafeGetType(newRow - 1, newCol) and
			SafeGetType(initRow, initCol) == SafeGetType(newRow - 2, newCol) then
			return true;
		end
	end

	return false
end

local function IsPossibleMoveForChip(row, col)
	--try move down
	if row + 1 < MAX_ROWS then
		if VirtualMoveCheck(row + 1, col, row, col) then
			return true
		end
	end

	--try move right
	if col + 1 < MAX_COLS then
		if VirtualMoveCheck(row, col + 1, row, col) then
			return true
		end
	end

	--try move up
	if row > 0 then
		if VirtualMoveCheck(row - 1, col, row, col) then
			return true
		end
	end

	--try move left
	if col > 0 then
		if VirtualMoveCheck(row, col - 1, row, col) then
			return true
		end
	end

	return false
end

local function IsAnyPossibleMove()
	for i=0, MAX_ROWS-1 do
		for j=0, MAX_COLS-1 do
			local isMove = IsPossibleMoveForChip(i, j);
			if isMove then
				return true
			end
		end
	end
	return false
end

local function IsHanging()
	for j=0, MAX_COLS-1 do
		local isSignificantInCol = false
		for i=0, MAX_ROWS-1 do
			if(chipArray[i][j] == -1) then
				if(isSignificantInCol) then
					return true
				end
			else
				isSignificantInCol = true
			end
		end
	end
end		

function Tick()
	if isMoved then
		if IsFullMatchCheck() then
			isMoved = false
			isWaitUntilNoMatches = true
			Dump()
			return
		else
			MoveBack()
			Dump()
			return
		end
	end
	if IsHanging() then
		DropHanging()
		Dump()
		return
	end
	if IsEmptyCells() then
		DropNew()
		Dump()
		return
	end
	if isWaitUntilNoMatches then
		if not IsFullMatchCheck() then
			isWaitUntilNoMatches = false
		else
			Dump()
			return
		end
	end
	if not IsAnyPossibleMove() then
		Mix()
		Dump()
		return
	end
	--check for additional/test purposes
	if IsFullMatchCheck() then
		isWaitUntilNoMatches = true
		Dump()
		return
	end
	print("No changes")
end

local function GetRandomTypeForChip(row, col)
	excludes = {}
	if row > 0 then
		if (chipArray[row - 1][col]) then
			table.insert(excludes, chipArray[row - 1][col]);
		end
	end		
	if (col > 0) then
		if (chipArray[row][col - 1]) then
			table.insert(excludes, chipArray[row][col - 1]);
		end
	end		
	return GetRandomWithExcludes(BASE_CHIP_TYPES, excludes);
end

--set another type for two adjacent chips to generate one move in case of no moves
local function GeneratePatchForField()
	chipArray[0][2] = chipArray[0][0]
	chipArray[1][1] = chipArray[0][0]
end

--generate field, no adjacent 
function GenerateField()
	chipArray = {}
	for i=0, MAX_ROWS-1 do
		chipArray[i] = {}
		for j=0, MAX_COLS-1 do
			 chipArray[i][j] = GetRandomTypeForChip(i, j)
		end
	end

	if not IsAnyPossibleMove() then
		GeneratePatchForField();
	end
	
	chipArray[9][0] = -1
	chipArray[9][1] = -1
	chipArray[8][2] = -1
end

--entry point
GenerateField()
Dump()
dofile("controller.lua")