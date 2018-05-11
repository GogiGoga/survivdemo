;++++++++++++++++ ENGINE_2.H +++++++++++++
;движок игры

                MAIN "GAME.H",#C0

;драйвер мышки
;вх  - нет
;вых - нет

MOUSE           PUSH AF,BC,DE,HL
                LD BC,#FADF
                IN A,(C)
                XOR #FF
                AND 3
                LD (INPUT_BUTTON),A

                LD DE,(MOUSE_LY)

                LD B,#FB
                IN A,(C)
                LD H,A
                LD B,#FF
                IN A,(C)
                LD L,A

                PUSH HL
                OR A
                SBC HL,DE
                JR Z,MOUSE_1
                XOR A
                LD (INPUT_KEYBUSE),A
MOUSE_1         POP HL

                LD (MOUSE_LY),HL
                LD BC,(INPUT_Y)
                LD A,191
                SUB C
                LD C,A

                LD A,H
                SUB D
                JR C,MOUSE_XL
MOUSE_XR        CP 128
                JR NC,MOUSE_XR2
                CALL MOUSE_SCAL
                ADD A,B
                JR C,MOUSE_XR0
                CP 252
                JR C,MOUSE_XR1
MOUSE_XR0       LD A,251
MOUSE_XR1       LD B,A
                JP MOUSE_YCRD
MOUSE_XR2       NEG
                CALL MOUSE_SCAL
                LD H,A
                LD A,B
                SUB H
                JR NC,MOUSE_XR3
                XOR A
MOUSE_XR3       LD B,A
                JP MOUSE_YCRD

MOUSE_XL        NEG
                CP 128
                JR NC,MOUSE_XL2
                CALL MOUSE_SCAL
                LD H,A
                LD A,B
                SUB H
                JR NC,MOUSE_XL1
                XOR A
MOUSE_XL1       LD B,A
                JP MOUSE_YCRD
MOUSE_XL2       NEG
                CALL MOUSE_SCAL
                ADD A,B
                JR C,MOUSE_XL21
                CP 252
                JR C,MOUSE_XL3
MOUSE_XL21      LD A,251
MOUSE_XL3       LD B,A
                JP MOUSE_YCRD

MOUSE_YCRD      LD A,L
                SUB E
                JR C,MOUSE_YL
MOUSE_YR        CP 128
                JR NC,MOUSE_YR2
                CALL MOUSE_SCAL
                ADD A,C
                CP 192
                JR C,MOUSE_YL1
                LD A,191
MOUSE_YR1       LD C,A
                JP MOUSE_END
MOUSE_YR2       NEG
                CALL MOUSE_SCAL
                LD L,A
                LD A,C
                SUB L
                JR C,MOUSE_YR21
                CP 4
                JR NC,MOUSE_YR3
MOUSE_YR21      LD A,4
MOUSE_YR3       LD C,A
                JP MOUSE_END

MOUSE_YL        NEG
                CP 128
                JR NC,MOUSE_YL2
                CALL MOUSE_SCAL
                LD L,A
                LD A,C
                SUB L
                JR C,MOUSE_YL0
                CP 4
                JR NC,MOUSE_YL1
MOUSE_YL0       LD A,4
MOUSE_YL1       LD C,A
                JP MOUSE_END
MOUSE_YL2       NEG
                CALL MOUSE_SCAL
                ADD A,C
                CP 192
                JR C,MOUSE_YL3
                LD A,191
MOUSE_YL3       LD C,A

MOUSE_END       LD A,191
                SUB C
                LD C,A
                LD (INPUT_Y),BC

                CALL KEYBOARD

;проверка нажатия кнопок мыши
                LD A,(INPUT_LKEY)
                LD B,A
                LD A,(INPUT_KEY)
                LD C,A
                LD A,(INPUT_BUTTON)
                BIT 0,A
                JR Z,MOUSE_KEY1
                BIT 0,B
                JR NZ,MOUSE_KEY1
                SET 0,C
MOUSE_KEY1      BIT 1,A
                JR Z,MOUSE_KEY2
                BIT 1,B
                JR NZ,MOUSE_KEY2
                SET 1,C
MOUSE_KEY2      LD A,C
                LD (INPUT_KEY),A
                LD A,(INPUT_BUTTON)
                LD (INPUT_LKEY),A

                POP HL,DE,BC,AF
                RET

MOUSE_SCAL      RET

MOUSE_LY        DB 0
MOUSE_LX        DB 0
INPUT_LKEY      DB 0

;опрос клавиатуры
;вх  - нет
;вых - нет

KEYBOARD        PUSH AF,BC,DE,HL

                LD A,(INPUT_KEYBSPD)
                RRCA
                RRCA
                AND #3F
                JR NZ,KEYBOARD_1
                INC A
KEYBOARD_1      LD D,A
                LD L,0

;вверх
                LD A,(INPUT_Y)
                LD H,A
                LD BC,(KEY_UP)
                LD E,C
                LD C,#FE
                IN A,(C)
                AND E
                JR NZ,KEYBOARD_2
                LD L,1
                LD A,H
                SUB D
                LD H,A
                JR NC,KEYBOARD_2
                LD H,0
                LD L,2
                LD A,(INPUT_OVER)
                OR 1
                LD (INPUT_OVER),A
                JR KEYBOARD_4

;вниз
KEYBOARD_2      LD BC,(KEY_DOWN)
                LD E,C
                LD C,#FE
                IN A,(C)
                AND E
                JR NZ,KEYBOARD_4
                LD L,1
                LD A,H
                ADD A,D
                LD H,A
                JR C,KEYBOARD_3
                CP 188
                JR C,KEYBOARD_4
KEYBOARD_3      LD H,187
                LD L,2
                LD A,(INPUT_OVER)
                OR 4
                LD (INPUT_OVER),A

KEYBOARD_4      LD A,H
                LD (INPUT_Y),A

;влево
                LD A,(INPUT_X)
                LD H,A
                LD BC,(KEY_LEFT)
                LD E,C
                LD C,#FE
                IN A,(C)
                AND E
                JR NZ,KEYBOARD_5
                LD L,1
                LD A,H
                SUB D
                LD H,A
                JR NC,KEYBOARD_5
                LD H,0
                LD L,2
                LD A,(INPUT_OVER)
                OR 8
                LD (INPUT_OVER),A
                JR KEYBOARD_7

;вправо
KEYBOARD_5      LD BC,(KEY_RIGHT)
                LD E,C
                LD C,#FE
                IN A,(C)
                AND E
                JR NZ,KEYBOARD_7
                LD L,1
                LD A,H
                ADD A,D
                LD H,A
                JR C,KEYBOARD_6
                CP 252
                JR C,KEYBOARD_7
KEYBOARD_6      LD H,251
                LD L,2
                LD A,(INPUT_OVER)
                OR 2
                LD (INPUT_OVER),A

KEYBOARD_7      LD A,H
                LD (INPUT_X),A

;огонь
                LD BC,(KEY_FIRE)
                LD E,C
                LD C,#FE
                IN A,(C)
                AND E
                JR NZ,KEYBOARD_8
                LD A,(INPUT_BUTTON)
                OR 1
                LD (INPUT_BUTTON),A

;отмена
KEYBOARD_8      LD BC,(KEY_CANCEL)
                LD E,C
                LD C,#FE
                IN A,(C)
                AND E
                JR NZ,KEYBOARD_9
                LD A,(INPUT_BUTTON)
                OR 2
                LD (INPUT_BUTTON),A


KEYBOARD_9      LD A,L
                OR A
                JR NZ,KEYBOARD_20
                XOR A
                LD (INPUT_KEYBSPD),A
                JR KEYBOARD_E
KEYBOARD_20     CP 1
                JR NZ,KEYBOARD_21
                LD A,(INPUT_KEYBSPD)
                INC A
                LD (INPUT_KEYBSPD),A
                LD A,#FF
                LD (INPUT_KEYBUSE),A
                JR KEYBOARD_E
KEYBOARD_21     XOR A
                LD (INPUT_KEYBSPD),A
                LD A,#FF
                LD (INPUT_KEYBUSE),A


KEYBOARD_E      POP HL,DE,BC,AF
                RET


;вывод курсора на экран
;тип курсора из INPUT_ARROWTYPE
;вх  - HL - координаты в пикселях
;вых - нет

PUT_CURSOR      PUSH AF,BC,DE,HL

;пересчет координат
                LD A,(INPUT_ARROWCENT)
                AND 1
                JP Z,PUT_CURSV0
                LD A,L
                SUB 8
                LD L,A
                LD A,H
                SUB 8
                LD H,A
                JP NC,PUT_CURSV0
                LD H,0

;сохраняем фон под курсором
PUT_CURSV0      LD B,16
                LD A,L
                CP 192
                JP NC,PUT_CURSP+3
                CP 176
                JP C,PUT_CURSV1
                LD A,192
                SUB L
                LD B,A

PUT_CURSV1      PUSH BC,HL
                SRL H,H,H
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                EX DE,HL
                LD HL,CURSOR_BUF
                LD (HL),E
                INC HL
                LD (HL),D
                INC HL
                LD (HL),B
                INC HL
                EX DE,HL
                LD C,#FF
PUT_CURSV2      LDI
                LDI
                LDI
                DEC HL,HL,HL
                DOWN HL
                DJNZ PUT_CURSV2
                POP HL,BC

;адрес спрайта курсора
                EX DE,HL
                LD A,(INPUT_ARROWTYPE)
                RRCA
                RRCA
                LD C,A
                OR #3F
                AND #C0
                LD L,A
                LD A,C
                AND #3F
                ADD A,'INPUT_CURSPR
                LD H,A
                LD (PUT_CURSP+1),SP
                LD SP,HL

;экранный адрес
PUT_CURA1       EX DE,HL
                LD A,H
                AND 7
                SRL H,H,H
                ADD A,A
                ADD A,A
                LD (PUT_CURA2+1),A
                LD A,H

PUT_CURA2       JR $
                JP PUT_CURS0
                NOP
                JP PUT_CURS1
                NOP
                JP PUT_CURS2
                NOP
                JP PUT_CURS3
                NOP
                JP PUT_CURS4
                NOP
                JP PUT_CURS5
                NOP
                JP PUT_CURS6
                NOP
                JP PUT_CURS7

;подготовка смещение 0
PUT_CURS0       CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV01),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR0

;подготовка смещение 1
PUT_CURS1       CP 30
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV121),A
                LD (PUT_CURV122),A
                LD A,H
                CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV11),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR1

;подготовка смещение 2
PUT_CURS2       CP 30
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV221),A
                LD (PUT_CURV222),A
                LD A,H
                CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV21),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR2

;подготовка смещение 3
PUT_CURS3       CP 30
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV321),A
                LD (PUT_CURV322),A
                LD A,H
                CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV31),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR3

;подготовка смещение 4
PUT_CURS4       CP 30
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV421),A
                LD (PUT_CURV422),A
                LD A,H
                CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV41),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR4

;подготовка смещение 5
PUT_CURS5       CP 30
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV52),A
                LD A,H
                CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV51),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR5

;подготовка смещение 6
PUT_CURS6       CP 30
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV62),A
                LD A,H
                CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV61),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR6

;подготовка смещение 7
PUT_CURS7       CP 30
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV72),A
                LD A,H
                CP 31
                LD A,#77; (LD (HL),A)
                JR C,$+3
                XOR A;    (NOP)
                LD (PUT_CURV71),A
                SCRADRPIX HL
                LD A,H
                XOR #80
                LD H,A
                LD A,B
                JP PUT_CUR7

;вывод смещение 0
PUT_CUR0        EXA
                INC L
                POP BC
                POP DE
                LD A,(HL)
                AND B
                OR D
PUT_CURV01      LD (HL),A
                DEC L
                LD A,(HL)
                AND C
                OR E
                LD (HL),A
                DOWN HL
                EXA
                DNZ A,PUT_CUR0
                JP PUT_CURSP

;вывод смещение 1
PUT_CUR1        EXA
                INC L,L
                POP BC
                XOR A
                SUB 1
                RR C
                RR B
                RRA
                AND (HL)
PUT_CURV121     LD (HL),A
                POP DE
                XOR A
                RR E
                RR D
                RRA
                OR (HL)
PUT_CURV122     LD (HL),A
                DEC L
                LD A,(HL)
                AND B
                OR D
PUT_CURV11      LD (HL),A
                DEC L
                LD A,(HL)
                AND C
                OR E
                LD (HL),A
                DOWN HL
                EXA
                DNZ A,PUT_CUR1
                JP PUT_CURSP

;вывод смещение 2
PUT_CUR2        EXA
                INC L,L
                POP BC
                XOR A
                SUB 1
                DUP 2
                RR C
                RR B
                RRA
                EDUP
                AND (HL)
PUT_CURV221     LD (HL),A
                POP DE
                XOR A
                DUP 2
                RR E
                RR D
                RRA
                EDUP
                OR (HL)
PUT_CURV222     LD (HL),A
                DEC L
                LD A,(HL)
                AND B
                OR D
PUT_CURV21      LD (HL),A
                DEC L
                LD A,(HL)
                AND C
                OR E
                LD (HL),A
                DOWN HL
                EXA
                DNZ A,PUT_CUR2
                JP PUT_CURSP

;вывод смещение 3
PUT_CUR3        EXA
                INC L,L
                POP BC
                XOR A
                SUB 1
                DUP 3
                RR C
                RR B
                RRA
                EDUP
                AND (HL)
PUT_CURV321     LD (HL),A
                POP DE
                XOR A
                DUP 3
                RR E
                RR D
                RRA
                EDUP
                OR (HL)
PUT_CURV322     LD (HL),A
                DEC L
                LD A,(HL)
                AND B
                OR D
PUT_CURV31      LD (HL),A
                DEC L
                LD A,(HL)
                AND C
                OR E
                LD (HL),A
                DOWN HL
                EXA
                DNZ A,PUT_CUR3
                JP PUT_CURSP

;вывод смещение 4
PUT_CUR4        EXA
                INC L,L
                POP BC
                XOR A
                SUB 1
                DUP 4
                RR C
                RR B
                RRA
                EDUP
                AND (HL)
PUT_CURV421     LD (HL),A
                POP DE
                XOR A
                DUP 4
                RR E
                RR D
                RRA
                EDUP
                OR (HL)
PUT_CURV422     LD (HL),A
                DEC L
                LD A,(HL)
                AND B
                OR D
PUT_CURV41      LD (HL),A
                DEC L
                LD A,(HL)
                AND C
                OR E
                LD (HL),A
                DOWN HL
                EXA
                DNZ A,PUT_CUR4
                JP PUT_CURSP

;вывод смещение 5
PUT_CUR5        EXA
                POP BC
                XOR A
                SUB 1
                DUP 3
                RL B
                RL C
                RLA
                EDUP
                AND (HL)
                LD (HL),A
                POP DE
                XOR A
                DUP 3
                RL D
                RL E
                RLA
                EDUP
                OR (HL)
                LD (HL),A
                INC L
                LD A,(HL)
                AND C
                OR E
PUT_CURV51      LD (HL),A
                INC L
                LD A,(HL)
                AND B
                OR D
PUT_CURV52      LD (HL),A
                DEC L,L
                DOWN HL
                EXA
                DNZ A,PUT_CUR5
                JP PUT_CURSP

;вывод смещение 6
PUT_CUR6        EXA
                POP BC
                XOR A
                SUB 1
                DUP 2
                RL B
                RL C
                RLA
                EDUP
                AND (HL)
                LD (HL),A
                POP DE
                XOR A
                DUP 2
                RL D
                RL E
                RLA
                EDUP
                OR (HL)
                LD (HL),A
                INC L
                LD A,(HL)
                AND C
                OR E
PUT_CURV61      LD (HL),A
                INC L
                LD A,(HL)
                AND B
                OR D
PUT_CURV62      LD (HL),A
                DEC L,L
                DOWN HL
                EXA
                DNZ A,PUT_CUR6
                JP PUT_CURSP

;вывод смещение 7
PUT_CUR7        EXA
                POP BC
                XOR A
                SUB 1
                RL B
                RL C
                RLA
                AND (HL)
                LD (HL),A
                POP DE
                XOR A
                RL D
                RL E
                RLA
                OR (HL)
                LD (HL),A
                INC L
                LD A,(HL)
                AND C
                OR E
PUT_CURV71      LD (HL),A
                INC L
                LD A,(HL)
                AND B
                OR D
PUT_CURV72      LD (HL),A
                DEC L,L
                DOWN HL
                EXA
                DNZ A,PUT_CUR7

PUT_CURSP       LD SP,0
                POP HL,DE,BC,AF
                RET


;восстановление фона под курсором
;вх  - нет
;вых - нет

REST_CURSOR     PUSH AF,BC,DE,HL

                LD HL,CURSOR_BUF
                LD E,(HL)
                INC HL
                LD D,(HL)
                INC HL
                LD B,(HL)
                INC HL
                LD A,E
                OR D
                JR Z,REST_CURE
                LD C,#FF
REST_CURL       LDI
                LDI
                LDI
                DEC DE,DE,DE
                DOWN DE
                DJNZ REST_CURL

                LD HL,CURSOR_BUF
                XOR A
                LD (HL),A
                INC L
                LD (HL),A

REST_CURE       POP HL,DE,BC,AF
                RET

CURSOR_BUF      DS 51

;ожидания нажатия любой клавиши
;вх  - нет
;вых - нет

ANYKEY          PUSH AF
ANYKEY_1        XOR A
                IN A,(254)
                AND #1F
                CP #1F
                JP Z,ANYKEY_1
                POP AF
                RET

;обработка скроллинга карты
;вх  - нет
;вых - нет

MAP_SCROLL      LD DE,(INPUT_Y)
                LD HL,(MAP_XY)
                LD B,0

;скролл влево
                LD A,(INPUT_KEYBUSE)
                OR A
                JR Z,MAP_SCROLL1
                LD A,(INPUT_OVER)
                AND 8
                JR Z,MAP_SCROLL5
                JR MAP_SCROLL2
MAP_SCROLL1     LD A,D
                OR A
                JR NZ,MAP_SCROLL5
MAP_SCROLL2     LD A,H
                OR A
                JR Z,MAP_SCROLL5

;проверка главгероя

                IF0 EDITOR
                  LD A,(DISCRIPTORS+XCRD)
                  SUB H
                  JR C,MAP_SCROLL4
                  CP 14
                  JR NC,MAP_SCROLL5
                ENDIF

MAP_SCROLL4     DEC H
                LD B,7
                LD A,3,(MAP_SCRCNTR),A
                CALL REDRAW_ALL
                JR MAP_SCROLL9

;скролл вправо
MAP_SCROLL5     LD A,(INPUT_KEYBUSE)
                OR A
                JR Z,MAP_SCROLL6
                LD A,(INPUT_OVER)
                AND 2
                JR Z,MAP_SCROLL9
                JR MAP_SCROLL7
MAP_SCROLL6     LD A,D
                CP 251
                JR NZ,MAP_SCROLL9
MAP_SCROLL7     LD A,H

                IF0 EDITOR
                  CP 112
                ELSE
                  CP 116
                ENDIF
                JR NC,MAP_SCROLL9

;проверка главгероя

                IF0 EDITOR
                  LD A,(DISCRIPTORS+XCRD)
                  SUB H
                  JR Z,MAP_SCROLL9
                  JR C,MAP_SCROLL9
                ENDIF

MAP_SCROLL8     INC H
                LD B,3
                LD A,3,(MAP_SCRCNTR),A
                CALL REDRAW_ALL

;скролл вверх
MAP_SCROLL9     LD A,(INPUT_KEYBUSE)
                OR A
                JR Z,MAP_SCROLL10
                LD A,(INPUT_OVER)
                AND 1
                JR Z,MAP_SCROLL16
                JR MAP_SCROLL11
MAP_SCROLL10    LD A,E
                OR A
                JR NZ,MAP_SCROLL16
MAP_SCROLL11    LD A,L
                OR A
                JR Z,MAP_SCROLL16


;проверка главгероя

                IF0 EDITOR
                  LD A,(DISCRIPTORS+YCRD)
                  SUB L
                  JR C,MAP_SCROLL13
                  CP 11
                  JR NC,MAP_SCROLL22
                ENDIF

MAP_SCROLL13    DEC L
                LD A,3,(MAP_SCRCNTR),A
                CALL REDRAW_ALL
                LD A,B
                OR A
                JR NZ,MAP_SCROLL14
                LD B,1
                JR MAP_SCROLL22
MAP_SCROLL14    CP 3
                JR NZ,MAP_SCROLL15
                LD B,2
                JR MAP_SCROLL22
MAP_SCROLL15    LD B,8
                JR MAP_SCROLL22

;сколл вниз
MAP_SCROLL16    LD A,(INPUT_KEYBUSE)
                OR A
                JR Z,MAP_SCROLL17
                LD A,(INPUT_OVER)
                AND 4
                JR Z,MAP_SCROLL22
                JR MAP_SCROLL18
MAP_SCROLL17    LD A,E
                CP 187
                JR NZ,MAP_SCROLL22
MAP_SCROLL18    LD A,L
                CP 112
                JR NC,MAP_SCROLL22

;проверка главгероя

                IF0 EDITOR
                  LD A,(DISCRIPTORS+YCRD)
                  DEC A
                  SUB L
                  JR Z,MAP_SCROLL22
                  JR C,MAP_SCROLL22
                ENDIF

MAP_SCROLL19    INC L
                LD A,3,(MAP_SCRCNTR),A
                CALL REDRAW_ALL
                LD A,B
                OR A
                JR NZ,MAP_SCROLL20
                LD B,5
                JR MAP_SCROLL22
MAP_SCROLL20    CP 3
                JR NZ,MAP_SCROLL21
                LD B,4
                JR MAP_SCROLL22
MAP_SCROLL21    LD B,6

MAP_SCROLL22    XOR A
                LD (INPUT_OVER),A
                LD A,(CURSOR_CNTR)
                OR A
                JR NZ,MAP_SCROLL23
                LD A,B
                LD (CURSOR_TYPE),A
MAP_SCROLL23    LD (MAP_XY),HL
                RET
MAP_SCRCNTR     DB 0


;загрузка файла и его распаковка
;(если упакован)
;вх  - HL - адрес загрузки
;      DE - указатель на имя файла
;вых - нет

LOAD_FILE       EXA
                EXX
                PUSH AF,BC,DE,HL
                EXA
                EXX
                PUSH AF,BC,DE,HL,IX,IY

                PUSH HL
                EX DE,HL
                LD C,#13
                CALL #3D13
                POP HL

                PUSH HL
                XOR A
                LD (#5CF9),A
                LD A,#FF
                LD C,#0E
                CALL #3D13
                POP HL

                LD D,H,E,L
                CALL DEHRUST

                POP  IY,IX,HL,DE,BC,AF
                EXX
                EXA
                POP HL,DE,BC,AF
                EXX
                EXA
                RET


;проверка наличия файла на диске
;вх  - DE - указатель на имя файла
;вых - Z - файла нет, NZ - есть

EXIST_FILE      PUSH BC,DE,HL,IX,IY
                LD (EXIST_FILE1+1),A
                EX DE,HL
                LD C,#13
                CALL #3D13
                LD C,#0A
                CALL #3D13
                LD A,C
                CP #FF
EXIST_FILE1     LD A,0
                POP IY,IX,HL,DE,BC
                RET


;сохранение файла
;вх  - HL - адрес файла
;      BC - длинна файла
;      DE - указатель на имя файла
;вых - нет

SAVE_FILE       PUSH AF,BC,DE,HL,IX,IY
                PUSH BC,HL
                EX DE,HL
                LD C,#13
                CALL #3D13
                LD C,#0A
                CALL #3D13
                LD A,C
                CP #FF
                JR NZ,SAVE_FILE2

;новый файл
                POP HL,DE
SAVE_FILE1      LD C,#0B
                CALL #3D13
                JR SAVE_FILEE

;перезапись файла
SAVE_FILE2      LD C,#08
                CALL #3D13
                LD HL,SAVE_FILEB
                LD C,#14
                CALL #3D13
                POP HL,DE
                LD A,(SAVE_FILEB+11)
                CP E
                JR NZ,SAVE_FILE3
                LD A,(SAVE_FILEB+12)
                CP D
                JR NZ,SAVE_FILE3
                LD A,(SAVE_FILEB+15)
                LD D,A
                LD A,(SAVE_FILEB+14)
                LD E,A
                LD A,(SAVE_FILEB+13)
                LD B,A
                LD C,#06
                CALL #3D13
                JR SAVE_FILEE

;другой размер файла
SAVE_FILE3      PUSH DE,HL
                LD C,#12
                CALL #3D13
                POP HL,DE
                JR SAVE_FILE1

SAVE_FILEE      POP  IY,IX,HL,DE,BC,AF
                RET
SAVE_FILEB      DS 16


;сделать подготовленный экран видимым

SHOW_SCREEN     PUSH AF
                LD A,#FF
                LD (SCREEN_READY),A
                EI
                HALT
                EI
                POP AF
                RET

;коорд. карты для центрования по HL
;вх  - HL - текущие коорд.
;вых - HL - новые коорд.

CENTER_MAP      PUSH AF
                LD A,H
                SUB 7
                JR NC,$+3
                XOR A
                CP 116
                JR C,$+4
                LD A,116
                LD H,A
                LD A,L
                SUB 5
                JR NC,$+3
                XOR A
                CP 112
                JR C,$+4
                LD A,112
                LD L,A
                POP AF
                RET

;пошаговое центрование карты
;вх  - HL - координаты цели
;вых - нет

CENTER_MOVE     PUSH AF,DE,HL

                CALL CENTER_MAP
                LD DE,(MAP_XY)
                LD A,D
                CP H
                JR Z,CENTER_MOVE2
                JR C,CENTER_MOVE1
                DEC D
                JR CENTER_MOVE2
CENTER_MOVE1    INC D
CENTER_MOVE2    LD A,E
                CP L
                JR Z,CENTER_MOVE4
                JR C,CENTER_MOVE3
                DEC E
                JR CENTER_MOVE4
CENTER_MOVE3    INC E
CENTER_MOVE4    LD (MAP_XY),DE

                POP HL,DE,AF
                RET


;очистка прямоугольника и заполнение аттр
;вх  - HL - координаты на экране
;      BC - размеры
;      A - значение аттрибута
;вых - нет

CLEAR_RECT      PUSH AF,BC,DE,HL

;очистка прямоугольника
                PUSH AF,BC,HL
                SCRADR HL

                LD A,C
                DUP 3
                ADD A,A
                EDUP
                LD C,A

CLEAR_RECT1     PUSH BC,HL
CLEAR_RECT2     LD (HL),0
                INC L
                DJNZ CLEAR_RECT2
                POP HL,BC
                DOWN HL
                DNZ C,CLEAR_RECT1
                POP HL,BC,AF

;заполнение аттрибутов
CLEAR_RECT_EXT  LD D,A
                ATTRADR HL

CLEAR_RECT3     PUSH BC,HL
CLEAR_RECT4     LD (HL),D
                INC L
                DJNZ CLEAR_RECT4
                POP HL
                ADDW HL,32
                POP BC
                DNZ C,CLEAR_RECT3

                POP HL,DE,BC,AF
                RET


;заливка аттрибутами области экрана
;вх  - HL - координаты на экране
;      BC - размеры
;      A - значение аттрибута
;вых - нет

FILL_ATTR       PUSH AF,BC,DE,HL
                JP CLEAR_RECT_EXT


;вывод картинки на экран
;вх  - H - коорд X (0..31)
;      L - коорд Y (0..23)
;      DE - адрес картинки
;      BC - размеры в символах
;      A - аттрибут фона
;      (#00 - без аттрибутов)
;      (#FF - аттрибуты свои)

PUT_IMAGE       PUSH AF,BC,DE,HL

;вывод картинки
                PUSH AF,BC,HL
                SCRADR HL
                LD A,C
                ADD A,A
                ADD A,A
                ADD A,A
                LD C,B,B,A
                EX DE,HL
                IF0 EDITOR
PUT_IMAGE1        PUSH BC,DE
                  LD B,0
                  LDIR
                  POP DE,BC
                  DOWN DE
                  DJNZ PUT_IMAGE1
                ELSE
PUT_IMAGE1        PUSH BC,DE
PUT_IMAGE11       INC L
                  LD A,(HL)
                  LD (DE),A
                  INC L,E
                  DNZ C,PUT_IMAGE11
                  POP DE,BC
                  DOWN DE
                  DJNZ PUT_IMAGE1
                ENDIF
                POP HL,BC,AF

;проверка режима аттрибутов
                OR A
                JR Z,PUT_IMAGEE
                CP #FF
                JR Z,PUT_IMAGE2
                CALL FILL_ATTR
                JR PUT_IMAGEE

;вывод аттрибутов
PUT_IMAGE2      ATTRADR HL
                LD A,C,C,B,B,A
                EX DE,HL
PUT_IMAGE3      PUSH BC,DE
                LD B,0
                LDIR
                POP DE,BC
                ADDW DE,32
                DJNZ PUT_IMAGE3

PUT_IMAGEE      POP HL,DE,BC,AF
                RET


;распаковщик данных
;+--------------------+
;:Hrust Library v2.03 :
;: (C) Dmitry Pyankov :
;:   hrumer@mail.ru   :
;:      23.07.99      :
;+--------------------+
;вх  - HL - источник
;      DE - местоположение

DEHRUST         LD A,L
                ADD A,8
                LD L,A
                LD A,H
                ADC A,0
                LD H,A

                LD A,(HL)
                INC HL
                CP "H"
                RET NZ
                LD A,(HL)
                INC HL
                CP "r"
                RET NZ
                LD A,(HL)
                INC HL
                CP "s"
                RET NZ
                LD A,(HL)
                INC HL
                CP "t"
                RET NZ
                LD A,(HL)
                INC HL
                CP "2"
                RET NZ
                LD A,(HL)
                INC HL
                BIT 7,A
                RET NZ

                RRA
                EXA
                PUSH DE
                LD C,(HL)
                INC HL
                LD B,(HL)
                INC HL
                DEC BC

                EX DE,HL
                ADD HL,BC
                EX DE,HL

                LD C,(HL)
                INC HL
                LD B,(HL)
                INC HL

                LD A,(HL)
                ADD A,L
                LD L,A
                JR NC,$+3
                INC H
                ADD HL,BC

                SBC HL,DE
                ADD HL,DE
                JR C,$+4
                LD D,H
                LD E,L
                PUSH BC
                LDDR
                POP BC

                EX DE,HL
                EXA
                JR NC,DPCYES
                POP DE
                INC HL
                LDIR
                RET
DPCYES
                LD DE,7
                ADD HL,DE

                PUSH HL
                EXX
                POP HL
                POP DE

                LD B,6
                DEC HL
                LD A,(HL)
                PUSH AF
                INC SP
                DJNZ $-4

                EXX
                LD DE,#1003
                LD C,#80

DPC1            LD A,(HL)
                INC HL
                EXX
                LD (DE),A
                INC DE
DPC0            EXX
DPC0A
                SLA C
                JR NZ,$+6
                LD C,(HL)
                INC HL
                RL C
                JR C,DPC1

                LD B,#01
DPC4            LD A,%01000000
DPC2
                SLA C
                JR NZ,$+6
                LD C,(HL)
                INC HL
                RL C
                RLA
                JR NC,DPC2

                CP E;3
                JR C,DPC3
                ADD A,B
                LD B,A
                XOR D;#10
                JR NZ,DPC4
DPC3            ADD A,B
                CP 4
                JR Z,DPC5;B<>1;B=4
                ADC A,#FF
DPC8A           CP 2
DPC8            EXX
                LD C,A
                LD H,#FF
                EXX
                JR C,DPC9;B=1

                JR Z,DPC12
                SLA C
                JR NZ,$+6
                LD C,(HL)
                INC HL
                RL C
                JR C,DPC12

;B>=4
                LD A,%01111111
                LD B,E;3
                DJNZ DPC9A1;JR...B=2
DPC9A2          DJNZ DPC5A2
                LD B,A
                SBC A,A

DPC9B           SLA C
                JR NZ,$+6
                LD C,(HL)
                INC HL
                RL C
                RLA
                DEC A
                INC B
                JR NZ,DPC9B
                CP #FF-30
                JR NZ,$+4
                LD A,(HL)
                INC HL

                EXX
                LD H,A
                EXX

DPC12           LD A,(HL)
                INC HL
DPC11           EXX
                LD L,A
                ADD HL,DE
                LDIR
                JR DPC0

DPC5A2          ADD A,6
                RLA
                LD B,A
DPC5C           LD A,(HL)
                INC HL
                EXX
                LD (DE),A
                INC DE
                EXX
                DJNZ DPC5C
                JR DPC0A

DPC5
;B=4
                SLA C
                JR NZ,$+6
                LD C,(HL)
                INC HL
                RL C
                LD A,D;%00010000
                JR NC,DPC5A1

                LD A,(HL)
                INC HL
                CP D;16
                JR NC,DPC8A
                OR A
                JR Z,DPC6

                EXX
                LD B,A
                EXX
                LD A,(HL)
                INC HL
                JR DPC8

DPC9            ;B=1
                LD A,%00111111
DPC5A1          ;B=4
DPC9A1          ;B=2
DPC10           SLA C
                JR NZ,$+6
                LD C,(HL)
                INC HL
                RL C
                RLA
                JR NC,DPC10
                DJNZ DPC9A2
                JR DPC11

DPC6            LD HL,#2758
                EXX
                LD B,6
                DEC SP
                POP AF
                LD (DE),A
                INC DE
                DJNZ $-4
                RET

DPCL            EQU $-DEHRUST
