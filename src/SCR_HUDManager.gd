extends Control
class_name HUDManager
static var instance:HUDManager
@export var AlienProfile:Control
@export var ScientistProfile:Control
@export var SoldierProfile:Control

@export var CurrentProfile:Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ChangeProfile(NewProfile:Control):
	var T = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	T.parallel().tween_property(CurrentProfile,"position:x",-999,1.0)
	T.parallel().tween_property(NewProfile,"position:x",0,1.0)
	CurrentProfile = NewProfile
