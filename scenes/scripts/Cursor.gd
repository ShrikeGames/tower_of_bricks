extends AnimatedSprite2D
class_name Cursor
@export var camera:Camera2D


func _ready():
	self.global_position = camera.get_global_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(_delta):
	self.global_position = camera.get_global_mouse_position()
