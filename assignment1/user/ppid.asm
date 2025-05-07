
user/_ppid:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    fprintf(2, "My student ID is 2021011158\n");
   8:	00001597          	auipc	a1,0x1
   c:	88858593          	addi	a1,a1,-1912 # 890 <malloc+0x106>
  10:	4509                	li	a0,2
  12:	69a000ef          	jal	6ac <fprintf>
    int pid_val = getpid();
  16:	318000ef          	jal	32e <getpid>
  1a:	862a                	mv	a2,a0
    fprintf(1, "My pid is %x\n", pid_val);
  1c:	00001597          	auipc	a1,0x1
  20:	89458593          	addi	a1,a1,-1900 # 8b0 <malloc+0x126>
  24:	4505                	li	a0,1
  26:	686000ef          	jal	6ac <fprintf>
    int ppid_val = getppid();
  2a:	32c000ef          	jal	356 <getppid>
  2e:	862a                	mv	a2,a0
    fprintf(1, "My ppid is %x\n", ppid_val);
  30:	00001597          	auipc	a1,0x1
  34:	89058593          	addi	a1,a1,-1904 # 8c0 <malloc+0x136>
  38:	4505                	li	a0,1
  3a:	672000ef          	jal	6ac <fprintf>
    exit(0);
  3e:	4501                	li	a0,0
  40:	26e000ef          	jal	2ae <exit>

0000000000000044 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  44:	1141                	addi	sp,sp,-16
  46:	e406                	sd	ra,8(sp)
  48:	e022                	sd	s0,0(sp)
  4a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  4c:	fb5ff0ef          	jal	0 <main>
  exit(0);
  50:	4501                	li	a0,0
  52:	25c000ef          	jal	2ae <exit>

0000000000000056 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  56:	1141                	addi	sp,sp,-16
  58:	e422                	sd	s0,8(sp)
  5a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5c:	87aa                	mv	a5,a0
  5e:	0585                	addi	a1,a1,1
  60:	0785                	addi	a5,a5,1
  62:	fff5c703          	lbu	a4,-1(a1)
  66:	fee78fa3          	sb	a4,-1(a5)
  6a:	fb75                	bnez	a4,5e <strcpy+0x8>
    ;
  return os;
}
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cb91                	beqz	a5,90 <strcmp+0x1e>
  7e:	0005c703          	lbu	a4,0(a1)
  82:	00f71763          	bne	a4,a5,90 <strcmp+0x1e>
    p++, q++;
  86:	0505                	addi	a0,a0,1
  88:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	fbe5                	bnez	a5,7e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  90:	0005c503          	lbu	a0,0(a1)
}
  94:	40a7853b          	subw	a0,a5,a0
  98:	6422                	ld	s0,8(sp)
  9a:	0141                	addi	sp,sp,16
  9c:	8082                	ret

000000000000009e <strlen>:

uint
strlen(const char *s)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a4:	00054783          	lbu	a5,0(a0)
  a8:	cf91                	beqz	a5,c4 <strlen+0x26>
  aa:	0505                	addi	a0,a0,1
  ac:	87aa                	mv	a5,a0
  ae:	86be                	mv	a3,a5
  b0:	0785                	addi	a5,a5,1
  b2:	fff7c703          	lbu	a4,-1(a5)
  b6:	ff65                	bnez	a4,ae <strlen+0x10>
  b8:	40a6853b          	subw	a0,a3,a0
  bc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret
  for(n = 0; s[n]; n++)
  c4:	4501                	li	a0,0
  c6:	bfe5                	j	be <strlen+0x20>

00000000000000c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ce:	ca19                	beqz	a2,e4 <memset+0x1c>
  d0:	87aa                	mv	a5,a0
  d2:	1602                	slli	a2,a2,0x20
  d4:	9201                	srli	a2,a2,0x20
  d6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  de:	0785                	addi	a5,a5,1
  e0:	fee79de3          	bne	a5,a4,da <memset+0x12>
  }
  return dst;
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret

00000000000000ea <strchr>:

char*
strchr(const char *s, char c)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	cb99                	beqz	a5,10a <strchr+0x20>
    if(*s == c)
  f6:	00f58763          	beq	a1,a5,104 <strchr+0x1a>
  for(; *s; s++)
  fa:	0505                	addi	a0,a0,1
  fc:	00054783          	lbu	a5,0(a0)
 100:	fbfd                	bnez	a5,f6 <strchr+0xc>
      return (char*)s;
  return 0;
 102:	4501                	li	a0,0
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret
  return 0;
 10a:	4501                	li	a0,0
 10c:	bfe5                	j	104 <strchr+0x1a>

000000000000010e <gets>:

char*
gets(char *buf, int max)
{
 10e:	711d                	addi	sp,sp,-96
 110:	ec86                	sd	ra,88(sp)
 112:	e8a2                	sd	s0,80(sp)
 114:	e4a6                	sd	s1,72(sp)
 116:	e0ca                	sd	s2,64(sp)
 118:	fc4e                	sd	s3,56(sp)
 11a:	f852                	sd	s4,48(sp)
 11c:	f456                	sd	s5,40(sp)
 11e:	f05a                	sd	s6,32(sp)
 120:	ec5e                	sd	s7,24(sp)
 122:	1080                	addi	s0,sp,96
 124:	8baa                	mv	s7,a0
 126:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	892a                	mv	s2,a0
 12a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 12c:	4aa9                	li	s5,10
 12e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 130:	89a6                	mv	s3,s1
 132:	2485                	addiw	s1,s1,1
 134:	0344d663          	bge	s1,s4,160 <gets+0x52>
    cc = read(0, &c, 1);
 138:	4605                	li	a2,1
 13a:	faf40593          	addi	a1,s0,-81
 13e:	4501                	li	a0,0
 140:	186000ef          	jal	2c6 <read>
    if(cc < 1)
 144:	00a05e63          	blez	a0,160 <gets+0x52>
    buf[i++] = c;
 148:	faf44783          	lbu	a5,-81(s0)
 14c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 150:	01578763          	beq	a5,s5,15e <gets+0x50>
 154:	0905                	addi	s2,s2,1
 156:	fd679de3          	bne	a5,s6,130 <gets+0x22>
    buf[i++] = c;
 15a:	89a6                	mv	s3,s1
 15c:	a011                	j	160 <gets+0x52>
 15e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 160:	99de                	add	s3,s3,s7
 162:	00098023          	sb	zero,0(s3)
  return buf;
}
 166:	855e                	mv	a0,s7
 168:	60e6                	ld	ra,88(sp)
 16a:	6446                	ld	s0,80(sp)
 16c:	64a6                	ld	s1,72(sp)
 16e:	6906                	ld	s2,64(sp)
 170:	79e2                	ld	s3,56(sp)
 172:	7a42                	ld	s4,48(sp)
 174:	7aa2                	ld	s5,40(sp)
 176:	7b02                	ld	s6,32(sp)
 178:	6be2                	ld	s7,24(sp)
 17a:	6125                	addi	sp,sp,96
 17c:	8082                	ret

000000000000017e <stat>:

int
stat(const char *n, struct stat *st)
{
 17e:	1101                	addi	sp,sp,-32
 180:	ec06                	sd	ra,24(sp)
 182:	e822                	sd	s0,16(sp)
 184:	e04a                	sd	s2,0(sp)
 186:	1000                	addi	s0,sp,32
 188:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18a:	4581                	li	a1,0
 18c:	162000ef          	jal	2ee <open>
  if(fd < 0)
 190:	02054263          	bltz	a0,1b4 <stat+0x36>
 194:	e426                	sd	s1,8(sp)
 196:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 198:	85ca                	mv	a1,s2
 19a:	16c000ef          	jal	306 <fstat>
 19e:	892a                	mv	s2,a0
  close(fd);
 1a0:	8526                	mv	a0,s1
 1a2:	134000ef          	jal	2d6 <close>
  return r;
 1a6:	64a2                	ld	s1,8(sp)
}
 1a8:	854a                	mv	a0,s2
 1aa:	60e2                	ld	ra,24(sp)
 1ac:	6442                	ld	s0,16(sp)
 1ae:	6902                	ld	s2,0(sp)
 1b0:	6105                	addi	sp,sp,32
 1b2:	8082                	ret
    return -1;
 1b4:	597d                	li	s2,-1
 1b6:	bfcd                	j	1a8 <stat+0x2a>

00000000000001b8 <atoi>:

int
atoi(const char *s)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1be:	00054683          	lbu	a3,0(a0)
 1c2:	fd06879b          	addiw	a5,a3,-48
 1c6:	0ff7f793          	zext.b	a5,a5
 1ca:	4625                	li	a2,9
 1cc:	02f66863          	bltu	a2,a5,1fc <atoi+0x44>
 1d0:	872a                	mv	a4,a0
  n = 0;
 1d2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d4:	0705                	addi	a4,a4,1
 1d6:	0025179b          	slliw	a5,a0,0x2
 1da:	9fa9                	addw	a5,a5,a0
 1dc:	0017979b          	slliw	a5,a5,0x1
 1e0:	9fb5                	addw	a5,a5,a3
 1e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e6:	00074683          	lbu	a3,0(a4)
 1ea:	fd06879b          	addiw	a5,a3,-48
 1ee:	0ff7f793          	zext.b	a5,a5
 1f2:	fef671e3          	bgeu	a2,a5,1d4 <atoi+0x1c>
  return n;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  n = 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <atoi+0x3e>

0000000000000200 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 206:	02b57463          	bgeu	a0,a1,22e <memmove+0x2e>
    while(n-- > 0)
 20a:	00c05f63          	blez	a2,228 <memmove+0x28>
 20e:	1602                	slli	a2,a2,0x20
 210:	9201                	srli	a2,a2,0x20
 212:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 216:	872a                	mv	a4,a0
      *dst++ = *src++;
 218:	0585                	addi	a1,a1,1
 21a:	0705                	addi	a4,a4,1
 21c:	fff5c683          	lbu	a3,-1(a1)
 220:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 224:	fef71ae3          	bne	a4,a5,218 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
    dst += n;
 22e:	00c50733          	add	a4,a0,a2
    src += n;
 232:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 234:	fec05ae3          	blez	a2,228 <memmove+0x28>
 238:	fff6079b          	addiw	a5,a2,-1
 23c:	1782                	slli	a5,a5,0x20
 23e:	9381                	srli	a5,a5,0x20
 240:	fff7c793          	not	a5,a5
 244:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 246:	15fd                	addi	a1,a1,-1
 248:	177d                	addi	a4,a4,-1
 24a:	0005c683          	lbu	a3,0(a1)
 24e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 252:	fee79ae3          	bne	a5,a4,246 <memmove+0x46>
 256:	bfc9                	j	228 <memmove+0x28>

0000000000000258 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25e:	ca05                	beqz	a2,28e <memcmp+0x36>
 260:	fff6069b          	addiw	a3,a2,-1
 264:	1682                	slli	a3,a3,0x20
 266:	9281                	srli	a3,a3,0x20
 268:	0685                	addi	a3,a3,1
 26a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26c:	00054783          	lbu	a5,0(a0)
 270:	0005c703          	lbu	a4,0(a1)
 274:	00e79863          	bne	a5,a4,284 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 278:	0505                	addi	a0,a0,1
    p2++;
 27a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27c:	fed518e3          	bne	a0,a3,26c <memcmp+0x14>
  }
  return 0;
 280:	4501                	li	a0,0
 282:	a019                	j	288 <memcmp+0x30>
      return *p1 - *p2;
 284:	40e7853b          	subw	a0,a5,a4
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  return 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <memcmp+0x30>

0000000000000292 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e406                	sd	ra,8(sp)
 296:	e022                	sd	s0,0(sp)
 298:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29a:	f67ff0ef          	jal	200 <memmove>
}
 29e:	60a2                	ld	ra,8(sp)
 2a0:	6402                	ld	s0,0(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2a6:	4885                	li	a7,1
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ae:	4889                	li	a7,2
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2b6:	488d                	li	a7,3
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2be:	4891                	li	a7,4
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <read>:
.global read
read:
 li a7, SYS_read
 2c6:	4895                	li	a7,5
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <write>:
.global write
write:
 li a7, SYS_write
 2ce:	48c1                	li	a7,16
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <close>:
.global close
close:
 li a7, SYS_close
 2d6:	48d5                	li	a7,21
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <kill>:
.global kill
kill:
 li a7, SYS_kill
 2de:	4899                	li	a7,6
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2e6:	489d                	li	a7,7
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <open>:
.global open
open:
 li a7, SYS_open
 2ee:	48bd                	li	a7,15
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2f6:	48c5                	li	a7,17
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2fe:	48c9                	li	a7,18
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 306:	48a1                	li	a7,8
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <link>:
.global link
link:
 li a7, SYS_link
 30e:	48cd                	li	a7,19
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 316:	48d1                	li	a7,20
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 31e:	48a5                	li	a7,9
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <dup>:
.global dup
dup:
 li a7, SYS_dup
 326:	48a9                	li	a7,10
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 32e:	48ad                	li	a7,11
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 336:	48b1                	li	a7,12
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 33e:	48b5                	li	a7,13
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 346:	48b9                	li	a7,14
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <myfunction>:
.global myfunction
myfunction:
 li a7, SYS_myfunction
 34e:	48d9                	li	a7,22
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 356:	48dd                	li	a7,23
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 35e:	1101                	addi	sp,sp,-32
 360:	ec06                	sd	ra,24(sp)
 362:	e822                	sd	s0,16(sp)
 364:	1000                	addi	s0,sp,32
 366:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 36a:	4605                	li	a2,1
 36c:	fef40593          	addi	a1,s0,-17
 370:	f5fff0ef          	jal	2ce <write>
}
 374:	60e2                	ld	ra,24(sp)
 376:	6442                	ld	s0,16(sp)
 378:	6105                	addi	sp,sp,32
 37a:	8082                	ret

000000000000037c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37c:	7139                	addi	sp,sp,-64
 37e:	fc06                	sd	ra,56(sp)
 380:	f822                	sd	s0,48(sp)
 382:	f426                	sd	s1,40(sp)
 384:	0080                	addi	s0,sp,64
 386:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 388:	c299                	beqz	a3,38e <printint+0x12>
 38a:	0805c963          	bltz	a1,41c <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 38e:	2581                	sext.w	a1,a1
  neg = 0;
 390:	4881                	li	a7,0
 392:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 396:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 398:	2601                	sext.w	a2,a2
 39a:	00000517          	auipc	a0,0x0
 39e:	53e50513          	addi	a0,a0,1342 # 8d8 <digits>
 3a2:	883a                	mv	a6,a4
 3a4:	2705                	addiw	a4,a4,1
 3a6:	02c5f7bb          	remuw	a5,a1,a2
 3aa:	1782                	slli	a5,a5,0x20
 3ac:	9381                	srli	a5,a5,0x20
 3ae:	97aa                	add	a5,a5,a0
 3b0:	0007c783          	lbu	a5,0(a5)
 3b4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3b8:	0005879b          	sext.w	a5,a1
 3bc:	02c5d5bb          	divuw	a1,a1,a2
 3c0:	0685                	addi	a3,a3,1
 3c2:	fec7f0e3          	bgeu	a5,a2,3a2 <printint+0x26>
  if(neg)
 3c6:	00088c63          	beqz	a7,3de <printint+0x62>
    buf[i++] = '-';
 3ca:	fd070793          	addi	a5,a4,-48
 3ce:	00878733          	add	a4,a5,s0
 3d2:	02d00793          	li	a5,45
 3d6:	fef70823          	sb	a5,-16(a4)
 3da:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3de:	02e05a63          	blez	a4,412 <printint+0x96>
 3e2:	f04a                	sd	s2,32(sp)
 3e4:	ec4e                	sd	s3,24(sp)
 3e6:	fc040793          	addi	a5,s0,-64
 3ea:	00e78933          	add	s2,a5,a4
 3ee:	fff78993          	addi	s3,a5,-1
 3f2:	99ba                	add	s3,s3,a4
 3f4:	377d                	addiw	a4,a4,-1
 3f6:	1702                	slli	a4,a4,0x20
 3f8:	9301                	srli	a4,a4,0x20
 3fa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3fe:	fff94583          	lbu	a1,-1(s2)
 402:	8526                	mv	a0,s1
 404:	f5bff0ef          	jal	35e <putc>
  while(--i >= 0)
 408:	197d                	addi	s2,s2,-1
 40a:	ff391ae3          	bne	s2,s3,3fe <printint+0x82>
 40e:	7902                	ld	s2,32(sp)
 410:	69e2                	ld	s3,24(sp)
}
 412:	70e2                	ld	ra,56(sp)
 414:	7442                	ld	s0,48(sp)
 416:	74a2                	ld	s1,40(sp)
 418:	6121                	addi	sp,sp,64
 41a:	8082                	ret
    x = -xx;
 41c:	40b005bb          	negw	a1,a1
    neg = 1;
 420:	4885                	li	a7,1
    x = -xx;
 422:	bf85                	j	392 <printint+0x16>

0000000000000424 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 424:	711d                	addi	sp,sp,-96
 426:	ec86                	sd	ra,88(sp)
 428:	e8a2                	sd	s0,80(sp)
 42a:	e0ca                	sd	s2,64(sp)
 42c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 42e:	0005c903          	lbu	s2,0(a1)
 432:	26090863          	beqz	s2,6a2 <vprintf+0x27e>
 436:	e4a6                	sd	s1,72(sp)
 438:	fc4e                	sd	s3,56(sp)
 43a:	f852                	sd	s4,48(sp)
 43c:	f456                	sd	s5,40(sp)
 43e:	f05a                	sd	s6,32(sp)
 440:	ec5e                	sd	s7,24(sp)
 442:	e862                	sd	s8,16(sp)
 444:	e466                	sd	s9,8(sp)
 446:	8b2a                	mv	s6,a0
 448:	8a2e                	mv	s4,a1
 44a:	8bb2                	mv	s7,a2
  state = 0;
 44c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 44e:	4481                	li	s1,0
 450:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 452:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 456:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 45a:	06c00c93          	li	s9,108
 45e:	a005                	j	47e <vprintf+0x5a>
        putc(fd, c0);
 460:	85ca                	mv	a1,s2
 462:	855a                	mv	a0,s6
 464:	efbff0ef          	jal	35e <putc>
 468:	a019                	j	46e <vprintf+0x4a>
    } else if(state == '%'){
 46a:	03598263          	beq	s3,s5,48e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 46e:	2485                	addiw	s1,s1,1
 470:	8726                	mv	a4,s1
 472:	009a07b3          	add	a5,s4,s1
 476:	0007c903          	lbu	s2,0(a5)
 47a:	20090c63          	beqz	s2,692 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 47e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 482:	fe0994e3          	bnez	s3,46a <vprintf+0x46>
      if(c0 == '%'){
 486:	fd579de3          	bne	a5,s5,460 <vprintf+0x3c>
        state = '%';
 48a:	89be                	mv	s3,a5
 48c:	b7cd                	j	46e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 48e:	00ea06b3          	add	a3,s4,a4
 492:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 496:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 498:	c681                	beqz	a3,4a0 <vprintf+0x7c>
 49a:	9752                	add	a4,a4,s4
 49c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4a0:	03878f63          	beq	a5,s8,4de <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 4a4:	05978963          	beq	a5,s9,4f6 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4a8:	07500713          	li	a4,117
 4ac:	0ee78363          	beq	a5,a4,592 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4b0:	07800713          	li	a4,120
 4b4:	12e78563          	beq	a5,a4,5de <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4b8:	07000713          	li	a4,112
 4bc:	14e78a63          	beq	a5,a4,610 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4c0:	07300713          	li	a4,115
 4c4:	18e78a63          	beq	a5,a4,658 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4c8:	02500713          	li	a4,37
 4cc:	04e79563          	bne	a5,a4,516 <vprintf+0xf2>
        putc(fd, '%');
 4d0:	02500593          	li	a1,37
 4d4:	855a                	mv	a0,s6
 4d6:	e89ff0ef          	jal	35e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4da:	4981                	li	s3,0
 4dc:	bf49                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4de:	008b8913          	addi	s2,s7,8
 4e2:	4685                	li	a3,1
 4e4:	4629                	li	a2,10
 4e6:	000ba583          	lw	a1,0(s7)
 4ea:	855a                	mv	a0,s6
 4ec:	e91ff0ef          	jal	37c <printint>
 4f0:	8bca                	mv	s7,s2
      state = 0;
 4f2:	4981                	li	s3,0
 4f4:	bfad                	j	46e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4f6:	06400793          	li	a5,100
 4fa:	02f68963          	beq	a3,a5,52c <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4fe:	06c00793          	li	a5,108
 502:	04f68263          	beq	a3,a5,546 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 506:	07500793          	li	a5,117
 50a:	0af68063          	beq	a3,a5,5aa <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 50e:	07800793          	li	a5,120
 512:	0ef68263          	beq	a3,a5,5f6 <vprintf+0x1d2>
        putc(fd, '%');
 516:	02500593          	li	a1,37
 51a:	855a                	mv	a0,s6
 51c:	e43ff0ef          	jal	35e <putc>
        putc(fd, c0);
 520:	85ca                	mv	a1,s2
 522:	855a                	mv	a0,s6
 524:	e3bff0ef          	jal	35e <putc>
      state = 0;
 528:	4981                	li	s3,0
 52a:	b791                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 52c:	008b8913          	addi	s2,s7,8
 530:	4685                	li	a3,1
 532:	4629                	li	a2,10
 534:	000ba583          	lw	a1,0(s7)
 538:	855a                	mv	a0,s6
 53a:	e43ff0ef          	jal	37c <printint>
        i += 1;
 53e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 540:	8bca                	mv	s7,s2
      state = 0;
 542:	4981                	li	s3,0
        i += 1;
 544:	b72d                	j	46e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 546:	06400793          	li	a5,100
 54a:	02f60763          	beq	a2,a5,578 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 54e:	07500793          	li	a5,117
 552:	06f60963          	beq	a2,a5,5c4 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 556:	07800793          	li	a5,120
 55a:	faf61ee3          	bne	a2,a5,516 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 55e:	008b8913          	addi	s2,s7,8
 562:	4681                	li	a3,0
 564:	4641                	li	a2,16
 566:	000ba583          	lw	a1,0(s7)
 56a:	855a                	mv	a0,s6
 56c:	e11ff0ef          	jal	37c <printint>
        i += 2;
 570:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 572:	8bca                	mv	s7,s2
      state = 0;
 574:	4981                	li	s3,0
        i += 2;
 576:	bde5                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 578:	008b8913          	addi	s2,s7,8
 57c:	4685                	li	a3,1
 57e:	4629                	li	a2,10
 580:	000ba583          	lw	a1,0(s7)
 584:	855a                	mv	a0,s6
 586:	df7ff0ef          	jal	37c <printint>
        i += 2;
 58a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 58c:	8bca                	mv	s7,s2
      state = 0;
 58e:	4981                	li	s3,0
        i += 2;
 590:	bdf9                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 592:	008b8913          	addi	s2,s7,8
 596:	4681                	li	a3,0
 598:	4629                	li	a2,10
 59a:	000ba583          	lw	a1,0(s7)
 59e:	855a                	mv	a0,s6
 5a0:	dddff0ef          	jal	37c <printint>
 5a4:	8bca                	mv	s7,s2
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	b5d9                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5aa:	008b8913          	addi	s2,s7,8
 5ae:	4681                	li	a3,0
 5b0:	4629                	li	a2,10
 5b2:	000ba583          	lw	a1,0(s7)
 5b6:	855a                	mv	a0,s6
 5b8:	dc5ff0ef          	jal	37c <printint>
        i += 1;
 5bc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5be:	8bca                	mv	s7,s2
      state = 0;
 5c0:	4981                	li	s3,0
        i += 1;
 5c2:	b575                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c4:	008b8913          	addi	s2,s7,8
 5c8:	4681                	li	a3,0
 5ca:	4629                	li	a2,10
 5cc:	000ba583          	lw	a1,0(s7)
 5d0:	855a                	mv	a0,s6
 5d2:	dabff0ef          	jal	37c <printint>
        i += 2;
 5d6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d8:	8bca                	mv	s7,s2
      state = 0;
 5da:	4981                	li	s3,0
        i += 2;
 5dc:	bd49                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5de:	008b8913          	addi	s2,s7,8
 5e2:	4681                	li	a3,0
 5e4:	4641                	li	a2,16
 5e6:	000ba583          	lw	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	d91ff0ef          	jal	37c <printint>
 5f0:	8bca                	mv	s7,s2
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	bdad                	j	46e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f6:	008b8913          	addi	s2,s7,8
 5fa:	4681                	li	a3,0
 5fc:	4641                	li	a2,16
 5fe:	000ba583          	lw	a1,0(s7)
 602:	855a                	mv	a0,s6
 604:	d79ff0ef          	jal	37c <printint>
        i += 1;
 608:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
        i += 1;
 60e:	b585                	j	46e <vprintf+0x4a>
 610:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 612:	008b8d13          	addi	s10,s7,8
 616:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 61a:	03000593          	li	a1,48
 61e:	855a                	mv	a0,s6
 620:	d3fff0ef          	jal	35e <putc>
  putc(fd, 'x');
 624:	07800593          	li	a1,120
 628:	855a                	mv	a0,s6
 62a:	d35ff0ef          	jal	35e <putc>
 62e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 630:	00000b97          	auipc	s7,0x0
 634:	2a8b8b93          	addi	s7,s7,680 # 8d8 <digits>
 638:	03c9d793          	srli	a5,s3,0x3c
 63c:	97de                	add	a5,a5,s7
 63e:	0007c583          	lbu	a1,0(a5)
 642:	855a                	mv	a0,s6
 644:	d1bff0ef          	jal	35e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 648:	0992                	slli	s3,s3,0x4
 64a:	397d                	addiw	s2,s2,-1
 64c:	fe0916e3          	bnez	s2,638 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 650:	8bea                	mv	s7,s10
      state = 0;
 652:	4981                	li	s3,0
 654:	6d02                	ld	s10,0(sp)
 656:	bd21                	j	46e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 658:	008b8993          	addi	s3,s7,8
 65c:	000bb903          	ld	s2,0(s7)
 660:	00090f63          	beqz	s2,67e <vprintf+0x25a>
        for(; *s; s++)
 664:	00094583          	lbu	a1,0(s2)
 668:	c195                	beqz	a1,68c <vprintf+0x268>
          putc(fd, *s);
 66a:	855a                	mv	a0,s6
 66c:	cf3ff0ef          	jal	35e <putc>
        for(; *s; s++)
 670:	0905                	addi	s2,s2,1
 672:	00094583          	lbu	a1,0(s2)
 676:	f9f5                	bnez	a1,66a <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 678:	8bce                	mv	s7,s3
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bbcd                	j	46e <vprintf+0x4a>
          s = "(null)";
 67e:	00000917          	auipc	s2,0x0
 682:	25290913          	addi	s2,s2,594 # 8d0 <malloc+0x146>
        for(; *s; s++)
 686:	02800593          	li	a1,40
 68a:	b7c5                	j	66a <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 68c:	8bce                	mv	s7,s3
      state = 0;
 68e:	4981                	li	s3,0
 690:	bbf9                	j	46e <vprintf+0x4a>
 692:	64a6                	ld	s1,72(sp)
 694:	79e2                	ld	s3,56(sp)
 696:	7a42                	ld	s4,48(sp)
 698:	7aa2                	ld	s5,40(sp)
 69a:	7b02                	ld	s6,32(sp)
 69c:	6be2                	ld	s7,24(sp)
 69e:	6c42                	ld	s8,16(sp)
 6a0:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6a2:	60e6                	ld	ra,88(sp)
 6a4:	6446                	ld	s0,80(sp)
 6a6:	6906                	ld	s2,64(sp)
 6a8:	6125                	addi	sp,sp,96
 6aa:	8082                	ret

00000000000006ac <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ac:	715d                	addi	sp,sp,-80
 6ae:	ec06                	sd	ra,24(sp)
 6b0:	e822                	sd	s0,16(sp)
 6b2:	1000                	addi	s0,sp,32
 6b4:	e010                	sd	a2,0(s0)
 6b6:	e414                	sd	a3,8(s0)
 6b8:	e818                	sd	a4,16(s0)
 6ba:	ec1c                	sd	a5,24(s0)
 6bc:	03043023          	sd	a6,32(s0)
 6c0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c8:	8622                	mv	a2,s0
 6ca:	d5bff0ef          	jal	424 <vprintf>
}
 6ce:	60e2                	ld	ra,24(sp)
 6d0:	6442                	ld	s0,16(sp)
 6d2:	6161                	addi	sp,sp,80
 6d4:	8082                	ret

00000000000006d6 <printf>:

void
printf(const char *fmt, ...)
{
 6d6:	711d                	addi	sp,sp,-96
 6d8:	ec06                	sd	ra,24(sp)
 6da:	e822                	sd	s0,16(sp)
 6dc:	1000                	addi	s0,sp,32
 6de:	e40c                	sd	a1,8(s0)
 6e0:	e810                	sd	a2,16(s0)
 6e2:	ec14                	sd	a3,24(s0)
 6e4:	f018                	sd	a4,32(s0)
 6e6:	f41c                	sd	a5,40(s0)
 6e8:	03043823          	sd	a6,48(s0)
 6ec:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f0:	00840613          	addi	a2,s0,8
 6f4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f8:	85aa                	mv	a1,a0
 6fa:	4505                	li	a0,1
 6fc:	d29ff0ef          	jal	424 <vprintf>
}
 700:	60e2                	ld	ra,24(sp)
 702:	6442                	ld	s0,16(sp)
 704:	6125                	addi	sp,sp,96
 706:	8082                	ret

0000000000000708 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 708:	1141                	addi	sp,sp,-16
 70a:	e422                	sd	s0,8(sp)
 70c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 712:	00001797          	auipc	a5,0x1
 716:	8ee7b783          	ld	a5,-1810(a5) # 1000 <freep>
 71a:	a02d                	j	744 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71c:	4618                	lw	a4,8(a2)
 71e:	9f2d                	addw	a4,a4,a1
 720:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 724:	6398                	ld	a4,0(a5)
 726:	6310                	ld	a2,0(a4)
 728:	a83d                	j	766 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 72a:	ff852703          	lw	a4,-8(a0)
 72e:	9f31                	addw	a4,a4,a2
 730:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 732:	ff053683          	ld	a3,-16(a0)
 736:	a091                	j	77a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 738:	6398                	ld	a4,0(a5)
 73a:	00e7e463          	bltu	a5,a4,742 <free+0x3a>
 73e:	00e6ea63          	bltu	a3,a4,752 <free+0x4a>
{
 742:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 744:	fed7fae3          	bgeu	a5,a3,738 <free+0x30>
 748:	6398                	ld	a4,0(a5)
 74a:	00e6e463          	bltu	a3,a4,752 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74e:	fee7eae3          	bltu	a5,a4,742 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 752:	ff852583          	lw	a1,-8(a0)
 756:	6390                	ld	a2,0(a5)
 758:	02059813          	slli	a6,a1,0x20
 75c:	01c85713          	srli	a4,a6,0x1c
 760:	9736                	add	a4,a4,a3
 762:	fae60de3          	beq	a2,a4,71c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 766:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 76a:	4790                	lw	a2,8(a5)
 76c:	02061593          	slli	a1,a2,0x20
 770:	01c5d713          	srli	a4,a1,0x1c
 774:	973e                	add	a4,a4,a5
 776:	fae68ae3          	beq	a3,a4,72a <free+0x22>
    p->s.ptr = bp->s.ptr;
 77a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77c:	00001717          	auipc	a4,0x1
 780:	88f73223          	sd	a5,-1916(a4) # 1000 <freep>
}
 784:	6422                	ld	s0,8(sp)
 786:	0141                	addi	sp,sp,16
 788:	8082                	ret

000000000000078a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 78a:	7139                	addi	sp,sp,-64
 78c:	fc06                	sd	ra,56(sp)
 78e:	f822                	sd	s0,48(sp)
 790:	f426                	sd	s1,40(sp)
 792:	ec4e                	sd	s3,24(sp)
 794:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 796:	02051493          	slli	s1,a0,0x20
 79a:	9081                	srli	s1,s1,0x20
 79c:	04bd                	addi	s1,s1,15
 79e:	8091                	srli	s1,s1,0x4
 7a0:	0014899b          	addiw	s3,s1,1
 7a4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7a6:	00001517          	auipc	a0,0x1
 7aa:	85a53503          	ld	a0,-1958(a0) # 1000 <freep>
 7ae:	c915                	beqz	a0,7e2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b2:	4798                	lw	a4,8(a5)
 7b4:	08977a63          	bgeu	a4,s1,848 <malloc+0xbe>
 7b8:	f04a                	sd	s2,32(sp)
 7ba:	e852                	sd	s4,16(sp)
 7bc:	e456                	sd	s5,8(sp)
 7be:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7c0:	8a4e                	mv	s4,s3
 7c2:	0009871b          	sext.w	a4,s3
 7c6:	6685                	lui	a3,0x1
 7c8:	00d77363          	bgeu	a4,a3,7ce <malloc+0x44>
 7cc:	6a05                	lui	s4,0x1
 7ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d6:	00001917          	auipc	s2,0x1
 7da:	82a90913          	addi	s2,s2,-2006 # 1000 <freep>
  if(p == (char*)-1)
 7de:	5afd                	li	s5,-1
 7e0:	a081                	j	820 <malloc+0x96>
 7e2:	f04a                	sd	s2,32(sp)
 7e4:	e852                	sd	s4,16(sp)
 7e6:	e456                	sd	s5,8(sp)
 7e8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7ea:	00001797          	auipc	a5,0x1
 7ee:	82678793          	addi	a5,a5,-2010 # 1010 <base>
 7f2:	00001717          	auipc	a4,0x1
 7f6:	80f73723          	sd	a5,-2034(a4) # 1000 <freep>
 7fa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7fc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 800:	b7c1                	j	7c0 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 802:	6398                	ld	a4,0(a5)
 804:	e118                	sd	a4,0(a0)
 806:	a8a9                	j	860 <malloc+0xd6>
  hp->s.size = nu;
 808:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 80c:	0541                	addi	a0,a0,16
 80e:	efbff0ef          	jal	708 <free>
  return freep;
 812:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 816:	c12d                	beqz	a0,878 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81a:	4798                	lw	a4,8(a5)
 81c:	02977263          	bgeu	a4,s1,840 <malloc+0xb6>
    if(p == freep)
 820:	00093703          	ld	a4,0(s2)
 824:	853e                	mv	a0,a5
 826:	fef719e3          	bne	a4,a5,818 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 82a:	8552                	mv	a0,s4
 82c:	b0bff0ef          	jal	336 <sbrk>
  if(p == (char*)-1)
 830:	fd551ce3          	bne	a0,s5,808 <malloc+0x7e>
        return 0;
 834:	4501                	li	a0,0
 836:	7902                	ld	s2,32(sp)
 838:	6a42                	ld	s4,16(sp)
 83a:	6aa2                	ld	s5,8(sp)
 83c:	6b02                	ld	s6,0(sp)
 83e:	a03d                	j	86c <malloc+0xe2>
 840:	7902                	ld	s2,32(sp)
 842:	6a42                	ld	s4,16(sp)
 844:	6aa2                	ld	s5,8(sp)
 846:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 848:	fae48de3          	beq	s1,a4,802 <malloc+0x78>
        p->s.size -= nunits;
 84c:	4137073b          	subw	a4,a4,s3
 850:	c798                	sw	a4,8(a5)
        p += p->s.size;
 852:	02071693          	slli	a3,a4,0x20
 856:	01c6d713          	srli	a4,a3,0x1c
 85a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 85c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 860:	00000717          	auipc	a4,0x0
 864:	7aa73023          	sd	a0,1952(a4) # 1000 <freep>
      return (void*)(p + 1);
 868:	01078513          	addi	a0,a5,16
  }
}
 86c:	70e2                	ld	ra,56(sp)
 86e:	7442                	ld	s0,48(sp)
 870:	74a2                	ld	s1,40(sp)
 872:	69e2                	ld	s3,24(sp)
 874:	6121                	addi	sp,sp,64
 876:	8082                	ret
 878:	7902                	ld	s2,32(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
 880:	b7f5                	j	86c <malloc+0xe2>
