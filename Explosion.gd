extends Node3D

func mini_explosion():
	$CPUParticles3D.scale = $CPUParticles3D.scale * 0.2
	$AudioStreamPlayer3D.volume_db = -3
	pass
