extends Control

const MAIN = 0
const HIGHSC = 1

var list = []
var con_open = false
var registered_id = -1
var naame = ""

var menu = MAIN
var selection = 0


#This script only serves to show the player's score,
#but does not perform any recording or retrieval of data.
#These functions were implemented in the release version, using the C# language.


func _ready():
	list.clear()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mainText_up()
	pass

func mainText_up():
	var aditinTxt = ["", ""]
	$Main/Text.text = "Your score : " + str(Game.score) + "\n\n"
	aditinTxt = ["", ""]
	if selection == 0:
		aditinTxt = ["<", ">"]
	$Main/Text.text += aditinTxt[0] + "Main menu" + aditinTxt[1] + "\n"
	aditinTxt = ["", ""]
	if selection == 1:
		aditinTxt = ["<", ">"]
	$Main/Text.text += aditinTxt[0] + "Highscore" + aditinTxt[1]
	pass

func highsc_up():
	$HighTabel/scr.text = str(Game.score)
	$HighTabel/hightable.text = ""
	if list.size() > 0:
		for i in range(list.size()):
			$HighTabel/hightable.text += str(i + 1) + str(" - ") + list[i][1] + str(" : ") + list[i][2] + str("\n")
	else:
		$HighTabel/hightable.text = "No table"
	pass

func _on_submit_pressed():
	if not $HighTabel/customname.text == "":
		if not naame == $HighTabel/customname.text:
			naame = $HighTabel/customname.text
		$HighTabel.hide()
		$Main.show()
		menu = MAIN
		list.clear()
	pass

func _input(event):
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		if selection == 0:
			selection = 1
		else:
			selection = 0
	if event.is_action_pressed("ui_accept"):
		if selection == 0:
			get_tree().change_scene_to_file("res://MainTSCN.tscn")
		elif selection == 1:
			menu = HIGHSC
			$Main.visible = false
			$HighTabel.visible = true
			highsc_up()
	mainText_up()
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://MainTSCN.tscn")
	pass

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://MainTSCN.tscn")
	pass
