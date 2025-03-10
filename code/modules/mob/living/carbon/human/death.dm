/mob/living/carbon/human/gib()
	//Drop the NIF, they're expensive, why not recover them? Also important for prometheans.
	if(nif)
		var/obj/item/nif/deadnif = nif //Unimplant removes the reference on the mob
		deadnif.unimplant(src)
		deadnif.forceMove(drop_location())
		deadnif.throw_at_old(get_edge_target_turf(src,pick(GLOB.alldirs)), rand(1,3), round(30/deadnif.w_class))
		deadnif.wear(10) //Presumably it's gone through some shit if they got gibbed?

	if(vr_holder)
		exit_vr()
		// Delete the link, because this mob won't be around much longer
		vr_holder.vr_link = null

	if(vr_link)
		vr_link.exit_vr()
		vr_link.vr_holder = null
		vr_link = null

	for(var/obj/item/organ/I in internal_organs)
		I.removed(src, TRUE)
		if(istype(loc,/turf))
			I.throw_at_old(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),30)

	//mirror should drop on gib
	if(mirror)
		mirror.forceMove(drop_location())
		mirror.throw_at_old(get_edge_target_turf(src,pick(GLOB.alldirs)), rand(1,3), round(30/mirror.w_class))

	for(var/obj/item/organ/external/E in src.organs)
		E.droplimb(0,DROPLIMB_EDGE,1)

	sleep(1)

	for(var/obj/item/I in get_equipped_items(TRUE, TRUE))
		drop_item_to_ground(I, INV_OP_FORCE)
		I.throw_at_old(get_edge_target_turf(src,pick(GLOB.alldirs)), rand(1,3), round(30/I.w_class))

	..(species.gibbed_anim) // uses the default mob.dmi file for these, so we only need to specify the first argument
	gibs(loc, dna, null, species.get_flesh_colour(src), species.get_blood_colour(src))

/mob/living/carbon/human/dust()

	//mirror should drop on dust
	if(mirror)
		mirror.forceMove(drop_location())
		mirror = null

	if(species)
		return ..(species.dusted_anim, species.remains_type)
	else
		return ..()

/mob/living/carbon/human/ash()

	//mirror should drop on ash
	if(mirror)
		mirror.forceMove(drop_location())

	if(species)
		..(species.dusted_anim)
	else
		..()

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return

	update_hud_med_health()
	update_hud_med_status()

	//Handle species-specific deaths.
	species.handle_death(src, gibbed)
	animate_tail_stop()
	stop_flying()

	//Handle snowflake ling stuff.
	if(mind && mind.changeling)
		// If the ling is capable of revival, don't allow them to see deadchat.
		if(mind.changeling.chem_charges >= CHANGELING_STASIS_COST)
			if(mind.changeling.max_geneticpoints >= 0) // Absorbed lings don't count, as they can't revive.
				forbid_seeing_deadchat = TRUE

	//Handle brain slugs.
	var/obj/item/organ/external/Hd = get_organ(BP_HEAD)
	var/mob/living/simple_mob/animal/borer/B

	if(Hd)
		for(var/I in Hd.implants)
			if(istype(I,/mob/living/simple_mob/animal/borer))
				B = I
	if(B)
		if(!B.ckey && ckey && B.controlling)
			transfer_client_to(B)
			B.controlling = 0
		if(B.host_brain.ckey)
			B.host_brain.transfer_client_to(src)
			B.host_brain.name = "host brain"
			B.host_brain.real_name = "host brain"

		remove_verb(src, /mob/living/carbon/proc/release_control)

	callHook("death", list(src, gibbed))

	if(!gibbed && species.death_sound)
		playsound(loc, species.death_sound, 80, 1, 1)

	if(SSticker && SSticker.mode)
		ASYNC
			sql_report_death(src)
		SSticker.mode.check_win()

	if(wearing_rig)
		wearing_rig.notify_ai("<span class='danger'>Warning: user death event. Mobility control passed to integrated intelligence system.</span>")

	// If the body is in VR, move the mind back to the real world
	if(vr_holder)
		src.exit_vr()
		src.vr_holder.vr_link = null
		for(var/obj/item/W in src)
			_handle_inventory_hud_remove(W)

	// If our mind is in VR, bring it back to the real world so it can die with its body
	if(vr_link)
		vr_link.exit_vr()
		vr_link.vr_holder = null
		vr_link = null
		to_chat(src, "<span class='danger'>Everything abruptly stops.</span>")

	return ..(gibbed,species.get_death_message(src))

/mob/living/carbon/human/proc/ChangeToHusk()
	if(MUTATION_HUSK in mutations)	return

	if(f_style)
		f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(MUTATION_HUSK)
	update_icons_body()
	return

/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= MUTATION_HUSK
	return

/mob/living/carbon/human/proc/ChangeToSkeleton()
	if(MUTATION_SKELETON in src.mutations)	return

	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"
	update_hair(0)

	mutations.Add(MUTATION_SKELETON)
	update_icons_body()
	return
