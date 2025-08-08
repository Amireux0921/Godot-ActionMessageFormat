class_name DateTime
extends Timer

var Times:Dictionary={"year":1970,"month":1,"day":1,"hour":0,"minute":0,"second":0}

func _init(年:int=1970,月:int=1,日:int=1,时:int=0,分:int=0,秒:int=0) -> void:
	self.Times["year"] = 年
	self.Times["month"] = 月
	self.Times["day"] = 日
	self.Times["hour"] = 时
	self.Times["minute"] = 分
	self.Times["second"] = 秒
