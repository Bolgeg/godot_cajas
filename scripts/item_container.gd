extends Node2D

func _process(_delta: float) -> void:
	var animation_t:float=1-%AppleAnimationTimer.time_left/%AppleAnimationTimer.wait_time
	var animation_frame:=int(floor(animation_t*%AppleSprite.hframes))
	%AppleSprite.frame=animation_frame

func update(apples:int,crates:int,crates_total:int,lifes:int):
	%AppleLabel.text=str(apples)
	%CrateLabel.text=str(crates)+"/"+str(crates_total)
	%LifeLabel.text=str(lifes)
