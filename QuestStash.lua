-- Set addon name
local name = "Quest Stash"
local tinsert = table.insert

-- Define all events to watch
local function watchEvents()
	local events = {
		"ADDON_LOADED",
		"CHALLENGE_MODE_START",
		"CHALLENGE_MODE_COMPLETED",
		-- "CHALLENGE_MODE_RESET",
		"PLAYER_ENTERING_WORLD",
		"CHALLENGE_MODE_KEYSTONE_SLOTTED"
	}
	return events
end

-- Un-Track quests
local function hideQuests()
	print("|cFFFFFF00Quest Stash: |cFF00FF00Hidding Quests")
	saved_quest_list = { }
	for i = GetNumQuestWatches(), 1, -1 do
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(GetQuestIndexForWatch(i))
		if ( not isHeader ) then
	 		-- DEFAULT_CHAT_FRAME:AddMessage("Hidding: " .. title)
	 		tinsert(saved_quest_list, title)
	 		RemoveQuestWatch(GetQuestIndexForWatch(i))
		end
	end
	local savedQuests = table.getn(saved_quest_list)
	DEFAULT_CHAT_FRAME:AddMessage("Saved Quests: " .. savedQuests)
end

-- Re-Track Quests
local function showQuests()
	local savedQuests = table.getn(saved_quest_list)
	if savedQuests == 0 then 
		print("|cFFFFFF00Quest Stash: |cFFFF0000No hidden quests!")
		return true 
	else
		print("|cFFFFFF00Quest Stash: |cFF00FF00Re-Tracking Quests (" .. savedQuests .. ")")
		numEntries, numQuests = GetNumQuestLogEntries();
		-- get all quests in quest log
		for i=1, numEntries do
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(i)
			if isHeader == false then
				-- DEFAULT_CHAT_FRAME:AddMessage("Comparing: " .. title .. " id: " .. i )
				for j, savedName in ipairs(saved_quest_list) do
					if title == savedName then
						AddQuestWatch(i)
						-- DEFAULT_CHAT_FRAME:AddMessage("Re-Traking: " .. title )
					end
				end
			end
		end
		-- Reset saves quests
		saved_quest_list = { }
		return true
	end
end

-- Triggers on events and slash commands
local function handler(msg)

	if msg == "hide" then
		hideQuests()
		return true

	elseif msg == "questlog" then
		numEntries, numQuests = GetNumQuestLogEntries();
		for i=1, numQuests do
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(i)
			DEFAULT_CHAT_FRAME:AddMessage("Quest: " .. title .. " Quest ID: " .. questID )
		end
		return true

	elseif msg == "on" or msg == "activate" or msg == "1" then
		print("|cFFFFFF00Quest Stash: |cFF00FF00Activated")
		quest_stash = true
		return true

	elseif msg == "off" or msg == "0" or msg == "false" then
		print("|cFFFFFF00Quest Stash: |cFFFF0000Disabled")
		quest_stash = false
		return true

	elseif msg == "save" then
		print("|cFFFFFF00Quest Stash: |cFF00FF00Saving Quests")
		saved_quest_list = { }
		for i = GetNumQuestWatches(), 1, -1 do
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(GetQuestIndexForWatch(i))
			if ( not isHeader ) then
		 		DEFAULT_CHAT_FRAME:AddMessage("Saving: " .. title)
		 		tinsert(saved_quest_list, title)
			end
		end
		local savedQuests = table.getn(saved_quest_list)
		print("|cFFFFFF00Quest Stash: |cFF00FF00Saved Quests " .. savedQuests)
		return true

	elseif msg == "show" then
		showQuests()
		return true

	elseif msg == "reset" then
		saved_quest_list = { }
		print("|cFFFFFF00Quest Stash: |cFF00FF00Reset Done")
		return true

	elseif msg == "status" then
		if type(saved_quest_list) ~= "table" then saved_quest_list = { } end
		local savedQuests = table.getn(saved_quest_list)
		print("|cFFFFFF00Quest Stash: |cFFFF0000Saved Quests:" .. savedQuests)
		if(quest_stash == true) then
			print("|cFFFFFF00Quest Stash Status:|cFF00FF00 Active")
		else
			print("|cFFFFFF00Quest Stash Status:|cFFFF0000 Inactive")
		end
		return true

	elseif msg == "help" then
		print("|cFFFFFF00Quest Stash commands:")
		print("|cFFFFFF00 hide - Hides all watched quests")
		print("|cFFFFFF00 show - Shows all hidden watched quests")
		print("|cFFFFFF00 save - Saves current watched quests")
		print("|cFFFFFF00 on - Activates automatic mode (hides on mythic key start and shows when it is over)")
		print("|cFFFFFF00 off - Disables automatic mode")
		print("|cFFFFFF00 reset - Clears saved list")
		print("|cFFFFFF00 status - Shows current status (Active, Inactive)")
		print("|cFFFFFF00 help - Shows this")

	else
		local savedQuests = table.getn(saved_quest_list)
		if savedQuests > 0 then
			showQuests()
		else
			hideQuests()
		end
		return true
	end
end

-- Handle event
local function eventHandler(self, event, arg1, ...)
	if event == "ADDON_LOADED" then
		if name == arg1 then
			-- Variables are available
			if quest_stash == true then
				print("|cFFFFFF00Quest Stash: |cFF00FF00Active")
			else
				print("|cFFFFFF00Quest Stash: |cFFFF0000Empty")
				local tipo = type(saved_quest_list)
				if type(saved_quest_list) ~= "table" then saved_quest_list = { } end
			end
			print("|cFFFFFF00Quest Stash: |cFF00FF00Loaded")
		end

	elseif event == "CHALLENGE_MODE_START" then
		if quest_stash == true then
			hideQuests()
		end

	elseif event == "CHALLENGE_MODE_COMPLETED" or event == "PLAYER_ENTERING_WORLD" then
		if quest_stash == true then
			showQuests()
		end

	else
		-- Player isn't in world yet on ADDON_LOADED
		handler("EVENT_FIRED")
	end
end

-- Initiate slash commands
SlashCmdList["QSTASH"] = handler;
SLASH_QSTASH1 = "/qstash"

-- Create frame to catch events
local frame = CreateFrame("FRAME", "DUMMY_FRAME");

-- Register events with frame
for _,event in ipairs(watchEvents()) do
	frame:RegisterEvent(event)
end

frame:SetScript("OnEvent", eventHandler);

