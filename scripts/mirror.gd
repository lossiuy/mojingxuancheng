extends Area2D

const ROTATION_ANGLE = deg_to_rad(5)  # 每次旋转10度
const HIGHLIGHT_COLOR = Color(1, 1, 0.5, 1)  # 高亮颜色
const NORMAL_COLOR = Color(1, 1, 1, 1)  # 正常颜色

func _ready():
    input_pickable = true
    print("Mirror ready at position: ", position)
    print("Mirror parent: ", get_parent().name)
    print("Process mode: ", process_mode)
    print("Mirror scene: ", get_tree().current_scene.name)
    print("Mirror input pickable: ", input_pickable)
    # 检查信号是否已连接
    if not mouse_entered.is_connected(_on_mouse_entered):
        mouse_entered.connect(_on_mouse_entered)
    if not mouse_exited.is_connected(_on_mouse_exited):
        mouse_exited.connect(_on_mouse_exited)
    if not input_event.is_connected(_on_mirror_clicked):
        input_event.connect(_on_mirror_clicked)
    print("Signals connected")
    # 设置初始颜色
    $Sprite2D.modulate = NORMAL_COLOR

func _on_mirror_clicked(_viewport, event: InputEvent, _shape_idx):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        print("Mirror clicked at position: ", position)
        print("Mouse position: ", event.position)
        print("Mirror global position: ", global_position)
        print("Mirror local position: ", position)

        # 将鼠标点击位置转换为镜子的局部坐标
        var local_mouse_position = to_local(event.position)

        # 判断鼠标点击位置
        if local_mouse_position.x < 0:
            # 点击在左侧，逆时针旋转
            rotation -= ROTATION_ANGLE
        else:
            # 点击在右侧，顺时针旋转
            rotation += ROTATION_ANGLE

# 获取镜子的反射法线
func get_reflection_normal() -> Vector2:
    var mirror_right = Vector2.RIGHT.rotated(rotation)
    return mirror_right.rotated(PI / 2)  # 确保法线是正确的

func _on_mouse_entered():
    print("Mouse entered mirror at position: ", position)
    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
    # 高亮效果
    var tween = create_tween()
    tween.tween_property($Sprite2D, "modulate", HIGHLIGHT_COLOR, 0.2)

func _on_mouse_exited():
    print("Mouse exited mirror at position: ", position)
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    # 恢复正常颜色
    var tween = create_tween()
    tween.tween_property($Sprite2D, "modulate", NORMAL_COLOR, 0.2) 