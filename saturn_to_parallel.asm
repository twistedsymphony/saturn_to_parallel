;SATURN TO PARALLEL
;(C) 2006 M.Pica 
;
;This program interfaces with a sega Saturn controller and separates
;out the individual pins, which can then be used for other tasks
;the original intended task is to inteface with an Xbox360 controller
;
;The Select bits are set by the PIC to RA<5:4>
;The Data bits are recieved by the PIC through RA<3:0>
;The parallel outputs are sent out through all of Ports B and C
;
;PIC(pin) : Saturn(pin)
;RA0(19) : D3(7)
;RA1(18) : D2(8)
;RA2(17) : D1(2)
;RA3(04) : D0(3)
;RA4(03) : S1(5)
;RA5(02) : S0(4)
;
;PIC(PIN) : Output
;RB4(13) : "R"
;RB5(12) : "X"
;RB6(11) : "Y"
;RB7(10) : "Z"
;RC0(16) : "L"
;RC1(15) : "A"
;RC2(14) : "C"
;RC3(07) : "B"
;RC4(06) : "D-Right"
;RC5(05) : "D-Left"
;RC6(08) : "D-Down"
;RC7(09) : "D-Up"

LIST P=PIC16F690;indicates intended PIC chip
#include <p16F690.inc>
;*****************************************
;CONFIGURATION BITS
    __config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

;*****************************************
;DEFINE FILES
    cblock 0x20
RBPREP    ;create a temp file for prepairing port B
RCPREP    ;create a temp file for prepairing port C
    endc

;*****************************************
;SETUP PORTS
    org 0
Start
    bcf    STATUS,RP0
    bsf    STATUS,RP1 ; Select Register Page 2
    clrf    ANSEL
    clrf    ANSELH; digital I/O
    bcf    STATUS RP1
    bsf    STATUS,RP0; select register Page 1
    movlw    0x0F; make RA<3:0> as inputs
    movwf    TRISA; and RA<5:4> as outputs
    clrf    TRISB; set RB<7:4> as outputs
    clrf    TRISC; set RC<7:0> as outputs
    bcf    STATUS,RP0; back to Register Page 0

;*****************************************
;MAIN PROGRAM

BEGIN
    clrf    RBPREP
    clrf    RCPREP;clear the prep files

SELECT0
    clrf    PORTA;set Select to 00
    swapf    PORTA,W;grab the data from the controller and swap nibbles
    andlw    0xF0;view only the data bits
    movwf    RBPREP;outputs the data to port B prep

SELECT1
    movlw    0x10
    movwf    PORTA;set Select to 01
    swapf    PORTA,W;grab the data from the controller and swap nibbles
    andlw    0xF0;view only the data bits
    movwf    RCPREP;outputs the data to port C prep
  
SELECT2
    movlw    0x20        
    movwf    PORTA;set Select to 10
    movf    PORTA,W;grab the data from the controller
    andlw    0x0E;view only the data bits
    iorwf    RCPREP,F;outputs the data to port C prep

SELECT3
    movlw    0x30        
    movwf    PORTA;set Select to 11
    movf    PORTA,W;grab the data from the controller
    andlw    0x01;view only the data bits
    iorwf    RCPREP,F;outputs the data to port C prep

DATAOUT
    movf    RBPREP,W
    movwf    PORTB;moves RBPREP to port B
    movf    RCPREP,W
    movwf    PORTC;moves RCPREP to port B
    goto    BEGIN;loop back to start

    end        ;YOU MUST END!
