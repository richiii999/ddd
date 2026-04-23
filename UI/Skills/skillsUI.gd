extends Panel ## SkillsUI: Controls skills states (closed / availible / active)

@onready var player = find_parent("Player") # Player ref

func _ready(): 
	for skill in get_children().filter(func(node): return node is skillButton): skill.skillUpdate.connect(skillUpdate) # Connect signals
	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints) # Update skill point counter

func skillUpdate(newSkill): # Refresh UI, and adjust player stats
	for skill in get_children().filter(func(node): return node is skillButton): skill.checkAvailible()
	
	player.skillPoints -= 1
	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints)
	
	# Update player stats
	for stat in newSkill.stats: player.coreStats[stat] += newSkill.stats[stat]
