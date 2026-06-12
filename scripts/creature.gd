extends CharacterBody2D

var xp := 0
var level := 1

func gain_xp(amount):
	xp += amount
	
	if xp >= level * 10:
		xp = 0
		level += 1
		print("Level Up! ", level)
