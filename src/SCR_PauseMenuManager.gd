extends Control
class_name PauseMenu
static var instance:PauseMenu

@export var ResumeButton:Button
@export var QuitButton:Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	visible = false
	ResumeButton.pressed.connect(ChangePauseValue.bind(false))
	QuitButton.pressed.connect(QuitGame)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = true
		ChangePauseValue(true)
	pass

func ChangePauseValue(_value:bool):
	get_tree().paused = _value
	visible = _value
	pass
	
	
func QuitGame():
	get_tree().quit()


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Master"),value)
	pass # Replace with function body.


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"SFX"),value)
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"MUSIC"),value)
	pass # Replace with function body.
