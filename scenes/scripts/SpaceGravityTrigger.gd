extends Node2D
class_name SpaceGravityTrigger
var audio_trigger_fab = load("res://scenes/AudioTrigger.tscn")
@export var subtitles:Subtitles
func _on_area_2d_body_entered(body):
	if is_instance_valid(body) and is_instance_of(body, Character):
		trigger()
	
func trigger():
	Global.space_gravity = true
	pass
	

func _on_area_2d_body_exited(body):
	if is_instance_valid(body) and is_instance_of(body, Character):
		Global.space_gravity = false
		if not Global.settings["achievements"].get("left_space", false):
			play_achievement_audio(body.global_position, "res://assets/audio/voice/reactions/left_space.wav", "Excuse me, player. You were so close, but you're going the wrong direction now.")
			Global.settings["achievements"]["left_space"] = true
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
	
