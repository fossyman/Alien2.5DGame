extends CharacterBody3D

@export var CurrentSpeed = 1.0
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

enum MOVESTATE{IDLE,MOVING,ATTACKING}
var MovementState:MOVESTATE = MOVESTATE.MOVING

var PlayerInProximity:bool = false
var ChasingPlayer:bool = false

@export var VisionArea:Area3D
@export var NavAgent:NavigationAgent3D

var TrackingTimer:Timer
@export var TimeToLoseTrack:float

func _ready() -> void:
	TrackingTimer = Timer.new()
	TrackingTimer.wait_time = TimeToLoseTrack
	TrackingTimer.one_shot = false
	add_child(TrackingTimer)
	TrackingTimer.timeout.connect(LoseTrackOfPlayer)
	
	Waypoints.append_array(WaypointContainer.get_children())
	UpdateAITarget(Waypoints[0])

func _physics_process(delta: float) -> void:
	
	if PlayerInProximity and !ChasingPlayer and GAMEMANAGER.CURRENTROOT.Player.LightDetection.IsVisible:
		ChasingPlayer = true
	
	if ChasingPlayer:
		UpdateAITarget(GAMEMANAGER.CURRENTROOT.Player)
	
	var next_path_position: Vector3 = NavAgent.get_next_path_position()
	var local_position = next_path_position - global_position
	var direction = local_position.normalized() * MoveSpeed
	NavAgent.velocity = direction
	pass

func NAV_SafeVelocityFound(_safe_Velocity:Vector3):
	if _safe_Velocity == Vector3.ZERO:
		return
	velocity = _safe_Velocity
	rotation.y = atan2(velocity.z,velocity.x)
	move_and_slide()

func GetNextPatrolPoint() -> Node3D:
	WaypointID+=1
	WaypointID = wrap(WaypointID,0,WaypointContainer.get_child_count())
	print("Next patrol point is:: " + str(WaypointID))
	return Waypoints[WaypointID]

func PlayerSpotted():
	pass

func _on_vision_area_entered(area: Area3D) -> void:
	if area.get_parent() is Playermanager:
		PlayerInProximity = true
		if GAMEMANAGER.CURRENTROOT.Player.LightDetection.IsVisible:
			TrackingTimer.stop()
	pass # Replace with function body.

func _on_vision_area_exited(area: Area3D) -> void:
	if area.get_parent() is Playermanager:
		PlayerInProximity = false
		TrackingTimer.start()
		pass
	pass # Replace with function body.

func UpdateAITarget(_node:Node3D):
	NavAgent.target_position = _node.global_position
	print("TARGET POSITION SET")
	
func SetMoveSpeed(_amount:float):
	CurrentSpeed = _amount
	CheckAnimationValue()

func _on_nav_agent_target_reached() -> void:
	print("TARGET_REACHED")
	if !ChasingPlayer:
		await get_tree().process_frame
		UpdateAITarget(GetNextPatrolPoint())
	pass # Replace with function body.
	
func CheckAnimationValue():
	var Movetween = create_tween()
	match MovementState:
		MOVESTATE.IDLE:
			Movetween.tween_property(AnimTree,"parameters/Blend3/blend_amount",0.0,0.2)
		MOVESTATE.MOVING:
			if CurrentSpeed == RunSpeed:
				Movetween.tween_property(AnimTree,"parameters/Blend3/blend_amount",1.0,0.2)
			else:
				Movetween.tween_property(AnimTree,"parameters/Blend3/blend_amount",-1.0,0.2)

func LoseTrackOfPlayer():
	print("LOST HIM")
	ChasingPlayer = false
	await get_tree().process_frame
	UpdateAITarget(GetNextPatrolPoint())
	pass
