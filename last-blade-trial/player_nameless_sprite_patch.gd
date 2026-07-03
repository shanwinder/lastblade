extends "res://player.gd"

# =========================
# PlayerNamelessSpritePatch.gd
# Patch เฉพาะช่วงนำ sprite จริงของ The Nameless Blade มาใช้
# เป้าหมาย: แก้ flip_h ที่ต้นทาง ไม่ให้ player.gd ตั้งภาพผิดฝั่งก่อนแล้วค่อยให้ manager ตามแก้
# =========================

# true = source sprite ของ Player หันซ้าย
# idle sprite ชุด nameless_blade ปัจจุบันเป็นท่าหันซ้าย จึงต้อง flip เมื่อ gameplay ต้องการหันขวา
@export var sprite_source_faces_left: bool = true


func set_facing_direction(new_direction: int) -> void:
	# ตั้งทิศหันหน้าและย้าย hitbox ดาบให้ตรงกับทิศนั้น
	# Override ฟังก์ชันเดิมจาก player.gd เพราะของเดิมสมมติว่า source sprite หันขวา
	if new_direction == 0:
		return

	# facing_direction ยังเป็นแหล่งข้อมูลหลักของ gameplay ทั้งหมด
	# 1 = หันขวา, -1 = หันซ้าย
	facing_direction = new_direction

	# แก้ภาพที่ต้นทางทันที ไม่รอให้ manager มาแก้ทีหลัง
	apply_player_sprite_facing()

	# ย้าย hitbox ดาบให้ไปอยู่ด้านหน้าของตัวละครตามทิศ gameplay
	attack_hitbox.position.x = attack_hitbox_offset_x * float(facing_direction)


func apply_player_sprite_facing() -> void:
	# จัด flip_h ตามทิศของ source sprite จริง
	# ถ้า source หันซ้าย: หันขวาต้อง flip, หันซ้ายไม่ต้อง flip
	# ถ้า source หันขวา: หันซ้ายต้อง flip, หันขวาไม่ต้อง flip
	if not is_instance_valid(sprite_2d):
		return

	if sprite_source_faces_left:
		sprite_2d.flip_h = facing_direction > 0
	else:
		sprite_2d.flip_h = facing_direction < 0
