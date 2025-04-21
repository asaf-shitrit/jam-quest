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

# skills
@export var shooting: int # 1-99
@export var finishing: int # 1-99
@export var defense: int # 1-99
@export var rebounding: int # 1-99
@export var speed: int # 1-99
@export var strength: int # 1-99
@export var playmaking: int # 1-99
@export var stamina: int # 1-99

# visuals
@export var character_texture: Texture2D
