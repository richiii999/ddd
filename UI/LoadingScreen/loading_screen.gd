extends Control ## Loading Screen

func _ready(): FadeOut()

func Enable():
	visible = true

func FadeOut(time:float=1.50) -> Timer: 
	$FadeOutTimer.start(time)
	return $FadeOutTimer # Returns the timer whose timeout is awaited by the caller
