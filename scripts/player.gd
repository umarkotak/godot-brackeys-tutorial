extends CharacterBody2D

const SPEED := 120.0
const JUMP_VELOCITY := -250.0
const MAX_JUMPS := 2

const WALL_JUMP_VELOCITY_Y := -250.0
const WALL_JUMP_HORIZONTAL_ACCELERATION := 150.0
const WALL_SLIDE_GRAVITY_MULTIPLIER := 0.1
const MAX_WALL_SLIDE_SPEED := 150.0

var jumps_made: int = 0
var wall_jump_source_normal_x: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var effective_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var input_horizontal = Input.get_axis("ui_left", "ui_right")

	var on_floor_now = is_on_floor()
	var on_wall_now = is_on_wall()

	if on_floor_now:
		jumps_made = 0
		wall_jump_source_normal_x = 0.0
	elif on_wall_now:
		jumps_made = 0

	var is_sliding = false
	if on_wall_now and not on_floor_now and velocity.y >= 0:
		var current_wall_normal = get_wall_normal()
		if (current_wall_normal.x > 0 and input_horizontal < 0) or \
		   (current_wall_normal.x < 0 and input_horizontal > 0) or \
		   input_horizontal == 0:
			is_sliding = true
			effective_gravity *= WALL_SLIDE_GRAVITY_MULTIPLIER
			velocity.y = min(velocity.y, MAX_WALL_SLIDE_SPEED)

	if not on_floor_now:
		velocity.y += effective_gravity * delta

	if Input.is_action_just_pressed("ui_accept"):
		if is_sliding:
			var current_wall_normal = get_wall_normal()
			velocity.y = WALL_JUMP_VELOCITY_Y
			wall_jump_source_normal_x = current_wall_normal.x
			animated_sprite.flip_h = (wall_jump_source_normal_x < 0)
			jumps_made = 1
		elif jumps_made < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jumps_made += 1
			wall_jump_source_normal_x = 0.0

	if input_horizontal != 0:
		velocity.x = input_horizontal * SPEED
		animated_sprite.flip_h = (input_horizontal < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if wall_jump_source_normal_x != 0.0 and Input.is_action_pressed("ui_accept"):
		velocity.x += wall_jump_source_normal_x * WALL_JUMP_HORIZONTAL_ACCELERATION * delta

	if animated_sprite:
		if on_floor_now:
			if abs(velocity.x) > 10.0:
				animated_sprite.play("move")
			else:
				animated_sprite.play("idle")
		else:
			if is_sliding:
				animated_sprite.play("jump")
			else:
				animated_sprite.play("jump")

	move_and_slide()
