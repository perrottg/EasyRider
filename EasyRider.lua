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

local TOTAL_MOUNT_TYPES = 7

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
local timerInterval = 3

buttonInfo[CATEGORY_GROUND] = {
	title = L["Summon Ground Mount"],
	icon = "Interface\\Icons\\Ability_mount_ridinghorse",
	description = L["Summons and dismisses a ground mount."]
}
buttonInfo[CATEGORY_FLY] = {
	title = L["Summon Flying Mount"],
	icon = "Interface\\Icons\\Ability_mount_goldengryphon",	
	description = L["Summons and dismisses a flying mount."]
}
buttonInfo[CATEGORY_SURFACE] = {
	title = L["Summon Surface Mount"],
	icon = "Interface\\Icons\\Ability_mount_waterstridermount",
	description = L["Summons and dismisses a mount capable of walking on water."]
}	
buttonInfo[CATEGORY_AQUATIC] = {
	title = L["Summon Aquatic Mount"],
	icon = "Interface\\Icons\\Ability_mount_seahorse",
	description = L["Summons and  dismisses an aquatic mount."]
}
buttonInfo[CATEGORY_PASSENGER] = {
	title = L["Summon Passenger Mount"], 
	icon = "Interface\\Icons\\Ability_mount_rocketmount2",
	description = L["Summons and dismisses a mount capable of transporting a passenger."]
}
buttonInfo[CATEGORY_VENDOR] = {
	title = L["Summon Vendor Mount"],
	icon = "Interface\\Icons\\Ability_mount_mammoth_brown_3seater",
	description = L["Summons and dismisses a mount with a vendor."]
}

local red = { r = 1.0, g = 0.2, b = 0.2 }
local blue = { r = 0.4, g = 0.4, b = 1.0 }
local green = { r = 0.2, g = 1.0, b = 0.2 }
local yellow = { r = 1.0, g = 1.0, b = 0.2 }
local gray = { r = 0.5, g = 0.5, b = 0.5 }
local black = { r = 0.0, g = 0.0, b = 0.0 }
local white = { r = 1.0, g = 1.0, b = 1.0 }

local function CaptureMounts()
	EasyRider:Print("Capturing mount.... ")
	local mountList = {}
	local mountIDs = C_MountJournal.GetMountIDs()

	for _, mountID in pairs(mountIDs) do

		local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID)
		local creatureID, description, sourceText, isSelfMount, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		local index = tostring(spellID)

		local mount = {}
		local mountTyped = false

		mount.name = creatureName
		mount.spellID = spellID
		mount.mountID = mountID
		mount.icon = icon
		mount.creatureID = creatureID
		mount.description = description
		mount.mountType = mountType 
		mount.sourceType = sourceType
		mount.sourceText = sourceText
		mount.isFactionSpecific = isFactionSpecific
		mount.faction = faction
		mount.isSelfMount = isSelfMount
		
		mountList[spellID] = mount
	end

	EasyRider.db.global.mountList = mountList
end

local function ButtonIsUsable(button)
	local usable = false
	local doingOtherStuff = inCombat or inVehicle or inPetBattle or IsFlying() or UnitOnTaxi("player") or UnitIsDead("player")
	local category = button.category
	local mountTotal = EasyRider:GetUsableMountTotal(category)

	if category == CATEGORY_GROUND or category == CATEGORY_SURFACE or category == CATEGORY_VENDOR then
		usable = IsOutdoors() 
	elseif category == CATEGORY_FLY then
		usable = IsOutdoors() --and IsFlyableArea()
	elseif category == CATEGORY_AQUATIC then				
		usable = IsSwimming()
	elseif category == CATEGORY_PASSENGER then
		usable = IsOutdoors()
	end

	return usable and not doingOtherStuff and mountTotal > 0
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
			name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitBuff("player", index) 
			mount = EasyRider:GetMountBySpellID(spellID)
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
		mount = EasyRider:GetRandomMount(category, true)
	elseif IsShiftKeyDown() then
		mount = EasyRider:GetRandomMount(category)		
	else
		if preferred[category] then
			mount = EasyRider:GetMountBySpellID(preferred[category])
		end
		if not mount then
			mount = EasyRider:GetRandomMount(category)
		end
	end		
	
	if mount then
		C_MountJournal.SummonByID(mount.mountID)
	end

	lastCategorySummoned = category
end

function ButtonOnClick(actionButton, mouseButton)
	if mouseButton == "LeftButton" and ButtonIsUsable(actionButton) then
		if EasyRider.debug then
			EasyRider:Print("Left Button clicked!")
		end
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
	local options = GetActionBarOptions()

	options.locked = not checked
	SetActionBarOptions(options)
end

function ToggleAutoHide(dropdownbutton, arg1, arg2, checked)
	local options = GetActionBarOptions()

	options.autoHide = checked
	SetActionBarOptions(options)
end

function SetActionBarOrientation(orientation)
	local options = GetActionBarOptions()

	if options.orientation ~= orientation then
		options.orientation = orientation
		SetActionBarOptions(options)
		EasyRider:ShowActionBar()
	end
end

function SetActionBarAlignment(alignment)
	local options = GetActionBarOptions()

	if options.alignment ~= alignment then 
		options.alignment = alignment

		if alignment == ALIGNMENT_TOP or alignment == ALIGNMENT_BOTTOM then
			options.orientation = ORIENTATION_HORIZONTAL
		else
			options.orientation = ORIENTATION_VERTICAL
		end
		
		SetActionBarOptions(options)

		if alignment == ALIGNMENT_NONE  and not options.position then
			SaveActionBarPosition()
		else
			EasyRider:ShowActionBar()
		end
	end
end

function ShowActionButton(buttonCategory, show)
	local options = GetActionBarOptions()

	if show ~= options.visibleButtons[buttonCategory] then
		options.visibleButtons[buttonCategory] = show
		SetActionBarOptions(options)
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
	local options = GetActionBarOptions()
	local frame = EasyRider.actionBar

	if not options.locked then
		frame:StartMoving()
	end
end

function ButtonOnDragStop(button)
	local options = GetActionBarOptions()
	local frame = EasyRider.actionBar

	frame:StopMovingOrSizing()

	options.alignment = ALIGNMENT_NONE

	SetActionBarOptions(options)
	SaveActionBarPosition()
end

function SaveActionBarPosition()
	local options = GetActionBarOptions()
	local frame = EasyRider.actionBar

	options.position = {}
	options.position.X = frame:GetLeft()
	options.position.Y = frame:GetTop()

	SetActionBarOptions(options)
end

function EasyRiderDropDownMenu_Initialize(self, level)
	if not level then
		return
	end

	local options = GetActionBarOptions()
	local info = nil
	 
	if level == 1 then

		info = UIDropDownMenu_CreateInfo()
		info.hasArrow = false
		info.notCheckable = false
		info.text = L["Auto Hide"]
		info.checked = false
		info.checked = options.autoHide
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
			info.checked = options.orientation == ORIENTATION_HORIZONTAL
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarOrientation(ORIENTATION_HORIZONTAL) 
			end
			UIDropDownMenu_AddButton(info, level)
			
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Vertical"]
			info.checked = options.orientation == ORIENTATION_VERTICAL
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
			info.checked = options.alignment == ALIGNMENT_NONE
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_NONE) 
			end
			UIDropDownMenu_AddButton(info, level)
			
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Top"]
			info.checked = options.alignment == ALIGNMENT_TOP
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_TOP) 
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Bottom"]
			info.checked = options.alignment == ALIGNMENT_BOTTOM
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_BOTTOM) 
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Left"]
			info.checked = options.alignment == ALIGNMENT_LEFT
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_LEFT) 
			end
			UIDropDownMenu_AddButton(info, level)
			
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Right"]
			info.checked = options.alignment == ALIGNMENT_RIGHT
			info.func = function() 
				CloseDropDownMenus()
				SetActionBarAlignment(ALIGNMENT_RIGHT) 
			end
			UIDropDownMenu_AddButton(info, level)
		elseif UIDROPDOWNMENU_MENU_VALUE == "ShowButtonsMenu" then
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Ground Mount"]
			info.checked = options.visibleButtons[1]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(1, not options.visibleButtons[1])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Flying Mount"]
			info.checked = options.visibleButtons[2]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(2, not options.visibleButtons[2])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Surface Mount"]
			info.checked = options.visibleButtons[3]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(3, not options.visibleButtons[3])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Aquatic Mount"]
			info.checked = options.visibleButtons[4]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(4, not options.visibleButtons[4])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Passenger Mount"]
			info.checked = options.visibleButtons[5]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(5, not options.visibleButtons[5])
			end
			UIDropDownMenu_AddButton(info, level)

			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = false
			info.notCheckable = false
			info.text = L["Vendor Mount"]
			info.checked = options.visibleButtons[6]
			info.func = function() 
				CloseDropDownMenus()
				ShowActionButton(6, not options.visibleButtons[6])
			end
			UIDropDownMenu_AddButton(info, level)

		end
	end
end

function CreateActionBar()
	local frame = CreateFrame("Frame", "EasyRiderActionBar", UIParent)
	local options = GetActionBarOptions()
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

function GetActionBarOptions()
	local options = EasyRider.db.global.actionBar

	if not options then
		options =	{}
		options.alignment = ALIGNMENT_NONE
		options.orientation = ORIENTATION_HORIZONTAL
		options.autoHide = true
		options.locked = false
	end

	if not options.visibleButtons then
		options.visibleButtons = {}

		for index = 1, TOTAL_CATEGORIES do
			options.visibleButtons[index] = true
		end
	end

	return options
end

function SetActionBarOptions(options)
	EasyRider.db.global.actionBar = options
end
 
function EasyRider:ShowActionBar()
	local count = 0
	local frame = EasyRider.actionBar
	local options = GetActionBarOptions()

	frame:Hide()

	for index = 1, TOTAL_CATEGORIES do
		
		local button = EasyRider.buttons[index]
		local info = buttonInfo[index]

		if options.visibleButtons[index] then
		
			button:ClearAllPoints();

			if options.orientation == ORIENTATION_HORIZONTAL then
				button:SetPoint("LEFT", (6 + 40 * count), 0);
			else
				button:SetPoint("TOPLEFT", 0, (6 + 40 * count)* -1);
			end

			button:Show();
			count = count + 1;   
		else
			button:Hide()
		end
	end

	if options.orientation == ORIENTATION_HORIZONTAL then
		frame:SetWidth(10 + 40 * count);
		frame:SetHeight(40)
	else
		frame:SetHeight(10 + 40 * count);
		frame:SetWidth(40)
	end

	frame:ClearAllPoints()

	if options.alignment == ALIGNMENT_NONE then
		if options.position then
			if options.position.X and options.position.Y then
				frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", options.position.X, options.position.Y)
			else
				frame:SetPoint("BOTTOMLEFT", options.position.XPos, options.position.YPos)			
			end
		else
			frame:SetPoint("CENTER")
		end
	else
		frame:SetClampedToScreen(true)
		if options.alignment == ALIGNMENT_TOP then
			frame:SetPoint("TOP")
		elseif options.alignment == ALIGNMENT_BOTTOM  then 
			frame:SetPoint("BOTTOM")
		elseif options.alignment == ALIGNMENT_LEFT then
			frame:SetPoint("LEFT")
		else
			frame:SetPoint("RIGHT")
		end
	end

	if not options.hide then
		frame:Show()	
	end
end

local function HideActionBar()
	local frame = EasyRider.actionBar
	frame:Hide()
end

function UpdateActionBarState()
	local options = GetActionBarOptions()


	for index = 1, TOTAL_CATEGORIES do
		local button = EasyRider.buttons[index]

		if button then
			local icon = button.icon;
			local normalTexture = button.NormalTexture;

			if ButtonIsUsable(button) then
				icon:SetVertexColor(1.0, 1.0, 1.0);
				normalTexture:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
				normalTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
		end
	end	

	if not options.alwaysShow then
		if inVehicle or inPetBattle then
			HideActionBar()
		else
			EasyRider:ShowActionBar()
		end
	end
end

function EasyRider:ChatCommand(input)
	if not input or input:trim() == "" then 
		return
	end

	local options = GetActionBarOptions()
	local command = input:lower() or nil

	if command == L["reset"]:lower() then
		SetActionBarOptions(nil)
		EasyRider:ShowActionBar()
	elseif command == L["show"]:lower() then
		options.hide = false
		SetActionBarOptions(options)
		EasyRider:ShowActionBar()
	elseif command == L["hide"]:lower() then
		options.hide = true
		SetActionBarOptions(options)
		HideActionBar()
	elseif command == L["debug on"]:lower() then
		EasyRider.debug = true	
		EasyRider:Print("Debug turned on")
	elseif command == L["debug off"]:lower() then
		EasyRider.debug = false
		EasyRider:Print("Debug turned off")
	elseif command == "capture" then
		CaptureMounts()
	end
end

local function StartTimer()
	if EasyRider.debug then
		EasyRider:Print("Starting timer...")
	end
	EasyRider.timer = EasyRider:ScheduleRepeatingTimer(UpdateActionBarState, timerInterval)
end

local function StopTimer()
	if EasyRider.debug then
		EasyRider:Print("Stopping timer...")
	end
	if EasyRider.timer then
		EasyRider:CancelTimer(EasyRider.timer)
	end
	EasyRider.timer = nil
end

local function CacheUsableMounts()
	EasyRider:CacheUsableMounts()
end

local function DelayedCache()
	if EasyRider:TimeLeft(EasyRider.cacheTimer) == 0 then
		EasyRider.cacheTimer = EasyRider:ScheduleTimer(CacheUsableMounts, 3)
	end
end

function EasyRider:PET_BATTLE_OPENING_START()
	inPetBattle = true
	StopTimer()
	UpdateActionBarState()
end

function EasyRider:PET_BATTLE_CLOSE()
	inPetBattle = false
	UpdateActionBarState()
	StartTimer()
end

function EasyRider:PLAYER_REGEN_ENABLED()
	inCombat = false
	UpdateActionBarState()
	StartTimer()
end

function EasyRider:PLAYER_REGEN_DISABLED()
	inCombat = true
	StopTimer()
	UpdateActionBarState()
end

function EasyRider:UNIT_ENTERED_VEHICLE(event, arg1)
	if EasyRider.debug then
		EasyRider:Print("UNIT_ENTERED_VEHICLE event received for arg1: " .. arg1 or "")
	end

	if arg1 == "player" then
		inVehicle = true
		StopTimer()
		UpdateActionBarState()
	end
end

function EasyRider:UNIT_EXITED_VEHICLE(event, arg1)
	if EasyRider.debug then
		EasyRider:Print("UNIT_EXITED_VEHICLE event received for arg1: " .. arg1 or "")
	end
	
	if arg1 == "player" then
		inVehicle = false
		UpdateActionBarState()
		StartTimer()
	end
end

function EasyRider:ZONE_CHANGED()
	if EasyRider.debug then
		EasyRider:Print("ZONE_CHANGED evevt received")
	end
end

function EasyRider:ZONE_CHANGED_INDOORS()
	if EasyRider.debug then
		EasyRider:Print("ZONE_CHANGED_INDOORS evevt received")
	end
end

function EasyRider:ZONE_CHANGED_NEW_AREA()
	if EasyRider.debug then
		EasyRider:Print("ZONE_CHANGED_NEW_AREA evevt received")
	end

	DelayedCache()
end

function EasyRider:PLAYER_ENTERING_WORLD()
	if EasyRider.debug then
		EasyRider:Print("PLAYER_ENTERING_WORLD evevt received")
	end

	DelayedCache()
end

function EasyRider:PLAYER_LEVEL_UP()
	if EasyRider.debug then
		EasyRider:Print("PLAYER_LEVEL_UP evevt received")
	end

	DelayedCache()
end

function EasyRider:OnInitialize()	
	self.db = LibStub("AceDB-3.0"):New("EasyRiderDB", nil)
	self:RegisterChatCommand("easyrider", "ChatCommand")
	--EasyRider.debug = true
	CreateActionBar()	
end

function EasyRider:OnEnable()	
	EasyRider:RegisterEvent("PET_BATTLE_OPENING_START")
	EasyRider:RegisterEvent("PET_BATTLE_CLOSE")
	EasyRider:RegisterEvent("PLAYER_REGEN_ENABLED")
	EasyRider:RegisterEvent("PLAYER_REGEN_DISABLED")
	EasyRider:RegisterEvent("UNIT_ENTERED_VEHICLE")
	EasyRider:RegisterEvent("UNIT_EXITED_VEHICLE")
	--EasyRider:RegisterEvent("ZONE_CHANGED")
	--EasyRider:RegisterEvent("ZONE_CHANGED_INDOORS")
	EasyRider:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	EasyRider:RegisterEvent("PLAYER_ENTERING_WORLD")
	EasyRider:RegisterEvent("PLAYER_LEVEL_UP")
	EasyRider:ShowActionBar()
	UpdateActionBarState()
	StartTimer()	
end

function EasyRider:OnDisable()
	StopTimer()
	EasyRider:UnregisterEvent("PET_BATTLE_OPENING_START")
	EasyRider:UnregisterEvent("PET_BATTLE_CLOSE")
	EasyRider:UnregisterEvent("PLAYER_REGEN_ENABLED")
	EasyRider:UnregisterEvent("PLAYER_REGEN_DISABLED")
	EasyRider:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	EasyRider:UnregisterEvent("UNIT_EXITED_VEHICLE")
	--EasyRider:UnregisterEvent("ZONE_CHANGED")
	--EasyRider:UnregisterEvent("ZONE_CHANGED_INDOORS")
	EasyRider:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	EasyRider:UnregisterEvent("PLAYER_ENTERING_WORLD")
	EasyRider:UnregisterEvent("PLAYER_LEVEL_UP")
end