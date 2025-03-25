local function CreateCopyFrame(text)
    -- Create the frame if it doesn't exist
    if not FaysPlannerFrame then
        local f = CreateFrame("Frame", "FaysPlannerFrame", UIParent)
        f:SetWidth(400)
        f:SetHeight(300)
        f:SetPoint("CENTER", nil, "CENTER", 0, 0)
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

        scrollFrame:SetScrollChild(editBox)
        f.editBox = editBox

        -- Close Button
        local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
        closeButton:SetScript("OnClick", function() f:Hide() end)

        f:Hide()
    end

    -- Set the text and show the frame
    FaysPlannerFrame.editBox:SetText(text or "")
    FaysPlannerFrame.editBox:HighlightText()
    FaysPlannerFrame:Show()
end

local function GenerateRaidInfo()
    -- Predefined class names for Classic (1.12)
    local validClasses = {
        ["WARRIOR"] = true,
        ["PRIEST"] = true,
        ["MAGE"] = true,
        ["ROGUE"] = true,
        ["DRUID"] = true,
        ["HUNTER"] = true,
        ["WARLOCK"] = true,
        ["SHAMAN"] = true,
        ["PALADIN"] = true
    }

    -- Create a table to store raid members by class
    local classSortedMembers = {}
    
    -- Get number of raid members
    local numRaidMembers = GetNumRaidMembers()
    DEFAULT_CHAT_FRAME:AddMessage("Number of raid members: " .. numRaidMembers)

    -- Collect raid members
    for i = 1, numRaidMembers do
        local name, rank, subgroup, level, class, fileName, zone, isOnline, isDead = GetRaidRosterInfo(i)
        
        -- Normalize class name and check validity
        local normalizedClass = class and string.upper(class)
        
        -- Debug: Output details of each raid member
        --DEFAULT_CHAT_FRAME:AddMessage(string.format("Raid Member %d: Name=%s, OriginalClass=%s, NormalizedClass=%s", 
            --i, tostring(name), tostring(class), tostring(normalizedClass)))

        if name and normalizedClass and validClasses[normalizedClass] then
            -- Initialize class group if not exists
            if not classSortedMembers[normalizedClass] then
                classSortedMembers[normalizedClass] = {}
            end
            
            -- Add member to their class group
            table.insert(classSortedMembers[normalizedClass], name)
        end
    end
    
    -- Predefined class order for Classic (1.12)
    local classOrder = {
        "WARRIOR", "PRIEST", "MAGE", "ROGUE", 
        "DRUID", "HUNTER", "WARLOCK", "SHAMAN", "PALADIN"
    }
    
    -- Generate output
    local output = ""
    for _, className in ipairs(classOrder) do
        if classSortedMembers[className] then
            -- Sort names within each class alphabetically
            table.sort(classSortedMembers[className])
            
            -- Add class members to output
            for _, name in ipairs(classSortedMembers[className]) do
                output = output .. name .. "," .. string.lower(className) .. "\n"
            end
        end
    end
    
    -- Ensure we have output
    if output == "" then
        output = "No raid members found.\nDebug info: Total members = " .. numRaidMembers
    end
    
    

        -- No superwow, no superapi
    if not SUPERWOW_VERSION then
        DEFAULT_CHAT_FRAME:AddMessage("No SuperWoW detected");
        CreateCopyFrame(output)
    else
        ExportFile("raidinfo", output)
    end
end

SLASH_FAYSPLANNER1 = "/faysplanner"
SlashCmdList["FAYSPLANNER"] = GenerateRaidInfo