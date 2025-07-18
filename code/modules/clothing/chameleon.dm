//*****************
//**Cham Jumpsuit**
//*****************

/obj/item/proc/disguise(var/newtype, var/mob/user)
	if(isnull(newtype))
		disguise_blank()
		return
	//this is necessary, unfortunately, as initial() does not play well with list vars
	var/obj/item/copy = new newtype(null) //so that it is GCed once we exit
	desc = copy.desc
	name = copy.name
	icon = copy.icon
	icon_override = copy.icon_override
	default_worn_icon = copy.default_worn_icon
	icon_state = copy.icon_state
	worn_render_flags = copy.worn_render_flags
	item_icons = copy.item_icons
	sprite_sheets = copy.sprite_sheets

	var/obj/item/clothing/under/uniform_copy = copy
	if(istype(uniform_copy))
		var/obj/item/clothing/under/uniform_self = src
		uniform_self.snowflake_worn_state = uniform_copy.snowflake_worn_state

	color = copy.color
	item_state = copy.item_state
	set_body_cover_flags(copy.body_cover_flags)
	inv_hide_flags = copy.inv_hide_flags
	gender = copy.gender

	if(copy.item_icons)
		item_icons = copy.item_icons.Copy()
	if(copy.item_state_slots)
		item_state_slots = copy.item_state_slots.Copy()
	if(copy.sprite_sheets)
		sprite_sheets = copy.sprite_sheets.Copy()

	OnDisguise(copy, user)
	qdel(copy)

	return copy

/obj/item/proc/disguise_blank()
	desc = ""
	name = "nothing"
	icon = null
	icon_override = null
	default_worn_icon = null
	icon_state = null
	worn_render_flags = null
	color = null
	item_state = null
	inv_hide_flags = null
	item_icons = null
	item_state_slots = null
	sprite_sheets = null

// Subtypes shall override this, not /disguise()
/obj/item/proc/OnDisguise(var/obj/item/copy, var/mob/user)
	return
	//copying sprite_sheets_obj should be unnecessary as chameleon items are not refittable.


/proc/generate_chameleon_choices(var/basetype, var/blacklist = list())
	. = list()
	var/i = 0 // in case there's a collision with both name/icon_state
	var/list/icon_state_cache = list()
	for(var/path in typesof(basetype) - blacklist)
		i = 0
		var/obj/item/clothing/C = path
		var/icon = initial(C.icon)
		var/icon_state = initial(C.icon_state)
		if(!icon || !icon_state)
			continue
		if(!icon_state_cache[icon])
			icon_state_cache[icon] = icon_states(icon)
		if(!(icon_state in icon_state_cache[icon]))      // state doesn't exist, do not let user pick
			continue
		var/name = initial(C.name)
		if(name in .)
			name += " ([icon_state])"
		if(name in .)    // STILL?
			name += " \[[++i]\]"
		.[name] = path
 	tim_sort(., GLOBAL_PROC_REF(cmp_text_asc))

 	. = list("None") + .

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon = 'icons/clothing/uniform/workwear/basic_colored_jumpsuit.dmi'
	icon_state = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon = 'icons/clothing/uniform/casual/psyche.dmi'
	icon_state = "psyche"
	update_icon()
	update_worn_icon()

/obj/item/clothing/under/chameleon/verb/change(picked in GLOB.clothing_under)
	set name = "Change Jumpsuit Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_under[picked]))
		return

	disguise(GLOB.clothing_under[picked])
	update_worn_icon()	//so our overlays update.

/obj/item/clothing/under/chameleon/holosphere
	name = "holographic jumpsuit"
	desc = "A holographic jumpsuit."
	clothing_flags = NO_UNEQUIP
	origin_tech = list()

/obj/item/clothing/under/chameleon/holosphere/emp_act(severity)
	return ..()

//*****************
//**Chameleon Hat**
//*****************

/obj/item/clothing/head/chameleon
	name = "grey cap"
	icon_state = "greysoft"
	desc = "It looks like a plain hat, but upon closer inspection, there's an advanced holographic array installed inside. It seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)
	body_cover_flags = 0

/obj/item/clothing/head/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	update_icon()
	update_worn_icon()

/obj/item/clothing/head/chameleon/verb/change(picked in GLOB.clothing_head)
	set name = "Change Hat/Helmet Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_head[picked]))
		return

	disguise(GLOB.clothing_head[picked])
	update_worn_icon()	//so our overlays update.

/obj/item/clothing/head/chameleon/holosphere
	name = "holographic hat"
	desc = "A holographic hat."
	clothing_flags = NO_UNEQUIP
	origin_tech = list()

/obj/item/clothing/head/chameleon/holosphere/emp_act(severity)
	return ..()

//******************
//**Chameleon Suit**
//******************

/obj/item/clothing/suit/chameleon
	name = "armor"
	icon_state = "armor"
	desc = "It appears to be a vest of standard armor, except this is embedded with a hidden holographic cloaker, allowing it to change it's appearance, but offering no protection.. It seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/clothing/suit/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	update_icon()
	update_worn_icon()

/obj/item/clothing/suit/chameleon/verb/change(picked in GLOB.clothing_suit)
	set name = "Change Oversuit Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_suit[picked]))
		return

	disguise(GLOB.clothing_suit[picked])
	update_worn_icon()	//so our overlays update.

/obj/item/clothing/suit/chameleon/holosphere
	name = "holographic suit"
	desc = "A holographic suit."
	clothing_flags = NO_UNEQUIP
	origin_tech = list()

/obj/item/clothing/suit/chameleon/holosphere/emp_act(severity)
	return ..()

//*******************
//**Chameleon Shoes**
//*******************
/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	desc = "They're comfy black shoes, with clever cloaking technology built in. It seems to have a small dial on the back of each shoe."
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/clothing/shoes/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "black shoes"
	desc = "A pair of black shoes."
	icon_state = "black"
	update_icon()
	update_worn_icon()

/obj/item/clothing/shoes/chameleon/verb/change(picked in GLOB.clothing_shoes)
	set name = "Change Footwear Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_shoes[picked]))
		return

	disguise(GLOB.clothing_shoes[picked])
	update_worn_icon()	//so our overlays update.

/obj/item/clothing/shoes/chameleon/holosphere
	name = "holographic shoes"
	desc = "A holographic shoes."
	clothing_flags = NO_UNEQUIP
	origin_tech = list()

/obj/item/clothing/shoes/chameleon/holosphere/emp_act(severity)
	return ..()

//**********************
//**Chameleon Backpack**
//**********************
/obj/item/storage/backpack/chameleon
	name = "backpack"
	icon_state = "backpack"
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/storage/backpack/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	update_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_back()

/obj/item/storage/backpack/chameleon/verb/change(picked in GLOB.clothing_backpack)
	set name = "Change Backpack Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_backpack[picked]))
		return

	disguise(GLOB.clothing_backpack[picked])

	//so our overlays update.
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_back()

//********************
//**Chameleon Gloves**
//********************

/obj/item/clothing/gloves/chameleon
	name = "black gloves"
	icon_state = "black"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/clothing/gloves/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "black gloves"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	icon_state = "black"
	update_icon()
	update_worn_icon()

/obj/item/clothing/gloves/chameleon/verb/change(picked in GLOB.clothing_gloves)
	set name = "Change Gloves Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_gloves[picked]))
		return

	disguise(GLOB.clothing_gloves[picked])
	update_worn_icon()	//so our overlays update.

/obj/item/clothing/gloves/chameleon/holosphere
	name = "holographic gloves"
	desc = "A holographic gloves."
	clothing_flags = NO_UNEQUIP
	origin_tech = list()

/obj/item/clothing/gloves/chameleon/holosphere/emp_act(severity)
	return ..()

//******************
//**Chameleon Mask**
//******************

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	icon_state = "gas_alt"
	desc = "It looks like a plain gask mask, but on closer inspection, it seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/clothing/mask/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "gas mask"
	desc = "It's a gas mask."
	icon_state = "gas_alt"
	update_icon()
	update_worn_icon()

/obj/item/clothing/mask/chameleon/verb/change(picked in GLOB.clothing_mask)
	set name = "Change Mask Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_mask[picked]))
		return

	disguise(GLOB.clothing_mask[picked])
	update_worn_icon()	//so our overlays update.

/obj/item/clothing/mask/chameleon/holosphere
	name = "holographic mask"
	desc = "A holographic mask."
	clothing_flags = NO_UNEQUIP
	origin_tech = list()

/obj/item/clothing/mask/chameleon/holosphere/emp_act(severity)
	return ..()

//*********************
//**Chameleon Glasses**
//*********************

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	icon_state = "meson"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "meson", SLOT_ID_LEFT_HAND = "meson")
	desc = "It looks like a plain set of mesons, but on closer inspection, it seems to have a small dial inside."
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/clothing/glasses/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "Optical Meson Scanner"
	desc = "It's a set of mesons."
	icon_state = "meson"
	update_icon()
	update_worn_icon()

/obj/item/clothing/glasses/chameleon/verb/change(picked in GLOB.clothing_glasses)
	set name = "Change Glasses Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_glasses[picked]))
		return

	disguise(GLOB.clothing_glasses[picked])
	update_worn_icon()	//so our overlays update.

/obj/item/clothing/glasses/chameleon/holosphere
	name = "holographic glasses"
	desc = "A holographic glasses."
	clothing_flags = NO_UNEQUIP
	origin_tech = list()

/obj/item/clothing/glasses/chameleon/holosphere/emp_act(severity)
	return ..()

//******************
//**Chameleon Belt**
//******************

/obj/item/storage/belt/chameleon
	name = "belt"
	desc = "Can hold various things.  It also has a small dial inside one of the pouches."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/storage/belt/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "belt"
	desc = "Can hold various things."
	icon_state = "utilitybelt"
	update_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_belt()

/obj/item/storage/belt/chameleon/verb/change(picked in GLOB.clothing_belt)
	set name = "Change Belt Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!picked != "None" && ispath(GLOB.clothing_belt[picked]))
		return

	disguise(GLOB.clothing_belt[picked])

	if(ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_belt() //so our overlays update.

//******************
//**Chameleon Tie**
//******************

/obj/item/clothing/accessory/chameleon
	name = "black tie"
	desc = "Looks like a black tie, but his one also has a dial inside."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "blacktie"
	origin_tech = list(TECH_ILLEGAL = 3)

/obj/item/clothing/accessory/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "black tie"
	desc = "Looks like a black tie, but his one also has a dial inside."
	icon_state = "blacktie"
	update_icon()
	update_worn_icon()

/obj/item/clothing/accessory/chameleon/verb/change(picked in GLOB.clothing_accessory)
	set name = "Change Accessory Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(picked != "None" && !ispath(GLOB.clothing_accessory[picked]))
		return

	disguise(GLOB.clothing_accessory[picked])
	update_icon()

//*****************
//**Chameleon Gun**
//*****************
/obj/item/gun/projectile/energy/chameleon
	name = "desert eagle"
	desc = "A hologram projector in the shape of a gun. There is a dial on the side to change the gun's disguise."
	icon = 'icons/obj/gun/holographic.dmi'
	icon_state = "deagle"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 4)
	materials_base = list()

	fire_sound = 'sound/weapons/Gunshot1.ogg'
	projectile_type = /obj/projectile/chameleon
	charge_meter = 0
	charge_cost = 48 //uses next to no power, since it's just holograms
	legacy_battery_lock = 1

	var/obj/projectile/copy_projectile
	var/global/list/gun_choices

/obj/item/gun/projectile/energy/chameleon/Initialize(mapload)
	. = ..()

	if(!gun_choices)
		gun_choices = list()
		for(var/gun_type in typesof(/obj/item/gun/) - src.type)
			var/obj/item/gun/G = gun_type
			src.gun_choices[initial(G.name)] = gun_type

/obj/item/gun/projectile/energy/chameleon/consume_next_projectile(datum/gun_firing_cycle/cycle)
	var/obj/projectile/P = ..()
	if(istype(P) && ispath(copy_projectile))
		P.name = initial(copy_projectile.name)
		P.icon = initial(copy_projectile.icon)
		P.icon_state = initial(copy_projectile.icon_state)
		P.pass_flags = initial(copy_projectile.pass_flags)
		P.fire_sound = initial(copy_projectile.fire_sound)
		P.hitscan = initial(copy_projectile.hitscan)
		P.speed = initial(copy_projectile.speed)
		P.legacy_muzzle_type = initial(copy_projectile.legacy_muzzle_type)
		P.legacy_tracer_type = initial(copy_projectile.legacy_tracer_type)
		P.legacy_impact_type = initial(copy_projectile.legacy_impact_type)
	return P

/obj/item/gun/projectile/energy/chameleon/emp_act(severity)
	name = "desert eagle"
	desc = "It's a desert eagle."
	icon_state = "deagle"
	update_icon()
	update_worn_icon()

/obj/item/gun/projectile/energy/chameleon/disguise(var/newtype)
	var/obj/item/gun/copy = ..()

	modifystate = copy.icon_state

	inv_hide_flags = copy.inv_hide_flags
	if(copy.fire_sound)
		fire_sound = copy.fire_sound
	else
		fire_sound = null
	fire_sound_text = copy.fire_sound_text

	var/obj/item/gun/G = copy
	if(istype(G))
		copy_projectile = G.projectile_type
		//charge_meter = E.charge_meter //does not work very well with icon_state changes, ATM
	else
		copy_projectile = null
		//charge_meter = 0

/obj/item/gun/projectile/energy/chameleon/verb/change(picked in gun_choices)
	set name = "Change Gun Appearance"
	set category = "Chameleon Items"
	set src in usr

	if(!ispath(gun_choices[picked]))
		return

	disguise(gun_choices[picked])
	update_worn_icon()
