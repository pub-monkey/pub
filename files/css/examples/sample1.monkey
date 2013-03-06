Strict
Import mojo
Import css

'Make sure you allow css files
#TEXT_FILES="*.txt|*.css|*.xml"

Function Main:Int()
	New CssTestApp
	Return 0
End

Class CssTestApp Extends App

	Method OnCreate:Int()
		SetUpdateRate(30)
		
		'Create a new file and load it
		Local file:CssFile = New CssFile
		Local success:Bool
		success = file.LoadFile("emitter.css")
		If Not success
			Error("Could not load fire.css")
		End
		
		'Get a property directly
		Print file.Get("Emitter1", "type")
		
		'For faster lookup create a temporary element
		Local element:CssElement = file.GetElementById("Emitter1")
		
		'Now we can use this element to get other properties
		Print element.Get("maxRadius")
		Print element.Get("minRadius")
		
		'We can directly convert to Int or Float & provide a default value when the property does not exist
		Local emission:Int = element.GetInt("emissionRate", 10) 'emissionRate will be 10 if property does not exist
		Local sizeX:Float = element.GetFloat("sizeX", 0.5)
		
		'Check if file contains property
		If file.Contains("Emitter2")
			Print "Emitter2 exists!"
		End
		
		'We can also get an aggregation of data/numbers as array
		Local colors:String[] = element.GetArray("color", " ")
		For Local i:Int = 0 Until colors.Length
			Print colors[i]
		Next
		
		'Adding to the file
		file.AddElement("NewOne", ["v1","p1","v2","p2"])
		
		'Changing properties
		element.ChangeProperty("v2", "hello")
		Print file.Get("NewOne", "v2")
		
		'Serializing a single Element
		Print "~n-------> Serialize Emitter2 <-------"
		Print file.GetElementById("Emitter2").ToString()
		
		'Serializing the whole file
		Print "~n-------> Serialize file <-------"
		Print file.ToString()
		
		'Get all elements of the file
		Print "~n-------> All elements of the file <-------"
		Local elements:CssElement[] = file.GetElements()
		For Local i:Int = 0 Until elements.Length
			Print elements[i].id
		Next
		
		'Get all properties of an element
		Print "~n-------> All properties of Emitter1 <-------"
		Local properties:String[] = file.GetElementById("Emitter1").GetProperties()
		For Local i:Int = 0 Until properties.Length
			Print properties[i]
		Next
		
		Return 0
	End
	
End
