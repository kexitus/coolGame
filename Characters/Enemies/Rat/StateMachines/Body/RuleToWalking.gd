extends Transition

func can_transition(character: Entity) -> bool:
    return character.velocity.length() > 0.01
