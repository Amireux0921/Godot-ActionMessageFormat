class_name ActionMessageFormat extends Object

enum AmfType
{
	AMF0_OBJECT_ENCODING = 0,
	AMF3_OBJECT_ENCODING = 3,
	UNKNOWN_CONTENT_LENGTH = 1,
	UINT29_MASK = 536870911,
	INT29_MAX_VALUE = 268435455,
	INT29_MIN_VALUE = -268435456,
	UINT_MAX_VALUE = 4294967295,
	UINT_MIN_VALUE = 0,
	AMF0_STRING_MAX_LENGTH = 65535,
	
	MAX_STORED_OBJECTS = 1024,
	POW_2_20 = 2 ^ 20,
	POW_2_52  = 2 ^ 52,
	POW_2_52N = 2 ^ -52
}

const CLASS_ALIAS = 			'_explicitType'
const EXTERNALIZED_FIELD =		'_externalizedData'

const RESULT_METHOD =       	'/onResult'
const STATUS_METHOD = 			'/onStatus'

const NULL_STRING = 			'null'
