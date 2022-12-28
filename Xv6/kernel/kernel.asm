
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8c070713          	addi	a4,a4,-1856 # 80008910 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	b5e78793          	addi	a5,a5,-1186 # 80005bc0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca7f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	388080e7          	jalr	904(ra) # 800024b2 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	134080e7          	jalr	308(ra) # 800022fc <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e7e080e7          	jalr	-386(ra) # 80002054 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	24a080e7          	jalr	586(ra) # 8000245c <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	216080e7          	jalr	534(ra) # 80002508 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c72080e7          	jalr	-910(ra) # 800020b8 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	77078793          	addi	a5,a5,1904 # 80020be8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5c07a223          	sw	zero,1476(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	34f72823          	sw	a5,848(a4) # 800088d0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	554dad83          	lw	s11,1364(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	4fe50513          	addi	a0,a0,1278 # 80010af8 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	3a050513          	addi	a0,a0,928 # 80010af8 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	38448493          	addi	s1,s1,900 # 80010af8 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	34450513          	addi	a0,a0,836 # 80010b18 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0d07a783          	lw	a5,208(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0a07b783          	ld	a5,160(a5) # 800088d8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0a073703          	ld	a4,160(a4) # 800088e0 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2b6a0a13          	addi	s4,s4,694 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	06e48493          	addi	s1,s1,110 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	06e98993          	addi	s3,s3,110 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	824080e7          	jalr	-2012(ra) # 800020b8 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	24850513          	addi	a0,a0,584 # 80010b18 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	ff07a783          	lw	a5,-16(a5) # 800088d0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	ff673703          	ld	a4,-10(a4) # 800088e0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	fe67b783          	ld	a5,-26(a5) # 800088d8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	21a98993          	addi	s3,s3,538 # 80010b18 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	fd248493          	addi	s1,s1,-46 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	fd290913          	addi	s2,s2,-46 # 800088e0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	736080e7          	jalr	1846(ra) # 80002054 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	1e448493          	addi	s1,s1,484 # 80010b18 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	f8e7bc23          	sd	a4,-104(a5) # 800088e0 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	15e48493          	addi	s1,s1,350 # 80010b18 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	38478793          	addi	a5,a5,900 # 80021d80 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	13490913          	addi	s2,s2,308 # 80010b50 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	2b250513          	addi	a0,a0,690 # 80021d80 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd281>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	78c080e7          	jalr	1932(ra) # 8000264a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	d3a080e7          	jalr	-710(ra) # 80005c00 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fd4080e7          	jalr	-44(ra) # 80001ea2 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	6ec080e7          	jalr	1772(ra) # 80002622 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	70c080e7          	jalr	1804(ra) # 8000264a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	ca4080e7          	jalr	-860(ra) # 80005bea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	cb2080e7          	jalr	-846(ra) # 80005c00 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	e52080e7          	jalr	-430(ra) # 80002da8 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	4f2080e7          	jalr	1266(ra) # 80003450 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	498080e7          	jalr	1176(ra) # 800043fe <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	d9a080e7          	jalr	-614(ra) # 80005d08 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d0e080e7          	jalr	-754(ra) # 80001c84 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd277>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd280>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	75448493          	addi	s1,s1,1876 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	13aa0a13          	addi	s4,s4,314 # 800169a0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	16848493          	addi	s1,s1,360
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	28850513          	addi	a0,a0,648 # 80010b70 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	28850513          	addi	a0,a0,648 # 80010b88 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	69048493          	addi	s1,s1,1680 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00015997          	auipc	s3,0x15
    80001936:	06e98993          	addi	s3,s3,110 # 800169a0 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	878d                	srai	a5,a5,0x3
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	16848493          	addi	s1,s1,360
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	20450513          	addi	a0,a0,516 # 80010ba0 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	1ac70713          	addi	a4,a4,428 # 80010b70 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first) {
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e647a783          	lw	a5,-412(a5) # 80008860 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	c5c080e7          	jalr	-932(ra) # 80002662 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e407a523          	sw	zero,-438(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	9b0080e7          	jalr	-1616(ra) # 800033d0 <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	13a90913          	addi	s2,s2,314 # 80010b70 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e1c78793          	addi	a5,a5,-484 # 80008864 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a54080e7          	jalr	-1452(ra) # 8000152e <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2e080e7          	jalr	-1490(ra) # 8000152e <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e4080e7          	jalr	-1564(ra) # 8000152e <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7a080e7          	jalr	-390(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	3de48493          	addi	s1,s1,990 # 80010fa0 <proc>
    80001bca:	00015917          	auipc	s2,0x15
    80001bce:	dd690913          	addi	s2,s2,-554 # 800169a0 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bea:	16848493          	addi	s1,s1,360
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a889                	j	80001c46 <allocproc+0x90>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ee2080e7          	jalr	-286(ra) # 80000ae6 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	c131                	beqz	a0,80001c54 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e5c080e7          	jalr	-420(ra) # 80001a70 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c20:	c531                	beqz	a0,80001c6c <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c34:	00000797          	auipc	a5,0x0
    80001c38:	db078793          	addi	a5,a5,-592 # 800019e4 <forkret>
    80001c3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3e:	60bc                	ld	a5,64(s1)
    80001c40:	6705                	lui	a4,0x1
    80001c42:	97ba                	add	a5,a5,a4
    80001c44:	f4bc                	sd	a5,104(s1)
}
    80001c46:	8526                	mv	a0,s1
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6902                	ld	s2,0(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret
    freeproc(p);
    80001c54:	8526                	mv	a0,s1
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	f08080e7          	jalr	-248(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	02a080e7          	jalr	42(ra) # 80000c8a <release>
    return 0;
    80001c68:	84ca                	mv	s1,s2
    80001c6a:	bff1                	j	80001c46 <allocproc+0x90>
    freeproc(p);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	ef0080e7          	jalr	-272(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	012080e7          	jalr	18(ra) # 80000c8a <release>
    return 0;
    80001c80:	84ca                	mv	s1,s2
    80001c82:	b7d1                	j	80001c46 <allocproc+0x90>

0000000080001c84 <userinit>:
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	f28080e7          	jalr	-216(ra) # 80001bb6 <allocproc>
    80001c96:	84aa                	mv	s1,a0
  initproc = p;
    80001c98:	00007797          	auipc	a5,0x7
    80001c9c:	c6a7b023          	sd	a0,-928(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca0:	03400613          	li	a2,52
    80001ca4:	00007597          	auipc	a1,0x7
    80001ca8:	bcc58593          	addi	a1,a1,-1076 # 80008870 <initcode>
    80001cac:	6928                	ld	a0,80(a0)
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	6a8080e7          	jalr	1704(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cb6:	6785                	lui	a5,0x1
    80001cb8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cba:	6cb8                	ld	a4,88(s1)
    80001cbc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc0:	6cb8                	ld	a4,88(s1)
    80001cc2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc4:	4641                	li	a2,16
    80001cc6:	00006597          	auipc	a1,0x6
    80001cca:	53a58593          	addi	a1,a1,1338 # 80008200 <digits+0x1c0>
    80001cce:	15848513          	addi	a0,s1,344
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	14a080e7          	jalr	330(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cda:	00006517          	auipc	a0,0x6
    80001cde:	53650513          	addi	a0,a0,1334 # 80008210 <digits+0x1d0>
    80001ce2:	00002097          	auipc	ra,0x2
    80001ce6:	118080e7          	jalr	280(ra) # 80003dfa <namei>
    80001cea:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cee:	478d                	li	a5,3
    80001cf0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	f96080e7          	jalr	-106(ra) # 80000c8a <release>
}
    80001cfc:	60e2                	ld	ra,24(sp)
    80001cfe:	6442                	ld	s0,16(sp)
    80001d00:	64a2                	ld	s1,8(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret

0000000080001d06 <growproc>:
{
    80001d06:	1101                	addi	sp,sp,-32
    80001d08:	ec06                	sd	ra,24(sp)
    80001d0a:	e822                	sd	s0,16(sp)
    80001d0c:	e426                	sd	s1,8(sp)
    80001d0e:	e04a                	sd	s2,0(sp)
    80001d10:	1000                	addi	s0,sp,32
    80001d12:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d14:	00000097          	auipc	ra,0x0
    80001d18:	c98080e7          	jalr	-872(ra) # 800019ac <myproc>
    80001d1c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d1e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d20:	01204c63          	bgtz	s2,80001d38 <growproc+0x32>
  } else if(n < 0){
    80001d24:	02094663          	bltz	s2,80001d50 <growproc+0x4a>
  p->sz = sz;
    80001d28:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d2a:	4501                	li	a0,0
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d38:	4691                	li	a3,4
    80001d3a:	00b90633          	add	a2,s2,a1
    80001d3e:	6928                	ld	a0,80(a0)
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	6d0080e7          	jalr	1744(ra) # 80001410 <uvmalloc>
    80001d48:	85aa                	mv	a1,a0
    80001d4a:	fd79                	bnez	a0,80001d28 <growproc+0x22>
      return -1;
    80001d4c:	557d                	li	a0,-1
    80001d4e:	bff9                	j	80001d2c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d50:	00b90633          	add	a2,s2,a1
    80001d54:	6928                	ld	a0,80(a0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	672080e7          	jalr	1650(ra) # 800013c8 <uvmdealloc>
    80001d5e:	85aa                	mv	a1,a0
    80001d60:	b7e1                	j	80001d28 <growproc+0x22>

0000000080001d62 <fork>:
{
    80001d62:	7139                	addi	sp,sp,-64
    80001d64:	fc06                	sd	ra,56(sp)
    80001d66:	f822                	sd	s0,48(sp)
    80001d68:	f426                	sd	s1,40(sp)
    80001d6a:	f04a                	sd	s2,32(sp)
    80001d6c:	ec4e                	sd	s3,24(sp)
    80001d6e:	e852                	sd	s4,16(sp)
    80001d70:	e456                	sd	s5,8(sp)
    80001d72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	c38080e7          	jalr	-968(ra) # 800019ac <myproc>
    80001d7c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	e38080e7          	jalr	-456(ra) # 80001bb6 <allocproc>
    80001d86:	10050c63          	beqz	a0,80001e9e <fork+0x13c>
    80001d8a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8c:	048ab603          	ld	a2,72(s5)
    80001d90:	692c                	ld	a1,80(a0)
    80001d92:	050ab503          	ld	a0,80(s5)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	7d2080e7          	jalr	2002(ra) # 80001568 <uvmcopy>
    80001d9e:	04054863          	bltz	a0,80001dee <fork+0x8c>
  np->sz = p->sz;
    80001da2:	048ab783          	ld	a5,72(s5)
    80001da6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001daa:	058ab683          	ld	a3,88(s5)
    80001dae:	87b6                	mv	a5,a3
    80001db0:	058a3703          	ld	a4,88(s4)
    80001db4:	12068693          	addi	a3,a3,288
    80001db8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dbc:	6788                	ld	a0,8(a5)
    80001dbe:	6b8c                	ld	a1,16(a5)
    80001dc0:	6f90                	ld	a2,24(a5)
    80001dc2:	01073023          	sd	a6,0(a4)
    80001dc6:	e708                	sd	a0,8(a4)
    80001dc8:	eb0c                	sd	a1,16(a4)
    80001dca:	ef10                	sd	a2,24(a4)
    80001dcc:	02078793          	addi	a5,a5,32
    80001dd0:	02070713          	addi	a4,a4,32
    80001dd4:	fed792e3          	bne	a5,a3,80001db8 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd8:	058a3783          	ld	a5,88(s4)
    80001ddc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de0:	0d0a8493          	addi	s1,s5,208
    80001de4:	0d0a0913          	addi	s2,s4,208
    80001de8:	150a8993          	addi	s3,s5,336
    80001dec:	a00d                	j	80001e0e <fork+0xac>
    freeproc(np);
    80001dee:	8552                	mv	a0,s4
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	d6e080e7          	jalr	-658(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001df8:	8552                	mv	a0,s4
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	e90080e7          	jalr	-368(ra) # 80000c8a <release>
    return -1;
    80001e02:	597d                	li	s2,-1
    80001e04:	a059                	j	80001e8a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e06:	04a1                	addi	s1,s1,8
    80001e08:	0921                	addi	s2,s2,8
    80001e0a:	01348b63          	beq	s1,s3,80001e20 <fork+0xbe>
    if(p->ofile[i])
    80001e0e:	6088                	ld	a0,0(s1)
    80001e10:	d97d                	beqz	a0,80001e06 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e12:	00002097          	auipc	ra,0x2
    80001e16:	67e080e7          	jalr	1662(ra) # 80004490 <filedup>
    80001e1a:	00a93023          	sd	a0,0(s2)
    80001e1e:	b7e5                	j	80001e06 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e20:	150ab503          	ld	a0,336(s5)
    80001e24:	00001097          	auipc	ra,0x1
    80001e28:	7ec080e7          	jalr	2028(ra) # 80003610 <idup>
    80001e2c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e30:	4641                	li	a2,16
    80001e32:	158a8593          	addi	a1,s5,344
    80001e36:	158a0513          	addi	a0,s4,344
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	fe2080e7          	jalr	-30(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e42:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e46:	8552                	mv	a0,s4
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	e42080e7          	jalr	-446(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e50:	0000f497          	auipc	s1,0xf
    80001e54:	d3848493          	addi	s1,s1,-712 # 80010b88 <wait_lock>
    80001e58:	8526                	mv	a0,s1
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	d7c080e7          	jalr	-644(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e62:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e66:	8526                	mv	a0,s1
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e70:	8552                	mv	a0,s4
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	d64080e7          	jalr	-668(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e7a:	478d                	li	a5,3
    80001e7c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e08080e7          	jalr	-504(ra) # 80000c8a <release>
}
    80001e8a:	854a                	mv	a0,s2
    80001e8c:	70e2                	ld	ra,56(sp)
    80001e8e:	7442                	ld	s0,48(sp)
    80001e90:	74a2                	ld	s1,40(sp)
    80001e92:	7902                	ld	s2,32(sp)
    80001e94:	69e2                	ld	s3,24(sp)
    80001e96:	6a42                	ld	s4,16(sp)
    80001e98:	6aa2                	ld	s5,8(sp)
    80001e9a:	6121                	addi	sp,sp,64
    80001e9c:	8082                	ret
    return -1;
    80001e9e:	597d                	li	s2,-1
    80001ea0:	b7ed                	j	80001e8a <fork+0x128>

0000000080001ea2 <scheduler>:
{
    80001ea2:	7139                	addi	sp,sp,-64
    80001ea4:	fc06                	sd	ra,56(sp)
    80001ea6:	f822                	sd	s0,48(sp)
    80001ea8:	f426                	sd	s1,40(sp)
    80001eaa:	f04a                	sd	s2,32(sp)
    80001eac:	ec4e                	sd	s3,24(sp)
    80001eae:	e852                	sd	s4,16(sp)
    80001eb0:	e456                	sd	s5,8(sp)
    80001eb2:	e05a                	sd	s6,0(sp)
    80001eb4:	0080                	addi	s0,sp,64
    80001eb6:	8792                	mv	a5,tp
  int id = r_tp();
    80001eb8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eba:	00779a93          	slli	s5,a5,0x7
    80001ebe:	0000f717          	auipc	a4,0xf
    80001ec2:	cb270713          	addi	a4,a4,-846 # 80010b70 <pid_lock>
    80001ec6:	9756                	add	a4,a4,s5
    80001ec8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ecc:	0000f717          	auipc	a4,0xf
    80001ed0:	cdc70713          	addi	a4,a4,-804 # 80010ba8 <cpus+0x8>
    80001ed4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed6:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed8:	4b11                	li	s6,4
        c->proc = p;
    80001eda:	079e                	slli	a5,a5,0x7
    80001edc:	0000fa17          	auipc	s4,0xf
    80001ee0:	c94a0a13          	addi	s4,s4,-876 # 80010b70 <pid_lock>
    80001ee4:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee6:	00015917          	auipc	s2,0x15
    80001eea:	aba90913          	addi	s2,s2,-1350 # 800169a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef6:	10079073          	csrw	sstatus,a5
    80001efa:	0000f497          	auipc	s1,0xf
    80001efe:	0a648493          	addi	s1,s1,166 # 80010fa0 <proc>
    80001f02:	a811                	j	80001f16 <scheduler+0x74>
      release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	16848493          	addi	s1,s1,360
    80001f12:	fd248ee3          	beq	s1,s2,80001eee <scheduler+0x4c>
      acquire(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	cbe080e7          	jalr	-834(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f20:	4c9c                	lw	a5,24(s1)
    80001f22:	ff3791e3          	bne	a5,s3,80001f04 <scheduler+0x62>
        p->state = RUNNING;
    80001f26:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f2a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f2e:	06048593          	addi	a1,s1,96
    80001f32:	8556                	mv	a0,s5
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	684080e7          	jalr	1668(ra) # 800025b8 <swtch>
        c->proc = 0;
    80001f3c:	020a3823          	sd	zero,48(s4)
    80001f40:	b7d1                	j	80001f04 <scheduler+0x62>

0000000080001f42 <sched>:
{
    80001f42:	7179                	addi	sp,sp,-48
    80001f44:	f406                	sd	ra,40(sp)
    80001f46:	f022                	sd	s0,32(sp)
    80001f48:	ec26                	sd	s1,24(sp)
    80001f4a:	e84a                	sd	s2,16(sp)
    80001f4c:	e44e                	sd	s3,8(sp)
    80001f4e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f50:	00000097          	auipc	ra,0x0
    80001f54:	a5c080e7          	jalr	-1444(ra) # 800019ac <myproc>
    80001f58:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	c02080e7          	jalr	-1022(ra) # 80000b5c <holding>
    80001f62:	c93d                	beqz	a0,80001fd8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f64:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f66:	2781                	sext.w	a5,a5
    80001f68:	079e                	slli	a5,a5,0x7
    80001f6a:	0000f717          	auipc	a4,0xf
    80001f6e:	c0670713          	addi	a4,a4,-1018 # 80010b70 <pid_lock>
    80001f72:	97ba                	add	a5,a5,a4
    80001f74:	0a87a703          	lw	a4,168(a5)
    80001f78:	4785                	li	a5,1
    80001f7a:	06f71763          	bne	a4,a5,80001fe8 <sched+0xa6>
  if(p->state == RUNNING)
    80001f7e:	4c98                	lw	a4,24(s1)
    80001f80:	4791                	li	a5,4
    80001f82:	06f70b63          	beq	a4,a5,80001ff8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f8a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f8c:	efb5                	bnez	a5,80002008 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f8e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f90:	0000f917          	auipc	s2,0xf
    80001f94:	be090913          	addi	s2,s2,-1056 # 80010b70 <pid_lock>
    80001f98:	2781                	sext.w	a5,a5
    80001f9a:	079e                	slli	a5,a5,0x7
    80001f9c:	97ca                	add	a5,a5,s2
    80001f9e:	0ac7a983          	lw	s3,172(a5)
    80001fa2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fa4:	2781                	sext.w	a5,a5
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	0000f597          	auipc	a1,0xf
    80001fac:	c0058593          	addi	a1,a1,-1024 # 80010ba8 <cpus+0x8>
    80001fb0:	95be                	add	a1,a1,a5
    80001fb2:	06048513          	addi	a0,s1,96
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	602080e7          	jalr	1538(ra) # 800025b8 <swtch>
    80001fbe:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc0:	2781                	sext.w	a5,a5
    80001fc2:	079e                	slli	a5,a5,0x7
    80001fc4:	993e                	add	s2,s2,a5
    80001fc6:	0b392623          	sw	s3,172(s2)
}
    80001fca:	70a2                	ld	ra,40(sp)
    80001fcc:	7402                	ld	s0,32(sp)
    80001fce:	64e2                	ld	s1,24(sp)
    80001fd0:	6942                	ld	s2,16(sp)
    80001fd2:	69a2                	ld	s3,8(sp)
    80001fd4:	6145                	addi	sp,sp,48
    80001fd6:	8082                	ret
    panic("sched p->lock");
    80001fd8:	00006517          	auipc	a0,0x6
    80001fdc:	24050513          	addi	a0,a0,576 # 80008218 <digits+0x1d8>
    80001fe0:	ffffe097          	auipc	ra,0xffffe
    80001fe4:	560080e7          	jalr	1376(ra) # 80000540 <panic>
    panic("sched locks");
    80001fe8:	00006517          	auipc	a0,0x6
    80001fec:	24050513          	addi	a0,a0,576 # 80008228 <digits+0x1e8>
    80001ff0:	ffffe097          	auipc	ra,0xffffe
    80001ff4:	550080e7          	jalr	1360(ra) # 80000540 <panic>
    panic("sched running");
    80001ff8:	00006517          	auipc	a0,0x6
    80001ffc:	24050513          	addi	a0,a0,576 # 80008238 <digits+0x1f8>
    80002000:	ffffe097          	auipc	ra,0xffffe
    80002004:	540080e7          	jalr	1344(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002008:	00006517          	auipc	a0,0x6
    8000200c:	24050513          	addi	a0,a0,576 # 80008248 <digits+0x208>
    80002010:	ffffe097          	auipc	ra,0xffffe
    80002014:	530080e7          	jalr	1328(ra) # 80000540 <panic>

0000000080002018 <yield>:
{
    80002018:	1101                	addi	sp,sp,-32
    8000201a:	ec06                	sd	ra,24(sp)
    8000201c:	e822                	sd	s0,16(sp)
    8000201e:	e426                	sd	s1,8(sp)
    80002020:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002022:	00000097          	auipc	ra,0x0
    80002026:	98a080e7          	jalr	-1654(ra) # 800019ac <myproc>
    8000202a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	baa080e7          	jalr	-1110(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002034:	478d                	li	a5,3
    80002036:	cc9c                	sw	a5,24(s1)
  sched();
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	f0a080e7          	jalr	-246(ra) # 80001f42 <sched>
  release(&p->lock);
    80002040:	8526                	mv	a0,s1
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	c48080e7          	jalr	-952(ra) # 80000c8a <release>
}
    8000204a:	60e2                	ld	ra,24(sp)
    8000204c:	6442                	ld	s0,16(sp)
    8000204e:	64a2                	ld	s1,8(sp)
    80002050:	6105                	addi	sp,sp,32
    80002052:	8082                	ret

0000000080002054 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002054:	7179                	addi	sp,sp,-48
    80002056:	f406                	sd	ra,40(sp)
    80002058:	f022                	sd	s0,32(sp)
    8000205a:	ec26                	sd	s1,24(sp)
    8000205c:	e84a                	sd	s2,16(sp)
    8000205e:	e44e                	sd	s3,8(sp)
    80002060:	1800                	addi	s0,sp,48
    80002062:	89aa                	mv	s3,a0
    80002064:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002066:	00000097          	auipc	ra,0x0
    8000206a:	946080e7          	jalr	-1722(ra) # 800019ac <myproc>
    8000206e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	b66080e7          	jalr	-1178(ra) # 80000bd6 <acquire>
  release(lk);
    80002078:	854a                	mv	a0,s2
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	c10080e7          	jalr	-1008(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002082:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002086:	4789                	li	a5,2
    80002088:	cc9c                	sw	a5,24(s1)

  sched();
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	eb8080e7          	jalr	-328(ra) # 80001f42 <sched>

  // Tidy up.
  p->chan = 0;
    80002092:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bf2080e7          	jalr	-1038(ra) # 80000c8a <release>
  acquire(lk);
    800020a0:	854a                	mv	a0,s2
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	b34080e7          	jalr	-1228(ra) # 80000bd6 <acquire>
}
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret

00000000800020b8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020b8:	7139                	addi	sp,sp,-64
    800020ba:	fc06                	sd	ra,56(sp)
    800020bc:	f822                	sd	s0,48(sp)
    800020be:	f426                	sd	s1,40(sp)
    800020c0:	f04a                	sd	s2,32(sp)
    800020c2:	ec4e                	sd	s3,24(sp)
    800020c4:	e852                	sd	s4,16(sp)
    800020c6:	e456                	sd	s5,8(sp)
    800020c8:	0080                	addi	s0,sp,64
    800020ca:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020cc:	0000f497          	auipc	s1,0xf
    800020d0:	ed448493          	addi	s1,s1,-300 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020d4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d8:	00015917          	auipc	s2,0x15
    800020dc:	8c890913          	addi	s2,s2,-1848 # 800169a0 <tickslock>
    800020e0:	a811                	j	800020f4 <wakeup+0x3c>
      }
      release(&p->lock);
    800020e2:	8526                	mv	a0,s1
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	ba6080e7          	jalr	-1114(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ec:	16848493          	addi	s1,s1,360
    800020f0:	03248663          	beq	s1,s2,8000211c <wakeup+0x64>
    if(p != myproc()){
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	8b8080e7          	jalr	-1864(ra) # 800019ac <myproc>
    800020fc:	fea488e3          	beq	s1,a0,800020ec <wakeup+0x34>
      acquire(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	ad4080e7          	jalr	-1324(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000210a:	4c9c                	lw	a5,24(s1)
    8000210c:	fd379be3          	bne	a5,s3,800020e2 <wakeup+0x2a>
    80002110:	709c                	ld	a5,32(s1)
    80002112:	fd4798e3          	bne	a5,s4,800020e2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002116:	0154ac23          	sw	s5,24(s1)
    8000211a:	b7e1                	j	800020e2 <wakeup+0x2a>
    }
  }
}
    8000211c:	70e2                	ld	ra,56(sp)
    8000211e:	7442                	ld	s0,48(sp)
    80002120:	74a2                	ld	s1,40(sp)
    80002122:	7902                	ld	s2,32(sp)
    80002124:	69e2                	ld	s3,24(sp)
    80002126:	6a42                	ld	s4,16(sp)
    80002128:	6aa2                	ld	s5,8(sp)
    8000212a:	6121                	addi	sp,sp,64
    8000212c:	8082                	ret

000000008000212e <reparent>:
{
    8000212e:	7179                	addi	sp,sp,-48
    80002130:	f406                	sd	ra,40(sp)
    80002132:	f022                	sd	s0,32(sp)
    80002134:	ec26                	sd	s1,24(sp)
    80002136:	e84a                	sd	s2,16(sp)
    80002138:	e44e                	sd	s3,8(sp)
    8000213a:	e052                	sd	s4,0(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002140:	0000f497          	auipc	s1,0xf
    80002144:	e6048493          	addi	s1,s1,-416 # 80010fa0 <proc>
      pp->parent = initproc;
    80002148:	00006a17          	auipc	s4,0x6
    8000214c:	7b0a0a13          	addi	s4,s4,1968 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002150:	00015997          	auipc	s3,0x15
    80002154:	85098993          	addi	s3,s3,-1968 # 800169a0 <tickslock>
    80002158:	a029                	j	80002162 <reparent+0x34>
    8000215a:	16848493          	addi	s1,s1,360
    8000215e:	01348d63          	beq	s1,s3,80002178 <reparent+0x4a>
    if(pp->parent == p){
    80002162:	7c9c                	ld	a5,56(s1)
    80002164:	ff279be3          	bne	a5,s2,8000215a <reparent+0x2c>
      pp->parent = initproc;
    80002168:	000a3503          	ld	a0,0(s4)
    8000216c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000216e:	00000097          	auipc	ra,0x0
    80002172:	f4a080e7          	jalr	-182(ra) # 800020b8 <wakeup>
    80002176:	b7d5                	j	8000215a <reparent+0x2c>
}
    80002178:	70a2                	ld	ra,40(sp)
    8000217a:	7402                	ld	s0,32(sp)
    8000217c:	64e2                	ld	s1,24(sp)
    8000217e:	6942                	ld	s2,16(sp)
    80002180:	69a2                	ld	s3,8(sp)
    80002182:	6a02                	ld	s4,0(sp)
    80002184:	6145                	addi	sp,sp,48
    80002186:	8082                	ret

0000000080002188 <exit>:
{
    80002188:	7179                	addi	sp,sp,-48
    8000218a:	f406                	sd	ra,40(sp)
    8000218c:	f022                	sd	s0,32(sp)
    8000218e:	ec26                	sd	s1,24(sp)
    80002190:	e84a                	sd	s2,16(sp)
    80002192:	e44e                	sd	s3,8(sp)
    80002194:	e052                	sd	s4,0(sp)
    80002196:	1800                	addi	s0,sp,48
    80002198:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	812080e7          	jalr	-2030(ra) # 800019ac <myproc>
    800021a2:	89aa                	mv	s3,a0
  if(p == initproc)
    800021a4:	00006797          	auipc	a5,0x6
    800021a8:	7547b783          	ld	a5,1876(a5) # 800088f8 <initproc>
    800021ac:	0d050493          	addi	s1,a0,208
    800021b0:	15050913          	addi	s2,a0,336
    800021b4:	02a79363          	bne	a5,a0,800021da <exit+0x52>
    panic("init exiting");
    800021b8:	00006517          	auipc	a0,0x6
    800021bc:	0a850513          	addi	a0,a0,168 # 80008260 <digits+0x220>
    800021c0:	ffffe097          	auipc	ra,0xffffe
    800021c4:	380080e7          	jalr	896(ra) # 80000540 <panic>
      fileclose(f);
    800021c8:	00002097          	auipc	ra,0x2
    800021cc:	31a080e7          	jalr	794(ra) # 800044e2 <fileclose>
      p->ofile[fd] = 0;
    800021d0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021d4:	04a1                	addi	s1,s1,8
    800021d6:	01248563          	beq	s1,s2,800021e0 <exit+0x58>
    if(p->ofile[fd]){
    800021da:	6088                	ld	a0,0(s1)
    800021dc:	f575                	bnez	a0,800021c8 <exit+0x40>
    800021de:	bfdd                	j	800021d4 <exit+0x4c>
  begin_op();
    800021e0:	00002097          	auipc	ra,0x2
    800021e4:	e3a080e7          	jalr	-454(ra) # 8000401a <begin_op>
  iput(p->cwd);
    800021e8:	1509b503          	ld	a0,336(s3)
    800021ec:	00001097          	auipc	ra,0x1
    800021f0:	61c080e7          	jalr	1564(ra) # 80003808 <iput>
  end_op();
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	ea4080e7          	jalr	-348(ra) # 80004098 <end_op>
  p->cwd = 0;
    800021fc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002200:	0000f497          	auipc	s1,0xf
    80002204:	98848493          	addi	s1,s1,-1656 # 80010b88 <wait_lock>
    80002208:	8526                	mv	a0,s1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	9cc080e7          	jalr	-1588(ra) # 80000bd6 <acquire>
  reparent(p);
    80002212:	854e                	mv	a0,s3
    80002214:	00000097          	auipc	ra,0x0
    80002218:	f1a080e7          	jalr	-230(ra) # 8000212e <reparent>
  wakeup(p->parent);
    8000221c:	0389b503          	ld	a0,56(s3)
    80002220:	00000097          	auipc	ra,0x0
    80002224:	e98080e7          	jalr	-360(ra) # 800020b8 <wakeup>
  acquire(&p->lock);
    80002228:	854e                	mv	a0,s3
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	9ac080e7          	jalr	-1620(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002232:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002236:	4795                	li	a5,5
    80002238:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000223c:	8526                	mv	a0,s1
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	a4c080e7          	jalr	-1460(ra) # 80000c8a <release>
  sched();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	cfc080e7          	jalr	-772(ra) # 80001f42 <sched>
  panic("zombie exit");
    8000224e:	00006517          	auipc	a0,0x6
    80002252:	02250513          	addi	a0,a0,34 # 80008270 <digits+0x230>
    80002256:	ffffe097          	auipc	ra,0xffffe
    8000225a:	2ea080e7          	jalr	746(ra) # 80000540 <panic>

000000008000225e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000225e:	7179                	addi	sp,sp,-48
    80002260:	f406                	sd	ra,40(sp)
    80002262:	f022                	sd	s0,32(sp)
    80002264:	ec26                	sd	s1,24(sp)
    80002266:	e84a                	sd	s2,16(sp)
    80002268:	e44e                	sd	s3,8(sp)
    8000226a:	1800                	addi	s0,sp,48
    8000226c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000226e:	0000f497          	auipc	s1,0xf
    80002272:	d3248493          	addi	s1,s1,-718 # 80010fa0 <proc>
    80002276:	00014997          	auipc	s3,0x14
    8000227a:	72a98993          	addi	s3,s3,1834 # 800169a0 <tickslock>
    acquire(&p->lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	956080e7          	jalr	-1706(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002288:	589c                	lw	a5,48(s1)
    8000228a:	01278d63          	beq	a5,s2,800022a4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	9fa080e7          	jalr	-1542(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002298:	16848493          	addi	s1,s1,360
    8000229c:	ff3491e3          	bne	s1,s3,8000227e <kill+0x20>
  }
  return -1;
    800022a0:	557d                	li	a0,-1
    800022a2:	a829                	j	800022bc <kill+0x5e>
      p->killed = 1;
    800022a4:	4785                	li	a5,1
    800022a6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022a8:	4c98                	lw	a4,24(s1)
    800022aa:	4789                	li	a5,2
    800022ac:	00f70f63          	beq	a4,a5,800022ca <kill+0x6c>
      release(&p->lock);
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	9d8080e7          	jalr	-1576(ra) # 80000c8a <release>
      return 0;
    800022ba:	4501                	li	a0,0
}
    800022bc:	70a2                	ld	ra,40(sp)
    800022be:	7402                	ld	s0,32(sp)
    800022c0:	64e2                	ld	s1,24(sp)
    800022c2:	6942                	ld	s2,16(sp)
    800022c4:	69a2                	ld	s3,8(sp)
    800022c6:	6145                	addi	sp,sp,48
    800022c8:	8082                	ret
        p->state = RUNNABLE;
    800022ca:	478d                	li	a5,3
    800022cc:	cc9c                	sw	a5,24(s1)
    800022ce:	b7cd                	j	800022b0 <kill+0x52>

00000000800022d0 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d0:	1101                	addi	sp,sp,-32
    800022d2:	ec06                	sd	ra,24(sp)
    800022d4:	e822                	sd	s0,16(sp)
    800022d6:	e426                	sd	s1,8(sp)
    800022d8:	1000                	addi	s0,sp,32
    800022da:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	8fa080e7          	jalr	-1798(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022e4:	4785                	li	a5,1
    800022e6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	9a0080e7          	jalr	-1632(ra) # 80000c8a <release>
}
    800022f2:	60e2                	ld	ra,24(sp)
    800022f4:	6442                	ld	s0,16(sp)
    800022f6:	64a2                	ld	s1,8(sp)
    800022f8:	6105                	addi	sp,sp,32
    800022fa:	8082                	ret

00000000800022fc <killed>:

int
killed(struct proc *p)
{
    800022fc:	1101                	addi	sp,sp,-32
    800022fe:	ec06                	sd	ra,24(sp)
    80002300:	e822                	sd	s0,16(sp)
    80002302:	e426                	sd	s1,8(sp)
    80002304:	e04a                	sd	s2,0(sp)
    80002306:	1000                	addi	s0,sp,32
    80002308:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	8cc080e7          	jalr	-1844(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002312:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	972080e7          	jalr	-1678(ra) # 80000c8a <release>
  return k;
}
    80002320:	854a                	mv	a0,s2
    80002322:	60e2                	ld	ra,24(sp)
    80002324:	6442                	ld	s0,16(sp)
    80002326:	64a2                	ld	s1,8(sp)
    80002328:	6902                	ld	s2,0(sp)
    8000232a:	6105                	addi	sp,sp,32
    8000232c:	8082                	ret

000000008000232e <wait>:
{
    8000232e:	715d                	addi	sp,sp,-80
    80002330:	e486                	sd	ra,72(sp)
    80002332:	e0a2                	sd	s0,64(sp)
    80002334:	fc26                	sd	s1,56(sp)
    80002336:	f84a                	sd	s2,48(sp)
    80002338:	f44e                	sd	s3,40(sp)
    8000233a:	f052                	sd	s4,32(sp)
    8000233c:	ec56                	sd	s5,24(sp)
    8000233e:	e85a                	sd	s6,16(sp)
    80002340:	e45e                	sd	s7,8(sp)
    80002342:	e062                	sd	s8,0(sp)
    80002344:	0880                	addi	s0,sp,80
    80002346:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	664080e7          	jalr	1636(ra) # 800019ac <myproc>
    80002350:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002352:	0000f517          	auipc	a0,0xf
    80002356:	83650513          	addi	a0,a0,-1994 # 80010b88 <wait_lock>
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	87c080e7          	jalr	-1924(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002362:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002364:	4a15                	li	s4,5
        havekids = 1;
    80002366:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002368:	00014997          	auipc	s3,0x14
    8000236c:	63898993          	addi	s3,s3,1592 # 800169a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002370:	0000fc17          	auipc	s8,0xf
    80002374:	818c0c13          	addi	s8,s8,-2024 # 80010b88 <wait_lock>
    havekids = 0;
    80002378:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000237a:	0000f497          	auipc	s1,0xf
    8000237e:	c2648493          	addi	s1,s1,-986 # 80010fa0 <proc>
    80002382:	a0bd                	j	800023f0 <wait+0xc2>
          pid = pp->pid;
    80002384:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002388:	000b0e63          	beqz	s6,800023a4 <wait+0x76>
    8000238c:	4691                	li	a3,4
    8000238e:	02c48613          	addi	a2,s1,44
    80002392:	85da                	mv	a1,s6
    80002394:	05093503          	ld	a0,80(s2)
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	2d4080e7          	jalr	724(ra) # 8000166c <copyout>
    800023a0:	02054563          	bltz	a0,800023ca <wait+0x9c>
          freeproc(pp);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	7b8080e7          	jalr	1976(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8da080e7          	jalr	-1830(ra) # 80000c8a <release>
          release(&wait_lock);
    800023b8:	0000e517          	auipc	a0,0xe
    800023bc:	7d050513          	addi	a0,a0,2000 # 80010b88 <wait_lock>
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	8ca080e7          	jalr	-1846(ra) # 80000c8a <release>
          return pid;
    800023c8:	a0b5                	j	80002434 <wait+0x106>
            release(&pp->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8be080e7          	jalr	-1858(ra) # 80000c8a <release>
            release(&wait_lock);
    800023d4:	0000e517          	auipc	a0,0xe
    800023d8:	7b450513          	addi	a0,a0,1972 # 80010b88 <wait_lock>
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
            return -1;
    800023e4:	59fd                	li	s3,-1
    800023e6:	a0b9                	j	80002434 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e8:	16848493          	addi	s1,s1,360
    800023ec:	03348463          	beq	s1,s3,80002414 <wait+0xe6>
      if(pp->parent == p){
    800023f0:	7c9c                	ld	a5,56(s1)
    800023f2:	ff279be3          	bne	a5,s2,800023e8 <wait+0xba>
        acquire(&pp->lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	7de080e7          	jalr	2014(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002400:	4c9c                	lw	a5,24(s1)
    80002402:	f94781e3          	beq	a5,s4,80002384 <wait+0x56>
        release(&pp->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	882080e7          	jalr	-1918(ra) # 80000c8a <release>
        havekids = 1;
    80002410:	8756                	mv	a4,s5
    80002412:	bfd9                	j	800023e8 <wait+0xba>
    if(!havekids || killed(p)){
    80002414:	c719                	beqz	a4,80002422 <wait+0xf4>
    80002416:	854a                	mv	a0,s2
    80002418:	00000097          	auipc	ra,0x0
    8000241c:	ee4080e7          	jalr	-284(ra) # 800022fc <killed>
    80002420:	c51d                	beqz	a0,8000244e <wait+0x120>
      release(&wait_lock);
    80002422:	0000e517          	auipc	a0,0xe
    80002426:	76650513          	addi	a0,a0,1894 # 80010b88 <wait_lock>
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	860080e7          	jalr	-1952(ra) # 80000c8a <release>
      return -1;
    80002432:	59fd                	li	s3,-1
}
    80002434:	854e                	mv	a0,s3
    80002436:	60a6                	ld	ra,72(sp)
    80002438:	6406                	ld	s0,64(sp)
    8000243a:	74e2                	ld	s1,56(sp)
    8000243c:	7942                	ld	s2,48(sp)
    8000243e:	79a2                	ld	s3,40(sp)
    80002440:	7a02                	ld	s4,32(sp)
    80002442:	6ae2                	ld	s5,24(sp)
    80002444:	6b42                	ld	s6,16(sp)
    80002446:	6ba2                	ld	s7,8(sp)
    80002448:	6c02                	ld	s8,0(sp)
    8000244a:	6161                	addi	sp,sp,80
    8000244c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000244e:	85e2                	mv	a1,s8
    80002450:	854a                	mv	a0,s2
    80002452:	00000097          	auipc	ra,0x0
    80002456:	c02080e7          	jalr	-1022(ra) # 80002054 <sleep>
    havekids = 0;
    8000245a:	bf39                	j	80002378 <wait+0x4a>

000000008000245c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000245c:	7179                	addi	sp,sp,-48
    8000245e:	f406                	sd	ra,40(sp)
    80002460:	f022                	sd	s0,32(sp)
    80002462:	ec26                	sd	s1,24(sp)
    80002464:	e84a                	sd	s2,16(sp)
    80002466:	e44e                	sd	s3,8(sp)
    80002468:	e052                	sd	s4,0(sp)
    8000246a:	1800                	addi	s0,sp,48
    8000246c:	84aa                	mv	s1,a0
    8000246e:	892e                	mv	s2,a1
    80002470:	89b2                	mv	s3,a2
    80002472:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	538080e7          	jalr	1336(ra) # 800019ac <myproc>
  if(user_dst){
    8000247c:	c08d                	beqz	s1,8000249e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000247e:	86d2                	mv	a3,s4
    80002480:	864e                	mv	a2,s3
    80002482:	85ca                	mv	a1,s2
    80002484:	6928                	ld	a0,80(a0)
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	1e6080e7          	jalr	486(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000248e:	70a2                	ld	ra,40(sp)
    80002490:	7402                	ld	s0,32(sp)
    80002492:	64e2                	ld	s1,24(sp)
    80002494:	6942                	ld	s2,16(sp)
    80002496:	69a2                	ld	s3,8(sp)
    80002498:	6a02                	ld	s4,0(sp)
    8000249a:	6145                	addi	sp,sp,48
    8000249c:	8082                	ret
    memmove((char *)dst, src, len);
    8000249e:	000a061b          	sext.w	a2,s4
    800024a2:	85ce                	mv	a1,s3
    800024a4:	854a                	mv	a0,s2
    800024a6:	fffff097          	auipc	ra,0xfffff
    800024aa:	888080e7          	jalr	-1912(ra) # 80000d2e <memmove>
    return 0;
    800024ae:	8526                	mv	a0,s1
    800024b0:	bff9                	j	8000248e <either_copyout+0x32>

00000000800024b2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b2:	7179                	addi	sp,sp,-48
    800024b4:	f406                	sd	ra,40(sp)
    800024b6:	f022                	sd	s0,32(sp)
    800024b8:	ec26                	sd	s1,24(sp)
    800024ba:	e84a                	sd	s2,16(sp)
    800024bc:	e44e                	sd	s3,8(sp)
    800024be:	e052                	sd	s4,0(sp)
    800024c0:	1800                	addi	s0,sp,48
    800024c2:	892a                	mv	s2,a0
    800024c4:	84ae                	mv	s1,a1
    800024c6:	89b2                	mv	s3,a2
    800024c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	4e2080e7          	jalr	1250(ra) # 800019ac <myproc>
  if(user_src){
    800024d2:	c08d                	beqz	s1,800024f4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024d4:	86d2                	mv	a3,s4
    800024d6:	864e                	mv	a2,s3
    800024d8:	85ca                	mv	a1,s2
    800024da:	6928                	ld	a0,80(a0)
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	21c080e7          	jalr	540(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024e4:	70a2                	ld	ra,40(sp)
    800024e6:	7402                	ld	s0,32(sp)
    800024e8:	64e2                	ld	s1,24(sp)
    800024ea:	6942                	ld	s2,16(sp)
    800024ec:	69a2                	ld	s3,8(sp)
    800024ee:	6a02                	ld	s4,0(sp)
    800024f0:	6145                	addi	sp,sp,48
    800024f2:	8082                	ret
    memmove(dst, (char*)src, len);
    800024f4:	000a061b          	sext.w	a2,s4
    800024f8:	85ce                	mv	a1,s3
    800024fa:	854a                	mv	a0,s2
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	832080e7          	jalr	-1998(ra) # 80000d2e <memmove>
    return 0;
    80002504:	8526                	mv	a0,s1
    80002506:	bff9                	j	800024e4 <either_copyin+0x32>

0000000080002508 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002508:	715d                	addi	sp,sp,-80
    8000250a:	e486                	sd	ra,72(sp)
    8000250c:	e0a2                	sd	s0,64(sp)
    8000250e:	fc26                	sd	s1,56(sp)
    80002510:	f84a                	sd	s2,48(sp)
    80002512:	f44e                	sd	s3,40(sp)
    80002514:	f052                	sd	s4,32(sp)
    80002516:	ec56                	sd	s5,24(sp)
    80002518:	e85a                	sd	s6,16(sp)
    8000251a:	e45e                	sd	s7,8(sp)
    8000251c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000251e:	00006517          	auipc	a0,0x6
    80002522:	baa50513          	addi	a0,a0,-1110 # 800080c8 <digits+0x88>
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	064080e7          	jalr	100(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000252e:	0000f497          	auipc	s1,0xf
    80002532:	bca48493          	addi	s1,s1,-1078 # 800110f8 <proc+0x158>
    80002536:	00014917          	auipc	s2,0x14
    8000253a:	5c290913          	addi	s2,s2,1474 # 80016af8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002540:	00006997          	auipc	s3,0x6
    80002544:	d4098993          	addi	s3,s3,-704 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002548:	00006a97          	auipc	s5,0x6
    8000254c:	d40a8a93          	addi	s5,s5,-704 # 80008288 <digits+0x248>
    printf("\n");
    80002550:	00006a17          	auipc	s4,0x6
    80002554:	b78a0a13          	addi	s4,s4,-1160 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002558:	00006b97          	auipc	s7,0x6
    8000255c:	d70b8b93          	addi	s7,s7,-656 # 800082c8 <states.0>
    80002560:	a00d                	j	80002582 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002562:	ed86a583          	lw	a1,-296(a3)
    80002566:	8556                	mv	a0,s5
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	022080e7          	jalr	34(ra) # 8000058a <printf>
    printf("\n");
    80002570:	8552                	mv	a0,s4
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	018080e7          	jalr	24(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257a:	16848493          	addi	s1,s1,360
    8000257e:	03248263          	beq	s1,s2,800025a2 <procdump+0x9a>
    if(p->state == UNUSED)
    80002582:	86a6                	mv	a3,s1
    80002584:	ec04a783          	lw	a5,-320(s1)
    80002588:	dbed                	beqz	a5,8000257a <procdump+0x72>
      state = "???";
    8000258a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258c:	fcfb6be3          	bltu	s6,a5,80002562 <procdump+0x5a>
    80002590:	02079713          	slli	a4,a5,0x20
    80002594:	01d75793          	srli	a5,a4,0x1d
    80002598:	97de                	add	a5,a5,s7
    8000259a:	6390                	ld	a2,0(a5)
    8000259c:	f279                	bnez	a2,80002562 <procdump+0x5a>
      state = "???";
    8000259e:	864e                	mv	a2,s3
    800025a0:	b7c9                	j	80002562 <procdump+0x5a>
  }
}
    800025a2:	60a6                	ld	ra,72(sp)
    800025a4:	6406                	ld	s0,64(sp)
    800025a6:	74e2                	ld	s1,56(sp)
    800025a8:	7942                	ld	s2,48(sp)
    800025aa:	79a2                	ld	s3,40(sp)
    800025ac:	7a02                	ld	s4,32(sp)
    800025ae:	6ae2                	ld	s5,24(sp)
    800025b0:	6b42                	ld	s6,16(sp)
    800025b2:	6ba2                	ld	s7,8(sp)
    800025b4:	6161                	addi	sp,sp,80
    800025b6:	8082                	ret

00000000800025b8 <swtch>:
    800025b8:	00153023          	sd	ra,0(a0)
    800025bc:	00253423          	sd	sp,8(a0)
    800025c0:	e900                	sd	s0,16(a0)
    800025c2:	ed04                	sd	s1,24(a0)
    800025c4:	03253023          	sd	s2,32(a0)
    800025c8:	03353423          	sd	s3,40(a0)
    800025cc:	03453823          	sd	s4,48(a0)
    800025d0:	03553c23          	sd	s5,56(a0)
    800025d4:	05653023          	sd	s6,64(a0)
    800025d8:	05753423          	sd	s7,72(a0)
    800025dc:	05853823          	sd	s8,80(a0)
    800025e0:	05953c23          	sd	s9,88(a0)
    800025e4:	07a53023          	sd	s10,96(a0)
    800025e8:	07b53423          	sd	s11,104(a0)
    800025ec:	0005b083          	ld	ra,0(a1)
    800025f0:	0085b103          	ld	sp,8(a1)
    800025f4:	6980                	ld	s0,16(a1)
    800025f6:	6d84                	ld	s1,24(a1)
    800025f8:	0205b903          	ld	s2,32(a1)
    800025fc:	0285b983          	ld	s3,40(a1)
    80002600:	0305ba03          	ld	s4,48(a1)
    80002604:	0385ba83          	ld	s5,56(a1)
    80002608:	0405bb03          	ld	s6,64(a1)
    8000260c:	0485bb83          	ld	s7,72(a1)
    80002610:	0505bc03          	ld	s8,80(a1)
    80002614:	0585bc83          	ld	s9,88(a1)
    80002618:	0605bd03          	ld	s10,96(a1)
    8000261c:	0685bd83          	ld	s11,104(a1)
    80002620:	8082                	ret

0000000080002622 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002622:	1141                	addi	sp,sp,-16
    80002624:	e406                	sd	ra,8(sp)
    80002626:	e022                	sd	s0,0(sp)
    80002628:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000262a:	00006597          	auipc	a1,0x6
    8000262e:	cce58593          	addi	a1,a1,-818 # 800082f8 <states.0+0x30>
    80002632:	00014517          	auipc	a0,0x14
    80002636:	36e50513          	addi	a0,a0,878 # 800169a0 <tickslock>
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	50c080e7          	jalr	1292(ra) # 80000b46 <initlock>
}
    80002642:	60a2                	ld	ra,8(sp)
    80002644:	6402                	ld	s0,0(sp)
    80002646:	0141                	addi	sp,sp,16
    80002648:	8082                	ret

000000008000264a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000264a:	1141                	addi	sp,sp,-16
    8000264c:	e422                	sd	s0,8(sp)
    8000264e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002650:	00003797          	auipc	a5,0x3
    80002654:	4e078793          	addi	a5,a5,1248 # 80005b30 <kernelvec>
    80002658:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000265c:	6422                	ld	s0,8(sp)
    8000265e:	0141                	addi	sp,sp,16
    80002660:	8082                	ret

0000000080002662 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002662:	1141                	addi	sp,sp,-16
    80002664:	e406                	sd	ra,8(sp)
    80002666:	e022                	sd	s0,0(sp)
    80002668:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000266a:	fffff097          	auipc	ra,0xfffff
    8000266e:	342080e7          	jalr	834(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002672:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002676:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002678:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000267c:	00005697          	auipc	a3,0x5
    80002680:	98468693          	addi	a3,a3,-1660 # 80007000 <_trampoline>
    80002684:	00005717          	auipc	a4,0x5
    80002688:	97c70713          	addi	a4,a4,-1668 # 80007000 <_trampoline>
    8000268c:	8f15                	sub	a4,a4,a3
    8000268e:	040007b7          	lui	a5,0x4000
    80002692:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002694:	07b2                	slli	a5,a5,0xc
    80002696:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002698:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000269c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000269e:	18002673          	csrr	a2,satp
    800026a2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026a4:	6d30                	ld	a2,88(a0)
    800026a6:	6138                	ld	a4,64(a0)
    800026a8:	6585                	lui	a1,0x1
    800026aa:	972e                	add	a4,a4,a1
    800026ac:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026ae:	6d38                	ld	a4,88(a0)
    800026b0:	00000617          	auipc	a2,0x0
    800026b4:	13060613          	addi	a2,a2,304 # 800027e0 <usertrap>
    800026b8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026ba:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026bc:	8612                	mv	a2,tp
    800026be:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026c4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026c8:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026cc:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026d0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026d2:	6f18                	ld	a4,24(a4)
    800026d4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026d8:	6928                	ld	a0,80(a0)
    800026da:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026dc:	00005717          	auipc	a4,0x5
    800026e0:	9c070713          	addi	a4,a4,-1600 # 8000709c <userret>
    800026e4:	8f15                	sub	a4,a4,a3
    800026e6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026e8:	577d                	li	a4,-1
    800026ea:	177e                	slli	a4,a4,0x3f
    800026ec:	8d59                	or	a0,a0,a4
    800026ee:	9782                	jalr	a5
}
    800026f0:	60a2                	ld	ra,8(sp)
    800026f2:	6402                	ld	s0,0(sp)
    800026f4:	0141                	addi	sp,sp,16
    800026f6:	8082                	ret

00000000800026f8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026f8:	1101                	addi	sp,sp,-32
    800026fa:	ec06                	sd	ra,24(sp)
    800026fc:	e822                	sd	s0,16(sp)
    800026fe:	e426                	sd	s1,8(sp)
    80002700:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002702:	00014497          	auipc	s1,0x14
    80002706:	29e48493          	addi	s1,s1,670 # 800169a0 <tickslock>
    8000270a:	8526                	mv	a0,s1
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	4ca080e7          	jalr	1226(ra) # 80000bd6 <acquire>
  ticks++;
    80002714:	00006517          	auipc	a0,0x6
    80002718:	1ec50513          	addi	a0,a0,492 # 80008900 <ticks>
    8000271c:	411c                	lw	a5,0(a0)
    8000271e:	2785                	addiw	a5,a5,1
    80002720:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002722:	00000097          	auipc	ra,0x0
    80002726:	996080e7          	jalr	-1642(ra) # 800020b8 <wakeup>
  release(&tickslock);
    8000272a:	8526                	mv	a0,s1
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	55e080e7          	jalr	1374(ra) # 80000c8a <release>
}
    80002734:	60e2                	ld	ra,24(sp)
    80002736:	6442                	ld	s0,16(sp)
    80002738:	64a2                	ld	s1,8(sp)
    8000273a:	6105                	addi	sp,sp,32
    8000273c:	8082                	ret

000000008000273e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000273e:	1101                	addi	sp,sp,-32
    80002740:	ec06                	sd	ra,24(sp)
    80002742:	e822                	sd	s0,16(sp)
    80002744:	e426                	sd	s1,8(sp)
    80002746:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002748:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000274c:	00074d63          	bltz	a4,80002766 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002750:	57fd                	li	a5,-1
    80002752:	17fe                	slli	a5,a5,0x3f
    80002754:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002756:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002758:	06f70363          	beq	a4,a5,800027be <devintr+0x80>
  }
}
    8000275c:	60e2                	ld	ra,24(sp)
    8000275e:	6442                	ld	s0,16(sp)
    80002760:	64a2                	ld	s1,8(sp)
    80002762:	6105                	addi	sp,sp,32
    80002764:	8082                	ret
     (scause & 0xff) == 9){
    80002766:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    8000276a:	46a5                	li	a3,9
    8000276c:	fed792e3          	bne	a5,a3,80002750 <devintr+0x12>
    int irq = plic_claim();
    80002770:	00003097          	auipc	ra,0x3
    80002774:	4c8080e7          	jalr	1224(ra) # 80005c38 <plic_claim>
    80002778:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000277a:	47a9                	li	a5,10
    8000277c:	02f50763          	beq	a0,a5,800027aa <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002780:	4785                	li	a5,1
    80002782:	02f50963          	beq	a0,a5,800027b4 <devintr+0x76>
    return 1;
    80002786:	4505                	li	a0,1
    } else if(irq){
    80002788:	d8f1                	beqz	s1,8000275c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000278a:	85a6                	mv	a1,s1
    8000278c:	00006517          	auipc	a0,0x6
    80002790:	b7450513          	addi	a0,a0,-1164 # 80008300 <states.0+0x38>
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	df6080e7          	jalr	-522(ra) # 8000058a <printf>
      plic_complete(irq);
    8000279c:	8526                	mv	a0,s1
    8000279e:	00003097          	auipc	ra,0x3
    800027a2:	4be080e7          	jalr	1214(ra) # 80005c5c <plic_complete>
    return 1;
    800027a6:	4505                	li	a0,1
    800027a8:	bf55                	j	8000275c <devintr+0x1e>
      uartintr();
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	1ee080e7          	jalr	494(ra) # 80000998 <uartintr>
    800027b2:	b7ed                	j	8000279c <devintr+0x5e>
      virtio_disk_intr();
    800027b4:	00004097          	auipc	ra,0x4
    800027b8:	970080e7          	jalr	-1680(ra) # 80006124 <virtio_disk_intr>
    800027bc:	b7c5                	j	8000279c <devintr+0x5e>
    if(cpuid() == 0){
    800027be:	fffff097          	auipc	ra,0xfffff
    800027c2:	1c2080e7          	jalr	450(ra) # 80001980 <cpuid>
    800027c6:	c901                	beqz	a0,800027d6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027c8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027cc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027ce:	14479073          	csrw	sip,a5
    return 2;
    800027d2:	4509                	li	a0,2
    800027d4:	b761                	j	8000275c <devintr+0x1e>
      clockintr();
    800027d6:	00000097          	auipc	ra,0x0
    800027da:	f22080e7          	jalr	-222(ra) # 800026f8 <clockintr>
    800027de:	b7ed                	j	800027c8 <devintr+0x8a>

00000000800027e0 <usertrap>:
{
    800027e0:	1101                	addi	sp,sp,-32
    800027e2:	ec06                	sd	ra,24(sp)
    800027e4:	e822                	sd	s0,16(sp)
    800027e6:	e426                	sd	s1,8(sp)
    800027e8:	e04a                	sd	s2,0(sp)
    800027ea:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ec:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027f0:	1007f793          	andi	a5,a5,256
    800027f4:	e3b1                	bnez	a5,80002838 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027f6:	00003797          	auipc	a5,0x3
    800027fa:	33a78793          	addi	a5,a5,826 # 80005b30 <kernelvec>
    800027fe:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002802:	fffff097          	auipc	ra,0xfffff
    80002806:	1aa080e7          	jalr	426(ra) # 800019ac <myproc>
    8000280a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000280c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000280e:	14102773          	csrr	a4,sepc
    80002812:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002814:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002818:	47a1                	li	a5,8
    8000281a:	02f70763          	beq	a4,a5,80002848 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000281e:	00000097          	auipc	ra,0x0
    80002822:	f20080e7          	jalr	-224(ra) # 8000273e <devintr>
    80002826:	892a                	mv	s2,a0
    80002828:	c151                	beqz	a0,800028ac <usertrap+0xcc>
  if(killed(p))
    8000282a:	8526                	mv	a0,s1
    8000282c:	00000097          	auipc	ra,0x0
    80002830:	ad0080e7          	jalr	-1328(ra) # 800022fc <killed>
    80002834:	c929                	beqz	a0,80002886 <usertrap+0xa6>
    80002836:	a099                	j	8000287c <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002838:	00006517          	auipc	a0,0x6
    8000283c:	ae850513          	addi	a0,a0,-1304 # 80008320 <states.0+0x58>
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	d00080e7          	jalr	-768(ra) # 80000540 <panic>
    if(killed(p))
    80002848:	00000097          	auipc	ra,0x0
    8000284c:	ab4080e7          	jalr	-1356(ra) # 800022fc <killed>
    80002850:	e921                	bnez	a0,800028a0 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002852:	6cb8                	ld	a4,88(s1)
    80002854:	6f1c                	ld	a5,24(a4)
    80002856:	0791                	addi	a5,a5,4
    80002858:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000285e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002862:	10079073          	csrw	sstatus,a5
    syscall();
    80002866:	00000097          	auipc	ra,0x0
    8000286a:	2d4080e7          	jalr	724(ra) # 80002b3a <syscall>
  if(killed(p))
    8000286e:	8526                	mv	a0,s1
    80002870:	00000097          	auipc	ra,0x0
    80002874:	a8c080e7          	jalr	-1396(ra) # 800022fc <killed>
    80002878:	c911                	beqz	a0,8000288c <usertrap+0xac>
    8000287a:	4901                	li	s2,0
    exit(-1);
    8000287c:	557d                	li	a0,-1
    8000287e:	00000097          	auipc	ra,0x0
    80002882:	90a080e7          	jalr	-1782(ra) # 80002188 <exit>
  if(which_dev == 2)
    80002886:	4789                	li	a5,2
    80002888:	04f90f63          	beq	s2,a5,800028e6 <usertrap+0x106>
  usertrapret();
    8000288c:	00000097          	auipc	ra,0x0
    80002890:	dd6080e7          	jalr	-554(ra) # 80002662 <usertrapret>
}
    80002894:	60e2                	ld	ra,24(sp)
    80002896:	6442                	ld	s0,16(sp)
    80002898:	64a2                	ld	s1,8(sp)
    8000289a:	6902                	ld	s2,0(sp)
    8000289c:	6105                	addi	sp,sp,32
    8000289e:	8082                	ret
      exit(-1);
    800028a0:	557d                	li	a0,-1
    800028a2:	00000097          	auipc	ra,0x0
    800028a6:	8e6080e7          	jalr	-1818(ra) # 80002188 <exit>
    800028aa:	b765                	j	80002852 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ac:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028b0:	5890                	lw	a2,48(s1)
    800028b2:	00006517          	auipc	a0,0x6
    800028b6:	a8e50513          	addi	a0,a0,-1394 # 80008340 <states.0+0x78>
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	cd0080e7          	jalr	-816(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028c6:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028ca:	00006517          	auipc	a0,0x6
    800028ce:	aa650513          	addi	a0,a0,-1370 # 80008370 <states.0+0xa8>
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	cb8080e7          	jalr	-840(ra) # 8000058a <printf>
    setkilled(p);
    800028da:	8526                	mv	a0,s1
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	9f4080e7          	jalr	-1548(ra) # 800022d0 <setkilled>
    800028e4:	b769                	j	8000286e <usertrap+0x8e>
    yield();
    800028e6:	fffff097          	auipc	ra,0xfffff
    800028ea:	732080e7          	jalr	1842(ra) # 80002018 <yield>
    800028ee:	bf79                	j	8000288c <usertrap+0xac>

00000000800028f0 <kerneltrap>:
{
    800028f0:	7179                	addi	sp,sp,-48
    800028f2:	f406                	sd	ra,40(sp)
    800028f4:	f022                	sd	s0,32(sp)
    800028f6:	ec26                	sd	s1,24(sp)
    800028f8:	e84a                	sd	s2,16(sp)
    800028fa:	e44e                	sd	s3,8(sp)
    800028fc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028fe:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002902:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002906:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000290a:	1004f793          	andi	a5,s1,256
    8000290e:	cb85                	beqz	a5,8000293e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002910:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002914:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002916:	ef85                	bnez	a5,8000294e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002918:	00000097          	auipc	ra,0x0
    8000291c:	e26080e7          	jalr	-474(ra) # 8000273e <devintr>
    80002920:	cd1d                	beqz	a0,8000295e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002922:	4789                	li	a5,2
    80002924:	06f50a63          	beq	a0,a5,80002998 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002928:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292c:	10049073          	csrw	sstatus,s1
}
    80002930:	70a2                	ld	ra,40(sp)
    80002932:	7402                	ld	s0,32(sp)
    80002934:	64e2                	ld	s1,24(sp)
    80002936:	6942                	ld	s2,16(sp)
    80002938:	69a2                	ld	s3,8(sp)
    8000293a:	6145                	addi	sp,sp,48
    8000293c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000293e:	00006517          	auipc	a0,0x6
    80002942:	a5250513          	addi	a0,a0,-1454 # 80008390 <states.0+0xc8>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	bfa080e7          	jalr	-1030(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    8000294e:	00006517          	auipc	a0,0x6
    80002952:	a6a50513          	addi	a0,a0,-1430 # 800083b8 <states.0+0xf0>
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	bea080e7          	jalr	-1046(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    8000295e:	85ce                	mv	a1,s3
    80002960:	00006517          	auipc	a0,0x6
    80002964:	a7850513          	addi	a0,a0,-1416 # 800083d8 <states.0+0x110>
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	c22080e7          	jalr	-990(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002970:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002974:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002978:	00006517          	auipc	a0,0x6
    8000297c:	a7050513          	addi	a0,a0,-1424 # 800083e8 <states.0+0x120>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	c0a080e7          	jalr	-1014(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	a7850513          	addi	a0,a0,-1416 # 80008400 <states.0+0x138>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	bb0080e7          	jalr	-1104(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002998:	fffff097          	auipc	ra,0xfffff
    8000299c:	014080e7          	jalr	20(ra) # 800019ac <myproc>
    800029a0:	d541                	beqz	a0,80002928 <kerneltrap+0x38>
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	00a080e7          	jalr	10(ra) # 800019ac <myproc>
    800029aa:	4d18                	lw	a4,24(a0)
    800029ac:	4791                	li	a5,4
    800029ae:	f6f71de3          	bne	a4,a5,80002928 <kerneltrap+0x38>
    yield();
    800029b2:	fffff097          	auipc	ra,0xfffff
    800029b6:	666080e7          	jalr	1638(ra) # 80002018 <yield>
    800029ba:	b7bd                	j	80002928 <kerneltrap+0x38>

00000000800029bc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029bc:	1101                	addi	sp,sp,-32
    800029be:	ec06                	sd	ra,24(sp)
    800029c0:	e822                	sd	s0,16(sp)
    800029c2:	e426                	sd	s1,8(sp)
    800029c4:	1000                	addi	s0,sp,32
    800029c6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	fe4080e7          	jalr	-28(ra) # 800019ac <myproc>
  switch (n) {
    800029d0:	4795                	li	a5,5
    800029d2:	0497e163          	bltu	a5,s1,80002a14 <argraw+0x58>
    800029d6:	048a                	slli	s1,s1,0x2
    800029d8:	00006717          	auipc	a4,0x6
    800029dc:	a6070713          	addi	a4,a4,-1440 # 80008438 <states.0+0x170>
    800029e0:	94ba                	add	s1,s1,a4
    800029e2:	409c                	lw	a5,0(s1)
    800029e4:	97ba                	add	a5,a5,a4
    800029e6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029e8:	6d3c                	ld	a5,88(a0)
    800029ea:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029ec:	60e2                	ld	ra,24(sp)
    800029ee:	6442                	ld	s0,16(sp)
    800029f0:	64a2                	ld	s1,8(sp)
    800029f2:	6105                	addi	sp,sp,32
    800029f4:	8082                	ret
    return p->trapframe->a1;
    800029f6:	6d3c                	ld	a5,88(a0)
    800029f8:	7fa8                	ld	a0,120(a5)
    800029fa:	bfcd                	j	800029ec <argraw+0x30>
    return p->trapframe->a2;
    800029fc:	6d3c                	ld	a5,88(a0)
    800029fe:	63c8                	ld	a0,128(a5)
    80002a00:	b7f5                	j	800029ec <argraw+0x30>
    return p->trapframe->a3;
    80002a02:	6d3c                	ld	a5,88(a0)
    80002a04:	67c8                	ld	a0,136(a5)
    80002a06:	b7dd                	j	800029ec <argraw+0x30>
    return p->trapframe->a4;
    80002a08:	6d3c                	ld	a5,88(a0)
    80002a0a:	6bc8                	ld	a0,144(a5)
    80002a0c:	b7c5                	j	800029ec <argraw+0x30>
    return p->trapframe->a5;
    80002a0e:	6d3c                	ld	a5,88(a0)
    80002a10:	6fc8                	ld	a0,152(a5)
    80002a12:	bfe9                	j	800029ec <argraw+0x30>
  panic("argraw");
    80002a14:	00006517          	auipc	a0,0x6
    80002a18:	9fc50513          	addi	a0,a0,-1540 # 80008410 <states.0+0x148>
    80002a1c:	ffffe097          	auipc	ra,0xffffe
    80002a20:	b24080e7          	jalr	-1244(ra) # 80000540 <panic>

0000000080002a24 <fetchaddr>:
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	e426                	sd	s1,8(sp)
    80002a2c:	e04a                	sd	s2,0(sp)
    80002a2e:	1000                	addi	s0,sp,32
    80002a30:	84aa                	mv	s1,a0
    80002a32:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a34:	fffff097          	auipc	ra,0xfffff
    80002a38:	f78080e7          	jalr	-136(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a3c:	653c                	ld	a5,72(a0)
    80002a3e:	02f4f863          	bgeu	s1,a5,80002a6e <fetchaddr+0x4a>
    80002a42:	00848713          	addi	a4,s1,8
    80002a46:	02e7e663          	bltu	a5,a4,80002a72 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a4a:	46a1                	li	a3,8
    80002a4c:	8626                	mv	a2,s1
    80002a4e:	85ca                	mv	a1,s2
    80002a50:	6928                	ld	a0,80(a0)
    80002a52:	fffff097          	auipc	ra,0xfffff
    80002a56:	ca6080e7          	jalr	-858(ra) # 800016f8 <copyin>
    80002a5a:	00a03533          	snez	a0,a0
    80002a5e:	40a00533          	neg	a0,a0
}
    80002a62:	60e2                	ld	ra,24(sp)
    80002a64:	6442                	ld	s0,16(sp)
    80002a66:	64a2                	ld	s1,8(sp)
    80002a68:	6902                	ld	s2,0(sp)
    80002a6a:	6105                	addi	sp,sp,32
    80002a6c:	8082                	ret
    return -1;
    80002a6e:	557d                	li	a0,-1
    80002a70:	bfcd                	j	80002a62 <fetchaddr+0x3e>
    80002a72:	557d                	li	a0,-1
    80002a74:	b7fd                	j	80002a62 <fetchaddr+0x3e>

0000000080002a76 <fetchstr>:
{
    80002a76:	7179                	addi	sp,sp,-48
    80002a78:	f406                	sd	ra,40(sp)
    80002a7a:	f022                	sd	s0,32(sp)
    80002a7c:	ec26                	sd	s1,24(sp)
    80002a7e:	e84a                	sd	s2,16(sp)
    80002a80:	e44e                	sd	s3,8(sp)
    80002a82:	1800                	addi	s0,sp,48
    80002a84:	892a                	mv	s2,a0
    80002a86:	84ae                	mv	s1,a1
    80002a88:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	f22080e7          	jalr	-222(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a92:	86ce                	mv	a3,s3
    80002a94:	864a                	mv	a2,s2
    80002a96:	85a6                	mv	a1,s1
    80002a98:	6928                	ld	a0,80(a0)
    80002a9a:	fffff097          	auipc	ra,0xfffff
    80002a9e:	cec080e7          	jalr	-788(ra) # 80001786 <copyinstr>
    80002aa2:	00054e63          	bltz	a0,80002abe <fetchstr+0x48>
  return strlen(buf);
    80002aa6:	8526                	mv	a0,s1
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	3a6080e7          	jalr	934(ra) # 80000e4e <strlen>
}
    80002ab0:	70a2                	ld	ra,40(sp)
    80002ab2:	7402                	ld	s0,32(sp)
    80002ab4:	64e2                	ld	s1,24(sp)
    80002ab6:	6942                	ld	s2,16(sp)
    80002ab8:	69a2                	ld	s3,8(sp)
    80002aba:	6145                	addi	sp,sp,48
    80002abc:	8082                	ret
    return -1;
    80002abe:	557d                	li	a0,-1
    80002ac0:	bfc5                	j	80002ab0 <fetchstr+0x3a>

0000000080002ac2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ac2:	1101                	addi	sp,sp,-32
    80002ac4:	ec06                	sd	ra,24(sp)
    80002ac6:	e822                	sd	s0,16(sp)
    80002ac8:	e426                	sd	s1,8(sp)
    80002aca:	1000                	addi	s0,sp,32
    80002acc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ace:	00000097          	auipc	ra,0x0
    80002ad2:	eee080e7          	jalr	-274(ra) # 800029bc <argraw>
    80002ad6:	c088                	sw	a0,0(s1)
}
    80002ad8:	60e2                	ld	ra,24(sp)
    80002ada:	6442                	ld	s0,16(sp)
    80002adc:	64a2                	ld	s1,8(sp)
    80002ade:	6105                	addi	sp,sp,32
    80002ae0:	8082                	ret

0000000080002ae2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ae2:	1101                	addi	sp,sp,-32
    80002ae4:	ec06                	sd	ra,24(sp)
    80002ae6:	e822                	sd	s0,16(sp)
    80002ae8:	e426                	sd	s1,8(sp)
    80002aea:	1000                	addi	s0,sp,32
    80002aec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	ece080e7          	jalr	-306(ra) # 800029bc <argraw>
    80002af6:	e088                	sd	a0,0(s1)
}
    80002af8:	60e2                	ld	ra,24(sp)
    80002afa:	6442                	ld	s0,16(sp)
    80002afc:	64a2                	ld	s1,8(sp)
    80002afe:	6105                	addi	sp,sp,32
    80002b00:	8082                	ret

0000000080002b02 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b02:	7179                	addi	sp,sp,-48
    80002b04:	f406                	sd	ra,40(sp)
    80002b06:	f022                	sd	s0,32(sp)
    80002b08:	ec26                	sd	s1,24(sp)
    80002b0a:	e84a                	sd	s2,16(sp)
    80002b0c:	1800                	addi	s0,sp,48
    80002b0e:	84ae                	mv	s1,a1
    80002b10:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b12:	fd840593          	addi	a1,s0,-40
    80002b16:	00000097          	auipc	ra,0x0
    80002b1a:	fcc080e7          	jalr	-52(ra) # 80002ae2 <argaddr>
  return fetchstr(addr, buf, max);
    80002b1e:	864a                	mv	a2,s2
    80002b20:	85a6                	mv	a1,s1
    80002b22:	fd843503          	ld	a0,-40(s0)
    80002b26:	00000097          	auipc	ra,0x0
    80002b2a:	f50080e7          	jalr	-176(ra) # 80002a76 <fetchstr>
}
    80002b2e:	70a2                	ld	ra,40(sp)
    80002b30:	7402                	ld	s0,32(sp)
    80002b32:	64e2                	ld	s1,24(sp)
    80002b34:	6942                	ld	s2,16(sp)
    80002b36:	6145                	addi	sp,sp,48
    80002b38:	8082                	ret

0000000080002b3a <syscall>:
[SYS_cow]	sys_cow,
};

void
syscall(void)
{
    80002b3a:	1101                	addi	sp,sp,-32
    80002b3c:	ec06                	sd	ra,24(sp)
    80002b3e:	e822                	sd	s0,16(sp)
    80002b40:	e426                	sd	s1,8(sp)
    80002b42:	e04a                	sd	s2,0(sp)
    80002b44:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b46:	fffff097          	auipc	ra,0xfffff
    80002b4a:	e66080e7          	jalr	-410(ra) # 800019ac <myproc>
    80002b4e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b50:	05853903          	ld	s2,88(a0)
    80002b54:	0a893783          	ld	a5,168(s2)
    80002b58:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b5c:	37fd                	addiw	a5,a5,-1
    80002b5e:	4755                	li	a4,21
    80002b60:	00f76f63          	bltu	a4,a5,80002b7e <syscall+0x44>
    80002b64:	00369713          	slli	a4,a3,0x3
    80002b68:	00006797          	auipc	a5,0x6
    80002b6c:	8e878793          	addi	a5,a5,-1816 # 80008450 <syscalls>
    80002b70:	97ba                	add	a5,a5,a4
    80002b72:	639c                	ld	a5,0(a5)
    80002b74:	c789                	beqz	a5,80002b7e <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b76:	9782                	jalr	a5
    80002b78:	06a93823          	sd	a0,112(s2)
    80002b7c:	a839                	j	80002b9a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b7e:	15848613          	addi	a2,s1,344
    80002b82:	588c                	lw	a1,48(s1)
    80002b84:	00006517          	auipc	a0,0x6
    80002b88:	89450513          	addi	a0,a0,-1900 # 80008418 <states.0+0x150>
    80002b8c:	ffffe097          	auipc	ra,0xffffe
    80002b90:	9fe080e7          	jalr	-1538(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b94:	6cbc                	ld	a5,88(s1)
    80002b96:	577d                	li	a4,-1
    80002b98:	fbb8                	sd	a4,112(a5)
  }
}
    80002b9a:	60e2                	ld	ra,24(sp)
    80002b9c:	6442                	ld	s0,16(sp)
    80002b9e:	64a2                	ld	s1,8(sp)
    80002ba0:	6902                	ld	s2,0(sp)
    80002ba2:	6105                	addi	sp,sp,32
    80002ba4:	8082                	ret

0000000080002ba6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ba6:	1101                	addi	sp,sp,-32
    80002ba8:	ec06                	sd	ra,24(sp)
    80002baa:	e822                	sd	s0,16(sp)
    80002bac:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bae:	fec40593          	addi	a1,s0,-20
    80002bb2:	4501                	li	a0,0
    80002bb4:	00000097          	auipc	ra,0x0
    80002bb8:	f0e080e7          	jalr	-242(ra) # 80002ac2 <argint>
  exit(n);
    80002bbc:	fec42503          	lw	a0,-20(s0)
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	5c8080e7          	jalr	1480(ra) # 80002188 <exit>
  return 0;  // not reached
}
    80002bc8:	4501                	li	a0,0
    80002bca:	60e2                	ld	ra,24(sp)
    80002bcc:	6442                	ld	s0,16(sp)
    80002bce:	6105                	addi	sp,sp,32
    80002bd0:	8082                	ret

0000000080002bd2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd2:	1141                	addi	sp,sp,-16
    80002bd4:	e406                	sd	ra,8(sp)
    80002bd6:	e022                	sd	s0,0(sp)
    80002bd8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bda:	fffff097          	auipc	ra,0xfffff
    80002bde:	dd2080e7          	jalr	-558(ra) # 800019ac <myproc>
}
    80002be2:	5908                	lw	a0,48(a0)
    80002be4:	60a2                	ld	ra,8(sp)
    80002be6:	6402                	ld	s0,0(sp)
    80002be8:	0141                	addi	sp,sp,16
    80002bea:	8082                	ret

0000000080002bec <sys_fork>:

uint64
sys_fork(void)
{
    80002bec:	1141                	addi	sp,sp,-16
    80002bee:	e406                	sd	ra,8(sp)
    80002bf0:	e022                	sd	s0,0(sp)
    80002bf2:	0800                	addi	s0,sp,16
  return fork();
    80002bf4:	fffff097          	auipc	ra,0xfffff
    80002bf8:	16e080e7          	jalr	366(ra) # 80001d62 <fork>
}
    80002bfc:	60a2                	ld	ra,8(sp)
    80002bfe:	6402                	ld	s0,0(sp)
    80002c00:	0141                	addi	sp,sp,16
    80002c02:	8082                	ret

0000000080002c04 <sys_wait>:

uint64
sys_wait(void)
{
    80002c04:	1101                	addi	sp,sp,-32
    80002c06:	ec06                	sd	ra,24(sp)
    80002c08:	e822                	sd	s0,16(sp)
    80002c0a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c0c:	fe840593          	addi	a1,s0,-24
    80002c10:	4501                	li	a0,0
    80002c12:	00000097          	auipc	ra,0x0
    80002c16:	ed0080e7          	jalr	-304(ra) # 80002ae2 <argaddr>
  return wait(p);
    80002c1a:	fe843503          	ld	a0,-24(s0)
    80002c1e:	fffff097          	auipc	ra,0xfffff
    80002c22:	710080e7          	jalr	1808(ra) # 8000232e <wait>
}
    80002c26:	60e2                	ld	ra,24(sp)
    80002c28:	6442                	ld	s0,16(sp)
    80002c2a:	6105                	addi	sp,sp,32
    80002c2c:	8082                	ret

0000000080002c2e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c2e:	7179                	addi	sp,sp,-48
    80002c30:	f406                	sd	ra,40(sp)
    80002c32:	f022                	sd	s0,32(sp)
    80002c34:	ec26                	sd	s1,24(sp)
    80002c36:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c38:	fdc40593          	addi	a1,s0,-36
    80002c3c:	4501                	li	a0,0
    80002c3e:	00000097          	auipc	ra,0x0
    80002c42:	e84080e7          	jalr	-380(ra) # 80002ac2 <argint>
  addr = myproc()->sz;
    80002c46:	fffff097          	auipc	ra,0xfffff
    80002c4a:	d66080e7          	jalr	-666(ra) # 800019ac <myproc>
    80002c4e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c50:	fdc42503          	lw	a0,-36(s0)
    80002c54:	fffff097          	auipc	ra,0xfffff
    80002c58:	0b2080e7          	jalr	178(ra) # 80001d06 <growproc>
    80002c5c:	00054863          	bltz	a0,80002c6c <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c60:	8526                	mv	a0,s1
    80002c62:	70a2                	ld	ra,40(sp)
    80002c64:	7402                	ld	s0,32(sp)
    80002c66:	64e2                	ld	s1,24(sp)
    80002c68:	6145                	addi	sp,sp,48
    80002c6a:	8082                	ret
    return -1;
    80002c6c:	54fd                	li	s1,-1
    80002c6e:	bfcd                	j	80002c60 <sys_sbrk+0x32>

0000000080002c70 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c70:	7139                	addi	sp,sp,-64
    80002c72:	fc06                	sd	ra,56(sp)
    80002c74:	f822                	sd	s0,48(sp)
    80002c76:	f426                	sd	s1,40(sp)
    80002c78:	f04a                	sd	s2,32(sp)
    80002c7a:	ec4e                	sd	s3,24(sp)
    80002c7c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c7e:	fcc40593          	addi	a1,s0,-52
    80002c82:	4501                	li	a0,0
    80002c84:	00000097          	auipc	ra,0x0
    80002c88:	e3e080e7          	jalr	-450(ra) # 80002ac2 <argint>
  acquire(&tickslock);
    80002c8c:	00014517          	auipc	a0,0x14
    80002c90:	d1450513          	addi	a0,a0,-748 # 800169a0 <tickslock>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	f42080e7          	jalr	-190(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002c9c:	00006917          	auipc	s2,0x6
    80002ca0:	c6492903          	lw	s2,-924(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002ca4:	fcc42783          	lw	a5,-52(s0)
    80002ca8:	cf9d                	beqz	a5,80002ce6 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002caa:	00014997          	auipc	s3,0x14
    80002cae:	cf698993          	addi	s3,s3,-778 # 800169a0 <tickslock>
    80002cb2:	00006497          	auipc	s1,0x6
    80002cb6:	c4e48493          	addi	s1,s1,-946 # 80008900 <ticks>
    if(killed(myproc())){
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	cf2080e7          	jalr	-782(ra) # 800019ac <myproc>
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	63a080e7          	jalr	1594(ra) # 800022fc <killed>
    80002cca:	ed15                	bnez	a0,80002d06 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002ccc:	85ce                	mv	a1,s3
    80002cce:	8526                	mv	a0,s1
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	384080e7          	jalr	900(ra) # 80002054 <sleep>
  while(ticks - ticks0 < n){
    80002cd8:	409c                	lw	a5,0(s1)
    80002cda:	412787bb          	subw	a5,a5,s2
    80002cde:	fcc42703          	lw	a4,-52(s0)
    80002ce2:	fce7ece3          	bltu	a5,a4,80002cba <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ce6:	00014517          	auipc	a0,0x14
    80002cea:	cba50513          	addi	a0,a0,-838 # 800169a0 <tickslock>
    80002cee:	ffffe097          	auipc	ra,0xffffe
    80002cf2:	f9c080e7          	jalr	-100(ra) # 80000c8a <release>
  return 0;
    80002cf6:	4501                	li	a0,0
}
    80002cf8:	70e2                	ld	ra,56(sp)
    80002cfa:	7442                	ld	s0,48(sp)
    80002cfc:	74a2                	ld	s1,40(sp)
    80002cfe:	7902                	ld	s2,32(sp)
    80002d00:	69e2                	ld	s3,24(sp)
    80002d02:	6121                	addi	sp,sp,64
    80002d04:	8082                	ret
      release(&tickslock);
    80002d06:	00014517          	auipc	a0,0x14
    80002d0a:	c9a50513          	addi	a0,a0,-870 # 800169a0 <tickslock>
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	f7c080e7          	jalr	-132(ra) # 80000c8a <release>
      return -1;
    80002d16:	557d                	li	a0,-1
    80002d18:	b7c5                	j	80002cf8 <sys_sleep+0x88>

0000000080002d1a <sys_cow>:

//My systemCalls
//-----------------------------

uint
sys_cow(void){
    80002d1a:	1141                	addi	sp,sp,-16
    80002d1c:	e406                	sd	ra,8(sp)
    80002d1e:	e022                	sd	s0,0(sp)
    80002d20:	0800                	addi	s0,sp,16
    printf("cow() system call :)\n");
    80002d22:	00005517          	auipc	a0,0x5
    80002d26:	7e650513          	addi	a0,a0,2022 # 80008508 <syscalls+0xb8>
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	860080e7          	jalr	-1952(ra) # 8000058a <printf>
    return 12;
}
    80002d32:	4531                	li	a0,12
    80002d34:	60a2                	ld	ra,8(sp)
    80002d36:	6402                	ld	s0,0(sp)
    80002d38:	0141                	addi	sp,sp,16
    80002d3a:	8082                	ret

0000000080002d3c <sys_kill>:

//-----------------------------
uint64
sys_kill(void)
{
    80002d3c:	1101                	addi	sp,sp,-32
    80002d3e:	ec06                	sd	ra,24(sp)
    80002d40:	e822                	sd	s0,16(sp)
    80002d42:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d44:	fec40593          	addi	a1,s0,-20
    80002d48:	4501                	li	a0,0
    80002d4a:	00000097          	auipc	ra,0x0
    80002d4e:	d78080e7          	jalr	-648(ra) # 80002ac2 <argint>
  return kill(pid);
    80002d52:	fec42503          	lw	a0,-20(s0)
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	508080e7          	jalr	1288(ra) # 8000225e <kill>
}
    80002d5e:	60e2                	ld	ra,24(sp)
    80002d60:	6442                	ld	s0,16(sp)
    80002d62:	6105                	addi	sp,sp,32
    80002d64:	8082                	ret

0000000080002d66 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d66:	1101                	addi	sp,sp,-32
    80002d68:	ec06                	sd	ra,24(sp)
    80002d6a:	e822                	sd	s0,16(sp)
    80002d6c:	e426                	sd	s1,8(sp)
    80002d6e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d70:	00014517          	auipc	a0,0x14
    80002d74:	c3050513          	addi	a0,a0,-976 # 800169a0 <tickslock>
    80002d78:	ffffe097          	auipc	ra,0xffffe
    80002d7c:	e5e080e7          	jalr	-418(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d80:	00006497          	auipc	s1,0x6
    80002d84:	b804a483          	lw	s1,-1152(s1) # 80008900 <ticks>
  release(&tickslock);
    80002d88:	00014517          	auipc	a0,0x14
    80002d8c:	c1850513          	addi	a0,a0,-1000 # 800169a0 <tickslock>
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	efa080e7          	jalr	-262(ra) # 80000c8a <release>
  return xticks;
}
    80002d98:	02049513          	slli	a0,s1,0x20
    80002d9c:	9101                	srli	a0,a0,0x20
    80002d9e:	60e2                	ld	ra,24(sp)
    80002da0:	6442                	ld	s0,16(sp)
    80002da2:	64a2                	ld	s1,8(sp)
    80002da4:	6105                	addi	sp,sp,32
    80002da6:	8082                	ret

0000000080002da8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002da8:	7179                	addi	sp,sp,-48
    80002daa:	f406                	sd	ra,40(sp)
    80002dac:	f022                	sd	s0,32(sp)
    80002dae:	ec26                	sd	s1,24(sp)
    80002db0:	e84a                	sd	s2,16(sp)
    80002db2:	e44e                	sd	s3,8(sp)
    80002db4:	e052                	sd	s4,0(sp)
    80002db6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002db8:	00005597          	auipc	a1,0x5
    80002dbc:	76858593          	addi	a1,a1,1896 # 80008520 <syscalls+0xd0>
    80002dc0:	00014517          	auipc	a0,0x14
    80002dc4:	bf850513          	addi	a0,a0,-1032 # 800169b8 <bcache>
    80002dc8:	ffffe097          	auipc	ra,0xffffe
    80002dcc:	d7e080e7          	jalr	-642(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dd0:	0001c797          	auipc	a5,0x1c
    80002dd4:	be878793          	addi	a5,a5,-1048 # 8001e9b8 <bcache+0x8000>
    80002dd8:	0001c717          	auipc	a4,0x1c
    80002ddc:	e4870713          	addi	a4,a4,-440 # 8001ec20 <bcache+0x8268>
    80002de0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002de4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002de8:	00014497          	auipc	s1,0x14
    80002dec:	be848493          	addi	s1,s1,-1048 # 800169d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002df0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002df2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002df4:	00005a17          	auipc	s4,0x5
    80002df8:	734a0a13          	addi	s4,s4,1844 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    80002dfc:	2b893783          	ld	a5,696(s2)
    80002e00:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e02:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e06:	85d2                	mv	a1,s4
    80002e08:	01048513          	addi	a0,s1,16
    80002e0c:	00001097          	auipc	ra,0x1
    80002e10:	4c8080e7          	jalr	1224(ra) # 800042d4 <initsleeplock>
    bcache.head.next->prev = b;
    80002e14:	2b893783          	ld	a5,696(s2)
    80002e18:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e1a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e1e:	45848493          	addi	s1,s1,1112
    80002e22:	fd349de3          	bne	s1,s3,80002dfc <binit+0x54>
  }
}
    80002e26:	70a2                	ld	ra,40(sp)
    80002e28:	7402                	ld	s0,32(sp)
    80002e2a:	64e2                	ld	s1,24(sp)
    80002e2c:	6942                	ld	s2,16(sp)
    80002e2e:	69a2                	ld	s3,8(sp)
    80002e30:	6a02                	ld	s4,0(sp)
    80002e32:	6145                	addi	sp,sp,48
    80002e34:	8082                	ret

0000000080002e36 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e36:	7179                	addi	sp,sp,-48
    80002e38:	f406                	sd	ra,40(sp)
    80002e3a:	f022                	sd	s0,32(sp)
    80002e3c:	ec26                	sd	s1,24(sp)
    80002e3e:	e84a                	sd	s2,16(sp)
    80002e40:	e44e                	sd	s3,8(sp)
    80002e42:	1800                	addi	s0,sp,48
    80002e44:	892a                	mv	s2,a0
    80002e46:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e48:	00014517          	auipc	a0,0x14
    80002e4c:	b7050513          	addi	a0,a0,-1168 # 800169b8 <bcache>
    80002e50:	ffffe097          	auipc	ra,0xffffe
    80002e54:	d86080e7          	jalr	-634(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e58:	0001c497          	auipc	s1,0x1c
    80002e5c:	e184b483          	ld	s1,-488(s1) # 8001ec70 <bcache+0x82b8>
    80002e60:	0001c797          	auipc	a5,0x1c
    80002e64:	dc078793          	addi	a5,a5,-576 # 8001ec20 <bcache+0x8268>
    80002e68:	02f48f63          	beq	s1,a5,80002ea6 <bread+0x70>
    80002e6c:	873e                	mv	a4,a5
    80002e6e:	a021                	j	80002e76 <bread+0x40>
    80002e70:	68a4                	ld	s1,80(s1)
    80002e72:	02e48a63          	beq	s1,a4,80002ea6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e76:	449c                	lw	a5,8(s1)
    80002e78:	ff279ce3          	bne	a5,s2,80002e70 <bread+0x3a>
    80002e7c:	44dc                	lw	a5,12(s1)
    80002e7e:	ff3799e3          	bne	a5,s3,80002e70 <bread+0x3a>
      b->refcnt++;
    80002e82:	40bc                	lw	a5,64(s1)
    80002e84:	2785                	addiw	a5,a5,1
    80002e86:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e88:	00014517          	auipc	a0,0x14
    80002e8c:	b3050513          	addi	a0,a0,-1232 # 800169b8 <bcache>
    80002e90:	ffffe097          	auipc	ra,0xffffe
    80002e94:	dfa080e7          	jalr	-518(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002e98:	01048513          	addi	a0,s1,16
    80002e9c:	00001097          	auipc	ra,0x1
    80002ea0:	472080e7          	jalr	1138(ra) # 8000430e <acquiresleep>
      return b;
    80002ea4:	a8b9                	j	80002f02 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ea6:	0001c497          	auipc	s1,0x1c
    80002eaa:	dc24b483          	ld	s1,-574(s1) # 8001ec68 <bcache+0x82b0>
    80002eae:	0001c797          	auipc	a5,0x1c
    80002eb2:	d7278793          	addi	a5,a5,-654 # 8001ec20 <bcache+0x8268>
    80002eb6:	00f48863          	beq	s1,a5,80002ec6 <bread+0x90>
    80002eba:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ebc:	40bc                	lw	a5,64(s1)
    80002ebe:	cf81                	beqz	a5,80002ed6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ec0:	64a4                	ld	s1,72(s1)
    80002ec2:	fee49de3          	bne	s1,a4,80002ebc <bread+0x86>
  panic("bget: no buffers");
    80002ec6:	00005517          	auipc	a0,0x5
    80002eca:	66a50513          	addi	a0,a0,1642 # 80008530 <syscalls+0xe0>
    80002ece:	ffffd097          	auipc	ra,0xffffd
    80002ed2:	672080e7          	jalr	1650(ra) # 80000540 <panic>
      b->dev = dev;
    80002ed6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002eda:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ede:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ee2:	4785                	li	a5,1
    80002ee4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ee6:	00014517          	auipc	a0,0x14
    80002eea:	ad250513          	addi	a0,a0,-1326 # 800169b8 <bcache>
    80002eee:	ffffe097          	auipc	ra,0xffffe
    80002ef2:	d9c080e7          	jalr	-612(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002ef6:	01048513          	addi	a0,s1,16
    80002efa:	00001097          	auipc	ra,0x1
    80002efe:	414080e7          	jalr	1044(ra) # 8000430e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f02:	409c                	lw	a5,0(s1)
    80002f04:	cb89                	beqz	a5,80002f16 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f06:	8526                	mv	a0,s1
    80002f08:	70a2                	ld	ra,40(sp)
    80002f0a:	7402                	ld	s0,32(sp)
    80002f0c:	64e2                	ld	s1,24(sp)
    80002f0e:	6942                	ld	s2,16(sp)
    80002f10:	69a2                	ld	s3,8(sp)
    80002f12:	6145                	addi	sp,sp,48
    80002f14:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f16:	4581                	li	a1,0
    80002f18:	8526                	mv	a0,s1
    80002f1a:	00003097          	auipc	ra,0x3
    80002f1e:	fd8080e7          	jalr	-40(ra) # 80005ef2 <virtio_disk_rw>
    b->valid = 1;
    80002f22:	4785                	li	a5,1
    80002f24:	c09c                	sw	a5,0(s1)
  return b;
    80002f26:	b7c5                	j	80002f06 <bread+0xd0>

0000000080002f28 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f28:	1101                	addi	sp,sp,-32
    80002f2a:	ec06                	sd	ra,24(sp)
    80002f2c:	e822                	sd	s0,16(sp)
    80002f2e:	e426                	sd	s1,8(sp)
    80002f30:	1000                	addi	s0,sp,32
    80002f32:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f34:	0541                	addi	a0,a0,16
    80002f36:	00001097          	auipc	ra,0x1
    80002f3a:	472080e7          	jalr	1138(ra) # 800043a8 <holdingsleep>
    80002f3e:	cd01                	beqz	a0,80002f56 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f40:	4585                	li	a1,1
    80002f42:	8526                	mv	a0,s1
    80002f44:	00003097          	auipc	ra,0x3
    80002f48:	fae080e7          	jalr	-82(ra) # 80005ef2 <virtio_disk_rw>
}
    80002f4c:	60e2                	ld	ra,24(sp)
    80002f4e:	6442                	ld	s0,16(sp)
    80002f50:	64a2                	ld	s1,8(sp)
    80002f52:	6105                	addi	sp,sp,32
    80002f54:	8082                	ret
    panic("bwrite");
    80002f56:	00005517          	auipc	a0,0x5
    80002f5a:	5f250513          	addi	a0,a0,1522 # 80008548 <syscalls+0xf8>
    80002f5e:	ffffd097          	auipc	ra,0xffffd
    80002f62:	5e2080e7          	jalr	1506(ra) # 80000540 <panic>

0000000080002f66 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f66:	1101                	addi	sp,sp,-32
    80002f68:	ec06                	sd	ra,24(sp)
    80002f6a:	e822                	sd	s0,16(sp)
    80002f6c:	e426                	sd	s1,8(sp)
    80002f6e:	e04a                	sd	s2,0(sp)
    80002f70:	1000                	addi	s0,sp,32
    80002f72:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f74:	01050913          	addi	s2,a0,16
    80002f78:	854a                	mv	a0,s2
    80002f7a:	00001097          	auipc	ra,0x1
    80002f7e:	42e080e7          	jalr	1070(ra) # 800043a8 <holdingsleep>
    80002f82:	c92d                	beqz	a0,80002ff4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f84:	854a                	mv	a0,s2
    80002f86:	00001097          	auipc	ra,0x1
    80002f8a:	3de080e7          	jalr	990(ra) # 80004364 <releasesleep>

  acquire(&bcache.lock);
    80002f8e:	00014517          	auipc	a0,0x14
    80002f92:	a2a50513          	addi	a0,a0,-1494 # 800169b8 <bcache>
    80002f96:	ffffe097          	auipc	ra,0xffffe
    80002f9a:	c40080e7          	jalr	-960(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002f9e:	40bc                	lw	a5,64(s1)
    80002fa0:	37fd                	addiw	a5,a5,-1
    80002fa2:	0007871b          	sext.w	a4,a5
    80002fa6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fa8:	eb05                	bnez	a4,80002fd8 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002faa:	68bc                	ld	a5,80(s1)
    80002fac:	64b8                	ld	a4,72(s1)
    80002fae:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002fb0:	64bc                	ld	a5,72(s1)
    80002fb2:	68b8                	ld	a4,80(s1)
    80002fb4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fb6:	0001c797          	auipc	a5,0x1c
    80002fba:	a0278793          	addi	a5,a5,-1534 # 8001e9b8 <bcache+0x8000>
    80002fbe:	2b87b703          	ld	a4,696(a5)
    80002fc2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fc4:	0001c717          	auipc	a4,0x1c
    80002fc8:	c5c70713          	addi	a4,a4,-932 # 8001ec20 <bcache+0x8268>
    80002fcc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fce:	2b87b703          	ld	a4,696(a5)
    80002fd2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fd4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fd8:	00014517          	auipc	a0,0x14
    80002fdc:	9e050513          	addi	a0,a0,-1568 # 800169b8 <bcache>
    80002fe0:	ffffe097          	auipc	ra,0xffffe
    80002fe4:	caa080e7          	jalr	-854(ra) # 80000c8a <release>
}
    80002fe8:	60e2                	ld	ra,24(sp)
    80002fea:	6442                	ld	s0,16(sp)
    80002fec:	64a2                	ld	s1,8(sp)
    80002fee:	6902                	ld	s2,0(sp)
    80002ff0:	6105                	addi	sp,sp,32
    80002ff2:	8082                	ret
    panic("brelse");
    80002ff4:	00005517          	auipc	a0,0x5
    80002ff8:	55c50513          	addi	a0,a0,1372 # 80008550 <syscalls+0x100>
    80002ffc:	ffffd097          	auipc	ra,0xffffd
    80003000:	544080e7          	jalr	1348(ra) # 80000540 <panic>

0000000080003004 <bpin>:

void
bpin(struct buf *b) {
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	e426                	sd	s1,8(sp)
    8000300c:	1000                	addi	s0,sp,32
    8000300e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003010:	00014517          	auipc	a0,0x14
    80003014:	9a850513          	addi	a0,a0,-1624 # 800169b8 <bcache>
    80003018:	ffffe097          	auipc	ra,0xffffe
    8000301c:	bbe080e7          	jalr	-1090(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003020:	40bc                	lw	a5,64(s1)
    80003022:	2785                	addiw	a5,a5,1
    80003024:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003026:	00014517          	auipc	a0,0x14
    8000302a:	99250513          	addi	a0,a0,-1646 # 800169b8 <bcache>
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	c5c080e7          	jalr	-932(ra) # 80000c8a <release>
}
    80003036:	60e2                	ld	ra,24(sp)
    80003038:	6442                	ld	s0,16(sp)
    8000303a:	64a2                	ld	s1,8(sp)
    8000303c:	6105                	addi	sp,sp,32
    8000303e:	8082                	ret

0000000080003040 <bunpin>:

void
bunpin(struct buf *b) {
    80003040:	1101                	addi	sp,sp,-32
    80003042:	ec06                	sd	ra,24(sp)
    80003044:	e822                	sd	s0,16(sp)
    80003046:	e426                	sd	s1,8(sp)
    80003048:	1000                	addi	s0,sp,32
    8000304a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000304c:	00014517          	auipc	a0,0x14
    80003050:	96c50513          	addi	a0,a0,-1684 # 800169b8 <bcache>
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	b82080e7          	jalr	-1150(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000305c:	40bc                	lw	a5,64(s1)
    8000305e:	37fd                	addiw	a5,a5,-1
    80003060:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003062:	00014517          	auipc	a0,0x14
    80003066:	95650513          	addi	a0,a0,-1706 # 800169b8 <bcache>
    8000306a:	ffffe097          	auipc	ra,0xffffe
    8000306e:	c20080e7          	jalr	-992(ra) # 80000c8a <release>
}
    80003072:	60e2                	ld	ra,24(sp)
    80003074:	6442                	ld	s0,16(sp)
    80003076:	64a2                	ld	s1,8(sp)
    80003078:	6105                	addi	sp,sp,32
    8000307a:	8082                	ret

000000008000307c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000307c:	1101                	addi	sp,sp,-32
    8000307e:	ec06                	sd	ra,24(sp)
    80003080:	e822                	sd	s0,16(sp)
    80003082:	e426                	sd	s1,8(sp)
    80003084:	e04a                	sd	s2,0(sp)
    80003086:	1000                	addi	s0,sp,32
    80003088:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000308a:	00d5d59b          	srliw	a1,a1,0xd
    8000308e:	0001c797          	auipc	a5,0x1c
    80003092:	0067a783          	lw	a5,6(a5) # 8001f094 <sb+0x1c>
    80003096:	9dbd                	addw	a1,a1,a5
    80003098:	00000097          	auipc	ra,0x0
    8000309c:	d9e080e7          	jalr	-610(ra) # 80002e36 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030a0:	0074f713          	andi	a4,s1,7
    800030a4:	4785                	li	a5,1
    800030a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030aa:	14ce                	slli	s1,s1,0x33
    800030ac:	90d9                	srli	s1,s1,0x36
    800030ae:	00950733          	add	a4,a0,s1
    800030b2:	05874703          	lbu	a4,88(a4)
    800030b6:	00e7f6b3          	and	a3,a5,a4
    800030ba:	c69d                	beqz	a3,800030e8 <bfree+0x6c>
    800030bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030be:	94aa                	add	s1,s1,a0
    800030c0:	fff7c793          	not	a5,a5
    800030c4:	8f7d                	and	a4,a4,a5
    800030c6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030ca:	00001097          	auipc	ra,0x1
    800030ce:	126080e7          	jalr	294(ra) # 800041f0 <log_write>
  brelse(bp);
    800030d2:	854a                	mv	a0,s2
    800030d4:	00000097          	auipc	ra,0x0
    800030d8:	e92080e7          	jalr	-366(ra) # 80002f66 <brelse>
}
    800030dc:	60e2                	ld	ra,24(sp)
    800030de:	6442                	ld	s0,16(sp)
    800030e0:	64a2                	ld	s1,8(sp)
    800030e2:	6902                	ld	s2,0(sp)
    800030e4:	6105                	addi	sp,sp,32
    800030e6:	8082                	ret
    panic("freeing free block");
    800030e8:	00005517          	auipc	a0,0x5
    800030ec:	47050513          	addi	a0,a0,1136 # 80008558 <syscalls+0x108>
    800030f0:	ffffd097          	auipc	ra,0xffffd
    800030f4:	450080e7          	jalr	1104(ra) # 80000540 <panic>

00000000800030f8 <balloc>:
{
    800030f8:	711d                	addi	sp,sp,-96
    800030fa:	ec86                	sd	ra,88(sp)
    800030fc:	e8a2                	sd	s0,80(sp)
    800030fe:	e4a6                	sd	s1,72(sp)
    80003100:	e0ca                	sd	s2,64(sp)
    80003102:	fc4e                	sd	s3,56(sp)
    80003104:	f852                	sd	s4,48(sp)
    80003106:	f456                	sd	s5,40(sp)
    80003108:	f05a                	sd	s6,32(sp)
    8000310a:	ec5e                	sd	s7,24(sp)
    8000310c:	e862                	sd	s8,16(sp)
    8000310e:	e466                	sd	s9,8(sp)
    80003110:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003112:	0001c797          	auipc	a5,0x1c
    80003116:	f6a7a783          	lw	a5,-150(a5) # 8001f07c <sb+0x4>
    8000311a:	cff5                	beqz	a5,80003216 <balloc+0x11e>
    8000311c:	8baa                	mv	s7,a0
    8000311e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003120:	0001cb17          	auipc	s6,0x1c
    80003124:	f58b0b13          	addi	s6,s6,-168 # 8001f078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003128:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000312a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000312c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000312e:	6c89                	lui	s9,0x2
    80003130:	a061                	j	800031b8 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003132:	97ca                	add	a5,a5,s2
    80003134:	8e55                	or	a2,a2,a3
    80003136:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000313a:	854a                	mv	a0,s2
    8000313c:	00001097          	auipc	ra,0x1
    80003140:	0b4080e7          	jalr	180(ra) # 800041f0 <log_write>
        brelse(bp);
    80003144:	854a                	mv	a0,s2
    80003146:	00000097          	auipc	ra,0x0
    8000314a:	e20080e7          	jalr	-480(ra) # 80002f66 <brelse>
  bp = bread(dev, bno);
    8000314e:	85a6                	mv	a1,s1
    80003150:	855e                	mv	a0,s7
    80003152:	00000097          	auipc	ra,0x0
    80003156:	ce4080e7          	jalr	-796(ra) # 80002e36 <bread>
    8000315a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000315c:	40000613          	li	a2,1024
    80003160:	4581                	li	a1,0
    80003162:	05850513          	addi	a0,a0,88
    80003166:	ffffe097          	auipc	ra,0xffffe
    8000316a:	b6c080e7          	jalr	-1172(ra) # 80000cd2 <memset>
  log_write(bp);
    8000316e:	854a                	mv	a0,s2
    80003170:	00001097          	auipc	ra,0x1
    80003174:	080080e7          	jalr	128(ra) # 800041f0 <log_write>
  brelse(bp);
    80003178:	854a                	mv	a0,s2
    8000317a:	00000097          	auipc	ra,0x0
    8000317e:	dec080e7          	jalr	-532(ra) # 80002f66 <brelse>
}
    80003182:	8526                	mv	a0,s1
    80003184:	60e6                	ld	ra,88(sp)
    80003186:	6446                	ld	s0,80(sp)
    80003188:	64a6                	ld	s1,72(sp)
    8000318a:	6906                	ld	s2,64(sp)
    8000318c:	79e2                	ld	s3,56(sp)
    8000318e:	7a42                	ld	s4,48(sp)
    80003190:	7aa2                	ld	s5,40(sp)
    80003192:	7b02                	ld	s6,32(sp)
    80003194:	6be2                	ld	s7,24(sp)
    80003196:	6c42                	ld	s8,16(sp)
    80003198:	6ca2                	ld	s9,8(sp)
    8000319a:	6125                	addi	sp,sp,96
    8000319c:	8082                	ret
    brelse(bp);
    8000319e:	854a                	mv	a0,s2
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	dc6080e7          	jalr	-570(ra) # 80002f66 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031a8:	015c87bb          	addw	a5,s9,s5
    800031ac:	00078a9b          	sext.w	s5,a5
    800031b0:	004b2703          	lw	a4,4(s6)
    800031b4:	06eaf163          	bgeu	s5,a4,80003216 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800031b8:	41fad79b          	sraiw	a5,s5,0x1f
    800031bc:	0137d79b          	srliw	a5,a5,0x13
    800031c0:	015787bb          	addw	a5,a5,s5
    800031c4:	40d7d79b          	sraiw	a5,a5,0xd
    800031c8:	01cb2583          	lw	a1,28(s6)
    800031cc:	9dbd                	addw	a1,a1,a5
    800031ce:	855e                	mv	a0,s7
    800031d0:	00000097          	auipc	ra,0x0
    800031d4:	c66080e7          	jalr	-922(ra) # 80002e36 <bread>
    800031d8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031da:	004b2503          	lw	a0,4(s6)
    800031de:	000a849b          	sext.w	s1,s5
    800031e2:	8762                	mv	a4,s8
    800031e4:	faa4fde3          	bgeu	s1,a0,8000319e <balloc+0xa6>
      m = 1 << (bi % 8);
    800031e8:	00777693          	andi	a3,a4,7
    800031ec:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031f0:	41f7579b          	sraiw	a5,a4,0x1f
    800031f4:	01d7d79b          	srliw	a5,a5,0x1d
    800031f8:	9fb9                	addw	a5,a5,a4
    800031fa:	4037d79b          	sraiw	a5,a5,0x3
    800031fe:	00f90633          	add	a2,s2,a5
    80003202:	05864603          	lbu	a2,88(a2)
    80003206:	00c6f5b3          	and	a1,a3,a2
    8000320a:	d585                	beqz	a1,80003132 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000320c:	2705                	addiw	a4,a4,1
    8000320e:	2485                	addiw	s1,s1,1
    80003210:	fd471ae3          	bne	a4,s4,800031e4 <balloc+0xec>
    80003214:	b769                	j	8000319e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003216:	00005517          	auipc	a0,0x5
    8000321a:	35a50513          	addi	a0,a0,858 # 80008570 <syscalls+0x120>
    8000321e:	ffffd097          	auipc	ra,0xffffd
    80003222:	36c080e7          	jalr	876(ra) # 8000058a <printf>
  return 0;
    80003226:	4481                	li	s1,0
    80003228:	bfa9                	j	80003182 <balloc+0x8a>

000000008000322a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000322a:	7179                	addi	sp,sp,-48
    8000322c:	f406                	sd	ra,40(sp)
    8000322e:	f022                	sd	s0,32(sp)
    80003230:	ec26                	sd	s1,24(sp)
    80003232:	e84a                	sd	s2,16(sp)
    80003234:	e44e                	sd	s3,8(sp)
    80003236:	e052                	sd	s4,0(sp)
    80003238:	1800                	addi	s0,sp,48
    8000323a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000323c:	47ad                	li	a5,11
    8000323e:	02b7e863          	bltu	a5,a1,8000326e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003242:	02059793          	slli	a5,a1,0x20
    80003246:	01e7d593          	srli	a1,a5,0x1e
    8000324a:	00b504b3          	add	s1,a0,a1
    8000324e:	0504a903          	lw	s2,80(s1)
    80003252:	06091e63          	bnez	s2,800032ce <bmap+0xa4>
      addr = balloc(ip->dev);
    80003256:	4108                	lw	a0,0(a0)
    80003258:	00000097          	auipc	ra,0x0
    8000325c:	ea0080e7          	jalr	-352(ra) # 800030f8 <balloc>
    80003260:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003264:	06090563          	beqz	s2,800032ce <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003268:	0524a823          	sw	s2,80(s1)
    8000326c:	a08d                	j	800032ce <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000326e:	ff45849b          	addiw	s1,a1,-12
    80003272:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003276:	0ff00793          	li	a5,255
    8000327a:	08e7e563          	bltu	a5,a4,80003304 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000327e:	08052903          	lw	s2,128(a0)
    80003282:	00091d63          	bnez	s2,8000329c <bmap+0x72>
      addr = balloc(ip->dev);
    80003286:	4108                	lw	a0,0(a0)
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	e70080e7          	jalr	-400(ra) # 800030f8 <balloc>
    80003290:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003294:	02090d63          	beqz	s2,800032ce <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003298:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000329c:	85ca                	mv	a1,s2
    8000329e:	0009a503          	lw	a0,0(s3)
    800032a2:	00000097          	auipc	ra,0x0
    800032a6:	b94080e7          	jalr	-1132(ra) # 80002e36 <bread>
    800032aa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032ac:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032b0:	02049713          	slli	a4,s1,0x20
    800032b4:	01e75593          	srli	a1,a4,0x1e
    800032b8:	00b784b3          	add	s1,a5,a1
    800032bc:	0004a903          	lw	s2,0(s1)
    800032c0:	02090063          	beqz	s2,800032e0 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032c4:	8552                	mv	a0,s4
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	ca0080e7          	jalr	-864(ra) # 80002f66 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032ce:	854a                	mv	a0,s2
    800032d0:	70a2                	ld	ra,40(sp)
    800032d2:	7402                	ld	s0,32(sp)
    800032d4:	64e2                	ld	s1,24(sp)
    800032d6:	6942                	ld	s2,16(sp)
    800032d8:	69a2                	ld	s3,8(sp)
    800032da:	6a02                	ld	s4,0(sp)
    800032dc:	6145                	addi	sp,sp,48
    800032de:	8082                	ret
      addr = balloc(ip->dev);
    800032e0:	0009a503          	lw	a0,0(s3)
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	e14080e7          	jalr	-492(ra) # 800030f8 <balloc>
    800032ec:	0005091b          	sext.w	s2,a0
      if(addr){
    800032f0:	fc090ae3          	beqz	s2,800032c4 <bmap+0x9a>
        a[bn] = addr;
    800032f4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032f8:	8552                	mv	a0,s4
    800032fa:	00001097          	auipc	ra,0x1
    800032fe:	ef6080e7          	jalr	-266(ra) # 800041f0 <log_write>
    80003302:	b7c9                	j	800032c4 <bmap+0x9a>
  panic("bmap: out of range");
    80003304:	00005517          	auipc	a0,0x5
    80003308:	28450513          	addi	a0,a0,644 # 80008588 <syscalls+0x138>
    8000330c:	ffffd097          	auipc	ra,0xffffd
    80003310:	234080e7          	jalr	564(ra) # 80000540 <panic>

0000000080003314 <iget>:
{
    80003314:	7179                	addi	sp,sp,-48
    80003316:	f406                	sd	ra,40(sp)
    80003318:	f022                	sd	s0,32(sp)
    8000331a:	ec26                	sd	s1,24(sp)
    8000331c:	e84a                	sd	s2,16(sp)
    8000331e:	e44e                	sd	s3,8(sp)
    80003320:	e052                	sd	s4,0(sp)
    80003322:	1800                	addi	s0,sp,48
    80003324:	89aa                	mv	s3,a0
    80003326:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003328:	0001c517          	auipc	a0,0x1c
    8000332c:	d7050513          	addi	a0,a0,-656 # 8001f098 <itable>
    80003330:	ffffe097          	auipc	ra,0xffffe
    80003334:	8a6080e7          	jalr	-1882(ra) # 80000bd6 <acquire>
  empty = 0;
    80003338:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000333a:	0001c497          	auipc	s1,0x1c
    8000333e:	d7648493          	addi	s1,s1,-650 # 8001f0b0 <itable+0x18>
    80003342:	0001d697          	auipc	a3,0x1d
    80003346:	7fe68693          	addi	a3,a3,2046 # 80020b40 <log>
    8000334a:	a039                	j	80003358 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000334c:	02090b63          	beqz	s2,80003382 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003350:	08848493          	addi	s1,s1,136
    80003354:	02d48a63          	beq	s1,a3,80003388 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003358:	449c                	lw	a5,8(s1)
    8000335a:	fef059e3          	blez	a5,8000334c <iget+0x38>
    8000335e:	4098                	lw	a4,0(s1)
    80003360:	ff3716e3          	bne	a4,s3,8000334c <iget+0x38>
    80003364:	40d8                	lw	a4,4(s1)
    80003366:	ff4713e3          	bne	a4,s4,8000334c <iget+0x38>
      ip->ref++;
    8000336a:	2785                	addiw	a5,a5,1
    8000336c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000336e:	0001c517          	auipc	a0,0x1c
    80003372:	d2a50513          	addi	a0,a0,-726 # 8001f098 <itable>
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	914080e7          	jalr	-1772(ra) # 80000c8a <release>
      return ip;
    8000337e:	8926                	mv	s2,s1
    80003380:	a03d                	j	800033ae <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003382:	f7f9                	bnez	a5,80003350 <iget+0x3c>
    80003384:	8926                	mv	s2,s1
    80003386:	b7e9                	j	80003350 <iget+0x3c>
  if(empty == 0)
    80003388:	02090c63          	beqz	s2,800033c0 <iget+0xac>
  ip->dev = dev;
    8000338c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003390:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003394:	4785                	li	a5,1
    80003396:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000339a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000339e:	0001c517          	auipc	a0,0x1c
    800033a2:	cfa50513          	addi	a0,a0,-774 # 8001f098 <itable>
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	8e4080e7          	jalr	-1820(ra) # 80000c8a <release>
}
    800033ae:	854a                	mv	a0,s2
    800033b0:	70a2                	ld	ra,40(sp)
    800033b2:	7402                	ld	s0,32(sp)
    800033b4:	64e2                	ld	s1,24(sp)
    800033b6:	6942                	ld	s2,16(sp)
    800033b8:	69a2                	ld	s3,8(sp)
    800033ba:	6a02                	ld	s4,0(sp)
    800033bc:	6145                	addi	sp,sp,48
    800033be:	8082                	ret
    panic("iget: no inodes");
    800033c0:	00005517          	auipc	a0,0x5
    800033c4:	1e050513          	addi	a0,a0,480 # 800085a0 <syscalls+0x150>
    800033c8:	ffffd097          	auipc	ra,0xffffd
    800033cc:	178080e7          	jalr	376(ra) # 80000540 <panic>

00000000800033d0 <fsinit>:
fsinit(int dev) {
    800033d0:	7179                	addi	sp,sp,-48
    800033d2:	f406                	sd	ra,40(sp)
    800033d4:	f022                	sd	s0,32(sp)
    800033d6:	ec26                	sd	s1,24(sp)
    800033d8:	e84a                	sd	s2,16(sp)
    800033da:	e44e                	sd	s3,8(sp)
    800033dc:	1800                	addi	s0,sp,48
    800033de:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033e0:	4585                	li	a1,1
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	a54080e7          	jalr	-1452(ra) # 80002e36 <bread>
    800033ea:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033ec:	0001c997          	auipc	s3,0x1c
    800033f0:	c8c98993          	addi	s3,s3,-884 # 8001f078 <sb>
    800033f4:	02000613          	li	a2,32
    800033f8:	05850593          	addi	a1,a0,88
    800033fc:	854e                	mv	a0,s3
    800033fe:	ffffe097          	auipc	ra,0xffffe
    80003402:	930080e7          	jalr	-1744(ra) # 80000d2e <memmove>
  brelse(bp);
    80003406:	8526                	mv	a0,s1
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	b5e080e7          	jalr	-1186(ra) # 80002f66 <brelse>
  if(sb.magic != FSMAGIC)
    80003410:	0009a703          	lw	a4,0(s3)
    80003414:	102037b7          	lui	a5,0x10203
    80003418:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000341c:	02f71263          	bne	a4,a5,80003440 <fsinit+0x70>
  initlog(dev, &sb);
    80003420:	0001c597          	auipc	a1,0x1c
    80003424:	c5858593          	addi	a1,a1,-936 # 8001f078 <sb>
    80003428:	854a                	mv	a0,s2
    8000342a:	00001097          	auipc	ra,0x1
    8000342e:	b4a080e7          	jalr	-1206(ra) # 80003f74 <initlog>
}
    80003432:	70a2                	ld	ra,40(sp)
    80003434:	7402                	ld	s0,32(sp)
    80003436:	64e2                	ld	s1,24(sp)
    80003438:	6942                	ld	s2,16(sp)
    8000343a:	69a2                	ld	s3,8(sp)
    8000343c:	6145                	addi	sp,sp,48
    8000343e:	8082                	ret
    panic("invalid file system");
    80003440:	00005517          	auipc	a0,0x5
    80003444:	17050513          	addi	a0,a0,368 # 800085b0 <syscalls+0x160>
    80003448:	ffffd097          	auipc	ra,0xffffd
    8000344c:	0f8080e7          	jalr	248(ra) # 80000540 <panic>

0000000080003450 <iinit>:
{
    80003450:	7179                	addi	sp,sp,-48
    80003452:	f406                	sd	ra,40(sp)
    80003454:	f022                	sd	s0,32(sp)
    80003456:	ec26                	sd	s1,24(sp)
    80003458:	e84a                	sd	s2,16(sp)
    8000345a:	e44e                	sd	s3,8(sp)
    8000345c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000345e:	00005597          	auipc	a1,0x5
    80003462:	16a58593          	addi	a1,a1,362 # 800085c8 <syscalls+0x178>
    80003466:	0001c517          	auipc	a0,0x1c
    8000346a:	c3250513          	addi	a0,a0,-974 # 8001f098 <itable>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	6d8080e7          	jalr	1752(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003476:	0001c497          	auipc	s1,0x1c
    8000347a:	c4a48493          	addi	s1,s1,-950 # 8001f0c0 <itable+0x28>
    8000347e:	0001d997          	auipc	s3,0x1d
    80003482:	6d298993          	addi	s3,s3,1746 # 80020b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003486:	00005917          	auipc	s2,0x5
    8000348a:	14a90913          	addi	s2,s2,330 # 800085d0 <syscalls+0x180>
    8000348e:	85ca                	mv	a1,s2
    80003490:	8526                	mv	a0,s1
    80003492:	00001097          	auipc	ra,0x1
    80003496:	e42080e7          	jalr	-446(ra) # 800042d4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000349a:	08848493          	addi	s1,s1,136
    8000349e:	ff3498e3          	bne	s1,s3,8000348e <iinit+0x3e>
}
    800034a2:	70a2                	ld	ra,40(sp)
    800034a4:	7402                	ld	s0,32(sp)
    800034a6:	64e2                	ld	s1,24(sp)
    800034a8:	6942                	ld	s2,16(sp)
    800034aa:	69a2                	ld	s3,8(sp)
    800034ac:	6145                	addi	sp,sp,48
    800034ae:	8082                	ret

00000000800034b0 <ialloc>:
{
    800034b0:	715d                	addi	sp,sp,-80
    800034b2:	e486                	sd	ra,72(sp)
    800034b4:	e0a2                	sd	s0,64(sp)
    800034b6:	fc26                	sd	s1,56(sp)
    800034b8:	f84a                	sd	s2,48(sp)
    800034ba:	f44e                	sd	s3,40(sp)
    800034bc:	f052                	sd	s4,32(sp)
    800034be:	ec56                	sd	s5,24(sp)
    800034c0:	e85a                	sd	s6,16(sp)
    800034c2:	e45e                	sd	s7,8(sp)
    800034c4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800034c6:	0001c717          	auipc	a4,0x1c
    800034ca:	bbe72703          	lw	a4,-1090(a4) # 8001f084 <sb+0xc>
    800034ce:	4785                	li	a5,1
    800034d0:	04e7fa63          	bgeu	a5,a4,80003524 <ialloc+0x74>
    800034d4:	8aaa                	mv	s5,a0
    800034d6:	8bae                	mv	s7,a1
    800034d8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034da:	0001ca17          	auipc	s4,0x1c
    800034de:	b9ea0a13          	addi	s4,s4,-1122 # 8001f078 <sb>
    800034e2:	00048b1b          	sext.w	s6,s1
    800034e6:	0044d593          	srli	a1,s1,0x4
    800034ea:	018a2783          	lw	a5,24(s4)
    800034ee:	9dbd                	addw	a1,a1,a5
    800034f0:	8556                	mv	a0,s5
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	944080e7          	jalr	-1724(ra) # 80002e36 <bread>
    800034fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034fc:	05850993          	addi	s3,a0,88
    80003500:	00f4f793          	andi	a5,s1,15
    80003504:	079a                	slli	a5,a5,0x6
    80003506:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003508:	00099783          	lh	a5,0(s3)
    8000350c:	c3a1                	beqz	a5,8000354c <ialloc+0x9c>
    brelse(bp);
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	a58080e7          	jalr	-1448(ra) # 80002f66 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003516:	0485                	addi	s1,s1,1
    80003518:	00ca2703          	lw	a4,12(s4)
    8000351c:	0004879b          	sext.w	a5,s1
    80003520:	fce7e1e3          	bltu	a5,a4,800034e2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003524:	00005517          	auipc	a0,0x5
    80003528:	0b450513          	addi	a0,a0,180 # 800085d8 <syscalls+0x188>
    8000352c:	ffffd097          	auipc	ra,0xffffd
    80003530:	05e080e7          	jalr	94(ra) # 8000058a <printf>
  return 0;
    80003534:	4501                	li	a0,0
}
    80003536:	60a6                	ld	ra,72(sp)
    80003538:	6406                	ld	s0,64(sp)
    8000353a:	74e2                	ld	s1,56(sp)
    8000353c:	7942                	ld	s2,48(sp)
    8000353e:	79a2                	ld	s3,40(sp)
    80003540:	7a02                	ld	s4,32(sp)
    80003542:	6ae2                	ld	s5,24(sp)
    80003544:	6b42                	ld	s6,16(sp)
    80003546:	6ba2                	ld	s7,8(sp)
    80003548:	6161                	addi	sp,sp,80
    8000354a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000354c:	04000613          	li	a2,64
    80003550:	4581                	li	a1,0
    80003552:	854e                	mv	a0,s3
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	77e080e7          	jalr	1918(ra) # 80000cd2 <memset>
      dip->type = type;
    8000355c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003560:	854a                	mv	a0,s2
    80003562:	00001097          	auipc	ra,0x1
    80003566:	c8e080e7          	jalr	-882(ra) # 800041f0 <log_write>
      brelse(bp);
    8000356a:	854a                	mv	a0,s2
    8000356c:	00000097          	auipc	ra,0x0
    80003570:	9fa080e7          	jalr	-1542(ra) # 80002f66 <brelse>
      return iget(dev, inum);
    80003574:	85da                	mv	a1,s6
    80003576:	8556                	mv	a0,s5
    80003578:	00000097          	auipc	ra,0x0
    8000357c:	d9c080e7          	jalr	-612(ra) # 80003314 <iget>
    80003580:	bf5d                	j	80003536 <ialloc+0x86>

0000000080003582 <iupdate>:
{
    80003582:	1101                	addi	sp,sp,-32
    80003584:	ec06                	sd	ra,24(sp)
    80003586:	e822                	sd	s0,16(sp)
    80003588:	e426                	sd	s1,8(sp)
    8000358a:	e04a                	sd	s2,0(sp)
    8000358c:	1000                	addi	s0,sp,32
    8000358e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003590:	415c                	lw	a5,4(a0)
    80003592:	0047d79b          	srliw	a5,a5,0x4
    80003596:	0001c597          	auipc	a1,0x1c
    8000359a:	afa5a583          	lw	a1,-1286(a1) # 8001f090 <sb+0x18>
    8000359e:	9dbd                	addw	a1,a1,a5
    800035a0:	4108                	lw	a0,0(a0)
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	894080e7          	jalr	-1900(ra) # 80002e36 <bread>
    800035aa:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035ac:	05850793          	addi	a5,a0,88
    800035b0:	40d8                	lw	a4,4(s1)
    800035b2:	8b3d                	andi	a4,a4,15
    800035b4:	071a                	slli	a4,a4,0x6
    800035b6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035b8:	04449703          	lh	a4,68(s1)
    800035bc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035c0:	04649703          	lh	a4,70(s1)
    800035c4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800035c8:	04849703          	lh	a4,72(s1)
    800035cc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800035d0:	04a49703          	lh	a4,74(s1)
    800035d4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035d8:	44f8                	lw	a4,76(s1)
    800035da:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035dc:	03400613          	li	a2,52
    800035e0:	05048593          	addi	a1,s1,80
    800035e4:	00c78513          	addi	a0,a5,12
    800035e8:	ffffd097          	auipc	ra,0xffffd
    800035ec:	746080e7          	jalr	1862(ra) # 80000d2e <memmove>
  log_write(bp);
    800035f0:	854a                	mv	a0,s2
    800035f2:	00001097          	auipc	ra,0x1
    800035f6:	bfe080e7          	jalr	-1026(ra) # 800041f0 <log_write>
  brelse(bp);
    800035fa:	854a                	mv	a0,s2
    800035fc:	00000097          	auipc	ra,0x0
    80003600:	96a080e7          	jalr	-1686(ra) # 80002f66 <brelse>
}
    80003604:	60e2                	ld	ra,24(sp)
    80003606:	6442                	ld	s0,16(sp)
    80003608:	64a2                	ld	s1,8(sp)
    8000360a:	6902                	ld	s2,0(sp)
    8000360c:	6105                	addi	sp,sp,32
    8000360e:	8082                	ret

0000000080003610 <idup>:
{
    80003610:	1101                	addi	sp,sp,-32
    80003612:	ec06                	sd	ra,24(sp)
    80003614:	e822                	sd	s0,16(sp)
    80003616:	e426                	sd	s1,8(sp)
    80003618:	1000                	addi	s0,sp,32
    8000361a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000361c:	0001c517          	auipc	a0,0x1c
    80003620:	a7c50513          	addi	a0,a0,-1412 # 8001f098 <itable>
    80003624:	ffffd097          	auipc	ra,0xffffd
    80003628:	5b2080e7          	jalr	1458(ra) # 80000bd6 <acquire>
  ip->ref++;
    8000362c:	449c                	lw	a5,8(s1)
    8000362e:	2785                	addiw	a5,a5,1
    80003630:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003632:	0001c517          	auipc	a0,0x1c
    80003636:	a6650513          	addi	a0,a0,-1434 # 8001f098 <itable>
    8000363a:	ffffd097          	auipc	ra,0xffffd
    8000363e:	650080e7          	jalr	1616(ra) # 80000c8a <release>
}
    80003642:	8526                	mv	a0,s1
    80003644:	60e2                	ld	ra,24(sp)
    80003646:	6442                	ld	s0,16(sp)
    80003648:	64a2                	ld	s1,8(sp)
    8000364a:	6105                	addi	sp,sp,32
    8000364c:	8082                	ret

000000008000364e <ilock>:
{
    8000364e:	1101                	addi	sp,sp,-32
    80003650:	ec06                	sd	ra,24(sp)
    80003652:	e822                	sd	s0,16(sp)
    80003654:	e426                	sd	s1,8(sp)
    80003656:	e04a                	sd	s2,0(sp)
    80003658:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000365a:	c115                	beqz	a0,8000367e <ilock+0x30>
    8000365c:	84aa                	mv	s1,a0
    8000365e:	451c                	lw	a5,8(a0)
    80003660:	00f05f63          	blez	a5,8000367e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003664:	0541                	addi	a0,a0,16
    80003666:	00001097          	auipc	ra,0x1
    8000366a:	ca8080e7          	jalr	-856(ra) # 8000430e <acquiresleep>
  if(ip->valid == 0){
    8000366e:	40bc                	lw	a5,64(s1)
    80003670:	cf99                	beqz	a5,8000368e <ilock+0x40>
}
    80003672:	60e2                	ld	ra,24(sp)
    80003674:	6442                	ld	s0,16(sp)
    80003676:	64a2                	ld	s1,8(sp)
    80003678:	6902                	ld	s2,0(sp)
    8000367a:	6105                	addi	sp,sp,32
    8000367c:	8082                	ret
    panic("ilock");
    8000367e:	00005517          	auipc	a0,0x5
    80003682:	f7250513          	addi	a0,a0,-142 # 800085f0 <syscalls+0x1a0>
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	eba080e7          	jalr	-326(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000368e:	40dc                	lw	a5,4(s1)
    80003690:	0047d79b          	srliw	a5,a5,0x4
    80003694:	0001c597          	auipc	a1,0x1c
    80003698:	9fc5a583          	lw	a1,-1540(a1) # 8001f090 <sb+0x18>
    8000369c:	9dbd                	addw	a1,a1,a5
    8000369e:	4088                	lw	a0,0(s1)
    800036a0:	fffff097          	auipc	ra,0xfffff
    800036a4:	796080e7          	jalr	1942(ra) # 80002e36 <bread>
    800036a8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036aa:	05850593          	addi	a1,a0,88
    800036ae:	40dc                	lw	a5,4(s1)
    800036b0:	8bbd                	andi	a5,a5,15
    800036b2:	079a                	slli	a5,a5,0x6
    800036b4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036b6:	00059783          	lh	a5,0(a1)
    800036ba:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036be:	00259783          	lh	a5,2(a1)
    800036c2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036c6:	00459783          	lh	a5,4(a1)
    800036ca:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036ce:	00659783          	lh	a5,6(a1)
    800036d2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036d6:	459c                	lw	a5,8(a1)
    800036d8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036da:	03400613          	li	a2,52
    800036de:	05b1                	addi	a1,a1,12
    800036e0:	05048513          	addi	a0,s1,80
    800036e4:	ffffd097          	auipc	ra,0xffffd
    800036e8:	64a080e7          	jalr	1610(ra) # 80000d2e <memmove>
    brelse(bp);
    800036ec:	854a                	mv	a0,s2
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	878080e7          	jalr	-1928(ra) # 80002f66 <brelse>
    ip->valid = 1;
    800036f6:	4785                	li	a5,1
    800036f8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036fa:	04449783          	lh	a5,68(s1)
    800036fe:	fbb5                	bnez	a5,80003672 <ilock+0x24>
      panic("ilock: no type");
    80003700:	00005517          	auipc	a0,0x5
    80003704:	ef850513          	addi	a0,a0,-264 # 800085f8 <syscalls+0x1a8>
    80003708:	ffffd097          	auipc	ra,0xffffd
    8000370c:	e38080e7          	jalr	-456(ra) # 80000540 <panic>

0000000080003710 <iunlock>:
{
    80003710:	1101                	addi	sp,sp,-32
    80003712:	ec06                	sd	ra,24(sp)
    80003714:	e822                	sd	s0,16(sp)
    80003716:	e426                	sd	s1,8(sp)
    80003718:	e04a                	sd	s2,0(sp)
    8000371a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000371c:	c905                	beqz	a0,8000374c <iunlock+0x3c>
    8000371e:	84aa                	mv	s1,a0
    80003720:	01050913          	addi	s2,a0,16
    80003724:	854a                	mv	a0,s2
    80003726:	00001097          	auipc	ra,0x1
    8000372a:	c82080e7          	jalr	-894(ra) # 800043a8 <holdingsleep>
    8000372e:	cd19                	beqz	a0,8000374c <iunlock+0x3c>
    80003730:	449c                	lw	a5,8(s1)
    80003732:	00f05d63          	blez	a5,8000374c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003736:	854a                	mv	a0,s2
    80003738:	00001097          	auipc	ra,0x1
    8000373c:	c2c080e7          	jalr	-980(ra) # 80004364 <releasesleep>
}
    80003740:	60e2                	ld	ra,24(sp)
    80003742:	6442                	ld	s0,16(sp)
    80003744:	64a2                	ld	s1,8(sp)
    80003746:	6902                	ld	s2,0(sp)
    80003748:	6105                	addi	sp,sp,32
    8000374a:	8082                	ret
    panic("iunlock");
    8000374c:	00005517          	auipc	a0,0x5
    80003750:	ebc50513          	addi	a0,a0,-324 # 80008608 <syscalls+0x1b8>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	dec080e7          	jalr	-532(ra) # 80000540 <panic>

000000008000375c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000375c:	7179                	addi	sp,sp,-48
    8000375e:	f406                	sd	ra,40(sp)
    80003760:	f022                	sd	s0,32(sp)
    80003762:	ec26                	sd	s1,24(sp)
    80003764:	e84a                	sd	s2,16(sp)
    80003766:	e44e                	sd	s3,8(sp)
    80003768:	e052                	sd	s4,0(sp)
    8000376a:	1800                	addi	s0,sp,48
    8000376c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000376e:	05050493          	addi	s1,a0,80
    80003772:	08050913          	addi	s2,a0,128
    80003776:	a021                	j	8000377e <itrunc+0x22>
    80003778:	0491                	addi	s1,s1,4
    8000377a:	01248d63          	beq	s1,s2,80003794 <itrunc+0x38>
    if(ip->addrs[i]){
    8000377e:	408c                	lw	a1,0(s1)
    80003780:	dde5                	beqz	a1,80003778 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003782:	0009a503          	lw	a0,0(s3)
    80003786:	00000097          	auipc	ra,0x0
    8000378a:	8f6080e7          	jalr	-1802(ra) # 8000307c <bfree>
      ip->addrs[i] = 0;
    8000378e:	0004a023          	sw	zero,0(s1)
    80003792:	b7dd                	j	80003778 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003794:	0809a583          	lw	a1,128(s3)
    80003798:	e185                	bnez	a1,800037b8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000379a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000379e:	854e                	mv	a0,s3
    800037a0:	00000097          	auipc	ra,0x0
    800037a4:	de2080e7          	jalr	-542(ra) # 80003582 <iupdate>
}
    800037a8:	70a2                	ld	ra,40(sp)
    800037aa:	7402                	ld	s0,32(sp)
    800037ac:	64e2                	ld	s1,24(sp)
    800037ae:	6942                	ld	s2,16(sp)
    800037b0:	69a2                	ld	s3,8(sp)
    800037b2:	6a02                	ld	s4,0(sp)
    800037b4:	6145                	addi	sp,sp,48
    800037b6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037b8:	0009a503          	lw	a0,0(s3)
    800037bc:	fffff097          	auipc	ra,0xfffff
    800037c0:	67a080e7          	jalr	1658(ra) # 80002e36 <bread>
    800037c4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037c6:	05850493          	addi	s1,a0,88
    800037ca:	45850913          	addi	s2,a0,1112
    800037ce:	a021                	j	800037d6 <itrunc+0x7a>
    800037d0:	0491                	addi	s1,s1,4
    800037d2:	01248b63          	beq	s1,s2,800037e8 <itrunc+0x8c>
      if(a[j])
    800037d6:	408c                	lw	a1,0(s1)
    800037d8:	dde5                	beqz	a1,800037d0 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037da:	0009a503          	lw	a0,0(s3)
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	89e080e7          	jalr	-1890(ra) # 8000307c <bfree>
    800037e6:	b7ed                	j	800037d0 <itrunc+0x74>
    brelse(bp);
    800037e8:	8552                	mv	a0,s4
    800037ea:	fffff097          	auipc	ra,0xfffff
    800037ee:	77c080e7          	jalr	1916(ra) # 80002f66 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037f2:	0809a583          	lw	a1,128(s3)
    800037f6:	0009a503          	lw	a0,0(s3)
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	882080e7          	jalr	-1918(ra) # 8000307c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003802:	0809a023          	sw	zero,128(s3)
    80003806:	bf51                	j	8000379a <itrunc+0x3e>

0000000080003808 <iput>:
{
    80003808:	1101                	addi	sp,sp,-32
    8000380a:	ec06                	sd	ra,24(sp)
    8000380c:	e822                	sd	s0,16(sp)
    8000380e:	e426                	sd	s1,8(sp)
    80003810:	e04a                	sd	s2,0(sp)
    80003812:	1000                	addi	s0,sp,32
    80003814:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003816:	0001c517          	auipc	a0,0x1c
    8000381a:	88250513          	addi	a0,a0,-1918 # 8001f098 <itable>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	3b8080e7          	jalr	952(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003826:	4498                	lw	a4,8(s1)
    80003828:	4785                	li	a5,1
    8000382a:	02f70363          	beq	a4,a5,80003850 <iput+0x48>
  ip->ref--;
    8000382e:	449c                	lw	a5,8(s1)
    80003830:	37fd                	addiw	a5,a5,-1
    80003832:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003834:	0001c517          	auipc	a0,0x1c
    80003838:	86450513          	addi	a0,a0,-1948 # 8001f098 <itable>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	44e080e7          	jalr	1102(ra) # 80000c8a <release>
}
    80003844:	60e2                	ld	ra,24(sp)
    80003846:	6442                	ld	s0,16(sp)
    80003848:	64a2                	ld	s1,8(sp)
    8000384a:	6902                	ld	s2,0(sp)
    8000384c:	6105                	addi	sp,sp,32
    8000384e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003850:	40bc                	lw	a5,64(s1)
    80003852:	dff1                	beqz	a5,8000382e <iput+0x26>
    80003854:	04a49783          	lh	a5,74(s1)
    80003858:	fbf9                	bnez	a5,8000382e <iput+0x26>
    acquiresleep(&ip->lock);
    8000385a:	01048913          	addi	s2,s1,16
    8000385e:	854a                	mv	a0,s2
    80003860:	00001097          	auipc	ra,0x1
    80003864:	aae080e7          	jalr	-1362(ra) # 8000430e <acquiresleep>
    release(&itable.lock);
    80003868:	0001c517          	auipc	a0,0x1c
    8000386c:	83050513          	addi	a0,a0,-2000 # 8001f098 <itable>
    80003870:	ffffd097          	auipc	ra,0xffffd
    80003874:	41a080e7          	jalr	1050(ra) # 80000c8a <release>
    itrunc(ip);
    80003878:	8526                	mv	a0,s1
    8000387a:	00000097          	auipc	ra,0x0
    8000387e:	ee2080e7          	jalr	-286(ra) # 8000375c <itrunc>
    ip->type = 0;
    80003882:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003886:	8526                	mv	a0,s1
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	cfa080e7          	jalr	-774(ra) # 80003582 <iupdate>
    ip->valid = 0;
    80003890:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003894:	854a                	mv	a0,s2
    80003896:	00001097          	auipc	ra,0x1
    8000389a:	ace080e7          	jalr	-1330(ra) # 80004364 <releasesleep>
    acquire(&itable.lock);
    8000389e:	0001b517          	auipc	a0,0x1b
    800038a2:	7fa50513          	addi	a0,a0,2042 # 8001f098 <itable>
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	330080e7          	jalr	816(ra) # 80000bd6 <acquire>
    800038ae:	b741                	j	8000382e <iput+0x26>

00000000800038b0 <iunlockput>:
{
    800038b0:	1101                	addi	sp,sp,-32
    800038b2:	ec06                	sd	ra,24(sp)
    800038b4:	e822                	sd	s0,16(sp)
    800038b6:	e426                	sd	s1,8(sp)
    800038b8:	1000                	addi	s0,sp,32
    800038ba:	84aa                	mv	s1,a0
  iunlock(ip);
    800038bc:	00000097          	auipc	ra,0x0
    800038c0:	e54080e7          	jalr	-428(ra) # 80003710 <iunlock>
  iput(ip);
    800038c4:	8526                	mv	a0,s1
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	f42080e7          	jalr	-190(ra) # 80003808 <iput>
}
    800038ce:	60e2                	ld	ra,24(sp)
    800038d0:	6442                	ld	s0,16(sp)
    800038d2:	64a2                	ld	s1,8(sp)
    800038d4:	6105                	addi	sp,sp,32
    800038d6:	8082                	ret

00000000800038d8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038d8:	1141                	addi	sp,sp,-16
    800038da:	e422                	sd	s0,8(sp)
    800038dc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038de:	411c                	lw	a5,0(a0)
    800038e0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038e2:	415c                	lw	a5,4(a0)
    800038e4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038e6:	04451783          	lh	a5,68(a0)
    800038ea:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038ee:	04a51783          	lh	a5,74(a0)
    800038f2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038f6:	04c56783          	lwu	a5,76(a0)
    800038fa:	e99c                	sd	a5,16(a1)
}
    800038fc:	6422                	ld	s0,8(sp)
    800038fe:	0141                	addi	sp,sp,16
    80003900:	8082                	ret

0000000080003902 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003902:	457c                	lw	a5,76(a0)
    80003904:	0ed7e963          	bltu	a5,a3,800039f6 <readi+0xf4>
{
    80003908:	7159                	addi	sp,sp,-112
    8000390a:	f486                	sd	ra,104(sp)
    8000390c:	f0a2                	sd	s0,96(sp)
    8000390e:	eca6                	sd	s1,88(sp)
    80003910:	e8ca                	sd	s2,80(sp)
    80003912:	e4ce                	sd	s3,72(sp)
    80003914:	e0d2                	sd	s4,64(sp)
    80003916:	fc56                	sd	s5,56(sp)
    80003918:	f85a                	sd	s6,48(sp)
    8000391a:	f45e                	sd	s7,40(sp)
    8000391c:	f062                	sd	s8,32(sp)
    8000391e:	ec66                	sd	s9,24(sp)
    80003920:	e86a                	sd	s10,16(sp)
    80003922:	e46e                	sd	s11,8(sp)
    80003924:	1880                	addi	s0,sp,112
    80003926:	8b2a                	mv	s6,a0
    80003928:	8bae                	mv	s7,a1
    8000392a:	8a32                	mv	s4,a2
    8000392c:	84b6                	mv	s1,a3
    8000392e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003930:	9f35                	addw	a4,a4,a3
    return 0;
    80003932:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003934:	0ad76063          	bltu	a4,a3,800039d4 <readi+0xd2>
  if(off + n > ip->size)
    80003938:	00e7f463          	bgeu	a5,a4,80003940 <readi+0x3e>
    n = ip->size - off;
    8000393c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003940:	0a0a8963          	beqz	s5,800039f2 <readi+0xf0>
    80003944:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003946:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000394a:	5c7d                	li	s8,-1
    8000394c:	a82d                	j	80003986 <readi+0x84>
    8000394e:	020d1d93          	slli	s11,s10,0x20
    80003952:	020ddd93          	srli	s11,s11,0x20
    80003956:	05890613          	addi	a2,s2,88
    8000395a:	86ee                	mv	a3,s11
    8000395c:	963a                	add	a2,a2,a4
    8000395e:	85d2                	mv	a1,s4
    80003960:	855e                	mv	a0,s7
    80003962:	fffff097          	auipc	ra,0xfffff
    80003966:	afa080e7          	jalr	-1286(ra) # 8000245c <either_copyout>
    8000396a:	05850d63          	beq	a0,s8,800039c4 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000396e:	854a                	mv	a0,s2
    80003970:	fffff097          	auipc	ra,0xfffff
    80003974:	5f6080e7          	jalr	1526(ra) # 80002f66 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003978:	013d09bb          	addw	s3,s10,s3
    8000397c:	009d04bb          	addw	s1,s10,s1
    80003980:	9a6e                	add	s4,s4,s11
    80003982:	0559f763          	bgeu	s3,s5,800039d0 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003986:	00a4d59b          	srliw	a1,s1,0xa
    8000398a:	855a                	mv	a0,s6
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	89e080e7          	jalr	-1890(ra) # 8000322a <bmap>
    80003994:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003998:	cd85                	beqz	a1,800039d0 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000399a:	000b2503          	lw	a0,0(s6)
    8000399e:	fffff097          	auipc	ra,0xfffff
    800039a2:	498080e7          	jalr	1176(ra) # 80002e36 <bread>
    800039a6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039a8:	3ff4f713          	andi	a4,s1,1023
    800039ac:	40ec87bb          	subw	a5,s9,a4
    800039b0:	413a86bb          	subw	a3,s5,s3
    800039b4:	8d3e                	mv	s10,a5
    800039b6:	2781                	sext.w	a5,a5
    800039b8:	0006861b          	sext.w	a2,a3
    800039bc:	f8f679e3          	bgeu	a2,a5,8000394e <readi+0x4c>
    800039c0:	8d36                	mv	s10,a3
    800039c2:	b771                	j	8000394e <readi+0x4c>
      brelse(bp);
    800039c4:	854a                	mv	a0,s2
    800039c6:	fffff097          	auipc	ra,0xfffff
    800039ca:	5a0080e7          	jalr	1440(ra) # 80002f66 <brelse>
      tot = -1;
    800039ce:	59fd                	li	s3,-1
  }
  return tot;
    800039d0:	0009851b          	sext.w	a0,s3
}
    800039d4:	70a6                	ld	ra,104(sp)
    800039d6:	7406                	ld	s0,96(sp)
    800039d8:	64e6                	ld	s1,88(sp)
    800039da:	6946                	ld	s2,80(sp)
    800039dc:	69a6                	ld	s3,72(sp)
    800039de:	6a06                	ld	s4,64(sp)
    800039e0:	7ae2                	ld	s5,56(sp)
    800039e2:	7b42                	ld	s6,48(sp)
    800039e4:	7ba2                	ld	s7,40(sp)
    800039e6:	7c02                	ld	s8,32(sp)
    800039e8:	6ce2                	ld	s9,24(sp)
    800039ea:	6d42                	ld	s10,16(sp)
    800039ec:	6da2                	ld	s11,8(sp)
    800039ee:	6165                	addi	sp,sp,112
    800039f0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039f2:	89d6                	mv	s3,s5
    800039f4:	bff1                	j	800039d0 <readi+0xce>
    return 0;
    800039f6:	4501                	li	a0,0
}
    800039f8:	8082                	ret

00000000800039fa <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039fa:	457c                	lw	a5,76(a0)
    800039fc:	10d7e863          	bltu	a5,a3,80003b0c <writei+0x112>
{
    80003a00:	7159                	addi	sp,sp,-112
    80003a02:	f486                	sd	ra,104(sp)
    80003a04:	f0a2                	sd	s0,96(sp)
    80003a06:	eca6                	sd	s1,88(sp)
    80003a08:	e8ca                	sd	s2,80(sp)
    80003a0a:	e4ce                	sd	s3,72(sp)
    80003a0c:	e0d2                	sd	s4,64(sp)
    80003a0e:	fc56                	sd	s5,56(sp)
    80003a10:	f85a                	sd	s6,48(sp)
    80003a12:	f45e                	sd	s7,40(sp)
    80003a14:	f062                	sd	s8,32(sp)
    80003a16:	ec66                	sd	s9,24(sp)
    80003a18:	e86a                	sd	s10,16(sp)
    80003a1a:	e46e                	sd	s11,8(sp)
    80003a1c:	1880                	addi	s0,sp,112
    80003a1e:	8aaa                	mv	s5,a0
    80003a20:	8bae                	mv	s7,a1
    80003a22:	8a32                	mv	s4,a2
    80003a24:	8936                	mv	s2,a3
    80003a26:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a28:	00e687bb          	addw	a5,a3,a4
    80003a2c:	0ed7e263          	bltu	a5,a3,80003b10 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a30:	00043737          	lui	a4,0x43
    80003a34:	0ef76063          	bltu	a4,a5,80003b14 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a38:	0c0b0863          	beqz	s6,80003b08 <writei+0x10e>
    80003a3c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a42:	5c7d                	li	s8,-1
    80003a44:	a091                	j	80003a88 <writei+0x8e>
    80003a46:	020d1d93          	slli	s11,s10,0x20
    80003a4a:	020ddd93          	srli	s11,s11,0x20
    80003a4e:	05848513          	addi	a0,s1,88
    80003a52:	86ee                	mv	a3,s11
    80003a54:	8652                	mv	a2,s4
    80003a56:	85de                	mv	a1,s7
    80003a58:	953a                	add	a0,a0,a4
    80003a5a:	fffff097          	auipc	ra,0xfffff
    80003a5e:	a58080e7          	jalr	-1448(ra) # 800024b2 <either_copyin>
    80003a62:	07850263          	beq	a0,s8,80003ac6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a66:	8526                	mv	a0,s1
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	788080e7          	jalr	1928(ra) # 800041f0 <log_write>
    brelse(bp);
    80003a70:	8526                	mv	a0,s1
    80003a72:	fffff097          	auipc	ra,0xfffff
    80003a76:	4f4080e7          	jalr	1268(ra) # 80002f66 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a7a:	013d09bb          	addw	s3,s10,s3
    80003a7e:	012d093b          	addw	s2,s10,s2
    80003a82:	9a6e                	add	s4,s4,s11
    80003a84:	0569f663          	bgeu	s3,s6,80003ad0 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003a88:	00a9559b          	srliw	a1,s2,0xa
    80003a8c:	8556                	mv	a0,s5
    80003a8e:	fffff097          	auipc	ra,0xfffff
    80003a92:	79c080e7          	jalr	1948(ra) # 8000322a <bmap>
    80003a96:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a9a:	c99d                	beqz	a1,80003ad0 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003a9c:	000aa503          	lw	a0,0(s5)
    80003aa0:	fffff097          	auipc	ra,0xfffff
    80003aa4:	396080e7          	jalr	918(ra) # 80002e36 <bread>
    80003aa8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aaa:	3ff97713          	andi	a4,s2,1023
    80003aae:	40ec87bb          	subw	a5,s9,a4
    80003ab2:	413b06bb          	subw	a3,s6,s3
    80003ab6:	8d3e                	mv	s10,a5
    80003ab8:	2781                	sext.w	a5,a5
    80003aba:	0006861b          	sext.w	a2,a3
    80003abe:	f8f674e3          	bgeu	a2,a5,80003a46 <writei+0x4c>
    80003ac2:	8d36                	mv	s10,a3
    80003ac4:	b749                	j	80003a46 <writei+0x4c>
      brelse(bp);
    80003ac6:	8526                	mv	a0,s1
    80003ac8:	fffff097          	auipc	ra,0xfffff
    80003acc:	49e080e7          	jalr	1182(ra) # 80002f66 <brelse>
  }

  if(off > ip->size)
    80003ad0:	04caa783          	lw	a5,76(s5)
    80003ad4:	0127f463          	bgeu	a5,s2,80003adc <writei+0xe2>
    ip->size = off;
    80003ad8:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003adc:	8556                	mv	a0,s5
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	aa4080e7          	jalr	-1372(ra) # 80003582 <iupdate>

  return tot;
    80003ae6:	0009851b          	sext.w	a0,s3
}
    80003aea:	70a6                	ld	ra,104(sp)
    80003aec:	7406                	ld	s0,96(sp)
    80003aee:	64e6                	ld	s1,88(sp)
    80003af0:	6946                	ld	s2,80(sp)
    80003af2:	69a6                	ld	s3,72(sp)
    80003af4:	6a06                	ld	s4,64(sp)
    80003af6:	7ae2                	ld	s5,56(sp)
    80003af8:	7b42                	ld	s6,48(sp)
    80003afa:	7ba2                	ld	s7,40(sp)
    80003afc:	7c02                	ld	s8,32(sp)
    80003afe:	6ce2                	ld	s9,24(sp)
    80003b00:	6d42                	ld	s10,16(sp)
    80003b02:	6da2                	ld	s11,8(sp)
    80003b04:	6165                	addi	sp,sp,112
    80003b06:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b08:	89da                	mv	s3,s6
    80003b0a:	bfc9                	j	80003adc <writei+0xe2>
    return -1;
    80003b0c:	557d                	li	a0,-1
}
    80003b0e:	8082                	ret
    return -1;
    80003b10:	557d                	li	a0,-1
    80003b12:	bfe1                	j	80003aea <writei+0xf0>
    return -1;
    80003b14:	557d                	li	a0,-1
    80003b16:	bfd1                	j	80003aea <writei+0xf0>

0000000080003b18 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b18:	1141                	addi	sp,sp,-16
    80003b1a:	e406                	sd	ra,8(sp)
    80003b1c:	e022                	sd	s0,0(sp)
    80003b1e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b20:	4639                	li	a2,14
    80003b22:	ffffd097          	auipc	ra,0xffffd
    80003b26:	280080e7          	jalr	640(ra) # 80000da2 <strncmp>
}
    80003b2a:	60a2                	ld	ra,8(sp)
    80003b2c:	6402                	ld	s0,0(sp)
    80003b2e:	0141                	addi	sp,sp,16
    80003b30:	8082                	ret

0000000080003b32 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b32:	7139                	addi	sp,sp,-64
    80003b34:	fc06                	sd	ra,56(sp)
    80003b36:	f822                	sd	s0,48(sp)
    80003b38:	f426                	sd	s1,40(sp)
    80003b3a:	f04a                	sd	s2,32(sp)
    80003b3c:	ec4e                	sd	s3,24(sp)
    80003b3e:	e852                	sd	s4,16(sp)
    80003b40:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b42:	04451703          	lh	a4,68(a0)
    80003b46:	4785                	li	a5,1
    80003b48:	00f71a63          	bne	a4,a5,80003b5c <dirlookup+0x2a>
    80003b4c:	892a                	mv	s2,a0
    80003b4e:	89ae                	mv	s3,a1
    80003b50:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b52:	457c                	lw	a5,76(a0)
    80003b54:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b56:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b58:	e79d                	bnez	a5,80003b86 <dirlookup+0x54>
    80003b5a:	a8a5                	j	80003bd2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b5c:	00005517          	auipc	a0,0x5
    80003b60:	ab450513          	addi	a0,a0,-1356 # 80008610 <syscalls+0x1c0>
    80003b64:	ffffd097          	auipc	ra,0xffffd
    80003b68:	9dc080e7          	jalr	-1572(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003b6c:	00005517          	auipc	a0,0x5
    80003b70:	abc50513          	addi	a0,a0,-1348 # 80008628 <syscalls+0x1d8>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	9cc080e7          	jalr	-1588(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b7c:	24c1                	addiw	s1,s1,16
    80003b7e:	04c92783          	lw	a5,76(s2)
    80003b82:	04f4f763          	bgeu	s1,a5,80003bd0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b86:	4741                	li	a4,16
    80003b88:	86a6                	mv	a3,s1
    80003b8a:	fc040613          	addi	a2,s0,-64
    80003b8e:	4581                	li	a1,0
    80003b90:	854a                	mv	a0,s2
    80003b92:	00000097          	auipc	ra,0x0
    80003b96:	d70080e7          	jalr	-656(ra) # 80003902 <readi>
    80003b9a:	47c1                	li	a5,16
    80003b9c:	fcf518e3          	bne	a0,a5,80003b6c <dirlookup+0x3a>
    if(de.inum == 0)
    80003ba0:	fc045783          	lhu	a5,-64(s0)
    80003ba4:	dfe1                	beqz	a5,80003b7c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ba6:	fc240593          	addi	a1,s0,-62
    80003baa:	854e                	mv	a0,s3
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	f6c080e7          	jalr	-148(ra) # 80003b18 <namecmp>
    80003bb4:	f561                	bnez	a0,80003b7c <dirlookup+0x4a>
      if(poff)
    80003bb6:	000a0463          	beqz	s4,80003bbe <dirlookup+0x8c>
        *poff = off;
    80003bba:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bbe:	fc045583          	lhu	a1,-64(s0)
    80003bc2:	00092503          	lw	a0,0(s2)
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	74e080e7          	jalr	1870(ra) # 80003314 <iget>
    80003bce:	a011                	j	80003bd2 <dirlookup+0xa0>
  return 0;
    80003bd0:	4501                	li	a0,0
}
    80003bd2:	70e2                	ld	ra,56(sp)
    80003bd4:	7442                	ld	s0,48(sp)
    80003bd6:	74a2                	ld	s1,40(sp)
    80003bd8:	7902                	ld	s2,32(sp)
    80003bda:	69e2                	ld	s3,24(sp)
    80003bdc:	6a42                	ld	s4,16(sp)
    80003bde:	6121                	addi	sp,sp,64
    80003be0:	8082                	ret

0000000080003be2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003be2:	711d                	addi	sp,sp,-96
    80003be4:	ec86                	sd	ra,88(sp)
    80003be6:	e8a2                	sd	s0,80(sp)
    80003be8:	e4a6                	sd	s1,72(sp)
    80003bea:	e0ca                	sd	s2,64(sp)
    80003bec:	fc4e                	sd	s3,56(sp)
    80003bee:	f852                	sd	s4,48(sp)
    80003bf0:	f456                	sd	s5,40(sp)
    80003bf2:	f05a                	sd	s6,32(sp)
    80003bf4:	ec5e                	sd	s7,24(sp)
    80003bf6:	e862                	sd	s8,16(sp)
    80003bf8:	e466                	sd	s9,8(sp)
    80003bfa:	e06a                	sd	s10,0(sp)
    80003bfc:	1080                	addi	s0,sp,96
    80003bfe:	84aa                	mv	s1,a0
    80003c00:	8b2e                	mv	s6,a1
    80003c02:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c04:	00054703          	lbu	a4,0(a0)
    80003c08:	02f00793          	li	a5,47
    80003c0c:	02f70363          	beq	a4,a5,80003c32 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c10:	ffffe097          	auipc	ra,0xffffe
    80003c14:	d9c080e7          	jalr	-612(ra) # 800019ac <myproc>
    80003c18:	15053503          	ld	a0,336(a0)
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	9f4080e7          	jalr	-1548(ra) # 80003610 <idup>
    80003c24:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c26:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c2a:	4cb5                	li	s9,13
  len = path - s;
    80003c2c:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c2e:	4c05                	li	s8,1
    80003c30:	a87d                	j	80003cee <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003c32:	4585                	li	a1,1
    80003c34:	4505                	li	a0,1
    80003c36:	fffff097          	auipc	ra,0xfffff
    80003c3a:	6de080e7          	jalr	1758(ra) # 80003314 <iget>
    80003c3e:	8a2a                	mv	s4,a0
    80003c40:	b7dd                	j	80003c26 <namex+0x44>
      iunlockput(ip);
    80003c42:	8552                	mv	a0,s4
    80003c44:	00000097          	auipc	ra,0x0
    80003c48:	c6c080e7          	jalr	-916(ra) # 800038b0 <iunlockput>
      return 0;
    80003c4c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c4e:	8552                	mv	a0,s4
    80003c50:	60e6                	ld	ra,88(sp)
    80003c52:	6446                	ld	s0,80(sp)
    80003c54:	64a6                	ld	s1,72(sp)
    80003c56:	6906                	ld	s2,64(sp)
    80003c58:	79e2                	ld	s3,56(sp)
    80003c5a:	7a42                	ld	s4,48(sp)
    80003c5c:	7aa2                	ld	s5,40(sp)
    80003c5e:	7b02                	ld	s6,32(sp)
    80003c60:	6be2                	ld	s7,24(sp)
    80003c62:	6c42                	ld	s8,16(sp)
    80003c64:	6ca2                	ld	s9,8(sp)
    80003c66:	6d02                	ld	s10,0(sp)
    80003c68:	6125                	addi	sp,sp,96
    80003c6a:	8082                	ret
      iunlock(ip);
    80003c6c:	8552                	mv	a0,s4
    80003c6e:	00000097          	auipc	ra,0x0
    80003c72:	aa2080e7          	jalr	-1374(ra) # 80003710 <iunlock>
      return ip;
    80003c76:	bfe1                	j	80003c4e <namex+0x6c>
      iunlockput(ip);
    80003c78:	8552                	mv	a0,s4
    80003c7a:	00000097          	auipc	ra,0x0
    80003c7e:	c36080e7          	jalr	-970(ra) # 800038b0 <iunlockput>
      return 0;
    80003c82:	8a4e                	mv	s4,s3
    80003c84:	b7e9                	j	80003c4e <namex+0x6c>
  len = path - s;
    80003c86:	40998633          	sub	a2,s3,s1
    80003c8a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003c8e:	09acd863          	bge	s9,s10,80003d1e <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003c92:	4639                	li	a2,14
    80003c94:	85a6                	mv	a1,s1
    80003c96:	8556                	mv	a0,s5
    80003c98:	ffffd097          	auipc	ra,0xffffd
    80003c9c:	096080e7          	jalr	150(ra) # 80000d2e <memmove>
    80003ca0:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ca2:	0004c783          	lbu	a5,0(s1)
    80003ca6:	01279763          	bne	a5,s2,80003cb4 <namex+0xd2>
    path++;
    80003caa:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cac:	0004c783          	lbu	a5,0(s1)
    80003cb0:	ff278de3          	beq	a5,s2,80003caa <namex+0xc8>
    ilock(ip);
    80003cb4:	8552                	mv	a0,s4
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	998080e7          	jalr	-1640(ra) # 8000364e <ilock>
    if(ip->type != T_DIR){
    80003cbe:	044a1783          	lh	a5,68(s4)
    80003cc2:	f98790e3          	bne	a5,s8,80003c42 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003cc6:	000b0563          	beqz	s6,80003cd0 <namex+0xee>
    80003cca:	0004c783          	lbu	a5,0(s1)
    80003cce:	dfd9                	beqz	a5,80003c6c <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cd0:	865e                	mv	a2,s7
    80003cd2:	85d6                	mv	a1,s5
    80003cd4:	8552                	mv	a0,s4
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	e5c080e7          	jalr	-420(ra) # 80003b32 <dirlookup>
    80003cde:	89aa                	mv	s3,a0
    80003ce0:	dd41                	beqz	a0,80003c78 <namex+0x96>
    iunlockput(ip);
    80003ce2:	8552                	mv	a0,s4
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	bcc080e7          	jalr	-1076(ra) # 800038b0 <iunlockput>
    ip = next;
    80003cec:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003cee:	0004c783          	lbu	a5,0(s1)
    80003cf2:	01279763          	bne	a5,s2,80003d00 <namex+0x11e>
    path++;
    80003cf6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cf8:	0004c783          	lbu	a5,0(s1)
    80003cfc:	ff278de3          	beq	a5,s2,80003cf6 <namex+0x114>
  if(*path == 0)
    80003d00:	cb9d                	beqz	a5,80003d36 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003d02:	0004c783          	lbu	a5,0(s1)
    80003d06:	89a6                	mv	s3,s1
  len = path - s;
    80003d08:	8d5e                	mv	s10,s7
    80003d0a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d0c:	01278963          	beq	a5,s2,80003d1e <namex+0x13c>
    80003d10:	dbbd                	beqz	a5,80003c86 <namex+0xa4>
    path++;
    80003d12:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d14:	0009c783          	lbu	a5,0(s3)
    80003d18:	ff279ce3          	bne	a5,s2,80003d10 <namex+0x12e>
    80003d1c:	b7ad                	j	80003c86 <namex+0xa4>
    memmove(name, s, len);
    80003d1e:	2601                	sext.w	a2,a2
    80003d20:	85a6                	mv	a1,s1
    80003d22:	8556                	mv	a0,s5
    80003d24:	ffffd097          	auipc	ra,0xffffd
    80003d28:	00a080e7          	jalr	10(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003d2c:	9d56                	add	s10,s10,s5
    80003d2e:	000d0023          	sb	zero,0(s10)
    80003d32:	84ce                	mv	s1,s3
    80003d34:	b7bd                	j	80003ca2 <namex+0xc0>
  if(nameiparent){
    80003d36:	f00b0ce3          	beqz	s6,80003c4e <namex+0x6c>
    iput(ip);
    80003d3a:	8552                	mv	a0,s4
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	acc080e7          	jalr	-1332(ra) # 80003808 <iput>
    return 0;
    80003d44:	4a01                	li	s4,0
    80003d46:	b721                	j	80003c4e <namex+0x6c>

0000000080003d48 <dirlink>:
{
    80003d48:	7139                	addi	sp,sp,-64
    80003d4a:	fc06                	sd	ra,56(sp)
    80003d4c:	f822                	sd	s0,48(sp)
    80003d4e:	f426                	sd	s1,40(sp)
    80003d50:	f04a                	sd	s2,32(sp)
    80003d52:	ec4e                	sd	s3,24(sp)
    80003d54:	e852                	sd	s4,16(sp)
    80003d56:	0080                	addi	s0,sp,64
    80003d58:	892a                	mv	s2,a0
    80003d5a:	8a2e                	mv	s4,a1
    80003d5c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d5e:	4601                	li	a2,0
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	dd2080e7          	jalr	-558(ra) # 80003b32 <dirlookup>
    80003d68:	e93d                	bnez	a0,80003dde <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d6a:	04c92483          	lw	s1,76(s2)
    80003d6e:	c49d                	beqz	s1,80003d9c <dirlink+0x54>
    80003d70:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d72:	4741                	li	a4,16
    80003d74:	86a6                	mv	a3,s1
    80003d76:	fc040613          	addi	a2,s0,-64
    80003d7a:	4581                	li	a1,0
    80003d7c:	854a                	mv	a0,s2
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	b84080e7          	jalr	-1148(ra) # 80003902 <readi>
    80003d86:	47c1                	li	a5,16
    80003d88:	06f51163          	bne	a0,a5,80003dea <dirlink+0xa2>
    if(de.inum == 0)
    80003d8c:	fc045783          	lhu	a5,-64(s0)
    80003d90:	c791                	beqz	a5,80003d9c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d92:	24c1                	addiw	s1,s1,16
    80003d94:	04c92783          	lw	a5,76(s2)
    80003d98:	fcf4ede3          	bltu	s1,a5,80003d72 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d9c:	4639                	li	a2,14
    80003d9e:	85d2                	mv	a1,s4
    80003da0:	fc240513          	addi	a0,s0,-62
    80003da4:	ffffd097          	auipc	ra,0xffffd
    80003da8:	03a080e7          	jalr	58(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003dac:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003db0:	4741                	li	a4,16
    80003db2:	86a6                	mv	a3,s1
    80003db4:	fc040613          	addi	a2,s0,-64
    80003db8:	4581                	li	a1,0
    80003dba:	854a                	mv	a0,s2
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	c3e080e7          	jalr	-962(ra) # 800039fa <writei>
    80003dc4:	1541                	addi	a0,a0,-16
    80003dc6:	00a03533          	snez	a0,a0
    80003dca:	40a00533          	neg	a0,a0
}
    80003dce:	70e2                	ld	ra,56(sp)
    80003dd0:	7442                	ld	s0,48(sp)
    80003dd2:	74a2                	ld	s1,40(sp)
    80003dd4:	7902                	ld	s2,32(sp)
    80003dd6:	69e2                	ld	s3,24(sp)
    80003dd8:	6a42                	ld	s4,16(sp)
    80003dda:	6121                	addi	sp,sp,64
    80003ddc:	8082                	ret
    iput(ip);
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	a2a080e7          	jalr	-1494(ra) # 80003808 <iput>
    return -1;
    80003de6:	557d                	li	a0,-1
    80003de8:	b7dd                	j	80003dce <dirlink+0x86>
      panic("dirlink read");
    80003dea:	00005517          	auipc	a0,0x5
    80003dee:	84e50513          	addi	a0,a0,-1970 # 80008638 <syscalls+0x1e8>
    80003df2:	ffffc097          	auipc	ra,0xffffc
    80003df6:	74e080e7          	jalr	1870(ra) # 80000540 <panic>

0000000080003dfa <namei>:

struct inode*
namei(char *path)
{
    80003dfa:	1101                	addi	sp,sp,-32
    80003dfc:	ec06                	sd	ra,24(sp)
    80003dfe:	e822                	sd	s0,16(sp)
    80003e00:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e02:	fe040613          	addi	a2,s0,-32
    80003e06:	4581                	li	a1,0
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	dda080e7          	jalr	-550(ra) # 80003be2 <namex>
}
    80003e10:	60e2                	ld	ra,24(sp)
    80003e12:	6442                	ld	s0,16(sp)
    80003e14:	6105                	addi	sp,sp,32
    80003e16:	8082                	ret

0000000080003e18 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e18:	1141                	addi	sp,sp,-16
    80003e1a:	e406                	sd	ra,8(sp)
    80003e1c:	e022                	sd	s0,0(sp)
    80003e1e:	0800                	addi	s0,sp,16
    80003e20:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e22:	4585                	li	a1,1
    80003e24:	00000097          	auipc	ra,0x0
    80003e28:	dbe080e7          	jalr	-578(ra) # 80003be2 <namex>
}
    80003e2c:	60a2                	ld	ra,8(sp)
    80003e2e:	6402                	ld	s0,0(sp)
    80003e30:	0141                	addi	sp,sp,16
    80003e32:	8082                	ret

0000000080003e34 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e34:	1101                	addi	sp,sp,-32
    80003e36:	ec06                	sd	ra,24(sp)
    80003e38:	e822                	sd	s0,16(sp)
    80003e3a:	e426                	sd	s1,8(sp)
    80003e3c:	e04a                	sd	s2,0(sp)
    80003e3e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e40:	0001d917          	auipc	s2,0x1d
    80003e44:	d0090913          	addi	s2,s2,-768 # 80020b40 <log>
    80003e48:	01892583          	lw	a1,24(s2)
    80003e4c:	02892503          	lw	a0,40(s2)
    80003e50:	fffff097          	auipc	ra,0xfffff
    80003e54:	fe6080e7          	jalr	-26(ra) # 80002e36 <bread>
    80003e58:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e5a:	02c92683          	lw	a3,44(s2)
    80003e5e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e60:	02d05863          	blez	a3,80003e90 <write_head+0x5c>
    80003e64:	0001d797          	auipc	a5,0x1d
    80003e68:	d0c78793          	addi	a5,a5,-756 # 80020b70 <log+0x30>
    80003e6c:	05c50713          	addi	a4,a0,92
    80003e70:	36fd                	addiw	a3,a3,-1
    80003e72:	02069613          	slli	a2,a3,0x20
    80003e76:	01e65693          	srli	a3,a2,0x1e
    80003e7a:	0001d617          	auipc	a2,0x1d
    80003e7e:	cfa60613          	addi	a2,a2,-774 # 80020b74 <log+0x34>
    80003e82:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e84:	4390                	lw	a2,0(a5)
    80003e86:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e88:	0791                	addi	a5,a5,4
    80003e8a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003e8c:	fed79ce3          	bne	a5,a3,80003e84 <write_head+0x50>
  }
  bwrite(buf);
    80003e90:	8526                	mv	a0,s1
    80003e92:	fffff097          	auipc	ra,0xfffff
    80003e96:	096080e7          	jalr	150(ra) # 80002f28 <bwrite>
  brelse(buf);
    80003e9a:	8526                	mv	a0,s1
    80003e9c:	fffff097          	auipc	ra,0xfffff
    80003ea0:	0ca080e7          	jalr	202(ra) # 80002f66 <brelse>
}
    80003ea4:	60e2                	ld	ra,24(sp)
    80003ea6:	6442                	ld	s0,16(sp)
    80003ea8:	64a2                	ld	s1,8(sp)
    80003eaa:	6902                	ld	s2,0(sp)
    80003eac:	6105                	addi	sp,sp,32
    80003eae:	8082                	ret

0000000080003eb0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eb0:	0001d797          	auipc	a5,0x1d
    80003eb4:	cbc7a783          	lw	a5,-836(a5) # 80020b6c <log+0x2c>
    80003eb8:	0af05d63          	blez	a5,80003f72 <install_trans+0xc2>
{
    80003ebc:	7139                	addi	sp,sp,-64
    80003ebe:	fc06                	sd	ra,56(sp)
    80003ec0:	f822                	sd	s0,48(sp)
    80003ec2:	f426                	sd	s1,40(sp)
    80003ec4:	f04a                	sd	s2,32(sp)
    80003ec6:	ec4e                	sd	s3,24(sp)
    80003ec8:	e852                	sd	s4,16(sp)
    80003eca:	e456                	sd	s5,8(sp)
    80003ecc:	e05a                	sd	s6,0(sp)
    80003ece:	0080                	addi	s0,sp,64
    80003ed0:	8b2a                	mv	s6,a0
    80003ed2:	0001da97          	auipc	s5,0x1d
    80003ed6:	c9ea8a93          	addi	s5,s5,-866 # 80020b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eda:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003edc:	0001d997          	auipc	s3,0x1d
    80003ee0:	c6498993          	addi	s3,s3,-924 # 80020b40 <log>
    80003ee4:	a00d                	j	80003f06 <install_trans+0x56>
    brelse(lbuf);
    80003ee6:	854a                	mv	a0,s2
    80003ee8:	fffff097          	auipc	ra,0xfffff
    80003eec:	07e080e7          	jalr	126(ra) # 80002f66 <brelse>
    brelse(dbuf);
    80003ef0:	8526                	mv	a0,s1
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	074080e7          	jalr	116(ra) # 80002f66 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003efa:	2a05                	addiw	s4,s4,1
    80003efc:	0a91                	addi	s5,s5,4
    80003efe:	02c9a783          	lw	a5,44(s3)
    80003f02:	04fa5e63          	bge	s4,a5,80003f5e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f06:	0189a583          	lw	a1,24(s3)
    80003f0a:	014585bb          	addw	a1,a1,s4
    80003f0e:	2585                	addiw	a1,a1,1
    80003f10:	0289a503          	lw	a0,40(s3)
    80003f14:	fffff097          	auipc	ra,0xfffff
    80003f18:	f22080e7          	jalr	-222(ra) # 80002e36 <bread>
    80003f1c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f1e:	000aa583          	lw	a1,0(s5)
    80003f22:	0289a503          	lw	a0,40(s3)
    80003f26:	fffff097          	auipc	ra,0xfffff
    80003f2a:	f10080e7          	jalr	-240(ra) # 80002e36 <bread>
    80003f2e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f30:	40000613          	li	a2,1024
    80003f34:	05890593          	addi	a1,s2,88
    80003f38:	05850513          	addi	a0,a0,88
    80003f3c:	ffffd097          	auipc	ra,0xffffd
    80003f40:	df2080e7          	jalr	-526(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f44:	8526                	mv	a0,s1
    80003f46:	fffff097          	auipc	ra,0xfffff
    80003f4a:	fe2080e7          	jalr	-30(ra) # 80002f28 <bwrite>
    if(recovering == 0)
    80003f4e:	f80b1ce3          	bnez	s6,80003ee6 <install_trans+0x36>
      bunpin(dbuf);
    80003f52:	8526                	mv	a0,s1
    80003f54:	fffff097          	auipc	ra,0xfffff
    80003f58:	0ec080e7          	jalr	236(ra) # 80003040 <bunpin>
    80003f5c:	b769                	j	80003ee6 <install_trans+0x36>
}
    80003f5e:	70e2                	ld	ra,56(sp)
    80003f60:	7442                	ld	s0,48(sp)
    80003f62:	74a2                	ld	s1,40(sp)
    80003f64:	7902                	ld	s2,32(sp)
    80003f66:	69e2                	ld	s3,24(sp)
    80003f68:	6a42                	ld	s4,16(sp)
    80003f6a:	6aa2                	ld	s5,8(sp)
    80003f6c:	6b02                	ld	s6,0(sp)
    80003f6e:	6121                	addi	sp,sp,64
    80003f70:	8082                	ret
    80003f72:	8082                	ret

0000000080003f74 <initlog>:
{
    80003f74:	7179                	addi	sp,sp,-48
    80003f76:	f406                	sd	ra,40(sp)
    80003f78:	f022                	sd	s0,32(sp)
    80003f7a:	ec26                	sd	s1,24(sp)
    80003f7c:	e84a                	sd	s2,16(sp)
    80003f7e:	e44e                	sd	s3,8(sp)
    80003f80:	1800                	addi	s0,sp,48
    80003f82:	892a                	mv	s2,a0
    80003f84:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f86:	0001d497          	auipc	s1,0x1d
    80003f8a:	bba48493          	addi	s1,s1,-1094 # 80020b40 <log>
    80003f8e:	00004597          	auipc	a1,0x4
    80003f92:	6ba58593          	addi	a1,a1,1722 # 80008648 <syscalls+0x1f8>
    80003f96:	8526                	mv	a0,s1
    80003f98:	ffffd097          	auipc	ra,0xffffd
    80003f9c:	bae080e7          	jalr	-1106(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003fa0:	0149a583          	lw	a1,20(s3)
    80003fa4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fa6:	0109a783          	lw	a5,16(s3)
    80003faa:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003fac:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fb0:	854a                	mv	a0,s2
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	e84080e7          	jalr	-380(ra) # 80002e36 <bread>
  log.lh.n = lh->n;
    80003fba:	4d34                	lw	a3,88(a0)
    80003fbc:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fbe:	02d05663          	blez	a3,80003fea <initlog+0x76>
    80003fc2:	05c50793          	addi	a5,a0,92
    80003fc6:	0001d717          	auipc	a4,0x1d
    80003fca:	baa70713          	addi	a4,a4,-1110 # 80020b70 <log+0x30>
    80003fce:	36fd                	addiw	a3,a3,-1
    80003fd0:	02069613          	slli	a2,a3,0x20
    80003fd4:	01e65693          	srli	a3,a2,0x1e
    80003fd8:	06050613          	addi	a2,a0,96
    80003fdc:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003fde:	4390                	lw	a2,0(a5)
    80003fe0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fe2:	0791                	addi	a5,a5,4
    80003fe4:	0711                	addi	a4,a4,4
    80003fe6:	fed79ce3          	bne	a5,a3,80003fde <initlog+0x6a>
  brelse(buf);
    80003fea:	fffff097          	auipc	ra,0xfffff
    80003fee:	f7c080e7          	jalr	-132(ra) # 80002f66 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ff2:	4505                	li	a0,1
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	ebc080e7          	jalr	-324(ra) # 80003eb0 <install_trans>
  log.lh.n = 0;
    80003ffc:	0001d797          	auipc	a5,0x1d
    80004000:	b607a823          	sw	zero,-1168(a5) # 80020b6c <log+0x2c>
  write_head(); // clear the log
    80004004:	00000097          	auipc	ra,0x0
    80004008:	e30080e7          	jalr	-464(ra) # 80003e34 <write_head>
}
    8000400c:	70a2                	ld	ra,40(sp)
    8000400e:	7402                	ld	s0,32(sp)
    80004010:	64e2                	ld	s1,24(sp)
    80004012:	6942                	ld	s2,16(sp)
    80004014:	69a2                	ld	s3,8(sp)
    80004016:	6145                	addi	sp,sp,48
    80004018:	8082                	ret

000000008000401a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000401a:	1101                	addi	sp,sp,-32
    8000401c:	ec06                	sd	ra,24(sp)
    8000401e:	e822                	sd	s0,16(sp)
    80004020:	e426                	sd	s1,8(sp)
    80004022:	e04a                	sd	s2,0(sp)
    80004024:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004026:	0001d517          	auipc	a0,0x1d
    8000402a:	b1a50513          	addi	a0,a0,-1254 # 80020b40 <log>
    8000402e:	ffffd097          	auipc	ra,0xffffd
    80004032:	ba8080e7          	jalr	-1112(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004036:	0001d497          	auipc	s1,0x1d
    8000403a:	b0a48493          	addi	s1,s1,-1270 # 80020b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000403e:	4979                	li	s2,30
    80004040:	a039                	j	8000404e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004042:	85a6                	mv	a1,s1
    80004044:	8526                	mv	a0,s1
    80004046:	ffffe097          	auipc	ra,0xffffe
    8000404a:	00e080e7          	jalr	14(ra) # 80002054 <sleep>
    if(log.committing){
    8000404e:	50dc                	lw	a5,36(s1)
    80004050:	fbed                	bnez	a5,80004042 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004052:	5098                	lw	a4,32(s1)
    80004054:	2705                	addiw	a4,a4,1
    80004056:	0007069b          	sext.w	a3,a4
    8000405a:	0027179b          	slliw	a5,a4,0x2
    8000405e:	9fb9                	addw	a5,a5,a4
    80004060:	0017979b          	slliw	a5,a5,0x1
    80004064:	54d8                	lw	a4,44(s1)
    80004066:	9fb9                	addw	a5,a5,a4
    80004068:	00f95963          	bge	s2,a5,8000407a <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000406c:	85a6                	mv	a1,s1
    8000406e:	8526                	mv	a0,s1
    80004070:	ffffe097          	auipc	ra,0xffffe
    80004074:	fe4080e7          	jalr	-28(ra) # 80002054 <sleep>
    80004078:	bfd9                	j	8000404e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000407a:	0001d517          	auipc	a0,0x1d
    8000407e:	ac650513          	addi	a0,a0,-1338 # 80020b40 <log>
    80004082:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004084:	ffffd097          	auipc	ra,0xffffd
    80004088:	c06080e7          	jalr	-1018(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000408c:	60e2                	ld	ra,24(sp)
    8000408e:	6442                	ld	s0,16(sp)
    80004090:	64a2                	ld	s1,8(sp)
    80004092:	6902                	ld	s2,0(sp)
    80004094:	6105                	addi	sp,sp,32
    80004096:	8082                	ret

0000000080004098 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004098:	7139                	addi	sp,sp,-64
    8000409a:	fc06                	sd	ra,56(sp)
    8000409c:	f822                	sd	s0,48(sp)
    8000409e:	f426                	sd	s1,40(sp)
    800040a0:	f04a                	sd	s2,32(sp)
    800040a2:	ec4e                	sd	s3,24(sp)
    800040a4:	e852                	sd	s4,16(sp)
    800040a6:	e456                	sd	s5,8(sp)
    800040a8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040aa:	0001d497          	auipc	s1,0x1d
    800040ae:	a9648493          	addi	s1,s1,-1386 # 80020b40 <log>
    800040b2:	8526                	mv	a0,s1
    800040b4:	ffffd097          	auipc	ra,0xffffd
    800040b8:	b22080e7          	jalr	-1246(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800040bc:	509c                	lw	a5,32(s1)
    800040be:	37fd                	addiw	a5,a5,-1
    800040c0:	0007891b          	sext.w	s2,a5
    800040c4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040c6:	50dc                	lw	a5,36(s1)
    800040c8:	e7b9                	bnez	a5,80004116 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040ca:	04091e63          	bnez	s2,80004126 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040ce:	0001d497          	auipc	s1,0x1d
    800040d2:	a7248493          	addi	s1,s1,-1422 # 80020b40 <log>
    800040d6:	4785                	li	a5,1
    800040d8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040da:	8526                	mv	a0,s1
    800040dc:	ffffd097          	auipc	ra,0xffffd
    800040e0:	bae080e7          	jalr	-1106(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040e4:	54dc                	lw	a5,44(s1)
    800040e6:	06f04763          	bgtz	a5,80004154 <end_op+0xbc>
    acquire(&log.lock);
    800040ea:	0001d497          	auipc	s1,0x1d
    800040ee:	a5648493          	addi	s1,s1,-1450 # 80020b40 <log>
    800040f2:	8526                	mv	a0,s1
    800040f4:	ffffd097          	auipc	ra,0xffffd
    800040f8:	ae2080e7          	jalr	-1310(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800040fc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004100:	8526                	mv	a0,s1
    80004102:	ffffe097          	auipc	ra,0xffffe
    80004106:	fb6080e7          	jalr	-74(ra) # 800020b8 <wakeup>
    release(&log.lock);
    8000410a:	8526                	mv	a0,s1
    8000410c:	ffffd097          	auipc	ra,0xffffd
    80004110:	b7e080e7          	jalr	-1154(ra) # 80000c8a <release>
}
    80004114:	a03d                	j	80004142 <end_op+0xaa>
    panic("log.committing");
    80004116:	00004517          	auipc	a0,0x4
    8000411a:	53a50513          	addi	a0,a0,1338 # 80008650 <syscalls+0x200>
    8000411e:	ffffc097          	auipc	ra,0xffffc
    80004122:	422080e7          	jalr	1058(ra) # 80000540 <panic>
    wakeup(&log);
    80004126:	0001d497          	auipc	s1,0x1d
    8000412a:	a1a48493          	addi	s1,s1,-1510 # 80020b40 <log>
    8000412e:	8526                	mv	a0,s1
    80004130:	ffffe097          	auipc	ra,0xffffe
    80004134:	f88080e7          	jalr	-120(ra) # 800020b8 <wakeup>
  release(&log.lock);
    80004138:	8526                	mv	a0,s1
    8000413a:	ffffd097          	auipc	ra,0xffffd
    8000413e:	b50080e7          	jalr	-1200(ra) # 80000c8a <release>
}
    80004142:	70e2                	ld	ra,56(sp)
    80004144:	7442                	ld	s0,48(sp)
    80004146:	74a2                	ld	s1,40(sp)
    80004148:	7902                	ld	s2,32(sp)
    8000414a:	69e2                	ld	s3,24(sp)
    8000414c:	6a42                	ld	s4,16(sp)
    8000414e:	6aa2                	ld	s5,8(sp)
    80004150:	6121                	addi	sp,sp,64
    80004152:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004154:	0001da97          	auipc	s5,0x1d
    80004158:	a1ca8a93          	addi	s5,s5,-1508 # 80020b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000415c:	0001da17          	auipc	s4,0x1d
    80004160:	9e4a0a13          	addi	s4,s4,-1564 # 80020b40 <log>
    80004164:	018a2583          	lw	a1,24(s4)
    80004168:	012585bb          	addw	a1,a1,s2
    8000416c:	2585                	addiw	a1,a1,1
    8000416e:	028a2503          	lw	a0,40(s4)
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	cc4080e7          	jalr	-828(ra) # 80002e36 <bread>
    8000417a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000417c:	000aa583          	lw	a1,0(s5)
    80004180:	028a2503          	lw	a0,40(s4)
    80004184:	fffff097          	auipc	ra,0xfffff
    80004188:	cb2080e7          	jalr	-846(ra) # 80002e36 <bread>
    8000418c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000418e:	40000613          	li	a2,1024
    80004192:	05850593          	addi	a1,a0,88
    80004196:	05848513          	addi	a0,s1,88
    8000419a:	ffffd097          	auipc	ra,0xffffd
    8000419e:	b94080e7          	jalr	-1132(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800041a2:	8526                	mv	a0,s1
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	d84080e7          	jalr	-636(ra) # 80002f28 <bwrite>
    brelse(from);
    800041ac:	854e                	mv	a0,s3
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	db8080e7          	jalr	-584(ra) # 80002f66 <brelse>
    brelse(to);
    800041b6:	8526                	mv	a0,s1
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	dae080e7          	jalr	-594(ra) # 80002f66 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c0:	2905                	addiw	s2,s2,1
    800041c2:	0a91                	addi	s5,s5,4
    800041c4:	02ca2783          	lw	a5,44(s4)
    800041c8:	f8f94ee3          	blt	s2,a5,80004164 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	c68080e7          	jalr	-920(ra) # 80003e34 <write_head>
    install_trans(0); // Now install writes to home locations
    800041d4:	4501                	li	a0,0
    800041d6:	00000097          	auipc	ra,0x0
    800041da:	cda080e7          	jalr	-806(ra) # 80003eb0 <install_trans>
    log.lh.n = 0;
    800041de:	0001d797          	auipc	a5,0x1d
    800041e2:	9807a723          	sw	zero,-1650(a5) # 80020b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041e6:	00000097          	auipc	ra,0x0
    800041ea:	c4e080e7          	jalr	-946(ra) # 80003e34 <write_head>
    800041ee:	bdf5                	j	800040ea <end_op+0x52>

00000000800041f0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041f0:	1101                	addi	sp,sp,-32
    800041f2:	ec06                	sd	ra,24(sp)
    800041f4:	e822                	sd	s0,16(sp)
    800041f6:	e426                	sd	s1,8(sp)
    800041f8:	e04a                	sd	s2,0(sp)
    800041fa:	1000                	addi	s0,sp,32
    800041fc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041fe:	0001d917          	auipc	s2,0x1d
    80004202:	94290913          	addi	s2,s2,-1726 # 80020b40 <log>
    80004206:	854a                	mv	a0,s2
    80004208:	ffffd097          	auipc	ra,0xffffd
    8000420c:	9ce080e7          	jalr	-1586(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004210:	02c92603          	lw	a2,44(s2)
    80004214:	47f5                	li	a5,29
    80004216:	06c7c563          	blt	a5,a2,80004280 <log_write+0x90>
    8000421a:	0001d797          	auipc	a5,0x1d
    8000421e:	9427a783          	lw	a5,-1726(a5) # 80020b5c <log+0x1c>
    80004222:	37fd                	addiw	a5,a5,-1
    80004224:	04f65e63          	bge	a2,a5,80004280 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004228:	0001d797          	auipc	a5,0x1d
    8000422c:	9387a783          	lw	a5,-1736(a5) # 80020b60 <log+0x20>
    80004230:	06f05063          	blez	a5,80004290 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004234:	4781                	li	a5,0
    80004236:	06c05563          	blez	a2,800042a0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000423a:	44cc                	lw	a1,12(s1)
    8000423c:	0001d717          	auipc	a4,0x1d
    80004240:	93470713          	addi	a4,a4,-1740 # 80020b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004244:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004246:	4314                	lw	a3,0(a4)
    80004248:	04b68c63          	beq	a3,a1,800042a0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000424c:	2785                	addiw	a5,a5,1
    8000424e:	0711                	addi	a4,a4,4
    80004250:	fef61be3          	bne	a2,a5,80004246 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004254:	0621                	addi	a2,a2,8
    80004256:	060a                	slli	a2,a2,0x2
    80004258:	0001d797          	auipc	a5,0x1d
    8000425c:	8e878793          	addi	a5,a5,-1816 # 80020b40 <log>
    80004260:	97b2                	add	a5,a5,a2
    80004262:	44d8                	lw	a4,12(s1)
    80004264:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004266:	8526                	mv	a0,s1
    80004268:	fffff097          	auipc	ra,0xfffff
    8000426c:	d9c080e7          	jalr	-612(ra) # 80003004 <bpin>
    log.lh.n++;
    80004270:	0001d717          	auipc	a4,0x1d
    80004274:	8d070713          	addi	a4,a4,-1840 # 80020b40 <log>
    80004278:	575c                	lw	a5,44(a4)
    8000427a:	2785                	addiw	a5,a5,1
    8000427c:	d75c                	sw	a5,44(a4)
    8000427e:	a82d                	j	800042b8 <log_write+0xc8>
    panic("too big a transaction");
    80004280:	00004517          	auipc	a0,0x4
    80004284:	3e050513          	addi	a0,a0,992 # 80008660 <syscalls+0x210>
    80004288:	ffffc097          	auipc	ra,0xffffc
    8000428c:	2b8080e7          	jalr	696(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004290:	00004517          	auipc	a0,0x4
    80004294:	3e850513          	addi	a0,a0,1000 # 80008678 <syscalls+0x228>
    80004298:	ffffc097          	auipc	ra,0xffffc
    8000429c:	2a8080e7          	jalr	680(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800042a0:	00878693          	addi	a3,a5,8
    800042a4:	068a                	slli	a3,a3,0x2
    800042a6:	0001d717          	auipc	a4,0x1d
    800042aa:	89a70713          	addi	a4,a4,-1894 # 80020b40 <log>
    800042ae:	9736                	add	a4,a4,a3
    800042b0:	44d4                	lw	a3,12(s1)
    800042b2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042b4:	faf609e3          	beq	a2,a5,80004266 <log_write+0x76>
  }
  release(&log.lock);
    800042b8:	0001d517          	auipc	a0,0x1d
    800042bc:	88850513          	addi	a0,a0,-1912 # 80020b40 <log>
    800042c0:	ffffd097          	auipc	ra,0xffffd
    800042c4:	9ca080e7          	jalr	-1590(ra) # 80000c8a <release>
}
    800042c8:	60e2                	ld	ra,24(sp)
    800042ca:	6442                	ld	s0,16(sp)
    800042cc:	64a2                	ld	s1,8(sp)
    800042ce:	6902                	ld	s2,0(sp)
    800042d0:	6105                	addi	sp,sp,32
    800042d2:	8082                	ret

00000000800042d4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042d4:	1101                	addi	sp,sp,-32
    800042d6:	ec06                	sd	ra,24(sp)
    800042d8:	e822                	sd	s0,16(sp)
    800042da:	e426                	sd	s1,8(sp)
    800042dc:	e04a                	sd	s2,0(sp)
    800042de:	1000                	addi	s0,sp,32
    800042e0:	84aa                	mv	s1,a0
    800042e2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042e4:	00004597          	auipc	a1,0x4
    800042e8:	3b458593          	addi	a1,a1,948 # 80008698 <syscalls+0x248>
    800042ec:	0521                	addi	a0,a0,8
    800042ee:	ffffd097          	auipc	ra,0xffffd
    800042f2:	858080e7          	jalr	-1960(ra) # 80000b46 <initlock>
  lk->name = name;
    800042f6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042fe:	0204a423          	sw	zero,40(s1)
}
    80004302:	60e2                	ld	ra,24(sp)
    80004304:	6442                	ld	s0,16(sp)
    80004306:	64a2                	ld	s1,8(sp)
    80004308:	6902                	ld	s2,0(sp)
    8000430a:	6105                	addi	sp,sp,32
    8000430c:	8082                	ret

000000008000430e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000430e:	1101                	addi	sp,sp,-32
    80004310:	ec06                	sd	ra,24(sp)
    80004312:	e822                	sd	s0,16(sp)
    80004314:	e426                	sd	s1,8(sp)
    80004316:	e04a                	sd	s2,0(sp)
    80004318:	1000                	addi	s0,sp,32
    8000431a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000431c:	00850913          	addi	s2,a0,8
    80004320:	854a                	mv	a0,s2
    80004322:	ffffd097          	auipc	ra,0xffffd
    80004326:	8b4080e7          	jalr	-1868(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000432a:	409c                	lw	a5,0(s1)
    8000432c:	cb89                	beqz	a5,8000433e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000432e:	85ca                	mv	a1,s2
    80004330:	8526                	mv	a0,s1
    80004332:	ffffe097          	auipc	ra,0xffffe
    80004336:	d22080e7          	jalr	-734(ra) # 80002054 <sleep>
  while (lk->locked) {
    8000433a:	409c                	lw	a5,0(s1)
    8000433c:	fbed                	bnez	a5,8000432e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000433e:	4785                	li	a5,1
    80004340:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004342:	ffffd097          	auipc	ra,0xffffd
    80004346:	66a080e7          	jalr	1642(ra) # 800019ac <myproc>
    8000434a:	591c                	lw	a5,48(a0)
    8000434c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000434e:	854a                	mv	a0,s2
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	93a080e7          	jalr	-1734(ra) # 80000c8a <release>
}
    80004358:	60e2                	ld	ra,24(sp)
    8000435a:	6442                	ld	s0,16(sp)
    8000435c:	64a2                	ld	s1,8(sp)
    8000435e:	6902                	ld	s2,0(sp)
    80004360:	6105                	addi	sp,sp,32
    80004362:	8082                	ret

0000000080004364 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004364:	1101                	addi	sp,sp,-32
    80004366:	ec06                	sd	ra,24(sp)
    80004368:	e822                	sd	s0,16(sp)
    8000436a:	e426                	sd	s1,8(sp)
    8000436c:	e04a                	sd	s2,0(sp)
    8000436e:	1000                	addi	s0,sp,32
    80004370:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004372:	00850913          	addi	s2,a0,8
    80004376:	854a                	mv	a0,s2
    80004378:	ffffd097          	auipc	ra,0xffffd
    8000437c:	85e080e7          	jalr	-1954(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004380:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004384:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004388:	8526                	mv	a0,s1
    8000438a:	ffffe097          	auipc	ra,0xffffe
    8000438e:	d2e080e7          	jalr	-722(ra) # 800020b8 <wakeup>
  release(&lk->lk);
    80004392:	854a                	mv	a0,s2
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	8f6080e7          	jalr	-1802(ra) # 80000c8a <release>
}
    8000439c:	60e2                	ld	ra,24(sp)
    8000439e:	6442                	ld	s0,16(sp)
    800043a0:	64a2                	ld	s1,8(sp)
    800043a2:	6902                	ld	s2,0(sp)
    800043a4:	6105                	addi	sp,sp,32
    800043a6:	8082                	ret

00000000800043a8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043a8:	7179                	addi	sp,sp,-48
    800043aa:	f406                	sd	ra,40(sp)
    800043ac:	f022                	sd	s0,32(sp)
    800043ae:	ec26                	sd	s1,24(sp)
    800043b0:	e84a                	sd	s2,16(sp)
    800043b2:	e44e                	sd	s3,8(sp)
    800043b4:	1800                	addi	s0,sp,48
    800043b6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043b8:	00850913          	addi	s2,a0,8
    800043bc:	854a                	mv	a0,s2
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	818080e7          	jalr	-2024(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043c6:	409c                	lw	a5,0(s1)
    800043c8:	ef99                	bnez	a5,800043e6 <holdingsleep+0x3e>
    800043ca:	4481                	li	s1,0
  release(&lk->lk);
    800043cc:	854a                	mv	a0,s2
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	8bc080e7          	jalr	-1860(ra) # 80000c8a <release>
  return r;
}
    800043d6:	8526                	mv	a0,s1
    800043d8:	70a2                	ld	ra,40(sp)
    800043da:	7402                	ld	s0,32(sp)
    800043dc:	64e2                	ld	s1,24(sp)
    800043de:	6942                	ld	s2,16(sp)
    800043e0:	69a2                	ld	s3,8(sp)
    800043e2:	6145                	addi	sp,sp,48
    800043e4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043e6:	0284a983          	lw	s3,40(s1)
    800043ea:	ffffd097          	auipc	ra,0xffffd
    800043ee:	5c2080e7          	jalr	1474(ra) # 800019ac <myproc>
    800043f2:	5904                	lw	s1,48(a0)
    800043f4:	413484b3          	sub	s1,s1,s3
    800043f8:	0014b493          	seqz	s1,s1
    800043fc:	bfc1                	j	800043cc <holdingsleep+0x24>

00000000800043fe <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043fe:	1141                	addi	sp,sp,-16
    80004400:	e406                	sd	ra,8(sp)
    80004402:	e022                	sd	s0,0(sp)
    80004404:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004406:	00004597          	auipc	a1,0x4
    8000440a:	2a258593          	addi	a1,a1,674 # 800086a8 <syscalls+0x258>
    8000440e:	0001d517          	auipc	a0,0x1d
    80004412:	87a50513          	addi	a0,a0,-1926 # 80020c88 <ftable>
    80004416:	ffffc097          	auipc	ra,0xffffc
    8000441a:	730080e7          	jalr	1840(ra) # 80000b46 <initlock>
}
    8000441e:	60a2                	ld	ra,8(sp)
    80004420:	6402                	ld	s0,0(sp)
    80004422:	0141                	addi	sp,sp,16
    80004424:	8082                	ret

0000000080004426 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004426:	1101                	addi	sp,sp,-32
    80004428:	ec06                	sd	ra,24(sp)
    8000442a:	e822                	sd	s0,16(sp)
    8000442c:	e426                	sd	s1,8(sp)
    8000442e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004430:	0001d517          	auipc	a0,0x1d
    80004434:	85850513          	addi	a0,a0,-1960 # 80020c88 <ftable>
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	79e080e7          	jalr	1950(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004440:	0001d497          	auipc	s1,0x1d
    80004444:	86048493          	addi	s1,s1,-1952 # 80020ca0 <ftable+0x18>
    80004448:	0001d717          	auipc	a4,0x1d
    8000444c:	7f870713          	addi	a4,a4,2040 # 80021c40 <disk>
    if(f->ref == 0){
    80004450:	40dc                	lw	a5,4(s1)
    80004452:	cf99                	beqz	a5,80004470 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004454:	02848493          	addi	s1,s1,40
    80004458:	fee49ce3          	bne	s1,a4,80004450 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000445c:	0001d517          	auipc	a0,0x1d
    80004460:	82c50513          	addi	a0,a0,-2004 # 80020c88 <ftable>
    80004464:	ffffd097          	auipc	ra,0xffffd
    80004468:	826080e7          	jalr	-2010(ra) # 80000c8a <release>
  return 0;
    8000446c:	4481                	li	s1,0
    8000446e:	a819                	j	80004484 <filealloc+0x5e>
      f->ref = 1;
    80004470:	4785                	li	a5,1
    80004472:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004474:	0001d517          	auipc	a0,0x1d
    80004478:	81450513          	addi	a0,a0,-2028 # 80020c88 <ftable>
    8000447c:	ffffd097          	auipc	ra,0xffffd
    80004480:	80e080e7          	jalr	-2034(ra) # 80000c8a <release>
}
    80004484:	8526                	mv	a0,s1
    80004486:	60e2                	ld	ra,24(sp)
    80004488:	6442                	ld	s0,16(sp)
    8000448a:	64a2                	ld	s1,8(sp)
    8000448c:	6105                	addi	sp,sp,32
    8000448e:	8082                	ret

0000000080004490 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004490:	1101                	addi	sp,sp,-32
    80004492:	ec06                	sd	ra,24(sp)
    80004494:	e822                	sd	s0,16(sp)
    80004496:	e426                	sd	s1,8(sp)
    80004498:	1000                	addi	s0,sp,32
    8000449a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000449c:	0001c517          	auipc	a0,0x1c
    800044a0:	7ec50513          	addi	a0,a0,2028 # 80020c88 <ftable>
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	732080e7          	jalr	1842(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044ac:	40dc                	lw	a5,4(s1)
    800044ae:	02f05263          	blez	a5,800044d2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044b2:	2785                	addiw	a5,a5,1
    800044b4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044b6:	0001c517          	auipc	a0,0x1c
    800044ba:	7d250513          	addi	a0,a0,2002 # 80020c88 <ftable>
    800044be:	ffffc097          	auipc	ra,0xffffc
    800044c2:	7cc080e7          	jalr	1996(ra) # 80000c8a <release>
  return f;
}
    800044c6:	8526                	mv	a0,s1
    800044c8:	60e2                	ld	ra,24(sp)
    800044ca:	6442                	ld	s0,16(sp)
    800044cc:	64a2                	ld	s1,8(sp)
    800044ce:	6105                	addi	sp,sp,32
    800044d0:	8082                	ret
    panic("filedup");
    800044d2:	00004517          	auipc	a0,0x4
    800044d6:	1de50513          	addi	a0,a0,478 # 800086b0 <syscalls+0x260>
    800044da:	ffffc097          	auipc	ra,0xffffc
    800044de:	066080e7          	jalr	102(ra) # 80000540 <panic>

00000000800044e2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044e2:	7139                	addi	sp,sp,-64
    800044e4:	fc06                	sd	ra,56(sp)
    800044e6:	f822                	sd	s0,48(sp)
    800044e8:	f426                	sd	s1,40(sp)
    800044ea:	f04a                	sd	s2,32(sp)
    800044ec:	ec4e                	sd	s3,24(sp)
    800044ee:	e852                	sd	s4,16(sp)
    800044f0:	e456                	sd	s5,8(sp)
    800044f2:	0080                	addi	s0,sp,64
    800044f4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044f6:	0001c517          	auipc	a0,0x1c
    800044fa:	79250513          	addi	a0,a0,1938 # 80020c88 <ftable>
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	6d8080e7          	jalr	1752(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004506:	40dc                	lw	a5,4(s1)
    80004508:	06f05163          	blez	a5,8000456a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000450c:	37fd                	addiw	a5,a5,-1
    8000450e:	0007871b          	sext.w	a4,a5
    80004512:	c0dc                	sw	a5,4(s1)
    80004514:	06e04363          	bgtz	a4,8000457a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004518:	0004a903          	lw	s2,0(s1)
    8000451c:	0094ca83          	lbu	s5,9(s1)
    80004520:	0104ba03          	ld	s4,16(s1)
    80004524:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004528:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000452c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004530:	0001c517          	auipc	a0,0x1c
    80004534:	75850513          	addi	a0,a0,1880 # 80020c88 <ftable>
    80004538:	ffffc097          	auipc	ra,0xffffc
    8000453c:	752080e7          	jalr	1874(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004540:	4785                	li	a5,1
    80004542:	04f90d63          	beq	s2,a5,8000459c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004546:	3979                	addiw	s2,s2,-2
    80004548:	4785                	li	a5,1
    8000454a:	0527e063          	bltu	a5,s2,8000458a <fileclose+0xa8>
    begin_op();
    8000454e:	00000097          	auipc	ra,0x0
    80004552:	acc080e7          	jalr	-1332(ra) # 8000401a <begin_op>
    iput(ff.ip);
    80004556:	854e                	mv	a0,s3
    80004558:	fffff097          	auipc	ra,0xfffff
    8000455c:	2b0080e7          	jalr	688(ra) # 80003808 <iput>
    end_op();
    80004560:	00000097          	auipc	ra,0x0
    80004564:	b38080e7          	jalr	-1224(ra) # 80004098 <end_op>
    80004568:	a00d                	j	8000458a <fileclose+0xa8>
    panic("fileclose");
    8000456a:	00004517          	auipc	a0,0x4
    8000456e:	14e50513          	addi	a0,a0,334 # 800086b8 <syscalls+0x268>
    80004572:	ffffc097          	auipc	ra,0xffffc
    80004576:	fce080e7          	jalr	-50(ra) # 80000540 <panic>
    release(&ftable.lock);
    8000457a:	0001c517          	auipc	a0,0x1c
    8000457e:	70e50513          	addi	a0,a0,1806 # 80020c88 <ftable>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	708080e7          	jalr	1800(ra) # 80000c8a <release>
  }
}
    8000458a:	70e2                	ld	ra,56(sp)
    8000458c:	7442                	ld	s0,48(sp)
    8000458e:	74a2                	ld	s1,40(sp)
    80004590:	7902                	ld	s2,32(sp)
    80004592:	69e2                	ld	s3,24(sp)
    80004594:	6a42                	ld	s4,16(sp)
    80004596:	6aa2                	ld	s5,8(sp)
    80004598:	6121                	addi	sp,sp,64
    8000459a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000459c:	85d6                	mv	a1,s5
    8000459e:	8552                	mv	a0,s4
    800045a0:	00000097          	auipc	ra,0x0
    800045a4:	34c080e7          	jalr	844(ra) # 800048ec <pipeclose>
    800045a8:	b7cd                	j	8000458a <fileclose+0xa8>

00000000800045aa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045aa:	715d                	addi	sp,sp,-80
    800045ac:	e486                	sd	ra,72(sp)
    800045ae:	e0a2                	sd	s0,64(sp)
    800045b0:	fc26                	sd	s1,56(sp)
    800045b2:	f84a                	sd	s2,48(sp)
    800045b4:	f44e                	sd	s3,40(sp)
    800045b6:	0880                	addi	s0,sp,80
    800045b8:	84aa                	mv	s1,a0
    800045ba:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045bc:	ffffd097          	auipc	ra,0xffffd
    800045c0:	3f0080e7          	jalr	1008(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045c4:	409c                	lw	a5,0(s1)
    800045c6:	37f9                	addiw	a5,a5,-2
    800045c8:	4705                	li	a4,1
    800045ca:	04f76763          	bltu	a4,a5,80004618 <filestat+0x6e>
    800045ce:	892a                	mv	s2,a0
    ilock(f->ip);
    800045d0:	6c88                	ld	a0,24(s1)
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	07c080e7          	jalr	124(ra) # 8000364e <ilock>
    stati(f->ip, &st);
    800045da:	fb840593          	addi	a1,s0,-72
    800045de:	6c88                	ld	a0,24(s1)
    800045e0:	fffff097          	auipc	ra,0xfffff
    800045e4:	2f8080e7          	jalr	760(ra) # 800038d8 <stati>
    iunlock(f->ip);
    800045e8:	6c88                	ld	a0,24(s1)
    800045ea:	fffff097          	auipc	ra,0xfffff
    800045ee:	126080e7          	jalr	294(ra) # 80003710 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045f2:	46e1                	li	a3,24
    800045f4:	fb840613          	addi	a2,s0,-72
    800045f8:	85ce                	mv	a1,s3
    800045fa:	05093503          	ld	a0,80(s2)
    800045fe:	ffffd097          	auipc	ra,0xffffd
    80004602:	06e080e7          	jalr	110(ra) # 8000166c <copyout>
    80004606:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000460a:	60a6                	ld	ra,72(sp)
    8000460c:	6406                	ld	s0,64(sp)
    8000460e:	74e2                	ld	s1,56(sp)
    80004610:	7942                	ld	s2,48(sp)
    80004612:	79a2                	ld	s3,40(sp)
    80004614:	6161                	addi	sp,sp,80
    80004616:	8082                	ret
  return -1;
    80004618:	557d                	li	a0,-1
    8000461a:	bfc5                	j	8000460a <filestat+0x60>

000000008000461c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000461c:	7179                	addi	sp,sp,-48
    8000461e:	f406                	sd	ra,40(sp)
    80004620:	f022                	sd	s0,32(sp)
    80004622:	ec26                	sd	s1,24(sp)
    80004624:	e84a                	sd	s2,16(sp)
    80004626:	e44e                	sd	s3,8(sp)
    80004628:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000462a:	00854783          	lbu	a5,8(a0)
    8000462e:	c3d5                	beqz	a5,800046d2 <fileread+0xb6>
    80004630:	84aa                	mv	s1,a0
    80004632:	89ae                	mv	s3,a1
    80004634:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004636:	411c                	lw	a5,0(a0)
    80004638:	4705                	li	a4,1
    8000463a:	04e78963          	beq	a5,a4,8000468c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000463e:	470d                	li	a4,3
    80004640:	04e78d63          	beq	a5,a4,8000469a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004644:	4709                	li	a4,2
    80004646:	06e79e63          	bne	a5,a4,800046c2 <fileread+0xa6>
    ilock(f->ip);
    8000464a:	6d08                	ld	a0,24(a0)
    8000464c:	fffff097          	auipc	ra,0xfffff
    80004650:	002080e7          	jalr	2(ra) # 8000364e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004654:	874a                	mv	a4,s2
    80004656:	5094                	lw	a3,32(s1)
    80004658:	864e                	mv	a2,s3
    8000465a:	4585                	li	a1,1
    8000465c:	6c88                	ld	a0,24(s1)
    8000465e:	fffff097          	auipc	ra,0xfffff
    80004662:	2a4080e7          	jalr	676(ra) # 80003902 <readi>
    80004666:	892a                	mv	s2,a0
    80004668:	00a05563          	blez	a0,80004672 <fileread+0x56>
      f->off += r;
    8000466c:	509c                	lw	a5,32(s1)
    8000466e:	9fa9                	addw	a5,a5,a0
    80004670:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004672:	6c88                	ld	a0,24(s1)
    80004674:	fffff097          	auipc	ra,0xfffff
    80004678:	09c080e7          	jalr	156(ra) # 80003710 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000467c:	854a                	mv	a0,s2
    8000467e:	70a2                	ld	ra,40(sp)
    80004680:	7402                	ld	s0,32(sp)
    80004682:	64e2                	ld	s1,24(sp)
    80004684:	6942                	ld	s2,16(sp)
    80004686:	69a2                	ld	s3,8(sp)
    80004688:	6145                	addi	sp,sp,48
    8000468a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000468c:	6908                	ld	a0,16(a0)
    8000468e:	00000097          	auipc	ra,0x0
    80004692:	3c6080e7          	jalr	966(ra) # 80004a54 <piperead>
    80004696:	892a                	mv	s2,a0
    80004698:	b7d5                	j	8000467c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000469a:	02451783          	lh	a5,36(a0)
    8000469e:	03079693          	slli	a3,a5,0x30
    800046a2:	92c1                	srli	a3,a3,0x30
    800046a4:	4725                	li	a4,9
    800046a6:	02d76863          	bltu	a4,a3,800046d6 <fileread+0xba>
    800046aa:	0792                	slli	a5,a5,0x4
    800046ac:	0001c717          	auipc	a4,0x1c
    800046b0:	53c70713          	addi	a4,a4,1340 # 80020be8 <devsw>
    800046b4:	97ba                	add	a5,a5,a4
    800046b6:	639c                	ld	a5,0(a5)
    800046b8:	c38d                	beqz	a5,800046da <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046ba:	4505                	li	a0,1
    800046bc:	9782                	jalr	a5
    800046be:	892a                	mv	s2,a0
    800046c0:	bf75                	j	8000467c <fileread+0x60>
    panic("fileread");
    800046c2:	00004517          	auipc	a0,0x4
    800046c6:	00650513          	addi	a0,a0,6 # 800086c8 <syscalls+0x278>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	e76080e7          	jalr	-394(ra) # 80000540 <panic>
    return -1;
    800046d2:	597d                	li	s2,-1
    800046d4:	b765                	j	8000467c <fileread+0x60>
      return -1;
    800046d6:	597d                	li	s2,-1
    800046d8:	b755                	j	8000467c <fileread+0x60>
    800046da:	597d                	li	s2,-1
    800046dc:	b745                	j	8000467c <fileread+0x60>

00000000800046de <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800046de:	715d                	addi	sp,sp,-80
    800046e0:	e486                	sd	ra,72(sp)
    800046e2:	e0a2                	sd	s0,64(sp)
    800046e4:	fc26                	sd	s1,56(sp)
    800046e6:	f84a                	sd	s2,48(sp)
    800046e8:	f44e                	sd	s3,40(sp)
    800046ea:	f052                	sd	s4,32(sp)
    800046ec:	ec56                	sd	s5,24(sp)
    800046ee:	e85a                	sd	s6,16(sp)
    800046f0:	e45e                	sd	s7,8(sp)
    800046f2:	e062                	sd	s8,0(sp)
    800046f4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800046f6:	00954783          	lbu	a5,9(a0)
    800046fa:	10078663          	beqz	a5,80004806 <filewrite+0x128>
    800046fe:	892a                	mv	s2,a0
    80004700:	8b2e                	mv	s6,a1
    80004702:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004704:	411c                	lw	a5,0(a0)
    80004706:	4705                	li	a4,1
    80004708:	02e78263          	beq	a5,a4,8000472c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000470c:	470d                	li	a4,3
    8000470e:	02e78663          	beq	a5,a4,8000473a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004712:	4709                	li	a4,2
    80004714:	0ee79163          	bne	a5,a4,800047f6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004718:	0ac05d63          	blez	a2,800047d2 <filewrite+0xf4>
    int i = 0;
    8000471c:	4981                	li	s3,0
    8000471e:	6b85                	lui	s7,0x1
    80004720:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004724:	6c05                	lui	s8,0x1
    80004726:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000472a:	a861                	j	800047c2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000472c:	6908                	ld	a0,16(a0)
    8000472e:	00000097          	auipc	ra,0x0
    80004732:	22e080e7          	jalr	558(ra) # 8000495c <pipewrite>
    80004736:	8a2a                	mv	s4,a0
    80004738:	a045                	j	800047d8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000473a:	02451783          	lh	a5,36(a0)
    8000473e:	03079693          	slli	a3,a5,0x30
    80004742:	92c1                	srli	a3,a3,0x30
    80004744:	4725                	li	a4,9
    80004746:	0cd76263          	bltu	a4,a3,8000480a <filewrite+0x12c>
    8000474a:	0792                	slli	a5,a5,0x4
    8000474c:	0001c717          	auipc	a4,0x1c
    80004750:	49c70713          	addi	a4,a4,1180 # 80020be8 <devsw>
    80004754:	97ba                	add	a5,a5,a4
    80004756:	679c                	ld	a5,8(a5)
    80004758:	cbdd                	beqz	a5,8000480e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000475a:	4505                	li	a0,1
    8000475c:	9782                	jalr	a5
    8000475e:	8a2a                	mv	s4,a0
    80004760:	a8a5                	j	800047d8 <filewrite+0xfa>
    80004762:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004766:	00000097          	auipc	ra,0x0
    8000476a:	8b4080e7          	jalr	-1868(ra) # 8000401a <begin_op>
      ilock(f->ip);
    8000476e:	01893503          	ld	a0,24(s2)
    80004772:	fffff097          	auipc	ra,0xfffff
    80004776:	edc080e7          	jalr	-292(ra) # 8000364e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000477a:	8756                	mv	a4,s5
    8000477c:	02092683          	lw	a3,32(s2)
    80004780:	01698633          	add	a2,s3,s6
    80004784:	4585                	li	a1,1
    80004786:	01893503          	ld	a0,24(s2)
    8000478a:	fffff097          	auipc	ra,0xfffff
    8000478e:	270080e7          	jalr	624(ra) # 800039fa <writei>
    80004792:	84aa                	mv	s1,a0
    80004794:	00a05763          	blez	a0,800047a2 <filewrite+0xc4>
        f->off += r;
    80004798:	02092783          	lw	a5,32(s2)
    8000479c:	9fa9                	addw	a5,a5,a0
    8000479e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047a2:	01893503          	ld	a0,24(s2)
    800047a6:	fffff097          	auipc	ra,0xfffff
    800047aa:	f6a080e7          	jalr	-150(ra) # 80003710 <iunlock>
      end_op();
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	8ea080e7          	jalr	-1814(ra) # 80004098 <end_op>

      if(r != n1){
    800047b6:	009a9f63          	bne	s5,s1,800047d4 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800047ba:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800047be:	0149db63          	bge	s3,s4,800047d4 <filewrite+0xf6>
      int n1 = n - i;
    800047c2:	413a04bb          	subw	s1,s4,s3
    800047c6:	0004879b          	sext.w	a5,s1
    800047ca:	f8fbdce3          	bge	s7,a5,80004762 <filewrite+0x84>
    800047ce:	84e2                	mv	s1,s8
    800047d0:	bf49                	j	80004762 <filewrite+0x84>
    int i = 0;
    800047d2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800047d4:	013a1f63          	bne	s4,s3,800047f2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047d8:	8552                	mv	a0,s4
    800047da:	60a6                	ld	ra,72(sp)
    800047dc:	6406                	ld	s0,64(sp)
    800047de:	74e2                	ld	s1,56(sp)
    800047e0:	7942                	ld	s2,48(sp)
    800047e2:	79a2                	ld	s3,40(sp)
    800047e4:	7a02                	ld	s4,32(sp)
    800047e6:	6ae2                	ld	s5,24(sp)
    800047e8:	6b42                	ld	s6,16(sp)
    800047ea:	6ba2                	ld	s7,8(sp)
    800047ec:	6c02                	ld	s8,0(sp)
    800047ee:	6161                	addi	sp,sp,80
    800047f0:	8082                	ret
    ret = (i == n ? n : -1);
    800047f2:	5a7d                	li	s4,-1
    800047f4:	b7d5                	j	800047d8 <filewrite+0xfa>
    panic("filewrite");
    800047f6:	00004517          	auipc	a0,0x4
    800047fa:	ee250513          	addi	a0,a0,-286 # 800086d8 <syscalls+0x288>
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	d42080e7          	jalr	-702(ra) # 80000540 <panic>
    return -1;
    80004806:	5a7d                	li	s4,-1
    80004808:	bfc1                	j	800047d8 <filewrite+0xfa>
      return -1;
    8000480a:	5a7d                	li	s4,-1
    8000480c:	b7f1                	j	800047d8 <filewrite+0xfa>
    8000480e:	5a7d                	li	s4,-1
    80004810:	b7e1                	j	800047d8 <filewrite+0xfa>

0000000080004812 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004812:	7179                	addi	sp,sp,-48
    80004814:	f406                	sd	ra,40(sp)
    80004816:	f022                	sd	s0,32(sp)
    80004818:	ec26                	sd	s1,24(sp)
    8000481a:	e84a                	sd	s2,16(sp)
    8000481c:	e44e                	sd	s3,8(sp)
    8000481e:	e052                	sd	s4,0(sp)
    80004820:	1800                	addi	s0,sp,48
    80004822:	84aa                	mv	s1,a0
    80004824:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004826:	0005b023          	sd	zero,0(a1)
    8000482a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000482e:	00000097          	auipc	ra,0x0
    80004832:	bf8080e7          	jalr	-1032(ra) # 80004426 <filealloc>
    80004836:	e088                	sd	a0,0(s1)
    80004838:	c551                	beqz	a0,800048c4 <pipealloc+0xb2>
    8000483a:	00000097          	auipc	ra,0x0
    8000483e:	bec080e7          	jalr	-1044(ra) # 80004426 <filealloc>
    80004842:	00aa3023          	sd	a0,0(s4)
    80004846:	c92d                	beqz	a0,800048b8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	29e080e7          	jalr	670(ra) # 80000ae6 <kalloc>
    80004850:	892a                	mv	s2,a0
    80004852:	c125                	beqz	a0,800048b2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004854:	4985                	li	s3,1
    80004856:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000485a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000485e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004862:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004866:	00004597          	auipc	a1,0x4
    8000486a:	e8258593          	addi	a1,a1,-382 # 800086e8 <syscalls+0x298>
    8000486e:	ffffc097          	auipc	ra,0xffffc
    80004872:	2d8080e7          	jalr	728(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004876:	609c                	ld	a5,0(s1)
    80004878:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000487c:	609c                	ld	a5,0(s1)
    8000487e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004882:	609c                	ld	a5,0(s1)
    80004884:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004888:	609c                	ld	a5,0(s1)
    8000488a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000488e:	000a3783          	ld	a5,0(s4)
    80004892:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004896:	000a3783          	ld	a5,0(s4)
    8000489a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000489e:	000a3783          	ld	a5,0(s4)
    800048a2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048a6:	000a3783          	ld	a5,0(s4)
    800048aa:	0127b823          	sd	s2,16(a5)
  return 0;
    800048ae:	4501                	li	a0,0
    800048b0:	a025                	j	800048d8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048b2:	6088                	ld	a0,0(s1)
    800048b4:	e501                	bnez	a0,800048bc <pipealloc+0xaa>
    800048b6:	a039                	j	800048c4 <pipealloc+0xb2>
    800048b8:	6088                	ld	a0,0(s1)
    800048ba:	c51d                	beqz	a0,800048e8 <pipealloc+0xd6>
    fileclose(*f0);
    800048bc:	00000097          	auipc	ra,0x0
    800048c0:	c26080e7          	jalr	-986(ra) # 800044e2 <fileclose>
  if(*f1)
    800048c4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048c8:	557d                	li	a0,-1
  if(*f1)
    800048ca:	c799                	beqz	a5,800048d8 <pipealloc+0xc6>
    fileclose(*f1);
    800048cc:	853e                	mv	a0,a5
    800048ce:	00000097          	auipc	ra,0x0
    800048d2:	c14080e7          	jalr	-1004(ra) # 800044e2 <fileclose>
  return -1;
    800048d6:	557d                	li	a0,-1
}
    800048d8:	70a2                	ld	ra,40(sp)
    800048da:	7402                	ld	s0,32(sp)
    800048dc:	64e2                	ld	s1,24(sp)
    800048de:	6942                	ld	s2,16(sp)
    800048e0:	69a2                	ld	s3,8(sp)
    800048e2:	6a02                	ld	s4,0(sp)
    800048e4:	6145                	addi	sp,sp,48
    800048e6:	8082                	ret
  return -1;
    800048e8:	557d                	li	a0,-1
    800048ea:	b7fd                	j	800048d8 <pipealloc+0xc6>

00000000800048ec <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048ec:	1101                	addi	sp,sp,-32
    800048ee:	ec06                	sd	ra,24(sp)
    800048f0:	e822                	sd	s0,16(sp)
    800048f2:	e426                	sd	s1,8(sp)
    800048f4:	e04a                	sd	s2,0(sp)
    800048f6:	1000                	addi	s0,sp,32
    800048f8:	84aa                	mv	s1,a0
    800048fa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048fc:	ffffc097          	auipc	ra,0xffffc
    80004900:	2da080e7          	jalr	730(ra) # 80000bd6 <acquire>
  if(writable){
    80004904:	02090d63          	beqz	s2,8000493e <pipeclose+0x52>
    pi->writeopen = 0;
    80004908:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000490c:	21848513          	addi	a0,s1,536
    80004910:	ffffd097          	auipc	ra,0xffffd
    80004914:	7a8080e7          	jalr	1960(ra) # 800020b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004918:	2204b783          	ld	a5,544(s1)
    8000491c:	eb95                	bnez	a5,80004950 <pipeclose+0x64>
    release(&pi->lock);
    8000491e:	8526                	mv	a0,s1
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	36a080e7          	jalr	874(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004928:	8526                	mv	a0,s1
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	0be080e7          	jalr	190(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004932:	60e2                	ld	ra,24(sp)
    80004934:	6442                	ld	s0,16(sp)
    80004936:	64a2                	ld	s1,8(sp)
    80004938:	6902                	ld	s2,0(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret
    pi->readopen = 0;
    8000493e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004942:	21c48513          	addi	a0,s1,540
    80004946:	ffffd097          	auipc	ra,0xffffd
    8000494a:	772080e7          	jalr	1906(ra) # 800020b8 <wakeup>
    8000494e:	b7e9                	j	80004918 <pipeclose+0x2c>
    release(&pi->lock);
    80004950:	8526                	mv	a0,s1
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	338080e7          	jalr	824(ra) # 80000c8a <release>
}
    8000495a:	bfe1                	j	80004932 <pipeclose+0x46>

000000008000495c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000495c:	711d                	addi	sp,sp,-96
    8000495e:	ec86                	sd	ra,88(sp)
    80004960:	e8a2                	sd	s0,80(sp)
    80004962:	e4a6                	sd	s1,72(sp)
    80004964:	e0ca                	sd	s2,64(sp)
    80004966:	fc4e                	sd	s3,56(sp)
    80004968:	f852                	sd	s4,48(sp)
    8000496a:	f456                	sd	s5,40(sp)
    8000496c:	f05a                	sd	s6,32(sp)
    8000496e:	ec5e                	sd	s7,24(sp)
    80004970:	e862                	sd	s8,16(sp)
    80004972:	1080                	addi	s0,sp,96
    80004974:	84aa                	mv	s1,a0
    80004976:	8aae                	mv	s5,a1
    80004978:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000497a:	ffffd097          	auipc	ra,0xffffd
    8000497e:	032080e7          	jalr	50(ra) # 800019ac <myproc>
    80004982:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004984:	8526                	mv	a0,s1
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	250080e7          	jalr	592(ra) # 80000bd6 <acquire>
  while(i < n){
    8000498e:	0b405663          	blez	s4,80004a3a <pipewrite+0xde>
  int i = 0;
    80004992:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004994:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004996:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000499a:	21c48b93          	addi	s7,s1,540
    8000499e:	a089                	j	800049e0 <pipewrite+0x84>
      release(&pi->lock);
    800049a0:	8526                	mv	a0,s1
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	2e8080e7          	jalr	744(ra) # 80000c8a <release>
      return -1;
    800049aa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049ac:	854a                	mv	a0,s2
    800049ae:	60e6                	ld	ra,88(sp)
    800049b0:	6446                	ld	s0,80(sp)
    800049b2:	64a6                	ld	s1,72(sp)
    800049b4:	6906                	ld	s2,64(sp)
    800049b6:	79e2                	ld	s3,56(sp)
    800049b8:	7a42                	ld	s4,48(sp)
    800049ba:	7aa2                	ld	s5,40(sp)
    800049bc:	7b02                	ld	s6,32(sp)
    800049be:	6be2                	ld	s7,24(sp)
    800049c0:	6c42                	ld	s8,16(sp)
    800049c2:	6125                	addi	sp,sp,96
    800049c4:	8082                	ret
      wakeup(&pi->nread);
    800049c6:	8562                	mv	a0,s8
    800049c8:	ffffd097          	auipc	ra,0xffffd
    800049cc:	6f0080e7          	jalr	1776(ra) # 800020b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049d0:	85a6                	mv	a1,s1
    800049d2:	855e                	mv	a0,s7
    800049d4:	ffffd097          	auipc	ra,0xffffd
    800049d8:	680080e7          	jalr	1664(ra) # 80002054 <sleep>
  while(i < n){
    800049dc:	07495063          	bge	s2,s4,80004a3c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800049e0:	2204a783          	lw	a5,544(s1)
    800049e4:	dfd5                	beqz	a5,800049a0 <pipewrite+0x44>
    800049e6:	854e                	mv	a0,s3
    800049e8:	ffffe097          	auipc	ra,0xffffe
    800049ec:	914080e7          	jalr	-1772(ra) # 800022fc <killed>
    800049f0:	f945                	bnez	a0,800049a0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800049f2:	2184a783          	lw	a5,536(s1)
    800049f6:	21c4a703          	lw	a4,540(s1)
    800049fa:	2007879b          	addiw	a5,a5,512
    800049fe:	fcf704e3          	beq	a4,a5,800049c6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a02:	4685                	li	a3,1
    80004a04:	01590633          	add	a2,s2,s5
    80004a08:	faf40593          	addi	a1,s0,-81
    80004a0c:	0509b503          	ld	a0,80(s3)
    80004a10:	ffffd097          	auipc	ra,0xffffd
    80004a14:	ce8080e7          	jalr	-792(ra) # 800016f8 <copyin>
    80004a18:	03650263          	beq	a0,s6,80004a3c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a1c:	21c4a783          	lw	a5,540(s1)
    80004a20:	0017871b          	addiw	a4,a5,1
    80004a24:	20e4ae23          	sw	a4,540(s1)
    80004a28:	1ff7f793          	andi	a5,a5,511
    80004a2c:	97a6                	add	a5,a5,s1
    80004a2e:	faf44703          	lbu	a4,-81(s0)
    80004a32:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a36:	2905                	addiw	s2,s2,1
    80004a38:	b755                	j	800049dc <pipewrite+0x80>
  int i = 0;
    80004a3a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a3c:	21848513          	addi	a0,s1,536
    80004a40:	ffffd097          	auipc	ra,0xffffd
    80004a44:	678080e7          	jalr	1656(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004a48:	8526                	mv	a0,s1
    80004a4a:	ffffc097          	auipc	ra,0xffffc
    80004a4e:	240080e7          	jalr	576(ra) # 80000c8a <release>
  return i;
    80004a52:	bfa9                	j	800049ac <pipewrite+0x50>

0000000080004a54 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a54:	715d                	addi	sp,sp,-80
    80004a56:	e486                	sd	ra,72(sp)
    80004a58:	e0a2                	sd	s0,64(sp)
    80004a5a:	fc26                	sd	s1,56(sp)
    80004a5c:	f84a                	sd	s2,48(sp)
    80004a5e:	f44e                	sd	s3,40(sp)
    80004a60:	f052                	sd	s4,32(sp)
    80004a62:	ec56                	sd	s5,24(sp)
    80004a64:	e85a                	sd	s6,16(sp)
    80004a66:	0880                	addi	s0,sp,80
    80004a68:	84aa                	mv	s1,a0
    80004a6a:	892e                	mv	s2,a1
    80004a6c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a6e:	ffffd097          	auipc	ra,0xffffd
    80004a72:	f3e080e7          	jalr	-194(ra) # 800019ac <myproc>
    80004a76:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a78:	8526                	mv	a0,s1
    80004a7a:	ffffc097          	auipc	ra,0xffffc
    80004a7e:	15c080e7          	jalr	348(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a82:	2184a703          	lw	a4,536(s1)
    80004a86:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a8a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a8e:	02f71763          	bne	a4,a5,80004abc <piperead+0x68>
    80004a92:	2244a783          	lw	a5,548(s1)
    80004a96:	c39d                	beqz	a5,80004abc <piperead+0x68>
    if(killed(pr)){
    80004a98:	8552                	mv	a0,s4
    80004a9a:	ffffe097          	auipc	ra,0xffffe
    80004a9e:	862080e7          	jalr	-1950(ra) # 800022fc <killed>
    80004aa2:	e949                	bnez	a0,80004b34 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004aa4:	85a6                	mv	a1,s1
    80004aa6:	854e                	mv	a0,s3
    80004aa8:	ffffd097          	auipc	ra,0xffffd
    80004aac:	5ac080e7          	jalr	1452(ra) # 80002054 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ab0:	2184a703          	lw	a4,536(s1)
    80004ab4:	21c4a783          	lw	a5,540(s1)
    80004ab8:	fcf70de3          	beq	a4,a5,80004a92 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004abc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004abe:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ac0:	05505463          	blez	s5,80004b08 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004ac4:	2184a783          	lw	a5,536(s1)
    80004ac8:	21c4a703          	lw	a4,540(s1)
    80004acc:	02f70e63          	beq	a4,a5,80004b08 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ad0:	0017871b          	addiw	a4,a5,1
    80004ad4:	20e4ac23          	sw	a4,536(s1)
    80004ad8:	1ff7f793          	andi	a5,a5,511
    80004adc:	97a6                	add	a5,a5,s1
    80004ade:	0187c783          	lbu	a5,24(a5)
    80004ae2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ae6:	4685                	li	a3,1
    80004ae8:	fbf40613          	addi	a2,s0,-65
    80004aec:	85ca                	mv	a1,s2
    80004aee:	050a3503          	ld	a0,80(s4)
    80004af2:	ffffd097          	auipc	ra,0xffffd
    80004af6:	b7a080e7          	jalr	-1158(ra) # 8000166c <copyout>
    80004afa:	01650763          	beq	a0,s6,80004b08 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004afe:	2985                	addiw	s3,s3,1
    80004b00:	0905                	addi	s2,s2,1
    80004b02:	fd3a91e3          	bne	s5,s3,80004ac4 <piperead+0x70>
    80004b06:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b08:	21c48513          	addi	a0,s1,540
    80004b0c:	ffffd097          	auipc	ra,0xffffd
    80004b10:	5ac080e7          	jalr	1452(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004b14:	8526                	mv	a0,s1
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	174080e7          	jalr	372(ra) # 80000c8a <release>
  return i;
}
    80004b1e:	854e                	mv	a0,s3
    80004b20:	60a6                	ld	ra,72(sp)
    80004b22:	6406                	ld	s0,64(sp)
    80004b24:	74e2                	ld	s1,56(sp)
    80004b26:	7942                	ld	s2,48(sp)
    80004b28:	79a2                	ld	s3,40(sp)
    80004b2a:	7a02                	ld	s4,32(sp)
    80004b2c:	6ae2                	ld	s5,24(sp)
    80004b2e:	6b42                	ld	s6,16(sp)
    80004b30:	6161                	addi	sp,sp,80
    80004b32:	8082                	ret
      release(&pi->lock);
    80004b34:	8526                	mv	a0,s1
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	154080e7          	jalr	340(ra) # 80000c8a <release>
      return -1;
    80004b3e:	59fd                	li	s3,-1
    80004b40:	bff9                	j	80004b1e <piperead+0xca>

0000000080004b42 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b42:	1141                	addi	sp,sp,-16
    80004b44:	e422                	sd	s0,8(sp)
    80004b46:	0800                	addi	s0,sp,16
    80004b48:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b4a:	8905                	andi	a0,a0,1
    80004b4c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004b4e:	8b89                	andi	a5,a5,2
    80004b50:	c399                	beqz	a5,80004b56 <flags2perm+0x14>
      perm |= PTE_W;
    80004b52:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b56:	6422                	ld	s0,8(sp)
    80004b58:	0141                	addi	sp,sp,16
    80004b5a:	8082                	ret

0000000080004b5c <exec>:

int
exec(char *path, char **argv)
{
    80004b5c:	de010113          	addi	sp,sp,-544
    80004b60:	20113c23          	sd	ra,536(sp)
    80004b64:	20813823          	sd	s0,528(sp)
    80004b68:	20913423          	sd	s1,520(sp)
    80004b6c:	21213023          	sd	s2,512(sp)
    80004b70:	ffce                	sd	s3,504(sp)
    80004b72:	fbd2                	sd	s4,496(sp)
    80004b74:	f7d6                	sd	s5,488(sp)
    80004b76:	f3da                	sd	s6,480(sp)
    80004b78:	efde                	sd	s7,472(sp)
    80004b7a:	ebe2                	sd	s8,464(sp)
    80004b7c:	e7e6                	sd	s9,456(sp)
    80004b7e:	e3ea                	sd	s10,448(sp)
    80004b80:	ff6e                	sd	s11,440(sp)
    80004b82:	1400                	addi	s0,sp,544
    80004b84:	892a                	mv	s2,a0
    80004b86:	dea43423          	sd	a0,-536(s0)
    80004b8a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b8e:	ffffd097          	auipc	ra,0xffffd
    80004b92:	e1e080e7          	jalr	-482(ra) # 800019ac <myproc>
    80004b96:	84aa                	mv	s1,a0

  begin_op();
    80004b98:	fffff097          	auipc	ra,0xfffff
    80004b9c:	482080e7          	jalr	1154(ra) # 8000401a <begin_op>

  if((ip = namei(path)) == 0){
    80004ba0:	854a                	mv	a0,s2
    80004ba2:	fffff097          	auipc	ra,0xfffff
    80004ba6:	258080e7          	jalr	600(ra) # 80003dfa <namei>
    80004baa:	c93d                	beqz	a0,80004c20 <exec+0xc4>
    80004bac:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bae:	fffff097          	auipc	ra,0xfffff
    80004bb2:	aa0080e7          	jalr	-1376(ra) # 8000364e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bb6:	04000713          	li	a4,64
    80004bba:	4681                	li	a3,0
    80004bbc:	e5040613          	addi	a2,s0,-432
    80004bc0:	4581                	li	a1,0
    80004bc2:	8556                	mv	a0,s5
    80004bc4:	fffff097          	auipc	ra,0xfffff
    80004bc8:	d3e080e7          	jalr	-706(ra) # 80003902 <readi>
    80004bcc:	04000793          	li	a5,64
    80004bd0:	00f51a63          	bne	a0,a5,80004be4 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004bd4:	e5042703          	lw	a4,-432(s0)
    80004bd8:	464c47b7          	lui	a5,0x464c4
    80004bdc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004be0:	04f70663          	beq	a4,a5,80004c2c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004be4:	8556                	mv	a0,s5
    80004be6:	fffff097          	auipc	ra,0xfffff
    80004bea:	cca080e7          	jalr	-822(ra) # 800038b0 <iunlockput>
    end_op();
    80004bee:	fffff097          	auipc	ra,0xfffff
    80004bf2:	4aa080e7          	jalr	1194(ra) # 80004098 <end_op>
  }
  return -1;
    80004bf6:	557d                	li	a0,-1
}
    80004bf8:	21813083          	ld	ra,536(sp)
    80004bfc:	21013403          	ld	s0,528(sp)
    80004c00:	20813483          	ld	s1,520(sp)
    80004c04:	20013903          	ld	s2,512(sp)
    80004c08:	79fe                	ld	s3,504(sp)
    80004c0a:	7a5e                	ld	s4,496(sp)
    80004c0c:	7abe                	ld	s5,488(sp)
    80004c0e:	7b1e                	ld	s6,480(sp)
    80004c10:	6bfe                	ld	s7,472(sp)
    80004c12:	6c5e                	ld	s8,464(sp)
    80004c14:	6cbe                	ld	s9,456(sp)
    80004c16:	6d1e                	ld	s10,448(sp)
    80004c18:	7dfa                	ld	s11,440(sp)
    80004c1a:	22010113          	addi	sp,sp,544
    80004c1e:	8082                	ret
    end_op();
    80004c20:	fffff097          	auipc	ra,0xfffff
    80004c24:	478080e7          	jalr	1144(ra) # 80004098 <end_op>
    return -1;
    80004c28:	557d                	li	a0,-1
    80004c2a:	b7f9                	j	80004bf8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c2c:	8526                	mv	a0,s1
    80004c2e:	ffffd097          	auipc	ra,0xffffd
    80004c32:	e42080e7          	jalr	-446(ra) # 80001a70 <proc_pagetable>
    80004c36:	8b2a                	mv	s6,a0
    80004c38:	d555                	beqz	a0,80004be4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c3a:	e7042783          	lw	a5,-400(s0)
    80004c3e:	e8845703          	lhu	a4,-376(s0)
    80004c42:	c735                	beqz	a4,80004cae <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c44:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c46:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c4a:	6a05                	lui	s4,0x1
    80004c4c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c50:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c54:	6d85                	lui	s11,0x1
    80004c56:	7d7d                	lui	s10,0xfffff
    80004c58:	ac3d                	j	80004e96 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c5a:	00004517          	auipc	a0,0x4
    80004c5e:	a9650513          	addi	a0,a0,-1386 # 800086f0 <syscalls+0x2a0>
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	8de080e7          	jalr	-1826(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c6a:	874a                	mv	a4,s2
    80004c6c:	009c86bb          	addw	a3,s9,s1
    80004c70:	4581                	li	a1,0
    80004c72:	8556                	mv	a0,s5
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	c8e080e7          	jalr	-882(ra) # 80003902 <readi>
    80004c7c:	2501                	sext.w	a0,a0
    80004c7e:	1aa91963          	bne	s2,a0,80004e30 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004c82:	009d84bb          	addw	s1,s11,s1
    80004c86:	013d09bb          	addw	s3,s10,s3
    80004c8a:	1f74f663          	bgeu	s1,s7,80004e76 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004c8e:	02049593          	slli	a1,s1,0x20
    80004c92:	9181                	srli	a1,a1,0x20
    80004c94:	95e2                	add	a1,a1,s8
    80004c96:	855a                	mv	a0,s6
    80004c98:	ffffc097          	auipc	ra,0xffffc
    80004c9c:	3c4080e7          	jalr	964(ra) # 8000105c <walkaddr>
    80004ca0:	862a                	mv	a2,a0
    if(pa == 0)
    80004ca2:	dd45                	beqz	a0,80004c5a <exec+0xfe>
      n = PGSIZE;
    80004ca4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004ca6:	fd49f2e3          	bgeu	s3,s4,80004c6a <exec+0x10e>
      n = sz - i;
    80004caa:	894e                	mv	s2,s3
    80004cac:	bf7d                	j	80004c6a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cae:	4901                	li	s2,0
  iunlockput(ip);
    80004cb0:	8556                	mv	a0,s5
    80004cb2:	fffff097          	auipc	ra,0xfffff
    80004cb6:	bfe080e7          	jalr	-1026(ra) # 800038b0 <iunlockput>
  end_op();
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	3de080e7          	jalr	990(ra) # 80004098 <end_op>
  p = myproc();
    80004cc2:	ffffd097          	auipc	ra,0xffffd
    80004cc6:	cea080e7          	jalr	-790(ra) # 800019ac <myproc>
    80004cca:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004ccc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004cd0:	6785                	lui	a5,0x1
    80004cd2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004cd4:	97ca                	add	a5,a5,s2
    80004cd6:	777d                	lui	a4,0xfffff
    80004cd8:	8ff9                	and	a5,a5,a4
    80004cda:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004cde:	4691                	li	a3,4
    80004ce0:	6609                	lui	a2,0x2
    80004ce2:	963e                	add	a2,a2,a5
    80004ce4:	85be                	mv	a1,a5
    80004ce6:	855a                	mv	a0,s6
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	728080e7          	jalr	1832(ra) # 80001410 <uvmalloc>
    80004cf0:	8c2a                	mv	s8,a0
  ip = 0;
    80004cf2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004cf4:	12050e63          	beqz	a0,80004e30 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004cf8:	75f9                	lui	a1,0xffffe
    80004cfa:	95aa                	add	a1,a1,a0
    80004cfc:	855a                	mv	a0,s6
    80004cfe:	ffffd097          	auipc	ra,0xffffd
    80004d02:	93c080e7          	jalr	-1732(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80004d06:	7afd                	lui	s5,0xfffff
    80004d08:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d0a:	df043783          	ld	a5,-528(s0)
    80004d0e:	6388                	ld	a0,0(a5)
    80004d10:	c925                	beqz	a0,80004d80 <exec+0x224>
    80004d12:	e9040993          	addi	s3,s0,-368
    80004d16:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d1a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d1c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	130080e7          	jalr	304(ra) # 80000e4e <strlen>
    80004d26:	0015079b          	addiw	a5,a0,1
    80004d2a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d2e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004d32:	13596663          	bltu	s2,s5,80004e5e <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d36:	df043d83          	ld	s11,-528(s0)
    80004d3a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d3e:	8552                	mv	a0,s4
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	10e080e7          	jalr	270(ra) # 80000e4e <strlen>
    80004d48:	0015069b          	addiw	a3,a0,1
    80004d4c:	8652                	mv	a2,s4
    80004d4e:	85ca                	mv	a1,s2
    80004d50:	855a                	mv	a0,s6
    80004d52:	ffffd097          	auipc	ra,0xffffd
    80004d56:	91a080e7          	jalr	-1766(ra) # 8000166c <copyout>
    80004d5a:	10054663          	bltz	a0,80004e66 <exec+0x30a>
    ustack[argc] = sp;
    80004d5e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d62:	0485                	addi	s1,s1,1
    80004d64:	008d8793          	addi	a5,s11,8
    80004d68:	def43823          	sd	a5,-528(s0)
    80004d6c:	008db503          	ld	a0,8(s11)
    80004d70:	c911                	beqz	a0,80004d84 <exec+0x228>
    if(argc >= MAXARG)
    80004d72:	09a1                	addi	s3,s3,8
    80004d74:	fb3c95e3          	bne	s9,s3,80004d1e <exec+0x1c2>
  sz = sz1;
    80004d78:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d7c:	4a81                	li	s5,0
    80004d7e:	a84d                	j	80004e30 <exec+0x2d4>
  sp = sz;
    80004d80:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d82:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d84:	00349793          	slli	a5,s1,0x3
    80004d88:	f9078793          	addi	a5,a5,-112
    80004d8c:	97a2                	add	a5,a5,s0
    80004d8e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004d92:	00148693          	addi	a3,s1,1
    80004d96:	068e                	slli	a3,a3,0x3
    80004d98:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d9c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004da0:	01597663          	bgeu	s2,s5,80004dac <exec+0x250>
  sz = sz1;
    80004da4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004da8:	4a81                	li	s5,0
    80004daa:	a059                	j	80004e30 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004dac:	e9040613          	addi	a2,s0,-368
    80004db0:	85ca                	mv	a1,s2
    80004db2:	855a                	mv	a0,s6
    80004db4:	ffffd097          	auipc	ra,0xffffd
    80004db8:	8b8080e7          	jalr	-1864(ra) # 8000166c <copyout>
    80004dbc:	0a054963          	bltz	a0,80004e6e <exec+0x312>
  p->trapframe->a1 = sp;
    80004dc0:	058bb783          	ld	a5,88(s7)
    80004dc4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004dc8:	de843783          	ld	a5,-536(s0)
    80004dcc:	0007c703          	lbu	a4,0(a5)
    80004dd0:	cf11                	beqz	a4,80004dec <exec+0x290>
    80004dd2:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004dd4:	02f00693          	li	a3,47
    80004dd8:	a039                	j	80004de6 <exec+0x28a>
      last = s+1;
    80004dda:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004dde:	0785                	addi	a5,a5,1
    80004de0:	fff7c703          	lbu	a4,-1(a5)
    80004de4:	c701                	beqz	a4,80004dec <exec+0x290>
    if(*s == '/')
    80004de6:	fed71ce3          	bne	a4,a3,80004dde <exec+0x282>
    80004dea:	bfc5                	j	80004dda <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004dec:	4641                	li	a2,16
    80004dee:	de843583          	ld	a1,-536(s0)
    80004df2:	158b8513          	addi	a0,s7,344
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	026080e7          	jalr	38(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004dfe:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e02:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e06:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e0a:	058bb783          	ld	a5,88(s7)
    80004e0e:	e6843703          	ld	a4,-408(s0)
    80004e12:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e14:	058bb783          	ld	a5,88(s7)
    80004e18:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e1c:	85ea                	mv	a1,s10
    80004e1e:	ffffd097          	auipc	ra,0xffffd
    80004e22:	cee080e7          	jalr	-786(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e26:	0004851b          	sext.w	a0,s1
    80004e2a:	b3f9                	j	80004bf8 <exec+0x9c>
    80004e2c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e30:	df843583          	ld	a1,-520(s0)
    80004e34:	855a                	mv	a0,s6
    80004e36:	ffffd097          	auipc	ra,0xffffd
    80004e3a:	cd6080e7          	jalr	-810(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80004e3e:	da0a93e3          	bnez	s5,80004be4 <exec+0x88>
  return -1;
    80004e42:	557d                	li	a0,-1
    80004e44:	bb55                	j	80004bf8 <exec+0x9c>
    80004e46:	df243c23          	sd	s2,-520(s0)
    80004e4a:	b7dd                	j	80004e30 <exec+0x2d4>
    80004e4c:	df243c23          	sd	s2,-520(s0)
    80004e50:	b7c5                	j	80004e30 <exec+0x2d4>
    80004e52:	df243c23          	sd	s2,-520(s0)
    80004e56:	bfe9                	j	80004e30 <exec+0x2d4>
    80004e58:	df243c23          	sd	s2,-520(s0)
    80004e5c:	bfd1                	j	80004e30 <exec+0x2d4>
  sz = sz1;
    80004e5e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e62:	4a81                	li	s5,0
    80004e64:	b7f1                	j	80004e30 <exec+0x2d4>
  sz = sz1;
    80004e66:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e6a:	4a81                	li	s5,0
    80004e6c:	b7d1                	j	80004e30 <exec+0x2d4>
  sz = sz1;
    80004e6e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e72:	4a81                	li	s5,0
    80004e74:	bf75                	j	80004e30 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e76:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e7a:	e0843783          	ld	a5,-504(s0)
    80004e7e:	0017869b          	addiw	a3,a5,1
    80004e82:	e0d43423          	sd	a3,-504(s0)
    80004e86:	e0043783          	ld	a5,-512(s0)
    80004e8a:	0387879b          	addiw	a5,a5,56
    80004e8e:	e8845703          	lhu	a4,-376(s0)
    80004e92:	e0e6dfe3          	bge	a3,a4,80004cb0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e96:	2781                	sext.w	a5,a5
    80004e98:	e0f43023          	sd	a5,-512(s0)
    80004e9c:	03800713          	li	a4,56
    80004ea0:	86be                	mv	a3,a5
    80004ea2:	e1840613          	addi	a2,s0,-488
    80004ea6:	4581                	li	a1,0
    80004ea8:	8556                	mv	a0,s5
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	a58080e7          	jalr	-1448(ra) # 80003902 <readi>
    80004eb2:	03800793          	li	a5,56
    80004eb6:	f6f51be3          	bne	a0,a5,80004e2c <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80004eba:	e1842783          	lw	a5,-488(s0)
    80004ebe:	4705                	li	a4,1
    80004ec0:	fae79de3          	bne	a5,a4,80004e7a <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80004ec4:	e4043483          	ld	s1,-448(s0)
    80004ec8:	e3843783          	ld	a5,-456(s0)
    80004ecc:	f6f4ede3          	bltu	s1,a5,80004e46 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ed0:	e2843783          	ld	a5,-472(s0)
    80004ed4:	94be                	add	s1,s1,a5
    80004ed6:	f6f4ebe3          	bltu	s1,a5,80004e4c <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80004eda:	de043703          	ld	a4,-544(s0)
    80004ede:	8ff9                	and	a5,a5,a4
    80004ee0:	fbad                	bnez	a5,80004e52 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ee2:	e1c42503          	lw	a0,-484(s0)
    80004ee6:	00000097          	auipc	ra,0x0
    80004eea:	c5c080e7          	jalr	-932(ra) # 80004b42 <flags2perm>
    80004eee:	86aa                	mv	a3,a0
    80004ef0:	8626                	mv	a2,s1
    80004ef2:	85ca                	mv	a1,s2
    80004ef4:	855a                	mv	a0,s6
    80004ef6:	ffffc097          	auipc	ra,0xffffc
    80004efa:	51a080e7          	jalr	1306(ra) # 80001410 <uvmalloc>
    80004efe:	dea43c23          	sd	a0,-520(s0)
    80004f02:	d939                	beqz	a0,80004e58 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f04:	e2843c03          	ld	s8,-472(s0)
    80004f08:	e2042c83          	lw	s9,-480(s0)
    80004f0c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f10:	f60b83e3          	beqz	s7,80004e76 <exec+0x31a>
    80004f14:	89de                	mv	s3,s7
    80004f16:	4481                	li	s1,0
    80004f18:	bb9d                	j	80004c8e <exec+0x132>

0000000080004f1a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f1a:	7179                	addi	sp,sp,-48
    80004f1c:	f406                	sd	ra,40(sp)
    80004f1e:	f022                	sd	s0,32(sp)
    80004f20:	ec26                	sd	s1,24(sp)
    80004f22:	e84a                	sd	s2,16(sp)
    80004f24:	1800                	addi	s0,sp,48
    80004f26:	892e                	mv	s2,a1
    80004f28:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f2a:	fdc40593          	addi	a1,s0,-36
    80004f2e:	ffffe097          	auipc	ra,0xffffe
    80004f32:	b94080e7          	jalr	-1132(ra) # 80002ac2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f36:	fdc42703          	lw	a4,-36(s0)
    80004f3a:	47bd                	li	a5,15
    80004f3c:	02e7eb63          	bltu	a5,a4,80004f72 <argfd+0x58>
    80004f40:	ffffd097          	auipc	ra,0xffffd
    80004f44:	a6c080e7          	jalr	-1428(ra) # 800019ac <myproc>
    80004f48:	fdc42703          	lw	a4,-36(s0)
    80004f4c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd29a>
    80004f50:	078e                	slli	a5,a5,0x3
    80004f52:	953e                	add	a0,a0,a5
    80004f54:	611c                	ld	a5,0(a0)
    80004f56:	c385                	beqz	a5,80004f76 <argfd+0x5c>
    return -1;
  if(pfd)
    80004f58:	00090463          	beqz	s2,80004f60 <argfd+0x46>
    *pfd = fd;
    80004f5c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f60:	4501                	li	a0,0
  if(pf)
    80004f62:	c091                	beqz	s1,80004f66 <argfd+0x4c>
    *pf = f;
    80004f64:	e09c                	sd	a5,0(s1)
}
    80004f66:	70a2                	ld	ra,40(sp)
    80004f68:	7402                	ld	s0,32(sp)
    80004f6a:	64e2                	ld	s1,24(sp)
    80004f6c:	6942                	ld	s2,16(sp)
    80004f6e:	6145                	addi	sp,sp,48
    80004f70:	8082                	ret
    return -1;
    80004f72:	557d                	li	a0,-1
    80004f74:	bfcd                	j	80004f66 <argfd+0x4c>
    80004f76:	557d                	li	a0,-1
    80004f78:	b7fd                	j	80004f66 <argfd+0x4c>

0000000080004f7a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f7a:	1101                	addi	sp,sp,-32
    80004f7c:	ec06                	sd	ra,24(sp)
    80004f7e:	e822                	sd	s0,16(sp)
    80004f80:	e426                	sd	s1,8(sp)
    80004f82:	1000                	addi	s0,sp,32
    80004f84:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f86:	ffffd097          	auipc	ra,0xffffd
    80004f8a:	a26080e7          	jalr	-1498(ra) # 800019ac <myproc>
    80004f8e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f90:	0d050793          	addi	a5,a0,208
    80004f94:	4501                	li	a0,0
    80004f96:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f98:	6398                	ld	a4,0(a5)
    80004f9a:	cb19                	beqz	a4,80004fb0 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f9c:	2505                	addiw	a0,a0,1
    80004f9e:	07a1                	addi	a5,a5,8
    80004fa0:	fed51ce3          	bne	a0,a3,80004f98 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fa4:	557d                	li	a0,-1
}
    80004fa6:	60e2                	ld	ra,24(sp)
    80004fa8:	6442                	ld	s0,16(sp)
    80004faa:	64a2                	ld	s1,8(sp)
    80004fac:	6105                	addi	sp,sp,32
    80004fae:	8082                	ret
      p->ofile[fd] = f;
    80004fb0:	01a50793          	addi	a5,a0,26
    80004fb4:	078e                	slli	a5,a5,0x3
    80004fb6:	963e                	add	a2,a2,a5
    80004fb8:	e204                	sd	s1,0(a2)
      return fd;
    80004fba:	b7f5                	j	80004fa6 <fdalloc+0x2c>

0000000080004fbc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fbc:	715d                	addi	sp,sp,-80
    80004fbe:	e486                	sd	ra,72(sp)
    80004fc0:	e0a2                	sd	s0,64(sp)
    80004fc2:	fc26                	sd	s1,56(sp)
    80004fc4:	f84a                	sd	s2,48(sp)
    80004fc6:	f44e                	sd	s3,40(sp)
    80004fc8:	f052                	sd	s4,32(sp)
    80004fca:	ec56                	sd	s5,24(sp)
    80004fcc:	e85a                	sd	s6,16(sp)
    80004fce:	0880                	addi	s0,sp,80
    80004fd0:	8b2e                	mv	s6,a1
    80004fd2:	89b2                	mv	s3,a2
    80004fd4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fd6:	fb040593          	addi	a1,s0,-80
    80004fda:	fffff097          	auipc	ra,0xfffff
    80004fde:	e3e080e7          	jalr	-450(ra) # 80003e18 <nameiparent>
    80004fe2:	84aa                	mv	s1,a0
    80004fe4:	14050f63          	beqz	a0,80005142 <create+0x186>
    return 0;

  ilock(dp);
    80004fe8:	ffffe097          	auipc	ra,0xffffe
    80004fec:	666080e7          	jalr	1638(ra) # 8000364e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004ff0:	4601                	li	a2,0
    80004ff2:	fb040593          	addi	a1,s0,-80
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	b3a080e7          	jalr	-1222(ra) # 80003b32 <dirlookup>
    80005000:	8aaa                	mv	s5,a0
    80005002:	c931                	beqz	a0,80005056 <create+0x9a>
    iunlockput(dp);
    80005004:	8526                	mv	a0,s1
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	8aa080e7          	jalr	-1878(ra) # 800038b0 <iunlockput>
    ilock(ip);
    8000500e:	8556                	mv	a0,s5
    80005010:	ffffe097          	auipc	ra,0xffffe
    80005014:	63e080e7          	jalr	1598(ra) # 8000364e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005018:	000b059b          	sext.w	a1,s6
    8000501c:	4789                	li	a5,2
    8000501e:	02f59563          	bne	a1,a5,80005048 <create+0x8c>
    80005022:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd2c4>
    80005026:	37f9                	addiw	a5,a5,-2
    80005028:	17c2                	slli	a5,a5,0x30
    8000502a:	93c1                	srli	a5,a5,0x30
    8000502c:	4705                	li	a4,1
    8000502e:	00f76d63          	bltu	a4,a5,80005048 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005032:	8556                	mv	a0,s5
    80005034:	60a6                	ld	ra,72(sp)
    80005036:	6406                	ld	s0,64(sp)
    80005038:	74e2                	ld	s1,56(sp)
    8000503a:	7942                	ld	s2,48(sp)
    8000503c:	79a2                	ld	s3,40(sp)
    8000503e:	7a02                	ld	s4,32(sp)
    80005040:	6ae2                	ld	s5,24(sp)
    80005042:	6b42                	ld	s6,16(sp)
    80005044:	6161                	addi	sp,sp,80
    80005046:	8082                	ret
    iunlockput(ip);
    80005048:	8556                	mv	a0,s5
    8000504a:	fffff097          	auipc	ra,0xfffff
    8000504e:	866080e7          	jalr	-1946(ra) # 800038b0 <iunlockput>
    return 0;
    80005052:	4a81                	li	s5,0
    80005054:	bff9                	j	80005032 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005056:	85da                	mv	a1,s6
    80005058:	4088                	lw	a0,0(s1)
    8000505a:	ffffe097          	auipc	ra,0xffffe
    8000505e:	456080e7          	jalr	1110(ra) # 800034b0 <ialloc>
    80005062:	8a2a                	mv	s4,a0
    80005064:	c539                	beqz	a0,800050b2 <create+0xf6>
  ilock(ip);
    80005066:	ffffe097          	auipc	ra,0xffffe
    8000506a:	5e8080e7          	jalr	1512(ra) # 8000364e <ilock>
  ip->major = major;
    8000506e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005072:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005076:	4905                	li	s2,1
    80005078:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000507c:	8552                	mv	a0,s4
    8000507e:	ffffe097          	auipc	ra,0xffffe
    80005082:	504080e7          	jalr	1284(ra) # 80003582 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005086:	000b059b          	sext.w	a1,s6
    8000508a:	03258b63          	beq	a1,s2,800050c0 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000508e:	004a2603          	lw	a2,4(s4)
    80005092:	fb040593          	addi	a1,s0,-80
    80005096:	8526                	mv	a0,s1
    80005098:	fffff097          	auipc	ra,0xfffff
    8000509c:	cb0080e7          	jalr	-848(ra) # 80003d48 <dirlink>
    800050a0:	06054f63          	bltz	a0,8000511e <create+0x162>
  iunlockput(dp);
    800050a4:	8526                	mv	a0,s1
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	80a080e7          	jalr	-2038(ra) # 800038b0 <iunlockput>
  return ip;
    800050ae:	8ad2                	mv	s5,s4
    800050b0:	b749                	j	80005032 <create+0x76>
    iunlockput(dp);
    800050b2:	8526                	mv	a0,s1
    800050b4:	ffffe097          	auipc	ra,0xffffe
    800050b8:	7fc080e7          	jalr	2044(ra) # 800038b0 <iunlockput>
    return 0;
    800050bc:	8ad2                	mv	s5,s4
    800050be:	bf95                	j	80005032 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050c0:	004a2603          	lw	a2,4(s4)
    800050c4:	00003597          	auipc	a1,0x3
    800050c8:	64c58593          	addi	a1,a1,1612 # 80008710 <syscalls+0x2c0>
    800050cc:	8552                	mv	a0,s4
    800050ce:	fffff097          	auipc	ra,0xfffff
    800050d2:	c7a080e7          	jalr	-902(ra) # 80003d48 <dirlink>
    800050d6:	04054463          	bltz	a0,8000511e <create+0x162>
    800050da:	40d0                	lw	a2,4(s1)
    800050dc:	00003597          	auipc	a1,0x3
    800050e0:	63c58593          	addi	a1,a1,1596 # 80008718 <syscalls+0x2c8>
    800050e4:	8552                	mv	a0,s4
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	c62080e7          	jalr	-926(ra) # 80003d48 <dirlink>
    800050ee:	02054863          	bltz	a0,8000511e <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800050f2:	004a2603          	lw	a2,4(s4)
    800050f6:	fb040593          	addi	a1,s0,-80
    800050fa:	8526                	mv	a0,s1
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	c4c080e7          	jalr	-948(ra) # 80003d48 <dirlink>
    80005104:	00054d63          	bltz	a0,8000511e <create+0x162>
    dp->nlink++;  // for ".."
    80005108:	04a4d783          	lhu	a5,74(s1)
    8000510c:	2785                	addiw	a5,a5,1
    8000510e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005112:	8526                	mv	a0,s1
    80005114:	ffffe097          	auipc	ra,0xffffe
    80005118:	46e080e7          	jalr	1134(ra) # 80003582 <iupdate>
    8000511c:	b761                	j	800050a4 <create+0xe8>
  ip->nlink = 0;
    8000511e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005122:	8552                	mv	a0,s4
    80005124:	ffffe097          	auipc	ra,0xffffe
    80005128:	45e080e7          	jalr	1118(ra) # 80003582 <iupdate>
  iunlockput(ip);
    8000512c:	8552                	mv	a0,s4
    8000512e:	ffffe097          	auipc	ra,0xffffe
    80005132:	782080e7          	jalr	1922(ra) # 800038b0 <iunlockput>
  iunlockput(dp);
    80005136:	8526                	mv	a0,s1
    80005138:	ffffe097          	auipc	ra,0xffffe
    8000513c:	778080e7          	jalr	1912(ra) # 800038b0 <iunlockput>
  return 0;
    80005140:	bdcd                	j	80005032 <create+0x76>
    return 0;
    80005142:	8aaa                	mv	s5,a0
    80005144:	b5fd                	j	80005032 <create+0x76>

0000000080005146 <sys_dup>:
{
    80005146:	7179                	addi	sp,sp,-48
    80005148:	f406                	sd	ra,40(sp)
    8000514a:	f022                	sd	s0,32(sp)
    8000514c:	ec26                	sd	s1,24(sp)
    8000514e:	e84a                	sd	s2,16(sp)
    80005150:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005152:	fd840613          	addi	a2,s0,-40
    80005156:	4581                	li	a1,0
    80005158:	4501                	li	a0,0
    8000515a:	00000097          	auipc	ra,0x0
    8000515e:	dc0080e7          	jalr	-576(ra) # 80004f1a <argfd>
    return -1;
    80005162:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005164:	02054363          	bltz	a0,8000518a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005168:	fd843903          	ld	s2,-40(s0)
    8000516c:	854a                	mv	a0,s2
    8000516e:	00000097          	auipc	ra,0x0
    80005172:	e0c080e7          	jalr	-500(ra) # 80004f7a <fdalloc>
    80005176:	84aa                	mv	s1,a0
    return -1;
    80005178:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000517a:	00054863          	bltz	a0,8000518a <sys_dup+0x44>
  filedup(f);
    8000517e:	854a                	mv	a0,s2
    80005180:	fffff097          	auipc	ra,0xfffff
    80005184:	310080e7          	jalr	784(ra) # 80004490 <filedup>
  return fd;
    80005188:	87a6                	mv	a5,s1
}
    8000518a:	853e                	mv	a0,a5
    8000518c:	70a2                	ld	ra,40(sp)
    8000518e:	7402                	ld	s0,32(sp)
    80005190:	64e2                	ld	s1,24(sp)
    80005192:	6942                	ld	s2,16(sp)
    80005194:	6145                	addi	sp,sp,48
    80005196:	8082                	ret

0000000080005198 <sys_read>:
{
    80005198:	7179                	addi	sp,sp,-48
    8000519a:	f406                	sd	ra,40(sp)
    8000519c:	f022                	sd	s0,32(sp)
    8000519e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051a0:	fd840593          	addi	a1,s0,-40
    800051a4:	4505                	li	a0,1
    800051a6:	ffffe097          	auipc	ra,0xffffe
    800051aa:	93c080e7          	jalr	-1732(ra) # 80002ae2 <argaddr>
  argint(2, &n);
    800051ae:	fe440593          	addi	a1,s0,-28
    800051b2:	4509                	li	a0,2
    800051b4:	ffffe097          	auipc	ra,0xffffe
    800051b8:	90e080e7          	jalr	-1778(ra) # 80002ac2 <argint>
  if(argfd(0, 0, &f) < 0)
    800051bc:	fe840613          	addi	a2,s0,-24
    800051c0:	4581                	li	a1,0
    800051c2:	4501                	li	a0,0
    800051c4:	00000097          	auipc	ra,0x0
    800051c8:	d56080e7          	jalr	-682(ra) # 80004f1a <argfd>
    800051cc:	87aa                	mv	a5,a0
    return -1;
    800051ce:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051d0:	0007cc63          	bltz	a5,800051e8 <sys_read+0x50>
  return fileread(f, p, n);
    800051d4:	fe442603          	lw	a2,-28(s0)
    800051d8:	fd843583          	ld	a1,-40(s0)
    800051dc:	fe843503          	ld	a0,-24(s0)
    800051e0:	fffff097          	auipc	ra,0xfffff
    800051e4:	43c080e7          	jalr	1084(ra) # 8000461c <fileread>
}
    800051e8:	70a2                	ld	ra,40(sp)
    800051ea:	7402                	ld	s0,32(sp)
    800051ec:	6145                	addi	sp,sp,48
    800051ee:	8082                	ret

00000000800051f0 <sys_write>:
{
    800051f0:	7179                	addi	sp,sp,-48
    800051f2:	f406                	sd	ra,40(sp)
    800051f4:	f022                	sd	s0,32(sp)
    800051f6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051f8:	fd840593          	addi	a1,s0,-40
    800051fc:	4505                	li	a0,1
    800051fe:	ffffe097          	auipc	ra,0xffffe
    80005202:	8e4080e7          	jalr	-1820(ra) # 80002ae2 <argaddr>
  argint(2, &n);
    80005206:	fe440593          	addi	a1,s0,-28
    8000520a:	4509                	li	a0,2
    8000520c:	ffffe097          	auipc	ra,0xffffe
    80005210:	8b6080e7          	jalr	-1866(ra) # 80002ac2 <argint>
  if(argfd(0, 0, &f) < 0)
    80005214:	fe840613          	addi	a2,s0,-24
    80005218:	4581                	li	a1,0
    8000521a:	4501                	li	a0,0
    8000521c:	00000097          	auipc	ra,0x0
    80005220:	cfe080e7          	jalr	-770(ra) # 80004f1a <argfd>
    80005224:	87aa                	mv	a5,a0
    return -1;
    80005226:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005228:	0007cc63          	bltz	a5,80005240 <sys_write+0x50>
  return filewrite(f, p, n);
    8000522c:	fe442603          	lw	a2,-28(s0)
    80005230:	fd843583          	ld	a1,-40(s0)
    80005234:	fe843503          	ld	a0,-24(s0)
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	4a6080e7          	jalr	1190(ra) # 800046de <filewrite>
}
    80005240:	70a2                	ld	ra,40(sp)
    80005242:	7402                	ld	s0,32(sp)
    80005244:	6145                	addi	sp,sp,48
    80005246:	8082                	ret

0000000080005248 <sys_close>:
{
    80005248:	1101                	addi	sp,sp,-32
    8000524a:	ec06                	sd	ra,24(sp)
    8000524c:	e822                	sd	s0,16(sp)
    8000524e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005250:	fe040613          	addi	a2,s0,-32
    80005254:	fec40593          	addi	a1,s0,-20
    80005258:	4501                	li	a0,0
    8000525a:	00000097          	auipc	ra,0x0
    8000525e:	cc0080e7          	jalr	-832(ra) # 80004f1a <argfd>
    return -1;
    80005262:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005264:	02054463          	bltz	a0,8000528c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005268:	ffffc097          	auipc	ra,0xffffc
    8000526c:	744080e7          	jalr	1860(ra) # 800019ac <myproc>
    80005270:	fec42783          	lw	a5,-20(s0)
    80005274:	07e9                	addi	a5,a5,26
    80005276:	078e                	slli	a5,a5,0x3
    80005278:	953e                	add	a0,a0,a5
    8000527a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000527e:	fe043503          	ld	a0,-32(s0)
    80005282:	fffff097          	auipc	ra,0xfffff
    80005286:	260080e7          	jalr	608(ra) # 800044e2 <fileclose>
  return 0;
    8000528a:	4781                	li	a5,0
}
    8000528c:	853e                	mv	a0,a5
    8000528e:	60e2                	ld	ra,24(sp)
    80005290:	6442                	ld	s0,16(sp)
    80005292:	6105                	addi	sp,sp,32
    80005294:	8082                	ret

0000000080005296 <sys_fstat>:
{
    80005296:	1101                	addi	sp,sp,-32
    80005298:	ec06                	sd	ra,24(sp)
    8000529a:	e822                	sd	s0,16(sp)
    8000529c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000529e:	fe040593          	addi	a1,s0,-32
    800052a2:	4505                	li	a0,1
    800052a4:	ffffe097          	auipc	ra,0xffffe
    800052a8:	83e080e7          	jalr	-1986(ra) # 80002ae2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052ac:	fe840613          	addi	a2,s0,-24
    800052b0:	4581                	li	a1,0
    800052b2:	4501                	li	a0,0
    800052b4:	00000097          	auipc	ra,0x0
    800052b8:	c66080e7          	jalr	-922(ra) # 80004f1a <argfd>
    800052bc:	87aa                	mv	a5,a0
    return -1;
    800052be:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052c0:	0007ca63          	bltz	a5,800052d4 <sys_fstat+0x3e>
  return filestat(f, st);
    800052c4:	fe043583          	ld	a1,-32(s0)
    800052c8:	fe843503          	ld	a0,-24(s0)
    800052cc:	fffff097          	auipc	ra,0xfffff
    800052d0:	2de080e7          	jalr	734(ra) # 800045aa <filestat>
}
    800052d4:	60e2                	ld	ra,24(sp)
    800052d6:	6442                	ld	s0,16(sp)
    800052d8:	6105                	addi	sp,sp,32
    800052da:	8082                	ret

00000000800052dc <sys_link>:
{
    800052dc:	7169                	addi	sp,sp,-304
    800052de:	f606                	sd	ra,296(sp)
    800052e0:	f222                	sd	s0,288(sp)
    800052e2:	ee26                	sd	s1,280(sp)
    800052e4:	ea4a                	sd	s2,272(sp)
    800052e6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052e8:	08000613          	li	a2,128
    800052ec:	ed040593          	addi	a1,s0,-304
    800052f0:	4501                	li	a0,0
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	810080e7          	jalr	-2032(ra) # 80002b02 <argstr>
    return -1;
    800052fa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052fc:	10054e63          	bltz	a0,80005418 <sys_link+0x13c>
    80005300:	08000613          	li	a2,128
    80005304:	f5040593          	addi	a1,s0,-176
    80005308:	4505                	li	a0,1
    8000530a:	ffffd097          	auipc	ra,0xffffd
    8000530e:	7f8080e7          	jalr	2040(ra) # 80002b02 <argstr>
    return -1;
    80005312:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005314:	10054263          	bltz	a0,80005418 <sys_link+0x13c>
  begin_op();
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	d02080e7          	jalr	-766(ra) # 8000401a <begin_op>
  if((ip = namei(old)) == 0){
    80005320:	ed040513          	addi	a0,s0,-304
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	ad6080e7          	jalr	-1322(ra) # 80003dfa <namei>
    8000532c:	84aa                	mv	s1,a0
    8000532e:	c551                	beqz	a0,800053ba <sys_link+0xde>
  ilock(ip);
    80005330:	ffffe097          	auipc	ra,0xffffe
    80005334:	31e080e7          	jalr	798(ra) # 8000364e <ilock>
  if(ip->type == T_DIR){
    80005338:	04449703          	lh	a4,68(s1)
    8000533c:	4785                	li	a5,1
    8000533e:	08f70463          	beq	a4,a5,800053c6 <sys_link+0xea>
  ip->nlink++;
    80005342:	04a4d783          	lhu	a5,74(s1)
    80005346:	2785                	addiw	a5,a5,1
    80005348:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000534c:	8526                	mv	a0,s1
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	234080e7          	jalr	564(ra) # 80003582 <iupdate>
  iunlock(ip);
    80005356:	8526                	mv	a0,s1
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	3b8080e7          	jalr	952(ra) # 80003710 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005360:	fd040593          	addi	a1,s0,-48
    80005364:	f5040513          	addi	a0,s0,-176
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	ab0080e7          	jalr	-1360(ra) # 80003e18 <nameiparent>
    80005370:	892a                	mv	s2,a0
    80005372:	c935                	beqz	a0,800053e6 <sys_link+0x10a>
  ilock(dp);
    80005374:	ffffe097          	auipc	ra,0xffffe
    80005378:	2da080e7          	jalr	730(ra) # 8000364e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000537c:	00092703          	lw	a4,0(s2)
    80005380:	409c                	lw	a5,0(s1)
    80005382:	04f71d63          	bne	a4,a5,800053dc <sys_link+0x100>
    80005386:	40d0                	lw	a2,4(s1)
    80005388:	fd040593          	addi	a1,s0,-48
    8000538c:	854a                	mv	a0,s2
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	9ba080e7          	jalr	-1606(ra) # 80003d48 <dirlink>
    80005396:	04054363          	bltz	a0,800053dc <sys_link+0x100>
  iunlockput(dp);
    8000539a:	854a                	mv	a0,s2
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	514080e7          	jalr	1300(ra) # 800038b0 <iunlockput>
  iput(ip);
    800053a4:	8526                	mv	a0,s1
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	462080e7          	jalr	1122(ra) # 80003808 <iput>
  end_op();
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	cea080e7          	jalr	-790(ra) # 80004098 <end_op>
  return 0;
    800053b6:	4781                	li	a5,0
    800053b8:	a085                	j	80005418 <sys_link+0x13c>
    end_op();
    800053ba:	fffff097          	auipc	ra,0xfffff
    800053be:	cde080e7          	jalr	-802(ra) # 80004098 <end_op>
    return -1;
    800053c2:	57fd                	li	a5,-1
    800053c4:	a891                	j	80005418 <sys_link+0x13c>
    iunlockput(ip);
    800053c6:	8526                	mv	a0,s1
    800053c8:	ffffe097          	auipc	ra,0xffffe
    800053cc:	4e8080e7          	jalr	1256(ra) # 800038b0 <iunlockput>
    end_op();
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	cc8080e7          	jalr	-824(ra) # 80004098 <end_op>
    return -1;
    800053d8:	57fd                	li	a5,-1
    800053da:	a83d                	j	80005418 <sys_link+0x13c>
    iunlockput(dp);
    800053dc:	854a                	mv	a0,s2
    800053de:	ffffe097          	auipc	ra,0xffffe
    800053e2:	4d2080e7          	jalr	1234(ra) # 800038b0 <iunlockput>
  ilock(ip);
    800053e6:	8526                	mv	a0,s1
    800053e8:	ffffe097          	auipc	ra,0xffffe
    800053ec:	266080e7          	jalr	614(ra) # 8000364e <ilock>
  ip->nlink--;
    800053f0:	04a4d783          	lhu	a5,74(s1)
    800053f4:	37fd                	addiw	a5,a5,-1
    800053f6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053fa:	8526                	mv	a0,s1
    800053fc:	ffffe097          	auipc	ra,0xffffe
    80005400:	186080e7          	jalr	390(ra) # 80003582 <iupdate>
  iunlockput(ip);
    80005404:	8526                	mv	a0,s1
    80005406:	ffffe097          	auipc	ra,0xffffe
    8000540a:	4aa080e7          	jalr	1194(ra) # 800038b0 <iunlockput>
  end_op();
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	c8a080e7          	jalr	-886(ra) # 80004098 <end_op>
  return -1;
    80005416:	57fd                	li	a5,-1
}
    80005418:	853e                	mv	a0,a5
    8000541a:	70b2                	ld	ra,296(sp)
    8000541c:	7412                	ld	s0,288(sp)
    8000541e:	64f2                	ld	s1,280(sp)
    80005420:	6952                	ld	s2,272(sp)
    80005422:	6155                	addi	sp,sp,304
    80005424:	8082                	ret

0000000080005426 <sys_unlink>:
{
    80005426:	7151                	addi	sp,sp,-240
    80005428:	f586                	sd	ra,232(sp)
    8000542a:	f1a2                	sd	s0,224(sp)
    8000542c:	eda6                	sd	s1,216(sp)
    8000542e:	e9ca                	sd	s2,208(sp)
    80005430:	e5ce                	sd	s3,200(sp)
    80005432:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005434:	08000613          	li	a2,128
    80005438:	f3040593          	addi	a1,s0,-208
    8000543c:	4501                	li	a0,0
    8000543e:	ffffd097          	auipc	ra,0xffffd
    80005442:	6c4080e7          	jalr	1732(ra) # 80002b02 <argstr>
    80005446:	18054163          	bltz	a0,800055c8 <sys_unlink+0x1a2>
  begin_op();
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	bd0080e7          	jalr	-1072(ra) # 8000401a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005452:	fb040593          	addi	a1,s0,-80
    80005456:	f3040513          	addi	a0,s0,-208
    8000545a:	fffff097          	auipc	ra,0xfffff
    8000545e:	9be080e7          	jalr	-1602(ra) # 80003e18 <nameiparent>
    80005462:	84aa                	mv	s1,a0
    80005464:	c979                	beqz	a0,8000553a <sys_unlink+0x114>
  ilock(dp);
    80005466:	ffffe097          	auipc	ra,0xffffe
    8000546a:	1e8080e7          	jalr	488(ra) # 8000364e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000546e:	00003597          	auipc	a1,0x3
    80005472:	2a258593          	addi	a1,a1,674 # 80008710 <syscalls+0x2c0>
    80005476:	fb040513          	addi	a0,s0,-80
    8000547a:	ffffe097          	auipc	ra,0xffffe
    8000547e:	69e080e7          	jalr	1694(ra) # 80003b18 <namecmp>
    80005482:	14050a63          	beqz	a0,800055d6 <sys_unlink+0x1b0>
    80005486:	00003597          	auipc	a1,0x3
    8000548a:	29258593          	addi	a1,a1,658 # 80008718 <syscalls+0x2c8>
    8000548e:	fb040513          	addi	a0,s0,-80
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	686080e7          	jalr	1670(ra) # 80003b18 <namecmp>
    8000549a:	12050e63          	beqz	a0,800055d6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000549e:	f2c40613          	addi	a2,s0,-212
    800054a2:	fb040593          	addi	a1,s0,-80
    800054a6:	8526                	mv	a0,s1
    800054a8:	ffffe097          	auipc	ra,0xffffe
    800054ac:	68a080e7          	jalr	1674(ra) # 80003b32 <dirlookup>
    800054b0:	892a                	mv	s2,a0
    800054b2:	12050263          	beqz	a0,800055d6 <sys_unlink+0x1b0>
  ilock(ip);
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	198080e7          	jalr	408(ra) # 8000364e <ilock>
  if(ip->nlink < 1)
    800054be:	04a91783          	lh	a5,74(s2)
    800054c2:	08f05263          	blez	a5,80005546 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054c6:	04491703          	lh	a4,68(s2)
    800054ca:	4785                	li	a5,1
    800054cc:	08f70563          	beq	a4,a5,80005556 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054d0:	4641                	li	a2,16
    800054d2:	4581                	li	a1,0
    800054d4:	fc040513          	addi	a0,s0,-64
    800054d8:	ffffb097          	auipc	ra,0xffffb
    800054dc:	7fa080e7          	jalr	2042(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054e0:	4741                	li	a4,16
    800054e2:	f2c42683          	lw	a3,-212(s0)
    800054e6:	fc040613          	addi	a2,s0,-64
    800054ea:	4581                	li	a1,0
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	50c080e7          	jalr	1292(ra) # 800039fa <writei>
    800054f6:	47c1                	li	a5,16
    800054f8:	0af51563          	bne	a0,a5,800055a2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054fc:	04491703          	lh	a4,68(s2)
    80005500:	4785                	li	a5,1
    80005502:	0af70863          	beq	a4,a5,800055b2 <sys_unlink+0x18c>
  iunlockput(dp);
    80005506:	8526                	mv	a0,s1
    80005508:	ffffe097          	auipc	ra,0xffffe
    8000550c:	3a8080e7          	jalr	936(ra) # 800038b0 <iunlockput>
  ip->nlink--;
    80005510:	04a95783          	lhu	a5,74(s2)
    80005514:	37fd                	addiw	a5,a5,-1
    80005516:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000551a:	854a                	mv	a0,s2
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	066080e7          	jalr	102(ra) # 80003582 <iupdate>
  iunlockput(ip);
    80005524:	854a                	mv	a0,s2
    80005526:	ffffe097          	auipc	ra,0xffffe
    8000552a:	38a080e7          	jalr	906(ra) # 800038b0 <iunlockput>
  end_op();
    8000552e:	fffff097          	auipc	ra,0xfffff
    80005532:	b6a080e7          	jalr	-1174(ra) # 80004098 <end_op>
  return 0;
    80005536:	4501                	li	a0,0
    80005538:	a84d                	j	800055ea <sys_unlink+0x1c4>
    end_op();
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	b5e080e7          	jalr	-1186(ra) # 80004098 <end_op>
    return -1;
    80005542:	557d                	li	a0,-1
    80005544:	a05d                	j	800055ea <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005546:	00003517          	auipc	a0,0x3
    8000554a:	1da50513          	addi	a0,a0,474 # 80008720 <syscalls+0x2d0>
    8000554e:	ffffb097          	auipc	ra,0xffffb
    80005552:	ff2080e7          	jalr	-14(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005556:	04c92703          	lw	a4,76(s2)
    8000555a:	02000793          	li	a5,32
    8000555e:	f6e7f9e3          	bgeu	a5,a4,800054d0 <sys_unlink+0xaa>
    80005562:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005566:	4741                	li	a4,16
    80005568:	86ce                	mv	a3,s3
    8000556a:	f1840613          	addi	a2,s0,-232
    8000556e:	4581                	li	a1,0
    80005570:	854a                	mv	a0,s2
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	390080e7          	jalr	912(ra) # 80003902 <readi>
    8000557a:	47c1                	li	a5,16
    8000557c:	00f51b63          	bne	a0,a5,80005592 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005580:	f1845783          	lhu	a5,-232(s0)
    80005584:	e7a1                	bnez	a5,800055cc <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005586:	29c1                	addiw	s3,s3,16
    80005588:	04c92783          	lw	a5,76(s2)
    8000558c:	fcf9ede3          	bltu	s3,a5,80005566 <sys_unlink+0x140>
    80005590:	b781                	j	800054d0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005592:	00003517          	auipc	a0,0x3
    80005596:	1a650513          	addi	a0,a0,422 # 80008738 <syscalls+0x2e8>
    8000559a:	ffffb097          	auipc	ra,0xffffb
    8000559e:	fa6080e7          	jalr	-90(ra) # 80000540 <panic>
    panic("unlink: writei");
    800055a2:	00003517          	auipc	a0,0x3
    800055a6:	1ae50513          	addi	a0,a0,430 # 80008750 <syscalls+0x300>
    800055aa:	ffffb097          	auipc	ra,0xffffb
    800055ae:	f96080e7          	jalr	-106(ra) # 80000540 <panic>
    dp->nlink--;
    800055b2:	04a4d783          	lhu	a5,74(s1)
    800055b6:	37fd                	addiw	a5,a5,-1
    800055b8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055bc:	8526                	mv	a0,s1
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	fc4080e7          	jalr	-60(ra) # 80003582 <iupdate>
    800055c6:	b781                	j	80005506 <sys_unlink+0xe0>
    return -1;
    800055c8:	557d                	li	a0,-1
    800055ca:	a005                	j	800055ea <sys_unlink+0x1c4>
    iunlockput(ip);
    800055cc:	854a                	mv	a0,s2
    800055ce:	ffffe097          	auipc	ra,0xffffe
    800055d2:	2e2080e7          	jalr	738(ra) # 800038b0 <iunlockput>
  iunlockput(dp);
    800055d6:	8526                	mv	a0,s1
    800055d8:	ffffe097          	auipc	ra,0xffffe
    800055dc:	2d8080e7          	jalr	728(ra) # 800038b0 <iunlockput>
  end_op();
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	ab8080e7          	jalr	-1352(ra) # 80004098 <end_op>
  return -1;
    800055e8:	557d                	li	a0,-1
}
    800055ea:	70ae                	ld	ra,232(sp)
    800055ec:	740e                	ld	s0,224(sp)
    800055ee:	64ee                	ld	s1,216(sp)
    800055f0:	694e                	ld	s2,208(sp)
    800055f2:	69ae                	ld	s3,200(sp)
    800055f4:	616d                	addi	sp,sp,240
    800055f6:	8082                	ret

00000000800055f8 <sys_open>:

uint64
sys_open(void)
{
    800055f8:	7131                	addi	sp,sp,-192
    800055fa:	fd06                	sd	ra,184(sp)
    800055fc:	f922                	sd	s0,176(sp)
    800055fe:	f526                	sd	s1,168(sp)
    80005600:	f14a                	sd	s2,160(sp)
    80005602:	ed4e                	sd	s3,152(sp)
    80005604:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005606:	f4c40593          	addi	a1,s0,-180
    8000560a:	4505                	li	a0,1
    8000560c:	ffffd097          	auipc	ra,0xffffd
    80005610:	4b6080e7          	jalr	1206(ra) # 80002ac2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005614:	08000613          	li	a2,128
    80005618:	f5040593          	addi	a1,s0,-176
    8000561c:	4501                	li	a0,0
    8000561e:	ffffd097          	auipc	ra,0xffffd
    80005622:	4e4080e7          	jalr	1252(ra) # 80002b02 <argstr>
    80005626:	87aa                	mv	a5,a0
    return -1;
    80005628:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000562a:	0a07c963          	bltz	a5,800056dc <sys_open+0xe4>

  begin_op();
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	9ec080e7          	jalr	-1556(ra) # 8000401a <begin_op>

  if(omode & O_CREATE){
    80005636:	f4c42783          	lw	a5,-180(s0)
    8000563a:	2007f793          	andi	a5,a5,512
    8000563e:	cfc5                	beqz	a5,800056f6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005640:	4681                	li	a3,0
    80005642:	4601                	li	a2,0
    80005644:	4589                	li	a1,2
    80005646:	f5040513          	addi	a0,s0,-176
    8000564a:	00000097          	auipc	ra,0x0
    8000564e:	972080e7          	jalr	-1678(ra) # 80004fbc <create>
    80005652:	84aa                	mv	s1,a0
    if(ip == 0){
    80005654:	c959                	beqz	a0,800056ea <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005656:	04449703          	lh	a4,68(s1)
    8000565a:	478d                	li	a5,3
    8000565c:	00f71763          	bne	a4,a5,8000566a <sys_open+0x72>
    80005660:	0464d703          	lhu	a4,70(s1)
    80005664:	47a5                	li	a5,9
    80005666:	0ce7ed63          	bltu	a5,a4,80005740 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000566a:	fffff097          	auipc	ra,0xfffff
    8000566e:	dbc080e7          	jalr	-580(ra) # 80004426 <filealloc>
    80005672:	89aa                	mv	s3,a0
    80005674:	10050363          	beqz	a0,8000577a <sys_open+0x182>
    80005678:	00000097          	auipc	ra,0x0
    8000567c:	902080e7          	jalr	-1790(ra) # 80004f7a <fdalloc>
    80005680:	892a                	mv	s2,a0
    80005682:	0e054763          	bltz	a0,80005770 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005686:	04449703          	lh	a4,68(s1)
    8000568a:	478d                	li	a5,3
    8000568c:	0cf70563          	beq	a4,a5,80005756 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005690:	4789                	li	a5,2
    80005692:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005696:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000569a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000569e:	f4c42783          	lw	a5,-180(s0)
    800056a2:	0017c713          	xori	a4,a5,1
    800056a6:	8b05                	andi	a4,a4,1
    800056a8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056ac:	0037f713          	andi	a4,a5,3
    800056b0:	00e03733          	snez	a4,a4
    800056b4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056b8:	4007f793          	andi	a5,a5,1024
    800056bc:	c791                	beqz	a5,800056c8 <sys_open+0xd0>
    800056be:	04449703          	lh	a4,68(s1)
    800056c2:	4789                	li	a5,2
    800056c4:	0af70063          	beq	a4,a5,80005764 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800056c8:	8526                	mv	a0,s1
    800056ca:	ffffe097          	auipc	ra,0xffffe
    800056ce:	046080e7          	jalr	70(ra) # 80003710 <iunlock>
  end_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	9c6080e7          	jalr	-1594(ra) # 80004098 <end_op>

  return fd;
    800056da:	854a                	mv	a0,s2
}
    800056dc:	70ea                	ld	ra,184(sp)
    800056de:	744a                	ld	s0,176(sp)
    800056e0:	74aa                	ld	s1,168(sp)
    800056e2:	790a                	ld	s2,160(sp)
    800056e4:	69ea                	ld	s3,152(sp)
    800056e6:	6129                	addi	sp,sp,192
    800056e8:	8082                	ret
      end_op();
    800056ea:	fffff097          	auipc	ra,0xfffff
    800056ee:	9ae080e7          	jalr	-1618(ra) # 80004098 <end_op>
      return -1;
    800056f2:	557d                	li	a0,-1
    800056f4:	b7e5                	j	800056dc <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800056f6:	f5040513          	addi	a0,s0,-176
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	700080e7          	jalr	1792(ra) # 80003dfa <namei>
    80005702:	84aa                	mv	s1,a0
    80005704:	c905                	beqz	a0,80005734 <sys_open+0x13c>
    ilock(ip);
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	f48080e7          	jalr	-184(ra) # 8000364e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000570e:	04449703          	lh	a4,68(s1)
    80005712:	4785                	li	a5,1
    80005714:	f4f711e3          	bne	a4,a5,80005656 <sys_open+0x5e>
    80005718:	f4c42783          	lw	a5,-180(s0)
    8000571c:	d7b9                	beqz	a5,8000566a <sys_open+0x72>
      iunlockput(ip);
    8000571e:	8526                	mv	a0,s1
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	190080e7          	jalr	400(ra) # 800038b0 <iunlockput>
      end_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	970080e7          	jalr	-1680(ra) # 80004098 <end_op>
      return -1;
    80005730:	557d                	li	a0,-1
    80005732:	b76d                	j	800056dc <sys_open+0xe4>
      end_op();
    80005734:	fffff097          	auipc	ra,0xfffff
    80005738:	964080e7          	jalr	-1692(ra) # 80004098 <end_op>
      return -1;
    8000573c:	557d                	li	a0,-1
    8000573e:	bf79                	j	800056dc <sys_open+0xe4>
    iunlockput(ip);
    80005740:	8526                	mv	a0,s1
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	16e080e7          	jalr	366(ra) # 800038b0 <iunlockput>
    end_op();
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	94e080e7          	jalr	-1714(ra) # 80004098 <end_op>
    return -1;
    80005752:	557d                	li	a0,-1
    80005754:	b761                	j	800056dc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005756:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000575a:	04649783          	lh	a5,70(s1)
    8000575e:	02f99223          	sh	a5,36(s3)
    80005762:	bf25                	j	8000569a <sys_open+0xa2>
    itrunc(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	ff6080e7          	jalr	-10(ra) # 8000375c <itrunc>
    8000576e:	bfa9                	j	800056c8 <sys_open+0xd0>
      fileclose(f);
    80005770:	854e                	mv	a0,s3
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	d70080e7          	jalr	-656(ra) # 800044e2 <fileclose>
    iunlockput(ip);
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	134080e7          	jalr	308(ra) # 800038b0 <iunlockput>
    end_op();
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	914080e7          	jalr	-1772(ra) # 80004098 <end_op>
    return -1;
    8000578c:	557d                	li	a0,-1
    8000578e:	b7b9                	j	800056dc <sys_open+0xe4>

0000000080005790 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005790:	7175                	addi	sp,sp,-144
    80005792:	e506                	sd	ra,136(sp)
    80005794:	e122                	sd	s0,128(sp)
    80005796:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	882080e7          	jalr	-1918(ra) # 8000401a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057a0:	08000613          	li	a2,128
    800057a4:	f7040593          	addi	a1,s0,-144
    800057a8:	4501                	li	a0,0
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	358080e7          	jalr	856(ra) # 80002b02 <argstr>
    800057b2:	02054963          	bltz	a0,800057e4 <sys_mkdir+0x54>
    800057b6:	4681                	li	a3,0
    800057b8:	4601                	li	a2,0
    800057ba:	4585                	li	a1,1
    800057bc:	f7040513          	addi	a0,s0,-144
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	7fc080e7          	jalr	2044(ra) # 80004fbc <create>
    800057c8:	cd11                	beqz	a0,800057e4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	0e6080e7          	jalr	230(ra) # 800038b0 <iunlockput>
  end_op();
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	8c6080e7          	jalr	-1850(ra) # 80004098 <end_op>
  return 0;
    800057da:	4501                	li	a0,0
}
    800057dc:	60aa                	ld	ra,136(sp)
    800057de:	640a                	ld	s0,128(sp)
    800057e0:	6149                	addi	sp,sp,144
    800057e2:	8082                	ret
    end_op();
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	8b4080e7          	jalr	-1868(ra) # 80004098 <end_op>
    return -1;
    800057ec:	557d                	li	a0,-1
    800057ee:	b7fd                	j	800057dc <sys_mkdir+0x4c>

00000000800057f0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057f0:	7135                	addi	sp,sp,-160
    800057f2:	ed06                	sd	ra,152(sp)
    800057f4:	e922                	sd	s0,144(sp)
    800057f6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057f8:	fffff097          	auipc	ra,0xfffff
    800057fc:	822080e7          	jalr	-2014(ra) # 8000401a <begin_op>
  argint(1, &major);
    80005800:	f6c40593          	addi	a1,s0,-148
    80005804:	4505                	li	a0,1
    80005806:	ffffd097          	auipc	ra,0xffffd
    8000580a:	2bc080e7          	jalr	700(ra) # 80002ac2 <argint>
  argint(2, &minor);
    8000580e:	f6840593          	addi	a1,s0,-152
    80005812:	4509                	li	a0,2
    80005814:	ffffd097          	auipc	ra,0xffffd
    80005818:	2ae080e7          	jalr	686(ra) # 80002ac2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000581c:	08000613          	li	a2,128
    80005820:	f7040593          	addi	a1,s0,-144
    80005824:	4501                	li	a0,0
    80005826:	ffffd097          	auipc	ra,0xffffd
    8000582a:	2dc080e7          	jalr	732(ra) # 80002b02 <argstr>
    8000582e:	02054b63          	bltz	a0,80005864 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005832:	f6841683          	lh	a3,-152(s0)
    80005836:	f6c41603          	lh	a2,-148(s0)
    8000583a:	458d                	li	a1,3
    8000583c:	f7040513          	addi	a0,s0,-144
    80005840:	fffff097          	auipc	ra,0xfffff
    80005844:	77c080e7          	jalr	1916(ra) # 80004fbc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005848:	cd11                	beqz	a0,80005864 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	066080e7          	jalr	102(ra) # 800038b0 <iunlockput>
  end_op();
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	846080e7          	jalr	-1978(ra) # 80004098 <end_op>
  return 0;
    8000585a:	4501                	li	a0,0
}
    8000585c:	60ea                	ld	ra,152(sp)
    8000585e:	644a                	ld	s0,144(sp)
    80005860:	610d                	addi	sp,sp,160
    80005862:	8082                	ret
    end_op();
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	834080e7          	jalr	-1996(ra) # 80004098 <end_op>
    return -1;
    8000586c:	557d                	li	a0,-1
    8000586e:	b7fd                	j	8000585c <sys_mknod+0x6c>

0000000080005870 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005870:	7135                	addi	sp,sp,-160
    80005872:	ed06                	sd	ra,152(sp)
    80005874:	e922                	sd	s0,144(sp)
    80005876:	e526                	sd	s1,136(sp)
    80005878:	e14a                	sd	s2,128(sp)
    8000587a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000587c:	ffffc097          	auipc	ra,0xffffc
    80005880:	130080e7          	jalr	304(ra) # 800019ac <myproc>
    80005884:	892a                	mv	s2,a0
  
  begin_op();
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	794080e7          	jalr	1940(ra) # 8000401a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000588e:	08000613          	li	a2,128
    80005892:	f6040593          	addi	a1,s0,-160
    80005896:	4501                	li	a0,0
    80005898:	ffffd097          	auipc	ra,0xffffd
    8000589c:	26a080e7          	jalr	618(ra) # 80002b02 <argstr>
    800058a0:	04054b63          	bltz	a0,800058f6 <sys_chdir+0x86>
    800058a4:	f6040513          	addi	a0,s0,-160
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	552080e7          	jalr	1362(ra) # 80003dfa <namei>
    800058b0:	84aa                	mv	s1,a0
    800058b2:	c131                	beqz	a0,800058f6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	d9a080e7          	jalr	-614(ra) # 8000364e <ilock>
  if(ip->type != T_DIR){
    800058bc:	04449703          	lh	a4,68(s1)
    800058c0:	4785                	li	a5,1
    800058c2:	04f71063          	bne	a4,a5,80005902 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058c6:	8526                	mv	a0,s1
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	e48080e7          	jalr	-440(ra) # 80003710 <iunlock>
  iput(p->cwd);
    800058d0:	15093503          	ld	a0,336(s2)
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	f34080e7          	jalr	-204(ra) # 80003808 <iput>
  end_op();
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	7bc080e7          	jalr	1980(ra) # 80004098 <end_op>
  p->cwd = ip;
    800058e4:	14993823          	sd	s1,336(s2)
  return 0;
    800058e8:	4501                	li	a0,0
}
    800058ea:	60ea                	ld	ra,152(sp)
    800058ec:	644a                	ld	s0,144(sp)
    800058ee:	64aa                	ld	s1,136(sp)
    800058f0:	690a                	ld	s2,128(sp)
    800058f2:	610d                	addi	sp,sp,160
    800058f4:	8082                	ret
    end_op();
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	7a2080e7          	jalr	1954(ra) # 80004098 <end_op>
    return -1;
    800058fe:	557d                	li	a0,-1
    80005900:	b7ed                	j	800058ea <sys_chdir+0x7a>
    iunlockput(ip);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	fac080e7          	jalr	-84(ra) # 800038b0 <iunlockput>
    end_op();
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	78c080e7          	jalr	1932(ra) # 80004098 <end_op>
    return -1;
    80005914:	557d                	li	a0,-1
    80005916:	bfd1                	j	800058ea <sys_chdir+0x7a>

0000000080005918 <sys_exec>:

uint64
sys_exec(void)
{
    80005918:	7145                	addi	sp,sp,-464
    8000591a:	e786                	sd	ra,456(sp)
    8000591c:	e3a2                	sd	s0,448(sp)
    8000591e:	ff26                	sd	s1,440(sp)
    80005920:	fb4a                	sd	s2,432(sp)
    80005922:	f74e                	sd	s3,424(sp)
    80005924:	f352                	sd	s4,416(sp)
    80005926:	ef56                	sd	s5,408(sp)
    80005928:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000592a:	e3840593          	addi	a1,s0,-456
    8000592e:	4505                	li	a0,1
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	1b2080e7          	jalr	434(ra) # 80002ae2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005938:	08000613          	li	a2,128
    8000593c:	f4040593          	addi	a1,s0,-192
    80005940:	4501                	li	a0,0
    80005942:	ffffd097          	auipc	ra,0xffffd
    80005946:	1c0080e7          	jalr	448(ra) # 80002b02 <argstr>
    8000594a:	87aa                	mv	a5,a0
    return -1;
    8000594c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000594e:	0c07c363          	bltz	a5,80005a14 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005952:	10000613          	li	a2,256
    80005956:	4581                	li	a1,0
    80005958:	e4040513          	addi	a0,s0,-448
    8000595c:	ffffb097          	auipc	ra,0xffffb
    80005960:	376080e7          	jalr	886(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005964:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005968:	89a6                	mv	s3,s1
    8000596a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000596c:	02000a13          	li	s4,32
    80005970:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005974:	00391513          	slli	a0,s2,0x3
    80005978:	e3040593          	addi	a1,s0,-464
    8000597c:	e3843783          	ld	a5,-456(s0)
    80005980:	953e                	add	a0,a0,a5
    80005982:	ffffd097          	auipc	ra,0xffffd
    80005986:	0a2080e7          	jalr	162(ra) # 80002a24 <fetchaddr>
    8000598a:	02054a63          	bltz	a0,800059be <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000598e:	e3043783          	ld	a5,-464(s0)
    80005992:	c3b9                	beqz	a5,800059d8 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005994:	ffffb097          	auipc	ra,0xffffb
    80005998:	152080e7          	jalr	338(ra) # 80000ae6 <kalloc>
    8000599c:	85aa                	mv	a1,a0
    8000599e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059a2:	cd11                	beqz	a0,800059be <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059a4:	6605                	lui	a2,0x1
    800059a6:	e3043503          	ld	a0,-464(s0)
    800059aa:	ffffd097          	auipc	ra,0xffffd
    800059ae:	0cc080e7          	jalr	204(ra) # 80002a76 <fetchstr>
    800059b2:	00054663          	bltz	a0,800059be <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800059b6:	0905                	addi	s2,s2,1
    800059b8:	09a1                	addi	s3,s3,8
    800059ba:	fb491be3          	bne	s2,s4,80005970 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059be:	f4040913          	addi	s2,s0,-192
    800059c2:	6088                	ld	a0,0(s1)
    800059c4:	c539                	beqz	a0,80005a12 <sys_exec+0xfa>
    kfree(argv[i]);
    800059c6:	ffffb097          	auipc	ra,0xffffb
    800059ca:	022080e7          	jalr	34(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ce:	04a1                	addi	s1,s1,8
    800059d0:	ff2499e3          	bne	s1,s2,800059c2 <sys_exec+0xaa>
  return -1;
    800059d4:	557d                	li	a0,-1
    800059d6:	a83d                	j	80005a14 <sys_exec+0xfc>
      argv[i] = 0;
    800059d8:	0a8e                	slli	s5,s5,0x3
    800059da:	fc0a8793          	addi	a5,s5,-64
    800059de:	00878ab3          	add	s5,a5,s0
    800059e2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800059e6:	e4040593          	addi	a1,s0,-448
    800059ea:	f4040513          	addi	a0,s0,-192
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	16e080e7          	jalr	366(ra) # 80004b5c <exec>
    800059f6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059f8:	f4040993          	addi	s3,s0,-192
    800059fc:	6088                	ld	a0,0(s1)
    800059fe:	c901                	beqz	a0,80005a0e <sys_exec+0xf6>
    kfree(argv[i]);
    80005a00:	ffffb097          	auipc	ra,0xffffb
    80005a04:	fe8080e7          	jalr	-24(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a08:	04a1                	addi	s1,s1,8
    80005a0a:	ff3499e3          	bne	s1,s3,800059fc <sys_exec+0xe4>
  return ret;
    80005a0e:	854a                	mv	a0,s2
    80005a10:	a011                	j	80005a14 <sys_exec+0xfc>
  return -1;
    80005a12:	557d                	li	a0,-1
}
    80005a14:	60be                	ld	ra,456(sp)
    80005a16:	641e                	ld	s0,448(sp)
    80005a18:	74fa                	ld	s1,440(sp)
    80005a1a:	795a                	ld	s2,432(sp)
    80005a1c:	79ba                	ld	s3,424(sp)
    80005a1e:	7a1a                	ld	s4,416(sp)
    80005a20:	6afa                	ld	s5,408(sp)
    80005a22:	6179                	addi	sp,sp,464
    80005a24:	8082                	ret

0000000080005a26 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a26:	7139                	addi	sp,sp,-64
    80005a28:	fc06                	sd	ra,56(sp)
    80005a2a:	f822                	sd	s0,48(sp)
    80005a2c:	f426                	sd	s1,40(sp)
    80005a2e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a30:	ffffc097          	auipc	ra,0xffffc
    80005a34:	f7c080e7          	jalr	-132(ra) # 800019ac <myproc>
    80005a38:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a3a:	fd840593          	addi	a1,s0,-40
    80005a3e:	4501                	li	a0,0
    80005a40:	ffffd097          	auipc	ra,0xffffd
    80005a44:	0a2080e7          	jalr	162(ra) # 80002ae2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a48:	fc840593          	addi	a1,s0,-56
    80005a4c:	fd040513          	addi	a0,s0,-48
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	dc2080e7          	jalr	-574(ra) # 80004812 <pipealloc>
    return -1;
    80005a58:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a5a:	0c054463          	bltz	a0,80005b22 <sys_pipe+0xfc>
  fd0 = -1;
    80005a5e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a62:	fd043503          	ld	a0,-48(s0)
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	514080e7          	jalr	1300(ra) # 80004f7a <fdalloc>
    80005a6e:	fca42223          	sw	a0,-60(s0)
    80005a72:	08054b63          	bltz	a0,80005b08 <sys_pipe+0xe2>
    80005a76:	fc843503          	ld	a0,-56(s0)
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	500080e7          	jalr	1280(ra) # 80004f7a <fdalloc>
    80005a82:	fca42023          	sw	a0,-64(s0)
    80005a86:	06054863          	bltz	a0,80005af6 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a8a:	4691                	li	a3,4
    80005a8c:	fc440613          	addi	a2,s0,-60
    80005a90:	fd843583          	ld	a1,-40(s0)
    80005a94:	68a8                	ld	a0,80(s1)
    80005a96:	ffffc097          	auipc	ra,0xffffc
    80005a9a:	bd6080e7          	jalr	-1066(ra) # 8000166c <copyout>
    80005a9e:	02054063          	bltz	a0,80005abe <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005aa2:	4691                	li	a3,4
    80005aa4:	fc040613          	addi	a2,s0,-64
    80005aa8:	fd843583          	ld	a1,-40(s0)
    80005aac:	0591                	addi	a1,a1,4
    80005aae:	68a8                	ld	a0,80(s1)
    80005ab0:	ffffc097          	auipc	ra,0xffffc
    80005ab4:	bbc080e7          	jalr	-1092(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ab8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005aba:	06055463          	bgez	a0,80005b22 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005abe:	fc442783          	lw	a5,-60(s0)
    80005ac2:	07e9                	addi	a5,a5,26
    80005ac4:	078e                	slli	a5,a5,0x3
    80005ac6:	97a6                	add	a5,a5,s1
    80005ac8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005acc:	fc042783          	lw	a5,-64(s0)
    80005ad0:	07e9                	addi	a5,a5,26
    80005ad2:	078e                	slli	a5,a5,0x3
    80005ad4:	94be                	add	s1,s1,a5
    80005ad6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ada:	fd043503          	ld	a0,-48(s0)
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	a04080e7          	jalr	-1532(ra) # 800044e2 <fileclose>
    fileclose(wf);
    80005ae6:	fc843503          	ld	a0,-56(s0)
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	9f8080e7          	jalr	-1544(ra) # 800044e2 <fileclose>
    return -1;
    80005af2:	57fd                	li	a5,-1
    80005af4:	a03d                	j	80005b22 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005af6:	fc442783          	lw	a5,-60(s0)
    80005afa:	0007c763          	bltz	a5,80005b08 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005afe:	07e9                	addi	a5,a5,26
    80005b00:	078e                	slli	a5,a5,0x3
    80005b02:	97a6                	add	a5,a5,s1
    80005b04:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005b08:	fd043503          	ld	a0,-48(s0)
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	9d6080e7          	jalr	-1578(ra) # 800044e2 <fileclose>
    fileclose(wf);
    80005b14:	fc843503          	ld	a0,-56(s0)
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	9ca080e7          	jalr	-1590(ra) # 800044e2 <fileclose>
    return -1;
    80005b20:	57fd                	li	a5,-1
}
    80005b22:	853e                	mv	a0,a5
    80005b24:	70e2                	ld	ra,56(sp)
    80005b26:	7442                	ld	s0,48(sp)
    80005b28:	74a2                	ld	s1,40(sp)
    80005b2a:	6121                	addi	sp,sp,64
    80005b2c:	8082                	ret
	...

0000000080005b30 <kernelvec>:
    80005b30:	7111                	addi	sp,sp,-256
    80005b32:	e006                	sd	ra,0(sp)
    80005b34:	e40a                	sd	sp,8(sp)
    80005b36:	e80e                	sd	gp,16(sp)
    80005b38:	ec12                	sd	tp,24(sp)
    80005b3a:	f016                	sd	t0,32(sp)
    80005b3c:	f41a                	sd	t1,40(sp)
    80005b3e:	f81e                	sd	t2,48(sp)
    80005b40:	fc22                	sd	s0,56(sp)
    80005b42:	e0a6                	sd	s1,64(sp)
    80005b44:	e4aa                	sd	a0,72(sp)
    80005b46:	e8ae                	sd	a1,80(sp)
    80005b48:	ecb2                	sd	a2,88(sp)
    80005b4a:	f0b6                	sd	a3,96(sp)
    80005b4c:	f4ba                	sd	a4,104(sp)
    80005b4e:	f8be                	sd	a5,112(sp)
    80005b50:	fcc2                	sd	a6,120(sp)
    80005b52:	e146                	sd	a7,128(sp)
    80005b54:	e54a                	sd	s2,136(sp)
    80005b56:	e94e                	sd	s3,144(sp)
    80005b58:	ed52                	sd	s4,152(sp)
    80005b5a:	f156                	sd	s5,160(sp)
    80005b5c:	f55a                	sd	s6,168(sp)
    80005b5e:	f95e                	sd	s7,176(sp)
    80005b60:	fd62                	sd	s8,184(sp)
    80005b62:	e1e6                	sd	s9,192(sp)
    80005b64:	e5ea                	sd	s10,200(sp)
    80005b66:	e9ee                	sd	s11,208(sp)
    80005b68:	edf2                	sd	t3,216(sp)
    80005b6a:	f1f6                	sd	t4,224(sp)
    80005b6c:	f5fa                	sd	t5,232(sp)
    80005b6e:	f9fe                	sd	t6,240(sp)
    80005b70:	d81fc0ef          	jal	ra,800028f0 <kerneltrap>
    80005b74:	6082                	ld	ra,0(sp)
    80005b76:	6122                	ld	sp,8(sp)
    80005b78:	61c2                	ld	gp,16(sp)
    80005b7a:	7282                	ld	t0,32(sp)
    80005b7c:	7322                	ld	t1,40(sp)
    80005b7e:	73c2                	ld	t2,48(sp)
    80005b80:	7462                	ld	s0,56(sp)
    80005b82:	6486                	ld	s1,64(sp)
    80005b84:	6526                	ld	a0,72(sp)
    80005b86:	65c6                	ld	a1,80(sp)
    80005b88:	6666                	ld	a2,88(sp)
    80005b8a:	7686                	ld	a3,96(sp)
    80005b8c:	7726                	ld	a4,104(sp)
    80005b8e:	77c6                	ld	a5,112(sp)
    80005b90:	7866                	ld	a6,120(sp)
    80005b92:	688a                	ld	a7,128(sp)
    80005b94:	692a                	ld	s2,136(sp)
    80005b96:	69ca                	ld	s3,144(sp)
    80005b98:	6a6a                	ld	s4,152(sp)
    80005b9a:	7a8a                	ld	s5,160(sp)
    80005b9c:	7b2a                	ld	s6,168(sp)
    80005b9e:	7bca                	ld	s7,176(sp)
    80005ba0:	7c6a                	ld	s8,184(sp)
    80005ba2:	6c8e                	ld	s9,192(sp)
    80005ba4:	6d2e                	ld	s10,200(sp)
    80005ba6:	6dce                	ld	s11,208(sp)
    80005ba8:	6e6e                	ld	t3,216(sp)
    80005baa:	7e8e                	ld	t4,224(sp)
    80005bac:	7f2e                	ld	t5,232(sp)
    80005bae:	7fce                	ld	t6,240(sp)
    80005bb0:	6111                	addi	sp,sp,256
    80005bb2:	10200073          	sret
    80005bb6:	00000013          	nop
    80005bba:	00000013          	nop
    80005bbe:	0001                	nop

0000000080005bc0 <timervec>:
    80005bc0:	34051573          	csrrw	a0,mscratch,a0
    80005bc4:	e10c                	sd	a1,0(a0)
    80005bc6:	e510                	sd	a2,8(a0)
    80005bc8:	e914                	sd	a3,16(a0)
    80005bca:	6d0c                	ld	a1,24(a0)
    80005bcc:	7110                	ld	a2,32(a0)
    80005bce:	6194                	ld	a3,0(a1)
    80005bd0:	96b2                	add	a3,a3,a2
    80005bd2:	e194                	sd	a3,0(a1)
    80005bd4:	4589                	li	a1,2
    80005bd6:	14459073          	csrw	sip,a1
    80005bda:	6914                	ld	a3,16(a0)
    80005bdc:	6510                	ld	a2,8(a0)
    80005bde:	610c                	ld	a1,0(a0)
    80005be0:	34051573          	csrrw	a0,mscratch,a0
    80005be4:	30200073          	mret
	...

0000000080005bea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bea:	1141                	addi	sp,sp,-16
    80005bec:	e422                	sd	s0,8(sp)
    80005bee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005bf0:	0c0007b7          	lui	a5,0xc000
    80005bf4:	4705                	li	a4,1
    80005bf6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005bf8:	c3d8                	sw	a4,4(a5)
}
    80005bfa:	6422                	ld	s0,8(sp)
    80005bfc:	0141                	addi	sp,sp,16
    80005bfe:	8082                	ret

0000000080005c00 <plicinithart>:

void
plicinithart(void)
{
    80005c00:	1141                	addi	sp,sp,-16
    80005c02:	e406                	sd	ra,8(sp)
    80005c04:	e022                	sd	s0,0(sp)
    80005c06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c08:	ffffc097          	auipc	ra,0xffffc
    80005c0c:	d78080e7          	jalr	-648(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c10:	0085171b          	slliw	a4,a0,0x8
    80005c14:	0c0027b7          	lui	a5,0xc002
    80005c18:	97ba                	add	a5,a5,a4
    80005c1a:	40200713          	li	a4,1026
    80005c1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c22:	00d5151b          	slliw	a0,a0,0xd
    80005c26:	0c2017b7          	lui	a5,0xc201
    80005c2a:	97aa                	add	a5,a5,a0
    80005c2c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c30:	60a2                	ld	ra,8(sp)
    80005c32:	6402                	ld	s0,0(sp)
    80005c34:	0141                	addi	sp,sp,16
    80005c36:	8082                	ret

0000000080005c38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c38:	1141                	addi	sp,sp,-16
    80005c3a:	e406                	sd	ra,8(sp)
    80005c3c:	e022                	sd	s0,0(sp)
    80005c3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c40:	ffffc097          	auipc	ra,0xffffc
    80005c44:	d40080e7          	jalr	-704(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c48:	00d5151b          	slliw	a0,a0,0xd
    80005c4c:	0c2017b7          	lui	a5,0xc201
    80005c50:	97aa                	add	a5,a5,a0
  return irq;
}
    80005c52:	43c8                	lw	a0,4(a5)
    80005c54:	60a2                	ld	ra,8(sp)
    80005c56:	6402                	ld	s0,0(sp)
    80005c58:	0141                	addi	sp,sp,16
    80005c5a:	8082                	ret

0000000080005c5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c5c:	1101                	addi	sp,sp,-32
    80005c5e:	ec06                	sd	ra,24(sp)
    80005c60:	e822                	sd	s0,16(sp)
    80005c62:	e426                	sd	s1,8(sp)
    80005c64:	1000                	addi	s0,sp,32
    80005c66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c68:	ffffc097          	auipc	ra,0xffffc
    80005c6c:	d18080e7          	jalr	-744(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c70:	00d5151b          	slliw	a0,a0,0xd
    80005c74:	0c2017b7          	lui	a5,0xc201
    80005c78:	97aa                	add	a5,a5,a0
    80005c7a:	c3c4                	sw	s1,4(a5)
}
    80005c7c:	60e2                	ld	ra,24(sp)
    80005c7e:	6442                	ld	s0,16(sp)
    80005c80:	64a2                	ld	s1,8(sp)
    80005c82:	6105                	addi	sp,sp,32
    80005c84:	8082                	ret

0000000080005c86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c86:	1141                	addi	sp,sp,-16
    80005c88:	e406                	sd	ra,8(sp)
    80005c8a:	e022                	sd	s0,0(sp)
    80005c8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c8e:	479d                	li	a5,7
    80005c90:	04a7cc63          	blt	a5,a0,80005ce8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005c94:	0001c797          	auipc	a5,0x1c
    80005c98:	fac78793          	addi	a5,a5,-84 # 80021c40 <disk>
    80005c9c:	97aa                	add	a5,a5,a0
    80005c9e:	0187c783          	lbu	a5,24(a5)
    80005ca2:	ebb9                	bnez	a5,80005cf8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ca4:	00451693          	slli	a3,a0,0x4
    80005ca8:	0001c797          	auipc	a5,0x1c
    80005cac:	f9878793          	addi	a5,a5,-104 # 80021c40 <disk>
    80005cb0:	6398                	ld	a4,0(a5)
    80005cb2:	9736                	add	a4,a4,a3
    80005cb4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005cb8:	6398                	ld	a4,0(a5)
    80005cba:	9736                	add	a4,a4,a3
    80005cbc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005cc0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005cc4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005cc8:	97aa                	add	a5,a5,a0
    80005cca:	4705                	li	a4,1
    80005ccc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005cd0:	0001c517          	auipc	a0,0x1c
    80005cd4:	f8850513          	addi	a0,a0,-120 # 80021c58 <disk+0x18>
    80005cd8:	ffffc097          	auipc	ra,0xffffc
    80005cdc:	3e0080e7          	jalr	992(ra) # 800020b8 <wakeup>
}
    80005ce0:	60a2                	ld	ra,8(sp)
    80005ce2:	6402                	ld	s0,0(sp)
    80005ce4:	0141                	addi	sp,sp,16
    80005ce6:	8082                	ret
    panic("free_desc 1");
    80005ce8:	00003517          	auipc	a0,0x3
    80005cec:	a7850513          	addi	a0,a0,-1416 # 80008760 <syscalls+0x310>
    80005cf0:	ffffb097          	auipc	ra,0xffffb
    80005cf4:	850080e7          	jalr	-1968(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005cf8:	00003517          	auipc	a0,0x3
    80005cfc:	a7850513          	addi	a0,a0,-1416 # 80008770 <syscalls+0x320>
    80005d00:	ffffb097          	auipc	ra,0xffffb
    80005d04:	840080e7          	jalr	-1984(ra) # 80000540 <panic>

0000000080005d08 <virtio_disk_init>:
{
    80005d08:	1101                	addi	sp,sp,-32
    80005d0a:	ec06                	sd	ra,24(sp)
    80005d0c:	e822                	sd	s0,16(sp)
    80005d0e:	e426                	sd	s1,8(sp)
    80005d10:	e04a                	sd	s2,0(sp)
    80005d12:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d14:	00003597          	auipc	a1,0x3
    80005d18:	a6c58593          	addi	a1,a1,-1428 # 80008780 <syscalls+0x330>
    80005d1c:	0001c517          	auipc	a0,0x1c
    80005d20:	04c50513          	addi	a0,a0,76 # 80021d68 <disk+0x128>
    80005d24:	ffffb097          	auipc	ra,0xffffb
    80005d28:	e22080e7          	jalr	-478(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d2c:	100017b7          	lui	a5,0x10001
    80005d30:	4398                	lw	a4,0(a5)
    80005d32:	2701                	sext.w	a4,a4
    80005d34:	747277b7          	lui	a5,0x74727
    80005d38:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d3c:	14f71b63          	bne	a4,a5,80005e92 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d40:	100017b7          	lui	a5,0x10001
    80005d44:	43dc                	lw	a5,4(a5)
    80005d46:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d48:	4709                	li	a4,2
    80005d4a:	14e79463          	bne	a5,a4,80005e92 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d4e:	100017b7          	lui	a5,0x10001
    80005d52:	479c                	lw	a5,8(a5)
    80005d54:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d56:	12e79e63          	bne	a5,a4,80005e92 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d5a:	100017b7          	lui	a5,0x10001
    80005d5e:	47d8                	lw	a4,12(a5)
    80005d60:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d62:	554d47b7          	lui	a5,0x554d4
    80005d66:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d6a:	12f71463          	bne	a4,a5,80005e92 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d6e:	100017b7          	lui	a5,0x10001
    80005d72:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d76:	4705                	li	a4,1
    80005d78:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d7a:	470d                	li	a4,3
    80005d7c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d7e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d80:	c7ffe6b7          	lui	a3,0xc7ffe
    80005d84:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9df>
    80005d88:	8f75                	and	a4,a4,a3
    80005d8a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d8c:	472d                	li	a4,11
    80005d8e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005d90:	5bbc                	lw	a5,112(a5)
    80005d92:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d96:	8ba1                	andi	a5,a5,8
    80005d98:	10078563          	beqz	a5,80005ea2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d9c:	100017b7          	lui	a5,0x10001
    80005da0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005da4:	43fc                	lw	a5,68(a5)
    80005da6:	2781                	sext.w	a5,a5
    80005da8:	10079563          	bnez	a5,80005eb2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005dac:	100017b7          	lui	a5,0x10001
    80005db0:	5bdc                	lw	a5,52(a5)
    80005db2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005db4:	10078763          	beqz	a5,80005ec2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005db8:	471d                	li	a4,7
    80005dba:	10f77c63          	bgeu	a4,a5,80005ed2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005dbe:	ffffb097          	auipc	ra,0xffffb
    80005dc2:	d28080e7          	jalr	-728(ra) # 80000ae6 <kalloc>
    80005dc6:	0001c497          	auipc	s1,0x1c
    80005dca:	e7a48493          	addi	s1,s1,-390 # 80021c40 <disk>
    80005dce:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005dd0:	ffffb097          	auipc	ra,0xffffb
    80005dd4:	d16080e7          	jalr	-746(ra) # 80000ae6 <kalloc>
    80005dd8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005dda:	ffffb097          	auipc	ra,0xffffb
    80005dde:	d0c080e7          	jalr	-756(ra) # 80000ae6 <kalloc>
    80005de2:	87aa                	mv	a5,a0
    80005de4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005de6:	6088                	ld	a0,0(s1)
    80005de8:	cd6d                	beqz	a0,80005ee2 <virtio_disk_init+0x1da>
    80005dea:	0001c717          	auipc	a4,0x1c
    80005dee:	e5e73703          	ld	a4,-418(a4) # 80021c48 <disk+0x8>
    80005df2:	cb65                	beqz	a4,80005ee2 <virtio_disk_init+0x1da>
    80005df4:	c7fd                	beqz	a5,80005ee2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005df6:	6605                	lui	a2,0x1
    80005df8:	4581                	li	a1,0
    80005dfa:	ffffb097          	auipc	ra,0xffffb
    80005dfe:	ed8080e7          	jalr	-296(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e02:	0001c497          	auipc	s1,0x1c
    80005e06:	e3e48493          	addi	s1,s1,-450 # 80021c40 <disk>
    80005e0a:	6605                	lui	a2,0x1
    80005e0c:	4581                	li	a1,0
    80005e0e:	6488                	ld	a0,8(s1)
    80005e10:	ffffb097          	auipc	ra,0xffffb
    80005e14:	ec2080e7          	jalr	-318(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005e18:	6605                	lui	a2,0x1
    80005e1a:	4581                	li	a1,0
    80005e1c:	6888                	ld	a0,16(s1)
    80005e1e:	ffffb097          	auipc	ra,0xffffb
    80005e22:	eb4080e7          	jalr	-332(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e26:	100017b7          	lui	a5,0x10001
    80005e2a:	4721                	li	a4,8
    80005e2c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e2e:	4098                	lw	a4,0(s1)
    80005e30:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e34:	40d8                	lw	a4,4(s1)
    80005e36:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e3a:	6498                	ld	a4,8(s1)
    80005e3c:	0007069b          	sext.w	a3,a4
    80005e40:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e44:	9701                	srai	a4,a4,0x20
    80005e46:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e4a:	6898                	ld	a4,16(s1)
    80005e4c:	0007069b          	sext.w	a3,a4
    80005e50:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e54:	9701                	srai	a4,a4,0x20
    80005e56:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e5a:	4705                	li	a4,1
    80005e5c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005e5e:	00e48c23          	sb	a4,24(s1)
    80005e62:	00e48ca3          	sb	a4,25(s1)
    80005e66:	00e48d23          	sb	a4,26(s1)
    80005e6a:	00e48da3          	sb	a4,27(s1)
    80005e6e:	00e48e23          	sb	a4,28(s1)
    80005e72:	00e48ea3          	sb	a4,29(s1)
    80005e76:	00e48f23          	sb	a4,30(s1)
    80005e7a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005e7e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e82:	0727a823          	sw	s2,112(a5)
}
    80005e86:	60e2                	ld	ra,24(sp)
    80005e88:	6442                	ld	s0,16(sp)
    80005e8a:	64a2                	ld	s1,8(sp)
    80005e8c:	6902                	ld	s2,0(sp)
    80005e8e:	6105                	addi	sp,sp,32
    80005e90:	8082                	ret
    panic("could not find virtio disk");
    80005e92:	00003517          	auipc	a0,0x3
    80005e96:	8fe50513          	addi	a0,a0,-1794 # 80008790 <syscalls+0x340>
    80005e9a:	ffffa097          	auipc	ra,0xffffa
    80005e9e:	6a6080e7          	jalr	1702(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ea2:	00003517          	auipc	a0,0x3
    80005ea6:	90e50513          	addi	a0,a0,-1778 # 800087b0 <syscalls+0x360>
    80005eaa:	ffffa097          	auipc	ra,0xffffa
    80005eae:	696080e7          	jalr	1686(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80005eb2:	00003517          	auipc	a0,0x3
    80005eb6:	91e50513          	addi	a0,a0,-1762 # 800087d0 <syscalls+0x380>
    80005eba:	ffffa097          	auipc	ra,0xffffa
    80005ebe:	686080e7          	jalr	1670(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80005ec2:	00003517          	auipc	a0,0x3
    80005ec6:	92e50513          	addi	a0,a0,-1746 # 800087f0 <syscalls+0x3a0>
    80005eca:	ffffa097          	auipc	ra,0xffffa
    80005ece:	676080e7          	jalr	1654(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80005ed2:	00003517          	auipc	a0,0x3
    80005ed6:	93e50513          	addi	a0,a0,-1730 # 80008810 <syscalls+0x3c0>
    80005eda:	ffffa097          	auipc	ra,0xffffa
    80005ede:	666080e7          	jalr	1638(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80005ee2:	00003517          	auipc	a0,0x3
    80005ee6:	94e50513          	addi	a0,a0,-1714 # 80008830 <syscalls+0x3e0>
    80005eea:	ffffa097          	auipc	ra,0xffffa
    80005eee:	656080e7          	jalr	1622(ra) # 80000540 <panic>

0000000080005ef2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ef2:	7119                	addi	sp,sp,-128
    80005ef4:	fc86                	sd	ra,120(sp)
    80005ef6:	f8a2                	sd	s0,112(sp)
    80005ef8:	f4a6                	sd	s1,104(sp)
    80005efa:	f0ca                	sd	s2,96(sp)
    80005efc:	ecce                	sd	s3,88(sp)
    80005efe:	e8d2                	sd	s4,80(sp)
    80005f00:	e4d6                	sd	s5,72(sp)
    80005f02:	e0da                	sd	s6,64(sp)
    80005f04:	fc5e                	sd	s7,56(sp)
    80005f06:	f862                	sd	s8,48(sp)
    80005f08:	f466                	sd	s9,40(sp)
    80005f0a:	f06a                	sd	s10,32(sp)
    80005f0c:	ec6e                	sd	s11,24(sp)
    80005f0e:	0100                	addi	s0,sp,128
    80005f10:	8aaa                	mv	s5,a0
    80005f12:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f14:	00c52d03          	lw	s10,12(a0)
    80005f18:	001d1d1b          	slliw	s10,s10,0x1
    80005f1c:	1d02                	slli	s10,s10,0x20
    80005f1e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005f22:	0001c517          	auipc	a0,0x1c
    80005f26:	e4650513          	addi	a0,a0,-442 # 80021d68 <disk+0x128>
    80005f2a:	ffffb097          	auipc	ra,0xffffb
    80005f2e:	cac080e7          	jalr	-852(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005f32:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f34:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f36:	0001cb97          	auipc	s7,0x1c
    80005f3a:	d0ab8b93          	addi	s7,s7,-758 # 80021c40 <disk>
  for(int i = 0; i < 3; i++){
    80005f3e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f40:	0001cc97          	auipc	s9,0x1c
    80005f44:	e28c8c93          	addi	s9,s9,-472 # 80021d68 <disk+0x128>
    80005f48:	a08d                	j	80005faa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005f4a:	00fb8733          	add	a4,s7,a5
    80005f4e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f52:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f54:	0207c563          	bltz	a5,80005f7e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005f58:	2905                	addiw	s2,s2,1
    80005f5a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005f5c:	05690c63          	beq	s2,s6,80005fb4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005f60:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f62:	0001c717          	auipc	a4,0x1c
    80005f66:	cde70713          	addi	a4,a4,-802 # 80021c40 <disk>
    80005f6a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005f6c:	01874683          	lbu	a3,24(a4)
    80005f70:	fee9                	bnez	a3,80005f4a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005f72:	2785                	addiw	a5,a5,1
    80005f74:	0705                	addi	a4,a4,1
    80005f76:	fe979be3          	bne	a5,s1,80005f6c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005f7a:	57fd                	li	a5,-1
    80005f7c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005f7e:	01205d63          	blez	s2,80005f98 <virtio_disk_rw+0xa6>
    80005f82:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005f84:	000a2503          	lw	a0,0(s4)
    80005f88:	00000097          	auipc	ra,0x0
    80005f8c:	cfe080e7          	jalr	-770(ra) # 80005c86 <free_desc>
      for(int j = 0; j < i; j++)
    80005f90:	2d85                	addiw	s11,s11,1
    80005f92:	0a11                	addi	s4,s4,4
    80005f94:	ff2d98e3          	bne	s11,s2,80005f84 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f98:	85e6                	mv	a1,s9
    80005f9a:	0001c517          	auipc	a0,0x1c
    80005f9e:	cbe50513          	addi	a0,a0,-834 # 80021c58 <disk+0x18>
    80005fa2:	ffffc097          	auipc	ra,0xffffc
    80005fa6:	0b2080e7          	jalr	178(ra) # 80002054 <sleep>
  for(int i = 0; i < 3; i++){
    80005faa:	f8040a13          	addi	s4,s0,-128
{
    80005fae:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005fb0:	894e                	mv	s2,s3
    80005fb2:	b77d                	j	80005f60 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fb4:	f8042503          	lw	a0,-128(s0)
    80005fb8:	00a50713          	addi	a4,a0,10
    80005fbc:	0712                	slli	a4,a4,0x4

  if(write)
    80005fbe:	0001c797          	auipc	a5,0x1c
    80005fc2:	c8278793          	addi	a5,a5,-894 # 80021c40 <disk>
    80005fc6:	00e786b3          	add	a3,a5,a4
    80005fca:	01803633          	snez	a2,s8
    80005fce:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005fd0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005fd4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fd8:	f6070613          	addi	a2,a4,-160
    80005fdc:	6394                	ld	a3,0(a5)
    80005fde:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fe0:	00870593          	addi	a1,a4,8
    80005fe4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fe6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005fe8:	0007b803          	ld	a6,0(a5)
    80005fec:	9642                	add	a2,a2,a6
    80005fee:	46c1                	li	a3,16
    80005ff0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ff2:	4585                	li	a1,1
    80005ff4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005ff8:	f8442683          	lw	a3,-124(s0)
    80005ffc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006000:	0692                	slli	a3,a3,0x4
    80006002:	9836                	add	a6,a6,a3
    80006004:	058a8613          	addi	a2,s5,88
    80006008:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000600c:	0007b803          	ld	a6,0(a5)
    80006010:	96c2                	add	a3,a3,a6
    80006012:	40000613          	li	a2,1024
    80006016:	c690                	sw	a2,8(a3)
  if(write)
    80006018:	001c3613          	seqz	a2,s8
    8000601c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006020:	00166613          	ori	a2,a2,1
    80006024:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006028:	f8842603          	lw	a2,-120(s0)
    8000602c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006030:	00250693          	addi	a3,a0,2
    80006034:	0692                	slli	a3,a3,0x4
    80006036:	96be                	add	a3,a3,a5
    80006038:	58fd                	li	a7,-1
    8000603a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000603e:	0612                	slli	a2,a2,0x4
    80006040:	9832                	add	a6,a6,a2
    80006042:	f9070713          	addi	a4,a4,-112
    80006046:	973e                	add	a4,a4,a5
    80006048:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000604c:	6398                	ld	a4,0(a5)
    8000604e:	9732                	add	a4,a4,a2
    80006050:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006052:	4609                	li	a2,2
    80006054:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006058:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000605c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006060:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006064:	6794                	ld	a3,8(a5)
    80006066:	0026d703          	lhu	a4,2(a3)
    8000606a:	8b1d                	andi	a4,a4,7
    8000606c:	0706                	slli	a4,a4,0x1
    8000606e:	96ba                	add	a3,a3,a4
    80006070:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006074:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006078:	6798                	ld	a4,8(a5)
    8000607a:	00275783          	lhu	a5,2(a4)
    8000607e:	2785                	addiw	a5,a5,1
    80006080:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006084:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006088:	100017b7          	lui	a5,0x10001
    8000608c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006090:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006094:	0001c917          	auipc	s2,0x1c
    80006098:	cd490913          	addi	s2,s2,-812 # 80021d68 <disk+0x128>
  while(b->disk == 1) {
    8000609c:	4485                	li	s1,1
    8000609e:	00b79c63          	bne	a5,a1,800060b6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800060a2:	85ca                	mv	a1,s2
    800060a4:	8556                	mv	a0,s5
    800060a6:	ffffc097          	auipc	ra,0xffffc
    800060aa:	fae080e7          	jalr	-82(ra) # 80002054 <sleep>
  while(b->disk == 1) {
    800060ae:	004aa783          	lw	a5,4(s5)
    800060b2:	fe9788e3          	beq	a5,s1,800060a2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800060b6:	f8042903          	lw	s2,-128(s0)
    800060ba:	00290713          	addi	a4,s2,2
    800060be:	0712                	slli	a4,a4,0x4
    800060c0:	0001c797          	auipc	a5,0x1c
    800060c4:	b8078793          	addi	a5,a5,-1152 # 80021c40 <disk>
    800060c8:	97ba                	add	a5,a5,a4
    800060ca:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800060ce:	0001c997          	auipc	s3,0x1c
    800060d2:	b7298993          	addi	s3,s3,-1166 # 80021c40 <disk>
    800060d6:	00491713          	slli	a4,s2,0x4
    800060da:	0009b783          	ld	a5,0(s3)
    800060de:	97ba                	add	a5,a5,a4
    800060e0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060e4:	854a                	mv	a0,s2
    800060e6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060ea:	00000097          	auipc	ra,0x0
    800060ee:	b9c080e7          	jalr	-1124(ra) # 80005c86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060f2:	8885                	andi	s1,s1,1
    800060f4:	f0ed                	bnez	s1,800060d6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060f6:	0001c517          	auipc	a0,0x1c
    800060fa:	c7250513          	addi	a0,a0,-910 # 80021d68 <disk+0x128>
    800060fe:	ffffb097          	auipc	ra,0xffffb
    80006102:	b8c080e7          	jalr	-1140(ra) # 80000c8a <release>
}
    80006106:	70e6                	ld	ra,120(sp)
    80006108:	7446                	ld	s0,112(sp)
    8000610a:	74a6                	ld	s1,104(sp)
    8000610c:	7906                	ld	s2,96(sp)
    8000610e:	69e6                	ld	s3,88(sp)
    80006110:	6a46                	ld	s4,80(sp)
    80006112:	6aa6                	ld	s5,72(sp)
    80006114:	6b06                	ld	s6,64(sp)
    80006116:	7be2                	ld	s7,56(sp)
    80006118:	7c42                	ld	s8,48(sp)
    8000611a:	7ca2                	ld	s9,40(sp)
    8000611c:	7d02                	ld	s10,32(sp)
    8000611e:	6de2                	ld	s11,24(sp)
    80006120:	6109                	addi	sp,sp,128
    80006122:	8082                	ret

0000000080006124 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006124:	1101                	addi	sp,sp,-32
    80006126:	ec06                	sd	ra,24(sp)
    80006128:	e822                	sd	s0,16(sp)
    8000612a:	e426                	sd	s1,8(sp)
    8000612c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000612e:	0001c497          	auipc	s1,0x1c
    80006132:	b1248493          	addi	s1,s1,-1262 # 80021c40 <disk>
    80006136:	0001c517          	auipc	a0,0x1c
    8000613a:	c3250513          	addi	a0,a0,-974 # 80021d68 <disk+0x128>
    8000613e:	ffffb097          	auipc	ra,0xffffb
    80006142:	a98080e7          	jalr	-1384(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006146:	10001737          	lui	a4,0x10001
    8000614a:	533c                	lw	a5,96(a4)
    8000614c:	8b8d                	andi	a5,a5,3
    8000614e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006150:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006154:	689c                	ld	a5,16(s1)
    80006156:	0204d703          	lhu	a4,32(s1)
    8000615a:	0027d783          	lhu	a5,2(a5)
    8000615e:	04f70863          	beq	a4,a5,800061ae <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006162:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006166:	6898                	ld	a4,16(s1)
    80006168:	0204d783          	lhu	a5,32(s1)
    8000616c:	8b9d                	andi	a5,a5,7
    8000616e:	078e                	slli	a5,a5,0x3
    80006170:	97ba                	add	a5,a5,a4
    80006172:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006174:	00278713          	addi	a4,a5,2
    80006178:	0712                	slli	a4,a4,0x4
    8000617a:	9726                	add	a4,a4,s1
    8000617c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006180:	e721                	bnez	a4,800061c8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006182:	0789                	addi	a5,a5,2
    80006184:	0792                	slli	a5,a5,0x4
    80006186:	97a6                	add	a5,a5,s1
    80006188:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000618a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000618e:	ffffc097          	auipc	ra,0xffffc
    80006192:	f2a080e7          	jalr	-214(ra) # 800020b8 <wakeup>

    disk.used_idx += 1;
    80006196:	0204d783          	lhu	a5,32(s1)
    8000619a:	2785                	addiw	a5,a5,1
    8000619c:	17c2                	slli	a5,a5,0x30
    8000619e:	93c1                	srli	a5,a5,0x30
    800061a0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800061a4:	6898                	ld	a4,16(s1)
    800061a6:	00275703          	lhu	a4,2(a4)
    800061aa:	faf71ce3          	bne	a4,a5,80006162 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800061ae:	0001c517          	auipc	a0,0x1c
    800061b2:	bba50513          	addi	a0,a0,-1094 # 80021d68 <disk+0x128>
    800061b6:	ffffb097          	auipc	ra,0xffffb
    800061ba:	ad4080e7          	jalr	-1324(ra) # 80000c8a <release>
}
    800061be:	60e2                	ld	ra,24(sp)
    800061c0:	6442                	ld	s0,16(sp)
    800061c2:	64a2                	ld	s1,8(sp)
    800061c4:	6105                	addi	sp,sp,32
    800061c6:	8082                	ret
      panic("virtio_disk_intr status");
    800061c8:	00002517          	auipc	a0,0x2
    800061cc:	68050513          	addi	a0,a0,1664 # 80008848 <syscalls+0x3f8>
    800061d0:	ffffa097          	auipc	ra,0xffffa
    800061d4:	370080e7          	jalr	880(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
