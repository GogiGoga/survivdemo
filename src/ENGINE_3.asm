;++++++++++++++++ ENGINE_3.H +++++++++++++
;движок игры

                MAIN "GAME.H",#C0

;вывод статистики на экран

SHOW_STATISTIC

;аттрибуты
                LD A,(ACTIVE_SCREEN)
                ADD A,#18
                LD H,A
                LD A,%00000111
                LD L,28
                LD (HL),%01000010
                DUP 3
                INC L
                LD (HL),A
                EDUP 
                LD L,60
                LD (HL),%01000111
                DUP 3
                INC L
                LD (HL),A
                EDUP 
;жизнь
                LD A,(ACTIVE_SCREEN)
                LD H,A
                LD L,28
                LD A,11*8
                CALL PRINT_SMF
                INC L
                PUSH HL
                LD A,(DISCRIPTORS+LIFE)
                LD H,A,L,0
                LD A,(DISCRIPTORS+MAXLIFE)
                LD C,A
                CALL DIV_WORD
                ADD HL,HL; HL=HL*100
                ADD HL,HL
                LD B,H,C,L
                ADD HL,HL
                ADD HL,HL
                ADD HL,HL
                LD D,H,E,L
                ADD HL,HL
                ADD HL,BC
                ADD HL,DE
                LD A,H
                POP HL
                CALL PRINT_DEC
                LD A,(ACTIVE_SCREEN)
                LD H,A
                LD L,31
                LD B,8
                LD D,'MINI_FNT
                LD E,13*8
SHOW_STC1       LD A,(DE)
                RRCA 
                RRCA 
                OR (HL)
                LD (HL),A
                INC E,H
                DJNZ SHOW_STC1
;патроны
                LD A,(ACTIVE_SCREEN)
                LD H,A
                LD L,60
                LD A,12*8
                CALL PRINT_SMF
                INC L
                LD A,(DISCRIPTORS+BULLET)
                CALL PRINT_DEC

                RET 


;печать символа из минишрифта
;вх  - HL - экранный адрес
;      A - номер символа * 8

PRINT_SMF       PUSH HL
                LD B,8
                LD D,'MINI_FNT
                LD E,A
PRINT_SMF1      LD A,(DE)
                LD (HL),A
                INC E,H
                DJNZ PRINT_SMF1
                POP HL
                RET 

;печать десятичного числа (3 знакоместа)
;вх  - HL - экранный адрес
;    - A - число

PRINT_DEC       EXX 
                CALL DECBCD
                LD H,'MINI_FNT
                EXX 
                LD B,8

PRINT_D1        EXX 
                LD L,C
                LD A,(HL)
                RLCA 
                RLCA 
                LD E,A
                AND #03
                LD L,B
                OR (HL)
                EXX 
                LD (HL),A
                INC L
                EXX 
                LD A,E
                AND #F0
                LD E,A
                LD L,D
                LD A,(HL)
                RLCA 
                RLCA 
                RLCA 
                RLCA 
                LD L,A
                AND #0F
                OR E
                EXX 
                LD (HL),A
                INC L
                EXX 
                LD A,L
                AND #C0
                INC B,C,D
                EXX 
                LD (HL),A
                DEC L,L
                INC H
                DJNZ PRINT_D1
                RET 


;десятичное преобразование A в BCD
;с исключением первых нулей

DECBCD          LD BC,0

DECBCD_1        SUB 100
                JP C,DECBCD_2
                INC B
                JP DECBCD_1

DECBCD_2        ADD A,100

DECBCD_3        SUB 10
                JP C,DECBCD_4
                INC C
                JP DECBCD_3

DECBCD_4        ADD A,10
                ADD A,A
                ADD A,A
                ADD A,A
                LD D,A
                LD A,C
                ADD A,A
                ADD A,A
                ADD A,A
                LD C,A
                LD A,B
                ADD A,A
                ADD A,A
                ADD A,A
                LD B,A
                RET NZ

                LD B,10*8 ;пробел
                LD A,C
                OR A
                RET NZ

                LD C,10*8 ;пробел
                RET 


;вывод осколков на экран
;вх  - HL - координаты на карте в символах
;      A - номер спрайта осколков
;вых - нет

DRW_CLUSTER     PUSH AF,BC,DE,HL

;проверяем поподание осколков на экран
                LD C,A
                LD DE,(MAP_XY)
                SLA D,E
                LD A,H
                SUB D
                JP C,DRW_CLUSTERE
                CP 32
                JP NC,DRW_CLUSTERE
                LD H,A
                LD A,L
                SUB E
                JP C,DRW_CLUSTERE
                CP 24
                JP NC,DRW_CLUSTERE
                LD L,A

                PUSH DE,HL
                LD A,H
                AND #1E
                LD DE,TAB_REDRAW
                ADDA DE
                LD A,(ACTIVE_SCREEN)
                RRCA 
                RRCA 
                AND 32
                LD H,A
                LD A,L
                AND #1E
                ADD A,H
                LD HL,MAP_REDRAW+1
                ADDA HL
                LD A,(DE)
                OR (HL)
                LD (HL),A
                INC DE
                DEC L
                LD A,(DE)
                OR (HL)
                LD (HL),A
                POP HL,DE

;находим адрес спрайта осколков
                LD A,C
                ADD A,A
                ADD A,A
                ADD A,A
                LD DE,DRW_CLUSTERSPR
                ADDA DE

                PUSH HL
                SCRADR HL
                LD B,8

DRW_CLUSTER1    LD A,(DE)
                XOR (HL)
                LD (HL),A
                INC DE
                INC H
                DJNZ DRW_CLUSTER1


                POP HL
                ATTRADR HL
                LD A,(HL)
                AND #F8
                OR 2
                LD (HL),A

DRW_CLUSTERE    POP HL,DE,BC,AF
                RET 

DRW_CLUSTERSPR  DB #00,#14,#00,#18
                DB #50,#04,#00,#00

                DB #20,#0A,#40,#19
                DB #9C,#10,#22,#00

                DB #08,#80,#00,#18
                DB #04,#10,#00,#40

                DB #00,#14,#00,#18
                DB #50,#04,#00,#00


;вывод указателя места на экран
SHOW_PLACE      LD A,(PLACE_CNTR)
                OR A
                RET Z

                LD A,(FRAME_CURRENT)
                LD B,A
                LD A,(PLACE_CNTR)
                SUB B
                JR NC,$+3
                XOR A
                LD (PLACE_CNTR),A
                DUP 4
                RLCA 
                EDUP 
                AND #C0
                LD E,A
                LD D,'PLACE_SPRITE

;выводим указатель
                RAMPAGE 7
                LD HL,(PLACE_XY)
                LD BC,(MAP_XY)
                LD A,L
                SUB C
                RET C
                CP 12
                RET NC
                LD L,A
                LD A,H
                SUB B
                LD H,A
                JR C,SHOW_PLACE2
                CP 16
                RET NC
                CALL SHOW_PLACED
SHOW_PLACE2     LD A,E
                ADD A,32
                LD E,A
                LD A,H
                INC A
                LD H,A
                CP 16
                RET NC
                CALL SHOW_PLACED
                RET 

;прорисовка половинок указателя
SHOW_PLACED     PUSH DE,HL
                LD A,H
                ADD A,A
                LD DE,TAB_REDRAW+32
                ADDA DE
                LD A,(ACTIVE_SCREEN)
                RRCA 
                RRCA 
                AND 32
                LD H,A
                LD A,L
                ADD A,A
                ADD A,H
                LD HL,MAP_REDRAW+1
                ADDA HL

                LD A,(DE)
                OR (HL)
                LD (HL),A
                DEC L
                INC DE
                LD A,(DE)
                OR (HL)
                LD (HL),A
                POP HL,DE

                PUSH DE,HL
                SLA H,L
                SCRADR HL
                LD B,16
SHOW_PLACED1    LD A,(DE)
                XOR (HL)
                LD (HL),A
                INC E,L
                LD A,(DE)
                XOR (HL)
                LD (HL),A
                INC E
                DEC L
                DOWN HL
                DJNZ SHOW_PLACED1
                POP HL,DE
                RET 


;вывод осколков на экран
SHOW_CLUSTER    LD HL,CLUSTER_DISCR
                LD B,16
SHOW_CLUS1      LD D,(HL)
                INC L
                LD E,(HL)
                INC L
                LD A,(HL)
                EX DE,HL
                OR A
                JR Z,SHOW_CLUS2
                RRCA 
                RRCA 
                AND 3
                CALL DRW_CLUSTER
                LD A,(FRAME_CURRENT)
                LD C,A
                LD A,(DE)
                SUB C
                JR NC,$+3
                XOR A
                LD (DE),A
                JR NZ,SHOW_CLUS2
                XOR A
                DEC E
                LD (DE),A
                DEC E
                LD (DE),A
                INC E,E
SHOW_CLUS2      EX DE,HL
                INC L
                DJNZ SHOW_CLUS1
                RET 


;вывод видимых активных объектов на экран
SHOW_OBJECT
;находим объекты попадающие в экран
                LD IX,DISCRIPTORS
                LD HL,(MAP_XY)
                LD DE,TEMP_TAB
                LD B,OBJECT_MAX
                LD C,0

SHOW_OBJ1       LD A,(IX+XCRD)
                OR (IX+YCRD)
                JR Z,SHOW_OBJ3

                LD A,(IX+LIFE)
                OR A
                JR Z,SHOW_OBJ3

                LD A,(IX+XSM)
                RLA 
                LD A,(IX+XCRD)
                SBC A,0
                ADD A,2
                CP H
                JR C,SHOW_OBJ3

                LD A,(IX+XSM)
                RLA 
                LD A,H
                ADC A,15
                CP (IX+XCRD)
                JR C,SHOW_OBJ3

                LD A,(IX+YCRD)
                INC A
                CP L
                JR C,SHOW_OBJ3

                LD A,L
                ADD A,13
                CP (IX+YCRD)
                JR C,SHOW_OBJ3

                LD A,(IX+YCRD)
                SUB L
                DEC A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,(IX+YSM)
                ADD A,32
                LD (DE),A
                INC E,C
                LD A,(IX+XCRD)
                SUB H
                JR C,SHOW_OBJ2

                PUSH AF
                CP 8
                LD A,0
                RRA 
                RRA 
                XOR #40
                OR C
                LD C,A
                POP AF

SHOW_OBJ2       ADD A,A
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,(IX+XSM)
                LD (DE),A
                INC E
                LD A,(IX+TYPE)
                LD (DE),A
                INC E
                LD A,C
                AND #40
                OR (IX+SPRT)
                LD (DE),A
                RES 6,C
                INC E

SHOW_OBJ3       PUSH DE
                XOR A
                LD E,DISCR_LEN
                LD D,A
                ADD IX,DE
                POP DE
                DNZ B,SHOW_OBJ1
                OR C
                JR NZ,SHOW_OBJ4
                RET 

;сортируем объекты по высоте на экране
SHOW_OBJ4       LD HL,TEMP_TAB
                LD DE,TEMP_TAB+4
                LD B,C
                PUSH BC
                DEC B
                JR Z,SHOW_OBJ8
SHOW_OBJ5       PUSH BC,DE,HL
SHOW_OBJ6       LD A,(DE)
                CP (HL)
                JR NC,SHOW_OBJ7
                PUSH DE,HL
                DUP 4
                LD A,(DE)
                LD C,(HL)
                LD (HL),A
                LD A,C
                LD (DE),A
                INC L,E
                EDUP 
                POP HL,DE
SHOW_OBJ7       LD A,E
                ADD A,4
                LD E,A
                DJNZ SHOW_OBJ6
                POP HL,DE,BC
                LD A,L
                ADD A,4
                LD L,A
                LD A,E
                ADD A,4
                LD E,A
                DJNZ SHOW_OBJ5
SHOW_OBJ8       POP BC

;рисуем объекты
                LD HL,TEMP_TAB
SHOW_OBJ9       LD A,(HL)
                SUB 32
                LD E,A
                INC L
                LD D,(HL)
                INC L
                LD C,(HL)
                INC L
                LD A,(HL)
                INC L
                EX DE,HL
                CALL PUT_SPRITE
                EX DE,HL
                DJNZ SHOW_OBJ9
                RET 


;вывод неактивных объектов на экран
SHOW_STATIC     LD IX,DISCRIPTORS
                LD DE,DISCR_LEN
                LD B,OBJECT_MAX

SHOW_STATIC1    LD HL,(MAP_XY)
                LD A,(IX+XCRD)
                OR (IX+YCRD)
                JR Z,SHOW_STATIC3
                LD A,(IX+LIFE)
                OR A
                JR NZ,SHOW_STATIC3

                LD A,(IX+XCRD)
                ADD A,2
                CP H
                JR C,SHOW_STATIC3

                LD A,H
                ADD A,15
                CP (IX+XCRD)
                JR C,SHOW_STATIC3

                LD A,(IX+YCRD)
                INC A
                CP L
                JR C,SHOW_STATIC3

                LD A,L
                ADD A,13
                CP (IX+YCRD)
                JR C,SHOW_STATIC3

                LD A,(IX+YCRD)
                DEC A
                SUB L
                ADD A,A
                ADD A,A
                ADD A,A
                ADD A,A
                LD L,A
                LD C,0
                LD A,(IX+XCRD)
                SUB H
                JR C,SHOW_STATIC2
                CP 8
                CCF 
                RR C,C
SHOW_STATIC2    ADD A,A
                ADD A,A
                ADD A,A
                ADD A,A
                LD H,A
                LD A,C
                LD C,(IX+TYPE)
                OR (IX+SPRT)
                CALL PUT_SPRITE

SHOW_STATIC3    ADD IX,DE
                DJNZ SHOW_STATIC1
                RET 


;прорисовка огня из оружия
;вх  - IX - описатель объекта
;вых - нет

FIRE_LIGHT      PUSH AF,DE,HL

                RAMPAGE 7

;находим координаты огня
                LD H,(IX+XCRD)
                LD L,(IX+YCRD)
                LD DE,(MAP_XY)
                SLA H,L,D,E
                LD A,(IX+DIRECT)
                AND 7
                ADD A,A         ;A=A*8
                ADD A,A
                ADD A,A
                LD (FIRE_LIGHT1+1),A
FIRE_LIGHT1     JR $
                INC H,H         ;0
                DEC L,L
                JR FIRE_LIGHT2
                NOP 
                NOP 
                INC H,H,H       ;1
                DEC L,L
                JR FIRE_LIGHT2
                NOP 
                INC H,H,H       ;2
                JR FIRE_LIGHT2
                NOP 
                NOP 
                NOP 
                INC H,H,H,L     ;3
                JR FIRE_LIGHT2
                NOP 
                NOP 
                INC H,H,L       ;4
                JR FIRE_LIGHT2
                NOP 
                NOP 
                NOP 
                INC L           ;5
                JR FIRE_LIGHT2
                NOP 
                NOP 
                NOP 
                NOP 
                NOP 
                JR FIRE_LIGHT2  ;6
                NOP 
                NOP 
                NOP 
                NOP 
                NOP 
                NOP 
                DEC L,L         ;7

;проверяем на выход за пределы экрана
FIRE_LIGHT2     LD A,H
                SUB D
                JR C,FIRE_LIGHT3
                CP 32
                JR NC,FIRE_LIGHT3
                LD H,A
                LD A,L
                SUB E
                JR C,FIRE_LIGHT3
                CP 24
                JR NC,FIRE_LIGHT3
                LD L,A

;подсвечиваем аттрибут
                ATTRADR HL
                LD A,(HL)
                AND #F8
                OR 2
                LD (HL),A

FIRE_LIGHT3     POP HL,DE,AF
                RET 


;проверить карту на объекты под курсором
;вх  - нет
;вых - NZ - объект ненайден, Z - найден
;      IY - описатель найденого объекта

SEARCH_OBJECT   EXX 
                PUSH BC
                LD C,A
                LD B,OBJECT_MAX
                EXX 
                PUSH BC,DE,HL

                LD HL,DISCRIPTORS+1
                LD DE,(MAP_XY)
                LD BC,(INPUT_Y)

                LD A,B
                CP 8
                JP C,SEARCH_OBJ3
                CP 248
                JP NC,SEARCH_OBJ3
                LD A,C
                CP 8
                JP C,SEARCH_OBJ3
                CP 184
                JP NC,SEARCH_OBJ3

SEARCH_OBJ1     PUSH HL
                LD A,(HL);XCRD
                INC L
                OR (HL);YCRD
                JP Z,SEARCH_OBJ2
                INC L
                LD A,(HL);LIFE
                OR A
                JP Z,SEARCH_OBJ2

                DEC L
                LD A,(HL);YCRD
                SUB E
                JR C,SEARCH_OBJ2
                CP 12
                JR NC,SEARCH_OBJ2
                DEC A
                DUP 4
                ADD A,A
                INC L
                EDUP 
                ADD A,(HL);YSM
                CP C
                JR NC,SEARCH_OBJ2
                ADD A,32
                CP C
                JR C,SEARCH_OBJ2

                LD A,L
                SUB 5
                LD L,A
                LD A,(HL);XCRD
                SUB D
                JR C,SEARCH_OBJ2
                CP 16
                JR NC,SEARCH_OBJ2
                DUP 4
                ADD A,A
                INC L
                EDUP 
                ADD A,(HL);XSM
                CP B
                JR NC,SEARCH_OBJ2
                ADD A,32
                CP B
                JR C,SEARCH_OBJ2

SEARCH_OBJ5     POP IY
                DEC IY
                XOR A
                JR SEARCH_OBJ4

SEARCH_OBJ2     POP HL
                LD A,L
                ADD A,DISCR_LEN
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                EXX 
                DEC B
                EXX 
                JP NZ,SEARCH_OBJ1

SEARCH_OBJ3     XOR A
                DEC A

SEARCH_OBJ4     POP HL,DE,BC
                EXX 
                LD A,C
                POP BC
                EXX 
                RET 


;рисование тайла
;вх  - HL - координаты на экране
;      DE - адрес тайлсета
;      A - номер тайла
;вых - нет

DRAW_TILE       PUSH AF,BC,DE,HL

                LD L,A
                LD H,0
                ADD HL,HL
                ADD HL,HL
                LD C,L
                LD B,H
                ADD HL,HL
                ADD HL,HL
                ADD HL,HL
                ADD HL,BC
                ADD HL,DE
                EX DE,HL
                POP HL
                LD A,#FF
                LD BC,#0202
                CALL PUT_IMAGE

                POP DE,BC,AF
                RET 


;сделать тайл выделенным и мигающим
;вх  - HL - координаты на экране
;вых - нет

FLASH_TILE      PUSH AF,BC,HL
                XOR A
                LD BC,#0202
                CALL DRW_FRAME
                ATTRADR HL
                SET 7,(HL)
                INC L
                SET 7,(HL)
                LD A,L
                ADD A,31
                LD L,A
                LD A,H
                ADC A,0
                LD H,A
                SET 7,(HL)
                INC L
                SET 7,(HL)
                POP HL,BC,AF
                RET 

;вывод типового спрайта на экран
;вх  - H - коорд X (0..31)
;      L - коорд Y (0..23)
;      C - тип объекта
;      A - номер спрайта

DRAW_TYPE       PUSH AF,BC,DE,HL

;находим адрес спрайта
                PUSH HL

                LD D,A
                LD HL,SPRITE_TYPE
                LD B,MAX_SPRSETS-1
DRAW_TYPE1      LD A,(HL)
                CP C
                JR Z,DRAW_TYPE2
                INC HL,HL
                DJNZ DRAW_TYPE1
DRAW_TYPE2      INC HL
                LD A,(HL)
                CALL RAM_SEL

                LD HL,SPRITES
                LD DE,TEMP_TAB
                LD BC,256
                LDIR 

                POP HL
                RAMPAGE 7
                LD DE,TEMP_TAB
                LD A,#30
                LD BC,#0404
                CALL PUT_IMAGE

                POP HL,DE,BC,AF
                RET 

