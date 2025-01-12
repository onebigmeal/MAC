extends Node

@onready var L_score = 0 
@onready var R_score = 0
@onready var L_health = 100
@onready var R_health = 100
@onready var L_ammo = 100
@onready var R_ammo = 100
@onready var L_stamina = 100
@onready var R_stamina = 100
@onready var time = 0.0
@onready var volume = 0.0
@onready var CONTROLLER_SENSITIVITY = 0.03 
@onready var BASE_FOV = 55.0

const MAX_WALK_SPEED = 7.0 # this one is based on smth else
const MAX_SPRINT_SPEED = 2 # this is an increment
const MAX_CROUCH_SPEED = 5.0
const SLIDE_FRICTION = 2 # this changes linear damp
const SLIDE_FORCE = 7.0 # extra push applied when sliding
const SLIDE_POINT = 11.0 # slide threshold
const JUMP_HEIGHT = 10 # how high you jump
const SPRINT_MULTIPLIER = 2.0 # how much sprinting multiplies the
const MOUSE_SENSITIVITY = 0.004 
# FOV, used
const FOV_CHANGE = 20.0 # when sprint
