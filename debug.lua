local myname, ns = ...

--[[
Note to self about how this works:

A race is a quest, behind the scenes.

When a race starts we see CURRENCY_DISPLAY_UPDATE for assorted currencies
that're state-tracking:

* 2018: Dragon Racing - Temp Storage - Race Quest ID
* 2040: Dragon Racing - Scoreboard - Personal Best Time
* 2041: Dragon Racing - Scoreboard - Personal Best Time - Fraction 1

Then there's a QUEST_ACCEPTED for the same quest value that has been put into
2018.

During the race there's sometimes more updates to 2018, seeming to
remove/readd the questID for no obvious reason.

When a race finishes we see more CURRENCY_DISPLAY_UPDATEs:

* 2016: Dragon Racing - Scoreboard - Race Complete Time
* 2017: Dragon Racing - Scoreboard - Race Complete Time - Fraction 1
* 2124: Dragon Racing - Scoreboard - Race Complete Time - Fraction 10
* 2125: Dragon Racing - Scoreboard - Race Complete Time - Fraction 100
* 2236: Dragon Racing - Scoreboard - Race Complete Time MS
* 2040: Dragon Racing - Scoreboard - Personal Best Time
* 2041: Dragon Racing - Scoreboard - Personal Best Time - Fraction 1
* 2131: Dragon Racing - Scoreboard - Personal Best Time - Fraction 10
* 2132: Dragon Racing - Scoreboard - Personal Best Time - Fraction 100
* 2019: Dragon Racing - Scoreboard - Race Complete Time - Silver
* 2020: Dragon Racing - Scoreboard - Race Complete Time - Gold
* [currency for the current race]

The race complete time values are always updated for the current race. The
personal best values still fire if you *don't* beat your best, but they're
just being reset to still contain said best.

Then there's a QUEST_REMOVED for the race-quest, and we're done.

...yes, this is a really weird way to store all this.

All the CURRENCY_DISPLAY_UPDATEs happen twice: once to reset it to 0, and
again to set it to the new value.

2018 seems to stick around containing whatever the questID of the last race
the character did, until you start a new race.
--]]

if not ns.DEBUG then
	return
end

do
	local raceActive = false
	local irrelevant = {
		[2016] = true,
		[2017] = true,
		[2018] = true,
		[2019] = true,
		[2020] = true,
		[2040] = true,
		[2041] = true,
		[2124] = true,
		[2125] = true,
		[2131] = true,
		[2132] = true,
		[2236] = true,
	}
	EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", function(_, currencyType, quantity, quantityChange, quantityGainSource, destroyReason)
		if currencyType == 2018 and quantity > 0 then
			raceActive = quantity
		end
		if not raceActive then return end
		if irrelevant[currencyType] then return end
		if quantity <= 0 then return end
		-- this *might* be the race currency
		print("Possible race currency", currencyType, quantity)
	end)
	EventRegistry:RegisterFrameEventAndCallback("QUEST_REMOVED", function(_, questID)
		if questID == raceActive then
			print("RACE ENDED", questID, C_QuestLog.GetTitleForQuestID(questID))
			raceActive = false
		end
	end)
end

-- Helpful dump command:

local function printf(str, ...)
	return print(string.format(str, ...))
end

local function coord(x, y)
	return floor(x * 10000 + 0.5) * 10000 + floor(y * 10000 + 0.5)
end

local function printAreaPois(mapID, areaPoiIDs, primaryOnly)
	local any = false
	for _, areaPoiID in ipairs(areaPoiIDs) do
		local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
		if (not primaryOnly) or info.isPrimaryMapForPOI then
			printf("[%d] = Race({}, {}, {%d, %d}), -- %s", areaPoiID, mapID, coord(info.position:GetXY()), info.name)
			any = true
		end
	end
	return any
end

local function mapIDFromInput(msg)
	if msg:match("%d+") then
		return tonumber(msg)
	end
	if WorldMapFrame and WorldMapFrame:IsVisible() then
		return WorldMapFrame:GetMapID()
	end
	return C_Map.GetBestMapForUnit('player')
end

_G["SLASH_"..myname:upper().."1"] = "/racedump"
SlashCmdList[myname:upper()] = function(msg)
	local startMapID = mapIDFromInput(msg)
	if not startMapID then
		return print("No mapID found from input", msg)
	end
	local mapIDs
	if msg:match("children") then
		mapIDs = {}
		for _, childInfo in ipairs(C_Map.GetMapChildrenInfo(startMapID)) do
			if childInfo.mapType == Enum.UIMapType.Zone then
				table.insert(mapIDs, childInfo.mapID)
			end
		end
		if ns.extra_children[startMapID] then
			for _, childID in ipairs(ns.extra_children[startMapID]) do
				table.insert(mapIDs, childID)
			end
		end
	else
		mapIDs = {startMapID}
	end
	if #mapIDs == 0 then
		return print("No maps to search", msg)
	end
	for _, mapID in ipairs(mapIDs) do
		local info = mapID and C_Map.GetMapInfo(mapID)
		if not info then
			return print("No map found to search")
		end
		printf("-- %s (%d)", info.name, mapID)
		if not printAreaPois(mapID, C_AreaPoiInfo.GetDragonridingRacesForMap(mapID)) then
			print("-- no dragonriding races")
		end
		local function isRacePOI(areaPoiID)
			-- closure because we need the mapID
			local areaPoi = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
			return areaPoi and strlower(areaPoi.atlasName or "") == "racing"
		end
		if not printAreaPois(mapID, tFilter(C_AreaPoiInfo.GetAreaPOIForMap(mapID), isRacePOI, true)) then
			print("-- no POI races")
		end
	end
end
