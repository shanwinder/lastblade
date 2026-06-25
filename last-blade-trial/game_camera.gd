extends Camera2D

# =========================
# GameCamera.gd
# ใช้จัดการกล้องและเอฟเฟกต์กล้องสั่น
# =========================

# เวลาที่กล้องยังต้องสั่นอยู่
var shake_time: float = 0.0

# ระยะเวลาสั่นทั้งหมดของรอบปัจจุบัน
var shake_duration: float = 0.0

# ความแรงของการสั่น
var shake_strength: float = 0.0

# ตำแหน่ง offset เดิมของกล้อง
var original_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	# ตั้งกล้องนี้ให้เป็นกล้องหลัก
	make_current()

	# เก็บ offset เดิมไว้ เพื่อคืนค่าหลังสั่นเสร็จ
	original_offset = offset

	# เพิ่มกล้องเข้า group เพื่อให้ node อื่นเรียก shake ได้ง่าย
	# เช่น EnemyDummy หรือ Player สามารถใช้ call_group("game_camera", "shake", ...)
	add_to_group("game_camera")


func _process(delta: float) -> void:
	# ถ้าไม่มีเวลาสั่นเหลือ ให้คืน offset แล้วจบ
	if shake_time <= 0.0:
		offset = original_offset
		return

	# ลดเวลาสั่นตามเวลาเฟรม
	shake_time -= delta

	# คำนวณความแรงที่ค่อย ๆ เบาลงเมื่อใกล้หมดเวลา
	var progress := shake_time / shake_duration
	var current_strength := shake_strength * progress

	# สุ่ม offset ซ้ายขวา/ขึ้นลง
	var random_x := randf_range(-current_strength, current_strength)
	var random_y := randf_range(-current_strength, current_strength)

	# ตั้ง offset กล้องให้สั่น
	offset = original_offset + Vector2(random_x, random_y)


func shake(strength: float, duration: float) -> void:
	# ถ้ามี shake ใหม่ที่แรงกว่า ให้ใช้ค่าใหม่
	# ถ้า shake ใหม่เบากว่า แต่เข้ามาตอนกำลังสั่นอยู่ ให้ยังอัปเดตเวลาได้
	shake_strength = max(shake_strength, strength)
	shake_duration = max(duration, 0.01)
	shake_time = duration
