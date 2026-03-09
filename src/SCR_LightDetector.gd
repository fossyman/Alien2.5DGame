extends SubViewport
class_name LightDetector
var LightTimer:Timer
@export var LightTick:float = 0.1
@export var AffectedSprite:Sprite3D
var CurrentLightLevel:float = 0.0

var IsVisible:bool = true

signal VisibilityChanged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LightTimer = Timer.new()
	add_child(LightTimer)
	LightTimer.wait_time = LightTick
	LightTimer.one_shot = false
	LightTimer.connect("timeout",CaptureLightLevel)
	LightTimer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	AffectedSprite.modulate.v = lerp(AffectedSprite.modulate.v,CurrentLightLevel,12*delta)
	pass

func CaptureLightLevel():
	CurrentLightLevel = get_viewport().get_texture().get_image().get_pixel(1,1).v
	var vis = IsVisible
	IsVisible = CurrentLightLevel > 0.3
	if vis != IsVisible:
		VisibilityChanged.emit()
	
