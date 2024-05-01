extends Node

#its singleton script
#help with global vars and acess to main objects

#some constants
const DEMONSHIP = 0
const FALCON = 1
const ICECREAM = 2

const LIFE = 0
const POWERUP = 1
const SPECIAL = 2
const SHIELD = 3

const BULLET = 0
const TARGETED = 1

const INFINITE = 10000

#its the ship the player choosed. is changed by the script "Main"
var choosedShip = FALCON

var limitx = 0
var score = 0
var scoretime = 0.1

var inGameScript = null
var player = null
var camera = null
var interface = null

var spaceShips : Array

func scored(score):
	self.score += score
	interface.updateScore(self.score)
	pass

func resetedGame():
	#a singleton exists independent of events.
	#for our security we need to clear the data to start again
	score = 0
	spaceShips.clear()
	inGameScript = null
	player = null
	camera = null
	interface = null
	pass

func _process(delta):
	#automatic scoring. I think about whether I will remove it in the future
	if not interface == null:
		scoretime -= delta
		if scoretime <= 0:
			scoretime = 0.1
			scored(1)
	pass

func setLimitx(limitx):
	#called by "Main-Character" script. 
	#the var controls spawning and battlefield movement of enemy ships
	self.limitx = limitx
	pass

func getResolutionScale():
	#a workaround for calculating scales at different resolutions.
	#Yes, I don't understand control nodes well :/
	return Vector2(get_viewport().size) / Vector2(1152, 648)
	pass

func testProb(percent):
	#just a helper script. 
	#you enter the probability of happening from 0 to 100, where 0 means that there is no probability at all, 50 means that the probability of it happening or not happening is the same, and 100 meaning that it will happen.
	randomize()
	return randf_range(0, 100) <= percent
	pass

#All these methods below are related to the list "spaceShips".
#the creation and removal log are called by the enemy ships.
#We have methods to locate the nearest ship, deal damage to all ships, and check if such a ship exists in the list

func registerSpcShip(ship):
	spaceShips.append(ship)
	pass

func removeSpcShip(ship):
	for i in range(spaceShips.size()):
		if spaceShips[i] == ship:
			spaceShips.remove_at(i)
			return
	pass

func globalDamage(damage):
	if spaceShips.size() > 0:
		var calc_damage = damage / spaceShips.size()
		var missed = spaceShips.size()
		while missed > 0:
			missed = 0
			for i in range(spaceShips.size()):
				if i < spaceShips.size():
					spaceShips[i].damage(calc_damage)
				else:
					missed += 1
	pass

func searchNearShip(onPos):
	var dist = Game.INFINITE
	var returnVal = null
	for i in range(spaceShips.size()):
		var newDist = onPos.distance_to(spaceShips[i].position)
		if newDist < dist:
			dist = newDist
			returnVal = spaceShips[i]
	return returnVal
	pass

func shipExists(id):
	for i in range(spaceShips.size()):
		if spaceShips[i] == id:
			return true
	return false
	pass
