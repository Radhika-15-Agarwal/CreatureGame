extends CharacterBody2D

var xp := 0
var level := 1

var exploring := false

func gain_xp(amount):
	xp += amount

	if xp >= level * 10:
		xp = 0
		level += 1
		print("Level Up! ", level)

func explore():
	if exploring:
		print("Already exploring")
		return

	exploring = true

	print("Creature left to explore")

	await get_tree().create_timer(2.0).timeout

	gain_xp(5)

	exploring = false

	print("Creature returned")
