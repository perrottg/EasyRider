
--local mountTypes = EasyRider:MountTypes
local mountTypes = {
	GROUND = 1,
	FLY = 2,
	SURFACE = 3,
	AQUATIC = 4,
	PASSENGER = 5,
	VENDOR = 6,	
}

local mountDB = {	
	[30174] = {									-- Riding Turtle
		[mountTypes.AQUATIC] = true,
	},	
	[55531] = {									-- Mechano-hog
		[mountTypes.PASSENGER] = true,
	},
	[60424] = {									-- Mekgineer's Chopper
		[mountTypes.PASSENGER] = true,
	},
	[61425] = {									-- Traveler's Tundra Mammoth (alliance)
		[mountTypes.PASSENGER] = true,
		[mountTypes.VENDOR] = true,
	},
	[61447] = {									-- Traveler's Tundra Mammoth (horde)
		[mountTypes.PASSENGER] = true,
		[mountTypes.VENDOR] = true,
	},
	[61465] = {									-- Grand Black War Mammoth (alliance)
		[mountTypes.PASSENGER] = true,
	},
	[61467] = {									-- Grand Black War Mammoth (horde)
		[mountTypes.PASSENGER] = true,
	},
	[61469] = {									-- Grand Ice Mammoth (horde)
		[mountTypes.PASSENGER] = true,
	},
	[61470] = {									-- Grand Ice Mammoth (alliance)
		[mountTypes.PASSENGER] = true,
	},
	[64731] = {									-- Sea Turtle
		[mountTypes.AQUATIC] = true,
	},
	[75207] = {									-- Vashj'ir Seahorse
		[mountTypes.AQUATIC] = true,
	},
	[75973] = {									-- X-53 Touring Rocket
		[mountTypes.PASSENGER] = true,
	},
	[93326] = {									-- Sandstone Drake
		[mountTypes.PASSENGER] = true,
	},
	[98718] = {									-- Subdued Seahorse
		[mountTypes.AQUATIC] = true,
	},
	[118089] = {								-- Azure Water Strider 
		[mountTypes.SURFACE] = true,
	},
	[121820] = {								-- Obsidian Nightwing
		[mountTypes.PASSENGER] = true,
	},
	[127271] = {								-- Crimson Water Strider 
		[mountTypes.SURFACE] = true,
	},	
	[214791] = {								-- Brinedeep Bottom-Feeder
		[mountTypes.AQUATIC] = true,
	},
	[223018] = {								-- Fathom Dweller
		[mountTypes.AQUATIC] = true,
	},
	[228919] = {								-- Darkwater Skate
		[mountTypes.AQUATIC] = true,
	},
}

function EasyRider:IsMountType(spellID, mountType)
	return mountDB[spellID] and mountDB[spellID][mountType] 
end