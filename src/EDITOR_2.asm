;+++++++++++++++ EDITOR_2.H ++++++++++++++

                MAIN "GAME.H",#C0

;показать местоположение скриптов на карте
SHOW_SCRIPT     XOR A
                LD (SHOW_SCRIPTCNT),A
                LD DE,(MAP_XY)
                LD HL,MAP_PROPERTY+8
                LD B,15

SHOW_S1         PUSH BC,DE,HL
                XOR A
                CALL RAM_SEL
                LD B,(HL)
                INC L
                LD C,(HL)
                LD A,B
                OR C
                JR Z,SHOW_S2
                LD A,D
                ADD A,11
                CP B
                JR C,SHOW_S2
                LD A,E
                ADD A,11
                CP C
                JR C,SHOW_S2
                INC L
                LD B,(HL)
                INC L
                LD C,(HL)
                LD A,B
                CP D
                JR C,SHOW_S2
                LD A,C
                CP E
                JR C,SHOW_S2

;вывод отметки портала
                POP HL
                PUSH HL
                LD A,(HL)
                SUB D
                JR NC,$+3
                XOR A
                ADD A,A
                LD B,A
                INC L
                LD A,(HL)
                SUB E
                JR NC,$+3
                XOR A
                ADD A,A
                LD C,A
                INC L
                LD A,(HL)
                SUB D
                CP 12
                JR C,$+4
                LD A,11
                INC A
                ADD A,A
                SUB B
                LD D,A
                INC L
                LD A,(HL)
                SUB E
                CP 12
                JR C,$+4
                LD A,11
                INC A
                ADD A,A
                SUB C
                LD H,B,L,C
                LD B,D,C,A
                RAMPAGE 7
                LD A,(SHOW_SCRIPTCNT)
                LD D,A
                LD A,(CURRENT_SCRIPT)
                CP D
                LD A,#1F
                JR Z,$+4
                ADD A,16
                CALL FILL_ATTR

SHOW_S2         LD HL,SHOW_SCRIPTCNT
                INC (HL)
                POP HL,DE,BC
                LD A,L
                ADD A,8
                LD L,A
                DJNZ SHOW_S1
                RET 
SHOW_SCRIPTCNT  DB 0
CURRENT_SCRIPT  DB 0


;показать местоположение модов на карте
SHOW_MOD        LD HL,128*124+MAP
                LD DE,(MAP_XY)

SHOW_M1         PUSH DE,HL
                XOR A
                CALL RAM_SEL
                LD A,(HL)
                OR A
                JR Z,SHOW_ME
                INC HL
                LD B,(HL)
                INC HL
                LD C,(HL)
                INC HL
                LD A,D
                ADD A,11
                CP B
                JR C,SHOW_M2
                LD A,E
                ADD A,11
                CP C
                JR C,SHOW_M2
                LD A,(HL)
                DEC A
                ADD A,B
                CP D
                JR C,SHOW_M2
                INC HL
                LD A,(HL)
                DEC A
                ADD A,C
                CP E
                JR C,SHOW_M2

;вывод отметки мода
                POP HL
                PUSH HL
                INC HL
                LD B,(HL)
                INC HL
                LD C,(HL)
                INC HL
                LD A,(HL)
                ADD A,B
                INC HL
                LD L,(HL)
                LD H,A
                LD A,L
                ADD A,C
                LD L,A

                LD A,B
                SUB D
                JR NC,$+3
                XOR A
                LD B,A
                LD A,C
                SUB E
                JR NC,$+3
                XOR A
                LD C,A
                LD A,H
                SUB D
                CP 13
                JR C,$+4
                LD A,12
                SUB B
                ADD A,A
                LD D,A
                LD A,L
                SUB E
                CP 13
                JR C,$+4
                LD A,12
                SUB C
                ADD A,A
                LD H,B,L,C
                LD B,D,C,A
                SLA H,L
                LD A,7
                CALL RAM_SEL
                LD A,#78
                CALL FILL_ATTR

SHOW_M2         POP HL,DE
                XOR A
                CALL RAM_SEL
                LD A,(HL)
                ADD A,L
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                JP SHOW_M1

SHOW_ME         POP HL,DE
                RET 


;показать местоположение объектов на карте
SHOW_MAPOBJ     LD HL,MAP_OBJECTS
                LD DE,(MAP_XY)
                LD A,D
                SUB 1
                ADC A,0
                LD D,A
                LD B,0

SHOW_MO10       PUSH BC,DE,HL
                LD A,(HL)
                OR A
                JR Z,SHOW_MO20
                CP E
                JR C,SHOW_MO20
                LD A,E
                ADD A,12
                CP (HL)
                JR C,SHOW_MO20
                INC H
                LD A,(HL)
                CP D
                JR C,SHOW_MO20
                LD A,D
                ADD A,12
                CP (HL)
                JR C,SHOW_MO20

;вывод объекта на экран
                INC H
                LD A,(HL)
                ADD A,#81
                LD E,A
                LD D,MAP_PROPERTY/256
                XOR A
                CALL RAM_SEL
                LD A,(DE),C,A
                DEC H
                LD A,(HL)
                DEC H
                LD L,(HL),H,A
                LD DE,(MAP_XY)
                OR A
                SBC HL,DE
                LD B,H
                DEC L
                SLA H,H,H,H,L,L,L,L
                LD A,7
                CALL RAM_SEL
                LD A,B
                INC A,A
                RLCA 
                RLCA 
                RLCA 
                AND #40
                CALL PUT_SPRITE

SHOW_MO20       POP HL,DE,BC
                INC L
                DJNZ SHOW_MO10
                RET 


;захват координат с карты
;вх  - A=#FF - режим порталов
;вых - HL - коорд. 1
;      BC - коорд. 2
;      NZ - отмена, Z - есть координаты

CAPTURE_CORD    PUSH DE

                LD (CAPTURE_CORDPR),A
                LD (CAPTURE_CORDEX),HL

                LD A,7
                CALL RAM_SEL

                LD HL,CURSOR_BUF
                XOR A
                LD (HL),A
                INC HL
                LD (HL),A

                XOR A
                LD (CURSOR_TYPE),A
                LD L,A,E,A
                LD A,(ACTIVE_SCREEN)
                LD H,A
                XOR #80
                LD D,A
                LD BC,#1B00
                LDIR 

                XOR A
                LD (CAPTURE_CORDSL),A
                LD HL,#0101
                LD A,(CAPTURE_CORDPR)
                OR A
                JR Z,$+4
                INC H,L
                LD (CAPTURE_CORDSZ),HL

CAPTURE_C1      LD A,(CAPTURE_CORDSL)
                OR A
                CALL Z,MAP_SCROLL
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
CAPTURE_TYPE    CALL SHOW_SCRIPT
                LD A,7
                CALL RAM_SEL
                LD A,(CAPTURE_CORDPR)
                OR A
                JR Z,CAPTURE_C3

;вывод метки выхода из портала
                LD HL,(CAPTURE_CORDEX)
                LD DE,(MAP_XY)
                LD BC,#0202
CAPTURE_C2      LD A,H
                CP D
                JR C,CAPTURE_C2E
                LD A,D
                ADD A,11
                CP H
                JR C,CAPTURE_C2E
                LD A,L
                CP E
                JR C,CAPTURE_C2E
                LD A,E
                ADD A,11
                CP L
                JR C,CAPTURE_C2E
                PUSH BC,HL
                OR A
                SBC HL,DE
                SLA H,L
                LD A,#17
                LD BC,#0202
                CALL FILL_ATTR
                POP HL,BC
CAPTURE_C2E     INC H
                DJNZ CAPTURE_C2
                LD B,2
                DEC H,H
                INC L
                DEC C
                JR NZ,CAPTURE_C2

CAPTURE_C3      LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD BC,(CAPTURE_CORDSZ)

;проверка на вхождение в карту
                LD A,H
                CP 12
                JP NC,CAPTURE_C9

                LD A,(CAPTURE_CORDSL)
                OR A
                JR NZ,CAPTURE_C4

                LD A,H
                ADD A,B
                CP 13
                JR C,$+6
                LD A,12
                SUB B
                LD H,A
                LD A,L
                ADD A,C
                CP 13
                JR C,$+6
                LD A,12
                SUB C
                LD L,A
;вывод рамки
                PUSH BC,HL
                SLA B,C,H,L
                XOR A
                CALL DRW_FRAME
                POP HL,BC

CAPTURE_C4      LD A,(INPUT_BUTTON)
                AND 1
                JR Z,CAPTURE_C8

;инициализация выбора
                LD A,(CAPTURE_CORDSL)
                OR A
                JP NZ,CAPTURE_C5
                LD (CAPTURE_CORDXY),HL
                LD HL,#0101
                LD (CAPTURE_CORDSZ),HL
                LD A,#FF
                LD (CAPTURE_CORDSL),A
                JP CAPTURE_C8

;выбор фрагмента карты
CAPTURE_C5      LD DE,(CAPTURE_CORDXY)
                LD A,H
                CP D
                JR NC,CAPTURE_C6
                LD H,D
                LD D,A
CAPTURE_C6      LD A,L
                CP E
                JR NC,CAPTURE_C7
                LD L,E
                LD E,A
CAPTURE_C7      LD A,H
                SUB D
                INC A
                LD B,A
                LD A,L
                SUB E
                INC A
                LD C,A

                LD A,(CAPTURE_CORDPR)
                OR A
                JR Z,$+5
                LD BC,#0202

                LD (CAPTURE_CORDSZ),BC
                EX DE,HL
                LD (CAPTURE_CORDXYF),HL
                LD (CAPTURE_CORDSZF),BC
                SLA H,L,B,C
                XOR A
                CALL DRW_FRAME

CAPTURE_C8      LD A,(INPUT_BUTTON)
                AND 1
                JR NZ,CAPTURE_C9
                LD A,(CAPTURE_CORDSL)
                OR A
                JR Z,CAPTURE_C9
                LD HL,(CAPTURE_CORDXYF)
                LD DE,(MAP_XY)
                ADD HL,DE
                EX DE,HL
                LD HL,(CAPTURE_CORDSZF)
                ADD HL,DE
                EX DE,HL
                LD B,D,C,E
                DEC B,C
                XOR A
                JR CAPTURE_CE

CAPTURE_C9      LD A,(INPUT_BUTTON)
                AND 2
                JR NZ,CAPTURE_CE

                CALL SHOW_SCREEN
                JP CAPTURE_C1

CAPTURE_CE      POP DE
                PUSH AF
                CALL REDRAW_ALL
                POP AF
                RET 

CAPTURE_CORDPR  DB 0
CAPTURE_CORDSL  DB 0
CAPTURE_CORDXY  DW 0
CAPTURE_CORDSZ  DW #0101
CAPTURE_CORDXYF DW 0
CAPTURE_CORDSZF DW 0
CAPTURE_CORDEX  DW 0


;редактор скриптов
SCRIPT_EDIT

;рисуем карту и проверяем на скролл
                CALL MAP_SCROLL
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
                CALL SHOW_SCRIPT
                LD A,7
                CALL RAM_SEL

;рисуем панель инструментов
                LD HL,#1800
                LD BC,#0818
                LD A,7
                CALL CLEAR_RECT
                LD HL,SCRIPT_EDITLB
                CALL PRINT_TEXT
                CALL SHOW_CORD
;выбор скрипта
                LD HL,#1801
                LD DE,#1707
                LD B,14
                LD A,(CURRENT_SCRIPT)
                CALL SPINEDIT
                LD (CURRENT_SCRIPT),A

;координаты скрипта
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,128+8
                LD L,A
                LD H,'MAP_PROPERTY
                XOR A
                CALL RAM_SEL
                LD B,(HL)
                INC L
                LD C,(HL)
                INC L
                LD D,(HL)
                INC L
                LD E,(HL)
                INC L
                LD (SCRIPT_EDITHL),HL
                LD A,7
                CALL RAM_SEL
                LD HL,#1C06
                LD A,B
                CALL PRINT_HEX
                INC H,H
                LD A,C
                CALL PRINT_HEX
                LD HL,#1C07
                LD A,D
                CALL PRINT_HEX
                INC H,H
                LD A,E
                CALL PRINT_HEX
;быстрый переход
                PUSH BC,DE
                LD HL,#1808
                LD DE,#1707
                LD B,8
                CALL BUTTON
                POP HL,DE
                JR Z,SCRIPT_E1
                OR A
                SBC HL,DE
                SRL H,L
                ADD HL,DE
                CALL CENTER_MAP
                LD (MAP_XY),HL

;выбор типа скрипта
SCRIPT_E1       LD HL,(SCRIPT_EDITHL)
                XOR A
                CALL RAM_SEL
                LD C,(HL)
                LD A,7
                CALL RAM_SEL
                LD HL,#1803
                LD DE,#1707
                LD B,255
                LD A,C
                CALL SPINEDIT
                JR Z,SCRIPT_E3
                LD C,A
                XOR A
                CALL RAM_SEL
                LD HL,(SCRIPT_EDITHL)
                LD (HL),C
                LD A,#FF
                LD (GAME_EDITCHM),A

;скрипт - портал
SCRIPT_E3       LD A,7
                CALL RAM_SEL
                LD HL,SCRIPT_PRTLLB
                CALL PRINT_TEXT
                LD HL,(SCRIPT_EDITHL)
                XOR A
                CALL RAM_SEL
                INC L,L
                LD D,(HL)
                INC L
                LD E,(HL)
                LD A,7
                CALL RAM_SEL
                LD HL,#1C0E
                LD A,D
                CALL PRINT_HEX
                INC H,H
                LD A,E
                CALL PRINT_HEX
;быстрый переход
                PUSH DE
                LD HL,#180F
                LD DE,#1707
                LD B,8
                CALL BUTTON
                POP HL
                JR Z,SCRIPT_E4
                CALL CENTER_MAP
                LD (MAP_XY),HL

;захват координат скрипта
SCRIPT_E4       LD HL,#1806
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR NZ,SCRIPT_E5
                LD L,7
                CALL BUTTON
                JR Z,SCRIPT_E10
SCRIPT_E5       CALL MAP_PAUSE
                CALL MAP_PAUSE
                LD HL,SHOW_SCRIPT
                LD (CAPTURE_TYPE+1),HL
                XOR A
                CALL CAPTURE_CORD
                JR NZ,SCRIPT_E10
                EX DE,HL
                LD HL,(SCRIPT_EDITHL)
                XOR A
                CALL RAM_SEL
                DEC L
                LD (HL),C
                DEC L
                LD (HL),B
                DEC L
                LD (HL),E
                DEC L
                LD (HL),D
                LD A,#FF
                LD (GAME_EDITCHM),A
                LD A,7
                CALL RAM_SEL

;редактирование порталов
SCRIPT_E10

;выбор карты
                XOR A
                CALL RAM_SEL
                LD HL,(SCRIPT_EDITHL)
                INC L
                LD C,(HL)
                LD A,7
                CALL RAM_SEL
                LD HL,#180C
                LD DE,#1707
                LD B,255
                LD A,C
                CALL SPINEDIT
                JR Z,SCRIPT_E11
                LD C,A
                XOR A
                CALL RAM_SEL
                LD HL,(SCRIPT_EDITHL)
                INC L
                LD (HL),C
                LD A,#FF
                LD (GAME_EDITCHM),A

;захват координат портала
SCRIPT_E11      LD HL,#180E
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,SCRIPT_E13

                LD HL,(SCRIPT_EDITHL)
                XOR A
                CALL RAM_SEL
                INC L,L
                LD D,(HL)
                INC L
                LD E,(HL)
                DEC E
                EX DE,HL
                LD A,7
                CALL RAM_SEL

                PUSH HL
                LD A,(CURRENT_MAP)
                LD (SCRIPT_EDITM),A
                CALL SAVE_MAP
                LD A,C
                CALL INIT_MAP
                CALL MAP_PAUSE
                POP HL

                LD A,#FF
                CALL CAPTURE_CORD

                PUSH AF,HL
                LD A,(SCRIPT_EDITM)
                CALL INIT_MAP
                POP HL,AF

                JR NZ,SCRIPT_E13
                EX DE,HL
                LD HL,(SCRIPT_EDITHL)
                XOR A
                CALL RAM_SEL
                INC L,L
                LD (HL),D
                INC L,E
                LD (HL),E
                LD A,#FF
                LD (GAME_EDITCHM),A

;сохранение
SCRIPT_E13      LD A,7
                CALL RAM_SEL
                LD HL,#1816
                LD DE,#1707
                LD B,8
                CALL BUTTON
                CALL NZ,SAVE_MAP

;выход из редактора
                LD A,7
                CALL RAM_SEL
                LD HL,#1817
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JP NZ,SAVE_ALL
                CALL SHOW_SCREEN
                JP SCRIPT_EDIT


;редактор картмодов
MOD_EDIT

;рисуем карту и проверяем на скролл
                CALL MAP_SCROLL
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
                CALL SHOW_MOD
                LD A,7
                CALL RAM_SEL

;рисуем панель инструментов
                LD HL,#1800
                LD BC,#0818
                LD A,7
                CALL CLEAR_RECT
                LD HL,MOD_EDITLB
                CALL PRINT_TEXT
                CALL SHOW_CORD
;выбор мода и свободная память под моды
                XOR A
                CALL RAM_SEL
                LD B,-1
                LD HL,128*124+MAP
MOD_E1          LD A,(HL)
                OR A
                JR Z,MOD_E2
                ADD A,L
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                INC B
                JR MOD_E1

MOD_E2          LD A,7
                CALL RAM_SEL
                PUSH BC
                LD B,H,C,L
                LD HL,128*127+MAP
                OR A
                SBC HL,BC
                LD B,H,C,L
                LD HL,#1C12
                LD A,B
                CALL PRINT_HEX
                LD H,#1E
                LD A,C
                CALL PRINT_HEX
                POP BC

                INC B
                JR Z,MOD_E3
                DEC B

MOD_E3          LD HL,#1801
                LD DE,#1707
                LD A,(CURRENT_MOD)
                CP B
                JR C,$+6
                LD A,B
                LD (CURRENT_MOD),A
                CALL SPINEDIT
                JR Z,MOD_E10
                LD (CURRENT_MOD),A
                CALL MAP_PAUSE

;адрес, координаты и размер мода
MOD_E10         XOR A
                CALL RAM_SEL
                LD HL,128*124+MAP
                LD A,(CURRENT_MOD)
                INC A
                LD B,A
MOD_E11         DEC B
                JR Z,MOD_E12
                LD A,(HL)
                ADD A,L
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                JR MOD_E11

MOD_E12         LD (CURRENT_MODADR),HL
                INC HL
                LD B,(HL)
                INC HL
                LD C,(HL)
                INC HL
                LD D,(HL)
                INC HL
                LD E,(HL)
                LD A,7
                CALL RAM_SEL
                LD HL,#1C04
                LD A,B
                CALL PRINT_HEX
                INC H,H
                LD A,C
                CALL PRINT_HEX
                LD HL,#1C05
                LD A,D
                CALL PRINT_HEX
                INC H,H
                LD A,E
                CALL PRINT_HEX
;быстрый переход
                PUSH BC,DE
                LD HL,#1806
                LD DE,#1707
                LD B,8
                CALL BUTTON
                POP DE,HL
                JR Z,MOD_E15
                SRL D,E
                ADD HL,DE
                CALL CENTER_MAP
                LD (MAP_XY),HL
                CALL REDRAW_ALL

;создаем модификатор
MOD_E15         LD HL,#1808
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MOD_E30
                CALL MAP_PAUSE
                CALL MAP_PAUSE
                LD HL,SHOW_MOD
                LD (CAPTURE_TYPE+1),HL
                XOR A
                CALL CAPTURE_CORD
                JR NZ,MOD_E30

                EX DE,HL
                XOR A
                CALL RAM_SEL
                PUSH BC
                LD HL,128*124+MAP
                LD B,0
MOD_E20         LD A,(HL)
                OR A
                JR Z,MOD_E21
                ADD A,L
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                INC B
                JR MOD_E20

MOD_E21         LD A,B
                LD (CURRENT_MOD),A
                POP BC
                PUSH HL

                INC HL
                LD (HL),D
                INC HL
                LD (HL),E
                INC HL
                LD A,B
                SUB D
                INC A
                LD B,A
                LD (HL),B
                INC HL
                LD A,C
                SUB E
                INC A
                LD (HL),A
                GETMAPADR DEC 
                LD C,B
                LD B,(HL)
                INC HL
                EX DE,HL

MOD_E22         PUSH BC,HL
                LD B,0
                LDIR 
                POP HL,BC
                LD A,L
                ADD A,128
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                DJNZ MOD_E22

                POP HL
                EX DE,HL
                OR A
                SBC HL,DE
                EX DE,HL
                LD (HL),E

                LD A,#FF
                LD (GAME_EDITCHM),A
                JP MOD_E90

;удаление текущего мода
MOD_E30         LD HL,#180A
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MOD_E40
                CALL MAP_PAUSE
                CALL MAP_PAUSE
                XOR A
                CALL RAM_SEL
                LD BC,(CURRENT_MODADR)
                LD A,(BC)
                ADD A,C
                LD E,A
                LD A,B
                ADC A,0
                LD D,A
                LD HL,128*127+MAP
                OR A
                SBC HL,BC
                LD B,H,C,L
                LD HL,(CURRENT_MODADR)
                EX DE,HL
                LDIR 
                JP MOD_E90

;показать текущий модификатор
MOD_E40         LD HL,#180B
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MOD_E50
                CALL MAP_PAUSE
                CALL MAP_PAUSE

                XOR A
                CALL RAM_SEL
                LD HL,(CURRENT_MODADR)
                LD A,(HL)
                OR A
                JP Z,MOD_E90
                INC HL
                LD D,(HL)
                INC HL
                LD E,(HL)
                GETMAPADR DEC 
                INC HL
                LD B,(HL)
                INC HL
                LD C,(HL)
                INC HL

                CALL MOD_EXCHANGE
                LD A,2
                OUT (254),A
                PUSH HL
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
                POP HL
                CALL SHOW_SCREEN

                CALL ANYKEY
                XOR A
                OUT (254),A
                CALL MOD_EXCHANGE
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
                CALL SHOW_SCREEN
                JP MOD_E90

;редактирование мода
MOD_E50         LD HL,#1809
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JP Z,MOD_E90
;очищаем экраны
MOD_E51         RAMPAGE 7
                LD HL,#0000
                LD BC,#2018
                LD A,7
                CALL CLEAR_RECT
                CALL SHOW_SCREEN
                CALL CLEAR_RECT

;основной цикл
MOD_E60

;копируем инфу мода в MAP_BUFFER
                RAMPAGE 0
                LD HL,(CURRENT_MODADR)
                LD A,(HL)
                OR A
                JP Z,MOD_E90
                SUB 5
                PUSH AF
                INC HL
                LD D,(HL)
                INC HL
                LD E,(HL)
                GETMAPADR DEC 
                INC HL
                LD B,(HL)
                INC HL
                LD C,(HL)
                INC HL
                POP AF
                LD (CURRENT_MODSZ),BC
                LD DE,MAP_BUFFER
                LD C,A,B,0
                LDIR 

                RAMPAGE 7
                LD HL,0
                LD DE,MAP_BUFFER
                LD BC,(CURRENT_MODSZ)
MOD_E61         PUSH BC,HL
MOD_E62         LD A,(DE)
                PUSH DE
                LD DE,TILE_SPRITE+256
                CALL DRAW_TILE
                POP DE
                INC H,H,E
                DJNZ MOD_E62
                POP HL,BC
                INC L,L
                DNZ C,MOD_E61

;рисуем панель инструментов
                LD HL,#1800
                LD BC,#0818
                LD A,7
                CALL CLEAR_RECT
                LD HL,MOD_SUBEDITLB
                CALL PRINT_TEXT

;проверка вхождения курсора в мод
                LD BC,(CURRENT_MODSZ)
                LD D,B,E,C
                LD HL,(INPUT_Y)
                LD A,H
                DUP 4
                RRCA 
                EDUP 
                AND #0F
                CP B
                JP NC,MOD_E70
                LD H,A
                LD A,L
                DUP 4
                RRCA 
                EDUP 
                AND #0F
                CP C
                JP NC,MOD_E70
                LD L,A

;вывод блока и рамки
                LD A,(MAP_EDITSZ)
                CP C
                JR NC,$+3
                LD C,A
                LD A,(MAP_EDITSZ+1)
                CP B
                JR NC,$+3
                LD B,A

                LD A,H
                ADD A,B
                DEC A
                CP D
                JR C,$+5
                LD A,D
                SUB B
                LD H,A

                LD A,L
                ADD A,C
                DEC A
                CP E
                JR C,$+5
                LD A,E
                SUB C
                LD L,A

                PUSH BC,HL
                LD DE,TEMP_TAB
                SLA H,L
MOD_E63         PUSH BC,DE,HL
MOD_E64         LD A,(DE)
                PUSH DE
                LD DE,TILE_SPRITE+256
                CALL DRAW_TILE
                POP DE
                INC H,H,E
                DJNZ MOD_E64
                POP HL,DE,BC
                LD A,(MAP_EDITSZ+1)
                ADDA DE
                INC L,L
                DNZ C,MOD_E63
                POP HL,BC

                PUSH BC,HL
                SLA B,C,H,L
                XOR A
                CALL DRW_FRAME
                POP HL,BC

;изменение карты
                LD A,(INPUT_BUTTON)
                AND 1
                JP Z,MOD_E70

                LD A,#FF
                LD (GAME_EDITCHM),A
                RAMPAGE 0

                LD DE,(CURRENT_MODADR)
                ADDW DE,5
                LD A,(CURRENT_MODSZ+1)
                PUSH BC
                LD B,A
                XOR A
MOD_E65         ADD A,L
                DJNZ MOD_E65
                POP BC
                ADD A,H
                ADDA DE
                LD HL,TEMP_TAB
                LD A,B,B,C,C,A

MOD_E66         PUSH BC,DE,HL
                LD B,0
                LDIR 
                POP HL,DE,BC
                LD A,(CURRENT_MODSZ+1)
                ADDA DE
                LD A,(MAP_EDITSZ+1)
                ADDA HL
                DJNZ MOD_E66


;выбор образа тайлсета
MOD_E70         RAMPAGE 7
                LD HL,#1800
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MOD_E71
                XOR A
                CALL TILE_IMAGE
                JP MOD_E51

MOD_E71         LD HL,#1801
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MOD_E72
                LD A,1
                CALL TILE_IMAGE
                JP MOD_E51

MOD_E72         LD HL,#1802
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MOD_E73
                LD A,2
                CALL TILE_IMAGE
                JP MOD_E51

MOD_E73         LD HL,#1803
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MOD_E74
                LD A,3
                CALL TILE_IMAGE
                JP MOD_E51

;выход из подредактора
MOD_E74         RAMPAGE 7
                LD HL,#1817
                LD DE,#1707
                LD B,8
                CALL BUTTON
                CALL NZ,MAP_PAUSE
                JP NZ,MOD_EDIT
                CALL SHOW_SCREEN
                JP MOD_E60

;сохранение
MOD_E90         RAMPAGE 7
                LD HL,#1816
                LD DE,#1707
                LD B,8
                CALL BUTTON
                CALL NZ,SAVE_MAP

;выход из редактора
                RAMPAGE 7
                LD HL,#1817
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JP NZ,SAVE_ALL
                CALL SHOW_SCREEN
                JP MOD_EDIT


;обменяться между картой и модификатором
;вх  - HL - адрес данных мода
;      DE - адрес на карте
;      BC - размеры мода
;вых - нет

MOD_EXCHANGE    PUSH BC,DE,HL
                XOR A
                CALL RAM_SEL
MOD_EX1         PUSH BC,DE
MOD_EX2         LD C,(HL)
                LD A,(DE)
                LD (HL),A
                LD A,C
                LD (DE),A
                INC E,HL
                DJNZ MOD_EX2
                POP DE,BC
                ADDW DE,128
                DNZ C,MOD_EX1
                POP HL,DE,BC
                RET 


;редактор объектов
OBJECT_EDIT

;рисуем карту и проверяем на скролл
                CALL MAP_SCROLL
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
                CALL SHOW_MAPOBJ
                LD A,7
                CALL RAM_SEL

;рисуем панель инструментов
                LD HL,#1800
                LD BC,#0818
                LD A,7
                CALL CLEAR_RECT
                LD HL,OBJECT_EDITLB
                CALL PRINT_TEXT
                CALL SHOW_CORD

                LD HL,#1A02
                LD DE,MAP_PROPERTY+1
                LD B,3
OBJECT_E1       XOR A
                CALL RAM_SEL
                LD A,(DE)
                OR A
                LD C,A,A,0
                JR Z,OBJECT_E2
                CALL DRAW_TYPE
                LD A,(CURRENT_SPRSET)
                LD C,A,A,3
                SUB C
                CP B
                JR NZ,OBJECT_E2
                PUSH BC
                LD BC,#0404
                LD A,#18
                CALL FILL_ATTR
                POP BC
OBJECT_E2       LD A,L
                ADD A,6
                LD L,A
                INC DE
                DJNZ OBJECT_E1

                LD HL,MAP_OBJECTS
                LD BC,0
OBJECT_E3       LD A,(HL)
                OR A
                JR NZ,$+3
                INC C
                INC L
                DJNZ OBJECT_E3
                LD A,7
                CALL RAM_SEL
                LD HL,#1D12
                LD A,C
                CALL PRINT_HEX

;загрузка спрайтсетов
                LD B,3
                LD DE,MAP_PROPERTY+1
                LD HL,#1801
OBJECT_E10      PUSH BC,HL,DE

                XOR A
                CALL RAM_SEL
                LD A,(DE)
                LD C,A
                LD A,7
                CALL RAM_SEL
                LD DE,#1707
                LD B,255
                LD A,C
                CALL SPINEDIT
                JR Z,OBJECT_E11
                LD C,A

                XOR A
                CALL RAM_SEL
                POP HL
                PUSH HL
                LD (HL),C
                LD A,(CURRENT_MAP)
                CALL INIT_MAP
                LD A,#FF
                LD (GAME_EDITCHM),A

OBJECT_E11      POP DE,HL,BC
                LD A,L
                ADD A,6
                LD L,A
                INC DE
                DJNZ OBJECT_E10

;выбор спрайтсета
                LD A,(INPUT_BUTTON)
                AND 1
                JR Z,OBJECT_E30
                LD HL,(INPUT_Y)
                SRL H,H,H,L,L,L
                LD BC,#302
OBJECT_E20      LD A,H
                CP 26
                JR C,OBJECT_E21
                CP 30
                JR NC,OBJECT_E21
                LD A,L
                CP C
                JR C,OBJECT_E21
                LD A,C
                ADD A,3
                CP L
                JR C,OBJECT_E21
                LD A,3
                SUB B
                LD (CURRENT_SPRSET),A
OBJECT_E21      LD A,C
                ADD A,6
                LD C,A
                DJNZ OBJECT_E20

;установка объекта на карту
OBJECT_E30      LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD A,H
                CP 12
                JR NC,OBJECT_E50
                CP 11
                JR NZ,$+4
                LD H,10
                LD A,L
                CP 11
                JR NZ,$+4
                LD L,10
                SLA H,L
                LD BC,#0404
                XOR A
                CALL DRW_FRAME
                SRL H,L
                LD DE,(MAP_XY)
                ADD HL,DE
                INC L
                EX DE,HL

                LD A,(INPUT_BUTTON)
                AND 1
                JR Z,OBJECT_E40

;проверка на другой объект
                LD HL,MAP_OBJECTS
                LD B,0
OBJECT_E31      LD A,(HL)
                CP E
                JR NZ,OBJECT_E32
                INC H
                LD A,(HL)
                DEC H
                CP D
                JR Z,OBJECT_E40
OBJECT_E32      INC L
                DJNZ OBJECT_E31

;поиск свободного слота
                LD HL,MAP_OBJECTS
                LD B,0
OBJECT_E33      LD A,(HL)
                OR A
                JR Z,OBJECT_E34
                INC L
                DJNZ OBJECT_E33
                JR OBJECT_E40

OBJECT_E34      LD (HL),E
                INC H
                LD (HL),D
                INC H
                LD A,(CURRENT_SPRSET)
                LD (HL),A
                LD A,#FF
                LD (GAME_EDITCHO),A

;удаление объекта
OBJECT_E40      LD A,(INPUT_BUTTON)
                AND 2
                JR Z,OBJECT_E50
                LD HL,MAP_OBJECTS
                LD B,0
OBJECT_E41      LD A,(HL)
                CP E
                JR NZ,OBJECT_E42
                INC H
                LD A,(HL)
                DEC H
                CP D
                JR NZ,OBJECT_E42
                LD (HL),0
                LD A,#FF
                LD (GAME_EDITCHO),A
OBJECT_E42      INC L
                DJNZ OBJECT_E41

;сохранение
OBJECT_E50      LD A,7
                CALL RAM_SEL
                LD HL,#1816
                LD DE,#1707
                LD B,8
                CALL BUTTON
                CALL NZ,SAVE_MAP
                CALL NZ,SAVE_OBJECT

;выход из редактора
                LD A,7
                CALL RAM_SEL
                LD HL,#1817
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JP NZ,SAVE_ALL
                CALL SHOW_SCREEN
                JP OBJECT_EDIT

OBJECT_EDITLB   DB 24,00," Спрайт 1",0
                DB 24,01," +      -",0
                DB 24,06," Спрайт 2",0
                DB 24,07," +      -",0
                DB 24,12," Спрайт 3",0
                DB 24,13," +      -",0
                DB 24,18," Free",0
                DB 24,19," XYm",0
                DB 24,20," XYc",0
                DB 24,22," Сохранить",0
                DB 24,23," Выход",0,#FF
CURRENT_SPRSET  DB 0

MOD_EDITLB      DB 24,00," N мода:",0
                DB 24,01," +      -",0
                DB 24,03," Коорд.:",0
                DB 24,04," XY",0
                DB 24,05," IJ",0
                DB 24,06," Перейти",0
                DB 24,08," Добавить",0
                DB 24,09," Редакт.",0
                DB 24,10," Удалить",0
                DB 24,11," Показать",0
                DB 24,18," Free",0
                DB 24,19," XYm",0
                DB 24,20," XYc",0
                DB 24,22," Сохранить",0
                DB 24,23," Выход",0,#FF
MOD_SUBEDITLB   DB 24,0," Образ 1",0
                DB 24,1," Образ 2",0
                DB 24,2," Образ 3",0
                DB 24,3," Образ 4",0
                DB 24,23," Выход",0,#FF
CURRENT_MOD     DB 0
CURRENT_MODSZ   DW 0
CURRENT_MODADR  DW 0

