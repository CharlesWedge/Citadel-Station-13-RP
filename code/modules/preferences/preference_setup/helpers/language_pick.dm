// todo: proper tgui preferences

/datum/preferences/proc/language_pick(mob/user)
	if(GLOB.language_picker_active[REF(user)])
		return
	new /datum/tgui_language_picker(user, src)

/datum/preferences/proc/route_language_pick(id, mob/user)
	return language_pick_finalize(id, user)

/datum/preferences/proc/language_pick_finalize(id, mob/user)
	var/datum/prototype/language/L = RSlanguages.fetch(id)
	if(!L)
		to_chat(user, SPAN_WARNING("BUG: Invalid language ID: [id]"))
		return TRUE
	if(extraneous_language_ids().len > extraneous_languages_max())
		to_chat(user, SPAN_WARNING("You cannot select another language!"))
		return TRUE
	var/datum/species/CS = character_species_datum()
	var/list/whitelisted_ids = CS.get_whitelisted_language_ids() // cache ids from character species for speed
	if((L.language_flags & LANGUAGE_WHITELISTED) && !((L.id in whitelisted_ids) || config.check_alien_whitelist(ckey(L.name), client_ckey)))
		to_chat(user, SPAN_WARNING("[L] is a whitelisted language!"))
		return FALSE
	var/list/current = get_character_data(CHARACTER_DATA_LANGUAGES)
	current += L.id
	set_character_data(CHARACTER_DATA_LANGUAGES, current)
	refresh(user)
	return TRUE

GLOBAL_LIST_EMPTY(language_picker_active)
/datum/tgui_language_picker
	/// user ref
	var/user_ref
	/// preferences
	var/datum/preferences/prefs

/datum/tgui_language_picker/New(mob/user, datum/preferences/prefs)
	if(!istype(user) || !istype(prefs))
		qdel(src)
		CRASH("what?")
	src.prefs = prefs
	user_ref = REF(user)
	GLOB.language_picker_active[user_ref] = src
	open()

/datum/tgui_language_picker/Destroy()
	SStgui.close_uis(src)
	GLOB.language_picker_active -= user_ref
	return ..()

/datum/tgui_language_picker/proc/open()
	var/mob/M = locate(user_ref)
	ASSERT(M)
	ui_interact(M)

/datum/tgui_language_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LanguagePicker", "Choose language")
		ui.autoupdate = FALSE			// why the fuck are you updating language data??
		ui.open()

/datum/tgui_language_picker/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE

/datum/tgui_language_picker/ui_static_data(mob/user, datum/tgui/ui)
	var/list/data = ..()
	var/list/built = list()
	var/list/categories = list("General")
	for(var/datum/prototype/language/L as anything in RSlanguages.fetch_subtypes_immutable(/datum/prototype/language))
		if(L.language_flags & LANGUAGE_RESTRICTED)
			continue
		built[++built.len] = list(
			"id" = L.id,
			"name" = L.name,
			"desc" = L.desc,
			"category" = L.category
		)
		LAZYDISTINCTADD(categories, L.category)
	data["languages"] = built
	data["categories"] = categories
	return data

/datum/tgui_language_picker/on_ui_close(mob/user, datum/tgui/ui, embedded)
	. = ..()
	if(!QDELING(src))
		qdel(src)

/datum/tgui_language_picker/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	switch(action)
		if("pick")
			if(prefs.route_language_pick(params["id"], usr))
				qdel(src)
