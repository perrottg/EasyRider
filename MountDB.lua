
--local mountTypes = EasyRider:MountTypes
local mountTypes = {
	GROUND = 1,
	FLY = 2,
	WATERWALKING = 3,
	AQUATIC = 4,
	PASSENGER = 5,
	VENDOR = 6,	
	LOW = 7
}

local factions = {
	HORDE = 0,
	ALLIANCE = 1,
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
	STRIDER = 11
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
	[373] = {									-- Vashj'ir Seahorse
		spellID = 75207,
		requirements = {
			characterLevel = 80,
			ridingSkill = 225,
			zone = "Vashj'ir"
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

function EasyRider:IsMountType(mountID, mountType)
	local mount = mountDB[mountID]

	if mountType == mountTypes.GROUND then
		return mount and mount.travelModes.ground
	elseif mountType == mountTypes.FLY then
		return mount and mount.travelModes.flying
	elseif mountType == mountTypes.WATERWALKING then
		return mount and mount.travelModes.waterWalking
	elseif mountType == mountTypes.AQUATIC then
		return mount and mount.travelModes.swimming
	elseif mountType == mountTypes.PASSENGER then
		return mount and mount.passengers and mount.passengers > 0
	elseif mountType == mountTypes.VENDOR then
		return mount and mount.vendors
	elseif mountType == mountTypes.LOW then
		return mount and ((not mount.requirements) or (not mount.requirements.characterLevel) or (mount.requirements.characterLevel == 1))
	else 
		return false
	end

end