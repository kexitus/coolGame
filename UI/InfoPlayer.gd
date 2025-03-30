class_name InfoEntity
extends Control

@export var player:EntityPlayer

@export_category("Show")
@export var show_hp: bool = true
@export var show_body_state: bool = true
@export var show_invulnerability_state: bool = true
@export var show_hands_state: bool = true
@export var show_signs: bool = true

@onready var label: RichTextLabel = $RichTextLabel

var hp: String = ""
var body_state: String = ""
var invulnerability_state: String = ""
var hands_state: String = ""
var signs: Array[GlobalData.SIGNS] = []
func _ready() -> void:
	if show_hp:
		player.damage_taken.connect(update_hp)
		hp = str(player.max_hp)
	
	if show_body_state:
		player.body_state_machine.state_changed.connect(update_body_state)
		body_state = player.body_state_machine.current_state.name
	
	if show_invulnerability_state:
		player.invulnerability_state_machine.state_changed.connect(update_invulnerability_state)
		invulnerability_state = player.invulnerability_state_machine.current_state.name
	
	if show_hands_state:
		player.hands_state_machine.state_changed.connect(update_hands_state)
		hands_state = player.hands_state_machine.current_state.name
	
	if show_signs:
		player.signs_changed.connect(update_signs)
		signs = player.signs
	
	update_text()


func _physics_process(_delta: float) -> void:
	pass


func update_text() -> void:
	var text: String = ""
	
	if show_hp:
		text += "HP: " + hp
	
	if show_body_state:
		text +=  "\nBody: " + body_state
	
	if show_invulnerability_state:
		text +=  "\nInvul: " + invulnerability_state
	
	if show_hands_state:
		text +=  "\nHands: " + hands_state
	
	if show_signs:
		text +=  "\nSigns: "
		for sign in signs:
			text +=  str(sign) + " "
	
	label.clear()
	label.append_text(text)


func update_hp(_damage: float) -> void:
	hp = str(player.hp)
	update_text()


func update_body_state(new_state: State) -> void:
	body_state = new_state.name
	update_text()


func update_invulnerability_state(new_state: State) -> void:
	invulnerability_state = new_state.name
	update_text()


func update_hands_state(new_state: State) -> void:
	hands_state = new_state.name
	update_text()


func update_signs(new_signs: Array[GlobalData.SIGNS]) -> void:
	signs = new_signs
	update_text()
