-- auto-clear on /reload and login, convenient for spammy, loud and noisy addons that like to clog up chat
local OneTimeStartup = false

local function clearchat()
    for i = 1, 45 do
        print("")
    end
    OneTimeStartup = true
end

local function CreateTimer(delay, func)
    local frame = CreateFrame("Frame")
    local elapsed = 0
    frame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed >= delay then
            frame:SetScript("OnUpdate", nil)
            func()
        end
    end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "ADDON_LOADED") and (OneTimeStartup == false) then
        if clear_on_startup == true then
            CreateTimer(7, clearchat)
        end
	end
end)

SLASH_CS1 = "/CS"
SlashCmdList["CS"] = function(raw_module)
    module = raw_module
    CommandHandler()
end

tempStringTable = {}
local function flushstrings()
    for key, value in pairs(tempStringTable) do
        tempStringTable[key] = nil
    end
end

local function wipeTable(t)
    if t then
        for k in pairs(t) do
            t[k] = nil
        end
    end
end

local function wipe_everything()
    StaticPopupDialogs["CONFIRM_WIPE"] = 
    {
        text = "Are you absolutely sure that you want to wipe all settings/strings for ChatScanner?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            wipeTable(whitelistedStringTable)
            wipeTable(blacklistedStringTable)
            whitelistedStringTable = {}
            blacklistedStringTable = {}
            caseInsensitive = nil
            debug_mode = nil
            clear_on_startup = nil
            flushstrings()
            print("All settings/strings wiped")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }

    StaticPopup_Show("CONFIRM_WIPE")
end

local function printdivider()
    print("-----------------------------------------------")
end

local function help()
    printdivider()
    print("/CS addstring_[whitelist/blacklist] [String goes here]")
    print("Description : Adds a string to whitelist/blacklist accordingly")
    print("Example : /CS addstring_whitelist apple, will whitelist the word apple")
    printdivider()
    print("/CS delstrings")
    print("Description : Wipes all whitelisted/blacklisted strings")
    printdivider()
    print("/CS liststrings_[whitelist/blacklist]")
    print("Description : Lists all strings in whitelist")
    print("Example : /CS liststrings_blacklist, will list blacklisted strings.")
    printdivider()
    print("/CS case_insensitive_[on/off]")
    print("Description : Turns case insensitivity detection on or off")
    print("Example : /CS case_insensitive_off, will turn off case insensitivity")
    printdivider()
    print("/CS case_insensitive_status")
    print("Description : Checks if case insensitivity is on or off")
    printdivider()
    print("/CS clear_on_startup_[on/off]")
    print("Description : Clears chatbox on login/UI reload")
    printdivider()
    print("/CS clear_on_startup_status")
    print("Description : Checks if clear_on_startup is on or off")
    printdivider()
    print("/CS debug_mode_[on/off]")
    print("Description : Toggles debug mode, only use this if you know what you're doing")
    printdivider()
    print("/CS debug_mode_status")
    print("Description : Checks if debug mode is on or off")
    printdivider()
    print("/CS wipe_everything")
    print("Description : Wipes all settings and strings for ChatScanner")
    printdivider()
    print("/CS turnoff/turnon")
    print("Description : Turns the chat filter on or off, while still keeping the whitelisted/blacklisted strings.")
    printdivider()
    print("/CS help")
    print("Description : Prints this page")
    printdivider()
end

local function trim(str)
    return str:match("^%s*(.-)%s*$")
end

local function addstring(textstr)
    local textstr = module
    local decision = nil
    
    if string.find(textstr,"addstring_whitelist") then
        textstr = string.gsub(textstr,"addstring_whitelist","")
        decision = "whitelist"
    elseif string.find(textstr,"addstring_blacklist") then
        textstr = string.gsub(textstr,"addstring_blacklist","")
        decision = "blacklist"
    else 
        print("Error occured at function addstring(), on addon ChatScanner")
        return
    end

    printdivider()
    textstr = textstr:sub(1) -- removing first space on the strings that appear for some odd reason

    for substring in string.gmatch(textstr, "%S+") do
        table.insert(tempStringTable, substring.." ") --extra whitespace when finalstring concats all of our strings together, to be compat with multi-word strings
        if #tempStringTable > 10 then
            print("ERROR : String above 10 words, please enter string below 10 words.")
            return
        end
    end

    local finalstring = table.concat(tempStringTable, "")

    if decision == "whitelist" then
        print("Added string to whitelist : ", trim(finalstring))
        printdivider()
        table.insert(whitelistedStringTable,trim(finalstring))
    elseif decision == "blacklist" then
        print("Added string to blacklist : ", trim(finalstring))
        printdivider()
        table.insert(blacklistedStringTable,trim(finalstring))
    end

    flushstrings()
end

local function delstrings()
    wipeTable(whitelistedStringTable)
    wipeTable(blacklistedStringTable)
    printdivider()
    print("Wiped")
    printdivider()
end

local function liststrings_whitelist()
    printdivider()
    print("Whitelisted Strings : ")
    if (whitelistedStringTable == nil) or (#whitelistedStringTable == 0) then
         print("Whitelist is empty")
    else
        for i,v in ipairs(whitelistedStringTable) do
            if v then
                print(i,": -|",v,"|-")
            end
        end
    end
    printdivider()
end

local function liststrings_blacklist()
    printdivider()
    print("Blacklisted Strings : ")
    if (blacklistedStringTable == nil) or (#blacklistedStringTable == 0) then
         print("Blacklist is empty")
    else
        for i,v in ipairs(blacklistedStringTable) do
            if v then
                print(i,": -|",v,"|-")
            end
        end
    end
    printdivider()
end

local function case_insensitive_on()
    caseInsensitive = true
    printdivider()
    print("Case insensitivity turned ON")
    printdivider()
end

local function case_insensitive_off()
    caseInsensitive = false
    printdivider()
    print("Case insensitivity turned OFF")
    printdivider()
end

local function case_insensitive_status()
    if caseInsensitive == false then
        printdivider()
        print("Status : Case insensitivity is OFF")
        printdivider()
    elseif caseInsensitive == true then
        printdivider()
        print("Status : Case insensitivity is ON")
        printdivider()
    else 
        printdivider()
        print("Error : case_insensitive does not exist, turn case_insensitive state on or off to fix this")
        printdivider()
    end
end

local chat_filter_prevmsg = "" -- prev message check, workaround for potential wow api bug, where AddMessageEventFilter spams our handler function..
local function chat_filter(self,event,message,sender,channel_number,channel_name,...)
    if message == chat_filter_prevmsg then return false end

    chat_filter_prevmsg = message
    if debug_mode == true then
      print("event :"..event)
      print("message :"..message)
      print("sender :"..sender)
      print("channel_name :"..channel_name)
      printdivider()
    end

    -- Initialize tables if they don't exist
    if whitelistedStringTable == nil then
        printdivider()
        print("No whitelist table detected, creating a new, empty one")
        whitelistedStringTable = {}
    end

    if blacklistedStringTable == nil then
        printdivider()
        print("No blacklist table detected, creating a new, empty one")
        blacklistedStringTable = {}
    end

    -- Check whitelist
    for i, v in ipairs(whitelistedStringTable) do
        if v and message:find(v) then -- if matches normally
            print("|cff00ff00".."↓ Whitelisted Message ↓")
            RaidNotice_AddMessage(RaidWarningFrame,"ALERT: Whitelisted string detected", ChatTypeInfo["RAID_WARNING"])
            return false -- Allow message through
        end

        if caseInsensitive == true and v then
            local msg_lower_whitelist = message:lower()
            if msg_lower_whitelist:find(v:lower()) then -- if matches all lowercase
                print("|cff00ff00".."↓ Whitelisted Message ↓")
                RaidNotice_AddMessage(RaidWarningFrame,"ALERT: Whitelisted string detected", ChatTypeInfo["RAID_WARNING"])
                return false -- Allow message through
            end
        end
    end

    -- Check blacklist
    for i, v in ipairs(blacklistedStringTable) do
        if v and message:find(v) then -- if matches normally
            return true -- Block message
        end

        if caseInsensitive == true and v then
            local msg_lower_blacklist = message:lower()
            if msg_lower_blacklist:find(v:lower()) then -- if matches all lowercase
                return true -- Block message
            end
        end
    end
    
    return false -- Allow message through if no matches
end

-- Register chat filters
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", chat_filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", chat_filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", chat_filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", chat_filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", chat_filter)

local function turnoff()
    print("|cffff0000".."FILTER DISABLED") -- red color
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", chat_filter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", chat_filter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", chat_filter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", chat_filter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_GUILD", chat_filter)
end

local function turnon()
    print("|cff00ff00".."FILTER ENABLED") -- green color

    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", chat_filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", chat_filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", chat_filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", chat_filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", chat_filter)
end

function CommandHandler()
    if module == "help" then
        help()
    elseif module == "delstrings" then
        delstrings()
    elseif module == "liststrings_whitelist" then
        liststrings_whitelist()
    elseif module == "liststrings_blacklist" then
        liststrings_blacklist()
    elseif module == "case_insensitive_on" then
        case_insensitive_on()
    elseif module == "case_insensitive_off" then
        case_insensitive_off()
    elseif module == "case_insensitive_status" then
        case_insensitive_status()
    elseif module == "clear_on_startup_on" then
        clear_on_startup = true
        printdivider()
        print("clear_on_startup set to true")
        printdivider()
    elseif module == "clear_on_startup_off" then
        clear_on_startup = false
        printdivider()
        print("clear_on_startup set to false")
        printdivider()
    elseif module == "clear_on_startup_status" then
        if clear_on_startup == true then
            printdivider()
            print("clear_on_startup is on")
            printdivider()
        elseif clear_on_startup == false then
            printdivider()
            print("clear_on_startup is off")
            printdivider()
        else
            printdivider()
            print("clear_on_startup seems to be nil (nonexistent)")
            printdivider()
        end
    elseif module == "debug_mode_on" then
        debug_mode = true
        printdivider()
        print("Debug mode activated")
        printdivider()
    elseif module == "debug_mode_off" then
        debug_mode = false
        printdivider()
        print("Debug mode deactivated")
        printdivider()
    elseif module == "debug_mode_status" then
        if debug_mode == true then
            printdivider()
            print("debug_mode is on")
            printdivider()
        elseif debug_mode == false then
            printdivider()
            print("debug_mode is off")
            printdivider()
        else
            printdivider()
            print("debug_mode seems to be nil (nonexistent)")
            printdivider()
        end
    elseif module == "wipe_everything" then
        wipe_everything()
    elseif string.find(module, "addstring_whitelist") or string.find(module, "addstring_blacklist") then
        addstring()
    elseif module == "turnoff" then
        turnoff()
    elseif module == "turnon" then
        turnon()
    elseif module == "" then --Aka, if the user ONLY types /CS in chat
        help()
    else
        print("Incorrect command entered")
        print("Typed command: ","'",module,"'")
    end
end
