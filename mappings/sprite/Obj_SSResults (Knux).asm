; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 2 format
; --------------------------------------------------------------------------------

SME_cczka:	
		dc.w SME_cczka_3E-SME_cczka, SME_cczka_A0-SME_cczka	
		dc.w SME_cczka_102-SME_cczka, SME_cczka_14C-SME_cczka	
		dc.w SME_cczka_196-SME_cczka, SME_cczka_1F8-SME_cczka	
		dc.w SME_cczka_202-SME_cczka, SME_cczka_20C-SME_cczka	
		dc.w SME_cczka_216-SME_cczka, SME_cczka_220-SME_cczka	
		dc.w SME_cczka_22A-SME_cczka, SME_cczka_234-SME_cczka	
		dc.w SME_cczka_23E-SME_cczka, SME_cczka_268-SME_cczka	
		dc.w SME_cczka_28A-SME_cczka, SME_cczka_2BC-SME_cczka	
		dc.w SME_cczka_2EE-SME_cczka, SME_cczka_320-SME_cczka	
		dc.w SME_cczka_35A-SME_cczka, SME_cczka_37C-SME_cczka	
		dc.w SME_cczka_3AE-SME_cczka, SME_cczka_3E0-SME_cczka	
		dc.w SME_cczka_3F2-SME_cczka, SME_cczka_47C-SME_cczka	
		dc.w SME_cczka_4EE-SME_cczka, SME_cczka_560-SME_cczka	
		dc.w SME_cczka_5CA-SME_cczka, SME_cczka_63C-SME_cczka	
		dc.w SME_cczka_68E-SME_cczka, SME_cczka_6F8-SME_cczka	
		dc.w SME_cczka_74A-SME_cczka	
SME_cczka_3E:	dc.b 0, $C						; Matches Sonic's
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $A0	
		dc.b 0, 5, $80, $22, $80, $11, $FF, $B0	
		dc.b 0, 5, $85, $80, $85, $C0, $FF, $C0	
		dc.b 0, 5, $80, 6, $80, 3, $FF, $D0	
		dc.b 0, 1, $80, $16, $80, $B, $FF, $E0	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $E8	
		dc.b 0, 5, $80, $18, $80, $C, $FF, $F8	
		dc.b 0, 5, $80, $2A, $80, $15, 0, $10	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $20	
		dc.b 0, 5, $80, 2, $80, 1, 0, $2C	
		dc.b 0, 5, $80, $E, $80, 7, 0, $3C	
		dc.b 0, 5, $85, $80, $85, $C0, 0, $4C	
SME_cczka_A0:	dc.b 0, $C						; Doesn't match Sonic's
		dc.b 0, 5, $80, $2A, $80, $15, 0, 8	
		dc.b 0, 5, $85, $84, $85, $C2, $FF, $A8	
		dc.b 0, 5, $80, $E, $80, 7, 0, $20	
		dc.b 0, 5, $85, $88, $85, $C4, 0, $30	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $40	
		dc.b 0, 5, $80, 2, $80, 1, 0, $58	
		dc.b 0, 5, 0, $3C, 0, $1E, $FF, $98	
		dc.b 0, 5, 0, $32, 0, $19, $FF, $B8	
		dc.b 0, 5, 0, 6, 0, 3, $FF, $C8	
		dc.b 0, 5, 0, $3C, 0, $1E, $FF, $D8	
		dc.b 0, 5, 0, $18, 0, $C, $FF, $E8	
		dc.b 0, 5, 5, $80, 5, $C0, $FF, $F8	
SME_cczka_102:	dc.b 0, 9						; Doesn't match Sonic's, but is as long as
		dc.b 0, 9, $80, $1C, $80, $E, $FF, $B4	
		dc.b 0, 1, $80, $16, $80, $B, $FF, $CC	
		dc.b 0, 5, $80, $18, $80, $C, $FF, $D4	
		dc.b 0, 5, $85, $80, $85, $C0, $FF, $E4	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $F4	
		dc.b 0, 5, $80, $E, $80, 7, 0, $C	
		dc.b 0, 5, $85, $88, $85, $C4, 0, $1C	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $2C	
		dc.b 0, 5, $80, 2, $80, 1, 0, $44	
SME_cczka_14C:	dc.b 0, 9						; Doesn't match Sonic's, but is as long as
		dc.b 0, 5, $80, $2E, $80, $17, $FF, $BB	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $C8	
		dc.b 0, 1, $80, $16, $80, $B, $FF, $D8	
		dc.b 0, 5, $80, $18, $80, $C, $FF, $E0	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $F0	
		dc.b 0, 5, $80, $E, $80, 7, 0, 8	
		dc.b 0, 5, $85, $88, $85, $C4, 0, $18	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $28	
		dc.b 0, 5, $80, 2, $80, 1, 0, $40	
SME_cczka_196:	dc.b 0, $C				
		dc.b 0, 5, $80, 6, $80, 3, $FF, $98	
		dc.b 0, 5, $80, $12, $80, 9, $FF, $A8	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $B8	
		dc.b 0, 5, $85, $88, $85, $C4, $FF, $C8	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $D8	
		dc.b 0, 5, $85, $80, $85, $C0, $FF, $F3	
		dc.b 0, 9, $80, $1C, $80, $E, 0, 0	
		dc.b 0, 5, $85, $80, $85, $C0, 0, $18	
		dc.b 0, 5, $80, $26, $80, $13, 0, $28	
		dc.b 0, 5, $80, 2, $80, 1, 0, $38	
		dc.b 0, 5, $80, $18, $80, $C, 0, $48	
		dc.b 0, 5, $80, $A, $80, 5, 0, $58	
SME_cczka_1F8:	dc.b 0, 1	
		dc.b 0, 5, $C5, $A4, $C5, $D2, 0, 0	
SME_cczka_202:	dc.b 0, 1	
		dc.b 0, 5, $E5, $A4, $E5, $D2, 0, 0	
SME_cczka_20C:	dc.b 0, 1	
		dc.b 0, 5, $C5, $AC, $C5, $D6, 0, 0	
SME_cczka_216:	dc.b 0, 1	
		dc.b 0, 5, $E5, $AC, $E5, $D6, 0, 0	
SME_cczka_220:	dc.b 0, 1	
		dc.b 0, 5, $E5, $A8, $E5, $D4, 0, 0	
SME_cczka_22A:	dc.b 0, 1	
		dc.b 0, 5, $C5, $A8, $C5, $D4, 0, 0	
SME_cczka_234:	dc.b 0, 1	
		dc.b 0, 5, $A5, $A8, $A5, $D4, 0, 0	
SME_cczka_23E:	dc.b 0, 5	
		dc.b 0, 1, $A6, $E0, $A3, $65, $FF, $C0	
		dc.b 0, $D, $A6, $CA, $A6, $65, $FF, $A0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $BC	
		dc.b 0, 9, $86, $E4, $86, $72, 0, $28	
		dc.b 0, $D, $86, $EA, $86, $75, 0, $40	
SME_cczka_268:	dc.b 0, 4	
		dc.b 0, $D, $A6, $D2, $A3, $69, $FF, $A0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $C0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $BC	
		dc.b 0, $D, $85, $28, $85, $94, 0, $40	
SME_cczka_28A:	dc.b 0, 6	
		dc.b 0, $D, $A6, $D2, $A3, $69, $FF, $D0	
		dc.b 0, $D, $A5, $B8, $A5, $DC, $FF, $A0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $C0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $F0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $EC	
		dc.b 0, $D, $85, $30, $85, $98, 0, $40	
SME_cczka_2BC:	dc.b 0, 6	
		dc.b 0, $D, $A6, $D2, $A3, $69, $FF, $D0	
		dc.b 0, 9, $A5, $CE, $A5, $E7, $FF, $A0	
		dc.b 0, 5, $A5, $D4, $A5, $EA, $FF, $B8	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $F0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $EC	
		dc.b 0, $D, $85, $30, $85, $98, 0, $40	
SME_cczka_2EE:	dc.b 0, 6	
		dc.b 0, $D, $A5, $98, $A5, $CC, $FF, $A0	
		dc.b 0, $D, $A5, $90, $A5, $C8, $FF, $D0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $F0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $EC	
		dc.b 0, $D, $85, $20, $85, $90, 0, $38	
		dc.b 0, 1, $86, $F0, $86, $78, 0, $58	
SME_cczka_320:	dc.b 0, 7	
		dc.b 0, $D, $A5, $C0, $A5, $E0, $FF, $90	
		dc.b 0, 9, $A5, $C8, $A5, $E4, $FF, $B0	
		dc.b 0, $D, $A5, $90, $A5, $C8, $FF, $D0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $F0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $EC	
		dc.b 0, $D, $85, $28, $85, $94, 0, $38	
		dc.b 0, 1, $86, $F0, $86, $78, 0, $58	
SME_cczka_35A:	dc.b 0, 4	
		dc.b 0, $D, $A6, $D2, $A3, $69, $FF, $A0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $C0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $BC	
		dc.b 0, 1, $86, $F0, $86, $78, 0, $58	
SME_cczka_37C:	dc.b 0, 6	
		dc.b 0, $D, $A6, $D2, $A3, $69, $FF, $D0	
		dc.b 0, $D, $A5, $B8, $A5, $DC, $FF, $A0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $C0	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $F0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $EC	
		dc.b 0, 1, $86, $F0, $86, $78, 0, $58	
SME_cczka_3AE:	dc.b 0, 6	
		dc.b 0, $D, $A6, $D2, $A3, $69, $FF, $D0	
		dc.b 0, 9, $A5, $CE, $A5, $E7, $FF, $A0	
		dc.b 0, 5, $A5, $D4, $A5, $EA, $FF, $B8	
		dc.b 0, 1, $A6, $CA, $A6, $65, $FF, $F0	
		dc.b 0, 5, $85, $A0, $85, $D0, $FF, $EC	
		dc.b 0, 1, $86, $F0, $86, $78, 0, $58	
SME_cczka_3E0:	dc.b 0, 2	
		dc.b 0, $D, $85, $28, $85, $94, 0, $38	
		dc.b 0, 1, $86, $F0, $86, $78, 0, $58	
SME_cczka_3F2:	dc.b 0, $11	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $DC	
		dc.b 0, 5, $85, $84, $85, $C2, $FF, $7C	
		dc.b 0, 5, $80, 6, $80, 3, $FF, $9C	
		dc.b 0, 5, $80, $12, $80, 9, $FF, $F4	
		dc.b 0, 5, $80, 2, $80, 1, 0, 4	
		dc.b 0, 5, $80, $2A, $80, $15, 0, $14	
		dc.b 0, 5, $80, 2, $80, 1, 0, $2C	
		dc.b 0, 5, $80, $18, $80, $C, 0, $3C	
		dc.b 0, 5, $80, $18, $80, $C, 0, $4C	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $64	
		dc.b 0, 5, $80, $12, $80, 9, 0, $74	
		dc.b 0, 5, $85, $80, $85, $C0, 0, $84	
		dc.b 0, 5, 0, $3C, 0, $1E, $FF, $6C	
		dc.b 0, 5, 0, $32, 0, $19, $FF, $8C	
		dc.b 0, 5, 0, $3C, 0, $1E, $FF, $AC	
		dc.b 0, 5, 0, $18, 0, $C, $FF, $BC	
		dc.b 0, 5, 5, $80, 5, $C0, $FF, $CC	
SME_cczka_47C:	dc.b 0, $E	
		dc.b 0, 9, $80, $1C, $80, $E, $FF, $84	
		dc.b 0, 1, $80, $16, $80, $B, $FF, $9C	
		dc.b 0, 5, $80, $18, $80, $C, $FF, $A4	
		dc.b 0, 5, $85, $80, $85, $C0, $FF, $B4	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $C4	
		dc.b 0, 5, $80, $12, $80, 9, $FF, $DC	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $EC	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $FC	
		dc.b 0, 5, $80, 2, $80, 1, 0, $14	
		dc.b 0, 5, $80, $18, $80, $C, 0, $24	
		dc.b 0, 5, $80, $18, $80, $C, 0, $34	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $4C	
		dc.b 0, 5, $80, $12, $80, 9, 0, $5C	
		dc.b 0, 5, $85, $80, $85, $C0, 0, $6C	
SME_cczka_4EE:	dc.b 0, $E	
		dc.b 0, 5, $80, $2E, $80, $17, $FF, $8B	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $98	
		dc.b 0, 1, $80, $16, $80, $B, $FF, $A8	
		dc.b 0, 5, $80, $18, $80, $C, $FF, $B0	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $C0	
		dc.b 0, 5, $80, $12, $80, 9, $FF, $D8	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $E8	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $F8	
		dc.b 0, 5, $80, 2, $80, 1, 0, $10	
		dc.b 0, 5, $80, $18, $80, $C, 0, $20	
		dc.b 0, 5, $80, $18, $80, $C, 0, $30	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $48	
		dc.b 0, 5, $80, $12, $80, 9, 0, $58	
		dc.b 0, 5, $85, $80, $85, $C0, 0, $68	
SME_cczka_560:	dc.b 0, $D	
		dc.b 0, 5, $80, 6, $80, 3, $FF, $90	
		dc.b 0, 5, $80, $12, $80, 9, $FF, $A0	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $B0	
		dc.b 0, 5, $85, $88, $85, $C4, $FF, $C0	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $D0	
		dc.b 0, 5, $85, $80, $85, $C0, $FF, $EB	
		dc.b 0, 9, $80, $1C, $80, $E, $FF, $F8	
		dc.b 0, 5, $85, $80, $85, $C0, 0, $10	
		dc.b 0, 5, $80, $26, $80, $13, 0, $20	
		dc.b 0, 5, $80, 2, $80, 1, 0, $30	
		dc.b 0, 5, $80, $18, $80, $C, 0, $40	
		dc.b 0, 5, $80, $A, $80, 5, 0, $50	
		dc.b 0, 5, $80, $2A, $80, $15, 0, $60	
SME_cczka_5CA:	dc.b 0, $E	
		dc.b 0, 5, $85, $84, $85, $C2, $FF, $88	
		dc.b 0, 5, $85, $88, $85, $C4, $FF, $98	
		dc.b 0, 9, $80, $36, $80, $1B, $FF, $A8	
		dc.b 0, 5, $85, $84, $85, $C2, $FF, $D8	
		dc.b 0, 5, $80, 6, $80, 3, $FF, $F8	
		dc.b 0, 5, $80, 6, $80, 3, 0, $50	
		dc.b 0, 5, $80, 2, $80, 1, 0, $60	
		dc.b 0, 5, $85, $84, $85, $C2, 0, $70	
		dc.b 0, 5, 0, $3C, 0, $1E, $FF, $C8	
		dc.b 0, 5, 0, $32, 0, $19, $FF, $E8	
		dc.b 0, 5, 0, $3C, 0, $1E, 0, 8	
		dc.b 0, 5, 0, $18, 0, $C, 0, $18	
		dc.b 0, 5, 5, $80, 5, $C0, 0, $28	
		dc.b 0, 5, 0, $2A, 0, $15, 0, $38	
SME_cczka_63C:	dc.b 0, $A	
		dc.b 0, 5, $80, 6, $80, 3, $FF, $B0	
		dc.b 0, 5, $80, $12, $80, 9, $FF, $C0	
		dc.b 0, 5, $80, 2, $80, 1, $FF, $D0	
		dc.b 0, 5, $85, $84, $85, $C2, $FF, $E0	
		dc.b 0, 5, $80, $E, $80, 7, $FF, $F0	
		dc.b 0, 5, $85, $80, $85, $C0, 0, 0	
		dc.b 0, 1, $80, $16, $80, $B, 0, $18	
		dc.b 0, 5, $85, $84, $85, $C2, 0, $20	
		dc.b 0, 5, $80, $2E, $80, $17, 0, $30	
		dc.b 0, 5, $85, $88, $85, $C4, 0, $40	
SME_cczka_68E:	dc.b 0, $D	
		dc.b 0, 5, $85, $84, $85, $C2, $FF, $F0	
		dc.b 0, 5, $80, 6, $80, 3, 0, $10	
		dc.b 0, 5, 0, $3C, 0, $1E, $FF, $E0	
		dc.b 0, 5, 0, $32, 0, $19, 0, 0	
		dc.b 0, 5, 0, $3C, 0, $1E, 0, $20	
		dc.b 0, 5, 0, $18, 0, $C, 0, $30	
		dc.b 0, 5, 5, $80, 5, $C0, 0, $40	
		dc.b 0, 5, 0, $2A, 0, $15, 0, $50	
		dc.b 0, 5, 0, $2A, 0, $15, $FF, $88	
		dc.b 0, 5, 0, $32, 0, $19, $FF, $98	
		dc.b 0, 5, 0, $22, 0, $11, $FF, $A8	
		dc.b 0, 5, 5, $80, 5, $C0, $FF, $B8	
		dc.b 0, 5, 0, $26, 0, $13, $FF, $C8	
SME_cczka_6F8:	dc.b 0, $A	
		dc.b 0, 5, $85, $84, $85, $C2, $FF, $A0	
		dc.b 0, 5, $85, $88, $85, $C4, $FF, $B0	
		dc.b 0, 9, $80, $36, $80, $1B, $FF, $C0	
		dc.b 0, 5, $80, 6, $80, 3, 0, $30	
		dc.b 0, 5, $80, 2, $80, 1, 0, $40	
		dc.b 0, 5, $85, $84, $85, $C2, 0, $50	
		dc.b 0, 5, 0, $2E, 0, $17, $FF, $E0	
		dc.b 0, 5, 0, 2, 0, 1, $FF, $ED	
		dc.b 0, 9, 0, $16, 0, $B, $FF, $FD	
		dc.b 0, 5, 0, $2A, 0, $15, 0, $17	
SME_cczka_74A:	dc.b 0, 9	
		dc.b 0, 5, $80, $2A, $80, $15, $FF, $B0	
		dc.b 0, 5, $80, $32, $80, $19, $FF, $C0	
		dc.b 0, 5, $80, $22, $80, $11, $FF, $D0	
		dc.b 0, 5, $85, $80, $85, $C0, $FF, $E0	
		dc.b 0, 5, $80, $26, $80, $13, $FF, $F0	
		dc.b 0, 5, 0, $2E, 0, $17, 0, 8	
		dc.b 0, 5, 0, 2, 0, 1, 0, $15	
		dc.b 0, 9, 0, $16, 0, $B, 0, $25	
		dc.b 0, 5, 0, $2A, 0, $15, 0, $3F	
		even