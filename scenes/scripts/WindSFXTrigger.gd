extends Node2D
class_name WindSFXTrigger
@export var audio_player:AudioStreamPlayer
@export var trigger_on_touch:bool = true
@export var stop_on_leave:bool = false
var played:bool = false
		
func _on_area_2d_body_entered(body):
	if audio_player.playing:
		return
	if is_instance_valid(body) and is_instance_of(body, Character):
		trigger()
		
func _process(_delta:float):
	if not played and audio_player.volume_db > -40:
		audio_player.volume_db -= 0.2
	if not played and audio_player.volume_db <= -40:
		audio_player.stop()
	if played and audio_player.volume_db < -20:
		audio_player.volume_db += 0.2
		audio_player.volume_db = min(-20.0, audio_player.volume_db)
	
func trigger():
	audio_player.play()
	played = true
	

func _on_area_2d_body_exited(body):
	if stop_on_leave:
		if is_instance_valid(body) and is_instance_of(body, Character):
			played = false
	
