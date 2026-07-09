class_name ItemData

const ITEMS = {
	# ==========================================
	# Exploration Loot
	# ==========================================
	"Berry": {
		"category": "food",
		"buyable": false,
		"effects": {
			"energy_restore_min": 8,
			"energy_restore_max": 12
		}
	},
	"Ember Stone": {
		"category": "affinity",
		"buyable": false,
		"effects": {
			"affinity_type": "Fire",
			"affinity_min": 1,
			"affinity_max": 2
		}
	},
	"Crystal": {
		"category": "affinity",
		"buyable": false,
		"effects": {
			"affinity_type": "Earth",
			"affinity_min": 1,
			"affinity_max": 2
		}
	},
	"Fish": {
		"category": "food", 
		"buyable": false,
		"effects": {
			"energy_restore_min": 5,
			"energy_restore_max": 5, # Static 5 energy
			"affinity_type": "Water",
			"affinity_min": 0,
			"affinity_max": 1
		}
	},
	
	# ==========================================
	# Shop Items & Ingredients
	# ==========================================
	"Flour": {
		"category": "ingredient",
		"buyable": true,
		"cost": 5,
		"unlock": {
			"level": 1
		}
	},
	"Fire Seasoning": {
		"category": "ingredient",
		"buyable": true,
		"cost": 50,
		"unlock": {
			"location": "Volcano"
		}
	},
	
	# ==========================================
	# Permanent Home Upgrades
	# ==========================================
	"Cozy Bed": {
		"category": "upgrade",
		"buyable": true,
		"cost": 150,
		"unlock": {
			"level": 1
		},
		"effects": {
			"energy_recovery_rate": 1.0
		}
	}
}
