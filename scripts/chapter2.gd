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

func _on_back_pressed():
	get_tree().change_scene_to_file("res://content.tscn")
