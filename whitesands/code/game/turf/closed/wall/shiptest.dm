//Shamelessly stolen from NSV, not going to code durasteel and duranium in since these are just for ruin aesthethics

turf/closed/wall/durasteel
	icon = 'whitesands/icons/turf/walls/durasteel_wall.dmi'
	icon_state = "solid"
	name = "Durasteel hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE
	smooth = TRUE

turf/closed/wall/r_wall/duranium
	icon = 'whitesands/icons/turf/walls/duranium_wall.dmi'
	icon_state = "solid"
	name = "Duranium hull"
	desc = "A large hull segment designed to create vessels and structures capable of supporting life in even the most hazardous places."
	legacy_smooth = TRUE
	smooth = TRUE
	color = null

//Wall Smoothing//
//Credit to baystation for this mess.

/atom/proc/legacy_smooth()
	return //Only implemented on fucky 3/4 stuff

/atom
	var/legacy_smooth
	var/smooth

#define CORNER_NONE 0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL 2
#define CORNER_CLOCKWISE 4

/proc/dirs_to_corner_states(list/dirs)
	if(!istype(dirs)) return

	var/list/ret = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)

	for(var/i = 1 to ret.len)
		var/dir = ret[i]
		. = CORNER_NONE
		if(dir in dirs)
			. |= CORNER_DIAGONAL
		if(turn(dir,45) in dirs)
			. |= CORNER_COUNTERCLOCKWISE
		if(turn(dir,-45) in dirs)
			. |= CORNER_CLOCKWISE
		ret[i] = "[.]"

	return ret

#define CAN_SMOOTH_FULL 1 //Able to fully smooth, no "connection" states.
#define CAN_SMOOTH_HALF 2 //Able to half smooth, will spawn "connector" states.

/turf/closed/wall/legacy_smooth()
	update_connections()
	update_icon()

/turf/closed/wall/proc/update_connections()
	var/list/wall_dirs = list()
	var/list/other_dirs = list()

	for(var/atom/W in orange(src, 1))
		switch(can_join_with(W))
			if(FALSE)
				continue
			if(CAN_SMOOTH_FULL)
				wall_dirs += get_dir(src, W)
			if(CAN_SMOOTH_HALF)
				wall_dirs += get_dir(src, W)
				other_dirs += get_dir(src, W)

	wall_connections = dirs_to_corner_states(wall_dirs)
	other_connections = dirs_to_corner_states(other_dirs)
	return

/turf/closed/wall/proc/can_join_with(atom/movable/W)
	if(ismob(W) || istype(W, /obj/machinery/door/window) || istype(W, /turf/closed/wall/mineral/titanium)) //Just...trust me on this
		return FALSE
	if(istype(W, src.type))
		return CAN_SMOOTH_FULL
	for(var/_type in canSmoothWith)
		if(istype(W, _type))
			return CAN_SMOOTH_HALF
	return FALSE

/turf/closed/wall/update_icon()
	if(legacy_smooth)
		cut_overlays()
		var/image/I = null
		for(var/i = 1 to 4)
			I = image(icon, "[initial(icon_state)][wall_connections[i]]", dir = 1<<(i-1))
			add_overlay(I)
			if(other_connections[i] != "0")
				I = image(icon, "[initial(icon_state)]_other[wall_connections[i]]", dir = 1<<(i-1))
				add_overlay(I)
		if(texture)
			add_overlay(texture)
	else
		..()

#undef CAN_SMOOTH_FULL
#undef CAN_SMOOTH_HALF
