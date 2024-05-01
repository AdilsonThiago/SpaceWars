extends Node3D

var alienSpawnDelay = [3.0, 13.0, Game.INFINITE, Game.INFINITE, Game.INFINITE, Game.INFINITE]
var alienCountDelay = []
var alienShip = []

var bonusses = null
var gametime = 60
var level = 0
var boss = null

func _ready():
	#here we load the scene of enemy ships we will instantiate
	alienShip = [load("res://AlienShip.tscn"), load("res://AlienShip2.tscn"), load("res://AlienShip3.tscn"), load("res://AlienShip5.tscn"), load("res://AlienShip7.tscn"), load("res://AlienShip8.tscn")]
	#here we load the item/bonus scene
	bonusses = load("res://item.tscn")
	#here I inform our singleton that this object script exist by passing his locator
	Game.inGameScript = self
	alienCountDelay.clear()
	for i in range(alienSpawnDelay.size()):
		#alienSpawnDelay starts without having indexes.
		#it is the counter variable that will control the creation of enemy ships.
		#each index is being started with the aforementioned time value stipulated by our friend alienSpawnDelay
		alienCountDelay.append(alienSpawnDelay[i])
	#placing our ship in the phase according to the selected ship
	if Game.choosedShip == Game.FALCON:
		var o = load("res://Main-Character.tscn").instantiate()
		add_child(o)
		o.position = Vector3(0, 0, -10)
	elif Game.choosedShip == Game.DEMONSHIP:
		var o = load("res://Main-Character2.tscn").instantiate()
		add_child(o)
		o.position = Vector3(0, 0, -10)
	elif Game.choosedShip == Game.ICECREAM:
		var o = load("res://Main-Character3.tscn").instantiate()
		add_child(o)
		o.position = Vector3(0, 0, -10)
	pass

func spawnBonus(pos, bonusName):
	#called by enemy ships. spawn a bonus with id to player
	var o = bonusses.instantiate()
	add_child(o)
	o.position = Vector3(pos.x, 0, pos.z)
	#passing its identifier to the item script
	o.start(bonusName)
	pass

func _process(delta):
	if not Game.player.is_imune():
		#no enemy spawing if the player is imune :) peace moment
		for i in range(alienCountDelay.size()):
			#Automatic creation count of all enemies.
			if alienCountDelay[i] > 0:
				alienCountDelay[i] -= delta
			else:
				#some count index has been reset.
				#each index is related to a ship, let's create it
				var obj = alienShip[i].instantiate()
				add_child(obj)
				#let's decide whether to create the ship in front of our player, left or right...
				if Game.testProb(50):
					obj.position = Vector3(Game.limitx + randf_range(-7, 7), 13, 18)
					obj.start(Game.player, 0)
					#we call the method on our new enemy ship, enter our player's locator, and enter the value 1 at the end.
					#this value 0 is used for the ship to know that it was created behind our player
				else:
					if Game.testProb(50):
						obj.position = Vector3(Game.limitx + 15, 10, -3)
					else:
						obj.position = Vector3(Game.limitx - 15, 10, -3)
					obj.start(Game.player, 1)
				#Ship created successfully, resets the counter
				alienCountDelay[i] = alienSpawnDelay[i]
	#the variable gametime controls the level change.
	#If complete 60 seconds, move on to the next level
	#oh, and can't have left boss alive!! heheh
	gametime += delta
	if gametime > 60 and not Game.shipExists(boss):
		level += 1
		gametime = 0
		#message to the player informing his current level
		$UI.show_message("You are on level " + str(level))
		
		#configuring the levels
		#At each level, each ship will have its creation time changed.
		
		if level == 2:
			alienSpawnDelay = [1.5, 13.0, Game.INFINITE, Game.INFINITE, Game.INFINITE, Game.INFINITE]
		elif level == 3:
			alienSpawnDelay = [3.0, 20.0, 5.0, Game.INFINITE, Game.INFINITE, Game.INFINITE]
		elif level == 4:
			alienSpawnDelay = [2.5, 10.0, 5.0, Game.INFINITE, Game.INFINITE, Game.INFINITE]
		elif level == 5:
			alienSpawnDelay = [3.0, 15.0, 6.5, Game.INFINITE, Game.INFINITE, Game.INFINITE]
			boss = bossSpawn(0)
		elif level == 6:
			alienSpawnDelay = [2.0, 12.0, 6.0, 15.0, Game.INFINITE, Game.INFINITE]
		elif level == 7:
			alienSpawnDelay = [1.0, 7.0, 15.0, 9.0, Game.INFINITE, Game.INFINITE]
		elif level == 8:
			alienSpawnDelay = [2.5, 13.0, 7.0, 6.0, Game.INFINITE, Game.INFINITE]
		elif level == 9:
			alienSpawnDelay = [8.0, 15.0, 2.5, 5.0, Game.INFINITE, Game.INFINITE]
		elif level == 10:
			alienSpawnDelay = [3.0, 15.0, 6.0, 9.0, Game.INFINITE, Game.INFINITE]
			boss = bossSpawn(1)
		elif level == 11:
			alienSpawnDelay = [2.0, Game.INFINITE, 3.5, 6.0, 8.0, Game.INFINITE]
		elif level == 12:
			alienSpawnDelay = [1.5, Game.INFINITE, 3.0, 5.0, 7.0, Game.INFINITE]
		elif level == 13:
			alienSpawnDelay = [1.5, Game.INFINITE, 2.0, 4.0, 6.0, 30.0]
		elif level == 14:
			alienSpawnDelay = [Game.INFINITE, Game.INFINITE, 1.0, 5.0, 5.5, 25.0]
		elif level == 15:
			alienSpawnDelay = [Game.INFINITE, Game.INFINITE, 4.0, 7.0, 15.5, 25.0]
			boss = bossSpawn(2)
		elif level == 16:
			alienSpawnDelay = [2.0, Game.INFINITE, 4.0, 6.0, 9.5, 22.0]
			$UI.show_message("You completed all levels\n Now go far as you can")
		else:
			for i in range(alienSpawnDelay.size()):
				if alienSpawnDelay[i] > 1.0:
					alienSpawnDelay[i] -= 1.0
		#giving a little respite during the level change
		for i in range(alienCountDelay.size()):
			alienCountDelay[i] = alienSpawnDelay[i] + 5.0 + randf_range(-1, 1)
	pass

func bossSpawn(id):
	#stancing a boss enemy ship according to id.
	var o = null
	if id == 0:
		o = load("res://AlienShip4.tscn").instantiate()
		add_child(o)
		o.position = Vector3(Game.limitx + 15, 10, -3)
		#remembering that the number 1 is just to inform the enemy ship that it was created behind the player.
		o.start(Game.player, 1)
	if id == 1:
		o = load("res://AlienShip6.tscn").instantiate()
		add_child(o)
		o.position = Vector3(Game.limitx + 15, 10, -3)
		o.start(Game.player, 1)
	if id == 2:
		o = load("res://AlienShip9.tscn").instantiate()
		add_child(o)
		o.position = Vector3(Game.limitx + 15, 10, -3)
		o.start(Game.player, 1)
	#we will announce to the player that they are in a boss fight
	$UI.show_message("You are on level " + str(level) + str("\nIts the ") + str(id + 1) + str(" boss"))
	
	return o
	pass

func returnLevel():
	return level
	pass
