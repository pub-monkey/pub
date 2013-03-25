Strict

Private
Import math

Public
Class Color
Public
	Global BLACK:Color = New ImmutableColor(0, 0, 0, 1)
	Global RED:Color = New ImmutableColor(255, 0, 0, 1)
	Global GREEN:Color = New ImmutableColor(0, 255, 0, 1)
	Global BLUE:Color = New ImmutableColor(0, 0, 255, 1)
	Global YELLOW:Color = New ImmutableColor(255, 255, 0, 1)
	Global CYAN:Color = New ImmutableColor(0, 255, 255, 1)
	Global MAGENTA:Color = New ImmutableColor(255, 0, 255, 1)
	Global WHITE:Color = New ImmutableColor(255, 255, 255, 1)

Private
	Const RGB:Int = 0
	Const HSL:Int = 1
	
	' RGB
	Field red:Int = 255
	Field green:Int = 255
	Field blue:Int = 255
	Field rgbNeedsRecalc:Bool = False
	
	' HSL
	Field hue:Float = 0
	Field saturation:Float = 1
	Field luminance:Float = 1
	Field hslNeedsRecalc:Bool = True

	' common
	Field alpha:Float = 1

	Method HSLtoRGB:Void(force:Bool=False)
		If Not rgbNeedsRecalc And Not force Then Return
		rgbNeedsRecalc = False
		Local r:Float = luminance
		Local g:Float = luminance
		Local b:Float = luminance
		Local v:Float = 0
		If luminance <= 0.5 Then
			v = luminance * (1.0 + saturation)
		Else
			v = luminance + saturation - luminance * saturation
		End
		If v > 0 Then
			Local m:Float = luminance + luminance - v
			Local sv:Float = (v - m) / v
			hue *= 6
			Local sextant:Int = Int(hue)
			Local fract:Float = hue - sextant
			Local vsf:Float = v * sv * fract
			Local mid1:Float = m + vsf
			Local mid2:Float = v - vsf
			
			Select sextant
				Case 0
					r = v
					g = mid1
					b = m

				Case 1
					r = mid2
					g = v
					b = m

				Case 2
					r = m
					g = v
					b = mid1

				Case 3
					r = m
					g = mid2
					b = v

				Case 4
					r = mid1
					g = m
					b = v
				
				Case 5
					r = v
					g = m
					b = mid2
			End
		End
		red = Int(r)
		green = Int(g)
		blue = Int(b)
	End

	Method RGBtoHSL:Void(force:Bool=False)
		If Not hslNeedsRecalc And Not force Then Return
		hslNeedsRecalc = False
		
		' reset to black
		hue = 0
		saturation = 0
		luminance = 0
		
		Local r:Float = red/255.0
		Local g:Float = green/255.0
		Local b:Float = blue/255.0
		' calculate luminance
		Local v:Float = Max(Max(r,g),b)
		Local m:Float = Min(Min(r,g),b)
		luminance = (m + v) / 2.0
		' die if it's black
		If luminance <= 0 Then Return
		
		' precalculate saturation
		Local vm:Float = v - m
		saturation = vm
		' die if it's grey
		If saturation <= 0 Then Return
		
		' finish saturation
		If luminance <= 0.5 Then
			saturation /= v + m
		Else
			saturation /= 2 - v - m
		End
		
		Local r2:Float = (v - r) / vm
		Local g2:Float = (v - g) / vm
		Local b2:Float = (v - b) / vm
		If r = v Then
			If g = m Then hue = 5 + b2 Else hue = 1 - g2
		Elseif g = v Then
			If b = m Then hue = 1 + r2 Else hue = 3 - b2
		Else
			If r = m Then hue = 3 + g2 Else hue = 5 - r2
		End
		hue /= 6.0
	End

Public
	Method New(val1:Float, val2:Float, val3:Float, alpha:Float=-1, colorspace:Int=Color.RGB)
		If colorspace = Color.RGB Then
			SetRGBA(val1, val2, val3, alpha)
		ElseIf colorspace = Color.HSL Then
			SetHSLA(val1, val2, val3, alpha)
		End
	End
	
	Method New(src:Color)
		SetToColor(src)
	End

	Method Red:Int() Property
		HSLtoRGB()
		Return red
	End

	Method Green:Int() Property
		HSLtoRGB()
		Return green
	End

	Method Blue:Int() Property
		HSLtoRGB()
		Return blue
	End

	Method Red:Void(red:Int) Property
		Self.red = red
		hslNeedsRecalc = True
	End

	Method Green:Void(green:Int) Property
		Self.green = green
		hslNeedsRecalc = True
	End

	Method Blue:Void(blue:Int) Property
		Self.blue = blue
		hslNeedsRecalc = True
	End

	Method Alpha:Float() Property
		Return alpha
	End

	Method Alpha:Void(alpha:Float) Property
		Self.alpha = alpha
	End
	
	Method Hue:Float() Property
		RGBtoHSL()
		Return hue
	End

	Method Saturation:Float() Property
		RGBtoHSL()
		Return saturation
	End

	Method Luminance:Float() Property
		RGBtoHSL()
		Return luminance
	End

	Method Hue:Void(hue:Float) Property
		Self.hue = hue
		rgbNeedsRecalc = True
	End

	Method Saturation:Void(saturation:Float) Property
		Self.saturation = saturation
		rgbNeedsRecalc = True
	End

	Method Luminance:Void(luminance:Float) Property
		Self.luminance = luminance
		rgbNeedsRecalc = True
	End
	
	Method SetRGBA:Color(red:Float, green:Float, blue:Float, alpha:Float=-1)
		Self.red = red
		Self.green = green
		Self.blue = blue
		If alpha >= 0 Then Self.alpha = alpha
		RGBtoHSL(True)
		' return self for chaining
		Return Self
	End
	
	Method SetHSLA:Color(hue:Float, saturation:Float, luminance:Float, alpha:Float=-1)
		Self.hue = hue
		Self.saturation = saturation
		Self.luminance = luminance
		If alpha >= 0 Then Self.alpha = alpha
		HSLtoRGB(True)
		' return self for chaining
		Return Self
	End
	
	Method SetToColor:Color(other:Color)
		' RGBA components
		Self.red = other.red
		Self.green = other.green
		Self.blue = other.blue
		Self.alpha = other.alpha
		' HSL components
		Self.hue = other.hue
		Self.saturation = other.saturation
		Self.luminance = other.luminance
		' copy recalc status so that we know we're getting the same color!
		Self.rgbNeedsRecalc = other.rgbNeedsRecalc
		Self.hslNeedsRecalc = other.hslNeedsRecalc
		' return self for chaining
		Return Self
	End
	
	Method Lerp:Void(startValue:Object, endValue:Object, progress:Float)
		Local startColor:Color = Color(startValue)
		Local endColor:Color = Color(endValue)
		If Not startColor Or Not endColor Then Return
		Self.Hue = startColor.Hue + (endColor.Hue-startColor.Hue) * progress
		Self.Saturation = startColor.Saturation + (endColor.Saturation-startColor.Saturation) * progress
		Self.Luminance = startColor.Luminance + (endColor.Luminance-startColor.Luminance) * progress
	End
End

Class ImmutableColor Extends Color
Public
	Method New(val1:Float, val2:Float, val3:Float, alpha:Float=-1, colorspace:Int=Color.RGB)
		If colorspace = Color.RGB Then
			Super.SetRGBA(val1, val2, val3, alpha)
		Elseif colorspace = Color.HSL Then
			Super.SetHSLA(val1, val2, val3, alpha)
		End
	End
	
	Method Red:Void(red:Int) Property
	End

	Method Green:Void(green:Int) Property
	End

	Method Blue:Void(blue:Int) Property
	End
	
	Method Hue:Void(hue:Float) Property
	End

	Method Saturation:Void(saturation:Float) Property
	End

	Method Luminance:Void(luminance:Float) Property
	End
	
	Method SetRGBA:Color(red:Float, green:Float, blue:Float, alpha:Float=-1)
		Return Self
	End
	
	Method SetHSLA:Color(hue:Float, saturation:Float, luminance:Float, alpha:Float=-1)
		Return Self
	End
	
	Method SetToColor:Color(other:Color)
		Return Self
	End
	
	Method Lerp:Void(startValue:Object, endValue:Object, progress:Float)
	End
End
