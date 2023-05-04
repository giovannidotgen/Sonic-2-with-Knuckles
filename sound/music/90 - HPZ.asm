Silence_Header:
	smpsHeaderStartSong 2
	smpsHeaderVoice     Silence_Voices
	smpsHeaderChan      $06, $03
	smpsHeaderTempo     $00, $00

	smpsHeaderDAC       Silence_DAC
	smpsHeaderFM        Silence_FM1,	$00, $00
	smpsHeaderFM        Silence_FM2,	$00, $00
	smpsHeaderFM        Silence_FM3,	$00, $00
	smpsHeaderFM        Silence_FM4,	$00, $00
	smpsHeaderFM        Silence_FM5,	$00, $00
	smpsHeaderPSG       Silence_PSG1,	$00, $00, $00, fTone_01
	smpsHeaderPSG       Silence_PSG2,	$00, $00, $00, fTone_01
	smpsHeaderPSG       Silence_PSG3,	$00, $00, $00, fTone_01

Silence_Voices:
Silence_DAC:
Silence_FM1:
Silence_FM2:
Silence_FM3:
Silence_FM4:
Silence_FM5:
Silence_PSG1:
Silence_PSG2:
Silence_PSG3:

	smpsStop