--Interface of the game, controller part

local function splitString(inputString, separator)
        if separator == nil then
			--any whitespace
			separator = "%s"
        end
        tab={}
		i = 0
        for str in string.gmatch(inputString, "([^" .. separator .. "]+)") do
			tab[i] = str
			i = i + 1
        end
        return tab
end

local function ParseCommand(command)
	--[[print("OK. You printed " .. command)
	
	for i=0, #stringTab do
		print(stringTab[i])
	end]]--
	stringTab = splitString(command)
	if(not stringTab[0]) then
		print("Your commant is too short. Please use one of this: (i)nit, (t)ick, (m)ove x y direction(l/r/u/d), (s)huffle/mix")
	end
	
	if isMoved then
		if stringTab[0] ~= "t" then
			print("Two chips in the middle of it move! You can use only (t)ick command now")
			return
		end
	end
	
	--re-initialization
	if(stringTab[0] == "i") then
		GenerateField()
		Dump()
		return
	end
	
	if(stringTab[0] == "t") then
		Tick()
		return
	end
	
	if(stringTab[0] == "m") then
		TryMove(tonumber(stringTab[1]),tonumber(stringTab[2]),stringTab[3])
		Dump()
		return
	end
	
	if(stringTab[0] == "s" or stringTab[0]=="mix") then
		Mix()
		Dump()
		return
	end
end

repeat
	print("Enter your command please")
	command = io.read()
	ParseCommand(command)
until false
