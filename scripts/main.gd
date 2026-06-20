extends Node2D

@onready var creature = $Creature

@onready var level_label = $CanvasLayer/LevelLabel
@onready var xp_label = $CanvasLayer/XPLabel
@onready var state_label = $CanvasLayer/StateLabel
@onready var energy_label = $CanvasLayer/EnergyLabel
@onready var mood_label = $CanvasLayer/MoodLabel
@onready var berry_label = $CanvasLayer/BerryLabel
@onready var forest_exp_label = $CanvasLayer/ForestExpLabel
@onready var preference_label = $CanvasLayer/PreferenceLabel
@onready var nature_affinity_label = $CanvasLayer/NatureAffinityLabel
@onready var discovery_exp_label = $CanvasLayer/DiscoveryExpLabel
@onready var curiosity_label = $CanvasLayer/CuriosityLabel
@onready var trait_label = $CanvasLayer/TraitLabel
@onready var danger_exp_label = $CanvasLayer/DangerExpLabel
@onready var bravery_label = $CanvasLayer/BraveryLabel
@onready var volcano_exp_label = $CanvasLayer/VolcanoExpLabel
@onready var fire_affinity_label = $CanvasLayer/FireAffinityLabel
@onready var location_label = $CanvasLayer/LocationLabel
@onready var cave_exp_label = $CanvasLayer/CaveExpLabel
@onready var earth_affinity_label = $CanvasLayer/EarthAffinityLabel

func _on_explore_button_pressed():
	creature.explore()
	
func _on_location_button_pressed():
	creature.switch_location()
	
func _ready():
	creature.stats_changed.connect(update_ui)
	update_ui()
	
func update_ui():
	level_label.text = "Level: %d" % creature.level
	xp_label.text = "XP: %d/%d" % [
		creature.xp,
		creature.get_xp_threshold()
	]

	state_label.text = "State: " + creature.get_state()
		
	energy_label.text = "Energy: %d/%d" % [
		int(creature.energy),
		int(creature.max_energy)
	]
	mood_label.text = "Mood: " + creature.get_mood()
	berry_label.text = "Berries: %d" % creature.get_item_count("Berry")
	forest_exp_label.text = "Forest Exp: %d" % creature.get_experience("Forest")
	volcano_exp_label.text = "Volcano Exp: %d" % creature.get_experience("Volcano")
	discovery_exp_label.text = "Discovery Exp: %d" % creature.get_experience("Discovery")
	
	preference_label.text = "Preference: " + creature.get_preference()
	nature_affinity_label.text = "Nature Affinity: %d" % creature.get_affinity("Nature")
	fire_affinity_label.text = "Fire Affinity: %d" % creature.get_affinity("Fire")
	curiosity_label.text = "Curiosity: %d" % creature.get_tendency("Curiosity")
	trait_label.text = "Trait: " + creature.get_trait_text()
	
	danger_exp_label.text = "Danger Exp: %d" % creature.get_experience("Danger")
	bravery_label.text = "Bravery: %d" % creature.get_tendency("Bravery")
	location_label.text = "Location: " + creature.get_location()
	
	cave_exp_label.text = "Cave Exp: %d" % creature.get_experience("Cave")
	earth_affinity_label.text = "Earth Affinity: %d" % creature.get_affinity("Earth")


func _on_use_berry_button_pressed() -> void:
	creature.use_item("Berry")


func _on_use_ember_stone_button_pressed() -> void:
	creature.use_item("Ember Stone")


func _on_use_crystal_button_pressed() -> void:
	creature.use_item("Crystal")
