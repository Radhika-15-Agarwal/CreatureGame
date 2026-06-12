extends Node2D

@onready var creature = $Creature

func _on_explore_button_pressed():
	creature.explore()
