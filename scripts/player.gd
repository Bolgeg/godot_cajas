extends CharacterBody3D

signal collided_with_block(block_position:Vector3i,vertical_normal:int)

@onready var sprite:=%Sprite3D
@onready var spin_timer:=%SpinTimer
@onready var spin_cooldown_timer:=%SpinCooldownTimer

var current_texture:=Vector2i(0,0)

var current_animation:="idle"
var animation_progress:=0.0

var orientation_right:=true

const GRAVITY:=20
const MAX_FALLING_SPEED:=30

const WALK_SPEED:=5.0
const JUMP_SPEED:=8.0

var spinning:=false

var bouncing:=false
var crate_broken_by_jumping:=false

func _ready() -> void:
	update_animation_sprite(0)

func bounce(bounce_velocity:float):
	bouncing=true
	velocity.y=bounce_velocity

func _physics_process(delta: float) -> void:
	var new_animation:="idle"
	
	if spin_timer.is_stopped():
		spinning=false
	
	var movement_axis:=Input.get_axis("move_left","move_right")
	if movement_axis>0:
		orientation_right=true
	elif movement_axis<0:
		orientation_right=false
	if movement_axis!=0:
		new_animation="walk"
	velocity.x=movement_axis*WALK_SPEED
	
	if not is_on_floor():
		new_animation="idle"
		velocity.y-=delta*GRAVITY
		if velocity.y<-MAX_FALLING_SPEED:
			velocity.y=-MAX_FALLING_SPEED
		if velocity.y<0:
			new_animation="fall"
	
	if Input.is_action_just_pressed("spin") and spin_cooldown_timer.is_stopped():
		spin_timer.start()
		spin_cooldown_timer.start()
		spinning=true
	
	if is_on_floor() and not bouncing and Input.is_action_just_pressed("jump"):
		velocity.y=JUMP_SPEED
	
	if spinning:
		new_animation="spin"
	
	change_animation(new_animation)
	update_animation_sprite(delta)
	
	var was_on_floor:=is_on_floor()
	var old_velocity:=velocity
	
	move_and_slide()
	
	bouncing=false
	crate_broken_by_jumping=false
	
	for index in get_slide_collision_count():
		var collision:=get_slide_collision(index)
		for j in collision.get_collision_count():
			var block_position:Vector3i=Vector3i((collision.get_position(j)-collision.get_normal(j)*0.1).floor())
			var normal:=collision.get_normal(j)
			var vertical_normal:=0
			if not was_on_floor:
				if old_velocity.y<0 and normal.y>0.5:
					vertical_normal=1
				elif old_velocity.y>0 and normal.y<-0.5:
					vertical_normal=-1
			collided_with_block.emit(block_position,vertical_normal)

func change_animation(new_animation:String):
	if new_animation!=current_animation:
		current_animation=new_animation
		animation_progress=0

func update_animation_sprite(delta:float):
	if current_animation=="idle":
		const IDLE_ANIMATION_DURATION:=1.0
		animation_progress+=delta/IDLE_ANIMATION_DURATION
		animation_progress-=floor(animation_progress)
		
		var t:=int(floor(animation_progress*4))
		
		current_texture= Vector2i(t,1) if orientation_right else Vector2i(t,0)
	elif current_animation=="walk":
		const WALK_ANIMATION_DURATION:=0.5
		animation_progress+=delta/WALK_ANIMATION_DURATION
		animation_progress-=floor(animation_progress)
		
		var t:=int(floor(animation_progress*4))
		
		current_texture= Vector2i(t,3) if orientation_right else Vector2i(t,2)
	elif current_animation=="spin":
		const SPIN_ANIMATION_DURATION:=0.3
		animation_progress+=delta/SPIN_ANIMATION_DURATION
		animation_progress-=floor(animation_progress)
		
		var t:=int(floor(animation_progress*3))
		
		current_texture=Vector2i(t,4)
	elif current_animation=="fall":
		animation_progress=0
		current_texture= Vector2i(0,6) if orientation_right else Vector2i(0,5)
	else:
		animation_progress=0
	
	update_sprite()

func update_sprite():
	sprite.region_rect.position=Vector2(current_texture)*sprite.region_rect.size
