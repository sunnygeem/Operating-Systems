
user/_test_swtch:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fork_children>:
int parent;

char cmd;

int fork_children()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	4491                	li	s1,4
  int i, p;
  for (i = 0; i < NUM_THREAD; i++) {
    p = fork();
   c:	47a000ef          	jal	486 <fork>
    if (p == 0)
  10:	cd01                	beqz	a0,28 <fork_children+0x28>
  for (i = 0; i < NUM_THREAD; i++) {
  12:	34fd                	addiw	s1,s1,-1
  14:	fce5                	bnez	s1,c <fork_children+0xc>
    {
      sleep(10);
      return getpid();
    }
  }
  return parent;
  16:	00001517          	auipc	a0,0x1
  1a:	fee52503          	lw	a0,-18(a0) # 1004 <parent>
}
  1e:	60e2                	ld	ra,24(sp)
  20:	6442                	ld	s0,16(sp)
  22:	64a2                	ld	s1,8(sp)
  24:	6105                	addi	sp,sp,32
  26:	8082                	ret
      sleep(10);
  28:	4529                	li	a0,10
  2a:	4f4000ef          	jal	51e <sleep>
      return getpid();
  2e:	4e0000ef          	jal	50e <getpid>
  32:	b7f5                	j	1e <fork_children+0x1e>

0000000000000034 <exit_children>:

void exit_children()
{
  34:	1101                	addi	sp,sp,-32
  36:	ec06                	sd	ra,24(sp)
  38:	e822                	sd	s0,16(sp)
  3a:	e426                	sd	s1,8(sp)
  3c:	1000                	addi	s0,sp,32
  if (getpid() != parent) {
  3e:	4d0000ef          	jal	50e <getpid>
  42:	00001797          	auipc	a5,0x1
  46:	fc27a783          	lw	a5,-62(a5) # 1004 <parent>
    exit(0);
  }
  while (wait(0) != -1);
  4a:	54fd                	li	s1,-1
  if (getpid() != parent) {
  4c:	00a79c63          	bne	a5,a0,64 <exit_children+0x30>
  while (wait(0) != -1);
  50:	4501                	li	a0,0
  52:	444000ef          	jal	496 <wait>
  56:	fe951de3          	bne	a0,s1,50 <exit_children+0x1c>
}
  5a:	60e2                	ld	ra,24(sp)
  5c:	6442                	ld	s0,16(sp)
  5e:	64a2                	ld	s1,8(sp)
  60:	6105                	addi	sp,sp,32
  62:	8082                	ret
    exit(0);
  64:	4501                	li	a0,0
  66:	428000ef          	jal	48e <exit>

000000000000006a <main>:

int main(int argc, char* argv[]) {
  6a:	715d                	addi	sp,sp,-80
  6c:	e486                	sd	ra,72(sp)
  6e:	e0a2                	sd	s0,64(sp)
  70:	fc26                	sd	s1,56(sp)
  72:	0880                	addi	s0,sp,80
  74:	84ae                	mv	s1,a1
    fprintf(1, "Switching mode to ");
  76:	00001597          	auipc	a1,0x1
  7a:	a0a58593          	addi	a1,a1,-1526 # a80 <malloc+0xfe>
  7e:	4505                	li	a0,1
  80:	025000ef          	jal	8a4 <fprintf>
    cmd = argv[1][0];
  84:	649c                	ld	a5,8(s1)
  86:	0007c783          	lbu	a5,0(a5)
  8a:	00001717          	auipc	a4,0x1
  8e:	f6f70b23          	sb	a5,-138(a4) # 1000 <cmd>

    int ret = 1;

    if(cmd == '0'){
  92:	03000713          	li	a4,48
  96:	00e78c63          	beq	a5,a4,ae <main+0x44>
        fprintf(1, "FCFS mode\n");
        ret = fcfsmode();
    }
    else if(cmd == '1'){
  9a:	03100713          	li	a4,49
  9e:	04e78363          	beq	a5,a4,e4 <main+0x7a>
    else if(ret == -1){
        fprintf(1, "System is already in %c mode", cmd);
    }

    return 0;
}
  a2:	4501                	li	a0,0
  a4:	60a6                	ld	ra,72(sp)
  a6:	6406                	ld	s0,64(sp)
  a8:	74e2                	ld	s1,56(sp)
  aa:	6161                	addi	sp,sp,80
  ac:	8082                	ret
  ae:	f44e                	sd	s3,40(sp)
        fprintf(1, "FCFS mode\n");
  b0:	00001597          	auipc	a1,0x1
  b4:	9e858593          	addi	a1,a1,-1560 # a98 <malloc+0x116>
  b8:	4505                	li	a0,1
  ba:	7ea000ef          	jal	8a4 <fprintf>
        ret = fcfsmode();
  be:	490000ef          	jal	54e <fcfsmode>
  c2:	89aa                	mv	s3,a0
    if(ret == 0){
  c4:	12099e63          	bnez	s3,200 <main+0x196>
        if(cmd == '1'){
  c8:	00001797          	auipc	a5,0x1
  cc:	f387c783          	lbu	a5,-200(a5) # 1000 <cmd>
  d0:	03100713          	li	a4,49
  d4:	02e78463          	beq	a5,a4,fc <main+0x92>
        else if(cmd == '0'){
  d8:	03000713          	li	a4,48
  dc:	0ce78963          	beq	a5,a4,1ae <main+0x144>
  e0:	79a2                	ld	s3,40(sp)
  e2:	b7c1                	j	a2 <main+0x38>
  e4:	f44e                	sd	s3,40(sp)
        fprintf(1, "MLFQ mode\n");
  e6:	00001597          	auipc	a1,0x1
  ea:	9c258593          	addi	a1,a1,-1598 # aa8 <malloc+0x126>
  ee:	4505                	li	a0,1
  f0:	7b4000ef          	jal	8a4 <fprintf>
        ret = mlfqmode();
  f4:	452000ef          	jal	546 <mlfqmode>
  f8:	89aa                	mv	s3,a0
  fa:	b7e9                	j	c4 <main+0x5a>
  fc:	f052                	sd	s4,32(sp)
            parent = getpid();
  fe:	410000ef          	jal	50e <getpid>
 102:	00001497          	auipc	s1,0x1
 106:	f0248493          	addi	s1,s1,-254 # 1004 <parent>
 10a:	c088                	sw	a0,0(s1)
            int count[MAX_LEVEL] = { 0, 0, 0 };
 10c:	fa042823          	sw	zero,-80(s0)
 110:	fa042a23          	sw	zero,-76(s0)
 114:	fa042c23          	sw	zero,-72(s0)
            pid = fork_children();
 118:	ee9ff0ef          	jal	0 <fork_children>
 11c:	8a2a                	mv	s4,a0
            if (pid != parent)
 11e:	409c                	lw	a5,0(s1)
 120:	06a78763          	beq	a5,a0,18e <main+0x124>
 124:	f84a                	sd	s2,48(sp)
 126:	ec56                	sd	s5,24(sp)
 128:	64e1                	lui	s1,0x18
 12a:	6a048493          	addi	s1,s1,1696 # 186a0 <base+0x17690>
                if (x < 0 || x > 2)
 12e:	4909                	li	s2,2
                int x = getlev();
 130:	406000ef          	jal	536 <getlev>
                if (x < 0 || x > 2)
 134:	0005079b          	sext.w	a5,a0
 138:	06f96063          	bltu	s2,a5,198 <main+0x12e>
                count[x]++;
 13c:	00251613          	slli	a2,a0,0x2
 140:	fc060793          	addi	a5,a2,-64
 144:	00878633          	add	a2,a5,s0
 148:	ff062783          	lw	a5,-16(a2)
 14c:	2785                	addiw	a5,a5,1
 14e:	fef62823          	sw	a5,-16(a2)
            for (i = 0; i < NUM_LOOP; i++)
 152:	34fd                	addiw	s1,s1,-1
 154:	fcf1                	bnez	s1,130 <main+0xc6>
            fprintf(1, "Process %d\n", pid);
 156:	8652                	mv	a2,s4
 158:	00001597          	auipc	a1,0x1
 15c:	97858593          	addi	a1,a1,-1672 # ad0 <malloc+0x14e>
 160:	4505                	li	a0,1
 162:	742000ef          	jal	8a4 <fprintf>
            for (i = 0; i < MAX_LEVEL; i++)
 166:	fb040493          	addi	s1,s0,-80
                fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 16a:	00001a97          	auipc	s5,0x1
 16e:	976a8a93          	addi	s5,s5,-1674 # ae0 <malloc+0x15e>
            for (i = 0; i < MAX_LEVEL; i++)
 172:	490d                	li	s2,3
                fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 174:	4098                	lw	a4,0(s1)
 176:	86ce                	mv	a3,s3
 178:	8652                	mv	a2,s4
 17a:	85d6                	mv	a1,s5
 17c:	4505                	li	a0,1
 17e:	726000ef          	jal	8a4 <fprintf>
            for (i = 0; i < MAX_LEVEL; i++)
 182:	2985                	addiw	s3,s3,1
 184:	0491                	addi	s1,s1,4
 186:	ff2997e3          	bne	s3,s2,174 <main+0x10a>
 18a:	7942                	ld	s2,48(sp)
 18c:	6ae2                	ld	s5,24(sp)
            exit_children();
 18e:	ea7ff0ef          	jal	34 <exit_children>
 192:	79a2                	ld	s3,40(sp)
 194:	7a02                	ld	s4,32(sp)
 196:	b731                	j	a2 <main+0x38>
                fprintf(1, "Wrong level: %d\n", x);
 198:	862a                	mv	a2,a0
 19a:	00001597          	auipc	a1,0x1
 19e:	91e58593          	addi	a1,a1,-1762 # ab8 <malloc+0x136>
 1a2:	4505                	li	a0,1
 1a4:	700000ef          	jal	8a4 <fprintf>
                exit(0);
 1a8:	4501                	li	a0,0
 1aa:	2e4000ef          	jal	48e <exit>
            fprintf(2, "=== FCFS Scheduler Test ===\n");
 1ae:	00001597          	auipc	a1,0x1
 1b2:	94a58593          	addi	a1,a1,-1718 # af8 <malloc+0x176>
 1b6:	4509                	li	a0,2
 1b8:	6ec000ef          	jal	8a4 <fprintf>
 1bc:	4491                	li	s1,4
                pid = fork();
 1be:	2c8000ef          	jal	486 <fork>
                if (pid == 0) {
 1c2:	cd19                	beqz	a0,1e0 <main+0x176>
            for (int i = 0; i < NUM_THREAD; i++) {
 1c4:	34fd                	addiw	s1,s1,-1
 1c6:	fce5                	bnez	s1,1be <main+0x154>
 1c8:	f84a                	sd	s2,48(sp)
 1ca:	f052                	sd	s4,32(sp)
 1cc:	ec56                	sd	s5,24(sp)
            while (wait(0) != -1);
 1ce:	54fd                	li	s1,-1
 1d0:	4501                	li	a0,0
 1d2:	2c4000ef          	jal	496 <wait>
 1d6:	fe951de3          	bne	a0,s1,1d0 <main+0x166>
            exit(0);
 1da:	4501                	li	a0,0
 1dc:	2b2000ef          	jal	48e <exit>
 1e0:	f84a                	sd	s2,48(sp)
 1e2:	f052                	sd	s4,32(sp)
 1e4:	ec56                	sd	s5,24(sp)
                int pid_child = getpid();
 1e6:	328000ef          	jal	50e <getpid>
 1ea:	862a                	mv	a2,a0
                fprintf(1, "process %d finished\n", pid_child);
 1ec:	00001597          	auipc	a1,0x1
 1f0:	92c58593          	addi	a1,a1,-1748 # b18 <malloc+0x196>
 1f4:	4505                	li	a0,1
 1f6:	6ae000ef          	jal	8a4 <fprintf>
                exit(0);
 1fa:	4501                	li	a0,0
 1fc:	292000ef          	jal	48e <exit>
    else if(ret == -1){
 200:	57fd                	li	a5,-1
 202:	00f99f63          	bne	s3,a5,220 <main+0x1b6>
        fprintf(1, "System is already in %c mode", cmd);
 206:	00001617          	auipc	a2,0x1
 20a:	dfa64603          	lbu	a2,-518(a2) # 1000 <cmd>
 20e:	00001597          	auipc	a1,0x1
 212:	92258593          	addi	a1,a1,-1758 # b30 <malloc+0x1ae>
 216:	4505                	li	a0,1
 218:	68c000ef          	jal	8a4 <fprintf>
 21c:	79a2                	ld	s3,40(sp)
 21e:	b551                	j	a2 <main+0x38>
 220:	79a2                	ld	s3,40(sp)
 222:	b541                	j	a2 <main+0x38>

0000000000000224 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 224:	1141                	addi	sp,sp,-16
 226:	e406                	sd	ra,8(sp)
 228:	e022                	sd	s0,0(sp)
 22a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 22c:	e3fff0ef          	jal	6a <main>
  exit(0);
 230:	4501                	li	a0,0
 232:	25c000ef          	jal	48e <exit>

0000000000000236 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 23c:	87aa                	mv	a5,a0
 23e:	0585                	addi	a1,a1,1
 240:	0785                	addi	a5,a5,1
 242:	fff5c703          	lbu	a4,-1(a1)
 246:	fee78fa3          	sb	a4,-1(a5)
 24a:	fb75                	bnez	a4,23e <strcpy+0x8>
    ;
  return os;
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 258:	00054783          	lbu	a5,0(a0)
 25c:	cb91                	beqz	a5,270 <strcmp+0x1e>
 25e:	0005c703          	lbu	a4,0(a1)
 262:	00f71763          	bne	a4,a5,270 <strcmp+0x1e>
    p++, q++;
 266:	0505                	addi	a0,a0,1
 268:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 26a:	00054783          	lbu	a5,0(a0)
 26e:	fbe5                	bnez	a5,25e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 270:	0005c503          	lbu	a0,0(a1)
}
 274:	40a7853b          	subw	a0,a5,a0
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	addi	sp,sp,16
 27c:	8082                	ret

000000000000027e <strlen>:

uint
strlen(const char *s)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 284:	00054783          	lbu	a5,0(a0)
 288:	cf91                	beqz	a5,2a4 <strlen+0x26>
 28a:	0505                	addi	a0,a0,1
 28c:	87aa                	mv	a5,a0
 28e:	86be                	mv	a3,a5
 290:	0785                	addi	a5,a5,1
 292:	fff7c703          	lbu	a4,-1(a5)
 296:	ff65                	bnez	a4,28e <strlen+0x10>
 298:	40a6853b          	subw	a0,a3,a0
 29c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  for(n = 0; s[n]; n++)
 2a4:	4501                	li	a0,0
 2a6:	bfe5                	j	29e <strlen+0x20>

00000000000002a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2ae:	ca19                	beqz	a2,2c4 <memset+0x1c>
 2b0:	87aa                	mv	a5,a0
 2b2:	1602                	slli	a2,a2,0x20
 2b4:	9201                	srli	a2,a2,0x20
 2b6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2ba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2be:	0785                	addi	a5,a5,1
 2c0:	fee79de3          	bne	a5,a4,2ba <memset+0x12>
  }
  return dst;
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <strchr>:

char*
strchr(const char *s, char c)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2d0:	00054783          	lbu	a5,0(a0)
 2d4:	cb99                	beqz	a5,2ea <strchr+0x20>
    if(*s == c)
 2d6:	00f58763          	beq	a1,a5,2e4 <strchr+0x1a>
  for(; *s; s++)
 2da:	0505                	addi	a0,a0,1
 2dc:	00054783          	lbu	a5,0(a0)
 2e0:	fbfd                	bnez	a5,2d6 <strchr+0xc>
      return (char*)s;
  return 0;
 2e2:	4501                	li	a0,0
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <strchr+0x1a>

00000000000002ee <gets>:

char*
gets(char *buf, int max)
{
 2ee:	711d                	addi	sp,sp,-96
 2f0:	ec86                	sd	ra,88(sp)
 2f2:	e8a2                	sd	s0,80(sp)
 2f4:	e4a6                	sd	s1,72(sp)
 2f6:	e0ca                	sd	s2,64(sp)
 2f8:	fc4e                	sd	s3,56(sp)
 2fa:	f852                	sd	s4,48(sp)
 2fc:	f456                	sd	s5,40(sp)
 2fe:	f05a                	sd	s6,32(sp)
 300:	ec5e                	sd	s7,24(sp)
 302:	1080                	addi	s0,sp,96
 304:	8baa                	mv	s7,a0
 306:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 308:	892a                	mv	s2,a0
 30a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 30c:	4aa9                	li	s5,10
 30e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 310:	89a6                	mv	s3,s1
 312:	2485                	addiw	s1,s1,1
 314:	0344d663          	bge	s1,s4,340 <gets+0x52>
    cc = read(0, &c, 1);
 318:	4605                	li	a2,1
 31a:	faf40593          	addi	a1,s0,-81
 31e:	4501                	li	a0,0
 320:	186000ef          	jal	4a6 <read>
    if(cc < 1)
 324:	00a05e63          	blez	a0,340 <gets+0x52>
    buf[i++] = c;
 328:	faf44783          	lbu	a5,-81(s0)
 32c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 330:	01578763          	beq	a5,s5,33e <gets+0x50>
 334:	0905                	addi	s2,s2,1
 336:	fd679de3          	bne	a5,s6,310 <gets+0x22>
    buf[i++] = c;
 33a:	89a6                	mv	s3,s1
 33c:	a011                	j	340 <gets+0x52>
 33e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 340:	99de                	add	s3,s3,s7
 342:	00098023          	sb	zero,0(s3)
  return buf;
}
 346:	855e                	mv	a0,s7
 348:	60e6                	ld	ra,88(sp)
 34a:	6446                	ld	s0,80(sp)
 34c:	64a6                	ld	s1,72(sp)
 34e:	6906                	ld	s2,64(sp)
 350:	79e2                	ld	s3,56(sp)
 352:	7a42                	ld	s4,48(sp)
 354:	7aa2                	ld	s5,40(sp)
 356:	7b02                	ld	s6,32(sp)
 358:	6be2                	ld	s7,24(sp)
 35a:	6125                	addi	sp,sp,96
 35c:	8082                	ret

000000000000035e <stat>:

int
stat(const char *n, struct stat *st)
{
 35e:	1101                	addi	sp,sp,-32
 360:	ec06                	sd	ra,24(sp)
 362:	e822                	sd	s0,16(sp)
 364:	e04a                	sd	s2,0(sp)
 366:	1000                	addi	s0,sp,32
 368:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 36a:	4581                	li	a1,0
 36c:	162000ef          	jal	4ce <open>
  if(fd < 0)
 370:	02054263          	bltz	a0,394 <stat+0x36>
 374:	e426                	sd	s1,8(sp)
 376:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 378:	85ca                	mv	a1,s2
 37a:	16c000ef          	jal	4e6 <fstat>
 37e:	892a                	mv	s2,a0
  close(fd);
 380:	8526                	mv	a0,s1
 382:	134000ef          	jal	4b6 <close>
  return r;
 386:	64a2                	ld	s1,8(sp)
}
 388:	854a                	mv	a0,s2
 38a:	60e2                	ld	ra,24(sp)
 38c:	6442                	ld	s0,16(sp)
 38e:	6902                	ld	s2,0(sp)
 390:	6105                	addi	sp,sp,32
 392:	8082                	ret
    return -1;
 394:	597d                	li	s2,-1
 396:	bfcd                	j	388 <stat+0x2a>

0000000000000398 <atoi>:

int
atoi(const char *s)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 39e:	00054683          	lbu	a3,0(a0)
 3a2:	fd06879b          	addiw	a5,a3,-48
 3a6:	0ff7f793          	zext.b	a5,a5
 3aa:	4625                	li	a2,9
 3ac:	02f66863          	bltu	a2,a5,3dc <atoi+0x44>
 3b0:	872a                	mv	a4,a0
  n = 0;
 3b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3b4:	0705                	addi	a4,a4,1
 3b6:	0025179b          	slliw	a5,a0,0x2
 3ba:	9fa9                	addw	a5,a5,a0
 3bc:	0017979b          	slliw	a5,a5,0x1
 3c0:	9fb5                	addw	a5,a5,a3
 3c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3c6:	00074683          	lbu	a3,0(a4)
 3ca:	fd06879b          	addiw	a5,a3,-48
 3ce:	0ff7f793          	zext.b	a5,a5
 3d2:	fef671e3          	bgeu	a2,a5,3b4 <atoi+0x1c>
  return n;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
  n = 0;
 3dc:	4501                	li	a0,0
 3de:	bfe5                	j	3d6 <atoi+0x3e>

00000000000003e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3e6:	02b57463          	bgeu	a0,a1,40e <memmove+0x2e>
    while(n-- > 0)
 3ea:	00c05f63          	blez	a2,408 <memmove+0x28>
 3ee:	1602                	slli	a2,a2,0x20
 3f0:	9201                	srli	a2,a2,0x20
 3f2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3f6:	872a                	mv	a4,a0
      *dst++ = *src++;
 3f8:	0585                	addi	a1,a1,1
 3fa:	0705                	addi	a4,a4,1
 3fc:	fff5c683          	lbu	a3,-1(a1)
 400:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 404:	fef71ae3          	bne	a4,a5,3f8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 408:	6422                	ld	s0,8(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
    dst += n;
 40e:	00c50733          	add	a4,a0,a2
    src += n;
 412:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 414:	fec05ae3          	blez	a2,408 <memmove+0x28>
 418:	fff6079b          	addiw	a5,a2,-1
 41c:	1782                	slli	a5,a5,0x20
 41e:	9381                	srli	a5,a5,0x20
 420:	fff7c793          	not	a5,a5
 424:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 426:	15fd                	addi	a1,a1,-1
 428:	177d                	addi	a4,a4,-1
 42a:	0005c683          	lbu	a3,0(a1)
 42e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 432:	fee79ae3          	bne	a5,a4,426 <memmove+0x46>
 436:	bfc9                	j	408 <memmove+0x28>

0000000000000438 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 438:	1141                	addi	sp,sp,-16
 43a:	e422                	sd	s0,8(sp)
 43c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 43e:	ca05                	beqz	a2,46e <memcmp+0x36>
 440:	fff6069b          	addiw	a3,a2,-1
 444:	1682                	slli	a3,a3,0x20
 446:	9281                	srli	a3,a3,0x20
 448:	0685                	addi	a3,a3,1
 44a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 44c:	00054783          	lbu	a5,0(a0)
 450:	0005c703          	lbu	a4,0(a1)
 454:	00e79863          	bne	a5,a4,464 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 458:	0505                	addi	a0,a0,1
    p2++;
 45a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 45c:	fed518e3          	bne	a0,a3,44c <memcmp+0x14>
  }
  return 0;
 460:	4501                	li	a0,0
 462:	a019                	j	468 <memcmp+0x30>
      return *p1 - *p2;
 464:	40e7853b          	subw	a0,a5,a4
}
 468:	6422                	ld	s0,8(sp)
 46a:	0141                	addi	sp,sp,16
 46c:	8082                	ret
  return 0;
 46e:	4501                	li	a0,0
 470:	bfe5                	j	468 <memcmp+0x30>

0000000000000472 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 472:	1141                	addi	sp,sp,-16
 474:	e406                	sd	ra,8(sp)
 476:	e022                	sd	s0,0(sp)
 478:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 47a:	f67ff0ef          	jal	3e0 <memmove>
}
 47e:	60a2                	ld	ra,8(sp)
 480:	6402                	ld	s0,0(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret

0000000000000486 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 486:	4885                	li	a7,1
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <exit>:
.global exit
exit:
 li a7, SYS_exit
 48e:	4889                	li	a7,2
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <wait>:
.global wait
wait:
 li a7, SYS_wait
 496:	488d                	li	a7,3
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 49e:	4891                	li	a7,4
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <read>:
.global read
read:
 li a7, SYS_read
 4a6:	4895                	li	a7,5
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <write>:
.global write
write:
 li a7, SYS_write
 4ae:	48c1                	li	a7,16
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <close>:
.global close
close:
 li a7, SYS_close
 4b6:	48d5                	li	a7,21
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <kill>:
.global kill
kill:
 li a7, SYS_kill
 4be:	4899                	li	a7,6
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c6:	489d                	li	a7,7
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <open>:
.global open
open:
 li a7, SYS_open
 4ce:	48bd                	li	a7,15
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d6:	48c5                	li	a7,17
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4de:	48c9                	li	a7,18
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e6:	48a1                	li	a7,8
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <link>:
.global link
link:
 li a7, SYS_link
 4ee:	48cd                	li	a7,19
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f6:	48d1                	li	a7,20
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4fe:	48a5                	li	a7,9
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <dup>:
.global dup
dup:
 li a7, SYS_dup
 506:	48a9                	li	a7,10
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 50e:	48ad                	li	a7,11
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 516:	48b1                	li	a7,12
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 51e:	48b5                	li	a7,13
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 526:	48b9                	li	a7,14
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 52e:	48d9                	li	a7,22
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <getlev>:
.global getlev
getlev:
 li a7, SYS_getlev
 536:	48e1                	li	a7,24
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <yield>:
.global yield
yield:
 li a7, SYS_yield
 53e:	48dd                	li	a7,23
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <mlfqmode>:
.global mlfqmode
mlfqmode:
 li a7, SYS_mlfqmode
 546:	48e5                	li	a7,25
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <fcfsmode>:
.global fcfsmode
fcfsmode:
 li a7, SYS_fcfsmode
 54e:	48e9                	li	a7,26
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 556:	1101                	addi	sp,sp,-32
 558:	ec06                	sd	ra,24(sp)
 55a:	e822                	sd	s0,16(sp)
 55c:	1000                	addi	s0,sp,32
 55e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 562:	4605                	li	a2,1
 564:	fef40593          	addi	a1,s0,-17
 568:	f47ff0ef          	jal	4ae <write>
}
 56c:	60e2                	ld	ra,24(sp)
 56e:	6442                	ld	s0,16(sp)
 570:	6105                	addi	sp,sp,32
 572:	8082                	ret

0000000000000574 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 574:	7139                	addi	sp,sp,-64
 576:	fc06                	sd	ra,56(sp)
 578:	f822                	sd	s0,48(sp)
 57a:	f426                	sd	s1,40(sp)
 57c:	0080                	addi	s0,sp,64
 57e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 580:	c299                	beqz	a3,586 <printint+0x12>
 582:	0805c963          	bltz	a1,614 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 586:	2581                	sext.w	a1,a1
  neg = 0;
 588:	4881                	li	a7,0
 58a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 58e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 590:	2601                	sext.w	a2,a2
 592:	00000517          	auipc	a0,0x0
 596:	5c650513          	addi	a0,a0,1478 # b58 <digits>
 59a:	883a                	mv	a6,a4
 59c:	2705                	addiw	a4,a4,1
 59e:	02c5f7bb          	remuw	a5,a1,a2
 5a2:	1782                	slli	a5,a5,0x20
 5a4:	9381                	srli	a5,a5,0x20
 5a6:	97aa                	add	a5,a5,a0
 5a8:	0007c783          	lbu	a5,0(a5)
 5ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b0:	0005879b          	sext.w	a5,a1
 5b4:	02c5d5bb          	divuw	a1,a1,a2
 5b8:	0685                	addi	a3,a3,1
 5ba:	fec7f0e3          	bgeu	a5,a2,59a <printint+0x26>
  if(neg)
 5be:	00088c63          	beqz	a7,5d6 <printint+0x62>
    buf[i++] = '-';
 5c2:	fd070793          	addi	a5,a4,-48
 5c6:	00878733          	add	a4,a5,s0
 5ca:	02d00793          	li	a5,45
 5ce:	fef70823          	sb	a5,-16(a4)
 5d2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5d6:	02e05a63          	blez	a4,60a <printint+0x96>
 5da:	f04a                	sd	s2,32(sp)
 5dc:	ec4e                	sd	s3,24(sp)
 5de:	fc040793          	addi	a5,s0,-64
 5e2:	00e78933          	add	s2,a5,a4
 5e6:	fff78993          	addi	s3,a5,-1
 5ea:	99ba                	add	s3,s3,a4
 5ec:	377d                	addiw	a4,a4,-1
 5ee:	1702                	slli	a4,a4,0x20
 5f0:	9301                	srli	a4,a4,0x20
 5f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f6:	fff94583          	lbu	a1,-1(s2)
 5fa:	8526                	mv	a0,s1
 5fc:	f5bff0ef          	jal	556 <putc>
  while(--i >= 0)
 600:	197d                	addi	s2,s2,-1
 602:	ff391ae3          	bne	s2,s3,5f6 <printint+0x82>
 606:	7902                	ld	s2,32(sp)
 608:	69e2                	ld	s3,24(sp)
}
 60a:	70e2                	ld	ra,56(sp)
 60c:	7442                	ld	s0,48(sp)
 60e:	74a2                	ld	s1,40(sp)
 610:	6121                	addi	sp,sp,64
 612:	8082                	ret
    x = -xx;
 614:	40b005bb          	negw	a1,a1
    neg = 1;
 618:	4885                	li	a7,1
    x = -xx;
 61a:	bf85                	j	58a <printint+0x16>

000000000000061c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 61c:	711d                	addi	sp,sp,-96
 61e:	ec86                	sd	ra,88(sp)
 620:	e8a2                	sd	s0,80(sp)
 622:	e0ca                	sd	s2,64(sp)
 624:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 626:	0005c903          	lbu	s2,0(a1)
 62a:	26090863          	beqz	s2,89a <vprintf+0x27e>
 62e:	e4a6                	sd	s1,72(sp)
 630:	fc4e                	sd	s3,56(sp)
 632:	f852                	sd	s4,48(sp)
 634:	f456                	sd	s5,40(sp)
 636:	f05a                	sd	s6,32(sp)
 638:	ec5e                	sd	s7,24(sp)
 63a:	e862                	sd	s8,16(sp)
 63c:	e466                	sd	s9,8(sp)
 63e:	8b2a                	mv	s6,a0
 640:	8a2e                	mv	s4,a1
 642:	8bb2                	mv	s7,a2
  state = 0;
 644:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 646:	4481                	li	s1,0
 648:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 64a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 64e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 652:	06c00c93          	li	s9,108
 656:	a005                	j	676 <vprintf+0x5a>
        putc(fd, c0);
 658:	85ca                	mv	a1,s2
 65a:	855a                	mv	a0,s6
 65c:	efbff0ef          	jal	556 <putc>
 660:	a019                	j	666 <vprintf+0x4a>
    } else if(state == '%'){
 662:	03598263          	beq	s3,s5,686 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 666:	2485                	addiw	s1,s1,1
 668:	8726                	mv	a4,s1
 66a:	009a07b3          	add	a5,s4,s1
 66e:	0007c903          	lbu	s2,0(a5)
 672:	20090c63          	beqz	s2,88a <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 676:	0009079b          	sext.w	a5,s2
    if(state == 0){
 67a:	fe0994e3          	bnez	s3,662 <vprintf+0x46>
      if(c0 == '%'){
 67e:	fd579de3          	bne	a5,s5,658 <vprintf+0x3c>
        state = '%';
 682:	89be                	mv	s3,a5
 684:	b7cd                	j	666 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 686:	00ea06b3          	add	a3,s4,a4
 68a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 68e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 690:	c681                	beqz	a3,698 <vprintf+0x7c>
 692:	9752                	add	a4,a4,s4
 694:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 698:	03878f63          	beq	a5,s8,6d6 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 69c:	05978963          	beq	a5,s9,6ee <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6a0:	07500713          	li	a4,117
 6a4:	0ee78363          	beq	a5,a4,78a <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6a8:	07800713          	li	a4,120
 6ac:	12e78563          	beq	a5,a4,7d6 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6b0:	07000713          	li	a4,112
 6b4:	14e78a63          	beq	a5,a4,808 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 6b8:	07300713          	li	a4,115
 6bc:	18e78a63          	beq	a5,a4,850 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6c0:	02500713          	li	a4,37
 6c4:	04e79563          	bne	a5,a4,70e <vprintf+0xf2>
        putc(fd, '%');
 6c8:	02500593          	li	a1,37
 6cc:	855a                	mv	a0,s6
 6ce:	e89ff0ef          	jal	556 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bf49                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6d6:	008b8913          	addi	s2,s7,8
 6da:	4685                	li	a3,1
 6dc:	4629                	li	a2,10
 6de:	000ba583          	lw	a1,0(s7)
 6e2:	855a                	mv	a0,s6
 6e4:	e91ff0ef          	jal	574 <printint>
 6e8:	8bca                	mv	s7,s2
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bfad                	j	666 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6ee:	06400793          	li	a5,100
 6f2:	02f68963          	beq	a3,a5,724 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6f6:	06c00793          	li	a5,108
 6fa:	04f68263          	beq	a3,a5,73e <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 6fe:	07500793          	li	a5,117
 702:	0af68063          	beq	a3,a5,7a2 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 706:	07800793          	li	a5,120
 70a:	0ef68263          	beq	a3,a5,7ee <vprintf+0x1d2>
        putc(fd, '%');
 70e:	02500593          	li	a1,37
 712:	855a                	mv	a0,s6
 714:	e43ff0ef          	jal	556 <putc>
        putc(fd, c0);
 718:	85ca                	mv	a1,s2
 71a:	855a                	mv	a0,s6
 71c:	e3bff0ef          	jal	556 <putc>
      state = 0;
 720:	4981                	li	s3,0
 722:	b791                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 724:	008b8913          	addi	s2,s7,8
 728:	4685                	li	a3,1
 72a:	4629                	li	a2,10
 72c:	000ba583          	lw	a1,0(s7)
 730:	855a                	mv	a0,s6
 732:	e43ff0ef          	jal	574 <printint>
        i += 1;
 736:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 738:	8bca                	mv	s7,s2
      state = 0;
 73a:	4981                	li	s3,0
        i += 1;
 73c:	b72d                	j	666 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 73e:	06400793          	li	a5,100
 742:	02f60763          	beq	a2,a5,770 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 746:	07500793          	li	a5,117
 74a:	06f60963          	beq	a2,a5,7bc <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 74e:	07800793          	li	a5,120
 752:	faf61ee3          	bne	a2,a5,70e <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 756:	008b8913          	addi	s2,s7,8
 75a:	4681                	li	a3,0
 75c:	4641                	li	a2,16
 75e:	000ba583          	lw	a1,0(s7)
 762:	855a                	mv	a0,s6
 764:	e11ff0ef          	jal	574 <printint>
        i += 2;
 768:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	8bca                	mv	s7,s2
      state = 0;
 76c:	4981                	li	s3,0
        i += 2;
 76e:	bde5                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 770:	008b8913          	addi	s2,s7,8
 774:	4685                	li	a3,1
 776:	4629                	li	a2,10
 778:	000ba583          	lw	a1,0(s7)
 77c:	855a                	mv	a0,s6
 77e:	df7ff0ef          	jal	574 <printint>
        i += 2;
 782:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 784:	8bca                	mv	s7,s2
      state = 0;
 786:	4981                	li	s3,0
        i += 2;
 788:	bdf9                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 78a:	008b8913          	addi	s2,s7,8
 78e:	4681                	li	a3,0
 790:	4629                	li	a2,10
 792:	000ba583          	lw	a1,0(s7)
 796:	855a                	mv	a0,s6
 798:	dddff0ef          	jal	574 <printint>
 79c:	8bca                	mv	s7,s2
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b5d9                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7a2:	008b8913          	addi	s2,s7,8
 7a6:	4681                	li	a3,0
 7a8:	4629                	li	a2,10
 7aa:	000ba583          	lw	a1,0(s7)
 7ae:	855a                	mv	a0,s6
 7b0:	dc5ff0ef          	jal	574 <printint>
        i += 1;
 7b4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7b6:	8bca                	mv	s7,s2
      state = 0;
 7b8:	4981                	li	s3,0
        i += 1;
 7ba:	b575                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7bc:	008b8913          	addi	s2,s7,8
 7c0:	4681                	li	a3,0
 7c2:	4629                	li	a2,10
 7c4:	000ba583          	lw	a1,0(s7)
 7c8:	855a                	mv	a0,s6
 7ca:	dabff0ef          	jal	574 <printint>
        i += 2;
 7ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d0:	8bca                	mv	s7,s2
      state = 0;
 7d2:	4981                	li	s3,0
        i += 2;
 7d4:	bd49                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 7d6:	008b8913          	addi	s2,s7,8
 7da:	4681                	li	a3,0
 7dc:	4641                	li	a2,16
 7de:	000ba583          	lw	a1,0(s7)
 7e2:	855a                	mv	a0,s6
 7e4:	d91ff0ef          	jal	574 <printint>
 7e8:	8bca                	mv	s7,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bdad                	j	666 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7ee:	008b8913          	addi	s2,s7,8
 7f2:	4681                	li	a3,0
 7f4:	4641                	li	a2,16
 7f6:	000ba583          	lw	a1,0(s7)
 7fa:	855a                	mv	a0,s6
 7fc:	d79ff0ef          	jal	574 <printint>
        i += 1;
 800:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 802:	8bca                	mv	s7,s2
      state = 0;
 804:	4981                	li	s3,0
        i += 1;
 806:	b585                	j	666 <vprintf+0x4a>
 808:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 80a:	008b8d13          	addi	s10,s7,8
 80e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 812:	03000593          	li	a1,48
 816:	855a                	mv	a0,s6
 818:	d3fff0ef          	jal	556 <putc>
  putc(fd, 'x');
 81c:	07800593          	li	a1,120
 820:	855a                	mv	a0,s6
 822:	d35ff0ef          	jal	556 <putc>
 826:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 828:	00000b97          	auipc	s7,0x0
 82c:	330b8b93          	addi	s7,s7,816 # b58 <digits>
 830:	03c9d793          	srli	a5,s3,0x3c
 834:	97de                	add	a5,a5,s7
 836:	0007c583          	lbu	a1,0(a5)
 83a:	855a                	mv	a0,s6
 83c:	d1bff0ef          	jal	556 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 840:	0992                	slli	s3,s3,0x4
 842:	397d                	addiw	s2,s2,-1
 844:	fe0916e3          	bnez	s2,830 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 848:	8bea                	mv	s7,s10
      state = 0;
 84a:	4981                	li	s3,0
 84c:	6d02                	ld	s10,0(sp)
 84e:	bd21                	j	666 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 850:	008b8993          	addi	s3,s7,8
 854:	000bb903          	ld	s2,0(s7)
 858:	00090f63          	beqz	s2,876 <vprintf+0x25a>
        for(; *s; s++)
 85c:	00094583          	lbu	a1,0(s2)
 860:	c195                	beqz	a1,884 <vprintf+0x268>
          putc(fd, *s);
 862:	855a                	mv	a0,s6
 864:	cf3ff0ef          	jal	556 <putc>
        for(; *s; s++)
 868:	0905                	addi	s2,s2,1
 86a:	00094583          	lbu	a1,0(s2)
 86e:	f9f5                	bnez	a1,862 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 870:	8bce                	mv	s7,s3
      state = 0;
 872:	4981                	li	s3,0
 874:	bbcd                	j	666 <vprintf+0x4a>
          s = "(null)";
 876:	00000917          	auipc	s2,0x0
 87a:	2da90913          	addi	s2,s2,730 # b50 <malloc+0x1ce>
        for(; *s; s++)
 87e:	02800593          	li	a1,40
 882:	b7c5                	j	862 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 884:	8bce                	mv	s7,s3
      state = 0;
 886:	4981                	li	s3,0
 888:	bbf9                	j	666 <vprintf+0x4a>
 88a:	64a6                	ld	s1,72(sp)
 88c:	79e2                	ld	s3,56(sp)
 88e:	7a42                	ld	s4,48(sp)
 890:	7aa2                	ld	s5,40(sp)
 892:	7b02                	ld	s6,32(sp)
 894:	6be2                	ld	s7,24(sp)
 896:	6c42                	ld	s8,16(sp)
 898:	6ca2                	ld	s9,8(sp)
    }
  }
}
 89a:	60e6                	ld	ra,88(sp)
 89c:	6446                	ld	s0,80(sp)
 89e:	6906                	ld	s2,64(sp)
 8a0:	6125                	addi	sp,sp,96
 8a2:	8082                	ret

00000000000008a4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8a4:	715d                	addi	sp,sp,-80
 8a6:	ec06                	sd	ra,24(sp)
 8a8:	e822                	sd	s0,16(sp)
 8aa:	1000                	addi	s0,sp,32
 8ac:	e010                	sd	a2,0(s0)
 8ae:	e414                	sd	a3,8(s0)
 8b0:	e818                	sd	a4,16(s0)
 8b2:	ec1c                	sd	a5,24(s0)
 8b4:	03043023          	sd	a6,32(s0)
 8b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8c0:	8622                	mv	a2,s0
 8c2:	d5bff0ef          	jal	61c <vprintf>
}
 8c6:	60e2                	ld	ra,24(sp)
 8c8:	6442                	ld	s0,16(sp)
 8ca:	6161                	addi	sp,sp,80
 8cc:	8082                	ret

00000000000008ce <printf>:

void
printf(const char *fmt, ...)
{
 8ce:	711d                	addi	sp,sp,-96
 8d0:	ec06                	sd	ra,24(sp)
 8d2:	e822                	sd	s0,16(sp)
 8d4:	1000                	addi	s0,sp,32
 8d6:	e40c                	sd	a1,8(s0)
 8d8:	e810                	sd	a2,16(s0)
 8da:	ec14                	sd	a3,24(s0)
 8dc:	f018                	sd	a4,32(s0)
 8de:	f41c                	sd	a5,40(s0)
 8e0:	03043823          	sd	a6,48(s0)
 8e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e8:	00840613          	addi	a2,s0,8
 8ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8f0:	85aa                	mv	a1,a0
 8f2:	4505                	li	a0,1
 8f4:	d29ff0ef          	jal	61c <vprintf>
}
 8f8:	60e2                	ld	ra,24(sp)
 8fa:	6442                	ld	s0,16(sp)
 8fc:	6125                	addi	sp,sp,96
 8fe:	8082                	ret

0000000000000900 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 900:	1141                	addi	sp,sp,-16
 902:	e422                	sd	s0,8(sp)
 904:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 906:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90a:	00000797          	auipc	a5,0x0
 90e:	6fe7b783          	ld	a5,1790(a5) # 1008 <freep>
 912:	a02d                	j	93c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 914:	4618                	lw	a4,8(a2)
 916:	9f2d                	addw	a4,a4,a1
 918:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	6310                	ld	a2,0(a4)
 920:	a83d                	j	95e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 922:	ff852703          	lw	a4,-8(a0)
 926:	9f31                	addw	a4,a4,a2
 928:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 92a:	ff053683          	ld	a3,-16(a0)
 92e:	a091                	j	972 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 930:	6398                	ld	a4,0(a5)
 932:	00e7e463          	bltu	a5,a4,93a <free+0x3a>
 936:	00e6ea63          	bltu	a3,a4,94a <free+0x4a>
{
 93a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93c:	fed7fae3          	bgeu	a5,a3,930 <free+0x30>
 940:	6398                	ld	a4,0(a5)
 942:	00e6e463          	bltu	a3,a4,94a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 946:	fee7eae3          	bltu	a5,a4,93a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 94a:	ff852583          	lw	a1,-8(a0)
 94e:	6390                	ld	a2,0(a5)
 950:	02059813          	slli	a6,a1,0x20
 954:	01c85713          	srli	a4,a6,0x1c
 958:	9736                	add	a4,a4,a3
 95a:	fae60de3          	beq	a2,a4,914 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 95e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 962:	4790                	lw	a2,8(a5)
 964:	02061593          	slli	a1,a2,0x20
 968:	01c5d713          	srli	a4,a1,0x1c
 96c:	973e                	add	a4,a4,a5
 96e:	fae68ae3          	beq	a3,a4,922 <free+0x22>
    p->s.ptr = bp->s.ptr;
 972:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 974:	00000717          	auipc	a4,0x0
 978:	68f73a23          	sd	a5,1684(a4) # 1008 <freep>
}
 97c:	6422                	ld	s0,8(sp)
 97e:	0141                	addi	sp,sp,16
 980:	8082                	ret

0000000000000982 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 982:	7139                	addi	sp,sp,-64
 984:	fc06                	sd	ra,56(sp)
 986:	f822                	sd	s0,48(sp)
 988:	f426                	sd	s1,40(sp)
 98a:	ec4e                	sd	s3,24(sp)
 98c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 98e:	02051493          	slli	s1,a0,0x20
 992:	9081                	srli	s1,s1,0x20
 994:	04bd                	addi	s1,s1,15
 996:	8091                	srli	s1,s1,0x4
 998:	0014899b          	addiw	s3,s1,1
 99c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 99e:	00000517          	auipc	a0,0x0
 9a2:	66a53503          	ld	a0,1642(a0) # 1008 <freep>
 9a6:	c915                	beqz	a0,9da <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9aa:	4798                	lw	a4,8(a5)
 9ac:	08977a63          	bgeu	a4,s1,a40 <malloc+0xbe>
 9b0:	f04a                	sd	s2,32(sp)
 9b2:	e852                	sd	s4,16(sp)
 9b4:	e456                	sd	s5,8(sp)
 9b6:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9b8:	8a4e                	mv	s4,s3
 9ba:	0009871b          	sext.w	a4,s3
 9be:	6685                	lui	a3,0x1
 9c0:	00d77363          	bgeu	a4,a3,9c6 <malloc+0x44>
 9c4:	6a05                	lui	s4,0x1
 9c6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ca:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ce:	00000917          	auipc	s2,0x0
 9d2:	63a90913          	addi	s2,s2,1594 # 1008 <freep>
  if(p == (char*)-1)
 9d6:	5afd                	li	s5,-1
 9d8:	a081                	j	a18 <malloc+0x96>
 9da:	f04a                	sd	s2,32(sp)
 9dc:	e852                	sd	s4,16(sp)
 9de:	e456                	sd	s5,8(sp)
 9e0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9e2:	00000797          	auipc	a5,0x0
 9e6:	62e78793          	addi	a5,a5,1582 # 1010 <base>
 9ea:	00000717          	auipc	a4,0x0
 9ee:	60f73f23          	sd	a5,1566(a4) # 1008 <freep>
 9f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f8:	b7c1                	j	9b8 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9fa:	6398                	ld	a4,0(a5)
 9fc:	e118                	sd	a4,0(a0)
 9fe:	a8a9                	j	a58 <malloc+0xd6>
  hp->s.size = nu;
 a00:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a04:	0541                	addi	a0,a0,16
 a06:	efbff0ef          	jal	900 <free>
  return freep;
 a0a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a0e:	c12d                	beqz	a0,a70 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a10:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a12:	4798                	lw	a4,8(a5)
 a14:	02977263          	bgeu	a4,s1,a38 <malloc+0xb6>
    if(p == freep)
 a18:	00093703          	ld	a4,0(s2)
 a1c:	853e                	mv	a0,a5
 a1e:	fef719e3          	bne	a4,a5,a10 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a22:	8552                	mv	a0,s4
 a24:	af3ff0ef          	jal	516 <sbrk>
  if(p == (char*)-1)
 a28:	fd551ce3          	bne	a0,s5,a00 <malloc+0x7e>
        return 0;
 a2c:	4501                	li	a0,0
 a2e:	7902                	ld	s2,32(sp)
 a30:	6a42                	ld	s4,16(sp)
 a32:	6aa2                	ld	s5,8(sp)
 a34:	6b02                	ld	s6,0(sp)
 a36:	a03d                	j	a64 <malloc+0xe2>
 a38:	7902                	ld	s2,32(sp)
 a3a:	6a42                	ld	s4,16(sp)
 a3c:	6aa2                	ld	s5,8(sp)
 a3e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a40:	fae48de3          	beq	s1,a4,9fa <malloc+0x78>
        p->s.size -= nunits;
 a44:	4137073b          	subw	a4,a4,s3
 a48:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a4a:	02071693          	slli	a3,a4,0x20
 a4e:	01c6d713          	srli	a4,a3,0x1c
 a52:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a54:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a58:	00000717          	auipc	a4,0x0
 a5c:	5aa73823          	sd	a0,1456(a4) # 1008 <freep>
      return (void*)(p + 1);
 a60:	01078513          	addi	a0,a5,16
  }
}
 a64:	70e2                	ld	ra,56(sp)
 a66:	7442                	ld	s0,48(sp)
 a68:	74a2                	ld	s1,40(sp)
 a6a:	69e2                	ld	s3,24(sp)
 a6c:	6121                	addi	sp,sp,64
 a6e:	8082                	ret
 a70:	7902                	ld	s2,32(sp)
 a72:	6a42                	ld	s4,16(sp)
 a74:	6aa2                	ld	s5,8(sp)
 a76:	6b02                	ld	s6,0(sp)
 a78:	b7f5                	j	a64 <malloc+0xe2>
