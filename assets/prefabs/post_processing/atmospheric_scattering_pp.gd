extends MeshInstance3D

@export_group("Accelerated")
@export var is_accelerated : bool:
	set(value):
		is_accelerated = value
		if shader: shader.set_shader_parameter("is_accelerated", false)

@export var od_tex_filename : String:
	set(value):
		od_tex_filename = value
		var od_tex: ImageTexture = _get_od_tex()
		if shader: shader.set_shader_parameter("optical_depth_texture", od_tex)

@export_group("Radiuses")
@export var atmosphere_radius : float:
	set(value):
		atmosphere_radius = value
		if shader: shader.set_shader_parameter("atmosphere_radius", atmosphere_radius)

@export_group("Sample Sizes")
@export var optical_depth_sample_size : int:
	set(value):
		optical_depth_sample_size = value
		if shader: shader.set_shader_parameter("optical_depth_sample_size", optical_depth_sample_size)

@export var in_scattering_sample_size : int:
	set(value):
		in_scattering_sample_size = value
		if shader: shader.set_shader_parameter("in_scattering_sample_size", in_scattering_sample_size)

@export_group("Rayleigh")
@export var r_density_falloff : float:
	set(value):
		r_density_falloff = value
		if shader: shader.set_shader_parameter("r_density_falloff", r_density_falloff)

@export var r_exponent : float:
	set(value):
		r_exponent = value
		var scattering_coef: Vector3 = _calculate_rayleigh_coefficients()
		if shader: shader.set_shader_parameter("r_scattering_coefficients", scattering_coef)

@export var r_numerator : float:
	set(value):
		r_numerator = value
		var scattering_coef: Vector3 = _calculate_rayleigh_coefficients()
		if shader: shader.set_shader_parameter("r_scattering_coefficients", scattering_coef)

@export var r_scattering_strength : float:
	set(value):
		r_scattering_strength = value
		var scattering_coef: Vector3 = _calculate_rayleigh_coefficients()
		if shader: shader.set_shader_parameter("r_scattering_coefficients", scattering_coef)

@export_group("Mie")
@export var m_density_falloff : float:
	set(value):
		m_density_falloff = value
		if shader: shader.set_shader_parameter("m_density_falloff", m_density_falloff)

@export var m_scattering_strength : float:
	set(value):
		m_scattering_strength = value
		var scattering_coef: Vector3 = _calculate_mie_coefficients()
		if shader: shader.set_shader_parameter("m_scattering_coefficients", scattering_coef)

@export_group("Light")
@export var density_falloff_strength : float:
	set(value):
		density_falloff_strength = value
		if shader: shader.set_shader_parameter("density_falloff_strength", density_falloff_strength)
		
@export var optical_depth_strength : float:
	set(value):
		optical_depth_strength = value
		if shader: shader.set_shader_parameter("optical_depth_strength", optical_depth_strength)

@export var wavelengths : Vector3:
	set(value):
		wavelengths = value
		var r_scattering_coef: Vector3 = _calculate_rayleigh_coefficients()
		if shader: shader.set_shader_parameter("r_scattering_coefficients", r_scattering_coef)

@export_group("HDR")
@export var f_exposure : float:
	set(value):
		f_exposure = value
		if shader: shader.set_shader_parameter("f_exposure", f_exposure)

var shader: ShaderMaterial
var camera: Camera3D
var sun: DirectionalLight3D

func _ready() -> void:
	shader = get_active_material(0)
	while !camera:
		camera = STUtil.get_only_node_in_group("main_camera")
	while !sun:
		sun = STUtil.get_only_node_in_group("sun")
	_setup_shader_parameters()

func _process(_delta: float) -> void:
	_update_shader_parameters()

func _update_shader_parameters() -> void:
	if !shader: return
	if sun: shader.set_shader_parameter("sun_center", sun.global_position)
	if camera: shader.set_shader_parameter("fov", camera.fov)

func _setup_shader_parameters() -> void:
	if !shader: return

	var r_coeffs: Vector3 = _calculate_rayleigh_coefficients()
	var m_coeffs: Vector3 = _calculate_mie_coefficients()
	var od_tex: ImageTexture = _get_od_tex()

	# references and positions
	shader.set_shader_parameter("planet_center", Vector3(0.,0.,0.))
	if camera: shader.set_shader_parameter("fov", camera.fov)
	if sun: shader.set_shader_parameter("sun_center", sun.global_position)
	# accelerated
	shader.set_shader_parameter("is_accelerated", is_accelerated)
	shader.set_shader_parameter("optical_depth_texture", od_tex)
	# Radiuses
	shader.set_shader_parameter("planet_radius", STUtil.PLANET_RADIUS)
	shader.set_shader_parameter("atmosphere_radius", STUtil.PLANET_RADIUS * 16.)
	# Rayleigh
	shader.set_shader_parameter("r_density_falloff", r_density_falloff)
	shader.set_shader_parameter("r_scattering_coefficients", r_coeffs)
	# Mie
	shader.set_shader_parameter("m_density_falloff", m_density_falloff)
	shader.set_shader_parameter("m_scattering_coefficients", m_coeffs)
	# Sample sizes
	shader.set_shader_parameter("in_scattering_sample_size", in_scattering_sample_size)
	shader.set_shader_parameter("optical_depth_sample_size", optical_depth_sample_size)
	# Optical Depth
	shader.set_shader_parameter("density_falloff_strength", density_falloff_strength)
	shader.set_shader_parameter("optical_depth_strength", optical_depth_strength)
	# HDR
	shader.set_shader_parameter("f_exposure", f_exposure)

func _get_od_tex() -> ImageTexture:
	if od_tex_filename.is_empty(): return

	var img_in: FileAccess = FileAccess.open("res://assets/resources/atmosphere_data/%s.i" % od_tex_filename, FileAccess.READ)
	var dat_in: FileAccess = FileAccess.open("res://assets/resources/atmosphere_data/%s.idat" % od_tex_filename, FileAccess.READ)

	var dat: Dictionary = JSON.parse_string(dat_in.get_line())
	var inbytes: PackedByteArray = img_in.get_buffer(dat.blen)

	var od_img: Image = Image.create_from_data(dat.width, dat.height, false, dat.format, inbytes)
	var od_tex: ImageTexture = ImageTexture.create_from_image(od_img)

	return od_tex

func _calculate_rayleigh_coefficients() -> Vector3:
	return Vector3(
		pow(r_numerator / wavelengths.x, r_exponent) * r_scattering_strength,
		pow(r_numerator / wavelengths.y, r_exponent) * r_scattering_strength,
		pow(r_numerator / wavelengths.z, r_exponent) * r_scattering_strength,
	)

func _calculate_mie_coefficients() -> Vector3:
	return Vector3(
		18.0e-6,
		18.0e-6,
		18.0e-6
	) * m_scattering_strength