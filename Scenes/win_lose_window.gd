extends Control

var FileText = ["YOU MADE IT BACK", "YOU ARE LOST FOREVER"]
@onready var MyLabel = $WinorLose
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func GameOver(out: bool) -> void:
	if out == true:
		MyLabel.text = FileText[0]
	if out == false:
		MyLabel.text = FileText[1] 
