class_name CrateData
extends RefCounted

var apples_left:=0

var tnt_countdown:=0.0

var frame_apples_obtained:=false

func _init(apples_left_to_set:int,tnt_countdown_to_set:float) -> void:
	apples_left=apples_left_to_set
	tnt_countdown=tnt_countdown_to_set
