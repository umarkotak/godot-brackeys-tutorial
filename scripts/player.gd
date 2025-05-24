extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY_Y = -280.0
const WALL_JUMP_PUSH_X = 140.0
const WALL_SLIDE_GRAVITY_MULTIPLIER = 0.1

var max_jump = 2

var is_after_wall_jump = 0
var current_jump = 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Or your actual node name

func _ready():
	pass

func _physics_process(delta: float) -> void:
	var current_gravity = get_gravity()

	# --- Wall Sliding Logic ---
	var is_sliding_on_wall = false
	if is_on_wall() and not is_on_floor() and velocity.y > 0: # Check for downward movement on wall
		# Optional: Only slide if pressing towards the wall
		var input_direction_x = Input.get_axis("ui_left", "ui_right")
		var wall_normal = get_wall_normal()
		# If wall_normal.x > 0, wall is on the left. If < 0, wall is on the right.
		# Slide if input is towards the wall or no horizontal input
		if (wall_normal.x > 0 and input_direction_x < 0) or \
		   (wall_normal.x < 0 and input_direction_x > 0) or \
		   input_direction_x == 0: # Allows sliding even without pressing into wall
			is_sliding_on_wall = true
			current_gravity *= WALL_SLIDE_GRAVITY_MULTIPLIER # Slower fall

	# Add the gravity.
	if not is_on_floor():
		velocity += current_gravity * delta
	# Optional: Limit max fall speed when wall sliding (if you want a max slide speed)
	if is_sliding_on_wall:
		velocity.y = min(velocity.y, 150.0) # Example max wall slide speed

	if is_on_floor() or is_on_wall():
		current_jump = 0

	# --- Handle Jump ---
	if Input.is_action_just_pressed("ui_accept"):
		if current_jump < max_jump:
			velocity.y = JUMP_VELOCITY
			current_jump += 1
	
	#if Input.is_action_just_pressed("ui_accept"):
		#if is_sliding_on_wall: # Wall Jump
			#var wall_normal = get_wall_normal()
			#velocity.y = WALL_JUMP_VELOCITY_Y
			## Push away from the wall
			## Flip character on wall jump
			#is_after_wall_jump = wall_normal.x
			#if wall_normal.x > 0: # Wall on the left, jumped right
				#animated_sprite.flip_h = false
				##velocity.x = WALL_JUMP_PUSH_X
			#elif wall_normal.x < 0: # Wall on the right, jumped left
				#animated_sprite.flip_h = true
				##velocity.x = -1 * WALL_JUMP_PUSH_X
	
	

	# --- Horizontal Movement and Flipping ---
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		if animated_sprite:
			animated_sprite.flip_h = (direction < 0) # Flip if moving left
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) # Decelerate

	if Input.is_action_pressed("ui_accept") && is_after_wall_jump != 0:
		#velocity.x = is_after_wall_jump * SPEED * 2
		velocity.x = velocity.x + (is_after_wall_jump * WALL_JUMP_PUSH_X)
		
	if is_on_floor():
		is_after_wall_jump = 0

	# --- Animation State ---
	if animated_sprite:
		if is_on_floor():
			if abs(velocity.x) > 10.0: # Small threshold to prevent flickering
				animated_sprite.play("move")
			else:
				animated_sprite.play("idle")
		else: # In the air
			if is_sliding_on_wall:
				# You could have a "wall_slide" animation here
				# animated_sprite.play("wall_slide") 
				# For now, let's keep it simple, maybe just "idle" or "jump"
				animated_sprite.play("jump")
			else: # Fallback if no jump animation
				animated_sprite.play("jump")


	move_and_slide()
