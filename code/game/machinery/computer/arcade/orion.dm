// *** THE ORION TRAIL ** //

#define ORION_TRAIL_WINTURN 9

//defines in machines.dm

///assoc list, [datum singleton] = weight
GLOBAL_LIST_INIT(orion_events, generate_orion_events())

/proc/generate_orion_events()
	. = list()
	for(var/path in subtypesof(/datum/orion_event))
		var/datum/orion_event/new_event = new path(src)
		.[new_event] = new_event.weight

/obj/machinery/computer/arcade/orion_trail
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"
	icon_state = "arcade1"
	icon_screen = "orion"
	circuit = /obj/item/circuitboard/arcade/orion_trail
	var/busy = FALSE //prevent clickspam that allowed people to ~speedrun~ the game.
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/alive = ORION_STARTING_CREW_COUNT
	var/datum/orion_event/event = null
	var/reason
	var/list/settlers = list("Harry","Larry","Bob")
	var/list/settlermoods = list()
	var/list/events
	//actual amount of lings on board
	var/lings_aboard = 0
	//if the game should pretend there are lings on board.
	var/lings_suspected = FALSE
	var/spaceport_raided = FALSE
	var/gameStatus = ORION_STATUS_START

	var/obj/item/radio/radio
	var/list/gamers = list()
	var/killed_crew = 0

/obj/machinery/computer/arcade/orion_trail/Initialize()
	. = ..()
	radio = new /obj/item/radio(src)
	radio.listening = 0
	setup_events()

/obj/machinery/computer/arcade/orion_trail/proc/setup_events()
	events = GLOB.orion_events

/obj/machinery/computer/arcade/orion_trail/Destroy()
	QDEL_NULL(radio)
	events = null
	return ..()

/obj/machinery/computer/arcade/orion_trail/kobayashi
	name = "Kobayashi Maru control computer"
	desc = "A test for cadets."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp"
	//kobatashi has a smaller list of events, so we copy from the global list and cut whatever isn't here
	var/list/event_whitelist = list(
		/datum/orion_event/raiders,
		/datum/orion_event/flux,
		/datum/orion_event/illness,
		/datum/orion_event/engine_part,
		/datum/orion_event/electronic_part,
		/datum/orion_event/hull_part,
		/datum/orion_event/space_port,
		/datum/orion_event/space_port/tau_ceti,
		/datum/orion_event/space_port_raid,
		/datum/orion_event/black_hole,
		/datum/orion_event/black_hole_death,
	)
	prize_override = list(/obj/item/paper/fluff/holodeck/trek_diploma = 1)
	settlers = list("Kirk","Worf","Gene")

/obj/machinery/computer/arcade/orion_trail/kobayashi/setup_events()
	events = GLOB.orion_events.Copy()
	for(var/datum/orion_event/event as anything in events)
		if(!(event.type in event_whitelist))
			events.Remove(event)

/obj/machinery/computer/arcade/orion_trail/proc/newgame()
	// Set names of settlers in crew
	var/mob/living/carbon/player = usr
	var/player_crew_name = player.real_name
	settlers = list()
	for(var/i in 1 to ORION_STARTING_CREW_COUNT - 1) //one reserved to be YOU
		add_crewmember(update = FALSE)
	add_crewmember("[player_crew_name]")
	// Re-set items to defaults
	engine = 1
	hull = 1
	electronics = 1
	food = 80
	fuel = 60
	alive = ORION_STARTING_CREW_COUNT
	turns = 1
	event = null
	gameStatus = ORION_STATUS_NORMAL
	lings_aboard = 0
	lings_suspected = FALSE
	killed_crew = 0

	//spaceport junk
	spaceport_raided = FALSE

/obj/machinery/computer/arcade/orion_trail/proc/report_player(mob/gamer)
	if(gamers[gamer] == ORION_GAMER_GIVE_UP)
		return // enough harassing them

	if(gamers[gamer] == ORION_GAMER_PAMPHLET)
		src.audible_message("<b>\The [src]</b> says, 'WARNING: Continued antisocial behavior detected: Dispensing self-help literature.'")
		new /obj/item/paper/pamphlet/violent_video_games(drop_location())
		gamers[gamer]--
		return

	if(!(gamer in gamers))
		gamers[gamer] = 0

	gamers[gamer]++ // How many times the player has 'prestiged' (massacred their crew)

	if(gamers[gamer] > ORION_GAMER_REPORT_THRESHOLD && prob(20 * gamers[gamer]))

		radio.set_frequency(FREQ_SECURITY)
		radio.talk_into(src, "SECURITY ALERT: Crewmember [gamer] recorded displaying antisocial tendencies in [get_area(src)]. Please watch for violent behavior.", FREQ_SECURITY)

		radio.set_frequency(FREQ_MEDICAL)
		radio.talk_into(src, "PSYCH ALERT: Crewmember [gamer] recorded displaying antisocial tendencies in [get_area(src)]. Please schedule psych evaluation.", FREQ_MEDICAL)

		gamers[gamer] = ORION_GAMER_PAMPHLET //next report send a pamph

		//gamer.client.give_award(/datum/award/achievement/misc/gamer, gamer) // PSYCH REPORT NOTE: patient kept rambling about how they did it for an "achievement", recommend continued holding for observation
		//gamer.mind?.adjust_experience(/datum/skill/gaming, 50) // cheevos make u better

		if(!isnull(data_core.general))
			for(var/datum/data/record/insanity_records in data_core.general)
				if(insanity_records.fields["name"] == gamer.name)
					insanity_records.fields["m_stat"] = "*Unstable*"
					return

/obj/machinery/computer/arcade/orion_trail/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrionGame", name)
		ui.open()

/obj/machinery/computer/arcade/orion_trail/ui_asset_injection(datum/tgui/ui, list/immediate, list/deferred)
	immediate += /datum/asset_pack/spritesheet/moods
	return ..()

/obj/machinery/computer/arcade/orion_trail/ui_data(mob/user, datum/tgui/ui)
	var/list/data = list()
	data["gamestatus"] = gameStatus

	data["engine"] = engine
	data["turns"] = turns
	data["hull"] = hull
	data["electronics"] = electronics
	data["food"] = food
	data["fuel"] = fuel
	data["lings_suspected"] = lings_suspected

	data["eventname"] = event?.name
	data["eventtext"] = event?.text
	data["buttons"] = event?.event_responses

	data["spaceport_raided"] = spaceport_raided

	data["reason"] = reason

	return data

/obj/machinery/computer/arcade/orion_trail/ui_static_data(mob/user, datum/tgui/ui)
	var/list/static_data = list()
	static_data["gamename"] = name
	static_data["emagged"] = obj_flags & OBJ_EMAGGED
	static_data["settlers"] = settlers
	static_data["settlermoods"] = settlermoods
	return static_data

/obj/machinery/computer/arcade/orion_trail/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/gamer = usr
	if(!istype(gamer))
		return

	. = TRUE



	var/gamer_skill_level = 0
	var/gamer_skill = 0
	var/gamer_skill_rands = 0

//	if(gamer?.mind)
//		gamer_skill_level = gamer.mind.get_skill_level(/datum/skill/gaming)
//		gamer_skill = gamer.mind.get_skill_modifier(/datum/skill/gaming, SKILL_PROBS_MODIFIER)
//		gamer_skill_rands = gamer.mind.get_skill_modifier(/datum/skill/gaming, SKILL_RANDS_MODIFIER)

	var/xp_gained = 0

	if(event)
		event.response(src, action)
		if(!settlers.len || food <= 0 || fuel <= 0)
			set_game_over(gamer)
			return
		new_settler_mood() //events shake people up a bit and can also change food
		update_static_data(usr)
		return TRUE
	switch(action)
		if("start_game")
			if(gameStatus != ORION_STATUS_START)
				return
			newgame()
		if("instructions")
			if(gameStatus != ORION_STATUS_START)
				return
			gameStatus = ORION_STATUS_INSTRUCTIONS
		if("back_to_menu") //back to the main menu
			gameStatus = ORION_STATUS_START
			if(gameStatus == ORION_STATUS_GAMEOVER)
				event = null
				reason = null
				food = 80
				fuel = 60
				settlers = list("Harry","Larry","Bob")
		if("continue")
			if(turns >= ORION_TRAIL_WINTURN)
				win(gamer)
				xp_gained += 34
				return
			//gamer.mind.adjust_experience(/datum/skill/gaming, xp_gained+1)
			food -= (alive+lings_aboard)*2
			fuel -= 5
			turns += 1
			//out of supplies, die
			if(food <= 0 || fuel <= 0)
				set_game_over(gamer)
			if(turns == 2 && prob(30-gamer_skill)) //asteroids part of the trip
				encounter_event(/datum/orion_event/hull_part, gamer, gamer_skill, gamer_skill_level, gamer_skill_rands)
				return
			if(turns == 4) //halfway mark
				encounter_event(/datum/orion_event/space_port/tau_ceti, gamer, gamer_skill, gamer_skill_level, gamer_skill_rands)
				return
			if(turns == 7) //black hole part of the trip
				encounter_event(/datum/orion_event/black_hole, gamer, gamer_skill, gamer_skill_level, gamer_skill_rands)
				return
			//an uneventful (get it) turn
			if(prob(25 + gamer_skill))
				return
			encounter_event(null, gamer, gamer_skill, gamer_skill_level)
			if(lings_aboard && (istype(event, /datum/orion_event/changeling_infiltration) || prob(45 + gamer_skill)))
				//upgrade infiltration/whatever else we got to attack right away
				encounter_event(/datum/orion_event/changeling_attack, gamer, gamer_skill, gamer_skill_level, gamer_skill_rands)
		if("random_kill")
			execute_crewmember(gamer)
		if("target_kill")
			execute_crewmember(gamer, params["who"])
		//Spaceport specific interactions
		if("buycrew") //buy a crewmember
			if(!spaceport_raided && food >= 10 && fuel >= 10)
				if(params["odd"])
					//find some silly crewmember name
					add_crewmember(pick(GLOB.ai_names + GLOB.ninja_names + GLOB.commando_names + GLOB.clown_names))
				else
					add_crewmember()
				fuel -= ORION_BUY_CREW_PRICE
				food -= ORION_BUY_CREW_PRICE
				killed_crew-- // I mean not really but you know
		if("sellcrew") //sell a crewmember
			if(!spaceport_raided && settlers.len > 1)
				remove_crewmember()
				fuel += ORION_SELL_CREW_PRICE
				food += ORION_SELL_CREW_PRICE
		if("leave_spaceport")
			gameStatus = ORION_STATUS_NORMAL
			spaceport_raided = FALSE
		if("raid_spaceport")
			spaceport_raided = TRUE
			encounter_event(/datum/orion_event/space_port_raid, gamer, gamer_skill, gamer_skill_level, gamer_skill_rands)
		if("buyparts")
			if(!spaceport_raided && fuel > ORION_TRADE_RATE)
				switch(params["part"])
					if(ORION_BUY_ENGINE_PARTS)
						engine++
					if(ORION_BUY_ELECTRONICS)
						hull++
					if(ORION_BUY_HULL_PARTS)
						electronics++
				fuel -= ORION_TRADE_RATE
		if("trade")
			if(!spaceport_raided)
				switch(params["what"])
					if(ORION_I_WANT_FUEL)
						if(fuel > ORION_TRADE_RATE)
							fuel -= ORION_TRADE_RATE
							food += ORION_TRADE_RATE
					if(ORION_I_WANT_FOOD)
						if(food > ORION_TRADE_RATE)
							fuel += ORION_TRADE_RATE
							food -= ORION_TRADE_RATE
	add_fingerprint(gamer)

/**
 * pickweights a new event, sets event var as it. it then preps the event if it needs it
 *
 * giving a path argument will instead find that instanced datum instead of pickweighting. Used in events that follow from events.
 * Arguments:
 * * path: if we want a specific event, this is the path of the wanted one
 * * gamer: person using the arcade, used in emag effects
 * * gamer_skill: gaming skill of the player
 * * gamer_skill_level: gaming skill level of the player
 * * gamer_skill_rands: See above but for random chances, you can just look at gaming skill to see how it chalks that up
 */
/obj/machinery/computer/arcade/orion_trail/proc/encounter_event(path, gamer, gamer_skill, gamer_skill_level, gamer_skill_rands)
	if(!path)
		event = pickweightAllowZero(events)
	else
		for(var/datum/orion_event/instance as anything in events)
			if(instance.type == path)
				event = instance
				break
	if(!event)
		CRASH("Woah, hey! we could not find the specified event \"[path]\"! Add it to the events list, numb nuts!")
	event.on_select(src, gamer_skill, gamer_skill_level, gamer_skill_rands)
	if(obj_flags & OBJ_EMAGGED)
		event.emag_effect(src, gamer)

/obj/machinery/computer/arcade/orion_trail/proc/set_game_over(user, given_reason)
	gameStatus = ORION_STATUS_GAMEOVER
	event = null
	reason = given_reason || death_reason(user)

/obj/machinery/computer/arcade/orion_trail/proc/death_reason(mob/living/carbon/gamer)
	var/reason
	if(!settlers.len)
		reason = "Your entire crew died, and your ship joins the fleet of ghost-ships littering the galaxy."
	else
		if(food <= 0)
			reason = "You ran out of food and starved."
			if(obj_flags & OBJ_EMAGGED)
				gamer.set_nutrition(0) //yeah you pretty hongry
				to_chat(gamer, "<span class='userdanger'>Your body instantly contracts to that of one who has not eaten in months. Agonizing cramps seize you as you fall to the floor.</span>")
		if(fuel <= 0)
			reason = "You ran out of fuel, and drift, slowly, into a star."
			if(obj_flags & OBJ_EMAGGED)
				gamer.adjust_fire_stacks(5)
				gamer.IgniteMob() //flew into a star, so you're on fire
				to_chat(gamer, "<span class='userdanger'>You feel an immense wave of heat emanate from the arcade machine. Your skin bursts into flames.</span>")

	if(obj_flags & OBJ_EMAGGED)
		to_chat(gamer, "<span class='userdanger'>You're never going to make it to Orion...</span>")
		gamer.death()
		obj_flags &= ~OBJ_EMAGGED //removes the emagged status after you lose
		gameStatus = ORION_STATUS_START
		name = "The Orion Trail"
		desc = "Learn how our ancestors got to Orion, and have fun in the process!"

	//gamer?.mind?.adjust_experience(/datum/skill/gaming, 10)//learning from your mistakes is the first rule of roguelikes
	return reason

//Add Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/add_crewmember(specific = "", update = TRUE)
	var/newcrew = ""
	if(specific)
		newcrew = specific
	else
		if(prob(50))
			newcrew = pick(GLOB.first_names_male)
		else
			newcrew = pick(GLOB.first_names_female)
	if(newcrew)
		settlers += newcrew
		alive++
	if(update)
		new_settler_mood()//new faces!
		update_static_data(usr)
	return newcrew


//Remove Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/remove_crewmember(specific = "", dont_remove = "", update = TRUE)
	var/list/safe_to_remove = settlers
	var/removed = ""
	if(dont_remove)
		safe_to_remove -= dont_remove
	if(specific && specific != dont_remove)
		safe_to_remove = list(specific)
	removed = pick(safe_to_remove)

	if(removed)
		if(lings_aboard && prob(40*lings_aboard)) //if there are 2 lings you're twice as likely to get one, obviously
			lings_aboard = max(0,--lings_aboard)
		settlers -= removed
		alive--
	if(update)
		new_settler_mood()//bro, i...
		update_static_data(usr)
	return removed

/**
 * Crewmember executed code, targeted when there are no lings and untargeted when there are some
 * If there was no suspected lings (aka random shots) this is just murder and counts towards killed crew
 *
 * Arguments:
 * * gamer: carbon that may need emag effects applied
 */
/obj/machinery/computer/arcade/orion_trail/proc/execute_crewmember(mob/living/carbon/gamer, target)
	var/sheriff = remove_crewmember(target) //I shot the sheriff
	if(target)
		killed_crew += 1 //if there was no suspected lings, this is just plain murder
	gamer.playsound_local(get_turf(src) ,'sound/weapons/Gunshot_deagle.ogg', 50, TRUE)
	if(!settlers.len || !alive)
		src.audible_message("<b>\The [src]</b> says, 'The last crewmember [sheriff], shot themselves, GAME OVER!'")
		if(obj_flags & OBJ_EMAGGED)
			gamer.death()
		set_game_over(gamer, "Your last pioneer committed suicide.")
		if(killed_crew >= ORION_STARTING_CREW_COUNT)
			//gamer.mind?.adjust_experience(/datum/skill/gaming, -15)//no cheating by spamming game overs
			report_player(gamer)
	else if(obj_flags & OBJ_EMAGGED)
		if(findtext(gamer.name, sheriff))
			src.audible_message("<b>\The [src]</b> says, 'The crew of the ship chose to kill [gamer]!'")
			gamer.death()

/**
 * Creates a new mood icon for each settler
 *
 * Things that effect mood:
 * * Pioneer count
 * * Low food
 * * Low parts
 * * Sometimes they're just a bit happier or sadder
 * Arguments:
 * * None!
 */
/obj/machinery/computer/arcade/orion_trail/proc/new_settler_mood()
	settlermoods.Cut()
	for(var/i in 1 to settlers.len)
		var/food_mood = food >= 15
		var/supply_mood = -2
		if(hull)
			supply_mood++
		if(electronics)
			supply_mood++
		if(engine)
			supply_mood++
		var/changing_mood = 0
		if(prob(60)) //sometimes they just feel better or worse
			changing_mood = rand(-1,1)
		settlermoods[settlers[i]] += max(settlers.len + food_mood + supply_mood + changing_mood, 1)
		if(lings_suspected) //lings ruin any good mood
			settlermoods[settlers[i]] = min(settlermoods[settlers[i]], 3)

/obj/machinery/computer/arcade/orion_trail/proc/win(mob/user)
	gameStatus = ORION_STATUS_START
	src.audible_message("<b>\The [src]</b> says, 'Congratulations, you made it to Orion!'")
	if(obj_flags & OBJ_EMAGGED)
		new /obj/item/orion_ship(loc)
		message_admins("[ADMIN_LOOKUPFLW(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
		log_game("[key_name(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
	else
		prizevend(user)
	obj_flags &= ~OBJ_EMAGGED
	name = initial(name)
	desc = initial(desc)

/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
	if(obj_flags & OBJ_EMAGGED)
		return
	to_chat(user, SPAN_NOTICE("You override the cheat code menu and skip to Cheat #[rand(1, 50)]: Realism Mode."))
	name = "The Orion Trail: Realism Edition"
	desc = "Learn how our ancestors got to Orion, and try not to die in the process!"
	newgame()
	obj_flags |= OBJ_EMAGGED

/mob/living/simple_mob/hostile/humanoid/orion
	name = "spaceport security"
	desc = "Premier corporate security forces for all spaceports found along the Orion Trail."
	loot_list = list()
	//del_on_death = TRUE

/obj/item/orion_ship
	name = "model settler ship"
	desc = "A model spaceship, it looks like those used back in the day when travelling to Orion! It even has a miniature FX-293 reactor, which was renowned for its instability and tendency to explode..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ship"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE //if the ship is on

/obj/item/orion_ship/examine(mob/user, dist)
	if(!active)
		. += SPAN_NOTICE("There's a little switch on the bottom. It's flipped down.")
	else
		. += SPAN_NOTICE("There's a little switch on the bottom. It's flipped up.")

/obj/item/orion_ship/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(active)
		return

	message_admins("[key_name_admin(usr)] primed an explosive Orion ship for detonation.")
	log_game("[key_name(usr)] primed an explosive Orion ship for detonation.")

	to_chat(user, SPAN_WARNING( "You flip the switch on the underside of [src]."))
	active = 1
	src.visible_message(SPAN_NOTICE("[src] softly beeps and whirs to life!"))
	src.audible_message("<b>\The [src]</b> says, 'This is ship ID #[rand(1,1000)] to Orion Port Authority. We're coming in for landing, over.'")
	sleep(20)
	src.visible_message(SPAN_WARNING( "[src] begins to vibrate..."))
	src.audible_message("<b>\The [src]</b> says, 'Uh, Port? Having some issues with our reactor, could you check it out? Over.'")
	sleep(30)
	src.audible_message("<b>\The [src]</b> says, 'Oh, God! Code Eight! CODE EIGHT! IT'S GONNA BL-'")
	sleep(3.6)
	src.visible_message(SPAN_DANGER("[src] explodes!"))
	explosion(src.loc, 0,0,2)
	qdel(src)

#undef ORION_TRAIL_WINTURN
