
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	94010113          	addi	sp,sp,-1728 # 80007940 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd78f>
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
    800000fa:	3d2020ef          	jal	800024cc <either_copyin>
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
    80000154:	0000f517          	auipc	a0,0xf
    80000158:	7ec50513          	addi	a0,a0,2028 # 8000f940 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	0000f497          	auipc	s1,0xf
    80000164:	7e048493          	addi	s1,s1,2016 # 8000f940 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	87090913          	addi	s2,s2,-1936 # 8000f9d8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	1da020ef          	jal	8000235e <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	799010ef          	jal	80002126 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	7a070713          	addi	a4,a4,1952 # 8000f940 <cons>
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
    800001d2:	2b0020ef          	jal	80002482 <either_copyout>
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
    800001ee:	75650513          	addi	a0,a0,1878 # 8000f940 <cons>
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
    80000218:	7cf72223          	sw	a5,1988(a4) # 8000f9d8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	71650513          	addi	a0,a0,1814 # 8000f940 <cons>
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
    80000282:	6c250513          	addi	a0,a0,1730 # 8000f940 <cons>
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
    800002a0:	276020ef          	jal	80002516 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	69c50513          	addi	a0,a0,1692 # 8000f940 <cons>
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
    800002c6:	67e70713          	addi	a4,a4,1662 # 8000f940 <cons>
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
    800002ec:	65878793          	addi	a5,a5,1624 # 8000f940 <cons>
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
    8000031a:	6c27a783          	lw	a5,1730(a5) # 8000f9d8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	61470713          	addi	a4,a4,1556 # 8000f940 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	60448493          	addi	s1,s1,1540 # 8000f940 <cons>
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
    80000382:	5c270713          	addi	a4,a4,1474 # 8000f940 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	64f72623          	sw	a5,1612(a4) # 8000f9e0 <cons+0xa0>
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
    800003b6:	58e78793          	addi	a5,a5,1422 # 8000f940 <cons>
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
    800003da:	60c7a323          	sw	a2,1542(a5) # 8000f9dc <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	5fa50513          	addi	a0,a0,1530 # 8000f9d8 <cons+0x98>
    800003e6:	58d010ef          	jal	80002172 <wakeup>
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
    80000400:	54450513          	addi	a0,a0,1348 # 8000f940 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	acc78793          	addi	a5,a5,-1332 # 8001fed8 <devsw>
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
    8000044a:	32a60613          	addi	a2,a2,810 # 80007770 <digits>
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
    800004e4:	5207a783          	lw	a5,1312(a5) # 8000fa00 <pr+0x18>
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
    80000530:	4bc50513          	addi	a0,a0,1212 # 8000f9e8 <pr>
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
    800006f0:	084b8b93          	addi	s7,s7,132 # 80007770 <digits>
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
    8000078a:	26250513          	addi	a0,a0,610 # 8000f9e8 <pr>
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
    800007a4:	2607a023          	sw	zero,608(a5) # 8000fa00 <pr+0x18>
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
    800007c8:	12f72e23          	sw	a5,316(a4) # 80007900 <panicked>
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
    800007dc:	21048493          	addi	s1,s1,528 # 8000f9e8 <pr>
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
    80000844:	1c850513          	addi	a0,a0,456 # 8000fa08 <uart_tx_lock>
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
    80000868:	09c7a783          	lw	a5,156(a5) # 80007900 <panicked>
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
    8000089e:	06e7b783          	ld	a5,110(a5) # 80007908 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	06e73703          	ld	a4,110(a4) # 80007910 <uart_tx_w>
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
    800008cc:	140a8a93          	addi	s5,s5,320 # 8000fa08 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	03848493          	addi	s1,s1,56 # 80007908 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	03498993          	addi	s3,s3,52 # 80007910 <uart_tx_w>
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
    800008fe:	075010ef          	jal	80002172 <wakeup>
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
    80000950:	0bc50513          	addi	a0,a0,188 # 8000fa08 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	fa87a783          	lw	a5,-88(a5) # 80007900 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	fae73703          	ld	a4,-82(a4) # 80007910 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	f9e7b783          	ld	a5,-98(a5) # 80007908 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	09298993          	addi	s3,s3,146 # 8000fa08 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	f8a48493          	addi	s1,s1,-118 # 80007908 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	f8a90913          	addi	s2,s2,-118 # 80007910 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	790010ef          	jal	80002126 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	06048493          	addi	s1,s1,96 # 8000fa08 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f4e7ba23          	sd	a4,-172(a5) # 80007910 <uart_tx_w>
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
    80000a24:	fe848493          	addi	s1,s1,-24 # 8000fa08 <uart_tx_lock>
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
    80000a56:	00020797          	auipc	a5,0x20
    80000a5a:	61a78793          	addi	a5,a5,1562 # 80021070 <end>
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
    80000a76:	fce90913          	addi	s2,s2,-50 # 8000fa40 <kmem>
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
    80000b04:	f4050513          	addi	a0,a0,-192 # 8000fa40 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	56050513          	addi	a0,a0,1376 # 80021070 <end>
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
    80000b32:	f1248493          	addi	s1,s1,-238 # 8000fa40 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	efe50513          	addi	a0,a0,-258 # 8000fa40 <kmem>
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
    80000b6a:	eda50513          	addi	a0,a0,-294 # 8000fa40 <kmem>
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
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
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
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
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
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
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
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
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
    80000c40:	485000ef          	jal	800018c4 <mycpu>
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
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffddf91>
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
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	aaa70713          	addi	a4,a4,-1366 # 80007918 <started>
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
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	7b0010ef          	jal	80002648 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	78c040ef          	jal	80005628 <plicinithart>
  }

  scheduler();        
    80000ea0:	6a7000ef          	jal	80001d46 <scheduler>
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
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	744010ef          	jal	80002624 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	764010ef          	jal	80002648 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	726040ef          	jal	8000560e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	73c040ef          	jal	80005628 <plicinithart>
    binit();         // buffer cache
    80000ef0:	6e5010ef          	jal	80002dd4 <binit>
    iinit();         // inode table
    80000ef4:	4d6020ef          	jal	800033ca <iinit>
    fileinit();      // file table
    80000ef8:	282030ef          	jal	8000417a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	01d040ef          	jal	80005718 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	463000ef          	jal	80001b62 <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	a0f72723          	sw	a5,-1522(a4) # 80007918 <started>
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
    80000f22:	a027b783          	ld	a5,-1534(a5) # 80007920 <kernel_pagetable>
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
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffddf87>
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

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
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
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00006797          	auipc	a5,0x6
    800011ae:	76a7bb23          	sd	a0,1910(a5) # 80007920 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
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
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	0000e497          	auipc	s1,0xe
    80001780:	71448493          	addi	s1,s1,1812 # 8000fe90 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	00a36937          	lui	s2,0xa36
    8000178a:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    8000178e:	0932                	slli	s2,s2,0xc
    80001790:	46d90913          	addi	s2,s2,1133
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	df590913          	addi	s2,s2,-523
    8000179a:	093a                	slli	s2,s2,0xe
    8000179c:	6cf90913          	addi	s2,s2,1743
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00014a97          	auipc	s5,0x14
    800017ac:	4e8a8a93          	addi	s5,s5,1256 # 80015c90 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	858d                	srai	a1,a1,0x3
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	17848493          	addi	s1,s1,376
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	0000e517          	auipc	a0,0xe
    8000181e:	24650513          	addi	a0,a0,582 # 8000fa60 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	0000e517          	auipc	a0,0xe
    80001832:	24a50513          	addi	a0,a0,586 # 8000fa78 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	0000e497          	auipc	s1,0xe
    8000183e:	65648493          	addi	s1,s1,1622 # 8000fe90 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	00a36937          	lui	s2,0xa36
    80001850:	77d90913          	addi	s2,s2,1917 # a3677d <_entry-0x7f5c9883>
    80001854:	0932                	slli	s2,s2,0xc
    80001856:	46d90913          	addi	s2,s2,1133
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	df590913          	addi	s2,s2,-523
    80001860:	093a                	slli	s2,s2,0xe
    80001862:	6cf90913          	addi	s2,s2,1743
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00014a17          	auipc	s4,0x14
    80001872:	422a0a13          	addi	s4,s4,1058 # 80015c90 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	878d                	srai	a5,a5,0x3
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	17848493          	addi	s1,s1,376
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	0000e517          	auipc	a0,0xe
    800018d4:	1c050513          	addi	a0,a0,448 # 8000fa90 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	0000e717          	auipc	a4,0xe
    800018f8:	16c70713          	addi	a4,a4,364 # 8000fa60 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00006797          	auipc	a5,0x6
    80001924:	f907a783          	lw	a5,-112(a5) # 800078b0 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	537000ef          	jal	80002660 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	227010ef          	jal	8000335e <fsinit>
    first = 0;
    8000193c:	00006797          	auipc	a5,0x6
    80001940:	f607aa23          	sw	zero,-140(a5) # 800078b0 <first.1>
    __sync_synchronize();
    80001944:	0ff0000f          	fence
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	0000e917          	auipc	s2,0xe
    8000195a:	10a90913          	addi	s2,s2,266 # 8000fa60 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00006797          	auipc	a5,0x6
    80001968:	f5078793          	addi	a5,a5,-176 # 800078b4 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	0000e497          	auipc	s1,0xe
    80001ab2:	3e248493          	addi	s1,s1,994 # 8000fe90 <proc>
    80001ab6:	00014917          	auipc	s2,0x14
    80001aba:	1da90913          	addi	s2,s2,474 # 80015c90 <tickslock>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	17848493          	addi	s1,s1,376
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a8b1                	j	80001b34 <allocproc+0x92>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  p->pr = 3;
    80001ae4:	478d                	li	a5,3
    80001ae6:	16f4a423          	sw	a5,360(s1)
  p->lv = 0;
    80001aea:	1604a623          	sw	zero,364(s1)
  p->tq = 0;
    80001aee:	1604a823          	sw	zero,368(s1)
  p->time = ticks;
    80001af2:	00006797          	auipc	a5,0x6
    80001af6:	e467a783          	lw	a5,-442(a5) # 80007938 <ticks>
    80001afa:	16f4aa23          	sw	a5,372(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001afe:	826ff0ef          	jal	80000b24 <kalloc>
    80001b02:	892a                	mv	s2,a0
    80001b04:	eca8                	sd	a0,88(s1)
    80001b06:	cd15                	beqz	a0,80001b42 <allocproc+0xa0>
  p->pagetable = proc_pagetable(p);
    80001b08:	8526                	mv	a0,s1
    80001b0a:	e7fff0ef          	jal	80001988 <proc_pagetable>
    80001b0e:	892a                	mv	s2,a0
    80001b10:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b12:	c121                	beqz	a0,80001b52 <allocproc+0xb0>
  memset(&p->context, 0, sizeof(p->context));
    80001b14:	07000613          	li	a2,112
    80001b18:	4581                	li	a1,0
    80001b1a:	06048513          	addi	a0,s1,96
    80001b1e:	9aaff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b22:	00000797          	auipc	a5,0x0
    80001b26:	dee78793          	addi	a5,a5,-530 # 80001910 <forkret>
    80001b2a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b2c:	60bc                	ld	a5,64(s1)
    80001b2e:	6705                	lui	a4,0x1
    80001b30:	97ba                	add	a5,a5,a4
    80001b32:	f4bc                	sd	a5,104(s1)
}
    80001b34:	8526                	mv	a0,s1
    80001b36:	60e2                	ld	ra,24(sp)
    80001b38:	6442                	ld	s0,16(sp)
    80001b3a:	64a2                	ld	s1,8(sp)
    80001b3c:	6902                	ld	s2,0(sp)
    80001b3e:	6105                	addi	sp,sp,32
    80001b40:	8082                	ret
    freeproc(p);
    80001b42:	8526                	mv	a0,s1
    80001b44:	f0fff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b48:	8526                	mv	a0,s1
    80001b4a:	942ff0ef          	jal	80000c8c <release>
    return 0;
    80001b4e:	84ca                	mv	s1,s2
    80001b50:	b7d5                	j	80001b34 <allocproc+0x92>
    freeproc(p);
    80001b52:	8526                	mv	a0,s1
    80001b54:	effff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b58:	8526                	mv	a0,s1
    80001b5a:	932ff0ef          	jal	80000c8c <release>
    return 0;
    80001b5e:	84ca                	mv	s1,s2
    80001b60:	bfd1                	j	80001b34 <allocproc+0x92>

0000000080001b62 <userinit>:
{
    80001b62:	1101                	addi	sp,sp,-32
    80001b64:	ec06                	sd	ra,24(sp)
    80001b66:	e822                	sd	s0,16(sp)
    80001b68:	e426                	sd	s1,8(sp)
    80001b6a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b6c:	f37ff0ef          	jal	80001aa2 <allocproc>
    80001b70:	84aa                	mv	s1,a0
  initproc = p;
    80001b72:	00006797          	auipc	a5,0x6
    80001b76:	daa7bf23          	sd	a0,-578(a5) # 80007930 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b7a:	03400613          	li	a2,52
    80001b7e:	00006597          	auipc	a1,0x6
    80001b82:	d4258593          	addi	a1,a1,-702 # 800078c0 <initcode>
    80001b86:	6928                	ld	a0,80(a0)
    80001b88:	f14ff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b8c:	6785                	lui	a5,0x1
    80001b8e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b90:	6cb8                	ld	a4,88(s1)
    80001b92:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b96:	6cb8                	ld	a4,88(s1)
    80001b98:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b9a:	4641                	li	a2,16
    80001b9c:	00005597          	auipc	a1,0x5
    80001ba0:	68458593          	addi	a1,a1,1668 # 80007220 <etext+0x220>
    80001ba4:	15848513          	addi	a0,s1,344
    80001ba8:	a5eff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001bac:	00005517          	auipc	a0,0x5
    80001bb0:	68450513          	addi	a0,a0,1668 # 80007230 <etext+0x230>
    80001bb4:	0b8020ef          	jal	80003c6c <namei>
    80001bb8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bbc:	478d                	li	a5,3
    80001bbe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	8caff0ef          	jal	80000c8c <release>
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <growproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bde:	d03ff0ef          	jal	800018e0 <myproc>
    80001be2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001be4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001be6:	01204c63          	bgtz	s2,80001bfe <growproc+0x2e>
  } else if(n < 0){
    80001bea:	02094463          	bltz	s2,80001c12 <growproc+0x42>
  p->sz = sz;
    80001bee:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bf0:	4501                	li	a0,0
}
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6902                	ld	s2,0(sp)
    80001bfa:	6105                	addi	sp,sp,32
    80001bfc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bfe:	4691                	li	a3,4
    80001c00:	00b90633          	add	a2,s2,a1
    80001c04:	6928                	ld	a0,80(a0)
    80001c06:	f38ff0ef          	jal	8000133e <uvmalloc>
    80001c0a:	85aa                	mv	a1,a0
    80001c0c:	f16d                	bnez	a0,80001bee <growproc+0x1e>
      return -1;
    80001c0e:	557d                	li	a0,-1
    80001c10:	b7cd                	j	80001bf2 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c12:	00b90633          	add	a2,s2,a1
    80001c16:	6928                	ld	a0,80(a0)
    80001c18:	ee2ff0ef          	jal	800012fa <uvmdealloc>
    80001c1c:	85aa                	mv	a1,a0
    80001c1e:	bfc1                	j	80001bee <growproc+0x1e>

0000000080001c20 <fork>:
{
    80001c20:	7139                	addi	sp,sp,-64
    80001c22:	fc06                	sd	ra,56(sp)
    80001c24:	f822                	sd	s0,48(sp)
    80001c26:	f04a                	sd	s2,32(sp)
    80001c28:	e456                	sd	s5,8(sp)
    80001c2a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c2c:	cb5ff0ef          	jal	800018e0 <myproc>
    80001c30:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c32:	e71ff0ef          	jal	80001aa2 <allocproc>
    80001c36:	10050663          	beqz	a0,80001d42 <fork+0x122>
    80001c3a:	ec4e                	sd	s3,24(sp)
    80001c3c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c3e:	048ab603          	ld	a2,72(s5)
    80001c42:	692c                	ld	a1,80(a0)
    80001c44:	050ab503          	ld	a0,80(s5)
    80001c48:	82fff0ef          	jal	80001476 <uvmcopy>
    80001c4c:	04054a63          	bltz	a0,80001ca0 <fork+0x80>
    80001c50:	f426                	sd	s1,40(sp)
    80001c52:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c54:	048ab783          	ld	a5,72(s5)
    80001c58:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c5c:	058ab683          	ld	a3,88(s5)
    80001c60:	87b6                	mv	a5,a3
    80001c62:	0589b703          	ld	a4,88(s3)
    80001c66:	12068693          	addi	a3,a3,288
    80001c6a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c6e:	6788                	ld	a0,8(a5)
    80001c70:	6b8c                	ld	a1,16(a5)
    80001c72:	6f90                	ld	a2,24(a5)
    80001c74:	01073023          	sd	a6,0(a4)
    80001c78:	e708                	sd	a0,8(a4)
    80001c7a:	eb0c                	sd	a1,16(a4)
    80001c7c:	ef10                	sd	a2,24(a4)
    80001c7e:	02078793          	addi	a5,a5,32
    80001c82:	02070713          	addi	a4,a4,32
    80001c86:	fed792e3          	bne	a5,a3,80001c6a <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c8a:	0589b783          	ld	a5,88(s3)
    80001c8e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c92:	0d0a8493          	addi	s1,s5,208
    80001c96:	0d098913          	addi	s2,s3,208
    80001c9a:	150a8a13          	addi	s4,s5,336
    80001c9e:	a831                	j	80001cba <fork+0x9a>
    freeproc(np);
    80001ca0:	854e                	mv	a0,s3
    80001ca2:	db1ff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001ca6:	854e                	mv	a0,s3
    80001ca8:	fe5fe0ef          	jal	80000c8c <release>
    return -1;
    80001cac:	597d                	li	s2,-1
    80001cae:	69e2                	ld	s3,24(sp)
    80001cb0:	a051                	j	80001d34 <fork+0x114>
  for(i = 0; i < NOFILE; i++)
    80001cb2:	04a1                	addi	s1,s1,8
    80001cb4:	0921                	addi	s2,s2,8
    80001cb6:	01448963          	beq	s1,s4,80001cc8 <fork+0xa8>
    if(p->ofile[i])
    80001cba:	6088                	ld	a0,0(s1)
    80001cbc:	d97d                	beqz	a0,80001cb2 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cbe:	53e020ef          	jal	800041fc <filedup>
    80001cc2:	00a93023          	sd	a0,0(s2)
    80001cc6:	b7f5                	j	80001cb2 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cc8:	150ab503          	ld	a0,336(s5)
    80001ccc:	091010ef          	jal	8000355c <idup>
    80001cd0:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cd4:	4641                	li	a2,16
    80001cd6:	158a8593          	addi	a1,s5,344
    80001cda:	15898513          	addi	a0,s3,344
    80001cde:	928ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001ce2:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001ce6:	854e                	mv	a0,s3
    80001ce8:	fa5fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cec:	0000e497          	auipc	s1,0xe
    80001cf0:	d8c48493          	addi	s1,s1,-628 # 8000fa78 <wait_lock>
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	efffe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001cfa:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001cfe:	8526                	mv	a0,s1
    80001d00:	f8dfe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001d04:	854e                	mv	a0,s3
    80001d06:	eeffe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001d0a:	478d                	li	a5,3
    80001d0c:	00f9ac23          	sw	a5,24(s3)
  np->tq = 0;
    80001d10:	1609a823          	sw	zero,368(s3)
  np->lv = 0;
    80001d14:	1609a623          	sw	zero,364(s3)
  np->time = ticks;
    80001d18:	00006717          	auipc	a4,0x6
    80001d1c:	c2072703          	lw	a4,-992(a4) # 80007938 <ticks>
    80001d20:	16e9aa23          	sw	a4,372(s3)
  np->pr = 3;
    80001d24:	16f9a423          	sw	a5,360(s3)
  release(&np->lock);
    80001d28:	854e                	mv	a0,s3
    80001d2a:	f63fe0ef          	jal	80000c8c <release>
  return pid;
    80001d2e:	74a2                	ld	s1,40(sp)
    80001d30:	69e2                	ld	s3,24(sp)
    80001d32:	6a42                	ld	s4,16(sp)
}
    80001d34:	854a                	mv	a0,s2
    80001d36:	70e2                	ld	ra,56(sp)
    80001d38:	7442                	ld	s0,48(sp)
    80001d3a:	7902                	ld	s2,32(sp)
    80001d3c:	6aa2                	ld	s5,8(sp)
    80001d3e:	6121                	addi	sp,sp,64
    80001d40:	8082                	ret
    return -1;
    80001d42:	597d                	li	s2,-1
    80001d44:	bfc5                	j	80001d34 <fork+0x114>

0000000080001d46 <scheduler>:
scheduler(void) {
    80001d46:	711d                	addi	sp,sp,-96
    80001d48:	ec86                	sd	ra,88(sp)
    80001d4a:	e8a2                	sd	s0,80(sp)
    80001d4c:	e4a6                	sd	s1,72(sp)
    80001d4e:	e0ca                	sd	s2,64(sp)
    80001d50:	fc4e                	sd	s3,56(sp)
    80001d52:	f852                	sd	s4,48(sp)
    80001d54:	f456                	sd	s5,40(sp)
    80001d56:	f05a                	sd	s6,32(sp)
    80001d58:	ec5e                	sd	s7,24(sp)
    80001d5a:	e862                	sd	s8,16(sp)
    80001d5c:	e466                	sd	s9,8(sp)
    80001d5e:	1080                	addi	s0,sp,96
    80001d60:	8792                	mv	a5,tp
  int id = r_tp();
    80001d62:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d64:	00779c13          	slli	s8,a5,0x7
    80001d68:	0000e717          	auipc	a4,0xe
    80001d6c:	cf870713          	addi	a4,a4,-776 # 8000fa60 <pid_lock>
    80001d70:	9762                	add	a4,a4,s8
    80001d72:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &running_p->context);
    80001d76:	0000e717          	auipc	a4,0xe
    80001d7a:	d2270713          	addi	a4,a4,-734 # 8000fa98 <cpus+0x8>
    80001d7e:	9c3a                	add	s8,s8,a4
    if(sched_mode == 0){
    80001d80:	00006b97          	auipc	s7,0x6
    80001d84:	ba8b8b93          	addi	s7,s7,-1112 # 80007928 <sched_mode>
    struct proc *running_p = 0;
    80001d88:	4b01                	li	s6,0
              if(running_p->lv == 2) {
    80001d8a:	4a89                	li	s5,2
      for(p = proc; p < &proc[NPROC]; p++) {
    80001d8c:	00014917          	auipc	s2,0x14
    80001d90:	f0490913          	addi	s2,s2,-252 # 80015c90 <tickslock>
      c->proc = running_p;
    80001d94:	079e                	slli	a5,a5,0x7
    80001d96:	0000ea17          	auipc	s4,0xe
    80001d9a:	ccaa0a13          	addi	s4,s4,-822 # 8000fa60 <pid_lock>
    80001d9e:	9a3e                	add	s4,s4,a5
    80001da0:	a8c9                	j	80001e72 <scheduler+0x12c>
            running_p = p;
    80001da2:	89a6                	mv	s3,s1
        release(&p->lock);
    80001da4:	8526                	mv	a0,s1
    80001da6:	ee7fe0ef          	jal	80000c8c <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001daa:	17848493          	addi	s1,s1,376
    80001dae:	09248e63          	beq	s1,s2,80001e4a <scheduler+0x104>
        acquire(&p->lock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	e41fe0ef          	jal	80000bf4 <acquire>
        if(p->state == RUNNABLE) {
    80001db8:	4c9c                	lw	a5,24(s1)
    80001dba:	ff9795e3          	bne	a5,s9,80001da4 <scheduler+0x5e>
          if(running_p == 0 || p->pid < running_p->pid) {
    80001dbe:	fe0982e3          	beqz	s3,80001da2 <scheduler+0x5c>
    80001dc2:	5898                	lw	a4,48(s1)
    80001dc4:	0309a783          	lw	a5,48(s3)
    80001dc8:	fcf75ee3          	bge	a4,a5,80001da4 <scheduler+0x5e>
            running_p = p;
    80001dcc:	89a6                	mv	s3,s1
    80001dce:	bfd9                	j	80001da4 <scheduler+0x5e>
    struct proc *running_p = 0;
    80001dd0:	89da                	mv	s3,s6
      for(p = proc; p < &proc[NPROC]; p++) {
    80001dd2:	0000e497          	auipc	s1,0xe
    80001dd6:	0be48493          	addi	s1,s1,190 # 8000fe90 <proc>
        if(p->state == RUNNABLE) {
    80001dda:	4c8d                	li	s9,3
    80001ddc:	a81d                	j	80001e12 <scheduler+0xcc>
                if(running_p->pr < p->pr) {
    80001dde:	1689a703          	lw	a4,360(s3)
    80001de2:	1684a783          	lw	a5,360(s1)
    80001de6:	06f74063          	blt	a4,a5,80001e46 <scheduler+0x100>
                } else if((running_p->pr == p->pr) && (running_p->tq > p->time)) {
    80001dea:	00f71d63          	bne	a4,a5,80001e04 <scheduler+0xbe>
    80001dee:	1709a703          	lw	a4,368(s3)
    80001df2:	1744a783          	lw	a5,372(s1)
    80001df6:	00e7d763          	bge	a5,a4,80001e04 <scheduler+0xbe>
                  running_p = p;
    80001dfa:	89a6                	mv	s3,s1
    80001dfc:	a021                	j	80001e04 <scheduler+0xbe>
            running_p = p;
    80001dfe:	89a6                	mv	s3,s1
    80001e00:	a011                	j	80001e04 <scheduler+0xbe>
              running_p = p;
    80001e02:	89a6                	mv	s3,s1
        release(&p->lock);
    80001e04:	8526                	mv	a0,s1
    80001e06:	e87fe0ef          	jal	80000c8c <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e0a:	17848493          	addi	s1,s1,376
    80001e0e:	03248e63          	beq	s1,s2,80001e4a <scheduler+0x104>
        acquire(&p->lock);
    80001e12:	8526                	mv	a0,s1
    80001e14:	de1fe0ef          	jal	80000bf4 <acquire>
        if(p->state == RUNNABLE) {
    80001e18:	4c9c                	lw	a5,24(s1)
    80001e1a:	ff9795e3          	bne	a5,s9,80001e04 <scheduler+0xbe>
          if(running_p == 0) {
    80001e1e:	fe0980e3          	beqz	s3,80001dfe <scheduler+0xb8>
            if(running_p->lv > p->lv) {
    80001e22:	16c9a783          	lw	a5,364(s3)
    80001e26:	16c4a703          	lw	a4,364(s1)
    80001e2a:	fcf74ce3          	blt	a4,a5,80001e02 <scheduler+0xbc>
            else if(running_p->lv == p->lv) {
    80001e2e:	fce79be3          	bne	a5,a4,80001e04 <scheduler+0xbe>
              if(running_p->lv == 2) {
    80001e32:	fb5786e3          	beq	a5,s5,80001dde <scheduler+0x98>
                if(running_p->time > p->time) {
    80001e36:	1749a703          	lw	a4,372(s3)
    80001e3a:	1744a783          	lw	a5,372(s1)
    80001e3e:	fce7d3e3          	bge	a5,a4,80001e04 <scheduler+0xbe>
                  running_p = p;
    80001e42:	89a6                	mv	s3,s1
    80001e44:	b7c1                	j	80001e04 <scheduler+0xbe>
                  running_p = p;
    80001e46:	89a6                	mv	s3,s1
    80001e48:	bf75                	j	80001e04 <scheduler+0xbe>
    if(running_p) {
    80001e4a:	04098463          	beqz	s3,80001e92 <scheduler+0x14c>
      acquire(&running_p->lock);
    80001e4e:	854e                	mv	a0,s3
    80001e50:	da5fe0ef          	jal	80000bf4 <acquire>
      running_p->state = RUNNING;
    80001e54:	4791                	li	a5,4
    80001e56:	00f9ac23          	sw	a5,24(s3)
      c->proc = running_p;
    80001e5a:	033a3823          	sd	s3,48(s4)
      swtch(&c->context, &running_p->context);
    80001e5e:	06098593          	addi	a1,s3,96
    80001e62:	8562                	mv	a0,s8
    80001e64:	756000ef          	jal	800025ba <swtch>
      c->proc = 0;
    80001e68:	020a3823          	sd	zero,48(s4)
      release(&running_p->lock);
    80001e6c:	854e                	mv	a0,s3
    80001e6e:	e1ffe0ef          	jal	80000c8c <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e72:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e76:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e7a:	10079073          	csrw	sstatus,a5
    if(sched_mode == 0){
    80001e7e:	000ba783          	lw	a5,0(s7)
    80001e82:	f7b9                	bnez	a5,80001dd0 <scheduler+0x8a>
    struct proc *running_p = 0;
    80001e84:	89da                	mv	s3,s6
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e86:	0000e497          	auipc	s1,0xe
    80001e8a:	00a48493          	addi	s1,s1,10 # 8000fe90 <proc>
        if(p->state == RUNNABLE) {
    80001e8e:	4c8d                	li	s9,3
    80001e90:	b70d                	j	80001db2 <scheduler+0x6c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e9a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e9e:	10500073          	wfi
    80001ea2:	bfc1                	j	80001e72 <scheduler+0x12c>

0000000080001ea4 <priority_boosting>:
priority_boosting(void){
    80001ea4:	1141                	addi	sp,sp,-16
    80001ea6:	e422                	sd	s0,8(sp)
    80001ea8:	0800                	addi	s0,sp,16
    p->time = ticks;
    80001eaa:	00006617          	auipc	a2,0x6
    80001eae:	a8e62603          	lw	a2,-1394(a2) # 80007938 <ticks>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eb2:	0000e797          	auipc	a5,0xe
    80001eb6:	fde78793          	addi	a5,a5,-34 # 8000fe90 <proc>
    p->pr = 3;
    80001eba:	468d                	li	a3,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ebc:	00014717          	auipc	a4,0x14
    80001ec0:	dd470713          	addi	a4,a4,-556 # 80015c90 <tickslock>
    p->pr = 3;
    80001ec4:	16d7a423          	sw	a3,360(a5)
    p->lv = 0;
    80001ec8:	1607a623          	sw	zero,364(a5)
    p->tq = 0;
    80001ecc:	1607a823          	sw	zero,368(a5)
    p->time = ticks;
    80001ed0:	16c7aa23          	sw	a2,372(a5)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ed4:	17878793          	addi	a5,a5,376
    80001ed8:	fee796e3          	bne	a5,a4,80001ec4 <priority_boosting+0x20>
}
    80001edc:	6422                	ld	s0,8(sp)
    80001ede:	0141                	addi	sp,sp,16
    80001ee0:	8082                	ret

0000000080001ee2 <setpriority>:
setpriority(int pid, int priority){
    80001ee2:	715d                	addi	sp,sp,-80
    80001ee4:	e486                	sd	ra,72(sp)
    80001ee6:	e0a2                	sd	s0,64(sp)
    80001ee8:	fc26                	sd	s1,56(sp)
    80001eea:	f84a                	sd	s2,48(sp)
    80001eec:	f44e                	sd	s3,40(sp)
    80001eee:	f052                	sd	s4,32(sp)
    80001ef0:	ec56                	sd	s5,24(sp)
    80001ef2:	e85a                	sd	s6,16(sp)
    80001ef4:	e45e                	sd	s7,8(sp)
    80001ef6:	e062                	sd	s8,0(sp)
    80001ef8:	0880                	addi	s0,sp,80
    80001efa:	892a                	mv	s2,a0
    80001efc:	8aae                	mv	s5,a1
  int chk = 0;
    80001efe:	4a01                	li	s4,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f00:	0000e497          	auipc	s1,0xe
    80001f04:	f9048493          	addi	s1,s1,-112 # 8000fe90 <proc>
      if(priority >= 0 && priority <= 3){
    80001f08:	00058b9b          	sext.w	s7,a1
    80001f0c:	4b0d                	li	s6,3
      chk = 1;
    80001f0e:	4c05                	li	s8,1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f10:	00014997          	auipc	s3,0x14
    80001f14:	d8098993          	addi	s3,s3,-640 # 80015c90 <tickslock>
    80001f18:	a805                	j	80001f48 <setpriority+0x66>
        release(&p->lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	d71fe0ef          	jal	80000c8c <release>
        return -2;
    80001f20:	5579                	li	a0,-2
}
    80001f22:	60a6                	ld	ra,72(sp)
    80001f24:	6406                	ld	s0,64(sp)
    80001f26:	74e2                	ld	s1,56(sp)
    80001f28:	7942                	ld	s2,48(sp)
    80001f2a:	79a2                	ld	s3,40(sp)
    80001f2c:	7a02                	ld	s4,32(sp)
    80001f2e:	6ae2                	ld	s5,24(sp)
    80001f30:	6b42                	ld	s6,16(sp)
    80001f32:	6ba2                	ld	s7,8(sp)
    80001f34:	6c02                	ld	s8,0(sp)
    80001f36:	6161                	addi	sp,sp,80
    80001f38:	8082                	ret
    release(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	d51fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f40:	17848493          	addi	s1,s1,376
    80001f44:	01348e63          	beq	s1,s3,80001f60 <setpriority+0x7e>
    acquire(&p->lock);
    80001f48:	8526                	mv	a0,s1
    80001f4a:	cabfe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80001f4e:	589c                	lw	a5,48(s1)
    80001f50:	ff2795e3          	bne	a5,s2,80001f3a <setpriority+0x58>
      if(priority >= 0 && priority <= 3){
    80001f54:	fd7b63e3          	bltu	s6,s7,80001f1a <setpriority+0x38>
        p->pr = priority;
    80001f58:	1754a423          	sw	s5,360(s1)
      chk = 1;
    80001f5c:	8a62                	mv	s4,s8
    80001f5e:	bff1                	j	80001f3a <setpriority+0x58>
  if(chk == 0){
    80001f60:	fffa051b          	addiw	a0,s4,-1
    80001f64:	2501                	sext.w	a0,a0
    80001f66:	bf75                	j	80001f22 <setpriority+0x40>

0000000080001f68 <getlev>:
  if(sched_mode == 0){
    80001f68:	00006797          	auipc	a5,0x6
    80001f6c:	9c07a783          	lw	a5,-1600(a5) # 80007928 <sched_mode>
    return 99;
    80001f70:	06300513          	li	a0,99
  if(sched_mode == 0){
    80001f74:	e391                	bnez	a5,80001f78 <getlev+0x10>
}
    80001f76:	8082                	ret
getlev(void){
    80001f78:	1141                	addi	sp,sp,-16
    80001f7a:	e406                	sd	ra,8(sp)
    80001f7c:	e022                	sd	s0,0(sp)
    80001f7e:	0800                	addi	s0,sp,16
    return myproc()->lv;
    80001f80:	961ff0ef          	jal	800018e0 <myproc>
    80001f84:	16c52503          	lw	a0,364(a0)
}
    80001f88:	60a2                	ld	ra,8(sp)
    80001f8a:	6402                	ld	s0,0(sp)
    80001f8c:	0141                	addi	sp,sp,16
    80001f8e:	8082                	ret

0000000080001f90 <mlfqmode>:
mlfqmode(void) {
    80001f90:	1141                	addi	sp,sp,-16
    80001f92:	e422                	sd	s0,8(sp)
    80001f94:	0800                	addi	s0,sp,16
  if(sched_mode == 1){ // 이미 mlfqmode인 경우
    80001f96:	00006717          	auipc	a4,0x6
    80001f9a:	99272703          	lw	a4,-1646(a4) # 80007928 <sched_mode>
    80001f9e:	4785                	li	a5,1
    80001fa0:	04f70363          	beq	a4,a5,80001fe6 <mlfqmode+0x56>
    sched_mode = 1;
    80001fa4:	00006717          	auipc	a4,0x6
    80001fa8:	98f72223          	sw	a5,-1660(a4) # 80007928 <sched_mode>
    ticks = 0;
    80001fac:	00006797          	auipc	a5,0x6
    80001fb0:	9807a623          	sw	zero,-1652(a5) # 80007938 <ticks>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb4:	0000e797          	auipc	a5,0xe
    80001fb8:	edc78793          	addi	a5,a5,-292 # 8000fe90 <proc>
      p->pr = 3;
    80001fbc:	468d                	li	a3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	00014717          	auipc	a4,0x14
    80001fc2:	cd270713          	addi	a4,a4,-814 # 80015c90 <tickslock>
      p->pr = 3;
    80001fc6:	16d7a423          	sw	a3,360(a5)
      p->lv = 0;
    80001fca:	1607a623          	sw	zero,364(a5)
      p->tq = 0;
    80001fce:	1607a823          	sw	zero,368(a5)
      p->time = 0;
    80001fd2:	1607aa23          	sw	zero,372(a5)
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd6:	17878793          	addi	a5,a5,376
    80001fda:	fee796e3          	bne	a5,a4,80001fc6 <mlfqmode+0x36>
    return 0;
    80001fde:	4501                	li	a0,0
}
    80001fe0:	6422                	ld	s0,8(sp)
    80001fe2:	0141                	addi	sp,sp,16
    80001fe4:	8082                	ret
    return -1;
    80001fe6:	557d                	li	a0,-1
    80001fe8:	bfe5                	j	80001fe0 <mlfqmode+0x50>

0000000080001fea <fcfsmode>:
fcfsmode(void) {
    80001fea:	1141                	addi	sp,sp,-16
    80001fec:	e422                	sd	s0,8(sp)
    80001fee:	0800                	addi	s0,sp,16
  if(sched_mode == 0){ // 이미 fcfsmode인 경우
    80001ff0:	00006797          	auipc	a5,0x6
    80001ff4:	9387a783          	lw	a5,-1736(a5) # 80007928 <sched_mode>
    80001ff8:	c3b1                	beqz	a5,8000203c <fcfsmode+0x52>
    sched_mode = 0;
    80001ffa:	00006797          	auipc	a5,0x6
    80001ffe:	9207a723          	sw	zero,-1746(a5) # 80007928 <sched_mode>
    ticks = 0;
    80002002:	00006797          	auipc	a5,0x6
    80002006:	9207ab23          	sw	zero,-1738(a5) # 80007938 <ticks>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000200a:	0000e797          	auipc	a5,0xe
    8000200e:	e8678793          	addi	a5,a5,-378 # 8000fe90 <proc>
      p->pr = -1;
    80002012:	577d                	li	a4,-1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002014:	00014697          	auipc	a3,0x14
    80002018:	c7c68693          	addi	a3,a3,-900 # 80015c90 <tickslock>
      p->pr = -1;
    8000201c:	16e7a423          	sw	a4,360(a5)
      p->lv = -1;
    80002020:	16e7a623          	sw	a4,364(a5)
      p->tq = -1;
    80002024:	16e7a823          	sw	a4,368(a5)
      p->time = 0;
    80002028:	1607aa23          	sw	zero,372(a5)
    for(p = proc; p < &proc[NPROC]; p++) {
    8000202c:	17878793          	addi	a5,a5,376
    80002030:	fed796e3          	bne	a5,a3,8000201c <fcfsmode+0x32>
    return 0;
    80002034:	4501                	li	a0,0
}
    80002036:	6422                	ld	s0,8(sp)
    80002038:	0141                	addi	sp,sp,16
    8000203a:	8082                	ret
    return -1;
    8000203c:	557d                	li	a0,-1
    8000203e:	bfe5                	j	80002036 <fcfsmode+0x4c>

0000000080002040 <sched>:
{
    80002040:	7179                	addi	sp,sp,-48
    80002042:	f406                	sd	ra,40(sp)
    80002044:	f022                	sd	s0,32(sp)
    80002046:	ec26                	sd	s1,24(sp)
    80002048:	e84a                	sd	s2,16(sp)
    8000204a:	e44e                	sd	s3,8(sp)
    8000204c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000204e:	893ff0ef          	jal	800018e0 <myproc>
    80002052:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002054:	b37fe0ef          	jal	80000b8a <holding>
    80002058:	c92d                	beqz	a0,800020ca <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000205a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000205c:	2781                	sext.w	a5,a5
    8000205e:	079e                	slli	a5,a5,0x7
    80002060:	0000e717          	auipc	a4,0xe
    80002064:	a0070713          	addi	a4,a4,-1536 # 8000fa60 <pid_lock>
    80002068:	97ba                	add	a5,a5,a4
    8000206a:	0a87a703          	lw	a4,168(a5)
    8000206e:	4785                	li	a5,1
    80002070:	06f71363          	bne	a4,a5,800020d6 <sched+0x96>
  if(p->state == RUNNING)
    80002074:	4c98                	lw	a4,24(s1)
    80002076:	4791                	li	a5,4
    80002078:	06f70563          	beq	a4,a5,800020e2 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000207c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002080:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002082:	e7b5                	bnez	a5,800020ee <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002084:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002086:	0000e917          	auipc	s2,0xe
    8000208a:	9da90913          	addi	s2,s2,-1574 # 8000fa60 <pid_lock>
    8000208e:	2781                	sext.w	a5,a5
    80002090:	079e                	slli	a5,a5,0x7
    80002092:	97ca                	add	a5,a5,s2
    80002094:	0ac7a983          	lw	s3,172(a5)
    80002098:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000209a:	2781                	sext.w	a5,a5
    8000209c:	079e                	slli	a5,a5,0x7
    8000209e:	0000e597          	auipc	a1,0xe
    800020a2:	9fa58593          	addi	a1,a1,-1542 # 8000fa98 <cpus+0x8>
    800020a6:	95be                	add	a1,a1,a5
    800020a8:	06048513          	addi	a0,s1,96
    800020ac:	50e000ef          	jal	800025ba <swtch>
    800020b0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020b2:	2781                	sext.w	a5,a5
    800020b4:	079e                	slli	a5,a5,0x7
    800020b6:	993e                	add	s2,s2,a5
    800020b8:	0b392623          	sw	s3,172(s2)
}
    800020bc:	70a2                	ld	ra,40(sp)
    800020be:	7402                	ld	s0,32(sp)
    800020c0:	64e2                	ld	s1,24(sp)
    800020c2:	6942                	ld	s2,16(sp)
    800020c4:	69a2                	ld	s3,8(sp)
    800020c6:	6145                	addi	sp,sp,48
    800020c8:	8082                	ret
    panic("sched p->lock");
    800020ca:	00005517          	auipc	a0,0x5
    800020ce:	16e50513          	addi	a0,a0,366 # 80007238 <etext+0x238>
    800020d2:	ec2fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    800020d6:	00005517          	auipc	a0,0x5
    800020da:	17250513          	addi	a0,a0,370 # 80007248 <etext+0x248>
    800020de:	eb6fe0ef          	jal	80000794 <panic>
    panic("sched running");
    800020e2:	00005517          	auipc	a0,0x5
    800020e6:	17650513          	addi	a0,a0,374 # 80007258 <etext+0x258>
    800020ea:	eaafe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    800020ee:	00005517          	auipc	a0,0x5
    800020f2:	17a50513          	addi	a0,a0,378 # 80007268 <etext+0x268>
    800020f6:	e9efe0ef          	jal	80000794 <panic>

00000000800020fa <yield>:
{
    800020fa:	1101                	addi	sp,sp,-32
    800020fc:	ec06                	sd	ra,24(sp)
    800020fe:	e822                	sd	s0,16(sp)
    80002100:	e426                	sd	s1,8(sp)
    80002102:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002104:	fdcff0ef          	jal	800018e0 <myproc>
    80002108:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000210a:	aebfe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    8000210e:	478d                	li	a5,3
    80002110:	cc9c                	sw	a5,24(s1)
  sched();
    80002112:	f2fff0ef          	jal	80002040 <sched>
  release(&p->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	b75fe0ef          	jal	80000c8c <release>
}
    8000211c:	60e2                	ld	ra,24(sp)
    8000211e:	6442                	ld	s0,16(sp)
    80002120:	64a2                	ld	s1,8(sp)
    80002122:	6105                	addi	sp,sp,32
    80002124:	8082                	ret

0000000080002126 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002126:	7179                	addi	sp,sp,-48
    80002128:	f406                	sd	ra,40(sp)
    8000212a:	f022                	sd	s0,32(sp)
    8000212c:	ec26                	sd	s1,24(sp)
    8000212e:	e84a                	sd	s2,16(sp)
    80002130:	e44e                	sd	s3,8(sp)
    80002132:	1800                	addi	s0,sp,48
    80002134:	89aa                	mv	s3,a0
    80002136:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002138:	fa8ff0ef          	jal	800018e0 <myproc>
    8000213c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000213e:	ab7fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80002142:	854a                	mv	a0,s2
    80002144:	b49fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80002148:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000214c:	4789                	li	a5,2
    8000214e:	cc9c                	sw	a5,24(s1)

  sched();
    80002150:	ef1ff0ef          	jal	80002040 <sched>

  // Tidy up.
  p->chan = 0;
    80002154:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002158:	8526                	mv	a0,s1
    8000215a:	b33fe0ef          	jal	80000c8c <release>
  acquire(lk);
    8000215e:	854a                	mv	a0,s2
    80002160:	a95fe0ef          	jal	80000bf4 <acquire>
}
    80002164:	70a2                	ld	ra,40(sp)
    80002166:	7402                	ld	s0,32(sp)
    80002168:	64e2                	ld	s1,24(sp)
    8000216a:	6942                	ld	s2,16(sp)
    8000216c:	69a2                	ld	s3,8(sp)
    8000216e:	6145                	addi	sp,sp,48
    80002170:	8082                	ret

0000000080002172 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002172:	7139                	addi	sp,sp,-64
    80002174:	fc06                	sd	ra,56(sp)
    80002176:	f822                	sd	s0,48(sp)
    80002178:	f426                	sd	s1,40(sp)
    8000217a:	f04a                	sd	s2,32(sp)
    8000217c:	ec4e                	sd	s3,24(sp)
    8000217e:	e852                	sd	s4,16(sp)
    80002180:	e456                	sd	s5,8(sp)
    80002182:	0080                	addi	s0,sp,64
    80002184:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002186:	0000e497          	auipc	s1,0xe
    8000218a:	d0a48493          	addi	s1,s1,-758 # 8000fe90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000218e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002190:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002192:	00014917          	auipc	s2,0x14
    80002196:	afe90913          	addi	s2,s2,-1282 # 80015c90 <tickslock>
    8000219a:	a801                	j	800021aa <wakeup+0x38>
      }
      release(&p->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	aeffe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021a2:	17848493          	addi	s1,s1,376
    800021a6:	03248263          	beq	s1,s2,800021ca <wakeup+0x58>
    if(p != myproc()){
    800021aa:	f36ff0ef          	jal	800018e0 <myproc>
    800021ae:	fea48ae3          	beq	s1,a0,800021a2 <wakeup+0x30>
      acquire(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	a41fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021b8:	4c9c                	lw	a5,24(s1)
    800021ba:	ff3791e3          	bne	a5,s3,8000219c <wakeup+0x2a>
    800021be:	709c                	ld	a5,32(s1)
    800021c0:	fd479ee3          	bne	a5,s4,8000219c <wakeup+0x2a>
        p->state = RUNNABLE;
    800021c4:	0154ac23          	sw	s5,24(s1)
    800021c8:	bfd1                	j	8000219c <wakeup+0x2a>
    }
  }
}
    800021ca:	70e2                	ld	ra,56(sp)
    800021cc:	7442                	ld	s0,48(sp)
    800021ce:	74a2                	ld	s1,40(sp)
    800021d0:	7902                	ld	s2,32(sp)
    800021d2:	69e2                	ld	s3,24(sp)
    800021d4:	6a42                	ld	s4,16(sp)
    800021d6:	6aa2                	ld	s5,8(sp)
    800021d8:	6121                	addi	sp,sp,64
    800021da:	8082                	ret

00000000800021dc <reparent>:
{
    800021dc:	7179                	addi	sp,sp,-48
    800021de:	f406                	sd	ra,40(sp)
    800021e0:	f022                	sd	s0,32(sp)
    800021e2:	ec26                	sd	s1,24(sp)
    800021e4:	e84a                	sd	s2,16(sp)
    800021e6:	e44e                	sd	s3,8(sp)
    800021e8:	e052                	sd	s4,0(sp)
    800021ea:	1800                	addi	s0,sp,48
    800021ec:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ee:	0000e497          	auipc	s1,0xe
    800021f2:	ca248493          	addi	s1,s1,-862 # 8000fe90 <proc>
      pp->parent = initproc;
    800021f6:	00005a17          	auipc	s4,0x5
    800021fa:	73aa0a13          	addi	s4,s4,1850 # 80007930 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021fe:	00014997          	auipc	s3,0x14
    80002202:	a9298993          	addi	s3,s3,-1390 # 80015c90 <tickslock>
    80002206:	a029                	j	80002210 <reparent+0x34>
    80002208:	17848493          	addi	s1,s1,376
    8000220c:	01348b63          	beq	s1,s3,80002222 <reparent+0x46>
    if(pp->parent == p){
    80002210:	7c9c                	ld	a5,56(s1)
    80002212:	ff279be3          	bne	a5,s2,80002208 <reparent+0x2c>
      pp->parent = initproc;
    80002216:	000a3503          	ld	a0,0(s4)
    8000221a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000221c:	f57ff0ef          	jal	80002172 <wakeup>
    80002220:	b7e5                	j	80002208 <reparent+0x2c>
}
    80002222:	70a2                	ld	ra,40(sp)
    80002224:	7402                	ld	s0,32(sp)
    80002226:	64e2                	ld	s1,24(sp)
    80002228:	6942                	ld	s2,16(sp)
    8000222a:	69a2                	ld	s3,8(sp)
    8000222c:	6a02                	ld	s4,0(sp)
    8000222e:	6145                	addi	sp,sp,48
    80002230:	8082                	ret

0000000080002232 <exit>:
{
    80002232:	7179                	addi	sp,sp,-48
    80002234:	f406                	sd	ra,40(sp)
    80002236:	f022                	sd	s0,32(sp)
    80002238:	ec26                	sd	s1,24(sp)
    8000223a:	e84a                	sd	s2,16(sp)
    8000223c:	e44e                	sd	s3,8(sp)
    8000223e:	e052                	sd	s4,0(sp)
    80002240:	1800                	addi	s0,sp,48
    80002242:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002244:	e9cff0ef          	jal	800018e0 <myproc>
    80002248:	89aa                	mv	s3,a0
  if(p == initproc)
    8000224a:	00005797          	auipc	a5,0x5
    8000224e:	6e67b783          	ld	a5,1766(a5) # 80007930 <initproc>
    80002252:	0d050493          	addi	s1,a0,208
    80002256:	15050913          	addi	s2,a0,336
    8000225a:	00a79f63          	bne	a5,a0,80002278 <exit+0x46>
    panic("init exiting");
    8000225e:	00005517          	auipc	a0,0x5
    80002262:	02250513          	addi	a0,a0,34 # 80007280 <etext+0x280>
    80002266:	d2efe0ef          	jal	80000794 <panic>
      fileclose(f);
    8000226a:	7d9010ef          	jal	80004242 <fileclose>
      p->ofile[fd] = 0;
    8000226e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002272:	04a1                	addi	s1,s1,8
    80002274:	01248563          	beq	s1,s2,8000227e <exit+0x4c>
    if(p->ofile[fd]){
    80002278:	6088                	ld	a0,0(s1)
    8000227a:	f965                	bnez	a0,8000226a <exit+0x38>
    8000227c:	bfdd                	j	80002272 <exit+0x40>
  begin_op();
    8000227e:	3ab010ef          	jal	80003e28 <begin_op>
  iput(p->cwd);
    80002282:	1509b503          	ld	a0,336(s3)
    80002286:	48e010ef          	jal	80003714 <iput>
  end_op();
    8000228a:	409010ef          	jal	80003e92 <end_op>
  p->cwd = 0;
    8000228e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002292:	0000d497          	auipc	s1,0xd
    80002296:	7e648493          	addi	s1,s1,2022 # 8000fa78 <wait_lock>
    8000229a:	8526                	mv	a0,s1
    8000229c:	959fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    800022a0:	854e                	mv	a0,s3
    800022a2:	f3bff0ef          	jal	800021dc <reparent>
  wakeup(p->parent);
    800022a6:	0389b503          	ld	a0,56(s3)
    800022aa:	ec9ff0ef          	jal	80002172 <wakeup>
  acquire(&p->lock);
    800022ae:	854e                	mv	a0,s3
    800022b0:	945fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    800022b4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022b8:	4795                	li	a5,5
    800022ba:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	9cdfe0ef          	jal	80000c8c <release>
  sched();
    800022c4:	d7dff0ef          	jal	80002040 <sched>
  panic("zombie exit");
    800022c8:	00005517          	auipc	a0,0x5
    800022cc:	fc850513          	addi	a0,a0,-56 # 80007290 <etext+0x290>
    800022d0:	cc4fe0ef          	jal	80000794 <panic>

00000000800022d4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022d4:	7179                	addi	sp,sp,-48
    800022d6:	f406                	sd	ra,40(sp)
    800022d8:	f022                	sd	s0,32(sp)
    800022da:	ec26                	sd	s1,24(sp)
    800022dc:	e84a                	sd	s2,16(sp)
    800022de:	e44e                	sd	s3,8(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022e4:	0000e497          	auipc	s1,0xe
    800022e8:	bac48493          	addi	s1,s1,-1108 # 8000fe90 <proc>
    800022ec:	00014997          	auipc	s3,0x14
    800022f0:	9a498993          	addi	s3,s3,-1628 # 80015c90 <tickslock>
    acquire(&p->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	8fffe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    800022fa:	589c                	lw	a5,48(s1)
    800022fc:	01278b63          	beq	a5,s2,80002312 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002300:	8526                	mv	a0,s1
    80002302:	98bfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002306:	17848493          	addi	s1,s1,376
    8000230a:	ff3495e3          	bne	s1,s3,800022f4 <kill+0x20>
  }
  return -1;
    8000230e:	557d                	li	a0,-1
    80002310:	a819                	j	80002326 <kill+0x52>
      p->killed = 1;
    80002312:	4785                	li	a5,1
    80002314:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002316:	4c98                	lw	a4,24(s1)
    80002318:	4789                	li	a5,2
    8000231a:	00f70d63          	beq	a4,a5,80002334 <kill+0x60>
      release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	96dfe0ef          	jal	80000c8c <release>
      return 0;
    80002324:	4501                	li	a0,0
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6145                	addi	sp,sp,48
    80002332:	8082                	ret
        p->state = RUNNABLE;
    80002334:	478d                	li	a5,3
    80002336:	cc9c                	sw	a5,24(s1)
    80002338:	b7dd                	j	8000231e <kill+0x4a>

000000008000233a <setkilled>:

void
setkilled(struct proc *p)
{
    8000233a:	1101                	addi	sp,sp,-32
    8000233c:	ec06                	sd	ra,24(sp)
    8000233e:	e822                	sd	s0,16(sp)
    80002340:	e426                	sd	s1,8(sp)
    80002342:	1000                	addi	s0,sp,32
    80002344:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002346:	8affe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    8000234a:	4785                	li	a5,1
    8000234c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	93dfe0ef          	jal	80000c8c <release>
}
    80002354:	60e2                	ld	ra,24(sp)
    80002356:	6442                	ld	s0,16(sp)
    80002358:	64a2                	ld	s1,8(sp)
    8000235a:	6105                	addi	sp,sp,32
    8000235c:	8082                	ret

000000008000235e <killed>:

int
killed(struct proc *p)
{
    8000235e:	1101                	addi	sp,sp,-32
    80002360:	ec06                	sd	ra,24(sp)
    80002362:	e822                	sd	s0,16(sp)
    80002364:	e426                	sd	s1,8(sp)
    80002366:	e04a                	sd	s2,0(sp)
    80002368:	1000                	addi	s0,sp,32
    8000236a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000236c:	889fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002370:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	917fe0ef          	jal	80000c8c <release>
  return k;
}
    8000237a:	854a                	mv	a0,s2
    8000237c:	60e2                	ld	ra,24(sp)
    8000237e:	6442                	ld	s0,16(sp)
    80002380:	64a2                	ld	s1,8(sp)
    80002382:	6902                	ld	s2,0(sp)
    80002384:	6105                	addi	sp,sp,32
    80002386:	8082                	ret

0000000080002388 <wait>:
{
    80002388:	715d                	addi	sp,sp,-80
    8000238a:	e486                	sd	ra,72(sp)
    8000238c:	e0a2                	sd	s0,64(sp)
    8000238e:	fc26                	sd	s1,56(sp)
    80002390:	f84a                	sd	s2,48(sp)
    80002392:	f44e                	sd	s3,40(sp)
    80002394:	f052                	sd	s4,32(sp)
    80002396:	ec56                	sd	s5,24(sp)
    80002398:	e85a                	sd	s6,16(sp)
    8000239a:	e45e                	sd	s7,8(sp)
    8000239c:	e062                	sd	s8,0(sp)
    8000239e:	0880                	addi	s0,sp,80
    800023a0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023a2:	d3eff0ef          	jal	800018e0 <myproc>
    800023a6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023a8:	0000d517          	auipc	a0,0xd
    800023ac:	6d050513          	addi	a0,a0,1744 # 8000fa78 <wait_lock>
    800023b0:	845fe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    800023b4:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023b6:	4a15                	li	s4,5
        havekids = 1;
    800023b8:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ba:	00014997          	auipc	s3,0x14
    800023be:	8d698993          	addi	s3,s3,-1834 # 80015c90 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023c2:	0000dc17          	auipc	s8,0xd
    800023c6:	6b6c0c13          	addi	s8,s8,1718 # 8000fa78 <wait_lock>
    800023ca:	a871                	j	80002466 <wait+0xde>
          pid = pp->pid;
    800023cc:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023d0:	000b0c63          	beqz	s6,800023e8 <wait+0x60>
    800023d4:	4691                	li	a3,4
    800023d6:	02c48613          	addi	a2,s1,44
    800023da:	85da                	mv	a1,s6
    800023dc:	05093503          	ld	a0,80(s2)
    800023e0:	972ff0ef          	jal	80001552 <copyout>
    800023e4:	02054b63          	bltz	a0,8000241a <wait+0x92>
          freeproc(pp);
    800023e8:	8526                	mv	a0,s1
    800023ea:	e68ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    800023ee:	8526                	mv	a0,s1
    800023f0:	89dfe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800023f4:	0000d517          	auipc	a0,0xd
    800023f8:	68450513          	addi	a0,a0,1668 # 8000fa78 <wait_lock>
    800023fc:	891fe0ef          	jal	80000c8c <release>
}
    80002400:	854e                	mv	a0,s3
    80002402:	60a6                	ld	ra,72(sp)
    80002404:	6406                	ld	s0,64(sp)
    80002406:	74e2                	ld	s1,56(sp)
    80002408:	7942                	ld	s2,48(sp)
    8000240a:	79a2                	ld	s3,40(sp)
    8000240c:	7a02                	ld	s4,32(sp)
    8000240e:	6ae2                	ld	s5,24(sp)
    80002410:	6b42                	ld	s6,16(sp)
    80002412:	6ba2                	ld	s7,8(sp)
    80002414:	6c02                	ld	s8,0(sp)
    80002416:	6161                	addi	sp,sp,80
    80002418:	8082                	ret
            release(&pp->lock);
    8000241a:	8526                	mv	a0,s1
    8000241c:	871fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002420:	0000d517          	auipc	a0,0xd
    80002424:	65850513          	addi	a0,a0,1624 # 8000fa78 <wait_lock>
    80002428:	865fe0ef          	jal	80000c8c <release>
            return -1;
    8000242c:	59fd                	li	s3,-1
    8000242e:	bfc9                	j	80002400 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002430:	17848493          	addi	s1,s1,376
    80002434:	03348063          	beq	s1,s3,80002454 <wait+0xcc>
      if(pp->parent == p){
    80002438:	7c9c                	ld	a5,56(s1)
    8000243a:	ff279be3          	bne	a5,s2,80002430 <wait+0xa8>
        acquire(&pp->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	fb4fe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    80002444:	4c9c                	lw	a5,24(s1)
    80002446:	f94783e3          	beq	a5,s4,800023cc <wait+0x44>
        release(&pp->lock);
    8000244a:	8526                	mv	a0,s1
    8000244c:	841fe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002450:	8756                	mv	a4,s5
    80002452:	bff9                	j	80002430 <wait+0xa8>
    if(!havekids || killed(p)){
    80002454:	cf19                	beqz	a4,80002472 <wait+0xea>
    80002456:	854a                	mv	a0,s2
    80002458:	f07ff0ef          	jal	8000235e <killed>
    8000245c:	e919                	bnez	a0,80002472 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000245e:	85e2                	mv	a1,s8
    80002460:	854a                	mv	a0,s2
    80002462:	cc5ff0ef          	jal	80002126 <sleep>
    havekids = 0;
    80002466:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002468:	0000e497          	auipc	s1,0xe
    8000246c:	a2848493          	addi	s1,s1,-1496 # 8000fe90 <proc>
    80002470:	b7e1                	j	80002438 <wait+0xb0>
      release(&wait_lock);
    80002472:	0000d517          	auipc	a0,0xd
    80002476:	60650513          	addi	a0,a0,1542 # 8000fa78 <wait_lock>
    8000247a:	813fe0ef          	jal	80000c8c <release>
      return -1;
    8000247e:	59fd                	li	s3,-1
    80002480:	b741                	j	80002400 <wait+0x78>

0000000080002482 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002482:	7179                	addi	sp,sp,-48
    80002484:	f406                	sd	ra,40(sp)
    80002486:	f022                	sd	s0,32(sp)
    80002488:	ec26                	sd	s1,24(sp)
    8000248a:	e84a                	sd	s2,16(sp)
    8000248c:	e44e                	sd	s3,8(sp)
    8000248e:	e052                	sd	s4,0(sp)
    80002490:	1800                	addi	s0,sp,48
    80002492:	84aa                	mv	s1,a0
    80002494:	892e                	mv	s2,a1
    80002496:	89b2                	mv	s3,a2
    80002498:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000249a:	c46ff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    8000249e:	cc99                	beqz	s1,800024bc <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800024a0:	86d2                	mv	a3,s4
    800024a2:	864e                	mv	a2,s3
    800024a4:	85ca                	mv	a1,s2
    800024a6:	6928                	ld	a0,80(a0)
    800024a8:	8aaff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024ac:	70a2                	ld	ra,40(sp)
    800024ae:	7402                	ld	s0,32(sp)
    800024b0:	64e2                	ld	s1,24(sp)
    800024b2:	6942                	ld	s2,16(sp)
    800024b4:	69a2                	ld	s3,8(sp)
    800024b6:	6a02                	ld	s4,0(sp)
    800024b8:	6145                	addi	sp,sp,48
    800024ba:	8082                	ret
    memmove((char *)dst, src, len);
    800024bc:	000a061b          	sext.w	a2,s4
    800024c0:	85ce                	mv	a1,s3
    800024c2:	854a                	mv	a0,s2
    800024c4:	861fe0ef          	jal	80000d24 <memmove>
    return 0;
    800024c8:	8526                	mv	a0,s1
    800024ca:	b7cd                	j	800024ac <either_copyout+0x2a>

00000000800024cc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024cc:	7179                	addi	sp,sp,-48
    800024ce:	f406                	sd	ra,40(sp)
    800024d0:	f022                	sd	s0,32(sp)
    800024d2:	ec26                	sd	s1,24(sp)
    800024d4:	e84a                	sd	s2,16(sp)
    800024d6:	e44e                	sd	s3,8(sp)
    800024d8:	e052                	sd	s4,0(sp)
    800024da:	1800                	addi	s0,sp,48
    800024dc:	892a                	mv	s2,a0
    800024de:	84ae                	mv	s1,a1
    800024e0:	89b2                	mv	s3,a2
    800024e2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024e4:	bfcff0ef          	jal	800018e0 <myproc>
  if(user_src){
    800024e8:	cc99                	beqz	s1,80002506 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800024ea:	86d2                	mv	a3,s4
    800024ec:	864e                	mv	a2,s3
    800024ee:	85ca                	mv	a1,s2
    800024f0:	6928                	ld	a0,80(a0)
    800024f2:	936ff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024f6:	70a2                	ld	ra,40(sp)
    800024f8:	7402                	ld	s0,32(sp)
    800024fa:	64e2                	ld	s1,24(sp)
    800024fc:	6942                	ld	s2,16(sp)
    800024fe:	69a2                	ld	s3,8(sp)
    80002500:	6a02                	ld	s4,0(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret
    memmove(dst, (char*)src, len);
    80002506:	000a061b          	sext.w	a2,s4
    8000250a:	85ce                	mv	a1,s3
    8000250c:	854a                	mv	a0,s2
    8000250e:	817fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002512:	8526                	mv	a0,s1
    80002514:	b7cd                	j	800024f6 <either_copyin+0x2a>

0000000080002516 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002516:	715d                	addi	sp,sp,-80
    80002518:	e486                	sd	ra,72(sp)
    8000251a:	e0a2                	sd	s0,64(sp)
    8000251c:	fc26                	sd	s1,56(sp)
    8000251e:	f84a                	sd	s2,48(sp)
    80002520:	f44e                	sd	s3,40(sp)
    80002522:	f052                	sd	s4,32(sp)
    80002524:	ec56                	sd	s5,24(sp)
    80002526:	e85a                	sd	s6,16(sp)
    80002528:	e45e                	sd	s7,8(sp)
    8000252a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000252c:	00005517          	auipc	a0,0x5
    80002530:	b4c50513          	addi	a0,a0,-1204 # 80007078 <etext+0x78>
    80002534:	f8ffd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002538:	0000e497          	auipc	s1,0xe
    8000253c:	ab048493          	addi	s1,s1,-1360 # 8000ffe8 <proc+0x158>
    80002540:	00014917          	auipc	s2,0x14
    80002544:	8a890913          	addi	s2,s2,-1880 # 80015de8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002548:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000254a:	00005997          	auipc	s3,0x5
    8000254e:	d5698993          	addi	s3,s3,-682 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002552:	00005a97          	auipc	s5,0x5
    80002556:	d56a8a93          	addi	s5,s5,-682 # 800072a8 <etext+0x2a8>
    printf("\n");
    8000255a:	00005a17          	auipc	s4,0x5
    8000255e:	b1ea0a13          	addi	s4,s4,-1250 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002562:	00005b97          	auipc	s7,0x5
    80002566:	226b8b93          	addi	s7,s7,550 # 80007788 <states.0>
    8000256a:	a829                	j	80002584 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000256c:	ed86a583          	lw	a1,-296(a3)
    80002570:	8556                	mv	a0,s5
    80002572:	f51fd0ef          	jal	800004c2 <printf>
    printf("\n");
    80002576:	8552                	mv	a0,s4
    80002578:	f4bfd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257c:	17848493          	addi	s1,s1,376
    80002580:	03248263          	beq	s1,s2,800025a4 <procdump+0x8e>
    if(p->state == UNUSED)
    80002584:	86a6                	mv	a3,s1
    80002586:	ec04a783          	lw	a5,-320(s1)
    8000258a:	dbed                	beqz	a5,8000257c <procdump+0x66>
      state = "???";
    8000258c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258e:	fcfb6fe3          	bltu	s6,a5,8000256c <procdump+0x56>
    80002592:	02079713          	slli	a4,a5,0x20
    80002596:	01d75793          	srli	a5,a4,0x1d
    8000259a:	97de                	add	a5,a5,s7
    8000259c:	6390                	ld	a2,0(a5)
    8000259e:	f679                	bnez	a2,8000256c <procdump+0x56>
      state = "???";
    800025a0:	864e                	mv	a2,s3
    800025a2:	b7e9                	j	8000256c <procdump+0x56>
  }
}
    800025a4:	60a6                	ld	ra,72(sp)
    800025a6:	6406                	ld	s0,64(sp)
    800025a8:	74e2                	ld	s1,56(sp)
    800025aa:	7942                	ld	s2,48(sp)
    800025ac:	79a2                	ld	s3,40(sp)
    800025ae:	7a02                	ld	s4,32(sp)
    800025b0:	6ae2                	ld	s5,24(sp)
    800025b2:	6b42                	ld	s6,16(sp)
    800025b4:	6ba2                	ld	s7,8(sp)
    800025b6:	6161                	addi	sp,sp,80
    800025b8:	8082                	ret

00000000800025ba <swtch>:
    800025ba:	00153023          	sd	ra,0(a0)
    800025be:	00253423          	sd	sp,8(a0)
    800025c2:	e900                	sd	s0,16(a0)
    800025c4:	ed04                	sd	s1,24(a0)
    800025c6:	03253023          	sd	s2,32(a0)
    800025ca:	03353423          	sd	s3,40(a0)
    800025ce:	03453823          	sd	s4,48(a0)
    800025d2:	03553c23          	sd	s5,56(a0)
    800025d6:	05653023          	sd	s6,64(a0)
    800025da:	05753423          	sd	s7,72(a0)
    800025de:	05853823          	sd	s8,80(a0)
    800025e2:	05953c23          	sd	s9,88(a0)
    800025e6:	07a53023          	sd	s10,96(a0)
    800025ea:	07b53423          	sd	s11,104(a0)
    800025ee:	0005b083          	ld	ra,0(a1)
    800025f2:	0085b103          	ld	sp,8(a1)
    800025f6:	6980                	ld	s0,16(a1)
    800025f8:	6d84                	ld	s1,24(a1)
    800025fa:	0205b903          	ld	s2,32(a1)
    800025fe:	0285b983          	ld	s3,40(a1)
    80002602:	0305ba03          	ld	s4,48(a1)
    80002606:	0385ba83          	ld	s5,56(a1)
    8000260a:	0405bb03          	ld	s6,64(a1)
    8000260e:	0485bb83          	ld	s7,72(a1)
    80002612:	0505bc03          	ld	s8,80(a1)
    80002616:	0585bc83          	ld	s9,88(a1)
    8000261a:	0605bd03          	ld	s10,96(a1)
    8000261e:	0685bd83          	ld	s11,104(a1)
    80002622:	8082                	ret

0000000080002624 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002624:	1141                	addi	sp,sp,-16
    80002626:	e406                	sd	ra,8(sp)
    80002628:	e022                	sd	s0,0(sp)
    8000262a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000262c:	00005597          	auipc	a1,0x5
    80002630:	cbc58593          	addi	a1,a1,-836 # 800072e8 <etext+0x2e8>
    80002634:	00013517          	auipc	a0,0x13
    80002638:	65c50513          	addi	a0,a0,1628 # 80015c90 <tickslock>
    8000263c:	d38fe0ef          	jal	80000b74 <initlock>
}
    80002640:	60a2                	ld	ra,8(sp)
    80002642:	6402                	ld	s0,0(sp)
    80002644:	0141                	addi	sp,sp,16
    80002646:	8082                	ret

0000000080002648 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002648:	1141                	addi	sp,sp,-16
    8000264a:	e422                	sd	s0,8(sp)
    8000264c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000264e:	00003797          	auipc	a5,0x3
    80002652:	f6278793          	addi	a5,a5,-158 # 800055b0 <kernelvec>
    80002656:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000265a:	6422                	ld	s0,8(sp)
    8000265c:	0141                	addi	sp,sp,16
    8000265e:	8082                	ret

0000000080002660 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002660:	1141                	addi	sp,sp,-16
    80002662:	e406                	sd	ra,8(sp)
    80002664:	e022                	sd	s0,0(sp)
    80002666:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002668:	a78ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002670:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002672:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002676:	00004697          	auipc	a3,0x4
    8000267a:	98a68693          	addi	a3,a3,-1654 # 80006000 <_trampoline>
    8000267e:	00004717          	auipc	a4,0x4
    80002682:	98270713          	addi	a4,a4,-1662 # 80006000 <_trampoline>
    80002686:	8f15                	sub	a4,a4,a3
    80002688:	040007b7          	lui	a5,0x4000
    8000268c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000268e:	07b2                	slli	a5,a5,0xc
    80002690:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002692:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002696:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002698:	18002673          	csrr	a2,satp
    8000269c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000269e:	6d30                	ld	a2,88(a0)
    800026a0:	6138                	ld	a4,64(a0)
    800026a2:	6585                	lui	a1,0x1
    800026a4:	972e                	add	a4,a4,a1
    800026a6:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026a8:	6d38                	ld	a4,88(a0)
    800026aa:	00000617          	auipc	a2,0x0
    800026ae:	14060613          	addi	a2,a2,320 # 800027ea <usertrap>
    800026b2:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026b4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026b6:	8612                	mv	a2,tp
    800026b8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ba:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026be:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026c2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026c6:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026ca:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026cc:	6f18                	ld	a4,24(a4)
    800026ce:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026d2:	6928                	ld	a0,80(a0)
    800026d4:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026d6:	00004717          	auipc	a4,0x4
    800026da:	9c670713          	addi	a4,a4,-1594 # 8000609c <userret>
    800026de:	8f15                	sub	a4,a4,a3
    800026e0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026e2:	577d                	li	a4,-1
    800026e4:	177e                	slli	a4,a4,0x3f
    800026e6:	8d59                	or	a0,a0,a4
    800026e8:	9782                	jalr	a5
}
    800026ea:	60a2                	ld	ra,8(sp)
    800026ec:	6402                	ld	s0,0(sp)
    800026ee:	0141                	addi	sp,sp,16
    800026f0:	8082                	ret

00000000800026f2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026f2:	1141                	addi	sp,sp,-16
    800026f4:	e406                	sd	ra,8(sp)
    800026f6:	e022                	sd	s0,0(sp)
    800026f8:	0800                	addi	s0,sp,16

  if(cpuid() == 0){
    800026fa:	9baff0ef          	jal	800018b4 <cpuid>
    800026fe:	cd11                	beqz	a0,8000271a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002700:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002704:	000f4737          	lui	a4,0xf4
    80002708:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000270c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000270e:	14d79073          	csrw	stimecmp,a5
}
    80002712:	60a2                	ld	ra,8(sp)
    80002714:	6402                	ld	s0,0(sp)
    80002716:	0141                	addi	sp,sp,16
    80002718:	8082                	ret
    acquire(&tickslock);
    8000271a:	00013517          	auipc	a0,0x13
    8000271e:	57650513          	addi	a0,a0,1398 # 80015c90 <tickslock>
    80002722:	cd2fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002726:	00005717          	auipc	a4,0x5
    8000272a:	21270713          	addi	a4,a4,530 # 80007938 <ticks>
    8000272e:	431c                	lw	a5,0(a4)
    80002730:	2785                	addiw	a5,a5,1
    80002732:	0007869b          	sext.w	a3,a5
    80002736:	c31c                	sw	a5,0(a4)
    if (ticks == 50 && sched_mode == 1) { // MLFQ mode 안에서 tick이 50이 될 때마다
    80002738:	03200793          	li	a5,50
    8000273c:	00f68f63          	beq	a3,a5,8000275a <clockintr+0x68>
    wakeup(&ticks);
    80002740:	00005517          	auipc	a0,0x5
    80002744:	1f850513          	addi	a0,a0,504 # 80007938 <ticks>
    80002748:	a2bff0ef          	jal	80002172 <wakeup>
    release(&tickslock);
    8000274c:	00013517          	auipc	a0,0x13
    80002750:	54450513          	addi	a0,a0,1348 # 80015c90 <tickslock>
    80002754:	d38fe0ef          	jal	80000c8c <release>
    80002758:	b765                	j	80002700 <clockintr+0xe>
    if (ticks == 50 && sched_mode == 1) { // MLFQ mode 안에서 tick이 50이 될 때마다
    8000275a:	00005717          	auipc	a4,0x5
    8000275e:	1ce72703          	lw	a4,462(a4) # 80007928 <sched_mode>
    80002762:	4785                	li	a5,1
    80002764:	fcf71ee3          	bne	a4,a5,80002740 <clockintr+0x4e>
      ticks = 0;
    80002768:	00005797          	auipc	a5,0x5
    8000276c:	1c07a823          	sw	zero,464(a5) # 80007938 <ticks>
      priority_boosting();
    80002770:	f34ff0ef          	jal	80001ea4 <priority_boosting>
    80002774:	b7f1                	j	80002740 <clockintr+0x4e>

0000000080002776 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002776:	1101                	addi	sp,sp,-32
    80002778:	ec06                	sd	ra,24(sp)
    8000277a:	e822                	sd	s0,16(sp)
    8000277c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000277e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002782:	57fd                	li	a5,-1
    80002784:	17fe                	slli	a5,a5,0x3f
    80002786:	07a5                	addi	a5,a5,9
    80002788:	00f70c63          	beq	a4,a5,800027a0 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000278c:	57fd                	li	a5,-1
    8000278e:	17fe                	slli	a5,a5,0x3f
    80002790:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002792:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002794:	04f70763          	beq	a4,a5,800027e2 <devintr+0x6c>
  }
}
    80002798:	60e2                	ld	ra,24(sp)
    8000279a:	6442                	ld	s0,16(sp)
    8000279c:	6105                	addi	sp,sp,32
    8000279e:	8082                	ret
    800027a0:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800027a2:	6bb020ef          	jal	8000565c <plic_claim>
    800027a6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027a8:	47a9                	li	a5,10
    800027aa:	00f50963          	beq	a0,a5,800027bc <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800027ae:	4785                	li	a5,1
    800027b0:	00f50963          	beq	a0,a5,800027c2 <devintr+0x4c>
    return 1;
    800027b4:	4505                	li	a0,1
    } else if(irq){
    800027b6:	e889                	bnez	s1,800027c8 <devintr+0x52>
    800027b8:	64a2                	ld	s1,8(sp)
    800027ba:	bff9                	j	80002798 <devintr+0x22>
      uartintr();
    800027bc:	a4afe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800027c0:	a819                	j	800027d6 <devintr+0x60>
      virtio_disk_intr();
    800027c2:	360030ef          	jal	80005b22 <virtio_disk_intr>
    if(irq)
    800027c6:	a801                	j	800027d6 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800027c8:	85a6                	mv	a1,s1
    800027ca:	00005517          	auipc	a0,0x5
    800027ce:	b2650513          	addi	a0,a0,-1242 # 800072f0 <etext+0x2f0>
    800027d2:	cf1fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800027d6:	8526                	mv	a0,s1
    800027d8:	6a5020ef          	jal	8000567c <plic_complete>
    return 1;
    800027dc:	4505                	li	a0,1
    800027de:	64a2                	ld	s1,8(sp)
    800027e0:	bf65                	j	80002798 <devintr+0x22>
    clockintr();
    800027e2:	f11ff0ef          	jal	800026f2 <clockintr>
    return 2;
    800027e6:	4509                	li	a0,2
    800027e8:	bf45                	j	80002798 <devintr+0x22>

00000000800027ea <usertrap>:
{
    800027ea:	1101                	addi	sp,sp,-32
    800027ec:	ec06                	sd	ra,24(sp)
    800027ee:	e822                	sd	s0,16(sp)
    800027f0:	e426                	sd	s1,8(sp)
    800027f2:	e04a                	sd	s2,0(sp)
    800027f4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027fa:	1007f793          	andi	a5,a5,256
    800027fe:	ef85                	bnez	a5,80002836 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002800:	00003797          	auipc	a5,0x3
    80002804:	db078793          	addi	a5,a5,-592 # 800055b0 <kernelvec>
    80002808:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000280c:	8d4ff0ef          	jal	800018e0 <myproc>
    80002810:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002812:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002814:	14102773          	csrr	a4,sepc
    80002818:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000281a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000281e:	47a1                	li	a5,8
    80002820:	02f70163          	beq	a4,a5,80002842 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002824:	f53ff0ef          	jal	80002776 <devintr>
    80002828:	892a                	mv	s2,a0
    8000282a:	c939                	beqz	a0,80002880 <usertrap+0x96>
  if(killed(p))
    8000282c:	8526                	mv	a0,s1
    8000282e:	b31ff0ef          	jal	8000235e <killed>
    80002832:	c151                	beqz	a0,800028b6 <usertrap+0xcc>
    80002834:	a8b5                	j	800028b0 <usertrap+0xc6>
    panic("usertrap: not from user mode");
    80002836:	00005517          	auipc	a0,0x5
    8000283a:	ada50513          	addi	a0,a0,-1318 # 80007310 <etext+0x310>
    8000283e:	f57fd0ef          	jal	80000794 <panic>
    if(killed(p))
    80002842:	b1dff0ef          	jal	8000235e <killed>
    80002846:	e90d                	bnez	a0,80002878 <usertrap+0x8e>
    p->trapframe->epc += 4;
    80002848:	6cb8                	ld	a4,88(s1)
    8000284a:	6f1c                	ld	a5,24(a4)
    8000284c:	0791                	addi	a5,a5,4
    8000284e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002850:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002854:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002858:	10079073          	csrw	sstatus,a5
    syscall();
    8000285c:	2f2000ef          	jal	80002b4e <syscall>
  if(killed(p))
    80002860:	8526                	mv	a0,s1
    80002862:	afdff0ef          	jal	8000235e <killed>
    80002866:	e521                	bnez	a0,800028ae <usertrap+0xc4>
  usertrapret();
    80002868:	df9ff0ef          	jal	80002660 <usertrapret>
}
    8000286c:	60e2                	ld	ra,24(sp)
    8000286e:	6442                	ld	s0,16(sp)
    80002870:	64a2                	ld	s1,8(sp)
    80002872:	6902                	ld	s2,0(sp)
    80002874:	6105                	addi	sp,sp,32
    80002876:	8082                	ret
      exit(-1);
    80002878:	557d                	li	a0,-1
    8000287a:	9b9ff0ef          	jal	80002232 <exit>
    8000287e:	b7e9                	j	80002848 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002880:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002884:	5890                	lw	a2,48(s1)
    80002886:	00005517          	auipc	a0,0x5
    8000288a:	aaa50513          	addi	a0,a0,-1366 # 80007330 <etext+0x330>
    8000288e:	c35fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002892:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002896:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000289a:	00005517          	auipc	a0,0x5
    8000289e:	ac650513          	addi	a0,a0,-1338 # 80007360 <etext+0x360>
    800028a2:	c21fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    800028a6:	8526                	mv	a0,s1
    800028a8:	a93ff0ef          	jal	8000233a <setkilled>
    800028ac:	bf55                	j	80002860 <usertrap+0x76>
  if(killed(p))
    800028ae:	4901                	li	s2,0
    exit(-1);
    800028b0:	557d                	li	a0,-1
    800028b2:	981ff0ef          	jal	80002232 <exit>
  if(which_dev == 2){
    800028b6:	4789                	li	a5,2
    800028b8:	faf918e3          	bne	s2,a5,80002868 <usertrap+0x7e>
    if(sched_mode == 1){
    800028bc:	00005717          	auipc	a4,0x5
    800028c0:	06c72703          	lw	a4,108(a4) # 80007928 <sched_mode>
    800028c4:	4785                	li	a5,1
    800028c6:	00f70563          	beq	a4,a5,800028d0 <usertrap+0xe6>
    yield();
    800028ca:	831ff0ef          	jal	800020fa <yield>
    800028ce:	bf69                	j	80002868 <usertrap+0x7e>
      p->tq++;
    800028d0:	1704a703          	lw	a4,368(s1)
    800028d4:	0017079b          	addiw	a5,a4,1
    800028d8:	16f4a823          	sw	a5,368(s1)
      if(p->tq == (p->lv)*2 + 1){
    800028dc:	16c4a783          	lw	a5,364(s1)
    800028e0:	0017969b          	slliw	a3,a5,0x1
    800028e4:	fee693e3          	bne	a3,a4,800028ca <usertrap+0xe0>
        if(p->lv == 2){
    800028e8:	4709                	li	a4,2
    800028ea:	00e78e63          	beq	a5,a4,80002906 <usertrap+0x11c>
          p->time = ticks;
    800028ee:	00005717          	auipc	a4,0x5
    800028f2:	04a72703          	lw	a4,74(a4) # 80007938 <ticks>
    800028f6:	16e4aa23          	sw	a4,372(s1)
          p->lv++;
    800028fa:	2785                	addiw	a5,a5,1
    800028fc:	16f4a623          	sw	a5,364(s1)
        p->tq = 0;
    80002900:	1604a823          	sw	zero,368(s1)
    80002904:	b7d9                	j	800028ca <usertrap+0xe0>
          setpriority(p->pid, (p->pr) - 1);
    80002906:	1684a583          	lw	a1,360(s1)
    8000290a:	35fd                	addiw	a1,a1,-1 # fff <_entry-0x7ffff001>
    8000290c:	5888                	lw	a0,48(s1)
    8000290e:	dd4ff0ef          	jal	80001ee2 <setpriority>
    80002912:	b7fd                	j	80002900 <usertrap+0x116>

0000000080002914 <kerneltrap>:
{
    80002914:	7179                	addi	sp,sp,-48
    80002916:	f406                	sd	ra,40(sp)
    80002918:	f022                	sd	s0,32(sp)
    8000291a:	ec26                	sd	s1,24(sp)
    8000291c:	e84a                	sd	s2,16(sp)
    8000291e:	e44e                	sd	s3,8(sp)
    80002920:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002922:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002926:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000292a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000292e:	1004f793          	andi	a5,s1,256
    80002932:	c795                	beqz	a5,8000295e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002934:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002938:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000293a:	eb85                	bnez	a5,8000296a <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000293c:	e3bff0ef          	jal	80002776 <devintr>
    80002940:	c91d                	beqz	a0,80002976 <kerneltrap+0x62>
  if(which_dev == 2  && myproc() != 0){
    80002942:	4789                	li	a5,2
    80002944:	04f50a63          	beq	a0,a5,80002998 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002948:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000294c:	10049073          	csrw	sstatus,s1
}
    80002950:	70a2                	ld	ra,40(sp)
    80002952:	7402                	ld	s0,32(sp)
    80002954:	64e2                	ld	s1,24(sp)
    80002956:	6942                	ld	s2,16(sp)
    80002958:	69a2                	ld	s3,8(sp)
    8000295a:	6145                	addi	sp,sp,48
    8000295c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000295e:	00005517          	auipc	a0,0x5
    80002962:	a2a50513          	addi	a0,a0,-1494 # 80007388 <etext+0x388>
    80002966:	e2ffd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    8000296a:	00005517          	auipc	a0,0x5
    8000296e:	a4650513          	addi	a0,a0,-1466 # 800073b0 <etext+0x3b0>
    80002972:	e23fd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002976:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000297e:	85ce                	mv	a1,s3
    80002980:	00005517          	auipc	a0,0x5
    80002984:	a5050513          	addi	a0,a0,-1456 # 800073d0 <etext+0x3d0>
    80002988:	b3bfd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    8000298c:	00005517          	auipc	a0,0x5
    80002990:	a6c50513          	addi	a0,a0,-1428 # 800073f8 <etext+0x3f8>
    80002994:	e01fd0ef          	jal	80000794 <panic>
  if(which_dev == 2  && myproc() != 0){
    80002998:	f49fe0ef          	jal	800018e0 <myproc>
    8000299c:	d555                	beqz	a0,80002948 <kerneltrap+0x34>
    struct proc *p = myproc();
    8000299e:	f43fe0ef          	jal	800018e0 <myproc>
    800029a2:	89aa                	mv	s3,a0
    if(sched_mode == 1){
    800029a4:	00005717          	auipc	a4,0x5
    800029a8:	f8472703          	lw	a4,-124(a4) # 80007928 <sched_mode>
    800029ac:	4785                	li	a5,1
    800029ae:	00f70563          	beq	a4,a5,800029b8 <kerneltrap+0xa4>
    yield();
    800029b2:	f48ff0ef          	jal	800020fa <yield>
    800029b6:	bf49                	j	80002948 <kerneltrap+0x34>
      p->tq++;
    800029b8:	17052703          	lw	a4,368(a0)
    800029bc:	0017079b          	addiw	a5,a4,1
    800029c0:	16f52823          	sw	a5,368(a0)
      if(p->tq == (p->lv)*2 + 1){
    800029c4:	16c52783          	lw	a5,364(a0)
    800029c8:	0017969b          	slliw	a3,a5,0x1
    800029cc:	fee693e3          	bne	a3,a4,800029b2 <kerneltrap+0x9e>
        if(p->lv == 2){
    800029d0:	4709                	li	a4,2
    800029d2:	00e78e63          	beq	a5,a4,800029ee <kerneltrap+0xda>
          p->lv++;
    800029d6:	2785                	addiw	a5,a5,1
    800029d8:	16f52623          	sw	a5,364(a0)
          p->time = ticks;
    800029dc:	00005797          	auipc	a5,0x5
    800029e0:	f5c7a783          	lw	a5,-164(a5) # 80007938 <ticks>
    800029e4:	16f52a23          	sw	a5,372(a0)
        p->tq = 0;
    800029e8:	1609a823          	sw	zero,368(s3)
    800029ec:	b7d9                	j	800029b2 <kerneltrap+0x9e>
          setpriority(p->pid, (p->pr) - 1);
    800029ee:	16852583          	lw	a1,360(a0)
    800029f2:	35fd                	addiw	a1,a1,-1
    800029f4:	5908                	lw	a0,48(a0)
    800029f6:	cecff0ef          	jal	80001ee2 <setpriority>
    800029fa:	b7fd                	j	800029e8 <kerneltrap+0xd4>

00000000800029fc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029fc:	1101                	addi	sp,sp,-32
    800029fe:	ec06                	sd	ra,24(sp)
    80002a00:	e822                	sd	s0,16(sp)
    80002a02:	e426                	sd	s1,8(sp)
    80002a04:	1000                	addi	s0,sp,32
    80002a06:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a08:	ed9fe0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002a0c:	4795                	li	a5,5
    80002a0e:	0497e163          	bltu	a5,s1,80002a50 <argraw+0x54>
    80002a12:	048a                	slli	s1,s1,0x2
    80002a14:	00005717          	auipc	a4,0x5
    80002a18:	da470713          	addi	a4,a4,-604 # 800077b8 <states.0+0x30>
    80002a1c:	94ba                	add	s1,s1,a4
    80002a1e:	409c                	lw	a5,0(s1)
    80002a20:	97ba                	add	a5,a5,a4
    80002a22:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a24:	6d3c                	ld	a5,88(a0)
    80002a26:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	64a2                	ld	s1,8(sp)
    80002a2e:	6105                	addi	sp,sp,32
    80002a30:	8082                	ret
    return p->trapframe->a1;
    80002a32:	6d3c                	ld	a5,88(a0)
    80002a34:	7fa8                	ld	a0,120(a5)
    80002a36:	bfcd                	j	80002a28 <argraw+0x2c>
    return p->trapframe->a2;
    80002a38:	6d3c                	ld	a5,88(a0)
    80002a3a:	63c8                	ld	a0,128(a5)
    80002a3c:	b7f5                	j	80002a28 <argraw+0x2c>
    return p->trapframe->a3;
    80002a3e:	6d3c                	ld	a5,88(a0)
    80002a40:	67c8                	ld	a0,136(a5)
    80002a42:	b7dd                	j	80002a28 <argraw+0x2c>
    return p->trapframe->a4;
    80002a44:	6d3c                	ld	a5,88(a0)
    80002a46:	6bc8                	ld	a0,144(a5)
    80002a48:	b7c5                	j	80002a28 <argraw+0x2c>
    return p->trapframe->a5;
    80002a4a:	6d3c                	ld	a5,88(a0)
    80002a4c:	6fc8                	ld	a0,152(a5)
    80002a4e:	bfe9                	j	80002a28 <argraw+0x2c>
  panic("argraw");
    80002a50:	00005517          	auipc	a0,0x5
    80002a54:	9b850513          	addi	a0,a0,-1608 # 80007408 <etext+0x408>
    80002a58:	d3dfd0ef          	jal	80000794 <panic>

0000000080002a5c <fetchaddr>:
{
    80002a5c:	1101                	addi	sp,sp,-32
    80002a5e:	ec06                	sd	ra,24(sp)
    80002a60:	e822                	sd	s0,16(sp)
    80002a62:	e426                	sd	s1,8(sp)
    80002a64:	e04a                	sd	s2,0(sp)
    80002a66:	1000                	addi	s0,sp,32
    80002a68:	84aa                	mv	s1,a0
    80002a6a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a6c:	e75fe0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a70:	653c                	ld	a5,72(a0)
    80002a72:	02f4f663          	bgeu	s1,a5,80002a9e <fetchaddr+0x42>
    80002a76:	00848713          	addi	a4,s1,8
    80002a7a:	02e7e463          	bltu	a5,a4,80002aa2 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a7e:	46a1                	li	a3,8
    80002a80:	8626                	mv	a2,s1
    80002a82:	85ca                	mv	a1,s2
    80002a84:	6928                	ld	a0,80(a0)
    80002a86:	ba3fe0ef          	jal	80001628 <copyin>
    80002a8a:	00a03533          	snez	a0,a0
    80002a8e:	40a00533          	neg	a0,a0
}
    80002a92:	60e2                	ld	ra,24(sp)
    80002a94:	6442                	ld	s0,16(sp)
    80002a96:	64a2                	ld	s1,8(sp)
    80002a98:	6902                	ld	s2,0(sp)
    80002a9a:	6105                	addi	sp,sp,32
    80002a9c:	8082                	ret
    return -1;
    80002a9e:	557d                	li	a0,-1
    80002aa0:	bfcd                	j	80002a92 <fetchaddr+0x36>
    80002aa2:	557d                	li	a0,-1
    80002aa4:	b7fd                	j	80002a92 <fetchaddr+0x36>

0000000080002aa6 <fetchstr>:
{
    80002aa6:	7179                	addi	sp,sp,-48
    80002aa8:	f406                	sd	ra,40(sp)
    80002aaa:	f022                	sd	s0,32(sp)
    80002aac:	ec26                	sd	s1,24(sp)
    80002aae:	e84a                	sd	s2,16(sp)
    80002ab0:	e44e                	sd	s3,8(sp)
    80002ab2:	1800                	addi	s0,sp,48
    80002ab4:	892a                	mv	s2,a0
    80002ab6:	84ae                	mv	s1,a1
    80002ab8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002aba:	e27fe0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002abe:	86ce                	mv	a3,s3
    80002ac0:	864a                	mv	a2,s2
    80002ac2:	85a6                	mv	a1,s1
    80002ac4:	6928                	ld	a0,80(a0)
    80002ac6:	be9fe0ef          	jal	800016ae <copyinstr>
    80002aca:	00054c63          	bltz	a0,80002ae2 <fetchstr+0x3c>
  return strlen(buf);
    80002ace:	8526                	mv	a0,s1
    80002ad0:	b68fe0ef          	jal	80000e38 <strlen>
}
    80002ad4:	70a2                	ld	ra,40(sp)
    80002ad6:	7402                	ld	s0,32(sp)
    80002ad8:	64e2                	ld	s1,24(sp)
    80002ada:	6942                	ld	s2,16(sp)
    80002adc:	69a2                	ld	s3,8(sp)
    80002ade:	6145                	addi	sp,sp,48
    80002ae0:	8082                	ret
    return -1;
    80002ae2:	557d                	li	a0,-1
    80002ae4:	bfc5                	j	80002ad4 <fetchstr+0x2e>

0000000080002ae6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	1000                	addi	s0,sp,32
    80002af0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af2:	f0bff0ef          	jal	800029fc <argraw>
    80002af6:	c088                	sw	a0,0(s1)
}
    80002af8:	60e2                	ld	ra,24(sp)
    80002afa:	6442                	ld	s0,16(sp)
    80002afc:	64a2                	ld	s1,8(sp)
    80002afe:	6105                	addi	sp,sp,32
    80002b00:	8082                	ret

0000000080002b02 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b02:	1101                	addi	sp,sp,-32
    80002b04:	ec06                	sd	ra,24(sp)
    80002b06:	e822                	sd	s0,16(sp)
    80002b08:	e426                	sd	s1,8(sp)
    80002b0a:	1000                	addi	s0,sp,32
    80002b0c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b0e:	eefff0ef          	jal	800029fc <argraw>
    80002b12:	e088                	sd	a0,0(s1)
}
    80002b14:	60e2                	ld	ra,24(sp)
    80002b16:	6442                	ld	s0,16(sp)
    80002b18:	64a2                	ld	s1,8(sp)
    80002b1a:	6105                	addi	sp,sp,32
    80002b1c:	8082                	ret

0000000080002b1e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b1e:	7179                	addi	sp,sp,-48
    80002b20:	f406                	sd	ra,40(sp)
    80002b22:	f022                	sd	s0,32(sp)
    80002b24:	ec26                	sd	s1,24(sp)
    80002b26:	e84a                	sd	s2,16(sp)
    80002b28:	1800                	addi	s0,sp,48
    80002b2a:	84ae                	mv	s1,a1
    80002b2c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b2e:	fd840593          	addi	a1,s0,-40
    80002b32:	fd1ff0ef          	jal	80002b02 <argaddr>
  return fetchstr(addr, buf, max);
    80002b36:	864a                	mv	a2,s2
    80002b38:	85a6                	mv	a1,s1
    80002b3a:	fd843503          	ld	a0,-40(s0)
    80002b3e:	f69ff0ef          	jal	80002aa6 <fetchstr>
}
    80002b42:	70a2                	ld	ra,40(sp)
    80002b44:	7402                	ld	s0,32(sp)
    80002b46:	64e2                	ld	s1,24(sp)
    80002b48:	6942                	ld	s2,16(sp)
    80002b4a:	6145                	addi	sp,sp,48
    80002b4c:	8082                	ret

0000000080002b4e <syscall>:
[SYS_fcfsmode]   sys_fcfsmode,
};

void
syscall(void)
{
    80002b4e:	1101                	addi	sp,sp,-32
    80002b50:	ec06                	sd	ra,24(sp)
    80002b52:	e822                	sd	s0,16(sp)
    80002b54:	e426                	sd	s1,8(sp)
    80002b56:	e04a                	sd	s2,0(sp)
    80002b58:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b5a:	d87fe0ef          	jal	800018e0 <myproc>
    80002b5e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b60:	05853903          	ld	s2,88(a0)
    80002b64:	0a893783          	ld	a5,168(s2)
    80002b68:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b6c:	37fd                	addiw	a5,a5,-1
    80002b6e:	4765                	li	a4,25
    80002b70:	00f76f63          	bltu	a4,a5,80002b8e <syscall+0x40>
    80002b74:	00369713          	slli	a4,a3,0x3
    80002b78:	00005797          	auipc	a5,0x5
    80002b7c:	c5878793          	addi	a5,a5,-936 # 800077d0 <syscalls>
    80002b80:	97ba                	add	a5,a5,a4
    80002b82:	639c                	ld	a5,0(a5)
    80002b84:	c789                	beqz	a5,80002b8e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b86:	9782                	jalr	a5
    80002b88:	06a93823          	sd	a0,112(s2)
    80002b8c:	a829                	j	80002ba6 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b8e:	15848613          	addi	a2,s1,344
    80002b92:	588c                	lw	a1,48(s1)
    80002b94:	00005517          	auipc	a0,0x5
    80002b98:	87c50513          	addi	a0,a0,-1924 # 80007410 <etext+0x410>
    80002b9c:	927fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ba0:	6cbc                	ld	a5,88(s1)
    80002ba2:	577d                	li	a4,-1
    80002ba4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba6:	60e2                	ld	ra,24(sp)
    80002ba8:	6442                	ld	s0,16(sp)
    80002baa:	64a2                	ld	s1,8(sp)
    80002bac:	6902                	ld	s2,0(sp)
    80002bae:	6105                	addi	sp,sp,32
    80002bb0:	8082                	ret

0000000080002bb2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bb2:	1101                	addi	sp,sp,-32
    80002bb4:	ec06                	sd	ra,24(sp)
    80002bb6:	e822                	sd	s0,16(sp)
    80002bb8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bba:	fec40593          	addi	a1,s0,-20
    80002bbe:	4501                	li	a0,0
    80002bc0:	f27ff0ef          	jal	80002ae6 <argint>
  exit(n);
    80002bc4:	fec42503          	lw	a0,-20(s0)
    80002bc8:	e6aff0ef          	jal	80002232 <exit>
  return 0;  // not reached
}
    80002bcc:	4501                	li	a0,0
    80002bce:	60e2                	ld	ra,24(sp)
    80002bd0:	6442                	ld	s0,16(sp)
    80002bd2:	6105                	addi	sp,sp,32
    80002bd4:	8082                	ret

0000000080002bd6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd6:	1141                	addi	sp,sp,-16
    80002bd8:	e406                	sd	ra,8(sp)
    80002bda:	e022                	sd	s0,0(sp)
    80002bdc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bde:	d03fe0ef          	jal	800018e0 <myproc>
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
    80002bf4:	82cff0ef          	jal	80001c20 <fork>
}
    80002bf8:	60a2                	ld	ra,8(sp)
    80002bfa:	6402                	ld	s0,0(sp)
    80002bfc:	0141                	addi	sp,sp,16
    80002bfe:	8082                	ret

0000000080002c00 <sys_wait>:

uint64
sys_wait(void)
{
    80002c00:	1101                	addi	sp,sp,-32
    80002c02:	ec06                	sd	ra,24(sp)
    80002c04:	e822                	sd	s0,16(sp)
    80002c06:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c08:	fe840593          	addi	a1,s0,-24
    80002c0c:	4501                	li	a0,0
    80002c0e:	ef5ff0ef          	jal	80002b02 <argaddr>
  return wait(p);
    80002c12:	fe843503          	ld	a0,-24(s0)
    80002c16:	f72ff0ef          	jal	80002388 <wait>
}
    80002c1a:	60e2                	ld	ra,24(sp)
    80002c1c:	6442                	ld	s0,16(sp)
    80002c1e:	6105                	addi	sp,sp,32
    80002c20:	8082                	ret

0000000080002c22 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c22:	7179                	addi	sp,sp,-48
    80002c24:	f406                	sd	ra,40(sp)
    80002c26:	f022                	sd	s0,32(sp)
    80002c28:	ec26                	sd	s1,24(sp)
    80002c2a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c2c:	fdc40593          	addi	a1,s0,-36
    80002c30:	4501                	li	a0,0
    80002c32:	eb5ff0ef          	jal	80002ae6 <argint>
  addr = myproc()->sz;
    80002c36:	cabfe0ef          	jal	800018e0 <myproc>
    80002c3a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c3c:	fdc42503          	lw	a0,-36(s0)
    80002c40:	f91fe0ef          	jal	80001bd0 <growproc>
    80002c44:	00054863          	bltz	a0,80002c54 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002c48:	8526                	mv	a0,s1
    80002c4a:	70a2                	ld	ra,40(sp)
    80002c4c:	7402                	ld	s0,32(sp)
    80002c4e:	64e2                	ld	s1,24(sp)
    80002c50:	6145                	addi	sp,sp,48
    80002c52:	8082                	ret
    return -1;
    80002c54:	54fd                	li	s1,-1
    80002c56:	bfcd                	j	80002c48 <sys_sbrk+0x26>

0000000080002c58 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c58:	7139                	addi	sp,sp,-64
    80002c5a:	fc06                	sd	ra,56(sp)
    80002c5c:	f822                	sd	s0,48(sp)
    80002c5e:	f04a                	sd	s2,32(sp)
    80002c60:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c62:	fcc40593          	addi	a1,s0,-52
    80002c66:	4501                	li	a0,0
    80002c68:	e7fff0ef          	jal	80002ae6 <argint>
  if(n < 0)
    80002c6c:	fcc42783          	lw	a5,-52(s0)
    80002c70:	0607c763          	bltz	a5,80002cde <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002c74:	00013517          	auipc	a0,0x13
    80002c78:	01c50513          	addi	a0,a0,28 # 80015c90 <tickslock>
    80002c7c:	f79fd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002c80:	00005917          	auipc	s2,0x5
    80002c84:	cb892903          	lw	s2,-840(s2) # 80007938 <ticks>
  while(ticks - ticks0 < n){
    80002c88:	fcc42783          	lw	a5,-52(s0)
    80002c8c:	cf8d                	beqz	a5,80002cc6 <sys_sleep+0x6e>
    80002c8e:	f426                	sd	s1,40(sp)
    80002c90:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c92:	00013997          	auipc	s3,0x13
    80002c96:	ffe98993          	addi	s3,s3,-2 # 80015c90 <tickslock>
    80002c9a:	00005497          	auipc	s1,0x5
    80002c9e:	c9e48493          	addi	s1,s1,-866 # 80007938 <ticks>
    if(killed(myproc())){
    80002ca2:	c3ffe0ef          	jal	800018e0 <myproc>
    80002ca6:	eb8ff0ef          	jal	8000235e <killed>
    80002caa:	ed0d                	bnez	a0,80002ce4 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002cac:	85ce                	mv	a1,s3
    80002cae:	8526                	mv	a0,s1
    80002cb0:	c76ff0ef          	jal	80002126 <sleep>
  while(ticks - ticks0 < n){
    80002cb4:	409c                	lw	a5,0(s1)
    80002cb6:	412787bb          	subw	a5,a5,s2
    80002cba:	fcc42703          	lw	a4,-52(s0)
    80002cbe:	fee7e2e3          	bltu	a5,a4,80002ca2 <sys_sleep+0x4a>
    80002cc2:	74a2                	ld	s1,40(sp)
    80002cc4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002cc6:	00013517          	auipc	a0,0x13
    80002cca:	fca50513          	addi	a0,a0,-54 # 80015c90 <tickslock>
    80002cce:	fbffd0ef          	jal	80000c8c <release>
  return 0;
    80002cd2:	4501                	li	a0,0
}
    80002cd4:	70e2                	ld	ra,56(sp)
    80002cd6:	7442                	ld	s0,48(sp)
    80002cd8:	7902                	ld	s2,32(sp)
    80002cda:	6121                	addi	sp,sp,64
    80002cdc:	8082                	ret
    n = 0;
    80002cde:	fc042623          	sw	zero,-52(s0)
    80002ce2:	bf49                	j	80002c74 <sys_sleep+0x1c>
      release(&tickslock);
    80002ce4:	00013517          	auipc	a0,0x13
    80002ce8:	fac50513          	addi	a0,a0,-84 # 80015c90 <tickslock>
    80002cec:	fa1fd0ef          	jal	80000c8c <release>
      return -1;
    80002cf0:	557d                	li	a0,-1
    80002cf2:	74a2                	ld	s1,40(sp)
    80002cf4:	69e2                	ld	s3,24(sp)
    80002cf6:	bff9                	j	80002cd4 <sys_sleep+0x7c>

0000000080002cf8 <sys_kill>:

uint64
sys_kill(void)
{
    80002cf8:	1101                	addi	sp,sp,-32
    80002cfa:	ec06                	sd	ra,24(sp)
    80002cfc:	e822                	sd	s0,16(sp)
    80002cfe:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d00:	fec40593          	addi	a1,s0,-20
    80002d04:	4501                	li	a0,0
    80002d06:	de1ff0ef          	jal	80002ae6 <argint>
  return kill(pid);
    80002d0a:	fec42503          	lw	a0,-20(s0)
    80002d0e:	dc6ff0ef          	jal	800022d4 <kill>
}
    80002d12:	60e2                	ld	ra,24(sp)
    80002d14:	6442                	ld	s0,16(sp)
    80002d16:	6105                	addi	sp,sp,32
    80002d18:	8082                	ret

0000000080002d1a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d1a:	1101                	addi	sp,sp,-32
    80002d1c:	ec06                	sd	ra,24(sp)
    80002d1e:	e822                	sd	s0,16(sp)
    80002d20:	e426                	sd	s1,8(sp)
    80002d22:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d24:	00013517          	auipc	a0,0x13
    80002d28:	f6c50513          	addi	a0,a0,-148 # 80015c90 <tickslock>
    80002d2c:	ec9fd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002d30:	00005497          	auipc	s1,0x5
    80002d34:	c084a483          	lw	s1,-1016(s1) # 80007938 <ticks>
  release(&tickslock);
    80002d38:	00013517          	auipc	a0,0x13
    80002d3c:	f5850513          	addi	a0,a0,-168 # 80015c90 <tickslock>
    80002d40:	f4dfd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002d44:	02049513          	slli	a0,s1,0x20
    80002d48:	9101                	srli	a0,a0,0x20
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	64a2                	ld	s1,8(sp)
    80002d50:	6105                	addi	sp,sp,32
    80002d52:	8082                	ret

0000000080002d54 <sys_setpriority>:

// system call implementation for project1
int
sys_setpriority(void){
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	1000                	addi	s0,sp,32
  int pid, priority;
  argint(0, &pid);
    80002d5c:	fec40593          	addi	a1,s0,-20
    80002d60:	4501                	li	a0,0
    80002d62:	d85ff0ef          	jal	80002ae6 <argint>
  argint(1, &priority);
    80002d66:	fe840593          	addi	a1,s0,-24
    80002d6a:	4505                	li	a0,1
    80002d6c:	d7bff0ef          	jal	80002ae6 <argint>
  return setpriority(pid, priority);
    80002d70:	fe842583          	lw	a1,-24(s0)
    80002d74:	fec42503          	lw	a0,-20(s0)
    80002d78:	96aff0ef          	jal	80001ee2 <setpriority>
}
    80002d7c:	60e2                	ld	ra,24(sp)
    80002d7e:	6442                	ld	s0,16(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret

0000000080002d84 <sys_yield>:

void
sys_yield(void){
    80002d84:	1141                	addi	sp,sp,-16
    80002d86:	e406                	sd	ra,8(sp)
    80002d88:	e022                	sd	s0,0(sp)
    80002d8a:	0800                	addi	s0,sp,16
  return yield();
    80002d8c:	b6eff0ef          	jal	800020fa <yield>
}
    80002d90:	60a2                	ld	ra,8(sp)
    80002d92:	6402                	ld	s0,0(sp)
    80002d94:	0141                	addi	sp,sp,16
    80002d96:	8082                	ret

0000000080002d98 <sys_getlev>:

int
sys_getlev(void){
    80002d98:	1141                	addi	sp,sp,-16
    80002d9a:	e406                	sd	ra,8(sp)
    80002d9c:	e022                	sd	s0,0(sp)
    80002d9e:	0800                	addi	s0,sp,16
  return getlev();
    80002da0:	9c8ff0ef          	jal	80001f68 <getlev>
}
    80002da4:	60a2                	ld	ra,8(sp)
    80002da6:	6402                	ld	s0,0(sp)
    80002da8:	0141                	addi	sp,sp,16
    80002daa:	8082                	ret

0000000080002dac <sys_mlfqmode>:

int
sys_mlfqmode(void) {
    80002dac:	1141                	addi	sp,sp,-16
    80002dae:	e406                	sd	ra,8(sp)
    80002db0:	e022                	sd	s0,0(sp)
    80002db2:	0800                	addi	s0,sp,16
  return mlfqmode();
    80002db4:	9dcff0ef          	jal	80001f90 <mlfqmode>
}
    80002db8:	60a2                	ld	ra,8(sp)
    80002dba:	6402                	ld	s0,0(sp)
    80002dbc:	0141                	addi	sp,sp,16
    80002dbe:	8082                	ret

0000000080002dc0 <sys_fcfsmode>:

int
sys_fcfsmode(void) {
    80002dc0:	1141                	addi	sp,sp,-16
    80002dc2:	e406                	sd	ra,8(sp)
    80002dc4:	e022                	sd	s0,0(sp)
    80002dc6:	0800                	addi	s0,sp,16
  return fcfsmode();
    80002dc8:	a22ff0ef          	jal	80001fea <fcfsmode>
    80002dcc:	60a2                	ld	ra,8(sp)
    80002dce:	6402                	ld	s0,0(sp)
    80002dd0:	0141                	addi	sp,sp,16
    80002dd2:	8082                	ret

0000000080002dd4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dd4:	7179                	addi	sp,sp,-48
    80002dd6:	f406                	sd	ra,40(sp)
    80002dd8:	f022                	sd	s0,32(sp)
    80002dda:	ec26                	sd	s1,24(sp)
    80002ddc:	e84a                	sd	s2,16(sp)
    80002dde:	e44e                	sd	s3,8(sp)
    80002de0:	e052                	sd	s4,0(sp)
    80002de2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002de4:	00004597          	auipc	a1,0x4
    80002de8:	64c58593          	addi	a1,a1,1612 # 80007430 <etext+0x430>
    80002dec:	00013517          	auipc	a0,0x13
    80002df0:	ebc50513          	addi	a0,a0,-324 # 80015ca8 <bcache>
    80002df4:	d81fd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002df8:	0001b797          	auipc	a5,0x1b
    80002dfc:	eb078793          	addi	a5,a5,-336 # 8001dca8 <bcache+0x8000>
    80002e00:	0001b717          	auipc	a4,0x1b
    80002e04:	11070713          	addi	a4,a4,272 # 8001df10 <bcache+0x8268>
    80002e08:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e0c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e10:	00013497          	auipc	s1,0x13
    80002e14:	eb048493          	addi	s1,s1,-336 # 80015cc0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e18:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e1a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e1c:	00004a17          	auipc	s4,0x4
    80002e20:	61ca0a13          	addi	s4,s4,1564 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002e24:	2b893783          	ld	a5,696(s2)
    80002e28:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e2a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e2e:	85d2                	mv	a1,s4
    80002e30:	01048513          	addi	a0,s1,16
    80002e34:	248010ef          	jal	8000407c <initsleeplock>
    bcache.head.next->prev = b;
    80002e38:	2b893783          	ld	a5,696(s2)
    80002e3c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e3e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e42:	45848493          	addi	s1,s1,1112
    80002e46:	fd349fe3          	bne	s1,s3,80002e24 <binit+0x50>
  }
}
    80002e4a:	70a2                	ld	ra,40(sp)
    80002e4c:	7402                	ld	s0,32(sp)
    80002e4e:	64e2                	ld	s1,24(sp)
    80002e50:	6942                	ld	s2,16(sp)
    80002e52:	69a2                	ld	s3,8(sp)
    80002e54:	6a02                	ld	s4,0(sp)
    80002e56:	6145                	addi	sp,sp,48
    80002e58:	8082                	ret

0000000080002e5a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e5a:	7179                	addi	sp,sp,-48
    80002e5c:	f406                	sd	ra,40(sp)
    80002e5e:	f022                	sd	s0,32(sp)
    80002e60:	ec26                	sd	s1,24(sp)
    80002e62:	e84a                	sd	s2,16(sp)
    80002e64:	e44e                	sd	s3,8(sp)
    80002e66:	1800                	addi	s0,sp,48
    80002e68:	892a                	mv	s2,a0
    80002e6a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e6c:	00013517          	auipc	a0,0x13
    80002e70:	e3c50513          	addi	a0,a0,-452 # 80015ca8 <bcache>
    80002e74:	d81fd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e78:	0001b497          	auipc	s1,0x1b
    80002e7c:	0e84b483          	ld	s1,232(s1) # 8001df60 <bcache+0x82b8>
    80002e80:	0001b797          	auipc	a5,0x1b
    80002e84:	09078793          	addi	a5,a5,144 # 8001df10 <bcache+0x8268>
    80002e88:	02f48b63          	beq	s1,a5,80002ebe <bread+0x64>
    80002e8c:	873e                	mv	a4,a5
    80002e8e:	a021                	j	80002e96 <bread+0x3c>
    80002e90:	68a4                	ld	s1,80(s1)
    80002e92:	02e48663          	beq	s1,a4,80002ebe <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002e96:	449c                	lw	a5,8(s1)
    80002e98:	ff279ce3          	bne	a5,s2,80002e90 <bread+0x36>
    80002e9c:	44dc                	lw	a5,12(s1)
    80002e9e:	ff3799e3          	bne	a5,s3,80002e90 <bread+0x36>
      b->refcnt++;
    80002ea2:	40bc                	lw	a5,64(s1)
    80002ea4:	2785                	addiw	a5,a5,1
    80002ea6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ea8:	00013517          	auipc	a0,0x13
    80002eac:	e0050513          	addi	a0,a0,-512 # 80015ca8 <bcache>
    80002eb0:	dddfd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002eb4:	01048513          	addi	a0,s1,16
    80002eb8:	1fa010ef          	jal	800040b2 <acquiresleep>
      return b;
    80002ebc:	a889                	j	80002f0e <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ebe:	0001b497          	auipc	s1,0x1b
    80002ec2:	09a4b483          	ld	s1,154(s1) # 8001df58 <bcache+0x82b0>
    80002ec6:	0001b797          	auipc	a5,0x1b
    80002eca:	04a78793          	addi	a5,a5,74 # 8001df10 <bcache+0x8268>
    80002ece:	00f48863          	beq	s1,a5,80002ede <bread+0x84>
    80002ed2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ed4:	40bc                	lw	a5,64(s1)
    80002ed6:	cb91                	beqz	a5,80002eea <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ed8:	64a4                	ld	s1,72(s1)
    80002eda:	fee49de3          	bne	s1,a4,80002ed4 <bread+0x7a>
  panic("bget: no buffers");
    80002ede:	00004517          	auipc	a0,0x4
    80002ee2:	56250513          	addi	a0,a0,1378 # 80007440 <etext+0x440>
    80002ee6:	8affd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002eea:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002eee:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ef2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ef6:	4785                	li	a5,1
    80002ef8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002efa:	00013517          	auipc	a0,0x13
    80002efe:	dae50513          	addi	a0,a0,-594 # 80015ca8 <bcache>
    80002f02:	d8bfd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002f06:	01048513          	addi	a0,s1,16
    80002f0a:	1a8010ef          	jal	800040b2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f0e:	409c                	lw	a5,0(s1)
    80002f10:	cb89                	beqz	a5,80002f22 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f12:	8526                	mv	a0,s1
    80002f14:	70a2                	ld	ra,40(sp)
    80002f16:	7402                	ld	s0,32(sp)
    80002f18:	64e2                	ld	s1,24(sp)
    80002f1a:	6942                	ld	s2,16(sp)
    80002f1c:	69a2                	ld	s3,8(sp)
    80002f1e:	6145                	addi	sp,sp,48
    80002f20:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f22:	4581                	li	a1,0
    80002f24:	8526                	mv	a0,s1
    80002f26:	1eb020ef          	jal	80005910 <virtio_disk_rw>
    b->valid = 1;
    80002f2a:	4785                	li	a5,1
    80002f2c:	c09c                	sw	a5,0(s1)
  return b;
    80002f2e:	b7d5                	j	80002f12 <bread+0xb8>

0000000080002f30 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f30:	1101                	addi	sp,sp,-32
    80002f32:	ec06                	sd	ra,24(sp)
    80002f34:	e822                	sd	s0,16(sp)
    80002f36:	e426                	sd	s1,8(sp)
    80002f38:	1000                	addi	s0,sp,32
    80002f3a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f3c:	0541                	addi	a0,a0,16
    80002f3e:	1f2010ef          	jal	80004130 <holdingsleep>
    80002f42:	c911                	beqz	a0,80002f56 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f44:	4585                	li	a1,1
    80002f46:	8526                	mv	a0,s1
    80002f48:	1c9020ef          	jal	80005910 <virtio_disk_rw>
}
    80002f4c:	60e2                	ld	ra,24(sp)
    80002f4e:	6442                	ld	s0,16(sp)
    80002f50:	64a2                	ld	s1,8(sp)
    80002f52:	6105                	addi	sp,sp,32
    80002f54:	8082                	ret
    panic("bwrite");
    80002f56:	00004517          	auipc	a0,0x4
    80002f5a:	50250513          	addi	a0,a0,1282 # 80007458 <etext+0x458>
    80002f5e:	837fd0ef          	jal	80000794 <panic>

0000000080002f62 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f62:	1101                	addi	sp,sp,-32
    80002f64:	ec06                	sd	ra,24(sp)
    80002f66:	e822                	sd	s0,16(sp)
    80002f68:	e426                	sd	s1,8(sp)
    80002f6a:	e04a                	sd	s2,0(sp)
    80002f6c:	1000                	addi	s0,sp,32
    80002f6e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f70:	01050913          	addi	s2,a0,16
    80002f74:	854a                	mv	a0,s2
    80002f76:	1ba010ef          	jal	80004130 <holdingsleep>
    80002f7a:	c135                	beqz	a0,80002fde <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f7c:	854a                	mv	a0,s2
    80002f7e:	17a010ef          	jal	800040f8 <releasesleep>

  acquire(&bcache.lock);
    80002f82:	00013517          	auipc	a0,0x13
    80002f86:	d2650513          	addi	a0,a0,-730 # 80015ca8 <bcache>
    80002f8a:	c6bfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002f8e:	40bc                	lw	a5,64(s1)
    80002f90:	37fd                	addiw	a5,a5,-1
    80002f92:	0007871b          	sext.w	a4,a5
    80002f96:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f98:	e71d                	bnez	a4,80002fc6 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f9a:	68b8                	ld	a4,80(s1)
    80002f9c:	64bc                	ld	a5,72(s1)
    80002f9e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fa0:	68b8                	ld	a4,80(s1)
    80002fa2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fa4:	0001b797          	auipc	a5,0x1b
    80002fa8:	d0478793          	addi	a5,a5,-764 # 8001dca8 <bcache+0x8000>
    80002fac:	2b87b703          	ld	a4,696(a5)
    80002fb0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fb2:	0001b717          	auipc	a4,0x1b
    80002fb6:	f5e70713          	addi	a4,a4,-162 # 8001df10 <bcache+0x8268>
    80002fba:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fbc:	2b87b703          	ld	a4,696(a5)
    80002fc0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fc2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fc6:	00013517          	auipc	a0,0x13
    80002fca:	ce250513          	addi	a0,a0,-798 # 80015ca8 <bcache>
    80002fce:	cbffd0ef          	jal	80000c8c <release>
}
    80002fd2:	60e2                	ld	ra,24(sp)
    80002fd4:	6442                	ld	s0,16(sp)
    80002fd6:	64a2                	ld	s1,8(sp)
    80002fd8:	6902                	ld	s2,0(sp)
    80002fda:	6105                	addi	sp,sp,32
    80002fdc:	8082                	ret
    panic("brelse");
    80002fde:	00004517          	auipc	a0,0x4
    80002fe2:	48250513          	addi	a0,a0,1154 # 80007460 <etext+0x460>
    80002fe6:	faefd0ef          	jal	80000794 <panic>

0000000080002fea <bpin>:

void
bpin(struct buf *b) {
    80002fea:	1101                	addi	sp,sp,-32
    80002fec:	ec06                	sd	ra,24(sp)
    80002fee:	e822                	sd	s0,16(sp)
    80002ff0:	e426                	sd	s1,8(sp)
    80002ff2:	1000                	addi	s0,sp,32
    80002ff4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ff6:	00013517          	auipc	a0,0x13
    80002ffa:	cb250513          	addi	a0,a0,-846 # 80015ca8 <bcache>
    80002ffe:	bf7fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80003002:	40bc                	lw	a5,64(s1)
    80003004:	2785                	addiw	a5,a5,1
    80003006:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003008:	00013517          	auipc	a0,0x13
    8000300c:	ca050513          	addi	a0,a0,-864 # 80015ca8 <bcache>
    80003010:	c7dfd0ef          	jal	80000c8c <release>
}
    80003014:	60e2                	ld	ra,24(sp)
    80003016:	6442                	ld	s0,16(sp)
    80003018:	64a2                	ld	s1,8(sp)
    8000301a:	6105                	addi	sp,sp,32
    8000301c:	8082                	ret

000000008000301e <bunpin>:

void
bunpin(struct buf *b) {
    8000301e:	1101                	addi	sp,sp,-32
    80003020:	ec06                	sd	ra,24(sp)
    80003022:	e822                	sd	s0,16(sp)
    80003024:	e426                	sd	s1,8(sp)
    80003026:	1000                	addi	s0,sp,32
    80003028:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000302a:	00013517          	auipc	a0,0x13
    8000302e:	c7e50513          	addi	a0,a0,-898 # 80015ca8 <bcache>
    80003032:	bc3fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80003036:	40bc                	lw	a5,64(s1)
    80003038:	37fd                	addiw	a5,a5,-1
    8000303a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000303c:	00013517          	auipc	a0,0x13
    80003040:	c6c50513          	addi	a0,a0,-916 # 80015ca8 <bcache>
    80003044:	c49fd0ef          	jal	80000c8c <release>
}
    80003048:	60e2                	ld	ra,24(sp)
    8000304a:	6442                	ld	s0,16(sp)
    8000304c:	64a2                	ld	s1,8(sp)
    8000304e:	6105                	addi	sp,sp,32
    80003050:	8082                	ret

0000000080003052 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003052:	1101                	addi	sp,sp,-32
    80003054:	ec06                	sd	ra,24(sp)
    80003056:	e822                	sd	s0,16(sp)
    80003058:	e426                	sd	s1,8(sp)
    8000305a:	e04a                	sd	s2,0(sp)
    8000305c:	1000                	addi	s0,sp,32
    8000305e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003060:	00d5d59b          	srliw	a1,a1,0xd
    80003064:	0001b797          	auipc	a5,0x1b
    80003068:	3207a783          	lw	a5,800(a5) # 8001e384 <sb+0x1c>
    8000306c:	9dbd                	addw	a1,a1,a5
    8000306e:	dedff0ef          	jal	80002e5a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003072:	0074f713          	andi	a4,s1,7
    80003076:	4785                	li	a5,1
    80003078:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000307c:	14ce                	slli	s1,s1,0x33
    8000307e:	90d9                	srli	s1,s1,0x36
    80003080:	00950733          	add	a4,a0,s1
    80003084:	05874703          	lbu	a4,88(a4)
    80003088:	00e7f6b3          	and	a3,a5,a4
    8000308c:	c29d                	beqz	a3,800030b2 <bfree+0x60>
    8000308e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003090:	94aa                	add	s1,s1,a0
    80003092:	fff7c793          	not	a5,a5
    80003096:	8f7d                	and	a4,a4,a5
    80003098:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000309c:	711000ef          	jal	80003fac <log_write>
  brelse(bp);
    800030a0:	854a                	mv	a0,s2
    800030a2:	ec1ff0ef          	jal	80002f62 <brelse>
}
    800030a6:	60e2                	ld	ra,24(sp)
    800030a8:	6442                	ld	s0,16(sp)
    800030aa:	64a2                	ld	s1,8(sp)
    800030ac:	6902                	ld	s2,0(sp)
    800030ae:	6105                	addi	sp,sp,32
    800030b0:	8082                	ret
    panic("freeing free block");
    800030b2:	00004517          	auipc	a0,0x4
    800030b6:	3b650513          	addi	a0,a0,950 # 80007468 <etext+0x468>
    800030ba:	edafd0ef          	jal	80000794 <panic>

00000000800030be <balloc>:
{
    800030be:	711d                	addi	sp,sp,-96
    800030c0:	ec86                	sd	ra,88(sp)
    800030c2:	e8a2                	sd	s0,80(sp)
    800030c4:	e4a6                	sd	s1,72(sp)
    800030c6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030c8:	0001b797          	auipc	a5,0x1b
    800030cc:	2a47a783          	lw	a5,676(a5) # 8001e36c <sb+0x4>
    800030d0:	0e078f63          	beqz	a5,800031ce <balloc+0x110>
    800030d4:	e0ca                	sd	s2,64(sp)
    800030d6:	fc4e                	sd	s3,56(sp)
    800030d8:	f852                	sd	s4,48(sp)
    800030da:	f456                	sd	s5,40(sp)
    800030dc:	f05a                	sd	s6,32(sp)
    800030de:	ec5e                	sd	s7,24(sp)
    800030e0:	e862                	sd	s8,16(sp)
    800030e2:	e466                	sd	s9,8(sp)
    800030e4:	8baa                	mv	s7,a0
    800030e6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030e8:	0001bb17          	auipc	s6,0x1b
    800030ec:	280b0b13          	addi	s6,s6,640 # 8001e368 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030f0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800030f2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030f4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030f6:	6c89                	lui	s9,0x2
    800030f8:	a0b5                	j	80003164 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800030fa:	97ca                	add	a5,a5,s2
    800030fc:	8e55                	or	a2,a2,a3
    800030fe:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003102:	854a                	mv	a0,s2
    80003104:	6a9000ef          	jal	80003fac <log_write>
        brelse(bp);
    80003108:	854a                	mv	a0,s2
    8000310a:	e59ff0ef          	jal	80002f62 <brelse>
  bp = bread(dev, bno);
    8000310e:	85a6                	mv	a1,s1
    80003110:	855e                	mv	a0,s7
    80003112:	d49ff0ef          	jal	80002e5a <bread>
    80003116:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003118:	40000613          	li	a2,1024
    8000311c:	4581                	li	a1,0
    8000311e:	05850513          	addi	a0,a0,88
    80003122:	ba7fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80003126:	854a                	mv	a0,s2
    80003128:	685000ef          	jal	80003fac <log_write>
  brelse(bp);
    8000312c:	854a                	mv	a0,s2
    8000312e:	e35ff0ef          	jal	80002f62 <brelse>
}
    80003132:	6906                	ld	s2,64(sp)
    80003134:	79e2                	ld	s3,56(sp)
    80003136:	7a42                	ld	s4,48(sp)
    80003138:	7aa2                	ld	s5,40(sp)
    8000313a:	7b02                	ld	s6,32(sp)
    8000313c:	6be2                	ld	s7,24(sp)
    8000313e:	6c42                	ld	s8,16(sp)
    80003140:	6ca2                	ld	s9,8(sp)
}
    80003142:	8526                	mv	a0,s1
    80003144:	60e6                	ld	ra,88(sp)
    80003146:	6446                	ld	s0,80(sp)
    80003148:	64a6                	ld	s1,72(sp)
    8000314a:	6125                	addi	sp,sp,96
    8000314c:	8082                	ret
    brelse(bp);
    8000314e:	854a                	mv	a0,s2
    80003150:	e13ff0ef          	jal	80002f62 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003154:	015c87bb          	addw	a5,s9,s5
    80003158:	00078a9b          	sext.w	s5,a5
    8000315c:	004b2703          	lw	a4,4(s6)
    80003160:	04eaff63          	bgeu	s5,a4,800031be <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003164:	41fad79b          	sraiw	a5,s5,0x1f
    80003168:	0137d79b          	srliw	a5,a5,0x13
    8000316c:	015787bb          	addw	a5,a5,s5
    80003170:	40d7d79b          	sraiw	a5,a5,0xd
    80003174:	01cb2583          	lw	a1,28(s6)
    80003178:	9dbd                	addw	a1,a1,a5
    8000317a:	855e                	mv	a0,s7
    8000317c:	cdfff0ef          	jal	80002e5a <bread>
    80003180:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003182:	004b2503          	lw	a0,4(s6)
    80003186:	000a849b          	sext.w	s1,s5
    8000318a:	8762                	mv	a4,s8
    8000318c:	fca4f1e3          	bgeu	s1,a0,8000314e <balloc+0x90>
      m = 1 << (bi % 8);
    80003190:	00777693          	andi	a3,a4,7
    80003194:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003198:	41f7579b          	sraiw	a5,a4,0x1f
    8000319c:	01d7d79b          	srliw	a5,a5,0x1d
    800031a0:	9fb9                	addw	a5,a5,a4
    800031a2:	4037d79b          	sraiw	a5,a5,0x3
    800031a6:	00f90633          	add	a2,s2,a5
    800031aa:	05864603          	lbu	a2,88(a2)
    800031ae:	00c6f5b3          	and	a1,a3,a2
    800031b2:	d5a1                	beqz	a1,800030fa <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b4:	2705                	addiw	a4,a4,1
    800031b6:	2485                	addiw	s1,s1,1
    800031b8:	fd471ae3          	bne	a4,s4,8000318c <balloc+0xce>
    800031bc:	bf49                	j	8000314e <balloc+0x90>
    800031be:	6906                	ld	s2,64(sp)
    800031c0:	79e2                	ld	s3,56(sp)
    800031c2:	7a42                	ld	s4,48(sp)
    800031c4:	7aa2                	ld	s5,40(sp)
    800031c6:	7b02                	ld	s6,32(sp)
    800031c8:	6be2                	ld	s7,24(sp)
    800031ca:	6c42                	ld	s8,16(sp)
    800031cc:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800031ce:	00004517          	auipc	a0,0x4
    800031d2:	2b250513          	addi	a0,a0,690 # 80007480 <etext+0x480>
    800031d6:	aecfd0ef          	jal	800004c2 <printf>
  return 0;
    800031da:	4481                	li	s1,0
    800031dc:	b79d                	j	80003142 <balloc+0x84>

00000000800031de <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800031de:	7179                	addi	sp,sp,-48
    800031e0:	f406                	sd	ra,40(sp)
    800031e2:	f022                	sd	s0,32(sp)
    800031e4:	ec26                	sd	s1,24(sp)
    800031e6:	e84a                	sd	s2,16(sp)
    800031e8:	e44e                	sd	s3,8(sp)
    800031ea:	1800                	addi	s0,sp,48
    800031ec:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800031ee:	47ad                	li	a5,11
    800031f0:	02b7e663          	bltu	a5,a1,8000321c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800031f4:	02059793          	slli	a5,a1,0x20
    800031f8:	01e7d593          	srli	a1,a5,0x1e
    800031fc:	00b504b3          	add	s1,a0,a1
    80003200:	0504a903          	lw	s2,80(s1)
    80003204:	06091a63          	bnez	s2,80003278 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003208:	4108                	lw	a0,0(a0)
    8000320a:	eb5ff0ef          	jal	800030be <balloc>
    8000320e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003212:	06090363          	beqz	s2,80003278 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003216:	0524a823          	sw	s2,80(s1)
    8000321a:	a8b9                	j	80003278 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000321c:	ff45849b          	addiw	s1,a1,-12
    80003220:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003224:	0ff00793          	li	a5,255
    80003228:	06e7ee63          	bltu	a5,a4,800032a4 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000322c:	08052903          	lw	s2,128(a0)
    80003230:	00091d63          	bnez	s2,8000324a <bmap+0x6c>
      addr = balloc(ip->dev);
    80003234:	4108                	lw	a0,0(a0)
    80003236:	e89ff0ef          	jal	800030be <balloc>
    8000323a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000323e:	02090d63          	beqz	s2,80003278 <bmap+0x9a>
    80003242:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003244:	0929a023          	sw	s2,128(s3)
    80003248:	a011                	j	8000324c <bmap+0x6e>
    8000324a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000324c:	85ca                	mv	a1,s2
    8000324e:	0009a503          	lw	a0,0(s3)
    80003252:	c09ff0ef          	jal	80002e5a <bread>
    80003256:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003258:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000325c:	02049713          	slli	a4,s1,0x20
    80003260:	01e75593          	srli	a1,a4,0x1e
    80003264:	00b784b3          	add	s1,a5,a1
    80003268:	0004a903          	lw	s2,0(s1)
    8000326c:	00090e63          	beqz	s2,80003288 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003270:	8552                	mv	a0,s4
    80003272:	cf1ff0ef          	jal	80002f62 <brelse>
    return addr;
    80003276:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003278:	854a                	mv	a0,s2
    8000327a:	70a2                	ld	ra,40(sp)
    8000327c:	7402                	ld	s0,32(sp)
    8000327e:	64e2                	ld	s1,24(sp)
    80003280:	6942                	ld	s2,16(sp)
    80003282:	69a2                	ld	s3,8(sp)
    80003284:	6145                	addi	sp,sp,48
    80003286:	8082                	ret
      addr = balloc(ip->dev);
    80003288:	0009a503          	lw	a0,0(s3)
    8000328c:	e33ff0ef          	jal	800030be <balloc>
    80003290:	0005091b          	sext.w	s2,a0
      if(addr){
    80003294:	fc090ee3          	beqz	s2,80003270 <bmap+0x92>
        a[bn] = addr;
    80003298:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000329c:	8552                	mv	a0,s4
    8000329e:	50f000ef          	jal	80003fac <log_write>
    800032a2:	b7f9                	j	80003270 <bmap+0x92>
    800032a4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800032a6:	00004517          	auipc	a0,0x4
    800032aa:	1f250513          	addi	a0,a0,498 # 80007498 <etext+0x498>
    800032ae:	ce6fd0ef          	jal	80000794 <panic>

00000000800032b2 <iget>:
{
    800032b2:	7179                	addi	sp,sp,-48
    800032b4:	f406                	sd	ra,40(sp)
    800032b6:	f022                	sd	s0,32(sp)
    800032b8:	ec26                	sd	s1,24(sp)
    800032ba:	e84a                	sd	s2,16(sp)
    800032bc:	e44e                	sd	s3,8(sp)
    800032be:	e052                	sd	s4,0(sp)
    800032c0:	1800                	addi	s0,sp,48
    800032c2:	89aa                	mv	s3,a0
    800032c4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800032c6:	0001b517          	auipc	a0,0x1b
    800032ca:	0c250513          	addi	a0,a0,194 # 8001e388 <itable>
    800032ce:	927fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    800032d2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032d4:	0001b497          	auipc	s1,0x1b
    800032d8:	0cc48493          	addi	s1,s1,204 # 8001e3a0 <itable+0x18>
    800032dc:	0001d697          	auipc	a3,0x1d
    800032e0:	b5468693          	addi	a3,a3,-1196 # 8001fe30 <log>
    800032e4:	a039                	j	800032f2 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032e6:	02090963          	beqz	s2,80003318 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032ea:	08848493          	addi	s1,s1,136
    800032ee:	02d48863          	beq	s1,a3,8000331e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800032f2:	449c                	lw	a5,8(s1)
    800032f4:	fef059e3          	blez	a5,800032e6 <iget+0x34>
    800032f8:	4098                	lw	a4,0(s1)
    800032fa:	ff3716e3          	bne	a4,s3,800032e6 <iget+0x34>
    800032fe:	40d8                	lw	a4,4(s1)
    80003300:	ff4713e3          	bne	a4,s4,800032e6 <iget+0x34>
      ip->ref++;
    80003304:	2785                	addiw	a5,a5,1
    80003306:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003308:	0001b517          	auipc	a0,0x1b
    8000330c:	08050513          	addi	a0,a0,128 # 8001e388 <itable>
    80003310:	97dfd0ef          	jal	80000c8c <release>
      return ip;
    80003314:	8926                	mv	s2,s1
    80003316:	a02d                	j	80003340 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003318:	fbe9                	bnez	a5,800032ea <iget+0x38>
      empty = ip;
    8000331a:	8926                	mv	s2,s1
    8000331c:	b7f9                	j	800032ea <iget+0x38>
  if(empty == 0)
    8000331e:	02090a63          	beqz	s2,80003352 <iget+0xa0>
  ip->dev = dev;
    80003322:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003326:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000332a:	4785                	li	a5,1
    8000332c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003330:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003334:	0001b517          	auipc	a0,0x1b
    80003338:	05450513          	addi	a0,a0,84 # 8001e388 <itable>
    8000333c:	951fd0ef          	jal	80000c8c <release>
}
    80003340:	854a                	mv	a0,s2
    80003342:	70a2                	ld	ra,40(sp)
    80003344:	7402                	ld	s0,32(sp)
    80003346:	64e2                	ld	s1,24(sp)
    80003348:	6942                	ld	s2,16(sp)
    8000334a:	69a2                	ld	s3,8(sp)
    8000334c:	6a02                	ld	s4,0(sp)
    8000334e:	6145                	addi	sp,sp,48
    80003350:	8082                	ret
    panic("iget: no inodes");
    80003352:	00004517          	auipc	a0,0x4
    80003356:	15e50513          	addi	a0,a0,350 # 800074b0 <etext+0x4b0>
    8000335a:	c3afd0ef          	jal	80000794 <panic>

000000008000335e <fsinit>:
fsinit(int dev) {
    8000335e:	7179                	addi	sp,sp,-48
    80003360:	f406                	sd	ra,40(sp)
    80003362:	f022                	sd	s0,32(sp)
    80003364:	ec26                	sd	s1,24(sp)
    80003366:	e84a                	sd	s2,16(sp)
    80003368:	e44e                	sd	s3,8(sp)
    8000336a:	1800                	addi	s0,sp,48
    8000336c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000336e:	4585                	li	a1,1
    80003370:	aebff0ef          	jal	80002e5a <bread>
    80003374:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003376:	0001b997          	auipc	s3,0x1b
    8000337a:	ff298993          	addi	s3,s3,-14 # 8001e368 <sb>
    8000337e:	02000613          	li	a2,32
    80003382:	05850593          	addi	a1,a0,88
    80003386:	854e                	mv	a0,s3
    80003388:	99dfd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    8000338c:	8526                	mv	a0,s1
    8000338e:	bd5ff0ef          	jal	80002f62 <brelse>
  if(sb.magic != FSMAGIC)
    80003392:	0009a703          	lw	a4,0(s3)
    80003396:	102037b7          	lui	a5,0x10203
    8000339a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000339e:	02f71063          	bne	a4,a5,800033be <fsinit+0x60>
  initlog(dev, &sb);
    800033a2:	0001b597          	auipc	a1,0x1b
    800033a6:	fc658593          	addi	a1,a1,-58 # 8001e368 <sb>
    800033aa:	854a                	mv	a0,s2
    800033ac:	1f9000ef          	jal	80003da4 <initlog>
}
    800033b0:	70a2                	ld	ra,40(sp)
    800033b2:	7402                	ld	s0,32(sp)
    800033b4:	64e2                	ld	s1,24(sp)
    800033b6:	6942                	ld	s2,16(sp)
    800033b8:	69a2                	ld	s3,8(sp)
    800033ba:	6145                	addi	sp,sp,48
    800033bc:	8082                	ret
    panic("invalid file system");
    800033be:	00004517          	auipc	a0,0x4
    800033c2:	10250513          	addi	a0,a0,258 # 800074c0 <etext+0x4c0>
    800033c6:	bcefd0ef          	jal	80000794 <panic>

00000000800033ca <iinit>:
{
    800033ca:	7179                	addi	sp,sp,-48
    800033cc:	f406                	sd	ra,40(sp)
    800033ce:	f022                	sd	s0,32(sp)
    800033d0:	ec26                	sd	s1,24(sp)
    800033d2:	e84a                	sd	s2,16(sp)
    800033d4:	e44e                	sd	s3,8(sp)
    800033d6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800033d8:	00004597          	auipc	a1,0x4
    800033dc:	10058593          	addi	a1,a1,256 # 800074d8 <etext+0x4d8>
    800033e0:	0001b517          	auipc	a0,0x1b
    800033e4:	fa850513          	addi	a0,a0,-88 # 8001e388 <itable>
    800033e8:	f8cfd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800033ec:	0001b497          	auipc	s1,0x1b
    800033f0:	fc448493          	addi	s1,s1,-60 # 8001e3b0 <itable+0x28>
    800033f4:	0001d997          	auipc	s3,0x1d
    800033f8:	a4c98993          	addi	s3,s3,-1460 # 8001fe40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800033fc:	00004917          	auipc	s2,0x4
    80003400:	0e490913          	addi	s2,s2,228 # 800074e0 <etext+0x4e0>
    80003404:	85ca                	mv	a1,s2
    80003406:	8526                	mv	a0,s1
    80003408:	475000ef          	jal	8000407c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000340c:	08848493          	addi	s1,s1,136
    80003410:	ff349ae3          	bne	s1,s3,80003404 <iinit+0x3a>
}
    80003414:	70a2                	ld	ra,40(sp)
    80003416:	7402                	ld	s0,32(sp)
    80003418:	64e2                	ld	s1,24(sp)
    8000341a:	6942                	ld	s2,16(sp)
    8000341c:	69a2                	ld	s3,8(sp)
    8000341e:	6145                	addi	sp,sp,48
    80003420:	8082                	ret

0000000080003422 <ialloc>:
{
    80003422:	7139                	addi	sp,sp,-64
    80003424:	fc06                	sd	ra,56(sp)
    80003426:	f822                	sd	s0,48(sp)
    80003428:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000342a:	0001b717          	auipc	a4,0x1b
    8000342e:	f4a72703          	lw	a4,-182(a4) # 8001e374 <sb+0xc>
    80003432:	4785                	li	a5,1
    80003434:	06e7f063          	bgeu	a5,a4,80003494 <ialloc+0x72>
    80003438:	f426                	sd	s1,40(sp)
    8000343a:	f04a                	sd	s2,32(sp)
    8000343c:	ec4e                	sd	s3,24(sp)
    8000343e:	e852                	sd	s4,16(sp)
    80003440:	e456                	sd	s5,8(sp)
    80003442:	e05a                	sd	s6,0(sp)
    80003444:	8aaa                	mv	s5,a0
    80003446:	8b2e                	mv	s6,a1
    80003448:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000344a:	0001ba17          	auipc	s4,0x1b
    8000344e:	f1ea0a13          	addi	s4,s4,-226 # 8001e368 <sb>
    80003452:	00495593          	srli	a1,s2,0x4
    80003456:	018a2783          	lw	a5,24(s4)
    8000345a:	9dbd                	addw	a1,a1,a5
    8000345c:	8556                	mv	a0,s5
    8000345e:	9fdff0ef          	jal	80002e5a <bread>
    80003462:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003464:	05850993          	addi	s3,a0,88
    80003468:	00f97793          	andi	a5,s2,15
    8000346c:	079a                	slli	a5,a5,0x6
    8000346e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003470:	00099783          	lh	a5,0(s3)
    80003474:	cb9d                	beqz	a5,800034aa <ialloc+0x88>
    brelse(bp);
    80003476:	aedff0ef          	jal	80002f62 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000347a:	0905                	addi	s2,s2,1
    8000347c:	00ca2703          	lw	a4,12(s4)
    80003480:	0009079b          	sext.w	a5,s2
    80003484:	fce7e7e3          	bltu	a5,a4,80003452 <ialloc+0x30>
    80003488:	74a2                	ld	s1,40(sp)
    8000348a:	7902                	ld	s2,32(sp)
    8000348c:	69e2                	ld	s3,24(sp)
    8000348e:	6a42                	ld	s4,16(sp)
    80003490:	6aa2                	ld	s5,8(sp)
    80003492:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003494:	00004517          	auipc	a0,0x4
    80003498:	05450513          	addi	a0,a0,84 # 800074e8 <etext+0x4e8>
    8000349c:	826fd0ef          	jal	800004c2 <printf>
  return 0;
    800034a0:	4501                	li	a0,0
}
    800034a2:	70e2                	ld	ra,56(sp)
    800034a4:	7442                	ld	s0,48(sp)
    800034a6:	6121                	addi	sp,sp,64
    800034a8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800034aa:	04000613          	li	a2,64
    800034ae:	4581                	li	a1,0
    800034b0:	854e                	mv	a0,s3
    800034b2:	817fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800034b6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034ba:	8526                	mv	a0,s1
    800034bc:	2f1000ef          	jal	80003fac <log_write>
      brelse(bp);
    800034c0:	8526                	mv	a0,s1
    800034c2:	aa1ff0ef          	jal	80002f62 <brelse>
      return iget(dev, inum);
    800034c6:	0009059b          	sext.w	a1,s2
    800034ca:	8556                	mv	a0,s5
    800034cc:	de7ff0ef          	jal	800032b2 <iget>
    800034d0:	74a2                	ld	s1,40(sp)
    800034d2:	7902                	ld	s2,32(sp)
    800034d4:	69e2                	ld	s3,24(sp)
    800034d6:	6a42                	ld	s4,16(sp)
    800034d8:	6aa2                	ld	s5,8(sp)
    800034da:	6b02                	ld	s6,0(sp)
    800034dc:	b7d9                	j	800034a2 <ialloc+0x80>

00000000800034de <iupdate>:
{
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	e426                	sd	s1,8(sp)
    800034e6:	e04a                	sd	s2,0(sp)
    800034e8:	1000                	addi	s0,sp,32
    800034ea:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034ec:	415c                	lw	a5,4(a0)
    800034ee:	0047d79b          	srliw	a5,a5,0x4
    800034f2:	0001b597          	auipc	a1,0x1b
    800034f6:	e8e5a583          	lw	a1,-370(a1) # 8001e380 <sb+0x18>
    800034fa:	9dbd                	addw	a1,a1,a5
    800034fc:	4108                	lw	a0,0(a0)
    800034fe:	95dff0ef          	jal	80002e5a <bread>
    80003502:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003504:	05850793          	addi	a5,a0,88
    80003508:	40d8                	lw	a4,4(s1)
    8000350a:	8b3d                	andi	a4,a4,15
    8000350c:	071a                	slli	a4,a4,0x6
    8000350e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003510:	04449703          	lh	a4,68(s1)
    80003514:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003518:	04649703          	lh	a4,70(s1)
    8000351c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003520:	04849703          	lh	a4,72(s1)
    80003524:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003528:	04a49703          	lh	a4,74(s1)
    8000352c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003530:	44f8                	lw	a4,76(s1)
    80003532:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003534:	03400613          	li	a2,52
    80003538:	05048593          	addi	a1,s1,80
    8000353c:	00c78513          	addi	a0,a5,12
    80003540:	fe4fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003544:	854a                	mv	a0,s2
    80003546:	267000ef          	jal	80003fac <log_write>
  brelse(bp);
    8000354a:	854a                	mv	a0,s2
    8000354c:	a17ff0ef          	jal	80002f62 <brelse>
}
    80003550:	60e2                	ld	ra,24(sp)
    80003552:	6442                	ld	s0,16(sp)
    80003554:	64a2                	ld	s1,8(sp)
    80003556:	6902                	ld	s2,0(sp)
    80003558:	6105                	addi	sp,sp,32
    8000355a:	8082                	ret

000000008000355c <idup>:
{
    8000355c:	1101                	addi	sp,sp,-32
    8000355e:	ec06                	sd	ra,24(sp)
    80003560:	e822                	sd	s0,16(sp)
    80003562:	e426                	sd	s1,8(sp)
    80003564:	1000                	addi	s0,sp,32
    80003566:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003568:	0001b517          	auipc	a0,0x1b
    8000356c:	e2050513          	addi	a0,a0,-480 # 8001e388 <itable>
    80003570:	e84fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    80003574:	449c                	lw	a5,8(s1)
    80003576:	2785                	addiw	a5,a5,1
    80003578:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000357a:	0001b517          	auipc	a0,0x1b
    8000357e:	e0e50513          	addi	a0,a0,-498 # 8001e388 <itable>
    80003582:	f0afd0ef          	jal	80000c8c <release>
}
    80003586:	8526                	mv	a0,s1
    80003588:	60e2                	ld	ra,24(sp)
    8000358a:	6442                	ld	s0,16(sp)
    8000358c:	64a2                	ld	s1,8(sp)
    8000358e:	6105                	addi	sp,sp,32
    80003590:	8082                	ret

0000000080003592 <ilock>:
{
    80003592:	1101                	addi	sp,sp,-32
    80003594:	ec06                	sd	ra,24(sp)
    80003596:	e822                	sd	s0,16(sp)
    80003598:	e426                	sd	s1,8(sp)
    8000359a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000359c:	cd19                	beqz	a0,800035ba <ilock+0x28>
    8000359e:	84aa                	mv	s1,a0
    800035a0:	451c                	lw	a5,8(a0)
    800035a2:	00f05c63          	blez	a5,800035ba <ilock+0x28>
  acquiresleep(&ip->lock);
    800035a6:	0541                	addi	a0,a0,16
    800035a8:	30b000ef          	jal	800040b2 <acquiresleep>
  if(ip->valid == 0){
    800035ac:	40bc                	lw	a5,64(s1)
    800035ae:	cf89                	beqz	a5,800035c8 <ilock+0x36>
}
    800035b0:	60e2                	ld	ra,24(sp)
    800035b2:	6442                	ld	s0,16(sp)
    800035b4:	64a2                	ld	s1,8(sp)
    800035b6:	6105                	addi	sp,sp,32
    800035b8:	8082                	ret
    800035ba:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800035bc:	00004517          	auipc	a0,0x4
    800035c0:	f4450513          	addi	a0,a0,-188 # 80007500 <etext+0x500>
    800035c4:	9d0fd0ef          	jal	80000794 <panic>
    800035c8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035ca:	40dc                	lw	a5,4(s1)
    800035cc:	0047d79b          	srliw	a5,a5,0x4
    800035d0:	0001b597          	auipc	a1,0x1b
    800035d4:	db05a583          	lw	a1,-592(a1) # 8001e380 <sb+0x18>
    800035d8:	9dbd                	addw	a1,a1,a5
    800035da:	4088                	lw	a0,0(s1)
    800035dc:	87fff0ef          	jal	80002e5a <bread>
    800035e0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035e2:	05850593          	addi	a1,a0,88
    800035e6:	40dc                	lw	a5,4(s1)
    800035e8:	8bbd                	andi	a5,a5,15
    800035ea:	079a                	slli	a5,a5,0x6
    800035ec:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800035ee:	00059783          	lh	a5,0(a1)
    800035f2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800035f6:	00259783          	lh	a5,2(a1)
    800035fa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800035fe:	00459783          	lh	a5,4(a1)
    80003602:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003606:	00659783          	lh	a5,6(a1)
    8000360a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000360e:	459c                	lw	a5,8(a1)
    80003610:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003612:	03400613          	li	a2,52
    80003616:	05b1                	addi	a1,a1,12
    80003618:	05048513          	addi	a0,s1,80
    8000361c:	f08fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003620:	854a                	mv	a0,s2
    80003622:	941ff0ef          	jal	80002f62 <brelse>
    ip->valid = 1;
    80003626:	4785                	li	a5,1
    80003628:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000362a:	04449783          	lh	a5,68(s1)
    8000362e:	c399                	beqz	a5,80003634 <ilock+0xa2>
    80003630:	6902                	ld	s2,0(sp)
    80003632:	bfbd                	j	800035b0 <ilock+0x1e>
      panic("ilock: no type");
    80003634:	00004517          	auipc	a0,0x4
    80003638:	ed450513          	addi	a0,a0,-300 # 80007508 <etext+0x508>
    8000363c:	958fd0ef          	jal	80000794 <panic>

0000000080003640 <iunlock>:
{
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	e04a                	sd	s2,0(sp)
    8000364a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000364c:	c505                	beqz	a0,80003674 <iunlock+0x34>
    8000364e:	84aa                	mv	s1,a0
    80003650:	01050913          	addi	s2,a0,16
    80003654:	854a                	mv	a0,s2
    80003656:	2db000ef          	jal	80004130 <holdingsleep>
    8000365a:	cd09                	beqz	a0,80003674 <iunlock+0x34>
    8000365c:	449c                	lw	a5,8(s1)
    8000365e:	00f05b63          	blez	a5,80003674 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003662:	854a                	mv	a0,s2
    80003664:	295000ef          	jal	800040f8 <releasesleep>
}
    80003668:	60e2                	ld	ra,24(sp)
    8000366a:	6442                	ld	s0,16(sp)
    8000366c:	64a2                	ld	s1,8(sp)
    8000366e:	6902                	ld	s2,0(sp)
    80003670:	6105                	addi	sp,sp,32
    80003672:	8082                	ret
    panic("iunlock");
    80003674:	00004517          	auipc	a0,0x4
    80003678:	ea450513          	addi	a0,a0,-348 # 80007518 <etext+0x518>
    8000367c:	918fd0ef          	jal	80000794 <panic>

0000000080003680 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003680:	7179                	addi	sp,sp,-48
    80003682:	f406                	sd	ra,40(sp)
    80003684:	f022                	sd	s0,32(sp)
    80003686:	ec26                	sd	s1,24(sp)
    80003688:	e84a                	sd	s2,16(sp)
    8000368a:	e44e                	sd	s3,8(sp)
    8000368c:	1800                	addi	s0,sp,48
    8000368e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003690:	05050493          	addi	s1,a0,80
    80003694:	08050913          	addi	s2,a0,128
    80003698:	a021                	j	800036a0 <itrunc+0x20>
    8000369a:	0491                	addi	s1,s1,4
    8000369c:	01248b63          	beq	s1,s2,800036b2 <itrunc+0x32>
    if(ip->addrs[i]){
    800036a0:	408c                	lw	a1,0(s1)
    800036a2:	dde5                	beqz	a1,8000369a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800036a4:	0009a503          	lw	a0,0(s3)
    800036a8:	9abff0ef          	jal	80003052 <bfree>
      ip->addrs[i] = 0;
    800036ac:	0004a023          	sw	zero,0(s1)
    800036b0:	b7ed                	j	8000369a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800036b2:	0809a583          	lw	a1,128(s3)
    800036b6:	ed89                	bnez	a1,800036d0 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800036b8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800036bc:	854e                	mv	a0,s3
    800036be:	e21ff0ef          	jal	800034de <iupdate>
}
    800036c2:	70a2                	ld	ra,40(sp)
    800036c4:	7402                	ld	s0,32(sp)
    800036c6:	64e2                	ld	s1,24(sp)
    800036c8:	6942                	ld	s2,16(sp)
    800036ca:	69a2                	ld	s3,8(sp)
    800036cc:	6145                	addi	sp,sp,48
    800036ce:	8082                	ret
    800036d0:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800036d2:	0009a503          	lw	a0,0(s3)
    800036d6:	f84ff0ef          	jal	80002e5a <bread>
    800036da:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800036dc:	05850493          	addi	s1,a0,88
    800036e0:	45850913          	addi	s2,a0,1112
    800036e4:	a021                	j	800036ec <itrunc+0x6c>
    800036e6:	0491                	addi	s1,s1,4
    800036e8:	01248963          	beq	s1,s2,800036fa <itrunc+0x7a>
      if(a[j])
    800036ec:	408c                	lw	a1,0(s1)
    800036ee:	dde5                	beqz	a1,800036e6 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800036f0:	0009a503          	lw	a0,0(s3)
    800036f4:	95fff0ef          	jal	80003052 <bfree>
    800036f8:	b7fd                	j	800036e6 <itrunc+0x66>
    brelse(bp);
    800036fa:	8552                	mv	a0,s4
    800036fc:	867ff0ef          	jal	80002f62 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003700:	0809a583          	lw	a1,128(s3)
    80003704:	0009a503          	lw	a0,0(s3)
    80003708:	94bff0ef          	jal	80003052 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000370c:	0809a023          	sw	zero,128(s3)
    80003710:	6a02                	ld	s4,0(sp)
    80003712:	b75d                	j	800036b8 <itrunc+0x38>

0000000080003714 <iput>:
{
    80003714:	1101                	addi	sp,sp,-32
    80003716:	ec06                	sd	ra,24(sp)
    80003718:	e822                	sd	s0,16(sp)
    8000371a:	e426                	sd	s1,8(sp)
    8000371c:	1000                	addi	s0,sp,32
    8000371e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003720:	0001b517          	auipc	a0,0x1b
    80003724:	c6850513          	addi	a0,a0,-920 # 8001e388 <itable>
    80003728:	cccfd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000372c:	4498                	lw	a4,8(s1)
    8000372e:	4785                	li	a5,1
    80003730:	02f70063          	beq	a4,a5,80003750 <iput+0x3c>
  ip->ref--;
    80003734:	449c                	lw	a5,8(s1)
    80003736:	37fd                	addiw	a5,a5,-1
    80003738:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000373a:	0001b517          	auipc	a0,0x1b
    8000373e:	c4e50513          	addi	a0,a0,-946 # 8001e388 <itable>
    80003742:	d4afd0ef          	jal	80000c8c <release>
}
    80003746:	60e2                	ld	ra,24(sp)
    80003748:	6442                	ld	s0,16(sp)
    8000374a:	64a2                	ld	s1,8(sp)
    8000374c:	6105                	addi	sp,sp,32
    8000374e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003750:	40bc                	lw	a5,64(s1)
    80003752:	d3ed                	beqz	a5,80003734 <iput+0x20>
    80003754:	04a49783          	lh	a5,74(s1)
    80003758:	fff1                	bnez	a5,80003734 <iput+0x20>
    8000375a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000375c:	01048913          	addi	s2,s1,16
    80003760:	854a                	mv	a0,s2
    80003762:	151000ef          	jal	800040b2 <acquiresleep>
    release(&itable.lock);
    80003766:	0001b517          	auipc	a0,0x1b
    8000376a:	c2250513          	addi	a0,a0,-990 # 8001e388 <itable>
    8000376e:	d1efd0ef          	jal	80000c8c <release>
    itrunc(ip);
    80003772:	8526                	mv	a0,s1
    80003774:	f0dff0ef          	jal	80003680 <itrunc>
    ip->type = 0;
    80003778:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000377c:	8526                	mv	a0,s1
    8000377e:	d61ff0ef          	jal	800034de <iupdate>
    ip->valid = 0;
    80003782:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003786:	854a                	mv	a0,s2
    80003788:	171000ef          	jal	800040f8 <releasesleep>
    acquire(&itable.lock);
    8000378c:	0001b517          	auipc	a0,0x1b
    80003790:	bfc50513          	addi	a0,a0,-1028 # 8001e388 <itable>
    80003794:	c60fd0ef          	jal	80000bf4 <acquire>
    80003798:	6902                	ld	s2,0(sp)
    8000379a:	bf69                	j	80003734 <iput+0x20>

000000008000379c <iunlockput>:
{
    8000379c:	1101                	addi	sp,sp,-32
    8000379e:	ec06                	sd	ra,24(sp)
    800037a0:	e822                	sd	s0,16(sp)
    800037a2:	e426                	sd	s1,8(sp)
    800037a4:	1000                	addi	s0,sp,32
    800037a6:	84aa                	mv	s1,a0
  iunlock(ip);
    800037a8:	e99ff0ef          	jal	80003640 <iunlock>
  iput(ip);
    800037ac:	8526                	mv	a0,s1
    800037ae:	f67ff0ef          	jal	80003714 <iput>
}
    800037b2:	60e2                	ld	ra,24(sp)
    800037b4:	6442                	ld	s0,16(sp)
    800037b6:	64a2                	ld	s1,8(sp)
    800037b8:	6105                	addi	sp,sp,32
    800037ba:	8082                	ret

00000000800037bc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037bc:	1141                	addi	sp,sp,-16
    800037be:	e422                	sd	s0,8(sp)
    800037c0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037c2:	411c                	lw	a5,0(a0)
    800037c4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037c6:	415c                	lw	a5,4(a0)
    800037c8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037ca:	04451783          	lh	a5,68(a0)
    800037ce:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037d2:	04a51783          	lh	a5,74(a0)
    800037d6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037da:	04c56783          	lwu	a5,76(a0)
    800037de:	e99c                	sd	a5,16(a1)
}
    800037e0:	6422                	ld	s0,8(sp)
    800037e2:	0141                	addi	sp,sp,16
    800037e4:	8082                	ret

00000000800037e6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037e6:	457c                	lw	a5,76(a0)
    800037e8:	0ed7eb63          	bltu	a5,a3,800038de <readi+0xf8>
{
    800037ec:	7159                	addi	sp,sp,-112
    800037ee:	f486                	sd	ra,104(sp)
    800037f0:	f0a2                	sd	s0,96(sp)
    800037f2:	eca6                	sd	s1,88(sp)
    800037f4:	e0d2                	sd	s4,64(sp)
    800037f6:	fc56                	sd	s5,56(sp)
    800037f8:	f85a                	sd	s6,48(sp)
    800037fa:	f45e                	sd	s7,40(sp)
    800037fc:	1880                	addi	s0,sp,112
    800037fe:	8b2a                	mv	s6,a0
    80003800:	8bae                	mv	s7,a1
    80003802:	8a32                	mv	s4,a2
    80003804:	84b6                	mv	s1,a3
    80003806:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003808:	9f35                	addw	a4,a4,a3
    return 0;
    8000380a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000380c:	0cd76063          	bltu	a4,a3,800038cc <readi+0xe6>
    80003810:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003812:	00e7f463          	bgeu	a5,a4,8000381a <readi+0x34>
    n = ip->size - off;
    80003816:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000381a:	080a8f63          	beqz	s5,800038b8 <readi+0xd2>
    8000381e:	e8ca                	sd	s2,80(sp)
    80003820:	f062                	sd	s8,32(sp)
    80003822:	ec66                	sd	s9,24(sp)
    80003824:	e86a                	sd	s10,16(sp)
    80003826:	e46e                	sd	s11,8(sp)
    80003828:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000382a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000382e:	5c7d                	li	s8,-1
    80003830:	a80d                	j	80003862 <readi+0x7c>
    80003832:	020d1d93          	slli	s11,s10,0x20
    80003836:	020ddd93          	srli	s11,s11,0x20
    8000383a:	05890613          	addi	a2,s2,88
    8000383e:	86ee                	mv	a3,s11
    80003840:	963a                	add	a2,a2,a4
    80003842:	85d2                	mv	a1,s4
    80003844:	855e                	mv	a0,s7
    80003846:	c3dfe0ef          	jal	80002482 <either_copyout>
    8000384a:	05850763          	beq	a0,s8,80003898 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000384e:	854a                	mv	a0,s2
    80003850:	f12ff0ef          	jal	80002f62 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003854:	013d09bb          	addw	s3,s10,s3
    80003858:	009d04bb          	addw	s1,s10,s1
    8000385c:	9a6e                	add	s4,s4,s11
    8000385e:	0559f763          	bgeu	s3,s5,800038ac <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003862:	00a4d59b          	srliw	a1,s1,0xa
    80003866:	855a                	mv	a0,s6
    80003868:	977ff0ef          	jal	800031de <bmap>
    8000386c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003870:	c5b1                	beqz	a1,800038bc <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003872:	000b2503          	lw	a0,0(s6)
    80003876:	de4ff0ef          	jal	80002e5a <bread>
    8000387a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000387c:	3ff4f713          	andi	a4,s1,1023
    80003880:	40ec87bb          	subw	a5,s9,a4
    80003884:	413a86bb          	subw	a3,s5,s3
    80003888:	8d3e                	mv	s10,a5
    8000388a:	2781                	sext.w	a5,a5
    8000388c:	0006861b          	sext.w	a2,a3
    80003890:	faf671e3          	bgeu	a2,a5,80003832 <readi+0x4c>
    80003894:	8d36                	mv	s10,a3
    80003896:	bf71                	j	80003832 <readi+0x4c>
      brelse(bp);
    80003898:	854a                	mv	a0,s2
    8000389a:	ec8ff0ef          	jal	80002f62 <brelse>
      tot = -1;
    8000389e:	59fd                	li	s3,-1
      break;
    800038a0:	6946                	ld	s2,80(sp)
    800038a2:	7c02                	ld	s8,32(sp)
    800038a4:	6ce2                	ld	s9,24(sp)
    800038a6:	6d42                	ld	s10,16(sp)
    800038a8:	6da2                	ld	s11,8(sp)
    800038aa:	a831                	j	800038c6 <readi+0xe0>
    800038ac:	6946                	ld	s2,80(sp)
    800038ae:	7c02                	ld	s8,32(sp)
    800038b0:	6ce2                	ld	s9,24(sp)
    800038b2:	6d42                	ld	s10,16(sp)
    800038b4:	6da2                	ld	s11,8(sp)
    800038b6:	a801                	j	800038c6 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038b8:	89d6                	mv	s3,s5
    800038ba:	a031                	j	800038c6 <readi+0xe0>
    800038bc:	6946                	ld	s2,80(sp)
    800038be:	7c02                	ld	s8,32(sp)
    800038c0:	6ce2                	ld	s9,24(sp)
    800038c2:	6d42                	ld	s10,16(sp)
    800038c4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038c6:	0009851b          	sext.w	a0,s3
    800038ca:	69a6                	ld	s3,72(sp)
}
    800038cc:	70a6                	ld	ra,104(sp)
    800038ce:	7406                	ld	s0,96(sp)
    800038d0:	64e6                	ld	s1,88(sp)
    800038d2:	6a06                	ld	s4,64(sp)
    800038d4:	7ae2                	ld	s5,56(sp)
    800038d6:	7b42                	ld	s6,48(sp)
    800038d8:	7ba2                	ld	s7,40(sp)
    800038da:	6165                	addi	sp,sp,112
    800038dc:	8082                	ret
    return 0;
    800038de:	4501                	li	a0,0
}
    800038e0:	8082                	ret

00000000800038e2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038e2:	457c                	lw	a5,76(a0)
    800038e4:	10d7e063          	bltu	a5,a3,800039e4 <writei+0x102>
{
    800038e8:	7159                	addi	sp,sp,-112
    800038ea:	f486                	sd	ra,104(sp)
    800038ec:	f0a2                	sd	s0,96(sp)
    800038ee:	e8ca                	sd	s2,80(sp)
    800038f0:	e0d2                	sd	s4,64(sp)
    800038f2:	fc56                	sd	s5,56(sp)
    800038f4:	f85a                	sd	s6,48(sp)
    800038f6:	f45e                	sd	s7,40(sp)
    800038f8:	1880                	addi	s0,sp,112
    800038fa:	8aaa                	mv	s5,a0
    800038fc:	8bae                	mv	s7,a1
    800038fe:	8a32                	mv	s4,a2
    80003900:	8936                	mv	s2,a3
    80003902:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003904:	00e687bb          	addw	a5,a3,a4
    80003908:	0ed7e063          	bltu	a5,a3,800039e8 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000390c:	00043737          	lui	a4,0x43
    80003910:	0cf76e63          	bltu	a4,a5,800039ec <writei+0x10a>
    80003914:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003916:	0a0b0f63          	beqz	s6,800039d4 <writei+0xf2>
    8000391a:	eca6                	sd	s1,88(sp)
    8000391c:	f062                	sd	s8,32(sp)
    8000391e:	ec66                	sd	s9,24(sp)
    80003920:	e86a                	sd	s10,16(sp)
    80003922:	e46e                	sd	s11,8(sp)
    80003924:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003926:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000392a:	5c7d                	li	s8,-1
    8000392c:	a825                	j	80003964 <writei+0x82>
    8000392e:	020d1d93          	slli	s11,s10,0x20
    80003932:	020ddd93          	srli	s11,s11,0x20
    80003936:	05848513          	addi	a0,s1,88
    8000393a:	86ee                	mv	a3,s11
    8000393c:	8652                	mv	a2,s4
    8000393e:	85de                	mv	a1,s7
    80003940:	953a                	add	a0,a0,a4
    80003942:	b8bfe0ef          	jal	800024cc <either_copyin>
    80003946:	05850a63          	beq	a0,s8,8000399a <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000394a:	8526                	mv	a0,s1
    8000394c:	660000ef          	jal	80003fac <log_write>
    brelse(bp);
    80003950:	8526                	mv	a0,s1
    80003952:	e10ff0ef          	jal	80002f62 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003956:	013d09bb          	addw	s3,s10,s3
    8000395a:	012d093b          	addw	s2,s10,s2
    8000395e:	9a6e                	add	s4,s4,s11
    80003960:	0569f063          	bgeu	s3,s6,800039a0 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003964:	00a9559b          	srliw	a1,s2,0xa
    80003968:	8556                	mv	a0,s5
    8000396a:	875ff0ef          	jal	800031de <bmap>
    8000396e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003972:	c59d                	beqz	a1,800039a0 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003974:	000aa503          	lw	a0,0(s5)
    80003978:	ce2ff0ef          	jal	80002e5a <bread>
    8000397c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000397e:	3ff97713          	andi	a4,s2,1023
    80003982:	40ec87bb          	subw	a5,s9,a4
    80003986:	413b06bb          	subw	a3,s6,s3
    8000398a:	8d3e                	mv	s10,a5
    8000398c:	2781                	sext.w	a5,a5
    8000398e:	0006861b          	sext.w	a2,a3
    80003992:	f8f67ee3          	bgeu	a2,a5,8000392e <writei+0x4c>
    80003996:	8d36                	mv	s10,a3
    80003998:	bf59                	j	8000392e <writei+0x4c>
      brelse(bp);
    8000399a:	8526                	mv	a0,s1
    8000399c:	dc6ff0ef          	jal	80002f62 <brelse>
  }

  if(off > ip->size)
    800039a0:	04caa783          	lw	a5,76(s5)
    800039a4:	0327fa63          	bgeu	a5,s2,800039d8 <writei+0xf6>
    ip->size = off;
    800039a8:	052aa623          	sw	s2,76(s5)
    800039ac:	64e6                	ld	s1,88(sp)
    800039ae:	7c02                	ld	s8,32(sp)
    800039b0:	6ce2                	ld	s9,24(sp)
    800039b2:	6d42                	ld	s10,16(sp)
    800039b4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039b6:	8556                	mv	a0,s5
    800039b8:	b27ff0ef          	jal	800034de <iupdate>

  return tot;
    800039bc:	0009851b          	sext.w	a0,s3
    800039c0:	69a6                	ld	s3,72(sp)
}
    800039c2:	70a6                	ld	ra,104(sp)
    800039c4:	7406                	ld	s0,96(sp)
    800039c6:	6946                	ld	s2,80(sp)
    800039c8:	6a06                	ld	s4,64(sp)
    800039ca:	7ae2                	ld	s5,56(sp)
    800039cc:	7b42                	ld	s6,48(sp)
    800039ce:	7ba2                	ld	s7,40(sp)
    800039d0:	6165                	addi	sp,sp,112
    800039d2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039d4:	89da                	mv	s3,s6
    800039d6:	b7c5                	j	800039b6 <writei+0xd4>
    800039d8:	64e6                	ld	s1,88(sp)
    800039da:	7c02                	ld	s8,32(sp)
    800039dc:	6ce2                	ld	s9,24(sp)
    800039de:	6d42                	ld	s10,16(sp)
    800039e0:	6da2                	ld	s11,8(sp)
    800039e2:	bfd1                	j	800039b6 <writei+0xd4>
    return -1;
    800039e4:	557d                	li	a0,-1
}
    800039e6:	8082                	ret
    return -1;
    800039e8:	557d                	li	a0,-1
    800039ea:	bfe1                	j	800039c2 <writei+0xe0>
    return -1;
    800039ec:	557d                	li	a0,-1
    800039ee:	bfd1                	j	800039c2 <writei+0xe0>

00000000800039f0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039f0:	1141                	addi	sp,sp,-16
    800039f2:	e406                	sd	ra,8(sp)
    800039f4:	e022                	sd	s0,0(sp)
    800039f6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800039f8:	4639                	li	a2,14
    800039fa:	b9afd0ef          	jal	80000d94 <strncmp>
}
    800039fe:	60a2                	ld	ra,8(sp)
    80003a00:	6402                	ld	s0,0(sp)
    80003a02:	0141                	addi	sp,sp,16
    80003a04:	8082                	ret

0000000080003a06 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a06:	7139                	addi	sp,sp,-64
    80003a08:	fc06                	sd	ra,56(sp)
    80003a0a:	f822                	sd	s0,48(sp)
    80003a0c:	f426                	sd	s1,40(sp)
    80003a0e:	f04a                	sd	s2,32(sp)
    80003a10:	ec4e                	sd	s3,24(sp)
    80003a12:	e852                	sd	s4,16(sp)
    80003a14:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a16:	04451703          	lh	a4,68(a0)
    80003a1a:	4785                	li	a5,1
    80003a1c:	00f71a63          	bne	a4,a5,80003a30 <dirlookup+0x2a>
    80003a20:	892a                	mv	s2,a0
    80003a22:	89ae                	mv	s3,a1
    80003a24:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a26:	457c                	lw	a5,76(a0)
    80003a28:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a2a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a2c:	e39d                	bnez	a5,80003a52 <dirlookup+0x4c>
    80003a2e:	a095                	j	80003a92 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003a30:	00004517          	auipc	a0,0x4
    80003a34:	af050513          	addi	a0,a0,-1296 # 80007520 <etext+0x520>
    80003a38:	d5dfc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003a3c:	00004517          	auipc	a0,0x4
    80003a40:	afc50513          	addi	a0,a0,-1284 # 80007538 <etext+0x538>
    80003a44:	d51fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a48:	24c1                	addiw	s1,s1,16
    80003a4a:	04c92783          	lw	a5,76(s2)
    80003a4e:	04f4f163          	bgeu	s1,a5,80003a90 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a52:	4741                	li	a4,16
    80003a54:	86a6                	mv	a3,s1
    80003a56:	fc040613          	addi	a2,s0,-64
    80003a5a:	4581                	li	a1,0
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	d89ff0ef          	jal	800037e6 <readi>
    80003a62:	47c1                	li	a5,16
    80003a64:	fcf51ce3          	bne	a0,a5,80003a3c <dirlookup+0x36>
    if(de.inum == 0)
    80003a68:	fc045783          	lhu	a5,-64(s0)
    80003a6c:	dff1                	beqz	a5,80003a48 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003a6e:	fc240593          	addi	a1,s0,-62
    80003a72:	854e                	mv	a0,s3
    80003a74:	f7dff0ef          	jal	800039f0 <namecmp>
    80003a78:	f961                	bnez	a0,80003a48 <dirlookup+0x42>
      if(poff)
    80003a7a:	000a0463          	beqz	s4,80003a82 <dirlookup+0x7c>
        *poff = off;
    80003a7e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003a82:	fc045583          	lhu	a1,-64(s0)
    80003a86:	00092503          	lw	a0,0(s2)
    80003a8a:	829ff0ef          	jal	800032b2 <iget>
    80003a8e:	a011                	j	80003a92 <dirlookup+0x8c>
  return 0;
    80003a90:	4501                	li	a0,0
}
    80003a92:	70e2                	ld	ra,56(sp)
    80003a94:	7442                	ld	s0,48(sp)
    80003a96:	74a2                	ld	s1,40(sp)
    80003a98:	7902                	ld	s2,32(sp)
    80003a9a:	69e2                	ld	s3,24(sp)
    80003a9c:	6a42                	ld	s4,16(sp)
    80003a9e:	6121                	addi	sp,sp,64
    80003aa0:	8082                	ret

0000000080003aa2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003aa2:	711d                	addi	sp,sp,-96
    80003aa4:	ec86                	sd	ra,88(sp)
    80003aa6:	e8a2                	sd	s0,80(sp)
    80003aa8:	e4a6                	sd	s1,72(sp)
    80003aaa:	e0ca                	sd	s2,64(sp)
    80003aac:	fc4e                	sd	s3,56(sp)
    80003aae:	f852                	sd	s4,48(sp)
    80003ab0:	f456                	sd	s5,40(sp)
    80003ab2:	f05a                	sd	s6,32(sp)
    80003ab4:	ec5e                	sd	s7,24(sp)
    80003ab6:	e862                	sd	s8,16(sp)
    80003ab8:	e466                	sd	s9,8(sp)
    80003aba:	1080                	addi	s0,sp,96
    80003abc:	84aa                	mv	s1,a0
    80003abe:	8b2e                	mv	s6,a1
    80003ac0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ac2:	00054703          	lbu	a4,0(a0)
    80003ac6:	02f00793          	li	a5,47
    80003aca:	00f70e63          	beq	a4,a5,80003ae6 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ace:	e13fd0ef          	jal	800018e0 <myproc>
    80003ad2:	15053503          	ld	a0,336(a0)
    80003ad6:	a87ff0ef          	jal	8000355c <idup>
    80003ada:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003adc:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ae0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ae2:	4b85                	li	s7,1
    80003ae4:	a871                	j	80003b80 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003ae6:	4585                	li	a1,1
    80003ae8:	4505                	li	a0,1
    80003aea:	fc8ff0ef          	jal	800032b2 <iget>
    80003aee:	8a2a                	mv	s4,a0
    80003af0:	b7f5                	j	80003adc <namex+0x3a>
      iunlockput(ip);
    80003af2:	8552                	mv	a0,s4
    80003af4:	ca9ff0ef          	jal	8000379c <iunlockput>
      return 0;
    80003af8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003afa:	8552                	mv	a0,s4
    80003afc:	60e6                	ld	ra,88(sp)
    80003afe:	6446                	ld	s0,80(sp)
    80003b00:	64a6                	ld	s1,72(sp)
    80003b02:	6906                	ld	s2,64(sp)
    80003b04:	79e2                	ld	s3,56(sp)
    80003b06:	7a42                	ld	s4,48(sp)
    80003b08:	7aa2                	ld	s5,40(sp)
    80003b0a:	7b02                	ld	s6,32(sp)
    80003b0c:	6be2                	ld	s7,24(sp)
    80003b0e:	6c42                	ld	s8,16(sp)
    80003b10:	6ca2                	ld	s9,8(sp)
    80003b12:	6125                	addi	sp,sp,96
    80003b14:	8082                	ret
      iunlock(ip);
    80003b16:	8552                	mv	a0,s4
    80003b18:	b29ff0ef          	jal	80003640 <iunlock>
      return ip;
    80003b1c:	bff9                	j	80003afa <namex+0x58>
      iunlockput(ip);
    80003b1e:	8552                	mv	a0,s4
    80003b20:	c7dff0ef          	jal	8000379c <iunlockput>
      return 0;
    80003b24:	8a4e                	mv	s4,s3
    80003b26:	bfd1                	j	80003afa <namex+0x58>
  len = path - s;
    80003b28:	40998633          	sub	a2,s3,s1
    80003b2c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003b30:	099c5063          	bge	s8,s9,80003bb0 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003b34:	4639                	li	a2,14
    80003b36:	85a6                	mv	a1,s1
    80003b38:	8556                	mv	a0,s5
    80003b3a:	9eafd0ef          	jal	80000d24 <memmove>
    80003b3e:	84ce                	mv	s1,s3
  while(*path == '/')
    80003b40:	0004c783          	lbu	a5,0(s1)
    80003b44:	01279763          	bne	a5,s2,80003b52 <namex+0xb0>
    path++;
    80003b48:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b4a:	0004c783          	lbu	a5,0(s1)
    80003b4e:	ff278de3          	beq	a5,s2,80003b48 <namex+0xa6>
    ilock(ip);
    80003b52:	8552                	mv	a0,s4
    80003b54:	a3fff0ef          	jal	80003592 <ilock>
    if(ip->type != T_DIR){
    80003b58:	044a1783          	lh	a5,68(s4)
    80003b5c:	f9779be3          	bne	a5,s7,80003af2 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003b60:	000b0563          	beqz	s6,80003b6a <namex+0xc8>
    80003b64:	0004c783          	lbu	a5,0(s1)
    80003b68:	d7dd                	beqz	a5,80003b16 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b6a:	4601                	li	a2,0
    80003b6c:	85d6                	mv	a1,s5
    80003b6e:	8552                	mv	a0,s4
    80003b70:	e97ff0ef          	jal	80003a06 <dirlookup>
    80003b74:	89aa                	mv	s3,a0
    80003b76:	d545                	beqz	a0,80003b1e <namex+0x7c>
    iunlockput(ip);
    80003b78:	8552                	mv	a0,s4
    80003b7a:	c23ff0ef          	jal	8000379c <iunlockput>
    ip = next;
    80003b7e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003b80:	0004c783          	lbu	a5,0(s1)
    80003b84:	01279763          	bne	a5,s2,80003b92 <namex+0xf0>
    path++;
    80003b88:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b8a:	0004c783          	lbu	a5,0(s1)
    80003b8e:	ff278de3          	beq	a5,s2,80003b88 <namex+0xe6>
  if(*path == 0)
    80003b92:	cb8d                	beqz	a5,80003bc4 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003b94:	0004c783          	lbu	a5,0(s1)
    80003b98:	89a6                	mv	s3,s1
  len = path - s;
    80003b9a:	4c81                	li	s9,0
    80003b9c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003b9e:	01278963          	beq	a5,s2,80003bb0 <namex+0x10e>
    80003ba2:	d3d9                	beqz	a5,80003b28 <namex+0x86>
    path++;
    80003ba4:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003ba6:	0009c783          	lbu	a5,0(s3)
    80003baa:	ff279ce3          	bne	a5,s2,80003ba2 <namex+0x100>
    80003bae:	bfad                	j	80003b28 <namex+0x86>
    memmove(name, s, len);
    80003bb0:	2601                	sext.w	a2,a2
    80003bb2:	85a6                	mv	a1,s1
    80003bb4:	8556                	mv	a0,s5
    80003bb6:	96efd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003bba:	9cd6                	add	s9,s9,s5
    80003bbc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003bc0:	84ce                	mv	s1,s3
    80003bc2:	bfbd                	j	80003b40 <namex+0x9e>
  if(nameiparent){
    80003bc4:	f20b0be3          	beqz	s6,80003afa <namex+0x58>
    iput(ip);
    80003bc8:	8552                	mv	a0,s4
    80003bca:	b4bff0ef          	jal	80003714 <iput>
    return 0;
    80003bce:	4a01                	li	s4,0
    80003bd0:	b72d                	j	80003afa <namex+0x58>

0000000080003bd2 <dirlink>:
{
    80003bd2:	7139                	addi	sp,sp,-64
    80003bd4:	fc06                	sd	ra,56(sp)
    80003bd6:	f822                	sd	s0,48(sp)
    80003bd8:	f04a                	sd	s2,32(sp)
    80003bda:	ec4e                	sd	s3,24(sp)
    80003bdc:	e852                	sd	s4,16(sp)
    80003bde:	0080                	addi	s0,sp,64
    80003be0:	892a                	mv	s2,a0
    80003be2:	8a2e                	mv	s4,a1
    80003be4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003be6:	4601                	li	a2,0
    80003be8:	e1fff0ef          	jal	80003a06 <dirlookup>
    80003bec:	e535                	bnez	a0,80003c58 <dirlink+0x86>
    80003bee:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf0:	04c92483          	lw	s1,76(s2)
    80003bf4:	c48d                	beqz	s1,80003c1e <dirlink+0x4c>
    80003bf6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bf8:	4741                	li	a4,16
    80003bfa:	86a6                	mv	a3,s1
    80003bfc:	fc040613          	addi	a2,s0,-64
    80003c00:	4581                	li	a1,0
    80003c02:	854a                	mv	a0,s2
    80003c04:	be3ff0ef          	jal	800037e6 <readi>
    80003c08:	47c1                	li	a5,16
    80003c0a:	04f51b63          	bne	a0,a5,80003c60 <dirlink+0x8e>
    if(de.inum == 0)
    80003c0e:	fc045783          	lhu	a5,-64(s0)
    80003c12:	c791                	beqz	a5,80003c1e <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c14:	24c1                	addiw	s1,s1,16
    80003c16:	04c92783          	lw	a5,76(s2)
    80003c1a:	fcf4efe3          	bltu	s1,a5,80003bf8 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003c1e:	4639                	li	a2,14
    80003c20:	85d2                	mv	a1,s4
    80003c22:	fc240513          	addi	a0,s0,-62
    80003c26:	9a4fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003c2a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c2e:	4741                	li	a4,16
    80003c30:	86a6                	mv	a3,s1
    80003c32:	fc040613          	addi	a2,s0,-64
    80003c36:	4581                	li	a1,0
    80003c38:	854a                	mv	a0,s2
    80003c3a:	ca9ff0ef          	jal	800038e2 <writei>
    80003c3e:	1541                	addi	a0,a0,-16
    80003c40:	00a03533          	snez	a0,a0
    80003c44:	40a00533          	neg	a0,a0
    80003c48:	74a2                	ld	s1,40(sp)
}
    80003c4a:	70e2                	ld	ra,56(sp)
    80003c4c:	7442                	ld	s0,48(sp)
    80003c4e:	7902                	ld	s2,32(sp)
    80003c50:	69e2                	ld	s3,24(sp)
    80003c52:	6a42                	ld	s4,16(sp)
    80003c54:	6121                	addi	sp,sp,64
    80003c56:	8082                	ret
    iput(ip);
    80003c58:	abdff0ef          	jal	80003714 <iput>
    return -1;
    80003c5c:	557d                	li	a0,-1
    80003c5e:	b7f5                	j	80003c4a <dirlink+0x78>
      panic("dirlink read");
    80003c60:	00004517          	auipc	a0,0x4
    80003c64:	8e850513          	addi	a0,a0,-1816 # 80007548 <etext+0x548>
    80003c68:	b2dfc0ef          	jal	80000794 <panic>

0000000080003c6c <namei>:

struct inode*
namei(char *path)
{
    80003c6c:	1101                	addi	sp,sp,-32
    80003c6e:	ec06                	sd	ra,24(sp)
    80003c70:	e822                	sd	s0,16(sp)
    80003c72:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c74:	fe040613          	addi	a2,s0,-32
    80003c78:	4581                	li	a1,0
    80003c7a:	e29ff0ef          	jal	80003aa2 <namex>
}
    80003c7e:	60e2                	ld	ra,24(sp)
    80003c80:	6442                	ld	s0,16(sp)
    80003c82:	6105                	addi	sp,sp,32
    80003c84:	8082                	ret

0000000080003c86 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c86:	1141                	addi	sp,sp,-16
    80003c88:	e406                	sd	ra,8(sp)
    80003c8a:	e022                	sd	s0,0(sp)
    80003c8c:	0800                	addi	s0,sp,16
    80003c8e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c90:	4585                	li	a1,1
    80003c92:	e11ff0ef          	jal	80003aa2 <namex>
}
    80003c96:	60a2                	ld	ra,8(sp)
    80003c98:	6402                	ld	s0,0(sp)
    80003c9a:	0141                	addi	sp,sp,16
    80003c9c:	8082                	ret

0000000080003c9e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c9e:	1101                	addi	sp,sp,-32
    80003ca0:	ec06                	sd	ra,24(sp)
    80003ca2:	e822                	sd	s0,16(sp)
    80003ca4:	e426                	sd	s1,8(sp)
    80003ca6:	e04a                	sd	s2,0(sp)
    80003ca8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003caa:	0001c917          	auipc	s2,0x1c
    80003cae:	18690913          	addi	s2,s2,390 # 8001fe30 <log>
    80003cb2:	01892583          	lw	a1,24(s2)
    80003cb6:	02892503          	lw	a0,40(s2)
    80003cba:	9a0ff0ef          	jal	80002e5a <bread>
    80003cbe:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003cc0:	02c92603          	lw	a2,44(s2)
    80003cc4:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003cc6:	00c05f63          	blez	a2,80003ce4 <write_head+0x46>
    80003cca:	0001c717          	auipc	a4,0x1c
    80003cce:	19670713          	addi	a4,a4,406 # 8001fe60 <log+0x30>
    80003cd2:	87aa                	mv	a5,a0
    80003cd4:	060a                	slli	a2,a2,0x2
    80003cd6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003cd8:	4314                	lw	a3,0(a4)
    80003cda:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003cdc:	0711                	addi	a4,a4,4
    80003cde:	0791                	addi	a5,a5,4
    80003ce0:	fec79ce3          	bne	a5,a2,80003cd8 <write_head+0x3a>
  }
  bwrite(buf);
    80003ce4:	8526                	mv	a0,s1
    80003ce6:	a4aff0ef          	jal	80002f30 <bwrite>
  brelse(buf);
    80003cea:	8526                	mv	a0,s1
    80003cec:	a76ff0ef          	jal	80002f62 <brelse>
}
    80003cf0:	60e2                	ld	ra,24(sp)
    80003cf2:	6442                	ld	s0,16(sp)
    80003cf4:	64a2                	ld	s1,8(sp)
    80003cf6:	6902                	ld	s2,0(sp)
    80003cf8:	6105                	addi	sp,sp,32
    80003cfa:	8082                	ret

0000000080003cfc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cfc:	0001c797          	auipc	a5,0x1c
    80003d00:	1607a783          	lw	a5,352(a5) # 8001fe5c <log+0x2c>
    80003d04:	08f05f63          	blez	a5,80003da2 <install_trans+0xa6>
{
    80003d08:	7139                	addi	sp,sp,-64
    80003d0a:	fc06                	sd	ra,56(sp)
    80003d0c:	f822                	sd	s0,48(sp)
    80003d0e:	f426                	sd	s1,40(sp)
    80003d10:	f04a                	sd	s2,32(sp)
    80003d12:	ec4e                	sd	s3,24(sp)
    80003d14:	e852                	sd	s4,16(sp)
    80003d16:	e456                	sd	s5,8(sp)
    80003d18:	e05a                	sd	s6,0(sp)
    80003d1a:	0080                	addi	s0,sp,64
    80003d1c:	8b2a                	mv	s6,a0
    80003d1e:	0001ca97          	auipc	s5,0x1c
    80003d22:	142a8a93          	addi	s5,s5,322 # 8001fe60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d26:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d28:	0001c997          	auipc	s3,0x1c
    80003d2c:	10898993          	addi	s3,s3,264 # 8001fe30 <log>
    80003d30:	a829                	j	80003d4a <install_trans+0x4e>
    brelse(lbuf);
    80003d32:	854a                	mv	a0,s2
    80003d34:	a2eff0ef          	jal	80002f62 <brelse>
    brelse(dbuf);
    80003d38:	8526                	mv	a0,s1
    80003d3a:	a28ff0ef          	jal	80002f62 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d3e:	2a05                	addiw	s4,s4,1
    80003d40:	0a91                	addi	s5,s5,4
    80003d42:	02c9a783          	lw	a5,44(s3)
    80003d46:	04fa5463          	bge	s4,a5,80003d8e <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d4a:	0189a583          	lw	a1,24(s3)
    80003d4e:	014585bb          	addw	a1,a1,s4
    80003d52:	2585                	addiw	a1,a1,1
    80003d54:	0289a503          	lw	a0,40(s3)
    80003d58:	902ff0ef          	jal	80002e5a <bread>
    80003d5c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d5e:	000aa583          	lw	a1,0(s5)
    80003d62:	0289a503          	lw	a0,40(s3)
    80003d66:	8f4ff0ef          	jal	80002e5a <bread>
    80003d6a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d6c:	40000613          	li	a2,1024
    80003d70:	05890593          	addi	a1,s2,88
    80003d74:	05850513          	addi	a0,a0,88
    80003d78:	fadfc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d7c:	8526                	mv	a0,s1
    80003d7e:	9b2ff0ef          	jal	80002f30 <bwrite>
    if(recovering == 0)
    80003d82:	fa0b18e3          	bnez	s6,80003d32 <install_trans+0x36>
      bunpin(dbuf);
    80003d86:	8526                	mv	a0,s1
    80003d88:	a96ff0ef          	jal	8000301e <bunpin>
    80003d8c:	b75d                	j	80003d32 <install_trans+0x36>
}
    80003d8e:	70e2                	ld	ra,56(sp)
    80003d90:	7442                	ld	s0,48(sp)
    80003d92:	74a2                	ld	s1,40(sp)
    80003d94:	7902                	ld	s2,32(sp)
    80003d96:	69e2                	ld	s3,24(sp)
    80003d98:	6a42                	ld	s4,16(sp)
    80003d9a:	6aa2                	ld	s5,8(sp)
    80003d9c:	6b02                	ld	s6,0(sp)
    80003d9e:	6121                	addi	sp,sp,64
    80003da0:	8082                	ret
    80003da2:	8082                	ret

0000000080003da4 <initlog>:
{
    80003da4:	7179                	addi	sp,sp,-48
    80003da6:	f406                	sd	ra,40(sp)
    80003da8:	f022                	sd	s0,32(sp)
    80003daa:	ec26                	sd	s1,24(sp)
    80003dac:	e84a                	sd	s2,16(sp)
    80003dae:	e44e                	sd	s3,8(sp)
    80003db0:	1800                	addi	s0,sp,48
    80003db2:	892a                	mv	s2,a0
    80003db4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003db6:	0001c497          	auipc	s1,0x1c
    80003dba:	07a48493          	addi	s1,s1,122 # 8001fe30 <log>
    80003dbe:	00003597          	auipc	a1,0x3
    80003dc2:	79a58593          	addi	a1,a1,1946 # 80007558 <etext+0x558>
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	dadfc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003dcc:	0149a583          	lw	a1,20(s3)
    80003dd0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003dd2:	0109a783          	lw	a5,16(s3)
    80003dd6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003dd8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ddc:	854a                	mv	a0,s2
    80003dde:	87cff0ef          	jal	80002e5a <bread>
  log.lh.n = lh->n;
    80003de2:	4d30                	lw	a2,88(a0)
    80003de4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003de6:	00c05f63          	blez	a2,80003e04 <initlog+0x60>
    80003dea:	87aa                	mv	a5,a0
    80003dec:	0001c717          	auipc	a4,0x1c
    80003df0:	07470713          	addi	a4,a4,116 # 8001fe60 <log+0x30>
    80003df4:	060a                	slli	a2,a2,0x2
    80003df6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003df8:	4ff4                	lw	a3,92(a5)
    80003dfa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003dfc:	0791                	addi	a5,a5,4
    80003dfe:	0711                	addi	a4,a4,4
    80003e00:	fec79ce3          	bne	a5,a2,80003df8 <initlog+0x54>
  brelse(buf);
    80003e04:	95eff0ef          	jal	80002f62 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e08:	4505                	li	a0,1
    80003e0a:	ef3ff0ef          	jal	80003cfc <install_trans>
  log.lh.n = 0;
    80003e0e:	0001c797          	auipc	a5,0x1c
    80003e12:	0407a723          	sw	zero,78(a5) # 8001fe5c <log+0x2c>
  write_head(); // clear the log
    80003e16:	e89ff0ef          	jal	80003c9e <write_head>
}
    80003e1a:	70a2                	ld	ra,40(sp)
    80003e1c:	7402                	ld	s0,32(sp)
    80003e1e:	64e2                	ld	s1,24(sp)
    80003e20:	6942                	ld	s2,16(sp)
    80003e22:	69a2                	ld	s3,8(sp)
    80003e24:	6145                	addi	sp,sp,48
    80003e26:	8082                	ret

0000000080003e28 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e28:	1101                	addi	sp,sp,-32
    80003e2a:	ec06                	sd	ra,24(sp)
    80003e2c:	e822                	sd	s0,16(sp)
    80003e2e:	e426                	sd	s1,8(sp)
    80003e30:	e04a                	sd	s2,0(sp)
    80003e32:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e34:	0001c517          	auipc	a0,0x1c
    80003e38:	ffc50513          	addi	a0,a0,-4 # 8001fe30 <log>
    80003e3c:	db9fc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003e40:	0001c497          	auipc	s1,0x1c
    80003e44:	ff048493          	addi	s1,s1,-16 # 8001fe30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e48:	4979                	li	s2,30
    80003e4a:	a029                	j	80003e54 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e4c:	85a6                	mv	a1,s1
    80003e4e:	8526                	mv	a0,s1
    80003e50:	ad6fe0ef          	jal	80002126 <sleep>
    if(log.committing){
    80003e54:	50dc                	lw	a5,36(s1)
    80003e56:	fbfd                	bnez	a5,80003e4c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e58:	5098                	lw	a4,32(s1)
    80003e5a:	2705                	addiw	a4,a4,1
    80003e5c:	0027179b          	slliw	a5,a4,0x2
    80003e60:	9fb9                	addw	a5,a5,a4
    80003e62:	0017979b          	slliw	a5,a5,0x1
    80003e66:	54d4                	lw	a3,44(s1)
    80003e68:	9fb5                	addw	a5,a5,a3
    80003e6a:	00f95763          	bge	s2,a5,80003e78 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e6e:	85a6                	mv	a1,s1
    80003e70:	8526                	mv	a0,s1
    80003e72:	ab4fe0ef          	jal	80002126 <sleep>
    80003e76:	bff9                	j	80003e54 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e78:	0001c517          	auipc	a0,0x1c
    80003e7c:	fb850513          	addi	a0,a0,-72 # 8001fe30 <log>
    80003e80:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003e82:	e0bfc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003e86:	60e2                	ld	ra,24(sp)
    80003e88:	6442                	ld	s0,16(sp)
    80003e8a:	64a2                	ld	s1,8(sp)
    80003e8c:	6902                	ld	s2,0(sp)
    80003e8e:	6105                	addi	sp,sp,32
    80003e90:	8082                	ret

0000000080003e92 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e92:	7139                	addi	sp,sp,-64
    80003e94:	fc06                	sd	ra,56(sp)
    80003e96:	f822                	sd	s0,48(sp)
    80003e98:	f426                	sd	s1,40(sp)
    80003e9a:	f04a                	sd	s2,32(sp)
    80003e9c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e9e:	0001c497          	auipc	s1,0x1c
    80003ea2:	f9248493          	addi	s1,s1,-110 # 8001fe30 <log>
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	d4dfc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003eac:	509c                	lw	a5,32(s1)
    80003eae:	37fd                	addiw	a5,a5,-1
    80003eb0:	0007891b          	sext.w	s2,a5
    80003eb4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003eb6:	50dc                	lw	a5,36(s1)
    80003eb8:	ef9d                	bnez	a5,80003ef6 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003eba:	04091763          	bnez	s2,80003f08 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003ebe:	0001c497          	auipc	s1,0x1c
    80003ec2:	f7248493          	addi	s1,s1,-142 # 8001fe30 <log>
    80003ec6:	4785                	li	a5,1
    80003ec8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003eca:	8526                	mv	a0,s1
    80003ecc:	dc1fc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ed0:	54dc                	lw	a5,44(s1)
    80003ed2:	04f04b63          	bgtz	a5,80003f28 <end_op+0x96>
    acquire(&log.lock);
    80003ed6:	0001c497          	auipc	s1,0x1c
    80003eda:	f5a48493          	addi	s1,s1,-166 # 8001fe30 <log>
    80003ede:	8526                	mv	a0,s1
    80003ee0:	d15fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003ee4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003ee8:	8526                	mv	a0,s1
    80003eea:	a88fe0ef          	jal	80002172 <wakeup>
    release(&log.lock);
    80003eee:	8526                	mv	a0,s1
    80003ef0:	d9dfc0ef          	jal	80000c8c <release>
}
    80003ef4:	a025                	j	80003f1c <end_op+0x8a>
    80003ef6:	ec4e                	sd	s3,24(sp)
    80003ef8:	e852                	sd	s4,16(sp)
    80003efa:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003efc:	00003517          	auipc	a0,0x3
    80003f00:	66450513          	addi	a0,a0,1636 # 80007560 <etext+0x560>
    80003f04:	891fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003f08:	0001c497          	auipc	s1,0x1c
    80003f0c:	f2848493          	addi	s1,s1,-216 # 8001fe30 <log>
    80003f10:	8526                	mv	a0,s1
    80003f12:	a60fe0ef          	jal	80002172 <wakeup>
  release(&log.lock);
    80003f16:	8526                	mv	a0,s1
    80003f18:	d75fc0ef          	jal	80000c8c <release>
}
    80003f1c:	70e2                	ld	ra,56(sp)
    80003f1e:	7442                	ld	s0,48(sp)
    80003f20:	74a2                	ld	s1,40(sp)
    80003f22:	7902                	ld	s2,32(sp)
    80003f24:	6121                	addi	sp,sp,64
    80003f26:	8082                	ret
    80003f28:	ec4e                	sd	s3,24(sp)
    80003f2a:	e852                	sd	s4,16(sp)
    80003f2c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f2e:	0001ca97          	auipc	s5,0x1c
    80003f32:	f32a8a93          	addi	s5,s5,-206 # 8001fe60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f36:	0001ca17          	auipc	s4,0x1c
    80003f3a:	efaa0a13          	addi	s4,s4,-262 # 8001fe30 <log>
    80003f3e:	018a2583          	lw	a1,24(s4)
    80003f42:	012585bb          	addw	a1,a1,s2
    80003f46:	2585                	addiw	a1,a1,1
    80003f48:	028a2503          	lw	a0,40(s4)
    80003f4c:	f0ffe0ef          	jal	80002e5a <bread>
    80003f50:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f52:	000aa583          	lw	a1,0(s5)
    80003f56:	028a2503          	lw	a0,40(s4)
    80003f5a:	f01fe0ef          	jal	80002e5a <bread>
    80003f5e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f60:	40000613          	li	a2,1024
    80003f64:	05850593          	addi	a1,a0,88
    80003f68:	05848513          	addi	a0,s1,88
    80003f6c:	db9fc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003f70:	8526                	mv	a0,s1
    80003f72:	fbffe0ef          	jal	80002f30 <bwrite>
    brelse(from);
    80003f76:	854e                	mv	a0,s3
    80003f78:	febfe0ef          	jal	80002f62 <brelse>
    brelse(to);
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	fe5fe0ef          	jal	80002f62 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f82:	2905                	addiw	s2,s2,1
    80003f84:	0a91                	addi	s5,s5,4
    80003f86:	02ca2783          	lw	a5,44(s4)
    80003f8a:	faf94ae3          	blt	s2,a5,80003f3e <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f8e:	d11ff0ef          	jal	80003c9e <write_head>
    install_trans(0); // Now install writes to home locations
    80003f92:	4501                	li	a0,0
    80003f94:	d69ff0ef          	jal	80003cfc <install_trans>
    log.lh.n = 0;
    80003f98:	0001c797          	auipc	a5,0x1c
    80003f9c:	ec07a223          	sw	zero,-316(a5) # 8001fe5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003fa0:	cffff0ef          	jal	80003c9e <write_head>
    80003fa4:	69e2                	ld	s3,24(sp)
    80003fa6:	6a42                	ld	s4,16(sp)
    80003fa8:	6aa2                	ld	s5,8(sp)
    80003faa:	b735                	j	80003ed6 <end_op+0x44>

0000000080003fac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fac:	1101                	addi	sp,sp,-32
    80003fae:	ec06                	sd	ra,24(sp)
    80003fb0:	e822                	sd	s0,16(sp)
    80003fb2:	e426                	sd	s1,8(sp)
    80003fb4:	e04a                	sd	s2,0(sp)
    80003fb6:	1000                	addi	s0,sp,32
    80003fb8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fba:	0001c917          	auipc	s2,0x1c
    80003fbe:	e7690913          	addi	s2,s2,-394 # 8001fe30 <log>
    80003fc2:	854a                	mv	a0,s2
    80003fc4:	c31fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003fc8:	02c92603          	lw	a2,44(s2)
    80003fcc:	47f5                	li	a5,29
    80003fce:	06c7c363          	blt	a5,a2,80004034 <log_write+0x88>
    80003fd2:	0001c797          	auipc	a5,0x1c
    80003fd6:	e7a7a783          	lw	a5,-390(a5) # 8001fe4c <log+0x1c>
    80003fda:	37fd                	addiw	a5,a5,-1
    80003fdc:	04f65c63          	bge	a2,a5,80004034 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fe0:	0001c797          	auipc	a5,0x1c
    80003fe4:	e707a783          	lw	a5,-400(a5) # 8001fe50 <log+0x20>
    80003fe8:	04f05c63          	blez	a5,80004040 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fec:	4781                	li	a5,0
    80003fee:	04c05f63          	blez	a2,8000404c <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ff2:	44cc                	lw	a1,12(s1)
    80003ff4:	0001c717          	auipc	a4,0x1c
    80003ff8:	e6c70713          	addi	a4,a4,-404 # 8001fe60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003ffc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ffe:	4314                	lw	a3,0(a4)
    80004000:	04b68663          	beq	a3,a1,8000404c <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80004004:	2785                	addiw	a5,a5,1
    80004006:	0711                	addi	a4,a4,4
    80004008:	fef61be3          	bne	a2,a5,80003ffe <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000400c:	0621                	addi	a2,a2,8
    8000400e:	060a                	slli	a2,a2,0x2
    80004010:	0001c797          	auipc	a5,0x1c
    80004014:	e2078793          	addi	a5,a5,-480 # 8001fe30 <log>
    80004018:	97b2                	add	a5,a5,a2
    8000401a:	44d8                	lw	a4,12(s1)
    8000401c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000401e:	8526                	mv	a0,s1
    80004020:	fcbfe0ef          	jal	80002fea <bpin>
    log.lh.n++;
    80004024:	0001c717          	auipc	a4,0x1c
    80004028:	e0c70713          	addi	a4,a4,-500 # 8001fe30 <log>
    8000402c:	575c                	lw	a5,44(a4)
    8000402e:	2785                	addiw	a5,a5,1
    80004030:	d75c                	sw	a5,44(a4)
    80004032:	a80d                	j	80004064 <log_write+0xb8>
    panic("too big a transaction");
    80004034:	00003517          	auipc	a0,0x3
    80004038:	53c50513          	addi	a0,a0,1340 # 80007570 <etext+0x570>
    8000403c:	f58fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80004040:	00003517          	auipc	a0,0x3
    80004044:	54850513          	addi	a0,a0,1352 # 80007588 <etext+0x588>
    80004048:	f4cfc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    8000404c:	00878693          	addi	a3,a5,8
    80004050:	068a                	slli	a3,a3,0x2
    80004052:	0001c717          	auipc	a4,0x1c
    80004056:	dde70713          	addi	a4,a4,-546 # 8001fe30 <log>
    8000405a:	9736                	add	a4,a4,a3
    8000405c:	44d4                	lw	a3,12(s1)
    8000405e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004060:	faf60fe3          	beq	a2,a5,8000401e <log_write+0x72>
  }
  release(&log.lock);
    80004064:	0001c517          	auipc	a0,0x1c
    80004068:	dcc50513          	addi	a0,a0,-564 # 8001fe30 <log>
    8000406c:	c21fc0ef          	jal	80000c8c <release>
}
    80004070:	60e2                	ld	ra,24(sp)
    80004072:	6442                	ld	s0,16(sp)
    80004074:	64a2                	ld	s1,8(sp)
    80004076:	6902                	ld	s2,0(sp)
    80004078:	6105                	addi	sp,sp,32
    8000407a:	8082                	ret

000000008000407c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000407c:	1101                	addi	sp,sp,-32
    8000407e:	ec06                	sd	ra,24(sp)
    80004080:	e822                	sd	s0,16(sp)
    80004082:	e426                	sd	s1,8(sp)
    80004084:	e04a                	sd	s2,0(sp)
    80004086:	1000                	addi	s0,sp,32
    80004088:	84aa                	mv	s1,a0
    8000408a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000408c:	00003597          	auipc	a1,0x3
    80004090:	51c58593          	addi	a1,a1,1308 # 800075a8 <etext+0x5a8>
    80004094:	0521                	addi	a0,a0,8
    80004096:	adffc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    8000409a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000409e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040a2:	0204a423          	sw	zero,40(s1)
}
    800040a6:	60e2                	ld	ra,24(sp)
    800040a8:	6442                	ld	s0,16(sp)
    800040aa:	64a2                	ld	s1,8(sp)
    800040ac:	6902                	ld	s2,0(sp)
    800040ae:	6105                	addi	sp,sp,32
    800040b0:	8082                	ret

00000000800040b2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800040b2:	1101                	addi	sp,sp,-32
    800040b4:	ec06                	sd	ra,24(sp)
    800040b6:	e822                	sd	s0,16(sp)
    800040b8:	e426                	sd	s1,8(sp)
    800040ba:	e04a                	sd	s2,0(sp)
    800040bc:	1000                	addi	s0,sp,32
    800040be:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040c0:	00850913          	addi	s2,a0,8
    800040c4:	854a                	mv	a0,s2
    800040c6:	b2ffc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    800040ca:	409c                	lw	a5,0(s1)
    800040cc:	c799                	beqz	a5,800040da <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040ce:	85ca                	mv	a1,s2
    800040d0:	8526                	mv	a0,s1
    800040d2:	854fe0ef          	jal	80002126 <sleep>
  while (lk->locked) {
    800040d6:	409c                	lw	a5,0(s1)
    800040d8:	fbfd                	bnez	a5,800040ce <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040da:	4785                	li	a5,1
    800040dc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040de:	803fd0ef          	jal	800018e0 <myproc>
    800040e2:	591c                	lw	a5,48(a0)
    800040e4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040e6:	854a                	mv	a0,s2
    800040e8:	ba5fc0ef          	jal	80000c8c <release>
}
    800040ec:	60e2                	ld	ra,24(sp)
    800040ee:	6442                	ld	s0,16(sp)
    800040f0:	64a2                	ld	s1,8(sp)
    800040f2:	6902                	ld	s2,0(sp)
    800040f4:	6105                	addi	sp,sp,32
    800040f6:	8082                	ret

00000000800040f8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040f8:	1101                	addi	sp,sp,-32
    800040fa:	ec06                	sd	ra,24(sp)
    800040fc:	e822                	sd	s0,16(sp)
    800040fe:	e426                	sd	s1,8(sp)
    80004100:	e04a                	sd	s2,0(sp)
    80004102:	1000                	addi	s0,sp,32
    80004104:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004106:	00850913          	addi	s2,a0,8
    8000410a:	854a                	mv	a0,s2
    8000410c:	ae9fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80004110:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004114:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004118:	8526                	mv	a0,s1
    8000411a:	858fe0ef          	jal	80002172 <wakeup>
  release(&lk->lk);
    8000411e:	854a                	mv	a0,s2
    80004120:	b6dfc0ef          	jal	80000c8c <release>
}
    80004124:	60e2                	ld	ra,24(sp)
    80004126:	6442                	ld	s0,16(sp)
    80004128:	64a2                	ld	s1,8(sp)
    8000412a:	6902                	ld	s2,0(sp)
    8000412c:	6105                	addi	sp,sp,32
    8000412e:	8082                	ret

0000000080004130 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004130:	7179                	addi	sp,sp,-48
    80004132:	f406                	sd	ra,40(sp)
    80004134:	f022                	sd	s0,32(sp)
    80004136:	ec26                	sd	s1,24(sp)
    80004138:	e84a                	sd	s2,16(sp)
    8000413a:	1800                	addi	s0,sp,48
    8000413c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000413e:	00850913          	addi	s2,a0,8
    80004142:	854a                	mv	a0,s2
    80004144:	ab1fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004148:	409c                	lw	a5,0(s1)
    8000414a:	ef81                	bnez	a5,80004162 <holdingsleep+0x32>
    8000414c:	4481                	li	s1,0
  release(&lk->lk);
    8000414e:	854a                	mv	a0,s2
    80004150:	b3dfc0ef          	jal	80000c8c <release>
  return r;
}
    80004154:	8526                	mv	a0,s1
    80004156:	70a2                	ld	ra,40(sp)
    80004158:	7402                	ld	s0,32(sp)
    8000415a:	64e2                	ld	s1,24(sp)
    8000415c:	6942                	ld	s2,16(sp)
    8000415e:	6145                	addi	sp,sp,48
    80004160:	8082                	ret
    80004162:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004164:	0284a983          	lw	s3,40(s1)
    80004168:	f78fd0ef          	jal	800018e0 <myproc>
    8000416c:	5904                	lw	s1,48(a0)
    8000416e:	413484b3          	sub	s1,s1,s3
    80004172:	0014b493          	seqz	s1,s1
    80004176:	69a2                	ld	s3,8(sp)
    80004178:	bfd9                	j	8000414e <holdingsleep+0x1e>

000000008000417a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000417a:	1141                	addi	sp,sp,-16
    8000417c:	e406                	sd	ra,8(sp)
    8000417e:	e022                	sd	s0,0(sp)
    80004180:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004182:	00003597          	auipc	a1,0x3
    80004186:	43658593          	addi	a1,a1,1078 # 800075b8 <etext+0x5b8>
    8000418a:	0001c517          	auipc	a0,0x1c
    8000418e:	dee50513          	addi	a0,a0,-530 # 8001ff78 <ftable>
    80004192:	9e3fc0ef          	jal	80000b74 <initlock>
}
    80004196:	60a2                	ld	ra,8(sp)
    80004198:	6402                	ld	s0,0(sp)
    8000419a:	0141                	addi	sp,sp,16
    8000419c:	8082                	ret

000000008000419e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000419e:	1101                	addi	sp,sp,-32
    800041a0:	ec06                	sd	ra,24(sp)
    800041a2:	e822                	sd	s0,16(sp)
    800041a4:	e426                	sd	s1,8(sp)
    800041a6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800041a8:	0001c517          	auipc	a0,0x1c
    800041ac:	dd050513          	addi	a0,a0,-560 # 8001ff78 <ftable>
    800041b0:	a45fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041b4:	0001c497          	auipc	s1,0x1c
    800041b8:	ddc48493          	addi	s1,s1,-548 # 8001ff90 <ftable+0x18>
    800041bc:	0001d717          	auipc	a4,0x1d
    800041c0:	d7470713          	addi	a4,a4,-652 # 80020f30 <disk>
    if(f->ref == 0){
    800041c4:	40dc                	lw	a5,4(s1)
    800041c6:	cf89                	beqz	a5,800041e0 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041c8:	02848493          	addi	s1,s1,40
    800041cc:	fee49ce3          	bne	s1,a4,800041c4 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041d0:	0001c517          	auipc	a0,0x1c
    800041d4:	da850513          	addi	a0,a0,-600 # 8001ff78 <ftable>
    800041d8:	ab5fc0ef          	jal	80000c8c <release>
  return 0;
    800041dc:	4481                	li	s1,0
    800041de:	a809                	j	800041f0 <filealloc+0x52>
      f->ref = 1;
    800041e0:	4785                	li	a5,1
    800041e2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041e4:	0001c517          	auipc	a0,0x1c
    800041e8:	d9450513          	addi	a0,a0,-620 # 8001ff78 <ftable>
    800041ec:	aa1fc0ef          	jal	80000c8c <release>
}
    800041f0:	8526                	mv	a0,s1
    800041f2:	60e2                	ld	ra,24(sp)
    800041f4:	6442                	ld	s0,16(sp)
    800041f6:	64a2                	ld	s1,8(sp)
    800041f8:	6105                	addi	sp,sp,32
    800041fa:	8082                	ret

00000000800041fc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800041fc:	1101                	addi	sp,sp,-32
    800041fe:	ec06                	sd	ra,24(sp)
    80004200:	e822                	sd	s0,16(sp)
    80004202:	e426                	sd	s1,8(sp)
    80004204:	1000                	addi	s0,sp,32
    80004206:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004208:	0001c517          	auipc	a0,0x1c
    8000420c:	d7050513          	addi	a0,a0,-656 # 8001ff78 <ftable>
    80004210:	9e5fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004214:	40dc                	lw	a5,4(s1)
    80004216:	02f05063          	blez	a5,80004236 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000421a:	2785                	addiw	a5,a5,1
    8000421c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000421e:	0001c517          	auipc	a0,0x1c
    80004222:	d5a50513          	addi	a0,a0,-678 # 8001ff78 <ftable>
    80004226:	a67fc0ef          	jal	80000c8c <release>
  return f;
}
    8000422a:	8526                	mv	a0,s1
    8000422c:	60e2                	ld	ra,24(sp)
    8000422e:	6442                	ld	s0,16(sp)
    80004230:	64a2                	ld	s1,8(sp)
    80004232:	6105                	addi	sp,sp,32
    80004234:	8082                	ret
    panic("filedup");
    80004236:	00003517          	auipc	a0,0x3
    8000423a:	38a50513          	addi	a0,a0,906 # 800075c0 <etext+0x5c0>
    8000423e:	d56fc0ef          	jal	80000794 <panic>

0000000080004242 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004242:	7139                	addi	sp,sp,-64
    80004244:	fc06                	sd	ra,56(sp)
    80004246:	f822                	sd	s0,48(sp)
    80004248:	f426                	sd	s1,40(sp)
    8000424a:	0080                	addi	s0,sp,64
    8000424c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000424e:	0001c517          	auipc	a0,0x1c
    80004252:	d2a50513          	addi	a0,a0,-726 # 8001ff78 <ftable>
    80004256:	99ffc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    8000425a:	40dc                	lw	a5,4(s1)
    8000425c:	04f05a63          	blez	a5,800042b0 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004260:	37fd                	addiw	a5,a5,-1
    80004262:	0007871b          	sext.w	a4,a5
    80004266:	c0dc                	sw	a5,4(s1)
    80004268:	04e04e63          	bgtz	a4,800042c4 <fileclose+0x82>
    8000426c:	f04a                	sd	s2,32(sp)
    8000426e:	ec4e                	sd	s3,24(sp)
    80004270:	e852                	sd	s4,16(sp)
    80004272:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004274:	0004a903          	lw	s2,0(s1)
    80004278:	0094ca83          	lbu	s5,9(s1)
    8000427c:	0104ba03          	ld	s4,16(s1)
    80004280:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004284:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004288:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000428c:	0001c517          	auipc	a0,0x1c
    80004290:	cec50513          	addi	a0,a0,-788 # 8001ff78 <ftable>
    80004294:	9f9fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80004298:	4785                	li	a5,1
    8000429a:	04f90063          	beq	s2,a5,800042da <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000429e:	3979                	addiw	s2,s2,-2
    800042a0:	4785                	li	a5,1
    800042a2:	0527f563          	bgeu	a5,s2,800042ec <fileclose+0xaa>
    800042a6:	7902                	ld	s2,32(sp)
    800042a8:	69e2                	ld	s3,24(sp)
    800042aa:	6a42                	ld	s4,16(sp)
    800042ac:	6aa2                	ld	s5,8(sp)
    800042ae:	a00d                	j	800042d0 <fileclose+0x8e>
    800042b0:	f04a                	sd	s2,32(sp)
    800042b2:	ec4e                	sd	s3,24(sp)
    800042b4:	e852                	sd	s4,16(sp)
    800042b6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800042b8:	00003517          	auipc	a0,0x3
    800042bc:	31050513          	addi	a0,a0,784 # 800075c8 <etext+0x5c8>
    800042c0:	cd4fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    800042c4:	0001c517          	auipc	a0,0x1c
    800042c8:	cb450513          	addi	a0,a0,-844 # 8001ff78 <ftable>
    800042cc:	9c1fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042d0:	70e2                	ld	ra,56(sp)
    800042d2:	7442                	ld	s0,48(sp)
    800042d4:	74a2                	ld	s1,40(sp)
    800042d6:	6121                	addi	sp,sp,64
    800042d8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042da:	85d6                	mv	a1,s5
    800042dc:	8552                	mv	a0,s4
    800042de:	336000ef          	jal	80004614 <pipeclose>
    800042e2:	7902                	ld	s2,32(sp)
    800042e4:	69e2                	ld	s3,24(sp)
    800042e6:	6a42                	ld	s4,16(sp)
    800042e8:	6aa2                	ld	s5,8(sp)
    800042ea:	b7dd                	j	800042d0 <fileclose+0x8e>
    begin_op();
    800042ec:	b3dff0ef          	jal	80003e28 <begin_op>
    iput(ff.ip);
    800042f0:	854e                	mv	a0,s3
    800042f2:	c22ff0ef          	jal	80003714 <iput>
    end_op();
    800042f6:	b9dff0ef          	jal	80003e92 <end_op>
    800042fa:	7902                	ld	s2,32(sp)
    800042fc:	69e2                	ld	s3,24(sp)
    800042fe:	6a42                	ld	s4,16(sp)
    80004300:	6aa2                	ld	s5,8(sp)
    80004302:	b7f9                	j	800042d0 <fileclose+0x8e>

0000000080004304 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004304:	715d                	addi	sp,sp,-80
    80004306:	e486                	sd	ra,72(sp)
    80004308:	e0a2                	sd	s0,64(sp)
    8000430a:	fc26                	sd	s1,56(sp)
    8000430c:	f44e                	sd	s3,40(sp)
    8000430e:	0880                	addi	s0,sp,80
    80004310:	84aa                	mv	s1,a0
    80004312:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004314:	dccfd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004318:	409c                	lw	a5,0(s1)
    8000431a:	37f9                	addiw	a5,a5,-2
    8000431c:	4705                	li	a4,1
    8000431e:	04f76063          	bltu	a4,a5,8000435e <filestat+0x5a>
    80004322:	f84a                	sd	s2,48(sp)
    80004324:	892a                	mv	s2,a0
    ilock(f->ip);
    80004326:	6c88                	ld	a0,24(s1)
    80004328:	a6aff0ef          	jal	80003592 <ilock>
    stati(f->ip, &st);
    8000432c:	fb840593          	addi	a1,s0,-72
    80004330:	6c88                	ld	a0,24(s1)
    80004332:	c8aff0ef          	jal	800037bc <stati>
    iunlock(f->ip);
    80004336:	6c88                	ld	a0,24(s1)
    80004338:	b08ff0ef          	jal	80003640 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000433c:	46e1                	li	a3,24
    8000433e:	fb840613          	addi	a2,s0,-72
    80004342:	85ce                	mv	a1,s3
    80004344:	05093503          	ld	a0,80(s2)
    80004348:	a0afd0ef          	jal	80001552 <copyout>
    8000434c:	41f5551b          	sraiw	a0,a0,0x1f
    80004350:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004352:	60a6                	ld	ra,72(sp)
    80004354:	6406                	ld	s0,64(sp)
    80004356:	74e2                	ld	s1,56(sp)
    80004358:	79a2                	ld	s3,40(sp)
    8000435a:	6161                	addi	sp,sp,80
    8000435c:	8082                	ret
  return -1;
    8000435e:	557d                	li	a0,-1
    80004360:	bfcd                	j	80004352 <filestat+0x4e>

0000000080004362 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004362:	7179                	addi	sp,sp,-48
    80004364:	f406                	sd	ra,40(sp)
    80004366:	f022                	sd	s0,32(sp)
    80004368:	e84a                	sd	s2,16(sp)
    8000436a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000436c:	00854783          	lbu	a5,8(a0)
    80004370:	cfd1                	beqz	a5,8000440c <fileread+0xaa>
    80004372:	ec26                	sd	s1,24(sp)
    80004374:	e44e                	sd	s3,8(sp)
    80004376:	84aa                	mv	s1,a0
    80004378:	89ae                	mv	s3,a1
    8000437a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000437c:	411c                	lw	a5,0(a0)
    8000437e:	4705                	li	a4,1
    80004380:	04e78363          	beq	a5,a4,800043c6 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004384:	470d                	li	a4,3
    80004386:	04e78763          	beq	a5,a4,800043d4 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000438a:	4709                	li	a4,2
    8000438c:	06e79a63          	bne	a5,a4,80004400 <fileread+0x9e>
    ilock(f->ip);
    80004390:	6d08                	ld	a0,24(a0)
    80004392:	a00ff0ef          	jal	80003592 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004396:	874a                	mv	a4,s2
    80004398:	5094                	lw	a3,32(s1)
    8000439a:	864e                	mv	a2,s3
    8000439c:	4585                	li	a1,1
    8000439e:	6c88                	ld	a0,24(s1)
    800043a0:	c46ff0ef          	jal	800037e6 <readi>
    800043a4:	892a                	mv	s2,a0
    800043a6:	00a05563          	blez	a0,800043b0 <fileread+0x4e>
      f->off += r;
    800043aa:	509c                	lw	a5,32(s1)
    800043ac:	9fa9                	addw	a5,a5,a0
    800043ae:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800043b0:	6c88                	ld	a0,24(s1)
    800043b2:	a8eff0ef          	jal	80003640 <iunlock>
    800043b6:	64e2                	ld	s1,24(sp)
    800043b8:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800043ba:	854a                	mv	a0,s2
    800043bc:	70a2                	ld	ra,40(sp)
    800043be:	7402                	ld	s0,32(sp)
    800043c0:	6942                	ld	s2,16(sp)
    800043c2:	6145                	addi	sp,sp,48
    800043c4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043c6:	6908                	ld	a0,16(a0)
    800043c8:	388000ef          	jal	80004750 <piperead>
    800043cc:	892a                	mv	s2,a0
    800043ce:	64e2                	ld	s1,24(sp)
    800043d0:	69a2                	ld	s3,8(sp)
    800043d2:	b7e5                	j	800043ba <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043d4:	02451783          	lh	a5,36(a0)
    800043d8:	03079693          	slli	a3,a5,0x30
    800043dc:	92c1                	srli	a3,a3,0x30
    800043de:	4725                	li	a4,9
    800043e0:	02d76863          	bltu	a4,a3,80004410 <fileread+0xae>
    800043e4:	0792                	slli	a5,a5,0x4
    800043e6:	0001c717          	auipc	a4,0x1c
    800043ea:	af270713          	addi	a4,a4,-1294 # 8001fed8 <devsw>
    800043ee:	97ba                	add	a5,a5,a4
    800043f0:	639c                	ld	a5,0(a5)
    800043f2:	c39d                	beqz	a5,80004418 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800043f4:	4505                	li	a0,1
    800043f6:	9782                	jalr	a5
    800043f8:	892a                	mv	s2,a0
    800043fa:	64e2                	ld	s1,24(sp)
    800043fc:	69a2                	ld	s3,8(sp)
    800043fe:	bf75                	j	800043ba <fileread+0x58>
    panic("fileread");
    80004400:	00003517          	auipc	a0,0x3
    80004404:	1d850513          	addi	a0,a0,472 # 800075d8 <etext+0x5d8>
    80004408:	b8cfc0ef          	jal	80000794 <panic>
    return -1;
    8000440c:	597d                	li	s2,-1
    8000440e:	b775                	j	800043ba <fileread+0x58>
      return -1;
    80004410:	597d                	li	s2,-1
    80004412:	64e2                	ld	s1,24(sp)
    80004414:	69a2                	ld	s3,8(sp)
    80004416:	b755                	j	800043ba <fileread+0x58>
    80004418:	597d                	li	s2,-1
    8000441a:	64e2                	ld	s1,24(sp)
    8000441c:	69a2                	ld	s3,8(sp)
    8000441e:	bf71                	j	800043ba <fileread+0x58>

0000000080004420 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004420:	00954783          	lbu	a5,9(a0)
    80004424:	10078b63          	beqz	a5,8000453a <filewrite+0x11a>
{
    80004428:	715d                	addi	sp,sp,-80
    8000442a:	e486                	sd	ra,72(sp)
    8000442c:	e0a2                	sd	s0,64(sp)
    8000442e:	f84a                	sd	s2,48(sp)
    80004430:	f052                	sd	s4,32(sp)
    80004432:	e85a                	sd	s6,16(sp)
    80004434:	0880                	addi	s0,sp,80
    80004436:	892a                	mv	s2,a0
    80004438:	8b2e                	mv	s6,a1
    8000443a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000443c:	411c                	lw	a5,0(a0)
    8000443e:	4705                	li	a4,1
    80004440:	02e78763          	beq	a5,a4,8000446e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004444:	470d                	li	a4,3
    80004446:	02e78863          	beq	a5,a4,80004476 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000444a:	4709                	li	a4,2
    8000444c:	0ce79c63          	bne	a5,a4,80004524 <filewrite+0x104>
    80004450:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004452:	0ac05863          	blez	a2,80004502 <filewrite+0xe2>
    80004456:	fc26                	sd	s1,56(sp)
    80004458:	ec56                	sd	s5,24(sp)
    8000445a:	e45e                	sd	s7,8(sp)
    8000445c:	e062                	sd	s8,0(sp)
    int i = 0;
    8000445e:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004460:	6b85                	lui	s7,0x1
    80004462:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004466:	6c05                	lui	s8,0x1
    80004468:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000446c:	a8b5                	j	800044e8 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000446e:	6908                	ld	a0,16(a0)
    80004470:	1fc000ef          	jal	8000466c <pipewrite>
    80004474:	a04d                	j	80004516 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004476:	02451783          	lh	a5,36(a0)
    8000447a:	03079693          	slli	a3,a5,0x30
    8000447e:	92c1                	srli	a3,a3,0x30
    80004480:	4725                	li	a4,9
    80004482:	0ad76e63          	bltu	a4,a3,8000453e <filewrite+0x11e>
    80004486:	0792                	slli	a5,a5,0x4
    80004488:	0001c717          	auipc	a4,0x1c
    8000448c:	a5070713          	addi	a4,a4,-1456 # 8001fed8 <devsw>
    80004490:	97ba                	add	a5,a5,a4
    80004492:	679c                	ld	a5,8(a5)
    80004494:	c7dd                	beqz	a5,80004542 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004496:	4505                	li	a0,1
    80004498:	9782                	jalr	a5
    8000449a:	a8b5                	j	80004516 <filewrite+0xf6>
      if(n1 > max)
    8000449c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800044a0:	989ff0ef          	jal	80003e28 <begin_op>
      ilock(f->ip);
    800044a4:	01893503          	ld	a0,24(s2)
    800044a8:	8eaff0ef          	jal	80003592 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044ac:	8756                	mv	a4,s5
    800044ae:	02092683          	lw	a3,32(s2)
    800044b2:	01698633          	add	a2,s3,s6
    800044b6:	4585                	li	a1,1
    800044b8:	01893503          	ld	a0,24(s2)
    800044bc:	c26ff0ef          	jal	800038e2 <writei>
    800044c0:	84aa                	mv	s1,a0
    800044c2:	00a05763          	blez	a0,800044d0 <filewrite+0xb0>
        f->off += r;
    800044c6:	02092783          	lw	a5,32(s2)
    800044ca:	9fa9                	addw	a5,a5,a0
    800044cc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044d0:	01893503          	ld	a0,24(s2)
    800044d4:	96cff0ef          	jal	80003640 <iunlock>
      end_op();
    800044d8:	9bbff0ef          	jal	80003e92 <end_op>

      if(r != n1){
    800044dc:	029a9563          	bne	s5,s1,80004506 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800044e0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800044e4:	0149da63          	bge	s3,s4,800044f8 <filewrite+0xd8>
      int n1 = n - i;
    800044e8:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800044ec:	0004879b          	sext.w	a5,s1
    800044f0:	fafbd6e3          	bge	s7,a5,8000449c <filewrite+0x7c>
    800044f4:	84e2                	mv	s1,s8
    800044f6:	b75d                	j	8000449c <filewrite+0x7c>
    800044f8:	74e2                	ld	s1,56(sp)
    800044fa:	6ae2                	ld	s5,24(sp)
    800044fc:	6ba2                	ld	s7,8(sp)
    800044fe:	6c02                	ld	s8,0(sp)
    80004500:	a039                	j	8000450e <filewrite+0xee>
    int i = 0;
    80004502:	4981                	li	s3,0
    80004504:	a029                	j	8000450e <filewrite+0xee>
    80004506:	74e2                	ld	s1,56(sp)
    80004508:	6ae2                	ld	s5,24(sp)
    8000450a:	6ba2                	ld	s7,8(sp)
    8000450c:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000450e:	033a1c63          	bne	s4,s3,80004546 <filewrite+0x126>
    80004512:	8552                	mv	a0,s4
    80004514:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004516:	60a6                	ld	ra,72(sp)
    80004518:	6406                	ld	s0,64(sp)
    8000451a:	7942                	ld	s2,48(sp)
    8000451c:	7a02                	ld	s4,32(sp)
    8000451e:	6b42                	ld	s6,16(sp)
    80004520:	6161                	addi	sp,sp,80
    80004522:	8082                	ret
    80004524:	fc26                	sd	s1,56(sp)
    80004526:	f44e                	sd	s3,40(sp)
    80004528:	ec56                	sd	s5,24(sp)
    8000452a:	e45e                	sd	s7,8(sp)
    8000452c:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000452e:	00003517          	auipc	a0,0x3
    80004532:	0ba50513          	addi	a0,a0,186 # 800075e8 <etext+0x5e8>
    80004536:	a5efc0ef          	jal	80000794 <panic>
    return -1;
    8000453a:	557d                	li	a0,-1
}
    8000453c:	8082                	ret
      return -1;
    8000453e:	557d                	li	a0,-1
    80004540:	bfd9                	j	80004516 <filewrite+0xf6>
    80004542:	557d                	li	a0,-1
    80004544:	bfc9                	j	80004516 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004546:	557d                	li	a0,-1
    80004548:	79a2                	ld	s3,40(sp)
    8000454a:	b7f1                	j	80004516 <filewrite+0xf6>

000000008000454c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000454c:	7179                	addi	sp,sp,-48
    8000454e:	f406                	sd	ra,40(sp)
    80004550:	f022                	sd	s0,32(sp)
    80004552:	ec26                	sd	s1,24(sp)
    80004554:	e052                	sd	s4,0(sp)
    80004556:	1800                	addi	s0,sp,48
    80004558:	84aa                	mv	s1,a0
    8000455a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000455c:	0005b023          	sd	zero,0(a1)
    80004560:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004564:	c3bff0ef          	jal	8000419e <filealloc>
    80004568:	e088                	sd	a0,0(s1)
    8000456a:	c549                	beqz	a0,800045f4 <pipealloc+0xa8>
    8000456c:	c33ff0ef          	jal	8000419e <filealloc>
    80004570:	00aa3023          	sd	a0,0(s4)
    80004574:	cd25                	beqz	a0,800045ec <pipealloc+0xa0>
    80004576:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004578:	dacfc0ef          	jal	80000b24 <kalloc>
    8000457c:	892a                	mv	s2,a0
    8000457e:	c12d                	beqz	a0,800045e0 <pipealloc+0x94>
    80004580:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004582:	4985                	li	s3,1
    80004584:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004588:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000458c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004590:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004594:	00003597          	auipc	a1,0x3
    80004598:	06458593          	addi	a1,a1,100 # 800075f8 <etext+0x5f8>
    8000459c:	dd8fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800045a0:	609c                	ld	a5,0(s1)
    800045a2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800045a6:	609c                	ld	a5,0(s1)
    800045a8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800045ac:	609c                	ld	a5,0(s1)
    800045ae:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800045b2:	609c                	ld	a5,0(s1)
    800045b4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800045b8:	000a3783          	ld	a5,0(s4)
    800045bc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800045c0:	000a3783          	ld	a5,0(s4)
    800045c4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800045c8:	000a3783          	ld	a5,0(s4)
    800045cc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800045d0:	000a3783          	ld	a5,0(s4)
    800045d4:	0127b823          	sd	s2,16(a5)
  return 0;
    800045d8:	4501                	li	a0,0
    800045da:	6942                	ld	s2,16(sp)
    800045dc:	69a2                	ld	s3,8(sp)
    800045de:	a01d                	j	80004604 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800045e0:	6088                	ld	a0,0(s1)
    800045e2:	c119                	beqz	a0,800045e8 <pipealloc+0x9c>
    800045e4:	6942                	ld	s2,16(sp)
    800045e6:	a029                	j	800045f0 <pipealloc+0xa4>
    800045e8:	6942                	ld	s2,16(sp)
    800045ea:	a029                	j	800045f4 <pipealloc+0xa8>
    800045ec:	6088                	ld	a0,0(s1)
    800045ee:	c10d                	beqz	a0,80004610 <pipealloc+0xc4>
    fileclose(*f0);
    800045f0:	c53ff0ef          	jal	80004242 <fileclose>
  if(*f1)
    800045f4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800045f8:	557d                	li	a0,-1
  if(*f1)
    800045fa:	c789                	beqz	a5,80004604 <pipealloc+0xb8>
    fileclose(*f1);
    800045fc:	853e                	mv	a0,a5
    800045fe:	c45ff0ef          	jal	80004242 <fileclose>
  return -1;
    80004602:	557d                	li	a0,-1
}
    80004604:	70a2                	ld	ra,40(sp)
    80004606:	7402                	ld	s0,32(sp)
    80004608:	64e2                	ld	s1,24(sp)
    8000460a:	6a02                	ld	s4,0(sp)
    8000460c:	6145                	addi	sp,sp,48
    8000460e:	8082                	ret
  return -1;
    80004610:	557d                	li	a0,-1
    80004612:	bfcd                	j	80004604 <pipealloc+0xb8>

0000000080004614 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004614:	1101                	addi	sp,sp,-32
    80004616:	ec06                	sd	ra,24(sp)
    80004618:	e822                	sd	s0,16(sp)
    8000461a:	e426                	sd	s1,8(sp)
    8000461c:	e04a                	sd	s2,0(sp)
    8000461e:	1000                	addi	s0,sp,32
    80004620:	84aa                	mv	s1,a0
    80004622:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004624:	dd0fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004628:	02090763          	beqz	s2,80004656 <pipeclose+0x42>
    pi->writeopen = 0;
    8000462c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004630:	21848513          	addi	a0,s1,536
    80004634:	b3ffd0ef          	jal	80002172 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004638:	2204b783          	ld	a5,544(s1)
    8000463c:	e785                	bnez	a5,80004664 <pipeclose+0x50>
    release(&pi->lock);
    8000463e:	8526                	mv	a0,s1
    80004640:	e4cfc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004644:	8526                	mv	a0,s1
    80004646:	bfcfc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    8000464a:	60e2                	ld	ra,24(sp)
    8000464c:	6442                	ld	s0,16(sp)
    8000464e:	64a2                	ld	s1,8(sp)
    80004650:	6902                	ld	s2,0(sp)
    80004652:	6105                	addi	sp,sp,32
    80004654:	8082                	ret
    pi->readopen = 0;
    80004656:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000465a:	21c48513          	addi	a0,s1,540
    8000465e:	b15fd0ef          	jal	80002172 <wakeup>
    80004662:	bfd9                	j	80004638 <pipeclose+0x24>
    release(&pi->lock);
    80004664:	8526                	mv	a0,s1
    80004666:	e26fc0ef          	jal	80000c8c <release>
}
    8000466a:	b7c5                	j	8000464a <pipeclose+0x36>

000000008000466c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000466c:	711d                	addi	sp,sp,-96
    8000466e:	ec86                	sd	ra,88(sp)
    80004670:	e8a2                	sd	s0,80(sp)
    80004672:	e4a6                	sd	s1,72(sp)
    80004674:	e0ca                	sd	s2,64(sp)
    80004676:	fc4e                	sd	s3,56(sp)
    80004678:	f852                	sd	s4,48(sp)
    8000467a:	f456                	sd	s5,40(sp)
    8000467c:	1080                	addi	s0,sp,96
    8000467e:	84aa                	mv	s1,a0
    80004680:	8aae                	mv	s5,a1
    80004682:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004684:	a5cfd0ef          	jal	800018e0 <myproc>
    80004688:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000468a:	8526                	mv	a0,s1
    8000468c:	d68fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004690:	0b405a63          	blez	s4,80004744 <pipewrite+0xd8>
    80004694:	f05a                	sd	s6,32(sp)
    80004696:	ec5e                	sd	s7,24(sp)
    80004698:	e862                	sd	s8,16(sp)
  int i = 0;
    8000469a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000469c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000469e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800046a2:	21c48b93          	addi	s7,s1,540
    800046a6:	a81d                	j	800046dc <pipewrite+0x70>
      release(&pi->lock);
    800046a8:	8526                	mv	a0,s1
    800046aa:	de2fc0ef          	jal	80000c8c <release>
      return -1;
    800046ae:	597d                	li	s2,-1
    800046b0:	7b02                	ld	s6,32(sp)
    800046b2:	6be2                	ld	s7,24(sp)
    800046b4:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800046b6:	854a                	mv	a0,s2
    800046b8:	60e6                	ld	ra,88(sp)
    800046ba:	6446                	ld	s0,80(sp)
    800046bc:	64a6                	ld	s1,72(sp)
    800046be:	6906                	ld	s2,64(sp)
    800046c0:	79e2                	ld	s3,56(sp)
    800046c2:	7a42                	ld	s4,48(sp)
    800046c4:	7aa2                	ld	s5,40(sp)
    800046c6:	6125                	addi	sp,sp,96
    800046c8:	8082                	ret
      wakeup(&pi->nread);
    800046ca:	8562                	mv	a0,s8
    800046cc:	aa7fd0ef          	jal	80002172 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800046d0:	85a6                	mv	a1,s1
    800046d2:	855e                	mv	a0,s7
    800046d4:	a53fd0ef          	jal	80002126 <sleep>
  while(i < n){
    800046d8:	05495b63          	bge	s2,s4,8000472e <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800046dc:	2204a783          	lw	a5,544(s1)
    800046e0:	d7e1                	beqz	a5,800046a8 <pipewrite+0x3c>
    800046e2:	854e                	mv	a0,s3
    800046e4:	c7bfd0ef          	jal	8000235e <killed>
    800046e8:	f161                	bnez	a0,800046a8 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800046ea:	2184a783          	lw	a5,536(s1)
    800046ee:	21c4a703          	lw	a4,540(s1)
    800046f2:	2007879b          	addiw	a5,a5,512
    800046f6:	fcf70ae3          	beq	a4,a5,800046ca <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046fa:	4685                	li	a3,1
    800046fc:	01590633          	add	a2,s2,s5
    80004700:	faf40593          	addi	a1,s0,-81
    80004704:	0509b503          	ld	a0,80(s3)
    80004708:	f21fc0ef          	jal	80001628 <copyin>
    8000470c:	03650e63          	beq	a0,s6,80004748 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004710:	21c4a783          	lw	a5,540(s1)
    80004714:	0017871b          	addiw	a4,a5,1
    80004718:	20e4ae23          	sw	a4,540(s1)
    8000471c:	1ff7f793          	andi	a5,a5,511
    80004720:	97a6                	add	a5,a5,s1
    80004722:	faf44703          	lbu	a4,-81(s0)
    80004726:	00e78c23          	sb	a4,24(a5)
      i++;
    8000472a:	2905                	addiw	s2,s2,1
    8000472c:	b775                	j	800046d8 <pipewrite+0x6c>
    8000472e:	7b02                	ld	s6,32(sp)
    80004730:	6be2                	ld	s7,24(sp)
    80004732:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004734:	21848513          	addi	a0,s1,536
    80004738:	a3bfd0ef          	jal	80002172 <wakeup>
  release(&pi->lock);
    8000473c:	8526                	mv	a0,s1
    8000473e:	d4efc0ef          	jal	80000c8c <release>
  return i;
    80004742:	bf95                	j	800046b6 <pipewrite+0x4a>
  int i = 0;
    80004744:	4901                	li	s2,0
    80004746:	b7fd                	j	80004734 <pipewrite+0xc8>
    80004748:	7b02                	ld	s6,32(sp)
    8000474a:	6be2                	ld	s7,24(sp)
    8000474c:	6c42                	ld	s8,16(sp)
    8000474e:	b7dd                	j	80004734 <pipewrite+0xc8>

0000000080004750 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004750:	715d                	addi	sp,sp,-80
    80004752:	e486                	sd	ra,72(sp)
    80004754:	e0a2                	sd	s0,64(sp)
    80004756:	fc26                	sd	s1,56(sp)
    80004758:	f84a                	sd	s2,48(sp)
    8000475a:	f44e                	sd	s3,40(sp)
    8000475c:	f052                	sd	s4,32(sp)
    8000475e:	ec56                	sd	s5,24(sp)
    80004760:	0880                	addi	s0,sp,80
    80004762:	84aa                	mv	s1,a0
    80004764:	892e                	mv	s2,a1
    80004766:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004768:	978fd0ef          	jal	800018e0 <myproc>
    8000476c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000476e:	8526                	mv	a0,s1
    80004770:	c84fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004774:	2184a703          	lw	a4,536(s1)
    80004778:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000477c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004780:	02f71563          	bne	a4,a5,800047aa <piperead+0x5a>
    80004784:	2244a783          	lw	a5,548(s1)
    80004788:	cb85                	beqz	a5,800047b8 <piperead+0x68>
    if(killed(pr)){
    8000478a:	8552                	mv	a0,s4
    8000478c:	bd3fd0ef          	jal	8000235e <killed>
    80004790:	ed19                	bnez	a0,800047ae <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004792:	85a6                	mv	a1,s1
    80004794:	854e                	mv	a0,s3
    80004796:	991fd0ef          	jal	80002126 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000479a:	2184a703          	lw	a4,536(s1)
    8000479e:	21c4a783          	lw	a5,540(s1)
    800047a2:	fef701e3          	beq	a4,a5,80004784 <piperead+0x34>
    800047a6:	e85a                	sd	s6,16(sp)
    800047a8:	a809                	j	800047ba <piperead+0x6a>
    800047aa:	e85a                	sd	s6,16(sp)
    800047ac:	a039                	j	800047ba <piperead+0x6a>
      release(&pi->lock);
    800047ae:	8526                	mv	a0,s1
    800047b0:	cdcfc0ef          	jal	80000c8c <release>
      return -1;
    800047b4:	59fd                	li	s3,-1
    800047b6:	a8b1                	j	80004812 <piperead+0xc2>
    800047b8:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047ba:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800047bc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047be:	05505263          	blez	s5,80004802 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800047c2:	2184a783          	lw	a5,536(s1)
    800047c6:	21c4a703          	lw	a4,540(s1)
    800047ca:	02f70c63          	beq	a4,a5,80004802 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800047ce:	0017871b          	addiw	a4,a5,1
    800047d2:	20e4ac23          	sw	a4,536(s1)
    800047d6:	1ff7f793          	andi	a5,a5,511
    800047da:	97a6                	add	a5,a5,s1
    800047dc:	0187c783          	lbu	a5,24(a5)
    800047e0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800047e4:	4685                	li	a3,1
    800047e6:	fbf40613          	addi	a2,s0,-65
    800047ea:	85ca                	mv	a1,s2
    800047ec:	050a3503          	ld	a0,80(s4)
    800047f0:	d63fc0ef          	jal	80001552 <copyout>
    800047f4:	01650763          	beq	a0,s6,80004802 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800047f8:	2985                	addiw	s3,s3,1
    800047fa:	0905                	addi	s2,s2,1
    800047fc:	fd3a93e3          	bne	s5,s3,800047c2 <piperead+0x72>
    80004800:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004802:	21c48513          	addi	a0,s1,540
    80004806:	96dfd0ef          	jal	80002172 <wakeup>
  release(&pi->lock);
    8000480a:	8526                	mv	a0,s1
    8000480c:	c80fc0ef          	jal	80000c8c <release>
    80004810:	6b42                	ld	s6,16(sp)
  return i;
}
    80004812:	854e                	mv	a0,s3
    80004814:	60a6                	ld	ra,72(sp)
    80004816:	6406                	ld	s0,64(sp)
    80004818:	74e2                	ld	s1,56(sp)
    8000481a:	7942                	ld	s2,48(sp)
    8000481c:	79a2                	ld	s3,40(sp)
    8000481e:	7a02                	ld	s4,32(sp)
    80004820:	6ae2                	ld	s5,24(sp)
    80004822:	6161                	addi	sp,sp,80
    80004824:	8082                	ret

0000000080004826 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004826:	1141                	addi	sp,sp,-16
    80004828:	e422                	sd	s0,8(sp)
    8000482a:	0800                	addi	s0,sp,16
    8000482c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000482e:	8905                	andi	a0,a0,1
    80004830:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004832:	8b89                	andi	a5,a5,2
    80004834:	c399                	beqz	a5,8000483a <flags2perm+0x14>
      perm |= PTE_W;
    80004836:	00456513          	ori	a0,a0,4
    return perm;
}
    8000483a:	6422                	ld	s0,8(sp)
    8000483c:	0141                	addi	sp,sp,16
    8000483e:	8082                	ret

0000000080004840 <exec>:

int
exec(char *path, char **argv)
{
    80004840:	df010113          	addi	sp,sp,-528
    80004844:	20113423          	sd	ra,520(sp)
    80004848:	20813023          	sd	s0,512(sp)
    8000484c:	ffa6                	sd	s1,504(sp)
    8000484e:	fbca                	sd	s2,496(sp)
    80004850:	0c00                	addi	s0,sp,528
    80004852:	892a                	mv	s2,a0
    80004854:	dea43c23          	sd	a0,-520(s0)
    80004858:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000485c:	884fd0ef          	jal	800018e0 <myproc>
    80004860:	84aa                	mv	s1,a0

  begin_op();
    80004862:	dc6ff0ef          	jal	80003e28 <begin_op>

  if((ip = namei(path)) == 0){
    80004866:	854a                	mv	a0,s2
    80004868:	c04ff0ef          	jal	80003c6c <namei>
    8000486c:	c931                	beqz	a0,800048c0 <exec+0x80>
    8000486e:	f3d2                	sd	s4,480(sp)
    80004870:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004872:	d21fe0ef          	jal	80003592 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004876:	04000713          	li	a4,64
    8000487a:	4681                	li	a3,0
    8000487c:	e5040613          	addi	a2,s0,-432
    80004880:	4581                	li	a1,0
    80004882:	8552                	mv	a0,s4
    80004884:	f63fe0ef          	jal	800037e6 <readi>
    80004888:	04000793          	li	a5,64
    8000488c:	00f51a63          	bne	a0,a5,800048a0 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004890:	e5042703          	lw	a4,-432(s0)
    80004894:	464c47b7          	lui	a5,0x464c4
    80004898:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000489c:	02f70663          	beq	a4,a5,800048c8 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800048a0:	8552                	mv	a0,s4
    800048a2:	efbfe0ef          	jal	8000379c <iunlockput>
    end_op();
    800048a6:	decff0ef          	jal	80003e92 <end_op>
  }
  return -1;
    800048aa:	557d                	li	a0,-1
    800048ac:	7a1e                	ld	s4,480(sp)
}
    800048ae:	20813083          	ld	ra,520(sp)
    800048b2:	20013403          	ld	s0,512(sp)
    800048b6:	74fe                	ld	s1,504(sp)
    800048b8:	795e                	ld	s2,496(sp)
    800048ba:	21010113          	addi	sp,sp,528
    800048be:	8082                	ret
    end_op();
    800048c0:	dd2ff0ef          	jal	80003e92 <end_op>
    return -1;
    800048c4:	557d                	li	a0,-1
    800048c6:	b7e5                	j	800048ae <exec+0x6e>
    800048c8:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800048ca:	8526                	mv	a0,s1
    800048cc:	8bcfd0ef          	jal	80001988 <proc_pagetable>
    800048d0:	8b2a                	mv	s6,a0
    800048d2:	2c050b63          	beqz	a0,80004ba8 <exec+0x368>
    800048d6:	f7ce                	sd	s3,488(sp)
    800048d8:	efd6                	sd	s5,472(sp)
    800048da:	e7de                	sd	s7,456(sp)
    800048dc:	e3e2                	sd	s8,448(sp)
    800048de:	ff66                	sd	s9,440(sp)
    800048e0:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048e2:	e7042d03          	lw	s10,-400(s0)
    800048e6:	e8845783          	lhu	a5,-376(s0)
    800048ea:	12078963          	beqz	a5,80004a1c <exec+0x1dc>
    800048ee:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048f0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800048f2:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800048f4:	6c85                	lui	s9,0x1
    800048f6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800048fa:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800048fe:	6a85                	lui	s5,0x1
    80004900:	a085                	j	80004960 <exec+0x120>
      panic("loadseg: address should exist");
    80004902:	00003517          	auipc	a0,0x3
    80004906:	cfe50513          	addi	a0,a0,-770 # 80007600 <etext+0x600>
    8000490a:	e8bfb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    8000490e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004910:	8726                	mv	a4,s1
    80004912:	012c06bb          	addw	a3,s8,s2
    80004916:	4581                	li	a1,0
    80004918:	8552                	mv	a0,s4
    8000491a:	ecdfe0ef          	jal	800037e6 <readi>
    8000491e:	2501                	sext.w	a0,a0
    80004920:	24a49a63          	bne	s1,a0,80004b74 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004924:	012a893b          	addw	s2,s5,s2
    80004928:	03397363          	bgeu	s2,s3,8000494e <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000492c:	02091593          	slli	a1,s2,0x20
    80004930:	9181                	srli	a1,a1,0x20
    80004932:	95de                	add	a1,a1,s7
    80004934:	855a                	mv	a0,s6
    80004936:	ea0fc0ef          	jal	80000fd6 <walkaddr>
    8000493a:	862a                	mv	a2,a0
    if(pa == 0)
    8000493c:	d179                	beqz	a0,80004902 <exec+0xc2>
    if(sz - i < PGSIZE)
    8000493e:	412984bb          	subw	s1,s3,s2
    80004942:	0004879b          	sext.w	a5,s1
    80004946:	fcfcf4e3          	bgeu	s9,a5,8000490e <exec+0xce>
    8000494a:	84d6                	mv	s1,s5
    8000494c:	b7c9                	j	8000490e <exec+0xce>
    sz = sz1;
    8000494e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004952:	2d85                	addiw	s11,s11,1
    80004954:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004958:	e8845783          	lhu	a5,-376(s0)
    8000495c:	08fdd063          	bge	s11,a5,800049dc <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004960:	2d01                	sext.w	s10,s10
    80004962:	03800713          	li	a4,56
    80004966:	86ea                	mv	a3,s10
    80004968:	e1840613          	addi	a2,s0,-488
    8000496c:	4581                	li	a1,0
    8000496e:	8552                	mv	a0,s4
    80004970:	e77fe0ef          	jal	800037e6 <readi>
    80004974:	03800793          	li	a5,56
    80004978:	1cf51663          	bne	a0,a5,80004b44 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000497c:	e1842783          	lw	a5,-488(s0)
    80004980:	4705                	li	a4,1
    80004982:	fce798e3          	bne	a5,a4,80004952 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004986:	e4043483          	ld	s1,-448(s0)
    8000498a:	e3843783          	ld	a5,-456(s0)
    8000498e:	1af4ef63          	bltu	s1,a5,80004b4c <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004992:	e2843783          	ld	a5,-472(s0)
    80004996:	94be                	add	s1,s1,a5
    80004998:	1af4ee63          	bltu	s1,a5,80004b54 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000499c:	df043703          	ld	a4,-528(s0)
    800049a0:	8ff9                	and	a5,a5,a4
    800049a2:	1a079d63          	bnez	a5,80004b5c <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800049a6:	e1c42503          	lw	a0,-484(s0)
    800049aa:	e7dff0ef          	jal	80004826 <flags2perm>
    800049ae:	86aa                	mv	a3,a0
    800049b0:	8626                	mv	a2,s1
    800049b2:	85ca                	mv	a1,s2
    800049b4:	855a                	mv	a0,s6
    800049b6:	989fc0ef          	jal	8000133e <uvmalloc>
    800049ba:	e0a43423          	sd	a0,-504(s0)
    800049be:	1a050363          	beqz	a0,80004b64 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800049c2:	e2843b83          	ld	s7,-472(s0)
    800049c6:	e2042c03          	lw	s8,-480(s0)
    800049ca:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800049ce:	00098463          	beqz	s3,800049d6 <exec+0x196>
    800049d2:	4901                	li	s2,0
    800049d4:	bfa1                	j	8000492c <exec+0xec>
    sz = sz1;
    800049d6:	e0843903          	ld	s2,-504(s0)
    800049da:	bfa5                	j	80004952 <exec+0x112>
    800049dc:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800049de:	8552                	mv	a0,s4
    800049e0:	dbdfe0ef          	jal	8000379c <iunlockput>
  end_op();
    800049e4:	caeff0ef          	jal	80003e92 <end_op>
  p = myproc();
    800049e8:	ef9fc0ef          	jal	800018e0 <myproc>
    800049ec:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800049ee:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800049f2:	6985                	lui	s3,0x1
    800049f4:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800049f6:	99ca                	add	s3,s3,s2
    800049f8:	77fd                	lui	a5,0xfffff
    800049fa:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800049fe:	4691                	li	a3,4
    80004a00:	6609                	lui	a2,0x2
    80004a02:	964e                	add	a2,a2,s3
    80004a04:	85ce                	mv	a1,s3
    80004a06:	855a                	mv	a0,s6
    80004a08:	937fc0ef          	jal	8000133e <uvmalloc>
    80004a0c:	892a                	mv	s2,a0
    80004a0e:	e0a43423          	sd	a0,-504(s0)
    80004a12:	e519                	bnez	a0,80004a20 <exec+0x1e0>
  if(pagetable)
    80004a14:	e1343423          	sd	s3,-504(s0)
    80004a18:	4a01                	li	s4,0
    80004a1a:	aab1                	j	80004b76 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a1c:	4901                	li	s2,0
    80004a1e:	b7c1                	j	800049de <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004a20:	75f9                	lui	a1,0xffffe
    80004a22:	95aa                	add	a1,a1,a0
    80004a24:	855a                	mv	a0,s6
    80004a26:	b03fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004a2a:	7bfd                	lui	s7,0xfffff
    80004a2c:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004a2e:	e0043783          	ld	a5,-512(s0)
    80004a32:	6388                	ld	a0,0(a5)
    80004a34:	cd39                	beqz	a0,80004a92 <exec+0x252>
    80004a36:	e9040993          	addi	s3,s0,-368
    80004a3a:	f9040c13          	addi	s8,s0,-112
    80004a3e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004a40:	bf8fc0ef          	jal	80000e38 <strlen>
    80004a44:	0015079b          	addiw	a5,a0,1
    80004a48:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004a4c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004a50:	11796e63          	bltu	s2,s7,80004b6c <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004a54:	e0043d03          	ld	s10,-512(s0)
    80004a58:	000d3a03          	ld	s4,0(s10)
    80004a5c:	8552                	mv	a0,s4
    80004a5e:	bdafc0ef          	jal	80000e38 <strlen>
    80004a62:	0015069b          	addiw	a3,a0,1
    80004a66:	8652                	mv	a2,s4
    80004a68:	85ca                	mv	a1,s2
    80004a6a:	855a                	mv	a0,s6
    80004a6c:	ae7fc0ef          	jal	80001552 <copyout>
    80004a70:	10054063          	bltz	a0,80004b70 <exec+0x330>
    ustack[argc] = sp;
    80004a74:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004a78:	0485                	addi	s1,s1,1
    80004a7a:	008d0793          	addi	a5,s10,8
    80004a7e:	e0f43023          	sd	a5,-512(s0)
    80004a82:	008d3503          	ld	a0,8(s10)
    80004a86:	c909                	beqz	a0,80004a98 <exec+0x258>
    if(argc >= MAXARG)
    80004a88:	09a1                	addi	s3,s3,8
    80004a8a:	fb899be3          	bne	s3,s8,80004a40 <exec+0x200>
  ip = 0;
    80004a8e:	4a01                	li	s4,0
    80004a90:	a0dd                	j	80004b76 <exec+0x336>
  sp = sz;
    80004a92:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004a96:	4481                	li	s1,0
  ustack[argc] = 0;
    80004a98:	00349793          	slli	a5,s1,0x3
    80004a9c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffddf20>
    80004aa0:	97a2                	add	a5,a5,s0
    80004aa2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004aa6:	00148693          	addi	a3,s1,1
    80004aaa:	068e                	slli	a3,a3,0x3
    80004aac:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ab0:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004ab4:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004ab8:	f5796ee3          	bltu	s2,s7,80004a14 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004abc:	e9040613          	addi	a2,s0,-368
    80004ac0:	85ca                	mv	a1,s2
    80004ac2:	855a                	mv	a0,s6
    80004ac4:	a8ffc0ef          	jal	80001552 <copyout>
    80004ac8:	0e054263          	bltz	a0,80004bac <exec+0x36c>
  p->trapframe->a1 = sp;
    80004acc:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004ad0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ad4:	df843783          	ld	a5,-520(s0)
    80004ad8:	0007c703          	lbu	a4,0(a5)
    80004adc:	cf11                	beqz	a4,80004af8 <exec+0x2b8>
    80004ade:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004ae0:	02f00693          	li	a3,47
    80004ae4:	a039                	j	80004af2 <exec+0x2b2>
      last = s+1;
    80004ae6:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004aea:	0785                	addi	a5,a5,1
    80004aec:	fff7c703          	lbu	a4,-1(a5)
    80004af0:	c701                	beqz	a4,80004af8 <exec+0x2b8>
    if(*s == '/')
    80004af2:	fed71ce3          	bne	a4,a3,80004aea <exec+0x2aa>
    80004af6:	bfc5                	j	80004ae6 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004af8:	4641                	li	a2,16
    80004afa:	df843583          	ld	a1,-520(s0)
    80004afe:	158a8513          	addi	a0,s5,344
    80004b02:	b04fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004b06:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b0a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b0e:	e0843783          	ld	a5,-504(s0)
    80004b12:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004b16:	058ab783          	ld	a5,88(s5)
    80004b1a:	e6843703          	ld	a4,-408(s0)
    80004b1e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b20:	058ab783          	ld	a5,88(s5)
    80004b24:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004b28:	85e6                	mv	a1,s9
    80004b2a:	ee3fc0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004b2e:	0004851b          	sext.w	a0,s1
    80004b32:	79be                	ld	s3,488(sp)
    80004b34:	7a1e                	ld	s4,480(sp)
    80004b36:	6afe                	ld	s5,472(sp)
    80004b38:	6b5e                	ld	s6,464(sp)
    80004b3a:	6bbe                	ld	s7,456(sp)
    80004b3c:	6c1e                	ld	s8,448(sp)
    80004b3e:	7cfa                	ld	s9,440(sp)
    80004b40:	7d5a                	ld	s10,432(sp)
    80004b42:	b3b5                	j	800048ae <exec+0x6e>
    80004b44:	e1243423          	sd	s2,-504(s0)
    80004b48:	7dba                	ld	s11,424(sp)
    80004b4a:	a035                	j	80004b76 <exec+0x336>
    80004b4c:	e1243423          	sd	s2,-504(s0)
    80004b50:	7dba                	ld	s11,424(sp)
    80004b52:	a015                	j	80004b76 <exec+0x336>
    80004b54:	e1243423          	sd	s2,-504(s0)
    80004b58:	7dba                	ld	s11,424(sp)
    80004b5a:	a831                	j	80004b76 <exec+0x336>
    80004b5c:	e1243423          	sd	s2,-504(s0)
    80004b60:	7dba                	ld	s11,424(sp)
    80004b62:	a811                	j	80004b76 <exec+0x336>
    80004b64:	e1243423          	sd	s2,-504(s0)
    80004b68:	7dba                	ld	s11,424(sp)
    80004b6a:	a031                	j	80004b76 <exec+0x336>
  ip = 0;
    80004b6c:	4a01                	li	s4,0
    80004b6e:	a021                	j	80004b76 <exec+0x336>
    80004b70:	4a01                	li	s4,0
  if(pagetable)
    80004b72:	a011                	j	80004b76 <exec+0x336>
    80004b74:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004b76:	e0843583          	ld	a1,-504(s0)
    80004b7a:	855a                	mv	a0,s6
    80004b7c:	e91fc0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    80004b80:	557d                	li	a0,-1
  if(ip){
    80004b82:	000a1b63          	bnez	s4,80004b98 <exec+0x358>
    80004b86:	79be                	ld	s3,488(sp)
    80004b88:	7a1e                	ld	s4,480(sp)
    80004b8a:	6afe                	ld	s5,472(sp)
    80004b8c:	6b5e                	ld	s6,464(sp)
    80004b8e:	6bbe                	ld	s7,456(sp)
    80004b90:	6c1e                	ld	s8,448(sp)
    80004b92:	7cfa                	ld	s9,440(sp)
    80004b94:	7d5a                	ld	s10,432(sp)
    80004b96:	bb21                	j	800048ae <exec+0x6e>
    80004b98:	79be                	ld	s3,488(sp)
    80004b9a:	6afe                	ld	s5,472(sp)
    80004b9c:	6b5e                	ld	s6,464(sp)
    80004b9e:	6bbe                	ld	s7,456(sp)
    80004ba0:	6c1e                	ld	s8,448(sp)
    80004ba2:	7cfa                	ld	s9,440(sp)
    80004ba4:	7d5a                	ld	s10,432(sp)
    80004ba6:	b9ed                	j	800048a0 <exec+0x60>
    80004ba8:	6b5e                	ld	s6,464(sp)
    80004baa:	b9dd                	j	800048a0 <exec+0x60>
  sz = sz1;
    80004bac:	e0843983          	ld	s3,-504(s0)
    80004bb0:	b595                	j	80004a14 <exec+0x1d4>

0000000080004bb2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004bb2:	7179                	addi	sp,sp,-48
    80004bb4:	f406                	sd	ra,40(sp)
    80004bb6:	f022                	sd	s0,32(sp)
    80004bb8:	ec26                	sd	s1,24(sp)
    80004bba:	e84a                	sd	s2,16(sp)
    80004bbc:	1800                	addi	s0,sp,48
    80004bbe:	892e                	mv	s2,a1
    80004bc0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004bc2:	fdc40593          	addi	a1,s0,-36
    80004bc6:	f21fd0ef          	jal	80002ae6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004bca:	fdc42703          	lw	a4,-36(s0)
    80004bce:	47bd                	li	a5,15
    80004bd0:	02e7e963          	bltu	a5,a4,80004c02 <argfd+0x50>
    80004bd4:	d0dfc0ef          	jal	800018e0 <myproc>
    80004bd8:	fdc42703          	lw	a4,-36(s0)
    80004bdc:	01a70793          	addi	a5,a4,26
    80004be0:	078e                	slli	a5,a5,0x3
    80004be2:	953e                	add	a0,a0,a5
    80004be4:	611c                	ld	a5,0(a0)
    80004be6:	c385                	beqz	a5,80004c06 <argfd+0x54>
    return -1;
  if(pfd)
    80004be8:	00090463          	beqz	s2,80004bf0 <argfd+0x3e>
    *pfd = fd;
    80004bec:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004bf0:	4501                	li	a0,0
  if(pf)
    80004bf2:	c091                	beqz	s1,80004bf6 <argfd+0x44>
    *pf = f;
    80004bf4:	e09c                	sd	a5,0(s1)
}
    80004bf6:	70a2                	ld	ra,40(sp)
    80004bf8:	7402                	ld	s0,32(sp)
    80004bfa:	64e2                	ld	s1,24(sp)
    80004bfc:	6942                	ld	s2,16(sp)
    80004bfe:	6145                	addi	sp,sp,48
    80004c00:	8082                	ret
    return -1;
    80004c02:	557d                	li	a0,-1
    80004c04:	bfcd                	j	80004bf6 <argfd+0x44>
    80004c06:	557d                	li	a0,-1
    80004c08:	b7fd                	j	80004bf6 <argfd+0x44>

0000000080004c0a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c0a:	1101                	addi	sp,sp,-32
    80004c0c:	ec06                	sd	ra,24(sp)
    80004c0e:	e822                	sd	s0,16(sp)
    80004c10:	e426                	sd	s1,8(sp)
    80004c12:	1000                	addi	s0,sp,32
    80004c14:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c16:	ccbfc0ef          	jal	800018e0 <myproc>
    80004c1a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c1c:	0d050793          	addi	a5,a0,208
    80004c20:	4501                	li	a0,0
    80004c22:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c24:	6398                	ld	a4,0(a5)
    80004c26:	cb19                	beqz	a4,80004c3c <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c28:	2505                	addiw	a0,a0,1
    80004c2a:	07a1                	addi	a5,a5,8
    80004c2c:	fed51ce3          	bne	a0,a3,80004c24 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c30:	557d                	li	a0,-1
}
    80004c32:	60e2                	ld	ra,24(sp)
    80004c34:	6442                	ld	s0,16(sp)
    80004c36:	64a2                	ld	s1,8(sp)
    80004c38:	6105                	addi	sp,sp,32
    80004c3a:	8082                	ret
      p->ofile[fd] = f;
    80004c3c:	01a50793          	addi	a5,a0,26
    80004c40:	078e                	slli	a5,a5,0x3
    80004c42:	963e                	add	a2,a2,a5
    80004c44:	e204                	sd	s1,0(a2)
      return fd;
    80004c46:	b7f5                	j	80004c32 <fdalloc+0x28>

0000000080004c48 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004c48:	715d                	addi	sp,sp,-80
    80004c4a:	e486                	sd	ra,72(sp)
    80004c4c:	e0a2                	sd	s0,64(sp)
    80004c4e:	fc26                	sd	s1,56(sp)
    80004c50:	f84a                	sd	s2,48(sp)
    80004c52:	f44e                	sd	s3,40(sp)
    80004c54:	ec56                	sd	s5,24(sp)
    80004c56:	e85a                	sd	s6,16(sp)
    80004c58:	0880                	addi	s0,sp,80
    80004c5a:	8b2e                	mv	s6,a1
    80004c5c:	89b2                	mv	s3,a2
    80004c5e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004c60:	fb040593          	addi	a1,s0,-80
    80004c64:	822ff0ef          	jal	80003c86 <nameiparent>
    80004c68:	84aa                	mv	s1,a0
    80004c6a:	10050a63          	beqz	a0,80004d7e <create+0x136>
    return 0;

  ilock(dp);
    80004c6e:	925fe0ef          	jal	80003592 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004c72:	4601                	li	a2,0
    80004c74:	fb040593          	addi	a1,s0,-80
    80004c78:	8526                	mv	a0,s1
    80004c7a:	d8dfe0ef          	jal	80003a06 <dirlookup>
    80004c7e:	8aaa                	mv	s5,a0
    80004c80:	c129                	beqz	a0,80004cc2 <create+0x7a>
    iunlockput(dp);
    80004c82:	8526                	mv	a0,s1
    80004c84:	b19fe0ef          	jal	8000379c <iunlockput>
    ilock(ip);
    80004c88:	8556                	mv	a0,s5
    80004c8a:	909fe0ef          	jal	80003592 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004c8e:	4789                	li	a5,2
    80004c90:	02fb1463          	bne	s6,a5,80004cb8 <create+0x70>
    80004c94:	044ad783          	lhu	a5,68(s5)
    80004c98:	37f9                	addiw	a5,a5,-2
    80004c9a:	17c2                	slli	a5,a5,0x30
    80004c9c:	93c1                	srli	a5,a5,0x30
    80004c9e:	4705                	li	a4,1
    80004ca0:	00f76c63          	bltu	a4,a5,80004cb8 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004ca4:	8556                	mv	a0,s5
    80004ca6:	60a6                	ld	ra,72(sp)
    80004ca8:	6406                	ld	s0,64(sp)
    80004caa:	74e2                	ld	s1,56(sp)
    80004cac:	7942                	ld	s2,48(sp)
    80004cae:	79a2                	ld	s3,40(sp)
    80004cb0:	6ae2                	ld	s5,24(sp)
    80004cb2:	6b42                	ld	s6,16(sp)
    80004cb4:	6161                	addi	sp,sp,80
    80004cb6:	8082                	ret
    iunlockput(ip);
    80004cb8:	8556                	mv	a0,s5
    80004cba:	ae3fe0ef          	jal	8000379c <iunlockput>
    return 0;
    80004cbe:	4a81                	li	s5,0
    80004cc0:	b7d5                	j	80004ca4 <create+0x5c>
    80004cc2:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004cc4:	85da                	mv	a1,s6
    80004cc6:	4088                	lw	a0,0(s1)
    80004cc8:	f5afe0ef          	jal	80003422 <ialloc>
    80004ccc:	8a2a                	mv	s4,a0
    80004cce:	cd15                	beqz	a0,80004d0a <create+0xc2>
  ilock(ip);
    80004cd0:	8c3fe0ef          	jal	80003592 <ilock>
  ip->major = major;
    80004cd4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004cd8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004cdc:	4905                	li	s2,1
    80004cde:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004ce2:	8552                	mv	a0,s4
    80004ce4:	ffafe0ef          	jal	800034de <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ce8:	032b0763          	beq	s6,s2,80004d16 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004cec:	004a2603          	lw	a2,4(s4)
    80004cf0:	fb040593          	addi	a1,s0,-80
    80004cf4:	8526                	mv	a0,s1
    80004cf6:	eddfe0ef          	jal	80003bd2 <dirlink>
    80004cfa:	06054563          	bltz	a0,80004d64 <create+0x11c>
  iunlockput(dp);
    80004cfe:	8526                	mv	a0,s1
    80004d00:	a9dfe0ef          	jal	8000379c <iunlockput>
  return ip;
    80004d04:	8ad2                	mv	s5,s4
    80004d06:	7a02                	ld	s4,32(sp)
    80004d08:	bf71                	j	80004ca4 <create+0x5c>
    iunlockput(dp);
    80004d0a:	8526                	mv	a0,s1
    80004d0c:	a91fe0ef          	jal	8000379c <iunlockput>
    return 0;
    80004d10:	8ad2                	mv	s5,s4
    80004d12:	7a02                	ld	s4,32(sp)
    80004d14:	bf41                	j	80004ca4 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d16:	004a2603          	lw	a2,4(s4)
    80004d1a:	00003597          	auipc	a1,0x3
    80004d1e:	90658593          	addi	a1,a1,-1786 # 80007620 <etext+0x620>
    80004d22:	8552                	mv	a0,s4
    80004d24:	eaffe0ef          	jal	80003bd2 <dirlink>
    80004d28:	02054e63          	bltz	a0,80004d64 <create+0x11c>
    80004d2c:	40d0                	lw	a2,4(s1)
    80004d2e:	00003597          	auipc	a1,0x3
    80004d32:	8fa58593          	addi	a1,a1,-1798 # 80007628 <etext+0x628>
    80004d36:	8552                	mv	a0,s4
    80004d38:	e9bfe0ef          	jal	80003bd2 <dirlink>
    80004d3c:	02054463          	bltz	a0,80004d64 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d40:	004a2603          	lw	a2,4(s4)
    80004d44:	fb040593          	addi	a1,s0,-80
    80004d48:	8526                	mv	a0,s1
    80004d4a:	e89fe0ef          	jal	80003bd2 <dirlink>
    80004d4e:	00054b63          	bltz	a0,80004d64 <create+0x11c>
    dp->nlink++;  // for ".."
    80004d52:	04a4d783          	lhu	a5,74(s1)
    80004d56:	2785                	addiw	a5,a5,1
    80004d58:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	f80fe0ef          	jal	800034de <iupdate>
    80004d62:	bf71                	j	80004cfe <create+0xb6>
  ip->nlink = 0;
    80004d64:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004d68:	8552                	mv	a0,s4
    80004d6a:	f74fe0ef          	jal	800034de <iupdate>
  iunlockput(ip);
    80004d6e:	8552                	mv	a0,s4
    80004d70:	a2dfe0ef          	jal	8000379c <iunlockput>
  iunlockput(dp);
    80004d74:	8526                	mv	a0,s1
    80004d76:	a27fe0ef          	jal	8000379c <iunlockput>
  return 0;
    80004d7a:	7a02                	ld	s4,32(sp)
    80004d7c:	b725                	j	80004ca4 <create+0x5c>
    return 0;
    80004d7e:	8aaa                	mv	s5,a0
    80004d80:	b715                	j	80004ca4 <create+0x5c>

0000000080004d82 <sys_dup>:
{
    80004d82:	7179                	addi	sp,sp,-48
    80004d84:	f406                	sd	ra,40(sp)
    80004d86:	f022                	sd	s0,32(sp)
    80004d88:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004d8a:	fd840613          	addi	a2,s0,-40
    80004d8e:	4581                	li	a1,0
    80004d90:	4501                	li	a0,0
    80004d92:	e21ff0ef          	jal	80004bb2 <argfd>
    return -1;
    80004d96:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004d98:	02054363          	bltz	a0,80004dbe <sys_dup+0x3c>
    80004d9c:	ec26                	sd	s1,24(sp)
    80004d9e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004da0:	fd843903          	ld	s2,-40(s0)
    80004da4:	854a                	mv	a0,s2
    80004da6:	e65ff0ef          	jal	80004c0a <fdalloc>
    80004daa:	84aa                	mv	s1,a0
    return -1;
    80004dac:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004dae:	00054d63          	bltz	a0,80004dc8 <sys_dup+0x46>
  filedup(f);
    80004db2:	854a                	mv	a0,s2
    80004db4:	c48ff0ef          	jal	800041fc <filedup>
  return fd;
    80004db8:	87a6                	mv	a5,s1
    80004dba:	64e2                	ld	s1,24(sp)
    80004dbc:	6942                	ld	s2,16(sp)
}
    80004dbe:	853e                	mv	a0,a5
    80004dc0:	70a2                	ld	ra,40(sp)
    80004dc2:	7402                	ld	s0,32(sp)
    80004dc4:	6145                	addi	sp,sp,48
    80004dc6:	8082                	ret
    80004dc8:	64e2                	ld	s1,24(sp)
    80004dca:	6942                	ld	s2,16(sp)
    80004dcc:	bfcd                	j	80004dbe <sys_dup+0x3c>

0000000080004dce <sys_read>:
{
    80004dce:	7179                	addi	sp,sp,-48
    80004dd0:	f406                	sd	ra,40(sp)
    80004dd2:	f022                	sd	s0,32(sp)
    80004dd4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004dd6:	fd840593          	addi	a1,s0,-40
    80004dda:	4505                	li	a0,1
    80004ddc:	d27fd0ef          	jal	80002b02 <argaddr>
  argint(2, &n);
    80004de0:	fe440593          	addi	a1,s0,-28
    80004de4:	4509                	li	a0,2
    80004de6:	d01fd0ef          	jal	80002ae6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004dea:	fe840613          	addi	a2,s0,-24
    80004dee:	4581                	li	a1,0
    80004df0:	4501                	li	a0,0
    80004df2:	dc1ff0ef          	jal	80004bb2 <argfd>
    80004df6:	87aa                	mv	a5,a0
    return -1;
    80004df8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dfa:	0007ca63          	bltz	a5,80004e0e <sys_read+0x40>
  return fileread(f, p, n);
    80004dfe:	fe442603          	lw	a2,-28(s0)
    80004e02:	fd843583          	ld	a1,-40(s0)
    80004e06:	fe843503          	ld	a0,-24(s0)
    80004e0a:	d58ff0ef          	jal	80004362 <fileread>
}
    80004e0e:	70a2                	ld	ra,40(sp)
    80004e10:	7402                	ld	s0,32(sp)
    80004e12:	6145                	addi	sp,sp,48
    80004e14:	8082                	ret

0000000080004e16 <sys_write>:
{
    80004e16:	7179                	addi	sp,sp,-48
    80004e18:	f406                	sd	ra,40(sp)
    80004e1a:	f022                	sd	s0,32(sp)
    80004e1c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e1e:	fd840593          	addi	a1,s0,-40
    80004e22:	4505                	li	a0,1
    80004e24:	cdffd0ef          	jal	80002b02 <argaddr>
  argint(2, &n);
    80004e28:	fe440593          	addi	a1,s0,-28
    80004e2c:	4509                	li	a0,2
    80004e2e:	cb9fd0ef          	jal	80002ae6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e32:	fe840613          	addi	a2,s0,-24
    80004e36:	4581                	li	a1,0
    80004e38:	4501                	li	a0,0
    80004e3a:	d79ff0ef          	jal	80004bb2 <argfd>
    80004e3e:	87aa                	mv	a5,a0
    return -1;
    80004e40:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e42:	0007ca63          	bltz	a5,80004e56 <sys_write+0x40>
  return filewrite(f, p, n);
    80004e46:	fe442603          	lw	a2,-28(s0)
    80004e4a:	fd843583          	ld	a1,-40(s0)
    80004e4e:	fe843503          	ld	a0,-24(s0)
    80004e52:	dceff0ef          	jal	80004420 <filewrite>
}
    80004e56:	70a2                	ld	ra,40(sp)
    80004e58:	7402                	ld	s0,32(sp)
    80004e5a:	6145                	addi	sp,sp,48
    80004e5c:	8082                	ret

0000000080004e5e <sys_close>:
{
    80004e5e:	1101                	addi	sp,sp,-32
    80004e60:	ec06                	sd	ra,24(sp)
    80004e62:	e822                	sd	s0,16(sp)
    80004e64:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004e66:	fe040613          	addi	a2,s0,-32
    80004e6a:	fec40593          	addi	a1,s0,-20
    80004e6e:	4501                	li	a0,0
    80004e70:	d43ff0ef          	jal	80004bb2 <argfd>
    return -1;
    80004e74:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004e76:	02054063          	bltz	a0,80004e96 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004e7a:	a67fc0ef          	jal	800018e0 <myproc>
    80004e7e:	fec42783          	lw	a5,-20(s0)
    80004e82:	07e9                	addi	a5,a5,26
    80004e84:	078e                	slli	a5,a5,0x3
    80004e86:	953e                	add	a0,a0,a5
    80004e88:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004e8c:	fe043503          	ld	a0,-32(s0)
    80004e90:	bb2ff0ef          	jal	80004242 <fileclose>
  return 0;
    80004e94:	4781                	li	a5,0
}
    80004e96:	853e                	mv	a0,a5
    80004e98:	60e2                	ld	ra,24(sp)
    80004e9a:	6442                	ld	s0,16(sp)
    80004e9c:	6105                	addi	sp,sp,32
    80004e9e:	8082                	ret

0000000080004ea0 <sys_fstat>:
{
    80004ea0:	1101                	addi	sp,sp,-32
    80004ea2:	ec06                	sd	ra,24(sp)
    80004ea4:	e822                	sd	s0,16(sp)
    80004ea6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ea8:	fe040593          	addi	a1,s0,-32
    80004eac:	4505                	li	a0,1
    80004eae:	c55fd0ef          	jal	80002b02 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004eb2:	fe840613          	addi	a2,s0,-24
    80004eb6:	4581                	li	a1,0
    80004eb8:	4501                	li	a0,0
    80004eba:	cf9ff0ef          	jal	80004bb2 <argfd>
    80004ebe:	87aa                	mv	a5,a0
    return -1;
    80004ec0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ec2:	0007c863          	bltz	a5,80004ed2 <sys_fstat+0x32>
  return filestat(f, st);
    80004ec6:	fe043583          	ld	a1,-32(s0)
    80004eca:	fe843503          	ld	a0,-24(s0)
    80004ece:	c36ff0ef          	jal	80004304 <filestat>
}
    80004ed2:	60e2                	ld	ra,24(sp)
    80004ed4:	6442                	ld	s0,16(sp)
    80004ed6:	6105                	addi	sp,sp,32
    80004ed8:	8082                	ret

0000000080004eda <sys_link>:
{
    80004eda:	7169                	addi	sp,sp,-304
    80004edc:	f606                	sd	ra,296(sp)
    80004ede:	f222                	sd	s0,288(sp)
    80004ee0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ee2:	08000613          	li	a2,128
    80004ee6:	ed040593          	addi	a1,s0,-304
    80004eea:	4501                	li	a0,0
    80004eec:	c33fd0ef          	jal	80002b1e <argstr>
    return -1;
    80004ef0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ef2:	0c054e63          	bltz	a0,80004fce <sys_link+0xf4>
    80004ef6:	08000613          	li	a2,128
    80004efa:	f5040593          	addi	a1,s0,-176
    80004efe:	4505                	li	a0,1
    80004f00:	c1ffd0ef          	jal	80002b1e <argstr>
    return -1;
    80004f04:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f06:	0c054463          	bltz	a0,80004fce <sys_link+0xf4>
    80004f0a:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f0c:	f1dfe0ef          	jal	80003e28 <begin_op>
  if((ip = namei(old)) == 0){
    80004f10:	ed040513          	addi	a0,s0,-304
    80004f14:	d59fe0ef          	jal	80003c6c <namei>
    80004f18:	84aa                	mv	s1,a0
    80004f1a:	c53d                	beqz	a0,80004f88 <sys_link+0xae>
  ilock(ip);
    80004f1c:	e76fe0ef          	jal	80003592 <ilock>
  if(ip->type == T_DIR){
    80004f20:	04449703          	lh	a4,68(s1)
    80004f24:	4785                	li	a5,1
    80004f26:	06f70663          	beq	a4,a5,80004f92 <sys_link+0xb8>
    80004f2a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f2c:	04a4d783          	lhu	a5,74(s1)
    80004f30:	2785                	addiw	a5,a5,1
    80004f32:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f36:	8526                	mv	a0,s1
    80004f38:	da6fe0ef          	jal	800034de <iupdate>
  iunlock(ip);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	f02fe0ef          	jal	80003640 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f42:	fd040593          	addi	a1,s0,-48
    80004f46:	f5040513          	addi	a0,s0,-176
    80004f4a:	d3dfe0ef          	jal	80003c86 <nameiparent>
    80004f4e:	892a                	mv	s2,a0
    80004f50:	cd21                	beqz	a0,80004fa8 <sys_link+0xce>
  ilock(dp);
    80004f52:	e40fe0ef          	jal	80003592 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004f56:	00092703          	lw	a4,0(s2)
    80004f5a:	409c                	lw	a5,0(s1)
    80004f5c:	04f71363          	bne	a4,a5,80004fa2 <sys_link+0xc8>
    80004f60:	40d0                	lw	a2,4(s1)
    80004f62:	fd040593          	addi	a1,s0,-48
    80004f66:	854a                	mv	a0,s2
    80004f68:	c6bfe0ef          	jal	80003bd2 <dirlink>
    80004f6c:	02054b63          	bltz	a0,80004fa2 <sys_link+0xc8>
  iunlockput(dp);
    80004f70:	854a                	mv	a0,s2
    80004f72:	82bfe0ef          	jal	8000379c <iunlockput>
  iput(ip);
    80004f76:	8526                	mv	a0,s1
    80004f78:	f9cfe0ef          	jal	80003714 <iput>
  end_op();
    80004f7c:	f17fe0ef          	jal	80003e92 <end_op>
  return 0;
    80004f80:	4781                	li	a5,0
    80004f82:	64f2                	ld	s1,280(sp)
    80004f84:	6952                	ld	s2,272(sp)
    80004f86:	a0a1                	j	80004fce <sys_link+0xf4>
    end_op();
    80004f88:	f0bfe0ef          	jal	80003e92 <end_op>
    return -1;
    80004f8c:	57fd                	li	a5,-1
    80004f8e:	64f2                	ld	s1,280(sp)
    80004f90:	a83d                	j	80004fce <sys_link+0xf4>
    iunlockput(ip);
    80004f92:	8526                	mv	a0,s1
    80004f94:	809fe0ef          	jal	8000379c <iunlockput>
    end_op();
    80004f98:	efbfe0ef          	jal	80003e92 <end_op>
    return -1;
    80004f9c:	57fd                	li	a5,-1
    80004f9e:	64f2                	ld	s1,280(sp)
    80004fa0:	a03d                	j	80004fce <sys_link+0xf4>
    iunlockput(dp);
    80004fa2:	854a                	mv	a0,s2
    80004fa4:	ff8fe0ef          	jal	8000379c <iunlockput>
  ilock(ip);
    80004fa8:	8526                	mv	a0,s1
    80004faa:	de8fe0ef          	jal	80003592 <ilock>
  ip->nlink--;
    80004fae:	04a4d783          	lhu	a5,74(s1)
    80004fb2:	37fd                	addiw	a5,a5,-1
    80004fb4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004fb8:	8526                	mv	a0,s1
    80004fba:	d24fe0ef          	jal	800034de <iupdate>
  iunlockput(ip);
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	fdcfe0ef          	jal	8000379c <iunlockput>
  end_op();
    80004fc4:	ecffe0ef          	jal	80003e92 <end_op>
  return -1;
    80004fc8:	57fd                	li	a5,-1
    80004fca:	64f2                	ld	s1,280(sp)
    80004fcc:	6952                	ld	s2,272(sp)
}
    80004fce:	853e                	mv	a0,a5
    80004fd0:	70b2                	ld	ra,296(sp)
    80004fd2:	7412                	ld	s0,288(sp)
    80004fd4:	6155                	addi	sp,sp,304
    80004fd6:	8082                	ret

0000000080004fd8 <sys_unlink>:
{
    80004fd8:	7151                	addi	sp,sp,-240
    80004fda:	f586                	sd	ra,232(sp)
    80004fdc:	f1a2                	sd	s0,224(sp)
    80004fde:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004fe0:	08000613          	li	a2,128
    80004fe4:	f3040593          	addi	a1,s0,-208
    80004fe8:	4501                	li	a0,0
    80004fea:	b35fd0ef          	jal	80002b1e <argstr>
    80004fee:	16054063          	bltz	a0,8000514e <sys_unlink+0x176>
    80004ff2:	eda6                	sd	s1,216(sp)
  begin_op();
    80004ff4:	e35fe0ef          	jal	80003e28 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ff8:	fb040593          	addi	a1,s0,-80
    80004ffc:	f3040513          	addi	a0,s0,-208
    80005000:	c87fe0ef          	jal	80003c86 <nameiparent>
    80005004:	84aa                	mv	s1,a0
    80005006:	c945                	beqz	a0,800050b6 <sys_unlink+0xde>
  ilock(dp);
    80005008:	d8afe0ef          	jal	80003592 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000500c:	00002597          	auipc	a1,0x2
    80005010:	61458593          	addi	a1,a1,1556 # 80007620 <etext+0x620>
    80005014:	fb040513          	addi	a0,s0,-80
    80005018:	9d9fe0ef          	jal	800039f0 <namecmp>
    8000501c:	10050e63          	beqz	a0,80005138 <sys_unlink+0x160>
    80005020:	00002597          	auipc	a1,0x2
    80005024:	60858593          	addi	a1,a1,1544 # 80007628 <etext+0x628>
    80005028:	fb040513          	addi	a0,s0,-80
    8000502c:	9c5fe0ef          	jal	800039f0 <namecmp>
    80005030:	10050463          	beqz	a0,80005138 <sys_unlink+0x160>
    80005034:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005036:	f2c40613          	addi	a2,s0,-212
    8000503a:	fb040593          	addi	a1,s0,-80
    8000503e:	8526                	mv	a0,s1
    80005040:	9c7fe0ef          	jal	80003a06 <dirlookup>
    80005044:	892a                	mv	s2,a0
    80005046:	0e050863          	beqz	a0,80005136 <sys_unlink+0x15e>
  ilock(ip);
    8000504a:	d48fe0ef          	jal	80003592 <ilock>
  if(ip->nlink < 1)
    8000504e:	04a91783          	lh	a5,74(s2)
    80005052:	06f05763          	blez	a5,800050c0 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005056:	04491703          	lh	a4,68(s2)
    8000505a:	4785                	li	a5,1
    8000505c:	06f70963          	beq	a4,a5,800050ce <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005060:	4641                	li	a2,16
    80005062:	4581                	li	a1,0
    80005064:	fc040513          	addi	a0,s0,-64
    80005068:	c61fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000506c:	4741                	li	a4,16
    8000506e:	f2c42683          	lw	a3,-212(s0)
    80005072:	fc040613          	addi	a2,s0,-64
    80005076:	4581                	li	a1,0
    80005078:	8526                	mv	a0,s1
    8000507a:	869fe0ef          	jal	800038e2 <writei>
    8000507e:	47c1                	li	a5,16
    80005080:	08f51b63          	bne	a0,a5,80005116 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005084:	04491703          	lh	a4,68(s2)
    80005088:	4785                	li	a5,1
    8000508a:	08f70d63          	beq	a4,a5,80005124 <sys_unlink+0x14c>
  iunlockput(dp);
    8000508e:	8526                	mv	a0,s1
    80005090:	f0cfe0ef          	jal	8000379c <iunlockput>
  ip->nlink--;
    80005094:	04a95783          	lhu	a5,74(s2)
    80005098:	37fd                	addiw	a5,a5,-1
    8000509a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000509e:	854a                	mv	a0,s2
    800050a0:	c3efe0ef          	jal	800034de <iupdate>
  iunlockput(ip);
    800050a4:	854a                	mv	a0,s2
    800050a6:	ef6fe0ef          	jal	8000379c <iunlockput>
  end_op();
    800050aa:	de9fe0ef          	jal	80003e92 <end_op>
  return 0;
    800050ae:	4501                	li	a0,0
    800050b0:	64ee                	ld	s1,216(sp)
    800050b2:	694e                	ld	s2,208(sp)
    800050b4:	a849                	j	80005146 <sys_unlink+0x16e>
    end_op();
    800050b6:	dddfe0ef          	jal	80003e92 <end_op>
    return -1;
    800050ba:	557d                	li	a0,-1
    800050bc:	64ee                	ld	s1,216(sp)
    800050be:	a061                	j	80005146 <sys_unlink+0x16e>
    800050c0:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800050c2:	00002517          	auipc	a0,0x2
    800050c6:	56e50513          	addi	a0,a0,1390 # 80007630 <etext+0x630>
    800050ca:	ecafb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800050ce:	04c92703          	lw	a4,76(s2)
    800050d2:	02000793          	li	a5,32
    800050d6:	f8e7f5e3          	bgeu	a5,a4,80005060 <sys_unlink+0x88>
    800050da:	e5ce                	sd	s3,200(sp)
    800050dc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050e0:	4741                	li	a4,16
    800050e2:	86ce                	mv	a3,s3
    800050e4:	f1840613          	addi	a2,s0,-232
    800050e8:	4581                	li	a1,0
    800050ea:	854a                	mv	a0,s2
    800050ec:	efafe0ef          	jal	800037e6 <readi>
    800050f0:	47c1                	li	a5,16
    800050f2:	00f51c63          	bne	a0,a5,8000510a <sys_unlink+0x132>
    if(de.inum != 0)
    800050f6:	f1845783          	lhu	a5,-232(s0)
    800050fa:	efa1                	bnez	a5,80005152 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800050fc:	29c1                	addiw	s3,s3,16
    800050fe:	04c92783          	lw	a5,76(s2)
    80005102:	fcf9efe3          	bltu	s3,a5,800050e0 <sys_unlink+0x108>
    80005106:	69ae                	ld	s3,200(sp)
    80005108:	bfa1                	j	80005060 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000510a:	00002517          	auipc	a0,0x2
    8000510e:	53e50513          	addi	a0,a0,1342 # 80007648 <etext+0x648>
    80005112:	e82fb0ef          	jal	80000794 <panic>
    80005116:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005118:	00002517          	auipc	a0,0x2
    8000511c:	54850513          	addi	a0,a0,1352 # 80007660 <etext+0x660>
    80005120:	e74fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80005124:	04a4d783          	lhu	a5,74(s1)
    80005128:	37fd                	addiw	a5,a5,-1
    8000512a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000512e:	8526                	mv	a0,s1
    80005130:	baefe0ef          	jal	800034de <iupdate>
    80005134:	bfa9                	j	8000508e <sys_unlink+0xb6>
    80005136:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005138:	8526                	mv	a0,s1
    8000513a:	e62fe0ef          	jal	8000379c <iunlockput>
  end_op();
    8000513e:	d55fe0ef          	jal	80003e92 <end_op>
  return -1;
    80005142:	557d                	li	a0,-1
    80005144:	64ee                	ld	s1,216(sp)
}
    80005146:	70ae                	ld	ra,232(sp)
    80005148:	740e                	ld	s0,224(sp)
    8000514a:	616d                	addi	sp,sp,240
    8000514c:	8082                	ret
    return -1;
    8000514e:	557d                	li	a0,-1
    80005150:	bfdd                	j	80005146 <sys_unlink+0x16e>
    iunlockput(ip);
    80005152:	854a                	mv	a0,s2
    80005154:	e48fe0ef          	jal	8000379c <iunlockput>
    goto bad;
    80005158:	694e                	ld	s2,208(sp)
    8000515a:	69ae                	ld	s3,200(sp)
    8000515c:	bff1                	j	80005138 <sys_unlink+0x160>

000000008000515e <sys_open>:

uint64
sys_open(void)
{
    8000515e:	7131                	addi	sp,sp,-192
    80005160:	fd06                	sd	ra,184(sp)
    80005162:	f922                	sd	s0,176(sp)
    80005164:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005166:	f4c40593          	addi	a1,s0,-180
    8000516a:	4505                	li	a0,1
    8000516c:	97bfd0ef          	jal	80002ae6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005170:	08000613          	li	a2,128
    80005174:	f5040593          	addi	a1,s0,-176
    80005178:	4501                	li	a0,0
    8000517a:	9a5fd0ef          	jal	80002b1e <argstr>
    8000517e:	87aa                	mv	a5,a0
    return -1;
    80005180:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005182:	0a07c263          	bltz	a5,80005226 <sys_open+0xc8>
    80005186:	f526                	sd	s1,168(sp)

  begin_op();
    80005188:	ca1fe0ef          	jal	80003e28 <begin_op>

  if(omode & O_CREATE){
    8000518c:	f4c42783          	lw	a5,-180(s0)
    80005190:	2007f793          	andi	a5,a5,512
    80005194:	c3d5                	beqz	a5,80005238 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005196:	4681                	li	a3,0
    80005198:	4601                	li	a2,0
    8000519a:	4589                	li	a1,2
    8000519c:	f5040513          	addi	a0,s0,-176
    800051a0:	aa9ff0ef          	jal	80004c48 <create>
    800051a4:	84aa                	mv	s1,a0
    if(ip == 0){
    800051a6:	c541                	beqz	a0,8000522e <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800051a8:	04449703          	lh	a4,68(s1)
    800051ac:	478d                	li	a5,3
    800051ae:	00f71763          	bne	a4,a5,800051bc <sys_open+0x5e>
    800051b2:	0464d703          	lhu	a4,70(s1)
    800051b6:	47a5                	li	a5,9
    800051b8:	0ae7ed63          	bltu	a5,a4,80005272 <sys_open+0x114>
    800051bc:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800051be:	fe1fe0ef          	jal	8000419e <filealloc>
    800051c2:	892a                	mv	s2,a0
    800051c4:	c179                	beqz	a0,8000528a <sys_open+0x12c>
    800051c6:	ed4e                	sd	s3,152(sp)
    800051c8:	a43ff0ef          	jal	80004c0a <fdalloc>
    800051cc:	89aa                	mv	s3,a0
    800051ce:	0a054a63          	bltz	a0,80005282 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800051d2:	04449703          	lh	a4,68(s1)
    800051d6:	478d                	li	a5,3
    800051d8:	0cf70263          	beq	a4,a5,8000529c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800051dc:	4789                	li	a5,2
    800051de:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800051e2:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800051e6:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800051ea:	f4c42783          	lw	a5,-180(s0)
    800051ee:	0017c713          	xori	a4,a5,1
    800051f2:	8b05                	andi	a4,a4,1
    800051f4:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800051f8:	0037f713          	andi	a4,a5,3
    800051fc:	00e03733          	snez	a4,a4
    80005200:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005204:	4007f793          	andi	a5,a5,1024
    80005208:	c791                	beqz	a5,80005214 <sys_open+0xb6>
    8000520a:	04449703          	lh	a4,68(s1)
    8000520e:	4789                	li	a5,2
    80005210:	08f70d63          	beq	a4,a5,800052aa <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005214:	8526                	mv	a0,s1
    80005216:	c2afe0ef          	jal	80003640 <iunlock>
  end_op();
    8000521a:	c79fe0ef          	jal	80003e92 <end_op>

  return fd;
    8000521e:	854e                	mv	a0,s3
    80005220:	74aa                	ld	s1,168(sp)
    80005222:	790a                	ld	s2,160(sp)
    80005224:	69ea                	ld	s3,152(sp)
}
    80005226:	70ea                	ld	ra,184(sp)
    80005228:	744a                	ld	s0,176(sp)
    8000522a:	6129                	addi	sp,sp,192
    8000522c:	8082                	ret
      end_op();
    8000522e:	c65fe0ef          	jal	80003e92 <end_op>
      return -1;
    80005232:	557d                	li	a0,-1
    80005234:	74aa                	ld	s1,168(sp)
    80005236:	bfc5                	j	80005226 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005238:	f5040513          	addi	a0,s0,-176
    8000523c:	a31fe0ef          	jal	80003c6c <namei>
    80005240:	84aa                	mv	s1,a0
    80005242:	c11d                	beqz	a0,80005268 <sys_open+0x10a>
    ilock(ip);
    80005244:	b4efe0ef          	jal	80003592 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005248:	04449703          	lh	a4,68(s1)
    8000524c:	4785                	li	a5,1
    8000524e:	f4f71de3          	bne	a4,a5,800051a8 <sys_open+0x4a>
    80005252:	f4c42783          	lw	a5,-180(s0)
    80005256:	d3bd                	beqz	a5,800051bc <sys_open+0x5e>
      iunlockput(ip);
    80005258:	8526                	mv	a0,s1
    8000525a:	d42fe0ef          	jal	8000379c <iunlockput>
      end_op();
    8000525e:	c35fe0ef          	jal	80003e92 <end_op>
      return -1;
    80005262:	557d                	li	a0,-1
    80005264:	74aa                	ld	s1,168(sp)
    80005266:	b7c1                	j	80005226 <sys_open+0xc8>
      end_op();
    80005268:	c2bfe0ef          	jal	80003e92 <end_op>
      return -1;
    8000526c:	557d                	li	a0,-1
    8000526e:	74aa                	ld	s1,168(sp)
    80005270:	bf5d                	j	80005226 <sys_open+0xc8>
    iunlockput(ip);
    80005272:	8526                	mv	a0,s1
    80005274:	d28fe0ef          	jal	8000379c <iunlockput>
    end_op();
    80005278:	c1bfe0ef          	jal	80003e92 <end_op>
    return -1;
    8000527c:	557d                	li	a0,-1
    8000527e:	74aa                	ld	s1,168(sp)
    80005280:	b75d                	j	80005226 <sys_open+0xc8>
      fileclose(f);
    80005282:	854a                	mv	a0,s2
    80005284:	fbffe0ef          	jal	80004242 <fileclose>
    80005288:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000528a:	8526                	mv	a0,s1
    8000528c:	d10fe0ef          	jal	8000379c <iunlockput>
    end_op();
    80005290:	c03fe0ef          	jal	80003e92 <end_op>
    return -1;
    80005294:	557d                	li	a0,-1
    80005296:	74aa                	ld	s1,168(sp)
    80005298:	790a                	ld	s2,160(sp)
    8000529a:	b771                	j	80005226 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000529c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800052a0:	04649783          	lh	a5,70(s1)
    800052a4:	02f91223          	sh	a5,36(s2)
    800052a8:	bf3d                	j	800051e6 <sys_open+0x88>
    itrunc(ip);
    800052aa:	8526                	mv	a0,s1
    800052ac:	bd4fe0ef          	jal	80003680 <itrunc>
    800052b0:	b795                	j	80005214 <sys_open+0xb6>

00000000800052b2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800052b2:	7175                	addi	sp,sp,-144
    800052b4:	e506                	sd	ra,136(sp)
    800052b6:	e122                	sd	s0,128(sp)
    800052b8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800052ba:	b6ffe0ef          	jal	80003e28 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800052be:	08000613          	li	a2,128
    800052c2:	f7040593          	addi	a1,s0,-144
    800052c6:	4501                	li	a0,0
    800052c8:	857fd0ef          	jal	80002b1e <argstr>
    800052cc:	02054363          	bltz	a0,800052f2 <sys_mkdir+0x40>
    800052d0:	4681                	li	a3,0
    800052d2:	4601                	li	a2,0
    800052d4:	4585                	li	a1,1
    800052d6:	f7040513          	addi	a0,s0,-144
    800052da:	96fff0ef          	jal	80004c48 <create>
    800052de:	c911                	beqz	a0,800052f2 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052e0:	cbcfe0ef          	jal	8000379c <iunlockput>
  end_op();
    800052e4:	baffe0ef          	jal	80003e92 <end_op>
  return 0;
    800052e8:	4501                	li	a0,0
}
    800052ea:	60aa                	ld	ra,136(sp)
    800052ec:	640a                	ld	s0,128(sp)
    800052ee:	6149                	addi	sp,sp,144
    800052f0:	8082                	ret
    end_op();
    800052f2:	ba1fe0ef          	jal	80003e92 <end_op>
    return -1;
    800052f6:	557d                	li	a0,-1
    800052f8:	bfcd                	j	800052ea <sys_mkdir+0x38>

00000000800052fa <sys_mknod>:

uint64
sys_mknod(void)
{
    800052fa:	7135                	addi	sp,sp,-160
    800052fc:	ed06                	sd	ra,152(sp)
    800052fe:	e922                	sd	s0,144(sp)
    80005300:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005302:	b27fe0ef          	jal	80003e28 <begin_op>
  argint(1, &major);
    80005306:	f6c40593          	addi	a1,s0,-148
    8000530a:	4505                	li	a0,1
    8000530c:	fdafd0ef          	jal	80002ae6 <argint>
  argint(2, &minor);
    80005310:	f6840593          	addi	a1,s0,-152
    80005314:	4509                	li	a0,2
    80005316:	fd0fd0ef          	jal	80002ae6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000531a:	08000613          	li	a2,128
    8000531e:	f7040593          	addi	a1,s0,-144
    80005322:	4501                	li	a0,0
    80005324:	ffafd0ef          	jal	80002b1e <argstr>
    80005328:	02054563          	bltz	a0,80005352 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000532c:	f6841683          	lh	a3,-152(s0)
    80005330:	f6c41603          	lh	a2,-148(s0)
    80005334:	458d                	li	a1,3
    80005336:	f7040513          	addi	a0,s0,-144
    8000533a:	90fff0ef          	jal	80004c48 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000533e:	c911                	beqz	a0,80005352 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005340:	c5cfe0ef          	jal	8000379c <iunlockput>
  end_op();
    80005344:	b4ffe0ef          	jal	80003e92 <end_op>
  return 0;
    80005348:	4501                	li	a0,0
}
    8000534a:	60ea                	ld	ra,152(sp)
    8000534c:	644a                	ld	s0,144(sp)
    8000534e:	610d                	addi	sp,sp,160
    80005350:	8082                	ret
    end_op();
    80005352:	b41fe0ef          	jal	80003e92 <end_op>
    return -1;
    80005356:	557d                	li	a0,-1
    80005358:	bfcd                	j	8000534a <sys_mknod+0x50>

000000008000535a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000535a:	7135                	addi	sp,sp,-160
    8000535c:	ed06                	sd	ra,152(sp)
    8000535e:	e922                	sd	s0,144(sp)
    80005360:	e14a                	sd	s2,128(sp)
    80005362:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005364:	d7cfc0ef          	jal	800018e0 <myproc>
    80005368:	892a                	mv	s2,a0
  
  begin_op();
    8000536a:	abffe0ef          	jal	80003e28 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000536e:	08000613          	li	a2,128
    80005372:	f6040593          	addi	a1,s0,-160
    80005376:	4501                	li	a0,0
    80005378:	fa6fd0ef          	jal	80002b1e <argstr>
    8000537c:	04054363          	bltz	a0,800053c2 <sys_chdir+0x68>
    80005380:	e526                	sd	s1,136(sp)
    80005382:	f6040513          	addi	a0,s0,-160
    80005386:	8e7fe0ef          	jal	80003c6c <namei>
    8000538a:	84aa                	mv	s1,a0
    8000538c:	c915                	beqz	a0,800053c0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000538e:	a04fe0ef          	jal	80003592 <ilock>
  if(ip->type != T_DIR){
    80005392:	04449703          	lh	a4,68(s1)
    80005396:	4785                	li	a5,1
    80005398:	02f71963          	bne	a4,a5,800053ca <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000539c:	8526                	mv	a0,s1
    8000539e:	aa2fe0ef          	jal	80003640 <iunlock>
  iput(p->cwd);
    800053a2:	15093503          	ld	a0,336(s2)
    800053a6:	b6efe0ef          	jal	80003714 <iput>
  end_op();
    800053aa:	ae9fe0ef          	jal	80003e92 <end_op>
  p->cwd = ip;
    800053ae:	14993823          	sd	s1,336(s2)
  return 0;
    800053b2:	4501                	li	a0,0
    800053b4:	64aa                	ld	s1,136(sp)
}
    800053b6:	60ea                	ld	ra,152(sp)
    800053b8:	644a                	ld	s0,144(sp)
    800053ba:	690a                	ld	s2,128(sp)
    800053bc:	610d                	addi	sp,sp,160
    800053be:	8082                	ret
    800053c0:	64aa                	ld	s1,136(sp)
    end_op();
    800053c2:	ad1fe0ef          	jal	80003e92 <end_op>
    return -1;
    800053c6:	557d                	li	a0,-1
    800053c8:	b7fd                	j	800053b6 <sys_chdir+0x5c>
    iunlockput(ip);
    800053ca:	8526                	mv	a0,s1
    800053cc:	bd0fe0ef          	jal	8000379c <iunlockput>
    end_op();
    800053d0:	ac3fe0ef          	jal	80003e92 <end_op>
    return -1;
    800053d4:	557d                	li	a0,-1
    800053d6:	64aa                	ld	s1,136(sp)
    800053d8:	bff9                	j	800053b6 <sys_chdir+0x5c>

00000000800053da <sys_exec>:

uint64
sys_exec(void)
{
    800053da:	7121                	addi	sp,sp,-448
    800053dc:	ff06                	sd	ra,440(sp)
    800053de:	fb22                	sd	s0,432(sp)
    800053e0:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800053e2:	e4840593          	addi	a1,s0,-440
    800053e6:	4505                	li	a0,1
    800053e8:	f1afd0ef          	jal	80002b02 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800053ec:	08000613          	li	a2,128
    800053f0:	f5040593          	addi	a1,s0,-176
    800053f4:	4501                	li	a0,0
    800053f6:	f28fd0ef          	jal	80002b1e <argstr>
    800053fa:	87aa                	mv	a5,a0
    return -1;
    800053fc:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800053fe:	0c07c463          	bltz	a5,800054c6 <sys_exec+0xec>
    80005402:	f726                	sd	s1,424(sp)
    80005404:	f34a                	sd	s2,416(sp)
    80005406:	ef4e                	sd	s3,408(sp)
    80005408:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000540a:	10000613          	li	a2,256
    8000540e:	4581                	li	a1,0
    80005410:	e5040513          	addi	a0,s0,-432
    80005414:	8b5fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005418:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000541c:	89a6                	mv	s3,s1
    8000541e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005420:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005424:	00391513          	slli	a0,s2,0x3
    80005428:	e4040593          	addi	a1,s0,-448
    8000542c:	e4843783          	ld	a5,-440(s0)
    80005430:	953e                	add	a0,a0,a5
    80005432:	e2afd0ef          	jal	80002a5c <fetchaddr>
    80005436:	02054663          	bltz	a0,80005462 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000543a:	e4043783          	ld	a5,-448(s0)
    8000543e:	c3a9                	beqz	a5,80005480 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005440:	ee4fb0ef          	jal	80000b24 <kalloc>
    80005444:	85aa                	mv	a1,a0
    80005446:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000544a:	cd01                	beqz	a0,80005462 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000544c:	6605                	lui	a2,0x1
    8000544e:	e4043503          	ld	a0,-448(s0)
    80005452:	e54fd0ef          	jal	80002aa6 <fetchstr>
    80005456:	00054663          	bltz	a0,80005462 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000545a:	0905                	addi	s2,s2,1
    8000545c:	09a1                	addi	s3,s3,8
    8000545e:	fd4913e3          	bne	s2,s4,80005424 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005462:	f5040913          	addi	s2,s0,-176
    80005466:	6088                	ld	a0,0(s1)
    80005468:	c931                	beqz	a0,800054bc <sys_exec+0xe2>
    kfree(argv[i]);
    8000546a:	dd8fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000546e:	04a1                	addi	s1,s1,8
    80005470:	ff249be3          	bne	s1,s2,80005466 <sys_exec+0x8c>
  return -1;
    80005474:	557d                	li	a0,-1
    80005476:	74ba                	ld	s1,424(sp)
    80005478:	791a                	ld	s2,416(sp)
    8000547a:	69fa                	ld	s3,408(sp)
    8000547c:	6a5a                	ld	s4,400(sp)
    8000547e:	a0a1                	j	800054c6 <sys_exec+0xec>
      argv[i] = 0;
    80005480:	0009079b          	sext.w	a5,s2
    80005484:	078e                	slli	a5,a5,0x3
    80005486:	fd078793          	addi	a5,a5,-48
    8000548a:	97a2                	add	a5,a5,s0
    8000548c:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005490:	e5040593          	addi	a1,s0,-432
    80005494:	f5040513          	addi	a0,s0,-176
    80005498:	ba8ff0ef          	jal	80004840 <exec>
    8000549c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000549e:	f5040993          	addi	s3,s0,-176
    800054a2:	6088                	ld	a0,0(s1)
    800054a4:	c511                	beqz	a0,800054b0 <sys_exec+0xd6>
    kfree(argv[i]);
    800054a6:	d9cfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054aa:	04a1                	addi	s1,s1,8
    800054ac:	ff349be3          	bne	s1,s3,800054a2 <sys_exec+0xc8>
  return ret;
    800054b0:	854a                	mv	a0,s2
    800054b2:	74ba                	ld	s1,424(sp)
    800054b4:	791a                	ld	s2,416(sp)
    800054b6:	69fa                	ld	s3,408(sp)
    800054b8:	6a5a                	ld	s4,400(sp)
    800054ba:	a031                	j	800054c6 <sys_exec+0xec>
  return -1;
    800054bc:	557d                	li	a0,-1
    800054be:	74ba                	ld	s1,424(sp)
    800054c0:	791a                	ld	s2,416(sp)
    800054c2:	69fa                	ld	s3,408(sp)
    800054c4:	6a5a                	ld	s4,400(sp)
}
    800054c6:	70fa                	ld	ra,440(sp)
    800054c8:	745a                	ld	s0,432(sp)
    800054ca:	6139                	addi	sp,sp,448
    800054cc:	8082                	ret

00000000800054ce <sys_pipe>:

uint64
sys_pipe(void)
{
    800054ce:	7139                	addi	sp,sp,-64
    800054d0:	fc06                	sd	ra,56(sp)
    800054d2:	f822                	sd	s0,48(sp)
    800054d4:	f426                	sd	s1,40(sp)
    800054d6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800054d8:	c08fc0ef          	jal	800018e0 <myproc>
    800054dc:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800054de:	fd840593          	addi	a1,s0,-40
    800054e2:	4501                	li	a0,0
    800054e4:	e1efd0ef          	jal	80002b02 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800054e8:	fc840593          	addi	a1,s0,-56
    800054ec:	fd040513          	addi	a0,s0,-48
    800054f0:	85cff0ef          	jal	8000454c <pipealloc>
    return -1;
    800054f4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800054f6:	0a054463          	bltz	a0,8000559e <sys_pipe+0xd0>
  fd0 = -1;
    800054fa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800054fe:	fd043503          	ld	a0,-48(s0)
    80005502:	f08ff0ef          	jal	80004c0a <fdalloc>
    80005506:	fca42223          	sw	a0,-60(s0)
    8000550a:	08054163          	bltz	a0,8000558c <sys_pipe+0xbe>
    8000550e:	fc843503          	ld	a0,-56(s0)
    80005512:	ef8ff0ef          	jal	80004c0a <fdalloc>
    80005516:	fca42023          	sw	a0,-64(s0)
    8000551a:	06054063          	bltz	a0,8000557a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000551e:	4691                	li	a3,4
    80005520:	fc440613          	addi	a2,s0,-60
    80005524:	fd843583          	ld	a1,-40(s0)
    80005528:	68a8                	ld	a0,80(s1)
    8000552a:	828fc0ef          	jal	80001552 <copyout>
    8000552e:	00054e63          	bltz	a0,8000554a <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005532:	4691                	li	a3,4
    80005534:	fc040613          	addi	a2,s0,-64
    80005538:	fd843583          	ld	a1,-40(s0)
    8000553c:	0591                	addi	a1,a1,4
    8000553e:	68a8                	ld	a0,80(s1)
    80005540:	812fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005544:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005546:	04055c63          	bgez	a0,8000559e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000554a:	fc442783          	lw	a5,-60(s0)
    8000554e:	07e9                	addi	a5,a5,26
    80005550:	078e                	slli	a5,a5,0x3
    80005552:	97a6                	add	a5,a5,s1
    80005554:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005558:	fc042783          	lw	a5,-64(s0)
    8000555c:	07e9                	addi	a5,a5,26
    8000555e:	078e                	slli	a5,a5,0x3
    80005560:	94be                	add	s1,s1,a5
    80005562:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005566:	fd043503          	ld	a0,-48(s0)
    8000556a:	cd9fe0ef          	jal	80004242 <fileclose>
    fileclose(wf);
    8000556e:	fc843503          	ld	a0,-56(s0)
    80005572:	cd1fe0ef          	jal	80004242 <fileclose>
    return -1;
    80005576:	57fd                	li	a5,-1
    80005578:	a01d                	j	8000559e <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000557a:	fc442783          	lw	a5,-60(s0)
    8000557e:	0007c763          	bltz	a5,8000558c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005582:	07e9                	addi	a5,a5,26
    80005584:	078e                	slli	a5,a5,0x3
    80005586:	97a6                	add	a5,a5,s1
    80005588:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000558c:	fd043503          	ld	a0,-48(s0)
    80005590:	cb3fe0ef          	jal	80004242 <fileclose>
    fileclose(wf);
    80005594:	fc843503          	ld	a0,-56(s0)
    80005598:	cabfe0ef          	jal	80004242 <fileclose>
    return -1;
    8000559c:	57fd                	li	a5,-1
}
    8000559e:	853e                	mv	a0,a5
    800055a0:	70e2                	ld	ra,56(sp)
    800055a2:	7442                	ld	s0,48(sp)
    800055a4:	74a2                	ld	s1,40(sp)
    800055a6:	6121                	addi	sp,sp,64
    800055a8:	8082                	ret
    800055aa:	0000                	unimp
    800055ac:	0000                	unimp
	...

00000000800055b0 <kernelvec>:
    800055b0:	7111                	addi	sp,sp,-256
    800055b2:	e006                	sd	ra,0(sp)
    800055b4:	e40a                	sd	sp,8(sp)
    800055b6:	e80e                	sd	gp,16(sp)
    800055b8:	ec12                	sd	tp,24(sp)
    800055ba:	f016                	sd	t0,32(sp)
    800055bc:	f41a                	sd	t1,40(sp)
    800055be:	f81e                	sd	t2,48(sp)
    800055c0:	e4aa                	sd	a0,72(sp)
    800055c2:	e8ae                	sd	a1,80(sp)
    800055c4:	ecb2                	sd	a2,88(sp)
    800055c6:	f0b6                	sd	a3,96(sp)
    800055c8:	f4ba                	sd	a4,104(sp)
    800055ca:	f8be                	sd	a5,112(sp)
    800055cc:	fcc2                	sd	a6,120(sp)
    800055ce:	e146                	sd	a7,128(sp)
    800055d0:	edf2                	sd	t3,216(sp)
    800055d2:	f1f6                	sd	t4,224(sp)
    800055d4:	f5fa                	sd	t5,232(sp)
    800055d6:	f9fe                	sd	t6,240(sp)
    800055d8:	b3cfd0ef          	jal	80002914 <kerneltrap>
    800055dc:	6082                	ld	ra,0(sp)
    800055de:	6122                	ld	sp,8(sp)
    800055e0:	61c2                	ld	gp,16(sp)
    800055e2:	7282                	ld	t0,32(sp)
    800055e4:	7322                	ld	t1,40(sp)
    800055e6:	73c2                	ld	t2,48(sp)
    800055e8:	6526                	ld	a0,72(sp)
    800055ea:	65c6                	ld	a1,80(sp)
    800055ec:	6666                	ld	a2,88(sp)
    800055ee:	7686                	ld	a3,96(sp)
    800055f0:	7726                	ld	a4,104(sp)
    800055f2:	77c6                	ld	a5,112(sp)
    800055f4:	7866                	ld	a6,120(sp)
    800055f6:	688a                	ld	a7,128(sp)
    800055f8:	6e6e                	ld	t3,216(sp)
    800055fa:	7e8e                	ld	t4,224(sp)
    800055fc:	7f2e                	ld	t5,232(sp)
    800055fe:	7fce                	ld	t6,240(sp)
    80005600:	6111                	addi	sp,sp,256
    80005602:	10200073          	sret
	...

000000008000560e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000560e:	1141                	addi	sp,sp,-16
    80005610:	e422                	sd	s0,8(sp)
    80005612:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005614:	0c0007b7          	lui	a5,0xc000
    80005618:	4705                	li	a4,1
    8000561a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000561c:	0c0007b7          	lui	a5,0xc000
    80005620:	c3d8                	sw	a4,4(a5)
}
    80005622:	6422                	ld	s0,8(sp)
    80005624:	0141                	addi	sp,sp,16
    80005626:	8082                	ret

0000000080005628 <plicinithart>:

void
plicinithart(void)
{
    80005628:	1141                	addi	sp,sp,-16
    8000562a:	e406                	sd	ra,8(sp)
    8000562c:	e022                	sd	s0,0(sp)
    8000562e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005630:	a84fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005634:	0085171b          	slliw	a4,a0,0x8
    80005638:	0c0027b7          	lui	a5,0xc002
    8000563c:	97ba                	add	a5,a5,a4
    8000563e:	40200713          	li	a4,1026
    80005642:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005646:	00d5151b          	slliw	a0,a0,0xd
    8000564a:	0c2017b7          	lui	a5,0xc201
    8000564e:	97aa                	add	a5,a5,a0
    80005650:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005654:	60a2                	ld	ra,8(sp)
    80005656:	6402                	ld	s0,0(sp)
    80005658:	0141                	addi	sp,sp,16
    8000565a:	8082                	ret

000000008000565c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000565c:	1141                	addi	sp,sp,-16
    8000565e:	e406                	sd	ra,8(sp)
    80005660:	e022                	sd	s0,0(sp)
    80005662:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005664:	a50fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005668:	00d5151b          	slliw	a0,a0,0xd
    8000566c:	0c2017b7          	lui	a5,0xc201
    80005670:	97aa                	add	a5,a5,a0
  return irq;
}
    80005672:	43c8                	lw	a0,4(a5)
    80005674:	60a2                	ld	ra,8(sp)
    80005676:	6402                	ld	s0,0(sp)
    80005678:	0141                	addi	sp,sp,16
    8000567a:	8082                	ret

000000008000567c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000567c:	1101                	addi	sp,sp,-32
    8000567e:	ec06                	sd	ra,24(sp)
    80005680:	e822                	sd	s0,16(sp)
    80005682:	e426                	sd	s1,8(sp)
    80005684:	1000                	addi	s0,sp,32
    80005686:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005688:	a2cfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000568c:	00d5151b          	slliw	a0,a0,0xd
    80005690:	0c2017b7          	lui	a5,0xc201
    80005694:	97aa                	add	a5,a5,a0
    80005696:	c3c4                	sw	s1,4(a5)
}
    80005698:	60e2                	ld	ra,24(sp)
    8000569a:	6442                	ld	s0,16(sp)
    8000569c:	64a2                	ld	s1,8(sp)
    8000569e:	6105                	addi	sp,sp,32
    800056a0:	8082                	ret

00000000800056a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800056a2:	1141                	addi	sp,sp,-16
    800056a4:	e406                	sd	ra,8(sp)
    800056a6:	e022                	sd	s0,0(sp)
    800056a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800056aa:	479d                	li	a5,7
    800056ac:	04a7ca63          	blt	a5,a0,80005700 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800056b0:	0001c797          	auipc	a5,0x1c
    800056b4:	88078793          	addi	a5,a5,-1920 # 80020f30 <disk>
    800056b8:	97aa                	add	a5,a5,a0
    800056ba:	0187c783          	lbu	a5,24(a5)
    800056be:	e7b9                	bnez	a5,8000570c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800056c0:	00451693          	slli	a3,a0,0x4
    800056c4:	0001c797          	auipc	a5,0x1c
    800056c8:	86c78793          	addi	a5,a5,-1940 # 80020f30 <disk>
    800056cc:	6398                	ld	a4,0(a5)
    800056ce:	9736                	add	a4,a4,a3
    800056d0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800056d4:	6398                	ld	a4,0(a5)
    800056d6:	9736                	add	a4,a4,a3
    800056d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800056dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800056e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800056e4:	97aa                	add	a5,a5,a0
    800056e6:	4705                	li	a4,1
    800056e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800056ec:	0001c517          	auipc	a0,0x1c
    800056f0:	85c50513          	addi	a0,a0,-1956 # 80020f48 <disk+0x18>
    800056f4:	a7ffc0ef          	jal	80002172 <wakeup>
}
    800056f8:	60a2                	ld	ra,8(sp)
    800056fa:	6402                	ld	s0,0(sp)
    800056fc:	0141                	addi	sp,sp,16
    800056fe:	8082                	ret
    panic("free_desc 1");
    80005700:	00002517          	auipc	a0,0x2
    80005704:	f7050513          	addi	a0,a0,-144 # 80007670 <etext+0x670>
    80005708:	88cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000570c:	00002517          	auipc	a0,0x2
    80005710:	f7450513          	addi	a0,a0,-140 # 80007680 <etext+0x680>
    80005714:	880fb0ef          	jal	80000794 <panic>

0000000080005718 <virtio_disk_init>:
{
    80005718:	1101                	addi	sp,sp,-32
    8000571a:	ec06                	sd	ra,24(sp)
    8000571c:	e822                	sd	s0,16(sp)
    8000571e:	e426                	sd	s1,8(sp)
    80005720:	e04a                	sd	s2,0(sp)
    80005722:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005724:	00002597          	auipc	a1,0x2
    80005728:	f6c58593          	addi	a1,a1,-148 # 80007690 <etext+0x690>
    8000572c:	0001c517          	auipc	a0,0x1c
    80005730:	92c50513          	addi	a0,a0,-1748 # 80021058 <disk+0x128>
    80005734:	c40fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005738:	100017b7          	lui	a5,0x10001
    8000573c:	4398                	lw	a4,0(a5)
    8000573e:	2701                	sext.w	a4,a4
    80005740:	747277b7          	lui	a5,0x74727
    80005744:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005748:	18f71063          	bne	a4,a5,800058c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000574c:	100017b7          	lui	a5,0x10001
    80005750:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005752:	439c                	lw	a5,0(a5)
    80005754:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005756:	4709                	li	a4,2
    80005758:	16e79863          	bne	a5,a4,800058c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000575c:	100017b7          	lui	a5,0x10001
    80005760:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005762:	439c                	lw	a5,0(a5)
    80005764:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005766:	16e79163          	bne	a5,a4,800058c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000576a:	100017b7          	lui	a5,0x10001
    8000576e:	47d8                	lw	a4,12(a5)
    80005770:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005772:	554d47b7          	lui	a5,0x554d4
    80005776:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000577a:	14f71763          	bne	a4,a5,800058c8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000577e:	100017b7          	lui	a5,0x10001
    80005782:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005786:	4705                	li	a4,1
    80005788:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000578a:	470d                	li	a4,3
    8000578c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000578e:	10001737          	lui	a4,0x10001
    80005792:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005794:	c7ffe737          	lui	a4,0xc7ffe
    80005798:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd6ef>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000579c:	8ef9                	and	a3,a3,a4
    8000579e:	10001737          	lui	a4,0x10001
    800057a2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057a4:	472d                	li	a4,11
    800057a6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057a8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800057ac:	439c                	lw	a5,0(a5)
    800057ae:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800057b2:	8ba1                	andi	a5,a5,8
    800057b4:	12078063          	beqz	a5,800058d4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800057b8:	100017b7          	lui	a5,0x10001
    800057bc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800057c0:	100017b7          	lui	a5,0x10001
    800057c4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800057c8:	439c                	lw	a5,0(a5)
    800057ca:	2781                	sext.w	a5,a5
    800057cc:	10079a63          	bnez	a5,800058e0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800057d0:	100017b7          	lui	a5,0x10001
    800057d4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800057d8:	439c                	lw	a5,0(a5)
    800057da:	2781                	sext.w	a5,a5
  if(max == 0)
    800057dc:	10078863          	beqz	a5,800058ec <virtio_disk_init+0x1d4>
  if(max < NUM)
    800057e0:	471d                	li	a4,7
    800057e2:	10f77b63          	bgeu	a4,a5,800058f8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800057e6:	b3efb0ef          	jal	80000b24 <kalloc>
    800057ea:	0001b497          	auipc	s1,0x1b
    800057ee:	74648493          	addi	s1,s1,1862 # 80020f30 <disk>
    800057f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800057f4:	b30fb0ef          	jal	80000b24 <kalloc>
    800057f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800057fa:	b2afb0ef          	jal	80000b24 <kalloc>
    800057fe:	87aa                	mv	a5,a0
    80005800:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005802:	6088                	ld	a0,0(s1)
    80005804:	10050063          	beqz	a0,80005904 <virtio_disk_init+0x1ec>
    80005808:	0001b717          	auipc	a4,0x1b
    8000580c:	73073703          	ld	a4,1840(a4) # 80020f38 <disk+0x8>
    80005810:	0e070a63          	beqz	a4,80005904 <virtio_disk_init+0x1ec>
    80005814:	0e078863          	beqz	a5,80005904 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005818:	6605                	lui	a2,0x1
    8000581a:	4581                	li	a1,0
    8000581c:	cacfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005820:	0001b497          	auipc	s1,0x1b
    80005824:	71048493          	addi	s1,s1,1808 # 80020f30 <disk>
    80005828:	6605                	lui	a2,0x1
    8000582a:	4581                	li	a1,0
    8000582c:	6488                	ld	a0,8(s1)
    8000582e:	c9afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005832:	6605                	lui	a2,0x1
    80005834:	4581                	li	a1,0
    80005836:	6888                	ld	a0,16(s1)
    80005838:	c90fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000583c:	100017b7          	lui	a5,0x10001
    80005840:	4721                	li	a4,8
    80005842:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005844:	4098                	lw	a4,0(s1)
    80005846:	100017b7          	lui	a5,0x10001
    8000584a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000584e:	40d8                	lw	a4,4(s1)
    80005850:	100017b7          	lui	a5,0x10001
    80005854:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005858:	649c                	ld	a5,8(s1)
    8000585a:	0007869b          	sext.w	a3,a5
    8000585e:	10001737          	lui	a4,0x10001
    80005862:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005866:	9781                	srai	a5,a5,0x20
    80005868:	10001737          	lui	a4,0x10001
    8000586c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005870:	689c                	ld	a5,16(s1)
    80005872:	0007869b          	sext.w	a3,a5
    80005876:	10001737          	lui	a4,0x10001
    8000587a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000587e:	9781                	srai	a5,a5,0x20
    80005880:	10001737          	lui	a4,0x10001
    80005884:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005888:	10001737          	lui	a4,0x10001
    8000588c:	4785                	li	a5,1
    8000588e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005890:	00f48c23          	sb	a5,24(s1)
    80005894:	00f48ca3          	sb	a5,25(s1)
    80005898:	00f48d23          	sb	a5,26(s1)
    8000589c:	00f48da3          	sb	a5,27(s1)
    800058a0:	00f48e23          	sb	a5,28(s1)
    800058a4:	00f48ea3          	sb	a5,29(s1)
    800058a8:	00f48f23          	sb	a5,30(s1)
    800058ac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058b4:	100017b7          	lui	a5,0x10001
    800058b8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800058bc:	60e2                	ld	ra,24(sp)
    800058be:	6442                	ld	s0,16(sp)
    800058c0:	64a2                	ld	s1,8(sp)
    800058c2:	6902                	ld	s2,0(sp)
    800058c4:	6105                	addi	sp,sp,32
    800058c6:	8082                	ret
    panic("could not find virtio disk");
    800058c8:	00002517          	auipc	a0,0x2
    800058cc:	dd850513          	addi	a0,a0,-552 # 800076a0 <etext+0x6a0>
    800058d0:	ec5fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    800058d4:	00002517          	auipc	a0,0x2
    800058d8:	dec50513          	addi	a0,a0,-532 # 800076c0 <etext+0x6c0>
    800058dc:	eb9fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800058e0:	00002517          	auipc	a0,0x2
    800058e4:	e0050513          	addi	a0,a0,-512 # 800076e0 <etext+0x6e0>
    800058e8:	eadfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800058ec:	00002517          	auipc	a0,0x2
    800058f0:	e1450513          	addi	a0,a0,-492 # 80007700 <etext+0x700>
    800058f4:	ea1fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800058f8:	00002517          	auipc	a0,0x2
    800058fc:	e2850513          	addi	a0,a0,-472 # 80007720 <etext+0x720>
    80005900:	e95fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005904:	00002517          	auipc	a0,0x2
    80005908:	e3c50513          	addi	a0,a0,-452 # 80007740 <etext+0x740>
    8000590c:	e89fa0ef          	jal	80000794 <panic>

0000000080005910 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005910:	7159                	addi	sp,sp,-112
    80005912:	f486                	sd	ra,104(sp)
    80005914:	f0a2                	sd	s0,96(sp)
    80005916:	eca6                	sd	s1,88(sp)
    80005918:	e8ca                	sd	s2,80(sp)
    8000591a:	e4ce                	sd	s3,72(sp)
    8000591c:	e0d2                	sd	s4,64(sp)
    8000591e:	fc56                	sd	s5,56(sp)
    80005920:	f85a                	sd	s6,48(sp)
    80005922:	f45e                	sd	s7,40(sp)
    80005924:	f062                	sd	s8,32(sp)
    80005926:	ec66                	sd	s9,24(sp)
    80005928:	1880                	addi	s0,sp,112
    8000592a:	8a2a                	mv	s4,a0
    8000592c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000592e:	00c52c83          	lw	s9,12(a0)
    80005932:	001c9c9b          	slliw	s9,s9,0x1
    80005936:	1c82                	slli	s9,s9,0x20
    80005938:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000593c:	0001b517          	auipc	a0,0x1b
    80005940:	71c50513          	addi	a0,a0,1820 # 80021058 <disk+0x128>
    80005944:	ab0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005948:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000594a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000594c:	0001bb17          	auipc	s6,0x1b
    80005950:	5e4b0b13          	addi	s6,s6,1508 # 80020f30 <disk>
  for(int i = 0; i < 3; i++){
    80005954:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005956:	0001bc17          	auipc	s8,0x1b
    8000595a:	702c0c13          	addi	s8,s8,1794 # 80021058 <disk+0x128>
    8000595e:	a8b9                	j	800059bc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005960:	00fb0733          	add	a4,s6,a5
    80005964:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005968:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000596a:	0207c563          	bltz	a5,80005994 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000596e:	2905                	addiw	s2,s2,1
    80005970:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005972:	05590963          	beq	s2,s5,800059c4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005976:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005978:	0001b717          	auipc	a4,0x1b
    8000597c:	5b870713          	addi	a4,a4,1464 # 80020f30 <disk>
    80005980:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005982:	01874683          	lbu	a3,24(a4)
    80005986:	fee9                	bnez	a3,80005960 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005988:	2785                	addiw	a5,a5,1
    8000598a:	0705                	addi	a4,a4,1
    8000598c:	fe979be3          	bne	a5,s1,80005982 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005990:	57fd                	li	a5,-1
    80005992:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005994:	01205d63          	blez	s2,800059ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005998:	f9042503          	lw	a0,-112(s0)
    8000599c:	d07ff0ef          	jal	800056a2 <free_desc>
      for(int j = 0; j < i; j++)
    800059a0:	4785                	li	a5,1
    800059a2:	0127d663          	bge	a5,s2,800059ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800059a6:	f9442503          	lw	a0,-108(s0)
    800059aa:	cf9ff0ef          	jal	800056a2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059ae:	85e2                	mv	a1,s8
    800059b0:	0001b517          	auipc	a0,0x1b
    800059b4:	59850513          	addi	a0,a0,1432 # 80020f48 <disk+0x18>
    800059b8:	f6efc0ef          	jal	80002126 <sleep>
  for(int i = 0; i < 3; i++){
    800059bc:	f9040613          	addi	a2,s0,-112
    800059c0:	894e                	mv	s2,s3
    800059c2:	bf55                	j	80005976 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059c4:	f9042503          	lw	a0,-112(s0)
    800059c8:	00451693          	slli	a3,a0,0x4

  if(write)
    800059cc:	0001b797          	auipc	a5,0x1b
    800059d0:	56478793          	addi	a5,a5,1380 # 80020f30 <disk>
    800059d4:	00a50713          	addi	a4,a0,10
    800059d8:	0712                	slli	a4,a4,0x4
    800059da:	973e                	add	a4,a4,a5
    800059dc:	01703633          	snez	a2,s7
    800059e0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800059e2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800059e6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800059ea:	6398                	ld	a4,0(a5)
    800059ec:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800059ee:	0a868613          	addi	a2,a3,168
    800059f2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800059f4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800059f6:	6390                	ld	a2,0(a5)
    800059f8:	00d605b3          	add	a1,a2,a3
    800059fc:	4741                	li	a4,16
    800059fe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a00:	4805                	li	a6,1
    80005a02:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005a06:	f9442703          	lw	a4,-108(s0)
    80005a0a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a0e:	0712                	slli	a4,a4,0x4
    80005a10:	963a                	add	a2,a2,a4
    80005a12:	058a0593          	addi	a1,s4,88
    80005a16:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a18:	0007b883          	ld	a7,0(a5)
    80005a1c:	9746                	add	a4,a4,a7
    80005a1e:	40000613          	li	a2,1024
    80005a22:	c710                	sw	a2,8(a4)
  if(write)
    80005a24:	001bb613          	seqz	a2,s7
    80005a28:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a2c:	00166613          	ori	a2,a2,1
    80005a30:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a34:	f9842583          	lw	a1,-104(s0)
    80005a38:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a3c:	00250613          	addi	a2,a0,2
    80005a40:	0612                	slli	a2,a2,0x4
    80005a42:	963e                	add	a2,a2,a5
    80005a44:	577d                	li	a4,-1
    80005a46:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005a4a:	0592                	slli	a1,a1,0x4
    80005a4c:	98ae                	add	a7,a7,a1
    80005a4e:	03068713          	addi	a4,a3,48
    80005a52:	973e                	add	a4,a4,a5
    80005a54:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a58:	6398                	ld	a4,0(a5)
    80005a5a:	972e                	add	a4,a4,a1
    80005a5c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005a60:	4689                	li	a3,2
    80005a62:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005a66:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005a6a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005a6e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a72:	6794                	ld	a3,8(a5)
    80005a74:	0026d703          	lhu	a4,2(a3)
    80005a78:	8b1d                	andi	a4,a4,7
    80005a7a:	0706                	slli	a4,a4,0x1
    80005a7c:	96ba                	add	a3,a3,a4
    80005a7e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005a82:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a86:	6798                	ld	a4,8(a5)
    80005a88:	00275783          	lhu	a5,2(a4)
    80005a8c:	2785                	addiw	a5,a5,1
    80005a8e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005a92:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a96:	100017b7          	lui	a5,0x10001
    80005a9a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005a9e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005aa2:	0001b917          	auipc	s2,0x1b
    80005aa6:	5b690913          	addi	s2,s2,1462 # 80021058 <disk+0x128>
  while(b->disk == 1) {
    80005aaa:	4485                	li	s1,1
    80005aac:	01079a63          	bne	a5,a6,80005ac0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005ab0:	85ca                	mv	a1,s2
    80005ab2:	8552                	mv	a0,s4
    80005ab4:	e72fc0ef          	jal	80002126 <sleep>
  while(b->disk == 1) {
    80005ab8:	004a2783          	lw	a5,4(s4)
    80005abc:	fe978ae3          	beq	a5,s1,80005ab0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005ac0:	f9042903          	lw	s2,-112(s0)
    80005ac4:	00290713          	addi	a4,s2,2
    80005ac8:	0712                	slli	a4,a4,0x4
    80005aca:	0001b797          	auipc	a5,0x1b
    80005ace:	46678793          	addi	a5,a5,1126 # 80020f30 <disk>
    80005ad2:	97ba                	add	a5,a5,a4
    80005ad4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005ad8:	0001b997          	auipc	s3,0x1b
    80005adc:	45898993          	addi	s3,s3,1112 # 80020f30 <disk>
    80005ae0:	00491713          	slli	a4,s2,0x4
    80005ae4:	0009b783          	ld	a5,0(s3)
    80005ae8:	97ba                	add	a5,a5,a4
    80005aea:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005aee:	854a                	mv	a0,s2
    80005af0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005af4:	bafff0ef          	jal	800056a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005af8:	8885                	andi	s1,s1,1
    80005afa:	f0fd                	bnez	s1,80005ae0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005afc:	0001b517          	auipc	a0,0x1b
    80005b00:	55c50513          	addi	a0,a0,1372 # 80021058 <disk+0x128>
    80005b04:	988fb0ef          	jal	80000c8c <release>
}
    80005b08:	70a6                	ld	ra,104(sp)
    80005b0a:	7406                	ld	s0,96(sp)
    80005b0c:	64e6                	ld	s1,88(sp)
    80005b0e:	6946                	ld	s2,80(sp)
    80005b10:	69a6                	ld	s3,72(sp)
    80005b12:	6a06                	ld	s4,64(sp)
    80005b14:	7ae2                	ld	s5,56(sp)
    80005b16:	7b42                	ld	s6,48(sp)
    80005b18:	7ba2                	ld	s7,40(sp)
    80005b1a:	7c02                	ld	s8,32(sp)
    80005b1c:	6ce2                	ld	s9,24(sp)
    80005b1e:	6165                	addi	sp,sp,112
    80005b20:	8082                	ret

0000000080005b22 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b22:	1101                	addi	sp,sp,-32
    80005b24:	ec06                	sd	ra,24(sp)
    80005b26:	e822                	sd	s0,16(sp)
    80005b28:	e426                	sd	s1,8(sp)
    80005b2a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b2c:	0001b497          	auipc	s1,0x1b
    80005b30:	40448493          	addi	s1,s1,1028 # 80020f30 <disk>
    80005b34:	0001b517          	auipc	a0,0x1b
    80005b38:	52450513          	addi	a0,a0,1316 # 80021058 <disk+0x128>
    80005b3c:	8b8fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b40:	100017b7          	lui	a5,0x10001
    80005b44:	53b8                	lw	a4,96(a5)
    80005b46:	8b0d                	andi	a4,a4,3
    80005b48:	100017b7          	lui	a5,0x10001
    80005b4c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005b4e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005b52:	689c                	ld	a5,16(s1)
    80005b54:	0204d703          	lhu	a4,32(s1)
    80005b58:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b5c:	04f70663          	beq	a4,a5,80005ba8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005b60:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b64:	6898                	ld	a4,16(s1)
    80005b66:	0204d783          	lhu	a5,32(s1)
    80005b6a:	8b9d                	andi	a5,a5,7
    80005b6c:	078e                	slli	a5,a5,0x3
    80005b6e:	97ba                	add	a5,a5,a4
    80005b70:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005b72:	00278713          	addi	a4,a5,2
    80005b76:	0712                	slli	a4,a4,0x4
    80005b78:	9726                	add	a4,a4,s1
    80005b7a:	01074703          	lbu	a4,16(a4)
    80005b7e:	e321                	bnez	a4,80005bbe <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005b80:	0789                	addi	a5,a5,2
    80005b82:	0792                	slli	a5,a5,0x4
    80005b84:	97a6                	add	a5,a5,s1
    80005b86:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005b88:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b8c:	de6fc0ef          	jal	80002172 <wakeup>

    disk.used_idx += 1;
    80005b90:	0204d783          	lhu	a5,32(s1)
    80005b94:	2785                	addiw	a5,a5,1
    80005b96:	17c2                	slli	a5,a5,0x30
    80005b98:	93c1                	srli	a5,a5,0x30
    80005b9a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005b9e:	6898                	ld	a4,16(s1)
    80005ba0:	00275703          	lhu	a4,2(a4)
    80005ba4:	faf71ee3          	bne	a4,a5,80005b60 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005ba8:	0001b517          	auipc	a0,0x1b
    80005bac:	4b050513          	addi	a0,a0,1200 # 80021058 <disk+0x128>
    80005bb0:	8dcfb0ef          	jal	80000c8c <release>
}
    80005bb4:	60e2                	ld	ra,24(sp)
    80005bb6:	6442                	ld	s0,16(sp)
    80005bb8:	64a2                	ld	s1,8(sp)
    80005bba:	6105                	addi	sp,sp,32
    80005bbc:	8082                	ret
      panic("virtio_disk_intr status");
    80005bbe:	00002517          	auipc	a0,0x2
    80005bc2:	b9a50513          	addi	a0,a0,-1126 # 80007758 <etext+0x758>
    80005bc6:	bcffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
