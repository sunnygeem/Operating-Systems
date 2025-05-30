
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	96010113          	addi	sp,sp,-1696 # 80007960 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd16f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	382020ef          	jal	8000247c <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00010517          	auipc	a0,0x10
    80000158:	80c50513          	addi	a0,a0,-2036 # 8000f960 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00010497          	auipc	s1,0x10
    80000164:	80048493          	addi	s1,s1,-2048 # 8000f960 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	89090913          	addi	s2,s2,-1904 # 8000f9f8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	08f010ef          	jal	80001a0e <myproc>
    80000184:	18a020ef          	jal	8000230e <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	697010ef          	jal	80002024 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	7c070713          	addi	a4,a4,1984 # 8000f960 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	260020ef          	jal	80002432 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	77650513          	addi	a0,a0,1910 # 8000f960 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	0000f717          	auipc	a4,0xf
    80000218:	7ef72223          	sw	a5,2020(a4) # 8000f9f8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	73650513          	addi	a0,a0,1846 # 8000f960 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	0000f517          	auipc	a0,0xf
    80000282:	6e250513          	addi	a0,a0,1762 # 8000f960 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	226020ef          	jal	800024c6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	6bc50513          	addi	a0,a0,1724 # 8000f960 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	69e70713          	addi	a4,a4,1694 # 8000f960 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	67878793          	addi	a5,a5,1656 # 8000f960 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	0000f797          	auipc	a5,0xf
    8000031a:	6e27a783          	lw	a5,1762(a5) # 8000f9f8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	63470713          	addi	a4,a4,1588 # 8000f960 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	62448493          	addi	s1,s1,1572 # 8000f960 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	5e270713          	addi	a4,a4,1506 # 8000f960 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	66f72623          	sw	a5,1644(a4) # 8000fa00 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	5ae78793          	addi	a5,a5,1454 # 8000f960 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	62c7a323          	sw	a2,1574(a5) # 8000f9fc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	61a50513          	addi	a0,a0,1562 # 8000f9f8 <cons+0x98>
    800003e6:	48b010ef          	jal	80002070 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	56450513          	addi	a0,a0,1380 # 8000f960 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	0ec78793          	addi	a5,a5,236 # 800204f8 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	36a60613          	addi	a2,a2,874 # 800077b0 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	5407a783          	lw	a5,1344(a5) # 8000fa20 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	4dc50513          	addi	a0,a0,1244 # 8000fa08 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	0c4b8b93          	addi	s7,s7,196 # 800077b0 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	28250513          	addi	a0,a0,642 # 8000fa08 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	2807a023          	sw	zero,640(a5) # 8000fa20 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	14f72e23          	sw	a5,348(a4) # 80007920 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	23048493          	addi	s1,s1,560 # 8000fa08 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	1e850513          	addi	a0,a0,488 # 8000fa28 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	0bc7a783          	lw	a5,188(a5) # 80007920 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	08e7b783          	ld	a5,142(a5) # 80007928 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	08e73703          	ld	a4,142(a4) # 80007930 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	160a8a93          	addi	s5,s5,352 # 8000fa28 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	05848493          	addi	s1,s1,88 # 80007928 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	05498993          	addi	s3,s3,84 # 80007930 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	772010ef          	jal	80002070 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	0dc50513          	addi	a0,a0,220 # 8000fa28 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	fc87a783          	lw	a5,-56(a5) # 80007920 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	fce73703          	ld	a4,-50(a4) # 80007930 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	fbe7b783          	ld	a5,-66(a5) # 80007928 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	0b298993          	addi	s3,s3,178 # 8000fa28 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	faa48493          	addi	s1,s1,-86 # 80007928 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	faa90913          	addi	s2,s2,-86 # 80007930 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	68e010ef          	jal	80002024 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	08048493          	addi	s1,s1,128 # 8000fa28 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f6e7ba23          	sd	a4,-140(a5) # 80007930 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	00848493          	addi	s1,s1,8 # 8000fa28 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00021797          	auipc	a5,0x21
    80000a5a:	c3a78793          	addi	a5,a5,-966 # 80021690 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	fee90913          	addi	s2,s2,-18 # 8000fa60 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	f6050513          	addi	a0,a0,-160 # 8000fa60 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00021517          	auipc	a0,0x21
    80000b14:	b8050513          	addi	a0,a0,-1152 # 80021690 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	f3248493          	addi	s1,s1,-206 # 8000fa60 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	f1e50513          	addi	a0,a0,-226 # 8000fa60 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	efa50513          	addi	a0,a0,-262 # 8000fa60 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	655000ef          	jal	800019f2 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	627000ef          	jal	800019f2 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	61f000ef          	jal	800019f2 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	60b000ef          	jal	800019f2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	5d7000ef          	jal	800019f2 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	5b3000ef          	jal	800019f2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd971>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	379000ef          	jal	800019e2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	aca70713          	addi	a4,a4,-1334 # 80007938 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	361000ef          	jal	800019e2 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	2b5010ef          	jal	8000294c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	27d040ef          	jal	80005918 <plicinithart>
  }

  scheduler();        
    80000ea0:	7eb000ef          	jal	80001e8a <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	300000ef          	jal	800011d4 <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	251000ef          	jal	8000192c <procinit>
    trapinit();      // trap vectors
    80000ee0:	249010ef          	jal	80002928 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	269010ef          	jal	8000294c <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	217040ef          	jal	800058fe <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	22d040ef          	jal	80005918 <plicinithart>
    binit();         // buffer cache
    80000ef0:	112020ef          	jal	80003002 <binit>
    iinit();         // inode table
    80000ef4:	704020ef          	jal	800035f8 <iinit>
    fileinit();      // file table
    80000ef8:	4b0030ef          	jal	800043a8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	30d040ef          	jal	80005a08 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	5a7000ef          	jal	80001ca6 <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	a2f72723          	sw	a5,-1490(a4) # 80007938 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00007797          	auipc	a5,0x7
    80000f22:	a227b783          	ld	a5,-1502(a5) # 80007940 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd967>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <kwalkaddr>:
  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <kwalkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	cd01                	beqz	a0,80001008 <kwalkaddr+0x32>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
    80000ff4:	0017f513          	andi	a0,a5,1
    80000ff8:	c501                	beqz	a0,80001000 <kwalkaddr+0x2a>
  pa = PTE2PA(*pte);
    80000ffa:	83a9                	srli	a5,a5,0xa
    80000ffc:	00c79513          	slli	a0,a5,0xc
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
    return 0;
    80001008:	4501                	li	a0,0
    8000100a:	bfdd                	j	80001000 <kwalkaddr+0x2a>

000000008000100c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000100c:	57fd                	li	a5,-1
    8000100e:	83e9                	srli	a5,a5,0x1a
    80001010:	00b7f463          	bgeu	a5,a1,80001018 <walkaddr+0xc>
    return 0;
    80001014:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001016:	8082                	ret
{
    80001018:	1141                	addi	sp,sp,-16
    8000101a:	e406                	sd	ra,8(sp)
    8000101c:	e022                	sd	s0,0(sp)
    8000101e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001020:	4601                	li	a2,0
    80001022:	f1bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001026:	c105                	beqz	a0,80001046 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80001028:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000102a:	0117f693          	andi	a3,a5,17
    8000102e:	4745                	li	a4,17
    return 0;
    80001030:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001032:	00e68663          	beq	a3,a4,8000103e <walkaddr+0x32>
}
    80001036:	60a2                	ld	ra,8(sp)
    80001038:	6402                	ld	s0,0(sp)
    8000103a:	0141                	addi	sp,sp,16
    8000103c:	8082                	ret
  pa = PTE2PA(*pte);
    8000103e:	83a9                	srli	a5,a5,0xa
    80001040:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001044:	bfcd                	j	80001036 <walkaddr+0x2a>
    return 0;
    80001046:	4501                	li	a0,0
    80001048:	b7fd                	j	80001036 <walkaddr+0x2a>

000000008000104a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000104a:	715d                	addi	sp,sp,-80
    8000104c:	e486                	sd	ra,72(sp)
    8000104e:	e0a2                	sd	s0,64(sp)
    80001050:	fc26                	sd	s1,56(sp)
    80001052:	f84a                	sd	s2,48(sp)
    80001054:	f44e                	sd	s3,40(sp)
    80001056:	f052                	sd	s4,32(sp)
    80001058:	ec56                	sd	s5,24(sp)
    8000105a:	e85a                	sd	s6,16(sp)
    8000105c:	e45e                	sd	s7,8(sp)
    8000105e:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001060:	03459793          	slli	a5,a1,0x34
    80001064:	e7a9                	bnez	a5,800010ae <mappages+0x64>
    80001066:	8aaa                	mv	s5,a0
    80001068:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000106a:	03461793          	slli	a5,a2,0x34
    8000106e:	e7b1                	bnez	a5,800010ba <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001070:	ca39                	beqz	a2,800010c6 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001072:	77fd                	lui	a5,0xfffff
    80001074:	963e                	add	a2,a2,a5
    80001076:	00b609b3          	add	s3,a2,a1
  a = va;
    8000107a:	892e                	mv	s2,a1
    8000107c:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001080:	6b85                	lui	s7,0x1
    80001082:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001086:	4605                	li	a2,1
    80001088:	85ca                	mv	a1,s2
    8000108a:	8556                	mv	a0,s5
    8000108c:	eb1ff0ef          	jal	80000f3c <walk>
    80001090:	c539                	beqz	a0,800010de <mappages+0x94>
    if(*pte & PTE_V)
    80001092:	611c                	ld	a5,0(a0)
    80001094:	8b85                	andi	a5,a5,1
    80001096:	ef95                	bnez	a5,800010d2 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001098:	80b1                	srli	s1,s1,0xc
    8000109a:	04aa                	slli	s1,s1,0xa
    8000109c:	0164e4b3          	or	s1,s1,s6
    800010a0:	0014e493          	ori	s1,s1,1
    800010a4:	e104                	sd	s1,0(a0)
    if(a == last)
    800010a6:	05390863          	beq	s2,s3,800010f6 <mappages+0xac>
    a += PGSIZE;
    800010aa:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ac:	bfd9                	j	80001082 <mappages+0x38>
    panic("mappages: va not aligned");
    800010ae:	00006517          	auipc	a0,0x6
    800010b2:	00a50513          	addi	a0,a0,10 # 800070b8 <etext+0xb8>
    800010b6:	edeff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	01e50513          	addi	a0,a0,30 # 800070d8 <etext+0xd8>
    800010c2:	ed2ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    800010c6:	00006517          	auipc	a0,0x6
    800010ca:	03250513          	addi	a0,a0,50 # 800070f8 <etext+0xf8>
    800010ce:	ec6ff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    800010d2:	00006517          	auipc	a0,0x6
    800010d6:	03650513          	addi	a0,a0,54 # 80007108 <etext+0x108>
    800010da:	ebaff0ef          	jal	80000794 <panic>
      return -1;
    800010de:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010e0:	60a6                	ld	ra,72(sp)
    800010e2:	6406                	ld	s0,64(sp)
    800010e4:	74e2                	ld	s1,56(sp)
    800010e6:	7942                	ld	s2,48(sp)
    800010e8:	79a2                	ld	s3,40(sp)
    800010ea:	7a02                	ld	s4,32(sp)
    800010ec:	6ae2                	ld	s5,24(sp)
    800010ee:	6b42                	ld	s6,16(sp)
    800010f0:	6ba2                	ld	s7,8(sp)
    800010f2:	6161                	addi	sp,sp,80
    800010f4:	8082                	ret
  return 0;
    800010f6:	4501                	li	a0,0
    800010f8:	b7e5                	j	800010e0 <mappages+0x96>

00000000800010fa <kvmmap>:
{
    800010fa:	1141                	addi	sp,sp,-16
    800010fc:	e406                	sd	ra,8(sp)
    800010fe:	e022                	sd	s0,0(sp)
    80001100:	0800                	addi	s0,sp,16
    80001102:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001104:	86b2                	mv	a3,a2
    80001106:	863e                	mv	a2,a5
    80001108:	f43ff0ef          	jal	8000104a <mappages>
    8000110c:	e509                	bnez	a0,80001116 <kvmmap+0x1c>
}
    8000110e:	60a2                	ld	ra,8(sp)
    80001110:	6402                	ld	s0,0(sp)
    80001112:	0141                	addi	sp,sp,16
    80001114:	8082                	ret
    panic("kvmmap");
    80001116:	00006517          	auipc	a0,0x6
    8000111a:	00250513          	addi	a0,a0,2 # 80007118 <etext+0x118>
    8000111e:	e76ff0ef          	jal	80000794 <panic>

0000000080001122 <kvmmake>:
{
    80001122:	1101                	addi	sp,sp,-32
    80001124:	ec06                	sd	ra,24(sp)
    80001126:	e822                	sd	s0,16(sp)
    80001128:	e426                	sd	s1,8(sp)
    8000112a:	e04a                	sd	s2,0(sp)
    8000112c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000112e:	9f7ff0ef          	jal	80000b24 <kalloc>
    80001132:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001134:	6605                	lui	a2,0x1
    80001136:	4581                	li	a1,0
    80001138:	b91ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000113c:	4719                	li	a4,6
    8000113e:	6685                	lui	a3,0x1
    80001140:	10000637          	lui	a2,0x10000
    80001144:	100005b7          	lui	a1,0x10000
    80001148:	8526                	mv	a0,s1
    8000114a:	fb1ff0ef          	jal	800010fa <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000114e:	4719                	li	a4,6
    80001150:	6685                	lui	a3,0x1
    80001152:	10001637          	lui	a2,0x10001
    80001156:	100015b7          	lui	a1,0x10001
    8000115a:	8526                	mv	a0,s1
    8000115c:	f9fff0ef          	jal	800010fa <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001160:	4719                	li	a4,6
    80001162:	040006b7          	lui	a3,0x4000
    80001166:	0c000637          	lui	a2,0xc000
    8000116a:	0c0005b7          	lui	a1,0xc000
    8000116e:	8526                	mv	a0,s1
    80001170:	f8bff0ef          	jal	800010fa <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001174:	00006917          	auipc	s2,0x6
    80001178:	e8c90913          	addi	s2,s2,-372 # 80007000 <etext>
    8000117c:	4729                	li	a4,10
    8000117e:	80006697          	auipc	a3,0x80006
    80001182:	e8268693          	addi	a3,a3,-382 # 7000 <_entry-0x7fff9000>
    80001186:	4605                	li	a2,1
    80001188:	067e                	slli	a2,a2,0x1f
    8000118a:	85b2                	mv	a1,a2
    8000118c:	8526                	mv	a0,s1
    8000118e:	f6dff0ef          	jal	800010fa <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001192:	46c5                	li	a3,17
    80001194:	06ee                	slli	a3,a3,0x1b
    80001196:	4719                	li	a4,6
    80001198:	412686b3          	sub	a3,a3,s2
    8000119c:	864a                	mv	a2,s2
    8000119e:	85ca                	mv	a1,s2
    800011a0:	8526                	mv	a0,s1
    800011a2:	f59ff0ef          	jal	800010fa <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011a6:	4729                	li	a4,10
    800011a8:	6685                	lui	a3,0x1
    800011aa:	00005617          	auipc	a2,0x5
    800011ae:	e5660613          	addi	a2,a2,-426 # 80006000 <_trampoline>
    800011b2:	040005b7          	lui	a1,0x4000
    800011b6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011b8:	05b2                	slli	a1,a1,0xc
    800011ba:	8526                	mv	a0,s1
    800011bc:	f3fff0ef          	jal	800010fa <kvmmap>
  proc_mapstacks(kpgtbl);
    800011c0:	8526                	mv	a0,s1
    800011c2:	6d2000ef          	jal	80001894 <proc_mapstacks>
}
    800011c6:	8526                	mv	a0,s1
    800011c8:	60e2                	ld	ra,24(sp)
    800011ca:	6442                	ld	s0,16(sp)
    800011cc:	64a2                	ld	s1,8(sp)
    800011ce:	6902                	ld	s2,0(sp)
    800011d0:	6105                	addi	sp,sp,32
    800011d2:	8082                	ret

00000000800011d4 <kvminit>:
{
    800011d4:	1141                	addi	sp,sp,-16
    800011d6:	e406                	sd	ra,8(sp)
    800011d8:	e022                	sd	s0,0(sp)
    800011da:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011dc:	f47ff0ef          	jal	80001122 <kvmmake>
    800011e0:	00006797          	auipc	a5,0x6
    800011e4:	76a7b023          	sd	a0,1888(a5) # 80007940 <kernel_pagetable>
}
    800011e8:	60a2                	ld	ra,8(sp)
    800011ea:	6402                	ld	s0,0(sp)
    800011ec:	0141                	addi	sp,sp,16
    800011ee:	8082                	ret

00000000800011f0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011f0:	715d                	addi	sp,sp,-80
    800011f2:	e486                	sd	ra,72(sp)
    800011f4:	e0a2                	sd	s0,64(sp)
    800011f6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011f8:	03459793          	slli	a5,a1,0x34
    800011fc:	e39d                	bnez	a5,80001222 <uvmunmap+0x32>
    800011fe:	f84a                	sd	s2,48(sp)
    80001200:	f44e                	sd	s3,40(sp)
    80001202:	f052                	sd	s4,32(sp)
    80001204:	ec56                	sd	s5,24(sp)
    80001206:	e85a                	sd	s6,16(sp)
    80001208:	e45e                	sd	s7,8(sp)
    8000120a:	8a2a                	mv	s4,a0
    8000120c:	892e                	mv	s2,a1
    8000120e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001210:	0632                	slli	a2,a2,0xc
    80001212:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001216:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001218:	6b05                	lui	s6,0x1
    8000121a:	0735ff63          	bgeu	a1,s3,80001298 <uvmunmap+0xa8>
    8000121e:	fc26                	sd	s1,56(sp)
    80001220:	a0a9                	j	8000126a <uvmunmap+0x7a>
    80001222:	fc26                	sd	s1,56(sp)
    80001224:	f84a                	sd	s2,48(sp)
    80001226:	f44e                	sd	s3,40(sp)
    80001228:	f052                	sd	s4,32(sp)
    8000122a:	ec56                	sd	s5,24(sp)
    8000122c:	e85a                	sd	s6,16(sp)
    8000122e:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001230:	00006517          	auipc	a0,0x6
    80001234:	ef050513          	addi	a0,a0,-272 # 80007120 <etext+0x120>
    80001238:	d5cff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    8000123c:	00006517          	auipc	a0,0x6
    80001240:	efc50513          	addi	a0,a0,-260 # 80007138 <etext+0x138>
    80001244:	d50ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001248:	00006517          	auipc	a0,0x6
    8000124c:	f0050513          	addi	a0,a0,-256 # 80007148 <etext+0x148>
    80001250:	d44ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    80001254:	00006517          	auipc	a0,0x6
    80001258:	f0c50513          	addi	a0,a0,-244 # 80007160 <etext+0x160>
    8000125c:	d38ff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001260:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001264:	995a                	add	s2,s2,s6
    80001266:	03397863          	bgeu	s2,s3,80001296 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000126a:	4601                	li	a2,0
    8000126c:	85ca                	mv	a1,s2
    8000126e:	8552                	mv	a0,s4
    80001270:	ccdff0ef          	jal	80000f3c <walk>
    80001274:	84aa                	mv	s1,a0
    80001276:	d179                	beqz	a0,8000123c <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001278:	6108                	ld	a0,0(a0)
    8000127a:	00157793          	andi	a5,a0,1
    8000127e:	d7e9                	beqz	a5,80001248 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001280:	3ff57793          	andi	a5,a0,1023
    80001284:	fd7788e3          	beq	a5,s7,80001254 <uvmunmap+0x64>
    if(do_free){
    80001288:	fc0a8ce3          	beqz	s5,80001260 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    8000128c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000128e:	0532                	slli	a0,a0,0xc
    80001290:	fb2ff0ef          	jal	80000a42 <kfree>
    80001294:	b7f1                	j	80001260 <uvmunmap+0x70>
    80001296:	74e2                	ld	s1,56(sp)
    80001298:	7942                	ld	s2,48(sp)
    8000129a:	79a2                	ld	s3,40(sp)
    8000129c:	7a02                	ld	s4,32(sp)
    8000129e:	6ae2                	ld	s5,24(sp)
    800012a0:	6b42                	ld	s6,16(sp)
    800012a2:	6ba2                	ld	s7,8(sp)
  }
}
    800012a4:	60a6                	ld	ra,72(sp)
    800012a6:	6406                	ld	s0,64(sp)
    800012a8:	6161                	addi	sp,sp,80
    800012aa:	8082                	ret

00000000800012ac <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800012ac:	1101                	addi	sp,sp,-32
    800012ae:	ec06                	sd	ra,24(sp)
    800012b0:	e822                	sd	s0,16(sp)
    800012b2:	e426                	sd	s1,8(sp)
    800012b4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012b6:	86fff0ef          	jal	80000b24 <kalloc>
    800012ba:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012bc:	c509                	beqz	a0,800012c6 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    800012c6:	8526                	mv	a0,s1
    800012c8:	60e2                	ld	ra,24(sp)
    800012ca:	6442                	ld	s0,16(sp)
    800012cc:	64a2                	ld	s1,8(sp)
    800012ce:	6105                	addi	sp,sp,32
    800012d0:	8082                	ret

00000000800012d2 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012d2:	7179                	addi	sp,sp,-48
    800012d4:	f406                	sd	ra,40(sp)
    800012d6:	f022                	sd	s0,32(sp)
    800012d8:	ec26                	sd	s1,24(sp)
    800012da:	e84a                	sd	s2,16(sp)
    800012dc:	e44e                	sd	s3,8(sp)
    800012de:	e052                	sd	s4,0(sp)
    800012e0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012e2:	6785                	lui	a5,0x1
    800012e4:	04f67063          	bgeu	a2,a5,80001324 <uvmfirst+0x52>
    800012e8:	8a2a                	mv	s4,a0
    800012ea:	89ae                	mv	s3,a1
    800012ec:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012ee:	837ff0ef          	jal	80000b24 <kalloc>
    800012f2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012f4:	6605                	lui	a2,0x1
    800012f6:	4581                	li	a1,0
    800012f8:	9d1ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012fc:	4779                	li	a4,30
    800012fe:	86ca                	mv	a3,s2
    80001300:	6605                	lui	a2,0x1
    80001302:	4581                	li	a1,0
    80001304:	8552                	mv	a0,s4
    80001306:	d45ff0ef          	jal	8000104a <mappages>
  memmove(mem, src, sz);
    8000130a:	8626                	mv	a2,s1
    8000130c:	85ce                	mv	a1,s3
    8000130e:	854a                	mv	a0,s2
    80001310:	a15ff0ef          	jal	80000d24 <memmove>
}
    80001314:	70a2                	ld	ra,40(sp)
    80001316:	7402                	ld	s0,32(sp)
    80001318:	64e2                	ld	s1,24(sp)
    8000131a:	6942                	ld	s2,16(sp)
    8000131c:	69a2                	ld	s3,8(sp)
    8000131e:	6a02                	ld	s4,0(sp)
    80001320:	6145                	addi	sp,sp,48
    80001322:	8082                	ret
    panic("uvmfirst: more than a page");
    80001324:	00006517          	auipc	a0,0x6
    80001328:	e5450513          	addi	a0,a0,-428 # 80007178 <etext+0x178>
    8000132c:	c68ff0ef          	jal	80000794 <panic>

0000000080001330 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001330:	1101                	addi	sp,sp,-32
    80001332:	ec06                	sd	ra,24(sp)
    80001334:	e822                	sd	s0,16(sp)
    80001336:	e426                	sd	s1,8(sp)
    80001338:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000133a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000133c:	00b67d63          	bgeu	a2,a1,80001356 <uvmdealloc+0x26>
    80001340:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001342:	6785                	lui	a5,0x1
    80001344:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001346:	00f60733          	add	a4,a2,a5
    8000134a:	76fd                	lui	a3,0xfffff
    8000134c:	8f75                	and	a4,a4,a3
    8000134e:	97ae                	add	a5,a5,a1
    80001350:	8ff5                	and	a5,a5,a3
    80001352:	00f76863          	bltu	a4,a5,80001362 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001356:	8526                	mv	a0,s1
    80001358:	60e2                	ld	ra,24(sp)
    8000135a:	6442                	ld	s0,16(sp)
    8000135c:	64a2                	ld	s1,8(sp)
    8000135e:	6105                	addi	sp,sp,32
    80001360:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001362:	8f99                	sub	a5,a5,a4
    80001364:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001366:	4685                	li	a3,1
    80001368:	0007861b          	sext.w	a2,a5
    8000136c:	85ba                	mv	a1,a4
    8000136e:	e83ff0ef          	jal	800011f0 <uvmunmap>
    80001372:	b7d5                	j	80001356 <uvmdealloc+0x26>

0000000080001374 <uvmalloc>:
  if(newsz < oldsz)
    80001374:	08b66f63          	bltu	a2,a1,80001412 <uvmalloc+0x9e>
{
    80001378:	7139                	addi	sp,sp,-64
    8000137a:	fc06                	sd	ra,56(sp)
    8000137c:	f822                	sd	s0,48(sp)
    8000137e:	ec4e                	sd	s3,24(sp)
    80001380:	e852                	sd	s4,16(sp)
    80001382:	e456                	sd	s5,8(sp)
    80001384:	0080                	addi	s0,sp,64
    80001386:	8aaa                	mv	s5,a0
    80001388:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000138a:	6785                	lui	a5,0x1
    8000138c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000138e:	95be                	add	a1,a1,a5
    80001390:	77fd                	lui	a5,0xfffff
    80001392:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001396:	08c9f063          	bgeu	s3,a2,80001416 <uvmalloc+0xa2>
    8000139a:	f426                	sd	s1,40(sp)
    8000139c:	f04a                	sd	s2,32(sp)
    8000139e:	e05a                	sd	s6,0(sp)
    800013a0:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013a2:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800013a6:	f7eff0ef          	jal	80000b24 <kalloc>
    800013aa:	84aa                	mv	s1,a0
    if(mem == 0){
    800013ac:	c515                	beqz	a0,800013d8 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800013ae:	6605                	lui	a2,0x1
    800013b0:	4581                	li	a1,0
    800013b2:	917ff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013b6:	875a                	mv	a4,s6
    800013b8:	86a6                	mv	a3,s1
    800013ba:	6605                	lui	a2,0x1
    800013bc:	85ca                	mv	a1,s2
    800013be:	8556                	mv	a0,s5
    800013c0:	c8bff0ef          	jal	8000104a <mappages>
    800013c4:	e915                	bnez	a0,800013f8 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013c6:	6785                	lui	a5,0x1
    800013c8:	993e                	add	s2,s2,a5
    800013ca:	fd496ee3          	bltu	s2,s4,800013a6 <uvmalloc+0x32>
  return newsz;
    800013ce:	8552                	mv	a0,s4
    800013d0:	74a2                	ld	s1,40(sp)
    800013d2:	7902                	ld	s2,32(sp)
    800013d4:	6b02                	ld	s6,0(sp)
    800013d6:	a811                	j	800013ea <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013d8:	864e                	mv	a2,s3
    800013da:	85ca                	mv	a1,s2
    800013dc:	8556                	mv	a0,s5
    800013de:	f53ff0ef          	jal	80001330 <uvmdealloc>
      return 0;
    800013e2:	4501                	li	a0,0
    800013e4:	74a2                	ld	s1,40(sp)
    800013e6:	7902                	ld	s2,32(sp)
    800013e8:	6b02                	ld	s6,0(sp)
}
    800013ea:	70e2                	ld	ra,56(sp)
    800013ec:	7442                	ld	s0,48(sp)
    800013ee:	69e2                	ld	s3,24(sp)
    800013f0:	6a42                	ld	s4,16(sp)
    800013f2:	6aa2                	ld	s5,8(sp)
    800013f4:	6121                	addi	sp,sp,64
    800013f6:	8082                	ret
      kfree(mem);
    800013f8:	8526                	mv	a0,s1
    800013fa:	e48ff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013fe:	864e                	mv	a2,s3
    80001400:	85ca                	mv	a1,s2
    80001402:	8556                	mv	a0,s5
    80001404:	f2dff0ef          	jal	80001330 <uvmdealloc>
      return 0;
    80001408:	4501                	li	a0,0
    8000140a:	74a2                	ld	s1,40(sp)
    8000140c:	7902                	ld	s2,32(sp)
    8000140e:	6b02                	ld	s6,0(sp)
    80001410:	bfe9                	j	800013ea <uvmalloc+0x76>
    return oldsz;
    80001412:	852e                	mv	a0,a1
}
    80001414:	8082                	ret
  return newsz;
    80001416:	8532                	mv	a0,a2
    80001418:	bfc9                	j	800013ea <uvmalloc+0x76>

000000008000141a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000141a:	7179                	addi	sp,sp,-48
    8000141c:	f406                	sd	ra,40(sp)
    8000141e:	f022                	sd	s0,32(sp)
    80001420:	ec26                	sd	s1,24(sp)
    80001422:	e84a                	sd	s2,16(sp)
    80001424:	e44e                	sd	s3,8(sp)
    80001426:	e052                	sd	s4,0(sp)
    80001428:	1800                	addi	s0,sp,48
    8000142a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000142c:	84aa                	mv	s1,a0
    8000142e:	6905                	lui	s2,0x1
    80001430:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001432:	4985                	li	s3,1
    80001434:	a819                	j	8000144a <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001436:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001438:	00c79513          	slli	a0,a5,0xc
    8000143c:	fdfff0ef          	jal	8000141a <freewalk>
      pagetable[i] = 0;
    80001440:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001444:	04a1                	addi	s1,s1,8
    80001446:	01248f63          	beq	s1,s2,80001464 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000144a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000144c:	00f7f713          	andi	a4,a5,15
    80001450:	ff3703e3          	beq	a4,s3,80001436 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001454:	8b85                	andi	a5,a5,1
    80001456:	d7fd                	beqz	a5,80001444 <freewalk+0x2a>
      panic("freewalk: leaf");
    80001458:	00006517          	auipc	a0,0x6
    8000145c:	d4050513          	addi	a0,a0,-704 # 80007198 <etext+0x198>
    80001460:	b34ff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    80001464:	8552                	mv	a0,s4
    80001466:	ddcff0ef          	jal	80000a42 <kfree>
}
    8000146a:	70a2                	ld	ra,40(sp)
    8000146c:	7402                	ld	s0,32(sp)
    8000146e:	64e2                	ld	s1,24(sp)
    80001470:	6942                	ld	s2,16(sp)
    80001472:	69a2                	ld	s3,8(sp)
    80001474:	6a02                	ld	s4,0(sp)
    80001476:	6145                	addi	sp,sp,48
    80001478:	8082                	ret

000000008000147a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000147a:	1101                	addi	sp,sp,-32
    8000147c:	ec06                	sd	ra,24(sp)
    8000147e:	e822                	sd	s0,16(sp)
    80001480:	e426                	sd	s1,8(sp)
    80001482:	1000                	addi	s0,sp,32
    80001484:	84aa                	mv	s1,a0
  if(sz > 0)
    80001486:	e989                	bnez	a1,80001498 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001488:	8526                	mv	a0,s1
    8000148a:	f91ff0ef          	jal	8000141a <freewalk>
}
    8000148e:	60e2                	ld	ra,24(sp)
    80001490:	6442                	ld	s0,16(sp)
    80001492:	64a2                	ld	s1,8(sp)
    80001494:	6105                	addi	sp,sp,32
    80001496:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001498:	6785                	lui	a5,0x1
    8000149a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000149c:	95be                	add	a1,a1,a5
    8000149e:	4685                	li	a3,1
    800014a0:	00c5d613          	srli	a2,a1,0xc
    800014a4:	4581                	li	a1,0
    800014a6:	d4bff0ef          	jal	800011f0 <uvmunmap>
    800014aa:	bff9                	j	80001488 <uvmfree+0xe>

00000000800014ac <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014ac:	c65d                	beqz	a2,8000155a <uvmcopy+0xae>
{
    800014ae:	715d                	addi	sp,sp,-80
    800014b0:	e486                	sd	ra,72(sp)
    800014b2:	e0a2                	sd	s0,64(sp)
    800014b4:	fc26                	sd	s1,56(sp)
    800014b6:	f84a                	sd	s2,48(sp)
    800014b8:	f44e                	sd	s3,40(sp)
    800014ba:	f052                	sd	s4,32(sp)
    800014bc:	ec56                	sd	s5,24(sp)
    800014be:	e85a                	sd	s6,16(sp)
    800014c0:	e45e                	sd	s7,8(sp)
    800014c2:	0880                	addi	s0,sp,80
    800014c4:	8b2a                	mv	s6,a0
    800014c6:	8aae                	mv	s5,a1
    800014c8:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014ca:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800014cc:	4601                	li	a2,0
    800014ce:	85ce                	mv	a1,s3
    800014d0:	855a                	mv	a0,s6
    800014d2:	a6bff0ef          	jal	80000f3c <walk>
    800014d6:	c121                	beqz	a0,80001516 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014d8:	6118                	ld	a4,0(a0)
    800014da:	00177793          	andi	a5,a4,1
    800014de:	c3b1                	beqz	a5,80001522 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014e0:	00a75593          	srli	a1,a4,0xa
    800014e4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014e8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014ec:	e38ff0ef          	jal	80000b24 <kalloc>
    800014f0:	892a                	mv	s2,a0
    800014f2:	c129                	beqz	a0,80001534 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014f4:	6605                	lui	a2,0x1
    800014f6:	85de                	mv	a1,s7
    800014f8:	82dff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014fc:	8726                	mv	a4,s1
    800014fe:	86ca                	mv	a3,s2
    80001500:	6605                	lui	a2,0x1
    80001502:	85ce                	mv	a1,s3
    80001504:	8556                	mv	a0,s5
    80001506:	b45ff0ef          	jal	8000104a <mappages>
    8000150a:	e115                	bnez	a0,8000152e <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    8000150c:	6785                	lui	a5,0x1
    8000150e:	99be                	add	s3,s3,a5
    80001510:	fb49eee3          	bltu	s3,s4,800014cc <uvmcopy+0x20>
    80001514:	a805                	j	80001544 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80001516:	00006517          	auipc	a0,0x6
    8000151a:	c9250513          	addi	a0,a0,-878 # 800071a8 <etext+0x1a8>
    8000151e:	a76ff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    80001522:	00006517          	auipc	a0,0x6
    80001526:	ca650513          	addi	a0,a0,-858 # 800071c8 <etext+0x1c8>
    8000152a:	a6aff0ef          	jal	80000794 <panic>
      kfree(mem);
    8000152e:	854a                	mv	a0,s2
    80001530:	d12ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001534:	4685                	li	a3,1
    80001536:	00c9d613          	srli	a2,s3,0xc
    8000153a:	4581                	li	a1,0
    8000153c:	8556                	mv	a0,s5
    8000153e:	cb3ff0ef          	jal	800011f0 <uvmunmap>
  return -1;
    80001542:	557d                	li	a0,-1
}
    80001544:	60a6                	ld	ra,72(sp)
    80001546:	6406                	ld	s0,64(sp)
    80001548:	74e2                	ld	s1,56(sp)
    8000154a:	7942                	ld	s2,48(sp)
    8000154c:	79a2                	ld	s3,40(sp)
    8000154e:	7a02                	ld	s4,32(sp)
    80001550:	6ae2                	ld	s5,24(sp)
    80001552:	6b42                	ld	s6,16(sp)
    80001554:	6ba2                	ld	s7,8(sp)
    80001556:	6161                	addi	sp,sp,80
    80001558:	8082                	ret
  return 0;
    8000155a:	4501                	li	a0,0
}
    8000155c:	8082                	ret

000000008000155e <uvmshare>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    8000155e:	c259                	beqz	a2,800015e4 <uvmshare+0x86>
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e84a                	sd	s2,16(sp)
    8000156a:	e44e                	sd	s3,8(sp)
    8000156c:	e052                	sd	s4,0(sp)
    8000156e:	1800                	addi	s0,sp,48
    80001570:	8a2a                	mv	s4,a0
    80001572:	89ae                	mv	s3,a1
    80001574:	8932                	mv	s2,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001576:	4481                	li	s1,0
    if((pte = walk(old, i, 0)) == 0)
    80001578:	4601                	li	a2,0
    8000157a:	85a6                	mv	a1,s1
    8000157c:	8552                	mv	a0,s4
    8000157e:	9bfff0ef          	jal	80000f3c <walk>
    80001582:	c50d                	beqz	a0,800015ac <uvmshare+0x4e>
      panic("uvmshare: pte should exist");
    if((*pte & PTE_V) == 0)
    80001584:	6118                	ld	a4,0(a0)
    80001586:	00177793          	andi	a5,a4,1
    8000158a:	c79d                	beqz	a5,800015b8 <uvmshare+0x5a>
      panic("uvmshare: page not present");
    
    // 기존 물리 주소 가져옴
    pa = PTE2PA(*pte);              
    8000158c:	00a75693          	srli	a3,a4,0xa
    flags = PTE_FLAGS(*pte);       

    // 기존 pa를 공유하도록 새 pagetable에 매핑 => memmove로 복사 X
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80001590:	3ff77713          	andi	a4,a4,1023
    80001594:	06b2                	slli	a3,a3,0xc
    80001596:	6605                	lui	a2,0x1
    80001598:	85a6                	mv	a1,s1
    8000159a:	854e                	mv	a0,s3
    8000159c:	aafff0ef          	jal	8000104a <mappages>
    800015a0:	e115                	bnez	a0,800015c4 <uvmshare+0x66>
  for(i = 0; i < sz; i += PGSIZE){
    800015a2:	6785                	lui	a5,0x1
    800015a4:	94be                	add	s1,s1,a5
    800015a6:	fd24e9e3          	bltu	s1,s2,80001578 <uvmshare+0x1a>
    800015aa:	a02d                	j	800015d4 <uvmshare+0x76>
      panic("uvmshare: pte should exist");
    800015ac:	00006517          	auipc	a0,0x6
    800015b0:	c3c50513          	addi	a0,a0,-964 # 800071e8 <etext+0x1e8>
    800015b4:	9e0ff0ef          	jal	80000794 <panic>
      panic("uvmshare: page not present");
    800015b8:	00006517          	auipc	a0,0x6
    800015bc:	c5050513          	addi	a0,a0,-944 # 80007208 <etext+0x208>
    800015c0:	9d4ff0ef          	jal	80000794 <panic>
    }
  }
  return 0;

 bad:
  uvmunmap(new, 0, i / PGSIZE, 0); // do_free = 0: pa 공유이므로 free 금지
    800015c4:	4681                	li	a3,0
    800015c6:	00c4d613          	srli	a2,s1,0xc
    800015ca:	4581                	li	a1,0
    800015cc:	854e                	mv	a0,s3
    800015ce:	c23ff0ef          	jal	800011f0 <uvmunmap>
  return -1;
    800015d2:	557d                	li	a0,-1
}
    800015d4:	70a2                	ld	ra,40(sp)
    800015d6:	7402                	ld	s0,32(sp)
    800015d8:	64e2                	ld	s1,24(sp)
    800015da:	6942                	ld	s2,16(sp)
    800015dc:	69a2                	ld	s3,8(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	6145                	addi	sp,sp,48
    800015e2:	8082                	ret
  return 0;
    800015e4:	4501                	li	a0,0
}
    800015e6:	8082                	ret

00000000800015e8 <uvmshare_region>:

int
uvmshare_region(pagetable_t src, pagetable_t dst, uint64 start, uint64 end, int perm)
{
    800015e8:	7139                	addi	sp,sp,-64
    800015ea:	fc06                	sd	ra,56(sp)
    800015ec:	f822                	sd	s0,48(sp)
    800015ee:	f426                	sd	s1,40(sp)
    800015f0:	f04a                	sd	s2,32(sp)
    800015f2:	ec4e                	sd	s3,24(sp)
    800015f4:	e852                	sd	s4,16(sp)
    800015f6:	e456                	sd	s5,8(sp)
    800015f8:	0080                	addi	s0,sp,64
    800015fa:	89aa                	mv	s3,a0
    800015fc:	8aae                	mv	s5,a1
    800015fe:	8936                	mv	s2,a3
    80001600:	8a3a                	mv	s4,a4
  for (uint64 a = PGROUNDUP(start); a < end; a += PGSIZE) {
    80001602:	6785                	lui	a5,0x1
    80001604:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001606:	963e                	add	a2,a2,a5
    80001608:	77fd                	lui	a5,0xfffff
    8000160a:	00f674b3          	and	s1,a2,a5
    8000160e:	02d4f663          	bgeu	s1,a3,8000163a <uvmshare_region+0x52>
    uint64 pa = walkaddr(src, a);
    80001612:	85a6                	mv	a1,s1
    80001614:	854e                	mv	a0,s3
    80001616:	9f7ff0ef          	jal	8000100c <walkaddr>
    8000161a:	86aa                	mv	a3,a0
    if(pa == 0)
    8000161c:	c10d                	beqz	a0,8000163e <uvmshare_region+0x56>
      return -1;
    if(mappages(dst, a, PGSIZE, pa, perm) < 0)
    8000161e:	8752                	mv	a4,s4
    80001620:	6605                	lui	a2,0x1
    80001622:	85a6                	mv	a1,s1
    80001624:	8556                	mv	a0,s5
    80001626:	a25ff0ef          	jal	8000104a <mappages>
    8000162a:	02054463          	bltz	a0,80001652 <uvmshare_region+0x6a>
  for (uint64 a = PGROUNDUP(start); a < end; a += PGSIZE) {
    8000162e:	6785                	lui	a5,0x1
    80001630:	94be                	add	s1,s1,a5
    80001632:	ff24e0e3          	bltu	s1,s2,80001612 <uvmshare_region+0x2a>
      return -1;
  }
  return 0;
    80001636:	4501                	li	a0,0
    80001638:	a021                	j	80001640 <uvmshare_region+0x58>
    8000163a:	4501                	li	a0,0
    8000163c:	a011                	j	80001640 <uvmshare_region+0x58>
      return -1;
    8000163e:	557d                	li	a0,-1
}
    80001640:	70e2                	ld	ra,56(sp)
    80001642:	7442                	ld	s0,48(sp)
    80001644:	74a2                	ld	s1,40(sp)
    80001646:	7902                	ld	s2,32(sp)
    80001648:	69e2                	ld	s3,24(sp)
    8000164a:	6a42                	ld	s4,16(sp)
    8000164c:	6aa2                	ld	s5,8(sp)
    8000164e:	6121                	addi	sp,sp,64
    80001650:	8082                	ret
      return -1;
    80001652:	557d                	li	a0,-1
    80001654:	b7f5                	j	80001640 <uvmshare_region+0x58>

0000000080001656 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001656:	1141                	addi	sp,sp,-16
    80001658:	e406                	sd	ra,8(sp)
    8000165a:	e022                	sd	s0,0(sp)
    8000165c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165e:	4601                	li	a2,0
    80001660:	8ddff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001664:	c901                	beqz	a0,80001674 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001666:	611c                	ld	a5,0(a0)
    80001668:	9bbd                	andi	a5,a5,-17
    8000166a:	e11c                	sd	a5,0(a0)
}
    8000166c:	60a2                	ld	ra,8(sp)
    8000166e:	6402                	ld	s0,0(sp)
    80001670:	0141                	addi	sp,sp,16
    80001672:	8082                	ret
    panic("uvmclear");
    80001674:	00006517          	auipc	a0,0x6
    80001678:	bb450513          	addi	a0,a0,-1100 # 80007228 <etext+0x228>
    8000167c:	918ff0ef          	jal	80000794 <panic>

0000000080001680 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001680:	cad1                	beqz	a3,80001714 <copyout+0x94>
{
    80001682:	711d                	addi	sp,sp,-96
    80001684:	ec86                	sd	ra,88(sp)
    80001686:	e8a2                	sd	s0,80(sp)
    80001688:	e4a6                	sd	s1,72(sp)
    8000168a:	fc4e                	sd	s3,56(sp)
    8000168c:	f456                	sd	s5,40(sp)
    8000168e:	f05a                	sd	s6,32(sp)
    80001690:	ec5e                	sd	s7,24(sp)
    80001692:	1080                	addi	s0,sp,96
    80001694:	8baa                	mv	s7,a0
    80001696:	8aae                	mv	s5,a1
    80001698:	8b32                	mv	s6,a2
    8000169a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000169c:	74fd                	lui	s1,0xfffff
    8000169e:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800016a0:	57fd                	li	a5,-1
    800016a2:	83e9                	srli	a5,a5,0x1a
    800016a4:	0697ea63          	bltu	a5,s1,80001718 <copyout+0x98>
    800016a8:	e0ca                	sd	s2,64(sp)
    800016aa:	f852                	sd	s4,48(sp)
    800016ac:	e862                	sd	s8,16(sp)
    800016ae:	e466                	sd	s9,8(sp)
    800016b0:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800016b2:	4cd5                	li	s9,21
    800016b4:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    800016b6:	8c3e                	mv	s8,a5
    800016b8:	a025                	j	800016e0 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    800016ba:	83a9                	srli	a5,a5,0xa
    800016bc:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016be:	409a8533          	sub	a0,s5,s1
    800016c2:	0009061b          	sext.w	a2,s2
    800016c6:	85da                	mv	a1,s6
    800016c8:	953e                	add	a0,a0,a5
    800016ca:	e5aff0ef          	jal	80000d24 <memmove>

    len -= n;
    800016ce:	412989b3          	sub	s3,s3,s2
    src += n;
    800016d2:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800016d4:	02098963          	beqz	s3,80001706 <copyout+0x86>
    if(va0 >= MAXVA)
    800016d8:	054c6263          	bltu	s8,s4,8000171c <copyout+0x9c>
    800016dc:	84d2                	mv	s1,s4
    800016de:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800016e0:	4601                	li	a2,0
    800016e2:	85a6                	mv	a1,s1
    800016e4:	855e                	mv	a0,s7
    800016e6:	857ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800016ea:	c121                	beqz	a0,8000172a <copyout+0xaa>
    800016ec:	611c                	ld	a5,0(a0)
    800016ee:	0157f713          	andi	a4,a5,21
    800016f2:	05971b63          	bne	a4,s9,80001748 <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800016f6:	01a48a33          	add	s4,s1,s10
    800016fa:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800016fe:	fb29fee3          	bgeu	s3,s2,800016ba <copyout+0x3a>
    80001702:	894e                	mv	s2,s3
    80001704:	bf5d                	j	800016ba <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    80001706:	4501                	li	a0,0
    80001708:	6906                	ld	s2,64(sp)
    8000170a:	7a42                	ld	s4,48(sp)
    8000170c:	6c42                	ld	s8,16(sp)
    8000170e:	6ca2                	ld	s9,8(sp)
    80001710:	6d02                	ld	s10,0(sp)
    80001712:	a015                	j	80001736 <copyout+0xb6>
    80001714:	4501                	li	a0,0
}
    80001716:	8082                	ret
      return -1;
    80001718:	557d                	li	a0,-1
    8000171a:	a831                	j	80001736 <copyout+0xb6>
    8000171c:	557d                	li	a0,-1
    8000171e:	6906                	ld	s2,64(sp)
    80001720:	7a42                	ld	s4,48(sp)
    80001722:	6c42                	ld	s8,16(sp)
    80001724:	6ca2                	ld	s9,8(sp)
    80001726:	6d02                	ld	s10,0(sp)
    80001728:	a039                	j	80001736 <copyout+0xb6>
      return -1;
    8000172a:	557d                	li	a0,-1
    8000172c:	6906                	ld	s2,64(sp)
    8000172e:	7a42                	ld	s4,48(sp)
    80001730:	6c42                	ld	s8,16(sp)
    80001732:	6ca2                	ld	s9,8(sp)
    80001734:	6d02                	ld	s10,0(sp)
}
    80001736:	60e6                	ld	ra,88(sp)
    80001738:	6446                	ld	s0,80(sp)
    8000173a:	64a6                	ld	s1,72(sp)
    8000173c:	79e2                	ld	s3,56(sp)
    8000173e:	7aa2                	ld	s5,40(sp)
    80001740:	7b02                	ld	s6,32(sp)
    80001742:	6be2                	ld	s7,24(sp)
    80001744:	6125                	addi	sp,sp,96
    80001746:	8082                	ret
      return -1;
    80001748:	557d                	li	a0,-1
    8000174a:	6906                	ld	s2,64(sp)
    8000174c:	7a42                	ld	s4,48(sp)
    8000174e:	6c42                	ld	s8,16(sp)
    80001750:	6ca2                	ld	s9,8(sp)
    80001752:	6d02                	ld	s10,0(sp)
    80001754:	b7cd                	j	80001736 <copyout+0xb6>

0000000080001756 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001756:	c6a5                	beqz	a3,800017be <copyin+0x68>
{
    80001758:	715d                	addi	sp,sp,-80
    8000175a:	e486                	sd	ra,72(sp)
    8000175c:	e0a2                	sd	s0,64(sp)
    8000175e:	fc26                	sd	s1,56(sp)
    80001760:	f84a                	sd	s2,48(sp)
    80001762:	f44e                	sd	s3,40(sp)
    80001764:	f052                	sd	s4,32(sp)
    80001766:	ec56                	sd	s5,24(sp)
    80001768:	e85a                	sd	s6,16(sp)
    8000176a:	e45e                	sd	s7,8(sp)
    8000176c:	e062                	sd	s8,0(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8b2a                	mv	s6,a0
    80001772:	8a2e                	mv	s4,a1
    80001774:	8c32                	mv	s8,a2
    80001776:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6a85                	lui	s5,0x1
    8000177c:	a00d                	j	8000179e <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000177e:	018505b3          	add	a1,a0,s8
    80001782:	0004861b          	sext.w	a2,s1
    80001786:	412585b3          	sub	a1,a1,s2
    8000178a:	8552                	mv	a0,s4
    8000178c:	d98ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001790:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001794:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001796:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000179a:	02098063          	beqz	s3,800017ba <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    8000179e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017a2:	85ca                	mv	a1,s2
    800017a4:	855a                	mv	a0,s6
    800017a6:	867ff0ef          	jal	8000100c <walkaddr>
    if(pa0 == 0)
    800017aa:	cd01                	beqz	a0,800017c2 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    800017ac:	418904b3          	sub	s1,s2,s8
    800017b0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017b2:	fc99f6e3          	bgeu	s3,s1,8000177e <copyin+0x28>
    800017b6:	84ce                	mv	s1,s3
    800017b8:	b7d9                	j	8000177e <copyin+0x28>
  }
  return 0;
    800017ba:	4501                	li	a0,0
    800017bc:	a021                	j	800017c4 <copyin+0x6e>
    800017be:	4501                	li	a0,0
}
    800017c0:	8082                	ret
      return -1;
    800017c2:	557d                	li	a0,-1
}
    800017c4:	60a6                	ld	ra,72(sp)
    800017c6:	6406                	ld	s0,64(sp)
    800017c8:	74e2                	ld	s1,56(sp)
    800017ca:	7942                	ld	s2,48(sp)
    800017cc:	79a2                	ld	s3,40(sp)
    800017ce:	7a02                	ld	s4,32(sp)
    800017d0:	6ae2                	ld	s5,24(sp)
    800017d2:	6b42                	ld	s6,16(sp)
    800017d4:	6ba2                	ld	s7,8(sp)
    800017d6:	6c02                	ld	s8,0(sp)
    800017d8:	6161                	addi	sp,sp,80
    800017da:	8082                	ret

00000000800017dc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017dc:	c6dd                	beqz	a3,8000188a <copyinstr+0xae>
{
    800017de:	715d                	addi	sp,sp,-80
    800017e0:	e486                	sd	ra,72(sp)
    800017e2:	e0a2                	sd	s0,64(sp)
    800017e4:	fc26                	sd	s1,56(sp)
    800017e6:	f84a                	sd	s2,48(sp)
    800017e8:	f44e                	sd	s3,40(sp)
    800017ea:	f052                	sd	s4,32(sp)
    800017ec:	ec56                	sd	s5,24(sp)
    800017ee:	e85a                	sd	s6,16(sp)
    800017f0:	e45e                	sd	s7,8(sp)
    800017f2:	0880                	addi	s0,sp,80
    800017f4:	8a2a                	mv	s4,a0
    800017f6:	8b2e                	mv	s6,a1
    800017f8:	8bb2                	mv	s7,a2
    800017fa:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800017fc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017fe:	6985                	lui	s3,0x1
    80001800:	a825                	j	80001838 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001802:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001806:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001808:	37fd                	addiw	a5,a5,-1
    8000180a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000180e:	60a6                	ld	ra,72(sp)
    80001810:	6406                	ld	s0,64(sp)
    80001812:	74e2                	ld	s1,56(sp)
    80001814:	7942                	ld	s2,48(sp)
    80001816:	79a2                	ld	s3,40(sp)
    80001818:	7a02                	ld	s4,32(sp)
    8000181a:	6ae2                	ld	s5,24(sp)
    8000181c:	6b42                	ld	s6,16(sp)
    8000181e:	6ba2                	ld	s7,8(sp)
    80001820:	6161                	addi	sp,sp,80
    80001822:	8082                	ret
    80001824:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001828:	9742                	add	a4,a4,a6
      --max;
    8000182a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000182e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001832:	04e58463          	beq	a1,a4,8000187a <copyinstr+0x9e>
{
    80001836:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001838:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000183c:	85a6                	mv	a1,s1
    8000183e:	8552                	mv	a0,s4
    80001840:	fccff0ef          	jal	8000100c <walkaddr>
    if(pa0 == 0)
    80001844:	cd0d                	beqz	a0,8000187e <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001846:	417486b3          	sub	a3,s1,s7
    8000184a:	96ce                	add	a3,a3,s3
    if(n > max)
    8000184c:	00d97363          	bgeu	s2,a3,80001852 <copyinstr+0x76>
    80001850:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001852:	955e                	add	a0,a0,s7
    80001854:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001856:	c695                	beqz	a3,80001882 <copyinstr+0xa6>
    80001858:	87da                	mv	a5,s6
    8000185a:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000185c:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001860:	96da                	add	a3,a3,s6
    80001862:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001864:	00f60733          	add	a4,a2,a5
    80001868:	00074703          	lbu	a4,0(a4)
    8000186c:	db59                	beqz	a4,80001802 <copyinstr+0x26>
        *dst = *p;
    8000186e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001872:	0785                	addi	a5,a5,1
    while(n > 0){
    80001874:	fed797e3          	bne	a5,a3,80001862 <copyinstr+0x86>
    80001878:	b775                	j	80001824 <copyinstr+0x48>
    8000187a:	4781                	li	a5,0
    8000187c:	b771                	j	80001808 <copyinstr+0x2c>
      return -1;
    8000187e:	557d                	li	a0,-1
    80001880:	b779                	j	8000180e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001882:	6b85                	lui	s7,0x1
    80001884:	9ba6                	add	s7,s7,s1
    80001886:	87da                	mv	a5,s6
    80001888:	b77d                	j	80001836 <copyinstr+0x5a>
  int got_null = 0;
    8000188a:	4781                	li	a5,0
  if(got_null){
    8000188c:	37fd                	addiw	a5,a5,-1
    8000188e:	0007851b          	sext.w	a0,a5
}
    80001892:	8082                	ret

0000000080001894 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001894:	7139                	addi	sp,sp,-64
    80001896:	fc06                	sd	ra,56(sp)
    80001898:	f822                	sd	s0,48(sp)
    8000189a:	f426                	sd	s1,40(sp)
    8000189c:	f04a                	sd	s2,32(sp)
    8000189e:	ec4e                	sd	s3,24(sp)
    800018a0:	e852                	sd	s4,16(sp)
    800018a2:	e456                	sd	s5,8(sp)
    800018a4:	e05a                	sd	s6,0(sp)
    800018a6:	0080                	addi	s0,sp,64
    800018a8:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018aa:	0000e497          	auipc	s1,0xe
    800018ae:	60648493          	addi	s1,s1,1542 # 8000feb0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018b2:	8b26                	mv	s6,s1
    800018b4:	ff8f6937          	lui	s2,0xff8f6
    800018b8:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d4599>
    800018bc:	093e                	slli	s2,s2,0xf
    800018be:	ae190913          	addi	s2,s2,-1311
    800018c2:	0932                	slli	s2,s2,0xc
    800018c4:	47b90913          	addi	s2,s2,1147
    800018c8:	0936                	slli	s2,s2,0xd
    800018ca:	c2990913          	addi	s2,s2,-983
    800018ce:	040009b7          	lui	s3,0x4000
    800018d2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018d4:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d6:	00015a97          	auipc	s5,0x15
    800018da:	9daa8a93          	addi	s5,s5,-1574 # 800162b0 <tickslock>
    char *pa = kalloc();
    800018de:	a46ff0ef          	jal	80000b24 <kalloc>
    800018e2:	862a                	mv	a2,a0
    if(pa == 0)
    800018e4:	cd15                	beqz	a0,80001920 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800018e6:	416485b3          	sub	a1,s1,s6
    800018ea:	8591                	srai	a1,a1,0x4
    800018ec:	032585b3          	mul	a1,a1,s2
    800018f0:	2585                	addiw	a1,a1,1
    800018f2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018f6:	4719                	li	a4,6
    800018f8:	6685                	lui	a3,0x1
    800018fa:	40b985b3          	sub	a1,s3,a1
    800018fe:	8552                	mv	a0,s4
    80001900:	ffaff0ef          	jal	800010fa <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001904:	19048493          	addi	s1,s1,400
    80001908:	fd549be3          	bne	s1,s5,800018de <proc_mapstacks+0x4a>
  }
}
    8000190c:	70e2                	ld	ra,56(sp)
    8000190e:	7442                	ld	s0,48(sp)
    80001910:	74a2                	ld	s1,40(sp)
    80001912:	7902                	ld	s2,32(sp)
    80001914:	69e2                	ld	s3,24(sp)
    80001916:	6a42                	ld	s4,16(sp)
    80001918:	6aa2                	ld	s5,8(sp)
    8000191a:	6b02                	ld	s6,0(sp)
    8000191c:	6121                	addi	sp,sp,64
    8000191e:	8082                	ret
      panic("kalloc");
    80001920:	00006517          	auipc	a0,0x6
    80001924:	91850513          	addi	a0,a0,-1768 # 80007238 <etext+0x238>
    80001928:	e6dfe0ef          	jal	80000794 <panic>

000000008000192c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000192c:	7139                	addi	sp,sp,-64
    8000192e:	fc06                	sd	ra,56(sp)
    80001930:	f822                	sd	s0,48(sp)
    80001932:	f426                	sd	s1,40(sp)
    80001934:	f04a                	sd	s2,32(sp)
    80001936:	ec4e                	sd	s3,24(sp)
    80001938:	e852                	sd	s4,16(sp)
    8000193a:	e456                	sd	s5,8(sp)
    8000193c:	e05a                	sd	s6,0(sp)
    8000193e:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001940:	00006597          	auipc	a1,0x6
    80001944:	90058593          	addi	a1,a1,-1792 # 80007240 <etext+0x240>
    80001948:	0000e517          	auipc	a0,0xe
    8000194c:	13850513          	addi	a0,a0,312 # 8000fa80 <pid_lock>
    80001950:	a24ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001954:	00006597          	auipc	a1,0x6
    80001958:	8f458593          	addi	a1,a1,-1804 # 80007248 <etext+0x248>
    8000195c:	0000e517          	auipc	a0,0xe
    80001960:	13c50513          	addi	a0,a0,316 # 8000fa98 <wait_lock>
    80001964:	a10ff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	0000e497          	auipc	s1,0xe
    8000196c:	54848493          	addi	s1,s1,1352 # 8000feb0 <proc>
      initlock(&p->lock, "proc");
    80001970:	00006b17          	auipc	s6,0x6
    80001974:	8e8b0b13          	addi	s6,s6,-1816 # 80007258 <etext+0x258>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001978:	8aa6                	mv	s5,s1
    8000197a:	ff8f6937          	lui	s2,0xff8f6
    8000197e:	c2990913          	addi	s2,s2,-983 # ffffffffff8f5c29 <end+0xffffffff7f8d4599>
    80001982:	093e                	slli	s2,s2,0xf
    80001984:	ae190913          	addi	s2,s2,-1311
    80001988:	0932                	slli	s2,s2,0xc
    8000198a:	47b90913          	addi	s2,s2,1147
    8000198e:	0936                	slli	s2,s2,0xd
    80001990:	c2990913          	addi	s2,s2,-983
    80001994:	040009b7          	lui	s3,0x4000
    80001998:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000199a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199c:	00015a17          	auipc	s4,0x15
    800019a0:	914a0a13          	addi	s4,s4,-1772 # 800162b0 <tickslock>
      initlock(&p->lock, "proc");
    800019a4:	85da                	mv	a1,s6
    800019a6:	8526                	mv	a0,s1
    800019a8:	9ccff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    800019ac:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019b0:	415487b3          	sub	a5,s1,s5
    800019b4:	8791                	srai	a5,a5,0x4
    800019b6:	032787b3          	mul	a5,a5,s2
    800019ba:	2785                	addiw	a5,a5,1
    800019bc:	00d7979b          	slliw	a5,a5,0xd
    800019c0:	40f987b3          	sub	a5,s3,a5
    800019c4:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c6:	19048493          	addi	s1,s1,400
    800019ca:	fd449de3          	bne	s1,s4,800019a4 <procinit+0x78>
  }
}
    800019ce:	70e2                	ld	ra,56(sp)
    800019d0:	7442                	ld	s0,48(sp)
    800019d2:	74a2                	ld	s1,40(sp)
    800019d4:	7902                	ld	s2,32(sp)
    800019d6:	69e2                	ld	s3,24(sp)
    800019d8:	6a42                	ld	s4,16(sp)
    800019da:	6aa2                	ld	s5,8(sp)
    800019dc:	6b02                	ld	s6,0(sp)
    800019de:	6121                	addi	sp,sp,64
    800019e0:	8082                	ret

00000000800019e2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019e2:	1141                	addi	sp,sp,-16
    800019e4:	e422                	sd	s0,8(sp)
    800019e6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019e8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019ea:	2501                	sext.w	a0,a0
    800019ec:	6422                	ld	s0,8(sp)
    800019ee:	0141                	addi	sp,sp,16
    800019f0:	8082                	ret

00000000800019f2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019f2:	1141                	addi	sp,sp,-16
    800019f4:	e422                	sd	s0,8(sp)
    800019f6:	0800                	addi	s0,sp,16
    800019f8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019fa:	2781                	sext.w	a5,a5
    800019fc:	079e                	slli	a5,a5,0x7
  return c;
}
    800019fe:	0000e517          	auipc	a0,0xe
    80001a02:	0b250513          	addi	a0,a0,178 # 8000fab0 <cpus>
    80001a06:	953e                	add	a0,a0,a5
    80001a08:	6422                	ld	s0,8(sp)
    80001a0a:	0141                	addi	sp,sp,16
    80001a0c:	8082                	ret

0000000080001a0e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a0e:	1101                	addi	sp,sp,-32
    80001a10:	ec06                	sd	ra,24(sp)
    80001a12:	e822                	sd	s0,16(sp)
    80001a14:	e426                	sd	s1,8(sp)
    80001a16:	1000                	addi	s0,sp,32
  push_off();
    80001a18:	99cff0ef          	jal	80000bb4 <push_off>
    80001a1c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a1e:	2781                	sext.w	a5,a5
    80001a20:	079e                	slli	a5,a5,0x7
    80001a22:	0000e717          	auipc	a4,0xe
    80001a26:	05e70713          	addi	a4,a4,94 # 8000fa80 <pid_lock>
    80001a2a:	97ba                	add	a5,a5,a4
    80001a2c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a2e:	a0aff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001a32:	8526                	mv	a0,s1
    80001a34:	60e2                	ld	ra,24(sp)
    80001a36:	6442                	ld	s0,16(sp)
    80001a38:	64a2                	ld	s1,8(sp)
    80001a3a:	6105                	addi	sp,sp,32
    80001a3c:	8082                	ret

0000000080001a3e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a3e:	1141                	addi	sp,sp,-16
    80001a40:	e406                	sd	ra,8(sp)
    80001a42:	e022                	sd	s0,0(sp)
    80001a44:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a46:	fc9ff0ef          	jal	80001a0e <myproc>
    80001a4a:	a42ff0ef          	jal	80000c8c <release>

  if (first) {
    80001a4e:	00006797          	auipc	a5,0x6
    80001a52:	e827a783          	lw	a5,-382(a5) # 800078d0 <first.1>
    80001a56:	e799                	bnez	a5,80001a64 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001a58:	70d000ef          	jal	80002964 <usertrapret>
}
    80001a5c:	60a2                	ld	ra,8(sp)
    80001a5e:	6402                	ld	s0,0(sp)
    80001a60:	0141                	addi	sp,sp,16
    80001a62:	8082                	ret
    fsinit(ROOTDEV);
    80001a64:	4505                	li	a0,1
    80001a66:	327010ef          	jal	8000358c <fsinit>
    first = 0;
    80001a6a:	00006797          	auipc	a5,0x6
    80001a6e:	e607a323          	sw	zero,-410(a5) # 800078d0 <first.1>
    __sync_synchronize();
    80001a72:	0ff0000f          	fence
    80001a76:	b7cd                	j	80001a58 <forkret+0x1a>

0000000080001a78 <allocpid>:
{
    80001a78:	1101                	addi	sp,sp,-32
    80001a7a:	ec06                	sd	ra,24(sp)
    80001a7c:	e822                	sd	s0,16(sp)
    80001a7e:	e426                	sd	s1,8(sp)
    80001a80:	e04a                	sd	s2,0(sp)
    80001a82:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a84:	0000e917          	auipc	s2,0xe
    80001a88:	ffc90913          	addi	s2,s2,-4 # 8000fa80 <pid_lock>
    80001a8c:	854a                	mv	a0,s2
    80001a8e:	966ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001a92:	00006797          	auipc	a5,0x6
    80001a96:	e4678793          	addi	a5,a5,-442 # 800078d8 <nextpid>
    80001a9a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a9c:	0014871b          	addiw	a4,s1,1
    80001aa0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aa2:	854a                	mv	a0,s2
    80001aa4:	9e8ff0ef          	jal	80000c8c <release>
}
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	60e2                	ld	ra,24(sp)
    80001aac:	6442                	ld	s0,16(sp)
    80001aae:	64a2                	ld	s1,8(sp)
    80001ab0:	6902                	ld	s2,0(sp)
    80001ab2:	6105                	addi	sp,sp,32
    80001ab4:	8082                	ret

0000000080001ab6 <proc_pagetable>:
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	e04a                	sd	s2,0(sp)
    80001ac0:	1000                	addi	s0,sp,32
    80001ac2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac4:	fe8ff0ef          	jal	800012ac <uvmcreate>
    80001ac8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aca:	cd15                	beqz	a0,80001b06 <proc_pagetable+0x50>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001acc:	4729                	li	a4,10
    80001ace:	00004697          	auipc	a3,0x4
    80001ad2:	53268693          	addi	a3,a3,1330 # 80006000 <_trampoline>
    80001ad6:	6605                	lui	a2,0x1
    80001ad8:	040005b7          	lui	a1,0x4000
    80001adc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ade:	05b2                	slli	a1,a1,0xc
    80001ae0:	d6aff0ef          	jal	8000104a <mappages>
    80001ae4:	02054863          	bltz	a0,80001b14 <proc_pagetable+0x5e>
  if(mappages(pagetable, p->trapframe_va = TRAPFRAME, PGSIZE,
    80001ae8:	020005b7          	lui	a1,0x2000
    80001aec:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aee:	05b6                	slli	a1,a1,0xd
    80001af0:	04b93c23          	sd	a1,88(s2)
    80001af4:	4719                	li	a4,6
    80001af6:	06093683          	ld	a3,96(s2)
    80001afa:	6605                	lui	a2,0x1
    80001afc:	8526                	mv	a0,s1
    80001afe:	d4cff0ef          	jal	8000104a <mappages>
    80001b02:	00054f63          	bltz	a0,80001b20 <proc_pagetable+0x6a>
}
    80001b06:	8526                	mv	a0,s1
    80001b08:	60e2                	ld	ra,24(sp)
    80001b0a:	6442                	ld	s0,16(sp)
    80001b0c:	64a2                	ld	s1,8(sp)
    80001b0e:	6902                	ld	s2,0(sp)
    80001b10:	6105                	addi	sp,sp,32
    80001b12:	8082                	ret
    uvmfree(pagetable, 0);
    80001b14:	4581                	li	a1,0
    80001b16:	8526                	mv	a0,s1
    80001b18:	963ff0ef          	jal	8000147a <uvmfree>
    return 0;
    80001b1c:	4481                	li	s1,0
    80001b1e:	b7e5                	j	80001b06 <proc_pagetable+0x50>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b20:	4681                	li	a3,0
    80001b22:	4605                	li	a2,1
    80001b24:	040005b7          	lui	a1,0x4000
    80001b28:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b2a:	05b2                	slli	a1,a1,0xc
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	ec2ff0ef          	jal	800011f0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b32:	4581                	li	a1,0
    80001b34:	8526                	mv	a0,s1
    80001b36:	945ff0ef          	jal	8000147a <uvmfree>
    return 0;
    80001b3a:	4481                	li	s1,0
    80001b3c:	b7e9                	j	80001b06 <proc_pagetable+0x50>

0000000080001b3e <proc_freepagetable>:
{
    80001b3e:	1101                	addi	sp,sp,-32
    80001b40:	ec06                	sd	ra,24(sp)
    80001b42:	e822                	sd	s0,16(sp)
    80001b44:	e426                	sd	s1,8(sp)
    80001b46:	e04a                	sd	s2,0(sp)
    80001b48:	1000                	addi	s0,sp,32
    80001b4a:	84aa                	mv	s1,a0
    80001b4c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b4e:	4681                	li	a3,0
    80001b50:	4605                	li	a2,1
    80001b52:	040005b7          	lui	a1,0x4000
    80001b56:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b58:	05b2                	slli	a1,a1,0xc
    80001b5a:	e96ff0ef          	jal	800011f0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b5e:	4681                	li	a3,0
    80001b60:	4605                	li	a2,1
    80001b62:	020005b7          	lui	a1,0x2000
    80001b66:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b68:	05b6                	slli	a1,a1,0xd
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	e84ff0ef          	jal	800011f0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b70:	85ca                	mv	a1,s2
    80001b72:	8526                	mv	a0,s1
    80001b74:	907ff0ef          	jal	8000147a <uvmfree>
}
    80001b78:	60e2                	ld	ra,24(sp)
    80001b7a:	6442                	ld	s0,16(sp)
    80001b7c:	64a2                	ld	s1,8(sp)
    80001b7e:	6902                	ld	s2,0(sp)
    80001b80:	6105                	addi	sp,sp,32
    80001b82:	8082                	ret

0000000080001b84 <freeproc>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	1000                	addi	s0,sp,32
    80001b8e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b90:	7128                	ld	a0,96(a0)
    80001b92:	c119                	beqz	a0,80001b98 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b94:	eaffe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001b98:	0604b023          	sd	zero,96(s1)
  p->trapframe_va = 0;
    80001b9c:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable && p->tid == 0) {
    80001ba0:	68a8                	ld	a0,80(s1)
    80001ba2:	c501                	beqz	a0,80001baa <freeproc+0x26>
    80001ba4:	1784a783          	lw	a5,376(s1)
    80001ba8:	cf95                	beqz	a5,80001be4 <freeproc+0x60>
  p->pagetable = 0;
    80001baa:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bae:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bb2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bba:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001bbe:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bc2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bc6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bca:	0004ac23          	sw	zero,24(s1)
  p->tid = 0;
    80001bce:	1604ac23          	sw	zero,376(s1)
  p->main_thread = 0;
    80001bd2:	1604b823          	sd	zero,368(s1)
  p->stack = 0;
    80001bd6:	1804b023          	sd	zero,384(s1)
}
    80001bda:	60e2                	ld	ra,24(sp)
    80001bdc:	6442                	ld	s0,16(sp)
    80001bde:	64a2                	ld	s1,8(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
    proc_freepagetable(p->pagetable, p->sz);
    80001be4:	64ac                	ld	a1,72(s1)
    80001be6:	f59ff0ef          	jal	80001b3e <proc_freepagetable>
    80001bea:	b7c1                	j	80001baa <freeproc+0x26>

0000000080001bec <allocproc>:
{
    80001bec:	1101                	addi	sp,sp,-32
    80001bee:	ec06                	sd	ra,24(sp)
    80001bf0:	e822                	sd	s0,16(sp)
    80001bf2:	e426                	sd	s1,8(sp)
    80001bf4:	e04a                	sd	s2,0(sp)
    80001bf6:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf8:	0000e497          	auipc	s1,0xe
    80001bfc:	2b848493          	addi	s1,s1,696 # 8000feb0 <proc>
    80001c00:	00014917          	auipc	s2,0x14
    80001c04:	6b090913          	addi	s2,s2,1712 # 800162b0 <tickslock>
    acquire(&p->lock);
    80001c08:	8526                	mv	a0,s1
    80001c0a:	febfe0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001c0e:	4c9c                	lw	a5,24(s1)
    80001c10:	cb91                	beqz	a5,80001c24 <allocproc+0x38>
      release(&p->lock);
    80001c12:	8526                	mv	a0,s1
    80001c14:	878ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c18:	19048493          	addi	s1,s1,400
    80001c1c:	ff2496e3          	bne	s1,s2,80001c08 <allocproc+0x1c>
  return 0;
    80001c20:	4481                	li	s1,0
    80001c22:	a899                	j	80001c78 <allocproc+0x8c>
  p->pid = allocpid();
    80001c24:	e55ff0ef          	jal	80001a78 <allocpid>
    80001c28:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c2a:	4785                	li	a5,1
    80001c2c:	cc9c                	sw	a5,24(s1)
  p->main_thread = p;
    80001c2e:	1694b823          	sd	s1,368(s1)
  p->tid = 0;
    80001c32:	1604ac23          	sw	zero,376(s1)
  p->stack = 0;
    80001c36:	1804b023          	sd	zero,384(s1)
  p->main_sz = &(p->sz);
    80001c3a:	04848793          	addi	a5,s1,72
    80001c3e:	18f4b423          	sd	a5,392(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c42:	ee3fe0ef          	jal	80000b24 <kalloc>
    80001c46:	892a                	mv	s2,a0
    80001c48:	f0a8                	sd	a0,96(s1)
    80001c4a:	cd15                	beqz	a0,80001c86 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	e69ff0ef          	jal	80001ab6 <proc_pagetable>
    80001c52:	892a                	mv	s2,a0
    80001c54:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c56:	c121                	beqz	a0,80001c96 <allocproc+0xaa>
  memset(&p->context, 0, sizeof(p->context));
    80001c58:	07000613          	li	a2,112
    80001c5c:	4581                	li	a1,0
    80001c5e:	06848513          	addi	a0,s1,104
    80001c62:	866ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001c66:	00000797          	auipc	a5,0x0
    80001c6a:	dd878793          	addi	a5,a5,-552 # 80001a3e <forkret>
    80001c6e:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c70:	60bc                	ld	a5,64(s1)
    80001c72:	6705                	lui	a4,0x1
    80001c74:	97ba                	add	a5,a5,a4
    80001c76:	f8bc                	sd	a5,112(s1)
}
    80001c78:	8526                	mv	a0,s1
    80001c7a:	60e2                	ld	ra,24(sp)
    80001c7c:	6442                	ld	s0,16(sp)
    80001c7e:	64a2                	ld	s1,8(sp)
    80001c80:	6902                	ld	s2,0(sp)
    80001c82:	6105                	addi	sp,sp,32
    80001c84:	8082                	ret
    freeproc(p);
    80001c86:	8526                	mv	a0,s1
    80001c88:	efdff0ef          	jal	80001b84 <freeproc>
    release(&p->lock);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	ffffe0ef          	jal	80000c8c <release>
    return 0;
    80001c92:	84ca                	mv	s1,s2
    80001c94:	b7d5                	j	80001c78 <allocproc+0x8c>
    freeproc(p);
    80001c96:	8526                	mv	a0,s1
    80001c98:	eedff0ef          	jal	80001b84 <freeproc>
    release(&p->lock);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	feffe0ef          	jal	80000c8c <release>
    return 0;
    80001ca2:	84ca                	mv	s1,s2
    80001ca4:	bfd1                	j	80001c78 <allocproc+0x8c>

0000000080001ca6 <userinit>:
{
    80001ca6:	1101                	addi	sp,sp,-32
    80001ca8:	ec06                	sd	ra,24(sp)
    80001caa:	e822                	sd	s0,16(sp)
    80001cac:	e426                	sd	s1,8(sp)
    80001cae:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cb0:	f3dff0ef          	jal	80001bec <allocproc>
    80001cb4:	84aa                	mv	s1,a0
  initproc = p; 
    80001cb6:	00006797          	auipc	a5,0x6
    80001cba:	c8a7b923          	sd	a0,-878(a5) # 80007948 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cbe:	03400613          	li	a2,52
    80001cc2:	00006597          	auipc	a1,0x6
    80001cc6:	c1e58593          	addi	a1,a1,-994 # 800078e0 <initcode>
    80001cca:	6928                	ld	a0,80(a0)
    80001ccc:	e06ff0ef          	jal	800012d2 <uvmfirst>
  p->sz = PGSIZE;
    80001cd0:	6785                	lui	a5,0x1
    80001cd2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd4:	70b8                	ld	a4,96(s1)
    80001cd6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cda:	70b8                	ld	a4,96(s1)
    80001cdc:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cde:	4641                	li	a2,16
    80001ce0:	00005597          	auipc	a1,0x5
    80001ce4:	58058593          	addi	a1,a1,1408 # 80007260 <etext+0x260>
    80001ce8:	16048513          	addi	a0,s1,352
    80001cec:	91aff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001cf0:	00005517          	auipc	a0,0x5
    80001cf4:	58050513          	addi	a0,a0,1408 # 80007270 <etext+0x270>
    80001cf8:	1a2020ef          	jal	80003e9a <namei>
    80001cfc:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d00:	478d                	li	a5,3
    80001d02:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d04:	8526                	mv	a0,s1
    80001d06:	f87fe0ef          	jal	80000c8c <release>
}
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6105                	addi	sp,sp,32
    80001d12:	8082                	ret

0000000080001d14 <growproc>:
{
    80001d14:	1101                	addi	sp,sp,-32
    80001d16:	ec06                	sd	ra,24(sp)
    80001d18:	e822                	sd	s0,16(sp)
    80001d1a:	e426                	sd	s1,8(sp)
    80001d1c:	e04a                	sd	s2,0(sp)
    80001d1e:	1000                	addi	s0,sp,32
    80001d20:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d22:	cedff0ef          	jal	80001a0e <myproc>
    80001d26:	84aa                	mv	s1,a0
  uint64 sz = *(p->main_sz);
    80001d28:	18853783          	ld	a5,392(a0)
    80001d2c:	638c                	ld	a1,0(a5)
  if(n > 0){
    80001d2e:	01204e63          	bgtz	s2,80001d4a <growproc+0x36>
  } else if(n < 0){
    80001d32:	02094663          	bltz	s2,80001d5e <growproc+0x4a>
  *(p->main_sz) = sz;
    80001d36:	1884b783          	ld	a5,392(s1)
    80001d3a:	e38c                	sd	a1,0(a5)
  return 0;
    80001d3c:	4501                	li	a0,0
}
    80001d3e:	60e2                	ld	ra,24(sp)
    80001d40:	6442                	ld	s0,16(sp)
    80001d42:	64a2                	ld	s1,8(sp)
    80001d44:	6902                	ld	s2,0(sp)
    80001d46:	6105                	addi	sp,sp,32
    80001d48:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d4a:	4691                	li	a3,4
    80001d4c:	00b90633          	add	a2,s2,a1
    80001d50:	6928                	ld	a0,80(a0)
    80001d52:	e22ff0ef          	jal	80001374 <uvmalloc>
    80001d56:	85aa                	mv	a1,a0
    80001d58:	fd79                	bnez	a0,80001d36 <growproc+0x22>
      return -1;
    80001d5a:	557d                	li	a0,-1
    80001d5c:	b7cd                	j	80001d3e <growproc+0x2a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d5e:	00b90633          	add	a2,s2,a1
    80001d62:	6928                	ld	a0,80(a0)
    80001d64:	dccff0ef          	jal	80001330 <uvmdealloc>
    80001d68:	85aa                	mv	a1,a0
    80001d6a:	b7f1                	j	80001d36 <growproc+0x22>

0000000080001d6c <fork>:
{
    80001d6c:	7139                	addi	sp,sp,-64
    80001d6e:	fc06                	sd	ra,56(sp)
    80001d70:	f822                	sd	s0,48(sp)
    80001d72:	f426                	sd	s1,40(sp)
    80001d74:	e456                	sd	s5,8(sp)
    80001d76:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d78:	c97ff0ef          	jal	80001a0e <myproc>
    80001d7c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d7e:	e6fff0ef          	jal	80001bec <allocproc>
    80001d82:	10050263          	beqz	a0,80001e86 <fork+0x11a>
    80001d86:	ec4e                	sd	s3,24(sp)
    80001d88:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8a:	048ab603          	ld	a2,72(s5)
    80001d8e:	692c                	ld	a1,80(a0)
    80001d90:	050ab503          	ld	a0,80(s5)
    80001d94:	f18ff0ef          	jal	800014ac <uvmcopy>
    80001d98:	04054b63          	bltz	a0,80001dee <fork+0x82>
    80001d9c:	f04a                	sd	s2,32(sp)
    80001d9e:	e852                	sd	s4,16(sp)
  np->sz = *(p->main_sz);
    80001da0:	188ab783          	ld	a5,392(s5)
    80001da4:	639c                	ld	a5,0(a5)
    80001da6:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001daa:	060ab683          	ld	a3,96(s5)
    80001dae:	87b6                	mv	a5,a3
    80001db0:	0609b703          	ld	a4,96(s3)
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
    80001dd4:	fed792e3          	bne	a5,a3,80001db8 <fork+0x4c>
  np->trapframe->a0 = 0;
    80001dd8:	0609b783          	ld	a5,96(s3)
    80001ddc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de0:	0d8a8493          	addi	s1,s5,216
    80001de4:	0d898913          	addi	s2,s3,216
    80001de8:	158a8a13          	addi	s4,s5,344
    80001dec:	a831                	j	80001e08 <fork+0x9c>
    freeproc(np);
    80001dee:	854e                	mv	a0,s3
    80001df0:	d95ff0ef          	jal	80001b84 <freeproc>
    release(&np->lock);
    80001df4:	854e                	mv	a0,s3
    80001df6:	e97fe0ef          	jal	80000c8c <release>
    return -1;
    80001dfa:	54fd                	li	s1,-1
    80001dfc:	69e2                	ld	s3,24(sp)
    80001dfe:	a8ad                	j	80001e78 <fork+0x10c>
  for(i = 0; i < NOFILE; i++)
    80001e00:	04a1                	addi	s1,s1,8
    80001e02:	0921                	addi	s2,s2,8
    80001e04:	01448963          	beq	s1,s4,80001e16 <fork+0xaa>
    if(p->ofile[i])
    80001e08:	6088                	ld	a0,0(s1)
    80001e0a:	d97d                	beqz	a0,80001e00 <fork+0x94>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e0c:	61e020ef          	jal	8000442a <filedup>
    80001e10:	00a93023          	sd	a0,0(s2)
    80001e14:	b7f5                	j	80001e00 <fork+0x94>
  np->cwd = idup(p->cwd);
    80001e16:	158ab503          	ld	a0,344(s5)
    80001e1a:	171010ef          	jal	8000378a <idup>
    80001e1e:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e22:	4641                	li	a2,16
    80001e24:	160a8593          	addi	a1,s5,352
    80001e28:	16098513          	addi	a0,s3,352
    80001e2c:	fdbfe0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001e30:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001e34:	854e                	mv	a0,s3
    80001e36:	e57fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001e3a:	0000e517          	auipc	a0,0xe
    80001e3e:	c5e50513          	addi	a0,a0,-930 # 8000fa98 <wait_lock>
    80001e42:	db3fe0ef          	jal	80000bf4 <acquire>
  if (np->tid == 0){
    80001e46:	1789a783          	lw	a5,376(s3)
    80001e4a:	c399                	beqz	a5,80001e50 <fork+0xe4>
    np->parent = p->main_thread;
    80001e4c:	170aba83          	ld	s5,368(s5)
    80001e50:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e54:	0000e517          	auipc	a0,0xe
    80001e58:	c4450513          	addi	a0,a0,-956 # 8000fa98 <wait_lock>
    80001e5c:	e31fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001e60:	854e                	mv	a0,s3
    80001e62:	d93fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001e66:	478d                	li	a5,3
    80001e68:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e6c:	854e                	mv	a0,s3
    80001e6e:	e1ffe0ef          	jal	80000c8c <release>
  return pid;
    80001e72:	7902                	ld	s2,32(sp)
    80001e74:	69e2                	ld	s3,24(sp)
    80001e76:	6a42                	ld	s4,16(sp)
}
    80001e78:	8526                	mv	a0,s1
    80001e7a:	70e2                	ld	ra,56(sp)
    80001e7c:	7442                	ld	s0,48(sp)
    80001e7e:	74a2                	ld	s1,40(sp)
    80001e80:	6aa2                	ld	s5,8(sp)
    80001e82:	6121                	addi	sp,sp,64
    80001e84:	8082                	ret
    return -1;
    80001e86:	54fd                	li	s1,-1
    80001e88:	bfc5                	j	80001e78 <fork+0x10c>

0000000080001e8a <scheduler>:
{
    80001e8a:	715d                	addi	sp,sp,-80
    80001e8c:	e486                	sd	ra,72(sp)
    80001e8e:	e0a2                	sd	s0,64(sp)
    80001e90:	fc26                	sd	s1,56(sp)
    80001e92:	f84a                	sd	s2,48(sp)
    80001e94:	f44e                	sd	s3,40(sp)
    80001e96:	f052                	sd	s4,32(sp)
    80001e98:	ec56                	sd	s5,24(sp)
    80001e9a:	e85a                	sd	s6,16(sp)
    80001e9c:	e45e                	sd	s7,8(sp)
    80001e9e:	e062                	sd	s8,0(sp)
    80001ea0:	0880                	addi	s0,sp,80
    80001ea2:	8792                	mv	a5,tp
  int id = r_tp();
    80001ea4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ea6:	00779b13          	slli	s6,a5,0x7
    80001eaa:	0000e717          	auipc	a4,0xe
    80001eae:	bd670713          	addi	a4,a4,-1066 # 8000fa80 <pid_lock>
    80001eb2:	975a                	add	a4,a4,s6
    80001eb4:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001eb8:	0000e717          	auipc	a4,0xe
    80001ebc:	c0070713          	addi	a4,a4,-1024 # 8000fab8 <cpus+0x8>
    80001ec0:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001ec2:	4c11                	li	s8,4
        c->proc = p;
    80001ec4:	079e                	slli	a5,a5,0x7
    80001ec6:	0000ea17          	auipc	s4,0xe
    80001eca:	bbaa0a13          	addi	s4,s4,-1094 # 8000fa80 <pid_lock>
    80001ece:	9a3e                	add	s4,s4,a5
        found = 1;
    80001ed0:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ed2:	00014997          	auipc	s3,0x14
    80001ed6:	3de98993          	addi	s3,s3,990 # 800162b0 <tickslock>
    80001eda:	a0a9                	j	80001f24 <scheduler+0x9a>
      release(&p->lock);
    80001edc:	8526                	mv	a0,s1
    80001ede:	daffe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee2:	19048493          	addi	s1,s1,400
    80001ee6:	03348563          	beq	s1,s3,80001f10 <scheduler+0x86>
      acquire(&p->lock);
    80001eea:	8526                	mv	a0,s1
    80001eec:	d09fe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001ef0:	4c9c                	lw	a5,24(s1)
    80001ef2:	ff2795e3          	bne	a5,s2,80001edc <scheduler+0x52>
        p->state = RUNNING;
    80001ef6:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001efa:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001efe:	06848593          	addi	a1,s1,104
    80001f02:	855a                	mv	a0,s6
    80001f04:	1bb000ef          	jal	800028be <swtch>
        c->proc = 0;
    80001f08:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001f0c:	8ade                	mv	s5,s7
    80001f0e:	b7f9                	j	80001edc <scheduler+0x52>
    if(found == 0) {
    80001f10:	000a9a63          	bnez	s5,80001f24 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f1c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001f20:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f24:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f28:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f2c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001f30:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f32:	0000e497          	auipc	s1,0xe
    80001f36:	f7e48493          	addi	s1,s1,-130 # 8000feb0 <proc>
      if(p->state == RUNNABLE) {
    80001f3a:	490d                	li	s2,3
    80001f3c:	b77d                	j	80001eea <scheduler+0x60>

0000000080001f3e <sched>:
{
    80001f3e:	7179                	addi	sp,sp,-48
    80001f40:	f406                	sd	ra,40(sp)
    80001f42:	f022                	sd	s0,32(sp)
    80001f44:	ec26                	sd	s1,24(sp)
    80001f46:	e84a                	sd	s2,16(sp)
    80001f48:	e44e                	sd	s3,8(sp)
    80001f4a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f4c:	ac3ff0ef          	jal	80001a0e <myproc>
    80001f50:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f52:	c39fe0ef          	jal	80000b8a <holding>
    80001f56:	c92d                	beqz	a0,80001fc8 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f58:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f5a:	2781                	sext.w	a5,a5
    80001f5c:	079e                	slli	a5,a5,0x7
    80001f5e:	0000e717          	auipc	a4,0xe
    80001f62:	b2270713          	addi	a4,a4,-1246 # 8000fa80 <pid_lock>
    80001f66:	97ba                	add	a5,a5,a4
    80001f68:	0a87a703          	lw	a4,168(a5)
    80001f6c:	4785                	li	a5,1
    80001f6e:	06f71363          	bne	a4,a5,80001fd4 <sched+0x96>
  if(p->state == RUNNING)
    80001f72:	4c98                	lw	a4,24(s1)
    80001f74:	4791                	li	a5,4
    80001f76:	06f70563          	beq	a4,a5,80001fe0 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f7a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f7e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f80:	e7b5                	bnez	a5,80001fec <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f82:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f84:	0000e917          	auipc	s2,0xe
    80001f88:	afc90913          	addi	s2,s2,-1284 # 8000fa80 <pid_lock>
    80001f8c:	2781                	sext.w	a5,a5
    80001f8e:	079e                	slli	a5,a5,0x7
    80001f90:	97ca                	add	a5,a5,s2
    80001f92:	0ac7a983          	lw	s3,172(a5)
    80001f96:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f98:	2781                	sext.w	a5,a5
    80001f9a:	079e                	slli	a5,a5,0x7
    80001f9c:	0000e597          	auipc	a1,0xe
    80001fa0:	b1c58593          	addi	a1,a1,-1252 # 8000fab8 <cpus+0x8>
    80001fa4:	95be                	add	a1,a1,a5
    80001fa6:	06848513          	addi	a0,s1,104
    80001faa:	115000ef          	jal	800028be <swtch>
    80001fae:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fb0:	2781                	sext.w	a5,a5
    80001fb2:	079e                	slli	a5,a5,0x7
    80001fb4:	993e                	add	s2,s2,a5
    80001fb6:	0b392623          	sw	s3,172(s2)
}
    80001fba:	70a2                	ld	ra,40(sp)
    80001fbc:	7402                	ld	s0,32(sp)
    80001fbe:	64e2                	ld	s1,24(sp)
    80001fc0:	6942                	ld	s2,16(sp)
    80001fc2:	69a2                	ld	s3,8(sp)
    80001fc4:	6145                	addi	sp,sp,48
    80001fc6:	8082                	ret
    panic("sched p->lock");
    80001fc8:	00005517          	auipc	a0,0x5
    80001fcc:	2b050513          	addi	a0,a0,688 # 80007278 <etext+0x278>
    80001fd0:	fc4fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001fd4:	00005517          	auipc	a0,0x5
    80001fd8:	2b450513          	addi	a0,a0,692 # 80007288 <etext+0x288>
    80001fdc:	fb8fe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001fe0:	00005517          	auipc	a0,0x5
    80001fe4:	2b850513          	addi	a0,a0,696 # 80007298 <etext+0x298>
    80001fe8:	facfe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001fec:	00005517          	auipc	a0,0x5
    80001ff0:	2bc50513          	addi	a0,a0,700 # 800072a8 <etext+0x2a8>
    80001ff4:	fa0fe0ef          	jal	80000794 <panic>

0000000080001ff8 <yield>:
{
    80001ff8:	1101                	addi	sp,sp,-32
    80001ffa:	ec06                	sd	ra,24(sp)
    80001ffc:	e822                	sd	s0,16(sp)
    80001ffe:	e426                	sd	s1,8(sp)
    80002000:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002002:	a0dff0ef          	jal	80001a0e <myproc>
    80002006:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002008:	bedfe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    8000200c:	478d                	li	a5,3
    8000200e:	cc9c                	sw	a5,24(s1)
  sched();
    80002010:	f2fff0ef          	jal	80001f3e <sched>
  release(&p->lock);
    80002014:	8526                	mv	a0,s1
    80002016:	c77fe0ef          	jal	80000c8c <release>
}
    8000201a:	60e2                	ld	ra,24(sp)
    8000201c:	6442                	ld	s0,16(sp)
    8000201e:	64a2                	ld	s1,8(sp)
    80002020:	6105                	addi	sp,sp,32
    80002022:	8082                	ret

0000000080002024 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002024:	7179                	addi	sp,sp,-48
    80002026:	f406                	sd	ra,40(sp)
    80002028:	f022                	sd	s0,32(sp)
    8000202a:	ec26                	sd	s1,24(sp)
    8000202c:	e84a                	sd	s2,16(sp)
    8000202e:	e44e                	sd	s3,8(sp)
    80002030:	1800                	addi	s0,sp,48
    80002032:	89aa                	mv	s3,a0
    80002034:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002036:	9d9ff0ef          	jal	80001a0e <myproc>
    8000203a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000203c:	bb9fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80002040:	854a                	mv	a0,s2
    80002042:	c4bfe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80002046:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000204a:	4789                	li	a5,2
    8000204c:	cc9c                	sw	a5,24(s1)

  sched();
    8000204e:	ef1ff0ef          	jal	80001f3e <sched>

  // Tidy up. wakeup하면 여기서부터 다시 실행.
  p->chan = 0;
    80002052:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002056:	8526                	mv	a0,s1
    80002058:	c35fe0ef          	jal	80000c8c <release>
  acquire(lk);
    8000205c:	854a                	mv	a0,s2
    8000205e:	b97fe0ef          	jal	80000bf4 <acquire>
}
    80002062:	70a2                	ld	ra,40(sp)
    80002064:	7402                	ld	s0,32(sp)
    80002066:	64e2                	ld	s1,24(sp)
    80002068:	6942                	ld	s2,16(sp)
    8000206a:	69a2                	ld	s3,8(sp)
    8000206c:	6145                	addi	sp,sp,48
    8000206e:	8082                	ret

0000000080002070 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002070:	7139                	addi	sp,sp,-64
    80002072:	fc06                	sd	ra,56(sp)
    80002074:	f822                	sd	s0,48(sp)
    80002076:	f426                	sd	s1,40(sp)
    80002078:	f04a                	sd	s2,32(sp)
    8000207a:	ec4e                	sd	s3,24(sp)
    8000207c:	e852                	sd	s4,16(sp)
    8000207e:	e456                	sd	s5,8(sp)
    80002080:	0080                	addi	s0,sp,64
    80002082:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002084:	0000e497          	auipc	s1,0xe
    80002088:	e2c48493          	addi	s1,s1,-468 # 8000feb0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000208c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000208e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002090:	00014917          	auipc	s2,0x14
    80002094:	22090913          	addi	s2,s2,544 # 800162b0 <tickslock>
    80002098:	a801                	j	800020a8 <wakeup+0x38>
      }
      release(&p->lock);
    8000209a:	8526                	mv	a0,s1
    8000209c:	bf1fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020a0:	19048493          	addi	s1,s1,400
    800020a4:	03248263          	beq	s1,s2,800020c8 <wakeup+0x58>
    if(p != myproc()){
    800020a8:	967ff0ef          	jal	80001a0e <myproc>
    800020ac:	fea48ae3          	beq	s1,a0,800020a0 <wakeup+0x30>
      acquire(&p->lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	b43fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800020b6:	4c9c                	lw	a5,24(s1)
    800020b8:	ff3791e3          	bne	a5,s3,8000209a <wakeup+0x2a>
    800020bc:	709c                	ld	a5,32(s1)
    800020be:	fd479ee3          	bne	a5,s4,8000209a <wakeup+0x2a>
        p->state = RUNNABLE;
    800020c2:	0154ac23          	sw	s5,24(s1)
    800020c6:	bfd1                	j	8000209a <wakeup+0x2a>
    }
  }
}
    800020c8:	70e2                	ld	ra,56(sp)
    800020ca:	7442                	ld	s0,48(sp)
    800020cc:	74a2                	ld	s1,40(sp)
    800020ce:	7902                	ld	s2,32(sp)
    800020d0:	69e2                	ld	s3,24(sp)
    800020d2:	6a42                	ld	s4,16(sp)
    800020d4:	6aa2                	ld	s5,8(sp)
    800020d6:	6121                	addi	sp,sp,64
    800020d8:	8082                	ret

00000000800020da <reparent>:
{
    800020da:	7179                	addi	sp,sp,-48
    800020dc:	f406                	sd	ra,40(sp)
    800020de:	f022                	sd	s0,32(sp)
    800020e0:	ec26                	sd	s1,24(sp)
    800020e2:	e84a                	sd	s2,16(sp)
    800020e4:	e44e                	sd	s3,8(sp)
    800020e6:	e052                	sd	s4,0(sp)
    800020e8:	1800                	addi	s0,sp,48
    800020ea:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020ec:	0000e497          	auipc	s1,0xe
    800020f0:	dc448493          	addi	s1,s1,-572 # 8000feb0 <proc>
      pp->parent = initproc;
    800020f4:	00006a17          	auipc	s4,0x6
    800020f8:	854a0a13          	addi	s4,s4,-1964 # 80007948 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020fc:	00014997          	auipc	s3,0x14
    80002100:	1b498993          	addi	s3,s3,436 # 800162b0 <tickslock>
    80002104:	a029                	j	8000210e <reparent+0x34>
    80002106:	19048493          	addi	s1,s1,400
    8000210a:	01348b63          	beq	s1,s3,80002120 <reparent+0x46>
    if(pp->parent == p){
    8000210e:	7c9c                	ld	a5,56(s1)
    80002110:	ff279be3          	bne	a5,s2,80002106 <reparent+0x2c>
      pp->parent = initproc;
    80002114:	000a3503          	ld	a0,0(s4)
    80002118:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000211a:	f57ff0ef          	jal	80002070 <wakeup>
    8000211e:	b7e5                	j	80002106 <reparent+0x2c>
}
    80002120:	70a2                	ld	ra,40(sp)
    80002122:	7402                	ld	s0,32(sp)
    80002124:	64e2                	ld	s1,24(sp)
    80002126:	6942                	ld	s2,16(sp)
    80002128:	69a2                	ld	s3,8(sp)
    8000212a:	6a02                	ld	s4,0(sp)
    8000212c:	6145                	addi	sp,sp,48
    8000212e:	8082                	ret

0000000080002130 <exit>:
{
    80002130:	7179                	addi	sp,sp,-48
    80002132:	f406                	sd	ra,40(sp)
    80002134:	f022                	sd	s0,32(sp)
    80002136:	e052                	sd	s4,0(sp)
    80002138:	1800                	addi	s0,sp,48
    8000213a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000213c:	8d3ff0ef          	jal	80001a0e <myproc>
  if(p == initproc)
    80002140:	00006797          	auipc	a5,0x6
    80002144:	8087b783          	ld	a5,-2040(a5) # 80007948 <initproc>
    80002148:	02a78263          	beq	a5,a0,8000216c <exit+0x3c>
    8000214c:	ec26                	sd	s1,24(sp)
    8000214e:	e84a                	sd	s2,16(sp)
    80002150:	e44e                	sd	s3,8(sp)
    80002152:	892a                	mv	s2,a0
  if(p->tid == 0){
    80002154:	17852783          	lw	a5,376(a0)
    80002158:	ebd9                	bnez	a5,800021ee <exit+0xbe>
    for(thread = proc; thread < &proc[NPROC]; thread++){
    8000215a:	0000e497          	auipc	s1,0xe
    8000215e:	d5648493          	addi	s1,s1,-682 # 8000feb0 <proc>
    80002162:	00014997          	auipc	s3,0x14
    80002166:	14e98993          	addi	s3,s3,334 # 800162b0 <tickslock>
    8000216a:	a899                	j	800021c0 <exit+0x90>
    8000216c:	ec26                	sd	s1,24(sp)
    8000216e:	e84a                	sd	s2,16(sp)
    80002170:	e44e                	sd	s3,8(sp)
    panic("init exiting");
    80002172:	00005517          	auipc	a0,0x5
    80002176:	14e50513          	addi	a0,a0,334 # 800072c0 <etext+0x2c0>
    8000217a:	e1afe0ef          	jal	80000794 <panic>
        thread->trapframe = 0;
    8000217e:	0604b023          	sd	zero,96(s1)
        thread->trapframe_va = 0;
    80002182:	0404bc23          	sd	zero,88(s1)
        thread->sz = 0;
    80002186:	0404b423          	sd	zero,72(s1)
        thread->pid = 0;
    8000218a:	0204a823          	sw	zero,48(s1)
        thread->parent = 0;
    8000218e:	0204bc23          	sd	zero,56(s1)
        thread->name[0] = 0;
    80002192:	16048023          	sb	zero,352(s1)
        thread->chan = 0;
    80002196:	0204b023          	sd	zero,32(s1)
        thread->killed = 0;
    8000219a:	0204a423          	sw	zero,40(s1)
        thread->xstate = 0;
    8000219e:	0204a623          	sw	zero,44(s1)
        thread->state = UNUSED;
    800021a2:	0004ac23          	sw	zero,24(s1)
        thread->tid = 0;
    800021a6:	1604ac23          	sw	zero,376(s1)
        thread->main_thread = 0;
    800021aa:	1604b823          	sd	zero,368(s1)
        thread->stack = 0;
    800021ae:	1804b023          	sd	zero,384(s1)
      release(&thread->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	ad9fe0ef          	jal	80000c8c <release>
    for(thread = proc; thread < &proc[NPROC]; thread++){
    800021b8:	19048493          	addi	s1,s1,400
    800021bc:	03348963          	beq	s1,s3,800021ee <exit+0xbe>
      acquire(&thread->lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	a33fe0ef          	jal	80000bf4 <acquire>
      if(thread->pid == p->pid && thread->tid != 0){
    800021c6:	5898                	lw	a4,48(s1)
    800021c8:	03092783          	lw	a5,48(s2)
    800021cc:	fef713e3          	bne	a4,a5,800021b2 <exit+0x82>
    800021d0:	1784a783          	lw	a5,376(s1)
    800021d4:	dff9                	beqz	a5,800021b2 <exit+0x82>
        if(thread->trapframe) {
    800021d6:	70bc                	ld	a5,96(s1)
    800021d8:	d3dd                	beqz	a5,8000217e <exit+0x4e>
          uvmunmap(thread->pagetable, thread->trapframe_va, 1, 0);
    800021da:	4681                	li	a3,0
    800021dc:	4605                	li	a2,1
    800021de:	6cac                	ld	a1,88(s1)
    800021e0:	68a8                	ld	a0,80(s1)
    800021e2:	80eff0ef          	jal	800011f0 <uvmunmap>
          kfree((void*)thread->trapframe);
    800021e6:	70a8                	ld	a0,96(s1)
    800021e8:	85bfe0ef          	jal	80000a42 <kfree>
    800021ec:	bf49                	j	8000217e <exit+0x4e>
  for(int fd = 0; fd < NOFILE; fd++){
    800021ee:	0d890493          	addi	s1,s2,216
    800021f2:	15890993          	addi	s3,s2,344
    800021f6:	a801                	j	80002206 <exit+0xd6>
      fileclose(f);
    800021f8:	278020ef          	jal	80004470 <fileclose>
      p->ofile[fd] = 0;
    800021fc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002200:	04a1                	addi	s1,s1,8
    80002202:	01348563          	beq	s1,s3,8000220c <exit+0xdc>
    if(p->ofile[fd]){
    80002206:	6088                	ld	a0,0(s1)
    80002208:	f965                	bnez	a0,800021f8 <exit+0xc8>
    8000220a:	bfdd                	j	80002200 <exit+0xd0>
  begin_op();
    8000220c:	64b010ef          	jal	80004056 <begin_op>
  iput(p->cwd);
    80002210:	15893503          	ld	a0,344(s2)
    80002214:	72e010ef          	jal	80003942 <iput>
  end_op();
    80002218:	6a9010ef          	jal	800040c0 <end_op>
  p->cwd = 0;
    8000221c:	14093c23          	sd	zero,344(s2)
  acquire(&wait_lock);
    80002220:	0000e517          	auipc	a0,0xe
    80002224:	87850513          	addi	a0,a0,-1928 # 8000fa98 <wait_lock>
    80002228:	9cdfe0ef          	jal	80000bf4 <acquire>
  if(p->tid == 0){
    8000222c:	17892783          	lw	a5,376(s2)
    80002230:	ef95                	bnez	a5,8000226c <exit+0x13c>
    reparent(p);
    80002232:	854a                	mv	a0,s2
    80002234:	ea7ff0ef          	jal	800020da <reparent>
    wakeup(p->parent);
    80002238:	03893503          	ld	a0,56(s2)
    8000223c:	e35ff0ef          	jal	80002070 <wakeup>
  acquire(&p->lock);
    80002240:	854a                	mv	a0,s2
    80002242:	9b3fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    80002246:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    8000224a:	4795                	li	a5,5
    8000224c:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002250:	0000e517          	auipc	a0,0xe
    80002254:	84850513          	addi	a0,a0,-1976 # 8000fa98 <wait_lock>
    80002258:	a35fe0ef          	jal	80000c8c <release>
  sched();
    8000225c:	ce3ff0ef          	jal	80001f3e <sched>
  panic("zombie exit");
    80002260:	00005517          	auipc	a0,0x5
    80002264:	07050513          	addi	a0,a0,112 # 800072d0 <etext+0x2d0>
    80002268:	d2cfe0ef          	jal	80000794 <panic>
    wakeup(p->main_thread);
    8000226c:	17093503          	ld	a0,368(s2)
    80002270:	e01ff0ef          	jal	80002070 <wakeup>
    80002274:	b7f1                	j	80002240 <exit+0x110>

0000000080002276 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002276:	7179                	addi	sp,sp,-48
    80002278:	f406                	sd	ra,40(sp)
    8000227a:	f022                	sd	s0,32(sp)
    8000227c:	ec26                	sd	s1,24(sp)
    8000227e:	e84a                	sd	s2,16(sp)
    80002280:	e44e                	sd	s3,8(sp)
    80002282:	e052                	sd	s4,0(sp)
    80002284:	1800                	addi	s0,sp,48
    80002286:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002288:	0000e497          	auipc	s1,0xe
    8000228c:	c2848493          	addi	s1,s1,-984 # 8000feb0 <proc>
    80002290:	00014a17          	auipc	s4,0x14
    80002294:	020a0a13          	addi	s4,s4,32 # 800162b0 <tickslock>
    80002298:	a819                	j	800022ae <kill+0x38>
    acquire(&p->lock);
    if(p->pid == pid && p->tid == 0){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
    8000229a:	478d                	li	a5,3
    8000229c:	cc9c                	sw	a5,24(s1)
    8000229e:	a805                	j	800022ce <kill+0x58>
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	9ebfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a6:	19048493          	addi	s1,s1,400
    800022aa:	03448e63          	beq	s1,s4,800022e6 <kill+0x70>
    acquire(&p->lock);
    800022ae:	8526                	mv	a0,s1
    800022b0:	945fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid && p->tid == 0){
    800022b4:	589c                	lw	a5,48(s1)
    800022b6:	ff2795e3          	bne	a5,s2,800022a0 <kill+0x2a>
    800022ba:	1784a983          	lw	s3,376(s1)
    800022be:	fe0991e3          	bnez	s3,800022a0 <kill+0x2a>
      p->killed = 1;
    800022c2:	4785                	li	a5,1
    800022c4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022c6:	4c98                	lw	a4,24(s1)
    800022c8:	4789                	li	a5,2
    800022ca:	fcf708e3          	beq	a4,a5,8000229a <kill+0x24>
      release(&p->lock);
    800022ce:	8526                	mv	a0,s1
    800022d0:	9bdfe0ef          	jal	80000c8c <release>
  }
  return -1;
}
    800022d4:	854e                	mv	a0,s3
    800022d6:	70a2                	ld	ra,40(sp)
    800022d8:	7402                	ld	s0,32(sp)
    800022da:	64e2                	ld	s1,24(sp)
    800022dc:	6942                	ld	s2,16(sp)
    800022de:	69a2                	ld	s3,8(sp)
    800022e0:	6a02                	ld	s4,0(sp)
    800022e2:	6145                	addi	sp,sp,48
    800022e4:	8082                	ret
  return -1;
    800022e6:	59fd                	li	s3,-1
    800022e8:	b7f5                	j	800022d4 <kill+0x5e>

00000000800022ea <setkilled>:

void
setkilled(struct proc *p)
{
    800022ea:	1101                	addi	sp,sp,-32
    800022ec:	ec06                	sd	ra,24(sp)
    800022ee:	e822                	sd	s0,16(sp)
    800022f0:	e426                	sd	s1,8(sp)
    800022f2:	1000                	addi	s0,sp,32
    800022f4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f6:	8fffe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800022fa:	4785                	li	a5,1
    800022fc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022fe:	8526                	mv	a0,s1
    80002300:	98dfe0ef          	jal	80000c8c <release>
}
    80002304:	60e2                	ld	ra,24(sp)
    80002306:	6442                	ld	s0,16(sp)
    80002308:	64a2                	ld	s1,8(sp)
    8000230a:	6105                	addi	sp,sp,32
    8000230c:	8082                	ret

000000008000230e <killed>:

int
killed(struct proc *p)
{
    8000230e:	1101                	addi	sp,sp,-32
    80002310:	ec06                	sd	ra,24(sp)
    80002312:	e822                	sd	s0,16(sp)
    80002314:	e426                	sd	s1,8(sp)
    80002316:	e04a                	sd	s2,0(sp)
    80002318:	1000                	addi	s0,sp,32
    8000231a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000231c:	8d9fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002320:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	967fe0ef          	jal	80000c8c <release>
  return k;
}
    8000232a:	854a                	mv	a0,s2
    8000232c:	60e2                	ld	ra,24(sp)
    8000232e:	6442                	ld	s0,16(sp)
    80002330:	64a2                	ld	s1,8(sp)
    80002332:	6902                	ld	s2,0(sp)
    80002334:	6105                	addi	sp,sp,32
    80002336:	8082                	ret

0000000080002338 <wait>:
{
    80002338:	715d                	addi	sp,sp,-80
    8000233a:	e486                	sd	ra,72(sp)
    8000233c:	e0a2                	sd	s0,64(sp)
    8000233e:	fc26                	sd	s1,56(sp)
    80002340:	f84a                	sd	s2,48(sp)
    80002342:	f44e                	sd	s3,40(sp)
    80002344:	f052                	sd	s4,32(sp)
    80002346:	ec56                	sd	s5,24(sp)
    80002348:	e85a                	sd	s6,16(sp)
    8000234a:	e45e                	sd	s7,8(sp)
    8000234c:	e062                	sd	s8,0(sp)
    8000234e:	0880                	addi	s0,sp,80
    80002350:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002352:	ebcff0ef          	jal	80001a0e <myproc>
    80002356:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002358:	0000d517          	auipc	a0,0xd
    8000235c:	74050513          	addi	a0,a0,1856 # 8000fa98 <wait_lock>
    80002360:	895fe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    80002364:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002366:	4a15                	li	s4,5
        havekids = 1;
    80002368:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000236a:	00014997          	auipc	s3,0x14
    8000236e:	f4698993          	addi	s3,s3,-186 # 800162b0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002372:	0000dc17          	auipc	s8,0xd
    80002376:	726c0c13          	addi	s8,s8,1830 # 8000fa98 <wait_lock>
    8000237a:	a871                	j	80002416 <wait+0xde>
          pid = pp->pid;
    8000237c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002380:	000b0c63          	beqz	s6,80002398 <wait+0x60>
    80002384:	4691                	li	a3,4
    80002386:	02c48613          	addi	a2,s1,44
    8000238a:	85da                	mv	a1,s6
    8000238c:	05093503          	ld	a0,80(s2)
    80002390:	af0ff0ef          	jal	80001680 <copyout>
    80002394:	02054b63          	bltz	a0,800023ca <wait+0x92>
          freeproc(pp);
    80002398:	8526                	mv	a0,s1
    8000239a:	feaff0ef          	jal	80001b84 <freeproc>
          release(&pp->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	8edfe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800023a4:	0000d517          	auipc	a0,0xd
    800023a8:	6f450513          	addi	a0,a0,1780 # 8000fa98 <wait_lock>
    800023ac:	8e1fe0ef          	jal	80000c8c <release>
}
    800023b0:	854e                	mv	a0,s3
    800023b2:	60a6                	ld	ra,72(sp)
    800023b4:	6406                	ld	s0,64(sp)
    800023b6:	74e2                	ld	s1,56(sp)
    800023b8:	7942                	ld	s2,48(sp)
    800023ba:	79a2                	ld	s3,40(sp)
    800023bc:	7a02                	ld	s4,32(sp)
    800023be:	6ae2                	ld	s5,24(sp)
    800023c0:	6b42                	ld	s6,16(sp)
    800023c2:	6ba2                	ld	s7,8(sp)
    800023c4:	6c02                	ld	s8,0(sp)
    800023c6:	6161                	addi	sp,sp,80
    800023c8:	8082                	ret
            release(&pp->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	8c1fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800023d0:	0000d517          	auipc	a0,0xd
    800023d4:	6c850513          	addi	a0,a0,1736 # 8000fa98 <wait_lock>
    800023d8:	8b5fe0ef          	jal	80000c8c <release>
            return -1;
    800023dc:	59fd                	li	s3,-1
    800023de:	bfc9                	j	800023b0 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e0:	19048493          	addi	s1,s1,400
    800023e4:	03348063          	beq	s1,s3,80002404 <wait+0xcc>
      if(pp->parent == p){
    800023e8:	7c9c                	ld	a5,56(s1)
    800023ea:	ff279be3          	bne	a5,s2,800023e0 <wait+0xa8>
        acquire(&pp->lock);
    800023ee:	8526                	mv	a0,s1
    800023f0:	805fe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800023f4:	4c9c                	lw	a5,24(s1)
    800023f6:	f94783e3          	beq	a5,s4,8000237c <wait+0x44>
        release(&pp->lock);
    800023fa:	8526                	mv	a0,s1
    800023fc:	891fe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002400:	8756                	mv	a4,s5
    80002402:	bff9                	j	800023e0 <wait+0xa8>
    if(!havekids || killed(p)){
    80002404:	cf19                	beqz	a4,80002422 <wait+0xea>
    80002406:	854a                	mv	a0,s2
    80002408:	f07ff0ef          	jal	8000230e <killed>
    8000240c:	e919                	bnez	a0,80002422 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000240e:	85e2                	mv	a1,s8
    80002410:	854a                	mv	a0,s2
    80002412:	c13ff0ef          	jal	80002024 <sleep>
    havekids = 0;
    80002416:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002418:	0000e497          	auipc	s1,0xe
    8000241c:	a9848493          	addi	s1,s1,-1384 # 8000feb0 <proc>
    80002420:	b7e1                	j	800023e8 <wait+0xb0>
      release(&wait_lock);
    80002422:	0000d517          	auipc	a0,0xd
    80002426:	67650513          	addi	a0,a0,1654 # 8000fa98 <wait_lock>
    8000242a:	863fe0ef          	jal	80000c8c <release>
      return -1;
    8000242e:	59fd                	li	s3,-1
    80002430:	b741                	j	800023b0 <wait+0x78>

0000000080002432 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002432:	7179                	addi	sp,sp,-48
    80002434:	f406                	sd	ra,40(sp)
    80002436:	f022                	sd	s0,32(sp)
    80002438:	ec26                	sd	s1,24(sp)
    8000243a:	e84a                	sd	s2,16(sp)
    8000243c:	e44e                	sd	s3,8(sp)
    8000243e:	e052                	sd	s4,0(sp)
    80002440:	1800                	addi	s0,sp,48
    80002442:	84aa                	mv	s1,a0
    80002444:	892e                	mv	s2,a1
    80002446:	89b2                	mv	s3,a2
    80002448:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000244a:	dc4ff0ef          	jal	80001a0e <myproc>
  if(user_dst){
    8000244e:	cc99                	beqz	s1,8000246c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002450:	86d2                	mv	a3,s4
    80002452:	864e                	mv	a2,s3
    80002454:	85ca                	mv	a1,s2
    80002456:	6928                	ld	a0,80(a0)
    80002458:	a28ff0ef          	jal	80001680 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000245c:	70a2                	ld	ra,40(sp)
    8000245e:	7402                	ld	s0,32(sp)
    80002460:	64e2                	ld	s1,24(sp)
    80002462:	6942                	ld	s2,16(sp)
    80002464:	69a2                	ld	s3,8(sp)
    80002466:	6a02                	ld	s4,0(sp)
    80002468:	6145                	addi	sp,sp,48
    8000246a:	8082                	ret
    memmove((char *)dst, src, len);
    8000246c:	000a061b          	sext.w	a2,s4
    80002470:	85ce                	mv	a1,s3
    80002472:	854a                	mv	a0,s2
    80002474:	8b1fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002478:	8526                	mv	a0,s1
    8000247a:	b7cd                	j	8000245c <either_copyout+0x2a>

000000008000247c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000247c:	7179                	addi	sp,sp,-48
    8000247e:	f406                	sd	ra,40(sp)
    80002480:	f022                	sd	s0,32(sp)
    80002482:	ec26                	sd	s1,24(sp)
    80002484:	e84a                	sd	s2,16(sp)
    80002486:	e44e                	sd	s3,8(sp)
    80002488:	e052                	sd	s4,0(sp)
    8000248a:	1800                	addi	s0,sp,48
    8000248c:	892a                	mv	s2,a0
    8000248e:	84ae                	mv	s1,a1
    80002490:	89b2                	mv	s3,a2
    80002492:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002494:	d7aff0ef          	jal	80001a0e <myproc>
  if(user_src){
    80002498:	cc99                	beqz	s1,800024b6 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000249a:	86d2                	mv	a3,s4
    8000249c:	864e                	mv	a2,s3
    8000249e:	85ca                	mv	a1,s2
    800024a0:	6928                	ld	a0,80(a0)
    800024a2:	ab4ff0ef          	jal	80001756 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024a6:	70a2                	ld	ra,40(sp)
    800024a8:	7402                	ld	s0,32(sp)
    800024aa:	64e2                	ld	s1,24(sp)
    800024ac:	6942                	ld	s2,16(sp)
    800024ae:	69a2                	ld	s3,8(sp)
    800024b0:	6a02                	ld	s4,0(sp)
    800024b2:	6145                	addi	sp,sp,48
    800024b4:	8082                	ret
    memmove(dst, (char*)src, len);
    800024b6:	000a061b          	sext.w	a2,s4
    800024ba:	85ce                	mv	a1,s3
    800024bc:	854a                	mv	a0,s2
    800024be:	867fe0ef          	jal	80000d24 <memmove>
    return 0;
    800024c2:	8526                	mv	a0,s1
    800024c4:	b7cd                	j	800024a6 <either_copyin+0x2a>

00000000800024c6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024c6:	715d                	addi	sp,sp,-80
    800024c8:	e486                	sd	ra,72(sp)
    800024ca:	e0a2                	sd	s0,64(sp)
    800024cc:	fc26                	sd	s1,56(sp)
    800024ce:	f84a                	sd	s2,48(sp)
    800024d0:	f44e                	sd	s3,40(sp)
    800024d2:	f052                	sd	s4,32(sp)
    800024d4:	ec56                	sd	s5,24(sp)
    800024d6:	e85a                	sd	s6,16(sp)
    800024d8:	e45e                	sd	s7,8(sp)
    800024da:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024dc:	00005517          	auipc	a0,0x5
    800024e0:	b9c50513          	addi	a0,a0,-1124 # 80007078 <etext+0x78>
    800024e4:	fdffd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024e8:	0000e497          	auipc	s1,0xe
    800024ec:	b2848493          	addi	s1,s1,-1240 # 80010010 <proc+0x160>
    800024f0:	00014917          	auipc	s2,0x14
    800024f4:	f2090913          	addi	s2,s2,-224 # 80016410 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024f8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024fa:	00005997          	auipc	s3,0x5
    800024fe:	de698993          	addi	s3,s3,-538 # 800072e0 <etext+0x2e0>
    printf("%d %s %s", p->pid, state, p->name);
    80002502:	00005a97          	auipc	s5,0x5
    80002506:	de6a8a93          	addi	s5,s5,-538 # 800072e8 <etext+0x2e8>
    printf("\n");
    8000250a:	00005a17          	auipc	s4,0x5
    8000250e:	b6ea0a13          	addi	s4,s4,-1170 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002512:	00005b97          	auipc	s7,0x5
    80002516:	2b6b8b93          	addi	s7,s7,694 # 800077c8 <states.0>
    8000251a:	a829                	j	80002534 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000251c:	ed06a583          	lw	a1,-304(a3)
    80002520:	8556                	mv	a0,s5
    80002522:	fa1fd0ef          	jal	800004c2 <printf>
    printf("\n");
    80002526:	8552                	mv	a0,s4
    80002528:	f9bfd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000252c:	19048493          	addi	s1,s1,400
    80002530:	03248263          	beq	s1,s2,80002554 <procdump+0x8e>
    if(p->state == UNUSED)
    80002534:	86a6                	mv	a3,s1
    80002536:	eb84a783          	lw	a5,-328(s1)
    8000253a:	dbed                	beqz	a5,8000252c <procdump+0x66>
      state = "???";
    8000253c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253e:	fcfb6fe3          	bltu	s6,a5,8000251c <procdump+0x56>
    80002542:	02079713          	slli	a4,a5,0x20
    80002546:	01d75793          	srli	a5,a4,0x1d
    8000254a:	97de                	add	a5,a5,s7
    8000254c:	6390                	ld	a2,0(a5)
    8000254e:	f679                	bnez	a2,8000251c <procdump+0x56>
      state = "???";
    80002550:	864e                	mv	a2,s3
    80002552:	b7e9                	j	8000251c <procdump+0x56>
  }
}
    80002554:	60a6                	ld	ra,72(sp)
    80002556:	6406                	ld	s0,64(sp)
    80002558:	74e2                	ld	s1,56(sp)
    8000255a:	7942                	ld	s2,48(sp)
    8000255c:	79a2                	ld	s3,40(sp)
    8000255e:	7a02                	ld	s4,32(sp)
    80002560:	6ae2                	ld	s5,24(sp)
    80002562:	6b42                	ld	s6,16(sp)
    80002564:	6ba2                	ld	s7,8(sp)
    80002566:	6161                	addi	sp,sp,80
    80002568:	8082                	ret

000000008000256a <clone>:

/* implementation for project02 */
int
clone(void (*fcn)(void*, void*), void *arg1, void *arg2, void *stack)
{
    8000256a:	711d                	addi	sp,sp,-96
    8000256c:	ec86                	sd	ra,88(sp)
    8000256e:	e8a2                	sd	s0,80(sp)
    80002570:	e4a6                	sd	s1,72(sp)
    80002572:	e0ca                	sd	s2,64(sp)
    80002574:	f852                	sd	s4,48(sp)
    80002576:	f456                	sd	s5,40(sp)
    80002578:	f05a                	sd	s6,32(sp)
    8000257a:	ec5e                	sd	s7,24(sp)
    8000257c:	e862                	sd	s8,16(sp)
    8000257e:	1080                	addi	s0,sp,96
    80002580:	8c2a                	mv	s8,a0
    80002582:	8bae                	mv	s7,a1
    80002584:	8b32                	mv	s6,a2
    80002586:	8ab6                	mv	s5,a3
  struct proc *np;
  struct proc *p = myproc();
    80002588:	c86ff0ef          	jal	80001a0e <myproc>
  struct proc *main_thread;
  
  if (p->main_thread){
    8000258c:	17053a03          	ld	s4,368(a0)
    80002590:	020a0863          	beqz	s4,800025c0 <clone+0x56>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002594:	0000e497          	auipc	s1,0xe
    80002598:	91c48493          	addi	s1,s1,-1764 # 8000feb0 <proc>
    8000259c:	00014917          	auipc	s2,0x14
    800025a0:	d1490913          	addi	s2,s2,-748 # 800162b0 <tickslock>
    acquire(&p->lock);
    800025a4:	8526                	mv	a0,s1
    800025a6:	e4efe0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    800025aa:	4c9c                	lw	a5,24(s1)
    800025ac:	cf81                	beqz	a5,800025c4 <clone+0x5a>
      release(&p->lock);
    800025ae:	8526                	mv	a0,s1
    800025b0:	edcfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025b4:	19048493          	addi	s1,s1,400
    800025b8:	ff2496e3          	bne	s1,s2,800025a4 <clone+0x3a>
  else{
    main_thread = p;
  }

  if((np = allocproc_for_clone(main_thread)) == 0){
    return -1;
    800025bc:	557d                	li	a0,-1
    800025be:	aa8d                	j	80002730 <clone+0x1c6>
    main_thread = p;
    800025c0:	8a2a                	mv	s4,a0
    800025c2:	bfc9                	j	80002594 <clone+0x2a>
    800025c4:	fc4e                	sd	s3,56(sp)
    800025c6:	e466                	sd	s9,8(sp)
  p->pid = main_thread->pid;
    800025c8:	030a2783          	lw	a5,48(s4)
    800025cc:	d89c                	sw	a5,48(s1)
  p->state = USED;
    800025ce:	4785                	li	a5,1
    800025d0:	cc9c                	sw	a5,24(s1)
  p->main_thread = main_thread;
    800025d2:	1744b823          	sd	s4,368(s1)
  p->tid = nexttid;
    800025d6:	00005717          	auipc	a4,0x5
    800025da:	2fe70713          	addi	a4,a4,766 # 800078d4 <nexttid>
    800025de:	431c                	lw	a5,0(a4)
    800025e0:	16f4ac23          	sw	a5,376(s1)
  nexttid++;
    800025e4:	2785                	addiw	a5,a5,1
    800025e6:	c31c                	sw	a5,0(a4)
  p->stack = 0;
    800025e8:	1804b023          	sd	zero,384(s1)
  p->main_sz = &(main_thread->sz);
    800025ec:	048a0793          	addi	a5,s4,72
    800025f0:	18f4b423          	sd	a5,392(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800025f4:	d30fe0ef          	jal	80000b24 <kalloc>
    800025f8:	f0a8                	sd	a0,96(s1)
    800025fa:	c145                	beqz	a0,8000269a <clone+0x130>
  memset(&p->context, 0, sizeof(p->context));
    800025fc:	07000613          	li	a2,112
    80002600:	4581                	li	a1,0
    80002602:	06848513          	addi	a0,s1,104
    80002606:	ec2fe0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    8000260a:	fffff797          	auipc	a5,0xfffff
    8000260e:	43478793          	addi	a5,a5,1076 # 80001a3e <forkret>
    80002612:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002614:	60bc                	ld	a5,64(s1)
    80002616:	6705                	lui	a4,0x1
    80002618:	97ba                	add	a5,a5,a4
    8000261a:	f8bc                	sd	a5,112(s1)
  }

  np->sz = *(np->main_sz);
    8000261c:	1884b783          	ld	a5,392(s1)
    80002620:	639c                	ld	a5,0(a5)
    80002622:	e4bc                	sd	a5,72(s1)
  np->parent = main_thread->parent;
    80002624:	038a3783          	ld	a5,56(s4)
    80002628:	fc9c                	sd	a5,56(s1)
  np->main_thread = main_thread;
    8000262a:	1744b823          	sd	s4,368(s1)
  np->stack = stack;
    8000262e:	1954b023          	sd	s5,384(s1)
  np->pid = main_thread->pid;
    80002632:	030a2783          	lw	a5,48(s4)
    80002636:	d89c                	sw	a5,48(s1)
  *(np->trapframe) = *(main_thread->trapframe);
    80002638:	060a3683          	ld	a3,96(s4)
    8000263c:	87b6                	mv	a5,a3
    8000263e:	70b8                	ld	a4,96(s1)
    80002640:	12068693          	addi	a3,a3,288
    80002644:	0007b803          	ld	a6,0(a5)
    80002648:	6788                	ld	a0,8(a5)
    8000264a:	6b8c                	ld	a1,16(a5)
    8000264c:	6f90                	ld	a2,24(a5)
    8000264e:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002652:	e708                	sd	a0,8(a4)
    80002654:	eb0c                	sd	a1,16(a4)
    80002656:	ef10                	sd	a2,24(a4)
    80002658:	02078793          	addi	a5,a5,32
    8000265c:	02070713          	addi	a4,a4,32
    80002660:	fed792e3          	bne	a5,a3,80002644 <clone+0xda>
  
  np->pagetable = main_thread->pagetable;
    80002664:	050a3503          	ld	a0,80(s4)
    80002668:	e8a8                	sd	a0,80(s1)
  np->trapframe_va = TRAPFRAME - np->tid * PGSIZE;
    8000266a:	1784a783          	lw	a5,376(s1)
    8000266e:	00c7979b          	slliw	a5,a5,0xc
    80002672:	020005b7          	lui	a1,0x2000
    80002676:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80002678:	05b6                	slli	a1,a1,0xd
    8000267a:	8d9d                	sub	a1,a1,a5
    8000267c:	ecac                	sd	a1,88(s1)

  if (mappages(np->pagetable, np->trapframe_va, PGSIZE,
    8000267e:	4719                	li	a4,6
    80002680:	70b4                	ld	a3,96(s1)
    80002682:	6605                	lui	a2,0x1
    80002684:	9c7fe0ef          	jal	8000104a <mappages>
    80002688:	02054363          	bltz	a0,800026ae <clone+0x144>
    8000268c:	0d8a0913          	addi	s2,s4,216
    80002690:	0d848993          	addi	s3,s1,216
    80002694:	158a0c93          	addi	s9,s4,344
    80002698:	a825                	j	800026d0 <clone+0x166>
    freeproc(p);
    8000269a:	8526                	mv	a0,s1
    8000269c:	ce8ff0ef          	jal	80001b84 <freeproc>
    release(&p->lock);
    800026a0:	8526                	mv	a0,s1
    800026a2:	deafe0ef          	jal	80000c8c <release>
    return -1;
    800026a6:	557d                	li	a0,-1
    800026a8:	79e2                	ld	s3,56(sp)
    800026aa:	6ca2                	ld	s9,8(sp)
    800026ac:	a051                	j	80002730 <clone+0x1c6>
              (uint64)(np->trapframe), PTE_R | PTE_W) < 0) {
    uvmunmap(np->pagetable, np->trapframe_va, 1, 0);
    800026ae:	4681                	li	a3,0
    800026b0:	4605                	li	a2,1
    800026b2:	6cac                	ld	a1,88(s1)
    800026b4:	68a8                	ld	a0,80(s1)
    800026b6:	b3bfe0ef          	jal	800011f0 <uvmunmap>
    freeproc(np);
    800026ba:	8526                	mv	a0,s1
    800026bc:	cc8ff0ef          	jal	80001b84 <freeproc>
    return -1;
    800026c0:	557d                	li	a0,-1
    800026c2:	79e2                	ld	s3,56(sp)
    800026c4:	6ca2                	ld	s9,8(sp)
    800026c6:	a0ad                	j	80002730 <clone+0x1c6>
  }

  for(int i = 0; i < NOFILE; i++){
    800026c8:	0921                	addi	s2,s2,8
    800026ca:	09a1                	addi	s3,s3,8
    800026cc:	01990a63          	beq	s2,s9,800026e0 <clone+0x176>
    if(main_thread->ofile[i])
    800026d0:	00093503          	ld	a0,0(s2)
    800026d4:	d975                	beqz	a0,800026c8 <clone+0x15e>
      np->ofile[i] = filedup(main_thread->ofile[i]);
    800026d6:	555010ef          	jal	8000442a <filedup>
    800026da:	00a9b023          	sd	a0,0(s3)
    800026de:	b7ed                	j	800026c8 <clone+0x15e>
  }

  np->cwd = idup(main_thread->cwd);
    800026e0:	158a3503          	ld	a0,344(s4)
    800026e4:	0a6010ef          	jal	8000378a <idup>
    800026e8:	14a4bc23          	sd	a0,344(s1)

  safestrcpy(np->name, main_thread->name, sizeof(main_thread->name));
    800026ec:	4641                	li	a2,16
    800026ee:	160a0593          	addi	a1,s4,352
    800026f2:	16048513          	addi	a0,s1,352
    800026f6:	f10fe0ef          	jal	80000e06 <safestrcpy>

  np->trapframe->epc = (uint64)fcn;
    800026fa:	70bc                	ld	a5,96(s1)
    800026fc:	0187bc23          	sd	s8,24(a5)
  np->trapframe->sp = PGROUNDUP((uint64)stack) + PGSIZE;
    80002700:	70b4                	ld	a3,96(s1)
    80002702:	6705                	lui	a4,0x1
    80002704:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80002708:	97d6                	add	a5,a5,s5
    8000270a:	767d                	lui	a2,0xfffff
    8000270c:	8ff1                	and	a5,a5,a2
    8000270e:	97ba                	add	a5,a5,a4
    80002710:	fa9c                	sd	a5,48(a3)
  np->trapframe->a0 = (uint64)arg1;
    80002712:	70bc                	ld	a5,96(s1)
    80002714:	0777b823          	sd	s7,112(a5)
  np->trapframe->a1 = (uint64)arg2;
    80002718:	70bc                	ld	a5,96(s1)
    8000271a:	0767bc23          	sd	s6,120(a5)

  np->state = RUNNABLE;
    8000271e:	478d                	li	a5,3
    80002720:	cc9c                	sw	a5,24(s1)

  release(&np->lock);
    80002722:	8526                	mv	a0,s1
    80002724:	d68fe0ef          	jal	80000c8c <release>

  return np->tid;
    80002728:	1784a503          	lw	a0,376(s1)
    8000272c:	79e2                	ld	s3,56(sp)
    8000272e:	6ca2                	ld	s9,8(sp)
}
    80002730:	60e6                	ld	ra,88(sp)
    80002732:	6446                	ld	s0,80(sp)
    80002734:	64a6                	ld	s1,72(sp)
    80002736:	6906                	ld	s2,64(sp)
    80002738:	7a42                	ld	s4,48(sp)
    8000273a:	7aa2                	ld	s5,40(sp)
    8000273c:	7b02                	ld	s6,32(sp)
    8000273e:	6be2                	ld	s7,24(sp)
    80002740:	6c42                	ld	s8,16(sp)
    80002742:	6125                	addi	sp,sp,96
    80002744:	8082                	ret

0000000080002746 <join>:

int
join(void **stack)
{
    80002746:	711d                	addi	sp,sp,-96
    80002748:	ec86                	sd	ra,88(sp)
    8000274a:	e8a2                	sd	s0,80(sp)
    8000274c:	e0ca                	sd	s2,64(sp)
    8000274e:	ec5e                	sd	s7,24(sp)
    80002750:	e862                	sd	s8,16(sp)
    80002752:	e466                	sd	s9,8(sp)
    80002754:	1080                	addi	s0,sp,96
    80002756:	8baa                	mv	s7,a0
  struct proc *p;
  struct proc *curproc = myproc();
    80002758:	ab6ff0ef          	jal	80001a0e <myproc>
    8000275c:	892a                	mv	s2,a0
  int havekids;
  int pid;

  acquire(&wait_lock);
    8000275e:	0000d517          	auipc	a0,0xd
    80002762:	33a50513          	addi	a0,a0,826 # 8000fa98 <wait_lock>
    80002766:	c8efe0ef          	jal	80000bf4 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;

    if(curproc->tid == 0){
    8000276a:	17892c03          	lw	s8,376(s2)
    8000276e:	020c0263          	beqz	s8,80002792 <join+0x4c>
        release(&p->lock);
      }
    }

    if(!havekids || killed(curproc)){
      release(&wait_lock);
    80002772:	0000d517          	auipc	a0,0xd
    80002776:	32650513          	addi	a0,a0,806 # 8000fa98 <wait_lock>
    8000277a:	d12fe0ef          	jal	80000c8c <release>
      return -1;
    8000277e:	5cfd                	li	s9,-1
    }

    // Wait for a child to exit.
    sleep(curproc, &wait_lock);  //DOC: wait-sleep
  }
}
    80002780:	8566                	mv	a0,s9
    80002782:	60e6                	ld	ra,88(sp)
    80002784:	6446                	ld	s0,80(sp)
    80002786:	6906                	ld	s2,64(sp)
    80002788:	6be2                	ld	s7,24(sp)
    8000278a:	6c42                	ld	s8,16(sp)
    8000278c:	6ca2                	ld	s9,8(sp)
    8000278e:	6125                	addi	sp,sp,96
    80002790:	8082                	ret
    80002792:	e4a6                	sd	s1,72(sp)
    80002794:	fc4e                	sd	s3,56(sp)
    80002796:	f852                	sd	s4,48(sp)
    80002798:	f456                	sd	s5,40(sp)
    8000279a:	f05a                	sd	s6,32(sp)
          if(p->state == ZOMBIE){
    8000279c:	4a95                	li	s5,5
          havekids = 1;
    8000279e:	4b05                	li	s6,1
      for(p = proc; p < &proc[NPROC]; p++){
    800027a0:	00014a17          	auipc	s4,0x14
    800027a4:	b10a0a13          	addi	s4,s4,-1264 # 800162b0 <tickslock>
      pid = curproc->pid;
    800027a8:	03092c83          	lw	s9,48(s2)
    havekids = 0;
    800027ac:	89e2                	mv	s3,s8
      for(p = proc; p < &proc[NPROC]; p++){
    800027ae:	0000d497          	auipc	s1,0xd
    800027b2:	70248493          	addi	s1,s1,1794 # 8000feb0 <proc>
    800027b6:	a05d                	j	8000285c <join+0x116>
            if (copyout(curproc->pagetable, (uint64)stack, (char *)&p->stack, sizeof(uint64)) < 0) {
    800027b8:	46a1                	li	a3,8
    800027ba:	18048613          	addi	a2,s1,384
    800027be:	85de                	mv	a1,s7
    800027c0:	05093503          	ld	a0,80(s2)
    800027c4:	ebdfe0ef          	jal	80001680 <copyout>
    800027c8:	06054663          	bltz	a0,80002834 <join+0xee>
            if(p->trapframe){
    800027cc:	70bc                	ld	a5,96(s1)
    800027ce:	cb91                	beqz	a5,800027e2 <join+0x9c>
              uvmunmap(p->pagetable, p->trapframe_va, 1, 0);
    800027d0:	4681                	li	a3,0
    800027d2:	4605                	li	a2,1
    800027d4:	6cac                	ld	a1,88(s1)
    800027d6:	68a8                	ld	a0,80(s1)
    800027d8:	a19fe0ef          	jal	800011f0 <uvmunmap>
              kfree((void*)p->trapframe);
    800027dc:	70a8                	ld	a0,96(s1)
    800027de:	a64fe0ef          	jal	80000a42 <kfree>
            p->trapframe = 0;
    800027e2:	0604b023          	sd	zero,96(s1)
            p->trapframe_va = 0;
    800027e6:	0404bc23          	sd	zero,88(s1)
            p->sz = 0;
    800027ea:	0404b423          	sd	zero,72(s1)
            p->pid = 0;
    800027ee:	0204a823          	sw	zero,48(s1)
            p->parent = 0;
    800027f2:	0204bc23          	sd	zero,56(s1)
            p->name[0] = 0;
    800027f6:	16048023          	sb	zero,352(s1)
            p->chan = 0;
    800027fa:	0204b023          	sd	zero,32(s1)
            p->killed = 0;
    800027fe:	0204a423          	sw	zero,40(s1)
            p->xstate = 0;
    80002802:	0204a623          	sw	zero,44(s1)
            p->state = UNUSED;
    80002806:	0004ac23          	sw	zero,24(s1)
            p->tid = 0;
    8000280a:	1604ac23          	sw	zero,376(s1)
            p->main_thread = 0;
    8000280e:	1604b823          	sd	zero,368(s1)
            p->stack = 0;
    80002812:	1804b023          	sd	zero,384(s1)
            release(&p->lock);
    80002816:	8526                	mv	a0,s1
    80002818:	c74fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    8000281c:	0000d517          	auipc	a0,0xd
    80002820:	27c50513          	addi	a0,a0,636 # 8000fa98 <wait_lock>
    80002824:	c68fe0ef          	jal	80000c8c <release>
            return pid;
    80002828:	64a6                	ld	s1,72(sp)
    8000282a:	79e2                	ld	s3,56(sp)
    8000282c:	7a42                	ld	s4,48(sp)
    8000282e:	7aa2                	ld	s5,40(sp)
    80002830:	7b02                	ld	s6,32(sp)
    80002832:	b7b9                	j	80002780 <join+0x3a>
              release(&wait_lock);
    80002834:	0000d517          	auipc	a0,0xd
    80002838:	26450513          	addi	a0,a0,612 # 8000fa98 <wait_lock>
    8000283c:	c50fe0ef          	jal	80000c8c <release>
              return -1;
    80002840:	5cfd                	li	s9,-1
    80002842:	64a6                	ld	s1,72(sp)
    80002844:	79e2                	ld	s3,56(sp)
    80002846:	7a42                	ld	s4,48(sp)
    80002848:	7aa2                	ld	s5,40(sp)
    8000284a:	7b02                	ld	s6,32(sp)
    8000284c:	bf15                	j	80002780 <join+0x3a>
        release(&p->lock);
    8000284e:	8526                	mv	a0,s1
    80002850:	c3cfe0ef          	jal	80000c8c <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80002854:	19048493          	addi	s1,s1,400
    80002858:	03448063          	beq	s1,s4,80002878 <join+0x132>
        acquire(&p->lock);
    8000285c:	8526                	mv	a0,s1
    8000285e:	b96fe0ef          	jal	80000bf4 <acquire>
        if(p->main_thread == curproc && p != curproc){
    80002862:	1704b783          	ld	a5,368(s1)
    80002866:	ff2794e3          	bne	a5,s2,8000284e <join+0x108>
    8000286a:	fe9902e3          	beq	s2,s1,8000284e <join+0x108>
          if(p->state == ZOMBIE){
    8000286e:	4c9c                	lw	a5,24(s1)
    80002870:	f55784e3          	beq	a5,s5,800027b8 <join+0x72>
          havekids = 1;
    80002874:	89da                	mv	s3,s6
    80002876:	bfe1                	j	8000284e <join+0x108>
    if(!havekids || killed(curproc)){
    80002878:	02098d63          	beqz	s3,800028b2 <join+0x16c>
    8000287c:	854a                	mv	a0,s2
    8000287e:	a91ff0ef          	jal	8000230e <killed>
    80002882:	e115                	bnez	a0,800028a6 <join+0x160>
    sleep(curproc, &wait_lock);  //DOC: wait-sleep
    80002884:	0000d597          	auipc	a1,0xd
    80002888:	21458593          	addi	a1,a1,532 # 8000fa98 <wait_lock>
    8000288c:	854a                	mv	a0,s2
    8000288e:	f96ff0ef          	jal	80002024 <sleep>
    if(curproc->tid == 0){
    80002892:	17892783          	lw	a5,376(s2)
    80002896:	f00789e3          	beqz	a5,800027a8 <join+0x62>
    8000289a:	64a6                	ld	s1,72(sp)
    8000289c:	79e2                	ld	s3,56(sp)
    8000289e:	7a42                	ld	s4,48(sp)
    800028a0:	7aa2                	ld	s5,40(sp)
    800028a2:	7b02                	ld	s6,32(sp)
    800028a4:	b5f9                	j	80002772 <join+0x2c>
    800028a6:	64a6                	ld	s1,72(sp)
    800028a8:	79e2                	ld	s3,56(sp)
    800028aa:	7a42                	ld	s4,48(sp)
    800028ac:	7aa2                	ld	s5,40(sp)
    800028ae:	7b02                	ld	s6,32(sp)
    800028b0:	b5c9                	j	80002772 <join+0x2c>
    800028b2:	64a6                	ld	s1,72(sp)
    800028b4:	79e2                	ld	s3,56(sp)
    800028b6:	7a42                	ld	s4,48(sp)
    800028b8:	7aa2                	ld	s5,40(sp)
    800028ba:	7b02                	ld	s6,32(sp)
    800028bc:	bd5d                	j	80002772 <join+0x2c>

00000000800028be <swtch>:
    800028be:	00153023          	sd	ra,0(a0)
    800028c2:	00253423          	sd	sp,8(a0)
    800028c6:	e900                	sd	s0,16(a0)
    800028c8:	ed04                	sd	s1,24(a0)
    800028ca:	03253023          	sd	s2,32(a0)
    800028ce:	03353423          	sd	s3,40(a0)
    800028d2:	03453823          	sd	s4,48(a0)
    800028d6:	03553c23          	sd	s5,56(a0)
    800028da:	05653023          	sd	s6,64(a0)
    800028de:	05753423          	sd	s7,72(a0)
    800028e2:	05853823          	sd	s8,80(a0)
    800028e6:	05953c23          	sd	s9,88(a0)
    800028ea:	07a53023          	sd	s10,96(a0)
    800028ee:	07b53423          	sd	s11,104(a0)
    800028f2:	0005b083          	ld	ra,0(a1)
    800028f6:	0085b103          	ld	sp,8(a1)
    800028fa:	6980                	ld	s0,16(a1)
    800028fc:	6d84                	ld	s1,24(a1)
    800028fe:	0205b903          	ld	s2,32(a1)
    80002902:	0285b983          	ld	s3,40(a1)
    80002906:	0305ba03          	ld	s4,48(a1)
    8000290a:	0385ba83          	ld	s5,56(a1)
    8000290e:	0405bb03          	ld	s6,64(a1)
    80002912:	0485bb83          	ld	s7,72(a1)
    80002916:	0505bc03          	ld	s8,80(a1)
    8000291a:	0585bc83          	ld	s9,88(a1)
    8000291e:	0605bd03          	ld	s10,96(a1)
    80002922:	0685bd83          	ld	s11,104(a1)
    80002926:	8082                	ret

0000000080002928 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002928:	1141                	addi	sp,sp,-16
    8000292a:	e406                	sd	ra,8(sp)
    8000292c:	e022                	sd	s0,0(sp)
    8000292e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002930:	00005597          	auipc	a1,0x5
    80002934:	9f858593          	addi	a1,a1,-1544 # 80007328 <etext+0x328>
    80002938:	00014517          	auipc	a0,0x14
    8000293c:	97850513          	addi	a0,a0,-1672 # 800162b0 <tickslock>
    80002940:	a34fe0ef          	jal	80000b74 <initlock>
}
    80002944:	60a2                	ld	ra,8(sp)
    80002946:	6402                	ld	s0,0(sp)
    80002948:	0141                	addi	sp,sp,16
    8000294a:	8082                	ret

000000008000294c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000294c:	1141                	addi	sp,sp,-16
    8000294e:	e422                	sd	s0,8(sp)
    80002950:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002952:	00003797          	auipc	a5,0x3
    80002956:	f4e78793          	addi	a5,a5,-178 # 800058a0 <kernelvec>
    8000295a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000295e:	6422                	ld	s0,8(sp)
    80002960:	0141                	addi	sp,sp,16
    80002962:	8082                	ret

0000000080002964 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002964:	1141                	addi	sp,sp,-16
    80002966:	e406                	sd	ra,8(sp)
    80002968:	e022                	sd	s0,0(sp)
    8000296a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000296c:	8a2ff0ef          	jal	80001a0e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002970:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002974:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002976:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000297a:	00003697          	auipc	a3,0x3
    8000297e:	68668693          	addi	a3,a3,1670 # 80006000 <_trampoline>
    80002982:	00003717          	auipc	a4,0x3
    80002986:	67e70713          	addi	a4,a4,1662 # 80006000 <_trampoline>
    8000298a:	8f15                	sub	a4,a4,a3
    8000298c:	040007b7          	lui	a5,0x4000
    80002990:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002992:	07b2                	slli	a5,a5,0xc
    80002994:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002996:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000299a:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000299c:	18002673          	csrr	a2,satp
    800029a0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029a2:	7130                	ld	a2,96(a0)
    800029a4:	6138                	ld	a4,64(a0)
    800029a6:	6585                	lui	a1,0x1
    800029a8:	972e                	add	a4,a4,a1
    800029aa:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029ac:	7138                	ld	a4,96(a0)
    800029ae:	00000617          	auipc	a2,0x0
    800029b2:	11660613          	addi	a2,a2,278 # 80002ac4 <usertrap>
    800029b6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029b8:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029ba:	8612                	mv	a2,tp
    800029bc:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029be:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029c2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029c6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ca:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029ce:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029d0:	6f18                	ld	a4,24(a4)
    800029d2:	14171073          	csrw	sepc,a4
  // }

  // if(p->tid >=1){
  //   printf("\ntrapframe_va in usertrapret(): %ld\n", p->trapframe_va);
  // }
  asm volatile("csrw sscratch, %0" : : "r" (p->trapframe_va));
    800029d6:	6d2c                	ld	a1,88(a0)
    800029d8:	14059073          	csrw	sscratch,a1

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029dc:	6928                	ld	a0,80(a0)
    800029de:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029e0:	00003717          	auipc	a4,0x3
    800029e4:	6b470713          	addi	a4,a4,1716 # 80006094 <userret>
    800029e8:	8f15                	sub	a4,a4,a3
    800029ea:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(satp, p->trapframe_va);
    800029ec:	577d                	li	a4,-1
    800029ee:	177e                	slli	a4,a4,0x3f
    800029f0:	8d59                	or	a0,a0,a4
    800029f2:	9782                	jalr	a5
}
    800029f4:	60a2                	ld	ra,8(sp)
    800029f6:	6402                	ld	s0,0(sp)
    800029f8:	0141                	addi	sp,sp,16
    800029fa:	8082                	ret

00000000800029fc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029fc:	1101                	addi	sp,sp,-32
    800029fe:	ec06                	sd	ra,24(sp)
    80002a00:	e822                	sd	s0,16(sp)
    80002a02:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002a04:	fdffe0ef          	jal	800019e2 <cpuid>
    80002a08:	cd11                	beqz	a0,80002a24 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a0a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a0e:	000f4737          	lui	a4,0xf4
    80002a12:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a16:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a18:	14d79073          	csrw	stimecmp,a5
}
    80002a1c:	60e2                	ld	ra,24(sp)
    80002a1e:	6442                	ld	s0,16(sp)
    80002a20:	6105                	addi	sp,sp,32
    80002a22:	8082                	ret
    80002a24:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002a26:	00014497          	auipc	s1,0x14
    80002a2a:	88a48493          	addi	s1,s1,-1910 # 800162b0 <tickslock>
    80002a2e:	8526                	mv	a0,s1
    80002a30:	9c4fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002a34:	00005517          	auipc	a0,0x5
    80002a38:	f1c50513          	addi	a0,a0,-228 # 80007950 <ticks>
    80002a3c:	411c                	lw	a5,0(a0)
    80002a3e:	2785                	addiw	a5,a5,1
    80002a40:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002a42:	e2eff0ef          	jal	80002070 <wakeup>
    release(&tickslock);
    80002a46:	8526                	mv	a0,s1
    80002a48:	a44fe0ef          	jal	80000c8c <release>
    80002a4c:	64a2                	ld	s1,8(sp)
    80002a4e:	bf75                	j	80002a0a <clockintr+0xe>

0000000080002a50 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a50:	1101                	addi	sp,sp,-32
    80002a52:	ec06                	sd	ra,24(sp)
    80002a54:	e822                	sd	s0,16(sp)
    80002a56:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a58:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a5c:	57fd                	li	a5,-1
    80002a5e:	17fe                	slli	a5,a5,0x3f
    80002a60:	07a5                	addi	a5,a5,9
    80002a62:	00f70c63          	beq	a4,a5,80002a7a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a66:	57fd                	li	a5,-1
    80002a68:	17fe                	slli	a5,a5,0x3f
    80002a6a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a6c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a6e:	04f70763          	beq	a4,a5,80002abc <devintr+0x6c>
  }
}
    80002a72:	60e2                	ld	ra,24(sp)
    80002a74:	6442                	ld	s0,16(sp)
    80002a76:	6105                	addi	sp,sp,32
    80002a78:	8082                	ret
    80002a7a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a7c:	6d1020ef          	jal	8000594c <plic_claim>
    80002a80:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a82:	47a9                	li	a5,10
    80002a84:	00f50963          	beq	a0,a5,80002a96 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002a88:	4785                	li	a5,1
    80002a8a:	00f50963          	beq	a0,a5,80002a9c <devintr+0x4c>
    return 1;
    80002a8e:	4505                	li	a0,1
    } else if(irq){
    80002a90:	e889                	bnez	s1,80002aa2 <devintr+0x52>
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	bff9                	j	80002a72 <devintr+0x22>
      uartintr();
    80002a96:	f71fd0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002a9a:	a819                	j	80002ab0 <devintr+0x60>
      virtio_disk_intr();
    80002a9c:	376030ef          	jal	80005e12 <virtio_disk_intr>
    if(irq)
    80002aa0:	a801                	j	80002ab0 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002aa2:	85a6                	mv	a1,s1
    80002aa4:	00005517          	auipc	a0,0x5
    80002aa8:	88c50513          	addi	a0,a0,-1908 # 80007330 <etext+0x330>
    80002aac:	a17fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    80002ab0:	8526                	mv	a0,s1
    80002ab2:	6bb020ef          	jal	8000596c <plic_complete>
    return 1;
    80002ab6:	4505                	li	a0,1
    80002ab8:	64a2                	ld	s1,8(sp)
    80002aba:	bf65                	j	80002a72 <devintr+0x22>
    clockintr();
    80002abc:	f41ff0ef          	jal	800029fc <clockintr>
    return 2;
    80002ac0:	4509                	li	a0,2
    80002ac2:	bf45                	j	80002a72 <devintr+0x22>

0000000080002ac4 <usertrap>:
{
    80002ac4:	1101                	addi	sp,sp,-32
    80002ac6:	ec06                	sd	ra,24(sp)
    80002ac8:	e822                	sd	s0,16(sp)
    80002aca:	e426                	sd	s1,8(sp)
    80002acc:	e04a                	sd	s2,0(sp)
    80002ace:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ad4:	1007f793          	andi	a5,a5,256
    80002ad8:	ef85                	bnez	a5,80002b10 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ada:	00003797          	auipc	a5,0x3
    80002ade:	dc678793          	addi	a5,a5,-570 # 800058a0 <kernelvec>
    80002ae2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ae6:	f29fe0ef          	jal	80001a0e <myproc>
    80002aea:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002aec:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aee:	14102773          	csrr	a4,sepc
    80002af2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002af4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002af8:	47a1                	li	a5,8
    80002afa:	02f70163          	beq	a4,a5,80002b1c <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002afe:	f53ff0ef          	jal	80002a50 <devintr>
    80002b02:	892a                	mv	s2,a0
    80002b04:	c135                	beqz	a0,80002b68 <usertrap+0xa4>
  if(killed(p)){
    80002b06:	8526                	mv	a0,s1
    80002b08:	807ff0ef          	jal	8000230e <killed>
    80002b0c:	cd1d                	beqz	a0,80002b4a <usertrap+0x86>
    80002b0e:	a81d                	j	80002b44 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002b10:	00005517          	auipc	a0,0x5
    80002b14:	84050513          	addi	a0,a0,-1984 # 80007350 <etext+0x350>
    80002b18:	c7dfd0ef          	jal	80000794 <panic>
    if(killed(p)){
    80002b1c:	ff2ff0ef          	jal	8000230e <killed>
    80002b20:	e121                	bnez	a0,80002b60 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002b22:	70b8                	ld	a4,96(s1)
    80002b24:	6f1c                	ld	a5,24(a4)
    80002b26:	0791                	addi	a5,a5,4
    80002b28:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b2a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b2e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b32:	10079073          	csrw	sstatus,a5
    syscall();
    80002b36:	248000ef          	jal	80002d7e <syscall>
  if(killed(p)){
    80002b3a:	8526                	mv	a0,s1
    80002b3c:	fd2ff0ef          	jal	8000230e <killed>
    80002b40:	c901                	beqz	a0,80002b50 <usertrap+0x8c>
    80002b42:	4901                	li	s2,0
    exit(-1);
    80002b44:	557d                	li	a0,-1
    80002b46:	deaff0ef          	jal	80002130 <exit>
  if(which_dev == 2)
    80002b4a:	4789                	li	a5,2
    80002b4c:	04f90563          	beq	s2,a5,80002b96 <usertrap+0xd2>
  usertrapret();
    80002b50:	e15ff0ef          	jal	80002964 <usertrapret>
}
    80002b54:	60e2                	ld	ra,24(sp)
    80002b56:	6442                	ld	s0,16(sp)
    80002b58:	64a2                	ld	s1,8(sp)
    80002b5a:	6902                	ld	s2,0(sp)
    80002b5c:	6105                	addi	sp,sp,32
    80002b5e:	8082                	ret
      exit(-1);
    80002b60:	557d                	li	a0,-1
    80002b62:	dceff0ef          	jal	80002130 <exit>
    80002b66:	bf75                	j	80002b22 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b68:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002b6c:	5890                	lw	a2,48(s1)
    80002b6e:	00005517          	auipc	a0,0x5
    80002b72:	80250513          	addi	a0,a0,-2046 # 80007370 <etext+0x370>
    80002b76:	94dfd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b7a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b7e:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002b82:	00005517          	auipc	a0,0x5
    80002b86:	81e50513          	addi	a0,a0,-2018 # 800073a0 <etext+0x3a0>
    80002b8a:	939fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    80002b8e:	8526                	mv	a0,s1
    80002b90:	f5aff0ef          	jal	800022ea <setkilled>
    80002b94:	b75d                	j	80002b3a <usertrap+0x76>
    yield();
    80002b96:	c62ff0ef          	jal	80001ff8 <yield>
    80002b9a:	bf5d                	j	80002b50 <usertrap+0x8c>

0000000080002b9c <kerneltrap>:
{
    80002b9c:	7179                	addi	sp,sp,-48
    80002b9e:	f406                	sd	ra,40(sp)
    80002ba0:	f022                	sd	s0,32(sp)
    80002ba2:	ec26                	sd	s1,24(sp)
    80002ba4:	e84a                	sd	s2,16(sp)
    80002ba6:	e44e                	sd	s3,8(sp)
    80002ba8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002baa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002bb6:	1004f793          	andi	a5,s1,256
    80002bba:	c795                	beqz	a5,80002be6 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bc0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002bc2:	eb85                	bnez	a5,80002bf2 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002bc4:	e8dff0ef          	jal	80002a50 <devintr>
    80002bc8:	c91d                	beqz	a0,80002bfe <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002bca:	4789                	li	a5,2
    80002bcc:	04f50a63          	beq	a0,a5,80002c20 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bd0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bd4:	10049073          	csrw	sstatus,s1
}
    80002bd8:	70a2                	ld	ra,40(sp)
    80002bda:	7402                	ld	s0,32(sp)
    80002bdc:	64e2                	ld	s1,24(sp)
    80002bde:	6942                	ld	s2,16(sp)
    80002be0:	69a2                	ld	s3,8(sp)
    80002be2:	6145                	addi	sp,sp,48
    80002be4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002be6:	00004517          	auipc	a0,0x4
    80002bea:	7e250513          	addi	a0,a0,2018 # 800073c8 <etext+0x3c8>
    80002bee:	ba7fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bf2:	00004517          	auipc	a0,0x4
    80002bf6:	7fe50513          	addi	a0,a0,2046 # 800073f0 <etext+0x3f0>
    80002bfa:	b9bfd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bfe:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c02:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c06:	85ce                	mv	a1,s3
    80002c08:	00005517          	auipc	a0,0x5
    80002c0c:	80850513          	addi	a0,a0,-2040 # 80007410 <etext+0x410>
    80002c10:	8b3fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	82450513          	addi	a0,a0,-2012 # 80007438 <etext+0x438>
    80002c1c:	b79fd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c20:	deffe0ef          	jal	80001a0e <myproc>
    80002c24:	d555                	beqz	a0,80002bd0 <kerneltrap+0x34>
    yield();
    80002c26:	bd2ff0ef          	jal	80001ff8 <yield>
    80002c2a:	b75d                	j	80002bd0 <kerneltrap+0x34>

0000000080002c2c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c2c:	1101                	addi	sp,sp,-32
    80002c2e:	ec06                	sd	ra,24(sp)
    80002c30:	e822                	sd	s0,16(sp)
    80002c32:	e426                	sd	s1,8(sp)
    80002c34:	1000                	addi	s0,sp,32
    80002c36:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c38:	dd7fe0ef          	jal	80001a0e <myproc>
  switch (n) {
    80002c3c:	4795                	li	a5,5
    80002c3e:	0497e163          	bltu	a5,s1,80002c80 <argraw+0x54>
    80002c42:	048a                	slli	s1,s1,0x2
    80002c44:	00005717          	auipc	a4,0x5
    80002c48:	bb470713          	addi	a4,a4,-1100 # 800077f8 <states.0+0x30>
    80002c4c:	94ba                	add	s1,s1,a4
    80002c4e:	409c                	lw	a5,0(s1)
    80002c50:	97ba                	add	a5,a5,a4
    80002c52:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c54:	713c                	ld	a5,96(a0)
    80002c56:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c58:	60e2                	ld	ra,24(sp)
    80002c5a:	6442                	ld	s0,16(sp)
    80002c5c:	64a2                	ld	s1,8(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret
    return p->trapframe->a1;
    80002c62:	713c                	ld	a5,96(a0)
    80002c64:	7fa8                	ld	a0,120(a5)
    80002c66:	bfcd                	j	80002c58 <argraw+0x2c>
    return p->trapframe->a2;
    80002c68:	713c                	ld	a5,96(a0)
    80002c6a:	63c8                	ld	a0,128(a5)
    80002c6c:	b7f5                	j	80002c58 <argraw+0x2c>
    return p->trapframe->a3;
    80002c6e:	713c                	ld	a5,96(a0)
    80002c70:	67c8                	ld	a0,136(a5)
    80002c72:	b7dd                	j	80002c58 <argraw+0x2c>
    return p->trapframe->a4;
    80002c74:	713c                	ld	a5,96(a0)
    80002c76:	6bc8                	ld	a0,144(a5)
    80002c78:	b7c5                	j	80002c58 <argraw+0x2c>
    return p->trapframe->a5;
    80002c7a:	713c                	ld	a5,96(a0)
    80002c7c:	6fc8                	ld	a0,152(a5)
    80002c7e:	bfe9                	j	80002c58 <argraw+0x2c>
  panic("argraw");
    80002c80:	00004517          	auipc	a0,0x4
    80002c84:	7c850513          	addi	a0,a0,1992 # 80007448 <etext+0x448>
    80002c88:	b0dfd0ef          	jal	80000794 <panic>

0000000080002c8c <fetchaddr>:
{
    80002c8c:	1101                	addi	sp,sp,-32
    80002c8e:	ec06                	sd	ra,24(sp)
    80002c90:	e822                	sd	s0,16(sp)
    80002c92:	e426                	sd	s1,8(sp)
    80002c94:	e04a                	sd	s2,0(sp)
    80002c96:	1000                	addi	s0,sp,32
    80002c98:	84aa                	mv	s1,a0
    80002c9a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c9c:	d73fe0ef          	jal	80001a0e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ca0:	653c                	ld	a5,72(a0)
    80002ca2:	02f4f663          	bgeu	s1,a5,80002cce <fetchaddr+0x42>
    80002ca6:	00848713          	addi	a4,s1,8
    80002caa:	02e7e463          	bltu	a5,a4,80002cd2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cae:	46a1                	li	a3,8
    80002cb0:	8626                	mv	a2,s1
    80002cb2:	85ca                	mv	a1,s2
    80002cb4:	6928                	ld	a0,80(a0)
    80002cb6:	aa1fe0ef          	jal	80001756 <copyin>
    80002cba:	00a03533          	snez	a0,a0
    80002cbe:	40a00533          	neg	a0,a0
}
    80002cc2:	60e2                	ld	ra,24(sp)
    80002cc4:	6442                	ld	s0,16(sp)
    80002cc6:	64a2                	ld	s1,8(sp)
    80002cc8:	6902                	ld	s2,0(sp)
    80002cca:	6105                	addi	sp,sp,32
    80002ccc:	8082                	ret
    return -1;
    80002cce:	557d                	li	a0,-1
    80002cd0:	bfcd                	j	80002cc2 <fetchaddr+0x36>
    80002cd2:	557d                	li	a0,-1
    80002cd4:	b7fd                	j	80002cc2 <fetchaddr+0x36>

0000000080002cd6 <fetchstr>:
{
    80002cd6:	7179                	addi	sp,sp,-48
    80002cd8:	f406                	sd	ra,40(sp)
    80002cda:	f022                	sd	s0,32(sp)
    80002cdc:	ec26                	sd	s1,24(sp)
    80002cde:	e84a                	sd	s2,16(sp)
    80002ce0:	e44e                	sd	s3,8(sp)
    80002ce2:	1800                	addi	s0,sp,48
    80002ce4:	892a                	mv	s2,a0
    80002ce6:	84ae                	mv	s1,a1
    80002ce8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cea:	d25fe0ef          	jal	80001a0e <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cee:	86ce                	mv	a3,s3
    80002cf0:	864a                	mv	a2,s2
    80002cf2:	85a6                	mv	a1,s1
    80002cf4:	6928                	ld	a0,80(a0)
    80002cf6:	ae7fe0ef          	jal	800017dc <copyinstr>
    80002cfa:	00054c63          	bltz	a0,80002d12 <fetchstr+0x3c>
  return strlen(buf);
    80002cfe:	8526                	mv	a0,s1
    80002d00:	938fe0ef          	jal	80000e38 <strlen>
}
    80002d04:	70a2                	ld	ra,40(sp)
    80002d06:	7402                	ld	s0,32(sp)
    80002d08:	64e2                	ld	s1,24(sp)
    80002d0a:	6942                	ld	s2,16(sp)
    80002d0c:	69a2                	ld	s3,8(sp)
    80002d0e:	6145                	addi	sp,sp,48
    80002d10:	8082                	ret
    return -1;
    80002d12:	557d                	li	a0,-1
    80002d14:	bfc5                	j	80002d04 <fetchstr+0x2e>

0000000080002d16 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	e426                	sd	s1,8(sp)
    80002d1e:	1000                	addi	s0,sp,32
    80002d20:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d22:	f0bff0ef          	jal	80002c2c <argraw>
    80002d26:	c088                	sw	a0,0(s1)
}
    80002d28:	60e2                	ld	ra,24(sp)
    80002d2a:	6442                	ld	s0,16(sp)
    80002d2c:	64a2                	ld	s1,8(sp)
    80002d2e:	6105                	addi	sp,sp,32
    80002d30:	8082                	ret

0000000080002d32 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d32:	1101                	addi	sp,sp,-32
    80002d34:	ec06                	sd	ra,24(sp)
    80002d36:	e822                	sd	s0,16(sp)
    80002d38:	e426                	sd	s1,8(sp)
    80002d3a:	1000                	addi	s0,sp,32
    80002d3c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d3e:	eefff0ef          	jal	80002c2c <argraw>
    80002d42:	e088                	sd	a0,0(s1)
}
    80002d44:	60e2                	ld	ra,24(sp)
    80002d46:	6442                	ld	s0,16(sp)
    80002d48:	64a2                	ld	s1,8(sp)
    80002d4a:	6105                	addi	sp,sp,32
    80002d4c:	8082                	ret

0000000080002d4e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d4e:	7179                	addi	sp,sp,-48
    80002d50:	f406                	sd	ra,40(sp)
    80002d52:	f022                	sd	s0,32(sp)
    80002d54:	ec26                	sd	s1,24(sp)
    80002d56:	e84a                	sd	s2,16(sp)
    80002d58:	1800                	addi	s0,sp,48
    80002d5a:	84ae                	mv	s1,a1
    80002d5c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d5e:	fd840593          	addi	a1,s0,-40
    80002d62:	fd1ff0ef          	jal	80002d32 <argaddr>
  return fetchstr(addr, buf, max);
    80002d66:	864a                	mv	a2,s2
    80002d68:	85a6                	mv	a1,s1
    80002d6a:	fd843503          	ld	a0,-40(s0)
    80002d6e:	f69ff0ef          	jal	80002cd6 <fetchstr>
}
    80002d72:	70a2                	ld	ra,40(sp)
    80002d74:	7402                	ld	s0,32(sp)
    80002d76:	64e2                	ld	s1,24(sp)
    80002d78:	6942                	ld	s2,16(sp)
    80002d7a:	6145                	addi	sp,sp,48
    80002d7c:	8082                	ret

0000000080002d7e <syscall>:
[SYS_join]   sys_join,
};

void
syscall(void)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	e04a                	sd	s2,0(sp)
    80002d88:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d8a:	c85fe0ef          	jal	80001a0e <myproc>
    80002d8e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d90:	06053903          	ld	s2,96(a0)
    80002d94:	0a893783          	ld	a5,168(s2)
    80002d98:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d9c:	37fd                	addiw	a5,a5,-1
    80002d9e:	4759                	li	a4,22
    80002da0:	00f76f63          	bltu	a4,a5,80002dbe <syscall+0x40>
    80002da4:	00369713          	slli	a4,a3,0x3
    80002da8:	00005797          	auipc	a5,0x5
    80002dac:	a6878793          	addi	a5,a5,-1432 # 80007810 <syscalls>
    80002db0:	97ba                	add	a5,a5,a4
    80002db2:	639c                	ld	a5,0(a5)
    80002db4:	c789                	beqz	a5,80002dbe <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002db6:	9782                	jalr	a5
    80002db8:	06a93823          	sd	a0,112(s2)
    80002dbc:	a829                	j	80002dd6 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002dbe:	16048613          	addi	a2,s1,352
    80002dc2:	588c                	lw	a1,48(s1)
    80002dc4:	00004517          	auipc	a0,0x4
    80002dc8:	68c50513          	addi	a0,a0,1676 # 80007450 <etext+0x450>
    80002dcc:	ef6fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dd0:	70bc                	ld	a5,96(s1)
    80002dd2:	577d                	li	a4,-1
    80002dd4:	fbb8                	sd	a4,112(a5)
  }
}
    80002dd6:	60e2                	ld	ra,24(sp)
    80002dd8:	6442                	ld	s0,16(sp)
    80002dda:	64a2                	ld	s1,8(sp)
    80002ddc:	6902                	ld	s2,0(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret

0000000080002de2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002de2:	1101                	addi	sp,sp,-32
    80002de4:	ec06                	sd	ra,24(sp)
    80002de6:	e822                	sd	s0,16(sp)
    80002de8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002dea:	fec40593          	addi	a1,s0,-20
    80002dee:	4501                	li	a0,0
    80002df0:	f27ff0ef          	jal	80002d16 <argint>
  exit(n);
    80002df4:	fec42503          	lw	a0,-20(s0)
    80002df8:	b38ff0ef          	jal	80002130 <exit>
  return 0;  // not reached
}
    80002dfc:	4501                	li	a0,0
    80002dfe:	60e2                	ld	ra,24(sp)
    80002e00:	6442                	ld	s0,16(sp)
    80002e02:	6105                	addi	sp,sp,32
    80002e04:	8082                	ret

0000000080002e06 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e06:	1141                	addi	sp,sp,-16
    80002e08:	e406                	sd	ra,8(sp)
    80002e0a:	e022                	sd	s0,0(sp)
    80002e0c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e0e:	c01fe0ef          	jal	80001a0e <myproc>
}
    80002e12:	5908                	lw	a0,48(a0)
    80002e14:	60a2                	ld	ra,8(sp)
    80002e16:	6402                	ld	s0,0(sp)
    80002e18:	0141                	addi	sp,sp,16
    80002e1a:	8082                	ret

0000000080002e1c <sys_fork>:

uint64
sys_fork(void)
{
    80002e1c:	1141                	addi	sp,sp,-16
    80002e1e:	e406                	sd	ra,8(sp)
    80002e20:	e022                	sd	s0,0(sp)
    80002e22:	0800                	addi	s0,sp,16
  return fork();
    80002e24:	f49fe0ef          	jal	80001d6c <fork>
}
    80002e28:	60a2                	ld	ra,8(sp)
    80002e2a:	6402                	ld	s0,0(sp)
    80002e2c:	0141                	addi	sp,sp,16
    80002e2e:	8082                	ret

0000000080002e30 <sys_wait>:

uint64
sys_wait(void)
{
    80002e30:	1101                	addi	sp,sp,-32
    80002e32:	ec06                	sd	ra,24(sp)
    80002e34:	e822                	sd	s0,16(sp)
    80002e36:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e38:	fe840593          	addi	a1,s0,-24
    80002e3c:	4501                	li	a0,0
    80002e3e:	ef5ff0ef          	jal	80002d32 <argaddr>
  return wait(p);
    80002e42:	fe843503          	ld	a0,-24(s0)
    80002e46:	cf2ff0ef          	jal	80002338 <wait>
}
    80002e4a:	60e2                	ld	ra,24(sp)
    80002e4c:	6442                	ld	s0,16(sp)
    80002e4e:	6105                	addi	sp,sp,32
    80002e50:	8082                	ret

0000000080002e52 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e52:	7179                	addi	sp,sp,-48
    80002e54:	f406                	sd	ra,40(sp)
    80002e56:	f022                	sd	s0,32(sp)
    80002e58:	ec26                	sd	s1,24(sp)
    80002e5a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e5c:	fdc40593          	addi	a1,s0,-36
    80002e60:	4501                	li	a0,0
    80002e62:	eb5ff0ef          	jal	80002d16 <argint>

  /* implementation for project02 */
  struct proc *p = myproc();
    80002e66:	ba9fe0ef          	jal	80001a0e <myproc>

  //addr = myproc()->sz;

  if(p->tid == 0 || !(p->main_thread)){
    80002e6a:	17852783          	lw	a5,376(a0)
    80002e6e:	c791                	beqz	a5,80002e7a <sys_sbrk+0x28>
    80002e70:	17053783          	ld	a5,368(a0)
    80002e74:	c399                	beqz	a5,80002e7a <sys_sbrk+0x28>
    addr = p->sz;
  }
  else{
    addr = p->main_thread->sz;
    80002e76:	67a4                	ld	s1,72(a5)
    80002e78:	a011                	j	80002e7c <sys_sbrk+0x2a>
    addr = p->sz;
    80002e7a:	6524                	ld	s1,72(a0)
  }
  /* ===== */
  if(growproc(n) < 0)
    80002e7c:	fdc42503          	lw	a0,-36(s0)
    80002e80:	e95fe0ef          	jal	80001d14 <growproc>
    80002e84:	00054863          	bltz	a0,80002e94 <sys_sbrk+0x42>
    return -1;

  return addr;
}
    80002e88:	8526                	mv	a0,s1
    80002e8a:	70a2                	ld	ra,40(sp)
    80002e8c:	7402                	ld	s0,32(sp)
    80002e8e:	64e2                	ld	s1,24(sp)
    80002e90:	6145                	addi	sp,sp,48
    80002e92:	8082                	ret
    return -1;
    80002e94:	54fd                	li	s1,-1
    80002e96:	bfcd                	j	80002e88 <sys_sbrk+0x36>

0000000080002e98 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e98:	7139                	addi	sp,sp,-64
    80002e9a:	fc06                	sd	ra,56(sp)
    80002e9c:	f822                	sd	s0,48(sp)
    80002e9e:	f04a                	sd	s2,32(sp)
    80002ea0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ea2:	fcc40593          	addi	a1,s0,-52
    80002ea6:	4501                	li	a0,0
    80002ea8:	e6fff0ef          	jal	80002d16 <argint>
  if(n < 0)
    80002eac:	fcc42783          	lw	a5,-52(s0)
    80002eb0:	0607c763          	bltz	a5,80002f1e <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002eb4:	00013517          	auipc	a0,0x13
    80002eb8:	3fc50513          	addi	a0,a0,1020 # 800162b0 <tickslock>
    80002ebc:	d39fd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002ec0:	00005917          	auipc	s2,0x5
    80002ec4:	a9092903          	lw	s2,-1392(s2) # 80007950 <ticks>
  while(ticks - ticks0 < n){
    80002ec8:	fcc42783          	lw	a5,-52(s0)
    80002ecc:	cf8d                	beqz	a5,80002f06 <sys_sleep+0x6e>
    80002ece:	f426                	sd	s1,40(sp)
    80002ed0:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ed2:	00013997          	auipc	s3,0x13
    80002ed6:	3de98993          	addi	s3,s3,990 # 800162b0 <tickslock>
    80002eda:	00005497          	auipc	s1,0x5
    80002ede:	a7648493          	addi	s1,s1,-1418 # 80007950 <ticks>
    if(killed(myproc())){
    80002ee2:	b2dfe0ef          	jal	80001a0e <myproc>
    80002ee6:	c28ff0ef          	jal	8000230e <killed>
    80002eea:	ed0d                	bnez	a0,80002f24 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002eec:	85ce                	mv	a1,s3
    80002eee:	8526                	mv	a0,s1
    80002ef0:	934ff0ef          	jal	80002024 <sleep>
  while(ticks - ticks0 < n){
    80002ef4:	409c                	lw	a5,0(s1)
    80002ef6:	412787bb          	subw	a5,a5,s2
    80002efa:	fcc42703          	lw	a4,-52(s0)
    80002efe:	fee7e2e3          	bltu	a5,a4,80002ee2 <sys_sleep+0x4a>
    80002f02:	74a2                	ld	s1,40(sp)
    80002f04:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f06:	00013517          	auipc	a0,0x13
    80002f0a:	3aa50513          	addi	a0,a0,938 # 800162b0 <tickslock>
    80002f0e:	d7ffd0ef          	jal	80000c8c <release>
  return 0;
    80002f12:	4501                	li	a0,0
}
    80002f14:	70e2                	ld	ra,56(sp)
    80002f16:	7442                	ld	s0,48(sp)
    80002f18:	7902                	ld	s2,32(sp)
    80002f1a:	6121                	addi	sp,sp,64
    80002f1c:	8082                	ret
    n = 0;
    80002f1e:	fc042623          	sw	zero,-52(s0)
    80002f22:	bf49                	j	80002eb4 <sys_sleep+0x1c>
      release(&tickslock);
    80002f24:	00013517          	auipc	a0,0x13
    80002f28:	38c50513          	addi	a0,a0,908 # 800162b0 <tickslock>
    80002f2c:	d61fd0ef          	jal	80000c8c <release>
      return -1;
    80002f30:	557d                	li	a0,-1
    80002f32:	74a2                	ld	s1,40(sp)
    80002f34:	69e2                	ld	s3,24(sp)
    80002f36:	bff9                	j	80002f14 <sys_sleep+0x7c>

0000000080002f38 <sys_kill>:

uint64
sys_kill(void)
{
    80002f38:	1101                	addi	sp,sp,-32
    80002f3a:	ec06                	sd	ra,24(sp)
    80002f3c:	e822                	sd	s0,16(sp)
    80002f3e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f40:	fec40593          	addi	a1,s0,-20
    80002f44:	4501                	li	a0,0
    80002f46:	dd1ff0ef          	jal	80002d16 <argint>
  return kill(pid);
    80002f4a:	fec42503          	lw	a0,-20(s0)
    80002f4e:	b28ff0ef          	jal	80002276 <kill>
}
    80002f52:	60e2                	ld	ra,24(sp)
    80002f54:	6442                	ld	s0,16(sp)
    80002f56:	6105                	addi	sp,sp,32
    80002f58:	8082                	ret

0000000080002f5a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f5a:	1101                	addi	sp,sp,-32
    80002f5c:	ec06                	sd	ra,24(sp)
    80002f5e:	e822                	sd	s0,16(sp)
    80002f60:	e426                	sd	s1,8(sp)
    80002f62:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f64:	00013517          	auipc	a0,0x13
    80002f68:	34c50513          	addi	a0,a0,844 # 800162b0 <tickslock>
    80002f6c:	c89fd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002f70:	00005497          	auipc	s1,0x5
    80002f74:	9e04a483          	lw	s1,-1568(s1) # 80007950 <ticks>
  release(&tickslock);
    80002f78:	00013517          	auipc	a0,0x13
    80002f7c:	33850513          	addi	a0,a0,824 # 800162b0 <tickslock>
    80002f80:	d0dfd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002f84:	02049513          	slli	a0,s1,0x20
    80002f88:	9101                	srli	a0,a0,0x20
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	64a2                	ld	s1,8(sp)
    80002f90:	6105                	addi	sp,sp,32
    80002f92:	8082                	ret

0000000080002f94 <sys_clone>:

/* implementation for project02 */
uint64
sys_clone(void)
{
    80002f94:	7179                	addi	sp,sp,-48
    80002f96:	f406                	sd	ra,40(sp)
    80002f98:	f022                	sd	s0,32(sp)
    80002f9a:	1800                	addi	s0,sp,48
  uint64 fcn, arg1, arg2, stack;
  argaddr(0, &fcn);
    80002f9c:	fe840593          	addi	a1,s0,-24
    80002fa0:	4501                	li	a0,0
    80002fa2:	d91ff0ef          	jal	80002d32 <argaddr>
  argaddr(1, &arg1);
    80002fa6:	fe040593          	addi	a1,s0,-32
    80002faa:	4505                	li	a0,1
    80002fac:	d87ff0ef          	jal	80002d32 <argaddr>
  argaddr(2, &arg2);
    80002fb0:	fd840593          	addi	a1,s0,-40
    80002fb4:	4509                	li	a0,2
    80002fb6:	d7dff0ef          	jal	80002d32 <argaddr>
  argaddr(3, &stack);
    80002fba:	fd040593          	addi	a1,s0,-48
    80002fbe:	450d                	li	a0,3
    80002fc0:	d73ff0ef          	jal	80002d32 <argaddr>

  int pid = clone((void (*)(void*, void*))fcn, (void *)arg1, (void *)arg2, (void *)stack);
    80002fc4:	fd043683          	ld	a3,-48(s0)
    80002fc8:	fd843603          	ld	a2,-40(s0)
    80002fcc:	fe043583          	ld	a1,-32(s0)
    80002fd0:	fe843503          	ld	a0,-24(s0)
    80002fd4:	d96ff0ef          	jal	8000256a <clone>

  return pid;
}
    80002fd8:	70a2                	ld	ra,40(sp)
    80002fda:	7402                	ld	s0,32(sp)
    80002fdc:	6145                	addi	sp,sp,48
    80002fde:	8082                	ret

0000000080002fe0 <sys_join>:

uint64
sys_join(void)
{
    80002fe0:	1101                	addi	sp,sp,-32
    80002fe2:	ec06                	sd	ra,24(sp)
    80002fe4:	e822                	sd	s0,16(sp)
    80002fe6:	1000                	addi	s0,sp,32
  uint64 stack;
  argaddr(0, &stack);
    80002fe8:	fe840593          	addi	a1,s0,-24
    80002fec:	4501                	li	a0,0
    80002fee:	d45ff0ef          	jal	80002d32 <argaddr>

  return join((void **)stack);
    80002ff2:	fe843503          	ld	a0,-24(s0)
    80002ff6:	f50ff0ef          	jal	80002746 <join>
}
    80002ffa:	60e2                	ld	ra,24(sp)
    80002ffc:	6442                	ld	s0,16(sp)
    80002ffe:	6105                	addi	sp,sp,32
    80003000:	8082                	ret

0000000080003002 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003002:	7179                	addi	sp,sp,-48
    80003004:	f406                	sd	ra,40(sp)
    80003006:	f022                	sd	s0,32(sp)
    80003008:	ec26                	sd	s1,24(sp)
    8000300a:	e84a                	sd	s2,16(sp)
    8000300c:	e44e                	sd	s3,8(sp)
    8000300e:	e052                	sd	s4,0(sp)
    80003010:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003012:	00004597          	auipc	a1,0x4
    80003016:	45e58593          	addi	a1,a1,1118 # 80007470 <etext+0x470>
    8000301a:	00013517          	auipc	a0,0x13
    8000301e:	2ae50513          	addi	a0,a0,686 # 800162c8 <bcache>
    80003022:	b53fd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003026:	0001b797          	auipc	a5,0x1b
    8000302a:	2a278793          	addi	a5,a5,674 # 8001e2c8 <bcache+0x8000>
    8000302e:	0001b717          	auipc	a4,0x1b
    80003032:	50270713          	addi	a4,a4,1282 # 8001e530 <bcache+0x8268>
    80003036:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000303a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000303e:	00013497          	auipc	s1,0x13
    80003042:	2a248493          	addi	s1,s1,674 # 800162e0 <bcache+0x18>
    b->next = bcache.head.next;
    80003046:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003048:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000304a:	00004a17          	auipc	s4,0x4
    8000304e:	42ea0a13          	addi	s4,s4,1070 # 80007478 <etext+0x478>
    b->next = bcache.head.next;
    80003052:	2b893783          	ld	a5,696(s2)
    80003056:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003058:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000305c:	85d2                	mv	a1,s4
    8000305e:	01048513          	addi	a0,s1,16
    80003062:	248010ef          	jal	800042aa <initsleeplock>
    bcache.head.next->prev = b;
    80003066:	2b893783          	ld	a5,696(s2)
    8000306a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000306c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003070:	45848493          	addi	s1,s1,1112
    80003074:	fd349fe3          	bne	s1,s3,80003052 <binit+0x50>
  }
}
    80003078:	70a2                	ld	ra,40(sp)
    8000307a:	7402                	ld	s0,32(sp)
    8000307c:	64e2                	ld	s1,24(sp)
    8000307e:	6942                	ld	s2,16(sp)
    80003080:	69a2                	ld	s3,8(sp)
    80003082:	6a02                	ld	s4,0(sp)
    80003084:	6145                	addi	sp,sp,48
    80003086:	8082                	ret

0000000080003088 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003088:	7179                	addi	sp,sp,-48
    8000308a:	f406                	sd	ra,40(sp)
    8000308c:	f022                	sd	s0,32(sp)
    8000308e:	ec26                	sd	s1,24(sp)
    80003090:	e84a                	sd	s2,16(sp)
    80003092:	e44e                	sd	s3,8(sp)
    80003094:	1800                	addi	s0,sp,48
    80003096:	892a                	mv	s2,a0
    80003098:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000309a:	00013517          	auipc	a0,0x13
    8000309e:	22e50513          	addi	a0,a0,558 # 800162c8 <bcache>
    800030a2:	b53fd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030a6:	0001b497          	auipc	s1,0x1b
    800030aa:	4da4b483          	ld	s1,1242(s1) # 8001e580 <bcache+0x82b8>
    800030ae:	0001b797          	auipc	a5,0x1b
    800030b2:	48278793          	addi	a5,a5,1154 # 8001e530 <bcache+0x8268>
    800030b6:	02f48b63          	beq	s1,a5,800030ec <bread+0x64>
    800030ba:	873e                	mv	a4,a5
    800030bc:	a021                	j	800030c4 <bread+0x3c>
    800030be:	68a4                	ld	s1,80(s1)
    800030c0:	02e48663          	beq	s1,a4,800030ec <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800030c4:	449c                	lw	a5,8(s1)
    800030c6:	ff279ce3          	bne	a5,s2,800030be <bread+0x36>
    800030ca:	44dc                	lw	a5,12(s1)
    800030cc:	ff3799e3          	bne	a5,s3,800030be <bread+0x36>
      b->refcnt++;
    800030d0:	40bc                	lw	a5,64(s1)
    800030d2:	2785                	addiw	a5,a5,1
    800030d4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030d6:	00013517          	auipc	a0,0x13
    800030da:	1f250513          	addi	a0,a0,498 # 800162c8 <bcache>
    800030de:	baffd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    800030e2:	01048513          	addi	a0,s1,16
    800030e6:	1fa010ef          	jal	800042e0 <acquiresleep>
      return b;
    800030ea:	a889                	j	8000313c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ec:	0001b497          	auipc	s1,0x1b
    800030f0:	48c4b483          	ld	s1,1164(s1) # 8001e578 <bcache+0x82b0>
    800030f4:	0001b797          	auipc	a5,0x1b
    800030f8:	43c78793          	addi	a5,a5,1084 # 8001e530 <bcache+0x8268>
    800030fc:	00f48863          	beq	s1,a5,8000310c <bread+0x84>
    80003100:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003102:	40bc                	lw	a5,64(s1)
    80003104:	cb91                	beqz	a5,80003118 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003106:	64a4                	ld	s1,72(s1)
    80003108:	fee49de3          	bne	s1,a4,80003102 <bread+0x7a>
  panic("bget: no buffers");
    8000310c:	00004517          	auipc	a0,0x4
    80003110:	37450513          	addi	a0,a0,884 # 80007480 <etext+0x480>
    80003114:	e80fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80003118:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000311c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003120:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003124:	4785                	li	a5,1
    80003126:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003128:	00013517          	auipc	a0,0x13
    8000312c:	1a050513          	addi	a0,a0,416 # 800162c8 <bcache>
    80003130:	b5dfd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80003134:	01048513          	addi	a0,s1,16
    80003138:	1a8010ef          	jal	800042e0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000313c:	409c                	lw	a5,0(s1)
    8000313e:	cb89                	beqz	a5,80003150 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003140:	8526                	mv	a0,s1
    80003142:	70a2                	ld	ra,40(sp)
    80003144:	7402                	ld	s0,32(sp)
    80003146:	64e2                	ld	s1,24(sp)
    80003148:	6942                	ld	s2,16(sp)
    8000314a:	69a2                	ld	s3,8(sp)
    8000314c:	6145                	addi	sp,sp,48
    8000314e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003150:	4581                	li	a1,0
    80003152:	8526                	mv	a0,s1
    80003154:	2ad020ef          	jal	80005c00 <virtio_disk_rw>
    b->valid = 1;
    80003158:	4785                	li	a5,1
    8000315a:	c09c                	sw	a5,0(s1)
  return b;
    8000315c:	b7d5                	j	80003140 <bread+0xb8>

000000008000315e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000315e:	1101                	addi	sp,sp,-32
    80003160:	ec06                	sd	ra,24(sp)
    80003162:	e822                	sd	s0,16(sp)
    80003164:	e426                	sd	s1,8(sp)
    80003166:	1000                	addi	s0,sp,32
    80003168:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000316a:	0541                	addi	a0,a0,16
    8000316c:	1f2010ef          	jal	8000435e <holdingsleep>
    80003170:	c911                	beqz	a0,80003184 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003172:	4585                	li	a1,1
    80003174:	8526                	mv	a0,s1
    80003176:	28b020ef          	jal	80005c00 <virtio_disk_rw>
}
    8000317a:	60e2                	ld	ra,24(sp)
    8000317c:	6442                	ld	s0,16(sp)
    8000317e:	64a2                	ld	s1,8(sp)
    80003180:	6105                	addi	sp,sp,32
    80003182:	8082                	ret
    panic("bwrite");
    80003184:	00004517          	auipc	a0,0x4
    80003188:	31450513          	addi	a0,a0,788 # 80007498 <etext+0x498>
    8000318c:	e08fd0ef          	jal	80000794 <panic>

0000000080003190 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003190:	1101                	addi	sp,sp,-32
    80003192:	ec06                	sd	ra,24(sp)
    80003194:	e822                	sd	s0,16(sp)
    80003196:	e426                	sd	s1,8(sp)
    80003198:	e04a                	sd	s2,0(sp)
    8000319a:	1000                	addi	s0,sp,32
    8000319c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000319e:	01050913          	addi	s2,a0,16
    800031a2:	854a                	mv	a0,s2
    800031a4:	1ba010ef          	jal	8000435e <holdingsleep>
    800031a8:	c135                	beqz	a0,8000320c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800031aa:	854a                	mv	a0,s2
    800031ac:	17a010ef          	jal	80004326 <releasesleep>

  acquire(&bcache.lock);
    800031b0:	00013517          	auipc	a0,0x13
    800031b4:	11850513          	addi	a0,a0,280 # 800162c8 <bcache>
    800031b8:	a3dfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    800031bc:	40bc                	lw	a5,64(s1)
    800031be:	37fd                	addiw	a5,a5,-1
    800031c0:	0007871b          	sext.w	a4,a5
    800031c4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031c6:	e71d                	bnez	a4,800031f4 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031c8:	68b8                	ld	a4,80(s1)
    800031ca:	64bc                	ld	a5,72(s1)
    800031cc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800031ce:	68b8                	ld	a4,80(s1)
    800031d0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031d2:	0001b797          	auipc	a5,0x1b
    800031d6:	0f678793          	addi	a5,a5,246 # 8001e2c8 <bcache+0x8000>
    800031da:	2b87b703          	ld	a4,696(a5)
    800031de:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031e0:	0001b717          	auipc	a4,0x1b
    800031e4:	35070713          	addi	a4,a4,848 # 8001e530 <bcache+0x8268>
    800031e8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031ea:	2b87b703          	ld	a4,696(a5)
    800031ee:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031f0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031f4:	00013517          	auipc	a0,0x13
    800031f8:	0d450513          	addi	a0,a0,212 # 800162c8 <bcache>
    800031fc:	a91fd0ef          	jal	80000c8c <release>
}
    80003200:	60e2                	ld	ra,24(sp)
    80003202:	6442                	ld	s0,16(sp)
    80003204:	64a2                	ld	s1,8(sp)
    80003206:	6902                	ld	s2,0(sp)
    80003208:	6105                	addi	sp,sp,32
    8000320a:	8082                	ret
    panic("brelse");
    8000320c:	00004517          	auipc	a0,0x4
    80003210:	29450513          	addi	a0,a0,660 # 800074a0 <etext+0x4a0>
    80003214:	d80fd0ef          	jal	80000794 <panic>

0000000080003218 <bpin>:

void
bpin(struct buf *b) {
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	e426                	sd	s1,8(sp)
    80003220:	1000                	addi	s0,sp,32
    80003222:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003224:	00013517          	auipc	a0,0x13
    80003228:	0a450513          	addi	a0,a0,164 # 800162c8 <bcache>
    8000322c:	9c9fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80003230:	40bc                	lw	a5,64(s1)
    80003232:	2785                	addiw	a5,a5,1
    80003234:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003236:	00013517          	auipc	a0,0x13
    8000323a:	09250513          	addi	a0,a0,146 # 800162c8 <bcache>
    8000323e:	a4ffd0ef          	jal	80000c8c <release>
}
    80003242:	60e2                	ld	ra,24(sp)
    80003244:	6442                	ld	s0,16(sp)
    80003246:	64a2                	ld	s1,8(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret

000000008000324c <bunpin>:

void
bunpin(struct buf *b) {
    8000324c:	1101                	addi	sp,sp,-32
    8000324e:	ec06                	sd	ra,24(sp)
    80003250:	e822                	sd	s0,16(sp)
    80003252:	e426                	sd	s1,8(sp)
    80003254:	1000                	addi	s0,sp,32
    80003256:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003258:	00013517          	auipc	a0,0x13
    8000325c:	07050513          	addi	a0,a0,112 # 800162c8 <bcache>
    80003260:	995fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80003264:	40bc                	lw	a5,64(s1)
    80003266:	37fd                	addiw	a5,a5,-1
    80003268:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000326a:	00013517          	auipc	a0,0x13
    8000326e:	05e50513          	addi	a0,a0,94 # 800162c8 <bcache>
    80003272:	a1bfd0ef          	jal	80000c8c <release>
}
    80003276:	60e2                	ld	ra,24(sp)
    80003278:	6442                	ld	s0,16(sp)
    8000327a:	64a2                	ld	s1,8(sp)
    8000327c:	6105                	addi	sp,sp,32
    8000327e:	8082                	ret

0000000080003280 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003280:	1101                	addi	sp,sp,-32
    80003282:	ec06                	sd	ra,24(sp)
    80003284:	e822                	sd	s0,16(sp)
    80003286:	e426                	sd	s1,8(sp)
    80003288:	e04a                	sd	s2,0(sp)
    8000328a:	1000                	addi	s0,sp,32
    8000328c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000328e:	00d5d59b          	srliw	a1,a1,0xd
    80003292:	0001b797          	auipc	a5,0x1b
    80003296:	7127a783          	lw	a5,1810(a5) # 8001e9a4 <sb+0x1c>
    8000329a:	9dbd                	addw	a1,a1,a5
    8000329c:	dedff0ef          	jal	80003088 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032a0:	0074f713          	andi	a4,s1,7
    800032a4:	4785                	li	a5,1
    800032a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032aa:	14ce                	slli	s1,s1,0x33
    800032ac:	90d9                	srli	s1,s1,0x36
    800032ae:	00950733          	add	a4,a0,s1
    800032b2:	05874703          	lbu	a4,88(a4)
    800032b6:	00e7f6b3          	and	a3,a5,a4
    800032ba:	c29d                	beqz	a3,800032e0 <bfree+0x60>
    800032bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032be:	94aa                	add	s1,s1,a0
    800032c0:	fff7c793          	not	a5,a5
    800032c4:	8f7d                	and	a4,a4,a5
    800032c6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800032ca:	711000ef          	jal	800041da <log_write>
  brelse(bp);
    800032ce:	854a                	mv	a0,s2
    800032d0:	ec1ff0ef          	jal	80003190 <brelse>
}
    800032d4:	60e2                	ld	ra,24(sp)
    800032d6:	6442                	ld	s0,16(sp)
    800032d8:	64a2                	ld	s1,8(sp)
    800032da:	6902                	ld	s2,0(sp)
    800032dc:	6105                	addi	sp,sp,32
    800032de:	8082                	ret
    panic("freeing free block");
    800032e0:	00004517          	auipc	a0,0x4
    800032e4:	1c850513          	addi	a0,a0,456 # 800074a8 <etext+0x4a8>
    800032e8:	cacfd0ef          	jal	80000794 <panic>

00000000800032ec <balloc>:
{
    800032ec:	711d                	addi	sp,sp,-96
    800032ee:	ec86                	sd	ra,88(sp)
    800032f0:	e8a2                	sd	s0,80(sp)
    800032f2:	e4a6                	sd	s1,72(sp)
    800032f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032f6:	0001b797          	auipc	a5,0x1b
    800032fa:	6967a783          	lw	a5,1686(a5) # 8001e98c <sb+0x4>
    800032fe:	0e078f63          	beqz	a5,800033fc <balloc+0x110>
    80003302:	e0ca                	sd	s2,64(sp)
    80003304:	fc4e                	sd	s3,56(sp)
    80003306:	f852                	sd	s4,48(sp)
    80003308:	f456                	sd	s5,40(sp)
    8000330a:	f05a                	sd	s6,32(sp)
    8000330c:	ec5e                	sd	s7,24(sp)
    8000330e:	e862                	sd	s8,16(sp)
    80003310:	e466                	sd	s9,8(sp)
    80003312:	8baa                	mv	s7,a0
    80003314:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003316:	0001bb17          	auipc	s6,0x1b
    8000331a:	672b0b13          	addi	s6,s6,1650 # 8001e988 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000331e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003320:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003322:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003324:	6c89                	lui	s9,0x2
    80003326:	a0b5                	j	80003392 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003328:	97ca                	add	a5,a5,s2
    8000332a:	8e55                	or	a2,a2,a3
    8000332c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003330:	854a                	mv	a0,s2
    80003332:	6a9000ef          	jal	800041da <log_write>
        brelse(bp);
    80003336:	854a                	mv	a0,s2
    80003338:	e59ff0ef          	jal	80003190 <brelse>
  bp = bread(dev, bno);
    8000333c:	85a6                	mv	a1,s1
    8000333e:	855e                	mv	a0,s7
    80003340:	d49ff0ef          	jal	80003088 <bread>
    80003344:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003346:	40000613          	li	a2,1024
    8000334a:	4581                	li	a1,0
    8000334c:	05850513          	addi	a0,a0,88
    80003350:	979fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80003354:	854a                	mv	a0,s2
    80003356:	685000ef          	jal	800041da <log_write>
  brelse(bp);
    8000335a:	854a                	mv	a0,s2
    8000335c:	e35ff0ef          	jal	80003190 <brelse>
}
    80003360:	6906                	ld	s2,64(sp)
    80003362:	79e2                	ld	s3,56(sp)
    80003364:	7a42                	ld	s4,48(sp)
    80003366:	7aa2                	ld	s5,40(sp)
    80003368:	7b02                	ld	s6,32(sp)
    8000336a:	6be2                	ld	s7,24(sp)
    8000336c:	6c42                	ld	s8,16(sp)
    8000336e:	6ca2                	ld	s9,8(sp)
}
    80003370:	8526                	mv	a0,s1
    80003372:	60e6                	ld	ra,88(sp)
    80003374:	6446                	ld	s0,80(sp)
    80003376:	64a6                	ld	s1,72(sp)
    80003378:	6125                	addi	sp,sp,96
    8000337a:	8082                	ret
    brelse(bp);
    8000337c:	854a                	mv	a0,s2
    8000337e:	e13ff0ef          	jal	80003190 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003382:	015c87bb          	addw	a5,s9,s5
    80003386:	00078a9b          	sext.w	s5,a5
    8000338a:	004b2703          	lw	a4,4(s6)
    8000338e:	04eaff63          	bgeu	s5,a4,800033ec <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003392:	41fad79b          	sraiw	a5,s5,0x1f
    80003396:	0137d79b          	srliw	a5,a5,0x13
    8000339a:	015787bb          	addw	a5,a5,s5
    8000339e:	40d7d79b          	sraiw	a5,a5,0xd
    800033a2:	01cb2583          	lw	a1,28(s6)
    800033a6:	9dbd                	addw	a1,a1,a5
    800033a8:	855e                	mv	a0,s7
    800033aa:	cdfff0ef          	jal	80003088 <bread>
    800033ae:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033b0:	004b2503          	lw	a0,4(s6)
    800033b4:	000a849b          	sext.w	s1,s5
    800033b8:	8762                	mv	a4,s8
    800033ba:	fca4f1e3          	bgeu	s1,a0,8000337c <balloc+0x90>
      m = 1 << (bi % 8);
    800033be:	00777693          	andi	a3,a4,7
    800033c2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033c6:	41f7579b          	sraiw	a5,a4,0x1f
    800033ca:	01d7d79b          	srliw	a5,a5,0x1d
    800033ce:	9fb9                	addw	a5,a5,a4
    800033d0:	4037d79b          	sraiw	a5,a5,0x3
    800033d4:	00f90633          	add	a2,s2,a5
    800033d8:	05864603          	lbu	a2,88(a2)
    800033dc:	00c6f5b3          	and	a1,a3,a2
    800033e0:	d5a1                	beqz	a1,80003328 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033e2:	2705                	addiw	a4,a4,1
    800033e4:	2485                	addiw	s1,s1,1
    800033e6:	fd471ae3          	bne	a4,s4,800033ba <balloc+0xce>
    800033ea:	bf49                	j	8000337c <balloc+0x90>
    800033ec:	6906                	ld	s2,64(sp)
    800033ee:	79e2                	ld	s3,56(sp)
    800033f0:	7a42                	ld	s4,48(sp)
    800033f2:	7aa2                	ld	s5,40(sp)
    800033f4:	7b02                	ld	s6,32(sp)
    800033f6:	6be2                	ld	s7,24(sp)
    800033f8:	6c42                	ld	s8,16(sp)
    800033fa:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800033fc:	00004517          	auipc	a0,0x4
    80003400:	0c450513          	addi	a0,a0,196 # 800074c0 <etext+0x4c0>
    80003404:	8befd0ef          	jal	800004c2 <printf>
  return 0;
    80003408:	4481                	li	s1,0
    8000340a:	b79d                	j	80003370 <balloc+0x84>

000000008000340c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000340c:	7179                	addi	sp,sp,-48
    8000340e:	f406                	sd	ra,40(sp)
    80003410:	f022                	sd	s0,32(sp)
    80003412:	ec26                	sd	s1,24(sp)
    80003414:	e84a                	sd	s2,16(sp)
    80003416:	e44e                	sd	s3,8(sp)
    80003418:	1800                	addi	s0,sp,48
    8000341a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000341c:	47ad                	li	a5,11
    8000341e:	02b7e663          	bltu	a5,a1,8000344a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003422:	02059793          	slli	a5,a1,0x20
    80003426:	01e7d593          	srli	a1,a5,0x1e
    8000342a:	00b504b3          	add	s1,a0,a1
    8000342e:	0504a903          	lw	s2,80(s1)
    80003432:	06091a63          	bnez	s2,800034a6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003436:	4108                	lw	a0,0(a0)
    80003438:	eb5ff0ef          	jal	800032ec <balloc>
    8000343c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003440:	06090363          	beqz	s2,800034a6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003444:	0524a823          	sw	s2,80(s1)
    80003448:	a8b9                	j	800034a6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000344a:	ff45849b          	addiw	s1,a1,-12
    8000344e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003452:	0ff00793          	li	a5,255
    80003456:	06e7ee63          	bltu	a5,a4,800034d2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000345a:	08052903          	lw	s2,128(a0)
    8000345e:	00091d63          	bnez	s2,80003478 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003462:	4108                	lw	a0,0(a0)
    80003464:	e89ff0ef          	jal	800032ec <balloc>
    80003468:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000346c:	02090d63          	beqz	s2,800034a6 <bmap+0x9a>
    80003470:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003472:	0929a023          	sw	s2,128(s3)
    80003476:	a011                	j	8000347a <bmap+0x6e>
    80003478:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000347a:	85ca                	mv	a1,s2
    8000347c:	0009a503          	lw	a0,0(s3)
    80003480:	c09ff0ef          	jal	80003088 <bread>
    80003484:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003486:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000348a:	02049713          	slli	a4,s1,0x20
    8000348e:	01e75593          	srli	a1,a4,0x1e
    80003492:	00b784b3          	add	s1,a5,a1
    80003496:	0004a903          	lw	s2,0(s1)
    8000349a:	00090e63          	beqz	s2,800034b6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000349e:	8552                	mv	a0,s4
    800034a0:	cf1ff0ef          	jal	80003190 <brelse>
    return addr;
    800034a4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800034a6:	854a                	mv	a0,s2
    800034a8:	70a2                	ld	ra,40(sp)
    800034aa:	7402                	ld	s0,32(sp)
    800034ac:	64e2                	ld	s1,24(sp)
    800034ae:	6942                	ld	s2,16(sp)
    800034b0:	69a2                	ld	s3,8(sp)
    800034b2:	6145                	addi	sp,sp,48
    800034b4:	8082                	ret
      addr = balloc(ip->dev);
    800034b6:	0009a503          	lw	a0,0(s3)
    800034ba:	e33ff0ef          	jal	800032ec <balloc>
    800034be:	0005091b          	sext.w	s2,a0
      if(addr){
    800034c2:	fc090ee3          	beqz	s2,8000349e <bmap+0x92>
        a[bn] = addr;
    800034c6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800034ca:	8552                	mv	a0,s4
    800034cc:	50f000ef          	jal	800041da <log_write>
    800034d0:	b7f9                	j	8000349e <bmap+0x92>
    800034d2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800034d4:	00004517          	auipc	a0,0x4
    800034d8:	00450513          	addi	a0,a0,4 # 800074d8 <etext+0x4d8>
    800034dc:	ab8fd0ef          	jal	80000794 <panic>

00000000800034e0 <iget>:
{
    800034e0:	7179                	addi	sp,sp,-48
    800034e2:	f406                	sd	ra,40(sp)
    800034e4:	f022                	sd	s0,32(sp)
    800034e6:	ec26                	sd	s1,24(sp)
    800034e8:	e84a                	sd	s2,16(sp)
    800034ea:	e44e                	sd	s3,8(sp)
    800034ec:	e052                	sd	s4,0(sp)
    800034ee:	1800                	addi	s0,sp,48
    800034f0:	89aa                	mv	s3,a0
    800034f2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034f4:	0001b517          	auipc	a0,0x1b
    800034f8:	4b450513          	addi	a0,a0,1204 # 8001e9a8 <itable>
    800034fc:	ef8fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003500:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003502:	0001b497          	auipc	s1,0x1b
    80003506:	4be48493          	addi	s1,s1,1214 # 8001e9c0 <itable+0x18>
    8000350a:	0001d697          	auipc	a3,0x1d
    8000350e:	f4668693          	addi	a3,a3,-186 # 80020450 <log>
    80003512:	a039                	j	80003520 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003514:	02090963          	beqz	s2,80003546 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003518:	08848493          	addi	s1,s1,136
    8000351c:	02d48863          	beq	s1,a3,8000354c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003520:	449c                	lw	a5,8(s1)
    80003522:	fef059e3          	blez	a5,80003514 <iget+0x34>
    80003526:	4098                	lw	a4,0(s1)
    80003528:	ff3716e3          	bne	a4,s3,80003514 <iget+0x34>
    8000352c:	40d8                	lw	a4,4(s1)
    8000352e:	ff4713e3          	bne	a4,s4,80003514 <iget+0x34>
      ip->ref++;
    80003532:	2785                	addiw	a5,a5,1
    80003534:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003536:	0001b517          	auipc	a0,0x1b
    8000353a:	47250513          	addi	a0,a0,1138 # 8001e9a8 <itable>
    8000353e:	f4efd0ef          	jal	80000c8c <release>
      return ip;
    80003542:	8926                	mv	s2,s1
    80003544:	a02d                	j	8000356e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003546:	fbe9                	bnez	a5,80003518 <iget+0x38>
      empty = ip;
    80003548:	8926                	mv	s2,s1
    8000354a:	b7f9                	j	80003518 <iget+0x38>
  if(empty == 0)
    8000354c:	02090a63          	beqz	s2,80003580 <iget+0xa0>
  ip->dev = dev;
    80003550:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003554:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003558:	4785                	li	a5,1
    8000355a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000355e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003562:	0001b517          	auipc	a0,0x1b
    80003566:	44650513          	addi	a0,a0,1094 # 8001e9a8 <itable>
    8000356a:	f22fd0ef          	jal	80000c8c <release>
}
    8000356e:	854a                	mv	a0,s2
    80003570:	70a2                	ld	ra,40(sp)
    80003572:	7402                	ld	s0,32(sp)
    80003574:	64e2                	ld	s1,24(sp)
    80003576:	6942                	ld	s2,16(sp)
    80003578:	69a2                	ld	s3,8(sp)
    8000357a:	6a02                	ld	s4,0(sp)
    8000357c:	6145                	addi	sp,sp,48
    8000357e:	8082                	ret
    panic("iget: no inodes");
    80003580:	00004517          	auipc	a0,0x4
    80003584:	f7050513          	addi	a0,a0,-144 # 800074f0 <etext+0x4f0>
    80003588:	a0cfd0ef          	jal	80000794 <panic>

000000008000358c <fsinit>:
fsinit(int dev) {
    8000358c:	7179                	addi	sp,sp,-48
    8000358e:	f406                	sd	ra,40(sp)
    80003590:	f022                	sd	s0,32(sp)
    80003592:	ec26                	sd	s1,24(sp)
    80003594:	e84a                	sd	s2,16(sp)
    80003596:	e44e                	sd	s3,8(sp)
    80003598:	1800                	addi	s0,sp,48
    8000359a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000359c:	4585                	li	a1,1
    8000359e:	aebff0ef          	jal	80003088 <bread>
    800035a2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035a4:	0001b997          	auipc	s3,0x1b
    800035a8:	3e498993          	addi	s3,s3,996 # 8001e988 <sb>
    800035ac:	02000613          	li	a2,32
    800035b0:	05850593          	addi	a1,a0,88
    800035b4:	854e                	mv	a0,s3
    800035b6:	f6efd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800035ba:	8526                	mv	a0,s1
    800035bc:	bd5ff0ef          	jal	80003190 <brelse>
  if(sb.magic != FSMAGIC)
    800035c0:	0009a703          	lw	a4,0(s3)
    800035c4:	102037b7          	lui	a5,0x10203
    800035c8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035cc:	02f71063          	bne	a4,a5,800035ec <fsinit+0x60>
  initlog(dev, &sb);
    800035d0:	0001b597          	auipc	a1,0x1b
    800035d4:	3b858593          	addi	a1,a1,952 # 8001e988 <sb>
    800035d8:	854a                	mv	a0,s2
    800035da:	1f9000ef          	jal	80003fd2 <initlog>
}
    800035de:	70a2                	ld	ra,40(sp)
    800035e0:	7402                	ld	s0,32(sp)
    800035e2:	64e2                	ld	s1,24(sp)
    800035e4:	6942                	ld	s2,16(sp)
    800035e6:	69a2                	ld	s3,8(sp)
    800035e8:	6145                	addi	sp,sp,48
    800035ea:	8082                	ret
    panic("invalid file system");
    800035ec:	00004517          	auipc	a0,0x4
    800035f0:	f1450513          	addi	a0,a0,-236 # 80007500 <etext+0x500>
    800035f4:	9a0fd0ef          	jal	80000794 <panic>

00000000800035f8 <iinit>:
{
    800035f8:	7179                	addi	sp,sp,-48
    800035fa:	f406                	sd	ra,40(sp)
    800035fc:	f022                	sd	s0,32(sp)
    800035fe:	ec26                	sd	s1,24(sp)
    80003600:	e84a                	sd	s2,16(sp)
    80003602:	e44e                	sd	s3,8(sp)
    80003604:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003606:	00004597          	auipc	a1,0x4
    8000360a:	f1258593          	addi	a1,a1,-238 # 80007518 <etext+0x518>
    8000360e:	0001b517          	auipc	a0,0x1b
    80003612:	39a50513          	addi	a0,a0,922 # 8001e9a8 <itable>
    80003616:	d5efd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000361a:	0001b497          	auipc	s1,0x1b
    8000361e:	3b648493          	addi	s1,s1,950 # 8001e9d0 <itable+0x28>
    80003622:	0001d997          	auipc	s3,0x1d
    80003626:	e3e98993          	addi	s3,s3,-450 # 80020460 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000362a:	00004917          	auipc	s2,0x4
    8000362e:	ef690913          	addi	s2,s2,-266 # 80007520 <etext+0x520>
    80003632:	85ca                	mv	a1,s2
    80003634:	8526                	mv	a0,s1
    80003636:	475000ef          	jal	800042aa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000363a:	08848493          	addi	s1,s1,136
    8000363e:	ff349ae3          	bne	s1,s3,80003632 <iinit+0x3a>
}
    80003642:	70a2                	ld	ra,40(sp)
    80003644:	7402                	ld	s0,32(sp)
    80003646:	64e2                	ld	s1,24(sp)
    80003648:	6942                	ld	s2,16(sp)
    8000364a:	69a2                	ld	s3,8(sp)
    8000364c:	6145                	addi	sp,sp,48
    8000364e:	8082                	ret

0000000080003650 <ialloc>:
{
    80003650:	7139                	addi	sp,sp,-64
    80003652:	fc06                	sd	ra,56(sp)
    80003654:	f822                	sd	s0,48(sp)
    80003656:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003658:	0001b717          	auipc	a4,0x1b
    8000365c:	33c72703          	lw	a4,828(a4) # 8001e994 <sb+0xc>
    80003660:	4785                	li	a5,1
    80003662:	06e7f063          	bgeu	a5,a4,800036c2 <ialloc+0x72>
    80003666:	f426                	sd	s1,40(sp)
    80003668:	f04a                	sd	s2,32(sp)
    8000366a:	ec4e                	sd	s3,24(sp)
    8000366c:	e852                	sd	s4,16(sp)
    8000366e:	e456                	sd	s5,8(sp)
    80003670:	e05a                	sd	s6,0(sp)
    80003672:	8aaa                	mv	s5,a0
    80003674:	8b2e                	mv	s6,a1
    80003676:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003678:	0001ba17          	auipc	s4,0x1b
    8000367c:	310a0a13          	addi	s4,s4,784 # 8001e988 <sb>
    80003680:	00495593          	srli	a1,s2,0x4
    80003684:	018a2783          	lw	a5,24(s4)
    80003688:	9dbd                	addw	a1,a1,a5
    8000368a:	8556                	mv	a0,s5
    8000368c:	9fdff0ef          	jal	80003088 <bread>
    80003690:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003692:	05850993          	addi	s3,a0,88
    80003696:	00f97793          	andi	a5,s2,15
    8000369a:	079a                	slli	a5,a5,0x6
    8000369c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000369e:	00099783          	lh	a5,0(s3)
    800036a2:	cb9d                	beqz	a5,800036d8 <ialloc+0x88>
    brelse(bp);
    800036a4:	aedff0ef          	jal	80003190 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036a8:	0905                	addi	s2,s2,1
    800036aa:	00ca2703          	lw	a4,12(s4)
    800036ae:	0009079b          	sext.w	a5,s2
    800036b2:	fce7e7e3          	bltu	a5,a4,80003680 <ialloc+0x30>
    800036b6:	74a2                	ld	s1,40(sp)
    800036b8:	7902                	ld	s2,32(sp)
    800036ba:	69e2                	ld	s3,24(sp)
    800036bc:	6a42                	ld	s4,16(sp)
    800036be:	6aa2                	ld	s5,8(sp)
    800036c0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800036c2:	00004517          	auipc	a0,0x4
    800036c6:	e6650513          	addi	a0,a0,-410 # 80007528 <etext+0x528>
    800036ca:	df9fc0ef          	jal	800004c2 <printf>
  return 0;
    800036ce:	4501                	li	a0,0
}
    800036d0:	70e2                	ld	ra,56(sp)
    800036d2:	7442                	ld	s0,48(sp)
    800036d4:	6121                	addi	sp,sp,64
    800036d6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036d8:	04000613          	li	a2,64
    800036dc:	4581                	li	a1,0
    800036de:	854e                	mv	a0,s3
    800036e0:	de8fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800036e4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036e8:	8526                	mv	a0,s1
    800036ea:	2f1000ef          	jal	800041da <log_write>
      brelse(bp);
    800036ee:	8526                	mv	a0,s1
    800036f0:	aa1ff0ef          	jal	80003190 <brelse>
      return iget(dev, inum);
    800036f4:	0009059b          	sext.w	a1,s2
    800036f8:	8556                	mv	a0,s5
    800036fa:	de7ff0ef          	jal	800034e0 <iget>
    800036fe:	74a2                	ld	s1,40(sp)
    80003700:	7902                	ld	s2,32(sp)
    80003702:	69e2                	ld	s3,24(sp)
    80003704:	6a42                	ld	s4,16(sp)
    80003706:	6aa2                	ld	s5,8(sp)
    80003708:	6b02                	ld	s6,0(sp)
    8000370a:	b7d9                	j	800036d0 <ialloc+0x80>

000000008000370c <iupdate>:
{
    8000370c:	1101                	addi	sp,sp,-32
    8000370e:	ec06                	sd	ra,24(sp)
    80003710:	e822                	sd	s0,16(sp)
    80003712:	e426                	sd	s1,8(sp)
    80003714:	e04a                	sd	s2,0(sp)
    80003716:	1000                	addi	s0,sp,32
    80003718:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000371a:	415c                	lw	a5,4(a0)
    8000371c:	0047d79b          	srliw	a5,a5,0x4
    80003720:	0001b597          	auipc	a1,0x1b
    80003724:	2805a583          	lw	a1,640(a1) # 8001e9a0 <sb+0x18>
    80003728:	9dbd                	addw	a1,a1,a5
    8000372a:	4108                	lw	a0,0(a0)
    8000372c:	95dff0ef          	jal	80003088 <bread>
    80003730:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003732:	05850793          	addi	a5,a0,88
    80003736:	40d8                	lw	a4,4(s1)
    80003738:	8b3d                	andi	a4,a4,15
    8000373a:	071a                	slli	a4,a4,0x6
    8000373c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000373e:	04449703          	lh	a4,68(s1)
    80003742:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003746:	04649703          	lh	a4,70(s1)
    8000374a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000374e:	04849703          	lh	a4,72(s1)
    80003752:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003756:	04a49703          	lh	a4,74(s1)
    8000375a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000375e:	44f8                	lw	a4,76(s1)
    80003760:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003762:	03400613          	li	a2,52
    80003766:	05048593          	addi	a1,s1,80
    8000376a:	00c78513          	addi	a0,a5,12
    8000376e:	db6fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003772:	854a                	mv	a0,s2
    80003774:	267000ef          	jal	800041da <log_write>
  brelse(bp);
    80003778:	854a                	mv	a0,s2
    8000377a:	a17ff0ef          	jal	80003190 <brelse>
}
    8000377e:	60e2                	ld	ra,24(sp)
    80003780:	6442                	ld	s0,16(sp)
    80003782:	64a2                	ld	s1,8(sp)
    80003784:	6902                	ld	s2,0(sp)
    80003786:	6105                	addi	sp,sp,32
    80003788:	8082                	ret

000000008000378a <idup>:
{
    8000378a:	1101                	addi	sp,sp,-32
    8000378c:	ec06                	sd	ra,24(sp)
    8000378e:	e822                	sd	s0,16(sp)
    80003790:	e426                	sd	s1,8(sp)
    80003792:	1000                	addi	s0,sp,32
    80003794:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003796:	0001b517          	auipc	a0,0x1b
    8000379a:	21250513          	addi	a0,a0,530 # 8001e9a8 <itable>
    8000379e:	c56fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800037a2:	449c                	lw	a5,8(s1)
    800037a4:	2785                	addiw	a5,a5,1
    800037a6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037a8:	0001b517          	auipc	a0,0x1b
    800037ac:	20050513          	addi	a0,a0,512 # 8001e9a8 <itable>
    800037b0:	cdcfd0ef          	jal	80000c8c <release>
}
    800037b4:	8526                	mv	a0,s1
    800037b6:	60e2                	ld	ra,24(sp)
    800037b8:	6442                	ld	s0,16(sp)
    800037ba:	64a2                	ld	s1,8(sp)
    800037bc:	6105                	addi	sp,sp,32
    800037be:	8082                	ret

00000000800037c0 <ilock>:
{
    800037c0:	1101                	addi	sp,sp,-32
    800037c2:	ec06                	sd	ra,24(sp)
    800037c4:	e822                	sd	s0,16(sp)
    800037c6:	e426                	sd	s1,8(sp)
    800037c8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037ca:	cd19                	beqz	a0,800037e8 <ilock+0x28>
    800037cc:	84aa                	mv	s1,a0
    800037ce:	451c                	lw	a5,8(a0)
    800037d0:	00f05c63          	blez	a5,800037e8 <ilock+0x28>
  acquiresleep(&ip->lock);
    800037d4:	0541                	addi	a0,a0,16
    800037d6:	30b000ef          	jal	800042e0 <acquiresleep>
  if(ip->valid == 0){
    800037da:	40bc                	lw	a5,64(s1)
    800037dc:	cf89                	beqz	a5,800037f6 <ilock+0x36>
}
    800037de:	60e2                	ld	ra,24(sp)
    800037e0:	6442                	ld	s0,16(sp)
    800037e2:	64a2                	ld	s1,8(sp)
    800037e4:	6105                	addi	sp,sp,32
    800037e6:	8082                	ret
    800037e8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800037ea:	00004517          	auipc	a0,0x4
    800037ee:	d5650513          	addi	a0,a0,-682 # 80007540 <etext+0x540>
    800037f2:	fa3fc0ef          	jal	80000794 <panic>
    800037f6:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037f8:	40dc                	lw	a5,4(s1)
    800037fa:	0047d79b          	srliw	a5,a5,0x4
    800037fe:	0001b597          	auipc	a1,0x1b
    80003802:	1a25a583          	lw	a1,418(a1) # 8001e9a0 <sb+0x18>
    80003806:	9dbd                	addw	a1,a1,a5
    80003808:	4088                	lw	a0,0(s1)
    8000380a:	87fff0ef          	jal	80003088 <bread>
    8000380e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003810:	05850593          	addi	a1,a0,88
    80003814:	40dc                	lw	a5,4(s1)
    80003816:	8bbd                	andi	a5,a5,15
    80003818:	079a                	slli	a5,a5,0x6
    8000381a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000381c:	00059783          	lh	a5,0(a1)
    80003820:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003824:	00259783          	lh	a5,2(a1)
    80003828:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000382c:	00459783          	lh	a5,4(a1)
    80003830:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003834:	00659783          	lh	a5,6(a1)
    80003838:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000383c:	459c                	lw	a5,8(a1)
    8000383e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003840:	03400613          	li	a2,52
    80003844:	05b1                	addi	a1,a1,12
    80003846:	05048513          	addi	a0,s1,80
    8000384a:	cdafd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    8000384e:	854a                	mv	a0,s2
    80003850:	941ff0ef          	jal	80003190 <brelse>
    ip->valid = 1;
    80003854:	4785                	li	a5,1
    80003856:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003858:	04449783          	lh	a5,68(s1)
    8000385c:	c399                	beqz	a5,80003862 <ilock+0xa2>
    8000385e:	6902                	ld	s2,0(sp)
    80003860:	bfbd                	j	800037de <ilock+0x1e>
      panic("ilock: no type");
    80003862:	00004517          	auipc	a0,0x4
    80003866:	ce650513          	addi	a0,a0,-794 # 80007548 <etext+0x548>
    8000386a:	f2bfc0ef          	jal	80000794 <panic>

000000008000386e <iunlock>:
{
    8000386e:	1101                	addi	sp,sp,-32
    80003870:	ec06                	sd	ra,24(sp)
    80003872:	e822                	sd	s0,16(sp)
    80003874:	e426                	sd	s1,8(sp)
    80003876:	e04a                	sd	s2,0(sp)
    80003878:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000387a:	c505                	beqz	a0,800038a2 <iunlock+0x34>
    8000387c:	84aa                	mv	s1,a0
    8000387e:	01050913          	addi	s2,a0,16
    80003882:	854a                	mv	a0,s2
    80003884:	2db000ef          	jal	8000435e <holdingsleep>
    80003888:	cd09                	beqz	a0,800038a2 <iunlock+0x34>
    8000388a:	449c                	lw	a5,8(s1)
    8000388c:	00f05b63          	blez	a5,800038a2 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003890:	854a                	mv	a0,s2
    80003892:	295000ef          	jal	80004326 <releasesleep>
}
    80003896:	60e2                	ld	ra,24(sp)
    80003898:	6442                	ld	s0,16(sp)
    8000389a:	64a2                	ld	s1,8(sp)
    8000389c:	6902                	ld	s2,0(sp)
    8000389e:	6105                	addi	sp,sp,32
    800038a0:	8082                	ret
    panic("iunlock");
    800038a2:	00004517          	auipc	a0,0x4
    800038a6:	cb650513          	addi	a0,a0,-842 # 80007558 <etext+0x558>
    800038aa:	eebfc0ef          	jal	80000794 <panic>

00000000800038ae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038ae:	7179                	addi	sp,sp,-48
    800038b0:	f406                	sd	ra,40(sp)
    800038b2:	f022                	sd	s0,32(sp)
    800038b4:	ec26                	sd	s1,24(sp)
    800038b6:	e84a                	sd	s2,16(sp)
    800038b8:	e44e                	sd	s3,8(sp)
    800038ba:	1800                	addi	s0,sp,48
    800038bc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038be:	05050493          	addi	s1,a0,80
    800038c2:	08050913          	addi	s2,a0,128
    800038c6:	a021                	j	800038ce <itrunc+0x20>
    800038c8:	0491                	addi	s1,s1,4
    800038ca:	01248b63          	beq	s1,s2,800038e0 <itrunc+0x32>
    if(ip->addrs[i]){
    800038ce:	408c                	lw	a1,0(s1)
    800038d0:	dde5                	beqz	a1,800038c8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800038d2:	0009a503          	lw	a0,0(s3)
    800038d6:	9abff0ef          	jal	80003280 <bfree>
      ip->addrs[i] = 0;
    800038da:	0004a023          	sw	zero,0(s1)
    800038de:	b7ed                	j	800038c8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038e0:	0809a583          	lw	a1,128(s3)
    800038e4:	ed89                	bnez	a1,800038fe <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038e6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038ea:	854e                	mv	a0,s3
    800038ec:	e21ff0ef          	jal	8000370c <iupdate>
}
    800038f0:	70a2                	ld	ra,40(sp)
    800038f2:	7402                	ld	s0,32(sp)
    800038f4:	64e2                	ld	s1,24(sp)
    800038f6:	6942                	ld	s2,16(sp)
    800038f8:	69a2                	ld	s3,8(sp)
    800038fa:	6145                	addi	sp,sp,48
    800038fc:	8082                	ret
    800038fe:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003900:	0009a503          	lw	a0,0(s3)
    80003904:	f84ff0ef          	jal	80003088 <bread>
    80003908:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000390a:	05850493          	addi	s1,a0,88
    8000390e:	45850913          	addi	s2,a0,1112
    80003912:	a021                	j	8000391a <itrunc+0x6c>
    80003914:	0491                	addi	s1,s1,4
    80003916:	01248963          	beq	s1,s2,80003928 <itrunc+0x7a>
      if(a[j])
    8000391a:	408c                	lw	a1,0(s1)
    8000391c:	dde5                	beqz	a1,80003914 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000391e:	0009a503          	lw	a0,0(s3)
    80003922:	95fff0ef          	jal	80003280 <bfree>
    80003926:	b7fd                	j	80003914 <itrunc+0x66>
    brelse(bp);
    80003928:	8552                	mv	a0,s4
    8000392a:	867ff0ef          	jal	80003190 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000392e:	0809a583          	lw	a1,128(s3)
    80003932:	0009a503          	lw	a0,0(s3)
    80003936:	94bff0ef          	jal	80003280 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000393a:	0809a023          	sw	zero,128(s3)
    8000393e:	6a02                	ld	s4,0(sp)
    80003940:	b75d                	j	800038e6 <itrunc+0x38>

0000000080003942 <iput>:
{
    80003942:	1101                	addi	sp,sp,-32
    80003944:	ec06                	sd	ra,24(sp)
    80003946:	e822                	sd	s0,16(sp)
    80003948:	e426                	sd	s1,8(sp)
    8000394a:	1000                	addi	s0,sp,32
    8000394c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000394e:	0001b517          	auipc	a0,0x1b
    80003952:	05a50513          	addi	a0,a0,90 # 8001e9a8 <itable>
    80003956:	a9efd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000395a:	4498                	lw	a4,8(s1)
    8000395c:	4785                	li	a5,1
    8000395e:	02f70063          	beq	a4,a5,8000397e <iput+0x3c>
  ip->ref--;
    80003962:	449c                	lw	a5,8(s1)
    80003964:	37fd                	addiw	a5,a5,-1
    80003966:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003968:	0001b517          	auipc	a0,0x1b
    8000396c:	04050513          	addi	a0,a0,64 # 8001e9a8 <itable>
    80003970:	b1cfd0ef          	jal	80000c8c <release>
}
    80003974:	60e2                	ld	ra,24(sp)
    80003976:	6442                	ld	s0,16(sp)
    80003978:	64a2                	ld	s1,8(sp)
    8000397a:	6105                	addi	sp,sp,32
    8000397c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000397e:	40bc                	lw	a5,64(s1)
    80003980:	d3ed                	beqz	a5,80003962 <iput+0x20>
    80003982:	04a49783          	lh	a5,74(s1)
    80003986:	fff1                	bnez	a5,80003962 <iput+0x20>
    80003988:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000398a:	01048913          	addi	s2,s1,16
    8000398e:	854a                	mv	a0,s2
    80003990:	151000ef          	jal	800042e0 <acquiresleep>
    release(&itable.lock);
    80003994:	0001b517          	auipc	a0,0x1b
    80003998:	01450513          	addi	a0,a0,20 # 8001e9a8 <itable>
    8000399c:	af0fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800039a0:	8526                	mv	a0,s1
    800039a2:	f0dff0ef          	jal	800038ae <itrunc>
    ip->type = 0;
    800039a6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039aa:	8526                	mv	a0,s1
    800039ac:	d61ff0ef          	jal	8000370c <iupdate>
    ip->valid = 0;
    800039b0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039b4:	854a                	mv	a0,s2
    800039b6:	171000ef          	jal	80004326 <releasesleep>
    acquire(&itable.lock);
    800039ba:	0001b517          	auipc	a0,0x1b
    800039be:	fee50513          	addi	a0,a0,-18 # 8001e9a8 <itable>
    800039c2:	a32fd0ef          	jal	80000bf4 <acquire>
    800039c6:	6902                	ld	s2,0(sp)
    800039c8:	bf69                	j	80003962 <iput+0x20>

00000000800039ca <iunlockput>:
{
    800039ca:	1101                	addi	sp,sp,-32
    800039cc:	ec06                	sd	ra,24(sp)
    800039ce:	e822                	sd	s0,16(sp)
    800039d0:	e426                	sd	s1,8(sp)
    800039d2:	1000                	addi	s0,sp,32
    800039d4:	84aa                	mv	s1,a0
  iunlock(ip);
    800039d6:	e99ff0ef          	jal	8000386e <iunlock>
  iput(ip);
    800039da:	8526                	mv	a0,s1
    800039dc:	f67ff0ef          	jal	80003942 <iput>
}
    800039e0:	60e2                	ld	ra,24(sp)
    800039e2:	6442                	ld	s0,16(sp)
    800039e4:	64a2                	ld	s1,8(sp)
    800039e6:	6105                	addi	sp,sp,32
    800039e8:	8082                	ret

00000000800039ea <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039ea:	1141                	addi	sp,sp,-16
    800039ec:	e422                	sd	s0,8(sp)
    800039ee:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039f0:	411c                	lw	a5,0(a0)
    800039f2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039f4:	415c                	lw	a5,4(a0)
    800039f6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039f8:	04451783          	lh	a5,68(a0)
    800039fc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a00:	04a51783          	lh	a5,74(a0)
    80003a04:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a08:	04c56783          	lwu	a5,76(a0)
    80003a0c:	e99c                	sd	a5,16(a1)
}
    80003a0e:	6422                	ld	s0,8(sp)
    80003a10:	0141                	addi	sp,sp,16
    80003a12:	8082                	ret

0000000080003a14 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a14:	457c                	lw	a5,76(a0)
    80003a16:	0ed7eb63          	bltu	a5,a3,80003b0c <readi+0xf8>
{
    80003a1a:	7159                	addi	sp,sp,-112
    80003a1c:	f486                	sd	ra,104(sp)
    80003a1e:	f0a2                	sd	s0,96(sp)
    80003a20:	eca6                	sd	s1,88(sp)
    80003a22:	e0d2                	sd	s4,64(sp)
    80003a24:	fc56                	sd	s5,56(sp)
    80003a26:	f85a                	sd	s6,48(sp)
    80003a28:	f45e                	sd	s7,40(sp)
    80003a2a:	1880                	addi	s0,sp,112
    80003a2c:	8b2a                	mv	s6,a0
    80003a2e:	8bae                	mv	s7,a1
    80003a30:	8a32                	mv	s4,a2
    80003a32:	84b6                	mv	s1,a3
    80003a34:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a36:	9f35                	addw	a4,a4,a3
    return 0;
    80003a38:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a3a:	0cd76063          	bltu	a4,a3,80003afa <readi+0xe6>
    80003a3e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003a40:	00e7f463          	bgeu	a5,a4,80003a48 <readi+0x34>
    n = ip->size - off;
    80003a44:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a48:	080a8f63          	beqz	s5,80003ae6 <readi+0xd2>
    80003a4c:	e8ca                	sd	s2,80(sp)
    80003a4e:	f062                	sd	s8,32(sp)
    80003a50:	ec66                	sd	s9,24(sp)
    80003a52:	e86a                	sd	s10,16(sp)
    80003a54:	e46e                	sd	s11,8(sp)
    80003a56:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a58:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a5c:	5c7d                	li	s8,-1
    80003a5e:	a80d                	j	80003a90 <readi+0x7c>
    80003a60:	020d1d93          	slli	s11,s10,0x20
    80003a64:	020ddd93          	srli	s11,s11,0x20
    80003a68:	05890613          	addi	a2,s2,88
    80003a6c:	86ee                	mv	a3,s11
    80003a6e:	963a                	add	a2,a2,a4
    80003a70:	85d2                	mv	a1,s4
    80003a72:	855e                	mv	a0,s7
    80003a74:	9bffe0ef          	jal	80002432 <either_copyout>
    80003a78:	05850763          	beq	a0,s8,80003ac6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	f12ff0ef          	jal	80003190 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a82:	013d09bb          	addw	s3,s10,s3
    80003a86:	009d04bb          	addw	s1,s10,s1
    80003a8a:	9a6e                	add	s4,s4,s11
    80003a8c:	0559f763          	bgeu	s3,s5,80003ada <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003a90:	00a4d59b          	srliw	a1,s1,0xa
    80003a94:	855a                	mv	a0,s6
    80003a96:	977ff0ef          	jal	8000340c <bmap>
    80003a9a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a9e:	c5b1                	beqz	a1,80003aea <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003aa0:	000b2503          	lw	a0,0(s6)
    80003aa4:	de4ff0ef          	jal	80003088 <bread>
    80003aa8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aaa:	3ff4f713          	andi	a4,s1,1023
    80003aae:	40ec87bb          	subw	a5,s9,a4
    80003ab2:	413a86bb          	subw	a3,s5,s3
    80003ab6:	8d3e                	mv	s10,a5
    80003ab8:	2781                	sext.w	a5,a5
    80003aba:	0006861b          	sext.w	a2,a3
    80003abe:	faf671e3          	bgeu	a2,a5,80003a60 <readi+0x4c>
    80003ac2:	8d36                	mv	s10,a3
    80003ac4:	bf71                	j	80003a60 <readi+0x4c>
      brelse(bp);
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	ec8ff0ef          	jal	80003190 <brelse>
      tot = -1;
    80003acc:	59fd                	li	s3,-1
      break;
    80003ace:	6946                	ld	s2,80(sp)
    80003ad0:	7c02                	ld	s8,32(sp)
    80003ad2:	6ce2                	ld	s9,24(sp)
    80003ad4:	6d42                	ld	s10,16(sp)
    80003ad6:	6da2                	ld	s11,8(sp)
    80003ad8:	a831                	j	80003af4 <readi+0xe0>
    80003ada:	6946                	ld	s2,80(sp)
    80003adc:	7c02                	ld	s8,32(sp)
    80003ade:	6ce2                	ld	s9,24(sp)
    80003ae0:	6d42                	ld	s10,16(sp)
    80003ae2:	6da2                	ld	s11,8(sp)
    80003ae4:	a801                	j	80003af4 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae6:	89d6                	mv	s3,s5
    80003ae8:	a031                	j	80003af4 <readi+0xe0>
    80003aea:	6946                	ld	s2,80(sp)
    80003aec:	7c02                	ld	s8,32(sp)
    80003aee:	6ce2                	ld	s9,24(sp)
    80003af0:	6d42                	ld	s10,16(sp)
    80003af2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003af4:	0009851b          	sext.w	a0,s3
    80003af8:	69a6                	ld	s3,72(sp)
}
    80003afa:	70a6                	ld	ra,104(sp)
    80003afc:	7406                	ld	s0,96(sp)
    80003afe:	64e6                	ld	s1,88(sp)
    80003b00:	6a06                	ld	s4,64(sp)
    80003b02:	7ae2                	ld	s5,56(sp)
    80003b04:	7b42                	ld	s6,48(sp)
    80003b06:	7ba2                	ld	s7,40(sp)
    80003b08:	6165                	addi	sp,sp,112
    80003b0a:	8082                	ret
    return 0;
    80003b0c:	4501                	li	a0,0
}
    80003b0e:	8082                	ret

0000000080003b10 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b10:	457c                	lw	a5,76(a0)
    80003b12:	10d7e063          	bltu	a5,a3,80003c12 <writei+0x102>
{
    80003b16:	7159                	addi	sp,sp,-112
    80003b18:	f486                	sd	ra,104(sp)
    80003b1a:	f0a2                	sd	s0,96(sp)
    80003b1c:	e8ca                	sd	s2,80(sp)
    80003b1e:	e0d2                	sd	s4,64(sp)
    80003b20:	fc56                	sd	s5,56(sp)
    80003b22:	f85a                	sd	s6,48(sp)
    80003b24:	f45e                	sd	s7,40(sp)
    80003b26:	1880                	addi	s0,sp,112
    80003b28:	8aaa                	mv	s5,a0
    80003b2a:	8bae                	mv	s7,a1
    80003b2c:	8a32                	mv	s4,a2
    80003b2e:	8936                	mv	s2,a3
    80003b30:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b32:	00e687bb          	addw	a5,a3,a4
    80003b36:	0ed7e063          	bltu	a5,a3,80003c16 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b3a:	00043737          	lui	a4,0x43
    80003b3e:	0cf76e63          	bltu	a4,a5,80003c1a <writei+0x10a>
    80003b42:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b44:	0a0b0f63          	beqz	s6,80003c02 <writei+0xf2>
    80003b48:	eca6                	sd	s1,88(sp)
    80003b4a:	f062                	sd	s8,32(sp)
    80003b4c:	ec66                	sd	s9,24(sp)
    80003b4e:	e86a                	sd	s10,16(sp)
    80003b50:	e46e                	sd	s11,8(sp)
    80003b52:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b54:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b58:	5c7d                	li	s8,-1
    80003b5a:	a825                	j	80003b92 <writei+0x82>
    80003b5c:	020d1d93          	slli	s11,s10,0x20
    80003b60:	020ddd93          	srli	s11,s11,0x20
    80003b64:	05848513          	addi	a0,s1,88
    80003b68:	86ee                	mv	a3,s11
    80003b6a:	8652                	mv	a2,s4
    80003b6c:	85de                	mv	a1,s7
    80003b6e:	953a                	add	a0,a0,a4
    80003b70:	90dfe0ef          	jal	8000247c <either_copyin>
    80003b74:	05850a63          	beq	a0,s8,80003bc8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b78:	8526                	mv	a0,s1
    80003b7a:	660000ef          	jal	800041da <log_write>
    brelse(bp);
    80003b7e:	8526                	mv	a0,s1
    80003b80:	e10ff0ef          	jal	80003190 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b84:	013d09bb          	addw	s3,s10,s3
    80003b88:	012d093b          	addw	s2,s10,s2
    80003b8c:	9a6e                	add	s4,s4,s11
    80003b8e:	0569f063          	bgeu	s3,s6,80003bce <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003b92:	00a9559b          	srliw	a1,s2,0xa
    80003b96:	8556                	mv	a0,s5
    80003b98:	875ff0ef          	jal	8000340c <bmap>
    80003b9c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ba0:	c59d                	beqz	a1,80003bce <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003ba2:	000aa503          	lw	a0,0(s5)
    80003ba6:	ce2ff0ef          	jal	80003088 <bread>
    80003baa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bac:	3ff97713          	andi	a4,s2,1023
    80003bb0:	40ec87bb          	subw	a5,s9,a4
    80003bb4:	413b06bb          	subw	a3,s6,s3
    80003bb8:	8d3e                	mv	s10,a5
    80003bba:	2781                	sext.w	a5,a5
    80003bbc:	0006861b          	sext.w	a2,a3
    80003bc0:	f8f67ee3          	bgeu	a2,a5,80003b5c <writei+0x4c>
    80003bc4:	8d36                	mv	s10,a3
    80003bc6:	bf59                	j	80003b5c <writei+0x4c>
      brelse(bp);
    80003bc8:	8526                	mv	a0,s1
    80003bca:	dc6ff0ef          	jal	80003190 <brelse>
  }

  if(off > ip->size)
    80003bce:	04caa783          	lw	a5,76(s5)
    80003bd2:	0327fa63          	bgeu	a5,s2,80003c06 <writei+0xf6>
    ip->size = off;
    80003bd6:	052aa623          	sw	s2,76(s5)
    80003bda:	64e6                	ld	s1,88(sp)
    80003bdc:	7c02                	ld	s8,32(sp)
    80003bde:	6ce2                	ld	s9,24(sp)
    80003be0:	6d42                	ld	s10,16(sp)
    80003be2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003be4:	8556                	mv	a0,s5
    80003be6:	b27ff0ef          	jal	8000370c <iupdate>

  return tot;
    80003bea:	0009851b          	sext.w	a0,s3
    80003bee:	69a6                	ld	s3,72(sp)
}
    80003bf0:	70a6                	ld	ra,104(sp)
    80003bf2:	7406                	ld	s0,96(sp)
    80003bf4:	6946                	ld	s2,80(sp)
    80003bf6:	6a06                	ld	s4,64(sp)
    80003bf8:	7ae2                	ld	s5,56(sp)
    80003bfa:	7b42                	ld	s6,48(sp)
    80003bfc:	7ba2                	ld	s7,40(sp)
    80003bfe:	6165                	addi	sp,sp,112
    80003c00:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c02:	89da                	mv	s3,s6
    80003c04:	b7c5                	j	80003be4 <writei+0xd4>
    80003c06:	64e6                	ld	s1,88(sp)
    80003c08:	7c02                	ld	s8,32(sp)
    80003c0a:	6ce2                	ld	s9,24(sp)
    80003c0c:	6d42                	ld	s10,16(sp)
    80003c0e:	6da2                	ld	s11,8(sp)
    80003c10:	bfd1                	j	80003be4 <writei+0xd4>
    return -1;
    80003c12:	557d                	li	a0,-1
}
    80003c14:	8082                	ret
    return -1;
    80003c16:	557d                	li	a0,-1
    80003c18:	bfe1                	j	80003bf0 <writei+0xe0>
    return -1;
    80003c1a:	557d                	li	a0,-1
    80003c1c:	bfd1                	j	80003bf0 <writei+0xe0>

0000000080003c1e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c1e:	1141                	addi	sp,sp,-16
    80003c20:	e406                	sd	ra,8(sp)
    80003c22:	e022                	sd	s0,0(sp)
    80003c24:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c26:	4639                	li	a2,14
    80003c28:	96cfd0ef          	jal	80000d94 <strncmp>
}
    80003c2c:	60a2                	ld	ra,8(sp)
    80003c2e:	6402                	ld	s0,0(sp)
    80003c30:	0141                	addi	sp,sp,16
    80003c32:	8082                	ret

0000000080003c34 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c34:	7139                	addi	sp,sp,-64
    80003c36:	fc06                	sd	ra,56(sp)
    80003c38:	f822                	sd	s0,48(sp)
    80003c3a:	f426                	sd	s1,40(sp)
    80003c3c:	f04a                	sd	s2,32(sp)
    80003c3e:	ec4e                	sd	s3,24(sp)
    80003c40:	e852                	sd	s4,16(sp)
    80003c42:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c44:	04451703          	lh	a4,68(a0)
    80003c48:	4785                	li	a5,1
    80003c4a:	00f71a63          	bne	a4,a5,80003c5e <dirlookup+0x2a>
    80003c4e:	892a                	mv	s2,a0
    80003c50:	89ae                	mv	s3,a1
    80003c52:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c54:	457c                	lw	a5,76(a0)
    80003c56:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c58:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c5a:	e39d                	bnez	a5,80003c80 <dirlookup+0x4c>
    80003c5c:	a095                	j	80003cc0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003c5e:	00004517          	auipc	a0,0x4
    80003c62:	90250513          	addi	a0,a0,-1790 # 80007560 <etext+0x560>
    80003c66:	b2ffc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003c6a:	00004517          	auipc	a0,0x4
    80003c6e:	90e50513          	addi	a0,a0,-1778 # 80007578 <etext+0x578>
    80003c72:	b23fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c76:	24c1                	addiw	s1,s1,16
    80003c78:	04c92783          	lw	a5,76(s2)
    80003c7c:	04f4f163          	bgeu	s1,a5,80003cbe <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c80:	4741                	li	a4,16
    80003c82:	86a6                	mv	a3,s1
    80003c84:	fc040613          	addi	a2,s0,-64
    80003c88:	4581                	li	a1,0
    80003c8a:	854a                	mv	a0,s2
    80003c8c:	d89ff0ef          	jal	80003a14 <readi>
    80003c90:	47c1                	li	a5,16
    80003c92:	fcf51ce3          	bne	a0,a5,80003c6a <dirlookup+0x36>
    if(de.inum == 0)
    80003c96:	fc045783          	lhu	a5,-64(s0)
    80003c9a:	dff1                	beqz	a5,80003c76 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003c9c:	fc240593          	addi	a1,s0,-62
    80003ca0:	854e                	mv	a0,s3
    80003ca2:	f7dff0ef          	jal	80003c1e <namecmp>
    80003ca6:	f961                	bnez	a0,80003c76 <dirlookup+0x42>
      if(poff)
    80003ca8:	000a0463          	beqz	s4,80003cb0 <dirlookup+0x7c>
        *poff = off;
    80003cac:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cb0:	fc045583          	lhu	a1,-64(s0)
    80003cb4:	00092503          	lw	a0,0(s2)
    80003cb8:	829ff0ef          	jal	800034e0 <iget>
    80003cbc:	a011                	j	80003cc0 <dirlookup+0x8c>
  return 0;
    80003cbe:	4501                	li	a0,0
}
    80003cc0:	70e2                	ld	ra,56(sp)
    80003cc2:	7442                	ld	s0,48(sp)
    80003cc4:	74a2                	ld	s1,40(sp)
    80003cc6:	7902                	ld	s2,32(sp)
    80003cc8:	69e2                	ld	s3,24(sp)
    80003cca:	6a42                	ld	s4,16(sp)
    80003ccc:	6121                	addi	sp,sp,64
    80003cce:	8082                	ret

0000000080003cd0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cd0:	711d                	addi	sp,sp,-96
    80003cd2:	ec86                	sd	ra,88(sp)
    80003cd4:	e8a2                	sd	s0,80(sp)
    80003cd6:	e4a6                	sd	s1,72(sp)
    80003cd8:	e0ca                	sd	s2,64(sp)
    80003cda:	fc4e                	sd	s3,56(sp)
    80003cdc:	f852                	sd	s4,48(sp)
    80003cde:	f456                	sd	s5,40(sp)
    80003ce0:	f05a                	sd	s6,32(sp)
    80003ce2:	ec5e                	sd	s7,24(sp)
    80003ce4:	e862                	sd	s8,16(sp)
    80003ce6:	e466                	sd	s9,8(sp)
    80003ce8:	1080                	addi	s0,sp,96
    80003cea:	84aa                	mv	s1,a0
    80003cec:	8b2e                	mv	s6,a1
    80003cee:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cf0:	00054703          	lbu	a4,0(a0)
    80003cf4:	02f00793          	li	a5,47
    80003cf8:	00f70e63          	beq	a4,a5,80003d14 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cfc:	d13fd0ef          	jal	80001a0e <myproc>
    80003d00:	15853503          	ld	a0,344(a0)
    80003d04:	a87ff0ef          	jal	8000378a <idup>
    80003d08:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d0a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d0e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d10:	4b85                	li	s7,1
    80003d12:	a871                	j	80003dae <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003d14:	4585                	li	a1,1
    80003d16:	4505                	li	a0,1
    80003d18:	fc8ff0ef          	jal	800034e0 <iget>
    80003d1c:	8a2a                	mv	s4,a0
    80003d1e:	b7f5                	j	80003d0a <namex+0x3a>
      iunlockput(ip);
    80003d20:	8552                	mv	a0,s4
    80003d22:	ca9ff0ef          	jal	800039ca <iunlockput>
      return 0;
    80003d26:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d28:	8552                	mv	a0,s4
    80003d2a:	60e6                	ld	ra,88(sp)
    80003d2c:	6446                	ld	s0,80(sp)
    80003d2e:	64a6                	ld	s1,72(sp)
    80003d30:	6906                	ld	s2,64(sp)
    80003d32:	79e2                	ld	s3,56(sp)
    80003d34:	7a42                	ld	s4,48(sp)
    80003d36:	7aa2                	ld	s5,40(sp)
    80003d38:	7b02                	ld	s6,32(sp)
    80003d3a:	6be2                	ld	s7,24(sp)
    80003d3c:	6c42                	ld	s8,16(sp)
    80003d3e:	6ca2                	ld	s9,8(sp)
    80003d40:	6125                	addi	sp,sp,96
    80003d42:	8082                	ret
      iunlock(ip);
    80003d44:	8552                	mv	a0,s4
    80003d46:	b29ff0ef          	jal	8000386e <iunlock>
      return ip;
    80003d4a:	bff9                	j	80003d28 <namex+0x58>
      iunlockput(ip);
    80003d4c:	8552                	mv	a0,s4
    80003d4e:	c7dff0ef          	jal	800039ca <iunlockput>
      return 0;
    80003d52:	8a4e                	mv	s4,s3
    80003d54:	bfd1                	j	80003d28 <namex+0x58>
  len = path - s;
    80003d56:	40998633          	sub	a2,s3,s1
    80003d5a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d5e:	099c5063          	bge	s8,s9,80003dde <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003d62:	4639                	li	a2,14
    80003d64:	85a6                	mv	a1,s1
    80003d66:	8556                	mv	a0,s5
    80003d68:	fbdfc0ef          	jal	80000d24 <memmove>
    80003d6c:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d6e:	0004c783          	lbu	a5,0(s1)
    80003d72:	01279763          	bne	a5,s2,80003d80 <namex+0xb0>
    path++;
    80003d76:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d78:	0004c783          	lbu	a5,0(s1)
    80003d7c:	ff278de3          	beq	a5,s2,80003d76 <namex+0xa6>
    ilock(ip);
    80003d80:	8552                	mv	a0,s4
    80003d82:	a3fff0ef          	jal	800037c0 <ilock>
    if(ip->type != T_DIR){
    80003d86:	044a1783          	lh	a5,68(s4)
    80003d8a:	f9779be3          	bne	a5,s7,80003d20 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003d8e:	000b0563          	beqz	s6,80003d98 <namex+0xc8>
    80003d92:	0004c783          	lbu	a5,0(s1)
    80003d96:	d7dd                	beqz	a5,80003d44 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d98:	4601                	li	a2,0
    80003d9a:	85d6                	mv	a1,s5
    80003d9c:	8552                	mv	a0,s4
    80003d9e:	e97ff0ef          	jal	80003c34 <dirlookup>
    80003da2:	89aa                	mv	s3,a0
    80003da4:	d545                	beqz	a0,80003d4c <namex+0x7c>
    iunlockput(ip);
    80003da6:	8552                	mv	a0,s4
    80003da8:	c23ff0ef          	jal	800039ca <iunlockput>
    ip = next;
    80003dac:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003dae:	0004c783          	lbu	a5,0(s1)
    80003db2:	01279763          	bne	a5,s2,80003dc0 <namex+0xf0>
    path++;
    80003db6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003db8:	0004c783          	lbu	a5,0(s1)
    80003dbc:	ff278de3          	beq	a5,s2,80003db6 <namex+0xe6>
  if(*path == 0)
    80003dc0:	cb8d                	beqz	a5,80003df2 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003dc2:	0004c783          	lbu	a5,0(s1)
    80003dc6:	89a6                	mv	s3,s1
  len = path - s;
    80003dc8:	4c81                	li	s9,0
    80003dca:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003dcc:	01278963          	beq	a5,s2,80003dde <namex+0x10e>
    80003dd0:	d3d9                	beqz	a5,80003d56 <namex+0x86>
    path++;
    80003dd2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003dd4:	0009c783          	lbu	a5,0(s3)
    80003dd8:	ff279ce3          	bne	a5,s2,80003dd0 <namex+0x100>
    80003ddc:	bfad                	j	80003d56 <namex+0x86>
    memmove(name, s, len);
    80003dde:	2601                	sext.w	a2,a2
    80003de0:	85a6                	mv	a1,s1
    80003de2:	8556                	mv	a0,s5
    80003de4:	f41fc0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003de8:	9cd6                	add	s9,s9,s5
    80003dea:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dee:	84ce                	mv	s1,s3
    80003df0:	bfbd                	j	80003d6e <namex+0x9e>
  if(nameiparent){
    80003df2:	f20b0be3          	beqz	s6,80003d28 <namex+0x58>
    iput(ip);
    80003df6:	8552                	mv	a0,s4
    80003df8:	b4bff0ef          	jal	80003942 <iput>
    return 0;
    80003dfc:	4a01                	li	s4,0
    80003dfe:	b72d                	j	80003d28 <namex+0x58>

0000000080003e00 <dirlink>:
{
    80003e00:	7139                	addi	sp,sp,-64
    80003e02:	fc06                	sd	ra,56(sp)
    80003e04:	f822                	sd	s0,48(sp)
    80003e06:	f04a                	sd	s2,32(sp)
    80003e08:	ec4e                	sd	s3,24(sp)
    80003e0a:	e852                	sd	s4,16(sp)
    80003e0c:	0080                	addi	s0,sp,64
    80003e0e:	892a                	mv	s2,a0
    80003e10:	8a2e                	mv	s4,a1
    80003e12:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e14:	4601                	li	a2,0
    80003e16:	e1fff0ef          	jal	80003c34 <dirlookup>
    80003e1a:	e535                	bnez	a0,80003e86 <dirlink+0x86>
    80003e1c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e1e:	04c92483          	lw	s1,76(s2)
    80003e22:	c48d                	beqz	s1,80003e4c <dirlink+0x4c>
    80003e24:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e26:	4741                	li	a4,16
    80003e28:	86a6                	mv	a3,s1
    80003e2a:	fc040613          	addi	a2,s0,-64
    80003e2e:	4581                	li	a1,0
    80003e30:	854a                	mv	a0,s2
    80003e32:	be3ff0ef          	jal	80003a14 <readi>
    80003e36:	47c1                	li	a5,16
    80003e38:	04f51b63          	bne	a0,a5,80003e8e <dirlink+0x8e>
    if(de.inum == 0)
    80003e3c:	fc045783          	lhu	a5,-64(s0)
    80003e40:	c791                	beqz	a5,80003e4c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e42:	24c1                	addiw	s1,s1,16
    80003e44:	04c92783          	lw	a5,76(s2)
    80003e48:	fcf4efe3          	bltu	s1,a5,80003e26 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003e4c:	4639                	li	a2,14
    80003e4e:	85d2                	mv	a1,s4
    80003e50:	fc240513          	addi	a0,s0,-62
    80003e54:	f77fc0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003e58:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5c:	4741                	li	a4,16
    80003e5e:	86a6                	mv	a3,s1
    80003e60:	fc040613          	addi	a2,s0,-64
    80003e64:	4581                	li	a1,0
    80003e66:	854a                	mv	a0,s2
    80003e68:	ca9ff0ef          	jal	80003b10 <writei>
    80003e6c:	1541                	addi	a0,a0,-16
    80003e6e:	00a03533          	snez	a0,a0
    80003e72:	40a00533          	neg	a0,a0
    80003e76:	74a2                	ld	s1,40(sp)
}
    80003e78:	70e2                	ld	ra,56(sp)
    80003e7a:	7442                	ld	s0,48(sp)
    80003e7c:	7902                	ld	s2,32(sp)
    80003e7e:	69e2                	ld	s3,24(sp)
    80003e80:	6a42                	ld	s4,16(sp)
    80003e82:	6121                	addi	sp,sp,64
    80003e84:	8082                	ret
    iput(ip);
    80003e86:	abdff0ef          	jal	80003942 <iput>
    return -1;
    80003e8a:	557d                	li	a0,-1
    80003e8c:	b7f5                	j	80003e78 <dirlink+0x78>
      panic("dirlink read");
    80003e8e:	00003517          	auipc	a0,0x3
    80003e92:	6fa50513          	addi	a0,a0,1786 # 80007588 <etext+0x588>
    80003e96:	8fffc0ef          	jal	80000794 <panic>

0000000080003e9a <namei>:

struct inode*
namei(char *path)
{
    80003e9a:	1101                	addi	sp,sp,-32
    80003e9c:	ec06                	sd	ra,24(sp)
    80003e9e:	e822                	sd	s0,16(sp)
    80003ea0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ea2:	fe040613          	addi	a2,s0,-32
    80003ea6:	4581                	li	a1,0
    80003ea8:	e29ff0ef          	jal	80003cd0 <namex>
}
    80003eac:	60e2                	ld	ra,24(sp)
    80003eae:	6442                	ld	s0,16(sp)
    80003eb0:	6105                	addi	sp,sp,32
    80003eb2:	8082                	ret

0000000080003eb4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eb4:	1141                	addi	sp,sp,-16
    80003eb6:	e406                	sd	ra,8(sp)
    80003eb8:	e022                	sd	s0,0(sp)
    80003eba:	0800                	addi	s0,sp,16
    80003ebc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ebe:	4585                	li	a1,1
    80003ec0:	e11ff0ef          	jal	80003cd0 <namex>
}
    80003ec4:	60a2                	ld	ra,8(sp)
    80003ec6:	6402                	ld	s0,0(sp)
    80003ec8:	0141                	addi	sp,sp,16
    80003eca:	8082                	ret

0000000080003ecc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ecc:	1101                	addi	sp,sp,-32
    80003ece:	ec06                	sd	ra,24(sp)
    80003ed0:	e822                	sd	s0,16(sp)
    80003ed2:	e426                	sd	s1,8(sp)
    80003ed4:	e04a                	sd	s2,0(sp)
    80003ed6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ed8:	0001c917          	auipc	s2,0x1c
    80003edc:	57890913          	addi	s2,s2,1400 # 80020450 <log>
    80003ee0:	01892583          	lw	a1,24(s2)
    80003ee4:	02892503          	lw	a0,40(s2)
    80003ee8:	9a0ff0ef          	jal	80003088 <bread>
    80003eec:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003eee:	02c92603          	lw	a2,44(s2)
    80003ef2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ef4:	00c05f63          	blez	a2,80003f12 <write_head+0x46>
    80003ef8:	0001c717          	auipc	a4,0x1c
    80003efc:	58870713          	addi	a4,a4,1416 # 80020480 <log+0x30>
    80003f00:	87aa                	mv	a5,a0
    80003f02:	060a                	slli	a2,a2,0x2
    80003f04:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f06:	4314                	lw	a3,0(a4)
    80003f08:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f0a:	0711                	addi	a4,a4,4
    80003f0c:	0791                	addi	a5,a5,4
    80003f0e:	fec79ce3          	bne	a5,a2,80003f06 <write_head+0x3a>
  }
  bwrite(buf);
    80003f12:	8526                	mv	a0,s1
    80003f14:	a4aff0ef          	jal	8000315e <bwrite>
  brelse(buf);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	a76ff0ef          	jal	80003190 <brelse>
}
    80003f1e:	60e2                	ld	ra,24(sp)
    80003f20:	6442                	ld	s0,16(sp)
    80003f22:	64a2                	ld	s1,8(sp)
    80003f24:	6902                	ld	s2,0(sp)
    80003f26:	6105                	addi	sp,sp,32
    80003f28:	8082                	ret

0000000080003f2a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f2a:	0001c797          	auipc	a5,0x1c
    80003f2e:	5527a783          	lw	a5,1362(a5) # 8002047c <log+0x2c>
    80003f32:	08f05f63          	blez	a5,80003fd0 <install_trans+0xa6>
{
    80003f36:	7139                	addi	sp,sp,-64
    80003f38:	fc06                	sd	ra,56(sp)
    80003f3a:	f822                	sd	s0,48(sp)
    80003f3c:	f426                	sd	s1,40(sp)
    80003f3e:	f04a                	sd	s2,32(sp)
    80003f40:	ec4e                	sd	s3,24(sp)
    80003f42:	e852                	sd	s4,16(sp)
    80003f44:	e456                	sd	s5,8(sp)
    80003f46:	e05a                	sd	s6,0(sp)
    80003f48:	0080                	addi	s0,sp,64
    80003f4a:	8b2a                	mv	s6,a0
    80003f4c:	0001ca97          	auipc	s5,0x1c
    80003f50:	534a8a93          	addi	s5,s5,1332 # 80020480 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f54:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f56:	0001c997          	auipc	s3,0x1c
    80003f5a:	4fa98993          	addi	s3,s3,1274 # 80020450 <log>
    80003f5e:	a829                	j	80003f78 <install_trans+0x4e>
    brelse(lbuf);
    80003f60:	854a                	mv	a0,s2
    80003f62:	a2eff0ef          	jal	80003190 <brelse>
    brelse(dbuf);
    80003f66:	8526                	mv	a0,s1
    80003f68:	a28ff0ef          	jal	80003190 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f6c:	2a05                	addiw	s4,s4,1
    80003f6e:	0a91                	addi	s5,s5,4
    80003f70:	02c9a783          	lw	a5,44(s3)
    80003f74:	04fa5463          	bge	s4,a5,80003fbc <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f78:	0189a583          	lw	a1,24(s3)
    80003f7c:	014585bb          	addw	a1,a1,s4
    80003f80:	2585                	addiw	a1,a1,1
    80003f82:	0289a503          	lw	a0,40(s3)
    80003f86:	902ff0ef          	jal	80003088 <bread>
    80003f8a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f8c:	000aa583          	lw	a1,0(s5)
    80003f90:	0289a503          	lw	a0,40(s3)
    80003f94:	8f4ff0ef          	jal	80003088 <bread>
    80003f98:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f9a:	40000613          	li	a2,1024
    80003f9e:	05890593          	addi	a1,s2,88
    80003fa2:	05850513          	addi	a0,a0,88
    80003fa6:	d7ffc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003faa:	8526                	mv	a0,s1
    80003fac:	9b2ff0ef          	jal	8000315e <bwrite>
    if(recovering == 0)
    80003fb0:	fa0b18e3          	bnez	s6,80003f60 <install_trans+0x36>
      bunpin(dbuf);
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	a96ff0ef          	jal	8000324c <bunpin>
    80003fba:	b75d                	j	80003f60 <install_trans+0x36>
}
    80003fbc:	70e2                	ld	ra,56(sp)
    80003fbe:	7442                	ld	s0,48(sp)
    80003fc0:	74a2                	ld	s1,40(sp)
    80003fc2:	7902                	ld	s2,32(sp)
    80003fc4:	69e2                	ld	s3,24(sp)
    80003fc6:	6a42                	ld	s4,16(sp)
    80003fc8:	6aa2                	ld	s5,8(sp)
    80003fca:	6b02                	ld	s6,0(sp)
    80003fcc:	6121                	addi	sp,sp,64
    80003fce:	8082                	ret
    80003fd0:	8082                	ret

0000000080003fd2 <initlog>:
{
    80003fd2:	7179                	addi	sp,sp,-48
    80003fd4:	f406                	sd	ra,40(sp)
    80003fd6:	f022                	sd	s0,32(sp)
    80003fd8:	ec26                	sd	s1,24(sp)
    80003fda:	e84a                	sd	s2,16(sp)
    80003fdc:	e44e                	sd	s3,8(sp)
    80003fde:	1800                	addi	s0,sp,48
    80003fe0:	892a                	mv	s2,a0
    80003fe2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fe4:	0001c497          	auipc	s1,0x1c
    80003fe8:	46c48493          	addi	s1,s1,1132 # 80020450 <log>
    80003fec:	00003597          	auipc	a1,0x3
    80003ff0:	5ac58593          	addi	a1,a1,1452 # 80007598 <etext+0x598>
    80003ff4:	8526                	mv	a0,s1
    80003ff6:	b7ffc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003ffa:	0149a583          	lw	a1,20(s3)
    80003ffe:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004000:	0109a783          	lw	a5,16(s3)
    80004004:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004006:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000400a:	854a                	mv	a0,s2
    8000400c:	87cff0ef          	jal	80003088 <bread>
  log.lh.n = lh->n;
    80004010:	4d30                	lw	a2,88(a0)
    80004012:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004014:	00c05f63          	blez	a2,80004032 <initlog+0x60>
    80004018:	87aa                	mv	a5,a0
    8000401a:	0001c717          	auipc	a4,0x1c
    8000401e:	46670713          	addi	a4,a4,1126 # 80020480 <log+0x30>
    80004022:	060a                	slli	a2,a2,0x2
    80004024:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004026:	4ff4                	lw	a3,92(a5)
    80004028:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000402a:	0791                	addi	a5,a5,4
    8000402c:	0711                	addi	a4,a4,4
    8000402e:	fec79ce3          	bne	a5,a2,80004026 <initlog+0x54>
  brelse(buf);
    80004032:	95eff0ef          	jal	80003190 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004036:	4505                	li	a0,1
    80004038:	ef3ff0ef          	jal	80003f2a <install_trans>
  log.lh.n = 0;
    8000403c:	0001c797          	auipc	a5,0x1c
    80004040:	4407a023          	sw	zero,1088(a5) # 8002047c <log+0x2c>
  write_head(); // clear the log
    80004044:	e89ff0ef          	jal	80003ecc <write_head>
}
    80004048:	70a2                	ld	ra,40(sp)
    8000404a:	7402                	ld	s0,32(sp)
    8000404c:	64e2                	ld	s1,24(sp)
    8000404e:	6942                	ld	s2,16(sp)
    80004050:	69a2                	ld	s3,8(sp)
    80004052:	6145                	addi	sp,sp,48
    80004054:	8082                	ret

0000000080004056 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004056:	1101                	addi	sp,sp,-32
    80004058:	ec06                	sd	ra,24(sp)
    8000405a:	e822                	sd	s0,16(sp)
    8000405c:	e426                	sd	s1,8(sp)
    8000405e:	e04a                	sd	s2,0(sp)
    80004060:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004062:	0001c517          	auipc	a0,0x1c
    80004066:	3ee50513          	addi	a0,a0,1006 # 80020450 <log>
    8000406a:	b8bfc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    8000406e:	0001c497          	auipc	s1,0x1c
    80004072:	3e248493          	addi	s1,s1,994 # 80020450 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004076:	4979                	li	s2,30
    80004078:	a029                	j	80004082 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000407a:	85a6                	mv	a1,s1
    8000407c:	8526                	mv	a0,s1
    8000407e:	fa7fd0ef          	jal	80002024 <sleep>
    if(log.committing){
    80004082:	50dc                	lw	a5,36(s1)
    80004084:	fbfd                	bnez	a5,8000407a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004086:	5098                	lw	a4,32(s1)
    80004088:	2705                	addiw	a4,a4,1
    8000408a:	0027179b          	slliw	a5,a4,0x2
    8000408e:	9fb9                	addw	a5,a5,a4
    80004090:	0017979b          	slliw	a5,a5,0x1
    80004094:	54d4                	lw	a3,44(s1)
    80004096:	9fb5                	addw	a5,a5,a3
    80004098:	00f95763          	bge	s2,a5,800040a6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000409c:	85a6                	mv	a1,s1
    8000409e:	8526                	mv	a0,s1
    800040a0:	f85fd0ef          	jal	80002024 <sleep>
    800040a4:	bff9                	j	80004082 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800040a6:	0001c517          	auipc	a0,0x1c
    800040aa:	3aa50513          	addi	a0,a0,938 # 80020450 <log>
    800040ae:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800040b0:	bddfc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    800040b4:	60e2                	ld	ra,24(sp)
    800040b6:	6442                	ld	s0,16(sp)
    800040b8:	64a2                	ld	s1,8(sp)
    800040ba:	6902                	ld	s2,0(sp)
    800040bc:	6105                	addi	sp,sp,32
    800040be:	8082                	ret

00000000800040c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040c0:	7139                	addi	sp,sp,-64
    800040c2:	fc06                	sd	ra,56(sp)
    800040c4:	f822                	sd	s0,48(sp)
    800040c6:	f426                	sd	s1,40(sp)
    800040c8:	f04a                	sd	s2,32(sp)
    800040ca:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040cc:	0001c497          	auipc	s1,0x1c
    800040d0:	38448493          	addi	s1,s1,900 # 80020450 <log>
    800040d4:	8526                	mv	a0,s1
    800040d6:	b1ffc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    800040da:	509c                	lw	a5,32(s1)
    800040dc:	37fd                	addiw	a5,a5,-1
    800040de:	0007891b          	sext.w	s2,a5
    800040e2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040e4:	50dc                	lw	a5,36(s1)
    800040e6:	ef9d                	bnez	a5,80004124 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800040e8:	04091763          	bnez	s2,80004136 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800040ec:	0001c497          	auipc	s1,0x1c
    800040f0:	36448493          	addi	s1,s1,868 # 80020450 <log>
    800040f4:	4785                	li	a5,1
    800040f6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040f8:	8526                	mv	a0,s1
    800040fa:	b93fc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040fe:	54dc                	lw	a5,44(s1)
    80004100:	04f04b63          	bgtz	a5,80004156 <end_op+0x96>
    acquire(&log.lock);
    80004104:	0001c497          	auipc	s1,0x1c
    80004108:	34c48493          	addi	s1,s1,844 # 80020450 <log>
    8000410c:	8526                	mv	a0,s1
    8000410e:	ae7fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80004112:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004116:	8526                	mv	a0,s1
    80004118:	f59fd0ef          	jal	80002070 <wakeup>
    release(&log.lock);
    8000411c:	8526                	mv	a0,s1
    8000411e:	b6ffc0ef          	jal	80000c8c <release>
}
    80004122:	a025                	j	8000414a <end_op+0x8a>
    80004124:	ec4e                	sd	s3,24(sp)
    80004126:	e852                	sd	s4,16(sp)
    80004128:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000412a:	00003517          	auipc	a0,0x3
    8000412e:	47650513          	addi	a0,a0,1142 # 800075a0 <etext+0x5a0>
    80004132:	e62fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80004136:	0001c497          	auipc	s1,0x1c
    8000413a:	31a48493          	addi	s1,s1,794 # 80020450 <log>
    8000413e:	8526                	mv	a0,s1
    80004140:	f31fd0ef          	jal	80002070 <wakeup>
  release(&log.lock);
    80004144:	8526                	mv	a0,s1
    80004146:	b47fc0ef          	jal	80000c8c <release>
}
    8000414a:	70e2                	ld	ra,56(sp)
    8000414c:	7442                	ld	s0,48(sp)
    8000414e:	74a2                	ld	s1,40(sp)
    80004150:	7902                	ld	s2,32(sp)
    80004152:	6121                	addi	sp,sp,64
    80004154:	8082                	ret
    80004156:	ec4e                	sd	s3,24(sp)
    80004158:	e852                	sd	s4,16(sp)
    8000415a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000415c:	0001ca97          	auipc	s5,0x1c
    80004160:	324a8a93          	addi	s5,s5,804 # 80020480 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004164:	0001ca17          	auipc	s4,0x1c
    80004168:	2eca0a13          	addi	s4,s4,748 # 80020450 <log>
    8000416c:	018a2583          	lw	a1,24(s4)
    80004170:	012585bb          	addw	a1,a1,s2
    80004174:	2585                	addiw	a1,a1,1
    80004176:	028a2503          	lw	a0,40(s4)
    8000417a:	f0ffe0ef          	jal	80003088 <bread>
    8000417e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004180:	000aa583          	lw	a1,0(s5)
    80004184:	028a2503          	lw	a0,40(s4)
    80004188:	f01fe0ef          	jal	80003088 <bread>
    8000418c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000418e:	40000613          	li	a2,1024
    80004192:	05850593          	addi	a1,a0,88
    80004196:	05848513          	addi	a0,s1,88
    8000419a:	b8bfc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    8000419e:	8526                	mv	a0,s1
    800041a0:	fbffe0ef          	jal	8000315e <bwrite>
    brelse(from);
    800041a4:	854e                	mv	a0,s3
    800041a6:	febfe0ef          	jal	80003190 <brelse>
    brelse(to);
    800041aa:	8526                	mv	a0,s1
    800041ac:	fe5fe0ef          	jal	80003190 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b0:	2905                	addiw	s2,s2,1
    800041b2:	0a91                	addi	s5,s5,4
    800041b4:	02ca2783          	lw	a5,44(s4)
    800041b8:	faf94ae3          	blt	s2,a5,8000416c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041bc:	d11ff0ef          	jal	80003ecc <write_head>
    install_trans(0); // Now install writes to home locations
    800041c0:	4501                	li	a0,0
    800041c2:	d69ff0ef          	jal	80003f2a <install_trans>
    log.lh.n = 0;
    800041c6:	0001c797          	auipc	a5,0x1c
    800041ca:	2a07ab23          	sw	zero,694(a5) # 8002047c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041ce:	cffff0ef          	jal	80003ecc <write_head>
    800041d2:	69e2                	ld	s3,24(sp)
    800041d4:	6a42                	ld	s4,16(sp)
    800041d6:	6aa2                	ld	s5,8(sp)
    800041d8:	b735                	j	80004104 <end_op+0x44>

00000000800041da <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041da:	1101                	addi	sp,sp,-32
    800041dc:	ec06                	sd	ra,24(sp)
    800041de:	e822                	sd	s0,16(sp)
    800041e0:	e426                	sd	s1,8(sp)
    800041e2:	e04a                	sd	s2,0(sp)
    800041e4:	1000                	addi	s0,sp,32
    800041e6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041e8:	0001c917          	auipc	s2,0x1c
    800041ec:	26890913          	addi	s2,s2,616 # 80020450 <log>
    800041f0:	854a                	mv	a0,s2
    800041f2:	a03fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800041f6:	02c92603          	lw	a2,44(s2)
    800041fa:	47f5                	li	a5,29
    800041fc:	06c7c363          	blt	a5,a2,80004262 <log_write+0x88>
    80004200:	0001c797          	auipc	a5,0x1c
    80004204:	26c7a783          	lw	a5,620(a5) # 8002046c <log+0x1c>
    80004208:	37fd                	addiw	a5,a5,-1
    8000420a:	04f65c63          	bge	a2,a5,80004262 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000420e:	0001c797          	auipc	a5,0x1c
    80004212:	2627a783          	lw	a5,610(a5) # 80020470 <log+0x20>
    80004216:	04f05c63          	blez	a5,8000426e <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000421a:	4781                	li	a5,0
    8000421c:	04c05f63          	blez	a2,8000427a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004220:	44cc                	lw	a1,12(s1)
    80004222:	0001c717          	auipc	a4,0x1c
    80004226:	25e70713          	addi	a4,a4,606 # 80020480 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000422a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000422c:	4314                	lw	a3,0(a4)
    8000422e:	04b68663          	beq	a3,a1,8000427a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80004232:	2785                	addiw	a5,a5,1
    80004234:	0711                	addi	a4,a4,4
    80004236:	fef61be3          	bne	a2,a5,8000422c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000423a:	0621                	addi	a2,a2,8
    8000423c:	060a                	slli	a2,a2,0x2
    8000423e:	0001c797          	auipc	a5,0x1c
    80004242:	21278793          	addi	a5,a5,530 # 80020450 <log>
    80004246:	97b2                	add	a5,a5,a2
    80004248:	44d8                	lw	a4,12(s1)
    8000424a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000424c:	8526                	mv	a0,s1
    8000424e:	fcbfe0ef          	jal	80003218 <bpin>
    log.lh.n++;
    80004252:	0001c717          	auipc	a4,0x1c
    80004256:	1fe70713          	addi	a4,a4,510 # 80020450 <log>
    8000425a:	575c                	lw	a5,44(a4)
    8000425c:	2785                	addiw	a5,a5,1
    8000425e:	d75c                	sw	a5,44(a4)
    80004260:	a80d                	j	80004292 <log_write+0xb8>
    panic("too big a transaction");
    80004262:	00003517          	auipc	a0,0x3
    80004266:	34e50513          	addi	a0,a0,846 # 800075b0 <etext+0x5b0>
    8000426a:	d2afc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    8000426e:	00003517          	auipc	a0,0x3
    80004272:	35a50513          	addi	a0,a0,858 # 800075c8 <etext+0x5c8>
    80004276:	d1efc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    8000427a:	00878693          	addi	a3,a5,8
    8000427e:	068a                	slli	a3,a3,0x2
    80004280:	0001c717          	auipc	a4,0x1c
    80004284:	1d070713          	addi	a4,a4,464 # 80020450 <log>
    80004288:	9736                	add	a4,a4,a3
    8000428a:	44d4                	lw	a3,12(s1)
    8000428c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000428e:	faf60fe3          	beq	a2,a5,8000424c <log_write+0x72>
  }
  release(&log.lock);
    80004292:	0001c517          	auipc	a0,0x1c
    80004296:	1be50513          	addi	a0,a0,446 # 80020450 <log>
    8000429a:	9f3fc0ef          	jal	80000c8c <release>
}
    8000429e:	60e2                	ld	ra,24(sp)
    800042a0:	6442                	ld	s0,16(sp)
    800042a2:	64a2                	ld	s1,8(sp)
    800042a4:	6902                	ld	s2,0(sp)
    800042a6:	6105                	addi	sp,sp,32
    800042a8:	8082                	ret

00000000800042aa <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042aa:	1101                	addi	sp,sp,-32
    800042ac:	ec06                	sd	ra,24(sp)
    800042ae:	e822                	sd	s0,16(sp)
    800042b0:	e426                	sd	s1,8(sp)
    800042b2:	e04a                	sd	s2,0(sp)
    800042b4:	1000                	addi	s0,sp,32
    800042b6:	84aa                	mv	s1,a0
    800042b8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042ba:	00003597          	auipc	a1,0x3
    800042be:	32e58593          	addi	a1,a1,814 # 800075e8 <etext+0x5e8>
    800042c2:	0521                	addi	a0,a0,8
    800042c4:	8b1fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    800042c8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042cc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042d0:	0204a423          	sw	zero,40(s1)
}
    800042d4:	60e2                	ld	ra,24(sp)
    800042d6:	6442                	ld	s0,16(sp)
    800042d8:	64a2                	ld	s1,8(sp)
    800042da:	6902                	ld	s2,0(sp)
    800042dc:	6105                	addi	sp,sp,32
    800042de:	8082                	ret

00000000800042e0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042e0:	1101                	addi	sp,sp,-32
    800042e2:	ec06                	sd	ra,24(sp)
    800042e4:	e822                	sd	s0,16(sp)
    800042e6:	e426                	sd	s1,8(sp)
    800042e8:	e04a                	sd	s2,0(sp)
    800042ea:	1000                	addi	s0,sp,32
    800042ec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042ee:	00850913          	addi	s2,a0,8
    800042f2:	854a                	mv	a0,s2
    800042f4:	901fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    800042f8:	409c                	lw	a5,0(s1)
    800042fa:	c799                	beqz	a5,80004308 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800042fc:	85ca                	mv	a1,s2
    800042fe:	8526                	mv	a0,s1
    80004300:	d25fd0ef          	jal	80002024 <sleep>
  while (lk->locked) {
    80004304:	409c                	lw	a5,0(s1)
    80004306:	fbfd                	bnez	a5,800042fc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004308:	4785                	li	a5,1
    8000430a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000430c:	f02fd0ef          	jal	80001a0e <myproc>
    80004310:	591c                	lw	a5,48(a0)
    80004312:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004314:	854a                	mv	a0,s2
    80004316:	977fc0ef          	jal	80000c8c <release>
}
    8000431a:	60e2                	ld	ra,24(sp)
    8000431c:	6442                	ld	s0,16(sp)
    8000431e:	64a2                	ld	s1,8(sp)
    80004320:	6902                	ld	s2,0(sp)
    80004322:	6105                	addi	sp,sp,32
    80004324:	8082                	ret

0000000080004326 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004326:	1101                	addi	sp,sp,-32
    80004328:	ec06                	sd	ra,24(sp)
    8000432a:	e822                	sd	s0,16(sp)
    8000432c:	e426                	sd	s1,8(sp)
    8000432e:	e04a                	sd	s2,0(sp)
    80004330:	1000                	addi	s0,sp,32
    80004332:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004334:	00850913          	addi	s2,a0,8
    80004338:	854a                	mv	a0,s2
    8000433a:	8bbfc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    8000433e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004342:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004346:	8526                	mv	a0,s1
    80004348:	d29fd0ef          	jal	80002070 <wakeup>
  release(&lk->lk);
    8000434c:	854a                	mv	a0,s2
    8000434e:	93ffc0ef          	jal	80000c8c <release>
}
    80004352:	60e2                	ld	ra,24(sp)
    80004354:	6442                	ld	s0,16(sp)
    80004356:	64a2                	ld	s1,8(sp)
    80004358:	6902                	ld	s2,0(sp)
    8000435a:	6105                	addi	sp,sp,32
    8000435c:	8082                	ret

000000008000435e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000435e:	7179                	addi	sp,sp,-48
    80004360:	f406                	sd	ra,40(sp)
    80004362:	f022                	sd	s0,32(sp)
    80004364:	ec26                	sd	s1,24(sp)
    80004366:	e84a                	sd	s2,16(sp)
    80004368:	1800                	addi	s0,sp,48
    8000436a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000436c:	00850913          	addi	s2,a0,8
    80004370:	854a                	mv	a0,s2
    80004372:	883fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004376:	409c                	lw	a5,0(s1)
    80004378:	ef81                	bnez	a5,80004390 <holdingsleep+0x32>
    8000437a:	4481                	li	s1,0
  release(&lk->lk);
    8000437c:	854a                	mv	a0,s2
    8000437e:	90ffc0ef          	jal	80000c8c <release>
  return r;
}
    80004382:	8526                	mv	a0,s1
    80004384:	70a2                	ld	ra,40(sp)
    80004386:	7402                	ld	s0,32(sp)
    80004388:	64e2                	ld	s1,24(sp)
    8000438a:	6942                	ld	s2,16(sp)
    8000438c:	6145                	addi	sp,sp,48
    8000438e:	8082                	ret
    80004390:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004392:	0284a983          	lw	s3,40(s1)
    80004396:	e78fd0ef          	jal	80001a0e <myproc>
    8000439a:	5904                	lw	s1,48(a0)
    8000439c:	413484b3          	sub	s1,s1,s3
    800043a0:	0014b493          	seqz	s1,s1
    800043a4:	69a2                	ld	s3,8(sp)
    800043a6:	bfd9                	j	8000437c <holdingsleep+0x1e>

00000000800043a8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043a8:	1141                	addi	sp,sp,-16
    800043aa:	e406                	sd	ra,8(sp)
    800043ac:	e022                	sd	s0,0(sp)
    800043ae:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043b0:	00003597          	auipc	a1,0x3
    800043b4:	24858593          	addi	a1,a1,584 # 800075f8 <etext+0x5f8>
    800043b8:	0001c517          	auipc	a0,0x1c
    800043bc:	1e050513          	addi	a0,a0,480 # 80020598 <ftable>
    800043c0:	fb4fc0ef          	jal	80000b74 <initlock>
}
    800043c4:	60a2                	ld	ra,8(sp)
    800043c6:	6402                	ld	s0,0(sp)
    800043c8:	0141                	addi	sp,sp,16
    800043ca:	8082                	ret

00000000800043cc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043cc:	1101                	addi	sp,sp,-32
    800043ce:	ec06                	sd	ra,24(sp)
    800043d0:	e822                	sd	s0,16(sp)
    800043d2:	e426                	sd	s1,8(sp)
    800043d4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043d6:	0001c517          	auipc	a0,0x1c
    800043da:	1c250513          	addi	a0,a0,450 # 80020598 <ftable>
    800043de:	817fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043e2:	0001c497          	auipc	s1,0x1c
    800043e6:	1ce48493          	addi	s1,s1,462 # 800205b0 <ftable+0x18>
    800043ea:	0001d717          	auipc	a4,0x1d
    800043ee:	16670713          	addi	a4,a4,358 # 80021550 <disk>
    if(f->ref == 0){
    800043f2:	40dc                	lw	a5,4(s1)
    800043f4:	cf89                	beqz	a5,8000440e <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043f6:	02848493          	addi	s1,s1,40
    800043fa:	fee49ce3          	bne	s1,a4,800043f2 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800043fe:	0001c517          	auipc	a0,0x1c
    80004402:	19a50513          	addi	a0,a0,410 # 80020598 <ftable>
    80004406:	887fc0ef          	jal	80000c8c <release>
  return 0;
    8000440a:	4481                	li	s1,0
    8000440c:	a809                	j	8000441e <filealloc+0x52>
      f->ref = 1;
    8000440e:	4785                	li	a5,1
    80004410:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004412:	0001c517          	auipc	a0,0x1c
    80004416:	18650513          	addi	a0,a0,390 # 80020598 <ftable>
    8000441a:	873fc0ef          	jal	80000c8c <release>
}
    8000441e:	8526                	mv	a0,s1
    80004420:	60e2                	ld	ra,24(sp)
    80004422:	6442                	ld	s0,16(sp)
    80004424:	64a2                	ld	s1,8(sp)
    80004426:	6105                	addi	sp,sp,32
    80004428:	8082                	ret

000000008000442a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000442a:	1101                	addi	sp,sp,-32
    8000442c:	ec06                	sd	ra,24(sp)
    8000442e:	e822                	sd	s0,16(sp)
    80004430:	e426                	sd	s1,8(sp)
    80004432:	1000                	addi	s0,sp,32
    80004434:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004436:	0001c517          	auipc	a0,0x1c
    8000443a:	16250513          	addi	a0,a0,354 # 80020598 <ftable>
    8000443e:	fb6fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004442:	40dc                	lw	a5,4(s1)
    80004444:	02f05063          	blez	a5,80004464 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004448:	2785                	addiw	a5,a5,1
    8000444a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000444c:	0001c517          	auipc	a0,0x1c
    80004450:	14c50513          	addi	a0,a0,332 # 80020598 <ftable>
    80004454:	839fc0ef          	jal	80000c8c <release>
  return f;
}
    80004458:	8526                	mv	a0,s1
    8000445a:	60e2                	ld	ra,24(sp)
    8000445c:	6442                	ld	s0,16(sp)
    8000445e:	64a2                	ld	s1,8(sp)
    80004460:	6105                	addi	sp,sp,32
    80004462:	8082                	ret
    panic("filedup");
    80004464:	00003517          	auipc	a0,0x3
    80004468:	19c50513          	addi	a0,a0,412 # 80007600 <etext+0x600>
    8000446c:	b28fc0ef          	jal	80000794 <panic>

0000000080004470 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004470:	7139                	addi	sp,sp,-64
    80004472:	fc06                	sd	ra,56(sp)
    80004474:	f822                	sd	s0,48(sp)
    80004476:	f426                	sd	s1,40(sp)
    80004478:	0080                	addi	s0,sp,64
    8000447a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000447c:	0001c517          	auipc	a0,0x1c
    80004480:	11c50513          	addi	a0,a0,284 # 80020598 <ftable>
    80004484:	f70fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004488:	40dc                	lw	a5,4(s1)
    8000448a:	04f05a63          	blez	a5,800044de <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000448e:	37fd                	addiw	a5,a5,-1
    80004490:	0007871b          	sext.w	a4,a5
    80004494:	c0dc                	sw	a5,4(s1)
    80004496:	04e04e63          	bgtz	a4,800044f2 <fileclose+0x82>
    8000449a:	f04a                	sd	s2,32(sp)
    8000449c:	ec4e                	sd	s3,24(sp)
    8000449e:	e852                	sd	s4,16(sp)
    800044a0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044a2:	0004a903          	lw	s2,0(s1)
    800044a6:	0094ca83          	lbu	s5,9(s1)
    800044aa:	0104ba03          	ld	s4,16(s1)
    800044ae:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044b2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044b6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044ba:	0001c517          	auipc	a0,0x1c
    800044be:	0de50513          	addi	a0,a0,222 # 80020598 <ftable>
    800044c2:	fcafc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    800044c6:	4785                	li	a5,1
    800044c8:	04f90063          	beq	s2,a5,80004508 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044cc:	3979                	addiw	s2,s2,-2
    800044ce:	4785                	li	a5,1
    800044d0:	0527f563          	bgeu	a5,s2,8000451a <fileclose+0xaa>
    800044d4:	7902                	ld	s2,32(sp)
    800044d6:	69e2                	ld	s3,24(sp)
    800044d8:	6a42                	ld	s4,16(sp)
    800044da:	6aa2                	ld	s5,8(sp)
    800044dc:	a00d                	j	800044fe <fileclose+0x8e>
    800044de:	f04a                	sd	s2,32(sp)
    800044e0:	ec4e                	sd	s3,24(sp)
    800044e2:	e852                	sd	s4,16(sp)
    800044e4:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800044e6:	00003517          	auipc	a0,0x3
    800044ea:	12250513          	addi	a0,a0,290 # 80007608 <etext+0x608>
    800044ee:	aa6fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    800044f2:	0001c517          	auipc	a0,0x1c
    800044f6:	0a650513          	addi	a0,a0,166 # 80020598 <ftable>
    800044fa:	f92fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800044fe:	70e2                	ld	ra,56(sp)
    80004500:	7442                	ld	s0,48(sp)
    80004502:	74a2                	ld	s1,40(sp)
    80004504:	6121                	addi	sp,sp,64
    80004506:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004508:	85d6                	mv	a1,s5
    8000450a:	8552                	mv	a0,s4
    8000450c:	336000ef          	jal	80004842 <pipeclose>
    80004510:	7902                	ld	s2,32(sp)
    80004512:	69e2                	ld	s3,24(sp)
    80004514:	6a42                	ld	s4,16(sp)
    80004516:	6aa2                	ld	s5,8(sp)
    80004518:	b7dd                	j	800044fe <fileclose+0x8e>
    begin_op();
    8000451a:	b3dff0ef          	jal	80004056 <begin_op>
    iput(ff.ip);
    8000451e:	854e                	mv	a0,s3
    80004520:	c22ff0ef          	jal	80003942 <iput>
    end_op();
    80004524:	b9dff0ef          	jal	800040c0 <end_op>
    80004528:	7902                	ld	s2,32(sp)
    8000452a:	69e2                	ld	s3,24(sp)
    8000452c:	6a42                	ld	s4,16(sp)
    8000452e:	6aa2                	ld	s5,8(sp)
    80004530:	b7f9                	j	800044fe <fileclose+0x8e>

0000000080004532 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004532:	715d                	addi	sp,sp,-80
    80004534:	e486                	sd	ra,72(sp)
    80004536:	e0a2                	sd	s0,64(sp)
    80004538:	fc26                	sd	s1,56(sp)
    8000453a:	f44e                	sd	s3,40(sp)
    8000453c:	0880                	addi	s0,sp,80
    8000453e:	84aa                	mv	s1,a0
    80004540:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004542:	cccfd0ef          	jal	80001a0e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004546:	409c                	lw	a5,0(s1)
    80004548:	37f9                	addiw	a5,a5,-2
    8000454a:	4705                	li	a4,1
    8000454c:	04f76063          	bltu	a4,a5,8000458c <filestat+0x5a>
    80004550:	f84a                	sd	s2,48(sp)
    80004552:	892a                	mv	s2,a0
    ilock(f->ip);
    80004554:	6c88                	ld	a0,24(s1)
    80004556:	a6aff0ef          	jal	800037c0 <ilock>
    stati(f->ip, &st);
    8000455a:	fb840593          	addi	a1,s0,-72
    8000455e:	6c88                	ld	a0,24(s1)
    80004560:	c8aff0ef          	jal	800039ea <stati>
    iunlock(f->ip);
    80004564:	6c88                	ld	a0,24(s1)
    80004566:	b08ff0ef          	jal	8000386e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000456a:	46e1                	li	a3,24
    8000456c:	fb840613          	addi	a2,s0,-72
    80004570:	85ce                	mv	a1,s3
    80004572:	05093503          	ld	a0,80(s2)
    80004576:	90afd0ef          	jal	80001680 <copyout>
    8000457a:	41f5551b          	sraiw	a0,a0,0x1f
    8000457e:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004580:	60a6                	ld	ra,72(sp)
    80004582:	6406                	ld	s0,64(sp)
    80004584:	74e2                	ld	s1,56(sp)
    80004586:	79a2                	ld	s3,40(sp)
    80004588:	6161                	addi	sp,sp,80
    8000458a:	8082                	ret
  return -1;
    8000458c:	557d                	li	a0,-1
    8000458e:	bfcd                	j	80004580 <filestat+0x4e>

0000000080004590 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004590:	7179                	addi	sp,sp,-48
    80004592:	f406                	sd	ra,40(sp)
    80004594:	f022                	sd	s0,32(sp)
    80004596:	e84a                	sd	s2,16(sp)
    80004598:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000459a:	00854783          	lbu	a5,8(a0)
    8000459e:	cfd1                	beqz	a5,8000463a <fileread+0xaa>
    800045a0:	ec26                	sd	s1,24(sp)
    800045a2:	e44e                	sd	s3,8(sp)
    800045a4:	84aa                	mv	s1,a0
    800045a6:	89ae                	mv	s3,a1
    800045a8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045aa:	411c                	lw	a5,0(a0)
    800045ac:	4705                	li	a4,1
    800045ae:	04e78363          	beq	a5,a4,800045f4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045b2:	470d                	li	a4,3
    800045b4:	04e78763          	beq	a5,a4,80004602 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045b8:	4709                	li	a4,2
    800045ba:	06e79a63          	bne	a5,a4,8000462e <fileread+0x9e>
    ilock(f->ip);
    800045be:	6d08                	ld	a0,24(a0)
    800045c0:	a00ff0ef          	jal	800037c0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800045c4:	874a                	mv	a4,s2
    800045c6:	5094                	lw	a3,32(s1)
    800045c8:	864e                	mv	a2,s3
    800045ca:	4585                	li	a1,1
    800045cc:	6c88                	ld	a0,24(s1)
    800045ce:	c46ff0ef          	jal	80003a14 <readi>
    800045d2:	892a                	mv	s2,a0
    800045d4:	00a05563          	blez	a0,800045de <fileread+0x4e>
      f->off += r;
    800045d8:	509c                	lw	a5,32(s1)
    800045da:	9fa9                	addw	a5,a5,a0
    800045dc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800045de:	6c88                	ld	a0,24(s1)
    800045e0:	a8eff0ef          	jal	8000386e <iunlock>
    800045e4:	64e2                	ld	s1,24(sp)
    800045e6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800045e8:	854a                	mv	a0,s2
    800045ea:	70a2                	ld	ra,40(sp)
    800045ec:	7402                	ld	s0,32(sp)
    800045ee:	6942                	ld	s2,16(sp)
    800045f0:	6145                	addi	sp,sp,48
    800045f2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800045f4:	6908                	ld	a0,16(a0)
    800045f6:	388000ef          	jal	8000497e <piperead>
    800045fa:	892a                	mv	s2,a0
    800045fc:	64e2                	ld	s1,24(sp)
    800045fe:	69a2                	ld	s3,8(sp)
    80004600:	b7e5                	j	800045e8 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004602:	02451783          	lh	a5,36(a0)
    80004606:	03079693          	slli	a3,a5,0x30
    8000460a:	92c1                	srli	a3,a3,0x30
    8000460c:	4725                	li	a4,9
    8000460e:	02d76863          	bltu	a4,a3,8000463e <fileread+0xae>
    80004612:	0792                	slli	a5,a5,0x4
    80004614:	0001c717          	auipc	a4,0x1c
    80004618:	ee470713          	addi	a4,a4,-284 # 800204f8 <devsw>
    8000461c:	97ba                	add	a5,a5,a4
    8000461e:	639c                	ld	a5,0(a5)
    80004620:	c39d                	beqz	a5,80004646 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004622:	4505                	li	a0,1
    80004624:	9782                	jalr	a5
    80004626:	892a                	mv	s2,a0
    80004628:	64e2                	ld	s1,24(sp)
    8000462a:	69a2                	ld	s3,8(sp)
    8000462c:	bf75                	j	800045e8 <fileread+0x58>
    panic("fileread");
    8000462e:	00003517          	auipc	a0,0x3
    80004632:	fea50513          	addi	a0,a0,-22 # 80007618 <etext+0x618>
    80004636:	95efc0ef          	jal	80000794 <panic>
    return -1;
    8000463a:	597d                	li	s2,-1
    8000463c:	b775                	j	800045e8 <fileread+0x58>
      return -1;
    8000463e:	597d                	li	s2,-1
    80004640:	64e2                	ld	s1,24(sp)
    80004642:	69a2                	ld	s3,8(sp)
    80004644:	b755                	j	800045e8 <fileread+0x58>
    80004646:	597d                	li	s2,-1
    80004648:	64e2                	ld	s1,24(sp)
    8000464a:	69a2                	ld	s3,8(sp)
    8000464c:	bf71                	j	800045e8 <fileread+0x58>

000000008000464e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000464e:	00954783          	lbu	a5,9(a0)
    80004652:	10078b63          	beqz	a5,80004768 <filewrite+0x11a>
{
    80004656:	715d                	addi	sp,sp,-80
    80004658:	e486                	sd	ra,72(sp)
    8000465a:	e0a2                	sd	s0,64(sp)
    8000465c:	f84a                	sd	s2,48(sp)
    8000465e:	f052                	sd	s4,32(sp)
    80004660:	e85a                	sd	s6,16(sp)
    80004662:	0880                	addi	s0,sp,80
    80004664:	892a                	mv	s2,a0
    80004666:	8b2e                	mv	s6,a1
    80004668:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000466a:	411c                	lw	a5,0(a0)
    8000466c:	4705                	li	a4,1
    8000466e:	02e78763          	beq	a5,a4,8000469c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004672:	470d                	li	a4,3
    80004674:	02e78863          	beq	a5,a4,800046a4 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004678:	4709                	li	a4,2
    8000467a:	0ce79c63          	bne	a5,a4,80004752 <filewrite+0x104>
    8000467e:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004680:	0ac05863          	blez	a2,80004730 <filewrite+0xe2>
    80004684:	fc26                	sd	s1,56(sp)
    80004686:	ec56                	sd	s5,24(sp)
    80004688:	e45e                	sd	s7,8(sp)
    8000468a:	e062                	sd	s8,0(sp)
    int i = 0;
    8000468c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000468e:	6b85                	lui	s7,0x1
    80004690:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004694:	6c05                	lui	s8,0x1
    80004696:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000469a:	a8b5                	j	80004716 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000469c:	6908                	ld	a0,16(a0)
    8000469e:	1fc000ef          	jal	8000489a <pipewrite>
    800046a2:	a04d                	j	80004744 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046a4:	02451783          	lh	a5,36(a0)
    800046a8:	03079693          	slli	a3,a5,0x30
    800046ac:	92c1                	srli	a3,a3,0x30
    800046ae:	4725                	li	a4,9
    800046b0:	0ad76e63          	bltu	a4,a3,8000476c <filewrite+0x11e>
    800046b4:	0792                	slli	a5,a5,0x4
    800046b6:	0001c717          	auipc	a4,0x1c
    800046ba:	e4270713          	addi	a4,a4,-446 # 800204f8 <devsw>
    800046be:	97ba                	add	a5,a5,a4
    800046c0:	679c                	ld	a5,8(a5)
    800046c2:	c7dd                	beqz	a5,80004770 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800046c4:	4505                	li	a0,1
    800046c6:	9782                	jalr	a5
    800046c8:	a8b5                	j	80004744 <filewrite+0xf6>
      if(n1 > max)
    800046ca:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800046ce:	989ff0ef          	jal	80004056 <begin_op>
      ilock(f->ip);
    800046d2:	01893503          	ld	a0,24(s2)
    800046d6:	8eaff0ef          	jal	800037c0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800046da:	8756                	mv	a4,s5
    800046dc:	02092683          	lw	a3,32(s2)
    800046e0:	01698633          	add	a2,s3,s6
    800046e4:	4585                	li	a1,1
    800046e6:	01893503          	ld	a0,24(s2)
    800046ea:	c26ff0ef          	jal	80003b10 <writei>
    800046ee:	84aa                	mv	s1,a0
    800046f0:	00a05763          	blez	a0,800046fe <filewrite+0xb0>
        f->off += r;
    800046f4:	02092783          	lw	a5,32(s2)
    800046f8:	9fa9                	addw	a5,a5,a0
    800046fa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800046fe:	01893503          	ld	a0,24(s2)
    80004702:	96cff0ef          	jal	8000386e <iunlock>
      end_op();
    80004706:	9bbff0ef          	jal	800040c0 <end_op>

      if(r != n1){
    8000470a:	029a9563          	bne	s5,s1,80004734 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    8000470e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004712:	0149da63          	bge	s3,s4,80004726 <filewrite+0xd8>
      int n1 = n - i;
    80004716:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000471a:	0004879b          	sext.w	a5,s1
    8000471e:	fafbd6e3          	bge	s7,a5,800046ca <filewrite+0x7c>
    80004722:	84e2                	mv	s1,s8
    80004724:	b75d                	j	800046ca <filewrite+0x7c>
    80004726:	74e2                	ld	s1,56(sp)
    80004728:	6ae2                	ld	s5,24(sp)
    8000472a:	6ba2                	ld	s7,8(sp)
    8000472c:	6c02                	ld	s8,0(sp)
    8000472e:	a039                	j	8000473c <filewrite+0xee>
    int i = 0;
    80004730:	4981                	li	s3,0
    80004732:	a029                	j	8000473c <filewrite+0xee>
    80004734:	74e2                	ld	s1,56(sp)
    80004736:	6ae2                	ld	s5,24(sp)
    80004738:	6ba2                	ld	s7,8(sp)
    8000473a:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000473c:	033a1c63          	bne	s4,s3,80004774 <filewrite+0x126>
    80004740:	8552                	mv	a0,s4
    80004742:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004744:	60a6                	ld	ra,72(sp)
    80004746:	6406                	ld	s0,64(sp)
    80004748:	7942                	ld	s2,48(sp)
    8000474a:	7a02                	ld	s4,32(sp)
    8000474c:	6b42                	ld	s6,16(sp)
    8000474e:	6161                	addi	sp,sp,80
    80004750:	8082                	ret
    80004752:	fc26                	sd	s1,56(sp)
    80004754:	f44e                	sd	s3,40(sp)
    80004756:	ec56                	sd	s5,24(sp)
    80004758:	e45e                	sd	s7,8(sp)
    8000475a:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000475c:	00003517          	auipc	a0,0x3
    80004760:	ecc50513          	addi	a0,a0,-308 # 80007628 <etext+0x628>
    80004764:	830fc0ef          	jal	80000794 <panic>
    return -1;
    80004768:	557d                	li	a0,-1
}
    8000476a:	8082                	ret
      return -1;
    8000476c:	557d                	li	a0,-1
    8000476e:	bfd9                	j	80004744 <filewrite+0xf6>
    80004770:	557d                	li	a0,-1
    80004772:	bfc9                	j	80004744 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004774:	557d                	li	a0,-1
    80004776:	79a2                	ld	s3,40(sp)
    80004778:	b7f1                	j	80004744 <filewrite+0xf6>

000000008000477a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000477a:	7179                	addi	sp,sp,-48
    8000477c:	f406                	sd	ra,40(sp)
    8000477e:	f022                	sd	s0,32(sp)
    80004780:	ec26                	sd	s1,24(sp)
    80004782:	e052                	sd	s4,0(sp)
    80004784:	1800                	addi	s0,sp,48
    80004786:	84aa                	mv	s1,a0
    80004788:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000478a:	0005b023          	sd	zero,0(a1)
    8000478e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004792:	c3bff0ef          	jal	800043cc <filealloc>
    80004796:	e088                	sd	a0,0(s1)
    80004798:	c549                	beqz	a0,80004822 <pipealloc+0xa8>
    8000479a:	c33ff0ef          	jal	800043cc <filealloc>
    8000479e:	00aa3023          	sd	a0,0(s4)
    800047a2:	cd25                	beqz	a0,8000481a <pipealloc+0xa0>
    800047a4:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800047a6:	b7efc0ef          	jal	80000b24 <kalloc>
    800047aa:	892a                	mv	s2,a0
    800047ac:	c12d                	beqz	a0,8000480e <pipealloc+0x94>
    800047ae:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800047b0:	4985                	li	s3,1
    800047b2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800047b6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800047ba:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800047be:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800047c2:	00003597          	auipc	a1,0x3
    800047c6:	e7658593          	addi	a1,a1,-394 # 80007638 <etext+0x638>
    800047ca:	baafc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800047ce:	609c                	ld	a5,0(s1)
    800047d0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800047d4:	609c                	ld	a5,0(s1)
    800047d6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800047da:	609c                	ld	a5,0(s1)
    800047dc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800047e0:	609c                	ld	a5,0(s1)
    800047e2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800047e6:	000a3783          	ld	a5,0(s4)
    800047ea:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800047ee:	000a3783          	ld	a5,0(s4)
    800047f2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800047f6:	000a3783          	ld	a5,0(s4)
    800047fa:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800047fe:	000a3783          	ld	a5,0(s4)
    80004802:	0127b823          	sd	s2,16(a5)
  return 0;
    80004806:	4501                	li	a0,0
    80004808:	6942                	ld	s2,16(sp)
    8000480a:	69a2                	ld	s3,8(sp)
    8000480c:	a01d                	j	80004832 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000480e:	6088                	ld	a0,0(s1)
    80004810:	c119                	beqz	a0,80004816 <pipealloc+0x9c>
    80004812:	6942                	ld	s2,16(sp)
    80004814:	a029                	j	8000481e <pipealloc+0xa4>
    80004816:	6942                	ld	s2,16(sp)
    80004818:	a029                	j	80004822 <pipealloc+0xa8>
    8000481a:	6088                	ld	a0,0(s1)
    8000481c:	c10d                	beqz	a0,8000483e <pipealloc+0xc4>
    fileclose(*f0);
    8000481e:	c53ff0ef          	jal	80004470 <fileclose>
  if(*f1)
    80004822:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004826:	557d                	li	a0,-1
  if(*f1)
    80004828:	c789                	beqz	a5,80004832 <pipealloc+0xb8>
    fileclose(*f1);
    8000482a:	853e                	mv	a0,a5
    8000482c:	c45ff0ef          	jal	80004470 <fileclose>
  return -1;
    80004830:	557d                	li	a0,-1
}
    80004832:	70a2                	ld	ra,40(sp)
    80004834:	7402                	ld	s0,32(sp)
    80004836:	64e2                	ld	s1,24(sp)
    80004838:	6a02                	ld	s4,0(sp)
    8000483a:	6145                	addi	sp,sp,48
    8000483c:	8082                	ret
  return -1;
    8000483e:	557d                	li	a0,-1
    80004840:	bfcd                	j	80004832 <pipealloc+0xb8>

0000000080004842 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004842:	1101                	addi	sp,sp,-32
    80004844:	ec06                	sd	ra,24(sp)
    80004846:	e822                	sd	s0,16(sp)
    80004848:	e426                	sd	s1,8(sp)
    8000484a:	e04a                	sd	s2,0(sp)
    8000484c:	1000                	addi	s0,sp,32
    8000484e:	84aa                	mv	s1,a0
    80004850:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004852:	ba2fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004856:	02090763          	beqz	s2,80004884 <pipeclose+0x42>
    pi->writeopen = 0;
    8000485a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000485e:	21848513          	addi	a0,s1,536
    80004862:	80ffd0ef          	jal	80002070 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004866:	2204b783          	ld	a5,544(s1)
    8000486a:	e785                	bnez	a5,80004892 <pipeclose+0x50>
    release(&pi->lock);
    8000486c:	8526                	mv	a0,s1
    8000486e:	c1efc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004872:	8526                	mv	a0,s1
    80004874:	9cefc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004878:	60e2                	ld	ra,24(sp)
    8000487a:	6442                	ld	s0,16(sp)
    8000487c:	64a2                	ld	s1,8(sp)
    8000487e:	6902                	ld	s2,0(sp)
    80004880:	6105                	addi	sp,sp,32
    80004882:	8082                	ret
    pi->readopen = 0;
    80004884:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004888:	21c48513          	addi	a0,s1,540
    8000488c:	fe4fd0ef          	jal	80002070 <wakeup>
    80004890:	bfd9                	j	80004866 <pipeclose+0x24>
    release(&pi->lock);
    80004892:	8526                	mv	a0,s1
    80004894:	bf8fc0ef          	jal	80000c8c <release>
}
    80004898:	b7c5                	j	80004878 <pipeclose+0x36>

000000008000489a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000489a:	711d                	addi	sp,sp,-96
    8000489c:	ec86                	sd	ra,88(sp)
    8000489e:	e8a2                	sd	s0,80(sp)
    800048a0:	e4a6                	sd	s1,72(sp)
    800048a2:	e0ca                	sd	s2,64(sp)
    800048a4:	fc4e                	sd	s3,56(sp)
    800048a6:	f852                	sd	s4,48(sp)
    800048a8:	f456                	sd	s5,40(sp)
    800048aa:	1080                	addi	s0,sp,96
    800048ac:	84aa                	mv	s1,a0
    800048ae:	8aae                	mv	s5,a1
    800048b0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800048b2:	95cfd0ef          	jal	80001a0e <myproc>
    800048b6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800048b8:	8526                	mv	a0,s1
    800048ba:	b3afc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800048be:	0b405a63          	blez	s4,80004972 <pipewrite+0xd8>
    800048c2:	f05a                	sd	s6,32(sp)
    800048c4:	ec5e                	sd	s7,24(sp)
    800048c6:	e862                	sd	s8,16(sp)
  int i = 0;
    800048c8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048ca:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800048cc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800048d0:	21c48b93          	addi	s7,s1,540
    800048d4:	a81d                	j	8000490a <pipewrite+0x70>
      release(&pi->lock);
    800048d6:	8526                	mv	a0,s1
    800048d8:	bb4fc0ef          	jal	80000c8c <release>
      return -1;
    800048dc:	597d                	li	s2,-1
    800048de:	7b02                	ld	s6,32(sp)
    800048e0:	6be2                	ld	s7,24(sp)
    800048e2:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800048e4:	854a                	mv	a0,s2
    800048e6:	60e6                	ld	ra,88(sp)
    800048e8:	6446                	ld	s0,80(sp)
    800048ea:	64a6                	ld	s1,72(sp)
    800048ec:	6906                	ld	s2,64(sp)
    800048ee:	79e2                	ld	s3,56(sp)
    800048f0:	7a42                	ld	s4,48(sp)
    800048f2:	7aa2                	ld	s5,40(sp)
    800048f4:	6125                	addi	sp,sp,96
    800048f6:	8082                	ret
      wakeup(&pi->nread);
    800048f8:	8562                	mv	a0,s8
    800048fa:	f76fd0ef          	jal	80002070 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800048fe:	85a6                	mv	a1,s1
    80004900:	855e                	mv	a0,s7
    80004902:	f22fd0ef          	jal	80002024 <sleep>
  while(i < n){
    80004906:	05495b63          	bge	s2,s4,8000495c <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000490a:	2204a783          	lw	a5,544(s1)
    8000490e:	d7e1                	beqz	a5,800048d6 <pipewrite+0x3c>
    80004910:	854e                	mv	a0,s3
    80004912:	9fdfd0ef          	jal	8000230e <killed>
    80004916:	f161                	bnez	a0,800048d6 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004918:	2184a783          	lw	a5,536(s1)
    8000491c:	21c4a703          	lw	a4,540(s1)
    80004920:	2007879b          	addiw	a5,a5,512
    80004924:	fcf70ae3          	beq	a4,a5,800048f8 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004928:	4685                	li	a3,1
    8000492a:	01590633          	add	a2,s2,s5
    8000492e:	faf40593          	addi	a1,s0,-81
    80004932:	0509b503          	ld	a0,80(s3)
    80004936:	e21fc0ef          	jal	80001756 <copyin>
    8000493a:	03650e63          	beq	a0,s6,80004976 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000493e:	21c4a783          	lw	a5,540(s1)
    80004942:	0017871b          	addiw	a4,a5,1
    80004946:	20e4ae23          	sw	a4,540(s1)
    8000494a:	1ff7f793          	andi	a5,a5,511
    8000494e:	97a6                	add	a5,a5,s1
    80004950:	faf44703          	lbu	a4,-81(s0)
    80004954:	00e78c23          	sb	a4,24(a5)
      i++;
    80004958:	2905                	addiw	s2,s2,1
    8000495a:	b775                	j	80004906 <pipewrite+0x6c>
    8000495c:	7b02                	ld	s6,32(sp)
    8000495e:	6be2                	ld	s7,24(sp)
    80004960:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004962:	21848513          	addi	a0,s1,536
    80004966:	f0afd0ef          	jal	80002070 <wakeup>
  release(&pi->lock);
    8000496a:	8526                	mv	a0,s1
    8000496c:	b20fc0ef          	jal	80000c8c <release>
  return i;
    80004970:	bf95                	j	800048e4 <pipewrite+0x4a>
  int i = 0;
    80004972:	4901                	li	s2,0
    80004974:	b7fd                	j	80004962 <pipewrite+0xc8>
    80004976:	7b02                	ld	s6,32(sp)
    80004978:	6be2                	ld	s7,24(sp)
    8000497a:	6c42                	ld	s8,16(sp)
    8000497c:	b7dd                	j	80004962 <pipewrite+0xc8>

000000008000497e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000497e:	715d                	addi	sp,sp,-80
    80004980:	e486                	sd	ra,72(sp)
    80004982:	e0a2                	sd	s0,64(sp)
    80004984:	fc26                	sd	s1,56(sp)
    80004986:	f84a                	sd	s2,48(sp)
    80004988:	f44e                	sd	s3,40(sp)
    8000498a:	f052                	sd	s4,32(sp)
    8000498c:	ec56                	sd	s5,24(sp)
    8000498e:	0880                	addi	s0,sp,80
    80004990:	84aa                	mv	s1,a0
    80004992:	892e                	mv	s2,a1
    80004994:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004996:	878fd0ef          	jal	80001a0e <myproc>
    8000499a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000499c:	8526                	mv	a0,s1
    8000499e:	a56fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049a2:	2184a703          	lw	a4,536(s1)
    800049a6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049aa:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049ae:	02f71563          	bne	a4,a5,800049d8 <piperead+0x5a>
    800049b2:	2244a783          	lw	a5,548(s1)
    800049b6:	cb85                	beqz	a5,800049e6 <piperead+0x68>
    if(killed(pr)){
    800049b8:	8552                	mv	a0,s4
    800049ba:	955fd0ef          	jal	8000230e <killed>
    800049be:	ed19                	bnez	a0,800049dc <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049c0:	85a6                	mv	a1,s1
    800049c2:	854e                	mv	a0,s3
    800049c4:	e60fd0ef          	jal	80002024 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049c8:	2184a703          	lw	a4,536(s1)
    800049cc:	21c4a783          	lw	a5,540(s1)
    800049d0:	fef701e3          	beq	a4,a5,800049b2 <piperead+0x34>
    800049d4:	e85a                	sd	s6,16(sp)
    800049d6:	a809                	j	800049e8 <piperead+0x6a>
    800049d8:	e85a                	sd	s6,16(sp)
    800049da:	a039                	j	800049e8 <piperead+0x6a>
      release(&pi->lock);
    800049dc:	8526                	mv	a0,s1
    800049de:	aaefc0ef          	jal	80000c8c <release>
      return -1;
    800049e2:	59fd                	li	s3,-1
    800049e4:	a8b1                	j	80004a40 <piperead+0xc2>
    800049e6:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049e8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800049ea:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800049ec:	05505263          	blez	s5,80004a30 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800049f0:	2184a783          	lw	a5,536(s1)
    800049f4:	21c4a703          	lw	a4,540(s1)
    800049f8:	02f70c63          	beq	a4,a5,80004a30 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800049fc:	0017871b          	addiw	a4,a5,1
    80004a00:	20e4ac23          	sw	a4,536(s1)
    80004a04:	1ff7f793          	andi	a5,a5,511
    80004a08:	97a6                	add	a5,a5,s1
    80004a0a:	0187c783          	lbu	a5,24(a5)
    80004a0e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a12:	4685                	li	a3,1
    80004a14:	fbf40613          	addi	a2,s0,-65
    80004a18:	85ca                	mv	a1,s2
    80004a1a:	050a3503          	ld	a0,80(s4)
    80004a1e:	c63fc0ef          	jal	80001680 <copyout>
    80004a22:	01650763          	beq	a0,s6,80004a30 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a26:	2985                	addiw	s3,s3,1
    80004a28:	0905                	addi	s2,s2,1
    80004a2a:	fd3a93e3          	bne	s5,s3,800049f0 <piperead+0x72>
    80004a2e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004a30:	21c48513          	addi	a0,s1,540
    80004a34:	e3cfd0ef          	jal	80002070 <wakeup>
  release(&pi->lock);
    80004a38:	8526                	mv	a0,s1
    80004a3a:	a52fc0ef          	jal	80000c8c <release>
    80004a3e:	6b42                	ld	s6,16(sp)
  return i;
}
    80004a40:	854e                	mv	a0,s3
    80004a42:	60a6                	ld	ra,72(sp)
    80004a44:	6406                	ld	s0,64(sp)
    80004a46:	74e2                	ld	s1,56(sp)
    80004a48:	7942                	ld	s2,48(sp)
    80004a4a:	79a2                	ld	s3,40(sp)
    80004a4c:	7a02                	ld	s4,32(sp)
    80004a4e:	6ae2                	ld	s5,24(sp)
    80004a50:	6161                	addi	sp,sp,80
    80004a52:	8082                	ret

0000000080004a54 <flags2perm>:
/* ===== */

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004a54:	1141                	addi	sp,sp,-16
    80004a56:	e422                	sd	s0,8(sp)
    80004a58:	0800                	addi	s0,sp,16
    80004a5a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004a5c:	8905                	andi	a0,a0,1
    80004a5e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004a60:	8b89                	andi	a5,a5,2
    80004a62:	c399                	beqz	a5,80004a68 <flags2perm+0x14>
      perm |= PTE_W;
    80004a64:	00456513          	ori	a0,a0,4
    return perm;
}
    80004a68:	6422                	ld	s0,8(sp)
    80004a6a:	0141                	addi	sp,sp,16
    80004a6c:	8082                	ret

0000000080004a6e <exec>:

int
exec(char *path, char **argv)
{
    80004a6e:	df010113          	addi	sp,sp,-528
    80004a72:	20113423          	sd	ra,520(sp)
    80004a76:	20813023          	sd	s0,512(sp)
    80004a7a:	ffa6                	sd	s1,504(sp)
    80004a7c:	fbca                	sd	s2,496(sp)
    80004a7e:	f7ce                	sd	s3,488(sp)
    80004a80:	f3d2                	sd	s4,480(sp)
    80004a82:	0c00                	addi	s0,sp,528
    80004a84:	e0a43423          	sd	a0,-504(s0)
    80004a88:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004a8c:	f83fc0ef          	jal	80001a0e <myproc>
    80004a90:	892a                	mv	s2,a0
  struct proc *thread;

  /* implementation for project02 */
  // terminate all threads
  for(thread = proc; thread < &proc[NPROC]; thread++){
    80004a92:	0000b497          	auipc	s1,0xb
    80004a96:	41e48493          	addi	s1,s1,1054 # 8000feb0 <proc>
    80004a9a:	00012997          	auipc	s3,0x12
    80004a9e:	81698993          	addi	s3,s3,-2026 # 800162b0 <tickslock>
    80004aa2:	a029                	j	80004aac <exec+0x3e>
    80004aa4:	19048493          	addi	s1,s1,400
    80004aa8:	03348463          	beq	s1,s3,80004ad0 <exec+0x62>
    if(thread->pid == p->pid && thread != p->main_thread){
    80004aac:	5898                	lw	a4,48(s1)
    80004aae:	03092783          	lw	a5,48(s2)
    80004ab2:	fef719e3          	bne	a4,a5,80004aa4 <exec+0x36>
    80004ab6:	17093783          	ld	a5,368(s2)
    80004aba:	fe9785e3          	beq	a5,s1,80004aa4 <exec+0x36>
      // unmapping
      if(thread->trapframe){
    80004abe:	70bc                	ld	a5,96(s1)
    80004ac0:	d3f5                	beqz	a5,80004aa4 <exec+0x36>
        uvmunmap(thread->pagetable, thread->trapframe_va, 1, 0);
    80004ac2:	4681                	li	a3,0
    80004ac4:	4605                	li	a2,1
    80004ac6:	6cac                	ld	a1,88(s1)
    80004ac8:	68a8                	ld	a0,80(s1)
    80004aca:	f26fc0ef          	jal	800011f0 <uvmunmap>
    80004ace:	bfd9                	j	80004aa4 <exec+0x36>
      }
    }
  }

  if(p->tid != 0){
    80004ad0:	17892783          	lw	a5,376(s2)
    80004ad4:	c395                	beqz	a5,80004af8 <exec+0x8a>
    p->main_thread->tid = p->tid;
    80004ad6:	17093703          	ld	a4,368(s2)
    80004ada:	16f72c23          	sw	a5,376(a4)
    p->tid = 0;
    80004ade:	16092c23          	sw	zero,376(s2)
    p->parent = p->main_thread->parent;
    80004ae2:	17093783          	ld	a5,368(s2)
    80004ae6:	7f9c                	ld	a5,56(a5)
    80004ae8:	02f93c23          	sd	a5,56(s2)
    p->main_thread = p;
    80004aec:	17293823          	sd	s2,368(s2)
    p->main_sz = &(p->sz);
    80004af0:	04890793          	addi	a5,s2,72
    80004af4:	18f93423          	sd	a5,392(s2)
  for(thread = proc; thread < &proc[NPROC]; thread++){
    80004af8:	0000b497          	auipc	s1,0xb
    80004afc:	3b848493          	addi	s1,s1,952 # 8000feb0 <proc>
  }

  for(thread = proc; thread < &proc[NPROC]; thread++){
    80004b00:	00011997          	auipc	s3,0x11
    80004b04:	7b098993          	addi	s3,s3,1968 # 800162b0 <tickslock>
    80004b08:	a0a1                	j	80004b50 <exec+0xe2>
      acquire(&thread->lock);

      if(thread->trapframe){
        kfree((void*)thread->trapframe);
      }
      thread->trapframe = 0;
    80004b0a:	0604b023          	sd	zero,96(s1)
      thread->trapframe_va = 0;
    80004b0e:	0404bc23          	sd	zero,88(s1)
      thread->pagetable = 0;
    80004b12:	0404b823          	sd	zero,80(s1)
      thread->sz = 0;
    80004b16:	0404b423          	sd	zero,72(s1)
      thread->pid = 0;
    80004b1a:	0204a823          	sw	zero,48(s1)
      thread->parent = 0;
    80004b1e:	0204bc23          	sd	zero,56(s1)
      thread->name[0] = 0;
    80004b22:	16048023          	sb	zero,352(s1)
      thread->chan = 0;
    80004b26:	0204b023          	sd	zero,32(s1)
      thread->killed = 0;
    80004b2a:	0204a423          	sw	zero,40(s1)
      thread->xstate = 0;
    80004b2e:	0204a623          	sw	zero,44(s1)
      thread->state = UNUSED;
    80004b32:	0004ac23          	sw	zero,24(s1)
      thread->tid = 0;
    80004b36:	1604ac23          	sw	zero,376(s1)
      thread->main_thread = 0;
    80004b3a:	1604b823          	sd	zero,368(s1)
      thread->stack = 0;
    80004b3e:	1804b023          	sd	zero,384(s1)
      
      release(&thread->lock);
    80004b42:	8526                	mv	a0,s1
    80004b44:	948fc0ef          	jal	80000c8c <release>
  for(thread = proc; thread < &proc[NPROC]; thread++){
    80004b48:	19048493          	addi	s1,s1,400
    80004b4c:	03348163          	beq	s1,s3,80004b6e <exec+0x100>
    if(thread->pid == p->pid && thread != p){
    80004b50:	5898                	lw	a4,48(s1)
    80004b52:	03092783          	lw	a5,48(s2)
    80004b56:	fef719e3          	bne	a4,a5,80004b48 <exec+0xda>
    80004b5a:	fe9907e3          	beq	s2,s1,80004b48 <exec+0xda>
      acquire(&thread->lock);
    80004b5e:	8526                	mv	a0,s1
    80004b60:	894fc0ef          	jal	80000bf4 <acquire>
      if(thread->trapframe){
    80004b64:	70a8                	ld	a0,96(s1)
    80004b66:	d155                	beqz	a0,80004b0a <exec+0x9c>
        kfree((void*)thread->trapframe);
    80004b68:	edbfb0ef          	jal	80000a42 <kfree>
    80004b6c:	bf79                	j	80004b0a <exec+0x9c>
    }
  }
  
  /* ===== */

  begin_op();
    80004b6e:	ce8ff0ef          	jal	80004056 <begin_op>

  if((ip = namei(path)) == 0){
    80004b72:	e0843503          	ld	a0,-504(s0)
    80004b76:	b24ff0ef          	jal	80003e9a <namei>
    80004b7a:	8a2a                	mv	s4,a0
    80004b7c:	c929                	beqz	a0,80004bce <exec+0x160>
    end_op();
    return -1;
  }
  ilock(ip);
    80004b7e:	c43fe0ef          	jal	800037c0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)){
    80004b82:	04000713          	li	a4,64
    80004b86:	4681                	li	a3,0
    80004b88:	e5040613          	addi	a2,s0,-432
    80004b8c:	4581                	li	a1,0
    80004b8e:	8552                	mv	a0,s4
    80004b90:	e85fe0ef          	jal	80003a14 <readi>
    80004b94:	04000793          	li	a5,64
    80004b98:	00f51a63          	bne	a0,a5,80004bac <exec+0x13e>
    goto bad;
  }

  if(elf.magic != ELF_MAGIC){
    80004b9c:	e5042703          	lw	a4,-432(s0)
    80004ba0:	464c47b7          	lui	a5,0x464c4
    80004ba4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ba8:	02f70763          	beq	a4,a5,80004bd6 <exec+0x168>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bac:	8552                	mv	a0,s4
    80004bae:	e1dfe0ef          	jal	800039ca <iunlockput>
    end_op();
    80004bb2:	d0eff0ef          	jal	800040c0 <end_op>
  }
  return -1;
    80004bb6:	557d                	li	a0,-1
}
    80004bb8:	20813083          	ld	ra,520(sp)
    80004bbc:	20013403          	ld	s0,512(sp)
    80004bc0:	74fe                	ld	s1,504(sp)
    80004bc2:	795e                	ld	s2,496(sp)
    80004bc4:	79be                	ld	s3,488(sp)
    80004bc6:	7a1e                	ld	s4,480(sp)
    80004bc8:	21010113          	addi	sp,sp,528
    80004bcc:	8082                	ret
    end_op();
    80004bce:	cf2ff0ef          	jal	800040c0 <end_op>
    return -1;
    80004bd2:	557d                	li	a0,-1
    80004bd4:	b7d5                	j	80004bb8 <exec+0x14a>
    80004bd6:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0){
    80004bd8:	854a                	mv	a0,s2
    80004bda:	eddfc0ef          	jal	80001ab6 <proc_pagetable>
    80004bde:	8b2a                	mv	s6,a0
    80004be0:	2c050263          	beqz	a0,80004ea4 <exec+0x436>
    80004be4:	efd6                	sd	s5,472(sp)
    80004be6:	e7de                	sd	s7,456(sp)
    80004be8:	e3e2                	sd	s8,448(sp)
    80004bea:	ff66                	sd	s9,440(sp)
    80004bec:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bee:	e7042d03          	lw	s10,-400(s0)
    80004bf2:	e8845783          	lhu	a5,-376(s0)
    80004bf6:	12078863          	beqz	a5,80004d26 <exec+0x2b8>
    80004bfa:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bfc:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bfe:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004c00:	6c85                	lui	s9,0x1
    80004c02:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c06:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c0a:	6a85                	lui	s5,0x1
    80004c0c:	a085                	j	80004c6c <exec+0x1fe>
      panic("loadseg: address should exist");
    80004c0e:	00003517          	auipc	a0,0x3
    80004c12:	a3250513          	addi	a0,a0,-1486 # 80007640 <etext+0x640>
    80004c16:	b7ffb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004c1a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c1c:	8726                	mv	a4,s1
    80004c1e:	012c06bb          	addw	a3,s8,s2
    80004c22:	4581                	li	a1,0
    80004c24:	8552                	mv	a0,s4
    80004c26:	deffe0ef          	jal	80003a14 <readi>
    80004c2a:	2501                	sext.w	a0,a0
    80004c2c:	24a49563          	bne	s1,a0,80004e76 <exec+0x408>
  for(i = 0; i < sz; i += PGSIZE){
    80004c30:	012a893b          	addw	s2,s5,s2
    80004c34:	03397363          	bgeu	s2,s3,80004c5a <exec+0x1ec>
    pa = walkaddr(pagetable, va + i);
    80004c38:	02091593          	slli	a1,s2,0x20
    80004c3c:	9181                	srli	a1,a1,0x20
    80004c3e:	95de                	add	a1,a1,s7
    80004c40:	855a                	mv	a0,s6
    80004c42:	bcafc0ef          	jal	8000100c <walkaddr>
    80004c46:	862a                	mv	a2,a0
    if(pa == 0)
    80004c48:	d179                	beqz	a0,80004c0e <exec+0x1a0>
    if(sz - i < PGSIZE)
    80004c4a:	412984bb          	subw	s1,s3,s2
    80004c4e:	0004879b          	sext.w	a5,s1
    80004c52:	fcfcf4e3          	bgeu	s9,a5,80004c1a <exec+0x1ac>
    80004c56:	84d6                	mv	s1,s5
    80004c58:	b7c9                	j	80004c1a <exec+0x1ac>
    sz = sz1;
    80004c5a:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c5e:	2d85                	addiw	s11,s11,1
    80004c60:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004c64:	e8845783          	lhu	a5,-376(s0)
    80004c68:	08fdd063          	bge	s11,a5,80004ce8 <exec+0x27a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c6c:	2d01                	sext.w	s10,s10
    80004c6e:	03800713          	li	a4,56
    80004c72:	86ea                	mv	a3,s10
    80004c74:	e1840613          	addi	a2,s0,-488
    80004c78:	4581                	li	a1,0
    80004c7a:	8552                	mv	a0,s4
    80004c7c:	d99fe0ef          	jal	80003a14 <readi>
    80004c80:	03800793          	li	a5,56
    80004c84:	1cf51163          	bne	a0,a5,80004e46 <exec+0x3d8>
    if(ph.type != ELF_PROG_LOAD)
    80004c88:	e1842783          	lw	a5,-488(s0)
    80004c8c:	4705                	li	a4,1
    80004c8e:	fce798e3          	bne	a5,a4,80004c5e <exec+0x1f0>
    if(ph.memsz < ph.filesz)
    80004c92:	e4043903          	ld	s2,-448(s0)
    80004c96:	e3843783          	ld	a5,-456(s0)
    80004c9a:	1af96a63          	bltu	s2,a5,80004e4e <exec+0x3e0>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004c9e:	e2843783          	ld	a5,-472(s0)
    80004ca2:	993e                	add	s2,s2,a5
    80004ca4:	1af96963          	bltu	s2,a5,80004e56 <exec+0x3e8>
    if(ph.vaddr % PGSIZE != 0)
    80004ca8:	df043703          	ld	a4,-528(s0)
    80004cac:	8ff9                	and	a5,a5,a4
    80004cae:	1a079863          	bnez	a5,80004e5e <exec+0x3f0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004cb2:	e1c42503          	lw	a0,-484(s0)
    80004cb6:	d9fff0ef          	jal	80004a54 <flags2perm>
    80004cba:	86aa                	mv	a3,a0
    80004cbc:	864a                	mv	a2,s2
    80004cbe:	85a6                	mv	a1,s1
    80004cc0:	855a                	mv	a0,s6
    80004cc2:	eb2fc0ef          	jal	80001374 <uvmalloc>
    80004cc6:	e0a43023          	sd	a0,-512(s0)
    80004cca:	18050e63          	beqz	a0,80004e66 <exec+0x3f8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004cce:	e2843b83          	ld	s7,-472(s0)
    80004cd2:	e2042c03          	lw	s8,-480(s0)
    80004cd6:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004cda:	00098463          	beqz	s3,80004ce2 <exec+0x274>
    80004cde:	4901                	li	s2,0
    80004ce0:	bfa1                	j	80004c38 <exec+0x1ca>
    sz = sz1;
    80004ce2:	e0043483          	ld	s1,-512(s0)
    80004ce6:	bfa5                	j	80004c5e <exec+0x1f0>
    80004ce8:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004cea:	8552                	mv	a0,s4
    80004cec:	cdffe0ef          	jal	800039ca <iunlockput>
  end_op();
    80004cf0:	bd0ff0ef          	jal	800040c0 <end_op>
  p = myproc();
    80004cf4:	d1bfc0ef          	jal	80001a0e <myproc>
    80004cf8:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004cfa:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    80004cfe:	6785                	lui	a5,0x1
    80004d00:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004d02:	94be                	add	s1,s1,a5
    80004d04:	77fd                	lui	a5,0xfffff
    80004d06:	8cfd                	and	s1,s1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0){
    80004d08:	4691                	li	a3,4
    80004d0a:	6609                	lui	a2,0x2
    80004d0c:	9626                	add	a2,a2,s1
    80004d0e:	85a6                	mv	a1,s1
    80004d10:	855a                	mv	a0,s6
    80004d12:	e62fc0ef          	jal	80001374 <uvmalloc>
    80004d16:	892a                	mv	s2,a0
    80004d18:	e0a43023          	sd	a0,-512(s0)
    80004d1c:	e519                	bnez	a0,80004d2a <exec+0x2bc>
  sz = PGROUNDUP(sz);
    80004d1e:	e0943023          	sd	s1,-512(s0)
  if(pagetable)
    80004d22:	4a01                	li	s4,0
    80004d24:	aa91                	j	80004e78 <exec+0x40a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d26:	4481                	li	s1,0
    80004d28:	b7c9                	j	80004cea <exec+0x27c>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004d2a:	75f9                	lui	a1,0xffffe
    80004d2c:	95aa                	add	a1,a1,a0
    80004d2e:	855a                	mv	a0,s6
    80004d30:	927fc0ef          	jal	80001656 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004d34:	7afd                	lui	s5,0xfffff
    80004d36:	9aca                	add	s5,s5,s2
  for(argc = 0; argv[argc]; argc++) {
    80004d38:	df843783          	ld	a5,-520(s0)
    80004d3c:	6388                	ld	a0,0(a5)
    80004d3e:	cd39                	beqz	a0,80004d9c <exec+0x32e>
    80004d40:	e9040b93          	addi	s7,s0,-368
    80004d44:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d46:	8f2fc0ef          	jal	80000e38 <strlen>
    80004d4a:	0015079b          	addiw	a5,a0,1
    80004d4e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d52:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase){
    80004d56:	11596c63          	bltu	s2,s5,80004e6e <exec+0x400>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0){
    80004d5a:	df843c83          	ld	s9,-520(s0)
    80004d5e:	000cbc03          	ld	s8,0(s9)
    80004d62:	8562                	mv	a0,s8
    80004d64:	8d4fc0ef          	jal	80000e38 <strlen>
    80004d68:	0015069b          	addiw	a3,a0,1
    80004d6c:	8662                	mv	a2,s8
    80004d6e:	85ca                	mv	a1,s2
    80004d70:	855a                	mv	a0,s6
    80004d72:	90ffc0ef          	jal	80001680 <copyout>
    80004d76:	0e054e63          	bltz	a0,80004e72 <exec+0x404>
    ustack[argc] = sp;
    80004d7a:	012bb023          	sd	s2,0(s7)
  for(argc = 0; argv[argc]; argc++) {
    80004d7e:	0485                	addi	s1,s1,1
    80004d80:	008c8793          	addi	a5,s9,8
    80004d84:	def43c23          	sd	a5,-520(s0)
    80004d88:	008cb503          	ld	a0,8(s9)
    80004d8c:	c919                	beqz	a0,80004da2 <exec+0x334>
    if(argc >= MAXARG){
    80004d8e:	0ba1                	addi	s7,s7,8
    80004d90:	f9040793          	addi	a5,s0,-112
    80004d94:	fafb99e3          	bne	s7,a5,80004d46 <exec+0x2d8>
  ip = 0;
    80004d98:	4a01                	li	s4,0
    80004d9a:	a8f9                	j	80004e78 <exec+0x40a>
  sp = sz;
    80004d9c:	e0043903          	ld	s2,-512(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004da0:	4481                	li	s1,0
  ustack[argc] = 0;
    80004da2:	00349793          	slli	a5,s1,0x3
    80004da6:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd900>
    80004daa:	97a2                	add	a5,a5,s0
    80004dac:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004db0:	00148693          	addi	a3,s1,1
    80004db4:	068e                	slli	a3,a3,0x3
    80004db6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004dba:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase){
    80004dbe:	f75962e3          	bltu	s2,s5,80004d22 <exec+0x2b4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0){
    80004dc2:	e9040613          	addi	a2,s0,-368
    80004dc6:	85ca                	mv	a1,s2
    80004dc8:	855a                	mv	a0,s6
    80004dca:	8b7fc0ef          	jal	80001680 <copyout>
    80004dce:	f4054ae3          	bltz	a0,80004d22 <exec+0x2b4>
  p->trapframe->a1 = sp;
    80004dd2:	0609b783          	ld	a5,96(s3)
    80004dd6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004dda:	e0843783          	ld	a5,-504(s0)
    80004dde:	0007c703          	lbu	a4,0(a5)
    80004de2:	cf11                	beqz	a4,80004dfe <exec+0x390>
    80004de4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004de6:	02f00693          	li	a3,47
    80004dea:	a029                	j	80004df4 <exec+0x386>
  for(last=s=path; *s; s++)
    80004dec:	0785                	addi	a5,a5,1
    80004dee:	fff7c703          	lbu	a4,-1(a5)
    80004df2:	c711                	beqz	a4,80004dfe <exec+0x390>
    if(*s == '/')
    80004df4:	fed71ce3          	bne	a4,a3,80004dec <exec+0x37e>
      last = s+1;
    80004df8:	e0f43423          	sd	a5,-504(s0)
    80004dfc:	bfc5                	j	80004dec <exec+0x37e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004dfe:	4641                	li	a2,16
    80004e00:	e0843583          	ld	a1,-504(s0)
    80004e04:	16098513          	addi	a0,s3,352
    80004e08:	ffffb0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e0c:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004e10:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004e14:	e0043783          	ld	a5,-512(s0)
    80004e18:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e1c:	0609b783          	ld	a5,96(s3)
    80004e20:	e6843703          	ld	a4,-408(s0)
    80004e24:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e26:	0609b783          	ld	a5,96(s3)
    80004e2a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e2e:	85d2                	mv	a1,s4
    80004e30:	d0ffc0ef          	jal	80001b3e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e34:	0004851b          	sext.w	a0,s1
    80004e38:	6afe                	ld	s5,472(sp)
    80004e3a:	6b5e                	ld	s6,464(sp)
    80004e3c:	6bbe                	ld	s7,456(sp)
    80004e3e:	6c1e                	ld	s8,448(sp)
    80004e40:	7cfa                	ld	s9,440(sp)
    80004e42:	7d5a                	ld	s10,432(sp)
    80004e44:	bb95                	j	80004bb8 <exec+0x14a>
    80004e46:	e0943023          	sd	s1,-512(s0)
    80004e4a:	7dba                	ld	s11,424(sp)
    80004e4c:	a035                	j	80004e78 <exec+0x40a>
    80004e4e:	e0943023          	sd	s1,-512(s0)
    80004e52:	7dba                	ld	s11,424(sp)
    80004e54:	a015                	j	80004e78 <exec+0x40a>
    80004e56:	e0943023          	sd	s1,-512(s0)
    80004e5a:	7dba                	ld	s11,424(sp)
    80004e5c:	a831                	j	80004e78 <exec+0x40a>
    80004e5e:	e0943023          	sd	s1,-512(s0)
    80004e62:	7dba                	ld	s11,424(sp)
    80004e64:	a811                	j	80004e78 <exec+0x40a>
    80004e66:	e0943023          	sd	s1,-512(s0)
    80004e6a:	7dba                	ld	s11,424(sp)
    80004e6c:	a031                	j	80004e78 <exec+0x40a>
  ip = 0;
    80004e6e:	4a01                	li	s4,0
    80004e70:	a021                	j	80004e78 <exec+0x40a>
    80004e72:	4a01                	li	s4,0
  if(pagetable)
    80004e74:	a011                	j	80004e78 <exec+0x40a>
    80004e76:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004e78:	e0043583          	ld	a1,-512(s0)
    80004e7c:	855a                	mv	a0,s6
    80004e7e:	cc1fc0ef          	jal	80001b3e <proc_freepagetable>
  return -1;
    80004e82:	557d                	li	a0,-1
  if(ip){
    80004e84:	000a1963          	bnez	s4,80004e96 <exec+0x428>
    80004e88:	6afe                	ld	s5,472(sp)
    80004e8a:	6b5e                	ld	s6,464(sp)
    80004e8c:	6bbe                	ld	s7,456(sp)
    80004e8e:	6c1e                	ld	s8,448(sp)
    80004e90:	7cfa                	ld	s9,440(sp)
    80004e92:	7d5a                	ld	s10,432(sp)
    80004e94:	b315                	j	80004bb8 <exec+0x14a>
    80004e96:	6afe                	ld	s5,472(sp)
    80004e98:	6b5e                	ld	s6,464(sp)
    80004e9a:	6bbe                	ld	s7,456(sp)
    80004e9c:	6c1e                	ld	s8,448(sp)
    80004e9e:	7cfa                	ld	s9,440(sp)
    80004ea0:	7d5a                	ld	s10,432(sp)
    80004ea2:	b329                	j	80004bac <exec+0x13e>
    80004ea4:	6b5e                	ld	s6,464(sp)
    80004ea6:	b319                	j	80004bac <exec+0x13e>

0000000080004ea8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ea8:	7179                	addi	sp,sp,-48
    80004eaa:	f406                	sd	ra,40(sp)
    80004eac:	f022                	sd	s0,32(sp)
    80004eae:	ec26                	sd	s1,24(sp)
    80004eb0:	e84a                	sd	s2,16(sp)
    80004eb2:	1800                	addi	s0,sp,48
    80004eb4:	892e                	mv	s2,a1
    80004eb6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004eb8:	fdc40593          	addi	a1,s0,-36
    80004ebc:	e5bfd0ef          	jal	80002d16 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ec0:	fdc42703          	lw	a4,-36(s0)
    80004ec4:	47bd                	li	a5,15
    80004ec6:	02e7e963          	bltu	a5,a4,80004ef8 <argfd+0x50>
    80004eca:	b45fc0ef          	jal	80001a0e <myproc>
    80004ece:	fdc42703          	lw	a4,-36(s0)
    80004ed2:	01a70793          	addi	a5,a4,26
    80004ed6:	078e                	slli	a5,a5,0x3
    80004ed8:	953e                	add	a0,a0,a5
    80004eda:	651c                	ld	a5,8(a0)
    80004edc:	c385                	beqz	a5,80004efc <argfd+0x54>
    return -1;
  if(pfd)
    80004ede:	00090463          	beqz	s2,80004ee6 <argfd+0x3e>
    *pfd = fd;
    80004ee2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004ee6:	4501                	li	a0,0
  if(pf)
    80004ee8:	c091                	beqz	s1,80004eec <argfd+0x44>
    *pf = f;
    80004eea:	e09c                	sd	a5,0(s1)
}
    80004eec:	70a2                	ld	ra,40(sp)
    80004eee:	7402                	ld	s0,32(sp)
    80004ef0:	64e2                	ld	s1,24(sp)
    80004ef2:	6942                	ld	s2,16(sp)
    80004ef4:	6145                	addi	sp,sp,48
    80004ef6:	8082                	ret
    return -1;
    80004ef8:	557d                	li	a0,-1
    80004efa:	bfcd                	j	80004eec <argfd+0x44>
    80004efc:	557d                	li	a0,-1
    80004efe:	b7fd                	j	80004eec <argfd+0x44>

0000000080004f00 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f00:	1101                	addi	sp,sp,-32
    80004f02:	ec06                	sd	ra,24(sp)
    80004f04:	e822                	sd	s0,16(sp)
    80004f06:	e426                	sd	s1,8(sp)
    80004f08:	1000                	addi	s0,sp,32
    80004f0a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f0c:	b03fc0ef          	jal	80001a0e <myproc>
    80004f10:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f12:	0d850793          	addi	a5,a0,216
    80004f16:	4501                	li	a0,0
    80004f18:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f1a:	6398                	ld	a4,0(a5)
    80004f1c:	cb19                	beqz	a4,80004f32 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004f1e:	2505                	addiw	a0,a0,1
    80004f20:	07a1                	addi	a5,a5,8
    80004f22:	fed51ce3          	bne	a0,a3,80004f1a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f26:	557d                	li	a0,-1
}
    80004f28:	60e2                	ld	ra,24(sp)
    80004f2a:	6442                	ld	s0,16(sp)
    80004f2c:	64a2                	ld	s1,8(sp)
    80004f2e:	6105                	addi	sp,sp,32
    80004f30:	8082                	ret
      p->ofile[fd] = f;
    80004f32:	01a50793          	addi	a5,a0,26
    80004f36:	078e                	slli	a5,a5,0x3
    80004f38:	963e                	add	a2,a2,a5
    80004f3a:	e604                	sd	s1,8(a2)
      return fd;
    80004f3c:	b7f5                	j	80004f28 <fdalloc+0x28>

0000000080004f3e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f3e:	715d                	addi	sp,sp,-80
    80004f40:	e486                	sd	ra,72(sp)
    80004f42:	e0a2                	sd	s0,64(sp)
    80004f44:	fc26                	sd	s1,56(sp)
    80004f46:	f84a                	sd	s2,48(sp)
    80004f48:	f44e                	sd	s3,40(sp)
    80004f4a:	ec56                	sd	s5,24(sp)
    80004f4c:	e85a                	sd	s6,16(sp)
    80004f4e:	0880                	addi	s0,sp,80
    80004f50:	8b2e                	mv	s6,a1
    80004f52:	89b2                	mv	s3,a2
    80004f54:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f56:	fb040593          	addi	a1,s0,-80
    80004f5a:	f5bfe0ef          	jal	80003eb4 <nameiparent>
    80004f5e:	84aa                	mv	s1,a0
    80004f60:	10050a63          	beqz	a0,80005074 <create+0x136>
    return 0;

  ilock(dp);
    80004f64:	85dfe0ef          	jal	800037c0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f68:	4601                	li	a2,0
    80004f6a:	fb040593          	addi	a1,s0,-80
    80004f6e:	8526                	mv	a0,s1
    80004f70:	cc5fe0ef          	jal	80003c34 <dirlookup>
    80004f74:	8aaa                	mv	s5,a0
    80004f76:	c129                	beqz	a0,80004fb8 <create+0x7a>
    iunlockput(dp);
    80004f78:	8526                	mv	a0,s1
    80004f7a:	a51fe0ef          	jal	800039ca <iunlockput>
    ilock(ip);
    80004f7e:	8556                	mv	a0,s5
    80004f80:	841fe0ef          	jal	800037c0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004f84:	4789                	li	a5,2
    80004f86:	02fb1463          	bne	s6,a5,80004fae <create+0x70>
    80004f8a:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd9b4>
    80004f8e:	37f9                	addiw	a5,a5,-2
    80004f90:	17c2                	slli	a5,a5,0x30
    80004f92:	93c1                	srli	a5,a5,0x30
    80004f94:	4705                	li	a4,1
    80004f96:	00f76c63          	bltu	a4,a5,80004fae <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004f9a:	8556                	mv	a0,s5
    80004f9c:	60a6                	ld	ra,72(sp)
    80004f9e:	6406                	ld	s0,64(sp)
    80004fa0:	74e2                	ld	s1,56(sp)
    80004fa2:	7942                	ld	s2,48(sp)
    80004fa4:	79a2                	ld	s3,40(sp)
    80004fa6:	6ae2                	ld	s5,24(sp)
    80004fa8:	6b42                	ld	s6,16(sp)
    80004faa:	6161                	addi	sp,sp,80
    80004fac:	8082                	ret
    iunlockput(ip);
    80004fae:	8556                	mv	a0,s5
    80004fb0:	a1bfe0ef          	jal	800039ca <iunlockput>
    return 0;
    80004fb4:	4a81                	li	s5,0
    80004fb6:	b7d5                	j	80004f9a <create+0x5c>
    80004fb8:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004fba:	85da                	mv	a1,s6
    80004fbc:	4088                	lw	a0,0(s1)
    80004fbe:	e92fe0ef          	jal	80003650 <ialloc>
    80004fc2:	8a2a                	mv	s4,a0
    80004fc4:	cd15                	beqz	a0,80005000 <create+0xc2>
  ilock(ip);
    80004fc6:	ffafe0ef          	jal	800037c0 <ilock>
  ip->major = major;
    80004fca:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004fce:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004fd2:	4905                	li	s2,1
    80004fd4:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004fd8:	8552                	mv	a0,s4
    80004fda:	f32fe0ef          	jal	8000370c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004fde:	032b0763          	beq	s6,s2,8000500c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004fe2:	004a2603          	lw	a2,4(s4)
    80004fe6:	fb040593          	addi	a1,s0,-80
    80004fea:	8526                	mv	a0,s1
    80004fec:	e15fe0ef          	jal	80003e00 <dirlink>
    80004ff0:	06054563          	bltz	a0,8000505a <create+0x11c>
  iunlockput(dp);
    80004ff4:	8526                	mv	a0,s1
    80004ff6:	9d5fe0ef          	jal	800039ca <iunlockput>
  return ip;
    80004ffa:	8ad2                	mv	s5,s4
    80004ffc:	7a02                	ld	s4,32(sp)
    80004ffe:	bf71                	j	80004f9a <create+0x5c>
    iunlockput(dp);
    80005000:	8526                	mv	a0,s1
    80005002:	9c9fe0ef          	jal	800039ca <iunlockput>
    return 0;
    80005006:	8ad2                	mv	s5,s4
    80005008:	7a02                	ld	s4,32(sp)
    8000500a:	bf41                	j	80004f9a <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000500c:	004a2603          	lw	a2,4(s4)
    80005010:	00002597          	auipc	a1,0x2
    80005014:	65058593          	addi	a1,a1,1616 # 80007660 <etext+0x660>
    80005018:	8552                	mv	a0,s4
    8000501a:	de7fe0ef          	jal	80003e00 <dirlink>
    8000501e:	02054e63          	bltz	a0,8000505a <create+0x11c>
    80005022:	40d0                	lw	a2,4(s1)
    80005024:	00002597          	auipc	a1,0x2
    80005028:	64458593          	addi	a1,a1,1604 # 80007668 <etext+0x668>
    8000502c:	8552                	mv	a0,s4
    8000502e:	dd3fe0ef          	jal	80003e00 <dirlink>
    80005032:	02054463          	bltz	a0,8000505a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005036:	004a2603          	lw	a2,4(s4)
    8000503a:	fb040593          	addi	a1,s0,-80
    8000503e:	8526                	mv	a0,s1
    80005040:	dc1fe0ef          	jal	80003e00 <dirlink>
    80005044:	00054b63          	bltz	a0,8000505a <create+0x11c>
    dp->nlink++;  // for ".."
    80005048:	04a4d783          	lhu	a5,74(s1)
    8000504c:	2785                	addiw	a5,a5,1
    8000504e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005052:	8526                	mv	a0,s1
    80005054:	eb8fe0ef          	jal	8000370c <iupdate>
    80005058:	bf71                	j	80004ff4 <create+0xb6>
  ip->nlink = 0;
    8000505a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000505e:	8552                	mv	a0,s4
    80005060:	eacfe0ef          	jal	8000370c <iupdate>
  iunlockput(ip);
    80005064:	8552                	mv	a0,s4
    80005066:	965fe0ef          	jal	800039ca <iunlockput>
  iunlockput(dp);
    8000506a:	8526                	mv	a0,s1
    8000506c:	95ffe0ef          	jal	800039ca <iunlockput>
  return 0;
    80005070:	7a02                	ld	s4,32(sp)
    80005072:	b725                	j	80004f9a <create+0x5c>
    return 0;
    80005074:	8aaa                	mv	s5,a0
    80005076:	b715                	j	80004f9a <create+0x5c>

0000000080005078 <sys_dup>:
{
    80005078:	7179                	addi	sp,sp,-48
    8000507a:	f406                	sd	ra,40(sp)
    8000507c:	f022                	sd	s0,32(sp)
    8000507e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005080:	fd840613          	addi	a2,s0,-40
    80005084:	4581                	li	a1,0
    80005086:	4501                	li	a0,0
    80005088:	e21ff0ef          	jal	80004ea8 <argfd>
    return -1;
    8000508c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000508e:	02054363          	bltz	a0,800050b4 <sys_dup+0x3c>
    80005092:	ec26                	sd	s1,24(sp)
    80005094:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005096:	fd843903          	ld	s2,-40(s0)
    8000509a:	854a                	mv	a0,s2
    8000509c:	e65ff0ef          	jal	80004f00 <fdalloc>
    800050a0:	84aa                	mv	s1,a0
    return -1;
    800050a2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800050a4:	00054d63          	bltz	a0,800050be <sys_dup+0x46>
  filedup(f);
    800050a8:	854a                	mv	a0,s2
    800050aa:	b80ff0ef          	jal	8000442a <filedup>
  return fd;
    800050ae:	87a6                	mv	a5,s1
    800050b0:	64e2                	ld	s1,24(sp)
    800050b2:	6942                	ld	s2,16(sp)
}
    800050b4:	853e                	mv	a0,a5
    800050b6:	70a2                	ld	ra,40(sp)
    800050b8:	7402                	ld	s0,32(sp)
    800050ba:	6145                	addi	sp,sp,48
    800050bc:	8082                	ret
    800050be:	64e2                	ld	s1,24(sp)
    800050c0:	6942                	ld	s2,16(sp)
    800050c2:	bfcd                	j	800050b4 <sys_dup+0x3c>

00000000800050c4 <sys_read>:
{
    800050c4:	7179                	addi	sp,sp,-48
    800050c6:	f406                	sd	ra,40(sp)
    800050c8:	f022                	sd	s0,32(sp)
    800050ca:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800050cc:	fd840593          	addi	a1,s0,-40
    800050d0:	4505                	li	a0,1
    800050d2:	c61fd0ef          	jal	80002d32 <argaddr>
  argint(2, &n);
    800050d6:	fe440593          	addi	a1,s0,-28
    800050da:	4509                	li	a0,2
    800050dc:	c3bfd0ef          	jal	80002d16 <argint>
  if(argfd(0, 0, &f) < 0)
    800050e0:	fe840613          	addi	a2,s0,-24
    800050e4:	4581                	li	a1,0
    800050e6:	4501                	li	a0,0
    800050e8:	dc1ff0ef          	jal	80004ea8 <argfd>
    800050ec:	87aa                	mv	a5,a0
    return -1;
    800050ee:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800050f0:	0007ca63          	bltz	a5,80005104 <sys_read+0x40>
  return fileread(f, p, n);
    800050f4:	fe442603          	lw	a2,-28(s0)
    800050f8:	fd843583          	ld	a1,-40(s0)
    800050fc:	fe843503          	ld	a0,-24(s0)
    80005100:	c90ff0ef          	jal	80004590 <fileread>
}
    80005104:	70a2                	ld	ra,40(sp)
    80005106:	7402                	ld	s0,32(sp)
    80005108:	6145                	addi	sp,sp,48
    8000510a:	8082                	ret

000000008000510c <sys_write>:
{
    8000510c:	7179                	addi	sp,sp,-48
    8000510e:	f406                	sd	ra,40(sp)
    80005110:	f022                	sd	s0,32(sp)
    80005112:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005114:	fd840593          	addi	a1,s0,-40
    80005118:	4505                	li	a0,1
    8000511a:	c19fd0ef          	jal	80002d32 <argaddr>
  argint(2, &n);
    8000511e:	fe440593          	addi	a1,s0,-28
    80005122:	4509                	li	a0,2
    80005124:	bf3fd0ef          	jal	80002d16 <argint>
  if(argfd(0, 0, &f) < 0)
    80005128:	fe840613          	addi	a2,s0,-24
    8000512c:	4581                	li	a1,0
    8000512e:	4501                	li	a0,0
    80005130:	d79ff0ef          	jal	80004ea8 <argfd>
    80005134:	87aa                	mv	a5,a0
    return -1;
    80005136:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005138:	0007ca63          	bltz	a5,8000514c <sys_write+0x40>
  return filewrite(f, p, n);
    8000513c:	fe442603          	lw	a2,-28(s0)
    80005140:	fd843583          	ld	a1,-40(s0)
    80005144:	fe843503          	ld	a0,-24(s0)
    80005148:	d06ff0ef          	jal	8000464e <filewrite>
}
    8000514c:	70a2                	ld	ra,40(sp)
    8000514e:	7402                	ld	s0,32(sp)
    80005150:	6145                	addi	sp,sp,48
    80005152:	8082                	ret

0000000080005154 <sys_close>:
{
    80005154:	1101                	addi	sp,sp,-32
    80005156:	ec06                	sd	ra,24(sp)
    80005158:	e822                	sd	s0,16(sp)
    8000515a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000515c:	fe040613          	addi	a2,s0,-32
    80005160:	fec40593          	addi	a1,s0,-20
    80005164:	4501                	li	a0,0
    80005166:	d43ff0ef          	jal	80004ea8 <argfd>
    return -1;
    8000516a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000516c:	02054063          	bltz	a0,8000518c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005170:	89ffc0ef          	jal	80001a0e <myproc>
    80005174:	fec42783          	lw	a5,-20(s0)
    80005178:	07e9                	addi	a5,a5,26
    8000517a:	078e                	slli	a5,a5,0x3
    8000517c:	953e                	add	a0,a0,a5
    8000517e:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005182:	fe043503          	ld	a0,-32(s0)
    80005186:	aeaff0ef          	jal	80004470 <fileclose>
  return 0;
    8000518a:	4781                	li	a5,0
}
    8000518c:	853e                	mv	a0,a5
    8000518e:	60e2                	ld	ra,24(sp)
    80005190:	6442                	ld	s0,16(sp)
    80005192:	6105                	addi	sp,sp,32
    80005194:	8082                	ret

0000000080005196 <sys_fstat>:
{
    80005196:	1101                	addi	sp,sp,-32
    80005198:	ec06                	sd	ra,24(sp)
    8000519a:	e822                	sd	s0,16(sp)
    8000519c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000519e:	fe040593          	addi	a1,s0,-32
    800051a2:	4505                	li	a0,1
    800051a4:	b8ffd0ef          	jal	80002d32 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800051a8:	fe840613          	addi	a2,s0,-24
    800051ac:	4581                	li	a1,0
    800051ae:	4501                	li	a0,0
    800051b0:	cf9ff0ef          	jal	80004ea8 <argfd>
    800051b4:	87aa                	mv	a5,a0
    return -1;
    800051b6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051b8:	0007c863          	bltz	a5,800051c8 <sys_fstat+0x32>
  return filestat(f, st);
    800051bc:	fe043583          	ld	a1,-32(s0)
    800051c0:	fe843503          	ld	a0,-24(s0)
    800051c4:	b6eff0ef          	jal	80004532 <filestat>
}
    800051c8:	60e2                	ld	ra,24(sp)
    800051ca:	6442                	ld	s0,16(sp)
    800051cc:	6105                	addi	sp,sp,32
    800051ce:	8082                	ret

00000000800051d0 <sys_link>:
{
    800051d0:	7169                	addi	sp,sp,-304
    800051d2:	f606                	sd	ra,296(sp)
    800051d4:	f222                	sd	s0,288(sp)
    800051d6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800051d8:	08000613          	li	a2,128
    800051dc:	ed040593          	addi	a1,s0,-304
    800051e0:	4501                	li	a0,0
    800051e2:	b6dfd0ef          	jal	80002d4e <argstr>
    return -1;
    800051e6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800051e8:	0c054e63          	bltz	a0,800052c4 <sys_link+0xf4>
    800051ec:	08000613          	li	a2,128
    800051f0:	f5040593          	addi	a1,s0,-176
    800051f4:	4505                	li	a0,1
    800051f6:	b59fd0ef          	jal	80002d4e <argstr>
    return -1;
    800051fa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800051fc:	0c054463          	bltz	a0,800052c4 <sys_link+0xf4>
    80005200:	ee26                	sd	s1,280(sp)
  begin_op();
    80005202:	e55fe0ef          	jal	80004056 <begin_op>
  if((ip = namei(old)) == 0){
    80005206:	ed040513          	addi	a0,s0,-304
    8000520a:	c91fe0ef          	jal	80003e9a <namei>
    8000520e:	84aa                	mv	s1,a0
    80005210:	c53d                	beqz	a0,8000527e <sys_link+0xae>
  ilock(ip);
    80005212:	daefe0ef          	jal	800037c0 <ilock>
  if(ip->type == T_DIR){
    80005216:	04449703          	lh	a4,68(s1)
    8000521a:	4785                	li	a5,1
    8000521c:	06f70663          	beq	a4,a5,80005288 <sys_link+0xb8>
    80005220:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005222:	04a4d783          	lhu	a5,74(s1)
    80005226:	2785                	addiw	a5,a5,1
    80005228:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000522c:	8526                	mv	a0,s1
    8000522e:	cdefe0ef          	jal	8000370c <iupdate>
  iunlock(ip);
    80005232:	8526                	mv	a0,s1
    80005234:	e3afe0ef          	jal	8000386e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005238:	fd040593          	addi	a1,s0,-48
    8000523c:	f5040513          	addi	a0,s0,-176
    80005240:	c75fe0ef          	jal	80003eb4 <nameiparent>
    80005244:	892a                	mv	s2,a0
    80005246:	cd21                	beqz	a0,8000529e <sys_link+0xce>
  ilock(dp);
    80005248:	d78fe0ef          	jal	800037c0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000524c:	00092703          	lw	a4,0(s2)
    80005250:	409c                	lw	a5,0(s1)
    80005252:	04f71363          	bne	a4,a5,80005298 <sys_link+0xc8>
    80005256:	40d0                	lw	a2,4(s1)
    80005258:	fd040593          	addi	a1,s0,-48
    8000525c:	854a                	mv	a0,s2
    8000525e:	ba3fe0ef          	jal	80003e00 <dirlink>
    80005262:	02054b63          	bltz	a0,80005298 <sys_link+0xc8>
  iunlockput(dp);
    80005266:	854a                	mv	a0,s2
    80005268:	f62fe0ef          	jal	800039ca <iunlockput>
  iput(ip);
    8000526c:	8526                	mv	a0,s1
    8000526e:	ed4fe0ef          	jal	80003942 <iput>
  end_op();
    80005272:	e4ffe0ef          	jal	800040c0 <end_op>
  return 0;
    80005276:	4781                	li	a5,0
    80005278:	64f2                	ld	s1,280(sp)
    8000527a:	6952                	ld	s2,272(sp)
    8000527c:	a0a1                	j	800052c4 <sys_link+0xf4>
    end_op();
    8000527e:	e43fe0ef          	jal	800040c0 <end_op>
    return -1;
    80005282:	57fd                	li	a5,-1
    80005284:	64f2                	ld	s1,280(sp)
    80005286:	a83d                	j	800052c4 <sys_link+0xf4>
    iunlockput(ip);
    80005288:	8526                	mv	a0,s1
    8000528a:	f40fe0ef          	jal	800039ca <iunlockput>
    end_op();
    8000528e:	e33fe0ef          	jal	800040c0 <end_op>
    return -1;
    80005292:	57fd                	li	a5,-1
    80005294:	64f2                	ld	s1,280(sp)
    80005296:	a03d                	j	800052c4 <sys_link+0xf4>
    iunlockput(dp);
    80005298:	854a                	mv	a0,s2
    8000529a:	f30fe0ef          	jal	800039ca <iunlockput>
  ilock(ip);
    8000529e:	8526                	mv	a0,s1
    800052a0:	d20fe0ef          	jal	800037c0 <ilock>
  ip->nlink--;
    800052a4:	04a4d783          	lhu	a5,74(s1)
    800052a8:	37fd                	addiw	a5,a5,-1
    800052aa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052ae:	8526                	mv	a0,s1
    800052b0:	c5cfe0ef          	jal	8000370c <iupdate>
  iunlockput(ip);
    800052b4:	8526                	mv	a0,s1
    800052b6:	f14fe0ef          	jal	800039ca <iunlockput>
  end_op();
    800052ba:	e07fe0ef          	jal	800040c0 <end_op>
  return -1;
    800052be:	57fd                	li	a5,-1
    800052c0:	64f2                	ld	s1,280(sp)
    800052c2:	6952                	ld	s2,272(sp)
}
    800052c4:	853e                	mv	a0,a5
    800052c6:	70b2                	ld	ra,296(sp)
    800052c8:	7412                	ld	s0,288(sp)
    800052ca:	6155                	addi	sp,sp,304
    800052cc:	8082                	ret

00000000800052ce <sys_unlink>:
{
    800052ce:	7151                	addi	sp,sp,-240
    800052d0:	f586                	sd	ra,232(sp)
    800052d2:	f1a2                	sd	s0,224(sp)
    800052d4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800052d6:	08000613          	li	a2,128
    800052da:	f3040593          	addi	a1,s0,-208
    800052de:	4501                	li	a0,0
    800052e0:	a6ffd0ef          	jal	80002d4e <argstr>
    800052e4:	16054063          	bltz	a0,80005444 <sys_unlink+0x176>
    800052e8:	eda6                	sd	s1,216(sp)
  begin_op();
    800052ea:	d6dfe0ef          	jal	80004056 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800052ee:	fb040593          	addi	a1,s0,-80
    800052f2:	f3040513          	addi	a0,s0,-208
    800052f6:	bbffe0ef          	jal	80003eb4 <nameiparent>
    800052fa:	84aa                	mv	s1,a0
    800052fc:	c945                	beqz	a0,800053ac <sys_unlink+0xde>
  ilock(dp);
    800052fe:	cc2fe0ef          	jal	800037c0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005302:	00002597          	auipc	a1,0x2
    80005306:	35e58593          	addi	a1,a1,862 # 80007660 <etext+0x660>
    8000530a:	fb040513          	addi	a0,s0,-80
    8000530e:	911fe0ef          	jal	80003c1e <namecmp>
    80005312:	10050e63          	beqz	a0,8000542e <sys_unlink+0x160>
    80005316:	00002597          	auipc	a1,0x2
    8000531a:	35258593          	addi	a1,a1,850 # 80007668 <etext+0x668>
    8000531e:	fb040513          	addi	a0,s0,-80
    80005322:	8fdfe0ef          	jal	80003c1e <namecmp>
    80005326:	10050463          	beqz	a0,8000542e <sys_unlink+0x160>
    8000532a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000532c:	f2c40613          	addi	a2,s0,-212
    80005330:	fb040593          	addi	a1,s0,-80
    80005334:	8526                	mv	a0,s1
    80005336:	8fffe0ef          	jal	80003c34 <dirlookup>
    8000533a:	892a                	mv	s2,a0
    8000533c:	0e050863          	beqz	a0,8000542c <sys_unlink+0x15e>
  ilock(ip);
    80005340:	c80fe0ef          	jal	800037c0 <ilock>
  if(ip->nlink < 1)
    80005344:	04a91783          	lh	a5,74(s2)
    80005348:	06f05763          	blez	a5,800053b6 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000534c:	04491703          	lh	a4,68(s2)
    80005350:	4785                	li	a5,1
    80005352:	06f70963          	beq	a4,a5,800053c4 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005356:	4641                	li	a2,16
    80005358:	4581                	li	a1,0
    8000535a:	fc040513          	addi	a0,s0,-64
    8000535e:	96bfb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005362:	4741                	li	a4,16
    80005364:	f2c42683          	lw	a3,-212(s0)
    80005368:	fc040613          	addi	a2,s0,-64
    8000536c:	4581                	li	a1,0
    8000536e:	8526                	mv	a0,s1
    80005370:	fa0fe0ef          	jal	80003b10 <writei>
    80005374:	47c1                	li	a5,16
    80005376:	08f51b63          	bne	a0,a5,8000540c <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000537a:	04491703          	lh	a4,68(s2)
    8000537e:	4785                	li	a5,1
    80005380:	08f70d63          	beq	a4,a5,8000541a <sys_unlink+0x14c>
  iunlockput(dp);
    80005384:	8526                	mv	a0,s1
    80005386:	e44fe0ef          	jal	800039ca <iunlockput>
  ip->nlink--;
    8000538a:	04a95783          	lhu	a5,74(s2)
    8000538e:	37fd                	addiw	a5,a5,-1
    80005390:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005394:	854a                	mv	a0,s2
    80005396:	b76fe0ef          	jal	8000370c <iupdate>
  iunlockput(ip);
    8000539a:	854a                	mv	a0,s2
    8000539c:	e2efe0ef          	jal	800039ca <iunlockput>
  end_op();
    800053a0:	d21fe0ef          	jal	800040c0 <end_op>
  return 0;
    800053a4:	4501                	li	a0,0
    800053a6:	64ee                	ld	s1,216(sp)
    800053a8:	694e                	ld	s2,208(sp)
    800053aa:	a849                	j	8000543c <sys_unlink+0x16e>
    end_op();
    800053ac:	d15fe0ef          	jal	800040c0 <end_op>
    return -1;
    800053b0:	557d                	li	a0,-1
    800053b2:	64ee                	ld	s1,216(sp)
    800053b4:	a061                	j	8000543c <sys_unlink+0x16e>
    800053b6:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800053b8:	00002517          	auipc	a0,0x2
    800053bc:	2b850513          	addi	a0,a0,696 # 80007670 <etext+0x670>
    800053c0:	bd4fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800053c4:	04c92703          	lw	a4,76(s2)
    800053c8:	02000793          	li	a5,32
    800053cc:	f8e7f5e3          	bgeu	a5,a4,80005356 <sys_unlink+0x88>
    800053d0:	e5ce                	sd	s3,200(sp)
    800053d2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800053d6:	4741                	li	a4,16
    800053d8:	86ce                	mv	a3,s3
    800053da:	f1840613          	addi	a2,s0,-232
    800053de:	4581                	li	a1,0
    800053e0:	854a                	mv	a0,s2
    800053e2:	e32fe0ef          	jal	80003a14 <readi>
    800053e6:	47c1                	li	a5,16
    800053e8:	00f51c63          	bne	a0,a5,80005400 <sys_unlink+0x132>
    if(de.inum != 0)
    800053ec:	f1845783          	lhu	a5,-232(s0)
    800053f0:	efa1                	bnez	a5,80005448 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800053f2:	29c1                	addiw	s3,s3,16
    800053f4:	04c92783          	lw	a5,76(s2)
    800053f8:	fcf9efe3          	bltu	s3,a5,800053d6 <sys_unlink+0x108>
    800053fc:	69ae                	ld	s3,200(sp)
    800053fe:	bfa1                	j	80005356 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005400:	00002517          	auipc	a0,0x2
    80005404:	28850513          	addi	a0,a0,648 # 80007688 <etext+0x688>
    80005408:	b8cfb0ef          	jal	80000794 <panic>
    8000540c:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000540e:	00002517          	auipc	a0,0x2
    80005412:	29250513          	addi	a0,a0,658 # 800076a0 <etext+0x6a0>
    80005416:	b7efb0ef          	jal	80000794 <panic>
    dp->nlink--;
    8000541a:	04a4d783          	lhu	a5,74(s1)
    8000541e:	37fd                	addiw	a5,a5,-1
    80005420:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005424:	8526                	mv	a0,s1
    80005426:	ae6fe0ef          	jal	8000370c <iupdate>
    8000542a:	bfa9                	j	80005384 <sys_unlink+0xb6>
    8000542c:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000542e:	8526                	mv	a0,s1
    80005430:	d9afe0ef          	jal	800039ca <iunlockput>
  end_op();
    80005434:	c8dfe0ef          	jal	800040c0 <end_op>
  return -1;
    80005438:	557d                	li	a0,-1
    8000543a:	64ee                	ld	s1,216(sp)
}
    8000543c:	70ae                	ld	ra,232(sp)
    8000543e:	740e                	ld	s0,224(sp)
    80005440:	616d                	addi	sp,sp,240
    80005442:	8082                	ret
    return -1;
    80005444:	557d                	li	a0,-1
    80005446:	bfdd                	j	8000543c <sys_unlink+0x16e>
    iunlockput(ip);
    80005448:	854a                	mv	a0,s2
    8000544a:	d80fe0ef          	jal	800039ca <iunlockput>
    goto bad;
    8000544e:	694e                	ld	s2,208(sp)
    80005450:	69ae                	ld	s3,200(sp)
    80005452:	bff1                	j	8000542e <sys_unlink+0x160>

0000000080005454 <sys_open>:

uint64
sys_open(void)
{
    80005454:	7131                	addi	sp,sp,-192
    80005456:	fd06                	sd	ra,184(sp)
    80005458:	f922                	sd	s0,176(sp)
    8000545a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000545c:	f4c40593          	addi	a1,s0,-180
    80005460:	4505                	li	a0,1
    80005462:	8b5fd0ef          	jal	80002d16 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005466:	08000613          	li	a2,128
    8000546a:	f5040593          	addi	a1,s0,-176
    8000546e:	4501                	li	a0,0
    80005470:	8dffd0ef          	jal	80002d4e <argstr>
    80005474:	87aa                	mv	a5,a0
    return -1;
    80005476:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005478:	0a07c263          	bltz	a5,8000551c <sys_open+0xc8>
    8000547c:	f526                	sd	s1,168(sp)

  begin_op();
    8000547e:	bd9fe0ef          	jal	80004056 <begin_op>

  if(omode & O_CREATE){
    80005482:	f4c42783          	lw	a5,-180(s0)
    80005486:	2007f793          	andi	a5,a5,512
    8000548a:	c3d5                	beqz	a5,8000552e <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000548c:	4681                	li	a3,0
    8000548e:	4601                	li	a2,0
    80005490:	4589                	li	a1,2
    80005492:	f5040513          	addi	a0,s0,-176
    80005496:	aa9ff0ef          	jal	80004f3e <create>
    8000549a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000549c:	c541                	beqz	a0,80005524 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000549e:	04449703          	lh	a4,68(s1)
    800054a2:	478d                	li	a5,3
    800054a4:	00f71763          	bne	a4,a5,800054b2 <sys_open+0x5e>
    800054a8:	0464d703          	lhu	a4,70(s1)
    800054ac:	47a5                	li	a5,9
    800054ae:	0ae7ed63          	bltu	a5,a4,80005568 <sys_open+0x114>
    800054b2:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800054b4:	f19fe0ef          	jal	800043cc <filealloc>
    800054b8:	892a                	mv	s2,a0
    800054ba:	c179                	beqz	a0,80005580 <sys_open+0x12c>
    800054bc:	ed4e                	sd	s3,152(sp)
    800054be:	a43ff0ef          	jal	80004f00 <fdalloc>
    800054c2:	89aa                	mv	s3,a0
    800054c4:	0a054a63          	bltz	a0,80005578 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800054c8:	04449703          	lh	a4,68(s1)
    800054cc:	478d                	li	a5,3
    800054ce:	0cf70263          	beq	a4,a5,80005592 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800054d2:	4789                	li	a5,2
    800054d4:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800054d8:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800054dc:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800054e0:	f4c42783          	lw	a5,-180(s0)
    800054e4:	0017c713          	xori	a4,a5,1
    800054e8:	8b05                	andi	a4,a4,1
    800054ea:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800054ee:	0037f713          	andi	a4,a5,3
    800054f2:	00e03733          	snez	a4,a4
    800054f6:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800054fa:	4007f793          	andi	a5,a5,1024
    800054fe:	c791                	beqz	a5,8000550a <sys_open+0xb6>
    80005500:	04449703          	lh	a4,68(s1)
    80005504:	4789                	li	a5,2
    80005506:	08f70d63          	beq	a4,a5,800055a0 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000550a:	8526                	mv	a0,s1
    8000550c:	b62fe0ef          	jal	8000386e <iunlock>
  end_op();
    80005510:	bb1fe0ef          	jal	800040c0 <end_op>

  return fd;
    80005514:	854e                	mv	a0,s3
    80005516:	74aa                	ld	s1,168(sp)
    80005518:	790a                	ld	s2,160(sp)
    8000551a:	69ea                	ld	s3,152(sp)
}
    8000551c:	70ea                	ld	ra,184(sp)
    8000551e:	744a                	ld	s0,176(sp)
    80005520:	6129                	addi	sp,sp,192
    80005522:	8082                	ret
      end_op();
    80005524:	b9dfe0ef          	jal	800040c0 <end_op>
      return -1;
    80005528:	557d                	li	a0,-1
    8000552a:	74aa                	ld	s1,168(sp)
    8000552c:	bfc5                	j	8000551c <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000552e:	f5040513          	addi	a0,s0,-176
    80005532:	969fe0ef          	jal	80003e9a <namei>
    80005536:	84aa                	mv	s1,a0
    80005538:	c11d                	beqz	a0,8000555e <sys_open+0x10a>
    ilock(ip);
    8000553a:	a86fe0ef          	jal	800037c0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000553e:	04449703          	lh	a4,68(s1)
    80005542:	4785                	li	a5,1
    80005544:	f4f71de3          	bne	a4,a5,8000549e <sys_open+0x4a>
    80005548:	f4c42783          	lw	a5,-180(s0)
    8000554c:	d3bd                	beqz	a5,800054b2 <sys_open+0x5e>
      iunlockput(ip);
    8000554e:	8526                	mv	a0,s1
    80005550:	c7afe0ef          	jal	800039ca <iunlockput>
      end_op();
    80005554:	b6dfe0ef          	jal	800040c0 <end_op>
      return -1;
    80005558:	557d                	li	a0,-1
    8000555a:	74aa                	ld	s1,168(sp)
    8000555c:	b7c1                	j	8000551c <sys_open+0xc8>
      end_op();
    8000555e:	b63fe0ef          	jal	800040c0 <end_op>
      return -1;
    80005562:	557d                	li	a0,-1
    80005564:	74aa                	ld	s1,168(sp)
    80005566:	bf5d                	j	8000551c <sys_open+0xc8>
    iunlockput(ip);
    80005568:	8526                	mv	a0,s1
    8000556a:	c60fe0ef          	jal	800039ca <iunlockput>
    end_op();
    8000556e:	b53fe0ef          	jal	800040c0 <end_op>
    return -1;
    80005572:	557d                	li	a0,-1
    80005574:	74aa                	ld	s1,168(sp)
    80005576:	b75d                	j	8000551c <sys_open+0xc8>
      fileclose(f);
    80005578:	854a                	mv	a0,s2
    8000557a:	ef7fe0ef          	jal	80004470 <fileclose>
    8000557e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005580:	8526                	mv	a0,s1
    80005582:	c48fe0ef          	jal	800039ca <iunlockput>
    end_op();
    80005586:	b3bfe0ef          	jal	800040c0 <end_op>
    return -1;
    8000558a:	557d                	li	a0,-1
    8000558c:	74aa                	ld	s1,168(sp)
    8000558e:	790a                	ld	s2,160(sp)
    80005590:	b771                	j	8000551c <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005592:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005596:	04649783          	lh	a5,70(s1)
    8000559a:	02f91223          	sh	a5,36(s2)
    8000559e:	bf3d                	j	800054dc <sys_open+0x88>
    itrunc(ip);
    800055a0:	8526                	mv	a0,s1
    800055a2:	b0cfe0ef          	jal	800038ae <itrunc>
    800055a6:	b795                	j	8000550a <sys_open+0xb6>

00000000800055a8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800055a8:	7175                	addi	sp,sp,-144
    800055aa:	e506                	sd	ra,136(sp)
    800055ac:	e122                	sd	s0,128(sp)
    800055ae:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800055b0:	aa7fe0ef          	jal	80004056 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800055b4:	08000613          	li	a2,128
    800055b8:	f7040593          	addi	a1,s0,-144
    800055bc:	4501                	li	a0,0
    800055be:	f90fd0ef          	jal	80002d4e <argstr>
    800055c2:	02054363          	bltz	a0,800055e8 <sys_mkdir+0x40>
    800055c6:	4681                	li	a3,0
    800055c8:	4601                	li	a2,0
    800055ca:	4585                	li	a1,1
    800055cc:	f7040513          	addi	a0,s0,-144
    800055d0:	96fff0ef          	jal	80004f3e <create>
    800055d4:	c911                	beqz	a0,800055e8 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800055d6:	bf4fe0ef          	jal	800039ca <iunlockput>
  end_op();
    800055da:	ae7fe0ef          	jal	800040c0 <end_op>
  return 0;
    800055de:	4501                	li	a0,0
}
    800055e0:	60aa                	ld	ra,136(sp)
    800055e2:	640a                	ld	s0,128(sp)
    800055e4:	6149                	addi	sp,sp,144
    800055e6:	8082                	ret
    end_op();
    800055e8:	ad9fe0ef          	jal	800040c0 <end_op>
    return -1;
    800055ec:	557d                	li	a0,-1
    800055ee:	bfcd                	j	800055e0 <sys_mkdir+0x38>

00000000800055f0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800055f0:	7135                	addi	sp,sp,-160
    800055f2:	ed06                	sd	ra,152(sp)
    800055f4:	e922                	sd	s0,144(sp)
    800055f6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800055f8:	a5ffe0ef          	jal	80004056 <begin_op>
  argint(1, &major);
    800055fc:	f6c40593          	addi	a1,s0,-148
    80005600:	4505                	li	a0,1
    80005602:	f14fd0ef          	jal	80002d16 <argint>
  argint(2, &minor);
    80005606:	f6840593          	addi	a1,s0,-152
    8000560a:	4509                	li	a0,2
    8000560c:	f0afd0ef          	jal	80002d16 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005610:	08000613          	li	a2,128
    80005614:	f7040593          	addi	a1,s0,-144
    80005618:	4501                	li	a0,0
    8000561a:	f34fd0ef          	jal	80002d4e <argstr>
    8000561e:	02054563          	bltz	a0,80005648 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005622:	f6841683          	lh	a3,-152(s0)
    80005626:	f6c41603          	lh	a2,-148(s0)
    8000562a:	458d                	li	a1,3
    8000562c:	f7040513          	addi	a0,s0,-144
    80005630:	90fff0ef          	jal	80004f3e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005634:	c911                	beqz	a0,80005648 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005636:	b94fe0ef          	jal	800039ca <iunlockput>
  end_op();
    8000563a:	a87fe0ef          	jal	800040c0 <end_op>
  return 0;
    8000563e:	4501                	li	a0,0
}
    80005640:	60ea                	ld	ra,152(sp)
    80005642:	644a                	ld	s0,144(sp)
    80005644:	610d                	addi	sp,sp,160
    80005646:	8082                	ret
    end_op();
    80005648:	a79fe0ef          	jal	800040c0 <end_op>
    return -1;
    8000564c:	557d                	li	a0,-1
    8000564e:	bfcd                	j	80005640 <sys_mknod+0x50>

0000000080005650 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005650:	7135                	addi	sp,sp,-160
    80005652:	ed06                	sd	ra,152(sp)
    80005654:	e922                	sd	s0,144(sp)
    80005656:	e14a                	sd	s2,128(sp)
    80005658:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000565a:	bb4fc0ef          	jal	80001a0e <myproc>
    8000565e:	892a                	mv	s2,a0
  
  begin_op();
    80005660:	9f7fe0ef          	jal	80004056 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005664:	08000613          	li	a2,128
    80005668:	f6040593          	addi	a1,s0,-160
    8000566c:	4501                	li	a0,0
    8000566e:	ee0fd0ef          	jal	80002d4e <argstr>
    80005672:	04054363          	bltz	a0,800056b8 <sys_chdir+0x68>
    80005676:	e526                	sd	s1,136(sp)
    80005678:	f6040513          	addi	a0,s0,-160
    8000567c:	81ffe0ef          	jal	80003e9a <namei>
    80005680:	84aa                	mv	s1,a0
    80005682:	c915                	beqz	a0,800056b6 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005684:	93cfe0ef          	jal	800037c0 <ilock>
  if(ip->type != T_DIR){
    80005688:	04449703          	lh	a4,68(s1)
    8000568c:	4785                	li	a5,1
    8000568e:	02f71963          	bne	a4,a5,800056c0 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	9dafe0ef          	jal	8000386e <iunlock>
  iput(p->cwd);
    80005698:	15893503          	ld	a0,344(s2)
    8000569c:	aa6fe0ef          	jal	80003942 <iput>
  end_op();
    800056a0:	a21fe0ef          	jal	800040c0 <end_op>
  p->cwd = ip;
    800056a4:	14993c23          	sd	s1,344(s2)
  return 0;
    800056a8:	4501                	li	a0,0
    800056aa:	64aa                	ld	s1,136(sp)
}
    800056ac:	60ea                	ld	ra,152(sp)
    800056ae:	644a                	ld	s0,144(sp)
    800056b0:	690a                	ld	s2,128(sp)
    800056b2:	610d                	addi	sp,sp,160
    800056b4:	8082                	ret
    800056b6:	64aa                	ld	s1,136(sp)
    end_op();
    800056b8:	a09fe0ef          	jal	800040c0 <end_op>
    return -1;
    800056bc:	557d                	li	a0,-1
    800056be:	b7fd                	j	800056ac <sys_chdir+0x5c>
    iunlockput(ip);
    800056c0:	8526                	mv	a0,s1
    800056c2:	b08fe0ef          	jal	800039ca <iunlockput>
    end_op();
    800056c6:	9fbfe0ef          	jal	800040c0 <end_op>
    return -1;
    800056ca:	557d                	li	a0,-1
    800056cc:	64aa                	ld	s1,136(sp)
    800056ce:	bff9                	j	800056ac <sys_chdir+0x5c>

00000000800056d0 <sys_exec>:

uint64
sys_exec(void)
{
    800056d0:	7121                	addi	sp,sp,-448
    800056d2:	ff06                	sd	ra,440(sp)
    800056d4:	fb22                	sd	s0,432(sp)
    800056d6:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800056d8:	e4840593          	addi	a1,s0,-440
    800056dc:	4505                	li	a0,1
    800056de:	e54fd0ef          	jal	80002d32 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800056e2:	08000613          	li	a2,128
    800056e6:	f5040593          	addi	a1,s0,-176
    800056ea:	4501                	li	a0,0
    800056ec:	e62fd0ef          	jal	80002d4e <argstr>
    800056f0:	87aa                	mv	a5,a0
    return -1;
    800056f2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800056f4:	0c07c463          	bltz	a5,800057bc <sys_exec+0xec>
    800056f8:	f726                	sd	s1,424(sp)
    800056fa:	f34a                	sd	s2,416(sp)
    800056fc:	ef4e                	sd	s3,408(sp)
    800056fe:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005700:	10000613          	li	a2,256
    80005704:	4581                	li	a1,0
    80005706:	e5040513          	addi	a0,s0,-432
    8000570a:	dbefb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000570e:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005712:	89a6                	mv	s3,s1
    80005714:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005716:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000571a:	00391513          	slli	a0,s2,0x3
    8000571e:	e4040593          	addi	a1,s0,-448
    80005722:	e4843783          	ld	a5,-440(s0)
    80005726:	953e                	add	a0,a0,a5
    80005728:	d64fd0ef          	jal	80002c8c <fetchaddr>
    8000572c:	02054663          	bltz	a0,80005758 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005730:	e4043783          	ld	a5,-448(s0)
    80005734:	c3a9                	beqz	a5,80005776 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005736:	beefb0ef          	jal	80000b24 <kalloc>
    8000573a:	85aa                	mv	a1,a0
    8000573c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005740:	cd01                	beqz	a0,80005758 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005742:	6605                	lui	a2,0x1
    80005744:	e4043503          	ld	a0,-448(s0)
    80005748:	d8efd0ef          	jal	80002cd6 <fetchstr>
    8000574c:	00054663          	bltz	a0,80005758 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005750:	0905                	addi	s2,s2,1
    80005752:	09a1                	addi	s3,s3,8
    80005754:	fd4913e3          	bne	s2,s4,8000571a <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005758:	f5040913          	addi	s2,s0,-176
    8000575c:	6088                	ld	a0,0(s1)
    8000575e:	c931                	beqz	a0,800057b2 <sys_exec+0xe2>
    kfree(argv[i]);
    80005760:	ae2fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005764:	04a1                	addi	s1,s1,8
    80005766:	ff249be3          	bne	s1,s2,8000575c <sys_exec+0x8c>
  return -1;
    8000576a:	557d                	li	a0,-1
    8000576c:	74ba                	ld	s1,424(sp)
    8000576e:	791a                	ld	s2,416(sp)
    80005770:	69fa                	ld	s3,408(sp)
    80005772:	6a5a                	ld	s4,400(sp)
    80005774:	a0a1                	j	800057bc <sys_exec+0xec>
      argv[i] = 0;
    80005776:	0009079b          	sext.w	a5,s2
    8000577a:	078e                	slli	a5,a5,0x3
    8000577c:	fd078793          	addi	a5,a5,-48
    80005780:	97a2                	add	a5,a5,s0
    80005782:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005786:	e5040593          	addi	a1,s0,-432
    8000578a:	f5040513          	addi	a0,s0,-176
    8000578e:	ae0ff0ef          	jal	80004a6e <exec>
    80005792:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005794:	f5040993          	addi	s3,s0,-176
    80005798:	6088                	ld	a0,0(s1)
    8000579a:	c511                	beqz	a0,800057a6 <sys_exec+0xd6>
    kfree(argv[i]);
    8000579c:	aa6fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057a0:	04a1                	addi	s1,s1,8
    800057a2:	ff349be3          	bne	s1,s3,80005798 <sys_exec+0xc8>
  return ret;
    800057a6:	854a                	mv	a0,s2
    800057a8:	74ba                	ld	s1,424(sp)
    800057aa:	791a                	ld	s2,416(sp)
    800057ac:	69fa                	ld	s3,408(sp)
    800057ae:	6a5a                	ld	s4,400(sp)
    800057b0:	a031                	j	800057bc <sys_exec+0xec>
  return -1;
    800057b2:	557d                	li	a0,-1
    800057b4:	74ba                	ld	s1,424(sp)
    800057b6:	791a                	ld	s2,416(sp)
    800057b8:	69fa                	ld	s3,408(sp)
    800057ba:	6a5a                	ld	s4,400(sp)
}
    800057bc:	70fa                	ld	ra,440(sp)
    800057be:	745a                	ld	s0,432(sp)
    800057c0:	6139                	addi	sp,sp,448
    800057c2:	8082                	ret

00000000800057c4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800057c4:	7139                	addi	sp,sp,-64
    800057c6:	fc06                	sd	ra,56(sp)
    800057c8:	f822                	sd	s0,48(sp)
    800057ca:	f426                	sd	s1,40(sp)
    800057cc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800057ce:	a40fc0ef          	jal	80001a0e <myproc>
    800057d2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800057d4:	fd840593          	addi	a1,s0,-40
    800057d8:	4501                	li	a0,0
    800057da:	d58fd0ef          	jal	80002d32 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800057de:	fc840593          	addi	a1,s0,-56
    800057e2:	fd040513          	addi	a0,s0,-48
    800057e6:	f95fe0ef          	jal	8000477a <pipealloc>
    return -1;
    800057ea:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800057ec:	0a054463          	bltz	a0,80005894 <sys_pipe+0xd0>
  fd0 = -1;
    800057f0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800057f4:	fd043503          	ld	a0,-48(s0)
    800057f8:	f08ff0ef          	jal	80004f00 <fdalloc>
    800057fc:	fca42223          	sw	a0,-60(s0)
    80005800:	08054163          	bltz	a0,80005882 <sys_pipe+0xbe>
    80005804:	fc843503          	ld	a0,-56(s0)
    80005808:	ef8ff0ef          	jal	80004f00 <fdalloc>
    8000580c:	fca42023          	sw	a0,-64(s0)
    80005810:	06054063          	bltz	a0,80005870 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005814:	4691                	li	a3,4
    80005816:	fc440613          	addi	a2,s0,-60
    8000581a:	fd843583          	ld	a1,-40(s0)
    8000581e:	68a8                	ld	a0,80(s1)
    80005820:	e61fb0ef          	jal	80001680 <copyout>
    80005824:	00054e63          	bltz	a0,80005840 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005828:	4691                	li	a3,4
    8000582a:	fc040613          	addi	a2,s0,-64
    8000582e:	fd843583          	ld	a1,-40(s0)
    80005832:	0591                	addi	a1,a1,4
    80005834:	68a8                	ld	a0,80(s1)
    80005836:	e4bfb0ef          	jal	80001680 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000583a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000583c:	04055c63          	bgez	a0,80005894 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005840:	fc442783          	lw	a5,-60(s0)
    80005844:	07e9                	addi	a5,a5,26
    80005846:	078e                	slli	a5,a5,0x3
    80005848:	97a6                	add	a5,a5,s1
    8000584a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000584e:	fc042783          	lw	a5,-64(s0)
    80005852:	07e9                	addi	a5,a5,26
    80005854:	078e                	slli	a5,a5,0x3
    80005856:	94be                	add	s1,s1,a5
    80005858:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000585c:	fd043503          	ld	a0,-48(s0)
    80005860:	c11fe0ef          	jal	80004470 <fileclose>
    fileclose(wf);
    80005864:	fc843503          	ld	a0,-56(s0)
    80005868:	c09fe0ef          	jal	80004470 <fileclose>
    return -1;
    8000586c:	57fd                	li	a5,-1
    8000586e:	a01d                	j	80005894 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005870:	fc442783          	lw	a5,-60(s0)
    80005874:	0007c763          	bltz	a5,80005882 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005878:	07e9                	addi	a5,a5,26
    8000587a:	078e                	slli	a5,a5,0x3
    8000587c:	97a6                	add	a5,a5,s1
    8000587e:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005882:	fd043503          	ld	a0,-48(s0)
    80005886:	bebfe0ef          	jal	80004470 <fileclose>
    fileclose(wf);
    8000588a:	fc843503          	ld	a0,-56(s0)
    8000588e:	be3fe0ef          	jal	80004470 <fileclose>
    return -1;
    80005892:	57fd                	li	a5,-1
}
    80005894:	853e                	mv	a0,a5
    80005896:	70e2                	ld	ra,56(sp)
    80005898:	7442                	ld	s0,48(sp)
    8000589a:	74a2                	ld	s1,40(sp)
    8000589c:	6121                	addi	sp,sp,64
    8000589e:	8082                	ret

00000000800058a0 <kernelvec>:
    800058a0:	7111                	addi	sp,sp,-256
    800058a2:	e006                	sd	ra,0(sp)
    800058a4:	e40a                	sd	sp,8(sp)
    800058a6:	e80e                	sd	gp,16(sp)
    800058a8:	ec12                	sd	tp,24(sp)
    800058aa:	f016                	sd	t0,32(sp)
    800058ac:	f41a                	sd	t1,40(sp)
    800058ae:	f81e                	sd	t2,48(sp)
    800058b0:	e4aa                	sd	a0,72(sp)
    800058b2:	e8ae                	sd	a1,80(sp)
    800058b4:	ecb2                	sd	a2,88(sp)
    800058b6:	f0b6                	sd	a3,96(sp)
    800058b8:	f4ba                	sd	a4,104(sp)
    800058ba:	f8be                	sd	a5,112(sp)
    800058bc:	fcc2                	sd	a6,120(sp)
    800058be:	e146                	sd	a7,128(sp)
    800058c0:	edf2                	sd	t3,216(sp)
    800058c2:	f1f6                	sd	t4,224(sp)
    800058c4:	f5fa                	sd	t5,232(sp)
    800058c6:	f9fe                	sd	t6,240(sp)
    800058c8:	ad4fd0ef          	jal	80002b9c <kerneltrap>
    800058cc:	6082                	ld	ra,0(sp)
    800058ce:	6122                	ld	sp,8(sp)
    800058d0:	61c2                	ld	gp,16(sp)
    800058d2:	7282                	ld	t0,32(sp)
    800058d4:	7322                	ld	t1,40(sp)
    800058d6:	73c2                	ld	t2,48(sp)
    800058d8:	6526                	ld	a0,72(sp)
    800058da:	65c6                	ld	a1,80(sp)
    800058dc:	6666                	ld	a2,88(sp)
    800058de:	7686                	ld	a3,96(sp)
    800058e0:	7726                	ld	a4,104(sp)
    800058e2:	77c6                	ld	a5,112(sp)
    800058e4:	7866                	ld	a6,120(sp)
    800058e6:	688a                	ld	a7,128(sp)
    800058e8:	6e6e                	ld	t3,216(sp)
    800058ea:	7e8e                	ld	t4,224(sp)
    800058ec:	7f2e                	ld	t5,232(sp)
    800058ee:	7fce                	ld	t6,240(sp)
    800058f0:	6111                	addi	sp,sp,256
    800058f2:	10200073          	sret
	...

00000000800058fe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800058fe:	1141                	addi	sp,sp,-16
    80005900:	e422                	sd	s0,8(sp)
    80005902:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005904:	0c0007b7          	lui	a5,0xc000
    80005908:	4705                	li	a4,1
    8000590a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000590c:	0c0007b7          	lui	a5,0xc000
    80005910:	c3d8                	sw	a4,4(a5)
}
    80005912:	6422                	ld	s0,8(sp)
    80005914:	0141                	addi	sp,sp,16
    80005916:	8082                	ret

0000000080005918 <plicinithart>:

void
plicinithart(void)
{
    80005918:	1141                	addi	sp,sp,-16
    8000591a:	e406                	sd	ra,8(sp)
    8000591c:	e022                	sd	s0,0(sp)
    8000591e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005920:	8c2fc0ef          	jal	800019e2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005924:	0085171b          	slliw	a4,a0,0x8
    80005928:	0c0027b7          	lui	a5,0xc002
    8000592c:	97ba                	add	a5,a5,a4
    8000592e:	40200713          	li	a4,1026
    80005932:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005936:	00d5151b          	slliw	a0,a0,0xd
    8000593a:	0c2017b7          	lui	a5,0xc201
    8000593e:	97aa                	add	a5,a5,a0
    80005940:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005944:	60a2                	ld	ra,8(sp)
    80005946:	6402                	ld	s0,0(sp)
    80005948:	0141                	addi	sp,sp,16
    8000594a:	8082                	ret

000000008000594c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000594c:	1141                	addi	sp,sp,-16
    8000594e:	e406                	sd	ra,8(sp)
    80005950:	e022                	sd	s0,0(sp)
    80005952:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005954:	88efc0ef          	jal	800019e2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005958:	00d5151b          	slliw	a0,a0,0xd
    8000595c:	0c2017b7          	lui	a5,0xc201
    80005960:	97aa                	add	a5,a5,a0
  return irq;
}
    80005962:	43c8                	lw	a0,4(a5)
    80005964:	60a2                	ld	ra,8(sp)
    80005966:	6402                	ld	s0,0(sp)
    80005968:	0141                	addi	sp,sp,16
    8000596a:	8082                	ret

000000008000596c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000596c:	1101                	addi	sp,sp,-32
    8000596e:	ec06                	sd	ra,24(sp)
    80005970:	e822                	sd	s0,16(sp)
    80005972:	e426                	sd	s1,8(sp)
    80005974:	1000                	addi	s0,sp,32
    80005976:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005978:	86afc0ef          	jal	800019e2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000597c:	00d5151b          	slliw	a0,a0,0xd
    80005980:	0c2017b7          	lui	a5,0xc201
    80005984:	97aa                	add	a5,a5,a0
    80005986:	c3c4                	sw	s1,4(a5)
}
    80005988:	60e2                	ld	ra,24(sp)
    8000598a:	6442                	ld	s0,16(sp)
    8000598c:	64a2                	ld	s1,8(sp)
    8000598e:	6105                	addi	sp,sp,32
    80005990:	8082                	ret

0000000080005992 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005992:	1141                	addi	sp,sp,-16
    80005994:	e406                	sd	ra,8(sp)
    80005996:	e022                	sd	s0,0(sp)
    80005998:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000599a:	479d                	li	a5,7
    8000599c:	04a7ca63          	blt	a5,a0,800059f0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800059a0:	0001c797          	auipc	a5,0x1c
    800059a4:	bb078793          	addi	a5,a5,-1104 # 80021550 <disk>
    800059a8:	97aa                	add	a5,a5,a0
    800059aa:	0187c783          	lbu	a5,24(a5)
    800059ae:	e7b9                	bnez	a5,800059fc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800059b0:	00451693          	slli	a3,a0,0x4
    800059b4:	0001c797          	auipc	a5,0x1c
    800059b8:	b9c78793          	addi	a5,a5,-1124 # 80021550 <disk>
    800059bc:	6398                	ld	a4,0(a5)
    800059be:	9736                	add	a4,a4,a3
    800059c0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800059c4:	6398                	ld	a4,0(a5)
    800059c6:	9736                	add	a4,a4,a3
    800059c8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800059cc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800059d0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800059d4:	97aa                	add	a5,a5,a0
    800059d6:	4705                	li	a4,1
    800059d8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800059dc:	0001c517          	auipc	a0,0x1c
    800059e0:	b8c50513          	addi	a0,a0,-1140 # 80021568 <disk+0x18>
    800059e4:	e8cfc0ef          	jal	80002070 <wakeup>
}
    800059e8:	60a2                	ld	ra,8(sp)
    800059ea:	6402                	ld	s0,0(sp)
    800059ec:	0141                	addi	sp,sp,16
    800059ee:	8082                	ret
    panic("free_desc 1");
    800059f0:	00002517          	auipc	a0,0x2
    800059f4:	cc050513          	addi	a0,a0,-832 # 800076b0 <etext+0x6b0>
    800059f8:	d9dfa0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800059fc:	00002517          	auipc	a0,0x2
    80005a00:	cc450513          	addi	a0,a0,-828 # 800076c0 <etext+0x6c0>
    80005a04:	d91fa0ef          	jal	80000794 <panic>

0000000080005a08 <virtio_disk_init>:
{
    80005a08:	1101                	addi	sp,sp,-32
    80005a0a:	ec06                	sd	ra,24(sp)
    80005a0c:	e822                	sd	s0,16(sp)
    80005a0e:	e426                	sd	s1,8(sp)
    80005a10:	e04a                	sd	s2,0(sp)
    80005a12:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005a14:	00002597          	auipc	a1,0x2
    80005a18:	cbc58593          	addi	a1,a1,-836 # 800076d0 <etext+0x6d0>
    80005a1c:	0001c517          	auipc	a0,0x1c
    80005a20:	c5c50513          	addi	a0,a0,-932 # 80021678 <disk+0x128>
    80005a24:	950fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005a28:	100017b7          	lui	a5,0x10001
    80005a2c:	4398                	lw	a4,0(a5)
    80005a2e:	2701                	sext.w	a4,a4
    80005a30:	747277b7          	lui	a5,0x74727
    80005a34:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005a38:	18f71063          	bne	a4,a5,80005bb8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005a3c:	100017b7          	lui	a5,0x10001
    80005a40:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005a42:	439c                	lw	a5,0(a5)
    80005a44:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005a46:	4709                	li	a4,2
    80005a48:	16e79863          	bne	a5,a4,80005bb8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005a4c:	100017b7          	lui	a5,0x10001
    80005a50:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005a52:	439c                	lw	a5,0(a5)
    80005a54:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005a56:	16e79163          	bne	a5,a4,80005bb8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005a5a:	100017b7          	lui	a5,0x10001
    80005a5e:	47d8                	lw	a4,12(a5)
    80005a60:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005a62:	554d47b7          	lui	a5,0x554d4
    80005a66:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005a6a:	14f71763          	bne	a4,a5,80005bb8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a6e:	100017b7          	lui	a5,0x10001
    80005a72:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a76:	4705                	li	a4,1
    80005a78:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a7a:	470d                	li	a4,3
    80005a7c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005a7e:	10001737          	lui	a4,0x10001
    80005a82:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005a84:	c7ffe737          	lui	a4,0xc7ffe
    80005a88:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd0cf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005a8c:	8ef9                	and	a3,a3,a4
    80005a8e:	10001737          	lui	a4,0x10001
    80005a92:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a94:	472d                	li	a4,11
    80005a96:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a98:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005a9c:	439c                	lw	a5,0(a5)
    80005a9e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005aa2:	8ba1                	andi	a5,a5,8
    80005aa4:	12078063          	beqz	a5,80005bc4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005aa8:	100017b7          	lui	a5,0x10001
    80005aac:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005ab0:	100017b7          	lui	a5,0x10001
    80005ab4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005ab8:	439c                	lw	a5,0(a5)
    80005aba:	2781                	sext.w	a5,a5
    80005abc:	10079a63          	bnez	a5,80005bd0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ac0:	100017b7          	lui	a5,0x10001
    80005ac4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005ac8:	439c                	lw	a5,0(a5)
    80005aca:	2781                	sext.w	a5,a5
  if(max == 0)
    80005acc:	10078863          	beqz	a5,80005bdc <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005ad0:	471d                	li	a4,7
    80005ad2:	10f77b63          	bgeu	a4,a5,80005be8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005ad6:	84efb0ef          	jal	80000b24 <kalloc>
    80005ada:	0001c497          	auipc	s1,0x1c
    80005ade:	a7648493          	addi	s1,s1,-1418 # 80021550 <disk>
    80005ae2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ae4:	840fb0ef          	jal	80000b24 <kalloc>
    80005ae8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005aea:	83afb0ef          	jal	80000b24 <kalloc>
    80005aee:	87aa                	mv	a5,a0
    80005af0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005af2:	6088                	ld	a0,0(s1)
    80005af4:	10050063          	beqz	a0,80005bf4 <virtio_disk_init+0x1ec>
    80005af8:	0001c717          	auipc	a4,0x1c
    80005afc:	a6073703          	ld	a4,-1440(a4) # 80021558 <disk+0x8>
    80005b00:	0e070a63          	beqz	a4,80005bf4 <virtio_disk_init+0x1ec>
    80005b04:	0e078863          	beqz	a5,80005bf4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005b08:	6605                	lui	a2,0x1
    80005b0a:	4581                	li	a1,0
    80005b0c:	9bcfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005b10:	0001c497          	auipc	s1,0x1c
    80005b14:	a4048493          	addi	s1,s1,-1472 # 80021550 <disk>
    80005b18:	6605                	lui	a2,0x1
    80005b1a:	4581                	li	a1,0
    80005b1c:	6488                	ld	a0,8(s1)
    80005b1e:	9aafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005b22:	6605                	lui	a2,0x1
    80005b24:	4581                	li	a1,0
    80005b26:	6888                	ld	a0,16(s1)
    80005b28:	9a0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005b2c:	100017b7          	lui	a5,0x10001
    80005b30:	4721                	li	a4,8
    80005b32:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005b34:	4098                	lw	a4,0(s1)
    80005b36:	100017b7          	lui	a5,0x10001
    80005b3a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005b3e:	40d8                	lw	a4,4(s1)
    80005b40:	100017b7          	lui	a5,0x10001
    80005b44:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005b48:	649c                	ld	a5,8(s1)
    80005b4a:	0007869b          	sext.w	a3,a5
    80005b4e:	10001737          	lui	a4,0x10001
    80005b52:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005b56:	9781                	srai	a5,a5,0x20
    80005b58:	10001737          	lui	a4,0x10001
    80005b5c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005b60:	689c                	ld	a5,16(s1)
    80005b62:	0007869b          	sext.w	a3,a5
    80005b66:	10001737          	lui	a4,0x10001
    80005b6a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005b6e:	9781                	srai	a5,a5,0x20
    80005b70:	10001737          	lui	a4,0x10001
    80005b74:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005b78:	10001737          	lui	a4,0x10001
    80005b7c:	4785                	li	a5,1
    80005b7e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005b80:	00f48c23          	sb	a5,24(s1)
    80005b84:	00f48ca3          	sb	a5,25(s1)
    80005b88:	00f48d23          	sb	a5,26(s1)
    80005b8c:	00f48da3          	sb	a5,27(s1)
    80005b90:	00f48e23          	sb	a5,28(s1)
    80005b94:	00f48ea3          	sb	a5,29(s1)
    80005b98:	00f48f23          	sb	a5,30(s1)
    80005b9c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ba0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ba4:	100017b7          	lui	a5,0x10001
    80005ba8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005bac:	60e2                	ld	ra,24(sp)
    80005bae:	6442                	ld	s0,16(sp)
    80005bb0:	64a2                	ld	s1,8(sp)
    80005bb2:	6902                	ld	s2,0(sp)
    80005bb4:	6105                	addi	sp,sp,32
    80005bb6:	8082                	ret
    panic("could not find virtio disk");
    80005bb8:	00002517          	auipc	a0,0x2
    80005bbc:	b2850513          	addi	a0,a0,-1240 # 800076e0 <etext+0x6e0>
    80005bc0:	bd5fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005bc4:	00002517          	auipc	a0,0x2
    80005bc8:	b3c50513          	addi	a0,a0,-1220 # 80007700 <etext+0x700>
    80005bcc:	bc9fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005bd0:	00002517          	auipc	a0,0x2
    80005bd4:	b5050513          	addi	a0,a0,-1200 # 80007720 <etext+0x720>
    80005bd8:	bbdfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    80005bdc:	00002517          	auipc	a0,0x2
    80005be0:	b6450513          	addi	a0,a0,-1180 # 80007740 <etext+0x740>
    80005be4:	bb1fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005be8:	00002517          	auipc	a0,0x2
    80005bec:	b7850513          	addi	a0,a0,-1160 # 80007760 <etext+0x760>
    80005bf0:	ba5fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005bf4:	00002517          	auipc	a0,0x2
    80005bf8:	b8c50513          	addi	a0,a0,-1140 # 80007780 <etext+0x780>
    80005bfc:	b99fa0ef          	jal	80000794 <panic>

0000000080005c00 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005c00:	7159                	addi	sp,sp,-112
    80005c02:	f486                	sd	ra,104(sp)
    80005c04:	f0a2                	sd	s0,96(sp)
    80005c06:	eca6                	sd	s1,88(sp)
    80005c08:	e8ca                	sd	s2,80(sp)
    80005c0a:	e4ce                	sd	s3,72(sp)
    80005c0c:	e0d2                	sd	s4,64(sp)
    80005c0e:	fc56                	sd	s5,56(sp)
    80005c10:	f85a                	sd	s6,48(sp)
    80005c12:	f45e                	sd	s7,40(sp)
    80005c14:	f062                	sd	s8,32(sp)
    80005c16:	ec66                	sd	s9,24(sp)
    80005c18:	1880                	addi	s0,sp,112
    80005c1a:	8a2a                	mv	s4,a0
    80005c1c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005c1e:	00c52c83          	lw	s9,12(a0)
    80005c22:	001c9c9b          	slliw	s9,s9,0x1
    80005c26:	1c82                	slli	s9,s9,0x20
    80005c28:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005c2c:	0001c517          	auipc	a0,0x1c
    80005c30:	a4c50513          	addi	a0,a0,-1460 # 80021678 <disk+0x128>
    80005c34:	fc1fa0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005c38:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005c3a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005c3c:	0001cb17          	auipc	s6,0x1c
    80005c40:	914b0b13          	addi	s6,s6,-1772 # 80021550 <disk>
  for(int i = 0; i < 3; i++){
    80005c44:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005c46:	0001cc17          	auipc	s8,0x1c
    80005c4a:	a32c0c13          	addi	s8,s8,-1486 # 80021678 <disk+0x128>
    80005c4e:	a8b9                	j	80005cac <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005c50:	00fb0733          	add	a4,s6,a5
    80005c54:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005c58:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005c5a:	0207c563          	bltz	a5,80005c84 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005c5e:	2905                	addiw	s2,s2,1
    80005c60:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005c62:	05590963          	beq	s2,s5,80005cb4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005c66:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005c68:	0001c717          	auipc	a4,0x1c
    80005c6c:	8e870713          	addi	a4,a4,-1816 # 80021550 <disk>
    80005c70:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005c72:	01874683          	lbu	a3,24(a4)
    80005c76:	fee9                	bnez	a3,80005c50 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005c78:	2785                	addiw	a5,a5,1
    80005c7a:	0705                	addi	a4,a4,1
    80005c7c:	fe979be3          	bne	a5,s1,80005c72 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005c80:	57fd                	li	a5,-1
    80005c82:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005c84:	01205d63          	blez	s2,80005c9e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005c88:	f9042503          	lw	a0,-112(s0)
    80005c8c:	d07ff0ef          	jal	80005992 <free_desc>
      for(int j = 0; j < i; j++)
    80005c90:	4785                	li	a5,1
    80005c92:	0127d663          	bge	a5,s2,80005c9e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005c96:	f9442503          	lw	a0,-108(s0)
    80005c9a:	cf9ff0ef          	jal	80005992 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005c9e:	85e2                	mv	a1,s8
    80005ca0:	0001c517          	auipc	a0,0x1c
    80005ca4:	8c850513          	addi	a0,a0,-1848 # 80021568 <disk+0x18>
    80005ca8:	b7cfc0ef          	jal	80002024 <sleep>
  for(int i = 0; i < 3; i++){
    80005cac:	f9040613          	addi	a2,s0,-112
    80005cb0:	894e                	mv	s2,s3
    80005cb2:	bf55                	j	80005c66 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005cb4:	f9042503          	lw	a0,-112(s0)
    80005cb8:	00451693          	slli	a3,a0,0x4

  if(write)
    80005cbc:	0001c797          	auipc	a5,0x1c
    80005cc0:	89478793          	addi	a5,a5,-1900 # 80021550 <disk>
    80005cc4:	00a50713          	addi	a4,a0,10
    80005cc8:	0712                	slli	a4,a4,0x4
    80005cca:	973e                	add	a4,a4,a5
    80005ccc:	01703633          	snez	a2,s7
    80005cd0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005cd2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005cd6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005cda:	6398                	ld	a4,0(a5)
    80005cdc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005cde:	0a868613          	addi	a2,a3,168
    80005ce2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ce4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ce6:	6390                	ld	a2,0(a5)
    80005ce8:	00d605b3          	add	a1,a2,a3
    80005cec:	4741                	li	a4,16
    80005cee:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005cf0:	4805                	li	a6,1
    80005cf2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005cf6:	f9442703          	lw	a4,-108(s0)
    80005cfa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005cfe:	0712                	slli	a4,a4,0x4
    80005d00:	963a                	add	a2,a2,a4
    80005d02:	058a0593          	addi	a1,s4,88
    80005d06:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005d08:	0007b883          	ld	a7,0(a5)
    80005d0c:	9746                	add	a4,a4,a7
    80005d0e:	40000613          	li	a2,1024
    80005d12:	c710                	sw	a2,8(a4)
  if(write)
    80005d14:	001bb613          	seqz	a2,s7
    80005d18:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005d1c:	00166613          	ori	a2,a2,1
    80005d20:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005d24:	f9842583          	lw	a1,-104(s0)
    80005d28:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005d2c:	00250613          	addi	a2,a0,2
    80005d30:	0612                	slli	a2,a2,0x4
    80005d32:	963e                	add	a2,a2,a5
    80005d34:	577d                	li	a4,-1
    80005d36:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005d3a:	0592                	slli	a1,a1,0x4
    80005d3c:	98ae                	add	a7,a7,a1
    80005d3e:	03068713          	addi	a4,a3,48
    80005d42:	973e                	add	a4,a4,a5
    80005d44:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005d48:	6398                	ld	a4,0(a5)
    80005d4a:	972e                	add	a4,a4,a1
    80005d4c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005d50:	4689                	li	a3,2
    80005d52:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005d56:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005d5a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005d5e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005d62:	6794                	ld	a3,8(a5)
    80005d64:	0026d703          	lhu	a4,2(a3)
    80005d68:	8b1d                	andi	a4,a4,7
    80005d6a:	0706                	slli	a4,a4,0x1
    80005d6c:	96ba                	add	a3,a3,a4
    80005d6e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005d72:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005d76:	6798                	ld	a4,8(a5)
    80005d78:	00275783          	lhu	a5,2(a4)
    80005d7c:	2785                	addiw	a5,a5,1
    80005d7e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005d82:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005d86:	100017b7          	lui	a5,0x10001
    80005d8a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005d8e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005d92:	0001c917          	auipc	s2,0x1c
    80005d96:	8e690913          	addi	s2,s2,-1818 # 80021678 <disk+0x128>
  while(b->disk == 1) {
    80005d9a:	4485                	li	s1,1
    80005d9c:	01079a63          	bne	a5,a6,80005db0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005da0:	85ca                	mv	a1,s2
    80005da2:	8552                	mv	a0,s4
    80005da4:	a80fc0ef          	jal	80002024 <sleep>
  while(b->disk == 1) {
    80005da8:	004a2783          	lw	a5,4(s4)
    80005dac:	fe978ae3          	beq	a5,s1,80005da0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005db0:	f9042903          	lw	s2,-112(s0)
    80005db4:	00290713          	addi	a4,s2,2
    80005db8:	0712                	slli	a4,a4,0x4
    80005dba:	0001b797          	auipc	a5,0x1b
    80005dbe:	79678793          	addi	a5,a5,1942 # 80021550 <disk>
    80005dc2:	97ba                	add	a5,a5,a4
    80005dc4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005dc8:	0001b997          	auipc	s3,0x1b
    80005dcc:	78898993          	addi	s3,s3,1928 # 80021550 <disk>
    80005dd0:	00491713          	slli	a4,s2,0x4
    80005dd4:	0009b783          	ld	a5,0(s3)
    80005dd8:	97ba                	add	a5,a5,a4
    80005dda:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005dde:	854a                	mv	a0,s2
    80005de0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005de4:	bafff0ef          	jal	80005992 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005de8:	8885                	andi	s1,s1,1
    80005dea:	f0fd                	bnez	s1,80005dd0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005dec:	0001c517          	auipc	a0,0x1c
    80005df0:	88c50513          	addi	a0,a0,-1908 # 80021678 <disk+0x128>
    80005df4:	e99fa0ef          	jal	80000c8c <release>
}
    80005df8:	70a6                	ld	ra,104(sp)
    80005dfa:	7406                	ld	s0,96(sp)
    80005dfc:	64e6                	ld	s1,88(sp)
    80005dfe:	6946                	ld	s2,80(sp)
    80005e00:	69a6                	ld	s3,72(sp)
    80005e02:	6a06                	ld	s4,64(sp)
    80005e04:	7ae2                	ld	s5,56(sp)
    80005e06:	7b42                	ld	s6,48(sp)
    80005e08:	7ba2                	ld	s7,40(sp)
    80005e0a:	7c02                	ld	s8,32(sp)
    80005e0c:	6ce2                	ld	s9,24(sp)
    80005e0e:	6165                	addi	sp,sp,112
    80005e10:	8082                	ret

0000000080005e12 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005e12:	1101                	addi	sp,sp,-32
    80005e14:	ec06                	sd	ra,24(sp)
    80005e16:	e822                	sd	s0,16(sp)
    80005e18:	e426                	sd	s1,8(sp)
    80005e1a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005e1c:	0001b497          	auipc	s1,0x1b
    80005e20:	73448493          	addi	s1,s1,1844 # 80021550 <disk>
    80005e24:	0001c517          	auipc	a0,0x1c
    80005e28:	85450513          	addi	a0,a0,-1964 # 80021678 <disk+0x128>
    80005e2c:	dc9fa0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005e30:	100017b7          	lui	a5,0x10001
    80005e34:	53b8                	lw	a4,96(a5)
    80005e36:	8b0d                	andi	a4,a4,3
    80005e38:	100017b7          	lui	a5,0x10001
    80005e3c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005e3e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005e42:	689c                	ld	a5,16(s1)
    80005e44:	0204d703          	lhu	a4,32(s1)
    80005e48:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005e4c:	04f70663          	beq	a4,a5,80005e98 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005e50:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005e54:	6898                	ld	a4,16(s1)
    80005e56:	0204d783          	lhu	a5,32(s1)
    80005e5a:	8b9d                	andi	a5,a5,7
    80005e5c:	078e                	slli	a5,a5,0x3
    80005e5e:	97ba                	add	a5,a5,a4
    80005e60:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005e62:	00278713          	addi	a4,a5,2
    80005e66:	0712                	slli	a4,a4,0x4
    80005e68:	9726                	add	a4,a4,s1
    80005e6a:	01074703          	lbu	a4,16(a4)
    80005e6e:	e321                	bnez	a4,80005eae <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005e70:	0789                	addi	a5,a5,2
    80005e72:	0792                	slli	a5,a5,0x4
    80005e74:	97a6                	add	a5,a5,s1
    80005e76:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005e78:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005e7c:	9f4fc0ef          	jal	80002070 <wakeup>

    disk.used_idx += 1;
    80005e80:	0204d783          	lhu	a5,32(s1)
    80005e84:	2785                	addiw	a5,a5,1
    80005e86:	17c2                	slli	a5,a5,0x30
    80005e88:	93c1                	srli	a5,a5,0x30
    80005e8a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005e8e:	6898                	ld	a4,16(s1)
    80005e90:	00275703          	lhu	a4,2(a4)
    80005e94:	faf71ee3          	bne	a4,a5,80005e50 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005e98:	0001b517          	auipc	a0,0x1b
    80005e9c:	7e050513          	addi	a0,a0,2016 # 80021678 <disk+0x128>
    80005ea0:	dedfa0ef          	jal	80000c8c <release>
}
    80005ea4:	60e2                	ld	ra,24(sp)
    80005ea6:	6442                	ld	s0,16(sp)
    80005ea8:	64a2                	ld	s1,8(sp)
    80005eaa:	6105                	addi	sp,sp,32
    80005eac:	8082                	ret
      panic("virtio_disk_intr status");
    80005eae:	00002517          	auipc	a0,0x2
    80005eb2:	8ea50513          	addi	a0,a0,-1814 # 80007798 <etext+0x798>
    80005eb6:	8dffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051573          	csrrw	a0,sscratch,a0
    80006004:	02153423          	sd	ra,40(a0)
    80006008:	02253823          	sd	sp,48(a0)
    8000600c:	02353c23          	sd	gp,56(a0)
    80006010:	04453023          	sd	tp,64(a0)
    80006014:	04553423          	sd	t0,72(a0)
    80006018:	04653823          	sd	t1,80(a0)
    8000601c:	04753c23          	sd	t2,88(a0)
    80006020:	f120                	sd	s0,96(a0)
    80006022:	f524                	sd	s1,104(a0)
    80006024:	fd2c                	sd	a1,120(a0)
    80006026:	e150                	sd	a2,128(a0)
    80006028:	e554                	sd	a3,136(a0)
    8000602a:	e958                	sd	a4,144(a0)
    8000602c:	ed5c                	sd	a5,152(a0)
    8000602e:	0b053023          	sd	a6,160(a0)
    80006032:	0b153423          	sd	a7,168(a0)
    80006036:	0b253823          	sd	s2,176(a0)
    8000603a:	0b353c23          	sd	s3,184(a0)
    8000603e:	0d453023          	sd	s4,192(a0)
    80006042:	0d553423          	sd	s5,200(a0)
    80006046:	0d653823          	sd	s6,208(a0)
    8000604a:	0d753c23          	sd	s7,216(a0)
    8000604e:	0f853023          	sd	s8,224(a0)
    80006052:	0f953423          	sd	s9,232(a0)
    80006056:	0fa53823          	sd	s10,240(a0)
    8000605a:	0fb53c23          	sd	s11,248(a0)
    8000605e:	11c53023          	sd	t3,256(a0)
    80006062:	11d53423          	sd	t4,264(a0)
    80006066:	11e53823          	sd	t5,272(a0)
    8000606a:	11f53c23          	sd	t6,280(a0)
    8000606e:	140022f3          	csrr	t0,sscratch
    80006072:	06553823          	sd	t0,112(a0)
    80006076:	00853103          	ld	sp,8(a0)
    8000607a:	02053203          	ld	tp,32(a0)
    8000607e:	01053283          	ld	t0,16(a0)
    80006082:	00053303          	ld	t1,0(a0)
    80006086:	12000073          	sfence.vma
    8000608a:	18031073          	csrw	satp,t1
    8000608e:	12000073          	sfence.vma
    80006092:	8282                	jr	t0

0000000080006094 <userret>:
    80006094:	12000073          	sfence.vma
    80006098:	18051073          	csrw	satp,a0
    8000609c:	12000073          	sfence.vma
    800060a0:	852e                	mv	a0,a1
    800060a2:	02853083          	ld	ra,40(a0)
    800060a6:	03053103          	ld	sp,48(a0)
    800060aa:	03853183          	ld	gp,56(a0)
    800060ae:	04053203          	ld	tp,64(a0)
    800060b2:	04853283          	ld	t0,72(a0)
    800060b6:	05053303          	ld	t1,80(a0)
    800060ba:	05853383          	ld	t2,88(a0)
    800060be:	7120                	ld	s0,96(a0)
    800060c0:	7524                	ld	s1,104(a0)
    800060c2:	7d2c                	ld	a1,120(a0)
    800060c4:	6150                	ld	a2,128(a0)
    800060c6:	6554                	ld	a3,136(a0)
    800060c8:	6958                	ld	a4,144(a0)
    800060ca:	6d5c                	ld	a5,152(a0)
    800060cc:	0a053803          	ld	a6,160(a0)
    800060d0:	0a853883          	ld	a7,168(a0)
    800060d4:	0b053903          	ld	s2,176(a0)
    800060d8:	0b853983          	ld	s3,184(a0)
    800060dc:	0c053a03          	ld	s4,192(a0)
    800060e0:	0c853a83          	ld	s5,200(a0)
    800060e4:	0d053b03          	ld	s6,208(a0)
    800060e8:	0d853b83          	ld	s7,216(a0)
    800060ec:	0e053c03          	ld	s8,224(a0)
    800060f0:	0e853c83          	ld	s9,232(a0)
    800060f4:	0f053d03          	ld	s10,240(a0)
    800060f8:	0f853d83          	ld	s11,248(a0)
    800060fc:	10053e03          	ld	t3,256(a0)
    80006100:	10853e83          	ld	t4,264(a0)
    80006104:	11053f03          	ld	t5,272(a0)
    80006108:	11853f83          	ld	t6,280(a0)
    8000610c:	7928                	ld	a0,112(a0)
    8000610e:	10200073          	sret
	...
