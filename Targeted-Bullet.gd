extends Area3D

var speed = 25
var lifeTime = 3.0
var direction = Vector2(0, 0)
var damage = 1
var target = null
var explosion

func _ready():
	explosion = load("res://Explosion.tscn")
	pass

func _process(delta):
	var spd = sqrt(abs(direction.x) * abs(direction.x) + abs(direction.y) * abs(direction.y))
	position += Vector3(direction.x, 0, direction.y) * delta
	if spd > speed:
		direction = direction.normalized() * (speed - 0.1)
	if target == null:
		target = Game.searchNearShip(position)
	else:
		direction += Vector2(target.position.x - position.x, target.position.z - position.z).normalized() * 22 * delta
	rotation.y = -self.direction.angle_to_point(Vector2(0, 0)) - deg_to_rad(90)
	lifeTime -= delta
	if lifeTime <= 0:
		var obj = explosion.instantiate()
		get_parent().add_child(obj)
		obj.position = position
		obj.mini_explosion()
		queue_free()
	pass

func shoot(direction, speed, damage, target):
	self.direction = Vector2(- direction.x, direction.y).normalized() * speed
	self.speed = speed
	self.damage = damage
	self.target = target
	if position.y > 0.4:
		position.y = 0.4
	pass

func _on_body_entered(body):
	if target == body:
		body.damage(damage)
		var obj = explosion.instantiate()
		get_parent().add_child(obj)
		obj.position = position
		obj.mini_explosion()
		queue_free()
	pass
