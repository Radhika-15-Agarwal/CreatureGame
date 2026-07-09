extends CharacterBody2D

#==================================================
# Creature State
#==================================================

# Progression
var xp := 0
var level := 1

# Energy
var energy := 100.0
var max_energy := 100.0

# Exploration
var exploring := false
var current_location := "Forest"
var home_position: Vector2

# Runtime Data
var inventory := {}
var experiences := {}
var affinities := {}
var tendencies := {}
var events := {}


#==================================================
# Balance
#==================================================

# Progression
var xp_per_level := 10

# Energy
var energy_recovery_rate := 0.5

# Mood
var happy_energy_threshold := 70.0
var okay_energy_threshold := 30.0

# Exploration
var exploration_energy_cost := 20.0
var exploration_xp_reward := 5
var exploration_duration := 2.0
var exploration_distance := 300.0
var travel_duration := 1.0

# Petting
var pets_since_explore := 0
var current_pet_tolerance := 3 
var min_pet_tolerance := 1
var max_pet_tolerance := 5

# Preferences
var preference_threshold := 10

# Affinities
var affinity_xp_modifier_per_level := 0.01
var max_bonus_chance := 0.5

# Trait Effects
var curious_discovery_bonus_chance := 0.1
var curious_danger_bonus_chance := 0.1
var brave_danger_bonus_chance := 0.1
var timid_danger_reduction := 0.1
var timid_discovery_penalty := 0.1


#==================================================
# Random Rewards
#==================================================

# Affinity
var affinity_min_gain := 1
var affinity_max_gain := 2

# Tendencies
var tendency_min_gain := 1
var tendency_max_gain := 2

# Experience
var affinity_bonus_min_exp := 1
var affinity_bonus_max_exp := 2

var brave_bonus_min_exp := 1
var brave_bonus_max_exp := 2

var petting_bonus_min_exp := 1
var petting_bonus_max_exp := 3

#==================================================
# Gameplay Data
#==================================================

var location_data := {
	"Forest": {
		"affinity": "Nature",
		"min_exp": 1,
		"max_exp": 3,
		"affinity_bonus": 0.1,
		"affinity_gain_chance": 0.25,
		"discovery_chance": 0.3,
		"danger_chance": 0.2,
		"item": "Berry",
		"min_item": 1,
		"max_item": 3
	},
	"Volcano": {
		"affinity": "Fire",
		"min_exp": 1,
		"max_exp": 3,
		"affinity_bonus": 0.1,
		"affinity_gain_chance": 0.35,
		"discovery_chance": 0.2,
		"danger_chance": 0.4,
		"item": "Ember Stone",
		"min_item": 1,
		"max_item": 2
	},
	"Cave": {
		"affinity": "Earth",
		"min_exp": 1,
		"max_exp": 4,
		"affinity_bonus": 0.15,
		"affinity_gain_chance": 0.30,
		"discovery_chance": 0.15,
		"danger_chance": 0.35,
		"item": "Crystal",
		"min_item": 1,
		"max_item": 4
	},
	"Lake": {
		"affinity": "Water",
		"min_exp": 1,
		"max_exp": 3,
		"affinity_bonus": 0.1,
		"affinity_gain_chance": 0.30,
		"discovery_chance": 0.25,
		"danger_chance": 0.25,
		"item": "Fish",
		"min_item": 1,
		"max_item": 3
	},
}

var trait_data := {
	"Curious": {
		"tendency": "Curiosity",
		"threshold": 10,
		"comparison": ">="
	},
	"Brave": {
		"tendency": "Bravery",
		"threshold": 10,
		"comparison": ">="
	},
	"Timid": {
		"tendency": "Bravery",
		"threshold": -10,
		"comparison": "<="
	}
}

var tendency_data := {
	"Curiosity": {
		"gain_chance": 0.5
	},
	"Bravery": {
		"event_chance": 0.5,
		"gain_chance": 0.5
	},
	"Trust": {
		"happy_gain_chance": 0.4, 
		"okay_gain_chance": 0.1
	}
}

var event_data := {
	"Discovery": {
		"reward": 1
	},
	"Danger": {
		"reward": 1
	}
}

var domain_data := {
	"Nature": {
		"strong_against": ["Water", "Light"],
		"weak_against": ["Fire", "Ice"],
		"likes": ["Nature", "Water", "Light"],
		"dislikes": ["Fire", "Metal"]
	},
	"Fire": {
		"strong_against": ["Ice", "Nature"],
		"weak_against": ["Water", "Earth"],
		"likes": ["Fire", "Light", "Electric"],
		"dislikes": ["Water", "Ice"]
	},
	"Earth": {
		"strong_against": ["Electric", "Fire"],
		"weak_against": ["Air", "Metal"],
		"likes": ["Earth", "Metal", "Nature"],
		"dislikes": ["Air"]
	},
	"Water": {
		"strong_against": ["Fire", "Light"],
		"weak_against": ["Nature", "Dark"],
		"likes": ["Water", "Nature", "Ice"],
		"dislikes": ["Electric"]
	},
	"Air": {
		"strong_against": ["Earth", "Metal"],
		"weak_against": ["Light", "Dark"],
		"likes": ["Air", "Light", "Electric"],
		"dislikes": ["Earth"]
	},
	"Ice": {
		"strong_against": ["Nature", "Electric"],
		"weak_against": ["Fire", "Metal"],
		"likes": ["Ice", "Water", "Dark"],
		"dislikes": ["Fire"]
	},
	"Electric": {
		"strong_against": ["Metal", "Dark"],
		"weak_against": ["Earth", "Ice"],
		"likes": ["Electric", "Air", "Fire"],
		"dislikes": ["Earth", "Water"]
	},
	"Metal": {
		"strong_against": ["Ice", "Earth"],
		"weak_against": ["Electric", "Air"],
		"likes": ["Metal", "Earth", "Electric"],
		"dislikes": ["Nature"]
	},
	"Light": {
		"strong_against": ["Dark", "Air"],
		"weak_against": ["Nature", "Water"],
		"likes": ["Light", "Nature", "Fire"],
		"dislikes": ["Dark"]
	},
	"Dark": {
		"strong_against": ["Air", "Water"],
		"weak_against": ["Light", "Electric"],
		"likes": ["Dark", "Ice", "Metal"],
		"dislikes": ["Light"]
	}
}


#==================================================
# Signals
#==================================================

signal stats_changed
signal log_updated(message: String)



# Functions 

#==================================================
# Lifecycle
#==================================================

func _ready():
	home_position = position
	
	min_pet_tolerance = random_range(0, 3) 
	max_pet_tolerance = random_range(min_pet_tolerance + 1, 6)
	current_pet_tolerance = random_range(min_pet_tolerance, max_pet_tolerance)

	initialize_locations()
	initialize_affinities()
	initialize_inventory()
	initialize_tendencies()
	initialize_events()

	if active_request.is_empty():
		generate_new_request()

	print(experiences)
	print(affinities)
	print(inventory)
	print(events)
	print(tendencies)
	

func _process(delta):
	if exploring:
		return

	if energy < max_energy:
		energy += delta * energy_recovery_rate
		energy = min(energy, max_energy)

		stats_changed.emit()
		

func initialize_locations():
	for location in location_data:
		experiences[location] = 0
		
func initialize_affinities():
	for location in location_data:
		var affinity = location_data[location]["affinity"]

		if not affinities.has(affinity):
			affinities[affinity] = 0

func initialize_inventory():
	for location in location_data:
		var item = location_data[location]["item"]

		if not inventory.has(item):
			inventory[item] = 0

func initialize_tendencies():
	for tendency in tendency_data:
		tendencies[tendency] = 0
		
func initialize_events():
	for event_type in event_data:
		events[event_type] = 0



#==================================================
# Player Actions
#==================================================

func explore():
	if not can_explore():
		return

	start_exploration()

	await travel_to_exploration()
	await explore_location()
	await return_home()
	
	var item_amount = collect_items()
	add_log("Found " + str(item_amount) + " " + get_location_item())
	
	process_location_experience()
	process_events()	
	process_affinity_bonus()
	process_affinity_growth()

	gain_xp(exploration_xp_reward)

	finish_exploration()
	

func use_item(item_name: String):
	if get_item_count(item_name) <= 0:
		return
		
	var item_info = ItemData.ITEMS.get(item_name, {})
	if item_info.is_empty() or not item_info.has("effects"):
		add_log("Cannot use " + item_name + ".")
		return

	var effects = item_info["effects"]

	# Energy Restore
	if effects.has("energy_restore_min") and effects.has("energy_restore_max"):
		if energy >= max_energy:
			add_log("Energy is already full!")
			return 
			
		var heal_amount = random_range(effects["energy_restore_min"], effects["energy_restore_max"])
		energy += heal_amount
		energy = min(energy, max_energy)
		add_log("Used " + item_name + ": +" + str(heal_amount) + " Energy.")

	# Affinity Gain
	if effects.has("affinity_type") and effects.has("affinity_min"):
		var aff_amount = random_range(effects["affinity_min"], effects["affinity_max"])
		
		if aff_amount > 0:
			gain_affinity(effects["affinity_type"], aff_amount)
			add_log("Used " + item_name + ": +" + str(aff_amount) + " " + effects["affinity_type"] + " Affinity.")

	inventory[item_name] -= 1
	stats_changed.emit()
	

func pet():
	if exploring:
		add_log("The creature is not home right now.")
		return
		
	if pets_since_explore >= current_pet_tolerance:
		add_log("The creature swats your hand away. It wants personal space.")
		return
		
	pets_since_explore += 1 
	var current_mood = get_mood()
	
	if current_mood == "Tired":
		add_log("You gently pet the tired creature. It rests easier.")
		energy += random_range(petting_bonus_min_exp, petting_bonus_max_exp)
		energy = min(energy, max_energy)
		
	elif current_mood == "Happy":
		add_log("The creature happily leans into your hand!")
		
		if randf() < tendency_data["Trust"]["happy_gain_chance"]:
			gain_tendency("Trust", 1)
			add_log("The creature trusts you a little more.")
			
	else: # "Okay" mood
		add_log("You pet the creature. It seems content.")
		
		if randf() < tendency_data["Trust"]["okay_gain_chance"]:
			gain_tendency("Trust", 1)
			add_log("The creature trusts you a little more.")

	stats_changed.emit()
	

func generate_new_request():
	var possible_items = ["Berry", "Ember Stone", "Crystal", "Fish"]
	var req_item = possible_items.pick_random()
	var req_amount = random_range(2, 5)
	
	var req_reward = req_amount * random_range(5, 10) 
	
	active_request = {
		"item": req_item, 
		"amount": req_amount, 
		"reward": req_reward
	}
	
	stats_changed.emit()
	add_log("New request posted: " + str(req_amount) + " " + req_item + "s.")


func fulfill_request():
	if active_request.is_empty():
		return
		
	var req_item = active_request["item"]
	var req_amount = active_request["amount"]
	var req_reward = active_request["reward"]
	
	if get_item_count(req_item) >= req_amount:
		inventory[req_item] -= req_amount
		coins += req_reward
		
		add_log("Request complete! Earned " + str(req_reward) + " coins.")
		generate_new_request() 
	else:
		add_log("Not enough " + req_item + "s. You need " + str(req_amount) + ".")




#==================================================
# Exploration Pipeline
#==================================================

func can_explore():
	if exploring:
		add_log("Already exploring")
		return false

	if energy < exploration_energy_cost:
		add_log("Too tired to explore")
		return false
	
	var location_affinity = get_location_affinity()
	var primary_affinity = get_primary_affinity()

	if primary_affinity != "":
		var dislikes = domain_data[primary_affinity].get("dislikes", [])
		
		if location_affinity in dislikes:
			# Base 20% refusal, +1% per affinity level (capped at 80%)
			var refusal_chance = min(0.2 + (get_affinity(primary_affinity) * 0.01), 0.8)
			
			if randf() < refusal_chance:
				add_log("REFUSED! Creature dislikes " + location_affinity + " domains.")
				return false

	return true
	
func start_exploration():
	exploring = true
	energy -= exploration_energy_cost
	
	pets_since_explore = 0
	current_pet_tolerance = random_range(min_pet_tolerance, max_pet_tolerance)
	
	stats_changed.emit()
	add_log("Creature left to explore")
	
func travel_to_exploration():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(exploration_distance, 0), travel_duration)

	await tween.finished
	
func explore_location():
	await get_tree().create_timer(exploration_duration).timeout
	
func return_home():
	var return_tween = create_tween()
	return_tween.tween_property(self, "position", home_position, travel_duration)

	await return_tween.finished
	
func collect_items():
	var location_info = get_location_data()
	
	var item_amount = random_range(
		location_info["min_item"],
		location_info["max_item"]
	)
	inventory[get_location_item()] += item_amount
	
	return item_amount

func process_location_experience():
	var location_info = get_location_data()
	
	var location_exp_gain = random_range(
		location_info["min_exp"],
		location_info["max_exp"]
	)

	var modifier = get_affinity_xp_modifier()

	location_exp_gain = round(location_exp_gain * (1.0 + modifier))

	location_exp_gain = max(location_exp_gain, 1)

	gain_experience(current_location, location_exp_gain)

func process_events():
	var final_discovery_chance = get_location_discovery_chance()
	var final_danger_chance = get_location_danger_chance()

	if has_trait("Curious"):
		final_discovery_chance += curious_discovery_bonus_chance
		final_danger_chance += curious_danger_bonus_chance
		
	if has_trait("Brave"):
		final_danger_chance += brave_danger_bonus_chance
		gain_experience(current_location, random_range(brave_bonus_min_exp, brave_bonus_max_exp))

	if has_trait("Timid"):
		final_danger_chance -= timid_danger_reduction
		final_discovery_chance -= timid_discovery_penalty

	final_discovery_chance = clamp(final_discovery_chance, 0.0, 1.0)
	final_danger_chance = clamp(final_danger_chance, 0.0, 1.0)
	
	if randf() < final_discovery_chance:
		gain_event("Discovery", get_event_reward("Discovery"))

		if randf() < get_tendency_gain_chance("Curiosity"):
			gain_tendency("Curiosity", random_range(tendency_min_gain, tendency_max_gain))

		add_log("Discovered something new!")
		
	if randf() < final_danger_chance:
		gain_event("Danger", get_event_reward("Danger"))

		if randf() < get_tendency_event_chance("Bravery"):
			if randf() < get_tendency_gain_chance("Bravery"):
				gain_tendency("Bravery", random_range(tendency_min_gain, tendency_max_gain))
			else:
				gain_tendency("Bravery", -1)

		add_log("Danger encountered!")

func process_affinity_bonus():
	var location_affinity = get_location_affinity()

	var affinity_level = get_affinity(location_affinity)

	if affinity_level <= 0:
		return

	var bonus_chance = affinity_level * get_location_affinity_bonus()
	bonus_chance = min(bonus_chance, max_bonus_chance)

	if randf() < bonus_chance:
		gain_experience(current_location, random_range(affinity_bonus_min_exp, affinity_bonus_max_exp))
		add_log(location_affinity + " affinity bonus!")

func process_affinity_growth():
	var location_affinity = get_location_affinity()
	
	if get_preference() != current_location:
		return
		
	if randf() < get_location_affinity_gain_chance():
		gain_affinity(location_affinity, random_range(affinity_min_gain, affinity_max_gain))
	
func finish_exploration():
	exploring = false
	stats_changed.emit()

	add_log("Creature returned")



#==================================================
# Progression
#==================================================

func gain_xp(amount):
	xp += amount

	while xp >= get_xp_threshold():
		xp -= get_xp_threshold()
		level += 1
		add_log("Level Up! Level " + str(level))

	stats_changed.emit()
	
func get_xp_threshold():
	return level * xp_per_level
	
func gain_experience(experience_type: String, amount: int):
	if not experiences.has(experience_type):
		experiences[experience_type] = 0

	experiences[experience_type] += amount
	stats_changed.emit()

func get_experience(experience_type: String):
	return experiences.get(experience_type, 0)
	

#==================================================
# Economy
#==================================================
var coins := 0
var active_request := {}
var home_upgrades := []


#==================================================
# Creature
#==================================================

func get_state():
	if exploring:
		return "Exploring"
	elif energy < max_energy:
		return "Resting"
	else:
		return "Idle"
		
func get_mood():
	if energy >= happy_energy_threshold:
		return "Happy"
	elif energy >= okay_energy_threshold:
		return "Okay"
	else:
		return "Tired"
		


#==================================================
# Affinities
#==================================================

func gain_affinity(affinity_type: String, amount: int):
	if not affinities.has(affinity_type):
		affinities[affinity_type] = 0

	affinities[affinity_type] += amount

	stats_changed.emit()

func get_affinity(affinity_type: String):
	return affinities.get(affinity_type, 0)
	
func get_affinity_xp_modifier():
	var modifier := 0.0
	var location_affinity = get_location_affinity()

	for affinity in affinities:
		var affinity_level = get_affinity(affinity)

		if affinity == location_affinity:
			modifier += affinity_level * affinity_xp_modifier_per_level

		elif location_affinity in domain_data[affinity]["weak_against"]:
			modifier -= affinity_level * affinity_xp_modifier_per_level

	return modifier
	
func get_primary_affinity() -> String:
	var highest_affinity = ""
	var max_val = 0
	
	for affinity in affinities:
		if affinities[affinity] > max_val:
			max_val = affinities[affinity]
			highest_affinity = affinity
			
	return highest_affinity
	
	

#==================================================
# Tendencies & Traits
#==================================================

func gain_tendency(tendency_type: String, amount: int):
	if not tendencies.has(tendency_type):
		tendencies[tendency_type] = 0

	tendencies[tendency_type] += amount

	stats_changed.emit()

func get_tendency(tendency_type: String):
	return tendencies.get(tendency_type, 0)
	
func has_trait(trait_name: String):
	if not trait_data.has(trait_name):
		return false

	var data = trait_data[trait_name]
	var tendency_value = get_tendency(data["tendency"])

	match data["comparison"]:
		">=":
			return tendency_value >= data["threshold"]
		"<=":
			return tendency_value <= data["threshold"]

	return false
	
func get_traits():
	var traits = []

	for trait_name in trait_data:
		if has_trait(trait_name):
			traits.append(trait_name)

	return traits
	
func get_trait_text():
	var traits = get_traits()

	if traits.is_empty():
		return "None"

	return ", ".join(traits)
	


#==================================================
# Events
#==================================================

func gain_event(event_type: String, amount: int):
	if not events.has(event_type):
		events[event_type] = 0

	events[event_type] += amount
	stats_changed.emit()

func get_event(event_type: String):
	return events.get(event_type, 0)
	


#==================================================
# Locations
#==================================================

func set_location(location_name: String):
	current_location = location_name
	stats_changed.emit()
	
func get_location():
	return current_location
	
func switch_location():
	if exploring:
		return

	var locations = location_data.keys()
	var current_index = locations.find(current_location)

	current_index = (current_index + 1) % locations.size()

	set_location(locations[current_index])
	
func get_preference():
	var favorite_location = ""
	var highest_exp = 0

	for location in location_data:
		var exp = get_experience(location)

		if exp > highest_exp:
			highest_exp = exp
			favorite_location = location

	if highest_exp < preference_threshold:
		return "Undecided"

	return favorite_location
	
func get_location_data():
	return location_data[current_location]
	
func get_location_affinity():
	return get_location_data()["affinity"]

func get_location_affinity_bonus():
	return get_location_data()["affinity_bonus"]
	
func get_location_discovery_chance():
	return get_location_data()["discovery_chance"]

func get_location_danger_chance():
	return get_location_data()["danger_chance"]
	
func get_location_affinity_gain_chance():
	return get_location_data()["affinity_gain_chance"]
	
func get_location_item():
	return get_location_data()["item"]
	
	


#==================================================
# Inventory
#==================================================

func get_item_count(item_name: String):
	return inventory.get(item_name, 0)
	



#==================================================
# Data Helpers
#==================================================

func get_event_reward(event_name: String):
	return event_data[event_name]["reward"]
	
func get_tendency_gain_chance(tendency: String):
	return tendency_data[tendency]["gain_chance"]
	
func get_tendency_event_chance(tendency: String):
	return tendency_data[tendency]["event_chance"]
	



#==================================================
# Utilities
#==================================================

func random_range(min_value: int, max_value: int):
	return randi_range(min_value, max_value)
	
func add_log(message: String):
	print(message)
	log_updated.emit(message)
	
	
	
	
func is_item_unlocked(item_name: String) -> bool:
	if not ItemData.ITEMS.has(item_name):
		return false
		
	var item_info = ItemData.ITEMS[item_name]
	
	if not item_info.has("unlock"):
		return true
		
	var reqs = item_info["unlock"]
	
	# Condition 1: Level Requirement
	if reqs.has("level"):
		if level < reqs["level"]:
			return false
			
	# Condition 2: Location Requirement (Must have gained XP there)
	if reqs.has("location"):
		var required_loc = reqs["location"]
		if get_experience(required_loc) <= 0:
			return false
			
	return true
	
func buy_item(item_name: String):
	if not ItemData.ITEMS.has(item_name):
		add_log("Item doesn't exist.")
		return
		
	var item_info = ItemData.ITEMS[item_name]
	
	if not item_info.get("buyable", false):
		add_log(item_name + " is not for sale.")
		return
		
	if not is_item_unlocked(item_name):
		add_log(item_name + " is locked.")
		return
		
	var cost = item_info["cost"]
	
	if coins < cost:
		add_log("Not enough coins.")
		return
		
	if item_info["category"] == "upgrade" and item_name in home_upgrades:
		add_log("You already own the " + item_name + "!")
		return
		
	coins -= cost
	
	if item_info["category"] == "upgrade":
		home_upgrades.append(item_name)
		apply_upgrades()
		add_log("Purchased Home Upgrade: " + item_name + "!")
	else:
		if not inventory.has(item_name):
			inventory[item_name] = 0
		inventory[item_name] += 1
		add_log("Bought " + item_name + " for " + str(cost) + " coins.")
		
	stats_changed.emit()
	
func apply_upgrades():
	# 1. Reset to base stats first
	energy_recovery_rate = 0.5 
	
	# 2. Apply safe, hardcoded effect routing
	for upgrade_name in home_upgrades:
		var item_info = ItemData.ITEMS[upgrade_name]
		if item_info.has("effects"):
			for effect in item_info["effects"]:
				match effect:
					"energy_recovery_rate":
						energy_recovery_rate = item_info["effects"][effect]
					# Example of how you add future effects:
					# "max_energy":
					# 	max_energy = item_info["effects"][effect]
