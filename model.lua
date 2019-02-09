--Logic of the game, MODEL part

--constants and variables
MAX_ROWS = 10
MAX_COLS = 10
BASE_CHIP_TYPES = 6

chipArray = {}

--variables for chips temporary exchange
tempCol1 = -1
tempRow1 = -1
tempCol2 = -1
tempRow2 = -1

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
	
	if not chipArray[changeRow][changeCol] then
		print("There is no chip at "..changeRow..";"..changeCol)
		return
	end
	
	
	
end

function Mix()
end

function Tick()
--if is any not fallen
--Drop() and return
--if any collectable
--CollectAll() and return
--if any empty
--Fill() and return
--otherwise
	print("No changes")
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
			isMove = IsPossibleMoveForChip(i, j);
			if answerVector then
				return true
			end
		end
	end
	return false
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
	for i=0, #excludes do
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
end

--entry point
GenerateField()
dofile("view.lua")
dofile("controller.lua")