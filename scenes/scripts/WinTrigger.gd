extends Node2D
class_name WinTrigger
@export var game:Game

func _on_area_2d_body_entered(body):
	if is_instance_valid(body) and is_instance_of(body, Character):
		trigger()
		
func trigger():
	var a_count:int = 0
	for a in Global.settings["achievements"].keys():
		if Global.settings["achievements"][a]:
			a_count += 1
	Global.settings["record"] ={
		"double_jumps": game.character.achievement_double_jump_count,
		"falls": game.falls,
		"bricks": game.achievement_num_bricks_picked_up,
		"time_sec": game.game_timer,
		"achievements": a_count
	}
	get_tree().change_scene_to_file("res://scenes/Win.tscn")
