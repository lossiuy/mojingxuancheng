extends Control

var current_stone_weight = 0
var people_weight = 60  # 每个难民60kg
var is_balanced = false
var can_rotate = false
var stone_height = 40
var current_stone_count = 0
var people_count = 2  # 第二章从2个人开始
var current_level = 1
var left_arm = 1
var right_arm = 2  # 第二章开始就是1:2的比例

var dialogue_index = 0
var dialogues = [
	"阿明来到浮光池，发现这里的机关和衡机阁类似...",
	"又是一群被困的难民，他们被绑在杠杆的右端...",
	"黑衣人的声音再次响起：\n\"哼，你果然追来了，不过这次可没那么简单...\"",
	"\"这次的杠杆右力臂是左力臂的两倍，你还能救出他们吗？\"",
	"阿明沉着地说：\"不管机关有多复杂，我一定会救出所有人！\""
]

var ending_dialogues = [
	"浮光池的难民也获救了...",
	"黑衣人的身影再次出现：\n\"哼，这里的确被你救了，但还有更多的地方在等着你...\"",
	"\"去吧，'救世主'，让我看看你能坚持多久！\"",
	"阿明若有所思：这个声音...似乎在哪里听过...",
	"一个获救的难民说：\n\"听说映月潭那边也有很多难民被困，请你一定要去救救他们！\"",
	"阿明点头：\"我这就去映月潭！\""
]

var is_showing_ending = false
var ending_dialogue_index = 0

func _ready():
	# 连接返回按钮信号
	$BackButton.pressed.connect(_on_back_pressed)
	
	# 连接设置相关的信号
	$SetButton.pressed.connect(_on_set_button_pressed)
	$SettingsPanel/CloseButton.pressed.connect(_on_close_button_pressed)
	$SettingsPanel/VolumeControl/VolumeSlider.value_changed.connect(_on_volume_changed)
	
	# 初始化音量滑块的值
	$SettingsPanel/VolumeControl/VolumeSlider.value = 50  # 设置初始音量为50%
	
	# 初始隐藏设置面板
	$SettingsPanel.hide()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")

func _on_set_button_pressed():
	$SettingsPanel.show()

func _on_close_button_pressed():
	$SettingsPanel.hide()

func _on_volume_changed(value):
	# 将滑块值（0-100）转换为分贝值（-80到0）
	# 使用对数曲线使音量变化更自然
	var volume_db = -40.0 * (1.0 - (value / 100.0))
	if value == 0:
		volume_db = -80.0  # 静音
	
	# 设置音频播放器的音量
	AudioManager.set_volume(volume_db)
