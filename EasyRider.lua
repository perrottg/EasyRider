EasyRider = LibStub("AceAddon-3.0"):NewAddon("EasyRider", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0" );

local L = LibStub("AceLocale-3.0"):GetLocale("EasyRider")

local buttonsInitialised = false
local mountDatastore = {}

local mountTypes = {
	GROUND = 1,
	FLY = 2,
	SURFACE = 3,
	AQUATIC = 4,
	PASSENGER = 5,
	VENDOR = 6,	
}

local TOTAL_MOUNT_TYPES = 6

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
local ALIGNMENT_TOP = 4
local ALIGNMENT_BOTTOM = 5
local ALIGNMENT_LEFT = 2
local ALIGNMENT_RIGHT = 3

local inCombat = false
local inPetBattle = false
local inVehicle = false

local lastCategorySummoned = 0
local buttonInfo = {}

buttonInfo[CATEGORY_GROUND] = {
	title = L["Summon Ground Mount"],
	icon = "Interface\\Icons\\Ability_mount_ridinghorse",
	description = format("%s %s", L["Summons and dismisses the preferred ground mount."], 
		L["If the preferred mount has not been set then a favorite or random mount will be summoned instead."])
}
buttonInfo[CATEGORY_FLY] = {
	title = L["Summon Flying Mount"],
	icon = "Interface\\Icons\\Ability_mount_goldengryphon",	
	description = format("%s %s", L["Summons and dismisses the preferred flying mount."], 
		L["If the preferred mount has not been set then a favorite or random mount will be summoned instead."])
}
buttonInfo[CATEGORY_SURFACE] = {
	title = L["Summon Surface Mount"],
	icon = "Interface\\Icons\\Ability_mount_waterstridermount",
	description = format("%s %s", L["Summons and dismisses the preferred mount capable of walking on water."], 
		L["If the preferred mount has not been set then a favorite or random mount will be summoned instead."])		
}	
buttonInfo[CATEGORY_AQUATIC] = {
	title = L["Summon Aquatic Mount"],
	icon = "Interface\\Icons\\Ability_mount_seahorse",
	description = format("%s %s", L["Summons and  dismisses the preferred aquatic mount."], 
		L["If the preferred mount has not been set then a favorite or random mount will be summoned instead."])	
}
buttonInfo[CATEGORY_PASSENGER] = {
	title = L["Summon Passenger Mount"], 
	icon = "Interface\\Icons\\Ability_mount_rocketmount2",
	description = format("%s %s", L["Summons and dismisses the preferred mount capable of transporting a passenger."], 
		L["If the preferred mount has not been set then a favorite or random mount will be summoned instead."])
}
buttonInfo[CATEGORY_VENDOR] = {
	title = L["Summon Vendor Mount"],
	icon = "Interface\\Icons\\Ability_mount_mammoth_brown_3seater",
	description = format("%s %s", L["Summons and dismisses the preferred mount with a vendor."], 
		L["If the preferred mount has not been set then a favorite or random mount will be summoned instead."])
}

local red = { r = 1.0, g = 0.2, b = 0.2 }
local blue = { r = 0.4, g = 0.4, b = 1.0 }
local green = { r = 0.2, g = 1.0, b = 0.2 }
local yellow = { r = 1.0, g = 1.0, b = 0.2 }
local gray = { r = 0.5, g = 0.5, b = 0.5 }
local black = { r = 0.0, g = 0.0, b = 0.0 }
local white = { r = 1.0, g = 1.0, b = 1.0 }

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

local function CaptureMounts()
	local collectedFlag = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED)
	local notCollectedFlag = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED)
	
	local mountList = {}

	mountDatastore.allMounts = {}
	mountDatastore.categoryIndex = {}
	
	C_MountJournal.SetAllSourceFilters(true);
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, true)
	
	local numMounts = C_MountJournal.GetNumDisplayedMounts()

	for index = 1, numMounts do		
		local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index)
		local creatureID, description, _, isSelfMount, mountType = C_MountJournal.GetDisplayedMountInfoExtra(index);
		local index = tostring(spellID)

		local mount = {}
		local mountTyped = false

		mount.name = creatureName
		mount.spellID = spellID
		mount.mountID = mountID
		mount.icon = icon
		mount.creatureID = creatureID
		mount.mountType = mountType 
		mount.sourceType = sourceType
		mount.isFactionSpecific = isFactionSpecific
		mount.faction = faction
		mount.isSelfMount = isSelfMount
		
		mountList[spellID] = mount
			
	end
	
	EasyRider.db.global.mountList = mountList

	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, collectedFlag)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, notCollectedFlag)
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

		if isUsable or EasyRider:IsMountType(spellID, mountTypes.AQUATIC) then
			local mount = {}
			local mountTyped = false

			mount.name = creatureName
			mount.description = description
			mount.spellID = spellID
			mount.mountID = mountID
			mount.icon = icon
			mount.creatureID = creatureID
			mount.mountType = mountType 
			mount.isFavorite = isFavorite

			mountDatastore.allMounts[index] = mount

			for i = mountTypes.SURFACE, TOTAL_MOUNT_TYPES do
				if EasyRider:IsMountType(mount.spellID, i) then
					IndexMount(mount, i)		
					mountTyped = true
				end
			end

			if mountType == 248 and not mountTyped then
				IndexMount(mount, CATEGORY_FLY)
			elseif mountType == 230 and not mountTyped then
				IndexMount(mount, CATEGORY_GROUND)
			end

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

	return mount
end

local function GetRandomMount(category, favoriteOnly )
	--math.randomseed(44)

	if not favoriteOnly then
		favoriteOnly = false
	end

	if not mountDatastore.categoryIndex[category] or #mountDatastore.categoryIndex[category][tostring(favoriteOnly)] == 0 then
		return nil
	end

	local count = #mountDatastore.categoryIndex[category][tostring(favoriteOnly)]	
	local index = math.random(1, count)
	local spellID = mountDatastore.categoryIndex[category][tostring(favoriteOnly)][index]

	return mountDatastore.allMounts[spellID] 
end

function EasyRider:ShowPopUpMenu(button)	
	ToggleDropDownMenu(1, nil, EasyRiderDropDownMenu, button, 0, 0);
end

function EasyRider:ShowTooltip(category)	
	local preferred = EasyRider.db.char.preferredMounts or {}
	
	local info = buttonInfo[category]
	local tooltip = GameTooltip

    --if button:GetRight() >= ( GetScreenWidth() / 2 ) then
    --    GameTooltip:SetOwner(button, "ANCHOR_LEFT");
    --else
    --    GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
    --end

	GameTooltip_SetDefaultAnchor(tooltip, EasyRider.buttons[category])

    tooltip:AddLine(info.title, white.r, white.g, white.b);
	tooltip:AddLine("1.5 sec cast", white.r, white.g, white.b);
	tooltip:AddLine(info.description, nil, nil, nil, true);	
	tooltip:AddLine(" ");

	if preferred[category] then 
		name, _, icon = GetSpellInfo(preferred[category])
		tooltip:AddLine(format("|cffffffff%s:|r |cff33ff99%s|r", L["Preferred Mount"], name))
	else
		tooltip:AddLine(format("|cffffffff%s:|r %s", L["Preferred Mount"], L["not set"]))
	end

	tooltip:AddLine(" ");
	tooltip:AddLine(format("|cffffffff%s:|r %s", L["Shift-Click"], L["Summon random mount"]))
	tooltip:AddLine(format("|cffffffff%s:|r %s", L["Alt+Left-Click"], L["Summon a favorite mount"]))
	tooltip:AddLine(format("|cffffffff%s:|r %s", L["Ctrl+Left-Click"], L["Set current mount as preferred"]))
	tooltip:AddLine(format("|cffffffff%s:|r %s", L["Right-Click"], L["Open options  menu"]))
    tooltip:Show();
end

function SetPreferredMount(category)
	local preferred = EasyRider.db.char.preferredMounts or {}

	if IsMounted() then		
		-- look for  active mount spell and set the preferred moount if found
		local index = 1
		local mount = nil
		repeat 
			name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitBuff("player", index) 
			mount = GetMountBySpellID(spellID)
			if mount then
				preferred[category] = spellID
				EasyRider.db.char.preferredMounts = preferred
				break
			end
			index = index+1
		until not name
	else
		-- Clear the preferred mount
		preferred[category] = nil
	end	

end


function SummonMount(category)	
	local preferred = EasyRider.db.char.preferredMounts or {}
	local  mount = nil
	
	if category == lastCategorySummoned and IsMounted() then
		Dismount()
		return
	end

	if IsAltKeyDown() then
		mount = GetRandomMount(category, true)
	elseif IsShiftKeyDown() then
		mount = GetRandomMount(category)		
	else
		if preferred[category] then
			mount = GetMountBySpellID(preferred[category])
		end
		if not mount then
			mount = GetRandomMount(category, true)
		end
		if not mount then
			mount = GetRandomMount(category)
		end
	end		
	
	if mount then
		C_MountJournal.SummonByID(mount.mountID)
	else
		EasyRider:Print("NO mount!")
	end

	lastCategorySummoned = category
end

function ButtonOnClick(actionButton, mouseButton)
	if mouseButton == "LeftButton" then
		if IsControlKeyDown() then
			GameTooltip:Hide()
			SetPreferredMount(actionButton.category)
			EasyRider:ShowTooltip(actionButton.category)
		else
			SummonMount(actionButton.category)	
		end
	elseif mouseButton == "RightButton" then
		GameTooltip:Hide()
		EasyRider:ShowPopUpMenu(actionButton)
	end	
end

function ToggleLocked(dropdownbutton, arg1, arg2, checked)
	local options = EasyRider.db.global.actionBar or {}

	options.locked = not checked
	EasyRider.db.global.actionBar = options
end

function ToggleAutoHide(dropdownbutton, arg1, arg2, checked)
	local options = EasyRider.db.global.actionBar or {}

	options.alwaysShow = checked
	EasyRider.db.global.actionBar = options
end

function SetActionBarOrientation(orientation)
	local options = EasyRider.db.global.actionBar or {}

	if options.orientation ~= orientation then
		options.orientation = orientation
		EasyRider.db.global.actionBar = options
		EasyRider:ShowActionBar()
	end
end

function SetActionBarAlignment(alignment)
	local options = EasyRider.db.global.actionBar or {}

	if options.alignment ~= alignment then 
		options.alignment = alignment

		if alignment == ALIGNMENT_TOP or alignment == ALIGNMENT_BOTTOM then
			options.orientation = ORIENTATION_HORIZONTAL
		else
			options.orientation = ORIENTATION_VERTICAL
		end
		
		EasyRider.db.global.actionBar = options

		if alignment == ALIGNMENT_NONE  and not options.position then
			SaveActionBarPosition()
		else
			EasyRider:ShowActionBar()
		end
	end
end

function GetVisibleButtons()
	local options = EasyRider.db.global.actionBar or {}
	local visibleButtons = options.visibleButtons

	if not visibleButtons then 
		visibleButtons = {}

		for index = 1, TOTAL_CATEGORIES do
			visibleButtons[index] = true
		end
	end
	
	return visibleButtons
end

function ShowActionButton(buttonCategory, show)
	local visibleButtons = GetVisibleButtons()

	if show ~= visibleButtons[buttonCategory] then
		visibleButtons[buttonCategory] = show
		EasyRider.db.global.actionBar.visibleButtons = visibleButtons

		EasyRider:ShowActionBar()
	end
end
	
function ButtonOnEnter(button)
	EasyRider:ShowTooltip(button.category)
end

function ButtonOnLeave(button)
	GameTooltip:Hide()
end

function ButtonOnDragStart(button)
	EasyRider:Print("ButtonOnDragStart")
	local options = EasyRider.db.global.actionBar or {}
	local frame = EasyRider.actionBar

	if not options.locked then
		frame:StartMoving()
	end
end

function ButtonOnDragStop(button)
	local options = EasyRider.db.global.actionBar or {}
	local frame = EasyRider.actionBar

	frame:StopMovingOrSizing()

	options.alignment = ALIGNMENT_NONE

	EasyRider.db.global.actionBar = options
	SaveActionBarPosition()
end

function SaveActionBarPosition()
	local options = EasyRider.db.global.actionBar or {}
	local frame = EasyRider.actionBar

	options.position = {}
	options.position.XPos = frame:GetLeft()
	options.position.YPos = frame:GetBottom()
	options.position.X = frame:GetLeft()
	options.position.Y = frame:GetTop()

	EasyRider.db.global.actionBar = options
end

  -- menu create function
function EasyRiderDropDownMenu_Initialize(self, level)
	if not level then
		return
	end

	local options = EasyRider.db.global.actionBar or {}
	local info = nil
	 
	if level == 1 then

		info = UIDropDownMenu_CreateInfo()
		info.hasArrow = false
		info.notCheckable = false
		info.text = L["Auto Hide"]
		info.checked = false
		info.checked = not options.alwaysShow
		info.func = ToggleAutoHide 
		UIDropDownMenu_AddButton(info, level)
		
		info = UIDropDownMenu_CreateInfo()
		info.hasArrow = false
		info.notCheckable = false
		info.text = L["Locked"]
		info.checked = false
		info.checked = options.locked
		info.func = ToggleLocked 
		UIDropDownMenu_AddButton(info, level)

		info = UIDropDownMenu_CreateInfo()
		info.hasArrow = true
		info.notCheckable = true
		info.text = L["Anchor"]		
		info.value = "AnchorMenu"
		UIDropDownMenu_AddButton(info, level)

		info = UIDropDownMenu_CreateInfo()
		info.hasArrow = true
		info.notCheckable = true
		info.text = L["Orientation"]
		info.value = "OrientationMenu"
		UIDropDownMenu_AddButton(info, level)
			
		info = UIDropDownMenu_CreateInfo()
		info.hasArrow = true
		info.notCheckable = true
		info.text = L["Show Buttons"]		
		info.value = "ShowButtonsMenu"
		UIDropDownMenu_AddButton(info, level)

		info = UIDropDownMenu_CreateInfo()
        info.text         = CLOSE        
        info.checked      = nil
        info.notCheckable = true
		info.func         = function() 
			CloseDropDownMenus() 
		end
        UIDropDownMenu_AddButton(info, level)
	end
	if level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "OrientationMenu" then
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Horizontal"]
			info.checked = options.orientation and options.orientation == ORIENTATION_HORIZONTAL
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarOrientation(ORIENTATION_HORIZONTAL) 
			end
			UIDropDownMenu_AddButton(info, level)
			
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Vertical"]
			info.checked = not options.orientation or options.orientation == ORIENTATION_VERTICAL
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarOrientation(ORIENTATION_VERTICAL) 
			end
			UIDropDownMenu_AddButton(info, level)
		
		elseif UIDROPDOWNMENU_MENU_VALUE == "AnchorMenu" then
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["None"]
			info.checked = options.alignment and options.alignment == ALIGNMENT_NONE
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_NONE) 
			end
			UIDropDownMenu_AddButton(info, level)
			
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Top"]
			info.checked = options.alignment and options.alignment == ALIGNMENT_TOP
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_TOP) 
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Bottom"]
			info.checked = options.alignment and options.alignment == ALIGNMENT_BOTTOM
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_BOTTOM) 
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Left"]
			info.checked = options.alignment and options.alignment == ALIGNMENT_LEFT
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_LEFT) 
			end
			UIDropDownMenu_AddButton(info, level)
			
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Right"]
			info.checked = not options.alignment or options.alignment == ALIGNMENT_RIGHT
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_RIGHT) 
			end
			UIDropDownMenu_AddButton(info, level)
		elseif UIDROPDOWNMENU_MENU_VALUE == "ShowButtonsMenu" then
			local visibleButtons = GetVisibleButtons()

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Ground Mount"]
			info.checked = visibleButtons[1]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(1, not visibleButtons[1])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Flying Mount"]
			info.checked = visibleButtons[2]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(2, not visibleButtons[2])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Surface Mount"]
			info.checked = visibleButtons[3]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(3, not visibleButtons[3])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Aquatic Mount"]
			info.checked = visibleButtons[4]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(4, not visibleButtons[4])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Passenger Mount"]
			info.checked = visibleButtons[5]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(5, not visibleButtons[5])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Vendor Mount"]
			info.checked = visibleButtons[6]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(6, not visibleButtons[6])
			end
			UIDropDownMenu_AddButton(info, level)

		end
	end
end

function CreateActionBar()
	local frame = CreateFrame("Frame", "EasyRiderActionBar", UIParent)
	local options = EasyRider.db.global.actionBar or {}
	local preferred = EasyRider.db.char.preferredMounts or {}
	EasyRider.buttons = {}

	frame:SetMovable(true)
	frame:SetToplevel(true)
	

	for index = 1, TOTAL_CATEGORIES do
		local button = CreateFrame("Button", "EasyRider_Button"..index, frame, "SecureActionButtonTemplate, ActionButtonTemplate")
		button:SetSize(37, 37)

		button.category = index
		button:RegisterForClicks("AnyUp")
		button:SetMotionScriptsWhileDisabled(true)
    
		button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
		button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		--item:SetDisabledTexture(buttonInfo[index].icon)
		--do local tex = button:GetNormalTexture()
		--	tex:ClearAllPoints()
		--	tex:SetPoint("CENTER", 0, -1)
		--	tex:SetSize(64, 64)
		--end
    
		
		--button.icon = button:CreateTexture("$parentIconTexture", "ARTWORK")
		button.icon:SetTexture(buttonInfo[index].icon)
    
		button:SetScript('OnLoad', ButtonOnLoad)
		button:SetScript('OnClick', ButtonOnClick)
		button:SetScript('OnEnter', ButtonOnEnter)
		button:SetScript('OnLeave', ButtonOnLeave)
		button:SetScript("OnDragStart", ButtonOnDragStart)
		button:SetScript("OnDragStop", ButtonOnDragStop)
		button:RegisterForDrag("LeftButton")

		EasyRider.buttons[index] = button
	end

	EasyRider.actionBar = frame

	local dropdown = CreateFrame("Frame", "EasyRiderDropDownMenu", UIParent, "UIDropDownMenuTemplate");
	UIDropDownMenu_Initialize(dropdown, EasyRiderDropDownMenu_Initialize, "MENU");
end

function EasyRider:ShowActionBar()
	local count = 0
	local frame = EasyRider.actionBar
	local options = EasyRider.db.global.actionBar or {}
	local visibleButtons = GetVisibleButtons()
	
	

	for index = 1, TOTAL_CATEGORIES do
		
		local button = EasyRider.buttons[index]
		local info = buttonInfo[index]

		if visibleButtons[index] then
		
			button:ClearAllPoints();

			if options.orientation == ORIENTATION_HORIZONTAL then
				button:SetPoint("LEFT", (6 + 38 * count), 0);
			else
				button:SetPoint("TOPLEFT", 0, (6 + 38 * count)* -1);
			end

			button:Show();
			count = count + 1;   
		else
			button:Hide()
		end
	end
	
	

	if options.orientation == ORIENTATION_HORIZONTAL then
		frame:SetWidth(10 + 38 * count);
		frame:SetHeight(38)
	else
		frame:SetHeight(10 + 38 * count);
		frame:SetWidth(38)
	end

	frame:ClearAllPoints()

	if options.alignment == ALIGNMENT_NONE and options.position then
		if options.position.X and options.position.Y then
			frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", options.position.X, options.position.Y)
		else
			frame:SetPoint("BOTTOMLEFT", options.position.XPos, options.position.YPos)
		end
		
	else
		frame:SetClampedToScreen(true)
		if options.alignment and options.alignment == ALIGNMENT_TOP then
			frame:SetPoint("TOP")
		elseif options.alignment and options.alignment == ALIGNMENT_BOTTOM  then 
			frame:SetPoint("BOTTOM")
		elseif options.alignment and options.alignment == ALIGNMENT_LEFT then
			frame:SetPoint("LEFT")
		else
			frame:SetPoint("RIGHT")
		end
	end

	UpdateActionBarState()
	frame:Show()		
end

local function HideActionBar()
	local frame = EasyRider.actionBar
	frame:Hide()
end

local function DelayedInit()
	CacheMounts()
	CreateActionBar()
	EasyRider:ShowActionBar()
end

function UpdateActionBarState()
	local usable = IsOutdoors() and not IsIndoors() and not  inCombat and not inVehicle and not inPetBattle	
	local options = EasyRider.db.global.actionBar or {}


	for index = 1, TOTAL_CATEGORIES do
		local button = EasyRider.buttons[index]

		if button then
			local icon = button.icon;
			local normalTexture = button.NormalTexture;
			
			if usable and (index ~= CATEGORY_AQUATIC or IsSwimming())  then
				icon:SetVertexColor(1.0, 1.0, 1.0);
				normalTexture:SetVertexColor(1.0, 1.0, 1.0);
				button:Enable()
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
				normalTexture:SetVertexColor(1.0, 1.0, 1.0);
				button:Disable()
			end
		end
	end	

	if not options.alwaysShow then
		if inVehicle or inPetBattle then
			HideActionBar()
		else
			ShowActionBar()
		end
	end
end

function EasyRider:PET_BATTLE_OPENING_START()
	inPetBattle = true
	UpdateActionBarState()
end

function EasyRider:PET_BATTLE_CLOSE()
	inPetBattle = false
	UpdateActionBarState()
end

function EasyRider:PLAYER_REGEN_ENABLED()
	inCombat = false
	UpdateActionBarState()
end

function EasyRider:PLAYER_REGEN_DISABLED()
	inCombat = true
	UpdateActionBarState()
end

function EasyRider:UNIT_ENTERED_VEHICLE(event, arg1)
	if arg1 == "player" then
		inVehicle = true
		UpdateActionBarState()
	end
end

function EasyRider:UNIT_EXITED_VEHICLE(event, arg1)
	if arg1 == "player" then
		inVehicle = false
		UpdateActionBarState()
	end
end

function EasyRider:ACTIONBAR_UPDATE_USABLE()
	EasyRider:ScheduleTimer(UpdateActionBarState, 1)
end

function EasyRider:OnInitialize()	
	self.db = LibStub("AceDB-3.0"):New("EasyRiderDB", nil)
	EasyRider:ScheduleTimer(DelayedInit, 3)
end

function EasyRider:OnEnable()	
	EasyRider:RegisterEvent("PET_BATTLE_OPENING_START")
	EasyRider:RegisterEvent("PET_BATTLE_CLOSE")
	EasyRider:RegisterEvent("PLAYER_REGEN_ENABLED")
	EasyRider:RegisterEvent("PLAYER_REGEN_DISABLED")
	EasyRider:RegisterEvent("UNIT_ENTERED_VEHICLE")
	EasyRider:RegisterEvent("UNIT_EXITED_VEHICLE")
	EasyRider:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
end

function EasyRider:OnDisable()
	EasyRider:UnregisterEvent("PET_BATTLE_OPENING_START")
	EasyRider:UnregisterEvent("PET_BATTLE_CLOSE")
	EasyRider:UnregisterEvent("PLAYER_REGEN_ENABLED")
	EasyRider:UnregisterEvent("PLAYER_REGEN_DISABLED")
	EasyRider:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	EasyRider:UnregisterEvent("UNIT_EXITED_VEHICLE")
	EasyRider:UnregisterEvent("ACTIONBAR_UPDATE_USABLE")
end

