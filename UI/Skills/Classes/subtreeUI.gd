extends Panel

#initialize our variables
var player : Node = null
var class_id : String = ""
var parent_ui : Panel = null

func setup(p: Node, cid: String, parent: Panel) -> void:
	player = p
	class_id = cid
	parent_ui = parent
	
	#connect all skill buttons in this subtree
	for skill in get_skills():
		skill.on_skill_bought.connect(onSkillUpdate)
	
	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints)
	$BackButton.pressed.connect(parent_ui.close_subtree)

func get_skills() -> Array: #same thing in skillsui
	return get_children().filter(func(node): return node is skillButton)

func onSkillUpdate(newSkill) -> void:
	for skill in get_skills(): skill.checkAvailible()
	
	player.skillPoints -= 1
	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints)
	
	for stat in newSkill.stats: player.coreStats[stat] += newSkill.stats[stat]
	player.UpdateProjStats()
	player.maxHealthCalc()
	player.maxManaCalc()
	if player.has_node("%CharMenu") and player.get_node("%CharMenu").visible:
		player.get_node("%CharMenu").refresh_stats()
