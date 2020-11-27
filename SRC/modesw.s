;--------------------------------------------------------------
; ModeSwitch
;
; Automatic screen mode switcher.
;
; (c)2020 Anders Granlund
;
;--------------------------------------------------------------
;
; These files are distributed under the GPL v2, or at your
; option any later version. See LICENSE.TXT for details
; 
;--------------------------------------------------------------

MAXINFS		EQU 256

section bss
gStackTop	ds.l 256		; 1024 byte stack
gStack		ds.l 2
gTsrSize	ds.l 1			; program size for TSR

gActive		ds.w 1
gFlags		ds.w 1
gBasePage	ds.l 1
gInfFile	ds.l 1			; inf file in memory
gInfSize	ds.l 1
gInfEntries	ds.w 1			; number of inf entries
gInfNames	ds.l MAXINFS		; name ptrs
gInfFlags	ds.b MAXINFS		; flag ptrs

; original vectors and variables
gOrgTrap1	ds.l 1
gOrgTrap2	ds.l 1
gOrgTrap13	ds.l 1
gOrgTrap14	ds.l 1
gOrgBconout	ds.l 8
gOrgLineaFonts	ds.l 4
gOrgLineaVecs	ds.l 16
gOrgLineaVars	ds.b 2000

gOrgLogBase	ds.l 1
gOrgPhysBase	ds.l 1


; saved vectors and variables
gBakTrap1	ds.l 1
gBakTrap2	ds.l 1
gBakTrap13	ds.l 1
gBakTrap14	ds.l 1
gBakLogBase	ds.l 1
gBakPhysBase	ds.l 1
gBakRez		ds.l 1
gBakLogBase2	ds.l 1
gBakPhysBase2	ds.l 1
gBakRez2	ds.l 1
gBakBconout	ds.l 8
gBakLineaVars	ds.b 2000
gBakLineaFonts	ds.l 4
gBakLineaVecs	ds.l 16
gBakGPO		ds.W 1
gBakLace	ds.w 1



DI	MACRO
	move.w	sr,-(sp)
	ori.w	#$700,sr
	ENDM

EI	MACRO
	move.w	(sp)+,sr
	ENDM


;--------------------------------------------------------------
section data
;--------------------------------------------------------------
sInfFile:	dc.b "AUTO\MODESW.INF",0



section text

;--------------------------------------------------------------
startup:
;--------------------------------------------------------------
	move.l	4(sp),a0		; a0 = basepage
	lea	gStack(pc),sp		; initalize stack
	move.l	#100,d0			; basepage size
	add.l	#$1000,d0		; 
	add.l	$c(a0),d0		; text size
	add.l	$14(a0),d0		; data size
	add.l	$1c(a0),d0		; bss size
	lea	gTsrSize(pc),a1
	move.l	d0,(a1)
	move.l	d0,-(sp)		; Mshrink()
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	lea	main(pc),a0		; call main as supervisor
	pea	(a0)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	tst.w	d0			; check return code from main
	beq	.fail			; 0 = exit normally
	move.w	#0,-(sp)		; 1 = stay resident
	lea	gTsrSize(pc),a0
	move.l	(a0),-(sp)
	move.w	#49,-(sp)
	trap	#1
	addq.l	#8,sp
.fail	move.w	#0,-(sp)
	move.w	#76,-(sp) 
	trap	#1
	addq.l	#4,sp



;--------------------------------------------------------------
main:
;--------------------------------------------------------------

	move.w	#0,gActive
	move.b	#0,gFlags

	bsr	loadInf			; parse config file
	cmp.w	#0,d0
	beq	.fail

	DI

	move.w	#2,-(sp)		; get original physbase
	trap	#14
	addq.l	#2,sp
	move.l	d0,gOrgPhysBase
	move.w	#3,-(sp)		; get original logbase
	trap	#14
	addq.l	#2,sp
	move.l	d0,gOrgLogBase

	lea	$57E,a0			; get original bconout
	lea	gOrgBconout(pc),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	dc.w	$A000
	lea	gOrgLineaFonts(pc),a3	; get original linea fonts
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	lea	gOrgLineaVecs(pc),a3	; get original linea vectors
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	sub.l	#$38E,a0		; get original linea vars
	lea	gOrgLineaVars(pc),a3
	move.w	#515,d0
.laloop	move.w	(a0)+,(a3)+
	sub.w	#1,d0
	bne 	.laloop

	move.l	$84,gOrgTrap1		; get trap1 (gemdos)
	move.l	$88,gOrgTrap2		; get trap2 (vdi/aes)
	move.l	$B4,gOrgTrap13		; get trap13 (bios)
	move.l	$B8,gOrgTrap14		; get trap14 (xbios)

	pea	Trap1(pc)		; replace Trap1 (gemdos)
	move.w	#$21,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.l	#8,sp

	EI

	move.w	#1,d0
	rts
.fail	move.w	#0,d0
	rts


;--------------------------------------------------------------
swv_vec:
;--------------------------------------------------------------
	rts


;--------------------------------------------------------------
SetMode:
; d0 = flags
;--------------------------------------------------------------

	movem.l	d0-d2/a0-a4,-(sp)

	DI

	and.w	#3,d0
	move.w	d0,-(sp)		; push new rez

	bsr	getLace			; get et4000/lacescan mode
	move.b	d0,gBakLace
	tst.b	d0
	bne	.swap_xbios

	move.w	#4,-(sp)		; backup current rez
	trap	#14
	addq.l	#2,sp
	move.w	d0,gBakRez2

	move.l	#-1,-(sp)		; push new physbase (no change)
	move.l	#-1,-(sp)		; push new logbase (no change)
	bra	.changerez
	

.swap_xbios

	move.w	#2,-(sp)		; backup current physbase
	trap	#14
	addq.l	#2,sp
	move.l	d0,gBakPhysBase
	move.w	#3,-(sp)		; backup current logbase
	trap	#14
	addq.l	#2,sp
	move.l	d0,gBakLogBase
	move.w	#4,-(sp)		; backup current rez
	trap	#14
	addq.l	#2,sp
	move.w	d0,gBakRez

;	move.b	$44C,gBakRez
;	move.l	$44E,gBakLogBase

	lea	$57E,a0			; backout bconout and set original
	lea	gOrgBconout(pc),a1
	lea	gBakBconout(pc),a2
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+
	move.l	(a0),(a2)+
	move.l	(a1)+,(a0)+


	dc.w	$A000
	lea	gBakLineaFonts(pc),a3	; backup linea fonts and set original
	lea	gOrgLineaFonts(pc),a4
	move.l	(a1),(a3)+
	move.l	(a4)+,(a1)+
	move.l	(a1),(a3)+
	move.l	(a4)+,(a1)+
	move.l	(a1),(a3)+
	move.l	(a4)+,(a1)+
	move.l	(a1),(a3)+
	move.l	(a4)+,(a1)+
	move.l	#gBakLineaVecs,a3	; backup linea vectors and set original
	move.l	#gOrgLineaVecs,a4
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	move.l	(a2),(a3)+
	move.l	(a4)+,(a2)+
	sub.l	#$38E,a0		; backup linea vars and set original
	lea	gBakLineaVars(pc),a2
	lea	gOrgLineaVars(pc),a3
	move.w	#515,d0
.laloop	move.w	(a0),(a2)+
;	move.w	(a3)+,(a0)+
	add.l	#2,a0
	sub.w	#1,d0
	bne 	.laloop

	move.w	#0,-(sp)		; get rid of cursor
	move.w	#0,-(sp)
	move.w	#21,-(sp)
	trap	#14
	addq.l	#6,sp

;	move.l	$84,gBakTrap1		; use old gemdos
;	move.l	#Trap1,$84
;	move.l	$88,gBakTrap2		; use old aes/vdi
;	move.l	gOrgTrap2,$88
;	move.l	$B4,gBakTrap13		; use old bios
;	move.l	gOrgTrap13,$B4
	move.l	$B8,gBakTrap14		; use old xbios
	move.l	gOrgTrap14,$B8

	move.w	#4,-(sp)		; backup rez old xbios
	trap	#14
	addq.l	#2,sp
	move.w	d0,gBakRez2

	move.b	#0,d0			; disable et4000/lacescan
	bsr	setLace

	move.l	gOrgLogBase,-(sp)
	move.l	gOrgPhysBase,-(sp)

.changerez
	move.l	(sp)+,d2
	move.l	(Sp)+,d1
	move.w	(sp)+,d0
	bsr	setScreen
	
	EI
	movem.l	(sp)+,d0-d2/a0-a4
	rts
	


;--------------------------------------------------------------
RestoreMode:
;--------------------------------------------------------------
	movem.l	d0-d2/a0-a4,-(sp)

	move.w	gBakRez2,d0		; restore rez
	move.l	#-1,d1
	move.l	#-1,d2
	bsr	setScreen

	tst.b	gBakLace
	beq	.finish


.restore_xbios
	DI

	move.l	#swv_vec,$46E		; set dummy mono vec


	move.l	gBakTrap14,$B8		; restore xbios
;	move.l	gBakTrap13,$B4		; restore bios
;	move.l	gBakTrap2,$88		; restore aes/vdi
;	move.l	gBakTrap1,$84		; restore gemdos


;	move.w	gBakRez,-(sp)
;	move.l	gBakPhysBase,-(sp)
;	move.l	gBakLogBase,-(sp)
;	move.w	#5,-(sp)
;	trap	#14
;	lea	$C(sp),sp

	move.w	gBakRez,d0
	move.l	gBakPhysBase,d1
	move.l	gBakLogBase,d2
	bsr	setScreen

	move.b	gBakRez,$44C		; set directly in case setscreen
	move.l	gBakLogBase,$44E	; was disabled (et4000 driver etc) 

	lea	$57E,a1			; restore bconout
	lea	gBakBconout(pc),a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	dc.w	$A000
	lea	gBakLineaFonts(pc),a3	; restore linea fonts
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	move.l	(a3)+,(a1)+
	lea	gBakLineaVecs(pc),a3	; restore linea vectors
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	sub.l	#$38E,a0		; restore linea vars
	lea	gBakLineaVars(pc),a3
	move.w	#515,d0
.laloop	move.w	(a3)+,(a0)+
	sub.w	#1,d0
	bne 	.laloop	

.test
	move.b	#1,d0
	bsr	setLace			; restore et4000/lacescan
	EI

.finish	movem.l	(sp)+,d0-d2/a0-a4
	rts


;--------------------------------------------------------------
setScreen:
;--------------------------------------------------------------
	move.w	sr,-(sp)		; save status reg
	move.l	$46E,-(sp)		; save mono vec

	move.l	#swv_vec,$46E		; set dummy mono vec
	move.w	#$2500,sr		; disable vbl irq

	move.w	d0,-(sp)		; set screen
	move.l	d1,-(sp)
	move.l	d2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	$C(sp),sp

	; todo: make sure timerC is actually running
	move.l	$4BA,d0			; give ubeswitch a chance to react
	add.l	#10,d0
.wait1	cmp.l	$4BA,d0
	bhi	.wait1

	move.w	#$2300,sr		; enable vbl irq

	move.l	$4BA,d0			; give tos a chance to react
	add.l	#10,d0
.wait2	cmp.l	$4BA,d0
	bhi	.wait2

	move.l	(sp)+,$46E		; restore mono vec
	move.w	(sp)+,sr		; restore status reg
	rts


;--------------------------------------------------------------
getLace:
;--------------------------------------------------------------
	move.w	#3,-(sp)		; logbase
	trap	#14
	addq.l	#2,sp
	cmp.l	#$FEC00000,d0		; ET4000?
	beq	.ret1

	move.l	#'Lace',d0		; Lacescan?
	bsr	getCookie
	cmp.w	#0,d0
	beq	.ret0

	; todo: check if Lacescan is active or not
	bra	.ret1


.ret0	move.b	#0,d0
	rts
.ret1	move.b	#1,d0
	rts

;--------------------------------------------------------------
setLace:
;--------------------------------------------------------------
	cmp.b	#0,d0
	bne	.set
	move.b	#$96,$FFFFFC00.w
	rts
.set	move.b	#$D6,$FFFFFC00.w
	rts


;--------------------------------------------------------------
getGPO:
;--------------------------------------------------------------
	move.b	#14,$FF8800
	move.b	$FF8802,d0
	and.b	#$40,d0
	rts


;--------------------------------------------------------------
setGPO:
;--------------------------------------------------------------
	movem.l	d0-d1,-(sp)
	move.b	#14,$FF8800
	move.b	$FF8802,d1
	and.b	#$BF,d1
	and.b	#$40,d0
	or.b	d0,d1
	move.b	d1,$FF8802
	movem.l	(sp)+,d0-d1
	rts


;--------------------------------------------------------------
Trap1:
;--------------------------------------------------------------
	move	usp,a0
	btst    #5,(sp)			; Already supervisor?
	beq.s   .handle
	lea     6(sp),a0
	tst.w   $59e.w			; Long stackframes?
	beq.s   .handle
	addq.l  #2,a0			; 2 more parameters for long stackframe
.handle	move.w  (a0)+,d0		; d0 = gemdos function number
	cmp.w   #75,d0
	beq     Trap1_Pexec		; Pexec
	cmp.w	#76,d0
	beq	Trap1_Pterm		; Pterm
	cmp.w	#0,d0
	beq	Trap1_Pterm		; Pterm0
	cmp.w	#49,d0
	beq	Trap1_Pterm		; Ptermres
Trap1Prev:
	movea.l gOrgTrap1(PC),a0	; call previous trap handler
	jmp	(a0)


;--------------------------------------------------------------
Trap1_Pexec:
;--------------------------------------------------------------
	tst.w	gActive			; already active?
	bne	Trap1Prev
	cmp.w	#0,(a0)+		; PE_LOAD?
	bne	Trap1Prev		; no, use old trap handler
	move.l	(a0),a0			; a0 = name ptr
	move.l	#gInfNames,a2
.loop	tst.l	(a2)
	beq	.done
	move.l	(a2)+,a1
	bsr	CompareSubStrings
	beq	.found
	bra	.loop
.found	move.l	a2,d1
	sub.l	#gInfNames,d1
	sub.l	#4,d1
	lsr.l	#2,d1
	move.l	#gInfFlags,a2
	move.b	0(a2,d1),d0
	bsr	SetMode

	move.l	$4F2,a0			; a0 = OSHEADER
	move.l	40(a0),a0		; a0 = BP**
	move.l	(a0),gBasePage		; store current basepage

	move.w	#1,gActive
.done	bra	Trap1Prev		; let old trap handler continue



;--------------------------------------------------------------
Trap1_Pterm:
;--------------------------------------------------------------
	tst.w	gActive
	beq	.ignore

	move.l	$4F2,a0			; a0 = OSHEADER
	move.l	40(a0),a0		; a0 = BP**
	move.l	(a0),a0			; a0 = BP*
	move.l	36(a0),d0		; a0 = p_parent
	cmp.l	gBasePage,d0		; verify parent process
	bne	.ignore

	bsr	RestoreMode
	move.w	#0,gActive
.ignore	bra	Trap1Prev



;--------------------------------------------------------------
CompareSubStrings:
;	input: a0, a1
;	return: d0 = 1 or 0
;--------------------------------------------------------------
	move.l	a0,-(sp)
.loop	tst.b	(a0)
	beq	.nfound
	bsr	CompareStrings
	beq	.found
	add.l	#1,a0
	bra	.loop
.found	clr.w	d0
	bra	.done
.nfound	move.w	#1,d0
.done	move.l	(sp)+,a0
	tst.w	d0
	rts




;--------------------------------------------------------------
CompareStrings:
;	input: a0, a1
;	return: d0 = 1 or 0
;--------------------------------------------------------------
	move.l	a0,-(sp)
	move.l	a1,-(sp)
.cslp	move.b	(a0)+,d0
	move.b	(a1)+,d1
	cmp.b	#0,d1		; compare up to length of a1
	beq	.cseq
	cmp.b	d0,d1
	bne	.csne
	cmp.b	#0,d0
	bne	.cslp
.cseq	clr.w	d0
	bra	.csdn
.csne	move.w	#1,d0
.csdn	move.l	(sp)+,a1
	move.l	(sp)+,a0
	tst.w	d0
	rts


;--------------------------------------------------------------
getCookie:
; value of cookie d0 is returned in d1.
; returns d0=1 if cookie exists, 0 if not
;--------------------------------------------------------------
	move.l	$5a0,d2			; has cookies?
	beq	.l3
	move.l	d2,a0
.l1	tst.l	(a0)			; end of cookies?
	beq	.l3
	cmp.l	(a0),d0			; compare cookie name
	beq	.l2
	addq.l	#8,a0
	bra	.l1
.l2 	move.l	4(a0),d1		; found
	move.w	#1,d0
	rts
.l3	moveq.l #0,d1			; not found
	moveq.l #0,d0
	rts

;--------------------------------------------------------------
setCookie:	
; create/update cookie d0 with value d1
; will resize or create jar as needed
;--------------------------------------------------------------
	move.l	d0,d3			; d3 = cookie
	move.l	d1,d4			; d4 = value
	moveq.l	#1,d5			; d5 = end cookie slot
	moveq.l	#0,d6			; d6 = jar total size
	movea.l	$5a0,a3			; a3 = current slot ptr
	move.l	a3,a4			; a4 = jar start ptr
	cmp.l	#0,a3
	beq	.create
.size	tst.l	(a3)			; end cookie?
	beq	.l1
	cmp.l	(a3),d3			; exist?
	beq	.update
	addq.l	#1,d5
	addq.l	#8,a3
	bra	.size
.l1 	move.l	4(a3),d6
	cmp.l	d6,d5			; jar full?
	bcs.s	.write
.create	add.l	#20,d6			; add 20 slots
	move.l	d6,d0
	lsl.l	#3,d0			; 8 bytes per slot
	move.l	d0,-(sp)
	move.w	#72,-(sp)
	trap	#1			; allocate
	addq.l	#6,sp
	cmp.l	#0,d0			; failed?
	beq	.end
	move.l	d0,a3			; copy old
	move.l	d5,d1
.l2	cmp.l	#1,d1
	beq	.l3
	move.l	(a4)+,(a3)+
	move.l	(a4)+,(a3)+
	subq.l	#1,d1
	bra	.l2
.l3 	move.l	d0,$5a0			; set new jar
.write					; update jar
	move.l	#0,8(a3)		; add end cookie
	move.l	d6,12(a3)
.update
	move.l	d3,0(a3)		; add new cookie
	move.l	d4,4(a3)
.end	rts




;--------------------------------------------------------------
loadInf:
;--------------------------------------------------------------
	move.w	#0,-(sp)		; open file
	pea	sInfFile
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	btst.l	#31,d0
	bne	.fail
	move.w	d0,d7			; d7 = handle
	move.w	#2,-(sp)		; get file size
	move.w	d7,-(sp)
	move.l	#0,-(sp)
	move.w	#66,-(sp)
	trap	#1
	lea	$A(sp),sp
	move.l	d0,gInfSize
	cmp.l	#0,d0
	beq	.inffin
	move.w	#0,-(sp)
	move.w	d7,-(sp)
	move.l	#0,-(sp)
	move.w	#66,-(sp)
	trap	#1
	lea	$A(sp),sp
	move.l	gInfSize,d0
	add.l	#1,d0
	move.l	d0,-(sp)		; allocate size+1
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,gInfFile
	cmp.l	#0,d0
	ble	.infnok
	add.l	gInfSize,d0		; clear last byte
	move.l	d0,a0
	move.b	#0,(a0)
	move.l	gInfFile,-(sp)		; read file
	move.l	gInfSize,-(sp)
	move.w	d7,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	$C(sp),sp	
	cmp.l	gInfSize,d0
	bne	.infnok
	add.l	#1,gInfSize
.infok	move.w	#1,d0
	bra	.inffin
.infnok	move.w	#0,d0
.inffin	move.w	d0,-(sp)
	move.w	d7,-(sp)		; close file
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	(sp)+,d0
	cmp.w	#0,d0
	beq	.fail
	bsr	parseInf		; parse buffer
	cmp.w	#0,d0
	beq	.fail
.ok	move.w	#1,d0
	rts
.fail	moveq.l	#0,d0
	rts

;--------------------------------------------------------------
parseInf:
;  returns number of entries in d0
;--------------------------------------------------------------
	move.w	#0,d7			; d7 = num entries
	move.w	#0,d6			; d6 = offset
	move.l	gInfFile,a0; 		; a0 = buffer ptr
	move.l	a0,a1
	add.l	gInfSize,a1		; a1 = end of buffer
	move.l	#gInfFlags,a2		; a2 = flag buffer
	move.l	#gInfNames,a3		; a3 = name buffer

.cl0	move.b	(a0),d0			; format whitespaces
	cmp.b	#32,d0
	bls	.ws
	cmp.b	#126,d0
	bhi	.ws
.cl1	add.l	#1,a0
	cmp.l	a0,a1
	bne	.cl0
	bra	.cld
.ws	move.b	#0,(a0)
	bra	.cl1
.cld	move.l	gInfFile,a0

.loop	bsr	parseFlag; 		; parse flag
	cmp.b	#$FF,d0
	beq	.done
	move.b	d0,0(a2,d7)	
	bsr	parseName		; parse name
	cmp.l	#0,d0
	beq	.done
	move.l	d0,0(a3,d6)
	add.w	#1,d7			; and again...
	add.w	#4,d6
	cmp.w	#MAXINFS,d7
	beq	.done
	bra	.loop
.done	move.w	d7,d0
	rts


;--------------------------------------------------------------
parseFlag:
;--------------------------------------------------------------
	bsr	parseString
	cmp.l	#0,a4			; ptr ok?
	beq	.fail
	cmp.l	#1,d0			; size ok?
	ble	.fail
	move.b	(a4)+,d0		; first char is upper 4 bits
	sub.b	#48,d0
	and.b	#$F,d0
	lsl.b	#4,d0
	move.b	(a4),d1			; second char is lower 4 bits
	sub.b	#48,d1
	and.b	#$F,d1
	or.b	d1,d0
	rts
.fail	move.w	#$FF,d0
	rts

;--------------------------------------------------------------
parseName:
;--------------------------------------------------------------
	bsr	parseString
	move.l	a4,d0
	rts

;--------------------------------------------------------------
parseString:
; returns string in a4, length in d0
;--------------------------------------------------------------
.l0	cmp.l	a0,a1			; skip whitespaces
	beq	.fail
	move.b	(a0),d0
	cmp.b	#0,d0
	bne	.l1
	add.l	#1,a0
	bra	.l0	
.l1	move.l	a0,a4			; a4 = start
.l2	cmp.l	a0,a1
	beq	.fail
	move.b	(a0),d0
	cmp.b	#0,d0
	beq	.l3
	add.l	#1,a0
	bra	.l2
.l3	move.l	a0,d0			; a0 = end
	move.l	a4,d1
	sub.l	d1,d0			; d0 = length
	rts
.fail	move.l	#0,a4
	move.l	#0,d0
	rts



