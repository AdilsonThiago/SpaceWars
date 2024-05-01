extends Control

var image : Sprite2D
var text : Label
var selection = 1
var menu = 0

func _ready():
	image = get_node("Image")
	image.scale = image.scale / Game.getResolutionScale()
	text = get_node("Main/Text")
	upLabel()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func upLabel():
	var cpstr = ["<", ">"]
	var normaltext = [" ", " "]
	var ptext = normaltext
	text.text = ""
	if selection == 1:
		ptext = cpstr
	text.text = ptext[0] + "Start Game" + ptext[1] + "\n"
	ptext = normaltext
	if selection == 2:
		ptext = cpstr
	text.text += ptext[0] + "HighScores" + ptext[1] + "\n"
	ptext = normaltext
	if selection == 3:
		ptext = cpstr
	text.text += ptext[0] + "Options" + ptext[1] + "\n"
	ptext = normaltext
	if selection == 4:
		ptext = cpstr
	text.text += ptext[0] + "Credits" + ptext[1] + "\n"
	ptext = normaltext
	if selection == 5:
		ptext = cpstr
	text.text += ptext[0] + "Quit" + ptext[1]
	$CharacterMenu/Text.text = "Choose your Spaceship:\n\n"
	if selection == 0:
		$CharacterMenu/Text.text += "DemonShip\n\nLife: ***\nSpeed: *\nShoot Speed: ***\nDamage: **"
	if selection == 1:
		$CharacterMenu/Text.text += "Falcon\n\nLife: **\nSpeed: **\nShoot Speed: **\nDamage: ***"
	if selection == 2:
		$CharacterMenu/Text.text += "IceCream\n\nLife: **\nSpeed: ***\nShoot Speed: **\nDamage: *"
		
	pass

func _input(event):
	if menu == 0:
		if event.is_action_pressed("ui_up"):
			selection -= 1
		elif event.is_action_pressed("ui_down"):
			selection += 1
		if event.is_action_pressed("ui_accept"):
			if selection == 1:
				menu = 1
				$Main.visible = false
				$CharacterMenu.visible = true
			if selection == 2:
				get_tree().change_scene_to_file("res://end.tscn")
			if selection == 4:
				menu = 2
				$Main.visible = false
				$Credits.visible = true
			if selection == 5:
				get_tree().quit()
		if selection <= 0:
			selection = 5
		elif selection >= 6:
			selection = 1
	elif menu == 1:
		if event.is_action_pressed("ui_left"):
			selection -= 1
		elif event.is_action_pressed("ui_right"):
			selection += 1
		if event.is_action_pressed("ui_accept"):
			Game.choosedShip = selection
			get_tree().change_scene_to_file("res://World.tscn")
		if selection < 0:
			selection = 2
		elif selection >= 3:
			selection = 0
		$CharacterMenu/Sprite2D.frame = selection
	elif menu == 2:
		if event.is_action_pressed("ui_accept"):
			menu = 0
			$Credits.visible = false
			$Main.visible = true
	upLabel()
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	pass
