// A simple datum that just holds many lists of lines for mobs to pick from.
// This is its own datum in order to be able to have different types of mobs be able to use the same lines if desired,
// even when inheritence wouldn't be able to do so.

// Also note this also contains emotes, despite its name.
// and now sounds because its probably better that way.

/mob/living
	var/datum/say_list/say_list = null
	var/say_list_type = /datum/say_list	// Type to give us on initialization. Default has empty lists, so the mob will be silent.

/mob/living/Initialize(mapload)
	if(say_list_type)
		say_list = new say_list_type(src)
	return ..()

/mob/living/Destroy()
	if(say_list)
		QDEL_NULL(say_list)
	return ..()

/datum/say_list
	var/list/speak = list()				// Things the mob might say if it talks while idle.
	var/list/emote_hear = list()		// Hearable emotes it might perform
	var/list/emote_see = list()			// Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/list/say_understood = list()	// When accepting an order.
	var/list/say_cannot = list()		// When they cannot comply.
	var/list/say_maybe_target = list()	// When they briefly see something.
	var/list/say_got_target = list()	// When a target is first assigned.
	var/list/say_threaten = list()		// When threatening someone.
	var/list/say_stand_down = list()	// When the threatened thing goes away.
	var/list/say_escalate = list()		// When the threatened thing doesn't go away.

	var/threaten_sound = null			// Sound file played when the mob's AI calls threaten_target() for the first time.
	var/stand_down_sound = null			// Sound file played when the mob's AI loses sight of the threatened target.







// Subtypes.

// This one's pretty dumb, but pirates are dumb anyways and it makes for a good test.
/datum/say_list/pirate
	emote_hear = list("whistles a shanty", "coughs loudly")
	emote_see = list("scratches his ass", "spins his knife around", "spits on the floor", "taps their foot")


	speak = list("Yarr!",
				"Yohoho and a bottle of rum...",
				"Getting tired of hardtack.",
				"What do you do with a drunken sailor...",
				"One day, we'll get that big score.",
				"They ain't catching this pirate, no siree.")
	say_understood = list("Alright, matey.")
	say_cannot = list("No, matey.")
	say_maybe_target = list("Eh?", "Who goes there?")
	say_got_target = list("Yarrrr!", "Just drop your loot and run.")
	say_threaten = list("You best leave, this booty is mine.", "No plank to walk on, just walk away.", "Wanna test your luck landlubber?")
	say_stand_down = list("Good.", "That's right, run, you lilly livers.", "Typical landlubbers.")
	say_escalate = list("Yarr! That booty is mine!", "Going to gut you, landlubber.", "Look's like its a pirate's life for me!")
	threaten_sound = 'sound/effects/holster/sheathout.ogg'
	stand_down_sound = 'sound/effects/holster/sheathin.ogg'

// Mercs!
/datum/say_list/merc
	speak = list("When are we gonna get out of this chicken-shit outfit?",
				"Wish I had better equipment...",
				"I knew I should have been a line chef...",
				"Fuckin' helmet keeps fogging up.",
				"Anyone else smell that?")
	emote_see = list("sniffs", "coughs", "taps his foot", "looks around", "checks his equipment")

	say_understood = list("Understood!", "Affirmative!")
	say_cannot = list("Negative!")
	say_maybe_target = list("Who's there?")
	say_got_target = list("Engaging!")
	say_threaten = list("Get out of here!", "Hey! Private Property!")
	say_stand_down = list("Good.")
	say_escalate = list("Your funeral!", "Bring it!")
	threaten_sound = 'sound/weapons/TargetOn.ogg'
	stand_down_sound = 'sound/weapons/TargetOff.ogg'

/datum/say_list/merc/elite // colder. also, actually just assholes.
	speak = list("I got better pay on my last job.",
				"So, y'think we'll get to shoot anyone today?",
				"Fuck, I hate those guys.",
				"Would be nice for something to happen, for once.",
				"Think those NT shits'll rear their heads?",
				"Any of you see anything recently?")
	emote_see = list("taps his foot", "looks around coldly", "checks his equipment", "rummages in his webbing")
	say_understood = list("Aff.", "Affirmative.", "Copy.", "Understood.")
	say_cannot = list("Neg.", "Negative.")
	say_maybe_target = list("I heard something.")
	say_got_target = list("Oh, good, I needed more range fodder.", "I'm going to enjoy this.", "I see you.", "Not quiet enough.")
	say_threaten = list("Hoy, private property, fuck off.", "You're acting mighty bold for a bullet sponge.", "First and last warning; find somewhere else to be.", "I wouldn't do that if I were you.", "Back off or your field medic's getting a bonus.")
	say_stand_down = list("Damn it, I was hoping you'd push your luck.", "What, that's it? Pussy.", "And don't come back.", "Good call. Don't do it again.", "Harrumph.", "That'll teach 'ya.")
	say_escalate = list("Oh, I'm gonna enjoy this.", "I'm going to enjoy making you regret that.", "Last mistake you'll make.")

/datum/say_list/malf_drone
	speak = list("ALERT.","Hostile-ile-ile entities dee-twhoooo-wected.","Threat parameterszzzz- szzet.","Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly","whirrs threateningly","scans its immediate vicinity")

	say_understood = list("Affirmative.", "Positive.")
	say_cannot = list("Denied.", "Negative.")
	say_maybe_target = list("Possible threat detected. Investigating.", "Motion detected.", "Investigating.")
	say_got_target = list("Threat detected.", "New task: Remove threat.", "Threat removal engaged.", "Engaging target.")
	say_threaten = list("Motion detected, judging target...")
	say_stand_down = list("Visual lost.", "Error: Target not found.")
	say_escalate = list("Viable target found. Removing.", "Engaging target.", "Target judgement complete. Removal required.")

	threaten_sound = 'sound/effects/turret/move1.wav'
	stand_down_sound = 'sound/effects/turret/move2.wav'


/datum/say_list/crab
	emote_hear = list("clicks")
	emote_see = list("clacks")

/datum/say_list/spider
	emote_hear = list("chitters")

/datum/say_list/hivebot
	speak = list(
		"Resuming task: Protect area.",
		"No threats found.",
		"Error: No targets found."
		)
	emote_hear = list("hums ominously", "whirrs softly", "grinds a gear")
	emote_see = list("looks around the area", "turns from side to side")
	say_understood = list("Affirmative.", "Positive.")
	say_cannot = list("Denied.", "Negative.")
	say_maybe_target = list("Possible threat detected.  Investigating.", "Motion detected.", "Investigating.")
	say_got_target = list("Threat detected.", "New task: Remove threat.", "Threat removal engaged.", "Engaging target.")

/datum/say_list/lizard
	emote_hear = list("hisses")

/datum/say_list/crab
	emote_hear = list("hisses")

//Vox Pirate Saylist
/datum/say_list/merc/voxpirate
	speak = list("Lookings for scrap, yaya.",
				"Tank is lookings low.",
				"Knowings should haves stayed on the Ark.",
				"Quills itchings...",
				"Cravings Teshari on stick.",
				"Plates locking up. Not good.")
	emote_see = list("sniffs", "coughs", "taps his foot", "looks around", "checks his equipment")

	say_understood = list("Yayaya!")
	say_cannot = list("Skreking negatives!", "Can't do that.")
	say_maybe_target = list("Who's theres?", "Is hearing things?")
	say_got_target = list("Dust!", "Easy loot!")
	say_threaten = list("Gets out of heres!")
	say_stand_down = list("Yaya, runs!", "Kikikiki!")
	say_escalate = list("Skrek!", "Bringings it!", "Takings shot", "Lock claws!")


	//Synth Horror Saylist

/datum/say_list/cyber_horror
	speak = list("H@!#$$P M@!$#",
				 "GHAA!@@#",
				 "KR@!!N",
				 "K!@@##L!@@ %!@#E",
				 "G@#!$ H@!#%",
				 "H!@%%@ @!E")
	emote_hear = list("emits", "groans", "wails", "pleads")
	emote_see = list ("stares unblinkingly.", "jitters and twitches.", "emits a synthetic scream.", "rapidly twitches.", "convulses.", "twitches uncontrollably.", "goes stock still.")
	say_threaten = list ("FR@#DOM","EN@ T#I$-$","N0$ M^> B@!#")
	say_got_target = list("I *#@ Y@%","!E@#$P","F#RR @I","D0@#$ ##OK %","IT $##TS")

//Roach Saylists Woo Hoo
/datum/say_list/roach
	speak = list("Chitter!","Chk chk!","Tchk?")
	emote_hear = list("chitters","chirps","shuffles")
	emote_see = list("rubs its antennae", "skitters", "clacks across the floor")

/datum/say_list/possessed
	speak = list("Where am I?",
				"Why am I here?",
				"Where did everyone go?")

	emote_hear = list("lets out a mournful cry.", "can be heard sobbing.", "groans out in pain.")
	emote_see = list("kneels down for a moment, picking something up before casting it away.","stands as still as a statue.", "looks to be doing some kind of work.")

	say_maybe_target = list("Is there someone there?", "Who's there?")
	say_got_target = list("You! You help people!", "Can you help me?", "I'm lost!")
	say_threaten = list("Help me!", "Please help!", "Hey, who turned out the lights?", "Allonsy!", "Geronimo!")
	say_stand_down = list("Please. Anyone. Help!", "Where is everyone?", "Where am I?")
	say_escalate = list("Help!", "I'm sorry!", "I can't stop!", "I don't want to do this!", "I don't want to go!")

// Generic Lines for all Tajara mobs
/datum/say_list/tajara
	speak = list("So hot herrre...",
				"Could use a nice cigarrr...",
				"Still betterrr then the factorrries...",
				"They didn't say it would be this borrring.",
				"Been forreverrr since I had some good gin.")
	emote_see = list("sniffs.", "coughs.", "mrrrps.", "looks around.", "chokes on a hairball.", "flicks their tail.")
	say_maybe_target = list("Who's therrre?")
	threaten_sound = 'sound/weapons/TargetOn.ogg'
	stand_down_sound = 'sound/weapons/TargetOff.ogg'

/datum/say_list/tajara/nka
	say_understood = list("Yes sirrr my liege!", "At once sirrre!")
	say_cannot = list("I cannot my lorrrd!")
	say_got_target = list("Messa will take you!")
	say_threaten = list("Begone Trrrespasserrr!", "You trrread on prrivate prropurrty!")
	say_stand_down = list("S'rrrendarrr good.")
	say_escalate = list("You'll make a fine rrrug!", "Forr Adhomai!")

/datum/say_list/tajara/pra
	say_understood = list("Aye Comrrrade!", "Togetherrr!")
	say_cannot = list("I cannot sirrr!")
	say_got_target = list("We will be liberrated!")
	say_threaten = list("You some corrporrrate pig?!", "This land belongs to the people!")
	say_stand_down = list("Grreat.")
	say_escalate = list("Die corrporrate dog!", "Forr Adhomai!")

/datum/say_list/tajara/dra
	say_understood = list("Yeah got it...", "Affirrrmative!")
	say_cannot = list("Harrr Harrr No!")
	say_got_target = list("Welcome to the snowfields!")
	say_threaten = list("You think you can stop us?!", "This is a frree terrrritorry! Scrram!")
	say_stand_down = list("Grrreat now we gotta move camp.")
	say_escalate = list("You'll neverrr stop us all!", "Forr Adhomai!")
