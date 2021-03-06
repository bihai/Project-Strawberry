dim shared As integer clr(0 To 15) ' color stuff for the simple gfx renderer
clr(0) = RGB(0,0,0)
clr(1) = RGB(255,255,255)
clr(2) = RGB(136,0,0)
clr(3) = RGB(170,255,238)
clr(4) = RGB(204,68,204)
clr(5) = RGB(0,204,85)
clr(6) = RGB(0,0,170)
clr(7) = RGB(238,238,119)
clr(8) = RGB(221,136,85)
clr(9) = RGB(102,68,0)
clr(10) = RGB(255,119,119)
clr(11) = RGB(51,51,51)
clr(12) = RGB(119,119,119)
clr(13) = RGB(170,255,102)
clr(14) = RGB(0,136,255)
clr(15) = RGB(187,187,187)
Declare Sub dumpmemory
Declare Sub simplegraphics
Declare Sub keycheck


Sub keycheck
	'This  is the keycheck for the "simple" 6502 programs. Basically it's memory mapped IO. This stuff will need to go when we work on NES/Atari/whatever
	If MultiKey(SC_w) Then
		cpu.memory(&hff) = Asc("w")
	elseIf MultiKey(SC_a) Then
		cpu.memory(&hff) = Asc("a")
	elseIf MultiKey(SC_s) Then
		cpu.memory(&hff) = Asc("s")
	elseIf MultiKey(SC_d) Then
		cpu.memory(&hff) = Asc("d")
	elseIf MultiKey(SC_x) Then
		cpu.memory(&hff) = Asc("x")
	Else
		cpu.memory(&hff)=Asc(" ")
	EndIf

	If MultiKey(SC_tilde) Then ' change whether the debug info is displayed or not
		Cls
		If monitor = 1 Then monitor = 0 Else If monitor = 0 Then monitor = 1
		if monitor = 1 then status
		While MultiKey(SC_tilde)
			'nothing
		Wend
	EndIf

	If MultiKey(SC_plus) Then ' increase emulation speed
		opgoal+=500
		While MultiKey(SC_plus)
			'nothing
		Wend
	End If

	If MultiKey(SC_minus) Then 'decrease emulation speed
		opgoal-=500
		While MultiKey(SC_minus)
			'nothing
		Wend
	End If

	If MultiKey(SC_f3)Then  'dump memory
		dumpmemory
		Print "Memory dumped to 6502dump.mem"
		Beep
		Sleep 1000,1
		While MultiKey(SC_F3)
			'nothing
		Wend
	End If

	If MultiKey(SC_f1)Then  'save state
		savestate
		While MultiKey(SC_F1)
			'nothing
		Wend
	End If

	If MultiKey(SC_f2)Then  'load state
		loadstate
		While MultiKey(SC_F2)
			'nothing
		Wend
	End If

End Sub

Sub dumpmemory ' dump memory to 6502dump.mem, for examining with hex or whatever
	Dim As Integer f = FreeFile
	If fileexists("6502dump.mem") Then Kill ("6502dump.mem")
	Open "6502dump.mem" For Binary As #f
	Put #f, 1, cpu.memory()
	Close #f

End Sub


Sub simplegraphics
	'Simple graphics renderer. As with keycheck, this is only useful for the "simple" 6502 machine. The graphics are memory mapped.
	Dim As integer	memcount = -1, sf
	If monitor = 0 Then sf = (screeny/32) Else sf = 8
	Dim As fb.image Ptr simplebuff
	simplebuff = ImageCreate(32*sf,32*sf,RGB(0,0,0))
	For dy As Integer = 1 To 32
		For dx As Integer = 1 To 32
			memcount+=1
			If memcount + &h200 > 1535 Then
				Exit for
			EndIf
			For z As Integer = sf To 1 Step -1
				' Draw a line z number of times to make a giant pixel. This is how we are scaling
				Line simplebuff, (dx*sf-sf,dy*sf-z)-(dx*sf,dy*sf-z), clr(cpu.memory(&h200 + memcount))
			Next
		Next
	next
	Line simplebuff, (0, 0)-(32*sf-1, 32*sf-1), RGB(255,255,255), b ' draw the box around the graphic area
	If monitor = 1 Then Put (screenx-(32*sf)-25,screeny-(32*sf)-25), simplebuff, _ 'long line break
	PSet Else Put ((screenx/2)-((sf*32)/2),0),simplebuff,PSet ' put the image buffer to screen
	ImageDestroy(simplebuff) ' Get rid of the buffer, or else memory leaks!
End Sub
