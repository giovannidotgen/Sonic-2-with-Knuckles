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

	clr.w	(VDP_Command_Buffer).w
	move.l	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w
	move.l	#vdpComm(tiles_to_bytes(ArtTile_ArtNem_FontStuff),VRAM,WRITE),(VDP_control_port).l
	lea	(ArtNem_FontStuff).l,a0
	jsr		NemDec
	lea	(Chunk_Table).l,a1
	lea	(MapEng_MenuBack).l,a0
	move.w	#make_art_tile(ArtTile_VRAM_Start,3,0),d0
	jsr		EniDec
	lea	(Chunk_Table).l,a1
	move.l	#vdpComm(VRAM_Plane_B_Name_Table,VRAM,WRITE),d0
	moveq	#$27,d1
	moveq	#$1B,d2
	jsrto	PlaneMapToVRAM_H40, JmpTo_PlaneMapToVRAM_H40	; fullscreen background

	clr.b	(Options_menu_box).w
	clr.b	(Options_menu_box).w
	clr.b	(Level_started_flag).w
	clr.w	(Anim_Counters).w	
	lea	(Anim_SonicMilesBG).l,a2
	jsrto	Dynamic_Normal, JmpTo2_Dynamic_Normal
	moveq	#PalID_Menu,d0
	bsr.w	PalLoad_ForFade
	move.b	#MusID_Options,d0
	jsrto	PlayMusic, JmpTo_PlayMusic
	clr.w	(Two_player_mode).w
	clr.l	(Camera_X_pos).w
	clr.l	(Camera_Y_pos).w
	clr.w	(Correct_cheat_entries).w
	clr.w	(Correct_cheat_entries_2).w
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint
	move.w	(VDP_Reg1_val).w,d0
	ori.b	#$40,d0
	move.w	d0,(VDP_control_port).l
	bsr.w	Pal_FadeFromBlack

.Menu_Loop:
	move.b	#VintID_Menu,(Vint_routine).w
	bsr.w	WaitForVint
	lea	(Anim_SonicMilesBG).l,a2
	jsrto	Dynamic_Normal, JmpTo2_Dynamic_Normal	
	move.b	(Ctrl_1_Press).w,d0
	andi.b	#button_start_mask,d0
	bne.s	.Menu_StartGame
	bra.w	.Menu_Loop
	
.Menu_StartGame:
	moveq	#0,d0
	move.w	d0,(Two_player_mode).w
	move.w	d0,(Two_player_mode_copy).w
    if emerald_hill_zone_act_1=0
	move.w	d0,(Current_ZoneAndAct).w ; emerald_hill_zone_act_1
    else
	move.w	#emerald_hill_zone_act_1,(Current_ZoneAndAct).w
    endif
    if fixBugs
	; The game forgets to reset these variables here, making it possible
	; for the player to repeatedly soft-reset and play Emerald Hill Zone
	; over and over again, collecting all of the emeralds within the
	; first act. This code is borrowed from similar logic in the title
	; screen, which doesn't make this mistake.
	move.w	d0,(Current_Special_StageAndAct).w
	move.w	d0,(Got_Emerald).w
	move.l	d0,(Got_Emeralds_array).w
	move.l	d0,(Got_Emeralds_array+4).w
    endif
	move.b	#GameModeID_Level,(Game_Mode).w ; => Level (Zone play mode)
	move.w	#1,(Player_option).w		
	rts
	