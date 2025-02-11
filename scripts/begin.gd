extends Control

func _ready():
	# 连接按钮点击信号
	$ClickArea.pressed.connect(_on_click_area_pressed)
	$SetButton.pressed.connect(_on_set_button_pressed)
	$SettingsPanel/CloseButton.pressed.connect(_on_close_button_pressed)
	$SettingsPanel/VolumeControl/VolumeSlider.value_changed.connect(_on_volume_changed)
	
	# 初始隐藏设置面板
	$SettingsPanel.hide()
	
	# 初始化音量滑块的值
	$SettingsPanel/VolumeControl/VolumeSlider.value = 50  # 设置初始音量为50%

func _on_click_area_pressed():
	if $SettingsPanel.visible:
		return
		
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	
	get_tree().set_meta("from_begin", true)
	AudioManager.change_bgm("res://music/bgm2.mp3")
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
