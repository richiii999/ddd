extends Panel ## SkillsUI: Controls skills states (closed / availible / active)

var player : Node = null # player init
var chosen_class : String = "" #since its empty, they haven't chosen a class yet
var subtree_save: Dictionary = {}  #persists subtree state even when closed


func _ready(): 
	#connect_skill_signals()
	#for skill in get_children().filter(func(node): return node is skillButton): skill.skillUpdate.connect(skillUpdate) # Connect signals
	#$SkillPointsText/SkillPointsCount.text = str(player.skillPoints) # Update skill point counter
	$OpenClass.visible = false
	$OpenClass.pressed.connect(reopen_subtree)

func setup(p: Node) -> void: #pass in the player node
	player = p
	connect_skill_signals()
	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints)

func connect_skill_signals() -> void: 
	for skill in get_skills():
		if not skill.on_skill_bought.is_connected(onSkillUpdate):
			skill.on_skill_bought.connect(onSkillUpdate)

func get_skills() -> Array: #retrieve the current skilltree
	return get_children().filter(func(node): return node is skillButton)

func onSkillUpdate(newSkill) -> void: 
	#check to see if the skill is availble 
	for skill in get_skills(): skill.checkAvailible()
	#use the skill point to increase a stat
	player.skillPoints -= 1
	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints)
	for stat in newSkill.stats: player.coreStats[stat] += newSkill.stats[stat]
	player.UpdateProjStats() #recalculate proj stats after skill purchase
	#check to see if the class is open to the player, otherwise lock it
	if newSkill.class_id != "" and chosen_class == "":
		chosen_class = newSkill.class_id
		lock_other_classes()
	
	#open the subtree if they have access to it
	if newSkill.subtree_scene:
		open_subtree(newSkill.subtree_scene)


#func skillUpdate(newSkill): # Refresh UI, and adjust player stats
#	for skill in get_children().filter(func(node): return node is skillButton): skill.checkAvailible()
	
#	player.skillPoints -= 1
#	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints)
	
	# Update player stats
#	for stat in newSkill.stats: player.coreStats[stat] += newSkill.stats[stat]
	
	#handle the classes
#	if newSkill.class_id != "" and chosen_class == "":
#		chosen_class = newSkill.class_id
#		_lock_other_classes()

func lock_other_classes(): #locks out the other classes if you chose one already
	for skill in get_children().filter(func(node): return node is skillButton): #loop through every available skill button and check to see if the class is empty or not chosen
		if skill.class_id != "" and skill.class_id != chosen_class:
			skill.permanently_locked = true #lock it if it's already been chosen 
			skill.setSkillIcon()


func open_subtree(scene: PackedScene) -> void:
	#hide all main skill buttons and points text
	for skill in get_skills(): skill.visible = false
	$SkillPointsText.visible = false
	
	#instantiate and add the subtree
	var subtree = scene.instantiate()
	subtree.name = "ActiveSubtree"
	add_child(subtree)
	
	#pass references down to the subtree
	subtree.setup(player, chosen_class, self)
	
	#restore bought subtree skills with multiple passes for parent dependencies
	var sub_skills = subtree.get_children().filter(func(n): return n is skillButton)
	for pas in range(sub_skills.size()):
		for skill in sub_skills:
			if subtree_save.get(skill.name, false) and not skill.active:
				skill.checkAvailible()
				if skill.availible:
					skill.availible = false
					skill.active = true
					skill.setSkillIcon()
	
	#sfter restoring actives, update availability for unspent skills
	for skill in sub_skills:
		if not skill.active:
			skill.checkAvailible()

func close_subtree() -> void:
	#remove the subtree but save it before doing so
	if has_node("ActiveSubtree"):
		var subtree = $ActiveSubtree
		for skill in subtree.get_children().filter(func(n): return n is skillButton):
			subtree_save[skill.name] = skill.active
		$ActiveSubtree.queue_free()
	
	#restore main panel
	for skill in get_skills(): skill.visible = true
	$SkillPointsText.visible = true
	$SkillPointsText/SkillPointsCount.text = str(player.skillPoints)
	
	#show a reopen button if you chose a class
	if chosen_class != "":
		$OpenClass.visible = true
	#reconnect signals in case subtree spent points
	connect_skill_signals()
	
	for skill in get_skills(): skill.checkAvailible()

func reopen_subtree() -> void:
	#find the class choice skill that was bought and reopen its subtree
	for skill in get_skills():
		if skill.is_class_choice and skill.active and skill.subtree_scene:
			open_subtree(skill.subtree_scene)
			$OpenClass.visible = false
			return

#apply our save data here
func apply_save(data: Dictionary) -> void:
	chosen_class = data.get("chosen_class", "")
	if chosen_class != "":
		lock_other_classes()
		$OpenClass.visible = true
	
	#populate subtree_save first so open_subtree() can use it
	for key in data:
		if key.begins_with("subtree_"):
			subtree_save[key.trim_prefix("subtree_")] = data[key]
	
	#restore main skills (multiple passes for parent dependencies)
	var skills = get_skills()
	for pas in range(skills.size()):
		for skill in skills:
			if data.get(skill.name, false) and not skill.active:
				skill.checkAvailible()
				if skill.availible:
					skill.availible = false
					skill.active = true
					skill.setSkillIcon()
	
	#ppen the subtree last as it will read from subtree_save automatically
	for skill in skills:
		if skill.is_class_choice and skill.active and skill.subtree_scene:
			open_subtree(skill.subtree_scene)
	
	#update the availability
	for skill in get_skills():
		if not skill.active:
			skill.checkAvailible()
