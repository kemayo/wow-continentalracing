local myname, ns = ...

function ns.AddRaceTimesToTooltip(tooltip, race)
	for i, achievementID in pairs(race.achievements) do
		local _, name, _, complete, _, _, _, _, _, icon, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)
		local currencyInfo = race.currencies[i] and C_CurrencyInfo.GetCurrencyInfo(race.currencies[i])
		if complete and not wasEarnedByMe then
			name = string.format(TEXT_MODE_A_STRING_VALUE_TYPE, name, GREEN_FONT_COLOR:WrapTextInColorCode(earnedBy or ACCOUNT_QUEST_LABEL))
			complete = false
		end
		tooltip:AddDoubleLine(
			name or achievementID,
			currencyInfo and ("%.3f s"):format(currencyInfo.quantity / 1000) or "? s",
			complete and 0 or 1, complete and 1 or 0, 0,
			complete and 0 or 1, complete and 1 or 0, 0
		)
	end
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
	local showing
	local function ShowTooltipForRace(name, description, areaPoiID)
		if not ns.data[areaPoiID] then return end
		local tooltip = GetAppropriateTooltip()
		tooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR")
		GameTooltip_SetTitle(tooltip, name)
		if description then
			GameTooltip_AddNormalLine(tooltip, description)
		end

		ns.AddRaceTimesToTooltip(tooltip, ns.data[areaPoiID])

		if ns.DEBUG then
			tooltip:AddDoubleLine("areaPoiID", areaPoiID)
			tooltip:AddDoubleLine("originalMapID", WorldMapFrame:GetMapID())
		end

		tooltip:Show()
		showing = tooltip
	end
	local cache = {}
	WorldMapFrame:RegisterCallback("SetAreaLabel", function(_, labelType, name, description)
		if labelType ~= MAP_AREA_LABEL_TYPE.POI then return end
		-- Sadly, there's not a convenient way I could see to just get the areaPoiID or the areaPoiInfo from this point
		-- As such...
		if not cache[name] then
			local mapID = WorldMapFrame:GetMapID()
			for _, areaPoiID in ipairs(C_AreaPoiInfo.GetDragonridingRacesForMap(mapID)) do
				local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
				if info and info.name then
					cache[info.name] = areaPoiID
				end
			end
			-- seasonal
			for _, areaPoiID in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(mapID)) do
				local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
				if info and info.name then
					cache[info.name] = areaPoiID
				end
			end
		end
		if cache[name] and ns.data[cache[name]] then
			ShowTooltipForRace(name, description, cache[name])
		end
	end)
	WorldMapFrame:RegisterCallback("ClearAreaLabel", function(_, labelType)
		if showing then
			showing:Hide()
			showing = nil
		end
	end)
end)
