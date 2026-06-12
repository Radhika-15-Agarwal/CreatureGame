extends CharacterBody2D

# Progression
var xp := 0
var level := 1

# Energy
var energy := 100.0
var max_energy := 100.0
var energy_recovery_rate := 0.5

# Exploration
var exploration_energy_cost := 20.0
var exploration_xp_reward := 5
var exploration_duration := 2.0

# Rewards
var berry_reward := 1

var exploring := false

var home_position : Vector2

var inventory := {
	"Berry": 0
}

signal stats_changed

func gain_xp(amount):
	xp += amount

	if xp >= level * 10:
		xp = 0
		level += 1
		print("Level Up! ", level)

	stats_changed.emit()

func explore():
	if exploring:
		print("Already exploring")
		return
		
	if energy < 20:
		print("Too tired to explore")
		return

	exploring = true
	energy -= exploration_energy_cost
	stats_changed.emit()

	print("Creature left to explore")

	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(300, 0), 1.0)

	await tween.finished

	await get_tree().create_timer(exploration_duration).timeout

	var return_tween = create_tween()
	return_tween.tween_property(self, "position", home_position, 1.0)

	await return_tween.finished
	
	inventory["Berry"] += berry_reward

	gain_xp(exploration_xp_reward)

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
	if energy >= 70:
		return "Happy"
	elif energy >= 30:
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
