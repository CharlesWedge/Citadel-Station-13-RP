
/obj/item/vehicle_component
	name = "mecha component"
	icon = 'icons/mecha/mech_component.dmi'
	icon_state = "component"
	w_class = WEIGHT_CLASS_HUGE
	origin_tech = list(TECH_DATA = 2, TECH_ENGINEERING = 2)

	var/component_type = null

	var/obj/vehicle/sealed/mecha/chassis = null
	var/start_damaged = FALSE

	var/emp_resistance = 0	// Amount of emp 'levels' removed.

	var/list/required_type = null	// List, if it exists. Exosuits meant to use the component (Unique var changes / effects)

	integrity = 100
	var/integrity_danger_mod = 0.5	// Multiplier for comparison to integrity_max before problems start.
	integrity_max = 100

	var/step_delay = 0

	var/relative_size = 30	// Percent chance for the component to be hit.

	var/internal_damage_flag	// If set, the component will toggle the flag on or off if it is destroyed / severely damaged.

/obj/item/vehicle_component/examine(mob/user, dist)
	. = ..()
	var/show_integrity = round(integrity/integrity_max*100, 0.1)
	switch(show_integrity)
		if(85 to 100)
			. += "It's fully intact."
		if(65 to 85)
			. += "It's slightly damaged."
		if(45 to 65)
			. += "<span class='notice'>It's badly damaged.</span>"
		if(25 to 45)
			. += "<span class='warning'>It's heavily damaged.</span>"
		if(2 to 25)
			. += "<span class='warning'><b>It's falling apart.</b></span>"
		if(0 to 1)
			. += "<span class='warning'><b>It is completely destroyed.</b></span>"

/obj/item/vehicle_component/Initialize(mapload)
	. = ..()
	integrity = integrity_max

	if(start_damaged)
		integrity = round(integrity * integrity_danger_mod)

/obj/item/vehicle_component/Destroy()
	detach()
	return ..()

// Damage code.

/obj/item/vehicle_component/emp_act(var/severity = 4)
	if(severity + emp_resistance > 4)
		return

	severity = clamp(severity + emp_resistance, 1, 4)

	damage_integrity((4 - severity) * round(integrity * 0.1, 0.1))

/obj/item/vehicle_component/proc/adjust_integrity_mecha(var/amt = 0)
	integrity = clamp(integrity + amt, 0, integrity_max)
	return

/obj/item/vehicle_component/proc/damage_part(var/dam_amt = 0, var/type = DAMAGE_TYPE_BRUTE)
	if(dam_amt <= 0)
		return FALSE

	adjust_integrity_mecha(-1 * dam_amt)

	if(chassis && internal_damage_flag)
		if(get_efficiency() < 0.5)
			chassis.check_for_internal_damage(list(internal_damage_flag), TRUE)

	return TRUE

/obj/item/vehicle_component/proc/get_efficiency()
	var/integ_limit = round(integrity_max * integrity_danger_mod)

	if(integrity < integ_limit)
		var/int_percent = round(integrity / integ_limit, 0.1)

		return int_percent

	return 1

// Attach/Detach code.

/obj/item/vehicle_component/proc/attach(var/obj/vehicle/sealed/mecha/target, var/mob/living/user)
	if(target)
		if(!(component_type in target.internal_components))
			if(user)
				to_chat(user, "<span class='notice'>\The [target] doesn't seem to have anywhere to put \the [src].</span>")
			return FALSE
		if(target.internal_components[component_type])
			if(user)
				to_chat(user, "<span class='notice'>\The [target] already has a [component_type] installed!</span>")
			return FALSE
		if(user)
			if(!user.attempt_insert_item_for_installation(src, target))
				return
			else
				forceMove(target)
		chassis = target

		if(internal_damage_flag)
			if(integrity > (integrity_max * integrity_danger_mod))
				if(chassis.hasInternalDamage(internal_damage_flag))
					chassis.clearInternalDamage(internal_damage_flag)

			else
				chassis.check_for_internal_damage(list(internal_damage_flag))

		chassis.internal_components[component_type] = src

		if(user)
			chassis.visible_message("<span class='notice'>[user] installs \the [src] in \the [chassis].</span>")
		return TRUE
	return FALSE

/obj/item/vehicle_component/proc/detach()
	if(chassis)
		chassis.internal_components[component_type] = null

		if(internal_damage_flag && chassis.hasInternalDamage(internal_damage_flag))	// If the module has been removed, it's kind of unfair to keep it causing problems by being damaged. It's nonfunctional either way.
			chassis.clearInternalDamage(internal_damage_flag)

		forceMove(get_turf(chassis))
	chassis = null
	return TRUE


/obj/item/vehicle_component/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/NP = W

		if(integrity < integrity_max)
			while(integrity < integrity_max && NP)
				if(do_after(user, 1 SECOND, src) && NP.use(1))
					adjust_integrity_mecha(10)

			return

	return ..()

// Various procs to handle different calls by Exosuits. IE, movement actions, damage actions, etc.

/obj/item/vehicle_component/proc/get_step_delay()
	return step_delay

/obj/item/vehicle_component/proc/handle_move()
	return
