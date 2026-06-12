extends Node2D

@onready var creature = $Creature

@onready var level_label = $CanvasLayer/LevelLabel
@onready var xp_label = $CanvasLayer/XPLabel
@onready var state_label = $CanvasLayer/StateLabel
@onready var energy_label = $CanvasLayer/EnergyLabel
@onready var mood_label = $CanvasLayer/MoodLabel
@onready var berry_label = $CanvasLayer/BerryLabel

func _on_explore_button_pressed():
	creature.explore()
	
func _ready():
	creature.stats_changed.connect(update_ui)
	update_ui()
	
func update_ui():
	level_label.text = "Level: %d" % creature.level
	xp_label.text = "XP: %d" % creature.xp

	state_label.text = "State: " + creature.get_state()
		
	energy_label.text = "Energy: %d/%d" % [
		int(creature.energy),
		int(creature.max_energy)
	]
	mood_label.text = "Mood: " + creature.get_mood()
	berry_label.text = "Berries: %d" % creature.get_item_count("Berry")
