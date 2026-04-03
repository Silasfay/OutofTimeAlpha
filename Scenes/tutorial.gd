extends Control

@onready var pages = self.get_children()
var iterate = 0

func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("UseActive"):
		self.queue_free()
