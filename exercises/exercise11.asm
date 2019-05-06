;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Exercise 11
; In this exercise you will add sound when the joystick button is 
; pressed
;
; Written for use with 8bitworkshop.com. 
; Code included there and "Making Games For The Atari 2600"
; by Steven Hugg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; Header
;;;; Needed at top of all your source files  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	processor 6502
	include "vcs.h"

;;;;;;;;;;;;;;;;;; VARIABLE SEGMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;

	seg.u Variables
    	org $80

    	;;; INSERT YOUR VARIABLES BELOW THIS 
PlayerYPos  .byte
    	;;; AND ABOVE THIS

;;;;;;;;;;;;;;;;;; CODE SEGMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	seg Code
	org $f000
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; GENERAL INIT
;;;; This code is necessary for initialization 
;;;; but you can ignore it until you get curious
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

Start	sei
	    cld
        ldx #$ff 
        txs 
        lda #0 ; 
        ldx #$ff
ZeroZP	sta $0,X
	    dex
        bne ZeroZP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;; INITIALIZE YOUR VARIABLES BELOW THIS 
    lda #80
    sta PlayerYPos
    ;;; AND ABOVE THIS


NextFrame
	; next two lines turn off beam
	lda #2
        sta VBLANK 
        ; now three lines of vsync per spec
        sta VSYNC  
        sta WSYNC
        sta WSYNC
        sta WSYNC
        
        ; turn off vsync
        lda #0
        sta VSYNC 
        
        ; now loop through 33 vertical blank lines
        ldx #33
VBlankLoop
	sta WSYNC
        dex
        bne VBlankLoop
        
        
        ; we will use our final two vblank line to setup
        ; any drawing                
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        lda #$80
        sta COLUPF
        sta WSYNC
        
        ldx #8
HorizPositionLoop
        dex
        bne HorizPositionLoop
        sta RESP0

        sta WSYNC

        ;;; now turn beam back on and draw 192 lines
        lda #0
        sta VBLANK

        ;;; Draw 10 lines
        ldx #10
ScanLoopTop
	sta WSYNC
        dex
        bne ScanLoopTop
        
        ;; Setup to draw the sidebar playfield (reflected)
        lda #$01
        sta CTRLPF
	lda #$10
	sta PF0
        lda #0
        sta PF1
        sta PF2
        
        ;; Skip until player top
        ldx PlayerYPos
ScanLoopMiddleTop
	sta WSYNC
        dex
        bne ScanLoopMiddleTop
        
        lda #$32
        sta COLUP0

        ;;; Draw 8 lines
        ldx #8
ScanLoopDrawSprite
	sta WSYNC
        lda ButtonsFrame0,x
        sta GRP0
        lda ButtonsColorFrame0,x
        sta COLUP0
        dex
        bne ScanLoopDrawSprite
        
        sta WSYNC
        
        lda #0
        sta GRP0
        
        ;;; Calculate and draw remaining lines
        lda #192
        sbc #10  ; top 
        sbc #10  ; bottom 
        sbc #8   ; sprite
        sbc PlayerYPos
        tax
ScanLoopMiddleBottom
	sta WSYNC
        dex
        bne ScanLoopMiddleBottom
        
        ;; Now draw PF for the last 10 lines
        lda #$ff
        sta PF0
        sta PF1
        sta PF2
        lda #$80
        sta COLUPF
        
        ;;; Draw another 10 lines
        ldx #10
ScanLoopBottom
	sta WSYNC
        dex
        bne ScanLoopBottom        
        
        ; now draw 31 lines of overscan after
        ; turning beam off again
        lda #2
	sta VBLANK 
        ldx #31
OverscanLoop 
	sta WSYNC
        dex
        bne OverscanLoop

        ; Use a vblank line to check for bounds 
        ;;; INSERT CODE BELOW HERE
        lda PlayerYPos
        cmp #2
        bcs .TopBoundsCheck
        ldx #2
        jmp .SkipMoveUp
.TopBoundsCheck  
        lda PlayerYPos
	cmp #162
        bcc .JoystickCheck
        ldx #161
        jmp .SkipMoveUp
        ;;; AND ABOVE HERE
.JoystickCheck
	ldx PlayerYPos
        lda #$10
        bit SWCHA
        bne .SkipMoveDown
        dex
.SkipMoveDown
        lda #$20
	bit SWCHA
        bne .SkipMoveUp
        inx
.SkipMoveUp
	stx PlayerYPos
    
    ;;; INSERT CODE BELOW HERE
	
    ;;; INSERT CODE ABOVE HERE
        
        sta WSYNC

        ;;; Now we've drawn our
        ;;; 3 VSYNC lines
        ;;; 37 VBLANK lines
        ;;; 192 scan lines
        ;;; 30 overscan lines

	jmp NextFrame
        
;---Graphics Data from PlayerPal 2600---

ButtonsFrame0
        .byte #%00000000;$30
        .byte #%00011000;$30
        .byte #%00011000;$30
        .byte #%00000000;$74
        .byte #%01100110;$74
        .byte #%01100110;$74
        .byte #%00000000;$74
        .byte #%00011000;$B4
        .byte #%00011000;$B4
;---End Graphics Data---


;---Color Data from PlayerPal 2600---

ButtonsColorFrame0
	.byte #0
        .byte #$30;
        .byte #$30; 
        .byte #$74;
        .byte #$74;
        .byte #$74;
        .byte #$74;
        .byte #$B4;
        .byte #$B4;
;---End Color Data---



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;; Footer
;;;; Needed at bottom of all your source files  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	
    org $fffc
	.word Start
	.word Start
 