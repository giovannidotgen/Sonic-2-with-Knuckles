; ===========================================================================
; ----------------------------------------------------------------------------
; Object 4D - Knuckles in Special Stage
; ----------------------------------------------------------------------------
; Sprite_338EC:
Obj4D:
	bsr.w	Obj4D_Inputs
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj4D_Index(pc,d0.w),d1
	jmp	Obj4D_Index(pc,d1.w)
; ===========================================================================
; off_338FE:
Obj4D_Index:	offsetTable
		offsetTableEntry.w Obj4D_Init	; 0
		offsetTableEntry.w Obj4D_MdNormal	; 2
		offsetTableEntry.w Obj4D_MdJump	; 4
		offsetTableEntry.w Obj4D_Index	; 6 - invalid
		offsetTableEntry.w Obj4D_MdAir	; 8
; ===========================================================================

Obj4D_Inputs:
	lea	(SS_Ctrl_Record_Buf_End).w,a1

	moveq	#bytesToWcnt(SS_Ctrl_Record_Buf_End-SS_Ctrl_Record_Buf)-1,d0
-	move.w	-4(a1),-(a1)
	dbf	d0,-

	move.w	(Ctrl_1_Logical).w,-(a1)
	rts
	
; ===========================================================================
; loc_3391C:
Obj4D_Init:
	move.b	#2,routine(a0)
	moveq	#0,d0
	move.l	d0,ss_x_pos(a0)
	move.w	#$80,d1
	move.w	d1,ss_y_pos(a0)
	move.w	d0,ss_y_sub(a0)
	add.w	(SS_Offset_X).w,d0
	move.w	d0,x_pos(a0)
	add.w	(SS_Offset_Y).w,d1
	move.w	d1,y_pos(a0)
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.l	#Obj4D_MapUnc,mappings(a0)
	move.w	#make_art_tile(ArtTile_ArtNem_SpecialSonic,1,0),art_tile(a0)
	move.b	#4,render_flags(a0)
	move.b	#3,priority(a0)
	move.w	#$6E,ss_z_pos(a0)
	clr.b	(SS_Swap_Positions_Flag).w
	move.w	#$400,ss_init_flip_timer(a0)
	move.b	#$40,angle(a0)
	move.b	#1,(Sonic_LastLoadedDPLC).w
	clr.b	ss_slide_timer(a0)
	bclr	#6,status(a0)
	clr.b	collision_property(a0)
	clr.b	ss_dplc_timer(a0)
	movea.l	#SpecialStageShadow_Sonic,a1
	move.b	#ObjID_SSShadow,id(a1) ; load obj63 (shadow) at $FFFFB140
	move.w	x_pos(a0),x_pos(a1)
	move.w	y_pos(a0),y_pos(a1)
	addi.w	#$18,y_pos(a1)
	move.l	#Obj63_MapUnc_34492,mappings(a1)
	move.w	#make_art_tile(ArtTile_ArtNem_SpecialFlatShadow,3,0),art_tile(a1)
	move.b	#4,render_flags(a1)
	move.b	#4,priority(a1)
	move.l	a0,ss_parent(a1)
	bra.w	LoadSSKnucklesDynPLC
	
; ===========================================================================

Obj4D_MdNormal:
	tst.b	routine_secondary(a0)
	bne.s	Obj4D_Hurt
	lea	(Ctrl_1_Held_Logical).w,a2
	bsr.w	SSPlayer_Move
	bsr.w	SSPlayer_Traction
	bsr.w	SSPlayerSwapPositions
	bsr.w	SSObjectMove
	bsr.w	SSAnglePos
	bsr.w	SSSonic_Jump
	bsr.w	SSPlayer_SetAnimation
	lea	(off_341E4).l,a1
	bsr.w	SSPlayer_Animate
	bsr.w	SSPlayer_Collision
	bra.w	LoadSSKnucklesDynPLC
	
; ===========================================================================

Obj4D_Hurt:
	bsr.w	SSHurt_Animation
	bsr.w	SSPlayerSwapPositions
	bsr.w	SSObjectMove
	bsr.w	SSAnglePos
	bra.w	LoadSSKnucklesDynPLC
	
; ===========================================================================

Obj4D_MdJump:
	lea	(Ctrl_1_Held_Logical).w,a2
	bsr.w	SSPlayer_ChgJumpDir
	bsr.w	SSObjectMoveAndFall
	bsr.w	SSPlayer_JumpAngle
	bsr.w	SSPlayer_DoLevelCollision
	bsr.w	SSPlayerSwapPositions
	bsr.w	SSAnglePos
	lea	(off_341E4).l,a1
	bsr.w	SSPlayer_Animate
	bra.w	LoadSSKnucklesDynPLC
; ===========================================================================

Obj4D_MdAir:
	lea	(Ctrl_1_Held_Logical).w,a2
	bsr.w	SSPlayer_ChgJumpDir
	bsr.w	SSObjectMoveAndFall
	bsr.w	SSPlayer_JumpAngle
	bsr.w	SSPlayer_DoLevelCollision
	bsr.w	SSPlayerSwapPositions
	bsr.w	SSAnglePos
	bsr.w	SSPlayer_SetAnimation
	lea	(off_341E4).l,a1
	bsr.w	SSPlayer_Animate
	bra.w	LoadSSKnucklesDynPLC
	
; ===========================================================================

LoadSSKnucklesDynPLC:
	move.b	ss_dplc_timer(a0),d0
	beq.s	+
	subq.b	#1,d0
	move.b	d0,ss_dplc_timer(a0)
	andi.b	#1,d0
	beq.s	+
	rts
	
; ===========================================================================
+
	jsrto	DisplaySprite, JmpTo43_DisplaySprite
	move.l	#SSRAM_ArtNem_SpecialSonicAndTails&$FFFFFF,d6
	lea	(Obj4D_MapRUnc).l,a2
	lea	(Sonic_LastLoadedDPLC).w,a4
	move.w	#tiles_to_bytes(ArtTile_ArtNem_SpecialSonic),d4
	moveq	#0,d1
	bra.w	LoadSSPlayerDynPLC