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

# Items
var berry_min_energy := 8
var berry_max_energy := 12

var ember_stone_min_affinity := 1
var ember_stone_max_affinity := 2

var crystal_min_affinity := 1
var crystal_max_affinity := 2


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
	}
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




# Functions 

#==================================================
# Lifecycle
#==================================================

func _ready():
	home_position = position

	initialize_locations()
	initialize_affinities()
	initialize_inventory()
	initialize_tendencies()
	initialize_events()

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
	print("Found ", item_amount, " ", get_location_item())
	
	process_location_experience()
	process_events()	
	process_affinity_bonus()
	process_affinity_growth()

	gain_xp(exploration_xp_reward)

	finish_exploration()
	

func use_item(item_name: String):
	if get_item_count(item_name) <= 0:
		return

	inventory[item_name] -= 1

	match item_name:
		"Berry":
			if energy >= max_energy:
				inventory["Berry"] += 1
				print("Energy Full!")
				return
			energy += random_range(berry_min_energy, berry_max_energy)
			energy = min(energy, max_energy)

		"Ember Stone":
			gain_affinity("Fire", random_range(ember_stone_min_affinity, ember_stone_max_affinity))

		"Crystal":
			gain_affinity("Earth", random_range(crystal_min_affinity, crystal_max_affinity))

	stats_changed.emit()
	



#==================================================
# Exploration Pipeline
#==================================================

func can_explore():
	if exploring:
		print("Already exploring")
		return false

	if energy < exploration_energy_cost:
		print("Too tired to explore")
		return false

	return true
	
func start_exploration():
	exploring = true
	energy -= exploration_energy_cost
	stats_changed.emit()

	print("Creature left to explore")
	
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

		print("Discovered something new!")
		
	if randf() < final_danger_chance:
		gain_event("Danger", get_event_reward("Danger"))

		if randf() < get_tendency_event_chance("Bravery"):
			if randf() < get_tendency_gain_chance("Bravery"):
				gain_tendency("Bravery", random_range(tendency_min_gain, tendency_max_gain))
			else:
				gain_tendency("Bravery", -1)

		print("Danger encountered!")

func process_affinity_bonus():
	var location_affinity = get_location_affinity()

	var affinity_level = get_affinity(location_affinity)

	if affinity_level <= 0:
		return

	var bonus_chance = affinity_level * get_location_affinity_bonus()
	bonus_chance = min(bonus_chance, max_bonus_chance)

	if randf() < bonus_chance:
		gain_experience(current_location, random_range(affinity_bonus_min_exp, affinity_bonus_max_exp))
		print(location_affinity, " affinity bonus!")

func process_affinity_growth():
	var location_affinity = get_location_affinity()
	
	if get_preference() != current_location:
		return
		
	if randf() < get_location_affinity_gain_chance():
		gain_affinity(location_affinity, random_range(affinity_min_gain, affinity_max_gain))
	
func finish_exploration():
	exploring = false
	stats_changed.emit()

	print("Creature returned")



#==================================================
# Progression
#==================================================

func gain_xp(amount):
	xp += amount

	while xp >= get_xp_threshold():
		xp -= get_xp_threshold()
		level += 1
		print("Level Up! ", level)

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
	
