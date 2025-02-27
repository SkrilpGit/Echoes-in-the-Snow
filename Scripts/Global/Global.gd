extends Node


func angle_to_vector2(angle : float):
	return Vector2(-sin(angle), cos(angle))

func vector2_to_angle(v : Vector2):
	return atan2(v.x,v.y)

func round_to_dec(num : float, digit : int):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func lerp_to_direction(my_rot : float,direction : Vector2,speed : float,delta : float):
	var angle = rad_to_deg(atan2(-direction.x, -direction.y))
	# Wrap angles to [0, 360] for easier quadrant checking
	var wrapped_angle = int(angle + 360) % 360
	var wrapped_my_rot = int(my_rot + 360) % 360
	# Calculate shortest path
	var delta_angle = wrapped_angle - wrapped_my_rot
	# Handle quadrant crossing (wrap delta_angle to [-180, 180])
	if delta_angle > 180:
		delta_angle -= 360
	elif delta_angle < -180:
		delta_angle += 360
	# Smoothly interpolate using lerp
	var new_angle = my_rot + delta_angle * (speed * delta)
	# Update rotation
	return new_angle
