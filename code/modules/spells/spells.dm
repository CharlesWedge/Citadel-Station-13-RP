/datum/mind
	var/list/learned_spells

/mob/Login()
	..()
	if(spell_masters)
		for(var/atom/movable/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.toggle_open(1)
			client.screen -= spell_master

/mob/statpanel_data(client/C)
	. = ..()
	//! WARNING
	//! NO, SERIOUSLY, READ THIS
	// DO NOT COPY PASTE THE FOLLOWING CODE.
	// THIS IS ALREADY SNOWFLAKED CODE; YOU *WILL* BREAK EVERYTHING IF YOU DO BY OVERWRITING DATA!!

	// i'm going to trust people aren't stupid and won't put the name of a regular panel in spells.
	if(!length(spell_list))
		if(C.tgui_stat.spell_last)
			// dispose
			for(var/tab in C.tgui_stat.spell_last)
				C.statpanel_tab(tab, FALSE)
			C.tgui_stat.spell_last = null
		return
	LAZYINITLIST(C.tgui_stat.spell_last)
	var/list/collected = list()
	for(var/spell/S in spell_list)
		if(!S.panel || !S.connected_button)
			continue
		collected[S.panel] = TRUE
		if(!C.statpanel_tab(S.panel))
			continue
		switch(S.charge_type)
			if(Sp_RECHARGE)
				STATPANEL_DATA_CLICK("[S.charge_counter/10.0]/[S.charge_max/10]", "[S.connected_button]", "\ref[S.connected_button]")
			if(Sp_CHARGES)
				STATPANEL_DATA_CLICK("[S.charge_counter]/[S.charge_max]", "[S.connected_button]", "\ref[S.connected_button]")
			if(Sp_HOLDVAR)
				STATPANEL_DATA_CLICK("[S.holder_var_type] [S.holder_var_amount]", "[S.connected_button]", "\ref[S.connected_button]")
	// process tabs
	var/list/removing = C.tgui_stat.spell_last - collected
	var/list/adding = collected - C.tgui_stat.spell_last
	for(var/tab in adding)
		C.statpanel_tab(adding, TRUE)
	for(var/tab in removing)
		C.statpanel_tab(removing, TRUE)

/hook/clone/proc/restore_spells(var/mob/H)
	if(H.mind && H.mind.learned_spells)
		for(var/spell/spell_to_add in H.mind.learned_spells)
			H.add_spell(spell_to_add)

/mob/proc/add_spell(var/spell/spell_to_add, var/spell_base = "wiz_spell_ready", var/master_type = /atom/movable/screen/movable/spell_master)
	if(!spell_masters)
		spell_masters = list()
	if(spell_masters.len)
		for(var/atom/movable/screen/movable/spell_master/spell_master in spell_masters)
			if(spell_master.type == master_type)
				spell_list.Add(spell_to_add)
				spell_master.add_spell(spell_to_add)
				return 1

	var/atom/movable/screen/movable/spell_master/new_spell_master = new master_type //we're here because either we didn't find our type, or we have no spell masters to attach to
	if(client)
		src.client.screen += new_spell_master
	new_spell_master.spell_holder = src
	new_spell_master.add_spell(spell_to_add)
	if(spell_base)
		new_spell_master.icon_state = spell_base
	spell_masters.Add(new_spell_master)
	spell_list.Add(spell_to_add)
	if(mind)
		if(!mind.learned_spells)
			mind.learned_spells = list()
		mind.learned_spells += spell_to_add

	return 1

/mob/proc/remove_spell(var/spell/spell_to_remove)
	if(!spell_to_remove || !istype(spell_to_remove))
		return

	if(!(spell_to_remove in spell_list))
		return

	if(!spell_masters || !spell_masters.len)
		return

	if(mind && mind.learned_spells)
		mind.learned_spells.Remove(spell_to_remove)
	spell_list.Remove(spell_to_remove)
	for(var/atom/movable/screen/movable/spell_master/spell_master in spell_masters)
		spell_master.remove_spell(spell_to_remove)
	return 1

/mob/proc/silence_spells(var/amount = 0)
	if(!(amount >= 0))
		return

	if(!spell_masters || !spell_masters.len)
		return

	for(var/atom/movable/screen/movable/spell_master/spell_master in spell_masters)
		spell_master.silence_spells(amount)
