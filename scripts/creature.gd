extends CharacterBody2D

var xp := 0
var level := 1

var exploring := false

var home_position : Vector2

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

	exploring = true
	stats_changed.emit()

	print("Creature left to explore")

	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(300, 0), 1.0)

	await tween.finished

	await get_tree().create_timer(2.0).timeout

	var return_tween = create_tween()
	return_tween.tween_property(self, "position", home_position, 1.0)

	await return_tween.finished

	gain_xp(5)

	exploring = false
	stats_changed.emit()

	print("Creature returned")
	
func _ready():
	home_position = position
