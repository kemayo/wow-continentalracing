local myname, ns = ...

local HBDP = LibStub("HereBeDragons-Pins-2.0")

local extra_children = {
	-- Note: this is only needed for zones where a child-of-child is relevant,
	-- and the child-of-child will have data from GetMapRectOnMap
	[2274] = { -- Khaz Algar
		2339, -- Dornogal (technically a child of Isle of Dorn)
		2346, -- Undermine (technically a child of Ringing Deeps)
	},
}

EventUtil.ContinueOnAddOnLoaded(myname, function()
	ContinentalRacingDB = ContinentalRacingDB or {}
end)

local RaceMixin = {}
function RaceMixin:OnLoad()
	self:SetSize(24, 24)
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
	if self.tooltipWidgetSet then
		local overflow = GameTooltip_AddWidgetSet(tooltip, self.tooltipWidgetSet, 10)
		if overflow then
			verticalPadding = -overflow
		end
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
local pool = CreateFramePool("Frame", nil, nil, nil, nil, function(frame)
	Mixin(frame, RaceMixin)
	frame:OnLoad()
end)

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
	local tx = Lerp(minX, maxX, x)
	local ty = Lerp(minY, maxY, y)
	local icon = pool:Acquire()
	icon:OnAcquire(info)
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

	for _, childInfo in ipairs(C_Map.GetMapChildrenInfo(mapID)) do
		if childInfo.mapType == Enum.UIMapType.Zone then
			addRacesForMap(mapID, childInfo)
		end
	end
	if extra_children[mapID] then
		for _, childID in ipairs(extra_children[mapID]) do
			addRacesForMap(mapID, C_Map.GetMapInfo(childID))
		end
	end
end

EventRegistry:RegisterCallback("MapCanvas.MapSet", function(_, mapID)
	refreshMapPins(mapID)
end)
