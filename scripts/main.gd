extends Node2D

@onready var creature = $Creature
@onready var save_manager = $SaveManager

# ==========================================
# Button Signals
# ==========================================
func _on_explore_button_pressed():
	creature.explore()
	
func _on_location_button_pressed():
	creature.switch_location()

func _on_use_berry_button_pressed() -> void:
	creature.use_item("Berry")

func _on_use_ember_stone_button_pressed() -> void:
	creature.use_item("Ember Stone")

func _on_use_crystal_button_pressed() -> void:
	creature.use_item("Crystal")
	
func _on_use_fish_button_pressed() -> void:
	creature.use_item("Fish")

# ==========================================
# System Buttons
# ==========================================
func _on_save_button_pressed() -> void:
	save_manager.save_game()

func _on_load_button_pressed() -> void:
	save_manager.load_game()

func _on_reset_button_pressed() -> void:
	save_manager.reset_game()
