/datum/gm_action/shipping_error
	name = "shipping error"
	departments = list(DEPARTMENT_CARGO)
	reusable = TRUE

/datum/gm_action/shipping_error/get_weight()
	var/cargo = metric.count_people_in_department(DEPARTMENT_CARGO)
	var/weight = (cargo * 40)
	return weight

/datum/gm_action/shipping_error/start()
	..()
	var/datum/supply_order/O = new /datum/supply_order()
	O.ordernum = SSsupply.ordernum
	O.object = SSsupply.legacy_supply_packs[pick(SSsupply.legacy_supply_packs)]
	O.ordered_by = random_name(pick(MALE,FEMALE), species = SPECIES_HUMAN)
	SSsupply.shoppinglist += O
