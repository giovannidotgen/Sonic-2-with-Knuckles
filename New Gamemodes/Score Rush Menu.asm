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
	move.b	#MusID_2PResult,d0
	jsrto	PlayMusic, JmpTo_PlayMusic

; initialize text
	move.w	#4,(Vscroll_Factor_FG).w	; Align text vertically
	moveq	#0,d6
	
Menu_Update:
	dmaFillVRAM 0,VRAM_Plane_A_Name_Table,VRAM_Plane_Table_Size	; Clear Plane A pattern name table

	moveq	#0,d0
	move.b	(MainMenu_Screen).w,d0
	add.b	d0,d0
	move.w	MainMenu_InitIndex(pc,d0.w),d1
	jsr		MainMenu_InitIndex(pc,d1.w)

	cmpi.l	#"UPDT",d6
	beq.s	Menu_Loop
	
; wait one frame
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint

; enable the VDP planes
	move.w	(VDP_Reg1_val).w,d0
	ori.b	#$40,d0
	move.w	d0,(VDP_control_port).l

; fade from black (standard)
	bsr.w	Pal_FadeFromBlack

Menu_Loop:
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint
	lea	(Anim_SonicMilesBG).l,a2
	jsrto	Dynamic_Normal, JmpTo2_Dynamic_Normal	
	bra.w	MainMenu_Controls	; manipulates stack
	; MainMenu_Controls doubles as the loop's "rts", returning to whatever address is
	; placed in the stack during execution

; End of function ScoreRushMenu.

; ===========================================================================
; Index for the main menu's text initialization routines.
; ===========================================================================

MainMenu_InitIndex:
	dc.w	TextInit_GameSel-MainMenu_InitIndex		; Gamemode selection
	dc.w	TextInit_Settings-MainMenu_InitIndex	; Settings
	dc.w	TextInit_CharSel-MainMenu_InitIndex		; Character Select - Score Rush

; ===========================================================================
; Text initialization routines
; ===========================================================================	

; Gamemode selection	
TextInit_GameSel:	
	bsr.w	GameSel_Headings
	bra.w	GameSel_Selections

; Settings menu
TextInit_Settings:
	bra.w	Settings_Init
	
TextInit_CharSel:
	rts
	
; ===========================================================================
; Controls subroutine: Main Menu
; ===========================================================================

MainMenu_Controls:

		pea		(Menu_Loop).l

		moveq	#0,d0		
		move.b	(MainMenu_Screen).w,d0
		add.b	d0,d0
		move.w	MenuCtrls_Index(pc,d0.w),d1
		jmp		MenuCtrls_Index(pc,d1.w)

; ===========================================================================
; Index for the various main menu control schemes
; ===========================================================================

MenuCtrls_Index:
		dc.w	GameSel_Controls-MenuCtrls_Index
		dc.w	Settings_Controls-MenuCtrls_Index
		dc.w	CharSel_Controls-MenuCtrls_Index

; ===========================================================================

CharSel_Controls:
		rts

; ===========================================================================

Settings_GoBack:
		move.w	#4,(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#SndID_Checkpoint,d0
		jmp		PlaySound	

Settings_Controls:
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands
		andi.b  #$90,d1            ; is start or B being pressed?
		bne.s   Settings_GoBack	
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands		
		andi.b	#$C,d1		; is left/right pressed and held?
		bne.s	Settings_LeftRight	; if yes, branch
		move.b	(Ctrl_1_Press).w,d1
		andi.b	#3,d1		; is up/down pressed and held?
		bne.s	Settings_UpDown	; if yes, branch
		subq.w	#1,(LevSel_HoldTimer).w ; subtract 1 from time	to next	move
		bpl.w	Settings_NoInput	; if time remains, branch

Settings_UpDown:
		move.w	#$B,(LevSel_HoldTimer).w ; reset time delay
		move.b	(Ctrl_1_Held).w,d1
		andi.b	#3,d1		; is up/down pressed?
		beq.s	Settings_NoInput	; if not, branch
		move.w	(Options_menu_box).w,d0
		btst	#0,d1		; is up	pressed?
		beq.s	Settings_Down	; if not, branch
		subq.w	#1,d0		; move up 1 selection
		bcc.s	Settings_Down
		moveq	#9,d0		; if selection moves below 0, jump to selection

Settings_Down:
		btst	#1,d1		; is down pressed?
		beq.s	Settings_FullRefresh	; if not, branch
		addq.w	#1,d0		; move down 1 selection
		cmpi.w	#10,d0
		bcs.s	Settings_FullRefresh
		moveq	#0,d0		; if selection moves above 6, jump to selection 0
		
Settings_FullRefresh:
		move.w	d0,(Options_menu_box).w ; set new selection
		bra.w	Settings_Init 			; refresh option names
Settings_PartialRefresh:
		move.b  d5,(a2)		
		bra.w	Settings_Values
		; move.w	#$CD,d0
		; jsr	(PlaySound_Special).l ;	play "blip" sound		
	
Settings_NoInput:
		rts	

Settings_LeftRight:	
		lea     Settings_Data,a3    
		move.w  (Options_menu_box).w,d2        ; load choice number		
		mulu.w  #6,d2                   ; multiply the selected line number by 6
		adda.l  d2,a3                   ; select correct option to work with
		movea.l	(a3),a2
		move.b  $4(a3),d3
		move.b  $5(a3),d4
		move.b  (a2),d5
		btst	#2,d1		; is left pressed?
		beq.s	Settings_Right	; if not, branch
		subq.b	#1,d5		; subtract 1 to selection
		cmp.b   d3,d5
		bge.s	Settings_Right
		move.b  d4,d5     
		
Settings_Right:
		btst	#3,d1		; is right pressed?
		beq.s	Settings_PartialRefresh	; if not, branch
		addq.b	#1,d5	; add 1 selection
		cmp.b	d4,d5
		ble.s	Settings_PartialRefresh
		move.b	d3,d5	
		bra.s   Settings_PartialRefresh	

; ===========================================================================

Settings_Data:
		dc.l	Option_AirSpeedCap
		dc.b	0,1
		
		dc.l	Option_RollJumpLock
		dc.b	0,1

		dc.l	Option_SlowDucking
		dc.b	0,1

		dc.l	Option_PeelOut
		dc.b	0,1

		dc.l	Option_DropDash
		dc.b	0,1

		dc.l	Option_InstaShield
		dc.b	0,1

		dc.l	Option_Flight
		dc.b	0,1	
		
		dc.l	Option_FlightCancel
		dc.b	0,1

		dc.l	Option_BulletDeflect
		dc.b	0,1

		dc.l	Option_PenaltySystem
		dc.b	0,1
		
; ===========================================================================

GameSel_Controls:
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands
		andi.b  #$C0,d1            ; is start or A being pressed?
		bne.s   GameSel_StartEvents
		move.b	(Ctrl_1_Press).w,d1
		andi.b	#3,d1		; is up/down pressed and held?
		bne.s	GameSel_UpDown	; if yes, branch
		subq.w	#1,(LevSel_HoldTimer).w ; subtract 1 from time	to next	move
		bpl.w	GameSel_NoInput	; if time remains, branch

GameSel_UpDown:
		move.w	#$B,(LevSel_HoldTimer).w ; reset time delay
		move.b	(Ctrl_1_Held).w,d1
		andi.b	#3,d1		; is up/down pressed?
		beq.s	GameSel_NoInput	; if not, branch
		move.w	(Options_menu_box).w,d0
		btst	#0,d1		; is up	pressed?
		beq.s	GameSel_Down	; if not, branch
		subq.w	#1,d0		; move up 1 selection
		bcc.s	GameSel_Down
		moveq	#6,d0		; if selection moves below 0, jump to selection	5.

GameSel_Down:
		btst	#1,d1		; is down pressed?
		beq.s	GameSel_Refresh	; if not, branch
		addq.w	#1,d0		; move down 1 selection
		cmpi.w	#$7,d0
		bcs.s	GameSel_Refresh
		moveq	#0,d0		; if selection moves above 6, jump to selection 0
		
GameSel_Refresh:
		move.w	d0,(Options_menu_box).w ; set new selection
		bsr.w	GameSel_Selections ; refresh option names
		; move.w	#$CD,d0
		; jsr	(PlaySound_Special).l ;	play "blip" sound		
	
GameSel_NoInput:
		rts	

GameSel_StartEvents:
		moveq	#0,d0				; clear d0
		moveq	#0,d1
		move.w	(Options_menu_box).w,d0	; check input
		add.w	d0,d0				; double the amount contained in d0
		move.w	.StartEvents_Index(pc,d0.w),d1	; fetch the index
		jmp	.StartEvents_Index(pc,d1.w)			; jump to the appropriate instruction
		
; ===========================================================================
.StartEvents_Index:	dc.w GameSel_ScoreRush-.StartEvents_Index		; Score Rush
		dc.w .Start_Null-.StartEvents_Index		; Endless Rush
		dc.w .Start_Null-.StartEvents_Index	; Quick Rush
		dc.w .Start_Null-.StartEvents_Index		; Instructions
		dc.w GameSel_Settings-.StartEvents_Index	     	; Settings
		dc.w .Start_Null-.StartEvents_Index		; Leaderboards
		dc.w .Start_Null-.StartEvents_Index		; View credits
; ===========================================================================		

.Start_Null:
		rts
		
GameSel_Settings:	
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#1,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound
		
GameSel_ScoreRush:	
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#2,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound
	
	; moveq	#0,d0
	; move.w	d0,(Two_player_mode).w
	; move.w	d0,(Two_player_mode_copy).w
    ; if emerald_hill_zone_act_1=0
	; move.w	d0,(Current_ZoneAndAct).w ; emerald_hill_zone_act_1
    ; else
	; move.w	#emerald_hill_zone_act_1,(Current_ZoneAndAct).w
    ; endif

	; move.w	d0,(Current_Special_StageAndAct).w
	; move.w	d0,(Got_Emerald).w
	; move.l	d0,(Got_Emeralds_array).w
	; move.l	d0,(Got_Emeralds_array+4).w

	; move.b	#GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)
	; move.w	#1,(Player_option).w			; get selected character
	; addq.l	#4,sp							; end loop
	; rts
; ===========================================================================
; Subroutine to render the Main menu's headings.
; ===========================================================================

GameSel_Headings:
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

; End of function GameSel_Headings.

; ===========================================================================
; Subroutine to render the Score Rush's main menu.
; ===========================================================================

GameSel_Selections:
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

; End of function GameSel_Selections.

; ===========================================================================
; Subroutine to render the settings menu
; ===========================================================================

Settings_Init:
		pea		(Settings_Values).l

Settings_Selections:
		lea	(TextData_SettingsMenu).l,a1 ; where to fetch the lines from
		move.l	#$41880003,d4	; (CHANGE) starting screen position 
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
		moveq	#9,d1		; number of lines of text to be displayed -1

-
		move.l	d4,4(a6)
		moveq	#19,d2		; number of characters to be rendered in a line -1
		bsr.w	SingleLineRender
		addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line
		dbf	d1,-
		moveq	#0,d0
	
	; calculate where the line to be yellowed out is
		move.w	(Options_menu_box).w,d0		; move the currently selected line to d0
		move.w	d0,d1					; store d0 in d1 for future use
		move.l	#$41880003,d4			; where does the text begin on the screen
		lsl.w	#8,d0					; logical shift by 8 bits (multiply by 8)
		swap	d0						; swap the two words that compose d0
		add.l	d0,d4					; add that to d4, effectively determining where the correct line is
		
	; yellow out the appropriate text of a line in a list of 17 characters	
		lea  	(TextData_SettingsMenu).l,a1	; go to the text's ROM address
		mulu.w	#20,d1
		adda.w	d1,a1					; set address
		move.w	#$C680,d3				; set VRAM address (text but yellow)
		move.l	d4,4(a6)
		moveq	#19,d2		
		bsr.w	SingleLineRender	
		rts							

Settings_Values:
		lea	($C00000).l,a6
		lea Settings_Data,a2  ; options table beginning	
		move.l	#$41C00003,d4	; starting screen position
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
		moveq	#9,d1		; number of lines of text to be displayed -1
		
-
		moveq	#0,d2
		lea	(TextData_OnOff).l,a1 ; where to fetch the text from
;		beq.s   ValueRender_IsZero ; if yes, branch
		movea.l	(a2),a3		  ; get option's RAM location
		move.b  (a3),d2		  ; move the option's current value to d2
		move.b  d2,d0		  ; copy d2 to d0 for future use
		lsl.w   #3,d2         ; multiply the value by 8
		adda.l  d2,a1		  ; finally, add the content of d2 to a1
		move.l	d4,4(a6)
		moveq	#2,d2		; number of characters to be rendered in a line -1	
		bsr.w	SingleLineRender
		addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line
		adda.l  #6,a2
		dbf	d1,-
		
		moveq	#0,d0
	; calculate where the line to be yellowed out is
		move.w	(Options_menu_box).w,d0	; move the currently selected line to d0
		move.w	d0,d1					; store d0 in d1 for future use
		move.l	#$41C00003,d4			; where does the text begin on the screen
		lsl.w	#8,d0					; logical shift by 8 bits
		swap	d0						; swap the two words that compose d0
		add.l	d0,d4					; add that to d4, effectively determining where the correct line is
		
	; determine what text is to be displayed
		lea  	(TextData_OnOff).l,a1	; go to the text's ROM address
;		move.w	d1,d0					; store the value of d1 in d0 for future use
		lea     Settings_Data,a2        ; store this address
		move.w  (Options_menu_box).w,d0			; move the currently selected line to d0
		mulu.w  #6,d0                   ; double that
		adda.w  d0,a2                   ; then move to the correct address
		movea.l	(a2),a3
		move.b  (a3),d1		  ; move the option's current value to d1
		move.b  d1,d0		  ; copy d1 to d0 for future use
		lsl.w   #3,d1         ; multiply the value by 8
		adda.l  d1,a1		  ; finally, add the content of d1 to a1
		move.w	#$C680,d3
		move.l	d4,4(a6)
		moveq	#2,d2					; number of characters to be rendered -1
		bra.w	SingleLineRender		; render one line of text		


; ===========================================================================
; All text data used by this screen.
; ===========================================================================	
TextData_Version:
	dc.b	"SONIC 2 - SCORE RUSH DEVBUILD"
	dc.b	"        NOT FOR PUBLIC ACCESS"
	dc.b	"  ORIGINAL GAME BY SEGA, 1992"
	even
		
TextData_MainMenu:
	dc.b    " SCORE RUSH "
	dc.b    "ENDLESS RUSH"
	dc.b    " QUICK RUSH "
	dc.b    "INSTRUCTIONS"
	dc.b    "  SETTINGS  "
	dc.b    "LEADERBOARDS"
	dc.b    "VIEW CREDITS"
	even
	
TextData_SettingsMenu:
	dc.b	"AIR SPEED CAP       "
	dc.b	"ROLLING JUMP LOCK   "
	dc.b	"SLOW DUCKING        "
	dc.b	"SUPER PEEL-OUT      "
	dc.b	"DROP DASH           "
	dc.b	"INSTA-SHIELD        "
	dc.b	"TAILS FLIGHT        "
	dc.b	"FLIGHT CANCEL       "
	dc.b	"BULLET DEFLECTION   "
	dc.b	"PENALTY SYSTEM      "
	even
	
TextData_OnOff:				
	dc.b    "OFF     "
	dc.b    "ON      "	
	even