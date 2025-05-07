
user/_test_fcfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

#define NUM_CHILDREN 4

int main() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  int pid;
  fprintf(2, "=== FCFS Scheduler Test ===\n");
   a:	00001597          	auipc	a1,0x1
   e:	8a658593          	addi	a1,a1,-1882 # 8b0 <malloc+0x102>
  12:	4509                	li	a0,2
  14:	6bc000ef          	jal	6d0 <fprintf>
  18:	4491                	li	s1,4

  for (int i = 0; i < NUM_CHILDREN; i++) {
    pid = fork();
  1a:	298000ef          	jal	2b2 <fork>
    if (pid == 0) {
  1e:	cd01                	beqz	a0,36 <main+0x36>
  for (int i = 0; i < NUM_CHILDREN; i++) {
  20:	34fd                	addiw	s1,s1,-1
  22:	fce5                	bnez	s1,1a <main+0x1a>
      int pid_child = getpid();
      fprintf(1, "process %d finished\n", pid_child);
      exit(0);
    }
  }
  while (wait(0) != -1);
  24:	54fd                	li	s1,-1
  26:	4501                	li	a0,0
  28:	29a000ef          	jal	2c2 <wait>
  2c:	fe951de3          	bne	a0,s1,26 <main+0x26>

  exit(0);
  30:	4501                	li	a0,0
  32:	288000ef          	jal	2ba <exit>
      int pid_child = getpid();
  36:	304000ef          	jal	33a <getpid>
  3a:	862a                	mv	a2,a0
      fprintf(1, "process %d finished\n", pid_child);
  3c:	00001597          	auipc	a1,0x1
  40:	89458593          	addi	a1,a1,-1900 # 8d0 <malloc+0x122>
  44:	4505                	li	a0,1
  46:	68a000ef          	jal	6d0 <fprintf>
      exit(0);
  4a:	4501                	li	a0,0
  4c:	26e000ef          	jal	2ba <exit>

0000000000000050 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  extern int main();
  main();
  58:	fa9ff0ef          	jal	0 <main>
  exit(0);
  5c:	4501                	li	a0,0
  5e:	25c000ef          	jal	2ba <exit>

0000000000000062 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  62:	1141                	addi	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  68:	87aa                	mv	a5,a0
  6a:	0585                	addi	a1,a1,1
  6c:	0785                	addi	a5,a5,1
  6e:	fff5c703          	lbu	a4,-1(a1)
  72:	fee78fa3          	sb	a4,-1(a5)
  76:	fb75                	bnez	a4,6a <strcpy+0x8>
    ;
  return os;
}
  78:	6422                	ld	s0,8(sp)
  7a:	0141                	addi	sp,sp,16
  7c:	8082                	ret

000000000000007e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  84:	00054783          	lbu	a5,0(a0)
  88:	cb91                	beqz	a5,9c <strcmp+0x1e>
  8a:	0005c703          	lbu	a4,0(a1)
  8e:	00f71763          	bne	a4,a5,9c <strcmp+0x1e>
    p++, q++;
  92:	0505                	addi	a0,a0,1
  94:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  96:	00054783          	lbu	a5,0(a0)
  9a:	fbe5                	bnez	a5,8a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9c:	0005c503          	lbu	a0,0(a1)
}
  a0:	40a7853b          	subw	a0,a5,a0
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	addi	sp,sp,16
  a8:	8082                	ret

00000000000000aa <strlen>:

uint
strlen(const char *s)
{
  aa:	1141                	addi	sp,sp,-16
  ac:	e422                	sd	s0,8(sp)
  ae:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b0:	00054783          	lbu	a5,0(a0)
  b4:	cf91                	beqz	a5,d0 <strlen+0x26>
  b6:	0505                	addi	a0,a0,1
  b8:	87aa                	mv	a5,a0
  ba:	86be                	mv	a3,a5
  bc:	0785                	addi	a5,a5,1
  be:	fff7c703          	lbu	a4,-1(a5)
  c2:	ff65                	bnez	a4,ba <strlen+0x10>
  c4:	40a6853b          	subw	a0,a3,a0
  c8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret
  for(n = 0; s[n]; n++)
  d0:	4501                	li	a0,0
  d2:	bfe5                	j	ca <strlen+0x20>

00000000000000d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  da:	ca19                	beqz	a2,f0 <memset+0x1c>
  dc:	87aa                	mv	a5,a0
  de:	1602                	slli	a2,a2,0x20
  e0:	9201                	srli	a2,a2,0x20
  e2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ea:	0785                	addi	a5,a5,1
  ec:	fee79de3          	bne	a5,a4,e6 <memset+0x12>
  }
  return dst;
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret

00000000000000f6 <strchr>:

char*
strchr(const char *s, char c)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fc:	00054783          	lbu	a5,0(a0)
 100:	cb99                	beqz	a5,116 <strchr+0x20>
    if(*s == c)
 102:	00f58763          	beq	a1,a5,110 <strchr+0x1a>
  for(; *s; s++)
 106:	0505                	addi	a0,a0,1
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbfd                	bnez	a5,102 <strchr+0xc>
      return (char*)s;
  return 0;
 10e:	4501                	li	a0,0
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret
  return 0;
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strchr+0x1a>

000000000000011a <gets>:

char*
gets(char *buf, int max)
{
 11a:	711d                	addi	sp,sp,-96
 11c:	ec86                	sd	ra,88(sp)
 11e:	e8a2                	sd	s0,80(sp)
 120:	e4a6                	sd	s1,72(sp)
 122:	e0ca                	sd	s2,64(sp)
 124:	fc4e                	sd	s3,56(sp)
 126:	f852                	sd	s4,48(sp)
 128:	f456                	sd	s5,40(sp)
 12a:	f05a                	sd	s6,32(sp)
 12c:	ec5e                	sd	s7,24(sp)
 12e:	1080                	addi	s0,sp,96
 130:	8baa                	mv	s7,a0
 132:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 134:	892a                	mv	s2,a0
 136:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 138:	4aa9                	li	s5,10
 13a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13c:	89a6                	mv	s3,s1
 13e:	2485                	addiw	s1,s1,1
 140:	0344d663          	bge	s1,s4,16c <gets+0x52>
    cc = read(0, &c, 1);
 144:	4605                	li	a2,1
 146:	faf40593          	addi	a1,s0,-81
 14a:	4501                	li	a0,0
 14c:	186000ef          	jal	2d2 <read>
    if(cc < 1)
 150:	00a05e63          	blez	a0,16c <gets+0x52>
    buf[i++] = c;
 154:	faf44783          	lbu	a5,-81(s0)
 158:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15c:	01578763          	beq	a5,s5,16a <gets+0x50>
 160:	0905                	addi	s2,s2,1
 162:	fd679de3          	bne	a5,s6,13c <gets+0x22>
    buf[i++] = c;
 166:	89a6                	mv	s3,s1
 168:	a011                	j	16c <gets+0x52>
 16a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16c:	99de                	add	s3,s3,s7
 16e:	00098023          	sb	zero,0(s3)
  return buf;
}
 172:	855e                	mv	a0,s7
 174:	60e6                	ld	ra,88(sp)
 176:	6446                	ld	s0,80(sp)
 178:	64a6                	ld	s1,72(sp)
 17a:	6906                	ld	s2,64(sp)
 17c:	79e2                	ld	s3,56(sp)
 17e:	7a42                	ld	s4,48(sp)
 180:	7aa2                	ld	s5,40(sp)
 182:	7b02                	ld	s6,32(sp)
 184:	6be2                	ld	s7,24(sp)
 186:	6125                	addi	sp,sp,96
 188:	8082                	ret

000000000000018a <stat>:

int
stat(const char *n, struct stat *st)
{
 18a:	1101                	addi	sp,sp,-32
 18c:	ec06                	sd	ra,24(sp)
 18e:	e822                	sd	s0,16(sp)
 190:	e04a                	sd	s2,0(sp)
 192:	1000                	addi	s0,sp,32
 194:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 196:	4581                	li	a1,0
 198:	162000ef          	jal	2fa <open>
  if(fd < 0)
 19c:	02054263          	bltz	a0,1c0 <stat+0x36>
 1a0:	e426                	sd	s1,8(sp)
 1a2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a4:	85ca                	mv	a1,s2
 1a6:	16c000ef          	jal	312 <fstat>
 1aa:	892a                	mv	s2,a0
  close(fd);
 1ac:	8526                	mv	a0,s1
 1ae:	134000ef          	jal	2e2 <close>
  return r;
 1b2:	64a2                	ld	s1,8(sp)
}
 1b4:	854a                	mv	a0,s2
 1b6:	60e2                	ld	ra,24(sp)
 1b8:	6442                	ld	s0,16(sp)
 1ba:	6902                	ld	s2,0(sp)
 1bc:	6105                	addi	sp,sp,32
 1be:	8082                	ret
    return -1;
 1c0:	597d                	li	s2,-1
 1c2:	bfcd                	j	1b4 <stat+0x2a>

00000000000001c4 <atoi>:

int
atoi(const char *s)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e422                	sd	s0,8(sp)
 1c8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ca:	00054683          	lbu	a3,0(a0)
 1ce:	fd06879b          	addiw	a5,a3,-48
 1d2:	0ff7f793          	zext.b	a5,a5
 1d6:	4625                	li	a2,9
 1d8:	02f66863          	bltu	a2,a5,208 <atoi+0x44>
 1dc:	872a                	mv	a4,a0
  n = 0;
 1de:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1e0:	0705                	addi	a4,a4,1
 1e2:	0025179b          	slliw	a5,a0,0x2
 1e6:	9fa9                	addw	a5,a5,a0
 1e8:	0017979b          	slliw	a5,a5,0x1
 1ec:	9fb5                	addw	a5,a5,a3
 1ee:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f2:	00074683          	lbu	a3,0(a4)
 1f6:	fd06879b          	addiw	a5,a3,-48
 1fa:	0ff7f793          	zext.b	a5,a5
 1fe:	fef671e3          	bgeu	a2,a5,1e0 <atoi+0x1c>
  return n;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
  n = 0;
 208:	4501                	li	a0,0
 20a:	bfe5                	j	202 <atoi+0x3e>

000000000000020c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 212:	02b57463          	bgeu	a0,a1,23a <memmove+0x2e>
    while(n-- > 0)
 216:	00c05f63          	blez	a2,234 <memmove+0x28>
 21a:	1602                	slli	a2,a2,0x20
 21c:	9201                	srli	a2,a2,0x20
 21e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 222:	872a                	mv	a4,a0
      *dst++ = *src++;
 224:	0585                	addi	a1,a1,1
 226:	0705                	addi	a4,a4,1
 228:	fff5c683          	lbu	a3,-1(a1)
 22c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 230:	fef71ae3          	bne	a4,a5,224 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
    dst += n;
 23a:	00c50733          	add	a4,a0,a2
    src += n;
 23e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 240:	fec05ae3          	blez	a2,234 <memmove+0x28>
 244:	fff6079b          	addiw	a5,a2,-1
 248:	1782                	slli	a5,a5,0x20
 24a:	9381                	srli	a5,a5,0x20
 24c:	fff7c793          	not	a5,a5
 250:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 252:	15fd                	addi	a1,a1,-1
 254:	177d                	addi	a4,a4,-1
 256:	0005c683          	lbu	a3,0(a1)
 25a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25e:	fee79ae3          	bne	a5,a4,252 <memmove+0x46>
 262:	bfc9                	j	234 <memmove+0x28>

0000000000000264 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26a:	ca05                	beqz	a2,29a <memcmp+0x36>
 26c:	fff6069b          	addiw	a3,a2,-1
 270:	1682                	slli	a3,a3,0x20
 272:	9281                	srli	a3,a3,0x20
 274:	0685                	addi	a3,a3,1
 276:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 278:	00054783          	lbu	a5,0(a0)
 27c:	0005c703          	lbu	a4,0(a1)
 280:	00e79863          	bne	a5,a4,290 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 284:	0505                	addi	a0,a0,1
    p2++;
 286:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 288:	fed518e3          	bne	a0,a3,278 <memcmp+0x14>
  }
  return 0;
 28c:	4501                	li	a0,0
 28e:	a019                	j	294 <memcmp+0x30>
      return *p1 - *p2;
 290:	40e7853b          	subw	a0,a5,a4
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  return 0;
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <memcmp+0x30>

000000000000029e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a6:	f67ff0ef          	jal	20c <memmove>
}
 2aa:	60a2                	ld	ra,8(sp)
 2ac:	6402                	ld	s0,0(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret

00000000000002b2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2b2:	4885                	li	a7,1
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ba:	4889                	li	a7,2
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2c2:	488d                	li	a7,3
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ca:	4891                	li	a7,4
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <read>:
.global read
read:
 li a7, SYS_read
 2d2:	4895                	li	a7,5
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <write>:
.global write
write:
 li a7, SYS_write
 2da:	48c1                	li	a7,16
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <close>:
.global close
close:
 li a7, SYS_close
 2e2:	48d5                	li	a7,21
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ea:	4899                	li	a7,6
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2f2:	489d                	li	a7,7
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <open>:
.global open
open:
 li a7, SYS_open
 2fa:	48bd                	li	a7,15
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 302:	48c5                	li	a7,17
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 30a:	48c9                	li	a7,18
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 312:	48a1                	li	a7,8
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <link>:
.global link
link:
 li a7, SYS_link
 31a:	48cd                	li	a7,19
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 322:	48d1                	li	a7,20
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 32a:	48a5                	li	a7,9
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <dup>:
.global dup
dup:
 li a7, SYS_dup
 332:	48a9                	li	a7,10
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 33a:	48ad                	li	a7,11
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 342:	48b1                	li	a7,12
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 34a:	48b5                	li	a7,13
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 352:	48b9                	li	a7,14
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 35a:	48d9                	li	a7,22
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <getlev>:
.global getlev
getlev:
 li a7, SYS_getlev
 362:	48e1                	li	a7,24
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <yield>:
.global yield
yield:
 li a7, SYS_yield
 36a:	48dd                	li	a7,23
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <mlfqmode>:
.global mlfqmode
mlfqmode:
 li a7, SYS_mlfqmode
 372:	48e5                	li	a7,25
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <fcfsmode>:
.global fcfsmode
fcfsmode:
 li a7, SYS_fcfsmode
 37a:	48e9                	li	a7,26
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	1000                	addi	s0,sp,32
 38a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38e:	4605                	li	a2,1
 390:	fef40593          	addi	a1,s0,-17
 394:	f47ff0ef          	jal	2da <write>
}
 398:	60e2                	ld	ra,24(sp)
 39a:	6442                	ld	s0,16(sp)
 39c:	6105                	addi	sp,sp,32
 39e:	8082                	ret

00000000000003a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a0:	7139                	addi	sp,sp,-64
 3a2:	fc06                	sd	ra,56(sp)
 3a4:	f822                	sd	s0,48(sp)
 3a6:	f426                	sd	s1,40(sp)
 3a8:	0080                	addi	s0,sp,64
 3aa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ac:	c299                	beqz	a3,3b2 <printint+0x12>
 3ae:	0805c963          	bltz	a1,440 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3b2:	2581                	sext.w	a1,a1
  neg = 0;
 3b4:	4881                	li	a7,0
 3b6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3bc:	2601                	sext.w	a2,a2
 3be:	00000517          	auipc	a0,0x0
 3c2:	53250513          	addi	a0,a0,1330 # 8f0 <digits>
 3c6:	883a                	mv	a6,a4
 3c8:	2705                	addiw	a4,a4,1
 3ca:	02c5f7bb          	remuw	a5,a1,a2
 3ce:	1782                	slli	a5,a5,0x20
 3d0:	9381                	srli	a5,a5,0x20
 3d2:	97aa                	add	a5,a5,a0
 3d4:	0007c783          	lbu	a5,0(a5)
 3d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3dc:	0005879b          	sext.w	a5,a1
 3e0:	02c5d5bb          	divuw	a1,a1,a2
 3e4:	0685                	addi	a3,a3,1
 3e6:	fec7f0e3          	bgeu	a5,a2,3c6 <printint+0x26>
  if(neg)
 3ea:	00088c63          	beqz	a7,402 <printint+0x62>
    buf[i++] = '-';
 3ee:	fd070793          	addi	a5,a4,-48
 3f2:	00878733          	add	a4,a5,s0
 3f6:	02d00793          	li	a5,45
 3fa:	fef70823          	sb	a5,-16(a4)
 3fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 402:	02e05a63          	blez	a4,436 <printint+0x96>
 406:	f04a                	sd	s2,32(sp)
 408:	ec4e                	sd	s3,24(sp)
 40a:	fc040793          	addi	a5,s0,-64
 40e:	00e78933          	add	s2,a5,a4
 412:	fff78993          	addi	s3,a5,-1
 416:	99ba                	add	s3,s3,a4
 418:	377d                	addiw	a4,a4,-1
 41a:	1702                	slli	a4,a4,0x20
 41c:	9301                	srli	a4,a4,0x20
 41e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 422:	fff94583          	lbu	a1,-1(s2)
 426:	8526                	mv	a0,s1
 428:	f5bff0ef          	jal	382 <putc>
  while(--i >= 0)
 42c:	197d                	addi	s2,s2,-1
 42e:	ff391ae3          	bne	s2,s3,422 <printint+0x82>
 432:	7902                	ld	s2,32(sp)
 434:	69e2                	ld	s3,24(sp)
}
 436:	70e2                	ld	ra,56(sp)
 438:	7442                	ld	s0,48(sp)
 43a:	74a2                	ld	s1,40(sp)
 43c:	6121                	addi	sp,sp,64
 43e:	8082                	ret
    x = -xx;
 440:	40b005bb          	negw	a1,a1
    neg = 1;
 444:	4885                	li	a7,1
    x = -xx;
 446:	bf85                	j	3b6 <printint+0x16>

0000000000000448 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 448:	711d                	addi	sp,sp,-96
 44a:	ec86                	sd	ra,88(sp)
 44c:	e8a2                	sd	s0,80(sp)
 44e:	e0ca                	sd	s2,64(sp)
 450:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 452:	0005c903          	lbu	s2,0(a1)
 456:	26090863          	beqz	s2,6c6 <vprintf+0x27e>
 45a:	e4a6                	sd	s1,72(sp)
 45c:	fc4e                	sd	s3,56(sp)
 45e:	f852                	sd	s4,48(sp)
 460:	f456                	sd	s5,40(sp)
 462:	f05a                	sd	s6,32(sp)
 464:	ec5e                	sd	s7,24(sp)
 466:	e862                	sd	s8,16(sp)
 468:	e466                	sd	s9,8(sp)
 46a:	8b2a                	mv	s6,a0
 46c:	8a2e                	mv	s4,a1
 46e:	8bb2                	mv	s7,a2
  state = 0;
 470:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 472:	4481                	li	s1,0
 474:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 476:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 47a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 47e:	06c00c93          	li	s9,108
 482:	a005                	j	4a2 <vprintf+0x5a>
        putc(fd, c0);
 484:	85ca                	mv	a1,s2
 486:	855a                	mv	a0,s6
 488:	efbff0ef          	jal	382 <putc>
 48c:	a019                	j	492 <vprintf+0x4a>
    } else if(state == '%'){
 48e:	03598263          	beq	s3,s5,4b2 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 492:	2485                	addiw	s1,s1,1
 494:	8726                	mv	a4,s1
 496:	009a07b3          	add	a5,s4,s1
 49a:	0007c903          	lbu	s2,0(a5)
 49e:	20090c63          	beqz	s2,6b6 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 4a2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4a6:	fe0994e3          	bnez	s3,48e <vprintf+0x46>
      if(c0 == '%'){
 4aa:	fd579de3          	bne	a5,s5,484 <vprintf+0x3c>
        state = '%';
 4ae:	89be                	mv	s3,a5
 4b0:	b7cd                	j	492 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4b2:	00ea06b3          	add	a3,s4,a4
 4b6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4ba:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4bc:	c681                	beqz	a3,4c4 <vprintf+0x7c>
 4be:	9752                	add	a4,a4,s4
 4c0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4c4:	03878f63          	beq	a5,s8,502 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 4c8:	05978963          	beq	a5,s9,51a <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4cc:	07500713          	li	a4,117
 4d0:	0ee78363          	beq	a5,a4,5b6 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4d4:	07800713          	li	a4,120
 4d8:	12e78563          	beq	a5,a4,602 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4dc:	07000713          	li	a4,112
 4e0:	14e78a63          	beq	a5,a4,634 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4e4:	07300713          	li	a4,115
 4e8:	18e78a63          	beq	a5,a4,67c <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4ec:	02500713          	li	a4,37
 4f0:	04e79563          	bne	a5,a4,53a <vprintf+0xf2>
        putc(fd, '%');
 4f4:	02500593          	li	a1,37
 4f8:	855a                	mv	a0,s6
 4fa:	e89ff0ef          	jal	382 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4fe:	4981                	li	s3,0
 500:	bf49                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 502:	008b8913          	addi	s2,s7,8
 506:	4685                	li	a3,1
 508:	4629                	li	a2,10
 50a:	000ba583          	lw	a1,0(s7)
 50e:	855a                	mv	a0,s6
 510:	e91ff0ef          	jal	3a0 <printint>
 514:	8bca                	mv	s7,s2
      state = 0;
 516:	4981                	li	s3,0
 518:	bfad                	j	492 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 51a:	06400793          	li	a5,100
 51e:	02f68963          	beq	a3,a5,550 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 522:	06c00793          	li	a5,108
 526:	04f68263          	beq	a3,a5,56a <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 52a:	07500793          	li	a5,117
 52e:	0af68063          	beq	a3,a5,5ce <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 532:	07800793          	li	a5,120
 536:	0ef68263          	beq	a3,a5,61a <vprintf+0x1d2>
        putc(fd, '%');
 53a:	02500593          	li	a1,37
 53e:	855a                	mv	a0,s6
 540:	e43ff0ef          	jal	382 <putc>
        putc(fd, c0);
 544:	85ca                	mv	a1,s2
 546:	855a                	mv	a0,s6
 548:	e3bff0ef          	jal	382 <putc>
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b791                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 550:	008b8913          	addi	s2,s7,8
 554:	4685                	li	a3,1
 556:	4629                	li	a2,10
 558:	000ba583          	lw	a1,0(s7)
 55c:	855a                	mv	a0,s6
 55e:	e43ff0ef          	jal	3a0 <printint>
        i += 1;
 562:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 564:	8bca                	mv	s7,s2
      state = 0;
 566:	4981                	li	s3,0
        i += 1;
 568:	b72d                	j	492 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 56a:	06400793          	li	a5,100
 56e:	02f60763          	beq	a2,a5,59c <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 572:	07500793          	li	a5,117
 576:	06f60963          	beq	a2,a5,5e8 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 57a:	07800793          	li	a5,120
 57e:	faf61ee3          	bne	a2,a5,53a <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 582:	008b8913          	addi	s2,s7,8
 586:	4681                	li	a3,0
 588:	4641                	li	a2,16
 58a:	000ba583          	lw	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	e11ff0ef          	jal	3a0 <printint>
        i += 2;
 594:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 596:	8bca                	mv	s7,s2
      state = 0;
 598:	4981                	li	s3,0
        i += 2;
 59a:	bde5                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 59c:	008b8913          	addi	s2,s7,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000ba583          	lw	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	df7ff0ef          	jal	3a0 <printint>
        i += 2;
 5ae:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b0:	8bca                	mv	s7,s2
      state = 0;
 5b2:	4981                	li	s3,0
        i += 2;
 5b4:	bdf9                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4629                	li	a2,10
 5be:	000ba583          	lw	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	dddff0ef          	jal	3a0 <printint>
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b5d9                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4629                	li	a2,10
 5d6:	000ba583          	lw	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	dc5ff0ef          	jal	3a0 <printint>
        i += 1;
 5e0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 1;
 5e6:	b575                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e8:	008b8913          	addi	s2,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4629                	li	a2,10
 5f0:	000ba583          	lw	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	dabff0ef          	jal	3a0 <printint>
        i += 2;
 5fa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
        i += 2;
 600:	bd49                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 602:	008b8913          	addi	s2,s7,8
 606:	4681                	li	a3,0
 608:	4641                	li	a2,16
 60a:	000ba583          	lw	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	d91ff0ef          	jal	3a0 <printint>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	bdad                	j	492 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000ba583          	lw	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	d79ff0ef          	jal	3a0 <printint>
        i += 1;
 62c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
        i += 1;
 632:	b585                	j	492 <vprintf+0x4a>
 634:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 636:	008b8d13          	addi	s10,s7,8
 63a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 63e:	03000593          	li	a1,48
 642:	855a                	mv	a0,s6
 644:	d3fff0ef          	jal	382 <putc>
  putc(fd, 'x');
 648:	07800593          	li	a1,120
 64c:	855a                	mv	a0,s6
 64e:	d35ff0ef          	jal	382 <putc>
 652:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 654:	00000b97          	auipc	s7,0x0
 658:	29cb8b93          	addi	s7,s7,668 # 8f0 <digits>
 65c:	03c9d793          	srli	a5,s3,0x3c
 660:	97de                	add	a5,a5,s7
 662:	0007c583          	lbu	a1,0(a5)
 666:	855a                	mv	a0,s6
 668:	d1bff0ef          	jal	382 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66c:	0992                	slli	s3,s3,0x4
 66e:	397d                	addiw	s2,s2,-1
 670:	fe0916e3          	bnez	s2,65c <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 674:	8bea                	mv	s7,s10
      state = 0;
 676:	4981                	li	s3,0
 678:	6d02                	ld	s10,0(sp)
 67a:	bd21                	j	492 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 67c:	008b8993          	addi	s3,s7,8
 680:	000bb903          	ld	s2,0(s7)
 684:	00090f63          	beqz	s2,6a2 <vprintf+0x25a>
        for(; *s; s++)
 688:	00094583          	lbu	a1,0(s2)
 68c:	c195                	beqz	a1,6b0 <vprintf+0x268>
          putc(fd, *s);
 68e:	855a                	mv	a0,s6
 690:	cf3ff0ef          	jal	382 <putc>
        for(; *s; s++)
 694:	0905                	addi	s2,s2,1
 696:	00094583          	lbu	a1,0(s2)
 69a:	f9f5                	bnez	a1,68e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 69c:	8bce                	mv	s7,s3
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bbcd                	j	492 <vprintf+0x4a>
          s = "(null)";
 6a2:	00000917          	auipc	s2,0x0
 6a6:	24690913          	addi	s2,s2,582 # 8e8 <malloc+0x13a>
        for(; *s; s++)
 6aa:	02800593          	li	a1,40
 6ae:	b7c5                	j	68e <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6b0:	8bce                	mv	s7,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bbf9                	j	492 <vprintf+0x4a>
 6b6:	64a6                	ld	s1,72(sp)
 6b8:	79e2                	ld	s3,56(sp)
 6ba:	7a42                	ld	s4,48(sp)
 6bc:	7aa2                	ld	s5,40(sp)
 6be:	7b02                	ld	s6,32(sp)
 6c0:	6be2                	ld	s7,24(sp)
 6c2:	6c42                	ld	s8,16(sp)
 6c4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6c6:	60e6                	ld	ra,88(sp)
 6c8:	6446                	ld	s0,80(sp)
 6ca:	6906                	ld	s2,64(sp)
 6cc:	6125                	addi	sp,sp,96
 6ce:	8082                	ret

00000000000006d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d0:	715d                	addi	sp,sp,-80
 6d2:	ec06                	sd	ra,24(sp)
 6d4:	e822                	sd	s0,16(sp)
 6d6:	1000                	addi	s0,sp,32
 6d8:	e010                	sd	a2,0(s0)
 6da:	e414                	sd	a3,8(s0)
 6dc:	e818                	sd	a4,16(s0)
 6de:	ec1c                	sd	a5,24(s0)
 6e0:	03043023          	sd	a6,32(s0)
 6e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ec:	8622                	mv	a2,s0
 6ee:	d5bff0ef          	jal	448 <vprintf>
}
 6f2:	60e2                	ld	ra,24(sp)
 6f4:	6442                	ld	s0,16(sp)
 6f6:	6161                	addi	sp,sp,80
 6f8:	8082                	ret

00000000000006fa <printf>:

void
printf(const char *fmt, ...)
{
 6fa:	711d                	addi	sp,sp,-96
 6fc:	ec06                	sd	ra,24(sp)
 6fe:	e822                	sd	s0,16(sp)
 700:	1000                	addi	s0,sp,32
 702:	e40c                	sd	a1,8(s0)
 704:	e810                	sd	a2,16(s0)
 706:	ec14                	sd	a3,24(s0)
 708:	f018                	sd	a4,32(s0)
 70a:	f41c                	sd	a5,40(s0)
 70c:	03043823          	sd	a6,48(s0)
 710:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 714:	00840613          	addi	a2,s0,8
 718:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 71c:	85aa                	mv	a1,a0
 71e:	4505                	li	a0,1
 720:	d29ff0ef          	jal	448 <vprintf>
}
 724:	60e2                	ld	ra,24(sp)
 726:	6442                	ld	s0,16(sp)
 728:	6125                	addi	sp,sp,96
 72a:	8082                	ret

000000000000072c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 72c:	1141                	addi	sp,sp,-16
 72e:	e422                	sd	s0,8(sp)
 730:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 732:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 736:	00001797          	auipc	a5,0x1
 73a:	8ca7b783          	ld	a5,-1846(a5) # 1000 <freep>
 73e:	a02d                	j	768 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 740:	4618                	lw	a4,8(a2)
 742:	9f2d                	addw	a4,a4,a1
 744:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 748:	6398                	ld	a4,0(a5)
 74a:	6310                	ld	a2,0(a4)
 74c:	a83d                	j	78a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 74e:	ff852703          	lw	a4,-8(a0)
 752:	9f31                	addw	a4,a4,a2
 754:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 756:	ff053683          	ld	a3,-16(a0)
 75a:	a091                	j	79e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75c:	6398                	ld	a4,0(a5)
 75e:	00e7e463          	bltu	a5,a4,766 <free+0x3a>
 762:	00e6ea63          	bltu	a3,a4,776 <free+0x4a>
{
 766:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 768:	fed7fae3          	bgeu	a5,a3,75c <free+0x30>
 76c:	6398                	ld	a4,0(a5)
 76e:	00e6e463          	bltu	a3,a4,776 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	fee7eae3          	bltu	a5,a4,766 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 776:	ff852583          	lw	a1,-8(a0)
 77a:	6390                	ld	a2,0(a5)
 77c:	02059813          	slli	a6,a1,0x20
 780:	01c85713          	srli	a4,a6,0x1c
 784:	9736                	add	a4,a4,a3
 786:	fae60de3          	beq	a2,a4,740 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 78a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 78e:	4790                	lw	a2,8(a5)
 790:	02061593          	slli	a1,a2,0x20
 794:	01c5d713          	srli	a4,a1,0x1c
 798:	973e                	add	a4,a4,a5
 79a:	fae68ae3          	beq	a3,a4,74e <free+0x22>
    p->s.ptr = bp->s.ptr;
 79e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7a0:	00001717          	auipc	a4,0x1
 7a4:	86f73023          	sd	a5,-1952(a4) # 1000 <freep>
}
 7a8:	6422                	ld	s0,8(sp)
 7aa:	0141                	addi	sp,sp,16
 7ac:	8082                	ret

00000000000007ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ae:	7139                	addi	sp,sp,-64
 7b0:	fc06                	sd	ra,56(sp)
 7b2:	f822                	sd	s0,48(sp)
 7b4:	f426                	sd	s1,40(sp)
 7b6:	ec4e                	sd	s3,24(sp)
 7b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ba:	02051493          	slli	s1,a0,0x20
 7be:	9081                	srli	s1,s1,0x20
 7c0:	04bd                	addi	s1,s1,15
 7c2:	8091                	srli	s1,s1,0x4
 7c4:	0014899b          	addiw	s3,s1,1
 7c8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ca:	00001517          	auipc	a0,0x1
 7ce:	83653503          	ld	a0,-1994(a0) # 1000 <freep>
 7d2:	c915                	beqz	a0,806 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d6:	4798                	lw	a4,8(a5)
 7d8:	08977a63          	bgeu	a4,s1,86c <malloc+0xbe>
 7dc:	f04a                	sd	s2,32(sp)
 7de:	e852                	sd	s4,16(sp)
 7e0:	e456                	sd	s5,8(sp)
 7e2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7e4:	8a4e                	mv	s4,s3
 7e6:	0009871b          	sext.w	a4,s3
 7ea:	6685                	lui	a3,0x1
 7ec:	00d77363          	bgeu	a4,a3,7f2 <malloc+0x44>
 7f0:	6a05                	lui	s4,0x1
 7f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7fa:	00001917          	auipc	s2,0x1
 7fe:	80690913          	addi	s2,s2,-2042 # 1000 <freep>
  if(p == (char*)-1)
 802:	5afd                	li	s5,-1
 804:	a081                	j	844 <malloc+0x96>
 806:	f04a                	sd	s2,32(sp)
 808:	e852                	sd	s4,16(sp)
 80a:	e456                	sd	s5,8(sp)
 80c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 80e:	00001797          	auipc	a5,0x1
 812:	80278793          	addi	a5,a5,-2046 # 1010 <base>
 816:	00000717          	auipc	a4,0x0
 81a:	7ef73523          	sd	a5,2026(a4) # 1000 <freep>
 81e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 820:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 824:	b7c1                	j	7e4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 826:	6398                	ld	a4,0(a5)
 828:	e118                	sd	a4,0(a0)
 82a:	a8a9                	j	884 <malloc+0xd6>
  hp->s.size = nu;
 82c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 830:	0541                	addi	a0,a0,16
 832:	efbff0ef          	jal	72c <free>
  return freep;
 836:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 83a:	c12d                	beqz	a0,89c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83e:	4798                	lw	a4,8(a5)
 840:	02977263          	bgeu	a4,s1,864 <malloc+0xb6>
    if(p == freep)
 844:	00093703          	ld	a4,0(s2)
 848:	853e                	mv	a0,a5
 84a:	fef719e3          	bne	a4,a5,83c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 84e:	8552                	mv	a0,s4
 850:	af3ff0ef          	jal	342 <sbrk>
  if(p == (char*)-1)
 854:	fd551ce3          	bne	a0,s5,82c <malloc+0x7e>
        return 0;
 858:	4501                	li	a0,0
 85a:	7902                	ld	s2,32(sp)
 85c:	6a42                	ld	s4,16(sp)
 85e:	6aa2                	ld	s5,8(sp)
 860:	6b02                	ld	s6,0(sp)
 862:	a03d                	j	890 <malloc+0xe2>
 864:	7902                	ld	s2,32(sp)
 866:	6a42                	ld	s4,16(sp)
 868:	6aa2                	ld	s5,8(sp)
 86a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 86c:	fae48de3          	beq	s1,a4,826 <malloc+0x78>
        p->s.size -= nunits;
 870:	4137073b          	subw	a4,a4,s3
 874:	c798                	sw	a4,8(a5)
        p += p->s.size;
 876:	02071693          	slli	a3,a4,0x20
 87a:	01c6d713          	srli	a4,a3,0x1c
 87e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 880:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 884:	00000717          	auipc	a4,0x0
 888:	76a73e23          	sd	a0,1916(a4) # 1000 <freep>
      return (void*)(p + 1);
 88c:	01078513          	addi	a0,a5,16
  }
}
 890:	70e2                	ld	ra,56(sp)
 892:	7442                	ld	s0,48(sp)
 894:	74a2                	ld	s1,40(sp)
 896:	69e2                	ld	s3,24(sp)
 898:	6121                	addi	sp,sp,64
 89a:	8082                	ret
 89c:	7902                	ld	s2,32(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
 8a4:	b7f5                	j	890 <malloc+0xe2>
