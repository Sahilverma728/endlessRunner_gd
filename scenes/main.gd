extends Node

# MACRO
const START_POS := Vector2i(150, 485)
const CAMERA_POS := Vector2i(573, 324)
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const MAX_DIFFICULTY : int = 2
var curr_difficulty
var speed : float
var is_game_running : bool
var screen_size : Vector2i
var crouch_speed : float
var score : int
var ground_height : int
const SCORE_MODIFIER : int = 10
const SPEED_MODIFIER : int = 5000

# Obstacle Variables
var obs_fire = preload("res://scenes/obstacle_fire.tscn")
var obs_wood = preload("res://scenes/obstacle_wood.tscn")
var obs_metal = preload("res://scenes/obstacle_metal.tscn")
var obs_raptor = preload("res://scenes/obstacle_raptor.tscn")

var obstacle_type := [obs_wood, obs_metal]
var obstacles : Array
var raptor_height := [200, 300]
var preload_obstacle


#func game_reset():
	#launch_game()

func launch_game():
	is_game_running = false
	score = 0
	show_score()
	get_tree().paused = false
	curr_difficulty = 0
	$Ch_player.position = START_POS
	$Ch_player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAMERA_POS
	$st_body_floor.position = Vector2i(0, 60)
	# HUD show and hide
	$"HUD UI".get_node("press_play_label").show()
	$game_over_scene.hide()

func difficulty_modd():
	curr_difficulty = score/SPEED_MODIFIER
	if curr_difficulty > MAX_DIFFICULTY:
		curr_difficulty = MAX_DIFFICULTY

# Obstacle Generator
func obs_gen():
	if obstacles.is_empty() or preload_obstacle.position.x<score+randi_range(300,500):
		var obs_type = obstacle_type[randi()%obstacle_type.size()]
		var obs
		var max_obs = curr_difficulty+1
		for i in range(randi()%max_obs+1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i*100)
			var obs_y : int = screen_size.y - 20 - (obs_height*obs_scale.y/2)+5
			preload_obstacle = obs
			add_obs(obs, obs_x, obs_y)
		## Raptor Obstacle Gen
		#if curr_difficulty == MAX_DIFFICULTY:
			#if(randi()%2) == 0:
				#obs.obstacle_raptor.instantiate()
				#var obs_x : int = screen_size.x + score + 100
				#var obs_y : int = raptor_height[randi()%raptor_height.size()]
				#add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func hit_obs(body):
	if body.name == "Ch_player":
		gameOver()
	

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func _ready():
	screen_size = get_window().size
	ground_height = $st_body_floor.get_node("spr_floor").texture.get_height()
	$game_over_scene.get_node("restart_btn").pressed.connect(launch_game)
	launch_game()
	
func show_score():
	$"HUD UI".get_node("score_label").text = "Score: " + str(score/SCORE_MODIFIER)

func _process(delta):
	if is_game_running: # Speed increases gradually
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		print("Your speed is ", speed)
		difficulty_modd() # Difficulty increases along with speed
		
		# Obstacles generates here
		obs_gen()
		
		$Ch_player.position.x += speed
		$Camera2D.position.x += speed
		score += speed
		show_score()
		#floor moves
		if $Camera2D.position.x - $st_body_floor.position.x > screen_size.x * 1.5:
			$st_body_floor.position.x += (screen_size.x)
		
		# Obstacles off the screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
		 #Experimental Block SPEED BOOST HAX
		if Input.is_action_pressed("alt"):
			crouch_speed = speed * 5
			$Ch_player.position.x += crouch_speed
			$Camera2D.position.x += crouch_speed
			score += crouch_speed
			print("HAX BOOST ", score/SCORE_MODIFIER)
	else:
		if Input.is_action_pressed("ui_accept"):
			is_game_running = true
			$"HUD UI".get_node("press_play_label").hide()

func gameOver():
	get_tree().paused = true
	is_game_running = false
	$game_over_scene.show()
