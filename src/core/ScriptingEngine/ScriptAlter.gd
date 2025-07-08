# This contains information about one specific alteration requested by the card
# automation
class_name ScriptAlter
extends ScriptObject

# Stores the details arg passed the signal to use for filtering
var trigger_details : Dictionary
# If true if this task has been confirmed to run by the player
# Only relevant for optional tasks (see [SP].KEY_IS_OPTIONAL)
var is_accepted := true

# Prepares the script_definition needed by the alteration to function and
# checks the ongoing task and its owner_card against defined filters.
#func _init(
		#alteration_script: Dictionary,
		#trigger_object: Card,
		#alterant_object,
		#task_details: Dictionary,
		#prev_subject = null).(
			#alterant_object,
			#alteration_script,
			#trigger_object) -> void:
@warning_ignore("shadowed_variable")
func _init(
		alteration_script: Dictionary,
		trigger_object: Card,
		alterant_object,
		task_details: Dictionary,
		prev_subject = null) -> void:
	super(alterant_object, alteration_script, trigger_object)
	# The alteration name gets its own var
	script_name = get_property("filter_task")
	trigger_details = task_details
	# For Alterants, we might need to calculate them per subject in a subject list
	if prev_subject != null:
		prev_subjects = [prev_subject]
	if not SP.filter_trigger(
			alteration_script,
			trigger_object,
			owner,
			trigger_details):
		is_valid = false
	if is_valid:
		#HACK: This prevents Tokens being a co-routine/needing to be awaited by finishing async
		if script_definition.get("is_optional_" + "task"):
			_async_confirm(script_definition,
				owner.canonical_name, script_name)
		else:
			# The alterant might require counting other cards to see if it's valid.
			# So we just run it through the _find_subjects() to see if it will
			# set is_valid to false.
			var ret = _find_subjects(0)
			if ret.has("awaiting_target"):
				#The targeting function will prime the script for us when ready
				ret.erase("awaiting_target")
			else:
				is_primed = true
				emit_signal("primed")

@warning_ignore("unused_parameter", "shadowed_variable")
func _async_confirm(script_definintion, canonical_name, script_name):
	var c = await CFUtils.confirm(
			script_definition,
			owner.canonical_name,
			script_name)
	is_valid = c
	if is_valid:
		var ret = _find_subjects()
		if ret.has("awaiting_target"):
			ret.erase("awaiting_target")
		else:
			is_primed = true
			emit_signal("primed")
	#is_primed = true
	#emit_signal("primed")
