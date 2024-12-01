class_name TimeUtils

static func is_past(time: int) -> bool:
	return time < Time.get_ticks_msec()

static func wait_for_ms(ms: int) -> int:
	return Time.get_ticks_msec() + ms
