/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A disposable syringe. A small sticker on the side reminds you to dispose after one use."
	icon = 'icons/obj/medical/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	materials_base = list(MAT_GLASS = 150, MAT_STEEL = 250)
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 15
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_EARS
	damage_mode = DAMAGE_MODE_SHARP
	integrity_flags = INTEGRITY_ACIDPROOF
	rad_flags = RAD_NO_CONTAMINATE
	item_flags = ITEM_NO_BLUDGEON | ITEM_ENCUMBERS_WHILE_HELD | ITEM_EASY_LATHE_DECONSTRUCT
	var/mode = SYRINGE_DRAW
	var/image/filling //holds a reference to the current filling overlay
	var/visible_name = "a syringe"
	var/time = 30
	var/drawing = 0
	drop_sound = 'sound/items/drop/glass.ogg'
	pickup_sound = 'sound/items/pickup/glass.ogg'

/obj/item/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/syringe/pickup(mob/user, flags, atom/oldLoc)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user, flags, atom/newLoc)
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user, datum/event_args/actor/actor)
	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/reagent_containers/syringe/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attackby(obj/item/I as obj, mob/user as mob)
	return

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	if(!(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY) || !target.reagents)
		return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, "<span class='warning'>This syringe is broken!</span>")
		return

	if(user.a_intent == INTENT_HARM && ismob(target))
		if((MUTATION_CLUMSY in user.mutations) && prob(50))
			target = user
		syringestab(target, user)
		return

	var/injtime = time // Calculated 'true' injection time (as added to by hardsuits and whatnot), 66% of this goes to warmup, then every 33% after injects 5u
	switch(mode)
		if(SYRINGE_DRAW)
			if(!reagents.available_volume())
				to_chat(user, "<span class='warning'>The syringe is full.</span>")
				mode = SYRINGE_INJECT
				return

			if(ismob(target))//Blood!
				if(reagents.has_reagent("blood"))
					to_chat(user, "<span class='notice'>There is already a blood sample in this syringe.</span>")
					return

				if(istype(target, /mob/living/carbon))
					var/amount = reagents.available_volume()
					var/mob/living/carbon/T = target
					if(!T.dna)
						to_chat(user, "<span class='warning'>You are unable to locate any blood. (To be specific, your target seems to be missing their DNA datum).</span>")
						return
					if(MUTATION_NOCLONE in T.mutations) //target done been et, no more blood in him
						to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
						return

					if(T.isSynthetic())
						to_chat(user, "<span class = 'warning'>You can't draw blood from a synthetic!</span>")
						return

					if(drawing)
						to_chat(user, "<span class='warning'>You are already drawing blood from [T.name].</span>")
						return

					drawing = 1
					if(istype(T, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = T
						if(H.species && !H.should_have_organ(O_HEART))
							H.reagents.trans_to_obj(src, amount)
						else
							if(ismob(H) && H != user)
								if(!do_mob(user, target, time))
									drawing = 0
									return
							T.take_blood_legacy(src, amount)
							drawing = 0
					else
						if(!do_mob(user, target, time))
							drawing = 0
							return
						T.take_blood_legacy(src,amount)
						drawing = 0

					to_chat(user, "<span class='notice'>You take a blood sample from [target].</span>")
					for(var/mob/O in viewers(4, user))
						O.show_message("<span class='notice'>[user] takes a blood sample from [target].</span>", 1)
						T.custom_pain(SPAN_WARNING("The needle stings a bit."), 2, TRUE)

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='notice'>[target] is empty.</span>")
					return

				if(!target.is_open_container() && !istype(target, /obj/structure/reagent_dispensers) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/reagent_containers/food))
					to_chat(user, "<span class='notice'>You cannot directly remove reagents from this object.</span>")
					return

				var/trans = target.reagents.trans_to_obj(src, amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You fill the syringe with [trans] units of the solution.</span>")
				update_icon()


			if(!reagents.available_volume())
				mode = SYRINGE_INJECT
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "<span class='notice'>The syringe is empty.</span>")
				mode = SYRINGE_DRAW
				return
			if(istype(target, /obj/item/implantcase/chem))
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/smokable/cigarette) && !istype(target, /obj/item/storage/fancy/cigarettes))
				to_chat(user, "<span class='notice'>You cannot directly fill this object.</span>")
				return
			if(!target.reagents.available_volume())
				to_chat(user, "<span class='notice'>[target] is full.</span>")
				return

			var/mob/living/carbon/human/H = target
			var/obj/item/organ/external/affected
			if(istype(H))
				affected = H.get_organ(user.zone_sel.selecting)
				if(!affected)
					to_chat(user, "<span class='danger'>\The [H] is missing that limb!</span>")
					return
				else if(affected.robotic >= ORGAN_ROBOT)
					to_chat(user, "<span class='danger'>You cannot inject a robotic limb.</span>")
					return
				else if(affected.behaviour_flags & BODYPART_NO_INJECT)
					to_chat(user, "<span class='danger'>You cannot inject this limb.</span>")
					return

			var/cycle_time = injtime*0.33 //33% of the time slept between 5u doses
			var/warmup_time = 0	//0 for containers
			if(ismob(target))
				warmup_time = cycle_time //If the target is another mob, this gets overwritten

			if(ismob(target) && target != user)
				warmup_time = injtime*0.66 //66% of the time is warmup

				if(istype(H))
					if(H.wear_suit)
						if(istype(H.wear_suit, /obj/item/clothing/suit/space))
							injtime = injtime * 2
					if(!H.can_inject(user, 1))
						return

				else if(isliving(target))

					var/mob/living/M = target
					if(!M.can_inject(user, 1))
						return

				if(injtime == time)
					user.visible_message("<span class='warning'>[user] is trying to inject [target] with [visible_name]!</span>","<span class='notice'>You begin injecting [target] with [visible_name].</span>")
				else
					user.visible_message("<span class='warning'>[user] begins hunting for an injection port on [target]'s suit!</span>","<span class='notice'>You begin hunting for an injection port on [target]'s suit!</span>")

			//The warmup
			user.setClickCooldownLegacy(DEFAULT_QUICK_COOLDOWN)
			if(!do_after(user,warmup_time,target))
				return

			var/trans = 0
			var/contained = reagentlist()
			if(ismob(target))
				while(reagents.total_volume)
					trans += reagents.trans_to_mob(target, amount_per_transfer_from_this, CHEM_INJECT)
					update_icon()
					if(!reagents.total_volume || !do_after(user,cycle_time,target))
						break
			else
				trans += reagents.trans_to_obj(target, amount_per_transfer_from_this)

			if (reagents.total_volume <= 0 && mode == SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

			if(trans)
				to_chat(user, "<span class='notice'>You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units.</span>")
				if(ismob(target))
					add_attack_logs(user,target,"Injected with [src.name] containing [contained], trasferred [trans] units")
					H.custom_pain(SPAN_WARNING("The needle stings a bit."), 2, TRUE)
			else
				to_chat(user, "<span class='notice'>The syringe is empty.</span>")

			if(ismob(target) && affected)
				dirty(target,affected) //Reactivated this feature per feedback and constant requests from players. If this proves to be utter crap we'll adjust the numbers before removing outright

	return

/obj/item/reagent_containers/syringe/proc/syringestab(mob/living/carbon/target as mob, mob/living/carbon/user as mob)
	if(istype(target, /mob/living/carbon/human))

		var/mob/living/carbon/human/H = target

		var/target_zone = ran_zone(check_zone(user.zone_sel.selecting, target))
		var/obj/item/organ/external/affecting = H.get_organ(target_zone)

		if (!affecting || affecting.is_stump())
			to_chat(user, "<span class='danger'>They are missing that limb!</span>")
			return

		var/hit_area = affecting.name

		if(user != target)
			var/list/shieldcall_results = target.run_mob_defense(
				7,
				attack_type = ATTACK_TYPE_MELEE,
				attack_source = new /datum/event_args/actor/clickchain(user),
				hit_zone = hit_area,
			)
			if(shieldcall_results[SHIELDCALL_ARG_FLAGS] & SHIELDCALL_FLAG_ATTACK_BLOCKED)
				return

		if (target != user && H.legacy_mob_armor(target_zone, "melee") > 5 && prob(50))
			for(var/mob/O in viewers(world.view, user))
				O.show_message(SPAN_BOLDDANGER("[user] tries to stab [target] in \the [hit_area] with [name], but the attack is deflected by armor!"), SAYCODE_TYPE_VISIBLE)
			qdel(src)
			add_attack_logs(user,target,"Syringe harmclick")
			return

		user.visible_message("<span class='danger'>[user] stabs [target] in \the [hit_area] with [src.name]!</span>")
		affecting.inflict_bodypart_damage(
			brute = 3,
			damage_mode = DAMAGE_MODE_SHARP,
			weapon_descriptor = "a needle",
		)
	else
		user.visible_message("<span class='danger'>[user] stabs [target] with [src.name]!</span>")
		target.take_random_targeted_damage(brute = 3)// 7 is the same as crowbar punch

	var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
	var/contained = reagents.get_reagents()
	var/trans = reagents.trans_to_mob(target, syringestab_amount_transferred, CHEM_INJECT)
	if(isnull(trans)) trans = 0
	add_attack_logs(user,target,"Stabbed with [src.name] containing [contained], trasferred [trans] units")
	break_syringe(target, user)

/obj/item/reagent_containers/syringe/proc/break_syringe(mob/living/carbon/target, mob/living/carbon/user)
	desc += " It is broken."
	mode = SYRINGE_BROKEN
	if(target)
		add_blood(target)
	if(user)
		add_fingerprint(user)
	update_icon()

/obj/item/reagent_containers/syringe/proc/handle_impact_as_projectile(atom/target, impact_flags, def_zone, efficiency, injected_ptr)
	if(impact_flags & (PROJECTILE_IMPACT_BLOCKED | PROJECTILE_IMPACT_FLAGS_SHOULD_GO_THROUGH))
		return impact_flags
	// TODO: better thickmaterial test
	if(isliving(target))
		var/mob/living/casted = target
		if(casted.can_inject() && reagents)
			*injected_ptr = reagents.trans_to_mob(casted, reagents.total_volume, CHEM_INJECT)
	break_syringe(iscarbon(target) ? target : null)
	return impact_flags
