extends "entity.gd"

export (int, -100, 100) var strength  = 0

export (int, -100, 100) var fire      = 0
export (int, -100, 100) var water     = 0
export (int, -100, 100) var ice       = 0
export (int, -100, 100) var thunder   = 0
export (int, -100, 100) var dragon    = 0
export (int, -100, 100) var poison    = 0
export (int, -100, 100) var paralysis = 0

const SPEED = 5

var weakness = {}
var players = []
var target = null
var combat = false

func _init().(500, 100, 1):
	weakness = {
		"fire":      fire,
		"water":     water,
		"ice":       ice,
		"thunder":   thunder,
		"dragon":    dragon,
		"poison":    poison,
		"paralysis": paralysis
	}


func _ready():
	if not networking.is_server() and networking.multiplayer:
		set_physics_process(false)

# @override from entity.gd
func die():
	.die()
	set_physics_process(false)
	animation_node.play("death")
	$fire.hide()
	$interact.add_to_group("interact")
	$view.disconnect("body_entered", self, "_on_view_body_entered")
	$view.disconnect("body_exited", self, "_on_view_body_exited")
	call_deferred("set_script", preload("res://src/interact/monster drop.gd"))

func sort_by_distance(a, b):
	var dist_a = (get_global_transform().origin - a.get_global_transform().origin).length()
	var dist_b = (get_global_transform().origin - b.get_global_transform().origin).length()
	return dist_a < dist_b

func _physics_process(delta):
	direction = Vector3()
	var origin = get_pos()
	var player = null
	var distance_from_player

	if players.size() != 0:
		players.sort_custom(self, "sort_by_distance")
		player = players[0]
		distance_from_player = player.get_pos() - origin
		if get_transform().basis.z.dot(distance_from_player.normalized()) > -0.5:
			if combat == false:
				combat = true
				$exclamation/animation.play("exclamation")
		else:
			player = null

	if player != null:
		distance_from_player = player.get_pos() - origin
		if distance_from_player.length() > 7.5:
			direction = distance_from_player.normalized() * SPEED
		else:
			direction = distance_from_player.normalized() * 0.01
			attack("attack")
	else:
		if target == null or (target - Vector3(origin.x, 0, origin.z)).length() < 2:
			target = Vector3(rand_range(-100, 100), 0, rand_range(-100, 100))
			print(target)
		direction = (target - origin).normalized() * (SPEED/2)

	move_entity(delta)


func _on_view_body_entered(body):
	if body.is_in_group("player"):
		players.push_front(body)

func _on_view_body_exited( body ):
	if body.is_in_group("player"):
		players.erase(body)
