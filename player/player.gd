extends CharacterBody2D

var bullet = preload("res://player/bullets.tscn")
@onready var muzzle: Marker2D = $muzzle

const GRAVITY = 1000
@export var SPEED : int = 1000
@export var max_horizontal_speed : int = 300
@export var JUMP : int = -350
@export var JUMP_HORIZONTAL : int = 150
@export var jump_horizontal_speed : int = 1000
@export var max_jump_horizontal_speed : int = 300

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


enum State {Idle, Run, Jump, Shoot}

var current_state : State
var muzzle_position

func _ready():
	current_state = State.Idle
	muzzle_position = muzzle.position
	
func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_muzzle_position()
	player_shooting(delta)
	
	move_and_slide()
	
	player_animations()
	
func player_falling(delta : float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(_delta : float):
	if is_on_floor():
		current_state = State.Idle

func player_run(delta : float):
	var direction = Input.get_axis("move left", "move right") #the first argument returns -1 and the second argument return +1
	
	if direction: #if direction equals 1 or -1
		velocity.x += direction * SPEED * delta
		velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		
	if direction != 0:
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction > 0 else true
		
func player_animations():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run and animated_sprite_2d.animation != "run_shoot":
		animated_sprite_2d.play("run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")
	elif current_state == State.Shoot:
		animated_sprite_2d.play("run_shoot")
		
func player_shooting(_delta : float):
	var direction = Input.get_axis("move left", "move right")
	
	if direction != 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = direction
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
		current_state = State.Shoot
		
		
func player_jump(delta : float):
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP
		current_state = State.Jump
		
	if !is_on_floor() and current_state == State.Jump:
		var direction = Input.get_axis("move left", "move right")
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)

func player_muzzle_position():
	var direction = Input.get_axis("move left", "move right")
	
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x
				
