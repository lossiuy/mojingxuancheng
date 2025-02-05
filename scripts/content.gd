extends Control

func _ready():
	# 连接按钮信号
	$Chapter1.pressed.connect(_on_chapter1_pressed)
	$Chapter2.pressed.connect(_on_chapter2_pressed)
	$Chapter3.pressed.connect(_on_chapter3_pressed)
	$BackButton.pressed.connect(_on_back_pressed)

func _on_chapter1_pressed():
	get_tree().change_scene_to_file("res://chapter1.tscn")

func _on_chapter2_pressed():
	get_tree().change_scene_to_file("res://chapter2.tscn")

func _on_chapter3_pressed():
	get_tree().change_scene_to_file("res://chapter3.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://begin.tscn") 
