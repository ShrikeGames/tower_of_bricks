extends Node2D
class_name WinTrigger

func _on_area_2d_body_entered(body):
	if is_instance_valid(body) and is_instance_of(body, Character):
		trigger()
		
func trigger():
	get_tree().change_scene_to_file("res://scenes/Win.tscn")
