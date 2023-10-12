extends Node

@onready var animated_sprite_2d = $"../AnimatedSprite2D"
@onready var ability_timer = $AbilityTimer

enum ELEMENTS { FIRE, WATER, EARTH, AIR }
var current_element: ELEMENTS = ELEMENTS.FIRE


func update_element_color():
	match current_element:
		ELEMENTS.FIRE:
			animated_sprite_2d.modulate = Color(1, 0.5, 0.5)  # Red tint for fire
		ELEMENTS.WATER:
			animated_sprite_2d.modulate = Color(0.5, 0.5, 1)  # Blue tint for water
		ELEMENTS.EARTH:
			animated_sprite_2d.modulate = Color(0.6, 0.4, 0.2)  # Brown tint for earth
		ELEMENTS.AIR:
			animated_sprite_2d.modulate = Color(0.8, 0.8, 0.8)  # Light gray tint for air


func switch_element(element: ELEMENTS) -> void:
	current_element = element
	update_element_color()


#func activate_elemental_ability():
#	match current_element:
#		ELEMENTS.FIRE:
#			ignite() # adds a chance to burn enemies on each hit
#		ELEMENTS.WATER:
#			water_shield() # activates the healing shield
#		ELEMENTS.EARTH:
#			stone_guard() # activates the damage-reducing shield
#		ELEMENTS.AIR:
#			if is_dashing:
#				swift_breeze() # increases movement speed
#			else:
#				gust_dash() # dashes in a direction
#
#func ignite():
#	pass
#
#func water_shield():
#	pass
#
#func stone_guard():
#	pass
#
#func swift_breeze():
#	pass
#
#func gust_dash():
#	pass
#
#func _on_AbilityTimer_timeout():
#	# revert speed or other effects when timer runs out
#	pass
