extends Node2D

@export var sfx:AudioStreamPlayer
@export var button:TextureButton
var scene_to_change_to:String = "res://scenes/Game.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	var image = button.texture_normal.get_image()
	var normal_bitmap = BitMap.new()
	normal_bitmap.create_from_image_alpha(image)
	button.texture_click_mask = normal_bitmap

func _on_play_button_mouse_entered():
	sfx.play()
	self.scale = Vector2(1.5, 1.5)

func _on_play_button_mouse_exited():
	self.scale = Vector2(1, 1)


func _on_play_button_button_down():
	print("pressed")
	get_tree().change_scene_to_file(scene_to_change_to)
