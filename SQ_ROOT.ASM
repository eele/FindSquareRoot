DATA SEGMENT   ;数据段
	SRTAB    DW    0,1,4,9,16,25,36,49,64,81,100   ;0-10的平方计算查询表
	MAX      DB    15   ;被开方数最大位数加1
	ACT      DB    ?  ;被开方数位数
	NUM      DB    18 DUP('0') ;被开方数
	BITN     DB    0  ;计算结果位数
	RESULT   DB    10 DUP(?) ;计算结果
	
	STITLE   DB    'Square Root Calculator '   ;标题
	STR1     DB    '******************************************'
	INPUT    DB    'Input a number: '  ;输入提示
	OUTPUT   DB    'The square root of '  ;输出提示
	STR2     DB    'is '  ;输出提示
	ERRS1    DB    'Input error: Invalid character(s)'   ;提示输入了无效字符
	ERRS2    DB    'Input error: Redundant decimal points'  ;提示输入了多余的小数点
	BLANK    DB    '                '  ;用于清除界面中已输入的被开方数
	CALING   DB    'Calculating...'   ;提示正在计算中
	PSTR     DB    'Press any key to continue...'  ;按任意键继续的提示
	PSTR1    DB    'Press R to restart'  ;按R键重新开始的提示
	PSTR2    DB    'Press Q to quit'  ;按Q键退出的提示
DATA ENDS

STACK SEGMENT  STACK   ;堆栈段
	DW    200    DUP(?)
STACK ENDS

CODE SEGMENT   ;代码段
	ASSUME CS:CODE,DS:DATA,SS:STACK
;=======主程序=======
START:
	MOV 	AX,DATA
	MOV 	DS,AX
	MOV 	ES,AX  ;数据段段地址送DS、ES中
	
RESTART:
	CALL 	INITIALIZE  ;初始化
	CALL 	INPUTNUM   ;输入被开方数
	CALL 	CALSQROOT  ;计算平方根
	CALL 	SHOWRESULT  ;显示计算结果
	CALL 	CONTINUEOP  ;程序后续操作
	
	CMP 	AL,'r'  ;检查CONTINUEOP子程序是否返回r到AL
	JZ  	RESTART  ;若返回r则重新开始计算

	MOV 	AH,4CH
	INT 	21H   ;结束程序
;====================

INITIALIZE  PROC  ;初始化阶段子程序
	MOV 	ACT,0   ;初始化被开方数位数
	MOV 	BITN,0   ;初始化计算结果位数
	
	MOV 	SI,OFFSET NUM
	MOV 	CX,18
L1:
	MOV 	[SI],BYTE PTR '0'
	INC 	SI
	LOOP 	L1   ;初始化被开方数
	
	MOV 	SI,OFFSET RESULT
	MOV 	CX,10
L2:
	MOV 	[SI],BYTE PTR 0
	INC 	SI
	LOOP 	L2   ;初始化计算结果

	MOV 	AH,0
	MOV 	AL,3
	INT 	10H   ;设置显示模式为3
	
	MOV 	AH,6
	MOV 	AL,0
	MOV 	CH,6
	MOV 	CL,19
	MOV 	DH,21
	MOV 	DL,61
	MOV 	BH,07H
	INT 	10H   ;清屏
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,STITLE
	MOV 	CX,23
	MOV 	DH,5
	MOV 	DL,29
	INT 	10H   ;显示标题
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,6
	MOV 	DL,19
	INT 	10H   ;显示分隔线
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,INPUT
	MOV 	CX,16
	MOV 	DH,8
	MOV 	DL,25
	INT 	10H   ;提示输入被开方数
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,12
	MOV 	DL,19
	INT 	10H   ;显示分隔线
	RET
INITIALIZE  ENDP

INPUTNUM  PROC  ;输入被开方数子程序
INPUTLO:	
	MOV 	AH,2
	MOV 	BH,0
	MOV 	DH,8
	MOV 	DL,41
	INT 	10H   ;调整光标位置
	
	LEA 	DX,MAX
	MOV 	AH,0AH
	INT 	21H   ;输入被开方数
	
	MOV 	BX,OFFSET NUM
	ADD 	BL,ACT
	MOV 	[BX],BYTE PTR '0'  ;用0覆盖输入的回车符
	
	MOV 	AX,0   ;AX用于小数点计数
	MOV 	SI,OFFSET NUM
	MOV 	CX,0
	MOV 	CL,ACT
L3:     ;遍历被开方数，检查是否有多余小数点及无效字符
	CMP 	[SI],BYTE PTR '.'
	JZ  	INCAX   ;若遍历到小数点则计数
	CMP 	[SI],BYTE PTR '0'
	JB  	ERRINP1
	CMP 	[SI],BYTE PTR '9'
	JA  	ERRINP1  ;被开方数含有数字以外的字符则跳转到错误提示
	JMP 	NORMALLOP  ;跳过小数点个数检测
INCAX:
	INC 	AX   ;AX自增计数
	CMP 	AX,1
	JA  	ERRINP2   ;若小数点超过一个则提示输入错误
NORMALLOP:
	INC 	SI
	LOOP 	L3
	JMP  	NORMAL  ;被开方数输入无误则正常跳转
	
ERRINP1:
	LEA 	BP,ERRS1  ;提示输入了无效字符
	MOV 	CX,33
	MOV 	DH,10
	MOV 	DL,24
	JMP 	ERRINP
ERRINP2:
	LEA 	BP,ERRS2  ;提示输入了多余的小数点
	MOV 	CX,37
	MOV 	DH,10
	MOV 	DL,21

ERRINP:
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0CH
	INT 	10H    ;显示错误提示
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,PSTR
	MOV 	CX,28
	MOV 	DH,14
	MOV 	DL,19
	INT 	10H   ;显示按任意键继续提示
	
	MOV 	AH,0
	INT 	16H   ;按任意键继续
	
	MOV 	SI,OFFSET NUM
	MOV 	CX,18
L4:
	MOV 	[SI],BYTE PTR '0'
	INC 	SI
	LOOP 	L4   ;清除内存中已输入的被开方数
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,BLANK
	MOV 	CX,16
	MOV 	DH,8
	MOV 	DL,41
	INT 	10H  ;清除界面中已输入的被开方数
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0H
	LEA 	BP,ERRS2
	MOV 	CX,37
	MOV 	DH,10
	MOV 	DL,21
	INT 	10H    ;清除错误提示
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0H
	LEA 	BP,PSTR
	MOV 	CX,28
	MOV 	DH,14
	MOV 	DL,19
	INT 	10H   ;清除按任意键继续提示
	
	JMP 	INPUTLO  ;重新输入	
NORMAL:
	RET
INPUTNUM  ENDP

SHOWRESULT  PROC  ;显示计算结果子程序
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,8
	MOV 	DL,19
	INT 	10H   ;覆盖清除正在计算提示

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
	INT 	10H   ;显示输出提示
	
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
	INT 	10H   ;显示被开方数
	
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
	INT 	10H   ;拼接提示文字
	
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
	INT 	10H   ;显示计算结果
	RET
SHOWRESULT  ENDP

CONTINUEOP  PROC   ;程序后续操作子程序
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,PSTR1
	MOV 	CX,18
	MOV 	DH,14
	MOV 	DL,19
	INT 	10H   ;显示按R键重新开始提示
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,07H
	LEA 	BP,PSTR2
	MOV 	CX,15
	MOV 	DH,15
	MOV 	DL,19
	INT 	10H   ;显示按Q键退出程序提示
		
KEYLOP:
	MOV 	AH,7
	INT 	21H  ;键盘操作
	CMP 	AL,'r'
	JZ 		RETURN
	CMP 	AL,'q'
	JZ 		RETURN  ;按下R或Q键返回
	JMP 	KEYLOP
RETURN:
	RET
CONTINUEOP  ENDP
	
CALSQROOT  PROC   ;竖式法求平方根子程序
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,0
	LEA 	BP,STR1
	MOV 	CX,42
	MOV 	DH,8
	MOV 	DL,19
	INT 	10H   ;覆盖清除输入提示
	
	MOV 	AH,13H
	MOV 	BH,0
	MOV 	AL,1
	MOV 	BL,87H
	LEA 	BP,CALING
	MOV 	CX,14
	MOV 	DH,8
	MOV 	DL,30
	INT 	10H   ;计算时间较长时显示正在计算提示

	MOV 	AL,ACT
	CBW
	PUSH 	AX   ;保存被开方数位数到堆栈
	
	MOV 	SI,OFFSET NUM
	MOV 	CX,0
	MOV 	CL,ACT
LSTR:
	MOV 	AL,[SI]
	CMP 	AL,'.'
	JZ  	OE   ;到达小数点位置时跳转
	INC 	SI
	LOOP 	LSTR  ;用SI遍历计算被开方数的整数部分位数
	MOV 	[SI],BYTE PTR '.'  ;使被开方数为整数时补上末尾小数点
	
OE: MOV 	AX,SI
	MOV 	BL,2
	DIV 	BL
	CMP 	AH,0
	JZ  	EVE  ;被开方数的整数部分位数是偶数时跳转

	MOV 	ACT,'0'  ;用ACT位补足使被开方数的整数部分位数是偶数
	MOV 	SI,OFFSET ACT
	JMP 	GETD
EVE:
	MOV 	SI,OFFSET NUM
	
GETD:
	MOV 	AX,0
	MOV 	DX,0  ;初始化除数n为0
	MOV 	BX,0
	MOV 	CX,0  ;初始化余数m为0
	MOV 	DI,OFFSET RESULT   ;指向计算结果
	
GETLOP:
	CALL 	ABITRSPROC   ;求平方根的一位
	INC 	BYTE PTR BITN   ;位数自增
	CMP 	BITN,9
	JB  	GETLOP

	POP 	AX
	MOV 	ACT,AL   ;恢复被开方数位数
	RET
CALSQROOT  ENDP

ABITRSPROC PROC   ;求平方根一位子程序
	PUSH 	AX
	PUSH 	DX   ;保存除数n到堆栈
	PUSH 	BX
	PUSH 	CX   ;保存余数m到堆栈
	
	MOV 	AL,[SI]   ;取被开方数下一位保存到AL
	CMP 	AL,'.'
	JNZ  	NUMBER   ;如果取到的不是小数点则跳转
	MOV 	[DI],BYTE PTR '.'  ;将小数点传送到计算结果中
	INC 	SI
	INC 	DI
	
	POP 	CX
	POP 	BX
	POP 	DX
	POP 	AX
	RET
NUMBER:
	SUB 	AL,30H   ;转换为十六进制
	CBW
	MOV 	BL,10
	MUL 	BL  ;扩大十倍
	INC 	SI
	MOV 	BL,[SI]   ;取被开方数接下一位保存到BL
	SUB 	BL,30H   ;转换为十六进制
	ADD 	AL,BL   ;相加获得该两位数a的十六进制
	INC 	SI
	CBW
	
	MOV 	DX,DI
	POP 	DI
	POP 	BX   ;取出余数m
	PUSH 	AX   ;保存a到堆栈
	PUSH 	DX   ;保存DI指针到堆栈
	
	MOV 	AX,BX
	MOV 	DX,DI
	MOV 	CX,9
ADDLOP1:
	ADD 	AX,BX
	ADC 	DX,DI
	LOOP 	ADDLOP1	 ;9次累加m，得10倍的余数m
	MOV 	BX,AX
	MOV 	DI,DX
	MOV 	CX,9
ADDLOP2:
	ADD 	AX,BX
	ADC 	DX,DI
	LOOP 	ADDLOP2	 ;再9次累加10倍的m，得100倍的m
	POP 	DI   ;恢复DI指针
	
	MOV 	CX,0
	POP 	BX   ;取出a
	ADD 	BX,AX
	ADC 	CX,DX   ;100*m与a相加,保存到CX:BX
	POP 	DX
	POP 	AX   ;取出除数n
	PUSH 	BX
	PUSH 	CX   ;保存余数扩展100*m + a到堆栈

				 ;求下一个除数的基底n0
	PUSH 	DX
	PUSH 	AX   ;保存除数n到堆栈
CALUNIT:
	CMP 	DX,0
	JA 		LA
	CMP 	AX,10   ;判断DX:AX是否小于10
	JB  	LESSTEN
LA:
	SUB 	AX,10
	SBB 	DX,0
	JMP 	CALUNIT   ;求除数n的个位数u到AX
LESSTEN:
	POP 	BX
	POP 	CX   ;取出n到CX:BX
	SUB 	BX,AX   ;n减去个位数u
	PUSH 	AX   ;保存n的个位数u到堆栈
	PUSH 	DI
	MOV 	DI,CX   ;借用DI代替CX，使CX可作为循环计数
	MOV 	AX,BX
	MOV 	DX,DI
	MOV 	CX,9
ADDLOP3:
	ADD 	AX,BX
	ADC 	DX,DI
	LOOP 	ADDLOP3	 ;9次累加(n-u)，得10*(n-u)
	MOV 	BX,AX
	MOV 	CX,DX   ;10*(n-u)的结果保存在CX:BX
	POP 	DI
	POP 	AX   ;取出n的个位数u
	MOV 	DL,20
	MUL 	DL   ;计算20*u,结果保存到AX
	ADD 	BX,AX
	ADC 	CX,0   ;计算10*(n-u)+20*u,得除数基底n0
	MOV 	AX,BX
	MOV 	DX,CX   ;除数基底n0保存到DX:AX

	POP 	CX
	POP 	BX   ;取出余数扩展100*m + a到CX:BX
	PUSH 	SI   ;保存被开方数指针到堆栈
	MOV 	SI,OFFSET SRTAB
	ADD 	SI,2  ;SI存放试商i的2倍

			     ;计算(n0+i)*i=n0*i+i*i
	PUSH 	AX
	PUSH 	DX   ;保存除数的基底n0到堆栈
MULLOP:
	ADD 	AX,[SI]
	ADC 	DX,0   ;n0*i与i*i相加
	CMP 	DX,CX
	JA  	BIGGER
	JB  	SMALLER
	CMP 	AX,BX
	JA  	BIGGER   ;如果n0*i+i*i大于余数扩展100*m + a则跳转
SMALLER:
	SUB 	AX,[SI]
	SBB 	DX,0   ;减去i*i
	MOV 	BP,SP
	ADD 	AX,[BP+2]
	ADC 	DX,[BP]   ;n0累加即得到n0*(i+1)
	ADD 	SI,2   ;SI指针移动，使i自增得i+1
	CMP 	SI,22
	JB  	MULLOP

BIGGER:
	SUB 	AX,[SI]
	SBB 	DX,0   ;减去i*i
	SUB 	AX,[BP+2]
	SBB 	DX,[BP]   ;恢复n0*i
	SUB 	SI,2
	ADD 	AX,[SI]
	ADC 	DX,0   ;n0*i与i*i相加保存到DX:AX
	
	SUB 	BX,AX
	SBB 	CX,DX   ;求出余数m保存到CX:BX
	POP 	DX
	POP 	AX   ;取出除数的基底n0
	SAR 	SI,1   ;得到使n0*i+i*i不超过余数扩展100*m + a的i的最大值
	ADD 	AX,SI
	ADC 	DX,0   ;计算n0+i保存到DX:AX作为新的除数基底
	ADD 	SI,30H
	MOV 	[DI],SI   ;试商i作为当前计算结果的下一位
	INC 	DI

	POP 	SI   ;取出被开方数指针
	RET
ABITRSPROC ENDP

CODE ENDS
	END START