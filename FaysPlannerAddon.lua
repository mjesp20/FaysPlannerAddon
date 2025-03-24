local function CreateCopyFrame(text)
    -- Create the frame if it doesn't exist
    if not FaysPlannerFrame then
        local f = CreateFrame("Frame", "FaysPlannerFrame", UIParent)
        f:SetWidth(400)
        f:SetHeight(300)
        f:SetPoint("CENTER", nil, "CENTER", 0, 0) -- Corrected SetPoint syntax
        f:SetBackdrop({
            bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function(self) self:StartMoving() end)
        f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

        -- Create the scrollable EditBox
        local scrollFrame = CreateFrame("ScrollFrame", "FaysPlannerScrollFrame", f, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -12)
        scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 12)

        local editBox = CreateFrame("EditBox", "FaysPlannerEditBox", scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(GameFontNormal)
        editBox:SetWidth(360)
        editBox:SetHeight(260)
        editBox:SetAutoFocus(true)
        editBox:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
        editBox:SetScript("OnEscapePressed", function() f:Hide() end)
        --editBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)

        scrollFrame:SetScrollChild(editBox)
        f.editBox = editBox

        -- Close Button
        local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
        closeButton:SetScript("OnClick", function() f:Hide() end)

        f:Hide()
    end

    -- Set the text and show the frame
    FaysPlannerFrame.editBox:SetText(text)
    FaysPlannerFrame.editBox:HighlightText()
    FaysPlannerFrame:Show()
end

local function GenerateRaidInfo()
    local output = ""
    for i = 1, GetNumRaidMembers() do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        if name and class then
            output = output .. name .. "," .. string.lower(class) .. "\n"
        end
    end
    CreateCopyFrame(output)
end

SLASH_FAYSPLANNER1 = "/faysplanner"
SlashCmdList["FAYSPLANNER"] = GenerateRaidInfo
