;основной модуль игры
;начало разработки - 02.10.2010

;режим компилирования

;EDITOR = 0 - игра, 1 - редактор
EDITOR=0
;BASIC = 0 - тестирование, 1 - BASIC
BASIC=0

;---------- распределение памяти ---------
MINI_FNT        EQU #AB00 ;размер #100
MAP_OBJECTS     EQU #AC00 ;размер #300
DISCRIPTORS     EQU #AF00 ;размер #200
INT_VECTOR      EQU #B100 ;размер #200
INPUT_CURSPR    EQU #B300 ;размер #600
TILE_TYPE       EQU #B900 ;размер #100
TRACE_TAB       EQU #BA00 ;размер #100
MAIN_TRACE      EQU #BB00 ;размер #100
CLUSTER_DISCR   EQU #BC00 ;размер #100
MAP_REDRAW      EQU #BCC0 ;размер #040
TEMP_TAB        EQU #BD00 ;размер #100
TAB_TILEPASS    EQU #BE00 ;размер #020
MAP_BUFFER      EQU #BE20 ;размер #0C0
MAIN_STEK       EQU #BFFF ;стек
;-------------- по страницам -------------
MAP             EQU #C000 ;размер #4000,0
SPRITES         EQU #C000 ;размер #4000,v
MUSIC           EQU #C000 ;размер #3000,4
SFX_TAB         EQU #E700 ;размер #1900,4
WIN_FNT         EQU #C000 ;размер #0800,6
TILE_SPRITE     EQU #DB00 ;размер #2500,7
PLACE_SPRITE    EQU #DB00 ;размер #0100,7
;-----------------------------------------


;--------------- константы ---------------
DISCR_LEN       EQU 32 ;длинна дискриптора
OBJECT_MAX      EQU 16 ;макс. колво объек.
MAP_PROPERTY    EQU #FF80 ;свойства карты
;-----------------------------------------


;----------- описатель объекта -----------
NUM             EQU 0  ;номер объекта
XCRD            EQU 1  ;коорд. X
YCRD            EQU 2  ;коорд. Y
LIFE            EQU 3  ;жизнь объекта
TYPE            EQU 4  ;тип объекта
XSM             EQU 5  ;смещ. X в символах
YSM             EQU 6  ;смещ. Y в пискелях
SPRT            EQU 7  ;текущий спрайт
DIRECT          EQU 8  ;направление
ORDER           EQU 9  ;текущий приказ
FAZE            EQU 10 ;текущая фаза пр.
CNTR            EQU 11 ;счетчик
XTAG            EQU 12 ;коорд. X цели
YTAG            EQU 13 ;коорд. Y цели
NEWORDER        EQU 14 ;новый приказ
BASEORDER       EQU 15 ;базовый приказ
TRACEADR        EQU 16 ;адрес в буфере
XLTAG           EQU 17 ;пред. X цели
YLTAG           EQU 18 ;пред. Y цели
NUMINT          EQU 19 ;номер взаим. объ.
ENEMY           EQU 20 ;признак врага
HIT             EQU 21 ;сила удара
DAMAGE          EQU 22 ;полученный урон
BULLET          EQU 23 ;кол-во патронов
MAXLIFE         EQU 24 ;макс. жизни

                ORG #6000
                ENT 
BEGIN_PROG

;------ BASIC MONOLOADER GENERATOR -------
;--- (c)2001 Evg/STALL -4b 2004 Alone  ---

                IFN BASIC
BASIC_START     EQU #5C53 ;начало BASIC программы
BASIC_VARS      EQU #5C4B ;конец программы, начало переменных
BASIC_END       EQU #5C59 ;конец переменных
BASIC_RUN       EQU #5CD1 ;номер строки старта
BASIC_MSKSZ     EQU #5D06 ;Количество символов поиска имени

                LD HL,BASIC_NAME
                LD C,19
                CALL #3D13
                LD A,9
                LD (BASIC_MSKSZ),A
                LD C,10
                CALL #3D13
                INC C
                LD C,18
                CALL NZ,#3D13
                LD HL,(BASIC_VARS)
                PUSH HL
                LD HL,(BASIC_START)
                PUSH HL
                LD HL,(BASIC_END)
                PUSH HL
                LD HL,BASIC_TST+BASIC_LEN-257
                LD (BASIC_VARS),HL
                LD HL,BASIC_TST-257
                LD (BASIC_START),HL
                LD HL,BASIC_TST+BASIC_VLEN-257
                LD (BASIC_END),HL
                LD HL,1
                LD (BASIC_RUN),HL
                LD C,12
                CALL #3D13
                POP HL
                LD (BASIC_END),HL
                POP HL
                LD (BASIC_START),HL
                POP HL
                LD (BASIC_VARS),HL
                RET 

BASIC_NAME      DB "DEMO    B"
BASIC_TST

                DISP #5D3B
BASIC_CODE      DB 0,1          ;STRING #
                DW BASIC_STRLEN
BASIC_STR       DB #FD ;CLEAR
                DB "0"
                DB #E,0,0       ;\
                DW MAIN_STEK    ;| #5FFF
                DB 0            ;/
                DB #3A,#D9,#C0  ;:INK USR
                DB "0"
                DB #E,0,0       ;\
                DW $+2          ;/ #5D50
                ENDIF 
;-----------------------------------------

                JP START

                ;CALL CAPTURE_SPRITE
                ;RET

                DI 
                LD HL,#C000
                LD DE,CAPTURE_SPN
                CALL LOAD_FILE

                LD A,#40
                LD (ACTIVE_SCREEN),A

                LD HL,#0000

LOOP            EI 
                HALT 

                LD A,2
                OUT (254),A

                LD C,0
                LD A,#40
                LD HL,#FF00
                CALL PUT_SPRITE
                INC H,H,L

                XOR A
                OUT (254),A
                IN A,(254)
                XOR #FF
                AND #1F
                JR Z,LOOP
                RET 

;-----------------------------------------
MAX_SPRSETS     EQU 2;кол-во SPRSET в RAM

;таблица расположения спрайтсетов
;1-ый байт - тип объекта
;2-ой байт - страница памяти
SPRITE_TYPE     DB 0,1        ;глав. герой
                DB 0,3
                DB 0,8
                DB 0,9
                DB 0,10
                DB 0,11
;-----------------------------------------


;---------- таблица свойств тайлов -------
TILEPASS        DB %00000000 ;0
                DB %00000000 ;1
                DB %11101110 ;2
                DB %00000000 ;3
                DB %00000000 ;4
                DB %11111111 ;5
                DB %10000011 ;6
                DB %00001110 ;7
                DB %00111000 ;8
                DB %11100000 ;9
                DB %10001111 ;10
                DB %00111110 ;11
                DB %11111000 ;12
                DB %11100011 ;13
                DB %11111111 ;14
                DB %00000000 ;15

                DB %00000000 ;0
                DB %00000000 ;1
                DB %11101110 ;2
                DB %00000000 ;3
                DB %00000000 ;4
                DB %11111111 ;5
                DB %00111000 ;6
                DB %11100000 ;7
                DB %10000011 ;8
                DB %00001110 ;9
                DB %11111000 ;10
                DB %11100011 ;11
                DB %10001111 ;12
                DB %00111110 ;13
                DB %11111111 ;14
                DB %11111111 ;15
;-----------------------------------------

;---------- таблицы для MAP_REDRAW -------
TAB_REDRAW      DW %1000000000000000
                DW %0100000000000000
                DW %0010000000000000
                DW %0001000000000000
                DW %0000100000000000
                DW %0000010000000000
                DW %0000001000000000
                DW %0000000100000000
                DW %0000000010000000
                DW %0000000001000000
                DW %0000000000100000
                DW %0000000000010000
                DW %0000000000001000
                DW %0000000000000100
                DW %0000000000000010
                DW %0000000000000001

                DW %1100000000000000
                DW %0110000000000000
                DW %0011000000000000
                DW %0001100000000000
                DW %0000110000000000
                DW %0000011000000000
                DW %0000001100000000
                DW %0000000110000000
                DW %0000000011000000
                DW %0000000001100000
                DW %0000000000110000
                DW %0000000000011000
                DW %0000000000001100
                DW %0000000000000110
                DW %0000000000000011
                DW %0000000000000001

                DW %1110000000000000
                DW %0111000000000000
                DW %0011100000000000
                DW %0001110000000000
                DW %0000111000000000
                DW %0000011100000000
                DW %0000001110000000
                DW %0000000111000000
                DW %0000000011100000
                DW %0000000001110000
                DW %0000000000111000
                DW %0000000000011100
                DW %0000000000001110
                DW %0000000000000111
                DW %0000000000000011
                DW %0000000000000001
;-----------------------------------------

                INCLUDE "ENGINE_1.H",#C1
                INCLUDE "ENGINE_2.H",#C2
                INCLUDE "ENGINE_3.H",#C3
                INCLUDE "S_ENGINE.H",#C4
                IF0 EDITOR
                  INCLUDE "OBJECTS.H",#C5
                  INCLUDE "MAINMODE.H",#C6
                ELSE 
                  INCLUDE "EDITOR_1.H",#C5
                  INCLUDE "EDITOR_2.H",#C6
                ENDIF 

START
;переносим стек
                LD (REST_STEK+1),SP
                LD SP,MAIN_STEK

;чистим дискрипторы
                LD HL,DISCRIPTORS
                LD DE,DISCRIPTORS+1
                LD BC,DISCR_LEN*OBJECT_MAX-1
                LD (HL),0
                LDIR 
                LD HL,CLUSTER_DISCR
                LD DE,CLUSTER_DISCR+1
                LD BC,254
                LD (HL),0
                LDIR 

;инициализируем таблицу трассировки
                LD HL,TRACE_TAB
                LD DE,TRACE_TAB+1
                LD BC,#FF
                LD (HL),15
                LDIR 

;инициализация глав. героя
                LD IX,DISCRIPTORS
                LD (IX+NUM),0
                LD (IX+XCRD),#32
                LD (IX+YCRD),#77
                LD (IX+XTAG),#32
                LD (IX+YTAG),#77
                ;LD (IX+XCRD),#05
                ;LD (IX+YCRD),#1B
                ;LD (IX+XTAG),#05
                ;LD (IX+YTAG),#1B
                LD (IX+XSM),0
                LD (IX+YSM),0
                LD (IX+DIRECT),4
                LD (IX+SPRT),4
                LD (IX+ENEMY),0
                LD (IX+TYPE),0
                LD (IX+BASEORDER),0
                LD (IX+LIFE),128
                LD (IX+HIT),16
                LD (IX+MAXLIFE),128
                LD (IX+BULLET),150

                CALL INIT_ENGINE

                IF0 EDITOR
                  LD HL,#2B70
                  ;LD HL,#0014
                  LD (MAP_XY),HL
                  CALL MAIN_MODE
                  CALL MUTE_MUSIC
                  CALL MUTE_SFX
                ELSE 
                  CALL GAME_EDIT
                  CALL MUTE_MUSIC
                  CALL MUTE_SFX
                ENDIF 

                IFN BASIC
                  JP START
                ENDIF 

REST_STEK       LD SP,0
                RET 

;--------------- переменные --------------
GAME_MODE       DB 0     ;текущий режим
CURSOR_TYPE     DB 0     ;тип курсора
CURSOR_CNTR     DB 0     ;сч-к курсора
FRAME_COUNTER   DB 0     ;счетчик фреймов
FRAME_CURRENT   DB 0     ;текущ. FPS
ACTION_POINT    DB 0     ;сч-к ходов
MAP_XY          DW 0     ;координаты карты
ACTIVE_SCREEN   DB #C0   ;активный экран
SCREEN_READY    DB 0     ;экран готов #FF
TIMER           DB 0     ;таймер
PLACE_XY        DW 0     ;координаты указ.
PLACE_CNTR      DB 0     ;счетчик указат.
CURRENT_MAP     DB 0     ;номер тек. карты
CURRENT_TILE    DB 0     ;номер тайлсета
CURRENT_MUSIC   DB 0     ;номер музыки
MUSIC_READY     DB 0     ;инициал. муз.
MUSIC_EXIST     DB 0     ;существование
MUSIC_ON        DB #FF   ;вкл. муз.
SFX_ON          DB #FF   ;вкл. муз.
;-----------------------------------------


;инициализация движка
INIT_ENGINE
                DI 
                IM 1
                EI 

;загрузка шрифтов
                RAMPAGE 6
                LD HL,WIN_FNT
                LD DE,FONT_NAME
                LD BC,#800
                CALL LOAD_FILE

                LD HL,MINI_FNT
                LD DE,MFONT_NAME
                LD BC,#100
                CALL LOAD_FILE

;загрузка курсоров
                LD HL,INPUT_CURSPR
                LD DE,CURSOR_NAME
                LD BC,#600
                CALL LOAD_FILE

;загрузка спрайтов глав. героя
                LD HL,SPRITE_TYPE+1
                LD A,(HL)
                CALL RAM_SEL
                LD HL,SPRITES
                LD A,"0"
                LD (SPRITE_NAME),A
                LD (SPRITE_NAME+1),A
                LD DE,SPRITE_NAME
                LD BC,#4000
                CALL LOAD_FILE

;инициализация звуковых эфектов
                RAMPAGE 4
                LD HL,SFX_TAB
                LD BC,#1900
                LD DE,SFX_NAME
                CALL LOAD_FILE

;инициализация прерываний
                DI 
                LD HL,INT_VECTOR
                LD B,0
                LD A,'INT_VECTOR+1
INIT_ENGINE1    LD (HL),A
                INC HL
                DJNZ INIT_ENGINE1
                LD (HL),A
                LD H,'INT_VECTOR+1
                LD L,H
                LD (HL),#C3
                INC HL
                LD DE,INTERRUPT
                LD (HL),E
                INC HL
                LD (HL),D
                LD A,'INT_VECTOR
                LD I,A
                IM 2
                EI 

;инициализация таблицы свойств тайлов
                LD HL,TILEPASS
                LD DE,TAB_TILEPASS
                LD BC,32
                LDIR 
                RET 


;инициализация карты и загрузка ресурсов
;вх  - A - номер карты
;INIT_MAP_FIRST - принудительная загрузка

INIT_MAP        DI 
                IM 1

;загрузка карты
                LD B,A
                LD A,(CURRENT_MAP)
                LD C,A
                RAMPAGE 0
                LD A,(INIT_MAP_FIRST)
                OR A
                LD A,B
                JR NZ,INIT_MAP1
                CP C
                JR Z,INIT_MAP2
INIT_MAP1       LD (CURRENT_MAP),A
                DUP 4
                RRCA 
                EDUP 
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (MAP_NAME),A
                LD A,B
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (MAP_NAME+1),A
                LD HL,MAP
                LD BC,#4000
                LD DE,MAP_NAME
                CALL LOAD_FILE

                CALL EXIST_FILE
                JR NZ,INIT_MAP2
                LD HL,MAP
                LD DE,MAP+1
                LD BC,#3FFF
                LD (HL),0
                LDIR 

;загрузка тайлов
INIT_MAP2       LD HL,MAP_PROPERTY
                LD A,(INIT_MAP_FIRST)
                OR A
                JR NZ,INIT_MAP3
                LD A,(CURRENT_TILE)
                CP (HL)
                JP Z,INIT_MAP7

INIT_MAP3       LD A,(HL)
                LD (CURRENT_TILE),A
                DUP 4
                RRCA 
                EDUP 
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (TILE_NAME),A
                LD A,(HL)
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (TILE_NAME+1),A

                RAMPAGE 7
                LD HL,TILE_SPRITE
                LD BC,#2500
                LD DE,TILE_NAME
                CALL LOAD_FILE

                CALL EXIST_FILE
                JR NZ,INIT_MAP4
                LD HL,TILE_SPRITE
                LD DE,TILE_SPRITE+1
                LD BC,#24FF
                LD (HL),0
                LDIR 

;переносим информацию о свойствах тайлов
INIT_MAP4       LD HL,TILE_SPRITE
                LD DE,TILE_TYPE
                LD BC,#100
                LDIR 
                LD HL,TILE_TYPE+255
                LD (HL),15

;загрузка спрайтов указателя трассера
                LD A,(INIT_MAP_FIRST)
                OR A
                JR Z,INIT_MAP7
                RAMPAGE 7
                LD HL,PLACE_SPRITE
                LD DE,PLACE_NAME
                LD BC,#100
                CALL LOAD_FILE

;загрузка спрайтсетов объектов

INIT_MAP7       RAMPAGE 0
                LD DE,MAP_PROPERTY+1
                LD HL,SPRITE_TYPE+2
                LD BC,#300
INIT_MAP8       PUSH BC,DE,HL
                LD B,MAX_SPRSETS-1
INIT_MAP9       LD A,(DE)
                CP (HL)
                JR Z,INIT_MAP10
                INC E
                DJNZ INIT_MAP9
                XOR A
                LD (HL),C
INIT_MAP10      POP HL,DE,BC
                INC HL,HL
                DJNZ INIT_MAP8

                LD DE,MAP_PROPERTY+1
                LD HL,SPRITE_TYPE+2
                LD B,MAX_SPRSETS-1
INIT_MAP11      PUSH BC,DE,HL
                RAMPAGE 0
                LD B,MAX_SPRSETS-1
INIT_MAP12      LD A,(DE)
                CP (HL)
                JR Z,INIT_MAP15
                INC HL,HL
                DJNZ INIT_MAP12
                LD HL,SPRITE_TYPE+2
                LD B,2
                XOR A
INIT_MAP13      CP (HL)
                JR Z,INIT_MAP14
                INC HL,HL
                DJNZ INIT_MAP13
INIT_MAP14      LD A,(DE)
                LD (HL),A
                LD B,A
                INC HL
                LD A,(HL)
                CALL RAM_SEL
                LD HL,SPRITES
                LD A,B
                DUP 4
                RRCA 
                EDUP 
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (SPRITE_NAME),A
                LD A,B
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (SPRITE_NAME+1),A
                LD BC,#4000
                LD DE,SPRITE_NAME
                CALL LOAD_FILE

                CALL EXIST_FILE
                JR NZ,INIT_MAP15
                LD D,H,E,L
                INC DE
                LD BC,#3FFF
                LD (HL),0
                LDIR 

INIT_MAP15      POP HL,DE,BC
                INC E
                DJNZ INIT_MAP11

;загрузка объектов карты
;(в дальнейшем нужно будет исправить на
;загрузку из профиля игрока)

                LD HL,MAP_NAME
                LD DE,OBJECT_NAME
                LD BC,2
                LDIR 
                LD HL,MAP_OBJECTS
                LD DE,OBJECT_NAME
                LD BC,#300
                CALL LOAD_FILE

                CALL EXIST_FILE
                JR NZ,INIT_MAP16
                LD D,H,E,L
                INC DE
                LD BC,#2FF
                LD (HL),0
                LDIR 

;загрузка основной музыки карты
INIT_MAP16      RAMPAGE 0
                LD HL,MAP_PROPERTY+7
                LD A,(HL)
                CALL INIT_MUSIC

                IM 2
                EI 
                RET 


INIT_MAP_FIRST  DB 0
MAP_NAME        DB "00      m"
TILE_NAME       DB "00      t"
SPRITE_NAME     DB "00      s"
OBJECT_NAME     DB "00      o"
MUSIC_NAME      DB "00      p"
PLACE_NAME      DB "place   C"
FONT_NAME       DB "font    r"
MFONT_NAME      DB "minifontr"
CURSOR_NAME     DB "cursors r"
SFX_NAME        DB "sfxbank C"


;обработка прерывания
INTERRUPT       DI 
                EX (SP),HL
                LD (INT_END+1),HL
                POP HL
                LD (INT_SP+1),SP
                PUSH DE
                LD SP,INT_STEK+127

                PUSH AF,BC,DE,HL,IX,IY
                EXX 
                EXA 
                PUSH AF,BC,DE,HL

                ;LD A,1
                ;OUT (254),A

                LD A,(RAM_SAVE)
                AND 7
                LD (INT_RAM+1),A
                RAMPAGE 7

;обработка курсора
                CALL REST_CURSOR
                LD A,(SCREEN_READY)
                OR A
                JP Z,INT_1
                CALL CHANGE_SCREEN
                XOR A
                LD (SCREEN_READY),A
INT_1           CALL MOUSE

;таймер
                LD A,(TIMER)
                INC A
                LD (TIMER),A
;тип курсора
                LD A,(CURSOR_TYPE)
;0 - стрелка
                OR A
                JP NZ,INT_2
                LD A,(TIMER)
                RRCA 
                AND 7
                LD (INPUT_ARROWTYPE),A
                LD HL,(INPUT_Y)
                JP INT_10

;1..8 - скролл экрана
INT_2           CP 9
                JP NC,INT_4
                LD HL,(INPUT_Y)
                ADD A,11
                LD (INPUT_ARROWTYPE),A
                CP 13
                JP C,INT_3
                CP 16
                JP NC,INT_3
                PUSH AF
                LD A,H
                SUB 12
                LD H,A
                POP AF
INT_3           CP 15
                JP C,INT_10
                CP 18
                JP NC,INT_10
                LD A,L
                SUB 12
                LD L,A
                JP INT_10
;9 - запрет
INT_4           CP 9
                JP NZ,INT_10
                LD HL,(INPUT_Y)
                LD A,20
                LD (INPUT_ARROWTYPE),A

INT_10          LD C,0

                IF0 EDITOR

;проверка на врага под стрелкой

                  CALL SEARCH_OBJECT
                  JP NZ,INT_12
                  LD A,(IY+ENEMY)
                  OR A
                  JP Z,INT_12

;задаем фазу курсора-прицела

                  LD A,(TIMER)
                  BIT 4,A
                  RRCA 
                  RRCA 
                  AND 3
                  JP Z,INT_11
                  LD C,A
                  LD A,3
                  SUB C
INT_11            ADD A,8
                  LD (INPUT_ARROWTYPE),A
                  LD C,8

                ENDIF 

INT_12          LD A,H
                SUB C
                LD H,A
                LD A,L
                SUB C
                LD L,A
                CALL PUT_CURSOR

                LD A,(CURSOR_CNTR)
                SUB 1
                ADC A,0
                LD (CURSOR_CNTR),A

;счетчик прерываний
                LD HL,FRAME_COUNTER
                INC (HL)

;проигрыватель музыки и эфектов
                LD A,(MUSIC_READY)
                OR A
                JR Z,INT_RAM
                RAMPAGE 4
                LD A,(MUSIC_ON)
                OR A
                CALL NZ,PLAY_MUSIC
                LD A,(SFX_ON)
                OR A
                CALL NZ,PLAY_SFX
                CALL AY_OUT

;восстановление текущей страницы памяти
INT_RAM         RAMPAGE 7


                ;XOR A
                ;OUT (254),A
                POP HL,DE,BC,AF
                EXX 
                EXA 
                POP IY,IX,HL,DE,BC,AF
INT_SP          LD SP,0
                EI 
INT_END         JP 0
INT_STEK        DS 128

;захват спрайтов
CAPTURE_SPRITE  DI 

;кол-во страйтсетов
                LD B,2

CAPTURE_S1      PUSH BC

                LD A,2
                SUB B
                ADD A,#30
                LD (CAPTURE_MSN+5),A
                LD (CAPTURE_SCN+5),A
                LD (CAPTURE_SPN+1),A

;кол-во скринов у одного спрайсета
                LD DE,#C000
                LD B,2

CAPTURE_S2      PUSH BC,DE

                LD A,2
                SUB B
                ADD A,#30
                LD (CAPTURE_MSN+7),A
                LD (CAPTURE_SCN+7),A

;обработка одного скрина
                LD B,2
CAPTURE_S3      PUSH BC,DE

                PUSH DE
                LD DE,CAPTURE_MSN
                LD A,B
                CP 2
                JR Z,$+5
                LD DE,CAPTURE_SCN
                LD HL,#4000
                CALL LOAD_FILE
                POP DE

                LD HL,#4000
                LD BC,#0806
CAPTURE_S4      PUSH BC,HL
                LD BC,#0420
CAPTURE_S5      LD A,(HL)
                LD (DE),A
                INC L,DE,DE
                DJNZ CAPTURE_S5
                LD B,4
                LD A,L
                SUB B
                LD L,A
                DOWN HL
                DNZ C,CAPTURE_S5
                POP HL,BC
                LD A,L
                ADD A,4
                LD L,A
                DJNZ CAPTURE_S4
                LD B,8
                LD A,L
                ADD A,128-32
                LD L,A
                JR NC,CAPTURE_S6
                LD A,H
                ADD A,8
                LD H,A
CAPTURE_S6      DNZ C,CAPTURE_S4

                POP DE,BC
                INC E
                DJNZ CAPTURE_S3

                POP DE,BC
                ADDW DE,#3000
                DJNZ CAPTURE_S2

                LD HL,#C000
                LD DE,CAPTURE_SPN
                LD BC,#4000
                CALL SAVE_FILE

                POP BC
                DNZ B,CAPTURE_S1
                EI 
                RET 

CAPTURE_SCN     DB "char_0.0C"
CAPTURE_MSN     DB "char_0.0M"
CAPTURE_SPN     DB "00      s"

                IFN BASIC
                BASIC_STRLEN=$-BASIC_STR
                BASIC_LEN=$-BASIC_CODE
                DB #80
                BASIC_VLEN=$-BASIC_CODE
                DB #AA
                DW 0
                ENDIF 
END_PROG

DISPLAY "Begin adress = ",BEGIN_PROG
DISPLAY "End   adress = ",END_PROG
DISPLAY "Len          = ",END_PROG-BEGIN_PROG



