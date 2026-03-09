extends CharacterBody3D

var CurrentSpeed = 1.0
@export var MoveSpeed = 1.0
@export var RunSpeed = 1.0
const JUMP_VELOCITY = 4.5

enum WAYPOINTTYPE{WALLTOWALL,POINTS}

@export var WalltoWallRaycast:RayCast3D

@export var WaypointTypes:WAYPOINTTYPE

@export var WaypointContainer:Node

@export var AnimPlayer:AnimationPlayer
@export var AnimTree:AnimationTree

var Waypoints:Array[Node3D]
var WaypointID:int = 0

var DirectionVelocity:Vector3

@export var IdleTime:float
var IdleTimer:Timer

enum ENEMYSTATE{IDLE,MOVING,ATTACKING}
var EnemyState:ENEMYSTATE = ENEMYSTATE.MOVING

var IsRunning:bool = false

var ChasingPlayer:bool = false
var PlayerInProximity:bool = false
var HasSightOfPlayer:bool = false

var CurrentTarget:Vector3

@export var VisionArea:Area3D

func _ready() -> void:
	IdleTimer = Timer.new()
	add_child(IdleTimer)
	IdleTimer.wait_time = IdleTime
	IdleTimer.connect("timeout",EndIdle)
	IdleTimer.one_shot = true
	
	Waypoints.append_array(WaypointContainer.get_children())
	
	CurrentTarget = Waypoints[0].global_position
	DetermineWaypointDirection()

func _physics_process(delta: float) -> void:
	if PlayerInProximity and !HasSightOfPlayer and GAMEMANAGER.CURRENTROOT.Player.LightDetection.IsVisible:
		if GAMEMANAGER.CURRENTROOT.Player.LightDetection.IsVisible:
			PlayerSpotted()
		pass
	if ChasingPlayer:
		DetermineWaypointDirection()
	else:
		match EnemyState:
			ENEMYSTATE.IDLE:
				pass
			ENEMYSTATE.MOVING:
				if global_position.distance_to(CurrentTarget) < 0.2:
					WaypointReached()
					
	velocity = DirectionVelocity
	move_and_slide()

func DetermineAnimation():
	if velocity == Vector3.ZERO:
		AnimPlayer.play("Idle")
	pass

func SelectNextWaypoints():
	if ChasingPlayer:
		CurrentTarget = GAMEMANAGER.CURRENTROOT.Player.global_position
	else:
		WaypointID+=1
		if WaypointID > Waypoints.size()-1:
			WaypointID = 0
		CurrentTarget = Waypoints[WaypointID].global_position
		pass

func DetermineWaypointDirection():
	if CurrentTarget:
		if global_position.direction_to(CurrentTarget).x > 0:
			DirectionVelocity = Vector3.RIGHT * CurrentSpeed
			rotation_degrees.y = 0.0
		else:
			DirectionVelocity = Vector3.LEFT * CurrentSpeed
			rotation_degrees.y = 180.0
		EnemyState = ENEMYSTATE.MOVING
		CheckAnimationValue()

func WaypointReached():
	print("HIT WAYPOINT")
	BeginIdle()
	velocity = Vector3.ZERO
	pass

func BeginIdle():
	DirectionVelocity = Vector3.ZERO
	EnemyState = ENEMYSTATE.IDLE
	SetMoveSpeed(0.0)
	IdleTimer.start()
	
func EndIdle():
	SetMoveSpeed(MoveSpeed)
	SelectNextWaypoints()
	DetermineWaypointDirection()
	print("FINISHING IDLE, BEGINNING MOVEMENT")
	
func PlayerSpotted():
	print("PLAYER SPOTTED")
	if HasSightOfPlayer:
		return
	PlayerInProximity = true
	if GAMEMANAGER.CURRENTROOT.Player.LightDetection.IsVisible:
		print("AND THEY ARE IN THE LIGHT >:D")
		HasSightOfPlayer = true
		SetMoveSpeed(0.0)
		AnimTree["parameters/Spotted/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		await AnimTree.animation_finished
		print("start chase")
		SetMoveSpeed(RunSpeed)
	pass
	
func LostPlayer():
	PlayerInProximity = false
	HasSightOfPlayer = false
	CurrentTarget = GAMEMANAGER.CURRENTROOT.Player.global_position
	print("WE LOST THE PLAYER")
	pass

func CheckAnimationValue():
	var Movetween = create_tween()
	match EnemyState:
		ENEMYSTATE.IDLE:
			Movetween.tween_property(AnimTree,"parameters/Blend3/blend_amount",0.0,0.2)
		ENEMYSTATE.MOVING:
			if CurrentSpeed == RunSpeed:
				Movetween.tween_property(AnimTree,"parameters/Blend3/blend_amount",1.0,0.2)
			else:
				Movetween.tween_property(AnimTree,"parameters/Blend3/blend_amount",-1.0,0.2)

func _on_vision_area_entered(area: Area3D) -> void:
	if area.get_parent() is Playermanager:
		PlayerSpotted()
	pass # Replace with function body.

func _on_vision_area_exited(area: Area3D) -> void:
	if area.get_parent() is Playermanager:
		LostPlayer()
	pass # Replace with function body.


func AITick() -> void:
	match EnemyState:
		ENEMYSTATE.IDLE:
			return
		ENEMYSTATE.MOVING:
			if ChasingPlayer:
				CurrentTarget = GAMEMANAGER.CURRENTROOT.Player.global_position
			DetermineWaypointDirection()
	pass # Replace with function body.

func SetMoveSpeed(_amount:float):
	CurrentSpeed = _amount
	CheckAnimationValue()
