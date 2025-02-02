local T, C, L, _ = unpack(select(2, ...))

----------------------------------------------------------------------------------------
--	Movement function(by Allez)
----------------------------------------------------------------------------------------
T.MoverFrames = {
	VehicleButtonAnchor,
	ExtraButtonAnchor,
	ZoneButtonAnchor,
	ActionBarAnchor,
	RightActionBarAnchor,
	PetActionBarAnchor,
	StanceBarAnchor,
	MicroAnchor,
	VehicleAnchor,
	AchievementAnchor,
	MinimapAnchor,
	TopPanelAnchor,
	BuffsAnchor,
	RaidCDAnchor,
	EnemyCDAnchor,
	ObjectiveTrackerAnchor,
	ObjectiveTimerAnchor,
	RaidUtilityPanelAnchor,
	ThreatMeterAnchor,
	LootRollAnchor,
	RaidBuffsAnchor,
	PulseCDAnchor,
	AutoButtonAnchor,
	TooltipAnchor,
	ChatBar,
	P_BUFF_ICON_Anchor,
	P_PROC_ICON_Anchor,
	SPECIAL_P_BUFF_ICON_Anchor,
	T_DEBUFF_ICON_Anchor,
	T_BUFF_Anchor,
	PVE_PVP_DEBUFF_Anchor,
	PVE_PVP_CC_Anchor,
	COOLDOWN_Anchor,
	T_DE_BUFF_BAR_Anchor,
	SplitBarLeft,
	SplitBarRight
}

local unitFrames = {
	oUF_Player,
	oUF_Target,
	oUF_Pet,
	oUF_Focus,
	oUF_FocusTarget,
	oUF_TargetTarget,
	oUF_Player_Castbar,
	oUF_Target_Castbar,
	oUF_Player_Portrait,
	oUF_Target_Portrait,
	PartyAnchor,
	PartyTargetAnchor,
	PartyPetAnchor,
	RaidTankAnchor,
	PartyDPSAnchor,
	PartyTargetDPSAnchor,
	PartyPetDPSAnchor,
	RaidTankDPSAnchor
}

for i = 1, 5 do
	tinsert(unitFrames,_G["oUF_Boss"..i])
	tinsert(unitFrames,_G["oUF_Arena"..i])
	tinsert(unitFrames,_G["oUF_Arena"..i.."Target"])
end

for i = 1, C.raidframe.raid_groups do
	tinsert(unitFrames, _G["RaidAnchor"..i])
	tinsert(unitFrames, _G["RaidPetAnchor"..i])
	tinsert(unitFrames, _G["RaidDPSAnchor"..i])
end

if C.actionbar.editor then
	tinsert(T.MoverFrames, Bar1Holder)
	tinsert(T.MoverFrames, Bar2Holder)
	tinsert(T.MoverFrames, Bar3Holder)
	tinsert(T.MoverFrames, Bar4Holder)
	tinsert(T.MoverFrames, Bar5Holder)
	tremove(T.MoverFrames, 5)	-- RightActionBarAnchor
	tremove(T.MoverFrames, 4)	-- ActionBarAnchor
end

local moving = false
local movers = {}
local placed = {
	"Butsu",
	"UIAltPowerBar",
	"LootHistoryFrame",
	"stArchaeologyFrame",
	"StuffingFrameBags",
	"StuffingFrameBank",
	"UIWidgetTopAnchor",
	"UIWidgetBelowAnchor"
}

local SaveDefaultPosition = function(mover)
	local ap, p, rp, x, y = mover.frame:GetPoint()
	ShestakUIPositions.Default = ShestakUIPositions.Default or {}
	if not ShestakUIPositions.Default[mover.frame:GetName()] then
		if not p then
			p = UIParent
		end
		ShestakUIPositions.Default[mover.frame:GetName()] = {ap, p:GetName(), rp, x, y}
	end
end

local SetPosition = function(mover)
	local x, y, ap = T.CalculateMoverPoints(mover)
	mover.frame:ClearAllPoints()
	mover.frame:SetPoint(ap, "UIParent", ap, x, y)
	ShestakUIPositions[mover.frame:GetName()] = {ap, "UIParent", ap, x, y}
end

-- Controls
local controls = CreateFrame("frame", nil, UIParent)
controls:SetPoint("CENTER", UIParent)
controls:SetSize(65, 25)
controls:SetFrameStrata("TOOLTIP")
controls:SetFrameLevel(100)
controls:SetClampedToScreen(true)
controls:Hide()
controls:SetScript("OnLeave", function(self)
	if MouseIsOver(self) then return end
	if not self._frame then
		self:Hide()
	elseif not MouseIsOver(self._frame) then
		self:Hide()
	end
	controls.x:SetText("")
	controls.y:SetText("")
end)

local function CreateArrow(moveX, moveY, callback)
	moveX = moveX or 0
	moveY = moveY or 0

	local button = CreateFrame("button", nil, controls)
	button:SetSize(14, 14)
	button.controls = controls

	button.tex = button:CreateTexture(nil, "OVERLAY")
	button.tex:SetTexture("Interface\\OPTIONSFRAME\\VoiceChat-Play")

	button.tex:SetPoint("CENTER")
	button.tex:SetSize(12, 12)
	button.tex:SetVertexColor(0.6, 0.6, 0.6)

	button:SetScript("OnEnter", function(self)
		self.tex:SetVertexColor(1, 1, 1)
	end)
	button:SetScript("OnLeave", function(self)
		self.tex:SetVertexColor(0.6, 0.6, 0.6)
	end)

	callback = callback or function(self)
		local frame = self.controls._frame
		if not frame then return end
		local point, relativeTo, relativePoint, xOfs, yOfs = frame.frame:GetPoint()
		SaveDefaultPosition(frame)
		if IsControlKeyDown() then
			frame.frame:SetPoint(point, relativeTo, relativePoint, xOfs + (moveX * 20), yOfs + (moveY * 20))
		elseif IsShiftKeyDown() then
			frame.frame:SetPoint(point, relativeTo, relativePoint, xOfs + (moveX * 5), yOfs + (moveY * 5))
		else
			frame.frame:SetPoint(point, relativeTo, relativePoint, xOfs + (moveX * 1), yOfs + (moveY * 1))
		end
		local point, relativeTo, relativePoint, xOfs, yOfs = frame.frame:GetPoint()
		if not relativeTo then
			relativeTo = UIParent
		end
		ShestakUIPositions[frame.frame:GetName()] = {point, relativeTo:GetName(), relativePoint, xOfs, yOfs}
		frame:SetAllPoints(frame.frame)
		controls.x:SetText(T.Round(xOfs))
		controls.y:SetText(T.Round(yOfs))
	end

	button:SetScript("OnClick", callback)

	if controls.last then
		button:SetPoint("LEFT", controls.last, "RIGHT", 2, 0)
	else
		button:SetPoint("LEFT", controls, "LEFT", 2, 0)
	end

	controls.last = button

	return button
end

controls.left = CreateArrow(-1, 0)
controls.left.tex:SetRotation(3.14159)

controls.up = CreateArrow(0, 1)
controls.up.tex:SetRotation(1.5708)

controls.down = CreateArrow(0, -1)
controls.down.tex:SetRotation(-1.5708)

controls.right = CreateArrow(1, 0)
controls.right.tex:SetRotation(0)

controls.x = controls:CreateFontString(nil, "OVERLAY")
controls.x:SetFont(C.media.pixel_font, C.media.pixel_font_size, C.media.pixel_font_style)
controls.x:SetPoint("RIGHT", controls, "LEFT", -10, 0)

controls.y = controls:CreateFontString(nil, "OVERLAY")
controls.y:SetFont(C.media.pixel_font, C.media.pixel_font_size, C.media.pixel_font_style)
controls.y:SetPoint("LEFT", controls, "RIGHT", 10, 0)

controls.shadow = controls:CreateTexture(nil, "OVERLAY")
controls.shadow:SetPoint("TOPLEFT", controls.x, "TOPLEFT", -5, 5)
controls.shadow:SetPoint("BOTTOMRIGHT", controls.y, "BOTTOMRIGHT", 2, -5)
controls.shadow:SetTexture(C.media.texture)
controls.shadow:SetVertexColor(0.1, 0.1, 0.1, 0.8)

local function GetQuadrant(frame)
	local _, y = frame:GetCenter()
	local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"
	return vhalf
end

local function ShowControls(frame)
	local y = GetQuadrant(frame)
	controls._frame = frame
	controls:Show()
	controls:ClearAllPoints()
	if y == "TOP" then
		controls:SetPoint("TOP", frame, "BOTTOM", 0, 0)
	else
		controls:SetPoint("BOTTOM", frame, "TOP", 0, 0)
	end
	local _, _, _, xOfs, yOfs = frame.frame:GetPoint()
	controls.x:SetText(T.Round(xOfs))
	controls.y:SetText(T.Round(yOfs))
end

local function UpdateCoords(self)
	local mover = self.child
	local x, y, ap = T.CalculateMoverPoints(mover)

	mover.frame:ClearAllPoints()
	mover.frame:SetPoint(ap, "UIParent", ap, x, y)
	controls.x:SetText(T.Round(x))
	controls.y:SetText(T.Round(y))
end

local coordFrame = CreateFrame("Frame")
coordFrame:SetScript("OnUpdate", UpdateCoords)
coordFrame:Hide()

local OnDragStart = function(self)
	SaveDefaultPosition(self)
	self:StartMoving()

	coordFrame.child = self
	coordFrame:Show()
end

local OnDragStop = function(self)
	self:StopMovingOrSizing()
	SetPosition(self)

	coordFrame.child = nil
	coordFrame:Hide()
end

local RestoreDefaults = function(self, button)
	if button == "RightButton" then
		local data = ShestakUIPositions.Default and ShestakUIPositions.Default[self.frame:GetName()]
		if data then
			self.frame:ClearAllPoints()
			self.frame:SetPoint(unpack(data))
			self:ClearAllPoints()
			self:SetAllPoints(self.frame)
			ShestakUIPositions.Default[self.frame:GetName()] = nil
			ShestakUIPositions[self.frame:GetName()] = nil
		end
	elseif button == "MiddleButton" then
		self:Hide()
	end
end

local CreateMover = function(frame, unit)
	local mover = CreateFrame("Frame", nil, UIParent)
	if unit then
		mover:CreateBackdrop("Transparent")
		mover.backdrop:SetBackdropBorderColor(1, 0, 0)
	else
		mover:SetTemplate("Transparent")
		mover:SetBackdropBorderColor(1, 0, 0)
	end
	mover.backdrop = mover.backdrop or mover
	mover:SetAllPoints(frame)
	mover:SetFrameStrata("TOOLTIP")
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", OnDragStart)
	mover:SetScript("OnDragStop", OnDragStop)
	mover:SetScript("OnEnter", function(self) self.backdrop:SetBackdropBorderColor(unpack(C.media.classborder_color)) ShowControls(self) end)
	mover:SetScript("OnLeave", function(self) self.backdrop:SetBackdropBorderColor(1, 0, 0) if not MouseIsOver(controls) then controls:Hide() end end)
	mover:SetScript("OnMouseUp", RestoreDefaults)
	mover.frame = frame

	mover.name = mover:CreateFontString(nil, "OVERLAY")
	mover.name:SetFont(C.media.pixel_font, C.media.pixel_font_size, C.media.pixel_font_style)
	mover.name:SetPoint("CENTER")
	mover.name:SetTextColor(1, 1, 1)
	local text = frame:GetName()
	text = text:gsub("_Anchor", "")
	text = text:gsub("Anchor", "")
	text = text:gsub("oUF_", "")
	mover.name:SetText(text)
	mover.name:SetWidth(frame:GetWidth() - 4)
	movers[frame:GetName()] = mover
end

local GetMover = function(frame, unit)
	if movers[frame:GetName()] then
		return movers[frame:GetName()]
	else
		return CreateMover(frame)
	end
end

local InitMove = function(msg)
	if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	if msg and (msg == "reset" or msg == "куыуе") then
		ShestakUIPositions = {}
		for _, v in pairs(placed) do
			if _G[v] then
				_G[v]:SetUserPlaced(false)
			end
		end
		ReloadUI()
		return
	end
	if not moving then
		for _, v in pairs(T.MoverFrames) do
			local mover = GetMover(v)
			if mover then mover:Show() end
		end
		for _, v in pairs(unitFrames) do
			local mover = GetMover(v, true)
			if mover then mover:Show() end
		end
		moving = true
		SlashCmdList.GRIDONSCREEN()
	else
		for _, v in pairs(movers) do
			v:Hide()
		end
		moving = false
		SlashCmdList.GRIDONSCREEN("hide")
		controls:Hide()
	end
end

local RestoreUI = function(self)
	if InCombatLockdown() then
		if not self.shedule then self.shedule = CreateFrame("Frame", nil, self) end
		self.shedule:RegisterEvent("PLAYER_REGEN_ENABLED")
		self.shedule:SetScript("OnEvent", function(self)
			RestoreUI(self:GetParent())
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:SetScript("OnEvent", nil)
		end)
		return
	end
	if ShestakUIPositions then
		-- TODO: delete after while
		if ShestakUIPositions.UnitFrame then
			for frame_name, point in pairs(ShestakUIPositions.UnitFrame) do
				if _G[frame_name] then
					for _, frame in pairs(unitFrames) do
						print(frame:GetName(), _G[frame_name]:GetName())
						if frame:GetName() and frame:GetName() == _G[frame_name]:GetName() then
							_G[frame_name]:ClearAllPoints()
							_G[frame_name]:SetPoint(unpack(point))
							ShestakUIPositions[frame_name] = point
						end
					end
				end
			end
			ShestakUIPositions.UnitFrame = nil
			ShestakUIPositions.UFPos = nil
		end
		-- End of block to delete

		for frame_name, point in pairs(ShestakUIPositions) do
			if _G[frame_name] then
				_G[frame_name]:ClearAllPoints()
				_G[frame_name]:SetPoint(unpack(point))
			end
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)
	RestoreUI(self)
end)

SlashCmdList.MOVING = InitMove
SLASH_MOVING1 = "/moveui"
SLASH_MOVING2 = "/ьщмугш"
SLASH_MOVING3 = "/ui"
SLASH_MOVING4 = "/гш"

StaticPopupDialogs.RESET_UF = {
	text = L_POPUP_RESETUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") else
		for _, frame in pairs(unitFrames) do
			if frame:GetName() then
				ShestakUIPositions[frame:GetName()] = nil
			end
		end
		ReloadUI()
	end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}

SlashCmdList.RESETUF = function() StaticPopup_Show("RESET_UF") end
SLASH_RESETUF1 = "/resetuf"