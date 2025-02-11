extends Control

# 入口区域状态
var collected_fragments := 0
var total_fragments := 3
var dialogue_index := 0  # 新增对话索引
var entrance_dialogues = [
	{
		"text": [
			"那是初入墨家的时光，师兄教导阿明研习机关术。",
			"师兄：\"阿明，记住，机关术不是为了伤人，而是为了守护。\"",
			"阿明：\"是的，师兄！\""
		]
	},
	{
		"text": [
			"在工坊里，师兄和阿明一起研究新的机关。",
			"师兄：\"看，这个装置能帮助百姓吊水灌溉。\"",
			"阿明：\"师兄总是想着如何帮助他人。\""
		]
	},
	{
		"text": [
			"那时的师兄，眼中还充满希望。",
			"师兄：\"墨家的兼爱之道，就是让天下人都能互帮互助。\"",
			"阿明：\"我一定会和师兄一起实现这个理想！\""
		]
	}
]

# 对话内容数组
var dialogues = [
	"好浓的雾，穿过这片雾应该就能到达镜天廊了。只是这雾太浓，稍有不慎可能会跌落悬崖......",
	"咦，迷雾中好像有一些闪闪发光的东西，好像是......镜子的碎片？拾起观察一下，也许会有所发现。"
]

@onready var entrance := $Entrance
@onready var mirror_hall := $MirrorHall
@onready var fog1 := $Entrance/FogOverlay1
@onready var fog2 := $Entrance/FogOverlay2
@onready var fog3 := $Entrance/FogOverlay3
@onready var fragment1 := $Entrance/Fragment1
@onready var fragment2 := $Entrance/Fragment2
@onready var fragment3 := $Entrance/Fragment3
@onready var dialogue_ui := $DialogueUI
@onready var memory1 := $Entrance/Memory1
@onready var memory2 := $Entrance/Memory2
@onready var memory3 := $Entrance/Memory3

# 加载字体
var font = load("res://方正榜书行简体.ttf")

enum GameState {
	STATE_NORMAL,
	STATE_MIRROR_HALL,
	STATE_DIALOGUE
}

var current_state = GameState.STATE_NORMAL

func _ready():
	# 初始化状态
	entrance.visible = true
	mirror_hall.visible = false
	fog1.visible = true
	fog2.visible = true
	fog3.visible = true
	fragment1.visible = true
	fragment2.visible = true
	fragment3.visible = true
	
	dialogue_ui.visible = false
	$BackButton.pressed.connect(_on_back_pressed)
	$DialogueUI/DialogueBox/StartButton.visible = false
	# 初始化输入处理
	$DialogueUI/DialogueBox.mouse_filter = Control.MOUSE_FILTER_STOP
	$DialogueUI/NarrationText.mouse_filter = Control.MOUSE_FILTER_STOP
	$DialogueUI/DialogueBox.gui_input.connect(_on_dialogue_input)
	$DialogueUI/NarrationText.gui_input.connect(_on_dialogue_input)

	# 隐藏回忆图片
	memory1.visible = false
	memory2.visible = false
	memory3.visible = false

	show_background_and_narration()

func show_background_and_narration():
	await get_tree().create_timer(1.0).timeout
	show_narration("镜天廊的入口被迷雾笼罩，破碎的镜片散落一地，每一片都映照着过去的影子……")

func show_narration(text: String):
	dialogue_ui.visible = true
	dialogue_ui.get_node("ColorRect").show()
	dialogue_ui.get_node("DialogueBox").hide()  # 隐藏对话框
	dialogue_ui.get_node("NarrationText").text = text
	dialogue_ui.get_node("NarrationText").show()
	
	# 渐显渐隐动画
	var tween = create_tween()
	tween.tween_property(dialogue_ui.get_node("NarrationText"), "modulate:a", 1.0, 1.0)
	await tween.finished
	
	# 等待一段时间后隐藏 NarrationText
	await get_tree().create_timer(2.0).timeout
	tween = create_tween()
	tween.tween_property(dialogue_ui.get_node("NarrationText"), "modulate:a", 0.0, 1.0)
	await tween.finished

	show_dialogue_box()
	

func show_dialogue_box():
	dialogue_index = 0  # 重置对话索引
	dialogue_ui.get_node("DialogueBox").show()
	update_dialogue_display(0)  # 显示第一条对话

# 新增统一对话更新方法
func update_dialogue_display(index: int):
	if index < dialogues.size():
		dialogue_ui.get_node("DialogueBox/DialogueText").text = dialogues[index]
		dialogue_ui.get_node("DialogueBox/DialogueText").modulate.a = 1
		$DialogueUI/DialogueBox/MingPortrait.visible = true
		$DialogueUI/DialogueBox/BlackmanPortrait.visible = false

# 输入处理统一方法
func _on_dialogue_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if dialogue_index < dialogues.size() - 1:
			dialogue_index += 1
			update_dialogue_display(dialogue_index)
		else:
			# 对话结束后隐藏UI并开始交互
			dialogue_ui.visible = false
			start_fragment_interaction()

func start_fragment_interaction():
	# 显示镜子碎片（只显示未被点击过的）
	for i in range(1, total_fragments + 1):
		var fragment = entrance.get_node("Fragment%d" % i)
		# 只显示未被点击的碎片
		if !is_fragment_collected(i-1):
			fragment.visible = true
		# 先断开之前的连接，避免重复连接
		if fragment.pressed.is_connected(_on_fragment_clicked.bind(i-1)):
			fragment.pressed.disconnect(_on_fragment_clicked.bind(i-1))
		fragment.pressed.connect(_on_fragment_clicked.bind(i-1))

# 新增判断函数
func is_fragment_collected(index: int) -> bool:
	match index:
		0: return !fragment1.visible
		1: return !fragment2.visible
		2: return !fragment3.visible
	return false

func _on_fragment_clicked(index):
	collected_fragments += 1
	# 显示对应的回忆图片
	match index:
		0:
			memory1.visible = true
			show_dialogue(entrance_dialogues[index]["text"], index)
		1:
			memory2.visible = true
			show_dialogue(entrance_dialogues[index]["text"], index)
		2:
			memory3.visible = true
			show_dialogue(entrance_dialogues[index]["text"], index)

# 修改 show_dialogue 函数以逐句显示对话
func show_dialogue(text: Array, index: int):
	dialogue_ui.visible = true
	dialogue_ui.get_node("DialogueBox").show()  # 确保对话框可见
	dialogue_ui.get_node("DialogueBox/DialogueText").text = ""  # 清空文本
	$DialogueUI/DialogueBox/SpeakerName.text = "阿明的回忆"
	$DialogueUI/DialogueBox/MingPortrait.visible = false
	$DialogueUI/DialogueBox/BlackmanPortrait.visible = false

	# 逐段显示对话
	for line in text:
		dialogue_ui.get_node("DialogueBox/DialogueText").text = line
		await get_tree().create_timer(1.0).timeout
		# 等待用户点击事件
		#await wait_for_left_click()  # 等待用户点击以显示下一句

	# 隐藏对话框和记忆图片
	dialogue_ui.get_node("DialogueBox").hide()
	dialogue_ui.visible = false  # 完全隐藏对话框UI

	# 隐藏对应的迷雾和碎片
	match index:
		0:
			fog1.visible = false
			fragment1.visible = false
			memory1.visible = false
		1:
			fog2.visible = false
			fragment2.visible = false
			memory2.visible = false
		2:
			fog3.visible = false
			fragment3.visible = false
			memory3.visible = false
		3:
			pass  # 直接留空

	# 检查是否所有碎片都被点击
	if collected_fragments == total_fragments:
		enter_mirror_hall()

# 异步函数：等待鼠标左键点击
func wait_for_left_click():
	while true:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			break
		await get_tree().process_frame

func enter_mirror_hall():
	entrance.visible = false
	mirror_hall.visible = true
	get_tree().change_scene_to_file("res://chapter_3_1.tscn")
	# $MirrorHall/RotatableMirror.visible = false
	# var tween = create_tween()
	# mirror_hall.modulate.a = 0
	# tween.tween_property(mirror_hall, "modulate:a", 1.0, 1.0)
	# await tween.finished
	
	# 直接调用处理镜天廊逻辑的函数
	#handle_mirror_hall_logic()

# 新增函数：处理镜天廊的逻辑
func handle_mirror_hall_logic():
	print("handle_mirror_hall_logic 被调用")  # 调试信息
	#show_narration("迷雾散尽，镜天廊的真相浮现——千百面镜子交织成网，每一面都映照着阿明与师兄的过去与未来。",1)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")

	

	


