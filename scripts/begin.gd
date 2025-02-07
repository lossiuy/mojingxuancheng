extends Control

func _ready():
	# 连接按钮点击信号
	$ClickArea.pressed.connect(_on_click_area_pressed)
	$SetButton.pressed.connect(_on_set_button_pressed)
	$SettingsPanel/CloseButton.pressed.connect(_on_close_button_pressed)
	$SettingsPanel/VolumeControl/VolumeSlider.value_changed.connect(_on_volume_changed)
	
	# 初始隐藏设置面板
	$SettingsPanel.hide()
	
	# 加载字体
	var font = load("res://方正榜书行简体.ttf")
	
	# 设置按钮字体
	$SetButton.add_theme_font_override("font", font)
	$SetButton.add_theme_font_size_override("font_size", 32)  # 增大字号
	
	$SettingsPanel/CloseButton.add_theme_font_override("font", font)
	$SettingsPanel/CloseButton.add_theme_font_size_override("font_size", 32)  # 增大字号

func _on_click_area_pressed():
	if $SettingsPanel.visible:
		return
		
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	
	AudioManager.change_bgm("res://music/bgm2.mp3")
	get_tree().set_meta("from_begin", true)  # 设置元数据
	get_tree().change_scene_to_file("res://content.tscn")

func _on_set_button_pressed():
	$SettingsPanel.show()

func _on_close_button_pressed():
	$SettingsPanel.hide()

func _on_volume_changed(value):
	var volume = -80.0 if value == 0 else (value - 100)
	AudioManager.bgm_player.volume_db = value

func _on_start_pressed():
	# 使用参数传递方式切换场景
	get_tree().change_scene_to_packed(preload("res://content.tscn"))
	# 设置全局参数
	get_node("/root/Global").from_begin = true
