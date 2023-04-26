; ================================================================
; "GIOVANNI" Splash Screen
; Art and code by Giovanni
; Code based on Static Splash Screen for Sonic 1 by Hixatas and ProjectFM
; ================================================================

GiovanniSplash:
    move.b  #MusID_FadeOut,d0		; set music ID to "stop music"
    jsr     PlaySound2				; play ID
    jsr     Pal_FadeToBlack			; fade palettes out
    jsr     ClearScreen				; clear the plane mappings

	lea	(VDP_control_port).l,a6
	move.w	#$8004,(a6)		; H-INT disabled
	move.w	#$8200|(VRAM_Plane_A_Name_Table/$400),(a6)	; PNT A base: $C000
	move.w	#$8400|(VRAM_Plane_B_Name_Table/$2000),(a6)	; PNT B base: $E000
	move.w	#$9001,(a6)		; Scroll table size: 64x32
	move.w	#$9200,(a6)		; Disable window
	move.w	#$8B03,(a6)		; EXT-INT disabled, V scroll by screen, H scroll by line
	move.w	#$8720,(a6)		; Background palette/color: 2/0


   ; load art, mappings and the palette

    dmaFillVRAM 0,$0000,$10000              ; fill entire VRAM with 0 | macro used in S2 disassemblies						

    lea     ($FF0000).l,a1				; load dump location
    lea     (Map_Giovanni).l,a0			; load compressed mappings address
    move.w  #320,d0             		; prepare pattern index value to patch to mappings (unsure of what this is but it may be VRAM related)
    jsr     EniDec						; decompress and dump
    lea     ($FF0000).l,a1				; load dump location
    move.l  #$46140003,d0				; VRAM location
    moveq   #19,d1						; width - 1
    moveq   #3,d2						; height - 1
    bsr.w   PlaneMapToVRAM_H40         	; flush mappings to VRAM
    move.l  #$68000000,(VDP_control_port).l		; VRAM location
    lea     (Nem_Giovanni).l,a0			; load background art
    jsr     NemDec              		; run NemDec to decompress art for display
    lea 	Pal_Giovanni.l,a0        	; load this palette
    lea 	(Normal_palette).l,a1        ; get beginning of palette line
    move.w  #$3,d0						; number of entries / 4
 
Giovanni_PalLoop:
    move.l  (a0)+,(a1)+					; copy colours to buffer
    move.l  (a0)+,(a1)+
    dbf d0,Giovanni_PalLoop				; repeat until done

; optimized version
	lea		(Horiz_Scroll_Buf+$184).w,a0
	move.w	#240,d0						; get distance
	move.w	#29,d1						; lines to affect - 1
	
Giovanni_SetDistance:
	move.w	d0,(a0)
	adda.l	#4,a0
	neg.w	d0
	dbf		d1,Giovanni_SetDistance
	
    move.b  #SndID_Teleport,d0			; set sound ID
    jsr     PlaySound2					; play ID	
	move	#28,d4
	
Giovanni_DeformLoop:
    move.b  #VintID_Unused6,(Vint_routine).w			; set V-blank routine to run
    jsr 	WaitForVint					; wait for V-blank (does not decrease "Demo_Time_left")
    tst.b   (Ctrl_1_Press).w           	; has player 1 pressed start button?
    bmi.w   Giovanni_GotoTitle         	; if so, branch	
	move	d4,d3
	bsr.w	Giovanni_Reform				; perform deformation
	tst.w	(Horiz_Scroll_Buf+$184).w	; test the first line
	bne.s	Giovanni_DeformLoop			; if not 0, perform deformation again

	; lea		(VDP_data_port).l,a6
	; move.l	#$50000003,4(a6)			; set VRAM write address
	; lea		(Art_S2Text).l,a5			; fetch the text graphics
	; move.w	#$39F,d1					; amount of data to be loaded
; load text
; Giovanni_LoadText:
	; move.w	(a5)+,(a6)					; load the text
	; dbf	d1,Giovanni_LoadText 			; repeat until done

    move.w  #1*60,(Demo_Time_left).w     	; set delay time (1 second on a 60hz system)

Giovanni_Delay1:
    move.b  #VintID_Title,(Vint_routine).w			; set V-blank routine to run
    jsr 	WaitForVint					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (Ctrl_1_Press).w           	; has player 1 pressed start button?
    bmi.w   Giovanni_GotoTitle         	; if so, branch	
    tst.w   (Demo_Time_left).w           	; has the delay time finished?
    bne.s   Giovanni_Delay1				; if not, branch

; Credits_Render:
	; lea	(VDP_data_port).l,a6
	; lea	(Text_Giovanni).l,a1 ; where to fetch the lines from
	; move.l	#$488A0003,4(a6)	; starting screen position 
	; move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	; moveq	#29,d2		; number of characters to be rendered in a line -1
	; bsr.w	SingleLineRender

    ; move.b  #SndID_Ring,d0			; set sound ID
    ; jsr     PlaySound_Special		; play ID	
	; move.b	#1,(v_paltime).w
	; move.b	#1,(v_paltimecur).w
	; move.b	#1,(v_palflags).w
	; move.b	#$F,(v_awcount).w
	; move.l	#Pal_SplashText,(p_awtarget).w
	; move.l	#Normal_palette+#$20,(p_awreplace).w
	
; Giovanni_TextFadeIn:
    ; move.b  #VintID_Unused6,(Vint_routine).w			; set V-blank routine to run
    ; jsr 	WaitForVint					; wait for V-blank (decreases "Demo_Time_left")
    ; tst.b   (Ctrl_1_Press).w           	; has player 1 pressed start button?
    ; bmi.w   Giovanni_GotoTitle         	; if so, branch	
	; bsr.w	DynPaletteTransition
	; tst.b	(v_palflags).w				; check if the palette is fully loaded
	; bne.s	Giovanni_TextFadeIn
	
    move.w  #3*60,(Demo_Time_left).w     	; set delay time (3 seconds on a 60hz system)

Giovanni_MainLoop:
    move.b  #VintID_Title,(Vint_routine).w			; set V-blank routine to run
    jsr 	WaitForVint					; wait for V-blank (decreases "Demo_Time_left")
    tst.b   (Ctrl_1_Press).w           	; has player 1 pressed start button?
    bmi.s   Giovanni_GotoTitle         	; if so, branch
    tst.w   (Demo_Time_left).w           	; has the delay time finished?
    bne.s   Giovanni_MainLoop			; if not, branch
 
Giovanni_GotoTitle:
    move.b  #GameModeID_TitleScreen,(Game_Mode).w      		; set the screen mode to Title Screen
    rts									; return

; ===============================================================
; Subroutine that deforms the screen until all of its lines are properly centered
; ===============================================================

Giovanni_Reform:

	lea		(Horiz_Scroll_Buf+$184).w,a0
	move	#29,d1						; lines to affect - 1

Giovanni_ReformLoop:
	tst.w	d3							; check timer
	bpl.s	.common						; if positive, skip the line

	tst.w	(a0)						; check for scanline's position
	bmi.s	.negative					; if negative, branch
	beq.s	.common						; if zero, skip the line
	
	subq.w	#8,(a0)
	bra.s	.common
	
.negative:
	addq.w	#8,(a0)

.common:
	subq	#1,d3
	adda.l	#4,a0
	dbf		d1,Giovanni_ReformLoop
	
	tst		d4
	bmi.s	.return
	subq	#1,d4
	
.return:	
	rts

; ===============================================================
; Giovanni Splash Screen assets
; ===============================================================

Nem_Giovanni: binclude "art\nemesis\Giovanni Splash.bin"
	even
Map_Giovanni: binclude "mappings\misc\Giovanni Splash.bin"
	even
Pal_Giovanni: binclude "art\palettes\Giovanni Splash.bin"
	even
; Pal_SplashText:	binclude "palette\Sonic 2 Text used in Splash Screen.bin"
	; even
Text_Giovanni: dc.b "IT'S JOE-VANNI, NOT GEO-VANNI."
	even	
	
	include "_additional\DynPaletteTransition.asm"