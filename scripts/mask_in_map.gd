extends Area3D

signal body_touched(body:Node3D,object:Node3D)

func _ready() -> void:
	%GenerationTimer.start()

func _process(_delta: float) -> void:
	if %GenerationTimer.is_stopped():
		%Sprite3D.position=Vector3(0,0,0)
	else:
		var t:float=1-%GenerationTimer.time_left/%GenerationTimer.wait_time
		const MAX_HEIGHT:=1.0
		var height=(1-(t*2-1)**2)*MAX_HEIGHT
		%Sprite3D.position=Vector3(0,height,0)
	
	const LEVITATION_AMPLITUDE:=0.15
	var tl:float=1-%LevitationTimer.time_left/%LevitationTimer.wait_time
	var offset=sin(tl*PI*2)*LEVITATION_AMPLITUDE
	%Sprite3D.position.y+=offset

func _on_body_entered(body: Node3D) -> void:
	if %GenerationTimer.is_stopped():
		body_touched.emit(body,self)
