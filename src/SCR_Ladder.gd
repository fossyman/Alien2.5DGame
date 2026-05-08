extends Interactable

func _ready() -> void:
	super()
	body_exited.connect(BodyLeave)
	
func BodyLeave(body:Node3D):
	if body is Playermanager:
		if body.Floating:
			body.Floating = false
			GAMEMANAGER.CURRENTROOT.Player.AnimTrees[0].set("parameters/IsClimbing/blend_amount", 0.0)

func Interact():
	print("INTERACT")
	GAMEMANAGER.CURRENTROOT.Player.Floating = !GAMEMANAGER.CURRENTROOT.Player.Floating
	GAMEMANAGER.CURRENTROOT.Player.AnimTrees[0].set("parameters/IsClimbing/blend_amount", 1.0)
