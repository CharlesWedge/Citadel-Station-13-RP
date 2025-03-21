// BLAST DOORS
//
// Refactored 27.12.2014 by Atlantis
//
// Blast doors are suposed to be reinforced versions of regular doors. Instead of being manually
// controlled they use buttons or other means of remote control. This is why they cannot be emagged
// as they lack any ID scanning system, they just handle remote control signals. Subtypes have
// different icons, which are defined by set of variables. Subtypes are on bottom of this file.

// UPDATE 06.04.2018
// The emag thing wasn't working as intended, manually overwrote it.

/obj/machinery/door/blast
	name = "Blast Door"
	desc = "That looks like it doesn't open easily."
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = null
	armor_type = /datum/armor/door/blast_door
	rad_flags = RAD_NO_CONTAMINATE
	rad_insulation = RAD_INSULATION_SUPER
	dir = NORTH
	explosion_resistance = 25
	closed_layer = ON_WINDOW_LAYER // Above airlocks when closed

	//Most blast doors are infrequently toggled and sometimes used with regular doors anyways,
	//turning this off prevents awkward zone geometry in places like medbay lobby, for example.
	block_air_zones = 0

	smoothing_groups = (SMOOTH_GROUP_SHUTTERS_BLASTDOORS)

	var/datum/prototype/material/implicit_material
	// Icon states for different shutter types. Simply change this instead of rewriting the update_icon proc.
	var/icon_state_open = null
	var/icon_state_opening = null
	var/icon_state_closed = null
	var/icon_state_closing = null

	var/id = 1.0

	var/open_sound = 'sound/machines/blastdoor_open.ogg'
	var/close_sound = 'sound/machines/blastdoor_close.ogg'

/obj/machinery/door/blast/Initialize(mapload)
	. = ..()
	implicit_material = get_material_by_name("plasteel")

// Proc: Bumped()
// Parameters: 1 (AM - Atom that tried to walk through this object)
// Description: If we are open returns zero, otherwise returns result of parent function.
/obj/machinery/door/blast/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return 0

// Proc: update_icon()
// Parameters: None
// Description: Updates icon of this object. Uses icon state variables.
/obj/machinery/door/blast/update_icon()
	. = ..()
	if(density)
		icon_state = icon_state_closed
	else
		icon_state = icon_state_open

// Has to be in here, comment at the top is older than the emag_act code on doors proper
/obj/machinery/door/blast/emag_act()
	return -1

// Blast doors are triggered remotely, so nobody is allowed to physically influence it.
/obj/machinery/door/blast/allowed(mob/M)
	return FALSE

// Proc: force_open()
// Parameters: None
// Description: Opens the door. No checks are done inside this proc.
/obj/machinery/door/blast/proc/force_open()
	src.operating = 1
	playsound(src.loc, open_sound, 100, 1)
	flick(icon_state_opening, src)
	src.density = 0
	update_nearby_tiles()
	src.update_icon()
	src.set_opacity(0)
	sleep(15)
	src.layer = open_layer
	rad_insulation = RAD_INSULATION_NONE
	src.operating = 0

// Proc: force_close()
// Parameters: None
// Description: Closes the door. No checks are done inside this proc.
/obj/machinery/door/blast/proc/force_close()
	src.operating = 1
	playsound(src.loc, close_sound, 100, 1)
	src.layer = closed_layer
	flick(icon_state_closing, src)
	src.density = 1
	update_nearby_tiles()
	src.update_icon()
	src.set_opacity(initial(opacity))
	sleep(15)
	rad_insulation = initial(rad_insulation)
	src.operating = 0

// Proc: force_toggle()
// Parameters: None
// Description: Opens or closes the door, depending on current state. No checks are done inside this proc.
/obj/machinery/door/blast/proc/force_toggle(var/forced = 0, mob/user as mob)
	if (forced)
		playsound(src.loc, 'sound/machines/airlock_creaking.ogg', 100, 1)

	if(src.density)
		src.force_open()
	else
		src.force_close()

//Proc: attack_hand
//Description: Attacked with empty hand. Only to allow special attack_bys.
/obj/machinery/door/blast/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/X = user
		if(istype(X.species, /datum/species/xenos))
			src.attack_alien(user)
			return
	..()


// Proc: attackby()
// Parameters: 2 (C - Item this object was clicked with, user - Mob which clicked this object)
// Description: If we are clicked with crowbar, wielded fire axe, or armblade, try to manually open the door.
// This only works on broken doors or doors without power. Also allows repair with Plasteel.
/obj/machinery/door/blast/attackby(obj/item/I, mob/living/user, list/params, clickchain_flags, damage_multiplier)
	if(user.a_intent == INTENT_HARM)
		return ..()
	src.add_fingerprint(user, 0, I)
	if(istype(I, /obj/item)) // For reasons unknown, sometimes C is actually not what it is advertised as, like a mob.
		if(I.pry == 1 && (user.a_intent != INTENT_HARM || (machine_stat & BROKEN))) // Can we pry it open with something, like a crowbar/fireaxe/lingblade?
			// If we're at this point, it's a fireaxe in both hands or something else that doesn't care for twohanding.
			if(((machine_stat & NOPOWER) || (machine_stat & BROKEN)) && !( src.operating ))
				force_toggle(1, user)

			else
				to_chat(user, "<span class='notice'>[src]'s motors resist your effort.</span>")
			return
	else if(I.is_material_stack_of(/datum/prototype/material/plasteel)) // Repairing.
		var/amt = CEILING((integrity_max - integrity)/150, 1)
		if(!amt)
			to_chat(user, "<span class='notice'>\The [src] is already fully repaired.</span>")
			return
		var/obj/item/stack/P = I
		if(P.amount < amt)
			to_chat(user, "<span class='warning'>You don't have enough sheets to repair this! You need at least [amt] sheets.</span>")
			return
		to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
		if(do_after(usr, 30))
			if(P.use(amt))
				to_chat(user, "<span class='notice'>You have repaired \The [src]</span>")
				src.repair()
			else
				to_chat(user, "<span class='warning'>You don't have enough sheets to repair this! You need at least [amt] sheets.</span>")
		return ..()

// Proc: attack_alien()
// Parameters: Attacking Xeno mob.
// Description: Forces open the door after a delay.
/obj/machinery/door/blast/attack_alien(var/mob/user) //Familiar, right? Doors.
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/X = user
		if(istype(X.species, /datum/species/xenos))
			if(src.density)
				visible_message("<span class='green'>\The [user] begins forcing \the [src] open!</span>")
				if(do_after(user, 15 SECONDS,src))
					playsound(src.loc, 'sound/machines/airlock_creaking.ogg', 100, 1)
					visible_message("<span class='danger'>\The [user] forces \the [src] open!</span>")
					force_open(1)
			else
				visible_message("<span class='green'>\The [user] begins forcing \the [src] closed!</span>")
				if(do_after(user, 5 SECONDS,src))
					playsound(src.loc, 'sound/machines/airlock_creaking.ogg', 100, 1)
					visible_message("<span class='danger'>\The [user] forces \the [src] closed!</span>")
					force_close(1)
		else
			visible_message("<span class='notice'>\The [user] strains fruitlessly to force \the [src] [density ? "open" : "closed"].</span>")
			return
	..()

// Proc: attack_generic()
// Parameters: Attacking simple mob, incoming damage.
// Description: Checks the power or integrity of the blast door, if either have failed, chekcs the damage to determine if the creature would be able to open the door by force. Otherwise, super.
/obj/machinery/door/blast/attack_generic(mob/living/user, damage)
	if(machine_stat & (BROKEN|NOPOWER))
		if(damage >= 10)
			user.set_AI_busy(TRUE) // If the mob doesn't have an AI attached, this won't do anything.
			if(src.density)
				visible_message("<span class='danger'>\The [user] starts forcing \the [src] open!</span>")
				if(do_after(user, 5 SECONDS, src))
					visible_message("<span class='danger'>\The [user] forces \the [src] open!</span>")
					force_open(1)
			else
				visible_message("<span class='danger'>\The [user] starts forcing \the [src] closed!</span>")
				if(do_after(user, 2 SECONDS, src))
					visible_message("<span class='danger'>\The [user] forces \the [src] closed!</span>")
					force_close(1)
			user.set_AI_busy(FALSE)
		else
			visible_message("<span class='notice'>\The [user] strains fruitlessly to force \the [src] [density ? "open" : "closed"].</span>")
		return
	..()

// Proc: open()
// Parameters: None
// Description: Opens the door. Does necessary checks. Automatically closes if autoclose is true
/obj/machinery/door/blast/open(var/forced = 0)
	if(forced)
		force_open()
		return 1
	else
		if (src.operating || (machine_stat & BROKEN || machine_stat & NOPOWER))
			return 1
		force_open()

	if(autoclose && src.operating && !(machine_stat & BROKEN || machine_stat & NOPOWER))
		spawn(150)
			close()
	return 1

// Proc: close()
// Parameters: None
// Description: Closes the door. Does necessary checks.
/obj/machinery/door/blast/close()
	if (src.operating || (machine_stat & BROKEN || machine_stat & NOPOWER))
		return
	force_close()


// Proc: repair()
// Parameters: None
// Description: Fully repairs the blast door.
/obj/machinery/door/blast/proc/repair()
	set_integrity(integrity_max)
	if(machine_stat & BROKEN)
		machine_stat &= ~BROKEN

/*
// This replicates the old functionality coded into CanPass() for this object, however it appeared to have made blast doors not airtight.
// If for some reason this is actually needed for something important, uncomment this.
/obj/machinery/door/blast/CanZASPass(turf/T, is_zone)
	if(is_zone)
		return ATMOS_PASS_YES
	return ..()
*/

// SUBTYPE: Regular
// Your classical blast door, found almost everywhere.
/obj/machinery/door/blast/regular
	icon_state_open = "pdoor0"
	icon_state_opening = "pdoorc0"
	icon_state_closed = "pdoor1"
	icon_state_closing = "pdoorc1"
	icon_state = "pdoor1"
	integrity = 600
	integrity_max = 600
	heat_resistance = INFINITY

/obj/machinery/door/blast/regular/open
	icon_state = "pdoor0"
	density = 0
	opacity = 0

// SUBTYPE: Shutters
// Nicer looking, and also weaker, shutters. Found in kitchen and similar areas.
/obj/machinery/door/blast/shutters
	icon_state_open = "shutter0"
	icon_state_opening = "shutterc0"
	icon_state_closed = "shutter1"
	icon_state_closing = "shutterc1"
	icon_state = "shutter1"
	open_sound = 'sound/machines/shutters_open.ogg'
	close_sound = 'sound/machines/shutters_close.ogg'
