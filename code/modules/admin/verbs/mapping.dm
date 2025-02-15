//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

/client
	var/camera_range_display = FALSE
	var/list/camera_range_images
	var/intercom_range_display = FALSE
	var/list/intercom_range_images

/client/proc/camera_view()
	set category = "Mapping"
	set name = "Camera Range Display"

	camera_range_display = !camera_range_display

	if(camera_range_images)
		images -= camera_range_images
	QDEL_LIST(camera_range_images)
	camera_range_images = list()

	if(camera_range_display)
		for(var/obj/machinery/camera/C in cameranet.cameras)
			for (var/turf/T in view(C.view_range, C))
				var/image/camrange = image('icons/turf/areas.dmi',T,"green")
				images += camrange
				camera_range_images += camrange

	feedback_add_details("admin_verb","mCRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/sec_camera_report()
	set category = "Mapping"
	set name = "Camera Report"

	if(!Master)
		alert(usr,"Master_controller not found.","Sec Camera Report")
		return 0

	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C in cameranet.cameras)
		CL += C

	var/output = {"<B>CAMERA ANOMALIES REPORT</B><HR>
<B>The following anomalies have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		for(var/obj/machinery/camera/C2 in CL)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) and \[[C2.x], [C2.y], [C2.z]\] ([C2.loc.loc]) - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
		var/turf/T = get_step(C1,turn(C1.dir,180))
		if(!T || !isturf(T) || !T.density )
			if(!(locate(/obj/structure/grille,T)))
				var/window_check = 0
				for(var/obj/structure/window/W in T)
					if (W.dir == turn(C1.dir,180) || W.is_fulltile)
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Network: [C1.network]</color></li>"

	output += "</ul>"
	usr << browse(output,"window=airreport;size=1000x500")
	feedback_add_details("admin_verb","mCRP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/intercom_view()
	set category = "Mapping"
	set name = "Intercom Range Display"

	intercom_range_display = !intercom_range_display

	if(intercom_range_images)
		images -= intercom_range_images
	QDEL_LIST(intercom_range_images)
	intercom_range_images = list()

	if(intercom_range_display)
		for (var/obj/item/device/radio/intercom/I in radio_list)
			for (var/turf/T in view(I.canhear_range, I))
				var/image/comrange = image('icons/turf/areas.dmi',T,"yellow")
				images += comrange
				intercom_range_images += comrange

	feedback_add_details("admin_verb","mIRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/enable_debug_verbs()
	set category = "Debug"
	set name = "Debug verbs"

	if(!check_rights(R_DEBUG))
		return

	src.verbs += /client/proc/camera_view 				//-errorage
	src.verbs += /client/proc/sec_camera_report 		//-errorage
	src.verbs += /client/proc/intercom_view 			//-errorage
	src.verbs += /client/proc/Cell //More air things
	src.verbs += /client/proc/pdiff //Antigriff testing - N3X
	src.verbs += /client/proc/atmosscan //check plumbing
	src.verbs += /client/proc/powerdebug //check power
	src.verbs += /client/proc/count_objects_on_z_level
	src.verbs += /client/proc/count_objects_all
	src.verbs += /client/proc/cmd_assume_direct_control	//-errorage
	src.verbs += /client/proc/startSinglo
	src.verbs += /client/proc/cheat_power // Because the above doesn't work off-station.  Or at all, occasionally - N3X
	src.verbs += /client/proc/setup_atmos // Laziness during atmos testing - N3X
	src.verbs += /client/proc/ticklag	//allows you to set the ticklag.
	src.verbs += /client/proc/cmd_admin_grantfullaccess
	src.verbs += /client/proc/splash
	src.verbs += /client/proc/cmd_admin_areatest
	src.verbs += /client/proc/cmd_admin_rejuvenate
	src.verbs += /datum/admins/proc/show_role_panel
	src.verbs += /client/proc/print_jobban_old
	src.verbs += /client/proc/print_jobban_old_filter
	src.verbs += /client/proc/forceEvent
	//src.verbs += /client/proc/break_all_air_groups
	//src.verbs += /client/proc/regroup_all_air_groups
	//src.verbs += /client/proc/kill_pipe_processing
	//src.verbs += /client/proc/kill_air_processing
	//src.verbs += /client/proc/disable_communication
	//src.verbs += /client/proc/disable_movement
	src.verbs += /client/proc/Zone_Info
	src.verbs += /client/proc/Test_ZAS_Connection
	src.verbs += /client/proc/SDQL2_query
	src.verbs += /client/proc/check_sim_unsim
	src.verbs += /client/proc/maprender
	//src.verbs += /client/proc/cmd_admin_rejuvenate
	src.verbs += /client/proc/start_line_profiling
	src.verbs += /client/proc/stop_line_profiling
	src.verbs += /client/proc/show_line_profiling
	src.verbs += /client/proc/check_wires
	src.verbs += /client/proc/check_pipes
	#if UNIT_TESTS_ENABLED
	src.verbs += /client/proc/unit_test_panel
	#endif
	feedback_add_details("admin_verb","mDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_on_z_level()
	set category = "Mapping"
	set name = "Count Objects On Level"

	var/level = input("Which z-level?","Level?") as text
	if(!level)
		return
	var/num_level = text2num(level)
	if(!num_level)
		return
	if(!isnum(num_level))
		return

	var/type_text = input("Which type path?","Path?") as text
	if(!type_text)
		return
	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B && B.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		to_chat(world, line)*/

	to_chat(world, "There are [count] objects of type [type_path] on z-level [num_level]")
	feedback_add_details("admin_verb","mOBJZ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_all()
	set background = 1
	set category = "Mapping"
	set name = "Count Objects All"

	var/type_text = input("Which type path?","") as text
	if(!type_text)
		return
	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		to_chat(world, line)*/

	to_chat(usr, "There are [count] objects of type [type_path] in the game world")
	feedback_add_details("admin_verb","mOBJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/check_sim_unsim()
	set category = "Mapping"
	set name = "Check Sim/Unsim Bounds"
	set background = 1

	// this/can/be/next/to = list(these)
	var/list/acceptable_types=list(
		/turf/simulated/wall = list(
			/turf/simulated,
			// Asteroid shit
			/turf/unsimulated/mineral,
			/turf/unsimulated/floor/airless,
			/turf/unsimulated/floor/asteroid,
			// Space is okay for walls
			/turf/space
		),
		/turf/simulated/floor/shuttle = list(
			/turf/simulated/wall/shuttle,
			/turf/simulated/floor/shuttle,
			/turf/simulated/floor/shuttle/plating,
			/turf/space
		),
		/turf/simulated/floor/shuttle/brig = list(
			/turf/simulated/wall/shuttle,
			/turf/simulated/floor/shuttle,
			/turf/simulated/floor/shuttle/plating,
			/turf/space
		),
		/turf/simulated/floor/plating/airless = list(
			/turf/simulated/floor/plating/airless,
			/turf/simulated/floor/airless,
			/turf/simulated/wall,
			/turf/space
		),
		/turf/simulated/floor/airless = list(
			/turf/simulated/floor/airless,
			/turf/simulated/floor/plating/airless,
			/turf/simulated/wall,
			/turf/space
		),
		/turf/simulated/floor = list(
			/turf/simulated/floor,
			/turf/simulated/wall,
			/turf/simulated/wall/shuttle
		),
	)

	// Actually a "wall" if we have this shit on the tile:
	var/list/wallify=list(
		/turf/simulated/wall,
		/obj/structure/window,
		/obj/structure/shuttle,
		/obj/machinery/door
	)

	for(var/turf/T in world)
		for(var/basetype in acceptable_types)
			var/list/badtiles[0]
			if(istype(T,basetype))
				for(var/atom/A in T)
					if(is_type_in_list(A,wallify))
						basetype = /turf/simulated/wall
						break
				for(var/D in cardinal)
					var/turf/AT = get_step(T,D)
					if(!is_type_in_list(AT, acceptable_types[basetype]))
						badtiles += AT.type
				var/oldcolor = initial(T.color)
				var/newcolor = oldcolor
				if(badtiles.len>0)
					message_admins("Tile [formatJumpTo(T)] (BT: [basetype]) is next to: [jointext(badtiles,", ")]")
					newcolor="#ff0000"
				if(newcolor!=oldcolor)
					T.color=newcolor
				break

	feedback_add_details("admin_verb","mSIM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


var/global/prevent_airgroup_regroup = 0

/*
/client/proc/break_all_air_groups()
	set category = "Mapping"
	set name = "Break All Airgroups"

	/*prevent_airgroup_regroup = 1
	for(var/datum/air_group/AG in SSair.air_groups)
		AG.suspend_group_processing()
	message_admins("[src.ckey] used 'Break All Airgroups'")*/

/client/proc/regroup_all_air_groups()
	set category = "Mapping"
	set name = "Regroup All Airgroups Attempt"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*prevent_airgroup_regroup = 0
	for(var/datum/air_group/AG in SSair.air_groups)
		AG.check_regroup()
	message_admins("[src.ckey] used 'Regroup All Airgroups Attempt'")*/

/client/proc/kill_pipe_processing()
	set category = "Mapping"
	set name = "Kill pipe processing"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*pipe_processing_killed = !pipe_processing_killed
	if(pipe_processing_killed)
		message_admins("[src.ckey] used 'kill pipe processing', stopping all pipe processing.")
	else
		message_admins("[src.ckey] used 'kill pipe processing', restoring all pipe processing.")*/

/client/proc/kill_air_processing()
	set category = "Mapping"
	set name = "Kill air processing"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*air_processing_killed = !air_processing_killed
	if(air_processing_killed)
		message_admins("[src.ckey] used 'kill air processing', stopping all air processing.")
	else
		message_admins("[src.ckey] used 'kill air processing', restoring all air processing.")*/
*/
//This proc is intended to detect lag problems relating to communication procs
var/global/say_disabled = 0
/*
/client/proc/disable_communication()
	set category = "Mapping"
	set name = "Disable all communication verbs"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*say_disabled = !say_disabled
	if(say_disabled)
		message_admins("[src.ckey] used 'Disable all communication verbs', killing all communication methods.")
	else
		message_admins("[src.ckey] used 'Disable all communication verbs', restoring all communication methods.")*/

//This proc is intended to detect lag problems relating to movement
*/
var/global/movement_disabled = 0
var/global/movement_disabled_exception //This is the client that calls the proc, so he can continue to run around to gauge any change to lag.
/*
/client/proc/disable_movement()
	set category = "Mapping"
	set name = "Disable all movement"

	to_chat(usr, "<span class='warning'>Proc disabled.</span>")

	/*movement_disabled = !movement_disabled
	if(movement_disabled)
		message_admins("[src.ckey] used 'Disable all movement', killing all movement.")
		movement_disabled_exception = usr.ckey
	else
		message_admins("[src.ckey] used 'Disable all movement', restoring all movement.")*/
*/

/client/proc/check_wires()
	set category = "Mapping"
	set name = "Check wire connections"

	if(!check_rights(R_DEBUG))
		return

	if(!mob)
		to_chat(usr, "<span class = 'warning'>You require a mob for this to work.</span>")
		return

	var/z = mob.z
	var/error_str = "<h1>Wire connections on current Z Level [z]</h1>"
	for(var/obj/structure/cable/C in cable_list)
		if(C.z != z)
			continue
		if(!C.d1) //It's a stub
			continue
		var/obj/structure/cable/neighbour
		neighbour = locate() in get_step(get_turf(C),C.d1)
		if(!neighbour || neighbour.get_powernet() != C.get_powernet())
			error_str += "<span class = 'warning'>Disconnected wire at [formatJumpTo(get_turf(C))]</span><br>"
		neighbour = locate() in get_step(get_turf(C),C.d2)
		if(!neighbour || neighbour.get_powernet() != C.get_powernet())
			error_str += "<span class = 'warning'>Disconnected wire at [formatJumpTo(get_turf(C))]</span><br>"
	
	var/datum/browser/popup = new(usr, "Wire connections", usr.name, 300, 400)
	popup.set_content(error_str)
	popup.open()

/client/proc/check_pipes()
	set category = "Mapping"
	set name = "Check if Distro and Waste mix"

	if(!check_rights(R_DEBUG))
		return
	feedback_add_details("admin_verb","CDWM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/bad_pipes = 0
	var/list/supply_pipes = list(/obj/machinery/atmospherics/pipe/layer_adapter/supply, /obj/machinery/atmospherics/pipe/manifold/supply, /obj/machinery/atmospherics/pipe/manifold4w/supply, /obj/machinery/atmospherics/pipe/simple/supply)
	var/list/waste_pipes = list(/obj/machinery/atmospherics/pipe/layer_adapter/scrubbers, /obj/machinery/atmospherics/pipe/manifold/scrubbers, /obj/machinery/atmospherics/pipe/manifold4w/scrubbers, /obj/machinery/atmospherics/pipe/simple/scrubbers)

	var/output = {"<B>PLUMBING DISTRO/WASTE MIX REPORT</B><HR>
		<B>The following anomalies have been detected.</B><BR><ul>"}

	for(var/datum/pipe_network/PN in pipe_networks)
		//Forgive me for what I must do
		for(var/datum/pipeline/P in PN.line_members)
			for(var/obj/machinery/atmospherics/AM in P.members)
				if(is_type_in_list(AM, supply_pipes))
					if(istype(AM, /obj/machinery/atmospherics/pipe/simple))
						var/obj/machinery/atmospherics/pipe/simple/SP = AM
						if(is_type_in_list(SP.node1, waste_pipes) || is_type_in_list(SP.node2, waste_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue
					if(istype(AM, /obj/machinery/atmospherics/pipe/layer_adapter))
						var/obj/machinery/atmospherics/pipe/layer_adapter/LA = AM
						if(is_type_in_list(LA.layer_node, waste_pipes) || is_type_in_list(LA.mid_node, waste_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue
					if(istype(AM, /obj/machinery/atmospherics/pipe/manifold))
						var/obj/machinery/atmospherics/pipe/manifold/MF = AM
						if(is_type_in_list(MF.node1, waste_pipes) || is_type_in_list(MF.node2, waste_pipes) || is_type_in_list(MF.node3, waste_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue
					if(istype(AM, /obj/machinery/atmospherics/pipe/manifold4w))
						var/obj/machinery/atmospherics/pipe/manifold4w/MF4 = AM
						if(is_type_in_list(MF4.node1, waste_pipes) || is_type_in_list(MF4.node2, waste_pipes) || is_type_in_list(MF4.node3, waste_pipes)|| is_type_in_list(MF4.node4, waste_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue
				if(is_type_in_list(AM, waste_pipes))
					if(istype(AM, /obj/machinery/atmospherics/pipe/simple))
						var/obj/machinery/atmospherics/pipe/simple/SP = AM
						if(is_type_in_list(SP.node1, supply_pipes) || is_type_in_list(SP.node2, supply_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue
					if(istype(AM, /obj/machinery/atmospherics/pipe/layer_adapter))
						var/obj/machinery/atmospherics/pipe/layer_adapter/LA = AM
						if(is_type_in_list(LA.layer_node, supply_pipes) || is_type_in_list(LA.mid_node, supply_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue
					if(istype(AM, /obj/machinery/atmospherics/pipe/manifold))
						var/obj/machinery/atmospherics/pipe/manifold/MF = AM
						if(is_type_in_list(MF.node1, supply_pipes) || is_type_in_list(MF.node2, supply_pipes) || is_type_in_list(MF.node3, supply_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue
					if(istype(AM, /obj/machinery/atmospherics/pipe/manifold4w))
						var/obj/machinery/atmospherics/pipe/manifold4w/MF4 = AM
						if(is_type_in_list(MF4.node1, supply_pipes) || is_type_in_list(MF4.node2, supply_pipes) || is_type_in_list(MF4.node3, supply_pipes)|| is_type_in_list(MF4.node4, supply_pipes))
							bad_pipes++
							output += "<li>Distro/Waste cross at [formatJumpTo(get_turf(AM))]</li>"
							continue

	output += "</ul><br>[bad_pipes] bad pipes detected."
	usr << browse(output,"window=distrowastemixreport;size=1000x500")
