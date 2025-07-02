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
	if is_valid:
		# The alterant might require counting other cards to see if it's valid.
		# So we just run it through the _find_subjects() to see if it will
		# set is_valid to false.
		#await _find_subjects(0) <- there's no reason to await the answer
		_find_subjects(0)
		#Alters needing confirmation are not yet primed, only these ones
		is_primed = true
		emit_signal("primed")
	# We emit a signal when done so that our ScriptingEngine
	# knows we're ready to continue
	#HACK: Conditionals make co-routines not work
	#await Engine.get_main_loop().process_frame
	#is_primed = false
	#emit_signal("primed")

func _async_confirm(script_definintion, canonical_name, script_name):
	var c = await CFUtils.confirm(
			script_definition,
			owner.canonical_name,
			script_name)
	is_valid = c
	if is_valid:
		_find_subjects(0)
	is_primed = true
	emit_signal("primed")
