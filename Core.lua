PortalWhere = CreateFrame("Frame")

PortalWhere.matchWords = {
    ["Undercity"] = {
        "Undercity",
        "UC",
        "Undershitty",
    },
    ["Orgrimmar"] = {
        "Orgrimmar",
        "Orgrimar",
        "Org",
        "Orgri",
        "Ogri",
        "Ogr",
        "Og",
    },
    ["Thunderbluff"] = {
        "Thunderbluff",
        "TB",
    }
}

function PortalWhere:Print(...)
    print("[PortalWh*re] " .. ...)
end

function PortalWhere:Boot()
    self:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)
    self:RegisterEvent("ADDON_LOADED")
end

function PortalWhere:ADDON_LOADED(name)
    if name == "PortalWh*re" then
        self:OnBoot()
    end
end

function PortalWhere:RegisterSlashCommand()
    SLASH_PORTALWHERE1 = "/pw"
    SLASH_PORTALWHERE2 = "/portalwhere"
    SlashCmdList["PORTALWHERE"] = function(msg)
        local _, _, command, args - string.find(msg, "%s?(%w+)%s?(.*)")
        if command then
            self:OnSlashCommand(command, args)
        end
    end
end

function PortalWhere:MakeLowercaseMatchWords()
    for destination, wordList in pairs(self.matchWords) do
        for index, word in ipairs(wordList) do
            self.matchWords[destination][index] = string.lower(word)
        end
    end
end

function PortalWhere:OnBoot()
    self:MakeLowercaseMatchWords()
    self:RegisterSlashCommand()
    self:Print("Loaded.")
end

function PortalWhere:OnSlashCommand(command, args)
    command = string.lower(command)
    if command == "on" then
        self:On()
    elseif command == "off" then
        self:Off()
    else
        self:Print("Unknown command.")
    end  
end

function PortalWhere:On()
    self:RegisterEvent("CHAT_MSG_SAY")
    self:RegisterEvent("CHAT_MSG_YELL")
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:Print("Looking for punters...")
end

function PortalWhere:Off()
    self:UnregisterEvent("CHAT_MSG_SAY")
    self:UnregisterEvent("CHAT_MSG_YELL")
    self:UnregisterEvent("CHAT_MSG_WHISPER")
    self:Print("All done. Time for breakfast.")
end

function PortalWhere:CHAT_MSG_SAY(...)
    self:OnChat(...)
end

function PortalWhere:CHAT_MSG_YELL(...)
    self:OnChat(...)
end

function PortalWhere:CHAT_MSG_WHISPER(...)
    self:OnChat(...)
end

function PortalWhere:MatchWordToDestination(word)
    word = string.lower(word)
    for destination, wordList in pairs(self.matchWords) do
        if self:ArrayHas(word, wordList) then
            return true, destination
        end
    end
    return false
end

function PortalWhere:ArrayHas(item, array)
    for index, value in pairs(array) do
        if value == item then
            return true
        end
    end
    return false
end

function PortalWhere:WantsPortal(playerName, guid, message)
    if playerName == UnitName("player") then
        return false
    end
    
    local _, playerClass = GetPlayerInfo(guid)
    if playerClass == "MAGE" then
        return false
    end

    for word in string.gmatch(message, "%a+") do
        local match, destination = self:matchWordToDestination(word)
        if match then
            return match, destination
        end
    end

    return false
end

function PortalWhere:OnChat(text, playerName, _, _, shortPlayerName, _, _, _, _, _, _, guid)
    if self:WantsPortal(playerName, guid, text) then
        InviteUnit(playerName)
    end
end

PortalWhere:Boot()