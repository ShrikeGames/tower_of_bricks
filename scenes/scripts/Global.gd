extends Node

var space_gravity:bool = false

var wind_speeds:Dictionary = {
	-400: Vector2(0.0, 0.0),
	-1200: Vector2(60.0, 10.0),
	-5000: Vector2(0.0, 0.0)
}


func get_wind_speed(pos:Vector2):
	for wind_speed_key in wind_speeds.keys():
		if pos.y > wind_speed_key:
			return wind_speeds[wind_speed_key]
	return Vector2(0.0, 0.0)
var playing_audio:bool = false

var audio_voice_lines:Array[String] = ["res://assets/audio/voice/a true friend.wav",
 "res://assets/audio/voice/achieve your goal.wav", 
"res://assets/audio/voice/became lost.wav", 
"res://assets/audio/voice/better than you are.wav", 
"res://assets/audio/voice/brighter the light.wav", 
"res://assets/audio/voice/courage.wav", 
"res://assets/audio/voice/cry give up.wav", 
"res://assets/audio/voice/do it again but better.wav", 
"res://assets/audio/voice/doom2.wav", 
"res://assets/audio/voice/drying pan.wav", 
"res://assets/audio/voice/feeling low.wav", 
"res://assets/audio/voice/great things.wav", 
"res://assets/audio/voice/hard work.wav", 
"res://assets/audio/voice/hear you crying.wav", 
"res://assets/audio/voice/I try to escape.wav", 
"res://assets/audio/voice/ignorance.wav", 
"res://assets/audio/voice/joy of discovery.wav", 
"res://assets/audio/voice/mourn in the dark.wav", 
"res://assets/audio/voice/passion.wav", 
"res://assets/audio/voice/path set forth.wav", 
"res://assets/audio/voice/seeds of doubt.wav", 
"res://assets/audio/voice/stand back up.wav", 
"res://assets/audio/voice/success.wav", 
"res://assets/audio/voice/truth lies.wav", 
"res://assets/audio/voice/two types of people.wav", 
"res://assets/audio/voice/understand.wav", 
"res://assets/audio/voice/world is constantly changing.wav"]
var subtitles:Array[String] = ["In my eyes, a true friend is someone who never clings to another's dream. Someone independent, who can find his own reason to live, and follow that path without guidance. And if anyone tries to crush his dream, he'll protect it heart and soul. Even if that person happened to be me. For me, a true friend is someone whom I consider my equal. - Griffith", 
"If you achieve your goal, you celebrate and feel terrific, but only until you realize that you just lost the thing that gave you purpose and direction. Your options are to feel empty and useless, perhaps enjoying the spoils of your success until they bore you, or to set new goals and re-enter the cycle of permanent presuccess failure. - Scott Adams",
"We wanted the courage to face our future, yet we became lost. - Pandora Hearts",
"You thought by now you'd be. So much better than you are. You thought by now they'd see. That you had come so far/ And the pride inside their eyes/ Would synchronize into a love you've never know. So much more than you've been shown",
"The brighter the light, the darker the nearby shadows grow. - Berserk",
"What it takes to overcome a crisis is not bravery... but a calm, calculated resolve to put everything on the line - Girls und Panzer",
"Cry... give up... it's okay...",
"Do it again, but better - Bop It! Extreme",
"Here in my car, I am playing Doom 2. Crashed into a school. 'cause I wanted to play Doom 2 - Amiya Aranha & Shukterhouse Jive",
"Oh no! It's raining! I know, I'll use my trusty frying pan as a drying pan! - Brock",
"I remember feeling low. I remember losing hope. I remember all the feelings. And the day they stopped. - Innocent by Our Lady Peace",
"One who plans to achieve great things inevitably endures terrible things. - Berserk",
"The belief that you're always rewarded for hard work is just a fairy tale. - ./hack//roots",
"I heard you crying through all the noise, and when I laughed I showed my weakness. - Pandora Hearts",
"I try to escape this harrowing reality. Everything I hoped for in my life turned out to be an illusion. A flood of emotions, struggles that lead me astray... I just want to cling onto them and move forward. - Casshern Sins",
"Indifference, overblown with confidence and ignorance. It all made sense.  - All you need is hate by The Delgados",
"We are surrounded by things we don't know or understand. It's because we don't know that there is the joy of discovery. It's because we don't comprehend that there is the joy of understanding. Even if you don't know the rules... just fully experience your role and take it as it comes. There's nothing left to enjoy if you know everything. - .hack//roots",
"Mourn in the dark, the bliss and the beauty will not return. - Nightfall by Blind Guardian",
"Some lack the passion to prevail, but not us, only the weak",
"Underneath everything the hidden truth is contained - but it is not obvious. It is imperative to know the truth and pursue the path which you have set forth. - King's Field 2 (3 in JP)",
"The seeds of doubt I thought I had thrown away sprouted and ripped through my heart. - Fractale",
"I've got something that no one can take from me. No matter how many times I fall, I'll stand back up. - Ben-To",
"'Staying the course' only makes sense if you're headed in a sensible direction. Because passion and persistence - while most often associated with success - are also essential ingredients of futility. - Mike Rowe",
"I look for the truth, but if lies are all I can find, so be it. - UN-GO",
"There are two types of people. The type that turtles in fear at the last moment, and the type that rises to the occasion. - Kaiji",
"It's all right if you don't understand. It's better than thinking that you understand it so easily. - Subaru fgrom .hack//sign",
"The world is constantly changing and you can't expect it to stay the same, even for a second. - Kino's Journey"
]
var settings = {
	"audio": {
		"Master": 1.0,
		"Voice": 0.5,
		"SFX": 1.0,
		"Music": 0.25,
		
	},
	"preferences":{
		"skip_intro": false,
	},
	"achievements": {
		"fell_1": false,
		"fell_1_fast": false,
		"fell_7": false,
		"fell_507": false,
		"double_jump_first": false,
		"brick_first": false,
		"danced": false
	}
}
var settings_config_location:String = "user://settings.json"
func save_settings():
	# save the results
	var json_string := JSON.stringify(settings)
	# We will need to open/create a new file for this data string
	var file_access := FileAccess.open(settings_config_location, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
		
	file_access.store_line(json_string)
	file_access.close()
	
func load_settings():
	if not FileAccess.file_exists(settings_config_location):
		return settings
	var json_string = FileAccess.get_file_as_string(settings_config_location)
	settings = JSON.parse_string(json_string)
	return settings

func _ready():
	load_settings()
