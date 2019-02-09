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

local function parseCommand(command)
	--[[print("OK. You printed " .. command)
	
	for i=0, #stringTab do
		print(stringTab[i])
	end]]--
	stringTab = splitString(command)
	if(not stringTab[0]) then
		print("Your commant is too short. Please use one of this: (i)nit, (t)ick, (m)ove x y direction(l/r/u/d), (s)huffle/mix")
	end
	
	--re-initialization
	if(stringTab[0] == "i" or stringTab[0]=="I") then
		GenerateField()
		dofile("view.lua")
		return
	end
	
	if(stringTab[0] == "t" or stringTab[0]=="T") then
		Tick()
		return
	end
	
	if(stringTab[0] == "m" or stringTab[0]=="M") then
		TryMove(stringTab[1],stringTab[2],stringTab[3])
		dofile("view.lua")
		return
	end
	
	if(stringTab[0] == "s" or stringTab[0]=="S" or stringTab[0]=="mix") then
		Mix()
		dofile("view.lua")
		return
	end
end

repeat
	print("Enter your command please")
	command = io.read()
	parseCommand(command)
until false
