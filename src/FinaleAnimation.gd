extends AnimationPlayer

@export var AudioToSilence:Array[AudioStreamPlayer]
@export var FinaleBG:Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FinaleBG.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
func AnimStarted():
	var T = get_tree().create_tween()
	for i in AudioToSilence:
		T.parallel().tween_property(i,"volume_db",-99,1.0)
	pass
	
func AnimFinished(_name:StringName):
	GAMEMANAGER.ChangeRoot(GAMEMANAGER.MainMenuRoot)
	pass

func HideUI():
	HUDManager.instance.AlienProfile.visible = false
	HUDManager.instance.ScientistProfile.visible = false
	HUDManager.instance.SoldierProfile.visible = false
