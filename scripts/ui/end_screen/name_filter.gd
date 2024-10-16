class_name NameFilter

const FILE_NAME := "banned_words.txt"

var banned_words: Array[String] = []


func _init():
  _load_from_file()

func test(test_string: String) -> bool:
  test_string = test_string.to_lower()
  if banned_words.has(test_string):
    return true
  for banned_word in banned_words:
    if test_string.contains(banned_word):
      return true
  return false


func _load_from_file():
  var file = FileAccess.open(_get_file_path(), FileAccess.READ)
  if file:
    while !file.eof_reached():
      banned_words.append(file.get_line().to_lower())
    file.close()

func _get_file_path() -> String:
  if OS.has_feature("editor"):
    return "res://".path_join(FILE_NAME)
  return OS.get_executable_path().get_base_dir().path_join(FILE_NAME)