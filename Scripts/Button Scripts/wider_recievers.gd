extends Button

var Filetext = "Pay 00:10:00:00 to permanently unlock another shop slot"
@onready var World = get_tree().root.get_node("World")
var Picture = preload("res://Sprites/Assets/Keyboard & Mouse/Default/keyboard_alt.png")
# Called when the node enters the scene tree for the first time.
@export var base_price = 2
var price = 0 
var alreadyB = false
func _ready() -> void:
	calcCost()
	self.text = Filetext + str(price)
	self.icon = Picture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _pressed() -> void:
	if get_parent().MaxSales == 3 && World.time_timer.time_left > 36000:
		World.adjust_timer(36000)
		get_parent().MaxSales = 4 # Replace with function body.
		self.queue_free()
		var NewItem = load(get_parent().ShopSelection).instantiate()
		get_parent().add_child(NewItem)




func calcCost():
	print("Price: ", price)
	price = base_price * (1 + World.upgradeCount * 0.3) * (1 + (World.round / World.total_rounds) * 0.5)
	
