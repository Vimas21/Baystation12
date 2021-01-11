/datum/extension/chameleon
	base_type = /datum/extension/chameleon
	expected_type = /obj/item
	flags = EXTENSION_FLAG_IMMEDIATE
	var/list/chameleon_choices
	var/static/list/chameleon_choices_by_type
	var/atom/atom_holder
	var/chameleon_verb

/datum/extension/chameleon/New(datum/holder, base_type)
	..()

	if (!chameleon_choices)
		var/chameleon_type = base_type || holder.parent_type
		chameleon_choices = LAZYACCESS(chameleon_choices_by_type, chameleon_type)
		if(!chameleon_choices)
			chameleon_choices = generate_chameleon_choices(chameleon_type)
			LAZYSET(chameleon_choices_by_type, chameleon_type, chameleon_choices)	
	else
		var/list/choices = list()
		for(var/path in chameleon_choices)
			add_chameleon_choice(choices, path)
		chameleon_choices = sortAssoc(choices)


	atom_holder = holder
	chameleon_verb += new/atom/proc/chameleon_appearance(atom_holder,"Change [atom_holder.name] Appearance")
	chameleon_verb += new/atom/proc/change_chameleon_outfit()

/datum/extension/chameleon/Destroy()
	. = ..()
	atom_holder.verbs -= chameleon_verb
	atom_holder = null

/datum/extension/chameleon/proc/disguise(newtype, mob/user)
	var/obj/item/copy = new newtype(null) //initial() does not handle lists well
	var/obj/item/C = atom_holder

	C.name = copy.name
	C.desc = copy.desc
	C.icon = copy.icon
	C.color = copy.color
	C.icon_state = copy.icon_state
	C.flags_inv = copy.flags_inv
	C.item_state = copy.item_state
	C.body_parts_covered = copy.body_parts_covered

	if (copy.item_icons)
		C.item_icons = copy.item_icons.Copy()
	if (copy.item_state_slots)
		C.item_state_slots = copy.item_state_slots.Copy()
	if (copy.sprite_sheets)
		C.sprite_sheets = copy.sprite_sheets.Copy()

	OnDisguise(copy)
	qdel(copy)

/datum/extension/chameleon/proc/OnDisguise(obj/item/copy)

/datum/extension/chameleon/clothing
	expected_type = /obj/item/clothing

/datum/extension/chameleon/clothing/accessory
	expected_type = /obj/item/clothing/accessory

/datum/extension/chameleon/clothing/accessory/OnDisguise(obj/item/clothing/accessory/copy)
	..()
	var/obj/item/clothing/accessory/A = holder

	A.slot = copy.slot
	A.has_suit = copy.has_suit
	A.inv_overlay = copy.inv_overlay
	A.mob_overlay = copy.mob_overlay
	A.overlay_state = copy.overlay_state
	A.accessory_icons = copy.accessory_icons
	A.on_rolled = copy.on_rolled
	A.high_visibility = copy.high_visibility

/datum/extension/chameleon/proc/add_chameleon_choice(list/target, path)
	var/obj/item/I = path
	if (initial(I.icon) && initial(I.icon_state) && !(initial(I.item_flags) & ITEM_FLAG_INVALID_FOR_CHAMELEON))
		var/name = initial(I.name)
		if (target[name])
			name += " ([initial(I.icon_state)])"
		if (target[name])
			var/snowflake = 1
			while (target["[name] [snowflake]"])
				++snowflake
			target["[name] [snowflake]"] = path
		else
			target[name] = path

/datum/extension/chameleon/proc/generate_chameleon_choices(basetype)
	var/choices = list()
	var/types = islist(basetype) ? basetype : typesof(basetype)
	for (var/path in types)
		add_chameleon_choice(choices, path)
	return sortAssoc(choices)

/datum/extension/chameleon/proc/initialize_outfits()
	var/global/list/standard_outfit_options
	if(!standard_outfit_options)	
		standard_outfit_options = list()
		for(var/path in typesof(/decl/hierarchy/outfit/job))
			for(var/subpath in typesof(path))
				var/decl/hierarchy/outfit/job/J = subpath
				if(initial(J.chameleon))
					standard_outfit_options[initial(J.name)] = subpath
		sortTim(standard_outfit_options, /proc/cmp_text_asc)
	return standard_outfit_options

/atom/proc/change_chameleon_outfit()
	set name = "Change Chameleon Outfit"
	set desc = "Activate the holographic appearance changing module across all acessible chameleon devices."
	set category = "Object"
	if(usr.incapacitated() || !ishuman(usr))
		return FALSE
	if (has_extension(src,/datum/extension/chameleon))
		var/datum/extension/chameleon/C = get_extension(src, /datum/extension/chameleon)
		var/list/outfits = C.initialize_outfits()
		var/selected_key = input(usr, "Choose an Outfit", "Chameleon Outfit") as null|anything in outfits
		if (!selected_key)
			return FALSE
		var/decl/hierarchy/outfit/selected = outfits[selected_key]
		var/mob/living/carbon/human/user = usr
		if (usr.incapacitated())
			return FALSE
		// Under
		var/datum/extension/chameleon/under = get_extension(user.w_uniform, /datum/extension/chameleon)
		if(under && initial(selected.uniform))
			under.disguise(initial(selected.uniform), user)
		// Head
		var/datum/extension/chameleon/head = get_extension(user.head, /datum/extension/chameleon)
		if(head && initial(selected.head))
			head.disguise(initial(selected.head), user)
		// Suit
		var/datum/extension/chameleon/suit = get_extension(user.wear_suit, /datum/extension/chameleon)
		if(suit && initial(selected.suit))
			suit.disguise(initial(selected.suit), user)
		// Shoes
		var/datum/extension/chameleon/shoes = get_extension(user.shoes, /datum/extension/chameleon)
		if(suit && initial(selected.shoes))
			shoes.disguise(initial(selected.shoes), user)
		// Back
		var/datum/extension/chameleon/backpack = get_extension(user.back, /datum/extension/chameleon)
		if(suit && initial(selected.back))
			backpack.disguise(initial(selected.back), user)
		// Glasses
		var/datum/extension/chameleon/glasses = get_extension(user.glasses, /datum/extension/chameleon)
		if(glasses && initial(selected.glasses))
			glasses.disguise(initial(selected.glasses), user)
		// Gloves
		var/datum/extension/chameleon/gloves = get_extension(user.gloves, /datum/extension/chameleon)
		if(gloves && initial(selected.gloves))
			gloves.disguise(initial(selected.gloves), user)
		// Mask
		var/datum/extension/chameleon/mask = get_extension(user.wear_mask, /datum/extension/chameleon)
		if(mask && initial(selected.mask))
			mask.disguise(initial(selected.mask), user)
		// Headset
		var/datum/extension/chameleon/headset = get_extension(user.l_ear, /datum/extension/chameleon)
		if(headset && initial(selected.l_ear))
			headset.disguise(initial(selected.l_ear), user)
		user.regenerate_icons()
	else
		src.verbs -= /atom/proc/change_chameleon_outfit

/atom/proc/chameleon_appearance()
	set name = "Change Appearance"
	set desc = "Activate the holographic appearance changing module."
	set category = "Object"

	if (!CanPhysicallyInteract(usr))
		return
	if (has_extension(src,/datum/extension/chameleon))
		var/datum/extension/chameleon/C = get_extension(src, /datum/extension/chameleon)
		C.change(usr)
	else
		src.verbs -= /atom/proc/chameleon_appearance

/datum/extension/chameleon/proc/change(mob/user)
	var/choice = input(user, "Select a new appearance", "Select appearance") as null|anything in chameleon_choices
	if (choice)
		if (QDELETED(user) || QDELETED(holder))
			return
		if(user.incapacitated() || !(holder in user))
			to_chat(user, SPAN_WARNING("You can't reach \the [holder]."))
			return
		disguise(chameleon_choices[choice], user)
		OnChange(user,holder)

/datum/extension/chameleon/proc/OnChange(mob/user, obj/item/clothing/C) //contains icon updates
	if (istype(C))
		C.update_clothing_icon()

/datum/extension/chameleon/backpack
	expected_type = /obj/item/weapon/storage/backpack

/datum/extension/chameleon/backpack/OnChange(mob/user, obj/item/weapon/storage/backpack/C)
	if (ismob(C.loc))
		var/mob/M = C.loc
		M.update_inv_back()

/datum/extension/chameleon/headset
	expected_type = /obj/item/device/radio/headset

/datum/extension/chameleon/headset/OnChange(mob/user, obj/item/device/radio/headset/C)
	if (ismob(C.loc))
		var/mob/M = C.loc
		M.update_inv_ears()

/datum/extension/chameleon/gun
	expected_type = /obj/item/weapon/gun

/datum/extension/chameleon/gun/OnChange(mob/user, obj/item/weapon/gun/C)
	if (ismob(C.loc))
		var/mob/M = C.loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/datum/extension/chameleon/gun/OnDisguise(obj/item/weapon/gun/copy)
	var/obj/item/weapon/gun/G = atom_holder

	G.flags_inv = copy.flags_inv
	G.fire_sound = copy.fire_sound
	G.fire_sound_text = copy.fire_sound_text
	G.icon = copy.icon

/datum/extension/chameleon/emag
	expected_type = /obj/item/weapon/card
	chameleon_choices = list(
		/obj/item/weapon/card/emag,
		/obj/item/weapon/card/union,
		/obj/item/weapon/card/data,
		/obj/item/weapon/card/data/full_color,
		/obj/item/weapon/card/data/disk,
		/obj/item/weapon/card/id
	)
