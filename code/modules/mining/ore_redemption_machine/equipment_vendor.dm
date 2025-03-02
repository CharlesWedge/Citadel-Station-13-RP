/**********************Mining Equipment Locker**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/mining_equipment_vendor
	var/icon_deny = "mining-deny"
	var/obj/item/card/id/inserted_id
	var/child = FALSE//To tell topic() to bypass this iteration of it
	var/list/prize_list = list(
		new /datum/data/mining_equipment("1 Marker Beacon",				/obj/item/stack/marker_beacon,										10),
		new /datum/data/mining_equipment("10 Marker Beacons",			/obj/item/stack/marker_beacon/ten,									100),
		new /datum/data/mining_equipment("30 Marker Beacons",			/obj/item/stack/marker_beacon/thirty,								300),
		new /datum/data/mining_equipment("Whiskey",						/obj/item/reagent_containers/food/drinks/bottle/whiskey,		125),
		new /datum/data/mining_equipment("Absinthe",					/obj/item/reagent_containers/food/drinks/bottle/absinthe,	125),
		new /datum/data/mining_equipment("Hard Root Beer",				/obj/item/reagent_containers/food/drinks/bottle/small/alcsassafras,	70),
		new /datum/data/mining_equipment("Special Blend Whiskey",						/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey,		250),
		new /datum/data/mining_equipment("Random Booze",						/obj/random/alcohol,		125),
		new /datum/data/mining_equipment("Cigar",						/obj/item/clothing/mask/smokable/cigarette/cigar/havana,			150),
		new /datum/data/mining_equipment("Root Beer",					/obj/item/reagent_containers/food/drinks/bottle/small/sassafras, 50),
		new /datum/data/mining_equipment("Sarsaparilla",				/obj/item/reagent_containers/food/drinks/bottle/small/sarsaparilla, 50),
		new /datum/data/mining_equipment("Soap",						/obj/item/soap/nanotrasen,									200),
		new /datum/data/mining_equipment("Laser Pointer",				/obj/item/laser_pointer,										900),
		new /datum/data/mining_equipment("Geiger Counter",				/obj/item/geiger_counter,											750),
		new /datum/data/mining_equipment("Plush Toy",					/obj/random/plushie,												300),
		new /datum/data/mining_equipment("GPS Device",					/obj/item/gps/mining,										100),
		new /datum/data/mining_equipment("Portable Fuel Can",			/obj/item/reagent_containers/portable_fuelcan,		250),
		// TODO new /datum/data/mining_equipment("Advanced Scanner",	/obj/item/t_scanner/adv_mining_scanner,						800),
		new /datum/data/mining_equipment("Fulton Beacon",				/obj/item/fulton_core,												500),
		new /datum/data/mining_equipment("Shelter Capsule",				/obj/item/survivalcapsule,									500),
		// TODO new /datum/data/mining_equipment("Explorer's Webbing",	/obj/item/storage/belt/mining,										500),
		new /datum/data/mining_equipment("500 Point Transfer Card",			/obj/item/card/mining_point_card,							500),
		new /datum/data/mining_equipment("1000 Point Transfer Card",			/obj/item/card/mining_point_card/onethou,							1000),
		new /datum/data/mining_equipment("2000 Point Transfer Card",			/obj/item/card/mining_point_card/twothou,							2000),
		new /datum/data/mining_equipment("3000 Point Transfer Card",			/obj/item/card/mining_point_card/threethou,							3000),
		new /datum/data/mining_equipment("Umbrella",					/obj/item/melee/umbrella/random,								200),
		new /datum/data/mining_equipment("Survival Medipen",			/obj/item/reagent_containers/hypospray/autoinjector/miner,	500),
		new /datum/data/mining_equipment("Mini-Translocator",			/obj/item/perfect_tele/one_beacon,							1200),
		// new /datum/data/mining_equipment("Kinetic Crusher",			/obj/item/twohanded/required/kinetic_crusher,						750),
		new /datum/data/mining_equipment("Kinetic Accelerator",			/obj/item/gun/projectile/energy/kinetic_accelerator,					900),
		new /datum/data/mining_equipment("Resonator",					/obj/item/resonator,												900),
		new /datum/data/mining_equipment("Fulton Pack",					/obj/item/extraction_pack,											1200),
		new /datum/data/mining_equipment("Wormhole Fulton Pack",					/obj/item/extraction_pack/wormhole,											1750),
		new /datum/data/mining_equipment("Silver Pickaxe",				/obj/item/pickaxe/silver,									1200),
		new /datum/data/mining_equipment("Climbing Pick",				/obj/item/pickaxe/icepick,									2200),
		//new /datum/data/mining_equipment("Mining Conscription Kit",	/obj/item/storage/backpack/duffelbag/mining_conscript,				1000),
		new /datum/data/mining_equipment("Diamond Pickaxe",				/obj/item/pickaxe/diamond,									2000),
		new /datum/data/mining_equipment("Advanced Ore Scanner",				/obj/item/mining_scanner/advanced,										2000),
		new /datum/data/mining_equipment("100 Thalers",					/obj/item/spacecash/c100,									20000),
		new /datum/data/mining_equipment("1000 Thalers",					/obj/item/spacecash/c1000,									200000),
		new /datum/data/mining_equipment("Hardsuit - Control Module",	/obj/item/hardsuit/industrial,									2000),
		new /datum/data/mining_equipment("Hardsuit - Plasma Cutter",		/obj/item/hardsuit_module/device/plasmacutter,						800),
		new /datum/data/mining_equipment("Hardsuit - Drill",				/obj/item/hardsuit_module/device/drill,								5000),
		new /datum/data/mining_equipment("Hardsuit - Ore Scanner",		/obj/item/hardsuit_module/device/orescanner,								1000),
		new /datum/data/mining_equipment("Hardsuit - Material Scanner",	/obj/item/hardsuit_module/vision/material,								500),
		new /datum/data/mining_equipment("Hardsuit - Maneuvering Jets",	/obj/item/hardsuit_module/maneuvering_jets,								1250),
		new /datum/data/mining_equipment("Hardsuit - Intelligence Storage",	/obj/item/hardsuit_module/ai_container,								2500),
		new /datum/data/mining_equipment("Hardsuit - Smoke Bomb Deployer",	/obj/item/hardsuit_module/grenade_launcher/smoke,					2000),
		new /datum/data/mining_equipment("Industrial Equipment - Phoron Bore",	/obj/item/gun/projectile/magnetic/matfed,						3000),
		new /datum/data/mining_equipment("Industrial Equipment - Sheet-Snatcher",/obj/item/storage/bag/sheetsnatcher,				500),
		new /datum/data/mining_equipment("Repurposed Equipment - Mining Carbine",	/obj/item/gun/projectile/energy/gun/miningcarbine,						5000),
		new /datum/data/mining_equipment("Digital Tablet - Standard",	/obj/item/modular_computer/tablet/preset/custom_loadout/standard,	500),
		new /datum/data/mining_equipment("Digital Tablet - Advanced",	/obj/item/modular_computer/tablet/preset/custom_loadout/advanced,	1000),
		new /datum/data/mining_equipment("Super Resonator",				/obj/item/resonator/upgraded,										2500),
		new /datum/data/mining_equipment("Jump Boots",					/obj/item/clothing/shoes/bhop,										2500),
		new /datum/data/mining_equipment("Luxury Shelter Capsule",		/obj/item/survivalcapsule/luxury,							3100),
		new /datum/data/mining_equipment("KA White Tracer Rounds",		/obj/item/ka_modkit/tracer,								125),
		new /datum/data/mining_equipment("KA Adjustable Tracer Rounds",	/obj/item/ka_modkit/tracer/adjustable,					175),
		new /datum/data/mining_equipment("KA Super Chassis",			/obj/item/ka_modkit/chassis_mod,							250),
		new /datum/data/mining_equipment("KA Hyper Chassis",			/obj/item/ka_modkit/chassis_mod/orange,					300),
		new /datum/data/mining_equipment("KA Range Increase",			/obj/item/ka_modkit/range,								1000),
		new /datum/data/mining_equipment("KA Cooldown Decrease",		/obj/item/ka_modkit/cooldown,							1200),
		new /datum/data/mining_equipment("KA Capacity Increase",		/obj/item/ka_modkit/capacity,							1500),
		new /datum/data/mining_equipment("KA Holster",				/obj/item/clothing/accessory/holster/waist/kinetic_accelerator,			350),
		new /datum/data/mining_equipment("Fine Excavation Kit - Chisels",/obj/item/storage/excavation,								500),
		new /datum/data/mining_equipment("Fine Excavation Kit - Measuring Tape",/obj/item/measuring_tape,							125),
		new /datum/data/mining_equipment("Fine Excavation Kit - Hand Pick",/obj/item/pickaxe/hand,									375),
		new /datum/data/mining_equipment("Explosive Excavation Kit - Plastic Charge",/obj/item/plastique/seismic/locked,					1500),
		new /datum/data/mining_equipment("Injector (L) - Glucose",/obj/item/reagent_containers/hypospray/autoinjector/biginjector/glucose,	500),
		new /datum/data/mining_equipment("Injector (L) - Panacea",/obj/item/reagent_containers/hypospray/autoinjector/biginjector/purity,	500),
		new /datum/data/mining_equipment("Injector (L) - Trauma",/obj/item/reagent_containers/hypospray/autoinjector/biginjector/brute,	500),
		new /datum/data/mining_equipment("Nanopaste Tube",				/obj/item/stack/nanopaste,											1000),
		new /datum/data/mining_equipment("Defense Equipment - Smoke Bomb",/obj/item/grenade/smokebomb,								100),
		new /datum/data/mining_equipment("Defense Equipment - Razor Drone Deployer",/obj/item/grenade/spawnergrenade/manhacks/station/locked,	1000),
		new /datum/data/mining_equipment("Defense Equipment - Sentry Drone Deployer",/obj/item/grenade/spawnergrenade/ward,			1500),
		new /datum/data/mining_equipment("Defense Equipment - Plasteel Machete",	/obj/item/clothing/accessory/holster/machete/occupied,				500),
		new /datum/data/mining_equipment("Defense Equipment - Kinetic Dagger",	/obj/item/kinetic_crusher/dagger,				1200),
		new /datum/data/mining_equipment("Bar Shelter Capsule",		/obj/item/survivalcapsule/luxurybar,							10000)
		)

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_vendor/power_change()
	var/old_stat = machine_stat
	..()
	if(old_stat != machine_stat)
		update_icon()
	if(inserted_id && !powered())
		visible_message("<span class='notice'>The ID slot indicator light flickers on \the [src] as it spits out a card before powering down.</span>")
		inserted_id.forceMove(get_turf(src))

/obj/machinery/mineral/equipment_vendor/update_icon()
	if(panel_open)
		icon_state = "[initial(icon_state)]-open"
	else if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/mineral/equipment_vendor/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(..())
		return
	interact(user)

/obj/machinery/mineral/equipment_vendor/attack_ghost(mob/user)
	. = ..()
	interact(user)

/obj/machinery/mineral/equipment_vendor/interact(mob/user)
	user.set_machine(src)

	var/dat
	dat +="<div class='statusDisplay'>"
	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];choice=eject'>Eject ID.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=\ref[src];choice=insert'>Insert ID.</A><br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='100%'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"
	var/datum/browser/popup = new(user, "miningvendor", "Mining Equipment Vendor", 400, 600)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/equipment_vendor/Topic(href, href_list)
	if(..())
		return 1
	if(child)
		return 0
	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				to_chat(usr, "<span class='notice'>You eject the ID from [src]'s card slot.</span>")
				if(ishuman(usr))
					usr.put_in_hands_or_drop(inserted_id)
					inserted_id = null
				else
					inserted_id.forceMove(get_turf(src))
					inserted_id = null
		else if(href_list["choice"] == "insert")
			var/obj/item/card/id/I = usr.get_active_held_item()
			if(istype(I) && !inserted_id)
				if(!usr.attempt_insert_item_for_installation(I, src))
					return
				inserted_id = I
				interact(usr)
				to_chat(usr, "<span class='notice'>You insert the ID into [src]'s card slot.</span>")
			else
				to_chat(usr, "<span class='warning'>No valid ID.</span>")
				flick(icon_deny, src)

	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
			if (!prize || !(prize in prize_list))
				to_chat(usr, "<span class='warning'>Error: Invalid choice!</span>")
				flick(icon_deny, src)
				return
			if(prize.cost > inserted_id.mining_points)
				to_chat(usr, "<span class='warning'>Error: Insufficent points for [prize.equipment_name]!</span>")
				flick(icon_deny, src)
			else
				inserted_id.mining_points -= prize.cost
				to_chat(usr, "<span class='notice'>[src] clanks to life briefly before vending [prize.equipment_name]!</span>")
				new prize.equipment_path(drop_location())
		else
			to_chat(usr, "<span class='warning'>Error: Please insert a valid ID!</span>")
			flick(icon_deny, src)
	updateUsrDialog()

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, I))
		updateUsrDialog()
		return CLICKCHAIN_DO_NOT_PROPAGATE
	if(default_part_replacement(user, I))
		return CLICKCHAIN_DO_NOT_PROPAGATE
	if(default_deconstruction_crowbar(user, I))
		return CLICKCHAIN_DO_NOT_PROPAGATE
	if(istype(I, /obj/item/mining_voucher))
		if(!powered())
			return
		RedeemVoucher(I, user)
		return CLICKCHAIN_DO_NOT_PROPAGATE
	if(istype(I,/obj/item/card/id))
		if(!powered())
			return CLICKCHAIN_DO_NOT_PROPAGATE
		else if(!inserted_id)
			if(!user.attempt_insert_item_for_installation(I, src))
				return
			inserted_id = I
			interact(user)
		return CLICKCHAIN_DO_NOT_PROPAGATE
	..()

/obj/machinery/mineral/equipment_vendor/drop_products(method, atom/where)
	. = ..()
	inserted_id?.forceMove(where)
	inserted_id = null

/obj/machinery/mineral/equipment_vendor/proc/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in list("Kinetic Accelerator", "Resonator", "Mining Drone", "Advanced Scanner", "Crusher")
	if(!selection || !Adjacent(redeemer) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Kinetic Accelerator")
			new /obj/item/gun/projectile/energy/kinetic_accelerator(drop_location)
		if("Resonator")
			new /obj/item/resonator(drop_location)
	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/proc/new_prize(var/name, var/path, var/cost) // Generic proc for adding new entries. Good for abusing for FUN and PROFIT.
	if(!cost)
		cost = 100
	if(!path)
		path = /obj/item/stack/marker_beacon
	if(!name)
		name = "Generic Entry"
	prize_list += new /datum/data/mining_equipment(name, path, cost)

/obj/machinery/mineral/equipment_vendor/legacy_ex_act(severity, target)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(prob(50 / severity) && severity < 3)
		qdel(src)
