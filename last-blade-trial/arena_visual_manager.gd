extends Node2D

# =========================
# ArenaVisualManager.gd
# สร้างฉากหลัง / พื้นสนาม / หมอก / เถ้าถ่าน
# ตอนนี้รองรับภาพ BG จริงจาก asset แล้ว และยังเก็บฉาก procedural เป็น fallback
# ไฟล์นี้ไม่แตะระบบต่อสู้ จึงปลอดภัยกับ Phase 9 Vertical Slice
# =========================

# เปิด/ปิดภาพฉากหลังทั้งหมด
@export var visual_enabled: bool = true

# เปิดใช้ภาพฉากหลังจริงจากไฟล์ asset
@export var use_background_texture: bool = true

# path ของ BG ธรรมดารอบแรก สำหรับ Moonlit Broken Dojo
@export_file("*.png") var background_texture_path: String = "res://assets/backgrounds/moonlit_broken_dojo/bg1.png"

# วาด BG เป็น screen-space เต็มจอ เพื่อให้เห็นแน่นอนและไม่ติดปัญหา world/camera/z sorting
@export var use_screen_space_background: bool = true

# layer ติดลบเพื่อให้ BG อยู่หลัง gameplay layer ปกติ
@export var background_canvas_layer: int = -100

# z_index ใช้เฉพาะกรณีปิด use_screen_space_background แล้ววาดเป็น Sprite2D ใน world space
@export var background_texture_z_index: int = -500

# สีทับภาพ BG ปกติใช้ขาวล้วน ถ้าต้องการทำ Trial มืดลงในอนาคตค่อยปรับ modulate ตรงนี้
@export var background_texture_modulate: Color = Color.WHITE

# ใช้ nearest filter เพื่อให้ pixel art ไม่เบลอเมื่อถูก scale
@export var background_texture_use_nearest_filter: bool = true

# บังคับให้ BG ทึบ เผื่อไฟล์ PNG มี alpha โปร่งใสโดยไม่ตั้งใจ
@export var force_background_texture_opaque: bool = true

# ถ้า BG โหลดไม่ได้ ให้กลับไปสร้างฉาก procedural เดิมแทน เพื่อไม่ให้ฉากว่าง
@export var use_procedural_background_when_texture_missing: bool = true

# รอบแรกให้ภาพ BG สะอาดก่อน ถ้าอยากซ้อนหมอก/เถ้าถ่านจากโค้ดค่อยเปิดภายหลัง
@export var add_atmosphere_over_background_texture: bool = false

# ตำแหน่งกึ่งกลางฉากหลักตอนนี้ กล้องหลักอยู่แถว 576,324
@export var arena_center: Vector2 = Vector2(576.0, 324.0)

# ขนาดพื้นที่วาดฉากหลัง เผื่อขอบจอและกล้องสั่น
@export var arena_visual_size: Vector2 = Vector2(1500.0, 820.0)

# ระดับพื้นสนามใกล้เท้าบอส/ผู้เล่นในฉากหลักปัจจุบัน
@export var ground_y: float = 356.0

# จำนวนเถ้าถ่านลอยในฉาก ใช้ไม่เยอะเพื่อให้มือถือยังเบา
@export var ember_count: int = 22

# สีบรรยากาศหลักแบบดาร์กแฟนตาซี ใช้กับฉาก procedural fallback
@export var sky_top_color: Color = Color(0.035, 0.045, 0.075, 1.0)
@export var sky_mid_color: Color = Color(0.075, 0.065, 0.105, 1.0)
@export var sky_bottom_color: Color = Color(0.12, 0.085, 0.075, 1.0)
@export var moon_color: Color = Color(1.0, 0.78, 0.45, 0.88)
@export var ground_color: Color = Color(0.055, 0.045, 0.05, 1.0)
@export var ground_edge_color: Color = Color(0.82, 0.58, 0.24, 0.72)
@export var fog_color: Color = Color(0.64, 0.78, 0.92, 0.13)
@export var ember_color: Color = Color(1.0, 0.48, 0.16, 0.72)


func _ready() -> void:
	# รอให้ scene หลักพร้อมก่อน แล้วค่อยสร้างภาพฉากหลัง
	if not visual_enabled:
		return

	randomize()
	create_arena_visuals.call_deferred()


func create_arena_visuals() -> void:
	# ล้างของเก่าก่อน เผื่อ reload scene แล้วไม่ซ้อนกัน
	for child in get_children():
		child.queue_free()

	var background_texture_created := create_background_texture_if_enabled()
	if background_texture_created:
		# ถ้าใช้ภาพ BG จริงแล้ว รอบแรกไม่สร้างฉาก procedural ทับ เพื่อดูภาพ asset ให้ชัด
		if add_atmosphere_over_background_texture:
			create_fog_lines()
			create_embers()
		return

	if use_procedural_background_when_texture_missing:
		create_procedural_arena_visuals()


func create_background_texture_if_enabled() -> bool:
	# โหลดภาพ BG จริงจาก asset และเลือกวิธีวาดที่เสถียรที่สุดสำหรับฉากปัจจุบัน
	if not use_background_texture:
		return false

	var texture := load(background_texture_path)
	if not texture is Texture2D:
		print("Arena BG texture not found or invalid: ", background_texture_path)
		return false

	var texture_size: Vector2 = texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		print("Arena BG texture has invalid size: ", background_texture_path)
		return false

	if use_screen_space_background:
		create_screen_space_background(texture, texture_size)
	else:
		create_world_space_background(texture, texture_size)

	return true


func create_screen_space_background(texture: Texture2D, texture_size: Vector2) -> void:
	# ใช้ CanvasLayer ติดลบ + TextureRect เต็มจอ เพื่อให้ BG แสดงหลัง gameplay อย่างแน่นอน
	var layer := CanvasLayer.new()
	layer.name = "BackgroundCanvasLayer"
	layer.layer = background_canvas_layer
	add_child(layer)

	var texture_rect := TextureRect.new()
	texture_rect.name = "BackgroundTextureRect"
	texture_rect.texture = texture
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_rect.offset_left = 0.0
	texture_rect.offset_top = 0.0
	texture_rect.offset_right = 0.0
	texture_rect.offset_bottom = 0.0
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	texture_rect.modulate = background_texture_modulate

	if background_texture_use_nearest_filter:
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if force_background_texture_opaque:
		texture_rect.material = create_force_opaque_texture_material()

	layer.add_child(texture_rect)
	print(
		"Arena BG screen texture loaded: ", background_texture_path,
		" size = ", texture_size,
		" canvas_layer = ", layer.layer,
		" stretch = keep_aspect_covered",
		" force_opaque = ", force_background_texture_opaque
	)


func create_world_space_background(texture: Texture2D, texture_size: Vector2) -> void:
	# โหมดสำรองสำหรับอนาคต หากต้องการให้ BG อยู่ใน world space เพื่อทำ parallax/manual camera work
	var background_sprite := Sprite2D.new()
	background_sprite.name = "BackgroundTexture"
	background_sprite.texture = texture
	background_sprite.centered = true
	background_sprite.position = arena_center
	background_sprite.z_index = background_texture_z_index
	# ใช้ z แบบ absolute เพื่อไม่ให้ลำดับ parent/child ทำให้ภาพ BG ถูกวาดผิดชั้น
	background_sprite.z_as_relative = false
	background_sprite.visible = true
	background_sprite.modulate = background_texture_modulate

	if background_texture_use_nearest_filter:
		background_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	if force_background_texture_opaque:
		background_sprite.material = create_force_opaque_texture_material()

	# ใช้ cover scale เพื่อไม่ให้เห็นขอบว่างบนมือถือจอกว้างหรือขณะกล้องสั่น
	var cover_scale: float = max(arena_visual_size.x / texture_size.x, arena_visual_size.y / texture_size.y)
	background_sprite.scale = Vector2(cover_scale, cover_scale)

	add_child(background_sprite)
	print(
		"Arena BG world texture loaded: ", background_texture_path,
		" size = ", texture_size,
		" scale = ", cover_scale,
		" position = ", background_sprite.position,
		" z = ", background_sprite.z_index,
		" absolute_z = ", not background_sprite.z_as_relative,
		" force_opaque = ", force_background_texture_opaque
	)


func create_force_opaque_texture_material() -> ShaderMaterial:
	# เผื่อ PNG ถูก export มาพร้อม alpha โปร่งใส ให้ใช้สี RGB ของภาพและบังคับ alpha เป็น 1
	var shader := Shader.new()
	shader.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec4 tex = texture(TEXTURE, UV);\n\tCOLOR = vec4(tex.rgb, 1.0) * COLOR;\n}\n"

	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func create_procedural_arena_visuals() -> void:
	# ฉากเดิมที่สร้างด้วยโค้ด เก็บไว้เป็น fallback เมื่อยังไม่มี asset หรือ asset โหลดไม่ได้
	create_sky_bands()
	create_moon()
	create_distant_mountains()
	create_broken_gate()
	create_arena_floor()
	create_blade_shadows()
	create_fog_lines()
	create_embers()


func create_sky_bands() -> void:
	# ใช้แถบสีซ้อนกันแทน gradient เพื่อให้รองรับ Godot ง่ายและเบาบนมือถือ
	var top_left: Vector2 = arena_center - arena_visual_size * 0.5
	var band_height: float = arena_visual_size.y / 3.0

	create_rect_polygon("SkyTop", top_left, Vector2(arena_visual_size.x, band_height + 8.0), sky_top_color, -500)
	create_rect_polygon("SkyMid", top_left + Vector2(0.0, band_height), Vector2(arena_visual_size.x, band_height + 8.0), sky_mid_color, -499)
	create_rect_polygon("SkyBottom", top_left + Vector2(0.0, band_height * 2.0), Vector2(arena_visual_size.x, band_height + 8.0), sky_bottom_color, -498)


func create_moon() -> void:
	# ดวงจันทร์แตกหลังบอส ช่วยเพิ่ม mood แบบดาบไร้นาม
	var moon := create_ellipse_polygon("BrokenMoon", arena_center + Vector2(260.0, -170.0), Vector2(56.0, 56.0), moon_color, 36, -470)
	moon.modulate.a = 0.82

	# รอยแหว่งของดวงจันทร์ ใช้สีเดียวกับท้องฟ้าทับบางส่วน
	create_ellipse_polygon("MoonBite", arena_center + Vector2(284.0, -185.0), Vector2(28.0, 34.0), sky_top_color, 28, -469)

	# เส้นแสงบาง ๆ รอบดวงจันทร์
	var halo := create_ellipse_polygon("MoonHalo", arena_center + Vector2(260.0, -170.0), Vector2(92.0, 92.0), Color(1.0, 0.72, 0.38, 0.10), 40, -471)
	halo.modulate.a = 0.65


func create_distant_mountains() -> void:
	# ภูเขา/ซากวัดด้านหลัง ทำให้ฉากไม่โล่ง
	var base_y: float = ground_y - 38.0
	var mountains := Polygon2D.new()
	mountains.name = "DistantMountains"
	mountains.color = Color(0.025, 0.028, 0.044, 0.96)
	mountains.z_index = -455
	mountains.polygon = PackedVector2Array([
		Vector2(-180.0, base_y),
		Vector2(30.0, base_y - 70.0),
		Vector2(170.0, base_y - 28.0),
		Vector2(320.0, base_y - 118.0),
		Vector2(500.0, base_y - 45.0),
		Vector2(700.0, base_y - 96.0),
		Vector2(930.0, base_y - 34.0),
		Vector2(1180.0, base_y - 86.0),
		Vector2(1380.0, base_y),
		Vector2(1380.0, base_y + 120.0),
		Vector2(-180.0, base_y + 120.0)
	])
	add_child(mountains)


func create_broken_gate() -> void:
	# ซุ้มประตู/เสาหักแบบ silhouette ช่วยให้ฉากมีเอกลักษณ์ญี่ปุ่นดาร์กแฟนตาซี
	var gate_color := Color(0.045, 0.035, 0.045, 0.92)
	create_rect_polygon("GateLeftPillar", Vector2(260.0, ground_y - 190.0), Vector2(34.0, 190.0), gate_color, -440)
	create_rect_polygon("GateRightPillar", Vector2(835.0, ground_y - 168.0), Vector2(34.0, 168.0), gate_color, -440)
	create_rect_polygon("GateTopBeam", Vector2(225.0, ground_y - 205.0), Vector2(690.0, 28.0), gate_color, -439)
	create_rect_polygon("GateBrokenBeam", Vector2(662.0, ground_y - 245.0), Vector2(190.0, 24.0), gate_color, -438)


func create_arena_floor() -> void:
	# พื้นสนามหลัก เน้นเส้นขอบทองเพื่อแยกตัวละครกับพื้น
	create_rect_polygon("ArenaGround", Vector2(-220.0, ground_y), Vector2(1600.0, 230.0), ground_color, -430)

	var edge_line := Line2D.new()
	edge_line.name = "GroundGoldEdge"
	edge_line.points = PackedVector2Array([Vector2(-220.0, ground_y), Vector2(1380.0, ground_y)])
	edge_line.default_color = ground_edge_color
	edge_line.width = 5.0
	edge_line.antialiased = true
	edge_line.z_index = -420
	add_child(edge_line)

	# เส้นพื้นแตกเล็ก ๆ เพื่อให้ไม่ดูเป็นพื้นแบน
	for i in range(10):
		var crack := Line2D.new()
		crack.name = "GroundCrack_%02d" % i
		var x: float = randf_range(70.0, 1060.0)
		var y: float = ground_y + randf_range(22.0, 105.0)
		crack.points = PackedVector2Array([
			Vector2(x, y),
			Vector2(x + randf_range(28.0, 80.0), y + randf_range(-12.0, 18.0))
		])
		crack.default_color = Color(0.36, 0.27, 0.18, 0.26)
		crack.width = randf_range(1.5, 3.0)
		crack.antialiased = true
		crack.z_index = -418
		add_child(crack)


func create_blade_shadows() -> void:
	# เงาดาบปักพื้นด้านหลัง สื่อว่าเป็นลานประลองดาบ
	for i in range(9):
		var x: float = 120.0 + float(i) * 115.0 + randf_range(-24.0, 24.0)
		var blade_height: float = randf_range(46.0, 88.0)
		var blade := Line2D.new()
		blade.name = "BackgroundBlade_%02d" % i
		blade.points = PackedVector2Array([
			Vector2(x, ground_y - 4.0),
			Vector2(x + randf_range(-16.0, 16.0), ground_y - blade_height)
		])
		blade.default_color = Color(0.16, 0.14, 0.16, 0.78)
		blade.width = randf_range(4.0, 7.0)
		blade.antialiased = true
		blade.z_index = -425
		add_child(blade)


func create_fog_lines() -> void:
	# หมอกบาง ๆ ขยับช้า ช่วยให้ภาพนิ่งดูมีชีวิต
	for i in range(5):
		var fog := Line2D.new()
		fog.name = "SlowFog_%02d" % i
		var y: float = ground_y - 72.0 + float(i) * 26.0
		fog.points = PackedVector2Array([
			Vector2(-160.0, y),
			Vector2(180.0, y + randf_range(-10.0, 10.0)),
			Vector2(540.0, y + randf_range(-8.0, 8.0)),
			Vector2(940.0, y + randf_range(-10.0, 10.0)),
			Vector2(1340.0, y)
		])
		fog.default_color = fog_color
		fog.width = randf_range(8.0, 15.0)
		fog.antialiased = true
		fog.z_index = -410
		add_child(fog)

		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(fog, "position:x", randf_range(20.0, 46.0), randf_range(3.0, 5.2))
		tween.tween_property(fog, "position:x", randf_range(-28.0, -10.0), randf_range(3.0, 5.2))


func create_embers() -> void:
	# เถ้าถ่าน/ประกายไฟเล็ก ๆ ไม่ใช่ gameplay VFX แค่เพิ่มบรรยากาศ
	for i in range(ember_count):
		var ember := create_ellipse_polygon("Ember_%02d" % i, Vector2.ZERO, Vector2(randf_range(2.0, 4.0), randf_range(2.0, 4.0)), ember_color, 8, -405)
		ember.position = Vector2(randf_range(40.0, 1120.0), randf_range(ground_y - 160.0, ground_y - 12.0))
		ember.modulate.a = randf_range(0.20, 0.70)
		animate_ember(ember)


func animate_ember(ember: Polygon2D) -> void:
	# ทำให้ ember ลอยขึ้นและจางหาย จากนั้นวนตำแหน่งใหม่
	if not is_instance_valid(ember):
		return

	var start_position: Vector2 = Vector2(randf_range(40.0, 1120.0), randf_range(ground_y - 75.0, ground_y - 10.0))
	ember.position = start_position
	ember.modulate.a = randf_range(0.22, 0.68)

	var target_position: Vector2 = start_position + Vector2(randf_range(-34.0, 34.0), randf_range(-95.0, -35.0))
	var duration: float = randf_range(1.5, 3.2)

	var tween := create_tween()
	tween.tween_interval(randf_range(0.0, 0.7))
	tween.set_parallel(true)
	tween.tween_property(ember, "position", target_position, duration)
	tween.tween_property(ember, "modulate:a", 0.0, duration)
	tween.set_parallel(false)
	tween.tween_callback(func(): animate_ember(ember))


func create_rect_polygon(node_name: String, top_left: Vector2, size: Vector2, fill_color: Color, z: int) -> Polygon2D:
	# สร้างสี่เหลี่ยมด้วย Polygon2D เพื่อใช้ z_index แบบ Node2D ได้ง่าย
	var polygon := Polygon2D.new()
	polygon.name = node_name
	polygon.color = fill_color
	polygon.z_index = z
	polygon.polygon = PackedVector2Array([
		top_left,
		top_left + Vector2(size.x, 0.0),
		top_left + size,
		top_left + Vector2(0.0, size.y)
	])
	add_child(polygon)
	return polygon


func create_ellipse_polygon(node_name: String, center: Vector2, radius: Vector2, fill_color: Color, point_count: int, z: int) -> Polygon2D:
	# สร้างวงกลม/วงรีจากหลายจุด ใช้แทน texture เพื่อให้ repo เบา
	var polygon := Polygon2D.new()
	polygon.name = node_name
	polygon.color = fill_color
	polygon.z_index = z

	var points := PackedVector2Array()
	for i in range(point_count):
		var angle: float = TAU * float(i) / float(point_count)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))

	polygon.polygon = points
	add_child(polygon)
	return polygon
