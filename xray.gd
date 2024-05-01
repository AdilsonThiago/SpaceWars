extends Area3D

var origin = self
var dmgtime = 0
@export var lifetime : float = 1.2

func start(origin):
	self.origin = origin
	pass

func _process(delta):
	if dmgtime > 0:
		dmgtime -= delta
	else:
		var list = get_overlapping_areas()
		list += get_overlapping_bodies()
		dmgtime = 0.05
		for i in range(list.size()):
			if list[i].is_in_group("projectile"):
				list[i].queue_free()
			elif (list[i].is_in_group("enemy") or list[i].is_in_group("player")) and not origin == list[i]:
				list[i].damage(1.0)
	if lifetime > 0:
		lifetime -= delta
	else:
		queue_free()
	pass
