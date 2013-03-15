Strict

'this is a monkey list but allows you to use custom sort callbacks to order the items in your list.
'a good example of usage would be to sort your game sprites by zorder.
'monkey by default requires that you create a custom list class per sorting method. So you could
'only ever have one speciffic sort routine per list. This module adds a new method SortBy to the 
'list and that lets you pass in an instance of SortableListCallback.
'You should Extend SortableListCallback to add custom sort routines.

'version 1
'- created basic sortable list

'imports
Import monkey.list

'classes
Class SortableList<T> Extends List<T>
	Field callback:SortableListCallback<T>
	
	'api
	Method Compare:Int(a:T, b:T)
		' --- use the callback if its set ---
		'if there is a callback let it do the sorting
		If callback Return callback.Compare(a, b)
		
		'default action
		Return 0
	End
	
	Method SortBy:Void(callback:SortableListCallback<T>, ascending:Bool = True)
		' --- sort with a provided callback ---
		Self.callback = callback
		Super.Sort(ascending)
		Self.callback = Null
	End
End

Class SortableListCallback<T> Abstract
	Method Compare:Int(a:T, b:T) Abstract
End