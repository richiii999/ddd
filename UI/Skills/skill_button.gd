class_name skillButton extends Button ## SkillButton: Able to be clicked only when parents are taken & have skillpoints

@export var skillText : String = "SkillText"

@export var parentSkills : Array[skillButton] = [] # NOTE: Cannot use node tree parents since multiparent possible
@export var availible : bool = false # Can this skill be selected? (Should be true when all parents are active)
@export var active : bool = false # Is this skill currently active? (Shuld be true once selected)

# Icons: Changes icon depending on closed (not availible), availible, and active state
@export var closedIcon = preload("res://Assets/UI/Inventory/inv_slot.png")
@export var openIcon = preload("res://Assets/UI/Inventory/inv_slotWhite.png")
@export var activeIcon = preload("res://Assets/UI/Inventory/inv_slotPurple.png")
func setSkillIcon() -> void: icon = activeIcon if active else openIcon if availible else closedIcon

@warning_ignore("int_as_enum_without_cast")
@export var stats: Dictionary[Stats.STAT, int] = {
Stats.STR: 5, 
Stats.INT: 5, 
Stats.AGI: 5, 
Stats.TOU: 3, 
Stats.WIS: 3, 
Stats.DEX: 3, 
Stats.BLK: 1, 
Stats.WIL: 1, 
Stats.SPD: 1
}
signal skillUpdate # emitted to the SkillsUI when a skill is bought

func _ready(): 
	pressed.connect(activateSkill)
	checkAvailible()
	$SkillText.text = skillText

func checkAvailible() -> bool: # Checks if this is now availible, called on all nodes when any skill is activated
	if active: return false # The skill is not available for the player to obtain
	for skill in parentSkills: 
		if not skill.active:
			return false # Inactive parent, not availible
	availible = true
	setSkillIcon()
	return true

func activateSkill() -> String: # Tries to activate the skill, costs a skillpoint and requires it to be availible
	if not checkAvailible(): return "Skill not availible!" # First, the skill must be availible
	if find_parent("Player").skillPoints == 0: return "No skill points!" # Then, must be able to afford it
	
	availible = false
	active = true
	setSkillIcon()
	skillUpdate.emit(self)
	return "Skill bought!"
