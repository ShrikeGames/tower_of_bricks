extends AnimatedSprite2D
class_name Cloud
var move_speed:Vector2
var start_pos:Vector2

func _ready():
	self.set_frame_and_progress(randi_range(0, 7), 0)
	self.pause()
	start_pos = self.position
	move_speed = Global.get_wind_speed(self.position)
func _process(delta):
	self.position.x += move_speed.x * delta
	self.position.y += move_speed.y * delta
	if self.position.x > 1800:
		self.position.x = -200
		self.position.y = start_pos.y
