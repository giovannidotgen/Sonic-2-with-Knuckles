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
	
; Load char select graphics	
	move.l	#vdpComm(tiles_to_bytes(ArtTile_ArtNem_MenuBox),VRAM,WRITE),(VDP_control_port).l
	lea	(ArtNem_MenuBox).l,a0									
	jsr		NemDec		
	
; Load char select graphics	
	move.l	#vdpComm(tiles_to_bytes(ArtTile_ArtNem_LevelSelectPics),VRAM,WRITE),(VDP_control_port).l
	lea	(ArtNem_CharSelect).l,a0									
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
	jsr		PlaneMapToVRAM_H40	; fullscreen background

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
	jsr	Dynamic_Normal

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
	jsr		PlayMusic

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
	jsr	Dynamic_Normal
	bra.w	MainMenu_Controls	; manipulates stack
	; MainMenu_Controls doubles as the loop's "rts", returning to whatever address is
	; placed in the stack during execution

; End of function ScoreRushMenu.

; ===========================================================================
; Index for the main menu's text initialization routines.
; ===========================================================================

MainMenu_InitIndex:
	dc.w	TextInit_GameSel-MainMenu_InitIndex			; Gamemode selection
	dc.w	TextInit_Settings-MainMenu_InitIndex		; Settings
	dc.w	TextInit_CharSel-MainMenu_InitIndex			; Character Select - Score Rush
	dc.w	TextInit_CharSel-MainMenu_InitIndex			; Character Select - Endless Rush
	dc.w	TextInit_CharSel-MainMenu_InitIndex			; Character Select - Quick Rush	
	dc.w	TextInit_Instructions-MainMenu_InitIndex	; Instructions Manual
	dc.w	TextInit_QuickRush-MainMenu_InitIndex		; Level Select - Quick Rush

; ===========================================================================
; Text initialization routines
; ===========================================================================	

; Gamemode selection	
TextInit_GameSel:	
	if emerald_hill_zone_act_1=0
	move.w	d0,(Current_ZoneAndAct).w ; emerald_hill_zone_act_1
	else
	move.w	#emerald_hill_zone_act_1,(Current_ZoneAndAct).w
	endif
	clr.w	(QuickRush_MemOption).w

	bsr.w	GameSel_Headings
	bra.w	GameSel_Selections

; Settings menu
TextInit_Settings:
	bra.w	Settings_Init
	
TextInit_CharSel:
	bsr.w	CharSel_Headings
	bsr.w	CharSel_Difficulties
	bra.w	CharSel_LoadPlayer
	
TextInit_Instructions:
	bsr.w	Instructions_Headings
	bra.w	Instructions_PageText
	
TextInit_QuickRush:
	move.w	(QuickRush_MemOption).w,(Options_menu_box).w
	bsr.w	QuickRush_Headings
	bra.w	QuickRush_LevelName
	
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
		dc.w	CharSel_Controls-MenuCtrls_Index
		dc.w	CharSel_Controls-MenuCtrls_Index
		dc.w	Instructions_Controls-MenuCtrls_Index
		dc.w	QuickRush_Controls-MenuCtrls_Index

; ===========================================================================

QuickRush_Start:
		clr.w	(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		move.b	#4,(MainMenu_Screen).w	; set menu
		move.w	#SndID_Checkpoint,d0
		jmp		PlaySound	

QuickRush_GoBack:
		move.w	#2,(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#SndID_Checkpoint,d0
		jmp		PlaySound	
	
QuickRush_Controls:
		btst	#button_B,(Ctrl_1_Press).w
		bne.s	QuickRush_GoBack
		btst	#button_start,(Ctrl_1_Press).w
		bne.s	QuickRush_Start
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands		
		andi.b	#$C,d1		; is left/right pressed and held?
		bne.s	QuickRush_LeftRight	; if yes, branch
		rts	

QuickRush_LeftRight:	
		move.w  (Options_menu_box).w,d2        ; load choice number		
		btst	#2,d1		; is left pressed?
		beq.s	QuickRush_Right	; if not, branch
		subq.w	#1,d2		; subtract 1 to selection
		bpl.s	QuickRush_Right
		move.w  #19,d2     
		
QuickRush_Right:
		btst	#3,d1		; is right pressed?
		beq.s	QuickRush_Refresh	; if not, branch
		addq.w	#1,d2	; add 1 selection
		cmp.w	#19,d2
		ble.s	QuickRush_Refresh
		move.w	#0,d2	
		
QuickRush_Refresh:
		move.w	d2,(Options_menu_box).w
		move.w	(Options_menu_box).w,(QuickRush_MemOption).w
		add.w	d2,d2
		move.w	QuickRush_LevelList(pc,d2.w),(Current_ZoneAndAct).w
		bra.w	QuickRush_LevelName
		
; ===========================================================================
QuickRush_LevelList:
		dc.w	emerald_hill_zone_act_1
		dc.w	emerald_hill_zone_act_2
		dc.w	chemical_plant_zone_act_1
		dc.w	chemical_plant_zone_act_2
		dc.w	aquatic_ruin_zone_act_1
		dc.w	aquatic_ruin_zone_act_2
		dc.w	casino_night_zone_act_1
		dc.w	casino_night_zone_act_2
		dc.w	hill_top_zone_act_1
		dc.w	hill_top_zone_act_2
		dc.w	mystic_cave_zone_act_1
		dc.w	mystic_cave_zone_act_2
		dc.w	oil_ocean_zone_act_1
		dc.w	oil_ocean_zone_act_2
		dc.w	metropolis_zone_act_1
		dc.w	metropolis_zone_act_2
		dc.w	metropolis_zone_act_3
		dc.w	sky_chase_zone_act_1
		dc.w	wing_fortress_zone_act_1
		dc.w	death_egg_zone_act_1
		
; ===========================================================================

Instructions_GoBack:
		moveq	#0,d0
		move.b	(MainMenu_Screen).w,d0
		sub.b	#2,d0
		move.w	d0,(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#SndID_Checkpoint,d0
		jmp		PlaySound	
	
Instructions_Controls:
		btst	#button_B,(Ctrl_1_Press).w
		bne.w	Instructions_GoBack
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands		
		andi.b	#$C,d1		; is left/right pressed and held?
		bne.s	Instructions_LeftRight	; if yes, branch
		rts	

Instructions_LeftRight:	
		move.w  (Options_menu_box).w,d2        ; load choice number		
		btst	#2,d1		; is left pressed?
		beq.s	Instructions_Right	; if not, branch
		subq.w	#1,d2		; subtract 1 to selection
		bpl.s	Instructions_Right
		move.w  #10,d2     
		
Instructions_Right:
		btst	#3,d1		; is right pressed?
		beq.s	Instructions_Refresh	; if not, branch
		addq.w	#1,d2	; add 1 selection
		cmp.w	#10,d2
		ble.s	Instructions_Refresh
		move.w	#0,d2	
		
Instructions_Refresh:
		move.w	d2,(Options_menu_box).w
		bra.w	Instructions_PageText
		rts

; ===========================================================================

CharSel_GoBack:
		clr.w	(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#SndID_Checkpoint,d0
		jmp		PlaySound	

CharSel_BeginGame:
		moveq	#0,d0
		move.b	#1,(Life_count).w
		move.w	d0,(Ring_count).w
		move.l	d0,(Timer).w
		move.l	#500,(Score).w
		move.l	#500,(Score_Saved).w
		clr.b	(Suicide_Flag).w
		move.b	d0,(Continue_count).w		
		move.w	d0,(Two_player_mode).w
		move.w	d0,(Two_player_mode_copy).w

		move.w	d0,(Current_Special_StageAndAct).w
		move.w	d0,(Got_Emerald).w
		move.l	d0,(Got_Emeralds_array).w
		move.l	d0,(Got_Emeralds_array+4).w

		move.b	#GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)
		add.w	#1,(Options_menu_box).w
		move.w	(Options_menu_box).w,(Player_option).w			; get selected character
		move.b	#10,(ScoreRush_TimerSpeed).w
		tst.b	(Option_Difficulty).w
		beq.s	+
		sub.b	#4,(ScoreRush_TimerSpeed).w
+	
		addq.l	#4,sp							; end loop
		rts
	
CharSel_Controls:
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands
		andi.b  #$C0,d1            ; is start or A being pressed?
		bne.w   CharSel_BeginGame	
		btst	#button_B,(Ctrl_1_Press).w
		bne.w	CharSel_GoBack
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands		
		andi.b	#$C,d1		; is left/right pressed and held?
		bne.s	CharSel_LeftRight	; if yes, branch
		move.b	(Ctrl_1_Press).w,d1
		andi.b	#3,d1		; is up/down pressed and held?
		bne.s	CharSel_UpDown	; if yes, branch
		subq.w	#1,(LevSel_HoldTimer).w ; subtract 1 from time	to next	move
		bpl.w	CharSel_NoInput	; if time remains, branch

CharSel_UpDown:
		move.w	#$B,(LevSel_HoldTimer).w ; reset time delay
		move.b	(Ctrl_1_Held).w,d1
		andi.b	#3,d1		; is up/down pressed?
		beq.s	CharSel_NoInput	; if not, branch
		move.b	(Option_Difficulty).w,d0
		btst	#0,d1		; is up	pressed?
		beq.s	CharSel_Down	; if not, branch
		subq.b	#1,d0		; move up 1 selection
		bcc.s	CharSel_Down
		moveq	#1,d0		; if selection moves below 0, jump to selection

CharSel_Down:
		btst	#1,d1		; is down pressed?
		beq.s	CharSel_RefreshDiff	; if not, branch
		addq.b	#1,d0		; move down 1 selection
		cmpi.b	#2,d0
		bcs.s	CharSel_RefreshDiff
		moveq	#0,d0		; if selection moves above 6, jump to selection 0
		
CharSel_RefreshDiff:
		move.b	d0,(Option_Difficulty).w
		bra.w	CharSel_Difficulties
CharSel_RefreshChar:
		move.w	d2,(Options_menu_box).w ; set new selection
		bra.w	CharSel_LoadPlayer 		; refresh option names
;		move.b  d5,(a2)		
;		bra.w	CharSel_Values
		; move.w	#$CD,d0
		; jsr	(PlaySound_Special).l ;	play "blip" sound		
	
CharSel_NoInput:
		rts	

CharSel_LeftRight:	
		move.w  (Options_menu_box).w,d2        ; load choice number		
		btst	#2,d1		; is left pressed?
		beq.s	CharSel_Right	; if not, branch
		subq.w	#1,d2		; subtract 1 to selection
		bpl.s	CharSel_Right
		move.w  #2,d2     
		
CharSel_Right:
		btst	#3,d1		; is right pressed?
		beq.s	CharSel_RefreshChar	; if not, branch
		addq.w	#1,d2	; add 1 selection
		cmp.w	#2,d2
		ble.s	CharSel_RefreshChar
		move.w	#0,d2	
		bra.s   CharSel_RefreshChar

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
		bra.w	Settings_Init			; refresh option names
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
		dc.w GameSel_QuickRush-.StartEvents_Index	; Quick Rush
		dc.w GameSel_Instructions-.StartEvents_Index		; Instructions
		dc.w GameSel_Settings-.StartEvents_Index	     	; Settings
		dc.w .Start_Null-.StartEvents_Index		; Leaderboards
		dc.w .Start_Null-.StartEvents_Index		; View credits
; ===========================================================================		

.Start_Null:
		rts
		
GameSel_Instructions:
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#5,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound		
		
GameSel_Settings:	
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#1,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound
		
GameSel_ScoreRush:	
	clr.b	(ScoreRush_Gamemode).w	; set gamemode to "SCORE RUSH"
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#2,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound
	
GameSel_QuickRush:	
	move.b	#2,(ScoreRush_Gamemode).w	; set gamemode to "QUICK RUSH"
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#6,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound	

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
		move.l	#$418A0003,d4	; (CHANGE) starting screen position 
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
		move.l	#$418A0003,d4			; where does the text begin on the screen
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

;Settings_Description:					
		lea	(TextData_Descriptions).l,a1 ; where to fetch the lines from
		moveq	#0,d1
		move.w	(Options_menu_box).w,d1
		mulu.w	#108,d1
		adda.w	d1,a1					; set address		
		move.l	#$4C040003,d4	; (CHANGE) starting screen position 
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
		moveq	#2,d1		; number of lines of text to be displayed -1

-
		move.l	d4,4(a6)
		moveq	#35,d2		; number of characters to be rendered in a line -1
		bsr.w	SingleLineRender
		addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
		dbf	d1,-

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

Instructions_Headings:
	lea	(Chunk_Table).l,a1
	lea	(MapEng_InstContainers).l,a0
	move.w	#make_art_tile(ArtTile_ArtNem_MenuBox,1,0),d0
	jsr		EniDec
	
	lea	(Chunk_Table).l,a1
	move.l	#$41840003,d0
	moveq	#36,d1
	moveq	#22,d2
	jmp		PlaneMapToVRAM_H40	
		
Instructions_PageText:
	moveq	#0,d1
	lea	(TextData_PageTitles).l,a1 ; where to fetch the lines from
	move.w	(Options_menu_box).w,d1
	mulu.w	#34,d1
	adda.l	d1,a1
	move.l	#$42060003,4(a6)	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#33,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender

	moveq	#0,d1
	lea	(TextData_PageBodies).l,a1 ; where to fetch the lines from
	move.w	(Options_menu_box).w,d1
	mulu.w	#34*16,d1	
	adda.l	d1,a1
	move.l	#$44060003,d4	; (CHANGE) starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#15,d1		; number of lines of text to be displayed -1

-
	move.l	d4,4(a6)
	moveq	#33,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,-
	
	rts

; ===========================================================================

CharSel_LoadPlayer:
	lea	($C00000).l,a6
; load palette
	move.w	(Options_menu_box).w,d1
	lea		(CharSel_CharData).l,a2
	lsl.w	#3,d1
	adda.l	d1,a2
	movea.l	4(a2),a0
	move.w	#14,d0
	lea		(Normal_palette+2).w,a1
	move.l  #vdpComm(2,CRAM,WRITE),VDP_control_port-VDP_data_port(a6)	; funny way of writing 4(a6) lol
-
	move.w	(a0),(a6)		; palette needs to ve written in CRAM too, otherwise it will update too late
	move.w	(a0)+,(a1)+
	dbf		d0,-

; load Player plane graphics
	lea	(Chunk_Table).l,a1
	moveq	#0,d1
	move.w	(Options_menu_box).w,d1
	movea.l	(a2),a0
	move.w	#make_art_tile(ArtTile_ArtNem_LevelSelectPics,0,0),d0
	jsr		EniDec
		
; place them in the foreground		
	lea	(Chunk_Table).l,a1
	move.l	#$44240003,d0
	moveq	#$3,d1
	moveq	#$5,d2
	jsr		PlaneMapToVRAM_H40
	rts

; ===========================================================================

CharSel_CharData:
	dc.l	MapEng_CSelSonic
	dc.l	Pal_BGND+$2
	
	dc.l	MapEng_CSelTails
	dc.l	Pal_BGND+$2
	
	dc.l	MapEng_CSelKnuckles
	dc.l	Pal_Knux+2

; ===========================================================================

CharSel_Headings:
	lea	(Chunk_Table).l,a1
	lea	(MapEng_CSelContainer).l,a0
	move.w	#make_art_tile(ArtTile_ArtNem_MenuBox,2,0),d0
	jsr		EniDec
	
	lea	(Chunk_Table).l,a1
	move.l	#$43A00003,d0
	moveq	#$8,d1
	moveq	#$8,d2
	jsr		PlaneMapToVRAM_H40	
	
	lea	(TextData_CharSelect).l,a1 ; where to fetch the lines from
	move.l	#$42960003,4(a6)	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#17,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender

	lea	(TextData_Difficulty).l,a1 ; where to fetch the lines from
	move.l	#$49920003,4(a6)	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#21,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	
	rts

; ===========================================================================

CharSel_Difficulties:
		lea	(TextData_Difficulties).l,a1 ; where to fetch the lines from
		move.l	#$4AA20003,d4	; (CHANGE) starting screen position 
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
		moveq	#1,d1		; number of lines of text to be displayed -1

-
		move.l	d4,4(a6)
		moveq	#5,d2		; number of characters to be rendered in a line -1
		bsr.w	SingleLineRender
		addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line
		dbf	d1,-
		moveq	#0,d0
		moveq	#0,d1
	
	; calculate where the line to be yellowed out is
		move.b	(Option_Difficulty).w,d0		; move the currently selected line to d0
		move.b	d0,d1					; store d0 in d1 for future use
		move.l	#$4AA20003,d4			; where does the text begin on the screen
		lsl.w	#8,d0					; logical shift by 8 bits (multiply by 8)
		swap	d0						; swap the two words that compose d0
		add.l	d0,d4					; add that to d4, effectively determining where the correct line is
		
	; yellow out the appropriate text of a line in a list of 17 characters	
		lea  	(TextData_Difficulties).l,a1	; go to the text's ROM address
		mulu.w	#6,d1
		adda.w	d1,a1					; set address
		move.w	#$C680,d3				; set VRAM address (text but yellow)
		move.l	d4,4(a6)
		moveq	#5,d2		
		bsr.w	SingleLineRender	
		rts				

; ===========================================================================

QuickRush_Headings:
	lea	(Chunk_Table).l,a1
	lea	(MapEng_QuickContainers).l,a0
	move.w	#make_art_tile(ArtTile_ArtNem_MenuBox,1,0),d0
	jsr		EniDec
	
	lea	(Chunk_Table).l,a1
	move.l	#$41840003,d0
	moveq	#36,d1
	moveq	#22,d2
	jsr		PlaneMapToVRAM_H40

	lea	(TextData_LevelSelect).l,a1 ; where to fetch the lines from
	move.l	#$43080003,4(a6)	; starting screen position 
	move.w	#$C680,d3	; which palette the font should use and where it is in VRAM
	moveq	#12,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender		
	
	lea	(TextData_TopScores).l,a1 ; where to fetch the lines from
	move.l	#$461E0003,4(a6)	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#9,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender	
	
	lea	(TextData_Difficulties).l,a1
	move.l	#$48220003,d4	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#1,d1

-	
	move.l	d4,4(a6)
	moveq	#5,d2		; number of characters to be rendered in a line -1	
	bsr.w	SingleLineRender
	addi.l	#(14*$20000),d4	; tiles to the right
	dbf		d1,-

	lea	(TextData_CharNames).l,a1 ; where to fetch the lines from
	move.l	#$49080003,d4	; (CHANGE) starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#2,d1		; number of lines of text to be displayed -1

-
	move.l	d4,4(a6)
	moveq	#7,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,-	
	
	rts
	
QuickRush_LevelName:
	movem.l	d6,-(sp)
	moveq	#0,d1
	lea	(TextData_LevelNames).l,a1 ; where to fetch the lines from
	move.w	(Options_menu_box).w,d1
	mulu.w	#16,d1
	adda.l	d1,a1
	move.l	#$43280003,4(a6)	; starting screen position 
	move.w	#$C680,d3	; which palette the font should use and where it is in VRAM
	moveq	#15,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender	
	
;QuickRush_GetValues:
	moveq	#0,d1
	lea	(Leaderboards_QuickRush).l,a1	; where to get the numbers from
	
	moveq	#0,d0
	move.b	(Current_Zone).w,d0			; get zone
	add.w	d0,d0						; multiply by 2
	add.b	(Current_Act).w,d0			; get individual level
	mulu.w	#24,d0						; by 2 for difficulties, by 3 for characters, by 4 for alignment
	adda.l	d0,a1						; align to correct set of leaderboards entries
	
	move.l	#$49180003,d4				; (CHANGE) starting screen position 
	move.w	#$A68F,d3					; which palette the font should use and where it is in VRAM	
	moveq	#2,d6						; number of lines to render - 1
	
	
.loop:
	move.l	d4,4(a6)
	moveq	#1,d5						; number of times to repeat this subloop
	
.subloop:
	lea	(Hud_1000000000).l,a2 			; get the number of digits
	moveq	#9,d0             			; repeat X-1 times
	move.l	(a1)+,d1					; get value to render
	movem.l	d0-d6,-(sp)
	bsr.w	DecimalNumberRender2
	movem.l	(sp)+,d0-d6

; wanna see me write SHIT CODE!?!?!?!?	
	
	move.w	#$A68F,(a6)					; 0
	tst		d5
	beq.s	.skip
	move.w	#0,(a6)						; whitespace
	move.w	#0,(a6)						; whitespace
				
	dbf		d5,.subloop

.skip:	
	addi.l	#(2*$800000),d4
	dbf		d6,.loop
	
	movem.l	(sp)+,d6
	rts

; ===========================================================================
; All text data used by this screen.
; ===========================================================================	

TextData_LevelSelect:
	dc.b	"SELECT LEVEL:"

TextData_TopScores:
	dc.b	"TOP SCORES"
	
TextData_CharNames:
	dc.b	"SONIC   "
	dc.b	"TAILS   "
	dc.b	"KNUCKLES"

TextData_LevelNames:
	dc.b	"  EMERALD HILL 1"
	dc.b	"  EMERALD HILL 2"
	dc.b	"CHEMICAL PLANT 1"
	dc.b	"CHEMICAL PLANT 2"
	dc.b	"  AQUATIC RUIN 1"
	dc.b	"  AQUATIC RUIN 2"
	dc.b	"  CASINO NIGHT 1"
	dc.b	"  CASINO NIGHT 2"
	dc.b	"      HILL TOP 1"
	dc.b	"      HILL TOP 2"
	dc.b	"   MYSTIC CAVE 1"
	dc.b	"   MYSTIC CAVE 2"
	dc.b	"     OIL OCEAN 1"
	dc.b	"     OIL OCEAN 2"
	dc.b	"    METROPOLIS 1"
	dc.b	"    METROPOLIS 2"
	dc.b	"    METROPOLIS 3"
	dc.b	"       SKY CHASE"
	dc.b	"   WING FORTRESS"
	dc.b	"       DEATH EGG"
	
TextData_PageTitles:

	dc.b	"PAGE 1 - WELCOME!                 "
	dc.b	"PAGE 2 - CONTROLS                 "
	dc.b	"PAGE 3 - THE SCORE RUSH GIMMICK   "
	dc.b	"PAGE 4 - THE SCORE RUSH GAMEMODE  "
	dc.b	"PAGE 5 - THE ENDLESS RUSH         "
	dc.b	"PAGE 6 - THE QUICK RUSH           "
	dc.b	"PAGE 7 - GETTING POINTS           "
	dc.b	"PAGE 8 - POWER-UPS                "
	dc.b	"PAGE 9 - PENALTY SYSTEM           "
	dc.b	"PAGE 10 - SAVE DATA               "
	dc.b	"PAGE 11 - BUILD INFORMATION       "	

TextData_PageBodies:

; Page 1
	dc.b	"WELCOME TO THE SONIC 2 - SCORE    "
	dc.b	"RUSH USER MANUAL!                 "
	dc.b	"                                  "
	dc.b	"TO NAVIGATE THROUGH THE MANUAL,   "
	dc.b	"PRESS LEFT AND RIGHT. ONCE YOU'RE "
	dc.b	"READY, PRESS THE B BUTTON TO      "
	dc.b	"RETURN TO THE MAIN MENU.          "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	
; Page 2
	dc.b	"ALL MOVES FROM THE OFFICIAL SONIC "
	dc.b	"GAMES ARE USED THE SAME WAY YOU   "
	dc.b	"WOULD USE THEM THERE. ADDITIONAL  "
	dc.b	"MOVES ARE EXPLAINED IN THE        "
	dc.b	"SETTINGS.                         "
	dc.b	"                                  "
	dc.b	"WHILE THE GAME IS PAUSED, PRESS A "
	dc.b	"TO RETURN TO THE MAIN MENU, AND,  "
	dc.b	"IF THE PENALTY SYSTEM IS ENABLED, "
	dc.b	"PRESS C TO RESTART THE LEVEL.     "
	dc.b	"                                  "
	dc.b	"PRESS A TO SKIP THE SCORE TALLY IN"
	dc.b	"QUICK RUSH MODE.                  "
	dc.b	"                                  "
	dc.b	"YOU CAN SKIP THE WING FORTRESS    "
	dc.b	"CUTSCENE BY PRESSING START.       "

; Page 3
	dc.b	"THE SCORE RUSH IS A CHALLENGE IN  "
	dc.b	"WHICH YOU MUST GET THE HIGHEST    "
	dc.b	"POSSIBLE SCORE WHILE IT GOES DOWN."
	dc.b	"                                  "
	dc.b	"BASED ON DIFFICULTY, YOUR SCORE   "
	dc.b	"MAY GO DOWN FASTER.               "
	dc.b	"                                  "
	dc.b	"IN GENERAL, IF YOUR SCORE REACHES "
	dc.b	"ZERO, YOU LOSE.                   "
	dc.b	"                                  "
	dc.b	"TO MAKE IT POSSIBLE TO EVEN BEGIN "
	dc.b	"THE GAME, YOU'RE GIVEN 5000 POINTS"
	dc.b	"AT THE VERY START.                "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	
; Page 4
	dc.b	"THE SCORE RUSH GAMEMODE INVOLVES  "
	dc.b	"GOING THROUGH THE ENTIRETY OF     "
	dc.b	"SONIC 2, FROM START TO FINISH.    "
	dc.b	"                                  "
	dc.b	"PLACEMENT ON THE LEADERBOARDS     "
	dc.b	"DEPENDS ON HOW MANY POINTS YOU'VE "
	dc.b	"GOT BY THE END OF THE GAME, AND   "
	dc.b	"YOU WILL NEED TO BEAT THE GAME    "
	dc.b	"TO EVEN HAVE A CHANCE TO GET IN   "
	dc.b	"THE LEADERBOARDS.                 "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "
	dc.b	"                                  "

; Page 5
	dc.b	"THE ENDLESS RUSH GAMEMODE IS, AS  "
	dc.b	"THE NAME SUGGESTS, ENDLESS. AS    "
	dc.b	"LONG AS YOU STAY ALIVE.           "
	dc.b	"                                  "
	dc.b	"THE LEVEL ORDER IS ENTIRELY       "
	dc.b	"RANDOMIZED, AND BY GOING FURTHER  "
	dc.b	"IN THE GAME, THE LEVELS WILL GET  "
	dc.b	"HARDER, AND THE SCORE WILL GO DOWN"
	dc.b	"FASTER.                           "
	dc.b	"                                  "
	dc.b	"IF YOUR SCORE BECOMES RED, IT     "
	dc.b	"MEANS YOU HAVE REACHED THE HIGHEST"
	dc.b	"DIFFICULTY. HOPEFULLY YOU LIKE    "
	dc.b	"METROPOLIS, BECAUSE THERE WILL BE "
	dc.b	"A LOT OF IT BY THEN!              "
	dc.b	"                                  "

; Page 6
	dc.b	"THE QUICK RUSH IS VERY SIMILAR TO "
	dc.b	"THE SCORE RUSH. HOWEVER, UNLIKE   "
	dc.b	"IN THE SCORE RUSH, YOU WILL PLAY  "
	dc.b	"A SINGULAR LEVEL. THE HIGHEST     "
	dc.b	"SCORE EVER ACHIEVED WILL BE       "
	dc.b	"RECORDED.                         "
	dc.b	"                                  "
	dc.b	"BECAUSE IT IS SO DISGUSTINGLY     "
	dc.b	"OVERPOWERED, THE QUICK RUSH IS THE"
	dc.b	"ONLY GAMEMODE IN WHICH YOU'LL BE  "
	dc.b	"ABLE TO PLAY SKY CHASE ZONE.      "
	dc.b	"DON'T BELIEVE IT? TRY DEFEATING   "
	dc.b	"AS MANY BADNIKS AS POSSIBLE       "
	dc.b	"WITHOUT JUMPING.                  "
	dc.b	"                                  "
	dc.b	"                                  "

; Page 7
	dc.b	"YOU CAN GET POINTS IN ANY OF THE  "
	dc.b	"WAYS PROVIDED BY SONIC 2, WITH A  "
	dc.b	"CAP OF 1000 POINTS PER BADNIK.    "
	dc.b	"                                  "
	dc.b	"YOU ALSO GET 50 POINTS PER RING   "
	dc.b	"COLLECTED. LAMP POSTS, SIGNPOSTS  "
	dc.b	"AND CAPSULES ALL AWARD YOU 1000   "
	dc.b	"POINTS EACH. BOSS FIGHTS STILL    "
	dc.b	"AWARD 1000 POINTS.                "
	dc.b	"                                  "
	dc.b	"SCORE DISPENSERS AWARD YOU 800    "
	dc.b	"POINTS, BUT ONLY ONCE.            "
	dc.b	"                                  "
	dc.b	"GETTING HIT WILL COST YOU 1000    "
	dc.b	"POINTS, BUT YOU CAN RECOVER SOME  "
	dc.b	"OF THEM THROUGH SCATTERED RINGS.  "

; Page 8
	dc.b	"RING MONITORS, AS EXPECTED, AWARD "
	dc.b	"500 POINTS EACH.                  "
	dc.b	"                                  "
	dc.b	"THE SHIELD ACTS LIKE IT USUALLY   "
	dc.b	"DOES, WITH THE ADDED ADVANTAGE    "
	dc.b	"THAT YOU DON'T LOSE POINTS WHEN   "
	dc.b	"HIT.                              "
	dc.b	"                                  "
	dc.b	"WHILE YOU'RE INVINCIBLE, THE SCORE"
	dc.b	"GETS HALTED, UNLESS THE SCORE IS  "
	dc.b	"RED.                              "
	dc.b	"                                  "
	dc.b	"1-UP MONITORS NO LONGER AWARD     "
	dc.b	"LIVES, BUT AWARD 2000 POINTS EACH."
	dc.b	"KEEP IN MIND THESE ARE THE        "
	dc.b	"KNUCKLES IN SONIC 2 LAYOUTS!      "

; Page 9
	dc.b	"THE PENALTY SYSTEM MAKES IT SO    "
	dc.b	"THAT IF YOU DIE DURING THE SCORE  "
	dc.b	"RUSH AND THE ENDLESS RUSH, IT'S   "
	dc.b	"NOT AN IMMEDIATE LEVEL.           "
	dc.b	"                                  "
	dc.b	"IF YOU DIE, YOU WILL RESTART FROM "
	dc.b	"THE BEGINNING OF THE LEVEL (AND   "
	dc.b	"NOT FROM CHECKPOINTS!) WITH THE   "
	dc.b	"SCORE YOU HAD THEN, MINUS 5000.   "
	dc.b	"                                  "
	dc.b	"IF YOU HAVE THE PENALTY SYSTEM    "
	dc.b	"TURNED OFF, HAVE LESS THAN 5000   "
	dc.b	"POINTS, OR ARE PLAYING THE QUICK  "
	dc.b	"RUSH GAMEMODE, YOU GET ONLY ONE   "
	dc.b	"LIFE.                             "
	dc.b	"                                  "

; Page 10
	dc.b	"THIS GAME SUPPORTS SRAM!          "
	dc.b	"IT WILL STORE YOUR SETTINGS, AS   "
	dc.b	"WELL AS LEADERBOARDS, UNLESS YOU  "
	dc.b	"GOT A WARNING SAYING OTHERWISE.   "
	dc.b	"                                  "
	dc.b	"IF YOU WISH TO RESET YOUR SAVE    "
	dc.b	"DATA, YOU CAN DO IT BY HOLDING A, "
	dc.b	"B, AND C DURING THE GIOVANNI      "
	dc.b	"SPLASH SCREEN.                    "
	dc.b	"                                  "
	dc.b	"BEWARE THAT RESETTING YOUR SAVE   "
	dc.b	"DATA IS IRREVERSIBLE, SO DO IT    "
	dc.b	"ONLY IF YOU REALLY, ABSOLUTELY    "
	dc.b	"WANT TO!                          "
	dc.b	"                                  "
	dc.b	"                                  "

; Page 11
	dc.b	"SONIC 2 - SCORE RUSH              "
	dc.b	"                                  "
	dc.b	"VERSION: ALPHA 0.1.1 (PRIVATE)    "
	dc.b	"                                  "
	dc.b	"THIS GAME IS NOT A PRODUCT        "
	dc.b	"PRODUCED BY OR OFFICIALLY LICENSED"
	dc.b	"FROM SEGA. IF YOU SPOT ANY        "
	dc.b	"TECHNICAL ISSUES, REPORT THEM TO  "
	dc.b	"GIOVANNI.GEN ON DISCORD, GIOVANNI "
	dc.b	"ON SSRG, OR GIOVA ON SONIC RETRO. "
	dc.b	"                                  "
	dc.b	"THIS BUILD IS NOT INTENDED FOR    "
	dc.b	"PUBLIC DISTRIBUTION. IF YOU DID   "
	dc.b	"NOT RECEIVE THIS BUILD FROM       "
	dc.b	"GIOVANNI, CONTACT ME THROUGH THE  "
	dc.b	"MEANS LISTED ABOVE.               "	

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
	
TextData_Descriptions:
	dc.b	"AFFECTS ALL CHARACTERS. APPLIES A   "
	dc.b	"LIMIT TO YOUR HORIZONTAL SPEED IN   "
	dc.b	"MID-AIR.                            "
	
	dc.b	"AFFECTS ALL CHARACTERS. REMOVES     "
	dc.b	"DIRECTIONAL CONTROL IF YOU JUMP     "
	dc.b	"AFTER ROLLING.                      "
	
	dc.b	"AFFECTS ALL CHARACTERS. INCREASES   "
	dc.b	"THE REQUIRED SPEED FOR ROLLING,     "
	dc.b	"MAKING SPIN DASHING EASIER.         "
	
	dc.b	"AFFECTS SONIC. ALLOWS HIM TO PERFORM"
	dc.b	"THE SUPER PEEL-OUT FROM SONIC CD.   "
	dc.b	"                                    "
	
	dc.b	"AFFECTS SONIC. ALLOWS HIM TO PERFORM"
	dc.b	"THE DROP DASH FROM SONIC MANIA.     "
	dc.b	"                                    "
	
	dc.b	"AFFECTS SONIC. ALLOWS HIM TO PERFORM"
	dc.b	"THE INSTA-SHIELD FROM SONIC 3.      "
	dc.b	"                                    "
	
	dc.b	"AFFECTS TAILS. ALLOWS HIM TO FLY,   "
	dc.b	"JUST LIKE IN SONIC 3.               "
	dc.b	"                                    "
	
	dc.b	"AFFECTS TAILS. PRESS DOWN AND JUMP  "
	dc.b	"AT THE SAME TIME TO CANCEL A FLIGHT."
	dc.b	"                                    "
	
	dc.b	"AFFECTS ALL CHARACTERS. ALLOWS THEM "
	dc.b	"TO DEFLECT BULLETS WHILE USING THEIR"
	dc.b	"MID-AIR ABILITIES, LIKE IN SONIC 3. "
	
	dc.b	"READ PAGES 2 AND 9 OF THE MANUAL FOR"
	dc.b	"MORE INFORMATION ABOUT THIS SETTING."
	dc.b	"                                    "
	
	
TextData_CharSelect:
	dc.b	"CHOOSE A CHARACTER"
	
TextData_Difficulty:
	dc.b	"SELECT YOUR DIFFICULTY"
	
TextData_Difficulties:
	dc.b	"NORMAL"
	dc.b	" HARD "
	
TextData_OnOff:				
	dc.b    "OFF     "
	dc.b    "ON      "	
	even