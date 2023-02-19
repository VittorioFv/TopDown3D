extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var ACCELERATION = 0.2  	 # valore tra 0 e 1
var FRICTION = 0.5      	# valore tra 0 e 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var objectLiftable = null 
var objectLifted = false

func lift_or_drop_object():
	if objectLifted:
		objectLifted = false
		objectLiftable.collision_layer = 1
		objectLiftable.collision_mask = 1
		
		objectLiftable.global_transform.origin = global_transform.origin
	elif objectLiftable != null:
		objectLifted = true
		objectLiftable.collision_layer = 0
		objectLiftable.collision_mask = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Lift
	if Input.is_action_just_pressed("ui_accept"):
		lift_or_drop_object()

	# movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * SPEED)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * SPEED)
		velocity.z = move_toward(velocity.z, 0, FRICTION * SPEED)

	move_and_slide()
	
	if objectLifted:
		objectLiftable.global_transform.origin = objectLiftable.global_transform.origin.lerp(global_transform.origin + Vector3(0,2,0), delta*10);

func _on_area_3d_body_entered(body):
	if body.is_in_group("liftable"):
		objectLiftable = body

func _on_area_3d_body_exited(body):
	if not objectLifted:
		if body == objectLiftable:
			objectLiftable = null
