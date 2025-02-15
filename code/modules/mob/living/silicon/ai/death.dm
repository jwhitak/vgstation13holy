/mob/living/silicon/ai/death(gibbed)
	if((status_flags & BUDDHAMODE) || stat == DEAD)
		return
	if(!gibbed)
		emote("deathgasp", message = TRUE)
		if(!explosive)
			playsound(src, 'sound/machines/WXP_shutdown.ogg', 75, FALSE)
	stat = DEAD
	update_icon()

	update_canmove()
	if(src.eyeobj)
		src.eyeobj.forceMove(get_turf(src))
	change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	var/callshuttle = 0

	for(var/obj/machinery/computer/communications/commconsole in machines)
		if(commconsole.z == map.zCentcomm)
			continue
		if(istype(commconsole.loc,/turf))
			break
		callshuttle++

	for(var/obj/item/weapon/circuitboard/communications/commboard in communications_circuitboards)
		if(commboard.z == map.zCentcomm)
			continue
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			break
		callshuttle++

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(shuttlecaller.z == map.zCentcomm)
			continue
		if(!shuttlecaller.stat && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			break
		callshuttle++

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction")
		callshuttle = 0

	if(callshuttle == 3) //if all three conditions are met
		shuttle_autocall()

	if(explosive && !gibbed && !istype(loc, /obj/machinery/power/apc))
		visible_message("<span class='danger'>[name] begins to spark violently!</span>")
		shake_animation(5, 5, 0.2, 15)
		spark(src)
		playsound(src, 'sound/machines/Alarm_short.ogg', 100, FALSE)
		spawn(30)
			explosion(src.loc, 2, 5, 8, 10, whodunnit = src)
			gibbed = TRUE
			gib()

	if(blackout_active)
		malf_rcd_disable = FALSE
		malf_radio_blackout = FALSE

	for(var/obj/machinery/ai_status_display/O in machines) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(loc, /obj/item/device/aicard))
			loc.icon_state = "aicard-404"

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", category=MIND_MEMORY_GENERAL, forced=TRUE)
		if(!mind.suiciding) //Cowards don't count
			score.deadaipenalty += 1

	return ..(gibbed)
