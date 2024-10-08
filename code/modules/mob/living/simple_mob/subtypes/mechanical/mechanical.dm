// Mechanical mobs don't care about the atmosphere and cannot be hurt by tasers.
// They're also immune to poisons as they're entirely metal, however this also makes most of them vulnerable to shocks.
// They can also be hurt by EMP.

/mob/living/simple_mob/mechanical
	mob_class = MOB_CLASS_SYNTHETIC
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	taser_kill = FALSE
	poison_resist = 1.0
	shock_resist = -0.5

/mob/living/simple_mob/mechanical/isSynthetic()
	return TRUE

/mob/living/simple_mob/mechanical/speech_bubble_appearance()
	return !has_iff_faction(MOB_IFF_FACTION_NEUTRAL) ? "synthetic_evil" : "machine"

// Fix for Virgo 2's Surface
/mob/living/simple_mob/mechanical
	maxbodytemp = 700
