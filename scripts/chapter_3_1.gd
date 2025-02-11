extends Control

# 新增文本数组
var mirror_hall_dialogues = [
    "随着最后一片记忆浮现，迷雾渐渐散去，镜天廊的轮廓显现在眼前。",
    "这里是墨家最神秘的试炼场，传说镜天廊能够映照出人心最深处的真实。无数面镜子折射着光影，仿佛要照进人的灵魂。",
    "阿明，你终于来了。",
    "师兄！为什么要这样做？",
    "想要知道答案，就用你的智慧打开心镜之门吧。"
]

var current_dialogue_index = 0 # 当前对话索引

func _ready():
    # 其他初始化代码...
    $HallBG.visible = true
    $BackButton.pressed.connect(_on_back_pressed)
    # 连接输入事件
    $DialogueUI/DialogueBox.mouse_filter = Control.MOUSE_FILTER_STOP
    $DialogueUI/NarrationText.mouse_filter = Control.MOUSE_FILTER_STOP
    $DialogueUI/DialogueBox.gui_input.connect(_on_dialogue_input)
    $DialogueUI/NarrationText.gui_input.connect(_on_dialogue_input)
    $DialogueUI/DialogueBox/StartButton.pressed.connect(_on_start_game)  # 更新按钮路径
    $DialogueUI/DialogueBox/StartButton.visible=false
    # 开始显示镜天廊的对话
    display_mirror_hall_dialogue()

func _on_back_pressed():
    get_tree().change_scene_to_file("res://content.tscn")

func display_mirror_hall_dialogue():
    # 显示对话框
    $DialogueUI/DialogueBox.show()
    update_dialogue_display(current_dialogue_index)

# 更新对话显示
func update_dialogue_display(index: int):
    var dialogue_text = mirror_hall_dialogues[index]
    $DialogueUI/DialogueBox/DialogueText.text = dialogue_text

    # 根据对话索引更新 speaker_label 和头像
    match index:
        0: # 旁白
            $DialogueUI/NarrationText.text = dialogue_text
            $DialogueUI/NarrationText.show()
            $DialogueUI/DialogueBox.hide()
            $DialogueUI/NarrationText.modulate.a = 0
            var tween = create_tween()
            tween.tween_property($DialogueUI/NarrationText, "modulate:a", 1.0, 1.0)
            await tween.finished
        1: # 旁白
            $DialogueUI/NarrationText.text = dialogue_text
            $DialogueUI/NarrationText.show()
            $DialogueUI/DialogueBox.hide()
            $DialogueUI/NarrationText.modulate.a = 0
            var tween = create_tween()
            tween.tween_property($DialogueUI/NarrationText, "modulate:a", 1.0, 1.0)
            await tween.finished
        2: # 师兄
            $DialogueUI/NarrationText.hide()
            $DialogueUI/DialogueBox.show()
            $DialogueUI/DialogueBox/SpeakerName.text = "师兄"
            $DialogueUI/DialogueBox/MingPortrait.visible = false
            $DialogueUI/DialogueBox/BlackmanPortrait.visible = true
        3: # 师兄
            $DialogueUI/NarrationText.hide()
            $DialogueUI/DialogueBox.show()
            $DialogueUI/DialogueBox/SpeakerName.text = "阿明"
            $DialogueUI/DialogueBox/MingPortrait.visible = true
            $DialogueUI/DialogueBox/BlackmanPortrait.visible = false
        4: # 师兄
            $DialogueUI/NarrationText.hide()
            $DialogueUI/DialogueBox.show()
            $DialogueUI/DialogueBox/SpeakerName.text = "师兄"
            $DialogueUI/DialogueBox/MingPortrait.visible = false
            $DialogueUI/DialogueBox/BlackmanPortrait.visible = true
            $DialogueUI/DialogueBox/StartButton.visible = true

# 输入处理
func _on_dialogue_input(event: InputEvent):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if current_dialogue_index < mirror_hall_dialogues.size() - 1:
            current_dialogue_index += 1
            update_dialogue_display(current_dialogue_index)
        else:
            # 对话结束后隐藏UI并开始交互
            $DialogueUI/DialogueBox.hide()

func _on_start_game():
    $RotatableMirror.visible = true
    $RotatableMirror.modulate.a = 0
    var tween = create_tween()
    tween.tween_property($RotatableMirror, "modulate:a", 1.0, 1.0)
    await tween.finished
   