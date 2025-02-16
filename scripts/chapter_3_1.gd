extends Control

# 定义每个关卡的目标位置
const TARGET_POSITIONS = {
	1: Vector2(400, 500),  # 第一关目标位置
	2: Vector2(700, 200),  # 第二关目标位置，放在更有挑战性的位置
	3: Vector2(800, 300)   # 第三关目标位置，需要多次反射才能到达
}

# 新增文本数组
var mirror_hall_dialogues = [
	"随着最后一片记忆浮现，迷雾渐渐散去，镜天廊的轮廓显现在眼前。",
	"这里是墨家最神秘的试炼场，传说镜天廊能够映照出人心最深处的真实。无数面镜子折射着光影，仿佛要照进人的灵魂。",
	"阿明，你终于来了。",
	"师兄！为什么要这样做？",
	"想要知道答案，就用你的智慧打开心镜之门吧。"
]
var level_dialogues = {
0: "这是最基础的光线反射，试着调整镜子角度吧。",
1: "记住墨经中说的，光线的反射要遵循入射角等于反射角的原理。",
2: "这是最后的考验，用你的智慧证明自己吧！"
}
var current_dialogue_index = 0 # 当前对话索引

var index = 0

# 添加基础属性
var current_level = 1
var total_levels = 3
var is_dragging = false
var current_mirror = null
var all_targets_lit = false

# 光线相关
var light_source_pos = Vector2()
var light_rays = []
var light_beam_scene = preload("res://light_beam.tscn")
var active_light_beams = []

func _ready():
	$HallBG.visible = true
	#$GameBackground.visible = false  # 初始隐藏游戏背景
	$LightSource.visible = false
	$LightSystem.visible = false
	$Mirrors.visible = false
	$Targets.visible = false
	$BackButton.pressed.connect(_on_back_pressed)
	setup_post_processing()  # 添加后处理效果
	# 连接输入事件
	$DialogueUI/DialogueBox.mouse_filter = Control.MOUSE_FILTER_STOP
	$DialogueUI/NarrationText.mouse_filter = Control.MOUSE_FILTER_STOP
	$DialogueUI/DialogueBox.gui_input.connect(_on_dialogue_input)
	$DialogueUI/NarrationText.gui_input.connect(_on_dialogue_input)
	$DialogueUI/DialogueBox/StartButton.pressed.connect(_on_start_game)  # 更新按钮路径
	$DialogueUI/DialogueBox/StartButton.visible=false
	# 开始显示镜天廊的对话
	display_mirror_hall_dialogue()
	# 初始化时不创建光束
	for beam in active_light_beams:
		beam.visible = false
	$DialogueUI.z_index = 10  # 设置对话框的 z_index 为更高的值

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")

func display_mirror_hall_dialogue():
	# 显示对话框
	$DialogueUI/DialogueBox.show()
	update_dialogue_display(index)

# 更新对话显示
func update_dialogue_display(index):
	if index >= 0:  # 开场对话
		# 根据对话索引更新文本和UI
		match index:
			0, 1:  # 旁白
				$DialogueUI/NarrationText.text = mirror_hall_dialogues[index]
				$DialogueUI/NarrationText.show()
				$DialogueUI/DialogueBox.hide()
				$DialogueUI/NarrationText.modulate.a = 0
				var tween = create_tween()
				tween.tween_property($DialogueUI/NarrationText, "modulate:a", 1.0, 1.0)
				await tween.finished
			2:  # 师兄
				$DialogueUI/NarrationText.hide()
				$DialogueUI/DialogueBox.show()
				$DialogueUI/DialogueBox/DialogueText.text = mirror_hall_dialogues[index]
				$DialogueUI/DialogueBox/SpeakerName.text = "师兄"
				$DialogueUI/DialogueBox/MingPortrait.visible = false
				$DialogueUI/DialogueBox/BlackmanPortrait.visible = true
			3:  # 阿明
				$DialogueUI/DialogueBox.show()
				$DialogueUI/DialogueBox/DialogueText.text = mirror_hall_dialogues[index]
				$DialogueUI/DialogueBox/SpeakerName.text = "阿明"
				$DialogueUI/DialogueBox/MingPortrait.visible = true
				$DialogueUI/DialogueBox/BlackmanPortrait.visible = false
			4:  # 师兄
				$DialogueUI/DialogueBox.show()
				$DialogueUI/DialogueBox/DialogueText.text = mirror_hall_dialogues[index]
				$DialogueUI/DialogueBox/SpeakerName.text = "师兄"
				$DialogueUI/DialogueBox/MingPortrait.visible = false
				$DialogueUI/DialogueBox/BlackmanPortrait.visible = true
				$DialogueUI/DialogueBox/StartButton.visible = true
				# 禁用其他点击事件
				$DialogueUI/DialogueBox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			5,6,7:  #level
				$DialogueUI/DialogueBox.show()
				$DialogueUI/DialogueBox/DialogueText.text = level_dialogues[index-5]
				$DialogueUI/DialogueBox/SpeakerName.text = " "
				$DialogueUI/DialogueBox/MingPortrait.visible = false
				$DialogueUI/DialogueBox/BlackmanPortrait.visible = false
				$DialogueUI/DialogueBox/StartButton.visible = false
				$DialogueUI/DialogueBox.mouse_filter = Control.MOUSE_FILTER_PASS
				

func _on_dialogue_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_dialogue_index < mirror_hall_dialogues.size() - 1:
			current_dialogue_index += 1
			index+=1
			update_dialogue_display(index)
		else:
			# 对话结束后隐藏UI并开始交互
			$DialogueUI/DialogueBox.hide()

func _on_start_game():
	# 只隐藏对话背景
	$DialogueUI.hide()
	$DialogueUI/ColorRect.visible = false
	# 显示游戏元素
	$GameBackground.visible = true
	$LightSource.visible = true
	$LightSystem.visible = true
	$Mirrors.visible = true
	$Targets.visible = true
	# 设置光源和光束
	setup_light_source()
	for beam in active_light_beams:
		beam.visible = true
	# 设置第一关
	setup_level(1)

func setup_level(level: int):
	# 清理当前关卡
	clear_current_level()
	
	match level:
		1:
			setup_level_one()
		2:
			setup_level_two()
		3:
			setup_level_three()

func check_level_complete():
	print("Checking level completion...")
	var all_lit = true
	for target in get_tree().get_nodes_in_group("targets"):
		print("Target lit state: ", target.is_lit)
		if !target.is_lit:
			all_lit = false
			break
	
	print("All targets lit: ", all_lit)
	if all_lit:
		print("Level complete! Showing dialog...")
		show_level_complete_dialog()

func setup_light_source():
	light_source_pos = $LightSource.position
	var light_beam = light_beam_scene.instantiate()
	add_child(light_beam)
	active_light_beams.append(light_beam)

func _process(_delta):
	update_light_beams()

func update_light_beams():
	if active_light_beams.size() > 0:
		var light_system = $LightSystem
		var initial_direction = Vector2.RIGHT  # 或其他初始方向
		var reflection_points = light_system.cast_light(light_source_pos, initial_direction)
		
		# 确保光束有脚本并调用更新
		var beam = active_light_beams[0]
		if beam.has_method("update_beam"):
			beam.update_beam(reflection_points)
		else:
			print("Error: Light beam missing script or update_beam method")

func setup_post_processing():
	var canvas_layer = CanvasLayer.new()
	var world_environment = WorldEnvironment.new()
	
	var environment = Environment.new()
	environment.glow_enabled = true
	environment.glow_intensity = 0.5
	environment.glow_bloom = 0.5
	environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	
	world_environment.environment = environment
	canvas_layer.add_child(world_environment)
	add_child(canvas_layer)

func clear_current_level():
	# 清理当前关卡的所有元素
	for mirror in $Mirrors.get_children():
		mirror.queue_free()
	for target in $Targets.get_children():
		target.queue_free()

func setup_level_one():
	# 设置第一关的镜子和目标
	var mirror = preload("res://mirror.tscn").instantiate()
	mirror.position = Vector2(642, 409)
	print("Creating mirror at position: ", mirror.position)
	mirror.process_mode = Node.PROCESS_MODE_ALWAYS  # 确保镜子总是处理输入
	mirror.input_pickable = true  # 确保可以接收输入
	mirror.z_index = 1  # 确保镜子在上层
	$Mirrors.add_child(mirror)
	
	setup_target(1)  # 设置第一关目标
	
	# 显示对话UI和文本
	$DialogueUI.show()
	$DialogueUI/DialogueBox.show()
	update_dialogue_display(5)

func setup_level_two():
	# 第一个镜子
	var mirror1 = preload("res://mirror.tscn").instantiate()
	mirror1.position = Vector2(400, 200)
	$Mirrors.add_child(mirror1)
	
	# 第二个镜子
	var mirror2 = preload("res://mirror.tscn").instantiate()
	mirror2.position = Vector2(500, 400)
	$Mirrors.add_child(mirror2)
	
	setup_target(2)  # 设置第二关目标
	
	$DialogueUI.show()
	$DialogueUI/DialogueBox.show()
	update_dialogue_display(6)

func setup_level_three():
	# 第一个镜子
	var mirror1 = preload("res://mirror.tscn").instantiate()
	mirror1.position = Vector2(300, 200)
	mirror1.rotation = deg_to_rad(5)  # 设置镜子旋转为5度
	$Mirrors.add_child(mirror1)
	
	# 第二个镜子
	var mirror2 = preload("res://mirror.tscn").instantiate()
	mirror2.position = Vector2(500, 300)
	mirror2.rotation = deg_to_rad(5)  # 设置镜子旋转为5度
	$Mirrors.add_child(mirror2)
	
	# 第三个镜子
	var mirror3 = preload("res://mirror.tscn").instantiate()
	mirror3.position = Vector2(400, 400)
	mirror3.rotation = deg_to_rad(5)  # 设置镜子旋转为5度
	$Mirrors.add_child(mirror3)
	
	setup_target(3)  # 设置第三关目标
	
	$DialogueUI.show()
	$DialogueUI/DialogueBox.show()
	update_dialogue_display(7)

# 新增函数：设置目标
func setup_target(level: int):
	var target = preload("res://target.tscn").instantiate()
	target.position = TARGET_POSITIONS[level]
	
	# 根据关卡调整目标的缩放和碰撞形状
	if level == 1:
		target.scale = Vector2(1.5, 1.5)  # 增大50%
		target.get_node("CollisionShape2D").shape.radius *= 1.5  # 调整碰撞形状
	elif level == 2:
		target.scale = Vector2(1.0, 1.0)  # 增大20%
		target.get_node("CollisionShape2D").shape.radius *= 1.0  # 调整碰撞形状
	elif level == 3:
		target.scale = Vector2(0.7, 0.7)  # 缩小
		target.get_node("CollisionShape2D").shape.radius *= 0.7  # 调整碰撞形状
	
	$Targets.add_child(target)


func show_level_complete_dialog():
	print("Showing level complete dialog")
	$DialogueUI.show()
	$DialogueUI/DialogueBox.show()
	
	# 创建闪光效果
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.8, 0.2)
	tween.tween_property(flash, "color:a", 0.0, 0.3)
	await tween.finished
	flash.queue_free()
	
	$DialogueUI/DialogueBox/DialogueText.text = "恭喜通过第" + str(current_level) + "关！"
	if current_level < total_levels:
		current_level += 1
		await get_tree().create_timer(2.0).timeout
		setup_level(current_level)
	else:
		# 游戏通关
		$DialogueUI/DialogueBox/DialogueText.text = "恭喜你完成所有考验！"

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked at: ", event.position)
		print("Mirrors count: ", $Mirrors.get_child_count())
		for mirror in $Mirrors.get_children():
			print("Mirror position: ", mirror.position)
			print("Mirror process mode: ", mirror.process_mode)
			print("Mirror input pickable: ", mirror.input_pickable)

 
