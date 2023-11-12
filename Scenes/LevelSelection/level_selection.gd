extends Control

const MainMenuScene = preload("res://Scenes/MainMenu.tscn")
var selected_chapter

func _ready():
	updateChapterInfo(null)

func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_start_pressed():
	# Change to the scene associated with the selected chapter.
	var scene_path = "res://Scenes/Chapters/Chapter" + str(selected_chapter) + ".tscn"
	print(scene_path)
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Chapter scene not found!")

func _on_chapter_button_pressed(chapter_button_name):
	var chapter_number = int(chapter_button_name.get_slice("ChapterButton", 1).strip_edges())
	updateChapterInfo(chapter_number) #update the chapter info...
	selected_chapter = chapter_number
	print("I am pressed")

func updateChapterInfo(chapter_number):
	# Get chapter information from the dictionary.
	if chapterdebriefs.has(chapter_number):
		var chapter_data = getChapterData(chapter_number)
		$ChapterDescription/ChapterImage.texture = chapter_data["image"]
		$ChapterDescription/ChapterDebrief.text = chapter_data["debrief"]

func getChapterData(chapter_number):
	# Check if the chapter number exists in the data dictionary.
	if chapterdebriefs.has(chapter_number):
		return chapterdebriefs[chapter_number]

var chapterdebriefs = {
	1: {"image": preload("res://Assets/Images/Prelude.png"),
	"debrief": "The flagship Achilleus is undergoing prelaunch checks and 
rearmament at Sparta Shipyard. Systems are online.
[i]Launch in 3...2...1[/i]. "},
	2: {"image": preload("res://Assets/Images/Chapter1.png"),
	"debrief": "Lead the Dorian Fleet to the Ionian Homeplanet and force their surrender."},
	3: {"image": preload("res://Assets/Images/Chapter2.png"),
	"debrief": "Status: Unknown..."},
	4: {"image": preload("res://Assets/Images/Chapter3.png"),
	"debrief": "Find out more about the Independent Worlds."},
	5: {"image": preload("res://Assets/Images/Chapter4.png"),
	"debrief": "Find out about the Empire."},
	6: {"image": preload("res://Assets/Images/Chapter5.png"),
	"debrief": "Push with your allies the Strogg Homeworld."}
	}
