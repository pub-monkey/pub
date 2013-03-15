Strict

Import sortablelist

'basic item class
Class Item
	Field id:String
	Field zOrder:Int
	
	Method New(id:String, zOrder:Int)
		Self.id = id
		Self.zOrder = zOrder
	End
End

'our custom sort function
Class SortItemsByZOrder Extends SortableListCallback<Item>
	'create a global instance of this to pass to the list sort method
	Global instance:= New SortItemsByZOrder
	
	'compare method
	Method Compare:Int(a:Item, b:Item)
		If a.zOrder > b.zOrder Return 1
		If a.zOrder = b.zOrder Return 0
		Return -1
	End
End

'main program code
Function Main:Int()
	'create a list
	Local list:= New SortableList<Item>
	
	'add some items
	list.AddLast(New Item("item1", 999))
	list.AddLast(New Item("item2", 60))
	list.AddLast(New Item("item3", 2))
	list.AddLast(New Item("item4", -10))
	list.AddLast(New Item("item5", 4))
	
	'print list of items in order
	Print "[before]"
	For Local item:= EachIn list
		Print "- " + item.id + " [zOrder: " + item.zOrder + "]"
	Next
	Print ""
	
	'sort the list by zOrder
	list.SortBy(SortItemsByZOrder.instance, True)
	
	'print list of items in NEW order
	Print "[after]"
	For Local item:= EachIn list
		Print "- " + item.id + " [zOrder: " + item.zOrder + "]"
	Next
	
	Return 0
End