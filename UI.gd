extends CanvasLayer

#I will comment later
var level = 0

func _ready():
	Game.interface = self
	$life1.position = $life1.position * Game.getResolutionScale()
	$life2.position = $life2.position * Game.getResolutionScale()
	$life3.position = $life3.position * Game.getResolutionScale()
	$power1.position = $power1.position * Game.getResolutionScale()
	$power2.position = $power2.position * Game.getResolutionScale()
	$power3.position = $power3.position * Game.getResolutionScale()
	$archonScore.position = $archonScore.position * Game.getResolutionScale()
	pass

func updateLifes(lives):
	for i in range(3):
		if i + 1 <= lives:
			get_node("life" + str(i + 1)).modulate = Color.WHITE
		else:
			get_node("life" + str(i + 1)).modulate = Color.DARK_SLATE_GRAY
	pass

func displayFlash():
	$AnimationPlayer.play("flash")
	pass

func updatePowers(powers):
	for i in range(3):
		if i + 1 <= powers:
			get_node("power" + str(i + 1)).modulate = Color.WHITE
		else:
			get_node("power" + str(i + 1)).modulate = Color.DARK_SLATE_GRAY
	pass

func updateScore(score):
	$archonScore/score.text = "Level: " + str(level) + "          Score: " + str(score)
	pass

func gameOver():
	get_tree().paused = true
	$AnimationPlayer.play("gameover")
	pass

func show_message(msg):
	level = Game.inGameScript.returnLevel()
	$info.text = msg
	$AnimationPlayer.play("info")
	pass

func gameReset():
	get_tree().paused = false
	Game.resetedGame()
	get_tree().change_scene_to_file("res://MainTSCN.tscn")
	pass
