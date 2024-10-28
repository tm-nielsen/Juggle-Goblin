class_name CompletionStatsIO

const FILEPATH = "user://jugghoul_completion_stats.json"


static func get_completions() -> Array[CompletionEntry]:
  var file_contents = _read_file()
  if file_contents:
    var completions: Array[CompletionEntry] = []
    for json_entry in file_contents:
      completions.append(CompletionEntry.parse_json(json_entry))
    return completions
  return [] as Array[CompletionEntry]


static func append_completion(name: String, game_time: float, deaths: int):
  var completions = get_completions()
  var completion_entry = CompletionEntry.new(name, game_time, deaths)
  completions.append(completion_entry)
  _write_file(completions)


static func _read_file() -> Array:
  if FileAccess.file_exists(FILEPATH):
    var file = FileAccess.open(FILEPATH, FileAccess.READ)
    var text_content = file.get_as_text()

    var json = JSON.new()
    var error = json.parse(text_content)

    file.close()
    if error == OK:
      return json.data
    else:
      push_error('JSON Parse Error: ', json.get_error_message(), ' on line ', json.get_error_line())
      return []
  else:
    _write_file([])
    return []


static func _write_file(completion_entries: Array[CompletionEntry]):
  var dictionary_entries = []
  for entry in completion_entries:
    dictionary_entries.append(entry.get_dictionary())
  
  var file_string = JSON.stringify(dictionary_entries, '\t')
  var file = FileAccess.open(FILEPATH, FileAccess.WRITE)
  file.store_string(file_string)
  file.close()


class CompletionEntry:
  var name: String
  var date: int
  var game_time: float
  var deaths: int

  func _init(p_name: String = "", p_game_time: float = 0, p_deaths: int = 0):
    name = p_name
    date = floor(Time.get_unix_time_from_system())
    game_time = p_game_time
    deaths = p_deaths

  func get_dictionary() -> Dictionary:
    return {
      'name': name,
      'date': date,
      'game_time': game_time,
      'deaths': deaths
    }

  static func parse_json(json_source: Dictionary) -> CompletionEntry:
    var new_entry = CompletionEntry.new()
    new_entry.name = json_source.name
    new_entry.date = json_source.date
    new_entry.game_time = json_source.game_time
    new_entry.deaths = json_source.deaths
    return new_entry