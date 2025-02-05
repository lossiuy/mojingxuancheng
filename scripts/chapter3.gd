extends Control

var current_stone_weight = 0
var people_weight = 60  # 每个难民60kg
var is_balanced = false
var can_rotate = false
var stone_height = 40
var current_stone_count = 0
var people_count = 3  # 第三章从3个人开始
var current_level = 1
var left_arm = 3  # 第三章开始就是3:1的比例
var right_arm = 1

var dialogue_index = 0
var dialogues = [
	"阿明终于来到映月潭，发现这里的机关更加诡异...",
	"难民们被困在更高的位置，情况更加危急...",
	"黑衣人冷笑道：\n\"这次的杠杆可不一样，左力臂是右力臂的三倍...\"",
	"\"就算你懂得力臂原理，这次的计算也没那么容易了吧？\"",
	"阿明坚定地说：\"不管比例如何，我都会找到正确的平衡点！\""
]

var ending_dialogues = [
	"映月潭的难民终于获救了...",
	"黑衣人再次现身：\n\"有点本事，但这还远远不够...\"",
	"\"你以为这就结束了吗？哈哈哈...\"",
	"这次阿明终于认出了这个声音：\n\"是你！为什么要这么做？\"",
	"黑衣人冷笑：\"想知道真相？那就继续追寻下去吧！\"",
	"一位老者颤抖着说：\n\"谢谢你救了我们，但我听说悬崖谷那边情况更加危急...\"",
	"阿明握紧拳头：\"我一定会找出真相，也一定会救出所有人！\""
]

var is_showing_ending = false
var ending_dialogue_index = 0

func _ready():
	# 连接返回按钮信号
	$BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")