/atom/movable/vv_edit_var(var_name, var_value, mass_edit, raw_edit)
	var/static/list/pixel_movement_edits = list("step_x", "step_y", "step_size", "bounds")
	var/static/list/careful_edits = list("bound_x", "bound_y", "bound_width", "bound_height")
	if(!pixel_movement)
		if(var_name in pixel_movement_edits)
			return FALSE	//PLEASE no.
		if((var_name in careful_edits) && (var_value % world.icon_size) != 0)
			return FALSE
	switch(var_name)
		if("x")
			var/turf/T = locate(var_value, y, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("y")
			var/turf/T = locate(x, var_value, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("z")
			var/turf/T = locate(x, y, var_value)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("loc")
			if(istype(var_value, /atom))
				forceMove(var_value)
				return TRUE
			else if(isnull(var_value))
				moveToNullspace()
				return TRUE
			return
	. = ..()
	if(!.)
		return
	if(!raw_edit)
		switch(var_name)
			if(NAMEOF(src, rad_insulation))
				var/turf/simulated/ST = loc
				if(!istype(ST))
					return
				ST.update_rad_insulation()

/atom/movable/vv_get_dropdown()
	. = ..()
	. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(src)]'>Follow</option>"
	. += "<option value='?_src_=holder;[HrefToken()];admingetmovable=[REF(src)]'>Get</option>"
