EasyRider = LibStub("AceAddon-3.0"):NewAddon("EasyRider", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0" );

local buttonsInitialised = false
local buttons = {}
local mountDatastore = {}

local CATEGORY_GROUND = 1
local CATEGORY_FLY = 2
local CATEGORY_SURFACE = 3
local CATEGORY_AQUATIC = 4
local CATEGORY_PASSENGER = 5
local CATEGORY_VENDOR = 6

local TOTAL_CATEGORIES = 6

local ORIENTATION_HORIZONTAL = 1
local ORIENTATION_VERTICAL = 2
local ALIGNMENT_NONE = 1
local ALIGNMENT_LEFT = 2
local ALIGNMENT_RIGHT = 3

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
	--math.randomseed(44)

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

function EasyRider:ShowPopUpMenu(button)
	GameTooltip:Hide()
	ToggleDropDownMenu(1, nil, EasyRiderDropDownMenu, button, 0, 0);
end

function EasyRider:ShowTooltip(category)	
	local preferred = EasyRider.db.profile.preferredMounts or {}
	
	local info = buttonInfo[category]
	local tooltip = GameTooltip
	local preferredMount = nil

    --if button:GetRight() >= ( GetScreenWidth() / 2 ) then
    --    GameTooltip:SetOwner(button, "ANCHOR_LEFT");
    --else
    --    GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
    --end

	if preferred[category] then
		preferredMount = GetMountBySpellID(preferred[category])
	end

	GameTooltip_SetDefaultAnchor(tooltip, buttons[category])

    tooltip:AddLine(info.title, white.r, white.g, white.b);
	tooltip:AddLine("1.5 sec cast", white.r, white.g, white.b);
	tooltip:AddLine(info.description, nil, nil, nil, true);	
	tooltip:AddLine(" ");

	if preferredMount then 
		tooltip:AddLine(format("|cffffffffPreferred Mount:|r |cff33ff99%s|r", preferredMount.name));
	else
		tooltip:AddLine("|cffffffffPreferred Mount:|r not set");
	end

	tooltip:AddLine(" ");
	tooltip:AddLine("|cffffffffShift-Click:|r Summon preferred mount");
	tooltip:AddLine("|cffffffffAlt+Left-Click:|r Summon random favorite mount");
	tooltip:AddLine("|cffffffffCtrl+Left-Click:|r Set active mount as preferred");
	tooltip:AddLine("|cffffffffRight-Click:|r Open options  menu");
    tooltip:Show();
end

function EasyRider:ShowActionBar()

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
		EasyRider:ShowPopUpMenu(actionButton)
	end	
end

function ToggleLocked()
	local options = EasyRider.db.profile.actionBar or {}

	options.locked = not options.locked	
	EasyRider.db.profile.actionBar = options
end

function SetOrientation(dropdownbutton, arg1, arg2, checked)
	local options = EasyRider.db.profile.actionBar or {}

	options.orientation = arg1 
	EasyRider.db.profile.actionBar = options
	ShowActionBar()
end
	
function SetAlignment(dropdownbutton, arg1, arg2, checked)
	local options = EasyRider.db.profile.actionBar or {}

	options.alignment = arg1
	EasyRider.db.profile.actionBar = options
	ShowActionBar()
end

function ButtonOnLoad(button)
	button:RegisterForClicks("AnyUp")
end

function ButtonOnEnter(button)
	EasyRider:ShowTooltip(button.category)
end

function ButtonOnLeave(button)
	GameTooltip:Hide()
end

function ButtonOnDragStart(button)
	local options = EasyRider.db.profile.actionBar

	if not options.locked then
		EasyRiderFrame:StartMoving()
	end
end

function ButtonOnDragStop(button)
	local position = {}

	EasyRiderFrame:StopMovingOrSizing()

	position.XPos = EasyRiderFrame:GetLeft()
	position.YPos = EasyRiderFrame:GetBottom()
	EasyRider.db.profile.actionBar.position = position
	EasyRider.db.profile.actionBar.alignment = ALIGNMENT_NONE
end

function FrameOnLoad(frame)
	--frame:RegisterForClicks("AnyUp")
end



  -- menu create function
function EasyRiderDropDownMenu_Initialize(self, level)
	if not level then
		return
	end

	local options = EasyRider.db.profile.actionBar or {}
	local info = nil
	 
	if level == 1 then
		
		info = UIDropDownMenu_CreateInfo();
		info.hasArrow = false;
		info.notCheckable = false;
		info.text = "Locked";
		info.checked = false
		info.checked = options.locked
		info.func = ToggleLocked 
		UIDropDownMenu_AddButton(info, level);

		info = UIDropDownMenu_CreateInfo();
		info.hasArrow = true;
		info.notCheckable = true;
		info.text = "Orientation";
		info.value = {
			["Level1_Key"] = "Orientation";
		}
		UIDropDownMenu_AddButton(info, level);
		
		info = UIDropDownMenu_CreateInfo();
		info.hasArrow = true;
		info.notCheckable = true;
		
		info.text = "Alignment";
		
		info.value = {
			["Level1_Key"] = "Alignment";
		}
		UIDropDownMenu_AddButton(info, level);
	end
	if level == 2 then
		local Level1_Key = UIDROPDOWNMENU_MENU_VALUE["Level1_Key"];

		if Level1_Key == "Orientation" then
			info = UIDropDownMenu_CreateInfo();
			info.hasArrow = false;
			info.notCheckable = false;
			info.text = "Horizontal";
			info.checked = options.orientation == ORIENTATION_HORIZONTAL
			info.func = SetOrientation
			info.value = ORIENTATION_HORIZONTAL
			info.arg1 = ORIENTATION_HORIZONTAL
			UIDropDownMenu_AddButton(info, level);
			
			info = UIDropDownMenu_CreateInfo();
			info.hasArrow = false;
			info.notCheckable = false;
			info.text = "Vertical";
			info.checked = not options.orientation or options.orientation == ORIENTATION_VERTICAL
			info.func = SetOrientation
			info.value = ORIENTATION_VERTICAL
			info.arg1 = ORIENTATION_VERTICAL
			UIDropDownMenu_AddButton(info, level);
		
		elseif Level1_Key == "Alignment" then
			info = UIDropDownMenu_CreateInfo();
			info.hasArrow = false;
			info.notCheckable = false;
			info.text = "None";
			info.checked = options.alignment == ALIGNMENT_NONE
			info.func = SetAlignment
			info.value = ALIGNMENT_NONE
			info.arg1 = ALIGNMENT_NONE
			UIDropDownMenu_AddButton(info, level);
			
			info = UIDropDownMenu_CreateInfo();
			info.hasArrow = false;
			info.notCheckable = false;
			info.text = "Left";
			info.checked = options.alignment == ALIGNMENT_LEFT
			info.func = SetAlignment
			info.value = ALIGNMENT_LEFT
			info.arg1 = ALIGNMENT_LEFT
			UIDropDownMenu_AddButton(info, level);
			
			info = UIDropDownMenu_CreateInfo();
			info.hasArrow = false;
			info.notCheckable = false;
			info.text = "Right";
			info.checked = not options.alignment or options.alignment == ALIGNMENT_RIGHT
			info.func = SetAlignment			
			info.value = ALIGNMENT_RIGHT
			info.arg1 = ALIGNMENT_RIGHT
			UIDropDownMenu_AddButton(info, level);		
		end
	end
end

function EasyRider_InitFrame()
	local options = EasyRider.db.profile.actionBar or {}

	EasyRider_InitButtons()	
	
	local count = 0

	for index = 1, TOTAL_CATEGORIES do
		local info = buttonInfo[index]
		local button = buttons[index]

		
		button:ClearAllPoints();

		if options.orientation == ORIENTATION_HORIZONTAL then

			button:SetPoint("LEFT", (6 + 38 * count), 0);
		else
			button:SetPoint("TOPLEFT", 0, (6 + 38 * count)* -1);
		end

		_G[button:GetName().."Icon"]:SetTexture(info.icon);


		button:SetScript('OnLoad', ButtonOnLoad)
		button:SetScript('OnClick', ButtonOnClick)
		button:SetScript('OnEnter', ButtonOnEnter)
		button:SetScript('OnLeave', ButtonOnLeave)

		button:RegisterForDrag("LeftButton")
		button:SetScript("OnDragStart", ButtonOnDragStart)
		button:SetScript("OnDragStop", ButtonOnDragStop)

		button:Show();
		count = count + 1;       
	end
	
	if options.orientation == ORIENTATION_HORIZONTAL then
		EasyRiderFrame:SetWidth(10 + 38 * count);
	else
		EasyRiderFrame:SetHeight(10 + 38 * count);
	end
	
	return count
end

--local defaults = {
--	profile = {
--		configured = false,
--	},
--	global = {

--	},
--};

function CreateActionBar()
	--local frame = CreateFrame("Frame", "EasyRiderActionBar", UIParent)
	local frame = getglobal("EasyRiderFrame")
	local options = EasyRider.db.profile.actionBar or {}
	

	for index = 1, TOTAL_CATEGORIES do
		local button = CreateFrame("Button", "EasyRider_Button"..index, EasyRiderFrame, "EasyRiderButtonTemplate");
		--local button = CreateFrame("Button", "EasyRiderActionBar_Button"..index, frame, "SecureActionButtonTemplate");
		local info = buttonInfo[index]

		button.category = index
		button:SetScript('OnLoad', ButtonOnLoad)
		button:SetScript('OnClick', ButtonOnClick)
		button:SetScript('OnEnter', ButtonOnEnter)
		button:SetScript('OnLeave', ButtonOnLeave)button:RegisterForDrag("LeftButton")
		button:SetScript("OnDragStart", ButtonOnDragStart)
		button:SetScript("OnDragStop", ButtonOnDragStop)

		--_G["EasyRiderActionBar_Button"..index.."Icon"]:SetTexture(info.icon);
		_G[button:GetName().."Icon"]:SetTexture(info.icon);

		buttons[index] = button
	end

	frame:RegisterForDrag("LeftButton")

	--EasyRider.actionBar = frame
end

function ShowActionBar()
	local count = 0
	--local frame = EasyRider.actionBar
	local frame = getglobal("EasyRiderFrame")
	local options = EasyRider.db.profile.actionBar or {}

	frame:Hide()

	for index = 1, TOTAL_CATEGORIES do		
		local button = buttons[index]
		local info = buttonInfo[index]
		
		--_G[button:GetName().."Icon"]:SetTexture(info.icon);

		button:ClearAllPoints();

		if options.orientation == ORIENTATION_HORIZONTAL then
			button:SetPoint("LEFT", (6 + 38 * count), 0);
		else
			button:SetPoint("TOPLEFT", 0, (6 + 38 * count)* -1);
		end

		button:Show();
		count = count + 1;       
	end
	
	if options.orientation == ORIENTATION_HORIZONTAL then
		frame:SetWidth(10 + 38 * count);
	else
		frame:SetHeight(10 + 38 * count);
	end

	frame:ClearAllPoints();

	if options.alignment == ALIGNMENT_NONE and options.position then
		x = options.position.XPos
		y = options.position.YPos
		frame:SetPoint("BOTTOMLEFT", x, y)
	else
		if options.alignment and options.alignment == ALIGNMENT_LEFT then
			frame:SetPoint("LEFT")
		else
			frame:SetPoint("RIGHT")
		end
	end

	frame:RegisterForDrag("LeftButton")

	frame:Show()	
end



local function DelayedInit()
	CacheMounts()
	CreateActionBar()
	ShowActionBar()
	--EasyRider.actionBar:Show()

--	local frame = getglobal("EasyRiderFrame")
--	local count = EasyRider_InitFrame()
--	local options = EasyRider.db.profile.actionBar or {}

--	 frame:ClearAllPoints();


--	if options.alignment == ALIGNMENT_NONE and options.position then
--		x = options.position.XPos
--		y = options.position.YPos
--		frame:SetPoint("BOTTOMLEFT", x, y)
--	else
--		if options.alignment and options.alignment == ALIGNMENT_LEFT then
--			frame:SetPoint("LEFT")
--		else
--			frame:SetPoint("RIGHT")
--		end
--	end

--	frame:RegisterForDrag("LeftButton")

--	frame:Show()
end

function EasyRider:OnInitialize()	
	self.db = LibStub("AceDB-3.0"):New("EasyRiderDB", nil)
end

function EasyRider:OnEnable()	
	EasyRider:ScheduleTimer(DelayedInit, 3)
end

function EasyRider:OnDisable()

end

