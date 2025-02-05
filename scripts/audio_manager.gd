extends Node

var bgm_player: AudioStreamPlayer
var current_volume: float = 0.0  # 记录当前音量

func _ready():
    # 创建音频播放器
    bgm_player = AudioStreamPlayer.new()
    add_child(bgm_player)
    
    # 加载并播放BGM
    var bgm = load("res://music/bgm1.mp3")
    bgm_player.stream = bgm
    bgm_player.volume_db = current_volume
    bgm_player.play()

func set_volume(value: float):
    current_volume = value
    bgm_player.volume_db = value

func change_bgm(path: String):
    # 加载新的BGM
    var bgm = load(path)
    bgm_player.stream = bgm
    # 保持当前音量设置
    bgm_player.volume_db = current_volume
    bgm_player.play()