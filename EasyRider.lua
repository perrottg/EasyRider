EasyRider = LibStub("AceAddon-3.0"):NewAddon("EasyRider", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0" );

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

local TOTAL_CATEGORIES = 6


mounts[CATEGORY_GROUND] = 200175
mounts[CATEGORY_FLY] = 183117
mounts[CATEGORY_SURFACE] = 118089
mounts[CATEGORY_AQUATIC] = 228919
mounts[CATEGORY_PASSENGER] = 75973
mounts[CATEGORY_VENDOR] = 61447

local buttonInfo = {}
buttonInfo[CATEGORY_GROUND] = {
	title = "Summon Ground Mount",
	icon = "Interface\\Icons\\Ability_mount_ridinghorse",
	description = "Summons and dismisses a randam ground mount."
}
buttonInfo[CATEGORY_FLY] = {
	title = "Summon Flying Mount",
	icon = "Interface\\Icons\\Ability_mount_goldengryphon",	
	description = "Summons and dismisses a randam flying mount."
}
buttonInfo[CATEGORY_SURFACE] = {
	title = "Summon Surface Mount",
	icon = "Interface\\Icons\\Ability_mount_waterstridermount",
	description = "Summons and dismisses a randam mount capable of walking on water."
}
buttonInfo[CATEGORY_AQUATIC] = {
	title = "Summon Aquaic Mount",
	icon = "Interface\\Icons\\Ability_mount_seahorse",
	description = "Summons and  dismisses a randam mount capable of swimming in water."
}
buttonInfo[CATEGORY_PASSENGER] = {
	title = "Summon Passenger Mount", 
	icon = "Interface\\Icons\\Ability_mount_rocketmount2",
	description = "Summons and dismisses a randam mount capable of transporting a passanger."
}
buttonInfo[CATEGORY_VENDOR] = {
	title = "Summon Vendor Mount",
	icon = "Interface\\Icons\\Ability_mount_mammoth_brown_3seater",
	description = "Summoms and dismisses a randam mount with a vendor."
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

local function IndexMount(mount, category)
	local index = tostring(mount.spellID)
	local count = 0

	if not mountDatastore.categoryIndex[category] then
		mountDatastore.categoryIndex[category] = {}
	end

	if not mountDatastore.categoryIndex[category][tostring(false)] then
		mountDatastore.categoryIndex[category][tostring(false)] = {}
	end

	if not mountDatastore.categoryIndex[category][tostring(true)] then
		mountDatastore.categoryIndex[category][tostring(true)] = {}
	end
	
	count = #mountDatastore.categoryIndex[category][tostring(false)]			
	mountDatastore.categoryIndex[category][tostring(false)][count +1] = index

	if mount.isFavorite then
		count = #mountDatastore.categoryIndex[category][tostring(true)]			
		mountDatastore.categoryIndex[category][tostring(true)][count +1] = index
	end
end 

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
		mount.isFavorite = isFavorite

		mountDatastore.allMounts[index] = mount

		-- Core mount types: ground, flying and aquatic
		if mountType == 232 or mountType == 254 then
			IndexMount(mount, CATEGORY_AQUATIC)
		elseif mountType == 248 then
			IndexMount(mount, CATEGORY_FLY)
		elseif mountType == 230 then
			IndexMount(mount, CATEGORY_GROUND)
		end

		if mountDB[CATEGORY_PASSENGER][mount.spellID] then
			IndexMount(mount, CATEGORY_PASSENGER)
		end
		
		if mountType == 269 then
			IndexMount(mount, CATEGORY_SURFACE)
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

local function GetRandomMount(category, favoriteOnly )
	--math.randomseed(time())

	if not favoriteOnly then
		favoriteOnly = false
	end

	if not mountDatastore.categoryIndex[category] or #mountDatastore.categoryIndex[category][tostring(favoriteOnly)] == 0 then
		EasyRider:Print("NO MOUNTS!")
		return nil
	end

	local count = #mountDatastore.categoryIndex[category][tostring(favoriteOnly)]	
	local index = math.random(1, count)
	local spellID = mountDatastore.categoryIndex[category][tostring(favoriteOnly)][index]

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
	local preferred = EasyRider.db.profile.preferredMounts or {}
	
	local info = buttonInfo[button.category]
	local tooltip = GameTooltip

    --if button:GetRight() >= ( GetScreenWidth() / 2 ) then
    --    GameTooltip:SetOwner(button, "ANCHOR_LEFT");
    --else
    --    GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
    --end

	GameTooltip_SetDefaultAnchor(tooltip, button)

    tooltip:AddLine(info.title, white.r, white.g, white.b);
	tooltip:AddLine("1.5 sec cast", white.r, white.g, white.b);
	tooltip:AddLine(info.description, nil, nil, nil, true);	
	tooltip:AddLine(" ");
	if preferred[button.category] then
		local mount = GetMountBySpellID(preferred[button.category])

		tooltip:AddLine("|cffffffffShift-Click:|r Summon "..mount.name);
	end
	tooltip:AddLine("|cffffffffAlt+Left-Click:|r Summon random favorite mount" );
	tooltip:AddLine("|cffffffffCtrl+Left-Click:|r Set active mount as preferred" );

    tooltip:Show();
end

function SetPreferredMount(category)
	if IsMounted() then
		local preferred = EasyRider.db.profile.preferredMounts or {}
		local index = 1
		local mount = nil
		repeat 
			name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitBuff("player", index) 
			mount = GetMountBySpellID(spellID)
			if mount then
				preferred[category] = spellID
				EasyRider.db.profile.preferredMounts = preferred
				EasyRider:Print("Preferred mount set to "..mount.name)
				break
			end
			index = index+1
		until not name
	end	
end


function SummonMount(category)	
	local preferred = EasyRider.db.profile.preferredMounts or {}
	local  mount = nil
	
	if IsAltKeyDown() then
		EasyRider:Print("Request to summon random favorite")
		mount = GetRandomMount(category, true)
	elseif IsShiftKeyDown() then
		mount = GetMountBySpellID(preferred[category])
	else	  
		mount = GetRandomMount(category)
	end		
	
	if mount then
		if IsMounted() then
			Dismount()
		end
		C_MountJournal.SummonByID(mount.mountID)
	else
		EasyRider:Print("No mount found!")
	end
end

function ButtonOnClick(actionButton, mouseButton)
	if mouseButton == "LeftButton" then
		if IsControlKeyDown() then
			SetPreferredMount(actionButton.category)
		else
			SummonMount(actionButton.category)	
		end
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
	local barOptions = EasyRider.db.profile.barOptions or {}

	EasyRider_InitButtons()	
	
	local count = 0

	for index = 1, TOTAL_CATEGORIES do
		local info = buttonInfo[index]
		local button = buttons[index]

		button:ClearAllPoints();

		if barOptions.horizontal then
			button:SetPoint("LEFT", (6 + 38 * count), 0);
		else
			button:SetPoint("TOPLEFT", 0, (6 + 38 * count)* -1);
		end

		_G[button:GetName().."Icon"]:SetTexture(info.icon);

		button:SetScript('OnClick', ButtonOnClick)
		button:SetScript('OnEnter', ButtonOnEnter)
		button:SetScript('OnLeave', ButtonOnLeave)
		button:Show();
		count = count + 1;       
	end
	
	if barOptions.horizontal then
		EasyRiderFrame:SetWidth(10 + 38 * count);
	else
		EasyRiderFrame:SetHeight(10 + 38 * count);
	end
	
	return count
end

local defaults = {
	profile = {
		configured = false,
	},
	global = {

	},
};

local function DelayedInit()
	CacheMounts()

	local config = EasyRider.db.profile
	local frame = getglobal("EasyRiderFrame")
	local count = EasyRider_InitFrame()

	 frame:ClearAllPoints();

	if config.configured then
		x = EasyRider.db.global.position.XPos
		y = EasyRider.db.global.position.YPos
		frame:SetPoint("BOTTOMLEFT", x, y)
	else
		--frame:SetPoint("CENTER", 0, 0)
		frame:SetPoint("RIGHT")
	end

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
	self.db = LibStub("AceDB-3.0"):New("EasyRiderDB", defaults)
end

function EasyRider:OnEnable()	
	EasyRider:ScheduleTimer(DelayedInit, 3)
end

function EasyRider:OnDisable()

end

