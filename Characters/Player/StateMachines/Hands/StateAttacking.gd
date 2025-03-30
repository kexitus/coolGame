extends State


func enter():
	animationPlayer.play("Hands/cast_start")

func exit():
	animationPlayer.play("Hands/cast_end")

func _update(_delta:float):
	if ! animationPlayer.is_playing():
		animationPlayer.play("Hands/cast_loop")
