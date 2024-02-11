/**
 * Smithing Molds
 */

/datum/crafting_recipe/mold //This null crafting recipe solely exists to inherit its traits to child recipes.
	name = "DEBUG Mold"
	time = 30
	reqs = list(/datum/reagent/water = 20,
				/obj/item/stack/material/sandstone = 2,
				/obj/item/stack/ore/slag = 1)
	tools = list(/obj/structure/ashlander/production/brickmaker)
	category = CAT_PRIMAL
	subcategory = CAT_SMITHING
	always_available = FALSE

/datum/crafting_recipe/mold/blunder
	name = "Blunderbuss Mold"
	result = /obj/item/smithing/mold/blunder

/datum/crafting_recipe/mold/mechanism
	name = "Mechanisms Mold"
	result = /obj/item/smithing/mold/mechanisms

/datum/crafting_recipe/mold/arrow
	name = "Arrow Mold"
	result = /obj/item/smithing/mold/arrow

/datum/crafting_recipe/mold/gunbarrel
	name = "Gunbarrel Mold"
	result = /obj/item/smithing/mold/gunbarrel

/datum/crafting_recipe/mold/pick
	name = "Pick Mold"
	result = /obj/item/smithing/mold/pick

/datum/crafting_recipe/mold/khopesh
	name = "Khopesh Mold"
	result = /obj/item/smithing/mold/khopesh

/datum/crafting_recipe/mold/hatchet
	name = "Hatchet Mold"
	result = /obj/item/smithing/mold/hatchet

/datum/crafting_recipe/mold/spear
	name = "Spearhead Mold"
	result = /obj/item/smithing/mold/spear

/**
 * Smithing Parts
 */


/datum/crafting_recipe/part //This null crafting recipe solely exists to inherit its traits to child recipes.
	name = "DEBUG Part"
	time = 60
	reqs = list(/obj/item/stack/material/copper = 10,
				/obj/item/smithing/mold = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	category = CAT_PRIMAL
	subcategory = CAT_SMITHING
	always_available = FALSE

/datum/crafting_recipe/part/blunder
	name = "Blunderbuss Barrel"
	reqs = list(/obj/item/stack/material/copper = 15,
				/obj/item/smithing/mold/blunder = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/blunder

/datum/crafting_recipe/part/gunbarrel
	name = "Bronze Gunbarrel"
	reqs = list(/obj/item/stack/material/copper = 12,
				/obj/item/smithing/mold/gunbarrel = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/gunbarrel

/datum/crafting_recipe/part/mechanisms
	name = "Bronze Mechanisms"
	reqs = list(/obj/item/stack/material/copper = 3,
				/obj/item/smithing/mold/gunbarrel = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/mechanisms

/datum/crafting_recipe/part/arrow
	name = "Bronze Arrowheads"
	reqs = list(/obj/item/stack/material/copper = 4,
				/obj/item/smithing/mold/arrow = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/arrow

/datum/crafting_recipe/part/pick
	name = "Bronze Pickaxe Head"
	reqs = list(/obj/item/stack/material/copper = 6,
				/obj/item/smithing/mold/pick = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/pick

/datum/crafting_recipe/part/khopesh
	name = "Bronze Khopesh Blade"
	reqs = list(/obj/item/stack/material/copper = 8,
				/obj/item/smithing/mold/khopesh = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/khopesh

/datum/crafting_recipe/part/hatchet
	name = "Bronze Hatchet Head"
	reqs = list(/obj/item/stack/material/copper = 8,
				/obj/item/smithing/mold/hatchet = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/hatchet

/datum/crafting_recipe/part/spear
	name = "Bronze Spearhead"
	reqs = list(/obj/item/stack/material/copper = 4,
				/obj/item/smithing/mold/spear = 1)
	tools = list(/obj/structure/ashlander/production/forge)
	result = /obj/item/smithing/part/spear

/**
 * Smithing Coins
 */

/datum/crafting_recipe/leadcoin
	name = "Mint Lead Coin"
	reqs = list(/obj/item/stack/material/lead = 2)
	tools = list(/obj/structure/ashlander/production/forge,
				TOOL_COINING)
	result = /obj/item/coin/sclead

/datum/crafting_recipe/coppercoin
	name = "Mint Copper Coin"
	reqs = list(/obj/item/stack/material/copper = 1)
	tools = list(/obj/structure/ashlander/production/forge,
				TOOL_COINING)
	result = /obj/item/coin/sccopper

/datum/crafting_recipe/bronzecoin
	name = "Mint Bronze Coin"
	reqs = list(/obj/item/stack/material/copper = 5,
				/obj/item/stack/ore/slag = 2)
	tools = list(/obj/structure/ashlander/production/forge,
				TOOL_COINING)
	result = /obj/item/coin/scbronze
