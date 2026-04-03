extends CanvasLayer

@onready var button_box : HBoxContainer = %ButtonBox
@onready var time_label : Label=  %TimeLeft 
@onready var success_label : Label= %SuccessLabel 
@onready var timer : Timer= $"%Timer"


signal finished(boolean: bool)

var buttonSelection = [
	{"action": "ui_down", "icon": preload("res://Sprites/Assets/Keyboard & Mouse/Default/keyboard_arrow_down.png")},
	{"action": "ui_left", "icon": preload("res://Sprites/Assets/Keyboard & Mouse/Default/keyboard_arrow_left.png")},
	{"action": "ui_right", "icon": preload("res://Sprites/Assets/Keyboard & Mouse/Default/keyboard_arrow_right.png")},
	{"action": "ui_up", "icon": preload("res://Sprites/Assets/Keyboard & Mouse/Default/keyboard_arrow_up.png")}
]
var actionSequence = []


var sequenceIndex = 0

func _ready() -> void:
	get_tree().paused = true
	success_label.hide()
	_set_random_sequence()
	
func _set_random_sequence() -> void:
	for node in button_box.get_children():
		var randomPick = buttonSelection.pick_random()
		node.texture = randomPick.icon
		actionSequence.append(randomPick.action)

func _input(event: InputEvent) -> void:
	#print("hit")
	if not timer.time_left: return
	if not event is InputEventKey or not event.is_pressed(): return

	if Input.is_action_just_pressed(actionSequence[sequenceIndex]):
		_next_index()
		
	else:
		_reset_all()

func _next_index() -> void:
	button_box.get_child(sequenceIndex).modulate.a = 0

	sequenceIndex += 1	
	if sequenceIndex >= actionSequence.size(): 
		timer.paused = true
		get_tree().root.get_node("World").challengeMult = 4
		_on_timer_timeout()

func _reset_all() -> void:

	sequenceIndex = 0
	for node in button_box.get_children():
		node.modulate.a = 1
func _process(delta: float) -> void:
	var remainingTime = snapped(timer.time_left, 0.01)
	time_label.text = str(remainingTime)
	
func _on_timer_timeout() -> void:
	var success = timer.time_left
	_update_success_label(success)
	get_tree().paused = false
	
	finished.emit(success)
func _update_success_label(success: bool) -> void:
	success_label.show()
	if success:
		success_label.text = "MULT +4"
		success_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		success_label.text = "FAIL"
		success_label.add_theme_color_override("font_color", Color.RED)
	await get_tree().create_timer(2).timeout
	self.queue_free()
