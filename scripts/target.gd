extends Area2D

var is_lit = false

@onready var point_light: PointLight2D

func _ready():
    # 初始化发光效果
    var glow = PointLight2D.new()
    var gradient = GradientTexture2D.new()
    gradient.width = 128
    gradient.height = 128
    gradient.fill = GradientTexture2D.FILL_RADIAL
    gradient.fill_from = Vector2(0.5, 0.5)
    glow.texture = gradient
    glow.color = Color(1, 1, 0.8, 0.8)
    glow.energy = 0.0
    add_child(glow)
    point_light = glow

    print("Target ready, collision_layer: ", collision_layer, ", collision_mask: ", collision_mask)
    print("Target position: ", global_position)

func hit_by_light():
    if not is_lit:
        print("Target hit by light!")
        is_lit = true
        $ColorRect.color = Color(0.2, 1, 0.2, 0.5)
        var tween = create_tween()
        tween.tween_property(point_light, "energy", 1.0, 0.3)
        get_node("/root/Chapter3-1").check_level_complete() 