/obj/item/organ/internal
	origin_tech = "biotech=2"
	force = 1
	w_class = 2
	throwforce = 0
	var/zone = "chest"
	var/slot
	var/vital = 0
	var/organ_action_name = null

/obj/item/organ/internal/proc/Insert(mob/living/carbon/M, special = 0)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/internal/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)

	owner = M
	M.internal_organs |= src
	loc = M
	if(organ_action_name)
		action_button_name = organ_action_name


/obj/item/organ/internal/proc/Remove(mob/living/carbon/M, special = 0)
	owner = null
	if(M)
		M.internal_organs -= src
		if(vital && !special)
			M.death()

	if(organ_action_name)
		action_button_name = null

/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return

/obj/item/organ/internal/proc/on_life()
	return

/obj/item/organ/internal/proc/prepare_eat()
	var/obj/item/weapon/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class

	return S

/obj/item/weapon/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'

	list_reagents = list("nutriment" = 5)


/obj/item/organ/internal/Destroy()
	if(owner)
		Remove(owner, 1)
	return ..()

/obj/item/organ/internal/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(status == ORGAN_ORGANIC)
			var/obj/item/weapon/reagent_containers/food/snacks/S = prepare_eat()
			if(S)
				H.drop_item()
				H.put_in_active_hand(S)
				S.attack(H, H)
				qdel(src)
	else
		..()

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm



/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	zone = "chest"
	slot = "heart"
	origin_tech = "biotech=3"
	vital = 1
	var/beating = 1

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"

/obj/item/organ/internal/heart/Insert(mob/living/carbon/M, special = 0)
	..()
	beating = 1
	update_icon()

/obj/item/organ/internal/heart/Remove(mob/living/carbon/M, special = 0)
	..()
	spawn(120)
		beating = 0
		update_icon()

/obj/item/organ/internal/heart/prepare_eat()
	var/obj/S = ..()
	S.icon_state = "heart-off"
	return S



/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = "groin"
	slot = "appendix"
	var/inflamed = 0

/obj/item/organ/internal/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/internal/appendix/Remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.viruses)
		A.cure()
		inflamed = 1
	update_icon()
	..()

/obj/item/organ/internal/appendix/Insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.AddDisease(new /datum/disease/appendicitis)

/obj/item/organ/internal/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent("????", 5)
	return S

/obj/item/organ/internal/butt //nvm i need to make it internal for surgery fuck
	name = "butt"
	desc = "extremely treasured body part"
	icon_state = "butt"
	item_state = "butt"
	zone = "groin"
	slot = "butt"
	throwforce = 5
	throw_speed = 4
	force = 5
	hitsound = 'sound/misc/fart.ogg'
	throwhitsound = 'sound/misc/fart.ogg' //woo
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	embed_chance = 5 //This is a joke
	var/loose = 0

/obj/item/organ/internal/butt/xeno //XENOMORPH BUTTS ARE BEST BUTTS yes i agree
	name = "alien butt"
	desc = "best trophy ever"
	icon_state = "xenobutt"
	item_state = "xenobutt"

/obj/item/organ/internal/butt/attackby(var/obj/item/W, mob/user as mob, params) // copypasting bot manufucturing process, im a lazy fuck

	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		user.drop_item()
		qdel(W)
		var/turf/T = get_turf(src.loc)
		var/obj/machinery/bot/buttbot/B = new(T)
		if(istype(src, /obj/item/organ/internal/butt/xeno))
			B.xeno = 1
			B.icon_state = "buttbot_xeno"
			B.speech_list = list("hissing butts", "hiss hiss motherfucker", "nice trophy nerd", "butt", "woop get an alien inspection")
		user << "<span class='notice'>You add the robot arm to the butt and... What?</span>"
		user.drop_item(src)
		qdel(src)
