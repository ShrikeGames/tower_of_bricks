extends Node2D

@export var audio_player:AudioStreamPlayer
@export var scrolling_text:RichTextLabel
@export var canvas_layer_to_hide:CanvasLayer
func _ready():
	if Global.settings["preferences"]["skip_intro"]:
		get_tree().paused = false
		canvas_layer_to_hide.visible = true
		audio_player.stop()
		self.queue_free()
	else:
		visible = true
		canvas_layer_to_hide.visible = false
		get_tree().paused = true
		audio_player.play()


func _process(delta):
	if not visible:
		return
	if not audio_player.playing:
		get_tree().paused = false
		canvas_layer_to_hide.visible = true
		self.queue_free()
	else:
		scrolling_text.position.y -= 60 * delta


func _on_visibility_changed():
	if not visible:
		get_tree().paused = false
		canvas_layer_to_hide.visible = true
		audio_player.stop()
		self.queue_free()
