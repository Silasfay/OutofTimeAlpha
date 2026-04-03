extends Button


signal Purchase



@export var base_price = 2
@onready var World = get_tree().root.get_node("World")
@onready var Clock = World.get_child(3)
var price = 0 
var alreadyB = false
var ItemType
var AllItems =[
	{"action": "1", "icon": preload("res://Sprites/Assets/PerfectHit.png"), "Display": "4D Resonator
Increases the Perfect Hitzone by 1 degree
Cost: "},
	{"action": "2", "icon": preload("res://Sprites/Assets/goodHit.png") ,"Display":"Wide Recievers
Increases the Good Hitzone by 2 degree
Cost: "},
	{"action": "3", "icon": preload("res://Sprites/Assets/Sealant.png"), "Display": "Engine Sealant
Decreases the amount of time leak there is but increases hand speed
+12% speed -2% leak
Cost: "},
{"action": "4", "icon": preload("res://Sprites/Assets/Keyboard & Mouse/Default/keyboard_arrow_up.png"), "Display": "Gravity emitter
Increases the rate the hand's spin slows down by 5%
Cost :"}
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Clock)
	calcCost()
	ItemType = AllItems.pick_random()
	self.text = ItemType.Display + str(price)
	self.icon = ItemType.icon
	print(price)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _pressed() -> void:
	if alreadyB == false && World.TimeCrystals >= price:
		alreadyB = true
		print("already purchased Out of Stock")
		if ItemType.action =="1":
			get_tree().root.get_node("World").PerfAngle += 1
		if ItemType.action =="2":
			get_tree().root.get_node("World").GoodAngle += 2
		if ItemType.action =="3":
			Clock.NormSpinSpeed += 20
			Clock.LeakCoeff +=.2
		if ItemType.action =="4":
			Clock.DECEL_RATE += 5
		get_tree().root.get_node("World").TimeCrystals -= price
		self.text = ItemType.Display + "Purchased"
		World.upgradeCount +=2
	

func calcCost():
	
	price = base_price * (1 + World.upgradeCount * 0.3) * (1 + (World.round / World.total_rounds) * 0.5)
	if price == 0:
		price ==base_price
