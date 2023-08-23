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
	clearRAM Misc_Variables,Misc_Variables_End	

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
	clr.b	(Water_fullscreen_flag).w
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
	dc.w	TextInit_CharSel-MainMenu_InitIndex			; Character Select - Leaderboards
	dc.w	TextInit_Leaderboards-MainMenu_InitIndex	; Leaderboards
	dc.w	TextInit_ResultsScreen-MainMenu_InitIndex	; Results screen - Score Rush

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
	clr.b	(ScoreRush_Gamemode).w

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
	
TextInit_Leaderboards:
	bsr.w	Leaderboards_Headings
	bra.w	Leaderboards_Values
	
TextInit_ResultsScreen:
	bsr.w	Results_UpdateLeaderboards
	bsr.w	Results_Headings
	bra.w	Results_Name
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
		dc.w	CharSel_Controls-MenuCtrls_Index
		dc.w	Leaderboards_Controls-MenuCtrls_Index
		dc.w	ResultsScreen_Controls-MenuCtrls_Index

; ===========================================================================

ResultsScreen_SaveChanges:
		tst.b	(SRAM_ErrorCode).w
		bne.s	.tocredits

		lea		(SRAM_ScoreRushBoards).l,a0
		lea		(Leaderboards_ScoreRush).l,a1
	
-
		move.l	(a1)+,d0					; place RAM data in d0
		movep.l	d0,(a0)						; put it in SRAM
		adda.l	#8,a0						; advance SRAM pointer
		cmpa.l	#SRAM_QuickRushBoards,a0	; check if we're past the Endless Rush zone
		blt.s	-							; if we aren't yet, repeat		

.tocredits:
		tst.b	(Credits_Watched).w				; has the player watched the credits before?
		beq.s	Menu_GotoCredits
		clr.w	(Options_menu_box).w			; get selected character
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#SndID_Checkpoint,d0
		jmp		PlaySound	

; Universal credits jump code. Thanks to Devon for help on how to do this.
; Note: if you want to use this in your hack, disable the interrupts in EndgameCredits after the fadeout!
Menu_GotoCredits:
		st.b	(Credits_Trigger).w
		jsr		EndgameCredits

		lea		(System_Stack).w,sp
		jmp		MainGameLoop
		
ResultsScreen_Controls:
		btst	#button_start,(Ctrl_1_Press).w
		bne.w	ResultsScreen_SaveChanges
		tst.l	(Leaderboards_EntryUpdate).w
		beq.w	Results_NoInput
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands		
		andi.b	#$C,d1		; is left/right pressed and held?
		bne.s	Results_LeftRight	; if yes, branch
		move.b	(Ctrl_1_Press).w,d1
		andi.b	#3,d1		; is up/down pressed and held?
		bne.s	Results_UpDown	; if yes, branch
		subq.w	#1,(LevSel_HoldTimer).w ; subtract 1 from time	to next	move
		bpl.w	Results_NoInput	; if time remains, branch

Results_UpDown:
		move.w	#$6,(LevSel_HoldTimer).w ; reset time delay
		move.b	(Ctrl_1_Held).w,d1
		andi.b	#3,d1		; is up/down pressed?
		beq.w	Results_NoInput	; if not, branch
		movea.l	(Leaderboards_EntryUpdate),a2
		moveq	#0,d2
		move.w	(Options_menu_box).w,d2
		adda.l	d2,a2
		move.b	(a2),d0
		btst	#0,d1		; is up	pressed?
		beq.s	Results_Down	; if not, branch
		subq.b	#1,d0		; move up 1 selection
		cmp.b	#("A"-1),d0	; is current value A or higher?
		bne.s	+
		move.b	#"9",d0
+		
		cmp.b	#"0",d0
		bhs.s	Results_Down
		move.b	#"Z",d0		; if selection moves below 0, jump to selection

Results_Down:
		btst	#1,d1		; is down pressed?
		beq.s	Results_LetterRefresh	; if not, branch
		addq.b	#1,d0		; move down 1 selection
		cmp.b	#("9"+1),d0	; is current value A or higher?
		bne.s	+
		move.b	#"A",d0
+		
		cmp.b	#"Z",d0
		bls.s	Results_LetterRefresh
		move.b	#"0",d0		
		bra.s	Results_LetterRefresh

Results_LeftRight:	
		move.w  (Options_menu_box).w,d2        ; load choice number		
		btst	#2,d1		; is left pressed?
		beq.s	Results_Right	; if not, branch
		subq.w	#1,d2		; subtract 1 to selection
		bpl.s	Results_Right
		move.w  #2,d2     
		
Results_Right:
		btst	#3,d1		; is right pressed?
		beq.s	Results_Refresh	; if not, branch
		addq.w	#1,d2	; add 1 selection
		cmp.w	#2,d2
		ble.s	Results_Refresh
		move.w	#0,d2	
		
Results_Refresh:
		move.w	d2,(Options_menu_box).w
		bsr.w	Results_Name
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l	
		
Results_LetterRefresh:
		move.b	d0,(a2)
		bsr.w	Results_Name
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l

Results_NoInput:
		rts
; ===========================================================================

Leaderboards_GoBack:
		move.w	(Player_option).w,(Options_menu_box).w			; get selected character
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		move.b	#7,(MainMenu_Screen).w	; set menu
		move.w	#SndID_Back,d0
		jmp		PlaySound	

Leaderboards_Controls:
		btst	#button_B,(Ctrl_1_Press).w
		bne.w	Leaderboards_GoBack
		move.b	(Ctrl_1_Press).w,d1 ; fetch commands		
		andi.b	#$C,d1		; is left/right pressed and held?
		bne.s	Leaderboards_LeftRight	; if yes, branch
		rts	
		
Leaderboards_LeftRight:
		bchg	#0,(Options_menu_box+1).w
		bsr.w	Leaderboards_Values
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l			

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
		move.w	#SndID_Back,d0
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
		bsr.w	QuickRush_LevelName
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l		
		
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
		move.w	#SndID_Back,d0
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
		bsr.w	Instructions_PageText
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l		

; ===========================================================================

CharSel_GoBack:
		clr.w	(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		cmp.b	#7,(MainMenu_Screen).w
		beq.s	CharSel_BackFromLB		
		cmp.b	#2,(ScoreRush_Gamemode).w
		beq.s	CharSel_GotoQuickRush
		cmp.b	#1,(ScoreRush_Gamemode).w
		beq.s	CharSel_BackFromER
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#SndID_Back,d0
		jmp		PlaySound	

CharSel_BackFromER:
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#1,(Options_menu_box).w
		move.w	#SndID_Back,d0
		jmp		PlaySound			

CharSel_BackFromLB:
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#5,(Options_menu_box).w
		move.w	#SndID_Back,d0
		jmp		PlaySound			

CharSel_GotoQuickRush:
		move.b	#6,(MainMenu_Screen).w	; set menu
		move.w	#SndID_Back,d0
		jmp		PlaySound		

CharSel_GotoLeaderboards:
		move.w	(Options_menu_box).w,(Player_option).w			; get selected character
		clr.w	(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		move.b	#8,(MainMenu_Screen).w	; set menu
		move.w	#SndID_Checkpoint,d0
		jmp		PlaySound		

CharSel_BeginGame:
		cmp.b	#6,(MainMenu_Screen).w
		bgt.s	CharSel_GotoLeaderboards
		cmp.b	#1,(ScoreRush_Gamemode).w	; Endless Rush?
		bne.s	+
		clr.l	(EndlRush_LevelsBeaten).w
		clr.b	(EndlRush_LevelsBeaten_Difficulty).w
		clr.b	(EndlRush_Difficulty).w		
		move.l	#"IGNR",d6
		jsr		LevelRandomizer
+		
		moveq	#0,d0
		move.b	#1,(Life_count).w
		move.w	d0,(Ring_count).w
		move.l	d0,(Timer).w
		move.l	#500,(Score).w
		move.l	#500,(Score_Saved).w
		st.b	(HUD_Init).w
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
		bsr.w	CharSel_Difficulties
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l				
CharSel_RefreshChar:
		move.w	d2,(Options_menu_box).w ; set new selection
		bsr.w	CharSel_LoadPlayer 		; refresh option names
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l				
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
Settings_Save:
		tst.b	(SRAM_ErrorCode).w	; is there SRAM?
		bne.s	.return				; if not, return

		lea		(Settings_Data).l,a0
		lea		(SRAM_Settings).l,a1


-
		cmpa.l	#SRAM_ScoreRushBoards,a1	; check for end of settings RAM
		beq.s	.return						; if reached, branch
		movea.l	(a0),a2						; get address of setting
		adda.l	#6,a0						; next setting (RAM)
		move.b	(a2),(a1)					; load the value in RAM into SRAM
		adda.l	#2,a1						; next setting (SRAM)
		bra.s	-		

.return:
		rts
; ===========================================================================

Settings_GoBack:
		bsr.w	Settings_Save
		move.w	#4,(Options_menu_box).w
		move.l	#Menu_Update,(sp)	; overwrite stack
		move.l	#"UPDT",d6
		clr.b	(MainMenu_Screen).w	; set menu
		move.w	#SndID_Back,d0
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
		bsr.w	Settings_Init			; refresh option names
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l				
Settings_PartialRefresh:
		move.b  d5,(a2)		
		bsr.w	Settings_Values
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l						
	
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
		move.w	#SndID_Blip,d0
		jmp	(PlaySound).l			
	
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
		dc.w GameSel_EndlessRush-.StartEvents_Index		; Endless Rush
		dc.w GameSel_QuickRush-.StartEvents_Index	; Quick Rush
		dc.w GameSel_Instructions-.StartEvents_Index		; Instructions
		dc.w GameSel_Settings-.StartEvents_Index	     	; Settings
		dc.w GameSel_Leaderboards-.StartEvents_Index		; Leaderboards
		dc.w Menu_GotoCredits-.StartEvents_Index		; View credits
; ===========================================================================		

.Start_Null:
		move.w	#SndID_Error,d0
		jmp		PlaySound

GameSel_EndlessRush:
	move.b	#1,(ScoreRush_Gamemode).w	; set gamemode to "ENDLESS RUSH"
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#3,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound
		
GameSel_Leaderboards:
	clr.w	(Options_menu_box).w
	move.l	#Menu_Update,(sp)	; overwrite stack
	move.l	#"UPDT",d6
	move.b	#7,(MainMenu_Screen).w	; set menu
	move.w	#SndID_Checkpoint,d0
	jmp		PlaySound		
		
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

;Settings_Description:					
		lea	(TextData_GMDescriptions).l,a1 ; where to fetch the lines from
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
	move.l	#$430C0003,4(a6)	; starting screen position 
	move.w	#$C680,d3	; which palette the font should use and where it is in VRAM
	moveq	#5,d2		; number of characters to be rendered in a line -1
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
	move.l	#$43240003,4(a6)	; starting screen position 
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

Leaderboards_Headings:

		lea	(Chunk_Table).l,a1
		lea	(MapEng_LeadContainers).l,a0
		move.w	#make_art_tile(ArtTile_ArtNem_MenuBox,1,0),d0
		jsr		EniDec
		
		lea	(Chunk_Table).l,a1
		move.l	#$41040003,d0
		moveq	#36,d1
		moveq	#24,d2
		jsr		PlaneMapToVRAM_H40

		move.l	#$45080003,d4
		move.w	#$A690,d3		; get number 1 in font
		moveq	#7,d1			

-
		move.l	d4,4(a6)
		move.w	d3,(a6)
		addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line
		addq.w	#1,d3
		dbf	d1,-	

				
Leaderboards_Values:		
		lea	(TextData_LeaderHeadings).l,a1 ; where to fetch the lines from
		tst.w	(Options_menu_box).w		
		beq.s	+
		lea	(TextData_LeaderHeadings2).l,a1
+		
		move.l	#$42160003,d4	; (CHANGE) starting screen position 
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
		moveq	#1,d1		; number of lines of text to be displayed -1

-
		move.l	d4,4(a6)
		moveq	#17,d2		; number of characters to be rendered in a line -1
		bsr.w	SingleLineRender
		addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line
		dbf	d1,-	


		lea	(Leaderboards_ScoreRush).l,a1 ; where to fetch the lines from
		tst.w	(Options_menu_box).w		
		beq.s	+
		lea	(Leaderboards_EndlessRush).l,a1	
		
+	
		tst.b	(Option_Difficulty).w
		beq.s	+
		adda.l	#64,a1						; add 64 bytes
		
+		
		moveq	#0,d0
		move.w	(Player_option).w,d0
		lsl.w	#7,d0						; times 128
		adda.l	d0,a1

		move.l	#$45140003,d4	; (CHANGE) starting screen position 
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
		moveq	#7,d1		; number of lines of text to be displayed -1

-
		move.l	d4,4(a6)
		moveq	#2,d2		; number of characters to be rendered in a line -1
		bsr.w	SingleLineRender
		adda.l	#1,a1			 ; get associated number
		moveq	#11,d2
		bsr.w	MakeBlankTiles
		tst.w	(Options_menu_box).w
		beq.s	+				 ; if score rush, skip
		move.w	#$0,(a6)		 ; extra blank space
		
+
		movem.l	d0-d6,-(sp)
		lea	(Hud_1000000000).l,a2 			; get the number of digits
		moveq	#9,d0             			; repeat X-1 times
		move.l	(a1)+,d1					; get value to render
		move.w	#$A68F,d3					; get 0 from font
		bsr.w	DecimalNumberRender2
		movem.l	(sp)+,d0-d6
		
		tst.w	(Options_menu_box).w
		bne.s	+							; if endless rush, skip
		move.w	#$A68F,(a6)					; render additional 0
+
		addi.l	#(2*$800000),d4  ; replace number to the left with desired distance between each line	
	

		dbf	d1,-			

		rts

; ===========================================================================

Results_Headings:
	lea	(TextData_ResultsTitle).l,a1 ; where to fetch the lines from
	cmpi.b	#1,(ScoreRush_Gamemode).w
	bne.s	+
	lea	(TextData_ResultsTitle2).l,a1
+	
	move.l	#$42180003,4(a6)	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#15,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender			

	lea	(TextData_ResultsBody).l,a1 ; where to fetch the lines from
	cmpi.b	#1,(ScoreRush_Gamemode).w
	bne.s	+
	lea	(TextData_ResultsBody2).l,a1
+	

	move.l	#$45060003,d4	; (CHANGE) starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#3,d1		; number of lines of text to be displayed -1

-
	move.l	d4,4(a6)
	moveq	#33,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,-		
	
	lea	(TextData_Success).l,a1 ; where to fetch the lines from
	tst.l	(Leaderboards_EntryUpdate).w	; is there an entry to update in the leaderboards?
	bne.s	+
	lea	(TextData_Failure).l,a1

+
	move.l	#$48060003,d4	; (CHANGE) starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#3,d1		; number of lines of text to be displayed -1

-
	move.l	d4,4(a6)
	moveq	#33,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender
	addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
	dbf	d1,-			

	lea		(Score).w,a1
	move.l	#$46AE0003,4(a6)
	cmpi.b	#1,(ScoreRush_Gamemode).w
	bne.s	+
	lea		(EndlRush_LevelsBeaten).w,a1
	move.l	#$46B00003,4(a6)
	tst.l	(EndlRush_LevelsBeaten).w
	beq.s	.return

+	
	movem.l	d0-d6,-(sp)
	lea	(Hud_1000000000).l,a2 			; get the number of digits
	moveq	#9,d0             			; repeat X-1 times
	move.l	(a1)+,d1					; get value to render
	move.w	#$A68F,d3					; get 0 from font
	bsr.w	DecimalNumberRender2
	movem.l	(sp)+,d0-d6

.return:
	rts
	
Results_Name:
	tst.l	(Leaderboards_EntryUpdate).w
	beq.s	.quit
	movea.l	(Leaderboards_EntryUpdate).w,a1
	
	move.l	#$48C20003,4(a6)	; starting screen position 
	move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	moveq	#2,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender	
	
	movea.l	(Leaderboards_EntryUpdate).w,a1
	moveq	#0,d0
	move.w	(Options_menu_box).w,d0
	adda.l	d0,a1
	add		d0,d0		; if d0 = 1, then d0 = 2
	swap	d0			; if d0 = 2, then d0 = $20000
	
	move.l	#$48C20003,d4
	add.l	d0,d4
	move.l	d4,4(a6)
	move.w	#$C680,d3	; which palette the font should use and where it is in VRAM
	moveq	#0,d2		; number of characters to be rendered in a line -1
	bsr.w	SingleLineRender		
	
.quit:
	rts
; ===========================================================================
; Subroutine to check if a specific value belongs in the leaderboards.
; ===========================================================================	

Results_UpdateLeaderboards:		
		bsr.w	Leaderboards_Find						; Find correct leaderboards based on character
		tst.l	(Leaderboards_EntryUpdate).w			; check if the above returned a valid pointer
		beq.s	.return									; if not, return

		move.l	#"AAA ",(a2)							; reinitialize name in leaderboards
		
.return:
		rts
		
; ===========================================================================
; Subroutine to seek the leaderboards data and update it.
; Input:
; a0: achieved score
; a1: start of leaderboards
;
; Output:
; a2: leaderboards entry that got updated
; Leaderboards_EntryUpdate: copy of a2
; ===========================================================================	

Leaderboards_CrashGame:
		illegal
		
Leaderboards_Find:
		lea		(Score).w,a0							; Input value		
		lea		(Leaderboards_ScoreRush).w,a1			; Leaderboards
		cmp.b	#1,(ScoreRush_Gamemode).w				; Check for Endless Rush
		bne.s	.common									

		lea		(EndlRush_LevelsBeaten).w,a0
		lea		(Leaderboards_EndlessRush).w,a1
.common:
		moveq	#0,d0
		move.w	(Player_option).w,d0
		sub.w	#1,d0									; 0 = Sonic, 1 = Tails, 2 = Knuckles
		bmi.s	Leaderboards_CrashGame
		cmp.b	#3,d0
		bhs.s	Leaderboards_CrashGame
		
		lsl.l	#7,d0									; times 128
		tst.b	(Option_Difficulty).w					; check difficulty
		beq.s	.skip									; if normal, branch
		add.l	#64,d0									; advance 64 more bytes
		
.skip:		
		add.l	#56,d0									; get last score entry
		adda.l	d0,a1									; align to last score entry of correct leaderboards
		
		moveq	#7,d2									; number of checks to do
		move.l	(a0),d0									; copy score into data register
		suba.l	a2,a2									; wipe a2 (address 0 is considered invalid)
		
; scan leaderboards entries
-
		cmp.l	4(a1),d0								; check the leaderboards score against the input score
		blt.s	.exit									; if the input score is lower, exit
		movea.l	a1,a2									; copy leaderboards pointer into a2
		cmp		#7,d2									; come here often, honey? ;)
		beq.s	.skip2									; if not, branch
		move.l	(a1),8(a1)								; copy name into previous entry
		move.l	4(a1),12(a1)							; copy value into previous entry
.skip2:		
		move.l	(a0),4(a1)								; copy score into leaderboards
		suba.l	#8,a1									; decrement a1
		dbf		d2,-									; repeat
		
.exit:
		move.l	a2,(Leaderboards_EntryUpdate).w			; copy a2 into RAM
		rts
		
		


; ===========================================================================
; All text data used by this screen.
; ===========================================================================	

TextData_ResultsTitle:
	dc.b	"CONGRATULATIONS!"
TextData_ResultsTitle2:
	dc.b	"  RUN FINISHED  "

TextData_ResultsBody:
	dc.b	"   YOU HAVE SUCCESSFULLY BEATEN   "
	dc.b	"          THE SCORE RUSH          "
	dc.b	"                                  "
	dc.b	"   FINAL RESULTS:             0   "
	
TextData_ResultsBody2:
	dc.b	"   YOUR RUN OF THE ENDLESS RUSH   "
	dc.b	"           HAS FINISHED           "
	dc.b	"                                  "
	dc.b	"   LEVELS BEATEN:             0   "
	
TextData_Success:
	dc.b	"  ENTER A NAME TO SAVE YOUR DATA  "
	dc.b	"IN THE LEADERBOARDS:         *   *"
	dc.b	"                                  "
	dc.b	"      PRESS START TO CONFIRM      "	
	
TextData_Failure:
	dc.b	"GET BETTER RESULTS FOR A CHANCE TO"
	dc.b	"      JOIN THE LEADERBOARDS!      "
	dc.b	"                                  "
	dc.b	"      PRESS START TO GO BACK      "	

TextData_LeaderHeadings:
	dc.b	"    SCORE RUSH    "
	dc.b	"  HIGHEST SCORES  "
	
	
TextData_LeaderHeadings2:	
	dc.b	"   ENDLESS RUSH   "
	dc.b	"MOST LEVELS BEATEN"

TextData_LevelSelect:
	dc.b	"LEVEL:"

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
	dc.b	"WOULD USE THEM THERE.             "
	dc.b	"                                  "
	dc.b	"IN CHEMICAL PLANT, HOLD UP AS YOU "
	dc.b	"ENTER A BRANCHING TUBE TO USE ITS "
	dc.b	"ALTERNATE ROUTE.                  "
	dc.b	"                                  "
	dc.b	"MID PAUSE, PRESS A TO QUIT, AND IF"
	dc.b	"THE PENALTY SYSTEM IS ON, PRESS C "
	dc.b	"TO DIE AND RESTART THE LEVEL.     "
	dc.b	"                                  "
	dc.b	"YOU CAN SKIP SCORE TALLIES WITH A."
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
	dc.b	"YOUR OBJECTIVE IS STAYING ALIVE   "
	dc.b	"AND BEATING AS MANY LEVELS AS     "
	dc.b	"POSSIBLE. LOSING ALL OF YOUR      "
	dc.b	"POINTS, OR MANUALLY QUITTING, WILL"
	dc.b	"LEAD YOU STRAIGHT TO THE RESULTS  "
	dc.b	"SCREEN.                           "

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
	dc.b	"WAYS PROVIDED BY SONIC 2.         "
	dc.b	"                                  "
	dc.b	"YOU ALSO GET 50 POINTS PER RING   "
	dc.b	"COLLECTED. STARPOSTS, SIGNPOSTS   "
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
	dc.b	"                                  "

; Page 8
	dc.b	"RING MONITORS, AS EXPECTED, AWARD "
	dc.b	"500 POINTS EACH.                  "
	dc.b	"                                  "
	dc.b	"THE SHIELD ACTS LIKE IT USUALLY   "
	dc.b	"DOES, WITH THE ADDED ADVANTAGE    "
	dc.b	"THAT YOU DON'T LOSE POINTS WHEN   "
	dc.b	"HIT.                              "
	dc.b	"                                  "
	dc.b	"THE SCORE WILL COMPLETELY STOP    "
	dc.b	"DRAINING WHILE YOU'RE INVINCIBLE, "
	dc.b	"OR IN OTHER PARTICULAR SCENARIOS. "
	dc.b	"                                  "
	dc.b	"1-UP MONITORS NO LONGER AWARD     "
	dc.b	"LIVES, BUT AWARD 2000 POINTS EACH."
	dc.b	"KEEP IN MIND THESE ARE THE        "
	dc.b	"KNUCKLES IN SONIC 2 LAYOUTS!      "

; Page 9
	dc.b	"THE PENALTY SYSTEM MAKES IT SO    "
	dc.b	"THAT IF YOU DIE DURING THE SCORE  "
	dc.b	"RUSH AND THE ENDLESS RUSH, IT'S   "
	dc.b	"NOT AN IMMEDIATE GAME OVER.       "
	dc.b	"                                  "
	dc.b	"IF YOU DIE, YOU WILL RESTART FROM "
	dc.b	"THE BEGINNING OF THE LEVEL (AND   "
	dc.b	"NOT FROM THE STARPOSTS!) WITH THE "
	dc.b	"SCORE YOU HAD THEN, MINUS 5000.   "
	dc.b	"                                  "
	dc.b	"IF YOU HAVE THE PENALTY SYSTEM    "
	dc.b	"TURNED OFF, START A LEVEL WITH    "
	dc.b	"LESS THAN 5000 POINTS, OR ARE     "
	dc.b	"PLAYING THE QUICK RUSH GAMEMODE,  "
	dc.b	"YOU ONLY GET ONE LIFE.            "
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
	dc.b	"VERSION: 1.0                      "
	dc.b	"                                  "
	dc.b	"THIS IS A ROM HACK. IT IS NOT     "
	dc.b	"PRODUCED BY OR UNDER LICENSE FROM "
	dc.b	"SEGA. REPORT ALL TECHNICAL ISSUES "
	dc.b	"TO THE LEAD DEVELOPER LIKE SO:    "
	dc.b	"                                  "
	dc.b	"- GIOVANNI.GEN (DISCORD)          "
	dc.b	"- GIOVANNI (SSRG, SONIC RETRO)    "
	dc.b	"                                  "
	dc.b	"THIS ROM HACK IS FREELY AVAILABLE,"
	dc.b	"AND NOT MEANT FOR MONETARY GAIN.  "
	dc.b	"IF YOU'VE PURCHASED THIS HACK, YOU"
	dc.b	"HAVE BEEN SCAMMED.                "	

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
	
TextData_GMDescriptions:
	dc.b	"PLAY THROUGH THE ENTIRETY OF SONIC 2"
	dc.b	"WITH THE SCORE RUSH TWIST! CAN YOU  "
	dc.b	"BEAT THE GAME?                      "
	
	dc.b	"A NEVER ENDING BARRAGE OF LEVELS    "
	dc.b	"COMES YOUR WAY! HOW MANY OF THEM CAN"
	dc.b	"YOU BEAT BEFORE THE SCORE REACHES 0?"
	
	dc.b	"PLAY THROUGH ANY OF YOUR FAVORITE   "
	dc.b	"LEVELS WITH THE SCORE RUSH GIMMICK! "
	dc.b	"CAN YOU FILL OUT THE SCOREBOARD?    "
	
	dc.b	"NEED HELP? LEARN EVERYTHING YOU NEED"
	dc.b	"ABOUT SONIC 2 - SCORE RUSH HERE!    "
	dc.b	"                                    "
	
	dc.b	"SET UP YOUR GENERAL EXPERIENCE, AS  "
	dc.b	"WELL AS YOUR CHARACTERS' MOVESETS,  "
	dc.b	"TO MATCH YOUR GAMEPLAY TASTE!       "
	
	dc.b	"VIEW THE GREATEST ACHIEVEMENTS EVER "
	dc.b	"PERFORMED IN THIS SAVE FILE OF SONIC"
	dc.b	"2 - SCORE RUSH!                     "
	
	dc.b	"CHECK OUT THE NAMES OF THOSE WHO    "
	dc.b	"HELPED MAKE THIS HACK AS GREAT AS IT"
	dc.b	"IS!                                 "
	
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