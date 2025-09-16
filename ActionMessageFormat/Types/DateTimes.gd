class_name DateTimes extends ActionMessageFormat

var Times:float

static func current_unix_time()->DateTimes:
	var date = DateTimes.new()
	date.Times = Time.get_unix_time_from_system()
	return date

func _init(Timestamp:float=0) -> void:
	if Timestamp:
		self.Times = Timestamp
	else:
		self.Times = Time.get_unix_time_from_system()

func _to_string() -> String:
	return Time.get_datetime_string_from_unix_time(self.Times,true)
