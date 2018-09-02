DATA SEGMENT   ;���ݶ�
	SRTAB    DW    0,1,4,9,16,25,36,49,64,81,100   ;0-10��ƽ�������ѯ��
	MAX      DB    15   ;�����������λ����1
	ACT      DB    ?  ;��������λ��
	NUM      DB    18 DUP('0') ;��������
	BITN     DB    0  ;������λ��
	RESULT   DB    10 DUP(?) ;������
	
	STITLE   DB    'Square Root Calculator '   ;����
	STR1     DB    '******************************************'
	INPUT    DB    'Input a number: '  ;������ʾ
	OUTPUT   DB    'The square root of '  ;�����ʾ
	STR2     DB    'is '  ;�����ʾ
	ERRS1    DB    'Input error: Invalid character(s)'   ;��ʾ��������Ч�ַ�
	ERRS2    DB    'Input error: Redundant decimal points'  ;��ʾ�����˶����С����
	BLANK    DB    '                '  ;�������������������ı�������
	CALING   DB    'Calculating...'   ;��ʾ���ڼ�����
	PSTR     DB    'Press any key to continue...'  ;���������������ʾ
	PSTR1    DB    'Press R to restart'  ;��R�����¿�ʼ����ʾ
	PSTR2    DB    'Press Q to quit'  ;��Q���˳�����ʾ
DATA ENDS

STACK SEGMENT  STACK   ;��ջ��
	DW    200    DUP(?)
STACK ENDS

CODE SEGMENT   ;�����
	ASSUME CS:CODE,DS:DATA,SS:STACK
;=======������=======
START:
	MOV 	AX,DATA
	MOV 	DS,AX
	MOV 	ES,AX  ;���ݶζε�ַ��DS��ES��
	
RESTART:
	CALL 	INITIALIZE  ;��ʼ��
	CALL 	INPUTNUM   ;���뱻������
	CALL 	CALSQROOT  ;����ƽ����
	CALL 	SHOWRESULT  ;��ʾ������
	CALL 	CONTINUEOP  ;�����������
	
	CMP 	AL,'r'  ;���CONTINUEOP�ӳ����Ƿ񷵻�r��AL
	JZ  	RESTART  ;������r�����¿�ʼ����

	MOV 	AH,4CH
	INT 	21H   ;��������
;====================

INITIALIZE  PROC  ;��ʼ���׶��ӳ���
	MOV 	ACT,0   ;��ʼ����������λ��
	MOV 	BITN,0   ;��ʼ��������λ��
	
	MOV 	SI,OFFSET NUM
	MOV 	CX,18
L1:
	MOV 	[SI],BYTE PTR '0'
	INC 	SI
	LOOP 	L1   ;��ʼ����������
	
	MOV 	SI,OFFSET RESULT
	MOV 	CX,10
L2:
	MOV 	[SI],BYTE PTR 0
	INC 	SI
	LOOP 	L2   ;��ʼ��������

	MOV 	AH,0
	MOV 	AL,3
	INT 	10H   ;������ʾģʽΪ3
	
	MOV 	AH,6
	MOV 	AL,0
	MOV 	CH,6
	MOV 	CL,19
	MOV 	DH,21
	MOV 	DL,61
	MOV 	BH,07H
	INT 	10H   ;����
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,STITLE
	MOV 	CX,23
	MOV 	DH,5
	MOV 	DL,29
	INT 	10H   ;��ʾ����
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,6
	MOV 	DL,19
	INT 	10H   ;��ʾ�ָ���
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,INPUT
	MOV 	CX,16
	MOV 	DH,8
	MOV 	DL,25
	INT 	10H   ;��ʾ���뱻������
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,12
	MOV 	DL,19
	INT 	10H   ;��ʾ�ָ���
	RET
INITIALIZE  ENDP

INPUTNUM  PROC  ;���뱻�������ӳ���
INPUTLO:	
	MOV 	AH,2
	MOV 	BH,0
	MOV 	DH,8
	MOV 	DL,41
	INT 	10H   ;�������λ��
	
	LEA 	DX,MAX
	MOV 	AH,0AH
	INT 	21H   ;���뱻������
	
	MOV 	BX,OFFSET NUM
	ADD 	BL,ACT
	MOV 	[BX],BYTE PTR '0'  ;��0��������Ļس���
	
	MOV 	AX,0   ;AX����С�������
	MOV 	SI,OFFSET NUM
	MOV 	CX,0
	MOV 	CL,ACT
L3:     ;������������������Ƿ��ж���С���㼰��Ч�ַ�
	CMP 	[SI],BYTE PTR '.'
	JZ  	INCAX   ;��������С���������
	CMP 	[SI],BYTE PTR '0'
	JB  	ERRINP1
	CMP 	[SI],BYTE PTR '9'
	JA  	ERRINP1  ;����������������������ַ�����ת��������ʾ
	JMP 	NORMALLOP  ;����С����������
INCAX:
	INC 	AX   ;AX��������
	CMP 	AX,1
	JA  	ERRINP2   ;��С���㳬��һ������ʾ�������
NORMALLOP:
	INC 	SI
	LOOP 	L3
	JMP  	NORMAL  ;������������������������ת
	
ERRINP1:
	LEA 	BP,ERRS1  ;��ʾ��������Ч�ַ�
	MOV 	CX,33
	MOV 	DH,10
	MOV 	DL,24
	JMP 	ERRINP
ERRINP2:
	LEA 	BP,ERRS2  ;��ʾ�����˶����С����
	MOV 	CX,37
	MOV 	DH,10
	MOV 	DL,21

ERRINP:
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0CH
	INT 	10H    ;��ʾ������ʾ
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,PSTR
	MOV 	CX,28
	MOV 	DH,14
	MOV 	DL,19
	INT 	10H   ;��ʾ�������������ʾ
	
	MOV 	AH,0
	INT 	16H   ;�����������
	
	MOV 	SI,OFFSET NUM
	MOV 	CX,18
L4:
	MOV 	[SI],BYTE PTR '0'
	INC 	SI
	LOOP 	L4   ;����ڴ���������ı�������
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,BLANK
	MOV 	CX,16
	MOV 	DH,8
	MOV 	DL,41
	INT 	10H  ;���������������ı�������
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0H
	LEA 	BP,ERRS2
	MOV 	CX,37
	MOV 	DH,10
	MOV 	DL,21
	INT 	10H    ;���������ʾ
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0H
	LEA 	BP,PSTR
	MOV 	CX,28
	MOV 	DH,14
	MOV 	DL,19
	INT 	10H   ;����������������ʾ
	
	JMP 	INPUTLO  ;��������	
NORMAL:
	RET
INPUTNUM  ENDP

SHOWRESULT  PROC  ;��ʾ�������ӳ���
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,8
	MOV 	DL,19
	INT 	10H   ;����������ڼ�����ʾ

	MOV 	AH,13H
	MOV 	BH,0
	MOV 	BL,07H
	LEA 	BP,OUTPUT
	MOV 	CX,19
	MOV 	DH,8
	MOV 	DL,28
	MOV 	AL,ACT
	SHR 	AL,1
	SUB 	DL,AL
	MOV 	AL,1
	INT 	10H   ;��ʾ�����ʾ
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,NUM
	MOV 	CH,0
	MOV 	CL,ACT
	MOV 	DH,8
	MOV 	DL,47
	MOV 	AL,ACT
	SHR 	AL,1
	SUB 	DL,AL
	MOV 	AL,1
	INT 	10H   ;��ʾ��������
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,STR2
	MOV 	CX,3
	MOV 	DH,8
	MOV 	DL,47
	MOV 	AL,ACT
	SHR 	AL,1
	SUB 	DL,AL
	ADD 	DL,ACT
	INC 	DL
	MOV 	AL,1
	INT 	10H   ;ƴ����ʾ����
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,RESULT
	MOV 	CH,0
	MOV 	CL,BITN
	MOV 	DH,10
	MOV 	DL,42
	SUB 	DL,BITN
	SHR 	DL,1
	ADD 	DL,19
	INT 	10H   ;��ʾ������
	RET
SHOWRESULT  ENDP

CONTINUEOP  PROC   ;������������ӳ���
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,PSTR1
	MOV 	CX,18
	MOV 	DH,14
	MOV 	DL,19
	INT 	10H   ;��ʾ��R�����¿�ʼ��ʾ
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,PSTR2
	MOV 	CX,15
	MOV 	DH,15
	MOV 	DL,19
	INT 	10H   ;��ʾ��Q���˳�������ʾ
		
KEYLOP:
	MOV 	AH,7
	INT 	21H  ;���̲���
	CMP 	AL,'r'
	JZ 		RETURN
	CMP 	AL,'q'
	JZ 		RETURN  ;����R��Q������
	JMP 	KEYLOP
RETURN:
	RET
CONTINUEOP  ENDP
	
CALSQROOT  PROC   ;��ʽ����ƽ�����ӳ���
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,8
	MOV 	DL,19
	INT 	10H   ;�������������ʾ
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,87H
	LEA 	BP,CALING
	MOV 	CX,14
	MOV 	DH,8
	MOV 	DL,30
	INT 	10H   ;����ʱ��ϳ�ʱ��ʾ���ڼ�����ʾ

	MOV 	AL,ACT
	CBW
	PUSH 	AX   ;���汻������λ������ջ
	
	MOV 	SI,OFFSET NUM
	MOV 	CX,0
	MOV 	CL,ACT
LSTR:
	MOV 	AL,[SI]
	CMP 	AL,'.'
	JZ  	OE   ;����С����λ��ʱ��ת
	INC 	SI
	LOOP 	LSTR  ;��SI�������㱻����������������λ��
	MOV 	[SI],BYTE PTR '.'  ;ʹ��������Ϊ����ʱ����ĩβС����
	
OE: MOV 	AX,SI
	MOV 	BL,2
	DIV 	BL
	CMP 	AH,0
	JZ  	EVE  ;������������������λ����ż��ʱ��ת

	MOV 	ACT,'0'  ;��ACTλ����ʹ������������������λ����ż��
	MOV 	SI,OFFSET ACT
	JMP 	GETD
EVE:
	MOV 	SI,OFFSET NUM
	
GETD:
	MOV 	AX,0
	MOV 	DX,0  ;��ʼ������nΪ0
	MOV 	BX,0
	MOV 	CX,0  ;��ʼ������mΪ0
	MOV 	DI,OFFSET RESULT   ;ָ�������
	
GETLOP:
	CALL 	ABITRSPROC   ;��ƽ������һλ
	INC 	BYTE PTR BITN   ;λ������
	CMP 	BITN,9
	JB  	GETLOP

	POP 	AX
	MOV 	ACT,AL   ;�ָ���������λ��
	RET
CALSQROOT  ENDP

ABITRSPROC PROC   ;��ƽ����һλ�ӳ���
	PUSH 	AX
	PUSH 	DX   ;�������n����ջ
	PUSH 	BX
	PUSH 	CX   ;��������m����ջ
	
	MOV 	AL,[SI]   ;ȡ����������һλ���浽AL
	CMP 	AL,'.'
	JNZ  	NUMBER   ;���ȡ���Ĳ���С��������ת
	MOV 	[DI],BYTE PTR '.'  ;��С���㴫�͵���������
	INC 	SI
	INC 	DI
	
	POP 	CX
	POP 	BX
	POP 	DX
	POP 	AX
	RET
NUMBER:
	SUB 	AL,30H   ;ת��Ϊʮ������
	CBW
	MOV 	BL,10
	MUL 	BL  ;����ʮ��
	INC 	SI
	MOV 	BL,[SI]   ;ȡ������������һλ���浽BL
	SUB 	BL,30H   ;ת��Ϊʮ������
	ADD 	AL,BL   ;��ӻ�ø���λ��a��ʮ������
	INC 	SI
	CBW
	
	MOV 	DX,DI
	POP 	DI
	POP 	BX   ;ȡ������m
	PUSH 	AX   ;����a����ջ
	PUSH 	DX   ;����DIָ�뵽��ջ
	
	MOV 	AX,BX
	MOV 	DX,DI
	MOV 	CX,9
ADDLOP1:
	ADD 	AX,BX
	ADC 	DX,DI
	LOOP 	ADDLOP1	 ;9���ۼ�m����10��������m
	MOV 	BX,AX
	MOV 	DI,DX
	MOV 	CX,9
ADDLOP2:
	ADD 	AX,BX
	ADC 	DX,DI
	LOOP 	ADDLOP2	 ;��9���ۼ�10����m����100����m
	POP 	DI   ;�ָ�DIָ��
	
	MOV 	CX,0
	POP 	BX   ;ȡ��a
	ADD 	BX,AX
	ADC 	CX,DX   ;100*m��a���,���浽CX:BX
	POP 	DX
	POP 	AX   ;ȡ������n
	PUSH 	BX
	PUSH 	CX   ;����������չ100*m + a����ջ

				 ;����һ�������Ļ���n0
	PUSH 	DX
	PUSH 	AX   ;�������n����ջ
CALUNIT:
	CMP 	DX,0
	JA 		LA
	CMP 	AX,10   ;�ж�DX:AX�Ƿ�С��10
	JB  	LESSTEN
LA:
	SUB 	AX,10
	SBB 	DX,0
	JMP 	CALUNIT   ;�����n�ĸ�λ��u��AX
LESSTEN:
	POP 	BX
	POP 	CX   ;ȡ��n��CX:BX
	SUB 	BX,AX   ;n��ȥ��λ��u
	PUSH 	AX   ;����n�ĸ�λ��u����ջ
	PUSH 	DI
	MOV 	DI,CX   ;����DI����CX��ʹCX����Ϊѭ������
	MOV 	AX,BX
	MOV 	DX,DI
	MOV 	CX,9
ADDLOP3:
	ADD 	AX,BX
	ADC 	DX,DI
	LOOP 	ADDLOP3	 ;9���ۼ�(n-u)����10*(n-u)
	MOV 	BX,AX
	MOV 	CX,DX   ;10*(n-u)�Ľ��������CX:BX
	POP 	DI
	POP 	AX   ;ȡ��n�ĸ�λ��u
	MOV 	DL,20
	MUL 	DL   ;����20*u,������浽AX
	ADD 	BX,AX
	ADC 	CX,0   ;����10*(n-u)+20*u,�ó�������n0
	MOV 	AX,BX
	MOV 	DX,CX   ;��������n0���浽DX:AX

	POP 	CX
	POP 	BX   ;ȡ��������չ100*m + a��CX:BX
	PUSH 	SI   ;���汻������ָ�뵽��ջ
	MOV 	SI,OFFSET SRTAB
	ADD 	SI,2  ;SI�������i��2��

			     ;����(n0+i)*i=n0*i+i*i
	PUSH 	AX
	PUSH 	DX   ;��������Ļ���n0����ջ
MULLOP:
	ADD 	AX,[SI]
	ADC 	DX,0   ;n0*i��i*i���
	CMP 	DX,CX
	JA  	BIGGER
	JB  	SMALLER
	CMP 	AX,BX
	JA  	BIGGER   ;���n0*i+i*i����������չ100*m + a����ת
SMALLER:
	SUB 	AX,[SI]
	SBB 	DX,0   ;��ȥi*i
	MOV 	BP,SP
	ADD 	AX,[BP+2]
	ADC 	DX,[BP]   ;n0�ۼӼ��õ�n0*(i+1)
	ADD 	SI,2   ;SIָ���ƶ���ʹi������i+1
	CMP 	SI,22
	JB  	MULLOP

BIGGER:
	SUB 	AX,[SI]
	SBB 	DX,0   ;��ȥi*i
	SUB 	AX,[BP+2]
	SBB 	DX,[BP]   ;�ָ�n0*i
	SUB 	SI,2
	ADD 	AX,[SI]
	ADC 	DX,0   ;n0*i��i*i��ӱ��浽DX:AX
	
	SUB 	BX,AX
	SBB 	CX,DX   ;�������m���浽CX:BX
	POP 	DX
	POP 	AX   ;ȡ�������Ļ���n0
	SAR 	SI,1   ;�õ�ʹn0*i+i*i������������չ100*m + a��i�����ֵ
	ADD 	AX,SI
	ADC 	DX,0   ;����n0+i���浽DX:AX��Ϊ�µĳ�������
	ADD 	SI,30H
	MOV 	[DI],SI   ;����i��Ϊ��ǰ����������һλ
	INC 	DI

	POP 	SI   ;ȡ����������ָ��
	RET
ABITRSPROC ENDP

CODE ENDS
	END START