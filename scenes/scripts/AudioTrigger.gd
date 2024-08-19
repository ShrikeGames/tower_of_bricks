extends Node2D
class_name AudioTrigger
@export var audio_player:AudioStreamPlayer
@export var trigger_on_touch:bool = true
@export var stop_on_leave:bool = false
@export var autoplay:bool = false
@export var audio_filename:String = ""
@export var play_random_audio:bool = true
@export var subtitles:Subtitles
@export var custom_subtitles:String
var played:bool = false
func _process(_delta:float):
	if played and not audio_player.playing:
		# audio file played completely so remove the trigger entirely
		if subtitles:
			subtitles.visible = false
		Global.playing_audio = false
		self.queue_free()
		return
		
func _on_area_2d_body_entered(body):
	if played or audio_player.playing or Global.playing_audio:
		return
	if is_instance_valid(body) and is_instance_of(body, Character):
		trigger()
		
func trigger():
	if play_random_audio:
		if Global.audio_voice_lines.is_empty():
			return
		else:
			var voice_index:int = randi_range(0, Global.audio_voice_lines.size()-1)
			audio_filename = Global.audio_voice_lines[voice_index]
			
			if subtitles:
				subtitles.sub_box.text = "[center]%s[/center]"%Global.subtitles[voice_index]
				subtitles.visible = true
			Global.audio_voice_lines.remove_at(voice_index)
			Global.subtitles.remove_at(voice_index)
	
	if subtitles and custom_subtitles:
		subtitles.sub_box.text = "[center]%s[/center]"%custom_subtitles
		subtitles.visible = true
	
	audio_player.stream = load(audio_filename)
	audio_player.play()
	Global.playing_audio = true
	played = true
	

func _on_area_2d_body_exited(body):
	if stop_on_leave:
		if is_instance_valid(body) and is_instance_of(body, Character):
			audio_player.stop()
			Global.playing_audio = false
	
