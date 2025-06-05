extends Node3D

@onready var player:=%Player
@onready var item_container:=%ItemContainer

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

const APPLE_BLOCK_INDEX:=20
const LIFE_BLOCK_INDEX:=21
const MASK_BLOCK_INDEX:=22

var level:Node3D
var grid_map:GridMap
var level_items:Node3D

var apples:=0
var crates:=0
var crates_total:=0
var lifes:=5

func _ready() -> void:
	level=$Level1
	grid_map=level.get_child(0)
	level_items=level.get_child(1)
	process_map()

func _process(_delta: float) -> void:
	item_container.update(apples,crates,crates_total,lifes)

func process_map():
	for apple_position in grid_map.get_used_cells_by_item(APPLE_BLOCK_INDEX):
		grid_map.set_cell_item(apple_position,-1)
		var apple:=preload("res://scenes/apple.tscn").instantiate()
		level_items.add_child(apple)
		apple.global_position=Vector3(apple_position)+Vector3(0.5,0.5,0.5)
		apple.body_touched.connect(_on_body_touched_apple)
	
	for life_position in grid_map.get_used_cells_by_item(LIFE_BLOCK_INDEX):
		grid_map.set_cell_item(life_position,-1)
		var life:=preload("res://scenes/life.tscn").instantiate()
		level_items.add_child(life)
		life.global_position=Vector3(life_position)+Vector3(0.5,0.5,0.5)
		life.body_touched.connect(_on_body_touched_life)
	
	for mask_position in grid_map.get_used_cells_by_item(MASK_BLOCK_INDEX):
		grid_map.set_cell_item(mask_position,-1)
		var mask:=preload("res://scenes/mask_in_map.tscn").instantiate()
		level_items.add_child(mask)
		mask.global_position=Vector3(mask_position)+Vector3(0.5,0.5,0.5)
		mask.body_touched.connect(_on_body_touched_mask)
	
	crates_total=0
	for block_position in grid_map.get_used_cells():
		var block_type:=grid_map.get_cell_item(block_position)
		if block_type!=GridMap.INVALID_CELL_ITEM and block_type<CRATE_TYPES.size():
			var crate_type=CRATE_TYPES[block_type]
			if crate_type!="metal_crate" and crate_type!="metal_arrow_crate" and crate_type!="green_metal_crate":
				crates_total+=1

func _on_body_touched_apple(body:Node3D,object:Node3D):
	if body.get_instance_id()==player.get_instance_id():
		absorb_apple(object.global_position)
		object.queue_free()

func _on_body_touched_life(body:Node3D,object:Node3D):
	if body.get_instance_id()==player.get_instance_id():
		absorb_life(object.global_position)
		object.queue_free()

func _on_body_touched_mask(body:Node3D,object:Node3D):
	if body.get_instance_id()==player.get_instance_id():
		absorb_mask(object.global_position)
		object.queue_free()

func absorb_apple(_object_position:Vector3):
	apples+=1
	if apples==100:
		apples=0
		if lifes<99:
			lifes+=1

func absorb_life(_object_position:Vector3):
	if lifes<99:
		lifes+=1

func absorb_mask(_object_position:Vector3):
	pass

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
			crate_drop_item(block_position,"apple")
		"life_crate":
			break_crate(block_position)
			crate_drop_item(block_position,"life")
		"mask_crate":
			break_crate(block_position)
			crate_drop_item(block_position,"mask")
		"checkpoint_crate":
			break_crate(block_position)
		"arrow_crate":
			break_crate(block_position)
			crate_drop_item(block_position,"apple")
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

func count_crate_as_broken():
	crates+=1

func crate_drop_item(block_position:Vector3i,item_type:String,quantity:int=1):
	var block_center:Vector3=Vector3(block_position)+Vector3(0.5,0.5,0.5)
	match item_type:
		"apple":
			for i in range(quantity):
				absorb_apple(block_center)
		"life":
			for i in range(quantity):
				absorb_life(block_center)
		"mask":
			for i in range(quantity):
				absorb_mask(block_center)

func break_crate(block_position:Vector3i):
	grid_map.set_cell_item(block_position,-1)
	count_crate_as_broken()

func break_crate_bounce(block_position:Vector3i,vertical_normal:int)->bool:
	bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
	if not player.crate_broken_by_jumping:
		player.crate_broken_by_jumping=true
		break_crate(block_position)
		return true
	return false

func get_crate_type(block_position:Vector3i)->String:
	var block_type:=grid_map.get_cell_item(block_position)
	if block_type!=GridMap.INVALID_CELL_ITEM and block_type<CRATE_TYPES.size():
		return CRATE_TYPES[block_type]
	return ""

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
						if break_crate_bounce(block_position,vertical_normal):
							crate_drop_item(block_position,"apple")
				"life_crate":
					if vertical_normal!=0:
						if break_crate_bounce(block_position,vertical_normal):
							crate_drop_item(block_position,"life")
				"mask_crate":
					if vertical_normal!=0:
						if break_crate_bounce(block_position,vertical_normal):
							crate_drop_item(block_position,"mask")
				"checkpoint_crate":
					if vertical_normal!=0:
						if break_crate_bounce(block_position,vertical_normal):
							pass
				"arrow_crate":
					if vertical_normal!=0:
						if vertical_normal>0:
							bounce_crate(block_position,"arrow_bounce")
						else:
							if break_crate_bounce(block_position,vertical_normal):
								crate_drop_item(block_position,"apple")
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
