extends Node2D

class SpinData:
	var current_speed = 0.0
	var target_speed = 0.0
	var direction = 1
	var transition_timer = 0.0
	var min_speed = 50.0
	var max_speed = 200.0

var gainTC = 0
@onready var time_timer = $Life
var Gtime: float = 0     #is bet time
var TimeCrystals = 2
#used in scoring to gain time 
@onready var Mult : float = 0

#base spin speed with counting how many times its spun around
var speedmult : float = 10
var round : int = 0
var roundGoal = 1000
var total_rounds = 8 
var upgradeCount = 0 
var randomspin = 90.0
#adjusts spin spead based on points needed and bet Time
var BetTimeCoef : float = 1
var NormSpinSpeed = .2
var GoodAngle = 45
var PerfAngle = 10
var goodHitSc = 2
var perfHitSc = 5
var challengeMult = 0 
#this controls how fast ur time leaks that ur betting
var LeakCoeff = .96
var turns : int = 0

#all Clock REfs
@onready var Clock = $Clock
@onready var handsref= $Clock/Arms # Called when the node enters the scene tree for the first time.
@onready var current_child = 0 
@onready var max_children = handsref.get_child_count() -1
@onready var Hitzones = $Clock/HitHolder

#Ui Refs(toomany try to reduce)
@onready var TimeBetter = $Windows/BetWindow/TimeBetter
@onready var BetWindow = $Windows/BetWindow

@onready var BetB = %BetButton
@onready var ButtonH = $Windows/PregameHolder
@onready var StoreWindow = $Windows/StoreWindow
@onready var ChalWindow = $Windows/ChallengesWindow
#Audio 
var buttons
@onready var PauseMenu = "res://Scenes/PauseMenu.tscn"
@onready var Challenge1 = "res://Scenes/button_sequence.tscn"
var spin_profiles = {}
var TimeNeedStr = "Time needed to progress: 
	" + update_time_label(roundGoal)
var font_file

func _ready() -> void:
	#$"Background Music".loop = true
	$RoundGoalLabel.text = TimeNeedStr
	$Windows.show()
	BetWindow.hide()
	StoreWindow.hide()
	ChalWindow.hide()
	print(time_timer.wait_time)
	$Clock.set_process(false)
	$Clock.connect("sendMult", Scoring)

	Clock.connect("failed", RestartRound)
	for i in $Windows/StoreWindow/Container/MarginContainer/ButtonBox.get_children():
		i.connect("Purchase", Purchase)
		
	for i in Hitzones.get_children():
		var spin = SpinData.new()
		spin.min_speed = randf_range(30, 100)   # Customize per hitzone
		spin.max_speed = randf_range(150, 400)
		spin.target_speed = randf_range(spin.min_speed, spin.max_speed)
		spin.transition_timer = randf_range(0.5, 2.0)
		spin_profiles[i] = spin
	await get_tree().process_frame  # or use call_deferred()
	await get_tree().process_frame
	_connect_all_buttons(get_tree().get_root())

func _connect_all_buttons(node):
	if node is Button:
		node.pressed.connect(_play_click_sound)
		#print("ive worked")
	for child in node.get_children():
		_connect_all_buttons(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TCLabel2.text = str(TimeCrystals)
	if ButtonH.visible == true:
	#this code makes the hitzones spin around idles when not engaged
		for i in Hitzones.get_children():
			var spin = spin_profiles[i]

		# Smooth speed change
			spin.current_speed = lerp(spin.current_speed, spin.target_speed * spin.direction, 3 * delta)
			i.rotation_degrees += spin.current_speed * delta

		# Countdown to next speed/dir change
			spin.transition_timer -= delta
			if spin.transition_timer <= 0:
				spin.direction = -1 if randf() < 0.5 else 1
				spin.target_speed = randf_range(spin.min_speed, spin.max_speed)
				spin.transition_timer = randf_range(0.5, 1.5)
	if BetWindow.visible == true:
		#this code makes the hitzones spin based on how much fuel is bet
		for i in Hitzones.get_children():
			i.rotation_degrees += 20 + Gtime * delta
	#Time Leak Func
	if round == total_rounds:
		Clock.set_process(false)
		#TODO make win screen
		$Windows/ScoringWindow.queue_free()
		$Windows/WinLoseWindow.show()
		$Windows/WinLoseWindow.GameOver(true)
	
	#time_timer.wait_time = float(Gtime)
	if Gtime <= 0:
		#print("game Over")
		$Clock.set_process(false)
	$RoundLabel.text = str(round) + " / " + str(total_rounds)
	$LifeLabel.text = "Life-time remaining: 
		" + update_time_label(time_timer.time_left)
	$BetLabel.text = "Fuel Time remaining: " + update_time_label(Clock.Gtime)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		var Pmenu = load(PauseMenu).instantiate()
		self.add_child(Pmenu)
		get_tree().paused = true
	
func Scoring(Mults: Array[float]):
	$"Background Music".pitch_scale = 1
	$TickTOckSOunds.stop()
	$Clock.set_process(false)
	var CalcMult : Array[float] =[0,0,0]
	var CalcScore = 0
	var child = 0
	var Pass = false
	Gtime = $Clock.Gtime
	Mult = 0
	print("Scoring: Angles Rceieved", Mults)
	for i in Mults:
		if abs(i)> GoodAngle: 
			print("miss")
			CalcMult[child] = -1 + abs(i)/360
			
		if abs(i) <GoodAngle:
			print("goodhit")
			CalcMult[child] = goodHitSc
			
		if abs(i) <PerfAngle:
			print("PerfHit")
			CalcMult[child] = perfHitSc
		Mult += CalcMult[child]
		
		child += 1
		print(child)
	Mult += challengeMult
	print(PerfAngle)
	print(CalcMult)
	print("mult is ", Mult)
	time_timer.wait_time
	
	CalcScore = Mult * Gtime
	print(Mult," * ",Gtime , " = ", CalcScore)
	
	
	if CalcScore >= roundGoal:
		Pass = true
		round += 1
		gainTC = int(CalcScore/roundGoal)
		#TODO put a round win screen here for polish
		print(gainTC)
		TimeCrystals += gainTC
		
		adjust_timer(-CalcScore)
		roundGoal = roundGoal * 1.5 + CalcScore*1.2
		print("New rg = ", roundGoal)
		TimeNeedStr = "Time needed to progress: 
		" + update_time_label(roundGoal)
		$RoundGoalLabel.text = TimeNeedStr
		$Windows/StoreWindow/Container/MarginContainer/ButtonBox.Refresh()
		
	else:
		print("Close but not close enough")
		#TODO put a round not pass screen
	$Windows/ScoringWindow.PassedData(CalcMult,CalcScore,Gtime,Mult,Pass,update_time_label(roundGoal),gainTC )
	$Windows/ScoringWindow.reveal_lines()
	print(CalcMult)
	ButtonH.show()
	gainTC = 0 
	challengeMult =0
	
	pass

func _on_time_better_drag_ended(value_changed: bool) -> void:
	
	print(Gtime, " ", time_timer.time_left)
	Gtime = time_timer.time_left * (clamp(TimeBetter.value,2,99)/100) #will get the amount of time they want to bet
	print(Gtime, " times ", TimeBetter.value, " is ", time_timer.time_left)
	
	$Clock.Gtime = Gtime

func _on_bet_back_button_pressed() -> void:
	BetWindow.hide()
	ButtonH.show()
	$TickTOckSOunds.stop()

func _on_bet_confirm_button_pressed() -> void:
	BetWindow.hide()
	adjust_timer(Gtime)
	print("Time left is ", time_timer.time_left)
	BetTimeCoef = clamp(Gtime / time_timer.time_left,2,1000000)
	print("BetCOef ", BetTimeCoef)
	$Clock.set_process(true)
	Clock.LeakCoeff = LeakCoeff
	Clock.BetTimeCoef = BetTimeCoef
	Clock.SceneReady()
	TimeBetter.value = clamp(TimeBetter.value, 2,99)
	print("Drag value: " , TimeBetter.value)
	

func adjust_timer(passed: float) -> void:
	var currentTime = time_timer.time_left
	time_timer.stop()
	print("time " ,time_timer.wait_time)
	time_timer.wait_time = currentTime - passed
	time_timer.start()

func _on_bet_button_pressed() -> void:
	ButtonH.hide()
	BetWindow.show() # Replace with function body.
	$TickTOckSOunds.autoplay = true
	$TickTOckSOunds.play()
	$TickTOckSOunds.pitch_scale = TimeBetter.value/50

func _on_life_timeout() -> void:
	#get_tree().paused = true
	#put gameover here
	$Windows/WinLoseWindow.show()
	$Windows/WinLoseWindow.GameOver(false)

func RestartRound() -> void:
	print("Round Restarted")
	Clock.set_process(false)
	ButtonH.show()

func update_time_label(Plabel: float):
	var total_seconds :int = Plabel
	var days = total_seconds / 86400
	var hours = (total_seconds % 86400) / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	var time_str = "%02d:%02d:%02d:%02d" % [days, hours, minutes, seconds]
	return time_str

func _on_store_pressed() -> void:
	ButtonH.hide()
	$Windows/StoreWindow.show()

func _on_challenges_pressed() -> void:
	
	ChalWindow.show()
	ButtonH.hide()
	if round >= 4:
		var f = load("res://Sprites/Assets/Fonts and Themes/Proc2.ttf") as FontFile
		$Windows/ChallengesWindow/Container/MarginContainer/ButtonBox/Button.text= "Pay half your life to get an time 
		multiplier (+4). Raction Based using arrow keys"
		$Windows/ChallengesWindow/Container/MarginContainer/ButtonBox/Button.add_theme_font_override("font", f)
		
func _on_quit_back_button_pressed() -> void:
	StoreWindow.hide() # Replace with function body.
	ButtonH.show()

func _on_c_quit_back_button_pressed() -> void:
	ChalWindow.hide() # Replace with function body.

func Purchase() -> void:
	upgradeCount += 1
	print(upgradeCount, " + 1")

func _on_button_3_pressed() -> void:
	get_tree().quit() # Replace with function body.

func _on_time_better_value_changed(value: float) -> void:
	$TickTOckSOunds.pitch_scale = value/50
	Gtime = time_timer.time_left * ((TimeBetter.value)/100) #will get the amount of time they want to bet
	#BetAmountLabel.text = str(Gtime)
	$Clock.Gtime = Gtime


func _on_button_2_pressed() -> void:
	$TilteScreen.hide()
	BeginTut()
	
	
	
func BeginTut():
	$Tutorial.show()
	
func _play_click_sound() -> void:
	$ClickPlayer.play()


func _on_try_again_pressed() -> void:
	get_tree().reload_current_scene() # Replace with function body.


func _on_button_pressed() -> void:
	if round >= 4:
		adjust_timer(time_timer.time_left/2)
		var Chal = load(Challenge1).instantiate()
		Chal.connect("finished", _inc_chalmult)
		self.add_child(Chal)

func _inc_chalmult():
	print("challengeMult ", challengeMult)
	challengeMult = 2
