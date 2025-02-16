extends Node2D

var ray_length = 1000
const MAX_REFLECTIONS = 5  # 最大反射次数

func cast_light(start_pos: Vector2, direction: Vector2) -> Array:
    var points = [start_pos]
    var current_pos = start_pos
    var current_dir = direction
    var reflection_count = 0
    
    while reflection_count < MAX_REFLECTIONS:
        var space_state = get_world_2d().direct_space_state
        var query = PhysicsRayQueryParameters2D.create(current_pos, current_pos + current_dir * ray_length)
        query.collision_mask = 24  # 同时检测反射层(8)和目标层(16)
        query.collide_with_areas = true  # 确保可以与 Area2D 碰撞
        var result = space_state.intersect_ray(query)
        
        if result:
            points.append(result.position)
            var mirror = result.collider
            if mirror.is_in_group("mirrors"):  # 检查是否是镜子
                var normal = mirror.get_reflection_normal()
                current_dir = current_dir.bounce(normal)
                current_pos = result.position
                reflection_count += 1
            elif mirror.is_in_group("targets"):  # 检查是否是目标
                # 到达目标就停止光线
                break
            else:
                break
        else:
            points.append(current_pos + current_dir * ray_length)
            break
    
    return points 