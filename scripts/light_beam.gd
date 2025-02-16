extends Area2D

@onready var line = $Line2D
@onready var light_particles = $CPUParticles2D
@onready var glow_line = $GlowLine
@onready var collision_shape = $CollisionShape2D

var points: Array = []
var beam_width = 3.0
var beam_color = Color(1, 0.95, 0.8, 0.9)

func _ready():
	line.width = beam_width
	line.default_color = beam_color
	
	# 设置粒子效果
	light_particles.emitting = true
	light_particles.lifetime = 0.5
	light_particles.amount = 50
	light_particles.modulate = beam_color
	
	# 设置碰撞检测
	collision_layer = 2  # 光线层
	collision_mask = 4   # 可反射物体层

	# 设置光线的粗细
	line.scale = Vector2(1, 1)  # 将宽度设置为2倍，您可以根据需要调整
	# 设置光线的颜色为更深的颜色
	line.default_color = Color(0.83,0.84,0.25,0.95)  # 调整颜色值

func update_beam(new_points: Array):
	points = new_points
	line.points = points
	glow_line.points = points
	
	# 更新碰撞形状
	if points.size() >= 2:
		var segment_shape = SegmentShape2D.new()
		segment_shape.a = points[0]
		segment_shape.b = points[points.size() - 1]
		collision_shape.shape = segment_shape
	
	# 更新粒子效果
	if points.size() > 0:
		light_particles.position = points[points.size() - 1]
	
	# 更新粒子效果
	light_particles.emitting = true
	light_particles.lifetime = 0.5
	light_particles.amount = 50
	light_particles.modulate = beam_color

	# 更新粒子发射位置
	if points.size() >= 2:
		for i in range(1, points.size()):
			var segment = points[i] - points[i-1]
			var particle = CPUParticles2D.new()
			particle.position = points[i-1]
			particle.direction = segment.normalized()
			particle.spread = 15.0
			particle.initial_velocity_min = 20.0
			particle.initial_velocity_max = 40.0

	# 检查是否碰到目标
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(points[0], points[points.size() - 1])
	query.collision_mask = 16  # 目标层
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	if result and result.collider.is_in_group("targets"):
		result.collider.hit_by_light()
