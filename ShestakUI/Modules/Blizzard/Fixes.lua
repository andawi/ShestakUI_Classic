local T, C, L, _ = unpack(select(2, ...))

----------------------------------------------------------------------------------------
--	Fix blank tooltip
----------------------------------------------------------------------------------------
local bug = nil
local FixTooltip = CreateFrame("Frame")
FixTooltip:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
FixTooltip:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
FixTooltip:SetScript("OnEvent", function()
	if GameTooltip:IsShown() then
		bug = true
	end
end)

local FixTooltipBags = CreateFrame("Frame")
FixTooltipBags:RegisterEvent("BAG_UPDATE_DELAYED")
FixTooltipBags:SetScript("OnEvent", function()
	if StuffingFrameBags and StuffingFrameBags:IsShown() then
		if GameTooltip:IsShown() then
			bug = true
		end
	end
end)

GameTooltip:HookScript("OnTooltipCleared", function(self)
	if self:IsForbidden() then return end
	if bug and self:NumLines() == 0 then
		self:Hide()
		bug = false
	end
end)

----------------------------------------------------------------------------------------
--	Fix RemoveTalent() taint
----------------------------------------------------------------------------------------
if not T.classic then
	FCF_StartAlertFlash = T.dummy
end

----------------------------------------------------------------------------------------
--	Fix DeclensionFrame strata
----------------------------------------------------------------------------------------
if T.client == "ruRU" then
	_G["DeclensionFrame"]:SetFrameStrata("HIGH")
end

----------------------------------------------------------------------------------------
--	Fix SearchLFGLeave() taint
----------------------------------------------------------------------------------------
if not T.classic then
	local TaintFix = CreateFrame("Frame")
	TaintFix:SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end