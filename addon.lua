local myname, ns = ...

ns.CVAR = 'dragonRidingRacesFilter'

-- ns.allowTooltipWidgets = false
function ns.AddToTooltip(tooltip, pin)
	if ns.data[pin.areaPoiID] then
		ns.AddRaceTimesToTooltip(tooltip, ns.data[pin.areaPoiID])
	end
end

local function allComplete(areaPoiID)
	if not (ns.data[areaPoiID] and ns.data[areaPoiID].achievements) then
		return
	end
	for _, achievementID in ipairs(ns.data[areaPoiID].achievements) do
		local _, name, _, complete, _, _, _, _, _, icon, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)
		if not complete then
			return false
		end
	end
	return true
end
local function shouldShow(areaPoiID, info)
	if ns.db.only_incomplete then
		return not allComplete(areaPoiID)
	end
	return true
end
function ns.GetPointsFromMapInfo(mapInfo, parentMapID)
	local races = {}
	for _, areaPoiID in ipairs(C_AreaPoiInfo.GetDragonridingRacesForMap(mapInfo.mapID)) do
		if shouldShow(areaPoiID) then
			local info = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, areaPoiID)
			races[areaPoiID] = info
		end
	end
	-- Seasonal cups aren't races. This is presumably also why they don't
	-- respect the toggle.
	for _, areaPoiID in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(mapInfo.mapID)) do
		if shouldShow(areaPoiID) then
			local info = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, areaPoiID)
			if info and strlower(info.atlasName or "") == "racing" then
				races[areaPoiID] = info
			end
		end
	end
	return races
end

function ns.OnPinAcquired(pin, info)
	local complete = allComplete(pin.areaPoiID)
	if complete then
		pin.texture:SetVertexColor(0, 1, 0)
	elseif complete == nil and ns.DEBUG then
		-- *I* want to know when there's missing data
		pin.texture:SetVertexColor(0.7, 0, 1)
	end
end

function ns.AddToTrackingMenu(owner, rootDescription, contextData, isChecked, setChecked)
	-- "%s Only"
	local title = RACE_CLASS_ONLY:format(TOOLTIP_UNIT_SPEC_CLASS:format(INCOMPLETE, DRAGONRIDING_RACES_MAP_TOGGLE))
	rootDescription:CreateDivider()
	local check = rootDescription:CreateCheckbox(title, isChecked, setChecked, "only_incomplete")
	check:SetTooltip(function(tooltip, elementDescription)
		-- this display style is from BlizzardWorldMapTemplates.lua,
		-- altered to account for SetTooltip not giving us access to the
		-- same things that SetOnEnter does.
		local owner = tooltip:GetOwner()
		tooltip:ClearAllPoints()
		tooltip:SetPoint("RIGHT", owner, "LEFT", -3, 0)
		tooltip:SetOwner(owner, "ANCHOR_PRESERVE")

		GameTooltip_SetTitle(tooltip, title)
		GameTooltip_AddNormalLine(tooltip, ACHIEVEMENT_FILTER_INCOMPLETE_EXPLANATION)
		tooltip:AddDoubleLine(" ", myname, 1, 1, 1, 0, 1, 1)
	end)
end
