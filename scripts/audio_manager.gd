extends Node

var bgm_player: AudioStreamPlayer
var current_volume: float = 0.0  # 记录当前音量

func _ready():
    # 创建音频播放器
    bgm_player = AudioStreamPlayer.new()
    add_child(bgm_player)
    bgm_player.bus = "Music"  # 使用专门的音乐音频总线
    
    # 加载并播放BGM
    var bgm = load("res://music/bgm1.mp3")
    bgm_player.stream = bgm
    bgm_player.volume_db = current_volume
    bgm_player.play()

func set_volume(volume_db: float):
    # 限制音量范围
    volume_db = clamp(volume_db, -80.0, 0.0)
    current_volume = volume_db
    bgm_player.volume_db = volume_db

func change_bgm(path: String):
    var audio_stream = load(path)
    if audio_stream:
        bgm_player.stream = audio_stream
        bgm_player.play()