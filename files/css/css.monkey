Strict
Import mojo.app


Class CssFile

'--------------------------------------------------------------------------
' * Constructors
'--------------------------------------------------------------------------
	Method New()
		Elements = New StringMap<CssElement>
	End
	
	Method New(path:String)
		Elements = New StringMap<CssElement>
		LoadFile(path)
	End
	

'--------------------------------------------------------------------------
' * File Loading
'--------------------------------------------------------------------------
	Method LoadFile:Bool(path:String)
		Local file:String = app.LoadString(path)
		Return LoadFromString(file)
	End
	
	Method LoadFromString:Bool(file:String)
		If file.Length < 3
			Return False
		End

		Local startIndex:Int
		Local endIndex:Int = -1
		Local name:String
		Local props:String
		Local match:Int

		Local prop:String
		Local value:String
		Local block:CssElement
		
		While True
			startIndex = MatchChar (file, START_BRACKET, endIndex)
			name = file[endIndex+1..startIndex].Trim()
			endIndex = MatchChar (file, END_BRACKET, startIndex)
			
			If startIndex = -1
				Exit
			End
			
			block = New CssElement (name)
			Elements.Add (name, block)
			props = TrimDown (file[startIndex+1..endIndex])
			
			Local lastIndex:Int = 0
			While True
				match = MatchChar (props, COLON, lastIndex)
				If match = -1
					Exit
				End
				prop = props[lastIndex..match]
				lastIndex = match + 1
				
				match = MatchChar (props, SEMICOLON, lastIndex)
				If match = -1
					Exit
				End
				value = props[lastIndex..match]
				lastIndex = match + 1
				block.AddProperty (prop, value)
			End
		End
		
		Return True
	End


'--------------------------------------------------------------------------
' * Getter
'--------------------------------------------------------------------------
	Method Get:String(id:String, prop:String)
		Local block:CssElement = Elements.Get(id)
		If block
			Return block.Properties.Get(prop)
		End
		Return ""
	End
	
	Method GetElementById:CssElement(id:String)
		Return Elements.Get(id)
	End
	
	Method GetElements:CssElement[]()
		Local buffer:Stack<CssElement> = New Stack<CssElement>
		Local element:CssElement
		For element = EachIn Elements.Values()
			buffer.Push(element)
		Next
		Return buffer.ToArray()
	End
	
	Method Contains:Bool(id:String)
		Return Elements.Contains(id)
	End
	

	Method AddElement:Void(id:String, properties:String[])
		Local element:CssElement = GetElementById(id)
		If element Or (properties.Length = 0) Or (properties.Length Mod 2 <> 0)
			Return
		End
		element = New CssElement(id)
		For Local i:Int = 0 Until properties.Length/2
			element.AddProperty(properties[i*2], properties[i*2+1])
		Next
		Elements.Add(id, element)
	End
	
	Method ToString:String()
		Local buffer:StringStack = New StringStack
		Local element:CssElement
		For element = EachIn Elements.Values()
			buffer.Push(element.ToString())
		Next
		Return buffer.Join("")
	End
	
	
	Private
	Field Elements:StringMap<CssElement>
	
	Function TrimDown:String (text:String)
		Local newText:String
		Local char:Int
		For Local i:Int = 0 Until text.Length
			char = text[i]
			If (char <> CssFile.TAB) And (char <> CssFile.NEWLINE)
				newText += String.FromChar (char)
			End
		End
		Return newText
	End
	
	Function MatchChar:Int (text:String, char:Int, startPos:Int)
		For Local i:Int = startPos Until text.Length
			If text[i] = char
				Return i
			End
		End
		Return -1
	End
	
	Const START_BRACKET:Int = 123
	Const END_BRACKET:Int   = 125
	Const SEMICOLON:Int     = 59
	Const NEWLINE:Int       = 10
	Const WHITESPACE:Int    = 32
	Const TAB:Int           = 9
	Const COLON:Int         = 58
	
End



Class CssElement
	
	Field id:String
	
'--------------------------------------------------------------------------
' * Constructor + Add/Change
'--------------------------------------------------------------------------
	Method New(id:String)
		Self.id = id
		Properties = New StringMap<String>
	End
	
	Method AddProperty:Void(propName:String, value:String)
		Properties.Add(propName, value)
	End
	
	Method ChangeProperty:Void(propName:String, newValue:String)
		Properties.Update(propName, newValue)
	End
	
	
'--------------------------------------------------------------------------
' * Getter
'--------------------------------------------------------------------------
	Method Get:String(propName:String)
		Return Properties.Get(propName)
	End
	
	Method GetInt:Int(propName:String, defaultValue:Int = 0)
		Local value:String = Properties.Get (propName)
		If (value.Length = 0)
			Return defaultValue
		End
		Return Int(value)
	End
	
	Method GetFloat:Float(propName:String, defaultValue:Float = 0.0)
		Local value:String = Properties.Get (propName)
		If (value.Length = 0)
			Return defaultValue
		End
		Return Float(value)
	End
	
	Method GetArray:String[](propName:String, delimiter:String = ",", defaultValue:String[] = [""])
		Local value:String = Properties.Get (propName)
		If value.Length = 0
			Return defaultValue
		End
		Local arr:String[] = value.Split (delimiter)
		For Local i:Int = 0 Until arr.Length
			arr[i] = arr[i].Trim()
		Next
		Return arr
	End
	
	Method GetProperties:String[]()
		Local buffer:StringStack = New StringStack
		Local text:String
		For text = EachIn Properties.Keys()
			buffer.Push(text)
		Next
		Return buffer.ToArray()
	End
	
	Method Contains:Bool(propName:String)
		Return Properties.Contains (propName)
	End
	

	Method ToString:String()
		Local buffer:StringStack = New StringStack
		buffer.Push(id + "{")
		Local text:String
		For text = EachIn Properties.Keys()
			buffer.Push(text + ":" + Properties.Get(text) + ";")
		Next
		buffer.Push("}")
		Return buffer.Join("")
	End
	
	Private
	Field Properties:StringMap<String>
End

