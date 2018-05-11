;++++++++++++++++ OBJECTS.H ++++++++++++++
;подпрограммы для работы с объектами

                MAIN "GAME.H",#C0

;найти описатель объекта по номеру
;вх  - A - номер
;вых - IY - описатель

GET_DISCRIPTOR  PUSH AF,BC,HL
                RRCA
                RRCA
                RRCA
                LD B,A
                AND #1F
                ADD A,'DISCRIPTORS
                LD H,A
                LD A,B
                AND #E0
                LD L,A
                PUSH HL
                POP IY
                POP HL,BC,AF
                RET


;проверить направление на объект
;вх  - HL - координаты на карте
;      A - направление
;вых - NZ - объект ненайден, Z - найден
;      IY - описатель найденого объекта

SEACH_DIRECT    PUSH BC,DE,HL
                LD C,A
                CALL GET_CORD
                LD IY,DISCRIPTORS
                LD DE,DISCR_LEN
                LD B,OBJECT_MAX
SEACH_DIR1      LD A,(IX+NUM)
                CP (IY+NUM)
                JR Z,SEACH_DIR2
                LD A,(IY+LIFE)
                OR A
                JR Z,SEACH_DIR2
                LD A,(IY+XCRD)
                CP H
                JR NZ,SEACH_DIR2
                LD A,(IY+YCRD)
                CP L
                JR Z,SEACH_DIRE
SEACH_DIR2      ADD IY,DE
                DJNZ SEACH_DIR1
                LD A,1
                CP B
SEACH_DIRE      LD A,C
                POP HL,DE,BC
                RET


;проверить координаты на объект
;вх  - HL - координаты на карте
;вых - NZ - объект ненайден, Z - найден
;      IY - описатель найденого объекта

SEARCH_CRD      PUSH BC,DE,HL

                LD (SEARCH_CRDE+1),A
                EX DE,HL
                LD HL,DISCRIPTORS
                LD C,(IX+NUM)
                LD B,OBJECT_MAX

SEARCH_CRD1     PUSH HL
                LD A,(HL);        NUM
                CP C
                JR Z,SEARCH_CRD3
                INC L
                LD A,(HL) ;       XCRD
                CP D
                JR Z,SEARCH_CRD2
                INC A
                CP D
                JR NZ,SEARCH_CRD3
SEARCH_CRD2     INC L
                LD A,(HL) ;       YCDR
                CP E
                JR NZ,SEARCH_CRD3
                INC L
                LD A,(HL);        LIFE
                OR A
                JR Z,SEARCH_CRD3
;нашли объект
                POP IY
                XOR A
                JP SEARCH_CRDE

;продолжение поиска
SEARCH_CRD3     POP HL
                LD A,L
                ADD A,DISCR_LEN
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                DJNZ SEARCH_CRD1
;ненашли объект
                CP B

SEARCH_CRDE     LD A,0
                POP HL,DE,BC
                RET


;найти направление до цели
;вх  - HL - текущие координаты
;      DE - координаты цели
;вых - A - направление

FIND_DIRECT     LD A,L
                CP E
                JP Z,FIND_DIR18
                JR C,FIND_DIR9
                LD A,H
                CP D
                JR NZ,FIND_DIR1
                XOR A
                RET
FIND_DIR1       JR NC,FIND_DIR5

;правая верхняя четверть
                PUSH BC,HL
                LD A,D
                SUB H
                ADD A,A
                ADD A,A
                LD H,A
                LD A,L
                SUB E
                LD L,A
                CALL DIV_BYTE
                LD A,B
                POP HL,BC
                CP 2
                JR NC,FIND_DIR2
                XOR A
                RET
FIND_DIR2       CP 4
                JR NC,FIND_DIR3
                LD A,1
                RET
FIND_DIR3       CP 8
                JR C,FIND_DIR4
                LD A,2
                RET
FIND_DIR4       LD A,1
                RET

;левая верхняя четверть
FIND_DIR5       PUSH BC,HL
                LD A,H
                SUB D
                ADD A,A
                ADD A,A
                LD H,A
                LD A,L
                SUB E
                LD L,A
                CALL DIV_BYTE
                LD A,B
                POP HL,BC
                CP 2
                JR NC,FIND_DIR6
                XOR A
                RET
FIND_DIR6       CP 4
                JR NC,FIND_DIR7
                LD A,7
                RET
FIND_DIR7       CP 8
                JR C,FIND_DIR8
                LD A,6
                RET
FIND_DIR8       LD A,7
                RET

FIND_DIR9       LD A,H
                CP D
                JR NZ,FIND_DIR10
                LD A,4
                RET
FIND_DIR10      JR NC,FIND_DIR14

;правая нижняя четверть
                PUSH BC,HL
                LD A,D
                SUB H
                ADD A,A
                ADD A,A
                LD H,A
                LD A,E
                SUB L
                LD L,A
                CALL DIV_BYTE
                LD A,B
                POP HL,BC
                CP 2
                JR NC,FIND_DIR11
                LD A,4
                RET
FIND_DIR11      CP 4
                JR NC,FIND_DIR12
                LD A,3
                RET
FIND_DIR12      CP 8
                JR C,FIND_DIR13
                LD A,2
                RET
FIND_DIR13      LD A,3
                RET

;левая нижняя четверть
FIND_DIR14      PUSH BC,HL
                LD A,H
                SUB D
                ADD A,A
                ADD A,A
                LD H,A
                LD A,E
                SUB L
                LD L,A
                CALL DIV_BYTE
                LD A,B
                POP HL,BC
                CP 2
                JR NC,FIND_DIR15
                LD A,4
                RET
FIND_DIR15      CP 4
                JR NC,FIND_DIR16
                LD A,5
                RET
FIND_DIR16      CP 8
                JR C,FIND_DIR17
                LD A,6
                RET
FIND_DIR17      LD A,5
                RET


FIND_DIR18      LD A,H
                CP D
                JR NC,FIND_DIR19
                LD A,2
                RET
FIND_DIR19      LD A,6
                RET


;проверить проходимость по направлению
;вх  - HL - начальные координаты
;      A - направление
;вых - Z - можно пройти, NZ - нельзя

TEST_DIRECT     PUSH BC,DE,HL

                LD (TEST_DIRE+1),A
                RLCA
                RLCA
                RLCA
                OR #47
                LD (TEST_DIROUT+1),A
                LD (TEST_DIRIN+1),A
                LD (TEST_DIRXY+1),HL

;проверка на выход из тайла
                GETMAPADR HLC
                LD B,2
TEST_DIR1       LD D,'TILE_TYPE
                LD E,(HL)
                LD A,(DE)
                LD E,A
                LD D,'TAB_TILEPASS
                LD A,(DE)
TEST_DIROUT     BIT 0,A
                JR NZ,TEST_DIRE
                INC L
                DJNZ TEST_DIR1

;проверка на выход за пределы карты
TEST_DIRXY      LD HL,0
                LD A,(TEST_DIRE+1)
                CALL GET_CORD
                LD A,H
                CP 128
                JR NC,TEST_DIRNZ
                LD A,L
                CP 124
                JR NC,TEST_DIRNZ

;проверка на вход в тайл
                CALL TEST_CORD
                JR NZ,TEST_DIRE

                GETMAPADR HLC
                LD C,0
                LD B,2
TEST_DIR2       LD D,'TILE_TYPE
                LD E,(HL)
                LD A,(DE)
                CP 2
                JR NZ,TEST_DIR3
                INC C
TEST_DIR3       ADD A,16
                LD E,A
                LD D,'TAB_TILEPASS
                LD A,(DE)
TEST_DIRIN      BIT 0,A
                JR NZ,TEST_DIRE
                INC L
                DJNZ TEST_DIR2
                BIT 0,C
                JR TEST_DIRE

TEST_DIRNZ      XOR A
                CP D
TEST_DIRE       LD A,0
                POP HL,DE,BC
                RET


;новые координаты из текущих по направл.
;вх  - HL - текущие координаты
;      A - направление
;вых - HL - новые координаты

GET_CORD        AND 7
                RLCA
                RLCA
                LD (GET_CORD1+1),A
                RRCA
                RRCA
GET_CORD1       JR $
;0
                DEC L
                RET
                NOP
                NOP
;1
                DEC L
                INC H
                RET
                NOP
;2
                INC H
                RET
                NOP
                NOP
;3
                INC L
                INC H
                RET
                NOP
;4
                INC L
                RET
                NOP
                NOP
;5
                INC L
                DEC H
                RET
                NOP
;6
                DEC H
                RET
                NOP
                NOP
;7
                DEC L
                DEC H
                RET

;новый адрес для таблицы трассера
;вх  - L - текущий адрес
;      A - направление
;вых - L - новый адрес

GET_TRACE       AND 7
                RLCA
                RLCA
                LD (GET_TRACE1+1),A
                LD A,L
GET_TRACE1      JR $
;0
                SUB 18
                LD L,A
                RET
;1
                SUB 17
                LD L,A
                RET
;2
                INC L
                RET
                NOP
                NOP
;3
                ADD A,19
                LD L,A
                RET
;4
                ADD A,18
                LD L,A
                RET
;5
                ADD A,17
                LD L,A
                RET
;6
                DEC L
                RET
                NOP
                NOP
;7
                SUB 19
                LD L,A
                RET


;проверить, является ли координата пустой
;вх  - HL - начальные координаты
;вых - Z - пусто, NZ - препятствие

TEST_CORD       PUSH BC,DE,HL

;адрес в карте
                LD D,A
                GETMAPADR HLC
                LD C,D
                LD D,'TILE_TYPE

                LD E,(HL)
                LD A,(DE)
;пусто
                CP 5
                JR Z,TEST_CORDNZ
                JR NC,TEST_CORD30
                CP 2
                JR Z,TEST_CORD20
                INC L
                LD E,(HL)
                LD A,(DE)
                CP 5
                JR Z,TEST_CORDNZ
                CP 2
                JR C,TEST_CORDZ
                JR Z,TEST_CORDNZ
                CP 14
                JR NC,TEST_CORDNZ
                CP 9
                JR Z,TEST_CORDNZ
                CP 12
                JR Z,TEST_CORDNZ
                CP 13
                JR Z,TEST_CORDNZ
                JR TEST_CORDZ
;подъем
TEST_CORD20     INC L
                LD E,(HL)
                LD A,(DE)
                CP 2
                JR TEST_CORD50
;препятствия
TEST_CORD30
                CP 14
                JR NC,TEST_CORDNZ
                CP 7
                JR Z,TEST_CORDNZ
                CP 10
                JR Z,TEST_CORDNZ
                CP 11
                JR Z,TEST_CORDNZ
                INC L
                LD E,(HL)
                LD A,(DE)
                CP 14
                JR NC,TEST_CORDNZ
                CP 9
                JR Z,TEST_CORDNZ
                CP 12
                JR Z,TEST_CORDNZ
                CP 13
                JR Z,TEST_CORDNZ

TEST_CORDZ      XOR A
                JR TEST_CORD50
TEST_CORDNZ     XOR A
                DEC A
TEST_CORD50     LD A,C
                POP HL,DE,BC
                RET

;движение по направлению
;вх  - IX - описатель объекта
;вых - NZ - завершен, Z - незавершен

GOTO_DIRECT     PUSH BC,DE,HL
                LD E,A

                LD A,(IX+CNTR)
                OR A
                JP NZ,GOTO_DIR9

                LD A,(IX+DIRECT)
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                CALL GET_CORD
                LD (IX+XCRD),H
                LD (IX+YCRD),L

;по гор. и верт. - X4 , диаг. - X6
                LD A,16
                BIT 0,(IX+DIRECT)
                JR Z,$+4
                LD A,21
                LD (IX+CNTR),A

GOTO_DIR9       LD H,(IX+XSM)
                LD L,(IX+YSM)
                LD D,(IX+SPRT)
                LD B,(IX+CNTR)
                LD C,(IX+DIRECT)
;направление 0
                LD A,C
                OR A
                JP NZ,GOTO_DIR10
                LD A,B
                DEC A
                AND #0F
                LD L,A
                LD H,0

                LD A,16
                SUB B
                RRCA
                RRCA
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                LD D,A
                JP GOTO_DIR80
;направление 1
GOTO_DIR10      CP 1
                JP NZ,GOTO_DIR20
;A=B*192/256
                PUSH BC,DE,HL
                LD H,B
                LD L,0
                SRL H
                RR L
                LD D,H,E,L
                SRL H
                RR L
                ADD HL,DE
                LD A,H
                POP HL,DE,BC

                LD L,A
                NEG
                LD H,A

                LD A,20
                SUB B
                RRCA
                RRCA
                LD B,A
                LD A,(IX+XCRD)
                ADD A,A
                AND 2
                ADD A,B
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                INC A
                LD D,A
                JP GOTO_DIR80
;направление 2
GOTO_DIR20      CP 2
                JP NZ,GOTO_DIR30
                LD A,B
                DEC A
                AND #0F
                NEG
                LD H,A
                LD L,0

                LD A,16
                SUB B
                RRCA
                RRCA
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,2
                LD D,A
                JP GOTO_DIR80
;направление 3
GOTO_DIR30      CP 3
                JP NZ,GOTO_DIR40
;A=B*192/256
                PUSH BC,DE,HL
                LD H,B
                LD L,0
                SRL H
                RR L
                LD D,H,E,L
                SRL H
                RR L
                ADD HL,DE
                LD A,H
                POP HL,DE,BC

                NEG
                LD L,A
                LD H,A

                LD A,20
                SUB B
                RRCA
                RRCA
                LD B,A
                LD A,(IX+XCRD)
                ADD A,A
                AND 2
                ADD A,B
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,3
                LD D,A
                JP GOTO_DIR80

;направление 4
GOTO_DIR40      CP 4
                JP NZ,GOTO_DIR50
                LD A,B
                DEC A
                AND #0F
                NEG
                LD L,A
                LD H,0

                LD A,16
                SUB B
                RRCA
                RRCA
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,4
                LD D,A
                JP GOTO_DIR80
;направление 5
GOTO_DIR50      CP 5
                JR NZ,GOTO_DIR60
;A=B*192/256
                PUSH BC,DE,HL
                LD H,B
                LD L,0
                SRL H
                RR L
                LD D,H,E,L
                SRL H
                RR L
                ADD HL,DE
                LD A,H
                POP HL,DE,BC

                LD H,A
                NEG
                LD L,A

                LD A,20
                SUB B
                RRCA
                RRCA
                LD B,A
                LD A,(IX+XCRD)
                ADD A,A
                AND 2
                ADD A,B
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,5
                LD D,A
                JR GOTO_DIR80

;направление 6
GOTO_DIR60      CP 6
                JR NZ,GOTO_DIR70
                LD A,B
                DEC A
                AND #0F
                LD H,A
                LD L,0

                LD A,16
                SUB B
                RRCA
                RRCA
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,6
                LD D,A
                JP GOTO_DIR80

;направление 7
GOTO_DIR70
;A=B*192/256
                PUSH BC,DE,HL
                LD H,B
                LD L,0
                SRL H
                RR L
                LD D,H,E,L
                SRL H
                RR L
                ADD HL,DE
                LD A,H
                POP HL,DE,BC

                LD L,A
                LD H,A

                LD A,20
                SUB B
                RRCA
                RRCA
                LD B,A
                LD A,(IX+XCRD)
                ADD A,A
                AND 2
                ADD A,B
                AND 3
                INC A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,7
                LD D,A

GOTO_DIR80      LD (IX+XSM),H
                LD (IX+YSM),L
                LD (IX+SPRT),D

                LD A,(ACTION_POINT)
                DEC A
                LD (ACTION_POINT),A
                DEC (IX+CNTR)
                JP Z,GOTO_DIRNZ

                XOR A
                JR GOTO_DIRE

GOTO_DIRNZ      XOR A
                LD (IX+XSM),A
                LD (IX+YSM),A
                DEC A

GOTO_DIRE       LD A,E
                POP HL,DE,BC
                RET


;-----------------------------------------
;высокоуровневые подпрограммы для объектов
;-----------------------------------------

;трассировка маршрута
;вх  - IX - описатель объекта
;вых - A - 0 - маршут не может быть найден
;          1 - маршрут найден
;          2 - цель недоступна

;находим адрес финиша в таблице, H'
TRACE_MAP       LD HL,(MAP_XY)
                ;INC L
                LD A,(IX+XCRD)
                SUB H
                JP C,TRACE_MAPEX
                CP 17
                JP NC,TRACE_MAPEX
                INC A
                LD H,A
                LD A,(IX+YCRD)
                SUB L
                JP C,TRACE_MAPEX
                CP 12
                JP NC,TRACE_MAPEX
                INC A
                ADD A,A;A=A*18
                LD B,A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,B
                ADD A,H
                EXX
                LD H,A
                EXX

;находим адрес старта в таблице, L'
                LD HL,(MAP_XY)
                ;INC L
                LD A,(IX+XTAG)
                SUB H
                JP C,TRACE_MAPEX
                CP 17
                JP NC,TRACE_MAPEX
                INC A
                LD H,A
                LD A,(IX+YTAG)
                SUB L
                JP C,TRACE_MAPEX
                CP 12
                JP NC,TRACE_MAPEX
                INC A
                ADD A,A;A=A*18
                LD B,A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,B
                ADD A,H
                EXX
                LD L,A
                EXX

;создаем фрагмент карты
                LD HL,(MAP_XY)
                ;INC L
                GETMAPADR HLB
                LD DE,TRACE_TAB+18+1
                LD B,12
TRACE_MAP1      PUSH BC,DE,HL
                LD B,16
TRACE_MAP2      PUSH BC
                LD B,'TILE_TYPE
                LD C,(HL)
                LD A,(BC)
                LD (DE),A
                POP BC
                INC L,E
                DJNZ TRACE_MAP2
                POP HL,DE,BC
                LD A,L
                ADD A,128
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                LD A,E
                ADD A,18
                LD E,A
                DJNZ TRACE_MAP1

;загружаем адрес старта в буфер
                EXX
                LD A,L
                LD BC,TEMP_TAB
                LD DE,TEMP_TAB+1
                LD (BC),A
                EXX
                LD H,'TRACE_TAB
                LD D,'TAB_TILEPASS
                LD L,A
                LD A,(HL)
                OR #F0
                LD (HL),A

;начинаем трассировку
TRACE_MAP10     EXX
                LD A,(BC)
                EXX
                LD C,A

;направление 0
;проверка на выход
                LD B,1
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAP11
;проверка на вход
                LD A,L
                SUB 19
                LD L,A
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAP11
;занимаем клетку
                LD B,#10
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

;направление 2
;проверка на выход
TRACE_MAP11     LD B,4
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAP12
;проверка на вход
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAP12
;занимаем клетку
                LD B,#30
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

;направление 4
;проверка на выход
TRACE_MAP12     LD B,16
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAP13
;проверка на вход
                LD A,L
                ADD A,17
                LD L,A
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAP13
;занимаем клетку
                LD B,#50
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

;направление 6
;проверка на выход
TRACE_MAP13     LD B,64
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAP14
;проверка на вход
                DEC L,L
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAP14
;занимаем клетку
                LD B,#70
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

;направление 1
;проверка на выход
TRACE_MAP14     LD B,2
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAP15
;проверка на вход
                LD A,L
                SUB 18
                LD L,A
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAP15
;занимаем клетку
                LD B,#20
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

;направление 3
;проверка на выход
TRACE_MAP15     LD B,8
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAP16
;проверка на вход
                LD A,L
                ADD A,18
                LD L,A
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAP16
;занимаем клетку
                LD B,#40
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

;направление 5
;проверка на выход
TRACE_MAP16     LD B,32
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAP17
;проверка на вход
                LD A,L
                ADD A,16
                LD L,A
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAP17
;занимаем клетку
                LD B,#60
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

;направление 7
;проверка на выход
TRACE_MAP17     LD B,128
                CALL TRACE_MAPOUT
                JR NZ,TRACE_MAPE
;проверка на вход
                LD A,L
                SUB 20
                LD L,A
                CALL TRACE_MAPIN
                JR NZ,TRACE_MAPE
;занимаем клетку
                LD B,#80
                CALL TRACE_MAPFILL
                JP Z,TRACE_MAPZ

TRACE_MAPE      EXX
                INC C
                LD A,C
                CP E
                EXX
                JR Z,TRACE_MAPNZ
                JP TRACE_MAP10

TRACE_MAPNZ     XOR A
                RET

TRACE_MAPZ      LD (IX+TRACEADR),A
                LD A,1
                RET

TRACE_MAPEX     LD A,2
                RET

;проверка на выход
;вх  - B - маска проверки
;вых - Z - выход есть, NZ - нет

TRACE_MAPOUT    LD L,C
                LD A,(HL)
                AND #0F
                LD E,A
                LD A,(DE)
                AND B
                RET NZ
                INC L
                LD A,(HL)
                AND #0F
                LD E,A
                LD A,(DE)
                AND B
                RET

;проверка на вход и свободное место
;вх  - B - маска проверки
;вых - Z - вход есть, NZ - нет

TRACE_MAPIN     LD A,(HL)
                AND #F0
                RET NZ
                LD A,(HL)
                AND #0F
                ADD A,16
                LD E,A
                LD A,(DE)
                AND B
                RET NZ
                INC L
                LD A,(HL)
                AND #0F
                ADD A,16
                LD E,A
                LD A,(DE)
                AND B
                RET NZ

;проверка на свободное место
                DEC L
                LD A,(HL)
                AND #0F
                LD E,A
                LD A,(DE)

;проверка на подъем
                CP #EE
                RET Z

                AND 4
                RET NZ
                INC L
                LD A,(HL)
                AND #0F
                ADD A,16
                LD E,A
                LD A,(DE)
                DEC L
                AND 4
                RET

;занимаем клетку
;вх  - B - байт направления
;вых - Z - достигут финиш, NZ - недост.

TRACE_MAPFILL   LD A,L
                EXX
                LD (DE),A
                INC E
                EXX
                LD A,(HL)
                OR B
                LD (HL),A
                LD A,L
                EXX
                CP H
                EXX
                RET

;проверка результативности выстрела
;вх  - IX - описатель стреляющего объекта
;      IY - описатель цели
;вых - Z - достиг цели, NZ - недостиг
;      IY - описатель найденого объекта

TRACE_SHOT      PUSH BC,DE,HL
                EXX
                PUSH BC,DE,HL

                LD (TRACE_SHOTA+1),A
                LD (TRACE_SHOTIY),IY

;находим начальную координату выстрела
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                SLA H,L
                LD A,(IX+DIRECT)
                AND 7
                ADD A,A
                ADD A,A
                ADD A,A
                LD (TRACE_SHOT1+1),A
TRACE_SHOT1     JR $
                INC H,H
                DEC L,L
                JR TRACE_SHOT2
                NOP
                NOP
                INC H,H,H
                DEC L,L
                JR TRACE_SHOT2
                NOP
                INC H,H,H
                JR TRACE_SHOT2
                NOP
                NOP
                NOP
                INC H,H,H,L
                JR TRACE_SHOT2
                NOP
                NOP
                INC H,H,L
                JR TRACE_SHOT2
                NOP
                NOP
                NOP
                INC L
                JR TRACE_SHOT2
                NOP
                NOP
                NOP
                NOP
                NOP
                JR TRACE_SHOT2
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                DEC L,L

;находим конечную координату выстрела
TRACE_SHOT2     LD D,(IY+XCRD)
                LD E,(IY+YCRD)
                SLA D,E
                LD A,(IX+DIRECT)
                AND 7
                LD B,A
                ADD A,A
                ADD A,A
                ADD A,B
                LD (TRACE_SHOT3+1),A
TRACE_SHOT3     JR $
                INC D,D
                JR TRACE_SHOT4
                NOP
                INC D
                JR TRACE_SHOT4
                NOP
                NOP
                INC D
                JR TRACE_SHOT4
                NOP
                NOP
                INC D
                DEC E
                JR TRACE_SHOT4
                NOP
                INC D,D
                DEC E
                JR TRACE_SHOT4
                INC D,D
                DEC E
                JR TRACE_SHOT4
                INC D,D
                JR TRACE_SHOT4
                NOP
                INC D,D

;расчитываем коэффициенты
TRACE_SHOT4     LD B,0
                EX DE,HL
                LD A,H
                SUB D
                JR NC,TRACE_SHOT5
                SET 0,B
                NEG
TRACE_SHOT5     LD H,A
                LD A,L
                SUB E
                JR NC,TRACE_SHOT6
                SET 1,B
                NEG
TRACE_SHOT6     LD L,A
                CP H
                JR C,TRACE_SHOT10
;X/Y
                LD A,L
                OR A
                JR NZ,TRACE_SHOT7
                LD HL,0
                JR TRACE_SHOT8
TRACE_SHOT7     LD C,L
                LD L,0
                CALL DIV_WORD
                BIT 0,B
                JR Z,TRACE_SHOT8
                LD A,L
                CPL
                LD L,A
                LD A,H
                CPL
                LD H,A
                INC HL
TRACE_SHOT8     BIT 1,B
                PUSH HL
                EXX
                POP BC
                LD A,1
                JR Z,TRACE_SHOT9
                NEG
TRACE_SHOT9     LD D,A
                LD E,0
                LD H,E
                LD L,E
                EXX
                JR TRACE_SHOT14
;Y/X
TRACE_SHOT10    LD A,H
                OR A
                JR NZ,TRACE_SHOT11
                LD HL,0
                JR TRACE_SHOT8
TRACE_SHOT11    LD C,H
                LD H,L
                LD L,0
                CALL DIV_WORD
                BIT 1,B
                JR Z,TRACE_SHOT12
                LD A,L
                CPL
                LD L,A
                LD A,H
                CPL
                LD H,A
                INC HL
TRACE_SHOT12    BIT 0,B
                PUSH HL
                EXX
                POP DE
                LD A,1
                JR Z,TRACE_SHOT13
                NEG
TRACE_SHOT13    LD B,A
                LD C,0
                LD H,C
                LD L,C
                EXX

TRACE_SHOT14    EX DE,HL
                XOR A   ;уровень над морем
                LD (TRACE_SHOTLV),A

;цикл трассировки выстрела
TRACE_SHOT20

;проверка на выход за пределы карты
                LD A,H
                OR A
                JP Z,TRACE_SHOTNZ
                CP 255
                JP Z,TRACE_SHOTNZ
                LD A,L
                OR A
                JP Z,TRACE_SHOTNZ
                CP 247
                JP Z,TRACE_SHOTNZ

                LD D,H
                LD E,L
                SRL D,E

;новые координаты
                EXX
                LD A,H
                ADD A,C
                LD H,A
                LD A,B
                EXX
                ADC A,H
                LD H,A
                EXX
                LD A,L
                ADD A,E
                LD L,A
                LD A,D
                EXX
                ADC A,L
                LD L,A

;проверка, перешли-ли в новую клетку
                PUSH HL
                SRL H,L
                OR A
                SBC HL,DE
                POP HL
                JR Z,TRACE_SHOT20

;проверка на объекты
                PUSH HL
                SRL H,L
                CALL SEARCH_CRD
                POP HL
                JR NZ,TRACE_SHOT30
                LD A,(IX+ENEMY)
                CP (IY+ENEMY)
                JR Z,TRACE_SHOT30
                LD (TRACE_SHOTIY),IY
                XOR A
                JP TRACE_SHOTA

;проверка поверхности
TRACE_SHOT30    LD A,(TRACE_SHOTLV)
                OR A
                JR NZ,TRACE_SHOT31
                PUSH HL
                SRL H,L
                GETMAPADR HLB
                LD L,(HL)
                LD H,'TILE_TYPE
                LD A,(HL)
                POP HL
                CP 5
                JP Z,TRACE_SHOTNZ

;находим текущее направление
TRACE_SHOT31    PUSH DE,HL
                SRL H,L
                EX DE,HL
                CALL FIND_DIRECT
                LD B,A
                INC B
                LD A,#80
TRACE_SHOT32    RLCA
                DJNZ TRACE_SHOT32
                LD B,A
                POP HL,DE

;выход из клетки
                PUSH BC,HL
                LD H,D
                LD L,E
                GETMAPADR HLC
                LD L,(HL)
                LD H,'TILE_TYPE
                LD A,(HL)
                CP 6
                JR C,TRACE_SHOT33
                CP 14
                JR NC,TRACE_SHOT33
                LD L,A
                LD H,'TAB_TILEPASS
                LD A,(HL)
                AND B
                JR Z,TRACE_SHOT33
                LD A,(TRACE_SHOTLV)
                INC A
                LD (TRACE_SHOTLV),A
TRACE_SHOT33    POP HL,BC

;вход в клетку
                PUSH BC,HL
                SRL H,L
                GETMAPADR HLC
                LD L,(HL)
                LD H,'TILE_TYPE
                LD A,(HL)
                CP 6
                JR C,TRACE_SHOT34
                CP 14
                JR NC,TRACE_SHOT34
                ADD A,16
                LD L,A
                LD H,'TAB_TILEPASS
                LD A,(HL)
                AND B
                JR Z,TRACE_SHOT34
                LD A,(TRACE_SHOTLV)
                DEC A
                LD (TRACE_SHOTLV),A
                CP #FF
                POP HL,BC
                JP Z,TRACE_SHOTNZ
                PUSH BC,HL
TRACE_SHOT34    POP HL,BC
                JP TRACE_SHOT20

TRACE_SHOTNZ    LD B,1
                XOR A
                CP B
TRACE_SHOTA     LD A,0
                LD IY,(TRACE_SHOTIY)
                CALL ADD_CLUSTER
                POP HL,DE,BC
                EXX
                POP HL,DE,BC
                RET
TRACE_SHOTIY    DW 0
TRACE_SHOTLV    DB 0


;добавить осколки
;вх  - HL - координаты на карте в симв.
;вых - нет

ADD_CLUSTER     PUSH AF,BC,DE,HL
                EX DE,HL
                LD HL,CLUSTER_DISCR
                LD B,16
ADD_CLUST1      LD A,(HL)
                INC L
                OR (HL),A
                JR Z,ADD_CLUST2
                INC L,L
                DJNZ ADD_CLUST1
                JR ADD_CLUST3
ADD_CLUST2      DEC L
                LD (HL),D
                INC L
                LD (HL),E
                INC L
                LD (HL),12
ADD_CLUST3      POP HL,DE,BC,AF
                RET


;тест проходимости участка пути
;вх  - HL - координаты старта
;      DE - координаты финиша
;вых - Z - есть путь, NZ - нет

TEST_WAY        PUSH BC,DE,HL

                LD C,A

;проверяем на достижение цели
TEST_WAY10      CALL FIND_DIRECT
                PUSH HL
                CALL GET_CORD
                OR A
                SBC HL,DE
                POP HL
                JR Z,TEST_WAY30

                CALL TEST_DIRECT
                JR Z,TEST_WAY20
                INC A
                AND 7
                CALL TEST_DIRECT
                JR Z,TEST_WAY20
                SUB 2
                AND 7
                CALL TEST_DIRECT
                JR NZ,TEST_WAY30

;продолжаем сканирование
TEST_WAY20      CALL GET_CORD
                JR TEST_WAY10

TEST_WAY30      LD A,C
                POP HL,DE,BC
                RET
