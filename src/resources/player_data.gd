extends Resource

class_name PlayerData

# Info
@export var name: String
@export var age: int
@export var number: String

# physicals
@export var height: String # in feat
@export var wingspan: String # in feat
@export var weight: int # in lb
@export var stamina: int # 1-99

# skills
@export var shooting: int # 1-99
@export var finishing: int # 1-99
@export var rebounding: int # 1-99
@export var speed: int # 1-99
@export var strength: int # 1-99
@export var playmaking: int # 1-99

# defense
@export var interior_defense: int
@export var perimeter_defense: int
@export var steal: int

# visuals
@export var character_texture: Texture2D

func calculate_rating() -> int:
	# Define weights for each category
	var skill_weight = 0.4  # 40% weight for skills
	var physical_weight = 0.3  # 30% weight for physical attributes
	var defense_weight = 0.3  # 30% weight for defense

	# Calculate averages for each category
	var skill_average = (shooting + finishing + playmaking) / 3.0
	var physical_average = (speed + strength + stamina) / 3.0
	var defense_average = (interior_defense + perimeter_defense + steal) / 3.0

	# Combine the weighted averages
	var overall_rating = (skill_average * skill_weight) + (physical_average * physical_weight) + (defense_average * defense_weight)

	# Return the rating as an integer (rounded down)
	return int(overall_rating)
