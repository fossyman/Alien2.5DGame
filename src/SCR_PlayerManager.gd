extends CharacterBody3D
class_name Playermanager

@export var SPEED = 5.0
@export var WALKSPEED = 1.0
@export var RUNSPEED = 5.0

@export var JUMP_VELOCITY = 4.5

@export var ModelContainer:Node3D

@export var Floating:bool

@export var AnimTrees:Array[AnimationTree]

@export var AnimSmoothness:float = 15.0

@export var VisionGrabber:Area3D

@export var LightDetection:LightDetector

@export var AlienMesh:Node3D
@export var ScientistMesh:Node3D
var CurrentMesh:Node3D = AlienMesh

@export var TransfromDistorterParent:Node3D
@export var TransfromDistorters:Array[Node3D]

var IsGrounded:bool = true

var MoveVal = 0.0

var TransformTween:Tween
var VisceraTween:Tween

func _ready() -> void:
	CurrentMesh = AlienMesh

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("run"):
		SPEED = RUNSPEED
		MoveVal = 1.0
	elif Input.is_action_just_released("run"):
		SPEED = WALKSPEED
		MoveVal = -1.0
	
	if Input.is_action_just_pressed("transform_alien"):
		ChangeActiveMesh(AlienMesh)
	elif Input.is_action_just_pressed("transform_scientist"):
		ChangeActiveMesh(ScientistMesh)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		IsGrounded = false
		for i in AnimTrees:
			i["parameters/GroundAir/blend_amount"] = lerp(i["parameters/GroundAir/blend_amount"] as float,1.0,AnimSmoothness*delta)
	else:
		if !IsGrounded:
			pass
		IsGrounded = true
		for i in AnimTrees:
			i["parameters/GroundAir/blend_amount"] = lerp(i["parameters/GroundAir/blend_amount"] as float,0.0,AnimSmoothness*delta)
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		for i in AnimTrees:
			i["parameters/JumpShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		await get_tree().create_timer(0.2).timeout
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Floating:
			velocity.x = direction.x * SPEED
			velocity.y = -direction.z * SPEED
			ModelContainer.rotation_degrees.y = 90
		else:
			velocity.x = direction.x * SPEED
			if input_dir.x != 0:
				ModelContainer.rotation_degrees.y = 90 * input_dir.x
		for i in AnimTrees:
			i["parameters/MovementBlend/blend_amount"] = lerp(i.get("parameters/MovementBlend/blend_amount") as float,1.0 * MoveVal,AnimSmoothness*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if Floating:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		for i in AnimTrees:
			i["parameters/MovementBlend/blend_amount"] = lerp(i.get("parameters/MovementBlend/blend_amount") as float,0.0,AnimSmoothness*delta)

	move_and_slide()

func ChangeActiveMesh(_node:Node3D):
	if TransformTween:
		TransformTween.kill()
	if VisceraTween:
		VisceraTween.kill()
		
	TransformTween = create_tween().set_trans(Tween.TRANS_SPRING)
	for i in TransfromDistorters:
		i.visible = true
		TransformTween.parallel().tween_property(i,"scale",Vector3(randf_range(0.2,0.9),randf_range(0.2,0.9),randf_range(0.2,0.9)),randf_range(0.1,0.5))
		TransformTween.parallel().tween_property(i,"rotation_degrees",Vector3(0.5,10.,7.8)*randf_range(5.0,25.0),0.5)

	match _node:
		AlienMesh:
			TransfromDistorterParent.scale.y = 0
			TransformTween.parallel().tween_property(TransfromDistorterParent,"scale:y",0.5,0.5)
			AlienMesh.visible = true
			ScientistMesh.visible = true
			AlienMesh.scale = Vector3(0.0,0.0,0.0)
			TransformTween.parallel().tween_property(AlienMesh,"scale:x",1.0,0.5)
			TransformTween.parallel().tween_property(AlienMesh,"scale:z",1.0,0.5)
			TransformTween.parallel().tween_property(AlienMesh,"scale:y",1.0,0.5)
			
			ScientistMesh.scale = Vector3(1.0,1.0,1.0)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:x",0.5,0.5)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:z",0.5,0.5)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:y",0,0.5)
			pass
		ScientistMesh:
			TransfromDistorterParent.scale.y = 0
			TransformTween.parallel().tween_property(TransfromDistorterParent,"scale:y",1.0,0.5)
			AlienMesh.visible = true
			ScientistMesh.visible = true
			AlienMesh.scale = Vector3(1.0,1.0,1.0)
			TransformTween.parallel().tween_property(AlienMesh,"scale:x",0.1,0.5)
			TransformTween.parallel().tween_property(AlienMesh,"scale:z",0.1,0.5)
			TransformTween.parallel().tween_property(AlienMesh,"scale:y",2.0,0.5)
			
			ScientistMesh.scale = Vector3(0.0,0.0,0.0)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:x",1.0,0.5)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:z",1.0,0.5)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:y",1.0,0.5)
			pass
	await TransformTween.finished
	
	AlienMesh.visible = false
	ScientistMesh.visible = false
	_node.visible = true
	CurrentMesh = _node
	
	VisceraTween = create_tween().set_trans(Tween.TRANS_EXPO)
	for i in TransfromDistorters:
		VisceraTween.parallel().tween_property(i,"scale",Vector3.ZERO,randf_range(0.2,1.0))
	await VisceraTween.finished
	for i in TransfromDistorters:
		i.visible = false
