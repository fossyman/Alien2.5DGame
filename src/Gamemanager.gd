extends Node

var MAIN:Node
var ROOTCONTAINER:Node
var CURRENTROOT:RootManager
var CONSTANT:Node
var delta:float

enum FACTIONS{ALIEN,SCIENTIST,SOLDIER}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MAIN = get_tree().root.find_child("MAIN",true,false)
	ROOTCONTAINER = MAIN.get_child(0)
	CURRENTROOT = ROOTCONTAINER.get_child(0)
	CONSTANT = MAIN.get_child(1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	delta = _delta
	pass
