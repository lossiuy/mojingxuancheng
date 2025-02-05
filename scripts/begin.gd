extends Control

func _ready():
	# 连接按钮点击信号
	$ClickArea.pressed.connect(_on_click_area_pressed)
	$SetButton.pressed.connect(_on_set_button_pressed)
	$SettingsPanel/CloseButton.pressed.connect(_on_close_button_pressed)
	$SettingsPanel/VolumeControl/VolumeSlider.value_changed.connect(_on_volume_changed)
	
	# 初始隐藏设置面板
	$SettingsPanel.hide()

func _on_click_area_pressed():
	if $SettingsPanel.visible:
		return
		
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	
	AudioManager.change_bgm("res://music/bgm2.mp3")
	get_tree().change_scene_to_file("res://content.tscn")

func _on_set_button_pressed():
	$SettingsPanel.show()

func _on_close_button_pressed():
	$SettingsPanel.hide()

func _on_volume_changed(value):
	var volume = -80.0 if value == 0 else (value - 100)
	AudioManager.bgm_player.volume_db = value
