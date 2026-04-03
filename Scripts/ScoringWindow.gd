extends Control
@onready var Hbox = $HBoxContainer/VBoxContainer

@onready var World = get_tree().root.get_node("World")

@export var line_delay := 0.5
@export var score_lines := [

]
@onready var Scence = "res://Scenes/TheLabel.tscn"

@onready var sound := $LineRevealSound

func _ready():
	pass
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("UseActive") or Input.is_action_just_pressed("MouseUsed"):
		self.hide()
		for i in Hbox.get_children():
			i.queue_free()
	return
			
func reveal_lines():
	self.show()
	for line in score_lines:
		var label = load(Scence).instantiate()
		label.text = line
		label.visible = false
		add_theme_font_size_override(label.name, 100)
		Hbox.add_child(label)

		# Wait a bit before showing
		await get_tree().create_timer(line_delay).timeout
		
		if Input.is_action_just_pressed("UseActive"):
			break
		if label != null:
			label.visible = true
			sound.play()
		
func PassedData(Mults: Array, Total: int, Gtime: float, Mult: float,Passed: bool,RoundGoal: String, Cys: int):
	score_lines = [	"Arm 1: " + str("%.2f" %Mults[0]),
	"Arm 2: "+  str("%.2f" %Mults[1]),
	"Arm 3: "+  str("%.2f" %Mults[2]),
	 str("%.2f" %Mult)+ " times " +  str(World.update_time_label(Gtime)) + " = " +  str(World.update_time_label(Total)), 
	" "
	]
	if World.challengeMult > 0:
		pass
		#score_lines[4] = str("%.2f" %Mult)+ " plus" + str("%.2f" %World.ChallengeMult) +"times " +  str(World.update_time_label(Gtime)) + " = " +  str(World.update_time_label(Total))
	if Passed == true:
		score_lines.append("Enough time achieved")
		score_lines.append("New Goal is "+ RoundGoal)
		score_lines.append("Time crystals earned: " + str(Cys))
	else:
		score_lines.append("Not enough time to progress")
		
	score_lines.append("Press 'E' to Close")
