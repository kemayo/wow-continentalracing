local myname, ns = ...

if not ns.DEBUG then
	return
end

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
