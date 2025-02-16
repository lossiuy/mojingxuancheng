extends Control

# 预加载资源
@onready var heavy_item_texture = preload("res://images/savegame-mediumstone.png")
@onready var float_item_texture = preload("res://images/savegame-lever.png")
@onready var nextlevel_texture = preload("res://images/nextlevel.png")
@onready var success_texture = preload("res://images/success.png")
@onready var failed_texture = preload("res://images/failed.png")
@onready var restart_texture = preload("res://images/restart.png")

# 关卡配置
const LEVEL_CONFIG = {
	1: {
		"target": 60.0,  # 降低第一关目标
		"time": 120.0,   # 增加时间，让新手更容易上手
		"items": {
			"float": [ItemType.FOAM],  # 只有最基础的泡沫块
			"heavy": [ItemType.IRON]   # 只有最基础的铁块
		}
	},
	2: {
		"target": 150.0,
		"time": 120.0,
		"items": {
			"float": [ItemType.FOAM, ItemType.WOOD],     # 增加木板
			"heavy": [ItemType.IRON, ItemType.POT]       # 增加铁锅
		}
	},
	3: {
		"target": 300.0,
		"time": 150.0,
		"items": {
			"float": [ItemType.FOAM, ItemType.WOOD, ItemType.MAGIC],  # 所有浮力物品
			"heavy": [ItemType.IRON, ItemType.POT, ItemType.STONE]    # 所有重力物品
		}
	}
}

var current_level = 1  # 当前关卡

# 对话相关变量
var dialogue_index = 0
var dialogues = [
	"阿明来到浮光池，水雾缭绕中，几艘竹筏在水面上摇晃不定...",
	"竹筏上绑着一群难民，筏下系着沉重的石块，四周散落着各种浮物。一个不慎，竹筏就会倾覆沉没...",
	"\"来得倒快。\" 黑衣人的声音在水雾中响起，语气中带着一丝熟悉的严厉",
	"阿明凝视着危险的局面：\n\"无论你设下什么机关，我都会破解！\"",
	"\"还是这么急躁。\" 黑衣人的语气突然让阿明想起了什么，但一时又想不起来",
	"阿明定了定神，回忆起《墨经》的教导：\n\"以重力沉，大小之势也。沉之重，与浮之轻相若，乃得浮于水...\"",
	"（看来要救出这些人，得利用浮物和重物的配合，使竹筏保持平衡...）\n\n准备好了吗？让我们开始营救！"
]

# 游戏相关变量
var current_stone_weight = 0.0
var current_float_weight = 0.0
var game_time = 90.0
var time_bonus = 10.0
var game_success = false
var target_weight = 100.0
var time_update_timer = 0.0  # 用于控制时间更新间隔

# 物品类
class Item:
	var position: Vector2
	var type: ItemType
	var value: float
	var speed: float = 200.0  # 下落速度
	var node: Control  # 改为更通用的 Control 类型
	
	func _init(pos: Vector2, t: ItemType, v: float):
		position = pos
		type = t
		value = v

# 玩家移动相关
var player_position = Vector2(500, 500)  # 玩家位置
var player_speed = 400  # 玩家移动速度
var spawn_timer = 0.0  # 生成物品的计时器
var spawn_interval = 0.8  # 生成物品的间隔
var falling_items = []  # 存储掉落物品的数组

# 定义物品类型
enum ItemType { 
	FOAM,    # 泡沫块 +10
	WOOD,    # 木板 +20
	MAGIC,   # 魔力浮石 +50
	IRON,    # 铁块 +10
	POT,     # 陶罐 +20
	STONE,   # 石雕 +50
	BOMB,    # 炸弹 失败
	TIMER    # 沙漏 加时间
}

# 物品属性配置
const ITEM_CONFIG = {
	ItemType.FOAM: { "value": 20.0, "text": "泡沫块" },
	ItemType.WOOD: { "value": 40.0, "text": "木板" },
	ItemType.MAGIC: { "value": 100.0, "text": "魔力浮石" },
	ItemType.IRON: { "value": 20.0, "text": "铁块" },
	ItemType.POT: { "value": 40.0, "text": "陶罐" },
	ItemType.STONE: { "value": 100.0, "text": "石雕" },
	ItemType.BOMB: { "value": 0.0, "text": "炸弹" },
	ItemType.TIMER: { "value": 0.0, "text": "沙漏" }
}

var ending_dialogues = [
	"浮光池的难民终于获救了，他们纷纷向阿明道谢...",
	"黑衣人站在不远处：\n\"看来你还记得我教你的道理。\"",
	"这熟悉的语气，这熟悉的教导方式，阿明终于想起来了：\n\"师...师兄？！真的是你？\"",
	"黑衣人摘下面具，露出一张熟悉的面容：\n\"世道早已不同，你又能救得了几人？\"",
	"\"等等！\" 阿明刚想追上去，黑衣人转身离开",
	"阿明望着师兄离去的背影，心中百感交集：\n\"师兄为何要这样做...看来去镜天廊，不仅是为了救人，更是为了找到答案！\""
]

var is_showing_ending = false
var ending_dialogue_index = 0

func _ready():
	# 初始时背景正常显示
	$Background.visible = true
	$Background.modulate = Color(1, 1, 1, 1)  # 正常亮度
	$BackButton.pressed.connect(_on_back_pressed)
	
	# 隐藏游戏UI
	$GameBackground.hide()
	$GameBackground/FallingItems.hide()
	$GameBackground/Player.hide()
	$GameBackground/UI/WeightInfo.hide()
	$Result.hide()  # 修改这里
	
	# 显示对话UI
	$DialogueUI.show()
	$DialogueUI/DialogueBox.show()
	$DialogueUI/NarrationText.show()
	
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
	
	# 初始化游戏相关变量
	current_stone_weight = 0
	current_float_weight = 0
	falling_items.clear()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")

func update_dialogue_display(index):
	print("Updating dialogue display for index:", index)  # 添加调试输出
	var dialogue_text = dialogues[index]
	var speaker_label = $DialogueUI/DialogueBox/SpeakerName

	if is_showing_ending:
		$DialogueUI/DialogueBox/StartButton.hide()
		
		if ending_dialogue_index in [0, 4]:
			$DialogueUI/NarrationText.text = ending_dialogues[ending_dialogue_index]
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		elif ending_dialogue_index == 3:
			$DialogueUI/DialogueBox/DialogueText.text = ending_dialogues[ending_dialogue_index]
			speaker_label.text = "阿明"
			speaker_label.position.x = 157
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
			$DialogueUI/DialogueBox/MingPortrait.visible = true
			$DialogueUI/DialogueBox/BlackmanPortrait.visible = false
		else:
			$DialogueUI/DialogueBox/DialogueText.text = ending_dialogues[ending_dialogue_index]
			if ending_dialogue_index in [1, 2]:
				speaker_label.text = "黑衣人"
				speaker_label.position.x = 800
			else:
				speaker_label.text = "阿明"
				speaker_label.position.x = 157
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
	else:
		if index in [0, 1]:
			$DialogueUI/NarrationText.text = dialogue_text
			$DialogueUI/NarrationText.show()
			$DialogueUI/DialogueBox.hide()
		elif index == 5:
			$DialogueUI/DialogueBox/DialogueText.text = dialogue_text
			speaker_label.text = "阿明"
			speaker_label.position.x = 157
			$DialogueUI/NarrationText.hide()
			$DialogueUI/DialogueBox.show()
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

		# 在最后一句对话时显示开始按钮
		if index == dialogues.size() - 1:
			print("Showing start button in update_dialogue_display")  # 添加调试输出
			$DialogueUI/DialogueBox/StartButton.show()
		else:
			$DialogueUI/DialogueBox/StartButton.hide()

func update_portrait_modulate(index):
	var ming_portrait = $DialogueUI/DialogueBox/MingPortrait
	var blackman_portrait = $DialogueUI/DialogueBox/BlackmanPortrait
	
	if is_showing_ending:
		ming_portrait.show()
		match ending_dialogue_index:
			0, 4:
				blackman_portrait.hide()
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			1, 2:
				blackman_portrait.show()
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			3, 5:
				blackman_portrait.hide()
				ming_portrait.modulate = Color(1, 1, 1, 1)
	else:
		ming_portrait.show()
		blackman_portrait.show()  # 总是显示黑衣人头像
		match index:
			0, 1:
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
			2, 4:
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(1, 1, 1, 1)
			3, 5, 6:
				ming_portrait.modulate = Color(0.5, 0.5, 0.5, 1)
				blackman_portrait.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_dialogue_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_showing_ending:
			if ending_dialogue_index < ending_dialogues.size() - 1:
				ending_dialogue_index += 1
				update_dialogue_display(ending_dialogue_index)
				update_portrait_modulate(ending_dialogue_index)
			else:
				# 结局对话结束后返回目录
				get_tree().change_scene_to_file("res://content.tscn")
		else:
		if dialogue_index < dialogues.size() - 1:
			dialogue_index += 1
			update_dialogue_display(dialogue_index)
			update_portrait_modulate(dialogue_index)

func _on_start_game():
	# 隐藏背景和对话界面
	$Background.hide()
	$DialogueUI.hide()
	
	# 显示游戏界面
	$GameBackground.show()
	$GameBackground.modulate = Color(1, 1, 1, 1)  # 确保游戏背景完全不透明

	# 显示游戏UI
	$GameBackground/FallingItems.show()
	$GameBackground/Player.show()
	$GameBackground/UI/WeightInfo.show()
	
	# 重置游戏状态
	reset_game_state()

func reset_game_state():
	# 重置所有游戏状态
	current_stone_weight = 0
	current_float_weight = 0
	game_time = LEVEL_CONFIG[current_level].time
	target_weight = LEVEL_CONFIG[current_level].target
	spawn_timer = 0.0
	game_success = false  # 重置游戏成功状态
	# 清理所有掉落物品
	for item in falling_items:
		if item.node:
			item.node.queue_free()
	falling_items.clear()
	# 更新显示
	update_weight_display()

func _process(delta):
	# 如果结果界面显示中，暂停游戏逻辑
	if $Result.visible:
		return
	
	if not $GameBackground.visible:
		return
		
	if game_success:
		return
		
	# 更新游戏时间，每秒更新一次
	time_update_timer += delta
	if time_update_timer >= 1.0:
		time_update_timer = 0.0
		game_time = max(0.0, game_time - 1.0)
		$GameBackground/UI/WeightInfo/TimeLabel.text = "时间: %d" % int(game_time)
		
		if game_time <= 0:
			game_success = false
			show_ending()
			return
		
	# 处理玩家输入
	var movement = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	
	# 更新玩家位置
	player_position.x += movement.x * player_speed * delta
	player_position.x = clamp(player_position.x, 100, 1050)
	$GameBackground/Player.position.x = player_position.x - 50
	
	# 更新掉落物品生成
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_new_item()
	
	# 更新掉落物品位置
	for item in falling_items:
		if item.node:
			item.position.y += item.speed * delta
			item.node.position = item.position
			
			# 检测是否掉落到底部
			if item.position.y > 600:
				item.node.queue_free()
				falling_items.erase(item)
				break
				
			# 检测是否被接住
			if abs(item.position.x - player_position.x) < 50 and \
			   abs(item.position.y - player_position.y) < 50:
				match item.type:
					ItemType.FOAM, ItemType.WOOD, ItemType.MAGIC:
						current_float_weight += item.value
					ItemType.IRON, ItemType.POT, ItemType.STONE:
						current_stone_weight += item.value
					ItemType.BOMB:
						game_success = false
						show_ending()
						return
					ItemType.TIMER:
						game_time += time_bonus
				
				item.node.queue_free()
				falling_items.erase(item)
				update_weight_display()
				check_balance()
				break

func spawn_new_item():
	var x = randf_range(100, 1050)
	# 获取当前关卡可用物品
	var available_float = LEVEL_CONFIG[current_level].items.float
	var available_heavy = LEVEL_CONFIG[current_level].items.heavy
	
	# 随机选择物品类型
	var rand = randf()
	var type: ItemType
	if rand < 0.40:  # 40% 浮力物品
		type = available_float[randi() % available_float.size()]
	elif rand < 0.80:  # 40% 重力物品
		type = available_heavy[randi() % available_heavy.size()]
	elif rand < 0.95:  # 15% 炸弹
		type = ItemType.BOMB
	else:  # 5% 沙漏
		type = ItemType.TIMER
	
	# 创建物品
	var item = Item.new(Vector2(x, -50), type, ITEM_CONFIG[type].value)
	
	# 创建物品的文字显示
	var item_node = ColorRect.new()
	item_node.color = Color(0.2, 0.2, 0.2, 0.8)
	item_node.custom_minimum_size = Vector2(60, 40)
	
	var label = Label.new()
	label.text = ITEM_CONFIG[type].text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.custom_minimum_size = Vector2(60, 40)
	item_node.add_child(label)
	
	item_node.position = item.position
	item.node = item_node
	
	# 添加到场景
	$GameBackground/FallingItems.add_child(item_node)
	falling_items.append(item)

func update_weight_display():
	# 更新时间显示
	$GameBackground/UI/WeightInfo/TimeLabel.text = "时间: %d" % int(game_time)
	
	# 更新进度条
	var progress = min(1.0, current_stone_weight / target_weight)
	$GameBackground/UI/WeightInfo/StoneProgress.value = progress * 100
	$GameBackground/UI/WeightInfo/StoneLabel.text = "重力: %.1f / %.1f" % [current_stone_weight, target_weight]
	
	progress = min(1.0, current_float_weight / target_weight)
	$GameBackground/UI/WeightInfo/FloatProgress.value = progress * 100
	$GameBackground/UI/WeightInfo/FloatLabel.text = "浮力: %.1f / %.1f" % [current_float_weight, target_weight]

func check_balance():
	if current_stone_weight >= target_weight and \
	   current_float_weight >= target_weight:
		game_success = true
		show_ending()

func show_ending():
	var result_ui = $Result
	
	if not result_ui:
		push_error("Result node not found!")
		return
		
	result_ui.show()  # 显示结果界面
	
	# 设置结果图片
	var result_texture = $Result/ResultTexture
	result_texture.texture = success_texture if game_success else failed_texture
	
	if not game_success:
		# 添加重新开始按钮
		var restart_button = TextureButton.new()
		restart_button.texture_normal = restart_texture
		restart_button.ignore_texture_size = true
		restart_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
		restart_button.custom_minimum_size = Vector2(200, 100)
		restart_button.set_anchors_preset(Control.PRESET_CENTER)
		restart_button.position.y = 100
		restart_button.pressed.connect(func():
			# 清理所有掉落物品
			for item in falling_items:
				if item.node:
					item.node.queue_free()
			falling_items.clear()
			
			# 清理旧按钮
			for child in result_ui.get_children():
				if child is TextureButton:
					child.queue_free()
			
			# 只重置当前关卡的状态
			current_stone_weight = 0
			current_float_weight = 0
			game_time = LEVEL_CONFIG[current_level].time
			spawn_timer = 0.0
			game_success = false
			
			# 更新显示
			update_weight_display()
			# 隐藏结果界面
			$Result.hide()
		)
		result_ui.add_child(restart_button)
		return
	
	# 如果不是最后一关，进入下一关
	if current_level < 3:
		# 添加下一关按钮
		var next_button = TextureButton.new()
		next_button.texture_normal = nextlevel_texture
		next_button.ignore_texture_size = true
		next_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
		next_button.custom_minimum_size = Vector2(200, 100)
		next_button.set_anchors_preset(Control.PRESET_CENTER)
		next_button.position.y = 100
		next_button.pressed.connect(func():
			# 清理所有掉落物品
			for item in falling_items:
				if item.node:
					item.node.queue_free()
			falling_items.clear()
			
			# 清理旧按钮
			for child in result_ui.get_children():
				if child is TextureButton:
					child.queue_free()
			
			await get_tree().create_timer(0.1).timeout  # 短暂延迟让界面更新
			current_level += 1
			reset_game_state()  # 使用统一的重置函数
			game_success = false  # 重置游戏成功状态
			
			# 更新显示
			update_weight_display()
			# 隐藏结果界面
			$Result.hide()
		)
		result_ui.add_child(next_button)
		return
	
	# 最后一关完成，显示结局对话
	await get_tree().create_timer(2.0).timeout  # 显示成功图片 2 秒
	result_ui.hide()  # 只是隐藏而不是销毁
	
	# 准备显示结局对话
	$Background.show()  # 显示主背景
	$Background.modulate = Color(0.3, 0.3, 0.3, 1)  # 调暗背景
	$GameBackground.hide()  # 隐藏游戏界面
	$DialogueUI.show()
			is_showing_ending = true
			ending_dialogue_index = 0
			update_dialogue_display(0)
	update_portrait_modulate(0)

func _input(event):
	if event.is_action_pressed("ui_accept"):
	if is_showing_ending:
		ending_dialogue_index += 1
		if ending_dialogue_index < ending_dialogues.size():
			update_dialogue_display(ending_dialogue_index)
				update_portrait_modulate(ending_dialogue_index)
		else:
				# 结局对话结束后返回目录
			get_tree().change_scene_to_file("res://content.tscn")
