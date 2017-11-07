;++++++++++++++++ ENGINE_1.H +++++++++++++
;движок игры

                MAIN "GAME.H",#C0

;--------- расширение Ассемблера ---------
;(C) SaNcHeZ

;сложить A и двухбайтный регистр
;портит: A
;пример: ADDA HL

MACRO           ADDA
                ADD A,\N\C
                LD \C,A
                LD A,\R\C
                ADC A,0
                LD \C,A
ENDM 

;сложить двухбайтный регистр и слово
;портит: A
;пример: ADDW HL,#C000

MACRO           ADDW
                LD A,\N\C
                ADD A,.\1
                LD \C,A
                LD A,\R\C
                ADC A,'\1
                LD \C,A
ENDM 

;декремент регистра и переход если не 0
;портит: нет
;пример: DNZ C,label

MACRO           DNZ
                DEC \0
                JP NZ,\1
ENDM 


;-------------- переменные ---------------
INPUT_Y         DB 80 ;коорд Y мышки
INPUT_X         DB 8 ;коорд X мышки
INPUT_OVER      DB 0 ;выход за пределы
INPUT_KEY       DB 0 ;нажатие на кнопки
INPUT_BUTTON    DB 0 ;кнопки мышки
INPUT_ARROWTYPE DB 0 ;тип курсора
INPUT_ARROWCENT DB 0 ;0-HOME,1-CENTER
INPUT_KEYBSPD   DB 0 ;скорость для клав.
INPUT_KEYBUSE   DB 0 ;признак исп. клав.

KEY_LEFT        DW #DF02
KEY_RIGHT       DW #DF01
KEY_UP          DW #FB01
KEY_DOWN        DW #FD01
KEY_FIRE        DW #7F01
KEY_CANCEL      DW #FB04


;---------------- макросы ----------------

;включить страницу памяти
MACRO           RAMPAGE
                IF0 \0
                  XOR A
                ELSE 
                  LD A,\0
                ENDIF 
                CALL RAM_SEL
ENDM 

;на одну строчку вниз
MACRO           DOWN
                INC \C
                LD A,\C
                AND 7
                JP NZ,$+18
                LD A,\C
                SUB 8
                LD \C,A
                LD A,\N\C
                ADD A,32
                LD \C,A
                JP NC,$+7
                LD A,\R\C
                ADD A,8
                LD \C,A
                ENDM 

;на одну строчку вверх
MACRO           UP
                DEC \C
                LD A,\C
                AND 7
                CP 7
                JP NZ,$+18
                LD A,\C
                ADD A,8
                LD \C,A
                LD A,\N\C
                SUB 32
                LD \C,A
                JP NC,$+7
                LD A,\R\C
                SUB 8
                LD \C,A
                ENDM 

;расчет адреса на экране в символах
MACRO           SCRADR
                LD A,\N\C
                RRCA 
                RRCA 
                RRCA 
                AND #E0
                OR \R\C
                LD \C,A
                LD A,\N\C
                AND #18
                LD \C,A
                LD A,(ACTIVE_SCREEN)
                ADD A,\C
                LD \C,\R\C
                LD \C,A
                ENDM 

;расчет адреса в аттрибутах в символах
MACRO           ATTRADR
                LD A,\N\C
                RRCA 
                RRCA 
                RRCA 
                AND #E0
                OR \R\C
                LD \C,A
                LD A,\N\C
                RRCA 
                RRCA 
                RRCA 
                AND #03
                LD \C,A
                LD A,(ACTIVE_SCREEN)
                ADD A,#18
                ADD A,\C
                LD \C,\R\C
                LD \C,A
                ENDM 

;расчет э.адр. коорд Y в пикселях,портит C
MACRO           SCRADRPIX
                LD A,\N\C
                RLCA 
                RLCA 
                AND #E0
                OR \R\C
                LD \C,\N\C
                LD \C,A
                LD A,\R\C
                AND 7
                LD C,A
                LD A,\C
                RRCA 
                RRCA 
                RRCA 
                AND #18
                OR C
                LD \C,A
                LD A,(ACTIVE_SCREEN)
                ADD A,\C
                LD \C,A
                ENDM 

;вычисляем адрес на карте по координатам
;пример использования - GETMAPADR HLC,
;где HL - координаты, C - регистр портится
MACRO           GETMAPADR
                LD A,\N\C
                RRCA 
                LD \N\C,A
                AND #80
                ADD A,\R\C
                LD \N\C,A
                LD A,\N\C
                AND #3F
                ADD A,'MAP
                LD \R\C,A
                ENDM 

;-----------------------------------------

;вывод спрайта на экран
;вх  - H - коорд X (0..255)
;      L - коорд Y (0..191)
;      C - тип объекта
;      A - D0-D5 номер спрайта
;          D6 -  половина экрана (л/п)

PUT_SPRITE      EXA 
                PUSH AF,BC,DE,HL
                EXA 
                PUSH AF,BC,DE,HL

                LD (PUT_SPRHL+1),HL
                LD (PUT_SPRA+1),A
                LD D,A

                LD A,H
                AND 7
                ADD A,A
                LD HL,PUT_SPRSADR
                ADDA HL
                LD A,(HL)
                INC HL
                LD H,(HL),L,A
                LD (PUT_SPRSEL+1),HL

;ищем страничку с нужным спрайтсетом
                LD HL,SPRITE_TYPE
                LD B,MAX_SPRSETS-1
PUT_SPR1        LD A,(HL)
                CP C
                JP Z,PUT_SPR2
                INC HL,HL
                DJNZ PUT_SPR1
PUT_SPR2        INC HL
                LD A,(HL)
                CALL RAM_SEL

;находим адрес спрайта, копируем в стек
                LD (PUT_SPRE+1),SP
                LD A,D
                AND #3F
                ADD A,'SPRITES
                LD H,A,L,#FF

                DUP 128
                LD D,(HL)
                DEC L
                LD E,(HL)
                DEC L
                PUSH DE
                EDUP 

;обработка выхода за пределы экрана
                XOR A
                LD H,A,L,A
                LD (PUT_SPRCL0),HL
                LD (PUT_SPRCL1),HL
                LD (PUT_SPRCL2),HL
                LD (PUT_SPRCL3),HL
                LD (PUT_SPRCL4),A

PUT_SPRHL       LD DE,0
                SRL D,D,D
                LD B,5
PUT_SPRA        LD A,0
                AND 64
                JP NZ,PUT_SPR10

;по горизонтали (левая половина экрана)
                LD A,D
                IF0 EDITOR
                  CP 28
                  JR C,PUT_SPR5
                ELSE 
                  CP 20
                  JR C,PUT_SPR5
                  CP 28
                  JP C,PUT_SPRE
                ENDIF 
                ADD A,5
                AND 7
                LD B,A
                LD D,0
PUT_SPR5        LD A,B,C,B
                DEC A
                LD (PUT_SPRCLN+1),A
                LD HL,#2C77
                LD A,L
                LD (PUT_SPRCL4),A
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL3),HL
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL2),HL
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL1),HL
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL0),HL
                JP PUT_SPR15

;по горизонтали (правая половина экрана)
PUT_SPR10       LD A,D
                IF0 EDITOR
                  CP 28
                  JR C,PUT_SPR11
                ELSE 
                  CP 24
                  JP NC,PUT_SPRE
                  CP 20
                  JR C,PUT_SPR11
                ENDIF 
                LD A,32
                SUB D
                AND 7
                LD B,A
                JP PUT_SPR12
PUT_SPR11       LD A,B
                DEC A
PUT_SPR12       LD C,B
                LD (PUT_SPRCLN+1),A
                LD HL,#2C77
                LD A,L
                LD (PUT_SPRCL0),HL
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL1),HL
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL2),HL
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL3),HL
                DEC B
                JR Z,PUT_SPR15
                LD (PUT_SPRCL4),A

;по вертикали
PUT_SPR15       LD B,32
                LD A,E
                CP 160
                JR C,PUT_SPR25
                CP 192
                JR NC,PUT_SPR20
                LD A,192
                SUB E
                LD B,A
                JR PUT_SPR25
PUT_SPR20       CP 225
                JP C,PUT_SPRE
                ADD A,32
                LD B,A
                LD E,0
                LD A,32
                SUB B
                ADD A,A
                ADD A,A
                ADD A,A
                LD L,A,H,0
                ADD HL,SP
                LD SP,HL

;отмечаем область перерисовки карты
PUT_SPR25       PUSH BC,DE,HL

                LD A,(PUT_SPRHL+2)
                AND 15
                JR NZ,PUT_SPR26
                LD A,C
                CP 5
                JR NZ,PUT_SPR26
                DEC C

;маска для перерисовки
PUT_SPR26       LD A,C
                DEC A
                AND 6
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,A
                LD C,A
                LD A,D
                AND #1E
                ADD A,C
                LD HL,TAB_REDRAW
                ADDA HL
                LD A,(HL)
                INC HL
                LD H,(HL)
                LD L,A

;кол-во перерисовываемых линий
                LD A,16
                CP B
                LD A,0
                RLA 
                LD B,A
                LD A,E
                AND 15
                JR Z,$+3
                INC B
                INC B

;накладываем маску на MAP_REDRAW
                LD A,E
                RRCA 
                RRCA 
                RRCA 
                AND #1E
                LD E,A
                LD A,(ACTIVE_SCREEN)
                RRCA 
                RRCA 
                AND 32
                ADD A,E
                LD DE,MAP_REDRAW
                ADDA DE
                EX DE,HL
PUT_SPR27       LD A,(HL)
                OR D
                LD (HL),A
                INC L
                LD A,(HL)
                OR E
                LD (HL),A
                INC L
                DJNZ PUT_SPR27

                POP HL,DE,BC

;вывод спрайта
                EX DE,HL
                SCRADRPIX HL
                RAMPAGE 7
                LD A,B

PUT_SPRLP       EXA 
PUT_SPRSEL      JP PUT_SPRSM0

;смещение 0
PUT_SPRSM0      POP BC,DE
                EXX 
                POP BC,DE
                LD HL,#00FF
                EXX 
                JP PUT_SPROUT
;смещение 1
PUT_SPRSM1      POP BC,DE
                EXX 
                POP BC,DE
                LD HL,#00FF
                EXX 
                SCF 
                RR C,E
                EXX 
                RR C,E,L
                EXX 
                OR A
                RR B,D
                EXX 
                RR B,D,H
                EXX 
                JP PUT_SPROUT
;смещение 2
PUT_SPRSM2      POP BC,DE
                EXX 
                POP BC,DE
                LD HL,#00FF
                EXX 
                SCF 
                DUP 2
                RR C,E
                EXX 
                RR C,E,L
                EXX 
                EDUP 
                OR A
                DUP 2
                RR B,D
                EXX 
                RR B,D,H
                EXX 
                EDUP 
                JP PUT_SPROUT
;смещение 3
PUT_SPRSM3      POP BC,DE
                EXX 
                POP BC,DE
                LD HL,#00FF
                EXX 
                SCF 
                DUP 3
                RR C,E
                EXX 
                RR C,E,L
                EXX 
                EDUP 
                OR A
                DUP 3
                RR B,D
                EXX 
                RR B,D,H
                EXX 
                EDUP 
                JP PUT_SPROUT
;смещение 4
PUT_SPRSM4      POP BC,DE
                EXX 
                POP BC,DE
                LD HL,#00FF
                EXX 
                SCF 
                DUP 4
                RR C,E
                EXX 
                RR C,E,L
                EXX 
                EDUP 
                OR A
                DUP 4
                RR B,D
                EXX 
                RR B,D,H
                EXX 
                EDUP 
                JP PUT_SPROUT
;смещение 5
PUT_SPRSM5      LD BC,#00FF
                POP DE
                EXX 
                POP BC,DE,HL
                SCF 
                DUP 3
                RL L,E,C
                EXX 
                RL E,C
                EXX 
                EDUP 
                OR A
                DUP 3
                RL H,D,B
                EXX 
                RL D,B
                EXX 
                EDUP 
                EXX 
                JP PUT_SPROUT
;смещение 6
PUT_SPRSM6      LD BC,#00FF
                POP DE
                EXX 
                POP BC,DE,HL
                SCF 
                DUP 2
                RL L,E,C
                EXX 
                RL E,C
                EXX 
                EDUP 
                OR A
                DUP 2
                RL H,D,B
                EXX 
                RL D,B
                EXX 
                EDUP 
                EXX 
                JP PUT_SPROUT
;смещение 7
PUT_SPRSM7      LD BC,#00FF
                POP DE
                EXX 
                POP BC,DE,HL
                SCF 
                RL L,E,C
                EXX 
                RL E,C
                EXX 
                OR A
                RL H,D,B
                EXX 
                RL D,B
;вывод линии
PUT_SPROUT      LD A,(HL)
                AND C
                OR B
PUT_SPRCL0      LD (HL),A
                INC L
                LD A,(HL)
                AND E
                OR D
PUT_SPRCL1      LD (HL),A
                INC L
                LD A,(HL)
                EXX 
                AND C
                OR B
                EXX 
PUT_SPRCL2      LD (HL),A
                INC L
                LD A,(HL)
                EXX 
                AND E
                OR D
                EXX 
PUT_SPRCL3      LD (HL),A
                INC L
                LD A,(HL)
                EXX 
                AND L
                OR H
                EXX 
PUT_SPRCL4      LD (HL),A
                LD A,L
PUT_SPRCLN      SUB 4
                LD L,A
                DOWN HL
                EXA 
                DNZ A,PUT_SPRLP

PUT_SPRE        LD SP,0
                POP HL,DE,BC,AF
                EXA 
                POP HL,DE,BC,AF
                EXA 
                RET 

PUT_SPRSADR     DW PUT_SPRSM0,PUT_SPRSM1
                DW PUT_SPRSM2,PUT_SPRSM3
                DW PUT_SPRSM4,PUT_SPRSM5
                DW PUT_SPRSM6,PUT_SPRSM7


;полная перерисовка карты
;вх  - нет
;вых - нет

REDRAW_ALL      PUSH BC,DE,HL
                LD HL,MAP_REDRAW
                LD DE,MAP_REDRAW+1
                LD BC,63
                LD (HL),255
                LDIR 
                POP HL,DE,BC
                RET 


;вывод карты на экран
;вх  - HL - позиция на карте

MAP_DRAW        PUSH AF,BC,DE,HL

;копируем фрагмент карты в буфер
                RAMPAGE 0
                GETMAPADR HLC
                LD DE,MAP_BUFFER
                LD A,12

                IF0 EDITOR
MAP_DRW1          DUP 16
                  LDI 
                  EDUP 
                  LD BC,128-16
                  ADD HL,BC
                  DNZ A,MAP_DRW1
                ELSE 
MAP_DRW1          DUP 12
                  LDI 
                  EDUP 
                  LD BC,128-12
                  ADD HL,BC
                  DNZ A,MAP_DRW1
                ENDIF 

                RAMPAGE 7
                LD A,(ACTIVE_SCREEN)
                LD H,A
                LD L,0
                LD (MAP_DRW8+1),HL
                ADD A,#18
                LD H,A
                LD (MAP_DRW9+1),HL

;режим вывода карты

                IFN EDITOR
                  LD HL,MAP_DRW5
                  LD A,(MAP_DRAWMODE)
                  OR A
                  JR Z,$+5
                  LD HL,MAP_DRW4
                  LD (MAP_DRW3+1),HL
                ENDIF 

                EXX 
                LD DE,MAP_BUFFER
                LD A,(ACTIVE_SCREEN)
                RRCA 
                RRCA 
                AND 32
                LD HL,MAP_REDRAW
                ADDA HL
                LD B,(HL)
                INC L
                LD C,(HL)
                INC L
                EXX 

                IF0 EDITOR
                  LD B,1
                  LD C,14
                  CALL MAP_DRW3
                  EXX 
                  INC E,E
                  EXX 
                  LD A,64
                  LD (MAP_DRW8+1),A
                  LD (MAP_DRW9+1),A
                  LD B,11
                  LD C,16
                  CALL MAP_DRW2

                  LD A,(FRAME_CURRENT)
                  LD B,A
                  LD A,(MAP_DRAWTM)
                  ADD A,B
                  LD (MAP_DRAWTM),A
                ELSE 
                  LD B,12
                  CALL MAP_DRW2

                  LD A,(MAP_DRAWTM)
                  INC A
                  LD (MAP_DRAWTM),A
                ENDIF 

                LD A,(ACTIVE_SCREEN)
                RRCA 
                RRCA 
                AND 32
                LD HL,MAP_REDRAW
                ADDA HL
                LD D,H,E,L
                INC DE
                LD BC,31
                LD (HL),0
                LDIR 

                POP HL,DE,BC,AF
                RET 

;подпрограмма вывода массива тайлов

;расчет адреса спец-тайлов
                IF0 EDITOR
MAP_DRW2          LD C,16

;проверка на пустую строку
                  EXX 
                  LD A,B
                  OR C
                  EXX 
                  JP NZ,MAP_DRW3

                  EXX 
                  PUSH BC,DE,HL
                  EX DE,HL
                  LD BC,#030E
                  LD D,'TILE_TYPE
                  DUP 16
                  LD E,(HL)
                  INC L
                  LD A,(DE)
                  CP B
                  JP Z,MAP_DRW21
                  CP C
                  JP Z,MAP_DRW21
                  EDUP 
MAP_DRW21         POP HL,DE,BC
                  EXX 
                  JP Z,MAP_DRW3

                  EXX 
                  LD A,E
                  ADD A,16
                  LD E,A
                  EXX 
                  LD HL,MAP_DRW9+1
                  LD A,(HL)
                  ADD A,64
                  LD (HL),A
                  INC HL
                  LD A,(HL)
                  ADC A,0
                  LD (HL),A
                  LD HL,MAP_DRW8+1
                  LD A,(HL)
                  ADD A,64
                  LD (HL),A
                  JP NC,MAP_DRW13
                  INC HL
                  LD A,(HL)
                  ADD A,8
                  LD (HL),A
                  JP MAP_DRW13
MAP_DRW3
                ELSE 
MAP_DRW2          LD C,12
MAP_DRW3          JP 0
MAP_DRW4          EXX 
                  LD A,(DE)
                  INC E
                  EXX 
                  LD E,A
                  LD D,'TILE_TYPE
                  LD A,(DE)
                  RLCA 
                  RLCA 
                  LD E,A
                  RLCA 
                  RLCA 
                  RLCA 
                  LD L,A
                  AND #1F
                  ADD A,'TRACE_TAB
                  LD H,A
                  LD A,L
                  AND #E0
                  LD L,A
                  LD A,E
                  AND #03
                  LD D,A
                  LD A,E
                  AND #FC
                  LD E,A
                  ADD HL,DE
                  JP MAP_DRW7
                ENDIF 

;расчет адреса тайла
MAP_DRW5        EXX 
                LD A,(DE)
                INC E
                EXX 
                LD H,'TILE_TYPE
                LD L,A
                LD A,(HL)
                CP 3
                JR Z,MAP_DRW51
                CP 14
                JP NZ,MAP_DRW52

;анимированные тайлы
MAP_DRW51       LD A,(MAP_DRAWTM)
                RRCA 
                RRCA 
                RRCA 
                AND 3
                ADD A,L
                LD L,A
                EXX 
                RL C,B
                EXX 
                JP MAP_DRW6

MAP_DRW52       EXX 
                RL C,B
                EXX 
                JP NC,MAP_DRW11
MAP_DRW6        LD A,L
                RLCA 
                RLCA 
                LD E,A
                RLCA 
                RLCA 
                RLCA 
                LD L,A
                AND #1F
                ADD A,'TILE_SPRITE+1
                LD H,A
                LD A,L
                AND #E0
                LD L,A
                LD A,E
                AND #03
                LD D,A
                LD A,E
                AND #FC
                LD E,A
                ADD HL,DE

MAP_DRW7        DEC HL
                LD D,(HL)
                DEC HL
                LD E,(HL)
                INC HL,HL
                LD (MAP_DRW10+1),SP
                LD SP,HL

;вывод тайла
MAP_DRW8        LD HL,0
                DUP 4
                POP DE
                LD (HL),E
                INC L
                LD (HL),D
                INC H
                POP DE
                LD (HL),D
                DEC L
                LD (HL),E
                INC H
                EDUP 
                LD A,H
                SUB 8
                LD H,A
                LD A,L
                ADD A,32
                LD L,A
                DUP 4
                POP DE
                LD (HL),E
                INC L
                LD (HL),D
                INC H
                POP DE
                LD (HL),D
                DEC L
                LD (HL),E
                INC H
                EDUP 

;аттрибуты тайла
MAP_DRW9        LD HL,0
                POP DE
                LD (HL),E
                INC L
                LD (HL),D
                LD A,L
                ADD A,32
                LD L,A
                POP DE
                LD (HL),D
                DEC L
                LD (HL),E

MAP_DRW10       LD SP,0
MAP_DRW11       LD HL,MAP_DRW9+1
                INC (HL),(HL)
                LD HL,MAP_DRW8+1
                INC (HL),(HL)
                DNZ C,MAP_DRW3
                LD A,(HL)

                IF0 EDITOR
                  ADD A,64-32
                ELSE 
                  ADD A,64-24
                ENDIF 

                LD (HL),A
                JP NC,MAP_DRW12
                INC HL
                LD A,(HL)
                ADD A,8
                LD (HL),A
MAP_DRW12       LD HL,(MAP_DRW9+1)

                IF0 EDITOR
                  LD DE,64-32
                ELSE 
                  LD DE,64-24
                ENDIF 

                ADD HL,DE
                LD (MAP_DRW9+1),HL

MAP_DRW13       EXX 
                LD B,(HL)
                INC L
                LD C,(HL)
                INC L
                EXX 

                DNZ B,MAP_DRW2
                RET 
MAP_DRAWTM      DB 0
MAP_DRAWMODE    DB 0


;деление H/L=B (C - остаток)
DIV_BYTE        PUSH AF,DE,HL
                LD BC,#0800
                LD D,0
DIV_BYTE_1      RL H
                LD A,C
                RLA 
                SUB L
                JR NC,DIV_BYTE_2
                ADD A,L
DIV_BYTE_2      LD C,A
                CCF 
                RL D
                DJNZ DIV_BYTE_1
                LD B,D
                POP HL,DE,AF
                RET 

;деление HL/C=HL
DIV_WORD        PUSH AF
                XOR A
                DUP 16
                ADD HL,HL
                RLA 
                CP C
                JR C,$+4
                SUB C
                INC L
                EDUP 
                POP AF
                RET 

;случайное число в A
RND             PUSH BC
                LD A,R
RND_1           LD B,0
                ADD A,B
                LD B,A
                ADD A,A
                ADD A,A
                ADD A,B
                ADD A,7
                LD (RND_1+1),A
                POP BC
                RET 

;печать символа 6х8 (через XOR)
;вх  - HL - адрес на экране
;      C - смещение (0,2,4,6)
;      A - код символа
;вых - нет

PRINT_SYM       PUSH AF,BC,DE,HL

                LD (PRINT_SYMC+1),HL
                LD H,'WIN_FNT+7
                LD L,A
                RAMPAGE 6
                DUP 3
                LD D,(HL)
                DEC H
                LD E,(HL)
                DEC H
                PUSH DE
                EDUP 
                LD D,(HL)
                DEC H
                LD E,(HL)
                PUSH DE
PRINT_SYMC      LD HL,0
                RAMPAGE 7
                INC C,L
                LD B,C

                DUP 4
                POP DE
;смещение E
                XOR A
                DEC C
                JR Z,$+8
                RR E
                RRA 
                JP $-6
;вывод E
                XOR (HL)
                LD (HL),A
                DEC L
                LD A,(HL)
                XOR E
                LD (HL),A
                INC H,L
;смещение D
                LD C,B
                XOR A
                DEC C
                JR Z,$+8
                RR D
                RRA 
                JP $-6
;вывод D
                XOR (HL)
                LD (HL),A
                DEC L
                LD A,(HL)
                XOR D
                LD (HL),A
                INC H,L
                LD C,B
                EDUP 

PRINT_SYME      POP HL,DE,BC,AF
                RET 

;печать строки
;вх  - HL - адрес на экране
;      DE - адрес строки (#00 - конец)
;вых - DE - адрес следующей строки

PRINT_STR       PUSH AF,BC,HL

                LD C,0
PRINT_STR1      LD A,(DE)
                INC DE
                OR A
                JP Z,PRINT_STRE
                CALL PRINT_SYM
                LD A,C
                SUB 2
                AND 7
                LD C,A
                CP 6
                JP Z,PRINT_STR1
                INC L
                JP PRINT_STR1

PRINT_STRE      POP HL,BC,AF
                RET 

;печать текста
;вх  - HL - адрес текста (#FF - конец)
;вых - нет

PRINT_TEXT      PUSH AF,BC,DE,HL
                EX DE,HL
PRINT_TEXT1     EX DE,HL
                LD D,(HL)
                INC HL
                LD E,(HL)
                INC HL
                EX DE,HL
                SCRADR HL
                CALL PRINT_STR
                LD A,(DE)
                CP #FF
                JR NZ,PRINT_TEXT1
                POP HL,DE,BC,AF
                RET 

;печать шестнадцатиричного числа
;HL - координаты в символах
;A - число

PRINT_HEX       PUSH AF,DE,HL
                LD D,A
                DUP 4
                RRCA 
                EDUP 
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (PRINT_HEXB),A
                LD A,D
                AND #0F
                ADD A,#30
                CP #3A
                JR C,$+4
                ADD A,7
                LD (PRINT_HEXB+1),A
                SCRADR HL
                LD DE,PRINT_HEXB
                CALL PRINT_STR
                POP HL,DE,AF
                RET 
PRINT_HEXB      DB 0,0,0


;вывод рамки на экран
;вх  - HL - координаты на экране
;      BC - размеры рамки
;      A - #FF - непрерывная
;          #00 - пунктирная
;вых - нет

DRW_FRAME       PUSH AF,BC,DE,HL

;настрайка рамки
                LD D,A
                LD A,#CC
                OR D
                LD (DRW_FRAME2+1),A
                LD A,D
                AND #80
                LD (DRW_FRAME5+1),A
                LD A,#33
                OR D
                LD (DRW_FRAME9+1),A
                LD A,D
                AND #01
                LD (DRW_FRAME12+1),A

                SCRADR HL

                LD A,C
                ADD A,A
                ADD A,A
                ADD A,A
                SUB 2
                LD C,A

;верхняя сторона
                PUSH BC,HL
DRW_FRAME1      LD A,(HL)
DRW_FRAME2      XOR #FF;#CC
                LD (HL),A
                INC L
                DJNZ DRW_FRAME1
                POP HL,BC

;левая сторона
                PUSH HL,BC
                INC H
                PUSH BC
                LD B,C
DRW_FRAME3      LD A,B
                RRCA 
                RRCA 
                AND #80
DRW_FRAME5      OR #80
                XOR (HL)
                LD (HL),A
                DOWN HL
                DJNZ DRW_FRAME3
                POP BC
                DOWN HL
                POP BC

;нижняя сторона
                DEC H
                LD A,L
                SUB 32
                LD L,A
                JP C,DRW_FRAME7
                LD A,H
                ADD A,8
                LD H,A
DRW_FRAME7      PUSH BC
DRW_FRAME8      LD A,(HL)
DRW_FRAME9      XOR #FF;#33
                LD (HL),A
                INC L
                DJNZ DRW_FRAME8
                POP BC,HL

;правая сторона
                LD A,L
                ADD A,B
                DEC A
                LD L,A
                INC H
                LD B,C
DRW_FRAME11     LD A,B
                RRCA 
                AND #01
DRW_FRAME12     OR #01
                XOR (HL)
                LD (HL),A
                DOWN HL
                DJNZ DRW_FRAME11

                POP HL,DE,BC,AF
                RET 

;драйвер памяти
;A - номер станицы памяти
RAM_SEL         PUSH AF,BC
                AND 7
                LD B,A
                LD A,(RAM_SAVE)
                AND #F8
                OR B
                LD (RAM_SAVE),A
                LD BC,#7FFD
                OUT (C),A
                POP BC,AF
                RET 
RAM_SAVE        DB #10

;сделать видимым активный экран и обменять
CHANGE_SCREEN   PUSH AF,BC
                LD A,(ACTIVE_SCREEN)
                XOR #80
                LD (ACTIVE_SCREEN),A
                XOR #80
                RRCA 
                RRCA 
                RRCA 
                RRCA 
                AND #08
                LD B,A
                LD A,(RAM_SAVE)
                AND #F7
                OR B
                LD (RAM_SAVE),A
                LD BC,#7FFD
                OUT (C),A
                POP BC,AF
                RET 



