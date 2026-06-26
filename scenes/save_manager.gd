extends Node

@onready var creature = $"../Creature"

var save_path := "user://creature_save.dat"

func save_game():
	var save_data = {
		"xp": creature.xp,
		"level": creature.level,
		"energy": creature.energy,
		"exploring": creature.exploring,
		"current_location": creature.current_location,
		"inventory": creature.inventory,
		"experiences": creature.experiences,
		"affinities": creature.affinities,
		"tendencies": creature.tendencies,
		"events": creature.events
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(save_data)
	creature.add_log("Game Saved!")

func load_game():
	if not FileAccess.file_exists(save_path):
		creature.add_log("No save file found.")
		return
		
	var file = FileAccess.open(save_path, FileAccess.READ)
	var save_data = file.get_var()
	
	# Load base stats
	creature.xp = save_data.get("xp", 0)
	creature.level = save_data.get("level", 1)
	creature.energy = save_data.get("energy", 100.0)
	creature.exploring = save_data.get("exploring", false)
	creature.current_location = save_data.get("current_location", "Forest")
	
	# Load dictionaries safely
	creature.inventory.merge(save_data.get("inventory", {}), true)
	creature.experiences.merge(save_data.get("experiences", {}), true)
	creature.affinities.merge(save_data.get("affinities", {}), true)
	creature.tendencies.merge(save_data.get("tendencies", {}), true)
	creature.events.merge(save_data.get("events", {}), true)
	
	creature.stats_changed.emit()
	creature.add_log("Game Loaded!")

func reset_game():
	# 1. Delete the save file if it exists
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		
	# 2. Reload the entire scene to instantly reset everything to default
	get_tree().reload_current_scene()
