##基本上用不到,但已实现
class_name Amf3Array extends IAmfObject

var StrictDense: Array
var SparseAssociative: Dictionary


func ToObject():
	if self.StrictDense.size():
		return self.StrictDense
	else:
		return self.SparseAssociative
