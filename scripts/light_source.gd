extends Node2D

@export var light_color: Color = Color(1, 0.9, 0.7, 1)
@export var light_energy: float = 1.0

func _ready():
    # 添加光源视觉效果
    var light = PointLight2D.new()
    # 创建一个简单的渐变纹理
    var gradient = GradientTexture2D.new()
    gradient.width = 50
    gradient.height = 128
    gradient.fill = GradientTexture2D.FILL_RADIAL
    gradient.fill_from = Vector2(0.5, 0.5)
    light.texture = gradient
    light.color = light_color
    light.energy = light_energy
    add_child(light)

func _draw():
    draw_rect(Rect2(-5, -5, 10, 10), Color.YELLOW)  # 绘制一个10x10的黄色方块 