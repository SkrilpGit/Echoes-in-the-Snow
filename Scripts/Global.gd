extends Node3D


func angle_to_vector2(angle : float):
	return Vector2(-sin(angle), cos(angle))

func vector2_to_angle(v : Vector2):
	return atan2(v.x,v.y)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
