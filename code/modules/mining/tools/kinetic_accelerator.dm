/**
 * This is here for now
 */
/proc/lavaland_environment_check(turf/simulated/T)
	. = TRUE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure > LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = FALSE
	if(environment.temperature < (T20C - 30))
		. = TRUE

/obj/item/gun/projectile/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self-recharging mining tool that fires unstable blasts of kinetic energy, because management wouldn't let you have the ripper saws or line cutters. Especially effective in low-pressure environments."
	icon = 'icons/obj/gun/energy.dmi'
	icon_state = "kineticgun"
	item_state = "kineticgun"
	cell_type = /obj/item/cell/device/weapon/empproof
	clothing_flags = NONE
	charge_meter = FALSE

	projectile_type = /obj/projectile/kinetic
	charge_cost = 1200
	legacy_battery_lock = TRUE
	fire_sound = 'sound/weapons/kenetic_accel.ogg'
	render_use_legacy_by_default = FALSE
	attachment_alignment = list(
		GUN_ATTACHMENT_SLOT_RAIL = list(
			17,
			23,
		),
		GUN_ATTACHMENT_SLOT_SIDEBARREL = list(
			30,
			17,
		),
	)
	var/overheat_time = 16
	var/holds_charge = FALSE
	var/unique_frequency = FALSE // modified by KA modkits
	var/overheat = FALSE
	var/emptystate = "kineticgun_empty"

	var/max_mod_capacity = 100
	var/list/modkits = list()

	var/recharge_timerid

/obj/item/gun/projectile/energy/kinetic_accelerator/consume_next_projectile(datum/gun_firing_cycle/cycle)
	if(overheat)
		return GUN_FIRED_FAIL_EMPTY
	. = ..()
	if(.)
		var/obj/projectile/P = .
		modify_projectile(P)

/obj/item/gun/projectile/energy/kinetic_accelerator/on_firing_cycle_end(datum/gun_firing_cycle/cycle)
	. = ..()
	attempt_reload()

/*
/obj/item/gun/projectile/energy/kinetic_accelerator/premiumka
	name = "premium accelerator"
	desc = "A premium kinetic accelerator fitted with an extended barrel and increased pressure tank."
	icon_state = "premiumgun"
	item_state = "premiumgun"
	projectile_type = /obj/projectile/kinetic/premium
*/

/obj/item/gun/projectile/energy/kinetic_accelerator/examine(mob/user, dist)
	. = ..()
	if(max_mod_capacity)
		. += "<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining."
		for(var/A in get_modkits())
			var/obj/item/ka_modkit/M = A
			. += "<span class='notice'>There is \a [M] installed, using <b>[M.cost]%</b> capacity.</span>"

/obj/item/gun/projectile/energy/kinetic_accelerator/Exited(atom/movable/AM)
	. = ..()
	if((AM in modkits) && istype(AM, /obj/item/ka_modkit))
		var/obj/item/ka_modkit/M = AM
		M.uninstall(src, FALSE)

/obj/item/gun/projectile/energy/kinetic_accelerator/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/tool/crowbar))
		if(modkits.len)
			to_chat(user, "<span class='notice'>You pry the modifications out.</span>")
			playsound(loc, I.tool_sound, 100, 1)
			for(var/obj/item/ka_modkit/M in modkits)
				M.uninstall(src)
		else
			to_chat(user, "<span class='notice'>There are no modifications currently installed.</span>")
	if(istype(I, /obj/item/ka_modkit))
		var/obj/item/ka_modkit/MK = I
		MK.install(src, user)
	else
		..()

/obj/item/gun/projectile/energy/kinetic_accelerator/proc/get_remaining_mod_capacity()
	var/current_capacity_used = 0
	for(var/A in get_modkits())
		var/obj/item/ka_modkit/M = A
		current_capacity_used += M.cost
	return max_mod_capacity - current_capacity_used

/obj/item/gun/projectile/energy/kinetic_accelerator/proc/get_modkits()
	. = list()
	for(var/A in modkits)
		. += A

/obj/item/gun/projectile/energy/kinetic_accelerator/proc/modify_projectile(obj/projectile/kinetic/K)
	K.kinetic_gun = src //do something special on-hit, easy!
	for(var/A in get_modkits())
		var/obj/item/ka_modkit/M = A
		M.modify_projectile(K)

/obj/item/gun/projectile/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/gun/projectile/energy/kinetic_accelerator/cyborg/Destroy()
	for(var/obj/item/ka_modkit/M in modkits)
		M.uninstall(src)
	return ..()

/obj/item/gun/projectile/energy/kinetic_accelerator/premiumka/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/gun/projectile/energy/kinetic_accelerator/premiumka/cyborg/Destroy()
	for(var/obj/item/ka_modkit/M in modkits)
		M.uninstall(src)
	return ..()

/obj/item/gun/projectile/energy/kinetic_accelerator/minebot
	// trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/gun/projectile/energy/kinetic_accelerator/Initialize(mapload)
	. = ..()
	if(!holds_charge)
		empty()
	AddElement(/datum/element/conflict_checking, CONFLICT_ELEMENT_KA)

/obj/item/gun/projectile/energy/kinetic_accelerator/equipped(mob/user, slot, flags)
	. = ..()
	if(obj_cell_slot.cell.charge < charge_cost)
		attempt_reload()

/obj/item/gun/projectile/energy/kinetic_accelerator/dropped(mob/user, flags, atom/newLoc)
	. = ..()
	if(!QDELING(src) && !holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		addtimer(CALLBACK(src, PROC_REF(empty_if_not_held)), 2)

/obj/item/gun/projectile/energy/kinetic_accelerator/proc/empty_if_not_held()
	if(!ismob(loc) && !istype(loc, /obj/item/integrated_circuit))
		empty()

/obj/item/gun/projectile/energy/kinetic_accelerator/proc/empty()
	if(obj_cell_slot.cell)
		obj_cell_slot.cell.use(obj_cell_slot.cell.charge)
	update_icon()

/obj/item/gun/projectile/energy/kinetic_accelerator/proc/attempt_reload(recharge_time)
	if(!obj_cell_slot.cell)
		return
	if(overheat)
		return
	if(!recharge_time)
		recharge_time = overheat_time
	overheat = TRUE
	update_icon()

	var/carried = max(1, loc.ConflictElementCount(CONFLICT_ELEMENT_KA))

	deltimer(recharge_timerid)
	recharge_timerid = addtimer(CALLBACK(src, PROC_REF(reload)), recharge_time * carried, TIMER_STOPPABLE)

/obj/item/gun/projectile/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/gun/projectile/energy/kinetic_accelerator/proc/reload()
	obj_cell_slot.cell.give(obj_cell_slot.cell.maxcharge)
	// process_chamber()
	// if(!suppressed)
	playsound(src, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	// else
		// to_chat(loc, "<span class='warning'>[src] silently charges up.</span>")
	overheat = FALSE
	update_icon()

/obj/item/gun/projectile/energy/kinetic_accelerator/update_overlays()
	. = ..()
	if(overheat || (obj_cell_slot.cell.charge == 0))
		. += emptystate

//Projectiles
/obj/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage_force = 30
	damage_type = DAMAGE_TYPE_BRUTE
	damage_flag = ARMOR_BOMB
	range = WORLD_ICON_SIZE * 4
	// log_override = TRUE

	var/pressure_decrease_active = FALSE
	var/pressure_decrease = 1/3
	var/obj/item/gun/projectile/energy/kinetic_accelerator/kinetic_gun

/obj/projectile/kinetic/premium
	damage_force = 40
	damage_type = DAMAGE_TYPE_BRUTE
	range = 5

/obj/projectile/kinetic/Destroy()
	kinetic_gun = null
	return ..()

/obj/projectile/kinetic/pre_impact(atom/target, impact_flags, def_zone)
	if(kinetic_gun)
		var/list/mods = kinetic_gun.get_modkits()
		for(var/obj/item/ka_modkit/M in mods)
			M.projectile_prehit(src, target, kinetic_gun)
	if(!pressure_decrease_active && !lavaland_environment_check(get_turf(src)))
		name = "weakened [name]"
		damage_force = damage_force * pressure_decrease
		pressure_decrease_active = TRUE
	return ..()

/obj/projectile/kinetic/legacy_on_range()
	strike_thing()
	..()

/obj/projectile/kinetic/on_impact(atom/target, impact_flags, def_zone, efficiency)
	. = ..()
	if(. & PROJECTILE_IMPACT_FLAGS_UNCONDITIONAL_ABORT)
		return
	strike_thing(target)

/obj/projectile/kinetic/proc/strike_thing(atom/target)
	if(!pressure_decrease_active && !lavaland_environment_check(get_turf(src)))
		name = "weakened [name]"
		damage_force = damage_force * pressure_decrease
		pressure_decrease_active = TRUE
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(kinetic_gun) //hopefully whoever shot this was not very, very unfortunate.
		var/list/mods = kinetic_gun.get_modkits()
		for(var/obj/item/ka_modkit/M in mods)
			M.projectile_strike_predamage(src, target_turf, target, kinetic_gun)
		for(var/obj/item/ka_modkit/M in mods)
			M.projectile_strike(src, target_turf, target, kinetic_gun)
	if(ismineralturf(target_turf))
		var/turf/simulated/mineral/M = target_turf
		M.GetDrilled(TRUE)
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color


//Modkits
/obj/item/ka_modkit
	name = "kinetic accelerator modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL
	var/require_module = 1
	// module_type = list(/obj/item/robot_module/miner)
	var/denied_type = null
	var/maximum_of_type = 1
	var/cost = 30
	var/modifier = 1 //For use in any mod kit that has numerical modifiers
	var/minebot_upgrade = TRUE
	var/minebot_exclusive = FALSE

/obj/item/ka_modkit/examine(mob/user, dist)
	. = ..()
	. += "<span class='notice'>Occupies <b>[cost]%</b> of mod capacity.</span>"

/obj/item/ka_modkit/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/gun/projectile/energy/kinetic_accelerator))
		install(A, user)
	else
		..()

/*
/obj/item/ka_modkit/afterInstall(mob/living/silicon/robot/R)
	for(var/obj/item/gun/projectile/energy/kinetic_accelerator/H in R.module.modules)
		if(install(H, R)) //It worked
			return
	to_chat(R, "<span class='alert'>Upgrade error - Aborting Kinetic Accelerator linking.</span>") //No applicable KA found, insufficient capacity, or some other problem.
*/

/obj/item/ka_modkit/proc/install(obj/item/gun/projectile/energy/kinetic_accelerator/KA, mob/user)
	. = TRUE
	if(src in KA.modkits) // Sanity check to prevent installing the same modkit twice thanks to occasional click/lag delays.
		return FALSE
	// if(minebot_upgrade)
	// 	if(minebot_exclusive && !istype(KA.loc, /mob/living/simple_animal/hostile/mining_drone))
	// 		to_chat(user, "<span class='notice'>The modkit you're trying to install is only rated for minebot use.</span>")
	// 		return FALSE
	// else if(istype(KA.loc, /mob/living/simple_animal/hostile/mining_drone))
	// 	to_chat(user, "<span class='notice'>The modkit you're trying to install is not rated for minebot use.</span>")
	// 	return FALSE
	if(denied_type)
		var/number_of_denied = 0
		for(var/A in KA.get_modkits())
			var/obj/item/ka_modkit/M = A
			if(istype(M, denied_type))
				number_of_denied++
			if(number_of_denied >= maximum_of_type)
				. = FALSE
				break
	if(KA.get_remaining_mod_capacity() >= cost)
		if(.)
			if(user.is_in_inventory(src))
				if(!user.attempt_insert_item_for_installation(src, KA))
					return FALSE
			else
				forceMove(KA)
			to_chat(user, "<span class='notice'>You install the modkit.</span>")
			playsound(loc, 'sound/items/screwdriver.ogg', 100, 1)
			KA.modkits += src
		else
			to_chat(user, "<span class='notice'>The modkit you're trying to install would conflict with an already installed modkit. Use a crowbar to remove existing modkits.</span>")
	else
		to_chat(user, "<span class='notice'>You don't have room(<b>[KA.get_remaining_mod_capacity()]%</b> remaining, [cost]% needed) to install this modkit. Use a crowbar to remove existing modkits.</span>")
		. = FALSE

/obj/item/ka_modkit/proc/uninstall(obj/item/gun/projectile/energy/kinetic_accelerator/KA, forcemove = TRUE)
	KA.modkits -= src
	if(forcemove)
		forceMove(get_turf(KA))

/obj/item/ka_modkit/proc/modify_projectile(obj/projectile/kinetic/K)

//use this one for effects you want to trigger before any damage is done at all and before damage is decreased by pressure
/obj/item/ka_modkit/proc/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
//use this one for effects you want to trigger before mods that do damage
/obj/item/ka_modkit/proc/projectile_strike_predamage(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
//and this one for things that don't need to trigger before other damage-dealing mods
/obj/item/ka_modkit/proc/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)

//Range
/obj/item/ka_modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	modifier = 1
	cost = 25

/obj/item/ka_modkit/range/modify_projectile(obj/projectile/kinetic/K)
	K.range += modifier * WORLD_ICON_SIZE
//Cooldown
/obj/item/ka_modkit/cooldown
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Not rated for minebot use."
	modifier = 2.5
	minebot_upgrade = FALSE
	var/decreased

/obj/item/ka_modkit/cooldown/install(obj/item/gun/projectile/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		var/old = KA.overheat_time
		KA.overheat_time = max(0, KA.overheat_time - modifier)
		decreased = old - KA.overheat_time


/obj/item/ka_modkit/cooldown/uninstall(obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	KA.overheat_time += decreased
	..()

/obj/item/ka_modkit/cooldown/minebot
	name = "minebot cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Only rated for minebot use."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	denied_type = /obj/item/ka_modkit/cooldown/minebot
	modifier = 10
	cost = 0
	minebot_upgrade = TRUE
	minebot_exclusive = TRUE


//Capacity
/obj/item/ka_modkit/capacity
	name = "capacity increase"
	desc = "A cutdown accelerator frame that increases mod capacity while reducing damage. Not compatible with minebots."
	modifier = -6
	cost = -15
	maximum_of_type = 2
	minebot_upgrade = FALSE
	denied_type = /obj/item/ka_modkit/capacity

/obj/item/ka_modkit/capacity/modify_projectile(obj/projectile/kinetic/K)
	K.damage_force += modifier


//AoE blasts
/obj/item/ka_modkit/aoe
	modifier = 0
	var/turf_aoe = FALSE
	var/stats_stolen = FALSE

/obj/item/ka_modkit/aoe/install(obj/item/gun/projectile/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		for(var/obj/item/ka_modkit/aoe/AOE in KA.modkits) //make sure only one of the aoe modules has values if somebody has multiple
			if(AOE.stats_stolen || AOE == src)
				continue
			modifier += AOE.modifier //take its modifiers
			AOE.modifier = 0
			turf_aoe += AOE.turf_aoe
			AOE.turf_aoe = FALSE
			AOE.stats_stolen = TRUE

/obj/item/ka_modkit/aoe/uninstall(obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	..()
	modifier = initial(modifier) //get our modifiers back
	turf_aoe = initial(turf_aoe)
	stats_stolen = FALSE

/obj/item/ka_modkit/aoe/modify_projectile(obj/projectile/kinetic/K)
	K.name = "kinetic explosion"

/obj/item/ka_modkit/aoe/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/explosion/fast(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
			if(ismineralturf(T))
				var/turf/simulated/mineral/M = T
				M.GetDrilled(TRUE)
	if(modifier)
		for(var/mob/living/L in range(1, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.damage_flag)
			// var/armor = L.run_armor_check(K.def_zone, K.flag, null, null, K.armour_penetration)
			L.apply_damage(K.damage_force*modifier, K.damage_type, K.def_zone, armor)
			// L.apply_damage(K.damage_force*modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, "<span class='userdanger'>You're struck by a [K.name]!</span>")

/obj/item/ka_modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	denied_type = /obj/item/ka_modkit/aoe/turfs
	turf_aoe = TRUE

/obj/item/ka_modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	maximum_of_type = 3
	modifier = 0.25

/obj/item/ka_modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2

//Minebot passthrough
/obj/item/ka_modkit/minebot_passthrough
	name = "minebot passthrough"
	desc = "Causes kinetic accelerator shots to pass through minebots."
	cost = 0

//Tendril-unique modules
/obj/item/ka_modkit/cooldown/repeater
	name = "rapid repeater"
	desc = "Quarters the kinetic accelerator's cooldown on striking a living target, but greatly increases the base cooldown."
	denied_type = /obj/item/ka_modkit/cooldown/repeater
	modifier = -14 //Makes the cooldown 3 seconds(with no cooldown mods) if you miss. Don't miss.
	cost = 50

/obj/item/ka_modkit/cooldown/repeater/projectile_strike_predamage(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	var/valid_repeat = FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			valid_repeat = TRUE
	if(ismineralturf(target_turf))
		valid_repeat = TRUE
	if(valid_repeat)
		KA.overheat = FALSE
		KA.attempt_reload(KA.overheat_time * 0.25) //If you hit, the cooldown drops to 0.75 seconds.

/*
/obj/item/ka_modkit/lifesteal
	name = "lifesteal crystal"
	desc = "Causes kinetic accelerator shots to slightly heal the firer on striking a living target."
	icon_state = "modkit_crystal"
	modifier = 2.5 //Not a very effective method of healing.
	cost = 20
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/ka_modkit/lifesteal/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	if(isliving(target) && isliving(K.firer))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		L = K.firer
		L.heal_ordered_damage(modifier, damage_heal_order)
*/

/obj/item/ka_modkit/resonator_blasts
	name = "resonator blast"
	desc = "Causes kinetic accelerator shots to leave and detonate resonator blasts."
	denied_type = /obj/item/ka_modkit/resonator_blasts
	cost = 30
	modifier = 0.25 //A bonus 15 damage if you burst the field on a target, 60 if you lure them into it.

/obj/item/ka_modkit/resonator_blasts/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	if(target_turf && !ismineralturf(target_turf)) //Don't make fields on mineral turfs.
		var/obj/effect/resonance/R = locate(/obj/effect/resonance) in target_turf
		if(R)
			R.resonance_damage *= modifier
			R.burst()
			return
		new /obj/effect/resonance(target_turf, K.firer, 30)

/*
/obj/item/ka_modkit/bounty
	name = "death syphon"
	desc = "Killing or assisting in killing a creature permanently increases your damage against that type of creature."
	denied_type = /obj/item/ka_modkit/bounty
	modifier = 1.25
	cost = 30
	var/maximum_bounty = 25
	var/list/bounties_reaped = list()

/obj/item/ka_modkit/bounty/projectile_prehit(obj/projectile/kinetic/K, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		var/list/existing_marks = L.has_status_effect_list(STATUS_EFFECT_SYPHONMARK)
		for(var/i in existing_marks)
			var/datum/status_effect/syphon_mark/SM = i
			if(SM.reward_target == src) //we want to allow multiple people with bounty modkits to use them, but we need to replace our own marks so we don't multi-reward
				SM.reward_target = null
				qdel(SM)
		L.apply_status_effect(STATUS_EFFECT_SYPHONMARK, src)

/obj/item/ka_modkit/bounty/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		if(bounties_reaped[L.type])
			var/kill_modifier = 1
			if(K.pressure_decrease_active)
				kill_modifier *= K.pressure_decrease
			var/armor = L.run_armor_check(K.def_zone, K.flag, null, null, K.armour_penetration)
			L.apply_damage(bounties_reaped[L.type]*kill_modifier, K.damage_type, K.def_zone, armor)

/obj/item/ka_modkit/bounty/proc/get_kill(mob/living/L)
	var/bonus_mod = 1
	if(ismegafauna(L)) //megafauna reward
		bonus_mod = 4
	if(!bounties_reaped[L.type])
		bounties_reaped[L.type] = min(modifier * bonus_mod, maximum_bounty)
	else
		bounties_reaped[L.type] = min(bounties_reaped[L.type] + (modifier * bonus_mod), maximum_bounty)
*/

//Indoors
/obj/item/ka_modkit/indoors
	name = "decrease pressure penalty"
	desc = "A syndicate modification kit that increases the damage a kinetic accelerator does in high pressure environments."
	modifier = 2
	denied_type = /obj/item/ka_modkit/indoors
	maximum_of_type = 2
	cost = 35

/obj/item/ka_modkit/indoors/modify_projectile(obj/projectile/kinetic/K)
	K.pressure_decrease *= modifier


//Trigger Guard

/*
/obj/item/ka_modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed."
	cost = 20
	denied_type = /obj/item/ka_modkit/trigger_guard

/obj/item/ka_modkit/trigger_guard/install(obj/item/gun/projectile/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/ka_modkit/trigger_guard/uninstall(obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_NORMAL
	..()
*/

//Cosmetic

/obj/item/ka_modkit/chassis_mod
	name = "super chassis"
	desc = "Makes your KA yellow. All the fun of having a more powerful KA without actually having a more powerful KA."
	cost = 0
	denied_type = /obj/item/ka_modkit/chassis_mod
	var/chassis_icon = "kineticgun_u"
	var/chassis_name = "super-kinetic accelerator"

/obj/item/ka_modkit/chassis_mod/install(obj/item/gun/projectile/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.icon_state = chassis_icon
		KA.name = chassis_name

/obj/item/ka_modkit/chassis_mod/uninstall(obj/item/gun/projectile/energy/kinetic_accelerator/KA)
	KA.icon_state = initial(KA.icon_state)
	KA.name = initial(KA.name)
	..()

/obj/item/ka_modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_icon = "kineticgun_h"
	chassis_name = "hyper-kinetic accelerator"

/obj/item/ka_modkit/tracer
	name = "white tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a white tracer trail and explosion."
	cost = 0
	denied_type = /obj/item/ka_modkit/tracer
	var/bolt_color = "#FFFFFF"

/obj/item/ka_modkit/tracer/modify_projectile(obj/projectile/kinetic/K)
	K.icon_state = "ka_tracer"
	K.color = bolt_color

/obj/item/ka_modkit/tracer/adjustable
	name = "adjustable tracer bolts"
	desc = "Causes kinetic accelerator bolts to have an adjustable-colored tracer trail and explosion. Use in-hand to change color."

/obj/item/ka_modkit/tracer/adjustable/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	bolt_color = input(user,"","Choose Color",bolt_color) as color|null
