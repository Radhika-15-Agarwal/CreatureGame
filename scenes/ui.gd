extends CanvasLayer

# Grab the creature from the parent node (Main)
@onready var creature = $"../Creature"

# ==========================================
# Core UI Elements
# ==========================================
@onready var level_label = $LevelLabel
@onready var xp_label = $XPLabel
@onready var state_label = $StateLabel
@onready var energy_label = $EnergyLabel
@onready var mood_label = $MoodLabel
@onready var location_label = $LocationLabel
@onready var preference_label = $PreferenceLabel
@onready var trait_label = $TraitLabel

# ==========================================
# Grouped Data Panels
# ==========================================
@onready var affinities_label = $AffinitiesLabel
@onready var experiences_label = $ExperiencesLabel
@onready var inventory_label = $InventoryLabel
@onready var tendencies_label = $TendenciesLabel

func _ready():
	setup_layout()
	creature.stats_changed.connect(update_ui)
	update_ui()

func setup_layout():
	# ==========================================
	# 1. Left Side: Static Stats
	# ==========================================
	var left_x = 30
	var start_y = 80 # Starts below your buttons
	var spacing = 35 # Vertical space between each line

	level_label.position = Vector2(left_x, start_y)
	xp_label.position = Vector2(left_x, start_y + spacing * 1)
	energy_label.position = Vector2(left_x, start_y + spacing * 2)
	state_label.position = Vector2(left_x, start_y + spacing * 3)
	mood_label.position = Vector2(left_x, start_y + spacing * 4)
	preference_label.position = Vector2(left_x, start_y + spacing * 5)
	trait_label.position = Vector2(left_x, start_y + spacing * 6)
	location_label.position = Vector2(left_x, start_y + spacing * 7)

	# ==========================================
	# 2. Right Side: Dynamic Panels (RichTextLabels)
	# ==========================================
	var right_x = 850
	var panel_size = Vector2(250, 130) # Fixes the text getting cut off/scrollbars
	var right_spacing = 140 # Space between the big boxes

	# Affinities
	affinities_label.size = panel_size
	affinities_label.position = Vector2(right_x, start_y)

	# Experiences
	experiences_label.size = panel_size
	experiences_label.position = Vector2(right_x, start_y + right_spacing * 1)

	# Inventory
	inventory_label.size = panel_size
	inventory_label.position = Vector2(right_x, start_y + right_spacing * 2)

	# Tendencies
	tendencies_label.size = panel_size
	tendencies_label.position = Vector2(right_x, start_y + right_spacing * 3)

func update_ui():
	# 1. Static Core Stats
	level_label.text = "Level: %d" % creature.level
	xp_label.text = "XP: %d/%d" % [creature.xp, creature.get_xp_threshold()]
	state_label.text = "State: " + creature.get_state()
	energy_label.text = "Energy: %d/%d" % [int(creature.energy), int(creature.max_energy)]
	mood_label.text = "Mood: " + creature.get_mood()
	location_label.text = "Location: " + creature.get_location()
	preference_label.text = "Preference: " + creature.get_preference()
	trait_label.text = "Trait: " + creature.get_trait_text()

	# Colorizing Energy based on tiredness
	if creature.energy <= 20:
		energy_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3)) # Red
	else:
		energy_label.remove_theme_color_override("font_color") # Default

	# 2. Dynamic Dictionaries
	var affinity_text = "--- Affinities ---\n"
	for affinity in creature.affinities:
		if creature.affinities[affinity] > 0:
			affinity_text += "%s: %d\n" % [affinity, creature.affinities[affinity]]
	affinities_label.text = affinity_text

	var exp_text = "--- Experiences ---\n"
	for exp in creature.experiences:
		if creature.experiences[exp] > 0:
			exp_text += "%s: %d\n" % [exp, creature.experiences[exp]]
	experiences_label.text = exp_text
	
	var inv_text = "--- Inventory ---\n"
	for item in creature.inventory:
		if creature.inventory[item] > 0:
			inv_text += "%s: %d\n" % [item, creature.inventory[item]]
	inventory_label.text = inv_text
	
	var tend_text = "--- Tendencies ---\n"
	for tend in creature.tendencies:
		if creature.tendencies[tend] != 0: 
			tend_text += "%s: %d\n" % [tend, creature.tendencies[tend]]
	tendencies_label.text = tend_text
