class_name FadeOutTimer extends Timer ## Reduces parent modularity linearly, sets visible to false on timeout()
func _ready(): timeout.connect(get_parent().set_visible.bind(false))
func _process(_delta): if !paused: get_parent().modulate.a = (time_left / wait_time)
