extends CharacterBody3D
class_name Playermanager

@export var SPEED = 5.0
@export var WALKSPEED = 1.0
@export var RUNSPEED = 5.0

@export var JUMP_VELOCITY = 4.5

@export var ModelContainer:Node3D

@export var Floating:bool

@export var InteractArea:Area3D

@export var AnimTrees:Array[AnimationTree]
@export var CurrentAnimTree:AnimationTree

@export var AnimSmoothness:float = 15.0

@export var VisionGrabber:Area3D

@export var LightDetection:LightDetector

@export var AlienMesh:Node3D
@export var AlienFootSFX:Array[Area3D]
@export var ScientistMesh:Node3D
@export var ScientistFootSFX:Array[Area3D]
@export var SoldierMesh:Node3D
@export var SoldierMeshFootSFX:Array[Area3D]

@export var CurrentMesh:Node3D = AlienMesh

@export var TransfromDistorterParent:Node3D
@export var TransfromDistorters:Array[Node3D]

@export var CurrentFaction:GAMEMANAGER.FACTIONS

@export var AlienMusicAddition:AudioStreamPlayer
@export var ScientistMusicAddition:AudioStreamPlayer
@export var SoliderMusicAddition:AudioStreamPlayer

@export var CanMove:bool = true

var IsGrounded:bool = true

var MoveVal = 0.0

var TransformTween:Tween
var VisceraTween:Tween

func _ready() -> void:
	CurrentMesh = AlienMesh
	ChangeActiveMesh(AlienMesh)
	SPEED = WALKSPEED
	MoveVal = -1.0

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
	elif Input.is_action_just_pressed("transform_guard"):
		ChangeActiveMesh(SoldierMesh)
		
	if !Floating:
		if Input.is_action_just_pressed("interact"):
			if InteractArea.has_overlapping_areas():
				(InteractArea.get_overlapping_areas()[0] as Interactable).Interact()
	# Add the gravity.
	if not is_on_floor():
		if !Floating:
			velocity += get_gravity() * delta
		IsGrounded = false
		CurrentAnimTree["parameters/GroundAir/blend_amount"] = lerp(CurrentAnimTree["parameters/GroundAir/blend_amount"] as float,1.0,AnimSmoothness*delta)
	else:
		if !IsGrounded:
			pass
		IsGrounded = true
		CurrentAnimTree["parameters/GroundAir/blend_amount"] = lerp(CurrentAnimTree["parameters/GroundAir/blend_amount"] as float,0.0,AnimSmoothness*delta)
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or Floating):
		CurrentAnimTree["parameters/JumpShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		AnimTrees[0]["parameters/IsClimbing/blend_amount"] = 0.0
		await get_tree().create_timer(0.2).timeout
		Floating = false
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2.ZERO
	if CanMove:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if Floating:
			velocity.x = direction.x * SPEED
			velocity.y = -direction.z * SPEED
			AnimTrees[0]["parameters/ClimbBlend/blend_amount"] = input_dir.y
			ModelContainer.rotation_degrees.y = 90
		else:
			velocity.x = direction.x * SPEED
			if input_dir.x != 0:
				ModelContainer.rotation_degrees.y = 90 * input_dir.x
		
		if direction.x:
			CurrentAnimTree["parameters/MovementBlend/blend_amount"] = lerp(CurrentAnimTree.get("parameters/MovementBlend/blend_amount") as float,1.0 * MoveVal,AnimSmoothness*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if Floating:
			velocity.y = move_toward(velocity.y, 0, SPEED)
			AnimTrees[0]["parameters/ClimbBlend/blend_amount"] = input_dir.y
		CurrentAnimTree["parameters/MovementBlend/blend_amount"] = lerp(CurrentAnimTree.get("parameters/MovementBlend/blend_amount") as float,0.0,AnimSmoothness*delta)

	move_and_slide()

func ChangeActiveMesh(_node:Node3D):
	if CurrentMesh == _node:
		return
	if TransformTween:
		TransformTween.kill()
	if VisceraTween:
		VisceraTween.kill()
		
	TransformTween = create_tween().set_trans(Tween.TRANS_SPRING)
	for i in TransfromDistorters:
		i.visible = true
		TransformTween.parallel().tween_property(i,"scale",Vector3(randf_range(0.2,0.9),randf_range(0.2,0.9),randf_range(0.2,0.9)),randf_range(0.1,0.5))
		TransformTween.parallel().tween_property(i,"rotation_degrees",Vector3(0.5,10.,7.8)*randf_range(5.0,25.0),0.5)
	TransformTween.parallel().tween_property(CurrentMesh,"scale:x",0.1,0.5)
	TransformTween.parallel().tween_property(CurrentMesh,"scale:z",0.1,0.5)
	TransformTween.parallel().tween_property(CurrentMesh,"scale:y",0.1,0.5)
	
	for i in AnimTrees:
		i.active = false
	
	if !AlienFootSFX.is_empty():
		for i in AlienFootSFX:
			i.monitoring = false
	if !ScientistFootSFX.is_empty():
		for i in ScientistFootSFX:
			i.monitoring = false
	if !SoldierMeshFootSFX.is_empty():
		for i in SoldierMeshFootSFX:
			i.monitoring = false
		
	TransformTween.parallel().tween_property(AlienMusicAddition,"volume_db",-99,1.0)
	TransformTween.parallel().tween_property(ScientistMusicAddition,"volume_db",-99,1.0)
	TransformTween.parallel().tween_property(SoliderMusicAddition,"volume_db",-99,1.0)
	
	if CurrentMesh:
		TransformTween.parallel().tween_property(CurrentMesh,"scale",Vector3(0.01,0.01,0.01),1.0)
	
	var OldMesh = CurrentMesh
	
	match _node:
		
		AlienMesh:
			CurrentFaction = GAMEMANAGER.FACTIONS.ALIEN
			TransfromDistorterParent.scale.y = 0.01
			AlienMesh.visible = true
			TransformTween.parallel().tween_property(TransfromDistorterParent,"scale:y",0.5,0.5)
			TransformTween.parallel().tween_property(AlienMesh,"scale:x",1.0,0.5)
			TransformTween.parallel().tween_property(AlienMesh,"scale:z",1.0,0.5)
			TransformTween.parallel().tween_property(AlienMesh,"scale:y",1.0,0.5)
			CurrentAnimTree = AnimTrees[0]
			HUDManager.instance.ChangeProfile(HUDManager.instance.AlienProfile)
			TransformTween.parallel().tween_property(AlienMusicAddition,"volume_db",-5,1.0)
			if !AlienFootSFX.is_empty():
				for i in AlienFootSFX:
					i.monitoring = true
			pass
		ScientistMesh:
			CurrentFaction = GAMEMANAGER.FACTIONS.SCIENTIST
			TransfromDistorterParent.scale.y = 0.01
			TransformTween.parallel().tween_property(TransfromDistorterParent,"scale:y",1.0,0.5)
			
			TransformTween.parallel().tween_property(ScientistMesh,"scale:x",1.0,0.5)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:z",1.0,0.5)
			TransformTween.parallel().tween_property(ScientistMesh,"scale:y",1.0,0.5)
			CurrentAnimTree = AnimTrees[1]
			ScientistMesh.visible = true
			HUDManager.instance.ChangeProfile(HUDManager.instance.ScientistProfile)
			TransformTween.parallel().tween_property(ScientistMusicAddition,"volume_db",-5,1.0)
			if !ScientistFootSFX.is_empty():
				for i in ScientistFootSFX:
					i.monitoring = true
		SoldierMesh:
			CurrentFaction = GAMEMANAGER.FACTIONS.SOLDIER
			TransfromDistorterParent.scale.y = 0.01
			TransformTween.parallel().tween_property(TransfromDistorterParent,"scale:y",1.0,0.5)
			
			TransformTween.parallel().tween_property(SoldierMesh,"scale:x",1.0,0.5)
			TransformTween.parallel().tween_property(SoldierMesh,"scale:z",1.0,0.5)
			TransformTween.parallel().tween_property(SoldierMesh,"scale:y",1.0,0.5)
			CurrentAnimTree = AnimTrees[2]
			SoldierMesh.visible = true
			HUDManager.instance.ChangeProfile(HUDManager.instance.SoldierProfile)
			TransformTween.parallel().tween_property(SoliderMusicAddition,"volume_db",-5,1.0)
			if !SoldierMeshFootSFX.is_empty():
				for i in SoldierMeshFootSFX:
					i.monitoring = true
	
	CurrentAnimTree.active = true
	
	CurrentMesh = _node
	TransformTween.parallel().tween_property(CurrentMesh,"scale",Vector3(1.0,1.0,1.0),0.5)
	await TransformTween.finished
	
	VisceraTween = create_tween().set_trans(Tween.TRANS_EXPO)
	for i in TransfromDistorters:
		VisceraTween.parallel().tween_property(i,"scale",Vector3.ZERO,randf_range(0.2,1.0))
	await VisceraTween.finished
	for i in TransfromDistorters:
		i.visible = false
	
	if OldMesh != CurrentMesh:
		OldMesh.visible = false
