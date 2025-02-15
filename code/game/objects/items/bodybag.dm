//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"

/obj/item/bodybag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	R.add_fingerprint(user)
	qdel(src)
	

/obj/item/weapon/storage/box/bodybags
	name = "body bag kit"
	desc = "A kit specifically designed to fit bodybags."
	icon_state = "bodybags" //Consider respriting this to a kit some day
	fits_max_w_class = 3
	max_combined_w_class = 21
	can_only_hold = list("/obj/item/bodybag") //Needed due to the last two variables, figures

/obj/item/weapon/storage/box/bodybags/New()
		..()
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)


/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = 0
	sound_file = 'sound/items/zip.ogg'
	w_type = NOT_RECYCLABLE

/obj/structure/closet/body_bag/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/S = W
		if(!S.use(5))
			return
		var/obj/structure/morgue/new_morgue = new(loc)
		for(var/atom/movable/thing in src)
			thing.forceMove(new_morgue)
		new_morgue.update_icon()
		qdel(src)
	else if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/device/flashlight/pen))
		set_tiny_label(user, maxlength=32)
	else if(W.is_wirecutter(user))
		remove_label()
		to_chat(user, "<span class='notice'>You cut the tag off the bodybag.</span>")

/obj/structure/closet/body_bag/set_labeled()
	..()
	src.overlays += image(src.icon, "bodybag_label")

/obj/structure/closet/body_bag/remove_label()
	..()
	src.overlays.len = 0

/obj/structure/closet/body_bag/MouseDropFrom(over_object, src_location, over_location)
	..()
	if(!usr.incapacitated() && over_object == usr && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishigherbeing(usr) || usr.incapacitated() || usr.lying)
			return
		if(opened)
			return 0
		if(contents.len)
			return 0
		visible_message("[usr] folds up the [src.name]")
		new/obj/item/bodybag(get_turf(src))
		spawn(0)
			qdel(src)
		return

/obj/structure/closet/body_bag/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/obj/structure/closet/body_bag/open(mob/user)

	icon_closed = "bodybag_closed"

	var/mob/living/L
	for (L in src)
		if (ishuman(L))
			if (!L.isStunned() && !L.resting)
				if(!istype(user))
					return 1
				if (do_after (user, src, 35)) //delay if someone is standing up
					return ..()
				else
					return 1 //prevents "it won't budge! messages from [closets.dm]
	return ..()

/obj/structure/closet/body_bag/close(mob/user)
	var/mob/living/L
	for (L in get_turf(src))
		if (ishuman(L))
			if (!L.isStunned() && !L.resting)
				if (do_after (user, src, 35))
					icon_closed = "bodybag_closed_alive"
					return ..()
				else
					return 1
	return ..()

/obj/structure/closet/body_bag/olympics/New()
	..()
	var/mob/living/carbon/human/torso = new
	torso.resting = TRUE
	for(var/datum/organ/external/limb in torso.get_organs(LIMB_LEFT_LEG, LIMB_RIGHT_LEG, LIMB_LEFT_ARM, LIMB_RIGHT_ARM))
		var/obj/limb_obj = limb.droplimb(override = TRUE, no_explode = TRUE, spawn_limb = TRUE, display_message = FALSE)
		limb_obj.forceMove(src)
	var/obj/heart = torso.remove_internal_organ(torso, torso.get_heart(), torso.get_organ(LIMB_CHEST))
	heart.forceMove(get_turf(src))
	var/datum/organ/external/head = torso.organs_by_name[LIMB_HEAD]
	head.droplimb(override = TRUE, no_explode = TRUE, spawn_limb = FALSE, display_message = FALSE)
	torso.forceMove(src)

//Cryobag (statis bag) below, not currently functional it seems

/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"

/obj/item/bodybag/cryobag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/cryobag/R = new /obj/structure/closet/body_bag/cryobag(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/closet/body_bag/cryobag
	name = "stasis bag"
	desc = "A non-reusable plastic bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = 0

	var/used = 0

/obj/structure/closet/body_bag/cryobag/open()
	. = ..()
	if(used)
		var/obj/item/O = new/obj/item(src.loc)
		O.name = "used stasis bag"
		O.icon = src.icon
		O.icon_state = "bodybag_used"
		O.desc = "Pretty useless now."
		qdel(src)

/obj/structure/closet/body_bag/cryobag/MouseDropFrom(over_object, src_location, over_location)
	if(!usr.incapacitated() && over_object == usr && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishigherbeing(usr) || usr.incapacitated() || usr.lying)
			return
		to_chat(usr, "<span class='warning'>You can't fold that up anymore.</span>")
	..()
