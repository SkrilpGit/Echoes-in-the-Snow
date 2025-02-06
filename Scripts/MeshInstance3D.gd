extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8,0.5,0.8,1)
	self.material_override = material
