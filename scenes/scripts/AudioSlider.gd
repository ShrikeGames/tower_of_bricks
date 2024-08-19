extends HSlider

@export var audio_bus_name:String = "Master"

func update_volume(audio_bus_index:int, linear_value:float):
	var volume_db = 20 * (log(linear_value*0.01) / log(10))
	AudioServer.set_bus_volume_db(audio_bus_index, volume_db)

func _ready():
	value = Global.settings["audio"][audio_bus_name]
	
func _on_value_changed(changed_value):
	Global.settings["audio"][audio_bus_name] = changed_value
	update_volume(AudioServer.get_bus_index(audio_bus_name), changed_value * 100)
	Global.save_settings()
