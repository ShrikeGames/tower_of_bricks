extends Node2D
class_name Game
var audio_trigger_fab = load("res://scenes/AudioTrigger.tscn")
var cloud_fab = load("res://scenes/background/Cloud.tscn")
var brick_fab_2 = load("res://scenes/bricks/Brick2High.tscn")
var brick_fab_4 = load("res://scenes/bricks/Brick4High.tscn")
var brick_fab_6 = load("res://scenes/bricks/Brick6High.tscn")
var brick_fab_slope_left = load("res://scenes/bricks/BrickSlope4Left.tscn")
var brick_fab_slope_right = load("res://scenes/bricks/BrickSlope4Right.tscn")
var brick_fab_underslope_left = load("res://scenes/bricks/BrickUnderSlope4Left.tscn")
var brick_fab_underslope_right = load("res://scenes/bricks/BrickUnderSlope4Right.tscn")
var brick_fabs:Array = [brick_fab_2, brick_fab_4, brick_fab_6]
var rare_brick_fabs:Array = [brick_fab_slope_left, brick_fab_slope_right, brick_fab_underslope_left, brick_fab_underslope_right]
var rare_chance:float = 0.1
var ghost_brick_fabs:Array = []
var rare_ghost_brick_fabs:Array = []

@export var pop_sfx:AudioStreamPlayer
@export var brick_node:Node2D
@export var background_node:Node2D
@export var camera:Camera2D
@export var character:Character
@export var cursor:Cursor
@export var subtitles:Subtitles
var mouse_position:Vector2
var ghost_brick:Brick
var next_brick_id:int = 0
var next_is_rare:bool = false
var next_colour:Color
var brick:Brick
var falls:int = 0
var game_timer:float = 0
var achievement_num_bricks_picked_up:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0, len(brick_fabs)):
		var ghost_brick_fab = brick_fabs[i]
		ghost_brick_fabs.append(ghost_brick_fab)
	for i in range(0, len(rare_brick_fabs)):
		var ghost_brick_fab = rare_brick_fabs[i]
		rare_ghost_brick_fabs.append(ghost_brick_fab)
	
	next_brick_id = 0
	next_is_rare = false
	next_colour = Color(randf(), randf(), randf(), 1)
	init()
	
func update_camera():
	var limited_mouse_pos:Vector2 = Vector2(max(camera.get_screen_center_position().x-600, min(mouse_position.x, camera.get_screen_center_position().x+600)), max(camera.get_screen_center_position().y-600, min(mouse_position.y, camera.get_screen_center_position().y+600)))
	var target_pos:Vector2 = (character.position + limited_mouse_pos)*0.5
	camera.position = target_pos
	
func snap(vector:Vector2, precision:float = 1):
	return Vector2(snapped(vector.x, precision), snapped(vector.y, precision))

func _process(delta:float):
	game_timer += delta
	mouse_position = to_local(snap(camera.get_global_mouse_position()))
	update_camera()
	if is_instance_valid(ghost_brick):
		ghost_brick.position = mouse_position
		if ghost_brick.no_placing_area.has_overlapping_areas():
			# tell the player they can't place there
			ghost_brick.colour_override = Color(1, 0, 0, 0.2)
			ghost_brick.modulate = ghost_brick.colour_override
		else:
			var ghost_colour:Color = next_colour
			ghost_colour.a = 0.2
			ghost_brick.colour_override = ghost_colour
			ghost_brick.modulate = ghost_brick.colour_override
			if Input.is_action_just_pressed("interact"):
				cursor.set_frame_and_progress(0, 0)
				character.remove_head_brick()
				brick = get_next_brick()
				brick.position = mouse_position
				brick.brick_id = next_brick_id
				brick.rare = next_is_rare
				brick.colour_override = next_colour
				brick.collision_mask = 2
				brick_node.add_child(brick)
				ghost_brick.queue_free()
				next_is_rare = randf() < rare_chance
	else:
		if Input.is_action_just_pressed("interact"):
			for brick_object in brick_node.get_children():
				if is_instance_valid(brick_object) and is_instance_of(brick_object, Brick) and brick_object.hovered:
					pop_sfx.play()
					cursor.set_frame_and_progress(1, 0)
					next_brick_id = brick_object.brick_id
					next_is_rare = brick_object.rare
					next_colour = brick_object.modulate
					update_ghost_brick()
					for touching_brick in brick_object.get_colliding_bodies():
						if is_instance_valid(touching_brick) and is_instance_of(touching_brick, Brick) and not touching_brick.unmovable:
							touching_brick.sleeping = false
							touching_brick.freeze = false
					brick_object.queue_free()
					update_character()
					achievement_num_bricks_picked_up += 1
					break
		else:
			var hovering:bool = false
			for brick_object in brick_node.get_children():
				if is_instance_valid(brick_object) and is_instance_of(brick_object, Brick) and brick_object.hovered and not brick_object.unmovable:
					cursor.set_frame_and_progress(2, 0)
					hovering = true
					break
			if not hovering:
				cursor.set_frame_and_progress(0, 0)
	
	if not character.moved:
		character.achievment_time_since_last_moved += delta
	else:
		character.achievment_time_since_last_moved = 0
	
	if character.position.y > 1000:
		character.reset()
		falls += 1
		spawn_random_voice_line(character.global_position)
		
	elif character.position.y > character.last_ground_pos.y + 1000:
		falls += 1
		spawn_random_voice_line(character.global_position)
		
	else:
		if not Global.playing_audio:
			if not Global.settings["achievements"].get("double_jump_first", false) and character.achievement_double_jump_count > 0 and achievement_num_bricks_picked_up <= 0:
				play_achievement_audio(character.global_position, "res://assets/audio/voice/reactions/double jump first.wav", "The player decided to ignore the bricks and make use of their double jump. Curious.")
				Global.settings["achievements"]["double_jump_first"] = true
				Global.save_settings()
			elif not Global.settings["achievements"].get("brick_first", false) and character.achievement_double_jump_count <= 0 and achievement_num_bricks_picked_up > 0:
				play_achievement_audio(character.global_position, "res://assets/audio/voice/reactions/bricks first.wav", "The player decided to use the bricks instead of their double jump. Curious.")
				Global.settings["achievements"]["brick_first"] = true
				Global.save_settings()
			elif not Global.settings["achievements"].get("danced", false):
				var dance_check:int = 0
				var prev_direction:int = 0
				for dance_direction in character.achievement_dance_history:
					if dance_direction != prev_direction:
						dance_check += 1
					prev_direction = dance_direction
				if abs(dance_check) > 10 and character.achievement_dance_history.size() >= 60:
					play_achievement_audio(character.global_position, "res://assets/audio/voice/reactions/dance.wav", "And so the player decided to dance. And dance they would. A glorious dance. A dance of their peoples.")
					Global.settings["achievements"]["danced"] = true
					Global.save_settings()
			elif not Global.settings["achievements"].get("stood_still", false) and character.achievment_time_since_last_moved >= 60:
				play_achievement_audio(character.global_position, "res://assets/audio/voice/reactions/1_doesntmove.wav", "And so our heroic player decided to stay put, on the very first platform, unmoving, deep in thought.")
				Global.settings["achievements"]["stood_still"] = true
				Global.save_settings()
func play_achievement_audio(pos:Vector2, custom_audio_file:String, custom_subtitles:String):
	
	var audio_trigger:AudioTrigger = audio_trigger_fab.instantiate()
	audio_trigger.play_random_audio = false
	audio_trigger.audio_filename = custom_audio_file
	audio_trigger.custom_subtitles = custom_subtitles
	
	audio_trigger.global_position = pos
	audio_trigger.subtitles = subtitles
	add_child(audio_trigger)
	audio_trigger.trigger()
	

func spawn_random_voice_line(pos:Vector2):
	if Global.playing_audio:
		return
		
	if falls >= 1 and game_timer <= 60 and not Global.settings["achievements"]["fell_1"] and not Global.settings["achievements"]["fell_1_fast"]:
		play_achievement_audio(pos, "res://assets/audio/voice/reactions/fell off fast.wav", "You fell off already? I believe that puts you in the bottom 12% of all players.")
		Global.settings["achievements"]["fell_1_fast"] = true
		Global.save_settings()
		return
	elif falls >= 1 and not Global.settings["achievements"]["fell_1"] and not Global.settings["achievements"]["fell_1_fast"]:
		play_achievement_audio(pos, "res://assets/audio/voice/reactions/first fall.wav", "Congratulations on your first fall. Let’s hope there won’t be 506 more of those.")
		Global.settings["achievements"]["fell_1"] = true
		Global.save_settings()
		return
		
	if falls >= 7 and not Global.settings["achievements"]["fell_7"]:
		play_achievement_audio(pos, "res://assets/audio/voice/reactions/die 7 times.wav", "There is a Japanese saying that roughly translates to ‘Fall down 7 times, get up 8 times!’")
		Global.settings["achievements"]["fell_7"] = true
		Global.save_settings()
		return
	
	if falls >= 507 and not Global.settings["achievements"]["fell_507"]:
		play_achievement_audio(pos, "res://assets/audio/voice/reactions/died 507 times.wav", "The player will save the day. The player will keep you safe. Even if they have to die, FIVE. HUNDRED. AND SEVEN. TIMES. The player will save the day. And yes, you just died Five Hundred and Seven Times.")
		Global.settings["achievements"]["fell_507"] = true
		Global.save_settings()
		return
	
	var audio_trigger:AudioTrigger = audio_trigger_fab.instantiate()
	audio_trigger.play_random_audio = true
	audio_trigger.global_position = pos
	audio_trigger.subtitles = subtitles
	add_child(audio_trigger)
	audio_trigger.trigger()
	
func get_next_brick():
	if next_is_rare:
		brick = rare_brick_fabs[next_brick_id].instantiate()
	else:
		brick = brick_fabs[next_brick_id].instantiate()
	return brick
	
func update_character():
	var head_brick:Brick
	if next_is_rare:
		head_brick = rare_ghost_brick_fabs[next_brick_id].instantiate()
	else:
		head_brick = ghost_brick_fabs[next_brick_id].instantiate()
	head_brick.colour_override = next_colour
	head_brick.modulate = head_brick.colour_override
	character.add_head_brick(head_brick)
	
func update_ghost_brick():
	if is_instance_valid(ghost_brick):
		ghost_brick.queue_free()
		
	if next_is_rare:
		ghost_brick = rare_ghost_brick_fabs[next_brick_id].instantiate()
	else:
		ghost_brick = ghost_brick_fabs[next_brick_id].instantiate()
		
	ghost_brick.is_ghost = true
	ghost_brick.position = mouse_position
	ghost_brick.freeze = true
	ghost_brick.sleeping = true
	ghost_brick.collision_layer = 9
	ghost_brick.collision_mask = 9
	ghost_brick.remove_child(ghost_brick.locked_in_area)
	var ghost_colour:Color = next_colour
	ghost_brick.colour_override = ghost_colour
	ghost_brick.modulate = ghost_brick.colour_override
	add_child(ghost_brick)
	
func init():
	mouse_position = to_local(camera.get_global_mouse_position())
	camera.position.y = 450
