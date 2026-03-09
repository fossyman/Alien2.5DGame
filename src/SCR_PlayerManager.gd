extends CharacterBody3D
class_name Playermanager

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

@export var ModelContainer:Node3D

@export var Floating:bool

@export var AnimTree:AnimationTree

@export var AnimSmoothness:float = 15.0

@export var VisionGrabber:Area3D

@export var LightDetection:LightDetector

var IsGrounded:bool = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		IsGrounded = false
		AnimTree["parameters/GroundAir/blend_amount"] = lerp(AnimTree["parameters/GroundAir/blend_amount"],1.0,AnimSmoothness*delta)
	else:
		if !IsGrounded:
			pass
		IsGrounded = true
		AnimTree["parameters/GroundAir/blend_amount"] = lerp(AnimTree["parameters/GroundAir/blend_amount"],0.0,AnimSmoothness*delta)
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		AnimTree["parameters/JumpShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
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
		AnimTree["parameters/MovementBlend/blend_amount"] = lerp(AnimTree.get("parameters/MovementBlend/blend_amount") as float,1.0,AnimSmoothness*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if Floating:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		AnimTree["parameters/MovementBlend/blend_amount"] = lerp(AnimTree.get("parameters/MovementBlend/blend_amount") as float,0.0,AnimSmoothness*delta)

	move_and_slide()


func _on_light_detector_visibility_changed() -> void:
	pass # Replace with function body.
