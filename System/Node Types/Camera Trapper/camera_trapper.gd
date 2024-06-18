@tool
class_name CameraTrapper2D
extends Area2D

var phantom_camera : PhantomCamera2D

func _process(delta):
	if Engine.is_editor_hint():
		if phantom_camera == null:
			return
		phantom_camera.tween_on_load = false

func _ready():
	for f in get_children(true):
		if f is PhantomCamera2D:
			phantom_camera = f
			pass
	if phantom_camera == null:
		return
	body_entered.connect(_on_body_entered, 1)
	body_exited.connect(_on_body_exited, 1)

func _on_body_entered(body:Node2D):
	if phantom_camera == null:
		return
	
	if body is Player and not phantom_camera.priority == 1:
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		phantom_camera.priority = 1
		body.process_mode = Node.PROCESS_MODE_DISABLED
		tween.tween_property(body, "position", clamp_position(body.position), 1.0)
		await tween.finished
		body.process_mode = Node.PROCESS_MODE_INHERIT

func _on_body_exited(body:Node2D):
	if phantom_camera == null:
		return
	
	if body is Player:
		phantom_camera.priority = 0



func get_shape_rect(shape:CollisionShape2D) -> Rect2:
	var rect = shape.shape.get_rect()
	rect.position += shape.position
	return rect

func get_bounding_rect() -> Rect2:
	var rect = null
	for f in get_children():
		if not f is CollisionShape2D:
			break
		if rect == null:
			var tmp = get_shape_rect(f)
			rect = tmp
		else:
			var tmp = get_shape_rect(f)
			rect = rect.merge(tmp)
	return rect

func clamp_position(value:Vector2, shrink:float = 16.0) -> Vector2:
	var rect = get_bounding_rect()
	rect = rect.grow(-shrink)
	return value.clamp(to_global(rect.position), to_global(rect.end))
