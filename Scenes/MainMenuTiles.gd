extends TileMapLayer

@export var tile_ids: Array[int] = [0, 1, 2, 3] # Atlas X coords
@export var source_id: int = 0  # TileSet source ID
@export var random_interval_range: Vector2 = Vector2(0.1, 0.5)
@export var fade_texture: Texture2D  # Texture to overlay (same size as your tile)
@export var overlay_layer: NodePath = "../FadeLayer"  # A Node2D in the parent or sibling of this layer
var rangemult = 6
var map_size = Vector2i(10, 10)  # Adjust to your tilemap bounds

func _ready():
	randomize()
	_fill_map_randomly()
	_start_random_updates()

func _start_random_updates():
	call_deferred("_random_update_loop")

func _random_update_loop():
	while true:
		var x = randi_range(map_size.x*-rangemult, map_size.x*rangemult)
		var y = randi_range(map_size.y*-rangemult, map_size.y*rangemult)
		var pos = Vector2i(x, y)

		# Choose a random tile ID (X coord in atlas)
		var atlas_coords = Vector2i(tile_ids.pick_random(), 0)
		set_cell(pos, source_id, atlas_coords)

		# Add fade effect
		_fade_tile_overlay(pos)

		var wait_time = randf_range(random_interval_range.x, random_interval_range.y)
		await get_tree().create_timer(wait_time).timeout

func _fade_tile_overlay(tile_pos: Vector2i):
	var sprite := Sprite2D.new()
	sprite.texture = fade_texture
	sprite.position = map_to_local(tile_pos)
	sprite.z_index = 100
	get_node(overlay_layer).add_child(sprite)

	var tween := create_tween()
	sprite.modulate.a = 0.0
	tween.tween_property(sprite, "modulate:a", 1.0, 0.2)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4).set_delay(0.3)
	tween.tween_callback(Callable(sprite, "queue_free"))
	
func _fill_map_randomly():
	pass
