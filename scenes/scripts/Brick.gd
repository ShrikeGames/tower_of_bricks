extends RigidBody2D
class_name Brick
signal pick_up

@export var no_placing_area:Area2D
@export var locked_in_area:Area2D
@export var clickable_area:Area2D
@export var required_freeze_connections:int = 4
@export var debug_text:RichTextLabel
var is_ghost:bool = false
var initial_position:Vector2
var off_screen:bool = false
var game:Game
var hovered:bool = false
@export var brick_id:int = 0
@export var rare:bool = false
@export var unmovable:bool = false
@export var colour_override:Color
@export var wind_point:Vector2 = Vector2(0, 0)
var last_touched_pos:Vector2
func _ready():
	initial_position = self.global_position
	last_touched_pos = self.global_position
	if colour_override:
		self.modulate = colour_override
	elif not unmovable:
		colour_override =  Color(randf(), randf(), randf(), 1)
		self.modulate = colour_override
	
func _process(_delta):
	if abs(angular_velocity) < 0.001:
		angular_velocity = 0
	
	if is_ghost or off_screen:
		return
	
	if self.get_contact_count() > 0:
		for body in self.get_colliding_bodies():
			if is_instance_valid(body) and is_instance_of(body, Brick) and body.unmovable:
				last_touched_pos = body.global_position - Vector2(0, 100)
		
	if wind_point.x != 0 or wind_point.y != 0:
		self.apply_impulse(Global.get_wind_speed(self.position), wind_point)
	else:
		self.apply_central_impulse(Global.get_wind_speed(self.position))
		
	if unmovable:
		return
	
	if locked_in_area:
		var count:int = 0
		hovered = false
		freeze = false
		if clickable_area:
			for area in clickable_area.get_overlapping_areas():
				# mouse cursor
				if area.get_collision_layer_value(4):
					hovered = true
					break
		if locked_in_area:
			for area in locked_in_area.get_overlapping_areas():
				if area.get_collision_layer_value(3):
					count += 1
		if count >= required_freeze_connections:
			freeze = true
			if debug_text:
				debug_text.text = "[center]%s[/center]"%(count)
		else:
			freeze = false
			if debug_text:
				debug_text.text = ""
		if freeze:
			for brick in self.get_colliding_bodies():
				if is_instance_valid(brick) and is_instance_of(brick, Brick) and not brick.unmovable and brick.position.y > self.position.y:
					brick.freeze = true
	
#
	if self.global_position.y > initial_position.y + 1000:
		self.global_position = last_touched_pos
		self.angular_velocity = 0
		self.rotation = 0
		self.linear_velocity = Vector2(0,0)

