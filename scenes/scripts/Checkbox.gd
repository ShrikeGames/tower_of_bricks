extends TextureButton

@export var settings_name:String

# Called when the node enters the scene tree for the first time.
func _ready():
	self.button_pressed = Global.settings["preferences"][settings_name]



func _on_toggled(toggled_button_pressed):
	Global.settings["preferences"][settings_name] = toggled_button_pressed
	Global.save_settings()
