;+++++++++++++++ MAINMODE.H ++++++++++++++
;основной игровой режим

                MAIN "GAME.H",#C0


MAIN_MODE       LD A,#FF
                LD (INIT_MAP_FIRST),A
                XOR A
                CALL INIT_MAP
                XOR A
                LD (INIT_MAP_FIRST),A

;инициируем полную перерисовку
                CALL REDRAW_ALL

;начало игрового цикла
MAIN_MODE10     XOR A
                LD (FRAME_COUNTER),A

;скролл карты
                LD A,(FRAME_CURRENT)
                LD B,A
                LD A,(MAP_SCRCNTR)
                SUB B
                JR NC,$+3
                XOR A
                LD (MAP_SCRCNTR),A
                CALL Z,MAP_SCROLL
                LD HL,(MAP_XY)
                CALL MAP_DRAW
                CALL OBJ_MANAGER

;работа с объектами

                LD IX,DISCRIPTORS
                LD A,OBJECT_MAX
                LD (MAIN_MODEOC+1),A
MAIN_MODE50     LD A,(IX+XCRD)
                OR (IX+YCRD)
                JP Z,MAIN_MODE190

                RAMPAGE 0
                CALL PUT_OBJECT
                LD A,(FRAME_CURRENT)
                ;LD A,1
                LD (ACTION_POINT),A

;проверка, есть ли новый приказ
MAIN_MODE51     LD A,(IX+CNTR)
                OR A
                JR NZ,MAIN_MODE52
                LD A,(IX+NEWORDER)
                OR A
                JR Z,MAIN_MODE52
                LD (IX+ORDER),A
                XOR A
                LD (IX+FAZE),A
                LD (IX+NEWORDER),A

;-------- проверка типов приказов --------
MAIN_MODE52     LD A,(IX+ORDER)
                OR A
                JP NZ,MAIN_MODE53
                XOR A
                LD (ACTION_POINT),A
                JP MAIN_MODE190

;-----------------------------------------
;приказ 1 (идти до координаты XY_TAG)
;-----------------------------------------
MAIN_MODE53     CP 1
                JP NZ,MAIN_MODE90

;-----------------------------------------
;фаза 0 - трассировка
;-----------------------------------------
                LD A,(IX+FAZE)
                OR A
                JP NZ,MAIN_MODE60

;трассировка
                CALL TRACE_MAP
                CP 1
                JR Z,MAIN_MODE55

;трассер не нашел маршрут
                LD A,9
                LD (CURSOR_TYPE),A
                LD A,20
                LD (CURSOR_CNTR),A

;ошибка трассера, конец движения
                LD A,(IX+TRACEADR)
                OR A
                JP Z,MAIN_MODE80

;продолжаем движение по старому маршруту
                LD (IX+FAZE),1
                LD A,(IX+XLTAG)
                LD (IX+XTAG),A
                LD A,(IX+YLTAG)
                LD (IX+YTAG),A
                JP MAIN_MODE60

;маршрут найден
MAIN_MODE55     LD HL,TRACE_TAB+18
                LD DE,MAIN_TRACE+18
                LD BC,204
MAIN_MODE56     DUP 16
                LDI
                EDUP
                INC L,L
                LD E,L
                DNZ C,MAIN_MODE56

                XOR A
                LD (IX+CNTR),A
                LD (ACTION_POINT),A
                LD (IX+FAZE),1
                LD A,(IX+XTAG)
                LD (IX+XLTAG),A
                LD A,(IX+YTAG)
                LD (IX+YLTAG),A
                JP MAIN_MODE190

;-----------------------------------------
;фаза 1 - разворот
;-----------------------------------------
MAIN_MODE60     LD A,(IX+FAZE)
                CP 1
                JP NZ,MAIN_MODE70

;проверка на завершение трасы
                LD H,'MAIN_TRACE
                LD L,(IX+TRACEADR)
                LD A,(HL)
                DUP 4
                RRCA
                EDUP
                AND #0F
                CP #0F
                JP Z,MAIN_MODE80
;разворот
                DEC A
                SUB 4
                AND 7
                CALL TURN_DIRECT
                JP Z,MAIN_MODE190
                LD (IX+FAZE),2
                LD A,(ACTION_POINT)
                OR A
                JP Z,MAIN_MODE190

;-----------------------------------------
;фаза 2 - проходим клетку
;-----------------------------------------
MAIN_MODE70     LD A,(IX+FAZE)
                CP 2
                JP NZ,MAIN_MODE80
                LD A,(IX+CNTR)
                OR A
                JR NZ,MAIN_MODE75

;проверяем на наличие других объектов
                LD A,(IX+DIRECT)
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                CALL SEACH_DIRECT
                JR NZ,MAIN_MODE72
                LD (IX+FAZE),0
                LD A,(IX+DIRECT)
                LD (IX+SPRT),A
                JP MAIN_MODE190

MAIN_MODE72     LD A,(IX+DIRECT)
                LD L,(IX+TRACEADR)
                CALL GET_TRACE
                LD (IX+TRACEADR),L

MAIN_MODE75     CALL GOTO_DIRECT
                JP Z,MAIN_MODE190

                LD (IX+CNTR),0
                LD (IX+FAZE),1
                JP MAIN_MODE190

;-----------------------------------------
;фаза 3 - завершение движения
;-----------------------------------------
MAIN_MODE80     LD A,(IX+BASEORDER)
                LD (IX+ORDER),A
                XOR A
                LD (IX+FAZE),A
                LD (IX+CNTR),A
                LD (IX+TRACEADR),A
                LD (ACTION_POINT),A
                LD A,(IX+XCRD)
                LD (IX+XTAG),A
                LD A,(IX+YCRD)
                LD (IX+YTAG),A
                LD A,(IX+DIRECT)
                LD (IX+SPRT),A
                JP MAIN_MODE190


;-----------------------------------------
;приказ 2 (стрелять по объекту NUMINT)
;-----------------------------------------
MAIN_MODE90     CP 2
                JP NZ,MAIN_MODE100

;-----------------------------------------
;фаза 0 - разворот
;-----------------------------------------
                LD A,(IX+FAZE)
                OR A
                JP NZ,MAIN_MODE93

;находим объект по номеру
                LD A,(IX+NUMINT)
                CALL GET_DISCRIPTOR

;находим направление для стрельбы
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                LD D,(IY+XCRD)
                LD E,(IY+YCRD)
                CALL FIND_DIRECT
                CALL TURN_DIRECT
                JP Z,MAIN_MODE190
                LD (IX+CNTR),0
                LD (IX+FAZE),1
                LD A,(ACTION_POINT)
                OR A
                JP Z,MAIN_MODE190

;-----------------------------------------
;фаза 1 - выстрел
;-----------------------------------------
MAIN_MODE93     LD A,(IX+CNTR)
                OR A
                JR NZ,MAIN_MODE98

;проверка кол-ва патронов
                LD A,(IX+BULLET)
                OR A
                JR NZ,MAIN_MODE94

;патронов нет
                XOR A
                LD (IX+ORDER),A
                LD (IX+FAZE),A
                LD (IX+CNTR),A
                LD (ACTION_POINT),A
                JP MAIN_MODE190

MAIN_MODE94     DEC (IX+BULLET)
                LD (IX+CNTR),10
                CALL FIRE_LIGHT
                LD A,30
                CALL INIT_SFX
                LD A,(IX+DIRECT)
                ADD A,40
                LD (IX+SPRT),A

;наносим урон вражескому объекту
                RAMPAGE 0
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                LD A,(IX+DIRECT)
                PUSH IY
                CALL SEACH_DIRECT
                POP IY
                JR NZ,MAIN_MODE95
                LD A,(IX+ENEMY)
                CP (IY+ENEMY)
                JR NZ,MAIN_MODE96
MAIN_MODE95     CALL TRACE_SHOT
                JP NZ,MAIN_MODE190
MAIN_MODE96     LD (IY+NEWORDER),3
                LD A,(IX+HIT)
                ADD A,(IY+DAMAGE)
                JR NC,MAIN_MODE97
                LD A,255
MAIN_MODE97     LD (IY+DAMAGE),A
                JP MAIN_MODE190

;пауза после выстрела
MAIN_MODE98     LD A,(ACTION_POINT)
                DEC A
                LD (ACTION_POINT),A
                DEC (IX+CNTR)
                JP NZ,MAIN_MODE190
                XOR A
                LD (IX+CNTR),A
                LD (IX+NEWORDER),A
                LD A,(IX+BASEORDER)
                LD (IX+ORDER),A
                LD A,(IX+DIRECT)
                LD (IX+SPRT),A
                JP MAIN_MODE190

;-----------------------------------------
;приказ 3 (объект получает урон)
;-----------------------------------------
MAIN_MODE100    CP 3
                JP NZ,MAIN_MODE110
                LD A,(IX+CNTR)
                OR A
                JR NZ,MAIN_MODE101
                LD (IX+CNTR),5
                LD A,(IX+DIRECT)
                ADD A,40
                LD (IX+SPRT),A
                JP MAIN_MODE190

MAIN_MODE101    LD A,(ACTION_POINT)
                DEC A
                LD (ACTION_POINT),A
                DEC (IX+CNTR)
                JP NZ,MAIN_MODE190

                LD A,(IX+LIFE)
                SUB (IX+DAMAGE)
                LD (IX+LIFE),A
                LD (IX+DAMAGE),0
                JR C,MAIN_MODE102
                JR Z,MAIN_MODE102
                LD A,(IX+BASEORDER)
                LD (IX+ORDER),A
                LD A,(IX+DIRECT)
                LD (IX+SPRT),A
                JP MAIN_MODE190

;смерть объекта
MAIN_MODE102    LD (IX+LIFE),0
                LD A,(IX+DIRECT)
                ADD A,56
                LD (IX+SPRT),A
                LD (IX+ORDER),5
                JP MAIN_MODE190

;-----------------------------------------
;приказ 4 (рандом для животных)
;-----------------------------------------
MAIN_MODE110    CP 4
                JP NZ,MAIN_MODE140

;-----------------------------------------
;фаза 0 - определяем действие
;-----------------------------------------
                LD A,(IX+FAZE)
                OR A
                JP NZ,MAIN_MODE120

;проверяем на ближайших врагов
                LD (ACTION_POINT),A
                CALL TEST_ENEMY
                JR NZ,MAIN_MODE111
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                LD D,(IY+XCRD)
                LD E,(IY+YCRD)
                CALL TEST_WAY
                JR NZ,MAIN_MODE111

;идем к врагу
                LD A,(IY+XCRD)
                LD (IX+XTAG),A
                LD A,(IY+YCRD)
                LD (IX+YTAG),A
                LD (IX+FAZE),1
                LD (IX+CNTR),0
                JP MAIN_MODE190

;находим случайную координату
MAIN_MODE111    CALL RND
                AND 15
                SUB 7
                ADD A,(IX+XLTAG)
                CP 128
                JP NC,MAIN_MODE190
                LD H,A
                CALL RND
                AND 15
                SUB 7
                ADD A,(IX+YLTAG)
                CP 124
                JP NC,MAIN_MODE190
                LD L,A
                CALL TEST_CORD
                JP NZ,MAIN_MODE190
                LD (IX+XTAG),H
                LD (IX+YTAG),L
                LD (IX+FAZE),1
                LD (IX+CNTR),0
                JP MAIN_MODE190

;-----------------------------------------
;фаза 1 - разворот на цель
;-----------------------------------------
MAIN_MODE120    LD A,(IX+FAZE)
                CP 1
                JP NZ,MAIN_MODE125

                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                LD D,(IX+XTAG)
                LD E,(IX+YTAG)

;проверяем на достижение цели
                PUSH HL
                OR A
                SBC HL,DE
                POP HL
                JR Z,MAIN_MODE126

                CALL FIND_DIRECT

;проверка на препятствия
                CALL TEST_DIRECT
                JR Z,MAIN_MODE121
                INC A
                AND 7
                CALL TEST_DIRECT
                JR Z,MAIN_MODE121
                SUB 2
                AND 7
                CALL TEST_DIRECT
                JR NZ,MAIN_MODE126

MAIN_MODE121    CALL TURN_DIRECT
                JP Z,MAIN_MODE190
                LD (IX+FAZE),2
                LD A,(ACTION_POINT)
                OR A
                JP Z,MAIN_MODE190

;-----------------------------------------
;фаза 2 - проходим клетку
;-----------------------------------------
MAIN_MODE125    LD A,(IX+FAZE)
                CP 2
                JP NZ,MAIN_MODE130
                LD A,(IX+CNTR)
                OR A
                JR NZ,MAIN_MODE129

;проверяем на наличие других объектов
                LD A,(IX+DIRECT)
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                CALL SEACH_DIRECT
                JR NZ,MAIN_MODE129

;инициализируем атаку
                LD A,(IY+ENEMY)
                CP (IX+ENEMY)
                JR NZ,MAIN_MODE127

;случайная атака "своего"
                CALL RND
                AND 7
                JR Z,MAIN_MODE127

;определение действия
MAIN_MODE126    XOR A
                LD (IX+FAZE),A
                LD (IX+CNTR),A
                LD (ACTION_POINT),A
                JP MAIN_MODE190

;атака
MAIN_MODE127    LD A,(IY+NUM)
                LD (IX+NUMINT),A
                LD A,3
                LD (IX+FAZE),A
                JP MAIN_MODE130

;идем через клетку
MAIN_MODE129    CALL GOTO_DIRECT
                JP Z,MAIN_MODE190
                LD (IX+CNTR),0
                LD (IX+FAZE),1
                JP MAIN_MODE190

;-----------------------------------------
;фаза 3 - атака
;-----------------------------------------
MAIN_MODE130    CP 3
                JP NZ,MAIN_MODE190
                LD A,(IX+CNTR)
                OR A
                JR NZ,MAIN_MODE131
                LD (IX+CNTR),12
MAIN_MODE131    LD A,(IX+CNTR)
                LD C,0
                CP 4
                JR C,MAIN_MODE132
                LD C,6
                CP 8
                JR C,MAIN_MODE132
                LD C,5
MAIN_MODE132    LD A,C
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,(IX+DIRECT)
                LD (IX+SPRT),A
                LD A,(ACTION_POINT)
                DEC A
                LD (ACTION_POINT),A
                DEC (IX+CNTR)
                JP NZ,MAIN_MODE190

                LD (IX+FAZE),0
                LD A,(IX+NUMINT)
                CALL GET_DISCRIPTOR
                LD (IY+NEWORDER),3
                LD A,(IY+ENEMY)
                CP (IX+ENEMY)
                JP Z,MAIN_MODE190

;наносим врагу урон
                LD A,(IX+HIT)
                ADD A,(IY+DAMAGE)
                JR NC,MAIN_MODE133
                LD A,255
MAIN_MODE133    LD (IY+DAMAGE),A
                JP MAIN_MODE190


;-----------------------------------------
;приказ 5 (объект умер)
;-----------------------------------------
MAIN_MODE140    CP 5
                JP NZ,MAIN_MODE190

                XOR A
                LD (ACTION_POINT),A
                JP MAIN_MODE190


;проверка остатка ACTION_POINT
MAIN_MODE190    LD A,(ACTION_POINT)
                OR A
                JP NZ,MAIN_MODE51

                RAMPAGE 0
                CALL REST_OBJECT

                RAMPAGE 7

                LD DE,DISCR_LEN
                ADD IX,DE
MAIN_MODEOC     LD A,0
                DEC A
                LD (MAIN_MODEOC+1),A
                JP NZ,MAIN_MODE50
                CALL SHOW_STATIC
                CALL SHOW_PLACE
                CALL SHOW_OBJECT
                CALL SHOW_CLUSTER

;приказы для главного героя
MAIN_MODE200    LD IX,DISCRIPTORS

;проверка глав. героя на видимость
                LD HL,(MAP_XY)
                INC L
                LD A,(IX+XCRD)
                CP H
                JR C,MAIN_MODE204
                LD A,H
                ADD A,14
                CP (IX+XCRD)
                JR C,MAIN_MODE204
                LD A,(IX+YCRD)
                CP L
                JR C,MAIN_MODE204
                LD A,L
                ADD A,10
                CP (IX+YCRD)
                JR NC,MAIN_MODE205

MAIN_MODE204    LD A,(IX+ORDER)
                OR A
                JR NZ,MAIN_MODE205
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                CALL CENTER_MOVE
                CALL REDRAW_ALL

;проверяем, жив-ли герой
MAIN_MODE205    LD A,(IX+LIFE)
                OR A
                RET Z

                LD A,(INPUT_KEY)
                AND 1
                JP Z,MAIN_MODE210
                LD HL,(INPUT_Y)

;корректировка коорд. курсора
                ;LD A,H
                ;SUB 8
                ;LD H,A
                ;JR NC,$+4
                ;LD H,0

                RAMPAGE 0

;проверка верхнего и правого отступа
                LD A,L
                DUP 4
                RRCA
                EDUP
                AND #0F
                JR NZ,$+3
                INC A
                LD L,A

                LD A,H
                DUP 4
                RRCA
                EDUP
                AND #0F
                CP 15
                JR NZ,$+3
                DEC A
                LD H,A

                LD DE,(MAP_XY)
                ADD HL,DE
                CALL TEST_CORD
                JR Z,MAIN_MODE202
                DEC H
                CALL TEST_CORD
                JR Z,MAIN_MODE202
                INC H

;запрещающий курсор
                LD A,9
                LD (CURSOR_TYPE),A
                LD A,20
                LD (CURSOR_CNTR),A
                JR MAIN_MODE210

MAIN_MODE202    LD A,(IX+XCRD)
                CP H
                JR NZ,MAIN_MODE203
                LD A,(IX+YCRD)
                CP L
                JP Z,MAIN_MODE210
;тип действия
MAIN_MODE203    CALL SEARCH_OBJECT
                JR NZ,MAIN_MODE212
                LD A,(IX+NUM)
                CP (IY+NUM)
                JR Z,MAIN_MODE212
                JR MAIN_MODE211


;идти к координате
MAIN_MODE212    LD (IX+XTAG),H
                LD (IX+YTAG),L
                LD (IX+NEWORDER),1
                LD (PLACE_XY),HL
                LD A,15
                LD (PLACE_CNTR),A
                JR MAIN_MODE220

;стрелять по координате
MAIN_MODE210    LD A,(INPUT_BUTTON)
                AND 1
                JR Z,MAIN_MODE220
                CALL SEARCH_OBJECT
                JR NZ,MAIN_MODE220
MAIN_MODE211    LD A,(IY+ENEMY)
                OR A
                JR Z,MAIN_MODE220
                LD (IX+NEWORDER),2
                LD A,(IY+NUM)
                LD (IX+NUMINT),A

;проверка на вхождение в скрипт
MAIN_MODE220    RAMPAGE 0
                LD HL,MAP_PROPERTY+8
                LD B,15
MAIN_MODE221    PUSH HL
                LD A,(HL)
                INC L
                OR (HL)
                JR Z,MAIN_MODE222
                DEC L
                LD A,(IX+XCRD)
                CP (HL)
                JR C,MAIN_MODE222
                INC L
                LD A,(IX+YCRD)
                CP (HL)
                JR C,MAIN_MODE222
                INC L
                LD A,(HL)
                CP (IX+XCRD)
                JR C,MAIN_MODE222
                INC L
                LD A,(HL)
                CP (IX+YCRD)
                JR NC,MAIN_MODE223
MAIN_MODE222    POP HL
                LD A,8
                ADD A,L
                LD L,A
                DJNZ MAIN_MODE221
                JR MAIN_MODE230
;тип скрипта
MAIN_MODE223    INC SP,SP,L
                LD A,(HL)
                OR A
                JR NZ,MAIN_MODE230
;портал
                INC L
                LD B,(HL)
                INC L
                LD D,(HL)
                INC L
                LD E,(HL)
                EX DE,HL
                LD (IX+XCRD),H
                LD (IX+YCRD),L
                LD (IX+XTAG),H
                LD (IX+YTAG),L
                LD (IX+ORDER),0
                LD (IX+CNTR),0
                LD (IX+XSM),0
                LD (IX+YSM),0
                LD A,(IX+DIRECT)
                LD (IX+SPRT),A
                PUSH HL
                LD A,B
                CALL INIT_MAP
                POP HL
                CALL CENTER_MAP
                LD (MAP_XY),HL
                JR MAIN_MODE230







;завершение игрового такта
MAIN_MODE230    XOR A
                LD (INPUT_KEY),A

                RAMPAGE 7
                CALL SHOW_STATISTIC
;вывод FPS
                LD A,(FRAME_CURRENT)
                LD L,A,H,50
                CALL DIV_BYTE
                LD A,B
                PUSH AF
                LD HL,#1A17
                LD BC,#0601
                LD A,7
                CALL CLEAR_RECT
                SCRADR HL
                POP AF
                PUSH HL
                CALL PRINT_DEC
                POP HL
                INC L,L,L
                LD DE,FPS_TEXT
                CALL PRINT_STR

                ;EI
                ;DUP 5
                ;HALT
                ;EDUP

                CALL SHOW_SCREEN
                LD A,(FRAME_COUNTER)
                LD (FRAME_CURRENT),A

                LD A,(INPUT_KEY)
                AND 2
                JP Z,MAIN_MODE10
                RET
FPS_TEXT        DB "fps",0


;проверка на врагов в радиусе 12 клеток
;вх  - IX - описатель объекта
;вых - NZ - нет врагов, Z - есть
;      IY - описатель врага

TEST_ENEMY      PUSH BC,DE,HL

                LD C,A
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)

                LD IY,DISCRIPTORS
                LD DE,DISCR_LEN
                LD B,OBJECT_MAX
TEST_ENEMY3     LD A,(IY+NUM)
                CP (IX+NUM)
                JR Z,TEST_ENEMY4
                LD A,(IY+ENEMY)
                CP (IX+ENEMY)
                JR Z,TEST_ENEMY4
                LD A,(IY+LIFE)
                OR A
                JR Z,TEST_ENEMY4
                LD A,(IY+XCRD)
                OR (IY+YCRD)
                JR Z,TEST_ENEMY4
                LD A,(IY+XCRD)
                SUB H
                JR NC,$+4
                NEG
                CP 13
                JR NC,TEST_ENEMY4
                LD A,(IY+YCRD)
                SUB L
                JR NC,$+4
                NEG
                CP 13
                JR NC,TEST_ENEMY4
                XOR A
                JR TEST_ENEMY5

TEST_ENEMY4     ADD IY,DE
                DJNZ TEST_ENEMY3
                LD A,1
                OR A

TEST_ENEMY5     LD A,C
                POP HL,DE,BC
                RET


;менеджер объектов карты
OBJ_MANAGER

;распаковка объектов
                LD HL,MAP_OBJECTS
                LD BC,(MAP_XY)
                LD A,B
                SUB 1
                ADC A,0
                LD B,A

;проверяем возможность создания
OBJ_MAN10       PUSH BC,HL

                LD A,(HL)
                OR A
                JP Z,OBJ_MAN40
                LD E,A
                INC H
                LD D,(HL)
                DEC H

;есть-ли объект по этим координатам
                EX DE,HL
                ;CALL SEARCH_CRD
                ;JP Z,OBJ_MAN40

;проверка на растояние от глав. героя
                LD A,(DISCRIPTORS+XCRD)
                SUB H
                JP NC,$+5
                NEG
                CP 17
                JP NC,OBJ_MAN40
                LD A,(DISCRIPTORS+YCRD)
                SUB L
                JP NC,$+5
                NEG
                CP 13
                JP NC,OBJ_MAN40

;проверка на край видимости окна карты
                LD A,H
                CP B
                JP C,OBJ_MAN20
                LD A,B
                ADD A,16
                CP H
                JP C,OBJ_MAN20
                LD A,L
                CP C
                JP C,OBJ_MAN20
                LD A,C
                ADD A,12
                CP L
                JP NC,OBJ_MAN40

;ищем свободный дискриптор
OBJ_MAN20       LD C,E
                EX DE,HL
                LD HL,DISCRIPTORS+1+DISCR_LEN
                LD B,OBJECT_MAX-1
OBJ_MAN21       LD A,(HL)
                INC L
                OR (HL)
                JP Z,OBJ_MAN30
                LD A,L
                ADD A,DISCR_LEN-1
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                DJNZ OBJ_MAN21
                JP OBJ_MAN40

;создаем объект
OBJ_MAN30       DEC L,L
                PUSH HL
                POP IX
                EX DE,HL
                LD A,OBJECT_MAX
                SUB B
                LD D,A
                LD B,'MAP_OBJECTS
                RAMPAGE 0
                LD (BC),A
                INC B,B
                LD A,(BC)
                ADD A,#81
                LD C,A
                LD B,'MAP_PROPERTY
                LD A,(BC)

;тут будет выбор типа объекта
                LD (IX+NUM),D       ;0
                LD (IX+XCRD),H      ;1
                LD (IX+YCRD),L      ;2
                LD (IX+XSM),0       ;3
                LD (IX+YSM),0       ;4
                LD (IX+TYPE),A      ;5
                LD (IX+SPRT),0      ;6
                LD (IX+DIRECT),0    ;7
                LD (IX+ORDER),4     ;8
                LD (IX+FAZE),0      ;9
                LD (IX+CNTR),0      ;10
                LD (IX+XTAG),H      ;11
                LD (IX+YTAG),L      ;12
                LD (IX+NEWORDER),0  ;13
                LD (IX+BASEORDER),4 ;14
                LD (IX+TRACEADR),0  ;15
                LD (IX+XLTAG),H     ;16
                LD (IX+YLTAG),L     ;17
                LD (IX+NUMINT),0    ;18
                LD (IX+ENEMY),1     ;19
                LD (IX+LIFE),48     ;20
                LD (IX+HIT),8       ;21
                LD (IX+DAMAGE),0    ;22

OBJ_MAN40       POP HL,BC
                INC L
                JP NZ,OBJ_MAN10

;упаковка объектов
                LD A,(DISCRIPTORS+XCRD)
                LD D,A
                LD A,(DISCRIPTORS+YCRD)
                LD E,A
                LD HL,DISCRIPTORS+1+DISCR_LEN
                LD B,OBJECT_MAX-1

;ищем сильно удаленные объекты
OBJ_MAN50       PUSH DE,HL
                LD A,(HL);        XCRD
                LD C,A
                INC L
                OR (HL);          YCRD
                JP Z,OBJ_MAN80
                LD A,(HL);        YCRD
                SUB E
                JP NC,$+5
                NEG
                CP 15
                JP NC,OBJ_MAN51
                LD A,C;           XCRD
                SUB D
                JP NC,$+5
                NEG
                CP 19
                JP C,OBJ_MAN80

OBJ_MAN51       LD (OBJ_MAN61+1),HL
                INC L
                LD A,(HL);        LIFE
                OR A
                JR Z,OBJ_MAN70

;ищем свободный слот для объекта
                LD HL,MAP_OBJECTS
                XOR A
OBJ_MAN60       CP (HL)
                JR Z,OBJ_MAN61
                INC L
                JP NZ,OBJ_MAN60
                JP OBJ_MAN70

;упаковываем объект
OBJ_MAN61       LD DE,0
                EX DE,HL
                LD A,(HL);        YCRD
                OR A
                JR NZ,$+3
                INC A
                LD (DE),A
                INC D
                DEC L
                LD A,(HL);        XCRD
                LD (DE),A
                INC D

;поиск номера спрайтсета
                INC L,L,L
                LD C,(HL);        TYPE
                RAMPAGE 0
                PUSH BC,HL
                LD HL,MAP_PROPERTY+1
                LD B,2
                LD A,C
OBJ_MAN62       CP (HL)
                JR Z,OBJ_MAN63
                INC L
                DJNZ OBJ_MAN62
OBJ_MAN63       LD A,2
                SUB B
                LD (DE),A
                POP HL,BC

;освобождаем объект
OBJ_MAN70       LD HL,(OBJ_MAN61+1)
                XOR A
                LD (HL),A;        YCRD
                DEC L
                LD (HL),A;        XCRD

OBJ_MAN80       POP HL
                LD DE,DISCR_LEN
                ADD HL,DE
                POP DE
                DJNZ OBJ_MAN50
                RET


;заполнение карты родственными объектами
;вх  - IX - описатель опорного объекта
;вых - нет

PUT_OBJECT      PUSH AF,BC,DE,HL,IX

                LD A,(IX+NUM)
                LD (PUT_OBJN+1),A
                LD A,(IX+ENEMY)
                LD (PUT_OBJE+1),A
                LD HL,MAP_BUFFER
                LD B,OBJECT_MAX
                LD IX,DISCRIPTORS
PUT_OBJ1        LD A,(IX+NUM)
PUT_OBJN        CP 0
                JR Z,PUT_OBJ2
                LD A,(IX+ENEMY)
PUT_OBJE        CP 0
                JR NZ,PUT_OBJ2
                LD A,(IX+LIFE)
                OR A
                JR Z,PUT_OBJ2
                LD D,(IX+XCRD)
                LD E,(IX+YCRD)
                LD A,D
                OR E
                JR Z,PUT_OBJ2

                GETMAPADR DEC
                LD (HL),E
                INC L
                LD (HL),D
                INC L
                LD A,(DE)
                LD (HL),A
                INC L
                LD A,#FF
                LD (DE),A

PUT_OBJ2        LD DE,DISCR_LEN
                ADD IX,DE
                DJNZ PUT_OBJ1

                LD A,L
                LD (REST_OBJL+1),A

                POP IX,HL,DE,BC,AF
                RET

;восстановление карты
;вх  - нет
;вых - нет

REST_OBJECT     PUSH AF,BC,DE,HL

                LD H,'MAP_BUFFER
REST_OBJL       LD L,0
REST_OBJ1       DEC L
                LD A,L
                CP .MAP_BUFFER-1
                JR Z,REST_OBJ2
                LD A,(HL)
                DEC L
                LD D,(HL)
                DEC L
                LD E,(HL)
                LD (DE),A
                JR REST_OBJ1

REST_OBJ2       POP HL,DE,BC,AF
                RET

;разворот по направлению
;вх  - IX - описатель объекта
;      A - направление
;вых - NZ - завершен, Z - незавершен

TURN_DIRECT     PUSH BC,DE,HL
                LD C,A

TURN_DIR1       LD A,(IX+CNTR)
                OR A
                JR NZ,TURN_DIR4

                LD A,C
                SUB (IX+DIRECT)
                JR Z,TURN_DIR5

;разворот на 45' по направлению
                AND 7
                CP 4
                JP NC,TURN_DIR2
                LD A,(IX+DIRECT)
                INC A
                JP TURN_DIR3
TURN_DIR2       LD A,(IX+DIRECT)
                DEC A
TURN_DIR3       AND 7
                LD (IX+DIRECT),A
                LD (IX+CNTR),4

;отсчет
TURN_DIR4       DEC (IX+CNTR)
                LD A,(ACTION_POINT)
                DEC A
                LD (ACTION_POINT),A
                LD A,1

TURN_DIR5       DEC A
                LD A,(IX+DIRECT)
                LD (IX+SPRT),A
                LD A,C
                POP HL,DE,BC
                RET
