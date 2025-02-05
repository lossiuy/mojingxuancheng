extends Control

var current_stone_weight = 0
var people_weight = 60  # 每个难民60kg
var is_balanced = false
var can_rotate = false  # 是否可以旋转杠杆
var stone_height = 40  # 每个石头的高度
var current_stone_count = 0  # 当前石头数量
var people_count = 3  # 第一关3个人
var current_level = 1
var left_arm = 1  # 左力臂比例
var right_arm = 1  # 右力臂比例
var dialogue_index = 0
var dialogues = [
	"阿明来到衡机阁中, 突然看到一群被拴在杠杆右侧的难民, 杠杆摇摇晃晃发出咯吱咯吱的声音, 下面是密密麻麻的毒虫...",
	"难民们惊恐地看着下方, 瑟瑟发抖. 突然, 一个黑衣人从阴影中现身.",
	"\"又是一只蝼蚁来逞英雄? 看看这些可怜虫, 哈哈哈哈哈...\"\n\"劝你还是省点力气, 你救不了他们的.\"",
	"\"我不会让你得逞的!\" 阿明坚定地说.",
	"\"那要看你有没有这个本事了.\" 黑衣人冷笑一声, 消失在黑暗中.",
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
	$BackButton.pressed.connect(_on_back_pressed)
	$"UI#ConfirmButton".pressed.connect(_on_confirm_pressed)
	$"UI#CancelButton".pressed.connect(_on_cancel_pressed)
	$"UI#NextButton".pressed.connect(_on_next_pressed)
	
	# 隐藏游戏UI
	$GameElements.hide()
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
	$DialogueUI/DialogueBox/StartButton.pressed.connect(_on_start_game)  # 更新按钮路径
	$DialogueUI/DialogueBox/StartButton.hide()

func update_dialogue_display(index):
	var dialogue_text = dialogues[index]
	if is_showing_ending:
		# 结局对话显示逻辑
		if ending_dialogue_index in [0, 4]:  # 纯旁白部分
			$DialogueUI/NarrationText.text = ending_dialogues[ending_dialogue_index]
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		elif ending_dialogue_index == 3:  # 阿明的心理活动
			$DialogueUI/DialogueBox/DialogueText.text = ending_dialogues[ending_dialogue_index]
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
			# 心理活动时只显示阿明头像
			$DialogueUI/DialogueBox/MingPortrait.visible = true
			$DialogueUI/DialogueBox/BlackmanPortrait.visible = false
		else:  # 对话部分
			$DialogueUI/DialogueBox/DialogueText.text = ending_dialogues[ending_dialogue_index]
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
			
			# 只在说话时显示对应的头像
			$DialogueUI/DialogueBox/BlackmanPortrait.visible = (ending_dialogue_index in [1, 2])
			$DialogueUI/DialogueBox/MingPortrait.visible = (ending_dialogue_index == 5)
		
		# 结局对话时始终隐藏开始按钮
		$DialogueUI/DialogueBox/StartButton.hide()
	else:
		# 开场对话显示逻辑
		if index in [0, 1, 7]:  # 纯旁白部分
			$DialogueUI/NarrationText.text = dialogue_text
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		else:  # 对话和心理活动部分
			$DialogueUI/DialogueBox/DialogueText.text = dialogue_text
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
			
			# 黑衣人消失后的对话和心理活动不显示黑衣人头像
			$DialogueUI/DialogueBox/BlackmanPortrait.visible = (index in [2, 4])
			
			# 阿明思考时只显示阿明的头像
			if index == 5:  # 思考墨经的部分
				$DialogueUI/DialogueBox/MingPortrait.modulate = Color(1, 1, 1, 1)
				$DialogueUI/DialogueBox/BlackmanPortrait.hide()
			
			# 最后一句对话显示开始按钮
			$DialogueUI/DialogueBox/StartButton.visible = (index == dialogues.size() - 1)

func _on_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if dialogue_index < dialogues.size() - 1:
			dialogue_index += 1
			update_dialogue_display(dialogue_index)
			update_portrait_modulate(dialogue_index)
			
			if dialogue_index == dialogues.size() - 1:
				$DialogueUI/DialogueBox/StartButton.show()

func update_portrait_modulate(index):
	var ming_portrait = $DialogueUI/DialogueBox/MingPortrait
	var blackman_portrait = $DialogueUI/DialogueBox/BlackmanPortrait
	
	if is_showing_ending:
		# 结局对话的亮暗逻辑
		match ending_dialogue_index:
			0, 4: # 纯旁白
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			1, 2: # 黑衣人说话
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			3: # 阿明思考
				ming_portrait.modulate = Color(1, 1, 1, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			5: # 阿明说话
				ming_portrait.modulate = Color(1, 1, 1, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
	else:
		# 开场对话的亮暗逻辑
		match index:
			0, 1: # 旁白
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			2: # 黑衣人说话
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			3: # 阿明说话
				ming_portrait.modulate = Color(1, 1, 1, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			4: # 黑衣人说话
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			5: # 阿明思考
				ming_portrait.modulate = Color(1, 1, 1, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			6: # 旁白
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")

func _on_confirm_pressed():
	if current_stone_weight == 0:
		return
		
	var moment_left = current_stone_weight * left_arm
	var moment_right = people_count * people_weight * right_arm
	
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
	for child in $GameElements/Lever.get_children():
		if child is Sprite2D and child != $GameElements/Lever/LeverBar:
			child.queue_free()
	current_stone_count = 0
	
	# 重置杠杆旋转
	var lever = $GameElements/Lever
	if lever:
		var tween = create_tween()
		tween.tween_property(lever, "rotation", 0.0, 1.0)
	
	# 重新生成人物
	setup_people()
	$"UI#ResultLabel".hide()
	$"UI#NextButton".hide()
	$"UI#ConfirmButton".disabled = false

func _on_next_pressed():
	if is_showing_ending:
		ending_dialogue_index += 1
		if ending_dialogue_index < ending_dialogues.size():
			update_dialogue_display(ending_dialogue_index)
		else:
			# 对话结束后直接返回目录地图页面
			get_tree().change_scene_to_file("res://content.tscn")
		return
		
	current_level += 1
	match current_level:
		2:
			people_count = 2  # 2个难民
			left_arm = 1
			right_arm = 2
			var level_hint = "第二关：右力臂(200)是左力臂(100)的2倍\n需要的石头重量 = 右力臂(%d) × 难民重量(%dkg) ÷ 左力臂(%d) = %dkg" % [
				right_arm * 100,
				people_count * people_weight,
				left_arm * 100,
				people_count * people_weight * 2
			]
			$"UI#ResultLabel".text = level_hint
			$"UI#ResultLabel".modulate = Color(0, 0, 0)
			$"UI#ResultLabel".show()
		3:
			people_count = 3  # 3个难民
			left_arm = 3
			right_arm = 1
			var level_hint = "第三关：左力臂(300)是右力臂(100)的3倍\n需要的石头重量 = 右力臂(%d) × 难民重量(%dkg) ÷ 左力臂(%d) = %dkg" % [
				right_arm * 100,
				people_count * people_weight,
				left_arm * 100,
				people_count * people_weight / 3
			]
			$"UI#ResultLabel".text = level_hint
			$"UI#ResultLabel".modulate = Color(0, 0, 0)
			$"UI#ResultLabel".show()
		_:
			# 显示结局对话
			is_showing_ending = true
			ending_dialogue_index = 0
			
			# 隐藏游戏UI
			$GameElements.hide()
			$"UI#StoneButtons".hide()
			$"UI#ConfirmButton".hide()
			$"UI#CancelButton".hide()
			$"UI_WeightInfo#CurrentWeight".hide()
			$"UI_WeightInfo#TargetWeight".hide()
			$"UI#LevelLabel".hide()
			$"UI#TorqueLabel".hide()
			$"UI#ResultLabel".hide()
			$"UI#NextButton".hide()
			
			# 显示结局对话UI
			$DialogueUI.show()
			update_dialogue_display(0)  # 使用统一的显示函数
			update_portrait_modulate(0)
			
			# 连接结局对话的输入事件
			if not $DialogueUI/DialogueBox.gui_input.is_connected(_on_ending_dialogue_input):
				$DialogueUI/DialogueBox.gui_input.connect(_on_ending_dialogue_input)
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

func _on_start_game():
	# 隐藏对话UI
	$DialogueUI.hide()
	
	# 显示游戏UI
	$GameElements.show()
	$"UI#StoneButtons".show()
	$"UI#ConfirmButton".show()
	$"UI#CancelButton".show()
	$"UI_WeightInfo#CurrentWeight".show()
	$"UI_WeightInfo#TargetWeight".show()
	$"UI#LevelLabel".show()
	$"UI#TorqueLabel".show()
	
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
	var weights = [10, 20, 50]  # 新的石头重量选项
	for weight in weights:
		var button = Button.new()
		button.text = str(weight) + "kg"
		button.pressed.connect(func(): add_weight(weight))
		button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		$"UI#StoneButtons".add_child(button)

func setup_lever():
	var lever = $GameElements/Lever
	if lever:
		lever.rotation = 0

func setup_person():
	pass  # 保留这个空函数，因为它被setup_game调用

func setup_people():
	# 删除所有现有的人物
	for child in $GameElements/Lever.get_children():
		if child.name.begins_with("@Sprite2D"):
			child.queue_free()
			
	# 生成新的人物
	for i in range(people_count):
		var person = Sprite2D.new()
		person.texture = load("res://images/savegame-people.png")
		person.scale = Vector2(0.3, 0.3)
		
		# 调整人物位置，确保在视野内
		var offset = Vector2(60, -20 - (40 * i))  # 调整x坐标从80到60
		person.position = offset
		
		$GameElements/Lever.add_child(person)

func add_weight(weight):
	current_stone_weight += weight
	update_weight_display()
	spawn_stone(weight)

func update_weight_display():
	$"UI_WeightInfo#CurrentWeight".text = "已选重量：%d kg" % current_stone_weight
	$"UI_WeightInfo#TargetWeight".text = "难民总重量：%d kg" % (people_count * people_weight)

func update_torque_ratio():
	# 更新力臂比例显示
	var hint = "力臂比例 = 左：右 = %d：%d\n左力臂长度 = %d, 右力臂长度 = %d" % [
		left_arm, right_arm, left_arm * 100, right_arm * 100
	]
	$"UI#TorqueLabel".text = hint

func spawn_stone(weight):
	var stone = Sprite2D.new()
	
	# 根据重量选择不同的石头图片
	var stone_texture = ""
	match weight:
		10:
			stone_texture = "res://images/savegame-smallstone.png"  # 最小的石头
			stone.scale = Vector2(0.3, 0.3)
		20:
			stone_texture = "res://images/savegame-mediumstone.png"  # 中等的石头
			stone.scale = Vector2(0.4, 0.4)
		50:
			stone_texture = "res://images/savegame-bigstone.png"  # 最大的石头
			stone.scale = Vector2(0.5, 0.5)
	
	var texture_resource = load(stone_texture)
	if texture_resource:
		stone.texture = texture_resource
	else:
		print("Failed to load texture: ", stone_texture)
		return
	
	# 调整石头的初始位置，确保在视野内
	var stone_spacing = 40
	var base_x = -200  # 修改为更靠近中心的位置
	var base_y = 55
	var offset = Vector2(base_x + (stone_spacing * current_stone_count), base_y)
	stone.position = offset
	
	$GameElements/Lever.add_child(stone)
	current_stone_count += 1

func show_success(moment):
	if current_level == 3:
		# 第三关成功后显示结局对话
		is_showing_ending = true
		ending_dialogue_index = 0
		
		# 隐藏游戏UI
		$GameElements.hide()
		$"UI#StoneButtons".hide()
		$"UI#ConfirmButton".hide()
		$"UI#CancelButton".hide()
		$"UI_WeightInfo#CurrentWeight".hide()
		$"UI_WeightInfo#TargetWeight".hide()
		$"UI#LevelLabel".hide()
		$"UI#TorqueLabel".hide()
		$"UI#ResultLabel".hide()
		$"UI#NextButton".hide()
		
		# 显示结局对话UI
		$DialogueUI.show()
		update_dialogue_display(0)  # 使用统一的显示函数
		update_portrait_modulate(0)
		
		# 连接结局对话的输入事件
		if not $DialogueUI/DialogueBox.gui_input.is_connected(_on_ending_dialogue_input):
			$DialogueUI/DialogueBox.gui_input.connect(_on_ending_dialogue_input)
		if not $DialogueUI/NarrationText.gui_input.is_connected(_on_ending_dialogue_input):
			$DialogueUI/NarrationText.gui_input.connect(_on_ending_dialogue_input)
	else:
		# 前两关显示成功提示和下一关按钮
		var message = "左边力矩 = 右边力矩 = %d（%d力臂×%dkg）\n拯救成功！请进入下一关拯救其他难民！" % [
			moment,
			left_arm,
			current_stone_weight
		]
		$"UI#ResultLabel".text = message
		$"UI#ResultLabel".modulate = Color(0, 1, 0)
		$"UI#ResultLabel".show()
		$"UI#NextButton".show()
		$"UI#ConfirmButton".disabled = true
	
	# 旋转杠杆动画
	can_rotate = true
	var tween = create_tween()
	tween.tween_property($GameElements/Lever, "rotation", 0.0, 1.0)
	
	# 移动石头和人物
	for child in $GameElements/Lever.get_children():
		if child is Sprite2D and child != $GameElements/Lever/LeverBar:
			var original_pos = child.position
			if "@Sprite2D" in child.name:  # 人物
				tween.parallel().tween_property(child, "position:y", original_pos.y + 20, 1.0)
			else:  # 石头
				tween.parallel().tween_property(child, "position:y", original_pos.y + 20, 1.0)

func show_failure():
	var message = "左边力矩 ≠ 右边力矩\n请重新尝试！"
	$"UI#ResultLabel".text = message
	$"UI#ResultLabel".modulate = Color(1, 0, 0)
	$"UI#ResultLabel".show()
	
	# 旋转杠杆动画
	can_rotate = true
	var tween = create_tween()
	var rotation_amount = 0.0
	var slide_direction = 1.0  # 1.0表示向右滑，-1.0表示向左滑
	
	if current_stone_weight * left_arm > people_count * people_weight * right_arm:
		rotation_amount = -0.5  # 向左倾斜
		slide_direction = -1.0
	else:
		rotation_amount = 0.5   # 向右倾斜
		slide_direction = 1.0
	
	# 先旋转杠杆
	tween.tween_property($GameElements/Lever, "rotation", rotation_amount, 0.5)
	
	# 等待一小段时间后开始滑落
	tween.tween_interval(0.2)
	
	# 调整滑落距离，确保在视野内
	for child in $GameElements/Lever.get_children():
		if child is Sprite2D and child != $GameElements/Lever/LeverBar:
			var original_pos = child.position
			
			if "@Sprite2D" in child.name:  # 人物
				var target_x = -200 if slide_direction < 0 else original_pos.x  # 修改从-305到-200
				
				# 第一阶段：沿着杆子滑到目标端
				tween.parallel().tween_property(child, "position:x", 
					target_x, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				
				# 第二阶段：从末端掉落
				tween.parallel().tween_property(child, "position:y", 
					500, 1.0).set_delay(1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)  # 修改从800到500
			else:  # 石头
				var target_x = original_pos.x if slide_direction < 0 else 60  # 修改从80到60
				
				# 第一阶段：沿着杆子滑到目标端
				tween.parallel().tween_property(child, "position:x", 
					target_x, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				
				# 第二阶段：从末端掉落
				tween.parallel().tween_property(child, "position:y", 
					500, 1.0).set_delay(1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)  # 修改从800到500
	
	# 等待动画结束后重置
	tween.tween_callback(func():
		_on_cancel_pressed()  # 重置场景
	).set_delay(2.5)

func update_level_display():
	$"UI#LevelLabel".text = "第%d关" % current_level

func update_fulcrum_position():
	var fulcrum = $GameElements/Fulcrum
	var lever = $GameElements/Lever
	var total_ratio = left_arm + right_arm
	var lever_length = 300  # 杠杆总长度
	
	# 计算支点位置
	# 如果左：右=1：2，支点在1/3处
	# 如果左：右=3：1，支点在3/4处
	var relative_position = float(left_arm) / total_ratio  # 这就是支点应该在的位置（从左端开始算）
	
	# 计算支点的新位置
	var lever_left = lever.position.x - lever_length/2  # 杠杆左端位置
	var new_x = lever_left + (lever_length * relative_position)
	
	# 使用动画移动支点
	var tween = create_tween()
	tween.tween_property(fulcrum, "position:x", new_x, 1.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# 保持y位置不变
	fulcrum.position.y = 470

func _on_ending_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ending_dialogue_index += 1
		if ending_dialogue_index < ending_dialogues.size():
			update_dialogue_display(ending_dialogue_index)
			update_portrait_modulate(ending_dialogue_index)
		else:
			get_tree().change_scene_to_file("res://content.tscn")
