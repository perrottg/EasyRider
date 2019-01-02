local usableMountCache = {}

local categories = {
	GROUND = 1,
	FLYING = 2,
	WATERWALKING = 3,
	AQUATIC = 4,
	PASSENGER = 5,
	VENDOR = 6
}

local factions = {
	HORDE = "Horde",
	ALLIANCE = "Alliance",
}

local families = {
	MAMMOTH = 1,
	YAK = 2,
	MECHANICAL = 3,
	BRUTOSAUR = 4,
	DRAGON = 5,
	SQUID = 6,
	FISH = 7,
	RAY = 8,
	TURTLE = 9,
	SEAHORSE = 10,
	STRIDER = 11,
	ELK = 12,
	RAM = 13
}

local patch = {
	VANILLA = 0,
	BURNINGCRUSADE = 1,
	WRATHOFTHELICHKING = 2,
	CATACLYSM = 3,
	MISTSOFPANDERIA = 4,
	WARLORDSOFDRAENOR = 5,
	LEGION = 6,
	BATTLEFORAZEROTH = 7
}

local classes = {
	PALADIN = "Paladin"
}

local zones = {
	ABYSSALDEPTHS = "Abyssal Depths",
	KELPTHARFOREST = "Kelp'thar Forest",
	SHIMMERINGEXPANSE = "Shimmering Expanse"
}


local mountDB = {	
	[125] = {									-- Riding Turtle
		spellID = 30174,
		requirements = {
			characterLevel = 1
		},
		family = families.TURTLE,
		introduced = patch.VANILLA,
		travelModes = {
			ground = true,
			swimming = true
		}
	},	
	[240] = {									-- Mechano-hog
		spellID = 55531,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.HORDE
		},
		family = families.MECHANICAL,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		passengers = 1
	},
	[275] = {									-- Mekgineer's Chopper
		spellID = 60424,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.ALLIANCE
		},
		family = families.MECHANICAL,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		passengers = 1
	},
	[280] = {									-- Traveler's Tundra Mammoth (alliance)
		spellID = 61425,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.ALLIANCE
		},
		family = families.MAMMOTH,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		vendors = {
			repair = true,
			reagents = true
		},
		passengers = 2
	},
	[284] = {									-- Traveler's Tundra Mammoth (horde)
		spellID = 61447,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.HORDE
		},
		family = families.MAMMOTH,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		vendors = {
			repair = true,
			reagents = true
		},
		passengers = 2
	},
	[286] = {									-- Grand Black War Mammoth (horde)
		spellID = 61465,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.HORDE
		},
		family = families.MAMMOTH,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		passengers = 2
	},
	[287] = {									-- Grand Black War Mammoth (alliance)
		spellID = 61467,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.ALLIANCE
		},
		family = families.MAMMOTH,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		passengers = 2
	},
	[288] = {									-- Grand Ice Mammoth (horde)
		spellID = 61469,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.HORDE
		},
		family = families.MAMMOTH,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		passengers = 2
	},
	[289] = {									-- Grand Ice Mammoth (alliance)
		spellID = 61470,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150,
			faction = factions.ALLIANCE
		},
		family = factions.MAMMOTH,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true
		},
		passengers = 2
	},
	[312] = {									-- Sea Turtle
		spellID = 64731,
		requirements = {
			characterLevel = 1
		},
		family = families.TURTLE,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true,
			swimming = true
		}
	},
	[367] = {									-- Exarch's Elekk
		spellID = 73629,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75,
			faction = factions.ALLIANCE,
			class = classes.PALADIN
		},
		family = families.ELK,
		introduced = patch.CATACLYSM,
		travelModes = {
			ground = true
		}
	},
	[373] = {									-- Vashj'ir Seahorse
		spellID = 75207,
		requirements = {
			characterLevel = 80,
			ridingSkill = 225,
			zones = { zones.ABYSSALDEPTHS, zones.KELPTHARFOREST, zones.SHIMMERINGEXPANSE }
		},
		family = families.SEAHORSE,
		introduced = patch.CATACLYSM,
		travelModes = {
			swimming = true
		}
	},
	[382] = {									-- X-53 Touring Rocket
		spellID = 75973,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75
		},
		family = factions.MECHANICAL,
		introduced = patch.WRATHOFTHELICHKING,
		travelModes = {
			ground = true,
			flying = true
		},
		transform = true,
		passengers = 1
	},
	[407] = {									-- Sandstone Drake
		spellID = 93326,
		requirements = {
			characterLevel = 80,
			ridingSkill = 225
		},
		family = factions.DRAGON,
		introduced = patch.CATACLYSM,
		travelModes = {
			ground = true,
			flying = true
		},
		transform = true,
		passengers = 1
	},
	[420] = {									-- Subdued Seahorse
		spellID = 98718,
		requirements = {
			characterLevel = 78,
			ridingSkill = 225
		},
		family = factions.SEAHORSE,
		introduced = patch.CATACLYSM,
		travelModes = {
			swimming= true
		}
	},
	[449] = {									-- Azure Water Strider 
		spellID = 118089,
		requirements = {
			characterLevel = 90,
			ridingSkill = 300
		},
		family = factions.STRIDER,
		introduced = patch.MISTSOFPANDERIA,
		travelModes = {
			ground = true,
			waterWalking = true
		}
	},
	[455] = {									-- Obsidian Nightwing
		spellID = 121820,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75
		},
		family = factions.DRAGON,
		introduced = patch.CATACLYSM,
		travelModes = {
			ground = true,
			flying = true
		},
		transform = true,
		passengers = 1
	},
	[460] = {									-- Grand Expedition Yak
		spellID = 122708,								
		requirements = {
			characterLevel = 85,
			ridingSkill = 150
		},
		family = families.YAK,
		introduced = patch.MISTSOFPANDERIA,
		travelModes = {
			ground = true
		},
		vendors = {
			repair = true,
			reagents = true,
			transmog = true
		},
		passengers = 2
	},
	[488] = {									-- Crimson Water Strider 
		spellID = 127271,
		requirements = {
			characterLevel = 90,
			ridingSkill = 300
		},
		family = factions.STRIDER,
		introduced = patch.MISTSOFPANDERIA,
		travelModes = {
			ground = true,
			waterWalking = true
		}
	},
	[678] = {									-- Chauffeured Mechano-Hog
		spellID = 179244,
		requirements = {
			characterLevel = 1,
			faction = factions.HORDE
		},
		family = factions.MECHANICAL,
		introduced = patch.WARLORDSOFDRAENOR,
		travelModes = {
			ground = true
		}
	},
	[679] = {									-- Chauffeured Mekgineer's Chopper
		spellID = 179245,
		requirements = {
			characterLevel = 1,
			faction = factions.ALLIANCE
		},
		family = factions.MECHANICAL,
		introduced = patch.WARLORDSOFDRAENOR,
		travelModes = {
			ground = true
		}
	},
	[800] = {									-- Brinedeep Bottom-Feeder
		spellID = 214791,
		requirements = {
			characterLevel = 90,
			ridingSkill = 150
		},
		family = families.FISH,
		introduced = patch.LEGION,
		travelModes = {
			swimming = true
		}
	},
	[838] = {									-- Fathom Dweller
		spellID = 223018,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75
		},
		family = families.SQUID,
		introduced = patch.LEGION,
		travelModes = {
			swimming = true
		}
	},
	[855] = {									-- Darkwater Skate
		spellID = 228919,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150
		},
		family = families.RAY,
		introduced = patch.LEGION,
		travelModes = {
			swimming = true
		}
	},
	[959] = {									-- Stormwind Skychaser (alliance)
		spellID = 245723,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75,
			faction = factions.ALLIANCE
		},
		family = factions.MECHANICAL,
		introduced = patch.LEGION,
		travelModes = {
			ground = true,
			flying = true
		},
		passengers = 1
	},
	[960] = {									-- Orgrimmar Interceptor (horde)
		spellID = 245725,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75,
			faction = factions.HORDE
		},
		family = factions.MECHANICAL,
		introduced = patch.LEGION,
		travelModes = {
			ground = true,
			flying = true
		},
		passengers = 1
	},
	[982] = {									-- Pond Nettle
		spellID = 253711,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75
		},
		family = families.SQUID,
		introduced = patch.LEGION,
		travelModes = {
			swimming= true
		}
	},
	[1025] = {									-- The Hivemind
		spellID = 2261395,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75
		},
		family = families.SQUID,
		introduced = patch.BATTLEFORAZEROTH,
		travelModes = {
			ground = true,
			flying = true
		},
		passengers = 4
	},
	[1039] = {									-- Mighty Caravan Brutosaur
		spellID = 264058,
		requirements = {
			characterLevel = 110,
			ridingSkill = 150
		},
		family = families.BRUTOSAUR,
		introduced = patch.BATTLEFORAZEROTH,
		travelModes = {
			ground = true
		},
		vendors = {
			repair = true,
			reagents = true,
			auctioneer = true
		},
		passengers = 2
	},
	[1046] = {									-- Darkforge Ram"
		spellID = 270562,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75,
			faction = factions.ALLIANCE,
			class = classes.PALADIN
		},
		family = families.RAM,
		introduced = patch.BATTLEFORAZEROTH,
		travelModes = {
			ground = true
		}
	},
	[1166] = {									-- Great Sea Ray
		spellID = 278803,
		requirements = {
			characterLevel = 40,
			ridingSkill = 150
		},
		family = families.RAY,
		introduced = patch.BATTLEFORAZEROTH,
		travelModes = {
			swimming = true
		}
	},
	[1169] = {									-- Surf Jelly
		spellID = 278979,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75
		},
		family = families.SQUID,
		introduced = patch.BATTLEFORAZEROTH,
		travelModes = {
			swimming = true
		}
	},
	[1208] = {									-- Saltwater Seahorse
		spellID = 288711,
		requirements = {
			characterLevel = 20,
			ridingSkill = 75
		},
		family = families.SEAHORSE,
		introduced = patch.BATTLEFORAZEROTH,
		travelModes = {
			swimming = true
		}
	},
}

local function GetPlayerRidingSkill()
	local skillLevel = 0
	local spellMap = { [33388] = 75, [33391] = 150, [34090] = 225, [34091] = 300, [90265] = 375 }
	local _, _, _, numberSpells = GetSpellTabInfo(1)
	for i = 1, numberSpells, 1 do
		local spellType, spellID = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
		if spellType == "SPELL" and spellMap[spellID] and spellMap[spellID] > skillLevel then
			skillLevel = spellMap[spellID]			
		end
	end

	return skillLevel
end


local function PlayerCanUseMount(mountID)
	local mount = mountDB[mountID]
	local isUsable = false
	
	if mount and mount.requirements then
		isUsable = true
		if mount.requirements.faction then
			local playerFaction = UnitFactionGroup("player");

			isUsable = isUsable and mount.requirements.faction == playerFaction

			if EasyRider.debug then
				if isUsable then
					EasyRider:Print("PASSED Faction Check!")
				else
					EasyRider:Print("FAILED Faction Check!")
				end
			end
		end
		if mount.requirements.class then
			local _, playerClass = UnitClass("unit");

			isUsable = isUsable and mount.requirements.class == playerClass

			if EasyRider.debug then
				if isUsable then
					EasyRider:Print("PASSED Class Check!")
				else
					EasyRider:Print("FAILED Class Check!")
				end
			end			
		end
		if mount.requirements.characterLevel then
			local playerLevel = UnitLevel("player");

			isUsable = isUsable and mount.requirements.characterLevel <= playerLevel
		end		
		if mount.requirements.ridingSkill then
			local playerRidingSkill = GetPlayerRidingSkill()

			isUsable = isUsable and mount.requirements.ridingSkill <= playerRidingSkill
		end
		if mount.requirements.zones then
			local currentZone = GetZoneText()
			local inRequiredZone = false

			for i,zone in ipairs(mount.requirements.zones) do
				if zone == currentZone then
					inRequiredZone = true
				end
			end

			isUsable = isUsable and inRequiredZone
		end		
	end

	return isUsable
end

local function GetMountCategory(mountID, mountType)
	local mount = mountDB[mountID]

	if mount then
		if mount.vendors then
			return categories.VENDOR
		elseif mount.passengers then
			return categories.PASSENGER
		elseif mount.travelModes.swimming then
			return categories.AQUATIC
		elseif mount.travelModes.waterWalking then
			return categories.WATERWALKING
		elseif mount.travelModes.flying then
			return categories.FLYING
		elseif mount.travelModes.ground then
			return categories.GROUND
		else 
			return false
		end
	else
		if mountType == 284 or mountType == 241 or mountType == 230 then
			return categories.GROUND
		elseif mountType == 269 then
			return categories.WATERWALKING
		elseif mountType == 254 or mountType == 232 or mountType == 231 then
			return categories.AQUATIC
		elseif mountType == 248 or mountTypes == 247 or mountType == 242 then
			return categories.FLYING
		else
			return false
		end
	end
end

function EasyRider:CacheUsableMounts()
	local playerFaction = UnitFactionGroup("player");
	local localizedClass, englishClass, classIndex = UnitClass("unit");
	local mountIDs = C_MountJournal.GetMountIDs();
	local totalMounts = 0
	local cachedMounts = 0

	if EasyRider.debug then
		EasyRider:Print("Caching mounts.... ")
	end

	usableMountCache = {}
	usableMountCache.allMounts = {}
	usableMountCache.categoryIndex = {}

	for category = categories.GROUND, categories.VENDOR do
		local index = tostring(category)
		local count = 0
	
		usableMountCache.categoryIndex[tostring(category)] = {}
		usableMountCache.categoryIndex[tostring(category)][tostring(false)] = {}
		usableMountCache.categoryIndex[tostring(category)][tostring(true)] = {}
	end
	
	for key, mountID in pairs(mountIDs) do
		local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
		local creatureDislayID, description, source, isSelfMount, mountType, uiModelScene = C_MountJournal.GetMountInfoExtraByID(mountID)
		local index = tostring(spellID)
		local category = GetMountCategory(mountID, mountType)

		if isCollected and not hideOnChar then 
			if ( category == categories.AQUATIC and PlayerCanUseMount(mountID) ) or isUsable then
				local mount = {}
				
				mount.name = name
				mount.spellID = spellID
				mount.mountID = mountID
				mount.icon = icon
				mount.mountType = mountType
				mount.isFavorite = isFavorite
				mount.isSelfMount = isSelfMount

				usableMountCache.allMounts[index] = mount

				if category then
					local count = #usableMountCache.categoryIndex[tostring(category)][tostring(false)]

					usableMountCache.categoryIndex[tostring(category)][tostring(false)][count+1] = index
					if mount.isFavorite then
						count = #usableMountCache.categoryIndex[tostring(category)][tostring(true)]
						usableMountCache.categoryIndex[tostring(category)][tostring(true)][count+1] = index
					end
				end
	
				cachedMounts = cachedMounts + 1
			end
		end
		totalMounts = totalMounts + 1	
	end

	if EasyRider.debug then
		EasyRider:Print(string.format("Cached %i of %i total  mounts.", cachedMounts, totalMounts))
	end
end

function EasyRider:GetRandomMount(category, isFavorite)
	if EasyRider.debug then
		EasyRider:Print("Geting mount for category: "..category)
	end

	if not isFavorite then
		isFavorite = false
	end

	if not usableMountCache.categoryIndex[tostring(category)] or #usableMountCache.categoryIndex[tostring(category)][tostring(isFavorite)] == 0 then
		return nil
	end

	local count = #usableMountCache.categoryIndex[tostring(category)][tostring(isFavorite)]	
	local index = fastrandom(1, count)
	local spellID = usableMountCache.categoryIndex[tostring(category)][tostring(isFavorite)][index]

	if EasyRider.debug then
		EasyRider:Print("Found "..count.." mounts. Selected no. "..index.." with spell ID: "..spellID)
	end

	return usableMountCache.allMounts[spellID] 
end

function EasyRider:GetMountBySpellID(spellID)
	local mount = usableMountCache.allMounts[tostring(spellID)]

	return mount
end

function EasyRider:GetUsableMountTotal(category)
	local mountTotal = 0

	if usableMountCache and usableMountCache.categoryIndex and usableMountCache.categoryIndex[tostring(category)] and usableMountCache.categoryIndex[tostring(category)][tostring(false)] then
		mountTotal =  #usableMountCache.categoryIndex[tostring(category)][tostring(false)]
	end

	return mountTotal
end