
user/_test_setpr:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84ae                	mv	s1,a1
  int pid = atoi(argv[1]);
   e:	6588                	ld	a0,8(a1)
  10:	1da000ef          	jal	1ea <atoi>
  14:	892a                	mv	s2,a0
  int pr = atoi(argv[2]);
  16:	6888                	ld	a0,16(s1)
  18:	1d2000ef          	jal	1ea <atoi>
  1c:	85aa                	mv	a1,a0

  int ret = setpriority(pid, pr);
  1e:	854a                	mv	a0,s2
  20:	360000ef          	jal	380 <setpriority>
  24:	84aa                	mv	s1,a0
  fprintf(1, "setpriority return value: %d\n", ret);
  26:	862a                	mv	a2,a0
  28:	00001597          	auipc	a1,0x1
  2c:	8a858593          	addi	a1,a1,-1880 # 8d0 <malloc+0xfc>
  30:	4505                	li	a0,1
  32:	6c4000ef          	jal	6f6 <fprintf>
  if(ret == -1){
  36:	57fd                	li	a5,-1
  38:	00f48f63          	beq	s1,a5,56 <main+0x56>
    fprintf(2, "Cannot find matched pid.\n");
  }
  else if(ret == -2){
  3c:	57f9                	li	a5,-2
  3e:	02f48463          	beq	s1,a5,66 <main+0x66>
    fprintf(2, "Priority value is out of range.\n");
  }
  else{ // ret == 0; default
    fprintf(2, "Setpriority has completed.\n");
  42:	00001597          	auipc	a1,0x1
  46:	8fe58593          	addi	a1,a1,-1794 # 940 <malloc+0x16c>
  4a:	4509                	li	a0,2
  4c:	6aa000ef          	jal	6f6 <fprintf>
  }

  exit(0);
  50:	4501                	li	a0,0
  52:	28e000ef          	jal	2e0 <exit>
    fprintf(2, "Cannot find matched pid.\n");
  56:	00001597          	auipc	a1,0x1
  5a:	8a258593          	addi	a1,a1,-1886 # 8f8 <malloc+0x124>
  5e:	4509                	li	a0,2
  60:	696000ef          	jal	6f6 <fprintf>
  64:	b7f5                	j	50 <main+0x50>
    fprintf(2, "Priority value is out of range.\n");
  66:	00001597          	auipc	a1,0x1
  6a:	8b258593          	addi	a1,a1,-1870 # 918 <malloc+0x144>
  6e:	4509                	li	a0,2
  70:	686000ef          	jal	6f6 <fprintf>
  74:	bff1                	j	50 <main+0x50>

0000000000000076 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  76:	1141                	addi	sp,sp,-16
  78:	e406                	sd	ra,8(sp)
  7a:	e022                	sd	s0,0(sp)
  7c:	0800                	addi	s0,sp,16
  extern int main();
  main();
  7e:	f83ff0ef          	jal	0 <main>
  exit(0);
  82:	4501                	li	a0,0
  84:	25c000ef          	jal	2e0 <exit>

0000000000000088 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  88:	1141                	addi	sp,sp,-16
  8a:	e422                	sd	s0,8(sp)
  8c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8e:	87aa                	mv	a5,a0
  90:	0585                	addi	a1,a1,1
  92:	0785                	addi	a5,a5,1
  94:	fff5c703          	lbu	a4,-1(a1)
  98:	fee78fa3          	sb	a4,-1(a5)
  9c:	fb75                	bnez	a4,90 <strcpy+0x8>
    ;
  return os;
}
  9e:	6422                	ld	s0,8(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret

00000000000000a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cb91                	beqz	a5,c2 <strcmp+0x1e>
  b0:	0005c703          	lbu	a4,0(a1)
  b4:	00f71763          	bne	a4,a5,c2 <strcmp+0x1e>
    p++, q++;
  b8:	0505                	addi	a0,a0,1
  ba:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	fbe5                	bnez	a5,b0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c2:	0005c503          	lbu	a0,0(a1)
}
  c6:	40a7853b          	subw	a0,a5,a0
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strlen>:

uint
strlen(const char *s)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cf91                	beqz	a5,f6 <strlen+0x26>
  dc:	0505                	addi	a0,a0,1
  de:	87aa                	mv	a5,a0
  e0:	86be                	mv	a3,a5
  e2:	0785                	addi	a5,a5,1
  e4:	fff7c703          	lbu	a4,-1(a5)
  e8:	ff65                	bnez	a4,e0 <strlen+0x10>
  ea:	40a6853b          	subw	a0,a3,a0
  ee:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret
  for(n = 0; s[n]; n++)
  f6:	4501                	li	a0,0
  f8:	bfe5                	j	f0 <strlen+0x20>

00000000000000fa <memset>:

void*
memset(void *dst, int c, uint n)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 100:	ca19                	beqz	a2,116 <memset+0x1c>
 102:	87aa                	mv	a5,a0
 104:	1602                	slli	a2,a2,0x20
 106:	9201                	srli	a2,a2,0x20
 108:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 10c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 110:	0785                	addi	a5,a5,1
 112:	fee79de3          	bne	a5,a4,10c <memset+0x12>
  }
  return dst;
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  for(; *s; s++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb99                	beqz	a5,13c <strchr+0x20>
    if(*s == c)
 128:	00f58763          	beq	a1,a5,136 <strchr+0x1a>
  for(; *s; s++)
 12c:	0505                	addi	a0,a0,1
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbfd                	bnez	a5,128 <strchr+0xc>
      return (char*)s;
  return 0;
 134:	4501                	li	a0,0
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  return 0;
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strchr+0x1a>

0000000000000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	711d                	addi	sp,sp,-96
 142:	ec86                	sd	ra,88(sp)
 144:	e8a2                	sd	s0,80(sp)
 146:	e4a6                	sd	s1,72(sp)
 148:	e0ca                	sd	s2,64(sp)
 14a:	fc4e                	sd	s3,56(sp)
 14c:	f852                	sd	s4,48(sp)
 14e:	f456                	sd	s5,40(sp)
 150:	f05a                	sd	s6,32(sp)
 152:	ec5e                	sd	s7,24(sp)
 154:	1080                	addi	s0,sp,96
 156:	8baa                	mv	s7,a0
 158:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15a:	892a                	mv	s2,a0
 15c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15e:	4aa9                	li	s5,10
 160:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	2485                	addiw	s1,s1,1
 166:	0344d663          	bge	s1,s4,192 <gets+0x52>
    cc = read(0, &c, 1);
 16a:	4605                	li	a2,1
 16c:	faf40593          	addi	a1,s0,-81
 170:	4501                	li	a0,0
 172:	186000ef          	jal	2f8 <read>
    if(cc < 1)
 176:	00a05e63          	blez	a0,192 <gets+0x52>
    buf[i++] = c;
 17a:	faf44783          	lbu	a5,-81(s0)
 17e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 182:	01578763          	beq	a5,s5,190 <gets+0x50>
 186:	0905                	addi	s2,s2,1
 188:	fd679de3          	bne	a5,s6,162 <gets+0x22>
    buf[i++] = c;
 18c:	89a6                	mv	s3,s1
 18e:	a011                	j	192 <gets+0x52>
 190:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 192:	99de                	add	s3,s3,s7
 194:	00098023          	sb	zero,0(s3)
  return buf;
}
 198:	855e                	mv	a0,s7
 19a:	60e6                	ld	ra,88(sp)
 19c:	6446                	ld	s0,80(sp)
 19e:	64a6                	ld	s1,72(sp)
 1a0:	6906                	ld	s2,64(sp)
 1a2:	79e2                	ld	s3,56(sp)
 1a4:	7a42                	ld	s4,48(sp)
 1a6:	7aa2                	ld	s5,40(sp)
 1a8:	7b02                	ld	s6,32(sp)
 1aa:	6be2                	ld	s7,24(sp)
 1ac:	6125                	addi	sp,sp,96
 1ae:	8082                	ret

00000000000001b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b0:	1101                	addi	sp,sp,-32
 1b2:	ec06                	sd	ra,24(sp)
 1b4:	e822                	sd	s0,16(sp)
 1b6:	e04a                	sd	s2,0(sp)
 1b8:	1000                	addi	s0,sp,32
 1ba:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1bc:	4581                	li	a1,0
 1be:	162000ef          	jal	320 <open>
  if(fd < 0)
 1c2:	02054263          	bltz	a0,1e6 <stat+0x36>
 1c6:	e426                	sd	s1,8(sp)
 1c8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ca:	85ca                	mv	a1,s2
 1cc:	16c000ef          	jal	338 <fstat>
 1d0:	892a                	mv	s2,a0
  close(fd);
 1d2:	8526                	mv	a0,s1
 1d4:	134000ef          	jal	308 <close>
  return r;
 1d8:	64a2                	ld	s1,8(sp)
}
 1da:	854a                	mv	a0,s2
 1dc:	60e2                	ld	ra,24(sp)
 1de:	6442                	ld	s0,16(sp)
 1e0:	6902                	ld	s2,0(sp)
 1e2:	6105                	addi	sp,sp,32
 1e4:	8082                	ret
    return -1;
 1e6:	597d                	li	s2,-1
 1e8:	bfcd                	j	1da <stat+0x2a>

00000000000001ea <atoi>:

int
atoi(const char *s)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f0:	00054683          	lbu	a3,0(a0)
 1f4:	fd06879b          	addiw	a5,a3,-48
 1f8:	0ff7f793          	zext.b	a5,a5
 1fc:	4625                	li	a2,9
 1fe:	02f66863          	bltu	a2,a5,22e <atoi+0x44>
 202:	872a                	mv	a4,a0
  n = 0;
 204:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 206:	0705                	addi	a4,a4,1
 208:	0025179b          	slliw	a5,a0,0x2
 20c:	9fa9                	addw	a5,a5,a0
 20e:	0017979b          	slliw	a5,a5,0x1
 212:	9fb5                	addw	a5,a5,a3
 214:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 218:	00074683          	lbu	a3,0(a4)
 21c:	fd06879b          	addiw	a5,a3,-48
 220:	0ff7f793          	zext.b	a5,a5
 224:	fef671e3          	bgeu	a2,a5,206 <atoi+0x1c>
  return n;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
  n = 0;
 22e:	4501                	li	a0,0
 230:	bfe5                	j	228 <atoi+0x3e>

0000000000000232 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 238:	02b57463          	bgeu	a0,a1,260 <memmove+0x2e>
    while(n-- > 0)
 23c:	00c05f63          	blez	a2,25a <memmove+0x28>
 240:	1602                	slli	a2,a2,0x20
 242:	9201                	srli	a2,a2,0x20
 244:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 248:	872a                	mv	a4,a0
      *dst++ = *src++;
 24a:	0585                	addi	a1,a1,1
 24c:	0705                	addi	a4,a4,1
 24e:	fff5c683          	lbu	a3,-1(a1)
 252:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 256:	fef71ae3          	bne	a4,a5,24a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
    dst += n;
 260:	00c50733          	add	a4,a0,a2
    src += n;
 264:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 266:	fec05ae3          	blez	a2,25a <memmove+0x28>
 26a:	fff6079b          	addiw	a5,a2,-1
 26e:	1782                	slli	a5,a5,0x20
 270:	9381                	srli	a5,a5,0x20
 272:	fff7c793          	not	a5,a5
 276:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 278:	15fd                	addi	a1,a1,-1
 27a:	177d                	addi	a4,a4,-1
 27c:	0005c683          	lbu	a3,0(a1)
 280:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 284:	fee79ae3          	bne	a5,a4,278 <memmove+0x46>
 288:	bfc9                	j	25a <memmove+0x28>

000000000000028a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 290:	ca05                	beqz	a2,2c0 <memcmp+0x36>
 292:	fff6069b          	addiw	a3,a2,-1
 296:	1682                	slli	a3,a3,0x20
 298:	9281                	srli	a3,a3,0x20
 29a:	0685                	addi	a3,a3,1
 29c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	0005c703          	lbu	a4,0(a1)
 2a6:	00e79863          	bne	a5,a4,2b6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2aa:	0505                	addi	a0,a0,1
    p2++;
 2ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ae:	fed518e3          	bne	a0,a3,29e <memcmp+0x14>
  }
  return 0;
 2b2:	4501                	li	a0,0
 2b4:	a019                	j	2ba <memcmp+0x30>
      return *p1 - *p2;
 2b6:	40e7853b          	subw	a0,a5,a4
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	bfe5                	j	2ba <memcmp+0x30>

00000000000002c4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2cc:	f67ff0ef          	jal	232 <memmove>
}
 2d0:	60a2                	ld	ra,8(sp)
 2d2:	6402                	ld	s0,0(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret

00000000000002d8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2d8:	4885                	li	a7,1
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e0:	4889                	li	a7,2
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2e8:	488d                	li	a7,3
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f0:	4891                	li	a7,4
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <read>:
.global read
read:
 li a7, SYS_read
 2f8:	4895                	li	a7,5
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <write>:
.global write
write:
 li a7, SYS_write
 300:	48c1                	li	a7,16
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <close>:
.global close
close:
 li a7, SYS_close
 308:	48d5                	li	a7,21
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <kill>:
.global kill
kill:
 li a7, SYS_kill
 310:	4899                	li	a7,6
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <exec>:
.global exec
exec:
 li a7, SYS_exec
 318:	489d                	li	a7,7
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <open>:
.global open
open:
 li a7, SYS_open
 320:	48bd                	li	a7,15
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 328:	48c5                	li	a7,17
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 330:	48c9                	li	a7,18
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 338:	48a1                	li	a7,8
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <link>:
.global link
link:
 li a7, SYS_link
 340:	48cd                	li	a7,19
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 348:	48d1                	li	a7,20
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 350:	48a5                	li	a7,9
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <dup>:
.global dup
dup:
 li a7, SYS_dup
 358:	48a9                	li	a7,10
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 360:	48ad                	li	a7,11
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 368:	48b1                	li	a7,12
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 370:	48b5                	li	a7,13
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 378:	48b9                	li	a7,14
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 380:	48d9                	li	a7,22
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <getlev>:
.global getlev
getlev:
 li a7, SYS_getlev
 388:	48e1                	li	a7,24
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <yield>:
.global yield
yield:
 li a7, SYS_yield
 390:	48dd                	li	a7,23
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <mlfqmode>:
.global mlfqmode
mlfqmode:
 li a7, SYS_mlfqmode
 398:	48e5                	li	a7,25
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <fcfsmode>:
.global fcfsmode
fcfsmode:
 li a7, SYS_fcfsmode
 3a0:	48e9                	li	a7,26
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a8:	1101                	addi	sp,sp,-32
 3aa:	ec06                	sd	ra,24(sp)
 3ac:	e822                	sd	s0,16(sp)
 3ae:	1000                	addi	s0,sp,32
 3b0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b4:	4605                	li	a2,1
 3b6:	fef40593          	addi	a1,s0,-17
 3ba:	f47ff0ef          	jal	300 <write>
}
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	6105                	addi	sp,sp,32
 3c4:	8082                	ret

00000000000003c6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c6:	7139                	addi	sp,sp,-64
 3c8:	fc06                	sd	ra,56(sp)
 3ca:	f822                	sd	s0,48(sp)
 3cc:	f426                	sd	s1,40(sp)
 3ce:	0080                	addi	s0,sp,64
 3d0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d2:	c299                	beqz	a3,3d8 <printint+0x12>
 3d4:	0805c963          	bltz	a1,466 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3d8:	2581                	sext.w	a1,a1
  neg = 0;
 3da:	4881                	li	a7,0
 3dc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3e0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e2:	2601                	sext.w	a2,a2
 3e4:	00000517          	auipc	a0,0x0
 3e8:	58450513          	addi	a0,a0,1412 # 968 <digits>
 3ec:	883a                	mv	a6,a4
 3ee:	2705                	addiw	a4,a4,1
 3f0:	02c5f7bb          	remuw	a5,a1,a2
 3f4:	1782                	slli	a5,a5,0x20
 3f6:	9381                	srli	a5,a5,0x20
 3f8:	97aa                	add	a5,a5,a0
 3fa:	0007c783          	lbu	a5,0(a5)
 3fe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 402:	0005879b          	sext.w	a5,a1
 406:	02c5d5bb          	divuw	a1,a1,a2
 40a:	0685                	addi	a3,a3,1
 40c:	fec7f0e3          	bgeu	a5,a2,3ec <printint+0x26>
  if(neg)
 410:	00088c63          	beqz	a7,428 <printint+0x62>
    buf[i++] = '-';
 414:	fd070793          	addi	a5,a4,-48
 418:	00878733          	add	a4,a5,s0
 41c:	02d00793          	li	a5,45
 420:	fef70823          	sb	a5,-16(a4)
 424:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 428:	02e05a63          	blez	a4,45c <printint+0x96>
 42c:	f04a                	sd	s2,32(sp)
 42e:	ec4e                	sd	s3,24(sp)
 430:	fc040793          	addi	a5,s0,-64
 434:	00e78933          	add	s2,a5,a4
 438:	fff78993          	addi	s3,a5,-1
 43c:	99ba                	add	s3,s3,a4
 43e:	377d                	addiw	a4,a4,-1
 440:	1702                	slli	a4,a4,0x20
 442:	9301                	srli	a4,a4,0x20
 444:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 448:	fff94583          	lbu	a1,-1(s2)
 44c:	8526                	mv	a0,s1
 44e:	f5bff0ef          	jal	3a8 <putc>
  while(--i >= 0)
 452:	197d                	addi	s2,s2,-1
 454:	ff391ae3          	bne	s2,s3,448 <printint+0x82>
 458:	7902                	ld	s2,32(sp)
 45a:	69e2                	ld	s3,24(sp)
}
 45c:	70e2                	ld	ra,56(sp)
 45e:	7442                	ld	s0,48(sp)
 460:	74a2                	ld	s1,40(sp)
 462:	6121                	addi	sp,sp,64
 464:	8082                	ret
    x = -xx;
 466:	40b005bb          	negw	a1,a1
    neg = 1;
 46a:	4885                	li	a7,1
    x = -xx;
 46c:	bf85                	j	3dc <printint+0x16>

000000000000046e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 46e:	711d                	addi	sp,sp,-96
 470:	ec86                	sd	ra,88(sp)
 472:	e8a2                	sd	s0,80(sp)
 474:	e0ca                	sd	s2,64(sp)
 476:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 478:	0005c903          	lbu	s2,0(a1)
 47c:	26090863          	beqz	s2,6ec <vprintf+0x27e>
 480:	e4a6                	sd	s1,72(sp)
 482:	fc4e                	sd	s3,56(sp)
 484:	f852                	sd	s4,48(sp)
 486:	f456                	sd	s5,40(sp)
 488:	f05a                	sd	s6,32(sp)
 48a:	ec5e                	sd	s7,24(sp)
 48c:	e862                	sd	s8,16(sp)
 48e:	e466                	sd	s9,8(sp)
 490:	8b2a                	mv	s6,a0
 492:	8a2e                	mv	s4,a1
 494:	8bb2                	mv	s7,a2
  state = 0;
 496:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 498:	4481                	li	s1,0
 49a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 49c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4a4:	06c00c93          	li	s9,108
 4a8:	a005                	j	4c8 <vprintf+0x5a>
        putc(fd, c0);
 4aa:	85ca                	mv	a1,s2
 4ac:	855a                	mv	a0,s6
 4ae:	efbff0ef          	jal	3a8 <putc>
 4b2:	a019                	j	4b8 <vprintf+0x4a>
    } else if(state == '%'){
 4b4:	03598263          	beq	s3,s5,4d8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4b8:	2485                	addiw	s1,s1,1
 4ba:	8726                	mv	a4,s1
 4bc:	009a07b3          	add	a5,s4,s1
 4c0:	0007c903          	lbu	s2,0(a5)
 4c4:	20090c63          	beqz	s2,6dc <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 4c8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4cc:	fe0994e3          	bnez	s3,4b4 <vprintf+0x46>
      if(c0 == '%'){
 4d0:	fd579de3          	bne	a5,s5,4aa <vprintf+0x3c>
        state = '%';
 4d4:	89be                	mv	s3,a5
 4d6:	b7cd                	j	4b8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4d8:	00ea06b3          	add	a3,s4,a4
 4dc:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4e0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4e2:	c681                	beqz	a3,4ea <vprintf+0x7c>
 4e4:	9752                	add	a4,a4,s4
 4e6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4ea:	03878f63          	beq	a5,s8,528 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 4ee:	05978963          	beq	a5,s9,540 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4f2:	07500713          	li	a4,117
 4f6:	0ee78363          	beq	a5,a4,5dc <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4fa:	07800713          	li	a4,120
 4fe:	12e78563          	beq	a5,a4,628 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 502:	07000713          	li	a4,112
 506:	14e78a63          	beq	a5,a4,65a <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 50a:	07300713          	li	a4,115
 50e:	18e78a63          	beq	a5,a4,6a2 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 512:	02500713          	li	a4,37
 516:	04e79563          	bne	a5,a4,560 <vprintf+0xf2>
        putc(fd, '%');
 51a:	02500593          	li	a1,37
 51e:	855a                	mv	a0,s6
 520:	e89ff0ef          	jal	3a8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 524:	4981                	li	s3,0
 526:	bf49                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 528:	008b8913          	addi	s2,s7,8
 52c:	4685                	li	a3,1
 52e:	4629                	li	a2,10
 530:	000ba583          	lw	a1,0(s7)
 534:	855a                	mv	a0,s6
 536:	e91ff0ef          	jal	3c6 <printint>
 53a:	8bca                	mv	s7,s2
      state = 0;
 53c:	4981                	li	s3,0
 53e:	bfad                	j	4b8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 540:	06400793          	li	a5,100
 544:	02f68963          	beq	a3,a5,576 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 548:	06c00793          	li	a5,108
 54c:	04f68263          	beq	a3,a5,590 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 550:	07500793          	li	a5,117
 554:	0af68063          	beq	a3,a5,5f4 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 558:	07800793          	li	a5,120
 55c:	0ef68263          	beq	a3,a5,640 <vprintf+0x1d2>
        putc(fd, '%');
 560:	02500593          	li	a1,37
 564:	855a                	mv	a0,s6
 566:	e43ff0ef          	jal	3a8 <putc>
        putc(fd, c0);
 56a:	85ca                	mv	a1,s2
 56c:	855a                	mv	a0,s6
 56e:	e3bff0ef          	jal	3a8 <putc>
      state = 0;
 572:	4981                	li	s3,0
 574:	b791                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 576:	008b8913          	addi	s2,s7,8
 57a:	4685                	li	a3,1
 57c:	4629                	li	a2,10
 57e:	000ba583          	lw	a1,0(s7)
 582:	855a                	mv	a0,s6
 584:	e43ff0ef          	jal	3c6 <printint>
        i += 1;
 588:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 58a:	8bca                	mv	s7,s2
      state = 0;
 58c:	4981                	li	s3,0
        i += 1;
 58e:	b72d                	j	4b8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 590:	06400793          	li	a5,100
 594:	02f60763          	beq	a2,a5,5c2 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 598:	07500793          	li	a5,117
 59c:	06f60963          	beq	a2,a5,60e <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5a0:	07800793          	li	a5,120
 5a4:	faf61ee3          	bne	a2,a5,560 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5a8:	008b8913          	addi	s2,s7,8
 5ac:	4681                	li	a3,0
 5ae:	4641                	li	a2,16
 5b0:	000ba583          	lw	a1,0(s7)
 5b4:	855a                	mv	a0,s6
 5b6:	e11ff0ef          	jal	3c6 <printint>
        i += 2;
 5ba:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5bc:	8bca                	mv	s7,s2
      state = 0;
 5be:	4981                	li	s3,0
        i += 2;
 5c0:	bde5                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000ba583          	lw	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	df7ff0ef          	jal	3c6 <printint>
        i += 2;
 5d4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
        i += 2;
 5da:	bdf9                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5dc:	008b8913          	addi	s2,s7,8
 5e0:	4681                	li	a3,0
 5e2:	4629                	li	a2,10
 5e4:	000ba583          	lw	a1,0(s7)
 5e8:	855a                	mv	a0,s6
 5ea:	dddff0ef          	jal	3c6 <printint>
 5ee:	8bca                	mv	s7,s2
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b5d9                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4629                	li	a2,10
 5fc:	000ba583          	lw	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	dc5ff0ef          	jal	3c6 <printint>
        i += 1;
 606:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 608:	8bca                	mv	s7,s2
      state = 0;
 60a:	4981                	li	s3,0
        i += 1;
 60c:	b575                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60e:	008b8913          	addi	s2,s7,8
 612:	4681                	li	a3,0
 614:	4629                	li	a2,10
 616:	000ba583          	lw	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	dabff0ef          	jal	3c6 <printint>
        i += 2;
 620:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 2;
 626:	bd49                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 628:	008b8913          	addi	s2,s7,8
 62c:	4681                	li	a3,0
 62e:	4641                	li	a2,16
 630:	000ba583          	lw	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	d91ff0ef          	jal	3c6 <printint>
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bdad                	j	4b8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 640:	008b8913          	addi	s2,s7,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000ba583          	lw	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	d79ff0ef          	jal	3c6 <printint>
        i += 1;
 652:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
        i += 1;
 658:	b585                	j	4b8 <vprintf+0x4a>
 65a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 65c:	008b8d13          	addi	s10,s7,8
 660:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 664:	03000593          	li	a1,48
 668:	855a                	mv	a0,s6
 66a:	d3fff0ef          	jal	3a8 <putc>
  putc(fd, 'x');
 66e:	07800593          	li	a1,120
 672:	855a                	mv	a0,s6
 674:	d35ff0ef          	jal	3a8 <putc>
 678:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67a:	00000b97          	auipc	s7,0x0
 67e:	2eeb8b93          	addi	s7,s7,750 # 968 <digits>
 682:	03c9d793          	srli	a5,s3,0x3c
 686:	97de                	add	a5,a5,s7
 688:	0007c583          	lbu	a1,0(a5)
 68c:	855a                	mv	a0,s6
 68e:	d1bff0ef          	jal	3a8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 692:	0992                	slli	s3,s3,0x4
 694:	397d                	addiw	s2,s2,-1
 696:	fe0916e3          	bnez	s2,682 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 69a:	8bea                	mv	s7,s10
      state = 0;
 69c:	4981                	li	s3,0
 69e:	6d02                	ld	s10,0(sp)
 6a0:	bd21                	j	4b8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6a2:	008b8993          	addi	s3,s7,8
 6a6:	000bb903          	ld	s2,0(s7)
 6aa:	00090f63          	beqz	s2,6c8 <vprintf+0x25a>
        for(; *s; s++)
 6ae:	00094583          	lbu	a1,0(s2)
 6b2:	c195                	beqz	a1,6d6 <vprintf+0x268>
          putc(fd, *s);
 6b4:	855a                	mv	a0,s6
 6b6:	cf3ff0ef          	jal	3a8 <putc>
        for(; *s; s++)
 6ba:	0905                	addi	s2,s2,1
 6bc:	00094583          	lbu	a1,0(s2)
 6c0:	f9f5                	bnez	a1,6b4 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6c2:	8bce                	mv	s7,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bbcd                	j	4b8 <vprintf+0x4a>
          s = "(null)";
 6c8:	00000917          	auipc	s2,0x0
 6cc:	29890913          	addi	s2,s2,664 # 960 <malloc+0x18c>
        for(; *s; s++)
 6d0:	02800593          	li	a1,40
 6d4:	b7c5                	j	6b4 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6d6:	8bce                	mv	s7,s3
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bbf9                	j	4b8 <vprintf+0x4a>
 6dc:	64a6                	ld	s1,72(sp)
 6de:	79e2                	ld	s3,56(sp)
 6e0:	7a42                	ld	s4,48(sp)
 6e2:	7aa2                	ld	s5,40(sp)
 6e4:	7b02                	ld	s6,32(sp)
 6e6:	6be2                	ld	s7,24(sp)
 6e8:	6c42                	ld	s8,16(sp)
 6ea:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6ec:	60e6                	ld	ra,88(sp)
 6ee:	6446                	ld	s0,80(sp)
 6f0:	6906                	ld	s2,64(sp)
 6f2:	6125                	addi	sp,sp,96
 6f4:	8082                	ret

00000000000006f6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6f6:	715d                	addi	sp,sp,-80
 6f8:	ec06                	sd	ra,24(sp)
 6fa:	e822                	sd	s0,16(sp)
 6fc:	1000                	addi	s0,sp,32
 6fe:	e010                	sd	a2,0(s0)
 700:	e414                	sd	a3,8(s0)
 702:	e818                	sd	a4,16(s0)
 704:	ec1c                	sd	a5,24(s0)
 706:	03043023          	sd	a6,32(s0)
 70a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 70e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 712:	8622                	mv	a2,s0
 714:	d5bff0ef          	jal	46e <vprintf>
}
 718:	60e2                	ld	ra,24(sp)
 71a:	6442                	ld	s0,16(sp)
 71c:	6161                	addi	sp,sp,80
 71e:	8082                	ret

0000000000000720 <printf>:

void
printf(const char *fmt, ...)
{
 720:	711d                	addi	sp,sp,-96
 722:	ec06                	sd	ra,24(sp)
 724:	e822                	sd	s0,16(sp)
 726:	1000                	addi	s0,sp,32
 728:	e40c                	sd	a1,8(s0)
 72a:	e810                	sd	a2,16(s0)
 72c:	ec14                	sd	a3,24(s0)
 72e:	f018                	sd	a4,32(s0)
 730:	f41c                	sd	a5,40(s0)
 732:	03043823          	sd	a6,48(s0)
 736:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 73a:	00840613          	addi	a2,s0,8
 73e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 742:	85aa                	mv	a1,a0
 744:	4505                	li	a0,1
 746:	d29ff0ef          	jal	46e <vprintf>
}
 74a:	60e2                	ld	ra,24(sp)
 74c:	6442                	ld	s0,16(sp)
 74e:	6125                	addi	sp,sp,96
 750:	8082                	ret

0000000000000752 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 752:	1141                	addi	sp,sp,-16
 754:	e422                	sd	s0,8(sp)
 756:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 758:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	00001797          	auipc	a5,0x1
 760:	8a47b783          	ld	a5,-1884(a5) # 1000 <freep>
 764:	a02d                	j	78e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 766:	4618                	lw	a4,8(a2)
 768:	9f2d                	addw	a4,a4,a1
 76a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 76e:	6398                	ld	a4,0(a5)
 770:	6310                	ld	a2,0(a4)
 772:	a83d                	j	7b0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 774:	ff852703          	lw	a4,-8(a0)
 778:	9f31                	addw	a4,a4,a2
 77a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 77c:	ff053683          	ld	a3,-16(a0)
 780:	a091                	j	7c4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 782:	6398                	ld	a4,0(a5)
 784:	00e7e463          	bltu	a5,a4,78c <free+0x3a>
 788:	00e6ea63          	bltu	a3,a4,79c <free+0x4a>
{
 78c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78e:	fed7fae3          	bgeu	a5,a3,782 <free+0x30>
 792:	6398                	ld	a4,0(a5)
 794:	00e6e463          	bltu	a3,a4,79c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 798:	fee7eae3          	bltu	a5,a4,78c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 79c:	ff852583          	lw	a1,-8(a0)
 7a0:	6390                	ld	a2,0(a5)
 7a2:	02059813          	slli	a6,a1,0x20
 7a6:	01c85713          	srli	a4,a6,0x1c
 7aa:	9736                	add	a4,a4,a3
 7ac:	fae60de3          	beq	a2,a4,766 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7b0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7b4:	4790                	lw	a2,8(a5)
 7b6:	02061593          	slli	a1,a2,0x20
 7ba:	01c5d713          	srli	a4,a1,0x1c
 7be:	973e                	add	a4,a4,a5
 7c0:	fae68ae3          	beq	a3,a4,774 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7c4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c6:	00001717          	auipc	a4,0x1
 7ca:	82f73d23          	sd	a5,-1990(a4) # 1000 <freep>
}
 7ce:	6422                	ld	s0,8(sp)
 7d0:	0141                	addi	sp,sp,16
 7d2:	8082                	ret

00000000000007d4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7d4:	7139                	addi	sp,sp,-64
 7d6:	fc06                	sd	ra,56(sp)
 7d8:	f822                	sd	s0,48(sp)
 7da:	f426                	sd	s1,40(sp)
 7dc:	ec4e                	sd	s3,24(sp)
 7de:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e0:	02051493          	slli	s1,a0,0x20
 7e4:	9081                	srli	s1,s1,0x20
 7e6:	04bd                	addi	s1,s1,15
 7e8:	8091                	srli	s1,s1,0x4
 7ea:	0014899b          	addiw	s3,s1,1
 7ee:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7f0:	00001517          	auipc	a0,0x1
 7f4:	81053503          	ld	a0,-2032(a0) # 1000 <freep>
 7f8:	c915                	beqz	a0,82c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fc:	4798                	lw	a4,8(a5)
 7fe:	08977a63          	bgeu	a4,s1,892 <malloc+0xbe>
 802:	f04a                	sd	s2,32(sp)
 804:	e852                	sd	s4,16(sp)
 806:	e456                	sd	s5,8(sp)
 808:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 80a:	8a4e                	mv	s4,s3
 80c:	0009871b          	sext.w	a4,s3
 810:	6685                	lui	a3,0x1
 812:	00d77363          	bgeu	a4,a3,818 <malloc+0x44>
 816:	6a05                	lui	s4,0x1
 818:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 81c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 820:	00000917          	auipc	s2,0x0
 824:	7e090913          	addi	s2,s2,2016 # 1000 <freep>
  if(p == (char*)-1)
 828:	5afd                	li	s5,-1
 82a:	a081                	j	86a <malloc+0x96>
 82c:	f04a                	sd	s2,32(sp)
 82e:	e852                	sd	s4,16(sp)
 830:	e456                	sd	s5,8(sp)
 832:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 834:	00000797          	auipc	a5,0x0
 838:	7dc78793          	addi	a5,a5,2012 # 1010 <base>
 83c:	00000717          	auipc	a4,0x0
 840:	7cf73223          	sd	a5,1988(a4) # 1000 <freep>
 844:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 846:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 84a:	b7c1                	j	80a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 84c:	6398                	ld	a4,0(a5)
 84e:	e118                	sd	a4,0(a0)
 850:	a8a9                	j	8aa <malloc+0xd6>
  hp->s.size = nu;
 852:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 856:	0541                	addi	a0,a0,16
 858:	efbff0ef          	jal	752 <free>
  return freep;
 85c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 860:	c12d                	beqz	a0,8c2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 862:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 864:	4798                	lw	a4,8(a5)
 866:	02977263          	bgeu	a4,s1,88a <malloc+0xb6>
    if(p == freep)
 86a:	00093703          	ld	a4,0(s2)
 86e:	853e                	mv	a0,a5
 870:	fef719e3          	bne	a4,a5,862 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 874:	8552                	mv	a0,s4
 876:	af3ff0ef          	jal	368 <sbrk>
  if(p == (char*)-1)
 87a:	fd551ce3          	bne	a0,s5,852 <malloc+0x7e>
        return 0;
 87e:	4501                	li	a0,0
 880:	7902                	ld	s2,32(sp)
 882:	6a42                	ld	s4,16(sp)
 884:	6aa2                	ld	s5,8(sp)
 886:	6b02                	ld	s6,0(sp)
 888:	a03d                	j	8b6 <malloc+0xe2>
 88a:	7902                	ld	s2,32(sp)
 88c:	6a42                	ld	s4,16(sp)
 88e:	6aa2                	ld	s5,8(sp)
 890:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 892:	fae48de3          	beq	s1,a4,84c <malloc+0x78>
        p->s.size -= nunits;
 896:	4137073b          	subw	a4,a4,s3
 89a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89c:	02071693          	slli	a3,a4,0x20
 8a0:	01c6d713          	srli	a4,a3,0x1c
 8a4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8aa:	00000717          	auipc	a4,0x0
 8ae:	74a73b23          	sd	a0,1878(a4) # 1000 <freep>
      return (void*)(p + 1);
 8b2:	01078513          	addi	a0,a5,16
  }
}
 8b6:	70e2                	ld	ra,56(sp)
 8b8:	7442                	ld	s0,48(sp)
 8ba:	74a2                	ld	s1,40(sp)
 8bc:	69e2                	ld	s3,24(sp)
 8be:	6121                	addi	sp,sp,64
 8c0:	8082                	ret
 8c2:	7902                	ld	s2,32(sp)
 8c4:	6a42                	ld	s4,16(sp)
 8c6:	6aa2                	ld	s5,8(sp)
 8c8:	6b02                	ld	s6,0(sp)
 8ca:	b7f5                	j	8b6 <malloc+0xe2>
