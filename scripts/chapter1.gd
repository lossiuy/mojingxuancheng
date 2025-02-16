extends Control

var current_stone_weight = 0
var people_weight = 2.5  # 每个难民2.5石(75kg)
var is_balanced = false
var can_rotate = false  # 是否可以旋转杠杆
var stone_height = 40  # 每个石头的高度
var current_stone_count = 0  # 当前石头数量
var people_count = 2  # 第一关2个人
var current_level = 1
var left_arm = 1  # 左力臂比例
var right_arm = 1  # 右力臂比例
var dialogue_index = 0
var dialogues = [
	"阿明来到衡机阁中, 突然看到一群被拴在杠杆右侧的百姓, 杠杆摇摇晃晃发出咯吱咯吱的声音, 下面是密密麻麻的毒虫...",
	"难民们惊恐地看着下方, 瑟瑟发抖. 突然, 一个黑衣人从阴影中现身.",
	"\"又是一只蝼蚁来逞英雄? 看看这些可怜虫, 哈哈哈哈哈...\"\n\"劝你还是省点力气, 你救不了他们的.\"",
	"\"我不会让你得逞的!\" 阿明坚定地说.",
	"\"三分钟后天平就会开始倾斜，他们也会开始下沉.你想救他们，那就看你有没有这个本事了！\" 黑衣人冷笑一声, 消失在黑暗中.",
	"(阿明环顾四周, 发现有很多石头. 他回忆起《墨经》中的智慧:)\n\"衡, 加重于其一旁, 必捶. 权重相若也相衡, 则本短标长.\"",
	"如果根据支点的位置和难民重量放置对应的石头重量, 或许可以使杠杆平衡, 解救难民...\n\n准备好了吗? 让我们开始拯救!"
]

var ending_dialogues = [
	"难民们终于获救了，脚下的毒虫也随之消失不见...",
	"就在这时，黑衣人的声音再次在黑暗中响起：\n\"呵，不过是解开了一个小小的机关罢了...\"",
	"\"真以为这样就能改变什么吗？\"\n黑衣人冷笑着说完，转身消失在黑暗中。",
	"(阿明望着黑衣人离去的背影，总觉得有些熟悉...)",
	"\"大侠！浮光池还有很多和我们一样的难民需要帮助，请你一定要去救救他们！\"",
	"阿明收回思绪，点点头：\"好，我这就去浮光池！\""
]

var is_showing_ending = false
var ending_dialogue_index = 0

func _ready():
	# 初始时背景正常显示
	$Background.visible = true
	$Background.modulate = Color(1, 1, 1, 1)  # 正常亮度
	$BackButton.pressed.connect(_on_back_pressed)
	
	# 修改按钮为 TextureButton 并连接信号
	$"UI#ConfirmButton".texture_normal = load("res://images/confirm.png")
	$"UI#CancelButton".texture_normal = load("res://images/reset.png")
	$"UI#NextButton".texture_normal = load("res://images/nextlevel.png")
	
	# 连接按钮信号
	$"UI#ConfirmButton".pressed.connect(_on_confirm_pressed)
	$"UI#CancelButton".pressed.connect(_on_cancel_pressed)
	$"UI#NextButton".pressed.connect(_on_next_level_pressed)
	
	# 设置按钮的大小和缩放模式
	$"UI#ConfirmButton".ignore_texture_size = true
	$"UI#ConfirmButton".stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	$"UI#CancelButton".ignore_texture_size = true
	$"UI#CancelButton".stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	$"UI#NextButton".ignore_texture_size = true
	$"UI#NextButton".stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	# 隐藏游戏UI
	$GameBackground/GameElements.hide()
	$"UI#ConfirmButton".hide()
	$"UI#CancelButton".hide()
	$"UI_WeightInfo#CurrentWeight".hide()
	$"UI_WeightInfo#TargetWeight".hide()
	$"UI#LevelLabel".hide()
	$"UI#TorqueLabel".hide()
	
	# 设置对话系统
	dialogue_index = 0
	update_dialogue_display(0)
	update_portrait_modulate(0)
	
	# 确保对话框和旁白区域都可以接收输入
	$DialogueUI/DialogueBox.mouse_filter = Control.MOUSE_FILTER_STOP
	$DialogueUI/NarrationText.mouse_filter = Control.MOUSE_FILTER_STOP
	$DialogueUI/DialogueBox.gui_input.connect(_on_dialogue_input)
	$DialogueUI/NarrationText.gui_input.connect(_on_dialogue_input)
	$DialogueUI/DialogueBox/StartButton.pressed.connect(_on_start_game)
	$DialogueUI/DialogueBox/StartButton.hide()
	$GameBackground.visible = false
	
	# 移除创建节点的代码，改为获取已有节点的引用
	$QuestionButton.pressed.connect(_on_question_pressed)

func update_dialogue_display(index):
	var dialogue_text = dialogues[index]
	var speaker_label = $DialogueUI/DialogueBox/SpeakerName
	
	if is_showing_ending:
		# 结局对话显示逻辑
		$DialogueUI/DialogueBox/StartButton.hide()  # 在结局对话时隐藏开始按钮
		
		if ending_dialogue_index in [0, 4]:  # 纯旁白部分
			$DialogueUI/NarrationText.text = ending_dialogues[ending_dialogue_index]
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		elif ending_dialogue_index == 3:  # 阿明的心理活动
			$DialogueUI/DialogueBox/DialogueText.text = ending_dialogues[ending_dialogue_index]
			speaker_label.text = "阿明"
			speaker_label.position.x = 157  # 左侧位置
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
			# 心理活动时只显示阿明头像
			$DialogueUI/DialogueBox/MingPortrait.visible = true
			$DialogueUI/DialogueBox/BlackmanPortrait.visible = false
		else:  # 对话部分
			$DialogueUI/DialogueBox/DialogueText.text = ending_dialogues[ending_dialogue_index]
			if ending_dialogue_index in [1, 2]:
				speaker_label.text = "黑衣人"
				speaker_label.position.x = 800  # 右侧位置
			else:
				speaker_label.text = "阿明"
				speaker_label.position.x = 157  # 左侧位置
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
	else:
		# 开场对话显示逻辑
		if index in [0, 1]:  # 纯旁白部分
			$DialogueUI/NarrationText.text = dialogue_text
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		elif index == 5:  # 阿明思考部分
			$DialogueUI/DialogueBox/DialogueText.text = dialogue_text
			speaker_label.text = "阿明"
			speaker_label.position.x = 157  # 左侧位置
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
		else:  # 对话部分
			$DialogueUI/DialogueBox/DialogueText.text = dialogue_text
			if index in [2, 4]:
				speaker_label.text = "黑衣人"
				speaker_label.position.x = 800  # 右侧位置
			else:
				speaker_label.text = "阿明"
				speaker_label.position.x = 157  # 左侧位置
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
	
	# 只在开场对话的最后一句显示开始按钮
	$DialogueUI/DialogueBox/StartButton.visible = (index == dialogues.size() - 1 and not is_showing_ending)

func _on_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if dialogue_index < dialogues.size() - 1:
			dialogue_index += 1
			update_dialogue_display(dialogue_index)
			update_portrait_modulate(dialogue_index)
			
			if dialogue_index == dialogues.size() - 1:
				$DialogueUI/DialogueBox/StartButton.show()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")

func _on_confirm_pressed():
	if current_stone_weight == 0:
		return
		
	var moment_left = current_stone_weight * right_arm  # 使用右侧力臂（实际的左侧）
	var moment_right = people_count * people_weight * left_arm  # 使用左侧力臂（实际的右侧）
	
	if moment_left == moment_right:
		show_success(moment_left)
	else:
		show_failure()

func _on_cancel_pressed():
	# 重置选择的重量
	current_stone_weight = 0
	can_rotate = false
	update_weight_display()
	
	# 删除所有已放置的石头和人物
	for child in $GameBackground/GameElements/Lever.get_children():
		if child is Sprite2D and child != $GameBackground/GameElements/Lever/LeverBar:
			child.queue_free()
	current_stone_count = 0
	
	# 重置杠杆旋转
	var lever = $GameBackground/GameElements/Lever
	if lever:
		var tween = create_tween()
		tween.tween_property(lever, "rotation", 0.0, 1.0)
	
	# 重新生成人物
	setup_people()
	$"UI#ResultTexture".hide()
	$"UI#NextButton".hide()
	$"UI#ConfirmButton".disabled = false

func _on_start_game():
	# 将场景背景调暗
	var tween = create_tween()
	tween.tween_property($Background, "modulate", Color(0.3, 0.3, 0.3, 1), 0.5)
	
	# 显示游戏背景和元素
	$GameBackground.visible = true
	$GameBackground.modulate = Color(0, 0, 0, 0)  # 初始透明
	tween.parallel().tween_property($GameBackground, "modulate", Color(1, 1, 1, 1), 0.5)  # 淡入显示
	
	# 隐藏对话界面
	$DialogueUI.visible = false
	
	# 显示游戏UI
	$GameBackground/GameElements.show()
	$"UI#StoneButtons".show()
	$"UI#ConfirmButton".show()
	$"UI#CancelButton".show()
	$"UI_WeightInfo#CurrentWeight".show()
	$"UI_WeightInfo#TargetWeight".show()
	$"UI#LevelLabel".show()
	$"UI#TorqueLabel".show()
	
	# 移除添加节点的代码，因为节点已经在场景中了
	$QuestionButton.show()
	$HintContainer.hide()  # 初始时隐藏提示容器
	
	# 初始化游戏
	setup_game()
	update_weight_display()
	setup_people()
	update_level_display()
	update_torque_ratio()
	update_fulcrum_position()

func setup_game():
	setup_stones()
	setup_lever()
	setup_person()
	
func setup_stones():
	var weights = [0.25, 1.0, 5.0]  # 石头重量选项
	var weight_textures = {
		0.25: "res://images/0.25.png",
		1.0: "res://images/1.00.png",
		5.0: "res://images/5.00.png"
	}
	
	var container = $"UI#StoneButtons"
	container.add_theme_constant_override("separation", -20)  # 设置按钮之间的间距为负值，使按钮靠得更近
	
	for weight in weights:
		var button = TextureButton.new()
		button.texture_normal = load(weight_textures[weight])
		button.pressed.connect(func(): add_weight(weight))
		button.ignore_texture_size = true
		button.custom_minimum_size = Vector2(200, 100)
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(button)

func setup_lever():
	var lever = $GameBackground/GameElements/Lever
	if lever:
		lever.rotation = 0

func setup_person():
	pass  # 保留这个空函数，因为它被setup_game调用

func setup_people():
	# 删除所有现有的人物
	for child in $GameBackground/GameElements/Lever.get_children():
		if child.name.begins_with("@Sprite2D"):
			child.queue_free()
			
	# 生成新的人物，使用不同的人物图片
	var people_textures = [
		"res://images/savegame-people1.png",
		"res://images/savegame-people2.png",
		"res://images/savegame-people3.png",
		"res://images/savegame-people4.png"
	]
	
	var person_spacing = 40  # 保持当前间距
	var base_x = 280  # 保持当前X坐标
	var base_y = -85  # 再调高Y坐标
	
	for i in range(people_count):
		var person = Sprite2D.new()
		# 循环使用不同的人物图片
		var texture_index = i % people_textures.size()
		person.texture = load(people_textures[texture_index])
		person.scale = Vector2(0.6, 0.6)  # 保持当前大小
		
		# 从左到右排列人物
		var offset = Vector2(base_x + (person_spacing * i), base_y)
		person.position = offset
		
		$GameBackground/GameElements/Lever.add_child(person)

func add_weight(weight):
	current_stone_weight += weight
	update_weight_display()
	spawn_stone(weight)

func update_weight_display():
	$"UI_WeightInfo#CurrentWeight".text = "石头重量：%.2f 石" % current_stone_weight
	$"UI_WeightInfo#TargetWeight".text = "难民总重量：%.1f 石" % (people_count * people_weight)

func update_torque_ratio():
	# 更新力臂比例显示
	var hint = "力臂比例 = 左：右 = %d：%d" % [
		right_arm, left_arm,  # 交换左右力臂比例
	]
	$"UI#TorqueLabel".text = hint

func spawn_stone(weight):
	var stone = Sprite2D.new()
	
	# 根据重量选择不同的石头图片和间距
	var stone_texture = ""
	var stone_spacing = 45  # 默认间距
	match weight:
		0.25:  # 小石头
			stone_texture = "res://images/savegame-smallstone.png"
			stone.scale = Vector2(0.3, 0.3)
			stone_spacing = 35  # 小石头用更小的间距
		1.0:  # 中等石头
			stone_texture = "res://images/savegame-mediumstone.png"
			stone.scale = Vector2(0.4, 0.4)
			stone_spacing = 40  # 中等石头用中等间距
		5.0:  # 大石头
			stone_texture = "res://images/savegame-bigstone.png"
			stone.scale = Vector2(0.5, 0.5)
			stone_spacing = 45  # 大石头保持原来的间距
	
	var texture_resource = load(stone_texture)
	if texture_resource:
		stone.texture = texture_resource
	else:
		print("Failed to load texture: ", stone_texture)
		return
	
	# 从左往右排列石头
	var base_x = -350  # 起始位置
	var base_y = -50   # 高度位置
	
	# 计算当前石头的位置，使用对应的间距
	var offset = Vector2(base_x + (stone_spacing * current_stone_count), base_y)
	stone.position = offset
	
	$GameBackground/GameElements/Lever.add_child(stone)
	current_stone_count += 1

func show_success(moment):
	# 显示成功图片
	$"UI#ResultTexture".texture = load("res://images/success.png")
	$"UI#ResultTexture".custom_minimum_size = Vector2(150, 75)
	$"UI#ResultTexture".size = Vector2(150, 75)
	$"UI#ResultTexture".show()
	
	# 添加下沉动画
	can_rotate = true
	var tween = create_tween()
	
	# 设置旋转中心点为支点位置
	var fulcrum = $GameBackground/GameElements/Fulcrum
	var lever = $GameBackground/GameElements/Lever
	var local_fulcrum_pos = lever.to_local(fulcrum.position)
	lever.transform.origin = local_fulcrum_pos
	
	# 先重置杠杆位置
	update_fulcrum_position()
	
	# 让所有物体下沉一点
	for child in $GameBackground/GameElements/Lever.get_children():
		if child is Sprite2D and child != $GameBackground/GameElements/Lever/LeverBar:
			var original_pos = child.position
			tween.parallel().tween_property(child, "position:y", 
				original_pos.y + 20, 1.0)
	
	# 3秒后自动隐藏成功图片
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func(): $"UI#ResultTexture".hide())
	
	if current_level == 3:
		# 等待动画和图片显示完成后显示结局对话
		timer.timeout.connect(func():
			# 显示结局对话
			is_showing_ending = true
			ending_dialogue_index = 0
			
			# 隐藏游戏UI
			$GameBackground/GameElements.hide()
			$"UI#StoneButtons".hide()
			$"UI#ConfirmButton".hide()
			$"UI#CancelButton".hide()
			$"UI_WeightInfo#CurrentWeight".hide()
			$"UI_WeightInfo#TargetWeight".hide()
			$"UI#LevelLabel".hide()
			$"UI#TorqueLabel".hide()
			
			# 显示结局对话UI
			$DialogueUI.show()
			update_dialogue_display(0)
			update_portrait_modulate(0)
			
			# 连接结局对话的输入事件
			if not $DialogueUI/DialogueBox.gui_input.is_connected(_on_ending_dialogue_input):
				$DialogueUI/DialogueBox.gui_input.connect(_on_ending_dialogue_input)
				if not $DialogueUI/NarrationText.gui_input.is_connected(_on_ending_dialogue_input):
					$DialogueUI/NarrationText.gui_input.connect(_on_ending_dialogue_input))
	else:
		# 显示下一关按钮
		$"UI#NextButton".show()
		$"UI#NextButton".move_to_front()
	
	$"UI#ConfirmButton".disabled = true

func show_failure():
	# 显示失败图片
	$"UI#ResultTexture".texture = load("res://images/failed.png")
	$"UI#ResultTexture".custom_minimum_size = Vector2(150, 75)
	$"UI#ResultTexture".size = Vector2(150, 75)
	$"UI#ResultTexture".show()
	
	# 3秒后自动隐藏失败图片
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func(): $"UI#ResultTexture".hide())
	
	# 旋转杠杆动画
	can_rotate = true
	var tween = create_tween()
	
	# 设置旋转中心点为支点位置
	var fulcrum = $GameBackground/GameElements/Fulcrum
	var lever = $GameBackground/GameElements/Lever
	var local_fulcrum_pos = lever.to_local(fulcrum.position)
	lever.transform.origin = local_fulcrum_pos
	
	# 先重置杠杆位置
	update_fulcrum_position()
	
	# 计算左右力矩
	var moment_left = current_stone_weight * right_arm
	var moment_right = people_count * people_weight * left_arm
	
	# 左边力矩大时往左倾斜，右边力矩大时往右倾斜
	var rotation_amount = -0.5 if moment_left > moment_right else 0.5
	
	# 先让所有物体下沉一点
	for child in $GameBackground/GameElements/Lever.get_children():
		if child is Sprite2D and child != $GameBackground/GameElements/Lever/LeverBar:
			var original_pos = child.position
			tween.parallel().tween_property(child, "position:y", 
				original_pos.y + 20, 1.0)
	
	# 等待下沉完成后开始倾斜
	tween.tween_callback(func():
		var tilt_tween = create_tween()
		
		# 执行倾斜动画
		tilt_tween.tween_property(lever, "rotation", rotation_amount, 0.8)
		
		# 等待倾斜完成后开始滑落
		tilt_tween.tween_callback(func():
			var slide_tween = create_tween()
			
			# 获取杆子的两端点位置（在倾斜后）
			var lever_bar = $GameBackground/GameElements/Lever/LeverBar
			var lever_length = lever_bar.texture.get_width() * lever_bar.scale.x
			var left_point = Vector2(-lever_length/2, 0)  # 杆子左端点（局部坐标）
			var right_point = Vector2(lever_length/2, 0)  # 杆子右端点（局部坐标）
			
			# 将局部坐标转换为全局坐标
			left_point = lever_bar.to_global(left_point)
			right_point = lever_bar.to_global(right_point)
			
			# 计算杆子的方向向量
			var direction = (right_point - left_point).normalized()
			var slide_distance = 800
			
			# 移动石头和人物
			for child in $GameBackground/GameElements/Lever.get_children():
				if child is Sprite2D and child != $GameBackground/GameElements/Lever/LeverBar:
					var original_pos = child.position
					
					# 计算滑落目标位置
					var target_pos = original_pos
					if rotation_amount < 0:  # 向左倾斜
						target_pos -= direction * slide_distance  # 向右滑动
					else:  # 向右倾斜
						target_pos += direction * slide_distance  # 向左滑动
					
					# 创建滑落动画
					slide_tween.parallel().tween_property(child, "position", 
						target_pos, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
			# 等待滑落动画结束后重置
			slide_tween.tween_callback(func():
				_on_cancel_pressed()  # 重置场景
			).set_delay(2.0)
		).set_delay(0.8)  # 等待倾斜动画完成
	).set_delay(1.0)  # 等待下沉动画完成

func update_level_display():
	# 根据当前关卡显示对应的图片
	var level_texture = load("res://images/level%d.png" % current_level)
	if level_texture:
		var texture_rect = $"UI#LevelLabel/LevelTexture"
		if texture_rect:
			texture_rect.texture = level_texture

func update_fulcrum_position():
	var fulcrum = $GameBackground/GameElements/Fulcrum
	var lever = $GameBackground/GameElements/Lever
	var total_ratio = left_arm + right_arm
	var lever_length = 300
	
	# 支点位置保持固定
	fulcrum.position = Vector2(561, 339)  # 使用场景中设置的固定位置
	
	# 根据力臂比例计算杠杆的位置
	var relative_position = float(left_arm) / total_ratio
	
	# 计算杠杆应该移动的位置，使支点位于正确的力臂比例处
	var lever_x = fulcrum.position.x + lever_length * (relative_position - 0.5)
	
	# 设置杠杆位置，保持Y坐标不变
	lever.position = Vector2(lever_x, 315)

func _on_ending_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ending_dialogue_index += 1
		if ending_dialogue_index < ending_dialogues.size():
			update_dialogue_display(ending_dialogue_index)
			update_portrait_modulate(ending_dialogue_index)
		else:
			get_tree().change_scene_to_file("res://content.tscn")

func update_portrait_modulate(index):
	var ming_portrait = $DialogueUI/DialogueBox/MingPortrait
	var blackman_portrait = $DialogueUI/DialogueBox/BlackmanPortrait
	
	if is_showing_ending:
		# 结局对话的显示逻辑
		ming_portrait.show()  # 主角头像始终显示
		match ending_dialogue_index:
			0, 4: # 纯旁白
				blackman_portrait.hide()
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			1, 2: # 黑衣人说话
				blackman_portrait.show()
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			3: # 阿明思考
				blackman_portrait.hide()
				ming_portrait.modulate = Color(1, 1, 1, 1)
			5: # 阿明说话
				blackman_portrait.hide()
				ming_portrait.modulate = Color(1, 1, 1, 1)
	else:
		# 开场对话的显示逻辑
		ming_portrait.show()  # 主角头像始终显示
		match index:
			0, 1: # 旁白
				blackman_portrait.hide()
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			2: # 黑衣人出现并说话
				blackman_portrait.show()
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			3: # 阿明说话
				blackman_portrait.show()  # 黑衣人还在场
				ming_portrait.modulate = Color(1, 1, 1, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			4: # 黑衣人最后说话
				blackman_portrait.show()
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			5, 6: # 黑衣人消失，阿明思考和旁白
				blackman_portrait.hide()
				ming_portrait.modulate = Color(1, 1, 1, 1)

func _on_next_level_pressed():
	current_level += 1
	match current_level:
		2:
			people_count = 3  # 第二关3个难民
			left_arm = 1
			right_arm = 2
		3:
			people_count = 1  # 第三关1个难民
			left_arm = 3
			right_arm = 1
		_:
			# 显示结局对话
			is_showing_ending = true
			ending_dialogue_index = 0
			
			# 隐藏游戏UI
			$GameBackground/GameElements.hide()
			$"UI#StoneButtons".hide()
			$"UI#ConfirmButton".hide()
			$"UI#CancelButton".hide()
			$"UI_WeightInfo#CurrentWeight".hide()
			$"UI_WeightInfo#TargetWeight".hide()
			$"UI#LevelLabel".hide()
			$"UI#TorqueLabel".hide()
			$"UI#ResultTexture".hide()
			$"UI#NextButton".hide()
			
			# 显示结局对话UI
			$DialogueUI.show()
			update_dialogue_display(0)
			update_portrait_modulate(0)
			return
	
	# 重置游戏状态
	_on_cancel_pressed()
	$"UI#NextButton".hide()
	$"UI#ConfirmButton".disabled = false
	
	# 更新UI显示
	update_weight_display()
	update_level_display()
	update_torque_ratio()
	update_fulcrum_position()
	
	# 清除并重新生成石头按钮
	for child in $"UI#StoneButtons".get_children():
		child.queue_free()
	setup_stones()

func _on_question_pressed():
	if not $HintContainer.visible:
		# 根据当前关卡显示不同提示
		match current_level:
			1:
				$HintContainer/HintLabel.text = "第一关：左右力臂相等\n需要的石头重量 = 难民重量"
			2:
				$HintContainer/HintLabel.text = "第二关：左力臂是右力臂2倍\n需要的石头重量 = 难民重量 ÷ 2"
			3:
				$HintContainer/HintLabel.text = "第三关：左力臂是右力臂1/3\n需要的石头重量 = 难民重量 × 3"
		
		# 显示提示
		$HintContainer.visible = true
		
		# 3秒后自动隐藏
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): $HintContainer.visible = false)
	else:
		$HintContainer.visible = false
