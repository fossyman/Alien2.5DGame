extends Node3D

@export var ScannerParent:Node3D
@export var ScannerMesh:MeshInstance3D
@export var ScannerScreen:ShaderMaterial
@export var DoorSFXPlayer:AudioStreamPlayer3D
@export var ScanningSFX:AudioStream
@export var SuccessSFX:AudioStream
@export var FailSFX:AudioStream
@export var CheckedFaction:GAMEMANAGER.FACTIONS

var isScanning:bool = false


var CheckingPlayer:Playermanager

@export var ScanDelay:float = 2.0
var ScanTimer:Timer

var ScanningDelta:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ScanTimer = Timer.new()
	add_child(ScanTimer)
	ScanTimer.wait_time = ScanDelay
	ScanTimer.timeout.connect(ScanCompleted)
	ScanTimer.one_shot = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !isScanning:
		return
	if CheckingPlayer:
		ScanningDelta += delta
		ScannerParent.rotation_degrees.z = sin((ScanningDelta*5))*20
	pass

func BeginScan():
	DoorSFXPlayer.stream = ScanningSFX
	ScannerMesh.visible = true
	(ScannerMesh.get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("Albedo", Vector3(1,1,0))
	ScannerScreen["shader_parameter/Albedo"] = Vector3(.8,.8,1)
	DoorSFXPlayer.play()
	ScanTimer.start()
	pass
	
func DecidePlayerValidity():
	if CheckingPlayer.CurrentFaction == CheckedFaction:
		DoorSFXPlayer.stream = SuccessSFX
		DoorSFXPlayer.play()
		(ScannerMesh.get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("Albedo", Vector3(0,1,0))
		ScannerScreen["shader_parameter/Albedo"] = Vector3(0,1,0)
	else:
		DoorSFXPlayer.stream = FailSFX
		DoorSFXPlayer.play()
		(ScannerMesh.get_surface_override_material(0) as ShaderMaterial).set_shader_parameter("Albedo", Vector3(1,0,0))
		ScannerScreen["shader_parameter/Albedo"] = Vector3(1,0,0)
	pass

func ScanCompleted():
	DecidePlayerValidity()
	pass

func _on_scanner_area_body_entered(body: Node3D) -> void:
	if body is Playermanager:
		CheckingPlayer = body
		isScanning = true
		BeginScan()
		pass
	pass # Replace with function body.


func _on_scanner_area_body_exited(body: Node3D) -> void:
	if body == CheckingPlayer:
		ScanTimer.stop()
		DoorSFXPlayer.stop()
		isScanning = false
		ScanningDelta = 0.0
	pass # Replace with function body.
