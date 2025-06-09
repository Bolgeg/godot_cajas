extends Node3D

@onready var player:=%Player
@onready var item_container:=%ItemContainer
@onready var death_timer:=%DeathTimer

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
var level_explosions:Node3D

var apples:=0
var crates:=0
var crates_total:=0
var lifes:=5

var crate_data:={}


var initial_grid_map:GridMap

var removed_blocks:=[]

var checkpoint_removed_blocks:=[]
var checkpoint_crates:=0
var checkpoint_block_position:=Vector3i(0,0,0)

func _ready() -> void:
	level=$Level1
	grid_map=level.find_child("GridMap")
	
	initial_grid_map=grid_map.duplicate()
	initial_grid_map.process_mode=Node.PROCESS_MODE_DISABLED
	
	level_items=level.find_child("Items")
	level_explosions=level.find_child("Explosions")
	process_map()
	save_checkpoint(Vector3i(player.global_position.floor()))

func _process(_delta: float) -> void:
	item_container.update(apples,crates,crates_total,lifes)

func save_checkpoint(block_position:Vector3i):
	checkpoint_removed_blocks=removed_blocks.duplicate(true)
	checkpoint_crates=crates
	checkpoint_block_position=block_position

func load_checkpoint():
	grid_map.free()
	grid_map=initial_grid_map.duplicate()
	grid_map.process_mode=Node.PROCESS_MODE_INHERIT
	level.add_child(grid_map)
	
	for child in level_items.get_children():
		child.queue_free()
	
	remove_checkpoint_removed_blocks()
	removed_blocks=checkpoint_removed_blocks.duplicate(true)
	
	process_map(true)
	
	crates=checkpoint_crates
	
	player.reset()
	player.global_position=Vector3(checkpoint_block_position)

func remove_checkpoint_removed_blocks():
	for block_position in checkpoint_removed_blocks:
		var crate_type:=get_crate_type(block_position)
		match crate_type:
			"wood_crate":
				break_crate(block_position,true)
			"life_crate":
				break_crate(block_position,true)
			"mask_crate":
				break_crate(block_position,true)
			"checkpoint_crate":
				break_crate(block_position,true)
			"arrow_crate":
				break_crate(block_position,true)
			"bounce_crate":
				break_crate(block_position,true)
			"nitro_crate":
				break_crate(block_position,true)
			"tnt_crate":
				break_crate(block_position,true)
			"tnt_crate_3":
				break_crate(block_position,true)
			"tnt_crate_2":
				break_crate(block_position,true)
			"tnt_crate_1":
				break_crate(block_position,true)
			"metal_crate":
				pass
			"metal_checkpoint_crate":
				grid_map.set_cell_item(block_position,CRATE_TYPES.find("metal_crate"))
			"metal_arrow_crate":
				pass
			"metal_activator_crate":
				grid_map.set_cell_item(block_position,CRATE_TYPES.find("metal_crate"))
				activate_crates()
			"green_metal_crate":
				pass
			"green_metal_detonator_crate":
				grid_map.set_cell_item(block_position,CRATE_TYPES.find("green_metal_crate"))
			"wireframe_crate":
				pass
			_:
				grid_map.set_cell_item(block_position,-1)

func process_map(checkpoint:bool=false):
	for apple_position in grid_map.get_used_cells_by_item(APPLE_BLOCK_INDEX):
		grid_map.set_cell_item(apple_position,-1)
		var apple:=preload("res://scenes/apple.tscn").instantiate()
		apple.block_position=apple_position
		level_items.add_child(apple)
		apple.global_position=Vector3(apple_position)+Vector3(0.5,0.5,0.5)
		apple.body_touched.connect(_on_body_touched_apple)
	
	for life_position in grid_map.get_used_cells_by_item(LIFE_BLOCK_INDEX):
		grid_map.set_cell_item(life_position,-1)
		var life:=preload("res://scenes/life.tscn").instantiate()
		life.block_position=life_position
		level_items.add_child(life)
		life.global_position=Vector3(life_position)+Vector3(0.5,0.5,0.5)
		life.body_touched.connect(_on_body_touched_life)
	
	for mask_position in grid_map.get_used_cells_by_item(MASK_BLOCK_INDEX):
		grid_map.set_cell_item(mask_position,-1)
		var mask:=preload("res://scenes/mask_in_map.tscn").instantiate()
		mask.block_position=mask_position
		level_items.add_child(mask)
		mask.global_position=Vector3(mask_position)+Vector3(0.5,0.5,0.5)
		mask.body_touched.connect(_on_body_touched_mask)
	
	if not checkpoint:
		crates_total=0
	for block_position in grid_map.get_used_cells():
		var block_type:=grid_map.get_cell_item(block_position)
		if block_type!=GridMap.INVALID_CELL_ITEM and block_type<CRATE_TYPES.size():
			var crate_type=CRATE_TYPES[block_type]
			if not checkpoint:
				if(
					crate_type!="metal_crate" and crate_type!="metal_arrow_crate"
					and crate_type!="green_metal_crate" and crate_type!="metal_checkpoint_crate"
					and crate_type!="metal_activator_crate" and crate_type!="green_metal_detonator_crate"
					):
					crates_total+=1
			if crate_type=="bounce_crate":
				crate_data[block_position]=CrateData.new(10,0)

func _on_body_touched_apple(body:Node3D,object:Node3D):
	if body.get_instance_id()==player.get_instance_id():
		removed_blocks.append(object.block_position)
		absorb_apple(object.global_position)
		object.queue_free()

func _on_body_touched_life(body:Node3D,object:Node3D):
	if body.get_instance_id()==player.get_instance_id():
		removed_blocks.append(object.block_position)
		absorb_life(object.global_position)
		object.queue_free()

func _on_body_touched_mask(body:Node3D,object:Node3D):
	if body.get_instance_id()==player.get_instance_id():
		removed_blocks.append(object.block_position)
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

func player_die():
	player.process_mode=Node.PROCESS_MODE_DISABLED
	player.visible=false
	death_timer.start()

func _on_body_touched_explosion(body:Node3D,_object:Node3D):
	if body.get_instance_id()==player.get_instance_id():
		if death_timer.is_stopped():
			player_die()

func _on_area_touched_explosion(area:Area3D,_object:Node3D):
	if area in level_items.get_children():
		area.queue_free()

func _physics_process(delta: float) -> void:
	for block_position in crate_data:
		crate_data[block_position].frame_apples_obtained=false
	
	for block_position in player.get_spin_overlapping_block_positions():
		var block_type:=grid_map.get_cell_item(block_position)
		if block_type!=GridMap.INVALID_CELL_ITEM and block_type<CRATE_TYPES.size():
			var crate_type=CRATE_TYPES[block_type]
			break_crate_spinning(block_position,crate_type,0)
	
	for block_position in crate_data:
		if crate_data[block_position].tnt_countdown>0:
			crate_data[block_position].tnt_countdown-=delta
			if crate_data[block_position].tnt_countdown<=0:
				break_crate(block_position)
			else:
				match int(floor(crate_data[block_position].tnt_countdown)):
					1:
						grid_map.set_cell_item(block_position,CRATE_TYPES.find("tnt_crate_2"))
					0:
						grid_map.set_cell_item(block_position,CRATE_TYPES.find("tnt_crate_1"))
	
	for explosion in level_explosions.get_children():
		var center:Vector3=explosion.global_position
		var radius:float=explosion.radius
		var minimum:=Vector3i((center-Vector3(radius,radius,radius)).floor())
		var maximum:=Vector3i((center+Vector3(radius,radius,radius)).ceil())+Vector3i(1,1,1)
		for z in range(minimum.z,maximum.z):
			for y in range(minimum.y,maximum.y):
				for x in range(minimum.x,maximum.x):
					var block_position:=Vector3i(x,y,z)
					var block_center:=Vector3(block_position)+Vector3(0.5,0.5,0.5)
					if center.distance_to(block_center)<=radius:
						var crate_type:=get_crate_type(block_position)
						if crate_type!="":
							match crate_type:
								"wood_crate":
									break_crate(block_position)
								"life_crate":
									break_crate(block_position)
								"mask_crate":
									break_crate(block_position)
								"checkpoint_crate":
									break_crate(block_position)
									set_checkpoint(block_position)
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
									activate_metal_crate(block_position)
								"metal_arrow_crate":
									pass
								"metal_activator_crate":
									activate_metal_crate(block_position)
								"green_metal_crate":
									pass
								"green_metal_detonator_crate":
									activate_metal_crate(block_position)
								"wireframe_crate":
									pass

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
			set_checkpoint(block_position)
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
			activate_metal_crate(block_position)
		"metal_arrow_crate":
			pass
		"metal_activator_crate":
			activate_metal_crate(block_position)
		"green_metal_crate":
			pass
		"green_metal_detonator_crate":
			activate_metal_crate(block_position)
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

func get_crate_type(block_position:Vector3i)->String:
	var block_type:=grid_map.get_cell_item(block_position)
	if block_type!=GridMap.INVALID_CELL_ITEM and block_type<CRATE_TYPES.size():
		return CRATE_TYPES[block_type]
	return ""

func create_explosion(center:Vector3,color:Color):
	var explosion:=preload("res://scenes/explosion.tscn").instantiate()
	explosion.set_explosion_color(color)
	explosion.position=center
	explosion.body_touched.connect(_on_body_touched_explosion)
	explosion.area_touched.connect(_on_area_touched_explosion)
	level_explosions.add_child(explosion)

func activate_tnt(block_position:Vector3i):
	crate_data[block_position]=CrateData.new(0,3)
	grid_map.set_cell_item(block_position,CRATE_TYPES.find("tnt_crate_3"))

func break_crate(block_position:Vector3i,checkpoint:bool=false):
	var crate_type:=get_crate_type(block_position)
	grid_map.set_cell_item(block_position,-1)
	if not checkpoint:
		count_crate_as_broken()
		removed_blocks.append(block_position)
		if block_position in crate_data:
			crate_data.erase(block_position)
		if(crate_type=="nitro_crate" or crate_type=="tnt_crate" or
			crate_type=="tnt_crate_3" or crate_type=="tnt_crate_2" or crate_type=="tnt_crate_1"):
			create_explosion(
				Vector3(block_position)+Vector3(0.5,0.5,0.5),
				Color.from_rgba8(0,255,0) if crate_type=="nitro_crate" else Color.from_rgba8(255,0,0)
				)

func break_crate_bounce(block_position:Vector3i,vertical_normal:int)->bool:
	bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
	if not player.crate_broken_by_jumping:
		player.crate_broken_by_jumping=true
		break_crate(block_position)
		return true
	return false

func set_checkpoint(block_position:Vector3i):
	save_checkpoint(block_position)

func detonate_all_nitro_crates():
	for block_position in grid_map.get_used_cells_by_item(CRATE_TYPES.find("nitro_crate")):
		break_crate(block_position)

func activate_crates():
	pass

func activate_metal_crate(block_position:Vector3i):
	var crate_type:=get_crate_type(block_position)
	match crate_type:
		"metal_checkpoint_crate":
			set_checkpoint(block_position+Vector3i.UP)
			grid_map.set_cell_item(block_position,CRATE_TYPES.find("metal_crate"))
			removed_blocks.append(block_position)
		"metal_activator_crate":
			activate_crates()
			grid_map.set_cell_item(block_position,CRATE_TYPES.find("metal_crate"))
			removed_blocks.append(block_position)
		"green_metal_detonator_crate":
			detonate_all_nitro_crates()
			grid_map.set_cell_item(block_position,CRATE_TYPES.find("green_metal_crate"))
			removed_blocks.append(block_position)

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
							set_checkpoint(block_position)
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
						if block_position in crate_data:
							if not crate_data[block_position].frame_apples_obtained:
								if crate_data[block_position].apples_left>0:
									crate_drop_item(block_position,"apple",2)
									crate_data[block_position].apples_left-=2
								crate_data[block_position].frame_apples_obtained=true
								if crate_data[block_position].apples_left<=0:
									break_crate(block_position)
						else:
							break_crate(block_position)
				"nitro_crate":
					break_crate(block_position)
				"tnt_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
						activate_tnt(block_position)
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
						activate_metal_crate(block_position)
				"metal_arrow_crate":
					if vertical_normal>0:
						bounce_crate(block_position,"arrow_bounce")
				"metal_activator_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
						activate_metal_crate(block_position)
				"green_metal_crate":
					pass
				"green_metal_detonator_crate":
					if vertical_normal!=0:
						bounce_crate(block_position,"crate_bounce" if vertical_normal>0 else "bounce_down")
						activate_metal_crate(block_position)
				"wireframe_crate":
					pass

func _on_death_timer_timeout() -> void:
	lifes-=1
	load_checkpoint()
	player.process_mode=Node.PROCESS_MODE_INHERIT
	player.visible=true
