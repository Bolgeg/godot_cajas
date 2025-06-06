extends CPUParticles3D

signal body_touched(body:Node3D,object:Node3D)
signal area_touched(area:Area3D,object:Node3D)

const MAX_RADIUS:=4.0

var radius:=0.0

func set_explosion_color(explosion_color:Color):
	color=explosion_color

func _ready() -> void:
	restart()
	%Timer.start()

func _physics_process(_delta: float) -> void:
	if radius==MAX_RADIUS:
		queue_free()
	else:
		radius=MAX_RADIUS*(1-%Timer.time_left/%Timer.wait_time)
		%CollisionShape3D.shape.radius=radius

func _on_area_3d_body_entered(body: Node3D) -> void:
	body_touched.emit(body,self)

func _on_area_3d_area_entered(area: Area3D) -> void:
	area_touched.emit(area,self)
