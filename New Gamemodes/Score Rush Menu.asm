; ===========================================================================
; The main menu from Sonic 2 - Score Rush.
; ===========================================================================

ScoreRushMenu:

	bsr.w	Pal_FadeToBlack
	move	#$2700,sr
	move.w	(VDP_Reg1_val).w,d0
	andi.b	#$BF,d0
	move.w	d0,(VDP_control_port).l
	jsr		ClearScreen
	lea	(VDP_control_port).l,a6
	move.w	#$8004,(a6)		; H-INT disabled
	move.w	#$8200|(VRAM_Menu_Plane_A_Name_Table/$400),(a6)		; PNT A base: $C000
	move.w	#$8400|(VRAM_Menu_Plane_B_Name_Table/$2000),(a6)	; PNT B base: $E000
	move.w	#$8200|(VRAM_Menu_Plane_A_Name_Table/$400),(a6)		; PNT A base: $C000
	move.w	#$8700,(a6)		; Background palette/color: 0/0
	move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled
	move.w	#$9001,(a6)		; Scroll table size: 64x32

	clearRAM Sprite_Table_Input,Sprite_Table_Input_End
	clearRAM Object_RAM,Object_RAM_End

	clr.w	(VDP_Command_Buffer).w								; Initialize DMA Queue RAM
	move.l	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w		

; Load background graphics	
	move.l	#vdpComm(tiles_to_bytes(ArtTile_ArtNem_FontStuff),VRAM,WRITE),(VDP_control_port).l
	lea	(ArtNem_FontStuff).l,a0									; Background graphics from Sonic 2
	jsr		NemDec

; load Sonic 2 ASCII graphics (uncompressed)
	lea		(VDP_data_port).l,a6
	move.l	#$50000003,4(a6)			; set VRAM write address
	lea		(Art_Font).l,a5			; fetch the text graphics
	move.w	#$39F,d1					; amount of data to be loaded

-
	move.w	(a5)+,(a6)					; load the text
	dbf	d1,- 			; repeat until done	

; load background mappings
	lea	(Chunk_Table).l,a1
	lea	(MapEng_MenuBack).l,a0
	move.w	#make_art_tile(ArtTile_VRAM_Start,3,0),d0
	jsr		EniDec
		
; place them in VRAM		
	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_Plane_B_Name_Table,VRAM,WRITE),d0
	moveq	#$27,d1
	moveq	#$1B,d2
	jsrto	PlaneMapToVRAM_H40, JmpTo_PlaneMapToVRAM_H40	; fullscreen background

; clear a bunch of variables
	clr.b	(LevSel_HoldTimer).w
	clr.b	(Options_menu_box).w
	clr.b	(Level_started_flag).w
	clr.w	(Anim_Counters).w
	clr.w	(Two_player_mode).w
	clr.l	(Camera_X_pos).w
	clr.l	(Camera_Y_pos).w
	clr.w	(Correct_cheat_entries).w
	clr.w	(Correct_cheat_entries_2).w

; initialize the Sonic-Miles BG	
	lea	(Anim_SonicMilesBG).l,a2
	jsrto	Dynamic_Normal, JmpTo2_Dynamic_Normal

; get palette data
	moveq	#PalID_Menu,d0
	bsr.w	PalLoad_ForFade
	
	lea		(Pal_SplashText).l,a1
	lea		(Target_palette+$20).l,a2
	moveq	#$F,d0
	
-
	move.l	(a1)+,(a2)+
	dbf		d0,-
	

; get music
	move.b	#MusID_Options,d0
	jsrto	PlayMusic, JmpTo_PlayMusic

; initialize text
	move.w	#4,(Vscroll_Factor_FG).w	; Align text vertically
	bsr.w	TextRender_Headings
	bsr.w	TextRender_MainMenu

; wait one frame
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint

; enable the VDP planes
	move.w	(VDP_Reg1_val).w,d0
	ori.b	#$40,d0
	move.w	d0,(VDP_control_port).l

; fade from black (standard)
	bsr.w	Pal_FadeFromBlack

.Menu_Loop:
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint
	lea	(Anim_SonicMilesBG).l,a2
	jsrto	Dynamic_Normal, JmpTo2_Dynamic_Normal	
	bsr.w	MainMenu_Controls
	bra.w	.Menu_Loop


; End of function ScoreRushMenu.

; ===========================================================================
; Controls subroutine: Main Menu
; ===========================================================================

MainMenu_Controls:
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands
		andi.b  #$C0,d1            ; is start or A being pressed?
		bne.s   MainMenu_StartEvents
		move.b	(Ctrl_1_Press).w,d1
		andi.b	#3,d1		; is up/down pressed and held?
		bne.s	MainMenu_UpDown	; if yes, branch
		subq.w	#1,(LevSel_HoldTimer).w ; subtract 1 from time	to next	move
		bpl.w	MainMenu_NoInput	; if time remains, branch

MainMenu_UpDown:
		move.w	#$B,(LevSel_HoldTimer).w ; reset time delay
		move.b	(Ctrl_1_Held).w,d1
		andi.b	#3,d1		; is up/down pressed?
		beq.s	MainMenu_NoInput	; if not, branch
		move.w	(Options_menu_box).w,d0
		btst	#0,d1		; is up	pressed?
		beq.s	MainMenu_Down	; if not, branch
		subq.w	#1,d0		; move up 1 selection
		bcc.s	MainMenu_Down
		moveq	#6,d0		; if selection moves below 0, jump to selection	5.

MainMenu_Down:
		btst	#1,d1		; is down pressed?
		beq.s	MainMenu_Refresh	; if not, branch
		addq.w	#1,d0		; move down 1 selection
		cmpi.w	#$7,d0
		bcs.s	MainMenu_Refresh
		moveq	#0,d0		; if selection moves above 6, jump to selection 0
		
MainMenu_Refresh:
		move.w	d0,(Options_menu_box).w ; set new selection
		bsr.w	TextRender_MainMenu ; refresh option names
		; move.w	#$CD,d0
		; jsr	(PlaySound_Special).l ;	play "blip" sound		
	
MainMenu_NoInput:
		rts	

MainMenu_StartEvents:
		moveq	#0,d0				; clear d0
		moveq	#0,d1
		move.w	(Options_menu_box).w,d0	; check input
		add.w	d0,d0				; double the amount contained in d0
		move.w	.StartEvents_Index(pc,d0.w),d1	; fetch the index
		jmp	.StartEvents_Index(pc,d1.w)			; jump to the appropriate instruction
		
; ===========================================================================
.StartEvents_Index:	dc.w MainMenu_ScoreRush-.StartEvents_Index		; Score Rush
		dc.w .Start_Null-.StartEvents_Index		; Endless Rush
		dc.w .Start_Null-.StartEvents_Index	; Quick Rush
		dc.w .Start_Null-.StartEvents_Index		; Instructions
		dc.w .Start_Null-.StartEvents_Index	     	; Settings
		dc.w .Start_Null-.StartEvents_Index		; Leaderboards
		dc.w .Start_Null-.StartEvents_Index		; View credits
; ===========================================================================		

.Start_Null:
		rts
		
MainMenu_ScoreRush:		
	moveq	#0,d0
	move.w	d0,(Two_player_mode).w
	move.w	d0,(Two_player_mode_copy).w
    if emerald_hill_zone_act_1=0
	move.w	d0,(Current_ZoneAndAct).w ; emerald_hill_zone_act_1
    else
	move.w	#emerald_hill_zone_act_1,(Current_ZoneAndAct).w
    endif

	move.w	d0,(Current_Special_StageAndAct).w
	move.w	d0,(Got_Emerald).w
	move.l	d0,(Got_Emeralds_array).w
	move.l	d0,(Got_Emeralds_array+4).w

	move.b	#GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)
	move.w	#1,(Player_option).w			; get selected character
	addq.l	#4,sp							; end loop
	rts
; ===========================================================================
; Subroutine to render the Main menu's headings.
; ===========================================================================

TextRender_Headings:
;	lea	(VDP_data_port).l,a6
	
	lea	(TextData_Version).l,a1 ; where to fetch the lines from
	lea	($C00000).l,a6
	move.l	#$4C120003,d4	; starting screen position
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#2,d1		; number of lines of text to be displayed -1

-:		
	move.l	d4,4(a6)
	moveq	#28,d2		; number of characters to be rendered in a line -1	
	bsr.w	SingleLineRender
	addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,-

	rts

; End of function TextRender_Headings.

; ===========================================================================
; Subroutine to render the Score Rush's main menu.
; ===========================================================================

TextRender_MainMenu:
		lea	(TextData_MainMenu).l,a1 ; where to fetch the lines from
		move.l	#$441C0003,d4	; (CHANGE) starting screen position 
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
		moveq	#6,d1		; number of lines of text to be displayed -1

-
		move.l	d4,4(a6)
		moveq	#11,d2		; number of characters to be rendered in a line -1
		bsr.w	SingleLineRender
		addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line
		dbf	d1,-
		moveq	#0,d0
	
	; calculate where the line to be yellowed out is
		move.w	(Options_menu_box).w,d0		; move the currently selected line to d0
		move.w	d0,d1					; store d0 in d1 for future use
		move.l	#$441C0003,d4			; where does the text begin on the screen
		lsl.w	#8,d0					; logical shift by 8 bits (multiply by 8)
		swap	d0						; swap the two words that compose d0
		add.l	d0,d4					; add that to d4, effectively determining where the correct line is
		
	; yellow out the appropriate text of a line in a list of 17 characters	
		lea  	(TextData_MainMenu).l,a1	; go to the text's ROM address
		move.w	d1,d0					; store the value of d1 in d0 for future use
		lsl.w	#3,d1					; shift to the left by 3 bits (d1 * 8)
	;	add.w	d1,d1
		lsl.w   #2,d0                 	; shift to the left by 2 bits (d0 * 4)
		add.w	d0,d1					; add whatever is in d0 to d1 to fix misalignment (d1 + d2 = $FFFFFF82 * 12)
		adda.w	d1,a1					; set address
		move.w	#$C680,d3				; set VRAM address (text but yellow)
		move.l	d4,4(a6)
		moveq	#11,d2		
		bsr.w	SingleLineRender	
		rts					

; End of function TextRender_MainMenu.

; ===========================================================================
; All text data used by this screen.
; ===========================================================================	
TextData_Version:
	dc.b	"SONIC 2 - SCORE RUSH DEVBUILD"
	dc.b	"        NOT FOR PUBLIC ACCESS"
	dc.b	"  ORIGINAL GAME BY SEGA, 1992"
	
TextData_MainMenu:
	dc.b    " SCORE RUSH "
	dc.b    "ENDLESS RUSH"
	dc.b    " QUICK RUSH "
	dc.b    "INSTRUCTIONS"
	dc.b    "  SETTINGS  "
	dc.b    "LEADERBOARDS"
	dc.b    "VIEW CREDITS"