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

# Rewards
var berry_reward := 1

var exploring := false

var home_position : Vector2

var inventory := {
	"Berry": 0
}

var experiences := {
	"Forest": 0
}

var min_experience_reward := 1
var max_experience_reward := 3

var forest_preference_threshold := 10

var affinities := {
	"Nature": 0
}

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
	
	inventory["Berry"] += berry_reward
	
	var forest_exp_reward = randi_range(
		min_experience_reward,
		max_experience_reward
	)
	gain_experience("Forest", forest_exp_reward)

	gain_xp(exploration_xp_reward)
	
	if get_preference() == "Likes Forests":
		if randf() < 0.25:
			gain_affinity("Nature", 1)

	exploring = false
	stats_changed.emit()

	print("Creature returned")
	
func _ready():
	home_position = position
	
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
	
func get_preference():
	if get_experience("Forest") >= forest_preference_threshold:
		return "Likes Forests"

	return "Undecided"
	
func gain_affinity(affinity_type: String, amount: int):
	if not affinities.has(affinity_type):
		affinities[affinity_type] = 0

	affinities[affinity_type] += amount

	stats_changed.emit()

func get_affinity(affinity_type: String):
	return affinities.get(affinity_type, 0)
