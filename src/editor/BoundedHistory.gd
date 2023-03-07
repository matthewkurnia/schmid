class_name BoundedHistory



var arr := []
var pointer := 0
var n := 0
var i := 0
var _bound := 4


func _init(bound: int):
	_bound = bound
	for i in range(_bound):
		arr.append(-1)


func _to_string():
	return str(arr)


func push(elem) -> bool:
	pointer = (pointer + i - n + _bound) % _bound
	n = min(i, n)
	
	arr[pointer] = elem
	pointer = (pointer + 1) % _bound
	var _n = n
	n = min(n + 1, _bound)
	i = n
	return _n == n


func move_forward():
	assert(i < n)
	i = i + 1
	var temp = arr[(pointer + i - n - 1 + _bound) % _bound]
	return temp


func can_move_forward():
	return i < n


func move_backward():
	assert(i > 0)
	var temp = arr[(pointer + i - n - 1 + _bound) % _bound]
	i = i - 1
	return temp


func can_move_backward():
	return i > 0
