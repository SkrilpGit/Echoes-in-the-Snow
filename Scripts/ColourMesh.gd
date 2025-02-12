extends MeshInstance3D

@export var colour : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	var material = StandardMaterial3D.new()
	material.albedo_color = colour
	self.material_override = material
