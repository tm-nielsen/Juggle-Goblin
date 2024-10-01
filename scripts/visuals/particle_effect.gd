class_name ParticleEffect
extends CPUParticles2D


func _ready():
  finished.connect(queue_free)
  restart()