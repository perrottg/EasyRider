EasyRider = LibStub("AceAddon-3.0"):NewAddon("EasyRider", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0" );

--local mountBar = nil
local buttonsInitialised = false
local buttons = {}
local mounts = {}
local mountDatastore = {}

local CATEGORY_GROUND = 1
local CATEGORY_FLY = 2
local CATEGORY_SURFACE = 3
local CATEGORY_AQUATIC = 4
local CATEGORY_PASSENGER = 5
local CATEGORY_VENDOR = 6
local CATEGORY_TRANSFORM = 7

local TOTAL_CATEGORIES = 7


mounts[CATEGORY_GROUND] = 200175
mounts[CATEGORY_FLY] = 183117
mounts[CATEGORY_SURFACE] = 118089
mounts[CATEGORY_AQUATIC] = 228919
mounts[CATEGORY_PASSENGER] = 75973
mounts[CATEGORY_VENDOR] = 61447
mounts[CATEGORY_TRANSFORM] = 93326

local buttonInfo = {}
buttonInfo[CATEGORY_GROUND] = {
	title = "Summon Ground Mount",
	description = "Summons and dismisses a ground mount."
}
buttonInfo[CATEGORY_FLY] = {
	title = "Summon Flying Mount",
	description = "Summons and dismisses a flying mount."
}
buttonInfo[CATEGORY_SURFACE] = {
	title = "Summon Surface Mount",
	description = "Summons and dismisses a mount capable of walking on water."
}
buttonInfo[CATEGORY_AQUATIC] = {
	title = "Summon Aquaic Mount",
	description = "Summons and  dismisses a mount capable of swimming in water."
}
buttonInfo[CATEGORY_PASSENGER] = {
	title = "Summon Passenger Mount", 
	description = "Summons and dismisses a mount capable of transporting a passanger."
}
buttonInfo[CATEGORY_VENDOR] = {
	title = "Summon Vendor Mount",
	description = "Summoms and dismisses a mount with a vendor."
}
buttonInfo[CATEGORY_TRANSFORM] = {
	title = "Mount Transformation",
	description = "Tranforms you into a mount."
}


local red = { r = 1.0, g = 0.2, b = 0.2 }
local blue = { r = 0.4, g = 0.4, b = 1.0 }
local green = { r = 0.2, g = 1.0, b = 0.2 }
local yellow = { r = 1.0, g = 1.0, b = 0.2 }
local gray = { r = 0.5, g = 0.5, b = 0.5 }
local black = { r = 0.0, g = 0.0, b = 0.0 }
local white = { r = 1.0, g = 1.0, b = 1.0 }

local mountDB = {}
mountDB[CATEGORY_PASSENGER] = {
	[61467] = 2, -- Grand Black War Mammoth (horde)
	[61465] = 2, -- Grand Black War Mammoth (alliance)
	[61469] = 2, -- Grand Ice Mammoth (horde)
	[61470] = 2, -- Grand Ice Mammoth (alliance)
	[61447] = 2, -- Traveler's Tundra Mammoth (horde)
	[61425] = 2, -- Traveler's Tundra Mammoth (alliance)
	[55531] = 1, -- Mechano-hog
	[60424] = 1, -- Mekgineer's Chopper
	[75973] = 1, -- X-53 Touring Rocket
	[93326] = 1, -- Sandstone Drake
}

local function CacheMounts()
	local collectedFlag = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED)
	local notCollectedFlag = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED)

	mountDatastore.allMounts = {}
	mountDatastore.categoryIndex = {}
	
	C_MountJournal.SetAllSourceFilters(true);
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, false)
	
	local numMounts = C_MountJournal.GetNumDisplayedMounts()

	for index = 1, numMounts do
		

		local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index)
		local creatureID, description, _, isSelfMount, mountType = C_MountJournal.GetDisplayedMountInfoExtra(index);
		local index = tostring(spellID)

		local mount = {}
		local category = nil

		mount.name = creatureName
		mount.description = description
		mount.spellID = spellID
		mount.mountID = mountID
		mount.icon = icon
		mount.creatureID = creatureID
		mount.mountType = mountType 

		mountDatastore.allMounts[index] = mount

		if isSelfMount then
			category = CATEGORY_TRANSFORM
		elseif mountDB[CATEGORY_PASSENGER][mount.spellID] then
			category = CATEGORY_PASSENGER
		elseif mountType == 232 or mountType == 254 then
			category = CATEGORY_AQUATIC
		elseif mountType == 269 then
			category = CATEGORY_SURFACE
		elseif mountType == 248 then
			category = CATEGORY_FLY
		elseif mountType == 230 then
			category = CATEGORY_GROUND			
		end
		
		if category then
			local indexCount = 0

			if not mountDatastore.categoryIndex[category] then
				mountDatastore.categoryIndex[category] = {}
			else
				indexCount = #mountDatastore.categoryIndex[category]
			end
			
			mountDatastore.categoryIndex[category][indexCount +1] = index
		end

		
	end

	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, collectedFlag)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, notCollectedFlag)
end

local function GetMountBySpellID(spellID)
	if not spellID then
		return nil
	end

	local mount = mountDatastore.allMounts[tostring(spellID)]

	if not mount then 
		EasyRider:Print("Mount not found for spellID: ".. spellID) 
	end

	return mount
end

local function GetRandomMount(category, favoriteOnly)
	--math.randomseed(time())

	if not mountDatastore.categoryIndex[category] or #mountDatastore.categoryIndex[category] == 0 then
		return nil
	end

	local indexCount = #mountDatastore.categoryIndex[category]	
	local index = math.random(1, indexCount)
	local spellID = mountDatastore.categoryIndex[category][index]

	return mountDatastore.allMounts[spellID] 
end


function EasyRider_InitButtons()
	if buttonsInitialised then
		return
	end

	for index = 1, TOTAL_CATEGORIES do
		local button = CreateFrame("Button", "EasyRider_Button"..index, EasyRiderFrame, "EasyRiderButtonTemplate");
		button.category = index
		buttons[index] = button
	end

	buttonsInitialised = true;
end

function  SummonMount(category)
	local mount = GetMountBySpellID(mounts[index])

	if not mount then  
		return
	end

	C_MountJournal.SummonByID(mount.mountID)
end

function ShowTooltip(button)	
	local mount = GetMountBySpellID(mounts[button.category])
	local info = buttonInfo[button.category]
	local tooltip = GameTooltip

	if not info or not mount then
		return
	end

	local _, _, _, castingTime, _, _, _ = GetSpellInfo(mount.spellID)

    --if button:GetRight() >= ( GetScreenWidth() / 2 ) then
    --    GameTooltip:SetOwner(button, "ANCHOR_LEFT");
    --else
    --    GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
    --end

	GameTooltip_SetDefaultAnchor(tooltip, button)

    tooltip:AddLine(info.title, white.r, white.g, white.b);
    tooltip:AddLine(format("%.1f sec cast", castingTime/1000), white.r, white.g, white.b);
	tooltip:AddLine(info.description, nil, nil, nil, true);	
	tooltip:AddLine(" ");
	tooltip:AddLine(format("Preferred Mount: |cff33ff99%s|r", mount.name), white.r, white.g, white.b);
	tooltip:AddLine(mount.description, nil, nil, nil, true);
	tooltip:AddLine(" ");
	tooltip:AddLine("|cffffffffLeft-Click:|r Summon preferred mount");
	tooltip:AddLine("|cffffffffShift+Left-Click:|r Summon random mount" );
	tooltip:AddLine("|cffffffffAlt+Left-Click:|r Summon random favorite mount" );
	--tooltip:AddLine("|cffffffffCtrl+Left-Click:|r Summon randam mount");
	--tooltip:AddLine("|cffffffffRight-click:|r Choose mount to summon");

    tooltip:Show();
end

function SummonMount(category)
	local  mount = nil
	
	if IsControlKeyDown() then
		
	elseif  IsAltKeyDown() then
		mount = GetRandomMount(category, true)
	elseif IsShiftKeyDown() then
		mount = GetRandomMount(category)
	else	  
		mount = GetMountBySpellID(mounts[category])
	end		
	
	if mount then
		C_MountJournal.SummonByID(mount.mountID)
	end
end

function ButtonOnClick(actionButton, mouseButton)
	if mouseButton == "LeftButton" then
		SummonMount(actionButton.category)	
	elseif mouseButton == "RightButton" then

	end	
end

function ButtonOnEnter(button)
	ShowTooltip(button)
end

function ButtonOnLeave(button)
	GameTooltip:Hide()
end

function EasyRider_InitFrame()
	EasyRider_InitButtons()	

	local count = 0

	for index = 1, TOTAL_CATEGORIES do
		local button = buttons[index]
		local spellID = mounts[index]
		

		if spellID then 
			local spellName, _, icon = GetSpellInfo(mounts[index])

			button:ClearAllPoints();
			button:SetPoint("LEFT", (6 + 38 * count), 0);

			_G[button:GetName().."Icon"]:SetTexture(icon);

			button:SetScript('OnClick', ButtonOnClick)
			button:SetScript('OnEnter', ButtonOnEnter)
			button:SetScript('OnLeave', ButtonOnLeave)

			button:Show();
			count = count + 1;		
		else
			button:Hide()
		end;
        
	end
	
	EasyRiderFrame:SetWidth(10 + 38 * count);
	
	return count
end

--function MountBar_OnEvent(self, event, ...)
--	if (event == "PLAYER_ENTER_COMBAT") then
--        if InCombatLockdown() then
--            local frame = getglobal("CraftBarFrame");
--            frame:Hide();
--        end
--    end

--	print(event)
--	DEFAULT_CHAT_FRAME:AddMessage(event)
--end 
local defaults = {
	global = {

	},
};

local function DelayedInit()
	CacheMounts()

	local frame = getglobal("EasyRiderFrame")
	local count = EasyRider_InitFrame()

	local x, y = GetCursorPosition();
    local scale = UIParent:GetEffectiveScale();

    x = x / scale;
    y = y / scale;

	if EasyRider.db.global.position then
		x = EasyRider.db.global.position.XPos
		y = EasyRider.db.global.position.YPos
	end

    frame:ClearAllPoints();
    --frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
	frame:SetPoint("BOTTOMLEFT", x, y)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop",function(self)
		self:StopMovingOrSizing()
		EasyRider.db.global.position = {}
		EasyRider.db.global.position.XPos = self:GetLeft()
		EasyRider.db.global.position.YPos = self:GetBottom()
	end)
	
	frame:Show()
end

function EasyRider:OnInitialize()	
	self.db = LibStub("AceDB-3.0"):New("EasyRiderDB", defaults, true)
end

function EasyRider:OnEnable()	
	EasyRider:ScheduleTimer(DelayedInit, 3)
end

function EasyRider:OnDisable()

end

