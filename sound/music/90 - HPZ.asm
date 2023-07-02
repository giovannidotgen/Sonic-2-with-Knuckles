Silence_Header:
	smpsHeaderStartSong 2
	smpsHeaderVoice     Silence_Voices
	smpsHeaderChan      $06, $03
	smpsHeaderTempo     $01, $CD

	smpsHeaderDAC       Silence_DAC
	smpsHeaderFM        Silence_FM1,	$F4, $0C
	smpsHeaderFM        Silence_FM2,	$F4, $0C
	smpsHeaderFM        Silence_FM3,	$F4, $0B
	smpsHeaderFM        Silence_FM4,	$F4, $0B
	smpsHeaderFM        Silence_FM5,	$F4, $0E
	smpsHeaderPSG       Silence_PSG1,	$00, $00, $00, fTone_03
	smpsHeaderPSG       Silence_PSG2,	$00, $02, $00, fTone_03
	smpsHeaderPSG       Silence_PSG3,	$00, $03, $00, fTone_04

; FM5 Data
Silence_FM5:
	smpsAlterNote       $03

; FM1 Data
Silence_FM1:
	smpsStop

; FM2 Data
Silence_FM2:
	smpsStop

; FM3 Data
Silence_FM3:
	smpsStop

; FM4 Data
Silence_FM4:
	smpsStop

; PSG3 Data
Silence_PSG3:
	smpsStop

; DAC Data
Silence_DAC:
	smpsStop

; PSG2 Data
Silence_PSG2:
	smpsStop

; PSG1 Data
Silence_PSG1:
	smpsStop

Silence_Voices:

