class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var elemental_manager = $ElementalManager
@onready var animation_player = $AnimationPlayer
#@onready var hitbox_component: HitboxComponent = $HitboxComponent
@export var move_speed = 200.0
@export var acceleration = 800.0
@export var friction = 6.0
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

enum ELEMENTS { FIRE, WATER, EARTH, AIR }
const VELOCITY_THRESHOLD = 10.0
const ATTACK_VELOCITY_THRESHOLD = 50.0
var current_element: ELEMENTS = ELEMENTS.FIRE
var is_attacking = false
var was_on_floor = true
var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0
var damage = 1

func _physics_process(delta: float) -> void:
	var input = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), 0)
	velocity.y += get_gravity() * delta
	
	# Jumping Mechanics with Coyote Time and Jump Buffering
	if Input.is_action_just_pressed("up"):
		if is_on_floor() or coyote_timer > 0:
			jump()
		else:
			jump_buffer_timer = jump_buffer_timer  # set buffer if player is in the air

	if not is_on_floor():
		coyote_timer = max(0, coyote_timer - delta)
	else:
		coyote_timer = coyote_timer  # reset timer if on the floor
		if jump_buffer_timer > 0:  # if jump is buffered, then jump
			jump_buffer_timer = 0  # clear buffer
			jump()

	if jump_buffer_timer > 0:
		jump_buffer_timer = max(0, jump_buffer_timer - delta)

	if Input.is_action_just_released("up") and velocity.y < 0:
		velocity.y *= 0.5

	# Directional Influence
	velocity.x += input.x * acceleration * delta
	velocity.x = clamp(velocity.x, -move_speed, move_speed)

	if input.x == 0 and is_on_floor():
		velocity.x = lerpf(velocity.x, 0, friction * delta)
	
	if Input.is_action_pressed("attack") and not is_attacking and not (is_on_floor() and abs(velocity.x) > ATTACK_VELOCITY_THRESHOLD):
		start_attack()

	if not is_attacking:
		handle_movement(input, delta)

	if Input.is_action_just_pressed("switch_to_fire"):
		elemental_manager.switch_element(ELEMENTS.FIRE)
	elif Input.is_action_just_pressed("switch_to_water"):
		elemental_manager.switch_element(ELEMENTS.WATER)
	elif Input.is_action_just_pressed("switch_to_earth"):
		elemental_manager.switch_element(ELEMENTS.EARTH)
	elif Input.is_action_just_pressed("switch_to_air"):
		elemental_manager.switch_element(ELEMENTS.AIR)

	move_and_slide()


func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func jump():
	velocity.y = jump_velocity
	animated_sprite_2d.play("jump")


func handle_movement(input: Vector2, delta: float) -> void:
	if input.x != 0:
		velocity.x += input.x * acceleration * delta
		velocity.x = clamp(velocity.x, -move_speed, move_speed)
	elif is_on_floor():
		velocity.x = lerpf(velocity.x, 0, friction * delta)
		# Check if the velocity is below the threshold
		if abs(velocity.x) < VELOCITY_THRESHOLD:
			velocity.x = 0

	# Animation Handling
	if is_on_floor():
		if velocity.x != 0:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
	else:
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		elif velocity.y > 0:
			animated_sprite_2d.play("fall")

	# Directional scaling based on input direction
	if input.x != 0:
		animated_sprite_2d.scale.x = sign(input.x)

#hitbox_component.scale.x = sign(input.x)
func start_attack() -> void:
#	if hitbox_component:
#		hitbox_component.damage = damage
	is_attacking = true
	animation_player.play("attack")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		is_attacking = false
