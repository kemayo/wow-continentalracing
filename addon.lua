local myname, ns = ...

ns.DEBUG = C_AddOns.GetAddOnMetadata(myname, "Version") == '@'..'project-version@'

local HBDP = LibStub("HereBeDragons-Pins-2.0")

EventUtil.ContinueOnAddOnLoaded(myname, function()
	ContinentalRacingDB = ContinentalRacingDB or {}
end)

local RaceMixin = {}
function RaceMixin:OnLoad()
	self:SetSize(20, 20)
	if not InCombatLockdown() then
		self:SetPassThroughButtons("LeftButton", "RightButton", "MiddleButton", "Button4", "Button5")
	end

	self.texture = self:CreateTexture(nil, "ARTWORK")
	self.texture:SetAllPoints()

	self:SetScript("OnEnter", self.OnMouseEnter)
	self:SetScript("OnLeave", self.OnMouseLeave)
end
function RaceMixin:OnAcquire(info)
	self.poiInfo = info
	self.areaPoiID = info.areaPoiID
	self.name = info.name
	self.description = info.description
	self.tooltipWidgetSet = info.tooltipWidgetSet
	self.iconWidgetSet = info.iconWidgetSet
	self.textureKit = info.uiTextureKit

	self.texture:SetAtlas(info.atlasName)
end
function RaceMixin:OnMouseEnter()
	-- /dump C_AreaPoiInfo.GetAreaPOIInfo(2248, 7781)
	-- see: AreaPOIPinMixin:TryShowTooltip
	local verticalPadding
	-- local isTimed, hideTimer = C_AreaPoiInfo.IsAreaPOITimed(self.areaPoiID)
	local tooltip = GetAppropriateTooltip()
	tooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip_SetTitle(tooltip, self.name, HIGHLIGHT_FONT_COLOR)
	if self.description and self.description ~= "" then
		GameTooltip_AddNormalLine(tooltip, self.description)
	end

	if ns.data[self.areaPoiID] then
		ns.AddRaceTimesToTooltip(tooltip, ns.data[self.areaPoiID])
	end

	if self.tooltipWidgetSet then
		local overflow = GameTooltip_AddWidgetSet(tooltip, self.tooltipWidgetSet, 10)
		if overflow then
			verticalPadding = -overflow
		end
	end

	if ns.DEBUG then
		tooltip:AddDoubleLine("areaPoiID", self.areaPoiID)
		tooltip:AddDoubleLine("originalMapID", self.originalMapID)
	end

	tooltip:Show()
	if verticalPadding then
		tooltip:SetPadding(0, verticalPadding)
	end

	-- Could do this, but it'd confuse listeners because these aren't on the right map
	-- EventRegistry:TriggerEvent("AreaPOIPin.MouseOver", self, true, self.poiInfo.areaPoiID, self.poiInfo.name or "")
end
function RaceMixin:OnMouseLeave()
	GetAppropriateTooltip():Hide()
end


-- frameType, parent, template, resetFunc, forbidden, frameInitializer, capacity
local pool = CreateFramePool(
	"Frame", nil, nil,
	function(_, frame)
		frame.texture:SetVertexColor(1, 1, 1, 1)
	end,
	nil,
	function(frame)
		Mixin(frame, RaceMixin)
		frame:OnLoad()
	end
)

local function addRaceForMap(mapID, childMapID, areaPoiID, definitelyARace)
	local info = C_AreaPoiInfo.GetAreaPOIInfo(childMapID, areaPoiID)
	-- print(">>>info", info.atlasName, info.name)
	if not (info and (definitelyARace or strlower(info.atlasName or "") == "racing")) then
		return
	end
	local x, y = info.position:GetXY()
	local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(childMapID, mapID)
	if not minX then
		return
	end
	local allComplete
	if ns.data[areaPoiID] and ns.data[areaPoiID].achievements then
		allComplete = true
		for _, achievementID in ipairs(ns.data[areaPoiID].achievements) do
			local _, name, _, complete, _, _, _, _, _, icon, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)
			if not complete then
				allComplete = false
				break
			end
		end
	end
	if ContinentalRacingDB.only_incomplete and allComplete then
		return
	end
	local tx = Lerp(minX, maxX, x)
	local ty = Lerp(minY, maxY, y)
	local icon = pool:Acquire()
	icon:OnAcquire(info)
	icon.originalMapID = childMapID

	if allComplete then
		icon.texture:SetVertexColor(0, 1, 0)
	elseif allComplete == nil and ns.DEBUG then
		-- *I* want to know when there's missing data
		icon.texture:SetVertexColor(0.7, 0, 1)
	end

	HBDP:AddWorldMapIconMap(myname, icon, mapID, tx, ty)
end
local function addRacesForMap(mapID, childInfo)
	-- print(">child", childInfo.mapID)
	for _, raceID in ipairs(C_AreaPoiInfo.GetDragonridingRacesForMap(childInfo.mapID)) do
		-- print(">>race", raceID)
		addRaceForMap(mapID, childInfo.mapID, raceID, true)
	end
	-- Seasonal cups aren't races. This is presumably also why they don't
	-- respect the toggle.
	for _, areaPoiID in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(childInfo.mapID)) do
		-- print(">>poi", areaPoiID)
		addRaceForMap(mapID, childInfo.mapID, areaPoiID)
	end
end

local function refreshMapPins(mapID)
	-- all needed data should be loaded by now
	-- print("map", mapID)
	if not mapID then return end
	local mapInfo = C_Map.GetMapInfo(mapID)
	if not (mapInfo and mapInfo.mapType == Enum.UIMapType.Continent) then
		return
	end

	pool:ReleaseAll()
	HBDP:RemoveAllWorldMapIcons(myname)

	if not C_CVar.GetCVarBool("dragonRidingRacesFilter") then
		return
	end

	for _, childInfo in ipairs(C_Map.GetMapChildrenInfo(mapID)) do
		if childInfo.mapType == Enum.UIMapType.Zone then
			addRacesForMap(mapID, childInfo)
		end
	end
	if ns.extra_children[mapID] then
		for _, childID in ipairs(ns.extra_children[mapID]) do
			addRacesForMap(mapID, C_Map.GetMapInfo(childID))
		end
	end
end

EventRegistry:RegisterCallback("MapCanvas.MapSet", function(_, mapID)
	refreshMapPins(mapID)
end)

EventRegistry:RegisterFrameEventAndCallback("CVAR_UPDATE", function(_, cvar, value)
	if cvar == "dragonRidingRacesFilter" and WorldMapFrame:IsVisible() then
		refreshMapPins(WorldMapFrame:GetMapID())
	end
end)

local function isChecked(key)
	return ContinentalRacingDB[key]
end
local function setChecked(key)
	ContinentalRacingDB[key] = not ContinentalRacingDB[key]
	refreshMapPins(WorldMapFrame:GetMapID())
end
Menu.ModifyMenu("MENU_WORLD_MAP_TRACKING", function(owner, rootDescription, contextData)
	local mapInfo = C_Map.GetMapInfo(owner:GetParent():GetMapID())
	if mapInfo and mapInfo.mapType == Enum.UIMapType.Continent then
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
end)
