extends Node

@export var VideoPlayer:VideoStreamPlayer
@export var IntroCutsceneAudio:AudioStreamPlayer
@export var Music:AudioStreamPlayer
@export var PlayButton:Button
@export var OptionsButton:Button
@export var QuitButton:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VideoPlayer.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if VideoPlayer.is_playing():
			VideoPlayer.finished.emit()
	pass
	
	
func PlayGame():
	VideoPlayer.visible = true
	VideoPlayer.play()
	IntroCutsceneAudio.play()
	Music.stop()
	await VideoPlayer.finished
	GAMEMANAGER.ChangeRoot(GAMEMANAGER.GameplayRoot)
	pass

func OpenSettings():
	pass
	
func Quit():
	get_tree().quit()
	pass
