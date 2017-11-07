;+++++++++++++++ EDITOR_1.H ++++++++++++++

                MAIN "GAME.H",#C0

;режим редактирования ресурсов игры

GAME_EDIT

;загрузка спецтайлов
                DI 
                IM 1
                EI 
                LD HL,TRACE_TAB
                LD DE,TRACE_NAME
                LD BC,#240
                CALL LOAD_FILE
                DI 
                IM 2
                EI 

                LD A,#FF
                LD (INIT_MAP_FIRST),A
                XOR A
                CALL INIT_MAP
                XOR A
                LD (INIT_MAP_FIRST),A
                LD (GAME_EDITCHM),A
                LD (GAME_EDITCHT),A

                LD A,7
                CALL RAM_SEL

;главное меню
GAME_E1         LD HL,#1800
                LD BC,#0818
                LD A,7
                CALL CLEAR_RECT
                LD HL,GAME_EDITLB
                CALL PRINT_TEXT
                CALL MAP_SCROLL
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
                CALL SHOW_SCRIPT
                CALL SHOW_MOD
                CALL SHOW_MAPOBJ
                LD A,7
                CALL RAM_SEL
;выбор карты
                LD HL,#1801
                LD DE,#1707
                LD B,255
                LD A,(CURRENT_MAP)
                CALL SPINEDIT
                JR Z,GAME_E5
                CALL INIT_MAP
                XOR A
                LD (GAME_EDITCHM),A
                JP GAME_EE

;выбор тайлсета
GAME_E5         LD HL,#1803
                LD DE,#1707
                LD B,255
                XOR A
                CALL RAM_SEL
                LD A,(MAP_PROPERTY)
                PUSH AF
                LD A,7
                CALL RAM_SEL
                POP AF
                CALL SPINEDIT
                JR Z,GAME_E6
                PUSH AF
                XOR A
                CALL RAM_SEL
                POP AF
                LD (MAP_PROPERTY),A
                LD A,(CURRENT_MAP)
                CALL INIT_MAP
                LD A,#FF
                LD (GAME_EDITCHM),A
                JP GAME_EE
;выбор трека
GAME_E6         LD HL,#1805
                LD DE,#1707
                LD B,255
                XOR A
                CALL RAM_SEL
                LD A,(MAP_PROPERTY+7)
                PUSH AF
                LD A,7
                CALL RAM_SEL
                POP AF
                CALL SPINEDIT
                JR Z,GAME_E7
                PUSH AF
                XOR A
                CALL RAM_SEL
                POP AF
                LD (MAP_PROPERTY+7),A
                LD A,(CURRENT_MAP)
                CALL INIT_MAP
                LD A,#FF
                LD (GAME_EDITCHM),A
                JP GAME_EE
;редактор карты
GAME_E7         LD HL,#1807
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,GAME_E8
                CALL MAP_EDIT
                JP GAME_EE

;редактор картмодов
GAME_E8         LD HL,#1808
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,GAME_E9
                CALL MOD_EDIT
                CALL MAP_PAUSE
                JP GAME_EE

;редактор тайлов
GAME_E9         LD HL,#1809
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,GAME_E10
                CALL TILE_EDIT
                CALL MAP_PAUSE
                JP GAME_EE

;редактор скриптов
GAME_E10        LD HL,#180A
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,GAME_E11
                CALL SCRIPT_EDIT
                CALL MAP_PAUSE
                JP GAME_EE

;редактор объектов
GAME_E11        LD HL,#180B
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,GAME_E12
                CALL OBJECT_EDIT
                CALL MAP_PAUSE
                JP GAME_EE

;выход из редактора
GAME_E12        LD HL,#1817
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JP NZ,SAVE_ALL
;сохранение
                LD HL,#1816
                LD DE,#1707
                LD B,8
                CALL BUTTON
                CALL NZ,SAVE_MAP
                CALL NZ,SAVE_TILE

GAME_EE         CALL SHOW_CORD
                CALL SHOW_SCREEN
                JP GAME_E1


;очистка временной таблицы и переменных
MAP_EDIT        LD HL,TEMP_TAB
                LD DE,TEMP_TAB+1
                LD BC,191
                LD (HL),0
                LDIR 
                LD HL,#0101
                LD (MAP_EDITSZ),HL


;основной цикл
MAP_E1

;рисуем карту и проверяем на скролл
                LD A,(MAP_EDITSL)
                OR A
                CALL Z,MAP_SCROLL
                CALL REDRAW_ALL
                LD HL,(MAP_XY)
                CALL MAP_DRAW

;рисуем панель инструментов
                LD HL,#1800
                LD BC,#0818
                LD A,7
                CALL CLEAR_RECT
                LD HL,MAP_EDITLB
                CALL PRINT_TEXT

                LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD BC,(MAP_EDITSZ)

;проверка на вхождение в карту
                LD A,H
                CP 12
                JP NC,MAP_E50

                LD A,(MAP_EDITSL)
                OR A
                JR NZ,MAP_E9

                LD A,H
                ADD A,B
                CP 13
                JR C,MAP_E5
                LD A,12
                SUB B
                LD H,A
MAP_E5          LD A,L
                ADD A,C
                CP 13
                JR C,MAP_E6
                LD A,12
                SUB C
                LD L,A

;вывод блока и рамки
MAP_E6          PUSH BC,HL
                LD DE,TEMP_TAB
                SLA H,L
MAP_E7          PUSH BC,HL
MAP_E8          LD A,(DE)
                PUSH DE
                LD DE,TILE_SPRITE+256
                CALL DRAW_TILE
                POP DE
                INC H,H,E
                DJNZ MAP_E8
                POP HL,BC
                INC L,L
                DEC C
                JR NZ,MAP_E7
                POP HL,BC
                PUSH BC,HL
                SLA B,C,H,L
                XOR A
                CALL DRW_FRAME
                POP HL,BC

;опрос кнопок
MAP_E9          LD A,(INPUT_BUTTON)
                AND 1
                JP Z,MAP_E20

;изменение карты
                LD A,#FF
                LD (GAME_EDITCHM),A
                XOR A
                CALL RAM_SEL
                LD DE,(MAP_XY)
                ADD HL,DE
                GETMAPADR HLE
                LD DE,TEMP_TAB
MAP_E10         PUSH BC,HL
MAP_E11         LD A,(DE)
                LD (HL),A
                INC L,E
                DJNZ MAP_E11
                POP HL,BC
                LD A,L
                ADD A,128
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                DEC C
                JR NZ,MAP_E10
                JP MAP_E90

MAP_E20         LD A,(INPUT_BUTTON)
                AND 2
                JP Z,MAP_E30

;проверка текущего режима карты
                LD A,(MAP_DRAWMODE)
                OR A
                JR Z,MAP_E21

;свойства тайла
                LD HL,#0101
                LD (MAP_EDITSZ),HL
                LD A,#FF
                LD (MAP_EDITSL),A
                LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD DE,(MAP_XY)
                ADD HL,DE
                GETMAPADR HLE
                XOR A
                CALL RAM_SEL
                LD A,(HL)
                LD (TEMP_TAB),A
                CALL TILE_PROPERTY
                CALL MAP_PAUSE
                JP MAP_E90

;инициализация выбора
MAP_E21         LD A,(MAP_EDITSL)
                OR A
                JP NZ,MAP_E40
                LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD (MAP_EDITXY),HL
                LD HL,#0101
                LD (MAP_EDITSZ),HL
                LD A,#FF
                LD (MAP_EDITSL),A
                JP MAP_E90

;запись в буфер фрагмента карты
MAP_E30         LD A,(MAP_EDITSL)
                OR A
                JP Z,MAP_E90
                LD DE,(MAP_EDITXY)
                LD A,H
                CP D
                JR NC,MAP_E33
                LD D,H
MAP_E33         LD A,L
                CP E
                JR NC,MAP_E34
                LD E,L
MAP_E34         EX DE,HL
                LD DE,(MAP_XY)
                ADD HL,DE
                GETMAPADR HLE
                XOR A
                CALL RAM_SEL
                LD DE,TEMP_TAB
MAP_E31         PUSH BC,HL
MAP_E32         LD A,(HL)
                LD (DE),A
                INC L,E
                DJNZ MAP_E32
                POP HL,BC
                LD A,L
                ADD A,128
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                DEC C
                JR NZ,MAP_E31
                XOR A
                LD (MAP_EDITSL),A
                JP MAP_E90

;выбор фрагмента карты
MAP_E40         LD DE,(MAP_EDITXY)
                LD A,H
                CP D
                JR NC,MAP_E41
                LD H,D
                LD D,A
MAP_E41         LD A,L
                CP E
                JR NC,MAP_E42
                LD L,E
                LD E,A
MAP_E42         LD A,H
                SUB D
                INC A
                LD B,A
                LD A,L
                SUB E
                INC A
                LD C,A
                LD (MAP_EDITSZ),BC
                EX DE,HL
                SLA H,L,B,C
                XOR A
                CALL DRW_FRAME
                JP MAP_E90

MAP_E50         LD HL,#1805
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MAP_E62
                CALL TILE_PROPERTY
                CALL MAP_PAUSE
                JP MAP_E90

;режим вывода карты
MAP_E62         LD HL,#1804
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,MAP_E64
                LD A,(MAP_DRAWMODE)
                XOR #FF
                LD (MAP_DRAWMODE),A
                CALL MAP_PAUSE
                JP MAP_E90

;выбор образа тайлсета
MAP_E64         LD HL,#1800
                LD DE,#1707
                LD B,8
                CALL BUTTON
                LD A,0
                CALL NZ,TILE_IMAGE

                LD HL,#1801
                LD DE,#1707
                LD B,8
                CALL BUTTON
                LD A,1
                CALL NZ,TILE_IMAGE

                LD HL,#1802
                LD DE,#1707
                LD B,8
                CALL BUTTON
                LD A,2
                CALL NZ,TILE_IMAGE

                LD HL,#1803
                LD DE,#1707
                LD B,8
                CALL BUTTON
                LD A,3
                CALL NZ,TILE_IMAGE

;сохранение
                LD HL,#1816
                LD DE,#1707
                LD B,8
                CALL BUTTON
                CALL NZ,SAVE_MAP
                CALL NZ,SAVE_TILE

MAP_E65
;выход из редактора
                LD HL,#1817
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JP NZ,SAVE_ALL

MAP_E90         CALL SHOW_CORD
                CALL SHOW_SCREEN
                JP MAP_E1

MAP_PAUSE       PUSH BC
                LD B,5
MAP_P1          EI 
                HALT 
                DJNZ MAP_P1
                EI 
                POP BC
                RET 


;отображение координат
SHOW_CORD       LD A,7
                CALL RAM_SEL
                LD DE,(MAP_XY)
                LD HL,#1C13
                LD A,D
                CALL PRINT_HEX
                LD H,#1E
                LD A,E
                CALL PRINT_HEX
                LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD A,H
                CP 12
                RET NC
                ADD HL,DE
                EX DE,HL
                LD HL,#1C14
                LD A,D
                CALL PRINT_HEX
                LD H,#1E
                LD A,E
                CALL PRINT_HEX
                RET 


;проверка сохранненых данных и RET
SAVE_ALL        LD A,(GAME_EDITCHM)
                OR A
                JR Z,SAVE_A1
                LD HL,SAVE_ALLQ1
                CALL MSGBOX
                OR A
                CALL NZ,SAVE_MAP
SAVE_A1         LD A,(GAME_EDITCHT)
                OR A
                JR Z,SAVE_A2
                LD HL,SAVE_ALLQ2
                CALL MSGBOX
                OR A
                CALL NZ,SAVE_TILE
SAVE_A2         LD A,(GAME_EDITCHO)
                OR A
                JR Z,SAVE_A3
                LD HL,SAVE_ALLQ3
                CALL MSGBOX
                OR A
                CALL NZ,SAVE_OBJECT
SAVE_A3         XOR A
                LD (MAP_DRAWMODE),A
                CALL MAP_PAUSE
                RET 


;образ тайлсета
;вх  - A - номер образа

TILE_IMAGE      LD HL,MAP_BUFFER
                LD DE,MAP_BUFFER+1
                LD BC,#BF
                LD (HL),0
                LDIR 
                CALL MAP_PAUSE
                LD HL,TILE_NAME
                LD DE,TILE_IMAGENAME
                LDI 
                LDI 
                ADD A,#30
                LD (DE),A

                DI 
                IM 1
                EI 
                LD HL,MAP_BUFFER
                LD DE,TILE_IMAGENAME
                LD BC,#00C0
                CALL LOAD_FILE
                DI 
                IM 2
                EI 

                XOR A
                LD (TILE_IMAGEC),A
                LD HL,#0101
                LD (MAP_EDITSZ),HL

TILE_I1         LD HL,0
                LD DE,MAP_BUFFER
                LD BC,#100C
TILE_I2         PUSH BC,HL
TILE_I3         PUSH DE
                LD A,(DE)
                LD DE,TILE_SPRITE+256
                CALL DRAW_TILE
                POP DE
                INC E,H,H
                DJNZ TILE_I3
                POP HL,BC
                INC L,L
                DEC C
                JR NZ,TILE_I2

;проверка кнопок
                LD A,(INPUT_BUTTON)
                AND 3
                JR Z,TILE_I4
                LD A,(TILE_IMAGEC)
                OR A
                JR NZ,TILE_I5
                LD A,#FF
                LD (TILE_IMAGEC),A
                LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD (MAP_EDITXY),HL
                JR TILE_I5

TILE_I4         LD A,(TILE_IMAGEC)
                OR A
                JR NZ,TILE_I10
                LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD (MAP_EDITXY),HL

TILE_I5         LD DE,(INPUT_Y)
                SRL D,D,D,D,E,E,E,E
                LD HL,(MAP_EDITXY)
                LD A,D
                SUB H
                JR NC,TILE_I6
                NEG 
                LD H,D
TILE_I6         INC A
                CP 12
                JR C,TILE_I7
                LD A,12
TILE_I7         LD B,A
                LD A,E
                SUB L
                JR NC,TILE_I8
                NEG 
                LD L,E
TILE_I8         INC A
                LD C,A
                LD (MAP_EDITSZ),BC
                SLA H,L,B,C
                XOR A
                CALL DRW_FRAME
                CALL SHOW_SCREEN
                JP TILE_I1

;сохраняем в буфер и выходим
TILE_I10        LD DE,(INPUT_Y)
                SRL D,D,D,D,E,E,E,E
                LD HL,(MAP_EDITXY)
                LD A,D
                CP H
                JR NC,TILE_I11
                LD H,D
TILE_I11        LD A,E
                CP L
                JR NC,TILE_I12
                LD L,E
TILE_I12        LD A,L
                DUP 4
                ADD A,A
                EDUP 
                ADD A,H
                ADD A,.MAP_BUFFER
                LD L,A
                LD H,'MAP_BUFFER

                LD BC,(MAP_EDITSZ)
                LD DE,TEMP_TAB
TILE_I13        PUSH BC,HL
TILE_I14        LD A,(HL)
                LD (DE),A
                INC L,E
                DJNZ TILE_I14
                POP HL,BC
                LD A,L
                ADD A,16
                LD L,A
                DEC C
                JR NZ,TILE_I13

                CALL MAP_PAUSE
                RET 


;свойства тайла
TILE_PROPERTY   LD A,7
                CALL RAM_SEL
                LD A,(TEMP_TAB)
                LD L,A
                LD H,TILE_TYPE/256
                LD A,(HL)
                LD (TILE_PROPDB),A

                XOR A
                LD (CURSOR_TYPE),A
                LD L,A,E,0
                LD A,(ACTIVE_SCREEN)
                LD H,A
                XOR #80
                LD D,A
                LD BC,#1B00
                LDIR 

TILE_P1         LD HL,#0B07
                LD BC,#0A0C
                LD A,#0F
                CALL CLEAR_RECT
                LD A,#FF
                CALL DRW_FRAME
                LD A,(TILE_PROPDB)
                LD D,A
                LD HL,#0C08
                LD BC,#0404
                XOR A
TILE_P2         PUSH BC,HL
TILE_P3         PUSH DE
                LD DE,TRACE_TAB
                CALL DRAW_TILE
                POP DE
                CP D
                CALL Z,FLASH_TILE
                INC H,H,A
                DJNZ TILE_P3
                POP HL,BC
                INC L,L
                DEC C
                JR NZ,TILE_P2

                LD HL,(INPUT_Y)
                SRL H,H,H,H,L,L,L,L
                LD A,H
                CP 6
                JR C,TILE_P4
                CP 10
                JR NC,TILE_P4
                LD A,L
                CP 4
                JR C,TILE_P4
                CP 8
                JR NC,TILE_P4
                XOR A
                SLA H,L
                LD BC,#0202
                CALL DRW_FRAME
                LD A,(INPUT_BUTTON)
                AND 1
                JR Z,TILE_P4
                SRL H,L
                LD A,L
                SUB 4
                ADD A,A
                ADD A,A
                LD L,A
                LD A,H
                SUB 6
                ADD A,L
                LD (TILE_PROPDB),A

TILE_P4         LD HL,TILE_PROPLB
                CALL PRINT_TEXT
;сохранить
                LD HL,#0C11
                LD DE,#170F
                LD B,2
                CALL BUTTON
                JR Z,TILE_P5

                LD A,(TEMP_TAB)
                LD L,A
                LD H,TILE_TYPE/256
                LD A,(TILE_PROPDB)
                LD (HL),A
                LD A,#FF
                LD (GAME_EDITCHT),A
                RET 
;отмена
TILE_P5         LD HL,#0F11
                LD DE,#170F
                LD B,5
                CALL BUTTON
                RET NZ


                CALL SHOW_SCREEN
                JP TILE_P1
TILE_PROPDB     DB 0


;редактор тайлов
TILE_EDIT       XOR A
                LD (CURSOR_TYPE),A
                LD HL,0
                LD BC,#0C0C
                LD D,0
TILE_E1         PUSH BC,HL
TILE_E2         LD A,D
                PUSH DE
                LD DE,TILE_SPRITE+256
                CALL DRAW_TILE
                POP DE
                INC H,H,D
                DJNZ TILE_E2
                POP HL,BC
                INC L,L
                DEC C
                JR NZ,TILE_E1

                LD HL,#1800
                LD BC,#0818
                LD A,7
                CALL CLEAR_RECT
                LD HL,TILE_EDITLB
                CALL PRINT_TEXT
                CALL TILE_COUNT
                LD HL,#1E00
                CALL PRINT_HEX

;очистка тайлсета
                LD HL,#1802
                LD DE,#1707
                LD B,8
                CALL BUTTON
                JR Z,TILE_E3
                LD HL,TILE_EDITQ1
                CALL MSGBOX
                OR A
                JR Z,TILE_E3
                LD HL,TILE_SPRITE+256
                LD DE,TILE_SPRITE+257
                LD BC,#23FF
                LD (HL),0
                LDIR 
                LD HL,TILE_TYPE
                LD DE,TILE_TYPE+1
                LD BC,#FF
                LD (HL),0
                LDIR 

;тест экранов или создание тайлсета
TILE_E3         LD HL,#1803
                LD DE,#1707
                LD B,8
                CALL BUTTON
                LD A,0
                LD (TILE_EDITMODE),A
                JR NZ,TILE_E4

                LD HL,#1804
                LD DE,#1707
                LD B,8
                CALL BUTTON
                LD A,1
                LD (TILE_EDITMODE),A
                JP Z,TILE_E8


TILE_E4         LD HL,TILE_NAME
                LD DE,TILE_EDITSN
                LDI 
                LDI 
                LD A,"0"
                LD (DE),A

                LD A,(RAM_SAVE)
                AND #F7
                LD (RAM_SAVE),A
                LD A,7
                CALL RAM_SEL
                LD A,#40
                LD (ACTIVE_SCREEN),A
                XOR A
                LD (TILE_EDITNUM),A

                DI 
                IM 1
                EI 
TILE_E5         LD HL,#4000
                LD DE,#4001
                LD BC,#17FF
                LD (HL),0
                LDIR 
                INC HL,DE
                LD BC,#2FF
                LD (HL),#30
                LDIR 
                LD HL,#4000
                LD DE,TILE_EDITSN
                LD BC,#1B00
                CALL EXIST_FILE
                JR Z,TILE_E7
                CALL LOAD_FILE
                LD A,(TILE_EDITMODE)
                OR A
                JR Z,TILE_E6

;создаем тайлы
                LD A,(TILE_EDITNUM)
                LD IX,MAP_BUFFER
                CALL AUTOCUT_TILE
                LD (TILE_EDITNUM),A
                LD HL,TILE_EDITSN
                LD DE,TILE_IMAGENAME
                LDI 
                LDI 
                LDI 
                LD HL,MAP_BUFFER
                LD DE,TILE_IMAGENAME
                LD BC,#C0
                CALL SAVE_FILE
                JR TILE_E7

;тестируем экраны
TILE_E6         CALL OPTIMIZE
                LD A,2
                OUT (254),A
                CALL ANYKEY
                CALL MAP_PAUSE
                XOR A
                OUT (254),A

TILE_E7         LD DE,TILE_EDITSN+2
                LD A,(DE)
                INC A
                LD (DE),A
                CP "4"
                JR NZ,TILE_E5
                DI 
                IM 2
                EI 
                LD A,(TILE_EDITMODE)
                OR A
                JR Z,TILE_E8
                LD HL,TILE_TYPE
                LD DE,TILE_TYPE+1
                LD BC,#FF
                LD (HL),0
                LDIR 
                CALL SAVE_TILE

;выход из редактора
TILE_E8         LD HL,#1817
                LD DE,#1707
                LD B,8
                CALL BUTTON
                RET NZ

                CALL SHOW_SCREEN
                JP TILE_EDIT
                RET 
TILE_EDITMODE   DB 0
TILE_EDITNUM    DB 0


;кол-во тайлов в тайлсете
;вх  - нет
;вых - A - кол-во

TILE_COUNT      PUSH BC,DE,HL
                LD A,7
                CALL RAM_SEL
                LD HL,TILE_SPRITE+#100
                LD DE,32
                LD B,0
TILE_C1         ADD HL,DE
                LD A,(HL)
                OR A
                JR Z,TILE_C2
                INC HL,HL,HL,HL
                INC B
                JR NZ,TILE_C1
TILE_C2         LD A,B
                POP HL,DE,BC
                RET 


;сохраняем карту
SAVE_MAP        PUSH AF,BC,DE,HL
                DI 
                IM 1
                EI 
                XOR A
                CALL RAM_SEL
                LD HL,MAP
                LD DE,MAP_NAME
                LD BC,#4000
                CALL SAVE_FILE
                XOR A
                LD (GAME_EDITCHM),A
                DI 
                IM 2
                EI 
                POP HL,DE,BC,AF
                RET 


;сохраняем тайлсет
SAVE_TILE       PUSH AF,BC,DE,HL
                DI 
                IM 1
                EI 
                LD A,7
                CALL RAM_SEL

                LD HL,TILE_TYPE
                LD DE,TILE_SPRITE
                LD BC,#100
                LDIR 

                LD HL,TILE_SPRITE
                LD DE,TILE_NAME
                LD BC,#2500
                CALL SAVE_FILE

;загрузка спрайтов указателя трассера
                LD HL,PLACE_SPRITE
                LD DE,PLACE_NAME
                LD BC,#100
                CALL LOAD_FILE

                XOR A
                LD (GAME_EDITCHT),A
                DI 
                IM 2
                EI 
                POP HL,DE,BC,AF
                RET 


;сохраняем объекты карты
SAVE_OBJECT     PUSH AF,BC,DE,HL
                DI 
                IM 1
                EI 
                LD HL,MAP_OBJECTS
                LD DE,OBJECT_NAME
                LD BC,#300
                CALL SAVE_FILE
                XOR A
                LD (GAME_EDITCHO),A
                DI 
                IM 2
                EI 
                POP HL,DE,BC,AF
                RET 


;автовырезалка тайлов из экрана и
;заполнение образа
;вх  - A - номер с какого начинать
;      IX - адрес образа
;вых - A - номер следующего тайла

AUTOCUT_TILE    LD HL,0
                LD E,A
                LD BC,#100C
AUTOCUT_T1      LD A,E
                CALL CUT_TILE
                JP Z,AUTOCUT_T2
                LD A,E
                INC E
AUTOCUT_T2      LD D,A
                LD (IX),A
                INC IX
                INC H,H
                DJNZ AUTOCUT_T1
                LD H,0
                INC L,L
                LD B,#10
                DEC C
                JP NZ,AUTOCUT_T1
                LD A,E
                RET 


;вырезать тайл с экрана если он уникальный
;вх  - HL - координаты тайла
;      A - порядковый номер тайла
;вых - NZ - тайл уникальный
;      Z - тайл неуникальный
;      A - номер тайла

CUT_TILE        PUSH BC,DE,HL

                LD (CUT_TE+1),A

;сохраняем тайл в буфер
                PUSH HL
                SCRADR HL
                LD DE,CUT_TILEB
                LD B,16
CUT_T1          LD A,(HL)
                LD (DE),A
                INC L,DE
                LD A,(HL)
                LD (DE),A
                DEC L
                INC DE
                DOWN HL
                DJNZ CUT_T1
                POP HL
                ATTRADR HL
                LD A,(HL)
                LD (DE),A
                INC L,DE
                LD A,(HL)
                LD (DE),A
                LD BC,31
                ADD HL,BC
                INC DE
                LD A,(HL)
                LD (DE),A
                INC L,DE
                LD A,(HL)
                LD (DE),A

;сравниваем тайл в буфере с остальными
                LD HL,TILE_SPRITE+#100
                LD BC,0
CUT_T2          PUSH BC,HL
                LD DE,CUT_TILEB
                LD B,36
CUT_T3          LD A,(DE)
                CP (HL)
                JP NZ,CUT_T4
                INC DE,HL
                DJNZ CUT_T3
CUT_T4          POP HL,BC
                JP NZ,CUT_T5
                LD A,C
                LD (CUT_TE+1),A
                JP CUT_TE
CUT_T5          INC C
                PUSH BC
                LD BC,36
                ADD HL,BC
                POP BC
                DJNZ CUT_T2

;переносим тайл из буфера
                LD A,(CUT_TE+1)
                LD L,A
                LD H,0
                ADD HL,HL
                ADD HL,HL
                LD A,H
                ADD A,TILE_SPRITE/256+1
                LD D,A
                LD E,L
                ADD HL,HL
                ADD HL,HL
                ADD HL,HL
                ADD HL,DE
                EX DE,HL
                LD HL,CUT_TILEB
                LD BC,36
                LDIR 
                XOR A
                LD B,1
                CP B

CUT_TE          LD A,0
                POP HL,DE,BC
                RET 
CUT_TILEB       DS 36

;оптимизатор картинки, выделение
;ключевых спрайтов
OPTIMIZE        LD HL,#0000
                LD BC,#100C
OPTIMIZE_1      PUSH BC
                LD BC,#100C
                LD DE,#0000
OPTIMIZE_2      PUSH HL
                OR A
                SBC HL,DE
                POP HL
                JP Z,OPTIMIZE_3
                CALL COMPAIR_SPR
                JP NZ,OPTIMIZE_3
                PUSH BC,DE,HL
                EX DE,HL
                LD BC,#0202
                LD A,7
                CALL CLEAR_RECT
                POP HL,DE,BC
OPTIMIZE_3      INC D,D
                DJNZ OPTIMIZE_2
                LD D,0
                LD B,#10
                INC E,E
                DEC C
                JP NZ,OPTIMIZE_2
                POP BC
                INC H,H
                DJNZ OPTIMIZE_1
                LD H,0
                LD B,#10
                INC L,L
                DEC C
                JP NZ,OPTIMIZE_1
                RET 


;сравнение спрайтов
;вх  - HL - коорд 1-ого спрайта
;      DE - коорд 2-ого спрайта
;вых - флаг Z - стандартно

COMPAIR_SPR     PUSH BC,DE,HL

                LD (COMPAIR_SE+1),A
                LD (COMPAIR_S2+1),HL
                LD (COMPAIR_S2+4),DE
                SCRADR HL
                SCRADR DE
                LD B,16
COMPAIR_S1      LD A,(DE)
                CP (HL)
                JP NZ,COMPAIR_SE
                INC E,L
                LD A,(DE)
                CP (HL)
                JP NZ,COMPAIR_SE
                DEC E,L
                DOWN HL
                DOWN DE
                DJNZ COMPAIR_S1

COMPAIR_S2      LD HL,0
                LD DE,0
                ATTRADR HL
                ATTRADR DE
                LD B,2
COMPAIR_S3      LD A,(DE)
                CP (HL)
                JP NZ,COMPAIR_SE
                INC E,L
                LD A,(DE)
                CP (HL)
                JP NZ,COMPAIR_SE
                PUSH BC
                LD BC,31
                ADD HL,BC
                EX DE,HL
                ADD HL,BC
                EX DE,HL
                POP BC
                DJNZ COMPAIR_S3

COMPAIR_SE      LD A,0
                POP HL,DE,BC
                RET 


;Месседж-бокс
;вх  - HL - строка вопроса (max 16 симв.)
;вых - A=0 - нет, A=#FF - да

MSGBOX          PUSH BC,DE,HL

                LD A,7
                CALL RAM_SEL
                LD (MSGBOX_ADR),HL

                XOR A
                LD (CURSOR_TYPE),A
                LD L,A,E,0
                LD A,(ACTIVE_SCREEN)
                LD H,A
                XOR #80
                LD D,A
                LD BC,#1B00
                LDIR 

MSGBOX_1        LD HL,#090A
                LD BC,#0E05
                LD A,#0F
                CALL CLEAR_RECT
                LD A,#FF
                CALL DRW_FRAME
                LD HL,#0A0B
                SCRADR HL
                LD DE,(MSGBOX_ADR)
                CALL PRINT_STR
                LD HL,#0D0D
                SCRADR HL
                LD DE,MSGBOX_TXT
                CALL PRINT_STR
                INC L,L,L,L
                CALL PRINT_STR

;проверка кнопочек

                LD B,4
                LD DE,#170F
                LD HL,#0C0D
                LD A,#FF
                CALL BUTTON
                JR NZ,MSGBOX_E
                LD HL,#100D
                XOR A
                CALL BUTTON
                JR NZ,MSGBOX_E

                LD A,#FF
                LD (SCREEN_READY),A
                EI 
                HALT 
                EI 
                JP MSGBOX_1

MSGBOX_E        POP HL,DE,BC
                RET 
MSGBOX_TXT      DB "Да",0,"Нет",0
MSGBOX_ADR      DW 0


;обработчик кнопки
;вх  - HL - координаты в символах
;      B - длинна кнопки
;      D - значение атрибута подсветки
;      E - значение атрибута фона
;вых - Z - не нажата, NZ -нажата

BUTTON          PUSH BC,DE,HL
                LD (BUTTON_2+1),A
                LD C,1
                LD A,E
                CALL FILL_ATTR
                LD A,(INPUT_Y)
                RRCA 
                RRCA 
                RRCA 
                AND #1F
                CP L
                JR NZ,BUTTON_1
                LD A,(INPUT_X)
                RRCA 
                RRCA 
                RRCA 
                AND #1F
                CP H
                JR C,BUTTON_1
                SUB B
                CP H
                JR NC,BUTTON_1
                LD A,D
                CALL FILL_ATTR
                LD A,(INPUT_BUTTON)
                AND 1
                JR NZ,BUTTON_2
BUTTON_1        XOR A
BUTTON_2        LD A,0
                POP HL,DE,BC
                RET 


;обработчик счетчика SPINEDIT
;вх  - A - начальное значение сч-ка
;      B - максимальное значение
;      HL - координаты в символах
;      D - значение атрибута подсветки
;      E - значение атрибута фона
;вых - A - результат
;      NZ - было нажатие

SPINEDIT        PUSH BC,DE,HL

                LD C,B

                LD B,3
                CALL BUTTON
                JR Z,SPINEDIT_1
                CP C
                JR Z,SPINEDIT_1
                INC A
                CALL MAP_PAUSE
                INC B
                JR SPINEDIT_2
SPINEDIT_1      INC H,H,H,H,H
                CALL BUTTON
                JR Z,SPINEDIT_2
                OR A
                JR Z,SPINEDIT_2
                DEC A
                CALL MAP_PAUSE
                INC B

SPINEDIT_2      POP HL
                PUSH HL,AF
                INC H,H,H
                CALL PRINT_HEX
                POP AF

                POP HL,DE,BC
                RET 





GAME_EDITCHM    DB 0
GAME_EDITCHT    DB 0
GAME_EDITCHO    DB 0
GAME_EDITLB     DB 24,0," N карты:",0
                DB 24,1," +      -",0
                DB 24,2," N тайла:",0
                DB 24,3," +      -",0
                DB 24,4," N трека:",0
                DB 24,5," +      -",0
                DB 24,7," Карта",0
                DB 24,8," Картмоды",0
                DB 24,9," Тайлы",0
                DB 24,10," Скрипты",0
                DB 24,11," Объекты",0
                DB 24,19," XYm",0
                DB 24,20," XYc",0
                DB 24,22," Сохранить",0
                DB 24,23," Выход ",0,#FF

SAVE_ALLQ1      DB "Сохранить карту?",0
SAVE_ALLQ2      DB "Сохранить тайлы?",0
SAVE_ALLQ3      DB "Сохр. объекты?",0

MAP_EDITSZ      DW #0101
MAP_EDITXY      DW #0000
MAP_EDITSL      DB 0
MAP_EDITLB      DB 24,0," Образ 1",0
                DB 24,1," Образ 2",0
                DB 24,2," Образ 3",0
                DB 24,3," Образ 4",0
                DB 24,4," Режим",0
                DB 24,5," Свойства",0
                DB 24,19," XYm",0
                DB 24,20," XYc",0
                DB 24,22," Сохранить",0
                DB 24,23," Выход",0,#FF

TILE_EDITQ1     DB " Удалить тайлы?",0
TILE_EDITSN     DB "000     C"
TILE_EDITLB     DB 24,0," Всего:",0
                DB 24,2," Очистить",0
                DB 24,3," Тест",0
                DB 24,4," Создать",0
                DB 24,23," Выход ",0,#FF

TILE_IMAGENAME  DB "000     i"
TILE_IMAGEC     DB 0

TILE_PROPLB     DB 12,17,"Ок  Отмена",0,#FF

TRACE_NAME      DB "tracer  C"

SCRIPT_EDITHL   DW 0
SCRIPT_EDITM    DB 0
SCRIPT_EDITLB   DB 24,00," N скр.:",0
                DB 24,01," +      -",0
                DB 24,02," Тип скр.:",0
                DB 24,03," +      -",0
                DB 24,05," Коорд.:",0
                DB 24,06," XY1",0
                DB 24,07," XY2",0
                DB 24,08," Перейти",0
                DB 24,19," XYm",0
                DB 24,20," XYc",0
                DB 24,22," Сохранить",0
                DB 24,23," Выход",0,#FF
SCRIPT_PRTLLB   DB 24,11," N карты:",0
                DB 24,12," +      -",0
                DB 24,13," Коорд.:",0
                DB 24,14," XYt",0
                DB 24,15," Перейти",0,#FF
