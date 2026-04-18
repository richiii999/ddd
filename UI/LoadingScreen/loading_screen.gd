extends Control ## Loading Screen

func _ready(): FadeOut()

func Enable():
	# TODO: take sprite info and copy it to center of screen
	# get name of place you're in -> loading into
	visible = true
	await get_tree().create_timer(2.00).timeout
	
	
	# TODO: change to some other way of doing it like:
	# start minimum time timer
	# await 
	# if !time expired, wait for timer minimum time on screen (2 seconds or somth)

func FadeOut(time:float=1.50) -> Timer: $FadeOutTimer.start(time); return $FadeOutTimer # Returns the timer whose timeout is awaited by the caller
