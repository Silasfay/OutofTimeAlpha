
extends Button

var Filetext = "Engine Sealant
Decreases the amount of time leak there is but increases hand speed
+12% speed -2% leak
Cost: "
@export var base_price = 2
@onready var World = get_tree().root.get_node("World")
var price = 0 
var alreadyB = false
var Picture = preload("res://Sprites/Assets/Keyboard & Mouse/Default/keyboard_alt.png")
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	calcCost()
	self.text = Filetext + str(price)
	self.icon = Picture
	print(price)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _pressed() -> void:
	if alreadyB == false && World.TimeCrystals >= price:
		alreadyB = true
		print("already purchased Out of Stock")
		get_tree().root.get_node("World").NormSpinSpeed += .012
		get_tree().root.get_node("World").NormSpinSpeed += .2
		get_tree().root.get_node("World").TimeCrystals -= price
	

func calcCost():
	
	price = base_price * (1 + World.upgradeCount * 0.3) * (1 + (World.round / World.total_rounds) * 0.5)
	
