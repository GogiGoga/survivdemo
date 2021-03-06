;+++++++++++++++ SOUND ENGINE ++++++++++++
;Звуковой движок на основе
;Vortex Tracker II v1.0 PT3 player
;for ZX Spectrum
;(c)2004,2007 S.V.Bulba
;<vorobey@mail.khstu.ru>
;http://bulba.untergrund.net
;(http://bulba.at.kz)

                MAIN "GAME.H",#C0

TEST_MUSIC      LD HL,MUSIC
                CALL INIT_MUSIC
                EI
TEST_M1         HALT
                CALL PLAY_MUSIC
                CALL PLAY_SFX
                XOR A
                IN A,(#FE)
                XOR #FF
                LD B,A
                AND 1
                JR NZ,MUTE_MUSIC
                LD A,B
                AND 2
                JR Z,TEST_M2
                XOR A
                CALL INIT_SFX
TEST_M2         LD A,B
                AND 4
                JR Z,TEST_M3
                LD A,1
                CALL INIT_SFX
TEST_M3         LD A,B
                AND 8
                JR Z,TEST_M4
                CALL MUTE_SFX
TEST_M4         CALL AY_OUT
                JR TEST_M1

;--------------- Константы ---------------
TonA=0
TonB=2
TonC=4
Noise=6
Mixer=7
AmplA=8
AmplB=9
AmplC=10
Env=11
EnvTp=13
PsInOr=0
PsInSm=1
CrAmSl=2
CrNsSl=3
CrEnSl=4
TSlCnt=5
CrTnSl=6
TnAcc=8
COnOff=10
OnOffD=11
OffOnD=12
OrnPtr=13
SamPtr=15
NNtSkp=17
Note=18
SlToNt=19
Env_En=20
Flags=21
TnSlDl=22
TSlStp=23
TnDelt=25
NtSkCn=27
Volume=28
CHP=29
;-----------------------------------------



;set bit0 to 1, if you want to play without looping
;bit7 is set each time, when loop point is passed
SETUP   DB 0
CrPsPtr DW 0

;Identifier
        DB "=VTII PT3 Player r.7="

CHECKLP         LD HL,SETUP
                SET 7,(HL)
                BIT 0,(HL)
                RET Z
                POP HL
                LD HL,DelyCnt
                INC (HL)
                LD HL,ChanA+NtSkCn
                INC (HL)
MUTE_MUSIC
                XOR A
                LD H,A
                LD L,A
                LD (MUSIC_READY),A
                LD (AYREGS+AmplA),A
                LD (AYREGS+AmplB),HL
                JP AY_OUT


;инициализация музыки
;вх  - A - номер музыки

INIT_MUSIC      PUSH AF
                RAMPAGE 4
                CALL MUTE_MUSIC
                POP AF
                LD C,A
                LD A,(INIT_MAP_FIRST)
                OR A
                JR NZ,INIT_MUS1
                LD A,(CURRENT_MUSIC)
                CP C
                JP NZ,INIT_MUS1

;повторное использование
                LD A,(MUSIC_EXIST)
                OR A
                JR NZ,INIT_MUS3
                RET
;загрузка
INIT_MUS1       LD A,C
                LD (CURRENT_MUSIC),A
                DUP 4
                RRCA
                EDUP
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (MUSIC_NAME),A
                LD A,(CURRENT_MUSIC)
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (MUSIC_NAME+1),A

                LD HL,MUSIC
                LD DE,MUSIC_NAME
                LD BC,#2700
                CALL LOAD_FILE
                CALL EXIST_FILE
                JR NZ,INIT_MUS2
;файл ненайден
                XOR A
                LD (MUSIC_EXIST),A
                LD (MUSIC_READY),A
                RET

;инициализация
INIT_MUS2       LD A,#FF
                LD (MUSIC_EXIST),A
INIT_MUS3       LD HL,MUSIC
                LD (MODADDR),HL
                LD (MDADDR2),HL
                PUSH HL
                LD DE,100
                ADD HL,DE
                LD A,(HL)
                LD (Delay),A
                PUSH HL
                POP IX
                ADD HL,DE
                LD (CrPsPtr),HL
                LD E,(IX+102-100)
                ADD HL,DE
                INC HL
                LD (LPosPtr),HL
                POP DE
                LD L,(IX+103-100)
                LD H,(IX+104-100)
                ADD HL,DE
                LD (PatsPtr),HL
                LD HL,169
                ADD HL,DE
                LD (OrnPtrs),HL
                LD HL,105
                ADD HL,DE
                LD (SamPtrs),HL
                LD HL,SETUP
                RES 7,(HL)

;note table data depacker
                LD DE,T_PACK
                LD BC,T1_+(2*49)-1
TP_0            LD A,(DE)
                INC DE
                CP 15*2
                JR NC,TP_1
                LD H,A
                LD A,(DE)
                LD L,A
                INC DE
                JR TP_2

TP_1            PUSH DE
                LD D,0
                LD E,A
                ADD HL,DE
                ADD HL,DE
                POP DE
TP_2            LD A,H
                LD (BC),A
                DEC BC
                LD A,L
                LD (BC),A
                DEC BC
                SUB #F8*2
                JR NZ,TP_0

                LD HL,VARS
                LD (HL),A
                LD DE,VARS+1
                LD BC,VAR0END-VARS-1
                LDIR
                INC A
                LD (DelyCnt),A
                LD HL,#F001 ;H - Volume, L - NtSkCn
                LD (ChanA+NtSkCn),HL
                LD (ChanB+NtSkCn),HL
                LD (ChanC+NtSkCn),HL

                LD HL,EMPTYSAMORN
                LD (AdInPtA),HL ;ptr to zero
                LD (ChanA+OrnPtr),HL ;ornament 0 is "0,1,0"
                LD (ChanB+OrnPtr),HL ;in all versions from
                LD (ChanC+OrnPtr),HL ;3.xx to 3.6x and VTII

                LD (ChanA+SamPtr),HL ;S1 There is no default
                LD (ChanB+SamPtr),HL ;S2 sample in PT3, so, you
                LD (ChanC+SamPtr),HL ;S3 can comment S1,2,3; see
                                    ;also EMPTYSAMORN comment
                LD A,(IX+13-100) ;EXTRACT VERSION NUMBER
                SUB #30
                JR C,L20
                CP 10
                JR C,L21
L20             LD A,6
L21             LD (Version),A
                PUSH AF
                CP 4
                LD A,(IX+99-100) ;TONE TABLE NUMBER
                RLA
                AND 7

;NoteTableCreator (c) Ivan Roshin
;A - NoteTableNumber*2+VersionForNoteTable
;(xx1b - 3.xx..3.4r, xx0b - 3.4x..3.6x..VTII1.0)

                LD HL,NT_DATA
                PUSH DE
                LD D,B
                ADD A,A
                LD E,A
                ADD HL,DE
                LD E,(HL)
                INC HL
                SRL E
                SBC A,A
                AND #A7 ;#00 (NOP) or #A7 (AND A)
                LD (L3),A
                EX DE,HL
                POP BC ;BC=T1_
                ADD HL,BC
                LD A,(DE)
                ADD A,T_
                LD C,A
                ADC A,'T_
                SUB C
                LD B,A
                PUSH BC
                LD DE,NT_
                PUSH DE

                LD B,12
L1              PUSH BC
                LD C,(HL)
                INC HL
                PUSH HL
                LD B,(HL)

                PUSH DE
                EX DE,HL
                LD DE,23
                LD HX,8

L2              SRL B
                RR C
L3              DB #19 ;AND A or NOP
                LD A,C
                ADC A,D ;=ADC 0
                LD (HL),A
                INC HL
                LD A,B
                ADC A,D
                LD (HL),A
                ADD HL,DE
                DEC HX
                JR NZ,L2

                POP DE
                INC DE
                INC DE
                POP HL
                INC HL
                POP BC
                DJNZ L1

                POP HL
                POP DE

                LD A,E
                CP TCOLD_1
                JR NZ,CORR_1
                LD A,#FD
                LD (NT_+#2E),A

CORR_1          LD A,(DE)
                AND A
                JR Z,TC_EXIT
                RRA
                PUSH AF
                ADD A,A
                LD C,A
                ADD HL,BC
                POP AF
                JR NC,CORR_2
                DEC (HL)
                DEC (HL)
CORR_2          INC (HL)
                AND A
                SBC HL,BC
                INC DE
                JR CORR_1

TC_EXIT
                POP AF

;VolTableCreator (c) Ivan Roshin
;A - VersionForVolumeTable (0..4 - 3.xx..3.4x;
                           ;5.. - 3.5x..3.6x..VTII1.0)

                CP 5
                LD HL,#11
                LD D,H
                LD E,H
                LD A,#17
                JR NC,M1
                DEC L
                LD E,L
                XOR A
M1              LD (M2),A

                LD IX,VT_+16
                LD C,#10

INITV2          PUSH HL

                ADD HL,DE
                EX DE,HL
                SBC HL,HL

INITV1          LD A,L
M2              DB #7D
                LD A,H
                ADC A,0
                LD (IX),A
                INC IX
                ADD HL,DE
                INC C
                LD A,C
                AND 15
                JR NZ,INITV1

                POP HL
                LD A,E
                CP #77
                JR NZ,M3
                INC E
M3              LD A,C
                AND A
                JR NZ,INITV2

;инициализирована
                LD A,#FF
                LD (MUSIC_READY),A
                RET

;pattern decoder
PD_OrSm         LD (IX-12+Env_En),0
                CALL SETORN
                LD A,(BC)
                INC BC
                RRCA

PD_SAM          ADD A,A
PD_SAM_         LD E,A
                LD D,0
SamPtrs=$+1
                LD HL,#2121
                ADD HL,DE
                LD E,(HL)
                INC HL
                LD D,(HL)
MODADDR=$+1
                LD HL,#2121
                ADD HL,DE
                LD (IX-12+SamPtr),L
                LD (IX-12+SamPtr+1),H
                JR PD_LOOP

PD_VOL          RLCA
                RLCA
                RLCA
                RLCA
                LD (IX-12+Volume),A
                JR PD_LP2

PD_EOff         LD (IX-12+Env_En),A
                LD (IX-12+PsInOr),A
                JR PD_LP2

PD_SorE         DEC A
                JR NZ,PD_ENV
                LD A,(BC)
                INC BC
                LD (IX-12+NNtSkp),A
                JR PD_LP2

PD_ENV          CALL SETENV
                JR PD_LP2

PD_ORN          CALL SETORN
                JR PD_LOOP

PD_ESAM         LD (IX-12+Env_En),A
                LD (IX-12+PsInOr),A
                CALL NZ,SETENV
                LD A,(BC)
                INC BC
                JR PD_SAM_

PTDECOD         LD A,(IX-12+Note)
                LD (PrNote+1),A
                LD L,(IX-12+CrTnSl)
                LD H,(IX-12+CrTnSl+1)
                LD (PrSlide+1),HL

PD_LOOP         LD DE,#2010
PD_LP2          LD A,(BC)
                INC BC
                ADD A,E
                JR C,PD_OrSm
                ADD A,D
                JR Z,PD_FIN
                JR C,PD_SAM
                ADD A,E
                JR Z,PD_REL
                JR C,PD_VOL
                ADD A,E
                JR Z,PD_EOff
                JR C,PD_SorE
                ADD A,96
                JR C,PD_NOTE
                ADD A,E
                JR C,PD_ORN
                ADD A,D
                JR C,PD_NOIS
                ADD A,E
                JR C,PD_ESAM
                ADD A,A
                LD E,A
                LD HL,SPCCOMS+#FF20-#2000
                ADD HL,DE
                LD E,(HL)
                INC HL
                LD D,(HL)
                PUSH DE
                JR PD_LOOP

PD_NOIS         LD (Ns_Base),A
                JR PD_LP2

PD_REL          RES 0,(IX-12+Flags)
                JR PD_RES

PD_NOTE         LD (IX-12+Note),A
                SET 0,(IX-12+Flags)
                XOR A

PD_RES          LD (PDSP_+1),SP
                LD SP,IX
                LD H,A
                LD L,A
                PUSH HL
                PUSH HL
                PUSH HL
                PUSH HL
                PUSH HL
                PUSH HL
PDSP_           LD SP,#3131

PD_FIN          LD A,(IX-12+NNtSkp)
                LD (IX-12+NtSkCn),A
                RET

C_PORTM         RES 2,(IX-12+Flags)
                LD A,(BC)
                INC BC
;SKIP PRECALCULATED TONE DELTA (BECAUSE
;CANNOT BE RIGHT AFTER PT3 COMPILATION)
                INC BC
                INC BC
                LD (IX-12+TnSlDl),A
                LD (IX-12+TSlCnt),A
                LD DE,NT_
                LD A,(IX-12+Note)
                LD (IX-12+SlToNt),A
                ADD A,A
                LD L,A
                LD H,0
                ADD HL,DE
                LD A,(HL)
                INC HL
                LD H,(HL)
                LD L,A
                PUSH HL
PrNote          LD A,#3E
                LD (IX-12+Note),A
                ADD A,A
                LD L,A
                LD H,0
                ADD HL,DE
                LD E,(HL)
                INC HL
                LD D,(HL)
                POP HL
                SBC HL,DE
                LD (IX-12+TnDelt),L
                LD (IX-12+TnDelt+1),H
                LD E,(IX-12+CrTnSl)
                LD D,(IX-12+CrTnSl+1)
Version=$+1
                LD A,#3E
                CP 6
                JR C,OLDPRTM ;Old 3xxx for PT v3.5-
PrSlide         LD DE,#1111
                LD (IX-12+CrTnSl),E
                LD (IX-12+CrTnSl+1),D
OLDPRTM         LD A,(BC) ;SIGNED TONE STEP
                INC BC
                EXA
                LD A,(BC)
                INC BC
                AND A
                JR Z,NOSIG
                EX DE,HL
NOSIG           SBC HL,DE
                JP P,SET_STP
                CPL
                EXA
                NEG
                EXA
SET_STP         LD (IX-12+TSlStp+1),A
                EXA
                LD (IX-12+TSlStp),A
                LD (IX-12+COnOff),0
                RET

C_GLISS         SET 2,(IX-12+Flags)
                LD A,(BC)
                INC BC
                LD (IX-12+TnSlDl),A
                AND A
                JR NZ,GL36
                LD A,(Version) ;AlCo PT3.7+
                CP 7
                SBC A,A
                INC A
GL36            LD (IX-12+TSlCnt),A
                LD A,(BC)
                INC BC
                EXA
                LD A,(BC)
                INC BC
                JR SET_STP

C_SMPOS         LD A,(BC)
                INC BC
                LD (IX-12+PsInSm),A
                RET

C_ORPOS         LD A,(BC)
                INC BC
                LD (IX-12+PsInOr),A
                RET

C_VIBRT         LD A,(BC)
                INC BC
                LD (IX-12+OnOffD),A
                LD (IX-12+COnOff),A
                LD A,(BC)
                INC BC
                LD (IX-12+OffOnD),A
                XOR A
                LD (IX-12+TSlCnt),A
                LD (IX-12+CrTnSl),A
                LD (IX-12+CrTnSl+1),A
                RET

C_ENGLS         LD A,(BC)
                INC BC
                LD (Env_Del),A
                LD (CurEDel),A
                LD A,(BC)
                INC BC
                LD L,A
                LD A,(BC)
                INC BC
                LD H,A
                LD (ESldAdd),HL
                RET

C_DELAY         LD A,(BC)
                INC BC
                LD (Delay),A
                RET

SETENV          LD (IX-12+Env_En),E
                LD (AYREGS+EnvTp),A
                LD A,(BC)
                INC BC
                LD H,A
                LD A,(BC)
                INC BC
                LD L,A
                LD (EnvBase),HL
                XOR A
                LD (IX-12+PsInOr),A
                LD (CurEDel),A
                LD H,A
                LD L,A
                LD (CurESld),HL
C_NOP           RET

SETORN          ADD A,A
                LD E,A
                LD D,0
                LD (IX-12+PsInOr),D
OrnPtrs=$+1
                LD HL,#2121
                ADD HL,DE
                LD E,(HL)
                INC HL
                LD D,(HL)
MDADDR2=$+1
                LD HL,#2121
                ADD HL,DE
                LD (IX-12+OrnPtr),L
                LD (IX-12+OrnPtr+1),H
                RET

;ALL 16 ADDRESSES TO PROTECT FROM BROKEN PT3 MODULES
SPCCOMS         DW C_NOP
                DW C_GLISS
                DW C_PORTM
                DW C_SMPOS
                DW C_ORPOS
                DW C_VIBRT
                DW C_NOP
                DW C_NOP
                DW C_ENGLS
                DW C_DELAY
                DW C_NOP
                DW C_NOP
                DW C_NOP
                DW C_NOP
                DW C_NOP
                DW C_NOP

CHREGS          XOR A
                LD (Ampl),A
                BIT 0,(IX+Flags)
                PUSH HL
                JP Z,CH_EXIT
                LD (CSP_+1),SP
                LD L,(IX+OrnPtr)
                LD H,(IX+OrnPtr+1)
                LD SP,HL
                POP DE
                LD H,A
                LD A,(IX+PsInOr)
                LD L,A
                ADD HL,SP
                INC A
                CP D
                JR C,CH_ORPS
                LD A,E
CH_ORPS         LD (IX+PsInOr),A
                LD A,(IX+Note)
                ADD A,(HL)
                JP P,CH_NTP
                XOR A
CH_NTP          CP 96
                JR C,CH_NOK
                LD A,95
CH_NOK          ADD A,A
                EXA
                LD L,(IX+SamPtr)
                LD H,(IX+SamPtr+1)
                LD SP,HL
                POP DE
                LD H,0
                LD A,(IX+PsInSm)
                LD B,A
                ADD A,A
                ADD A,A
                LD L,A
                ADD HL,SP
                LD SP,HL
                LD A,B
                INC A
                CP D
                JR C,CH_SMPS
                LD A,E
CH_SMPS         LD (IX+PsInSm),A
                POP BC
                POP HL
                LD E,(IX+TnAcc)
                LD D,(IX+TnAcc+1)
                ADD HL,DE
                BIT 6,B
                JR Z,CH_NOAC
                LD (IX+TnAcc),L
                LD (IX+TnAcc+1),H
CH_NOAC         EX DE,HL
                EXA
                LD L,A
                LD H,0
                LD SP,NT_
                ADD HL,SP
                LD SP,HL
                POP HL
                ADD HL,DE
                LD E,(IX+CrTnSl)
                LD D,(IX+CrTnSl+1)
                ADD HL,DE
CSP_            LD SP,#3131
                EX (SP),HL
                XOR A
                OR (IX+TSlCnt)
                JR Z,CH_AMP
                DEC (IX+TSlCnt)
                JR NZ,CH_AMP
                LD A,(IX+TnSlDl)
                LD (IX+TSlCnt),A
                LD L,(IX+TSlStp)
                LD H,(IX+TSlStp+1)
                LD A,H
                ADD HL,DE
                LD (IX+CrTnSl),L
                LD (IX+CrTnSl+1),H
                BIT 2,(IX+Flags)
                JR NZ,CH_AMP
                LD E,(IX+TnDelt)
                LD D,(IX+TnDelt+1)
                AND A
                JR Z,CH_STPP
                EX DE,HL
CH_STPP         SBC HL,DE
                JP M,CH_AMP
                LD A,(IX+SlToNt)
                LD (IX+Note),A
                XOR A
                LD (IX+TSlCnt),A
                LD (IX+CrTnSl),A
                LD (IX+CrTnSl+1),A
CH_AMP          LD A,(IX+CrAmSl)
                BIT 7,C
                JR Z,CH_NOAM
                BIT 6,C
                JR Z,CH_AMIN
                CP 15
                JR Z,CH_NOAM
                INC A
                JR CH_SVAM
CH_AMIN         CP -15
                JR Z,CH_NOAM
                DEC A
CH_SVAM         LD (IX+CrAmSl),A
CH_NOAM         LD L,A
                LD A,B
                AND 15
                ADD A,L
                JP P,CH_APOS
                XOR A
CH_APOS         CP 16
                JR C,CH_VOL
                LD A,15
CH_VOL          OR (IX+Volume)
                LD L,A
                LD H,0
                LD DE,VT_
                ADD HL,DE
                LD A,(HL)
CH_ENV          BIT 0,C
                JR NZ,CH_NOEN
                OR (IX+Env_En)
CH_NOEN         LD (Ampl),A
                BIT 7,B
                LD A,C
                JR Z,NO_ENSL
                RLA
                RLA
                SRA A
                SRA A
                SRA A
                ADD A,(IX+CrEnSl) ;SEE COMMENT BELOW
                BIT 5,B
                JR Z,NO_ENAC
                LD (IX+CrEnSl),A
NO_ENAC         LD HL,AddToEn
                ADD A,(HL) ;BUG IN PT3 - NEED WORD HERE.
;FIX IT IN NEXT VERSION?
                LD (HL),A
                JR CH_MIX
NO_ENSL         RRA
                ADD A,(IX+CrNsSl)
                LD (AddToNs),A
                BIT 5,B
                JR Z,CH_MIX
                LD (IX+CrNsSl),A
CH_MIX          LD A,B
                RRA
                AND #48
CH_EXIT         LD HL,AYREGS+Mixer
                OR (HL)
                RRCA
                LD (HL),A
                POP HL
                XOR A
                OR (IX+COnOff)
                RET Z
                DEC (IX+COnOff)
                RET NZ
                XOR (IX+Flags)
                LD (IX+Flags),A
                RRA
                LD A,(IX+OnOffD)
                JR C,CH_ONDL
                LD A,(IX+OffOnD)
CH_ONDL         LD (IX+COnOff),A
                RET

;проигрыватель музыки
PLAY_MUSIC      XOR A
                LD (AddToEn),A
                LD (AYREGS+Mixer),A
                DEC A
                LD (AYREGS+EnvTp),A
                LD HL,DelyCnt
                DEC (HL)
                JR NZ,PL2
                LD HL,ChanA+NtSkCn
                DEC (HL)
                JR NZ,PL1B
AdInPtA=$+1
                LD BC,#0101
                LD A,(BC)
                AND A
                JR NZ,PL1A
                LD D,A
                LD (Ns_Base),A
                LD HL,(CrPsPtr)
                INC HL
                LD A,(HL)
                INC A
                JR NZ,PLNLP
                CALL CHECKLP
LPosPtr=$+1
                LD HL,#2121
                LD A,(HL)
                INC A
PLNLP           LD (CrPsPtr),HL
                DEC A
                ADD A,A
                LD E,A
                RL D
PatsPtr=$+1
                LD HL,#2121
                ADD HL,DE
                LD DE,(MODADDR)
                LD (PSP_+1),SP
                LD SP,HL
                POP HL
                ADD HL,DE
                LD B,H
                LD C,L
                POP HL
                ADD HL,DE
                LD (AdInPtB),HL
                POP HL
                ADD HL,DE
                LD (AdInPtC),HL
PSP_            LD SP,#3131
PL1A            LD IX,ChanA+12
                CALL PTDECOD
                LD (AdInPtA),BC

PL1B            LD HL,ChanB+NtSkCn
                DEC (HL)
                JR NZ,PL1C
                LD IX,ChanB+12
AdInPtB=$+1
                LD BC,#0101
                CALL PTDECOD
                LD (AdInPtB),BC

PL1C            LD HL,ChanC+NtSkCn
                DEC (HL)
                JR NZ,PL1D
                LD IX,ChanC+12
AdInPtC=$+1
                LD BC,#0101
                CALL PTDECOD
                LD (AdInPtC),BC

Delay=$+1
PL1D            LD A,#3E
                LD (DelyCnt),A

PL2             LD IX,ChanA
                LD HL,(AYREGS+TonA)
                CALL CHREGS
                LD (AYREGS+TonA),HL
                LD A,(Ampl)
                LD (AYREGS+AmplA),A
                LD IX,ChanB
                LD HL,(AYREGS+TonB)
                CALL CHREGS
                LD (AYREGS+TonB),HL
                LD A,(Ampl)
                LD (AYREGS+AmplB),A
                LD IX,ChanC
                LD HL,(AYREGS+TonC)
                CALL CHREGS
;               LD A,(Ampl) ;Ampl = AYREGS+AmplC
;               LD (AYREGS+AmplC),A
                LD (AYREGS+TonC),HL

                LD HL,(Ns_Base_AddToNs)
                LD A,H
                ADD A,L
                LD (AYREGS+Noise),A

AddToEn=$+1
                LD A,#3E
                LD E,A
                ADD A,A
                SBC A,A
                LD D,A
                LD HL,(EnvBase)
                ADD HL,DE
                LD DE,(CurESld)
                ADD HL,DE
                LD (AYREGS+Env),HL

                XOR A
                LD HL,CurEDel
                OR (HL)
                RET Z
                DEC (HL)
                RET NZ
Env_Del=$+1
                LD A,#3E
                LD (HL),A
ESldAdd=$+1
                LD HL,#2121
                ADD HL,DE
                LD (CurESld),HL
                RET


;вывод на AY из буфера
AY_OUT

;обработка FADEOUT
                LD A,(FADEOUT_MCONT)
                OR A
                JR Z,AY_OUT1
                RRCA
                RRCA
                AND #0F
                LD D,A

                LD A,(AYREGS+AmplA)
                LD C,A
                AND #F0
                LD B,A
                LD A,C
                AND #0F
                CP D
                JR C,$+3
                LD A,D
                OR B
                LD (AYREGS+AmplA),A

                LD A,(AYREGS+AmplB)
                LD C,A
                AND #F0
                LD B,A
                LD A,C
                AND #0F
                CP D
                JR C,$+3
                LD A,D
                OR B
                LD (AYREGS+AmplB),A

                LD A,(AYREGS+AmplC)
                LD C,A
                AND #F0
                LD B,A
                LD A,C
                AND #0F
                CP D
                JR C,$+3
                LD A,D
                OR B
                LD (AYREGS+AmplC),A

                LD A,(FADEOUT_MCONT)
                DEC A
                LD (FADEOUT_MCONT),A
                JR NZ,AY_OUT1
                LD (MUSIC_READY),A
                CALL MUTE_MUSIC
                RET

;вывод переменных в порты AY
AY_OUT1         XOR A
                LD DE,#FFBF
                LD BC,#FFFD
                LD HL,AYREGS
AY_OUT2         OUT (C),A
                LD B,E
                OUTI
                LD B,D
                INC A
                CP 13
                JR NZ,AY_OUT2
                OUT (C),A
                LD A,(HL)
                AND A
                RET M
                LD B,E
                OUT (C),A
                RET

;Stupid ALASM limitations
NT_DATA DB 50*2 ;(T_NEW_0-T1_)*2
        DB TCNEW_0-T_
        DB 50*2+1 ;(T_OLD_0-T1_)*2+1
        DB TCOLD_0-T_
        DB 0*2+1 ;(T_NEW_1-T1_)*2+1
        DB TCNEW_1-T_
        DB 0*2+1 ;(T_OLD_1-T1_)*2+1
        DB TCOLD_1-T_
        DB 74*2;(T_NEW_2-T1_)*2
        DB TCNEW_2-T_
        DB 24*2 ;(T_OLD_2-T1_)*2
        DB TCOLD_2-T_
        DB 48*2 ;(T_NEW_3-T1_)*2
        DB TCNEW_3-T_
        DB 48*2 ;(T_OLD_3-T1_)*2
        DB TCOLD_3-T_

T_

TCOLD_0 DB #00+1,#04+1,#08+1,#0A+1,#0C+1,#0E+1,#12+1,#14+1
        DB #18+1,#24+1,#3C+1,0
TCOLD_1 DB #5C+1,0
TCOLD_2 DB #30+1,#36+1,#4C+1,#52+1,#5E+1,#70+1,#82,#8C,#9C
        DB #9E,#A0,#A6,#A8,#AA,#AC,#AE,#AE,0
TCNEW_3 DB #56+1
TCOLD_3 DB #1E+1,#22+1,#24+1,#28+1,#2C+1,#2E+1,#32+1,#BE+1,0
TCNEW_0 DB #1C+1,#20+1,#22+1,#26+1,#2A+1,#2C+1,#30+1,#54+1
        DB #BC+1,#BE+1,0
TCNEW_1=TCOLD_1
TCNEW_2 DB #1A+1,#20+1,#24+1,#28+1,#2A+1,#3A+1,#4C+1,#5E+1
        DB #BA+1,#BC+1,#BE+1,0

EMPTYSAMORN=$-1
        DB 1,0,#90 ;delete #90 if you don't need default sample

;first 12 values of tone tables (packed)

T_PACK  DB #06EC*2/256,#06EC*2
        DB #0755-#06EC
        DB #07C5-#0755
        DB #083B-#07C5
        DB #08B8-#083B
        DB #093D-#08B8
        DB #09CA-#093D
        DB #0A5F-#09CA
        DB #0AFC-#0A5F
        DB #0BA4-#0AFC
        DB #0C55-#0BA4
        DB #0D10-#0C55
        DB #066D*2/256,#066D*2
        DB #06CF-#066D
        DB #0737-#06CF
        DB #07A4-#0737
        DB #0819-#07A4
        DB #0894-#0819
        DB #0917-#0894
        DB #09A1-#0917
        DB #0A33-#09A1
        DB #0ACF-#0A33
        DB #0B73-#0ACF
        DB #0C22-#0B73
        DB #0CDA-#0C22
        DB #0704*2/256,#0704*2
        DB #076E-#0704
        DB #07E0-#076E
        DB #0858-#07E0
        DB #08D6-#0858
        DB #095C-#08D6
        DB #09EC-#095C
        DB #0A82-#09EC
        DB #0B22-#0A82
        DB #0BCC-#0B22
        DB #0C80-#0BCC
        DB #0D3E-#0C80
        DB #07E0*2/256,#07E0*2
        DB #0858-#07E0
        DB #08E0-#0858
        DB #0960-#08E0
        DB #09F0-#0960
        DB #0A88-#09F0
        DB #0B28-#0A88
        DB #0BD8-#0B28
        DB #0C80-#0BD8
        DB #0D60-#0C80
        DB #0E10-#0D60
        DB #0EF8-#0E10

;vars from here can be stripped
;you can move VARS to any other address

VARS

ChanA   DS CHP
ChanB   DS CHP
ChanC   DS CHP

;GlobalVars
DelyCnt DB 0
CurESld DW 0
CurEDel DB 0
Ns_Base_AddToNs
Ns_Base DB 0
AddToNs DB 0
AYREGS
VT_     DS 256 ;CreatedVolumeTableAddress
EnvBase=VT_+14
T1_=VT_+16 ;Tone tables data depacked here
T_OLD_1=T1_
T_OLD_2=T_OLD_1+24
T_OLD_3=T_OLD_2+24
T_OLD_0=T_OLD_3+2
T_NEW_0=T_OLD_0
T_NEW_1=T_OLD_1
T_NEW_2=T_NEW_0+24
T_NEW_3=T_OLD_3
NT_     DS 192 ;CreatedNoteTableAddress
;local var
Ampl=AYREGS+AmplC
VAR0END=VT_+16 ;INIT zeroes from VARS to VAR0END-1
VARSEND=$


;инициализация эфектов
;меняет текущую страницу на 4
;вх  - A - номер эфекта (0..42)

INIT_SFX        LD HL,SFX_TAB
                ADD A,A
                ADD A,L
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                RAMPAGE 4
                LD A,(HL)
                INC HL
                LD H,(HL)
                LD L,A
                LD E,(HL)
                INC HL
                LD D,(HL)
                INC HL
                LD (SFX_POS),HL
                ADD HL,DE
                LD (SFX_LOOP),HL
                XOR A
                LD (SFX_END),A
                RET

;проигрыватель эфекта

PLAY_SFX        LD HL,(SFX_POS)
                LD A,H
                OR L
                JR NZ,PLAY_SFX1
;заглушка
                LD A,(SFX_END)
                OR A
                RET NZ
                LD (AYREGS+AmplB),A
                LD A,#FF
                LD (SFX_END),A
                RET

PLAY_SFX1       LD B,(HL)
                INC HL
                LD A,B
                DUP 4
                RRCA
                EDUP
                AND #0F
                LD (AYREGS+AmplB),A
;шум
                BIT 0,B
                JR Z,PLAY_SFX2
                LD A,(HL)
                INC HL
                AND #1F
                LD (AYREGS+Noise),A
                LD A,(AYREGS+Mixer)
                AND %11101111
                LD (AYREGS+Mixer),A
;тон
PLAY_SFX2       BIT 1,B
                JR Z,PLAY_SFX3
                LD A,(HL)
                INC HL
                AND #0F
                LD (AYREGS+TonB+1),A
                LD A,(HL)
                INC HL
                LD (AYREGS+TonB),A
                LD A,(AYREGS+Mixer)
                AND %11111101
                LD (AYREGS+Mixer),A
;закольцовка
PLAY_SFX3       BIT 2,B
                JR Z,PLAY_SFX4
                LD HL,(SFX_LOOP)
;конец семпла
PLAY_SFX4       BIT 3,B
                JR Z,PLAY_SFX5
MUTE_SFX        LD HL,0

PLAY_SFX5       LD (SFX_POS),HL
                RET
SFX_POS         DW 0
SFX_LOOP        DW 0
SFX_END         DB 0


;запуск постепенного затухания музыки

FADEOUT_MUSIC   LD A,63
                LD (FADEOUT_MCONT),A
FADEOUT_M1      EI
                HALT
                DNZ A,FADEOUT_M1
                RET
FADEOUT_MCONT   DB 0
