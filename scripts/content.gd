extends Control

# 添加一个自动加载的单例类来保存全局状态
const SAVE_PATH = "user://story_shown.save"
var story_shown = false

var story_texts = [
	"\"天志有衡，地载有浮，光行无碍。\" ——《墨经》",
	
	"墨家，以\"兼爱非攻\"为信仰，以机关术护天下苍生。\n墨者不仅精通机关奇技，更研习自然之理：",
	
	"机关城有三大试炼场：衡机阁，悟杠杆之理，明平衡之道。\n浮光池，探浮力奥秘，晓共济之义。\n镜天廊，识光之反射，辨虚实之界。",
	
	"然而，机关城陷入危机。\n传闻黑衣人出没，劫掠粮仓，袭击百姓。\n更可怕的是，他似乎深谙机关术，能轻易破解墨家防御！",
	
	"阿明，墨家年轻弟子，天资聪颖，深得师父器重。\n面对机关城的危机，他主动请缨，要以机关术拯救百姓。",
	
	"师父对墨家弟子阿明嘱咐到：\"机关之术，可救世，亦可伤人。\n此行，你不仅要解开机关之谜，更要寻回墨家真正的信仰。\"",
	
	"就这样，阿明背起行囊，踏上试炼之路。"
]

var current_story_index = 0

func _ready():
	# 检查元数据
	var from_begin = get_tree().has_meta("from_begin") and get_tree().get_meta("from_begin")
	# 清除元数据，避免影响后续使用
	if get_tree().has_meta("from_begin"):
		get_tree().remove_meta("from_begin")
	
	if from_begin:
		# 显示前情提要
		$Background.modulate = Color(0.3, 0.3, 0.3, 1)  # 暗化背景
		$Chapter1.hide()
		$Chapter2.hide()
		$Chapter3.hide()
		$BackButton.hide()
		
		# 显示第一个分镜
		current_story_index = 0
		$StoryText.text = story_texts[0]
		$StoryText.show()
	else:
		# 直接显示关卡选择界面
		$StoryText.hide()
		$Background.modulate = Color(1, 1, 1, 1)  # 正常背景
		$Chapter1.show()
		$Chapter2.show()
		$Chapter3.show()
		$BackButton.show()
	
	# 连接信号
	$StoryText.gui_input.connect(_on_story_input)
	$BackButton.pressed.connect(_on_back_pressed)
	$Chapter1.pressed.connect(_on_chapter1_pressed)
	$Chapter2.pressed.connect(_on_chapter2_pressed)
	$Chapter3.pressed.connect(_on_chapter3_pressed)

func _on_story_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_story_index < story_texts.size() - 1:
			current_story_index += 1
			$StoryText.text = story_texts[current_story_index]
		else:
			# 显示关卡选择界面
			$StoryText.hide()
			# 恢复背景亮度
			var tween = create_tween()
			tween.tween_property($Background, "modulate", Color(1, 1, 1, 1), 0.5)
			# 显示关卡选择按钮
			$Chapter1.show()
			$Chapter2.show()
			$Chapter3.show()
			$BackButton.show()

func load_story_state():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		story_shown = file.get_var()

func save_story_state():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(story_shown)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://begin.tscn")

func _on_chapter1_pressed():
	get_tree().change_scene_to_file("res://chapter1.tscn")

func _on_chapter2_pressed():
	# 待实现
	pass

func _on_chapter3_pressed():
	# 待实现
	pass 
