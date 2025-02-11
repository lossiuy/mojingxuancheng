extends Control

var current_buoyancy = 0  # 当前浮力
var refugee_weight = 60   # 每个难民60kg
var is_rescued = false    # 是否成功救援
var can_float = false     # 救生筏是否可以浮起
var material_height = 40  # 每个材料的高度
var current_material_count = 0  # 当前材料数量
var refugee_count = 2     # 第一关2个难民
var current_level = 1
var dialogue_index = 0
var dialogues = [
	"洪水肆虐，城市陷入一片汪洋。远处传来呼救声，一群难民被困在水中，随时可能被洪水吞没...",
	"突然，一个黑衣人从阴影中现身，冷笑着说：'你以为你能救他们？没有我的允许，谁都别想离开！'",
	"阿明坚定地说：'我不会放弃的！我一定会救他们！'",
	"黑衣人嘲笑道：'那就试试吧！如果你能在三分钟内制作出足够承重的救生筏，我就放他们走。否则...'",
	"(阿明环顾四周，发现了一些木板、塑料瓶和绳子。他回忆起浮力原理：)\n\"浮力 = 排开水的重量 = 材料的总体积 × 水的密度。\"",
	"如果根据难民的重量，选择合适的材料并合理组合，或许可以制作出足够承重的救生筏...\n\n准备好了吗？让我们开始救援！"
]

var ending_dialogues = [
	"难民们终于获救了，洪水也逐渐退去...",
	"黑衣人冷笑道：'哼，不过是侥幸罢了。真正的挑战还在后面！'",
	"阿明望着黑衣人离去的背影，心中充满了疑惑...",
	"难民们感激地说：'大侠，还有很多人被困在下游，请你一定要救救他们！'",
	"阿明点点头：'好，我这就去！'"
]

var is_showing_ending = false
var ending_dialogue_index = 0

func _ready():
	$Background.visible = true
	$Background.modulate = Color(1, 1, 1, 1)  # 正常亮度
	$BackButton.pressed.connect(_on_back_pressed)
	$"UI#ConfirmButton".pressed.connect(_on_confirm_pressed)


	
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
	$DialogueUI/DialogueBox/StartButton.pressed.connect(_on_start_game)  # 更新按钮路径
	$DialogueUI/DialogueBox/StartButton.hide()
	$GameBackground.visible = false  # 初始时隐藏游戏背景

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")
	
func update_portrait_modulate(index):
	
	var ming_portrait = $DialogueUI/DialogueBox/MingPortrait
	if index in [2, 4]:  # 黑衣人说话时
		ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
	else:  # 阿明说话时
		ming_portrait.modulate = Color(1, 1, 1, 1)

func update_dialogue_display(index):
	var dialogue_text = dialogues[index]
	var speaker_label = $DialogueUI/DialogueBox/SpeakerName

	if is_showing_ending:
		# 结局对话显示逻辑
		$DialogueUI/DialogueBox/StartButton.hide()
		if ending_dialogue_index in [0, 3]:
			$DialogueUI/NarrationText.text = ending_dialogues[ending_dialogue_index]
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		else:
			$DialogueUI/DialogueBox/DialogueText.text = ending_dialogues[ending_dialogue_index]
			if ending_dialogue_index == 1:
				speaker_label.text = "黑衣人"
				speaker_label.position.x = 800
			else:
				speaker_label.text = "阿明"
				speaker_label.position.x = 157
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
	else:
		# 开场对话显示逻辑
		if index in [0, 1]:
			$DialogueUI/NarrationText.text = dialogue_text
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		else:
			$DialogueUI/DialogueBox/DialogueText.text = dialogue_text
			if index in [2, 4]:
				speaker_label.text = "黑衣人"
				speaker_label.position.x = 800
			else:
				speaker_label.text = "阿明"
				speaker_label.position.x = 157
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()

	# 显示开始按钮
	$DialogueUI/DialogueBox/StartButton.visible = (index == dialogues.size() - 1 and not is_showing_ending)

func _on_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if dialogue_index < dialogues.size() - 1:
			dialogue_index += 1
			update_dialogue_display(dialogue_index)
			update_portrait_modulate(dialogue_index)

			if dialogue_index == dialogues.size() - 1:
				$DialogueUI/DialogueBox/StartButton.show()

func _on_start_game():
	# 显示游戏背景和元素
	$GameBackground.visible = true
	$GameBackground.modulate = Color(1, 1, 1, 1)
	$DialogueUI.visible = false

	# 显示游戏UI
	show_game_ui()

	# 初始化游戏
	setup_game()
	update_buoyancy_display()
	setup_refugees()
	update_level_display()

func setup_game():
	setup_materials()
	setup_raft()
	setup_refugees()

func setup_refugees():
	# 确保 GameElements 节点存在
	var game_elements = $GameBackground/GameElements
	if not game_elements:
		push_error("GameElements node not found!")
		return
		
	# 清除现有的难民
	for child in game_elements.get_children():
		if child.name.begins_with("@Sprite2D"):
			child.queue_free()
	
	# 生成新的难民，使用不同的人物图片
	var people_textures = [
		"res://images/savegame-people1.png",
		"res://images/savegame-people2.png",
		"res://images/savegame-people3.png",
		"res://images/savegame-people4.png"
	]
	
	for i in range(refugee_count):
		var refugee = Sprite2D.new()
		# 循环使用不同的人物图片
		var texture_index = i % people_textures.size()
		var texture = load(people_textures[texture_index])
		if not texture:
			push_error("Failed to load refugee texture!")
			continue
			
		refugee.texture = texture
		refugee.position = Vector2(200, -150 + i * 40)
		game_elements.add_child(refugee)

# 更新关卡显示
func update_level_display():
	$"UI#LevelLabel".text = "当前关卡：%d" % current_level
	$"UI#LevelLabel".show()

# 初始化救生筏
func setup_raft():
	# 清空旧的物品
	for child in $GameBackground/GameElements/Raft.get_children():
		child.queue_free()

	# 重新初始化空的筏子
	var raft = Node2D.new()
	$GameBackground/GameElements/Raft.add_child(raft)

func setup_materials():
	var materials = {
		10: "res://images/savegame-smallstone.png",
		20: "res://images/savegame-mediumstone.png",
		50: "res://images/savegame-bigstone.png"
	}
	# 确保MaterialButtons节点存在
	var material_buttons = $UI/MaterialButtons
	if not material_buttons:
		push_error("MaterialButtons node not found!")
		return
		
	for buoyancy in materials.keys():
		var button = Button.new()
		button.text = str(buoyancy) + "浮力"
		button.pressed.connect(func(): add_buoyancy(buoyancy))
		button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		material_buttons.add_child(button)

func add_buoyancy(buoyancy):
	current_buoyancy += buoyancy
	update_buoyancy_display()
	spawn_material(buoyancy)

func update_buoyancy_display():
	$"UI_BuoyancyInfo#CurrentBuoyancy".text = "当前浮力：%d" % current_buoyancy
	$"UI_BuoyancyInfo#TargetBuoyancy".text = "所需浮力：%d" % (refugee_count * refugee_weight)

func spawn_material(buoyancy):
	var mat_sprite = Sprite2D.new()  # 改用mat_sprite而不是material
	var material_texture = ""
	match buoyancy:
		10: material_texture = "res://images/savegame-smallstone.png"
		20: material_texture = "res://images/savegame-mediumstone.png"
		50: material_texture = "res://images/savegame-bigstone.png"

	mat_sprite.texture = load(material_texture)
	mat_sprite.scale = Vector2(0.5, 0.5)
	mat_sprite.position = Vector2(-300 + (50 * current_material_count), -50)
	$GameBackground/GameElements/Raft.add_child(mat_sprite)
	current_material_count += 1

func _on_confirm_pressed():
	if current_buoyancy >= refugee_count * refugee_weight:
		show_success()
	else:
		show_failure()

func show_success():
	$"UI#ResultLabel".text = "浮力足够，难民获救！"
	$"UI#ResultLabel".modulate = Color(0, 1, 0)
	$"UI#ResultLabel".show()
	$"UI#NextButton".show()
	$"UI#ConfirmButton".disabled = true
	
	# 添加动画效果
	var tween = create_tween()
	
	# 让难民上升的动画
	for refugee in $GameBackground/GameElements.get_children():
		if refugee is Sprite2D:
			var original_pos = refugee.position
			tween.parallel().tween_property(refugee, "position:y", 
				original_pos.y - 100, 1.0).set_trans(Tween.TRANS_QUAD)
	
	# 如果是最后一关，显示结局对话
	if current_level == 3:
		tween.tween_callback(func():
			is_showing_ending = true
			ending_dialogue_index = 0
			hide_game_ui()
			$DialogueUI.show()
			update_dialogue_display(0)
		).set_delay(1.5)

func show_failure():
	$"UI#ResultLabel".text = "浮力不足，救生筏沉没了！"
	$"UI#ResultLabel".modulate = Color(1, 0, 0)
	$"UI#ResultLabel".show()
	$"UI#ConfirmButton".disabled = true
	
	# 添加动画效果
	var tween = create_tween()
	
	# 让难民和材料下沉的动画
	for child in $GameBackground/GameElements.get_children():
		if child is Sprite2D:
			var original_pos = child.position
			tween.parallel().tween_property(child, "position:y", 
				original_pos.y + 200, 1.5).set_trans(Tween.TRANS_QUAD)
	
	# 等待动画结束后重置
	tween.tween_callback(func():
		_on_cancel_pressed()
	).set_delay(2.0)

func _on_next_pressed():
	if is_showing_ending:
		ending_dialogue_index += 1
		if ending_dialogue_index < ending_dialogues.size():
			update_dialogue_display(ending_dialogue_index)
		else:
			get_tree().change_scene_to_file("res://content.tscn")
		return
		
	current_level += 1
	match current_level:
		2:
			refugee_count = 3
			var level_hint = "第二关：需要救援3名难民\n总重量 = %d kg" % (refugee_count * refugee_weight)
			$"UI#ResultLabel".text = level_hint
			$"UI#ResultLabel".modulate = Color(0, 0, 0)
			$"UI#ResultLabel".show()
		3:
			refugee_count = 4
			var level_hint = "第三关：需要救援4名难民\n总重量 = %d kg" % (refugee_count * refugee_weight)
			$"UI#ResultLabel".text = level_hint
			$"UI#ResultLabel".modulate = Color(0, 0, 0)
			$"UI#ResultLabel".show()
		_:
			# 显示结局对话
			is_showing_ending = true
			ending_dialogue_index = 0
			hide_game_ui()
			$DialogueUI.show()
			update_dialogue_display(0)
			return
	
	# 重置游戏状态
	_on_cancel_pressed()
	$"UI#NextButton".hide()
	$"UI#ConfirmButton".disabled = false
	
	# 更新UI显示
	update_buoyancy_display()
	update_level_display()
	setup_refugees()

func hide_game_ui():
	$GameBackground/GameElements.hide()
	$"UI#ConfirmButton".hide()
	$"UI#CancelButton".hide()
	$"UI_BuoyancyInfo#CurrentBuoyancy".hide()
	$"UI_BuoyancyInfo#TargetBuoyancy".hide()
	$"UI#LevelLabel".hide()
	$UI/BuoyancyLabel.hide()

func show_game_ui():
	$GameBackground/GameElements.show()
	$UI/MaterialButtons.show()
	$UI/ConfirmButton.show()
	$UI/CancelButton.show()
	$UI_BuoyancyInfo/CurrentBuoyancy.show()
	$UI_BuoyancyInfo/TargetBuoyancy.show()
	$UI/LevelLabel.show()
	$UI/BuoyancyLabel.show()

func _on_cancel_pressed():
	# 重置选择的浮力
	current_buoyancy = 0
	current_material_count = 0
	update_buoyancy_display()
	
	# 删除所有已放置的材料
	for child in $GameBackground/GameElements/Raft.get_children():
		child.queue_free()
	
	# 重置UI状态
	$"UI#ResultLabel".hide()
	$"UI#NextButton".hide()
	$"UI#ConfirmButton".disabled = false
	
	# 重新生成难民
	setup_refugees()
