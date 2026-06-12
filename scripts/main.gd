extends Node2D

@onready var creature = $Creature

@onready var level_label = $CanvasLayer/LevelLabel
@onready var xp_label = $CanvasLayer/XPLabel
@onready var state_label = $CanvasLayer/StateLabel
@onready var energy_label = $CanvasLayer/EnergyLabel

func _on_explore_button_pressed():
	creature.explore()
	
func _ready():
	creature.stats_changed.connect(update_ui)
	update_ui()
	
func update_ui():
	level_label.text = "Level: %d" % creature.level
	xp_label.text = "XP: %d" % creature.xp

	if creature.exploring:
		state_label.text = "State: Exploring"
	else:
		state_label.text = "State: Idle"
		
	energy_label.text = "Energy: %d/%d" % [
		creature.energy,
		creature.max_energy
	]
