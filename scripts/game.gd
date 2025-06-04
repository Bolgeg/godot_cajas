extends Node3D

@onready var player:=%Player

const CRATE_TYPES:=[
	"wood_crate",
	"life_crate",
	"mask_crate",
	"checkpoint_crate",
	"arrow_crate",
	"bounce_crate",
	"nitro_crate",
	"tnt_crate",
	"tnt_crate_3",
	"tnt_crate_2",
	"tnt_crate_1",
	"metal_crate",
	"metal_checkpoint_crate",
	"metal_arrow_crate",
	"metal_activator_crate",
	"green_metal_crate",
	"green_metal_detonator_crate",
	"wireframe_crate",
]

var level:Node3D
var grid_map:GridMap

func _ready() -> void:
	level=$Level1
	grid_map=level.get_child(0)

func _physics_process(_delta: float) -> void:
	for block_position in player.get_spin_overlapping_block_positions():
		var block_type:=grid_map.get_cell_item(block_position)
		if block_type!=GridMap.INVALID_CELL_ITEM and block_type<CRATE_TYPES.size():
			var crate_type=CRATE_TYPES[block_type]
			break_crate_spinning(block_position,crate_type,0)

func break_crate_spinning(block_position:Vector3i,crate_type:String,_vertical_normal:int):
	match crate_type:
		"wood_crate":
			break_crate(block_position)
		"life_crate":
			break_crate(block_position)
		"mask_crate":
			break_crate(block_position)
		"checkpoint_crate":
			break_crate(block_position)
		"arrow_crate":
			break_crate(block_position)
		"bounce_crate":
			break_crate(block_position)
		"nitro_crate":
			break_crate(block_position)
		"tnt_crate":
			break_crate(block_position)
		"tnt_crate_3":
			break_crate(block_position)
		"tnt_crate_2":
			break_crate(block_position)
		"tnt_crate_1":
			break_crate(block_position)
		"metal_crate":
			pass
		"metal_checkpoint_crate":
			pass
		"metal_arrow_crate":
			pass
		"metal_activator_crate":
			pass
		"green_metal_crate":
			pass
		"green_metal_detonator_crate":
			pass
		"wireframe_crate":
			pass

func break_crate(block_position:Vector3i):
	grid_map.set_cell_item(block_position,-1)

func break_crate_bounce(block_position:Vector3i,vertical_normal:int):
	bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
	if not player.crate_broken_by_jumping:
		player.crate_broken_by_jumping=true
		break_crate(block_position)

func bounce_crate(_block_position:Vector3i,mode:String):
	match mode:
		"bounce_down":
			player.bounce(-8)
		"crate_bounce":
			if Input.is_action_pressed("jump"):
				player.bounce(11)
			else:
				player.bounce(8)
		"arrow_bounce":
			if Input.is_action_pressed("jump"):
				player.bounce(14)
			else:
				player.bounce(11)

func _on_player_collided_with_block(block_position:Vector3i,vertical_normal:int):
	var block_type:=grid_map.get_cell_item(block_position)
	if block_type!=GridMap.INVALID_CELL_ITEM and block_type<CRATE_TYPES.size():
		var crate_type=CRATE_TYPES[block_type]
		if player.spinning and vertical_normal!=0:
			break_crate_spinning(block_position,crate_type,vertical_normal)
		else:
			match crate_type:
				"wood_crate":
					if vertical_normal!=0:
						break_crate_bounce(block_position,vertical_normal)
				"life_crate":
					if vertical_normal!=0:
						break_crate_bounce(block_position,vertical_normal)
				"mask_crate":
					if vertical_normal!=0:
						break_crate_bounce(block_position,vertical_normal)
				"checkpoint_crate":
					if vertical_normal!=0:
						break_crate_bounce(block_position,vertical_normal)
				"arrow_crate":
					if vertical_normal!=0:
						if vertical_normal>0:
							bounce_crate(block_position,"arrow_bounce")
						else:
							break_crate_bounce(block_position,vertical_normal)
				"bounce_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"arrow_bounce" if vertical_normal>0 else "bounce_down")
				"nitro_crate":
					break_crate(block_position)
				"tnt_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
				"tnt_crate_3":
					pass
				"tnt_crate_2":
					pass
				"tnt_crate_1":
					pass
				"metal_crate":
					pass
				"metal_checkpoint_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
				"metal_arrow_crate":
					if vertical_normal>0:
						bounce_crate(block_position,"arrow_bounce")
				"metal_activator_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
				"green_metal_crate":
					pass
				"green_metal_detonator_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
				"wireframe_crate":
					pass
