extends VBoxContainer
var MaxSales = 3
var ShopSelection = "res://Scenes/ShopItem.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Refresh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func Refresh() -> void:
	for i in self.get_children():
		i.queue_free()
	for i in MaxSales:
	
		var NewItem = load(ShopSelection).instantiate()
		self.add_child(NewItem)
		print(i, " spawned")
	if MaxSales ==3:
		var button = load("res://Scenes/Wider Recievers.tscn").instantiate()
		self.add_child(button)
	
	
