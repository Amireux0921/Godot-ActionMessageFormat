##基本上用不到,但已实现
class_name Amf3Array extends AmfType

var StrictDense: Array
var SparseAssociative: Dictionary


func ToObject()->Array:
	return self.StrictDense
