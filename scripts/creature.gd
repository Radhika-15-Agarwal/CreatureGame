extends CharacterBody2D

# Progression
var xp := 0
var level := 1
var xp_per_level := 10

# Energy
var energy := 100.0
var max_energy := 100.0
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

var exploring := false

var home_position : Vector2

var inventory := {}

var experiences := {}

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
var current_location := "Forest"
var max_bonus_chance := 0.5

var affinities := {}

var preference_threshold := 10

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

var tendencies := {}

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

var events := {}

# Traits
var curious_discovery_bonus_chance := 0.1

signal stats_changed

func gain_xp(amount):
	xp += amount

	while xp >= get_xp_threshold():
		xp -= get_xp_threshold()
		level += 1
		print("Level Up! ", level)

	stats_changed.emit()

func explore():
	if exploring:
		print("Already exploring")
		return
		
	if energy < exploration_energy_cost:
		print("Too tired to explore")
		return

	exploring = true
	energy -= exploration_energy_cost
	stats_changed.emit()

	print("Creature left to explore")

	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(exploration_distance, 0), travel_duration)

	await tween.finished

	await get_tree().create_timer(exploration_duration).timeout

	var return_tween = create_tween()
	return_tween.tween_property(self, "position", home_position, travel_duration)

	await return_tween.finished
	
	var location_info = get_location_data()
	
	var item_amount = randi_range(
		location_info["min_item"],
		location_info["max_item"]
	)
	inventory[get_location_item()] += item_amount

	var location_exp_gain = randi_range(
		location_info["min_exp"],
		location_info["max_exp"]
	)
	gain_experience(current_location, location_exp_gain)
	
	var final_discovery_chance = get_location_discovery_chance()

	if has_trait("Curious"):
		final_discovery_chance += curious_discovery_bonus_chance

	final_discovery_chance = min(final_discovery_chance, 1.0)
	
	if randf() < final_discovery_chance:
		gain_event("Discovery", event_data["Discovery"]["reward"])

		if randf() < tendency_data["Curiosity"]["gain_chance"]:
			gain_tendency("Curiosity", 1)

		print("Discovered something new!")
		
	if randf() < get_location_danger_chance():
		gain_event("Danger", event_data["Danger"]["reward"])

		if randf() < tendency_data["Bravery"]["event_chance"]:
			if randf() < tendency_data["Bravery"]["gain_chance"]:
				gain_tendency("Bravery", 1)
			else:
				gain_tendency("Bravery", -1)

		print("Danger encountered!")
		
	var location_affinity = get_location_affinity()

	if get_affinity(location_affinity) > 0:
		var bonus_chance = get_affinity(location_affinity) * get_location_affinity_bonus()
		bonus_chance = min(bonus_chance, max_bonus_chance)
		if randf() < bonus_chance:
			gain_experience(current_location, 1)
			print(location_affinity," affinity bonus!")

	gain_xp(exploration_xp_reward)
	
	if get_preference() == current_location:
		if randf() < get_location_affinity_gain_chance():
			gain_affinity(location_affinity, 1)

	exploring = false
	stats_changed.emit()

	print("Creature returned")
	print("Found ", item_amount, " ", get_location_item())
	
func _ready():
	home_position = position

	for location in location_data:
		if not experiences.has(location):
			experiences[location] = 0
			
		var affinity = location_data[location]["affinity"]

		if not affinities.has(affinity):
			affinities[affinity] = 0
		
		var item = location_data[location]["item"]

		if not inventory.has(item):
			inventory[item] = 0
			
	for tendency in tendency_data:
		tendencies[tendency] = 0
		
	for event_type in event_data:
		events[event_type] = 0
	
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
		
func get_mood():
	if energy >= happy_energy_threshold:
		return "Happy"
	elif energy >= okay_energy_threshold:
		return "Okay"
	else:
		return "Tired"
		
func get_state():
	if exploring:
		return "Exploring"
	elif energy < max_energy:
		return "Resting"
	else:
		return "Idle"
		
func get_item_count(item_name: String):
	return inventory.get(item_name, 0)
	
func get_xp_threshold():
	return level * xp_per_level
	
func gain_experience(experience_type: String, amount: int):
	if not experiences.has(experience_type):
		experiences[experience_type] = 0

	experiences[experience_type] += amount
	stats_changed.emit()

func get_experience(experience_type: String):
	return experiences.get(experience_type, 0)
	
func gain_event(event_type: String, amount: int):
	if not events.has(event_type):
		events[event_type] = 0

	events[event_type] += amount
	stats_changed.emit()

func get_event(event_type: String):
	return events.get(event_type, 0)
	
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
	
func gain_affinity(affinity_type: String, amount: int):
	if not affinities.has(affinity_type):
		affinities[affinity_type] = 0

	affinities[affinity_type] += amount

	stats_changed.emit()

func get_affinity(affinity_type: String):
	return affinities.get(affinity_type, 0)
	
func get_location_affinity():
	return get_location_data()["affinity"]

func get_location_affinity_bonus():
	return get_location_data()["affinity_bonus"]
	
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
	
func get_location_data():
	return location_data[current_location]
	
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
	
func get_location_discovery_chance():
	return get_location_data()["discovery_chance"]

func get_location_danger_chance():
	return get_location_data()["danger_chance"]
	
func get_location_affinity_gain_chance():
	return get_location_data()["affinity_gain_chance"]
	
func get_location_item():
	return get_location_data()["item"]
