extends Area2D

# --- Betting & timing ---
var Gtime: float = 0.0        # total time bet by player
var BetTimeCoef: float = 1.0  # fuel/time multiplier affects spin speed
var LeakCoeff: float = 0.0    # per-second Gtime leakage coefficient

# --- Spin configuration ---
var DECEL_RATE := 50.0           # deg/sec^2, deceleration after first rotation
@export var NormSpinSpeed: float = 600  # base deg/sec for initial spin
@export var speedmult: float = 1.0        # additional multiplier
@export var round_speed_increase: float = 0.1  # +10% speed per round
@export var fuel_exp_factor: float = 0.8  # exponent for fuel mapping
var turns: int = 0                        # full rotations counted
var current_speed: Array[float] = []      # per-arm speed state

# --- Hit zones & arms ---
signal sendMult(Mult: Array[float])
signal failed

@onready var handsref = $Arms
@onready var Hitzones = $HitHolder
@onready var Inner = $HitHolder/Hitzones
@onready var Mid = $HitHolder/Hitzones2
@onready var Outer = $HitHolder/Hitzones3
var AllHitzones: Array = []
@onready var current_child: int = 0
@onready var max_children: int = 0
var AllMult: Array[float] = []

# --- Per-arm tolerances ---
@export var perf_tolerances: Array[float] = [10.0, 10, 10]
@export var good_tolerances: Array[float] = [45, 45, 45]

# --- World thresholds (for round reference) ---
@onready var World = get_tree().root.get_node("World")

func _ready() -> void:
	# initialize arrays
	AllHitzones = [Inner, Mid, Outer]
	max_children = handsref.get_child_count() - 1
	current_speed.resize(max_children + 1)
	AllMult.resize(max_children + 1)
	SceneReady()

func _process(delta: float) -> void:
	# reset hitzone colors
	for hz in AllHitzones:
		hz.modulate = Color("#ffffff")
	if current_child <= max_children:
		AllHitzones[current_child].modulate = Color("#ffc300")

	# handle stop input
	if Input.is_action_just_pressed("UseActive"):
		_stop_current_arm()
		return

	# time out check
	if Gtime <= 0.0:
		AllHitzones[current_child].modulate = Color("#ffffff")
		failed.emit()
		return

	# spin logic
	if current_child <= max_children:
		var arm = handsref.get_child(current_child)
		if turns < 1:
			# initial spin speed mapping: fuel & round
			var fuel_coef = pow(clamp(BetTimeCoef, 0.0, 1.0), fuel_exp_factor)
			var round_coef = 1.0 + (World.round - 1) * round_speed_increase
			current_speed[current_child] = NormSpinSpeed * fuel_coef * speedmult * round_coef
		else:
			# decelerate after one full spin
			current_speed[current_child] = max(current_speed[current_child] - DECEL_RATE * delta, 0.0)
		# apply rotation
		arm.rotation_degrees += current_speed[current_child] * delta
		print(current_speed[current_child] * delta)
		# count full rotations
		if arm.rotation_degrees >= 360.0:
			arm.rotation_degrees -= 360.0
			turns += 1
		# leak bet time
		Gtime *= pow(LeakCoeff, delta)

func _stop_current_arm() -> void:
	var arm = handsref.get_child(current_child)
	var zone = AllHitzones[current_child]
	var raw_diff = arm.rotation_degrees - zone.rotation_degrees
	# normalize to [-180,180]
	var diff = abs(fmod(raw_diff + 180.0, 360.0) - 180.0)
	# play sound based on per-arm tolerance
	if diff > good_tolerances[current_child]:
		$Miss.play()
	elif diff > perf_tolerances[current_child]:
		$GoodHit.play()
	else:
		$PerfHit.play()
	AllMult[current_child] = diff
	zone.modulate = Color("#ffffff")
	current_child += 1
	turns = 0
	if current_child > max_children:
		sendMult.emit(AllMult)
		SceneReady()

func SceneReady() -> void:
	# randomize hitzone angles
	for hz in AllHitzones:
		hz.rotation_degrees = randf_range(0.0, 360.0)
	# reset state
	current_child = 0
	turns = 0
	AllMult.fill(0.0)
	# Gtime reset handled externally
