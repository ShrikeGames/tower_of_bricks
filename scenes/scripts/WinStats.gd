extends Node2D
@export var falls_count:RichTextLabel
@export var jumps_count:RichTextLabel
@export var bricks_count:RichTextLabel
@export var time_count:RichTextLabel
@export var a_count:RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	print(Global.settings["record"])
	falls_count.text = "%s"%[Global.settings["record"]["falls"]]
	jumps_count.text = "%s"%[Global.settings["record"]["double_jumps"]]
	bricks_count.text = "%s"%[Global.settings["record"]["bricks"]]
	time_count.text = "%s"%[snapped(Global.settings["record"]["time_sec"]/60.0, 0.01)]
	a_count.text = "%s"%[Global.settings["record"]["achievements"]]
