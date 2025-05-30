
user/_thread_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_basic>:
int expected[NUM_THREAD]; // for test#2

// test#1
void
thread_basic(void *arg1, void *arg2)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
    uint64 num = (uint64)arg1;
    printf("Thread %lu start\n", num);
   c:	85aa                	mv	a1,a0
   e:	00001517          	auipc	a0,0x1
  12:	f9250513          	addi	a0,a0,-110 # fa0 <thread_join+0x38>
  16:	54d000ef          	jal	d62 <printf>
    if (num == 0) {
  1a:	c899                	beqz	s1,30 <thread_basic+0x30>
        sleep(20);
        status = 1;
        //printf("tb status: %d\n", status);
    }
    printf("Thread %lu end\n", num);
  1c:	85a6                	mv	a1,s1
  1e:	00001517          	auipc	a0,0x1
  22:	f9a50513          	addi	a0,a0,-102 # fb8 <thread_join+0x50>
  26:	53d000ef          	jal	d62 <printf>
    exit(0);
  2a:	4501                	li	a0,0
  2c:	10f000ef          	jal	93a <exit>
        sleep(20);
  30:	4551                	li	a0,20
  32:	199000ef          	jal	9ca <sleep>
        status = 1;
  36:	4785                	li	a5,1
  38:	00002717          	auipc	a4,0x2
  3c:	fcf72823          	sw	a5,-48(a4) # 2008 <status>
  40:	bff1                	j	1c <thread_basic+0x1c>

0000000000000042 <thread_inc>:
}

// test#2
void
thread_inc(void *arg1, void *arg2)
{
  42:	1101                	addi	sp,sp,-32
  44:	ec06                	sd	ra,24(sp)
  46:	e822                	sd	s0,16(sp)
  48:	e426                	sd	s1,8(sp)
  4a:	e04a                	sd	s2,0(sp)
  4c:	1000                	addi	s0,sp,32
  4e:	892a                	mv	s2,a0
  50:	84ae                	mv	s1,a1
    int i;
    uint64 num = (uint64)arg1;
    uint64 iter = (uint64)arg2;
    printf("Thread %lu start, iter=%lu\n", num, iter);
  52:	862e                	mv	a2,a1
  54:	85aa                	mv	a1,a0
  56:	00001517          	auipc	a0,0x1
  5a:	f7250513          	addi	a0,a0,-142 # fc8 <thread_join+0x60>
  5e:	505000ef          	jal	d62 <printf>
    for (i = 0; i < iter; i++) {
  62:	c89d                	beqz	s1,98 <thread_inc+0x56>
  64:	00291713          	slli	a4,s2,0x2
  68:	00002797          	auipc	a5,0x2
  6c:	fb878793          	addi	a5,a5,-72 # 2020 <expected>
  70:	97ba                	add	a5,a5,a4
  72:	4394                	lw	a3,0(a5)
  74:	0016879b          	addiw	a5,a3,1
  78:	0014871b          	addiw	a4,s1,1
  7c:	9f35                	addw	a4,a4,a3
  7e:	0007869b          	sext.w	a3,a5
  82:	2785                	addiw	a5,a5,1
  84:	fee79de3          	bne	a5,a4,7e <thread_inc+0x3c>
  88:	00291713          	slli	a4,s2,0x2
  8c:	00002797          	auipc	a5,0x2
  90:	f9478793          	addi	a5,a5,-108 # 2020 <expected>
  94:	97ba                	add	a5,a5,a4
  96:	c394                	sw	a3,0(a5)
        expected[num]++;
    }
    printf("Thread %lu end\n", num);
  98:	85ca                	mv	a1,s2
  9a:	00001517          	auipc	a0,0x1
  9e:	f1e50513          	addi	a0,a0,-226 # fb8 <thread_join+0x50>
  a2:	4c1000ef          	jal	d62 <printf>
    exit(0);
  a6:	4501                	li	a0,0
  a8:	093000ef          	jal	93a <exit>

00000000000000ac <thread_fork>:
}

// test#3
void
thread_fork(void *arg1, void *arg2)
{
  ac:	1101                	addi	sp,sp,-32
  ae:	ec06                	sd	ra,24(sp)
  b0:	e822                	sd	s0,16(sp)
  b2:	e426                	sd	s1,8(sp)
  b4:	1000                	addi	s0,sp,32
  b6:	84aa                	mv	s1,a0
    uint64 num = (uint64)arg1;
    int pid;

    printf("Thread %lu start\n", num);
  b8:	85aa                	mv	a1,a0
  ba:	00001517          	auipc	a0,0x1
  be:	ee650513          	addi	a0,a0,-282 # fa0 <thread_join+0x38>
  c2:	4a1000ef          	jal	d62 <printf>
    pid = fork();
  c6:	06d000ef          	jal	932 <fork>
    if (pid < 0) {
  ca:	02054c63          	bltz	a0,102 <thread_fork+0x56>
        printf("Fork error on thread %lu\n", num);
        exit(1);
    }

    if (pid == 0) {
  ce:	e521                	bnez	a0,116 <thread_fork+0x6a>
        printf("Child of thread %lu start\n", num);
  d0:	85a6                	mv	a1,s1
  d2:	00001517          	auipc	a0,0x1
  d6:	f3650513          	addi	a0,a0,-202 # 1008 <thread_join+0xa0>
  da:	489000ef          	jal	d62 <printf>
        sleep(10);
  de:	4529                	li	a0,10
  e0:	0eb000ef          	jal	9ca <sleep>
        status = 3;
  e4:	478d                	li	a5,3
  e6:	00002717          	auipc	a4,0x2
  ea:	f2f72123          	sw	a5,-222(a4) # 2008 <status>
        printf("Child of thread %lu end\n", num);
  ee:	85a6                	mv	a1,s1
  f0:	00001517          	auipc	a0,0x1
  f4:	f3850513          	addi	a0,a0,-200 # 1028 <thread_join+0xc0>
  f8:	46b000ef          	jal	d62 <printf>
        exit(0);
  fc:	4501                	li	a0,0
  fe:	03d000ef          	jal	93a <exit>
        printf("Fork error on thread %lu\n", num);
 102:	85a6                	mv	a1,s1
 104:	00001517          	auipc	a0,0x1
 108:	ee450513          	addi	a0,a0,-284 # fe8 <thread_join+0x80>
 10c:	457000ef          	jal	d62 <printf>
        exit(1);
 110:	4505                	li	a0,1
 112:	029000ef          	jal	93a <exit>
    }
    else {
        status = 2;
 116:	4789                	li	a5,2
 118:	00002717          	auipc	a4,0x2
 11c:	eef72823          	sw	a5,-272(a4) # 2008 <status>
        if (wait(0) == -1) {
 120:	4501                	li	a0,0
 122:	021000ef          	jal	942 <wait>
 126:	57fd                	li	a5,-1
 128:	00f50c63          	beq	a0,a5,140 <thread_fork+0x94>
            printf("Thread %lu lost their child\n", num);
            exit(1);
        }
    }
    printf("Thread %lu end\n", num);
 12c:	85a6                	mv	a1,s1
 12e:	00001517          	auipc	a0,0x1
 132:	e8a50513          	addi	a0,a0,-374 # fb8 <thread_join+0x50>
 136:	42d000ef          	jal	d62 <printf>
    exit(0);
 13a:	4501                	li	a0,0
 13c:	7fe000ef          	jal	93a <exit>
            printf("Thread %lu lost their child\n", num);
 140:	85a6                	mv	a1,s1
 142:	00001517          	auipc	a0,0x1
 146:	f0650513          	addi	a0,a0,-250 # 1048 <thread_join+0xe0>
 14a:	419000ef          	jal	d62 <printf>
            exit(1);
 14e:	4505                	li	a0,1
 150:	7ea000ef          	jal	93a <exit>

0000000000000154 <thread_sbrk>:
// test#4
int *ptr;

void
thread_sbrk(void *arg1, void *arg2)
{
 154:	1101                	addi	sp,sp,-32
 156:	ec06                	sd	ra,24(sp)
 158:	e822                	sd	s0,16(sp)
 15a:	e426                	sd	s1,8(sp)
 15c:	e04a                	sd	s2,0(sp)
 15e:	1000                	addi	s0,sp,32
 160:	84aa                	mv	s1,a0
    uint64 num = (uint64)arg1;
    char *old_break = sbrk(0);
 162:	4501                	li	a0,0
 164:	05f000ef          	jal	9c2 <sbrk>

    // Global memory allocation
    if (num == 0) {
 168:	c8dd                	beqz	s1,21e <thread_sbrk+0xca>
        printf("Thread %lu sbrk: free memory\n", num);
        free(ptr);
        ptr = 0;
    }
    else {
        while (ptr == 0) {
 16a:	00002797          	auipc	a5,0x2
 16e:	e967b783          	ld	a5,-362(a5) # 2000 <ptr>
 172:	00002917          	auipc	s2,0x2
 176:	e8e90913          	addi	s2,s2,-370 # 2000 <ptr>
 17a:	e799                	bnez	a5,188 <thread_sbrk+0x34>
            sleep(1);
 17c:	4505                	li	a0,1
 17e:	04d000ef          	jal	9ca <sleep>
        while (ptr == 0) {
 182:	00093783          	ld	a5,0(s2)
 186:	dbfd                	beqz	a5,17c <thread_sbrk+0x28>
        }
        printf("Thread %lu size = %p\n", num, sbrk(0));
 188:	4501                	li	a0,0
 18a:	039000ef          	jal	9c2 <sbrk>
 18e:	862a                	mv	a2,a0
 190:	85a6                	mv	a1,s1
 192:	00001517          	auipc	a0,0x1
 196:	f5650513          	addi	a0,a0,-170 # 10e8 <thread_join+0x180>
 19a:	3c9000ef          	jal	d62 <printf>
        for (int i = 0; i < 4096; i++) {
 19e:	00e49793          	slli	a5,s1,0xe
 1a2:	6691                	lui	a3,0x4
 1a4:	96be                	add	a3,a3,a5
            ptr[num*4096 + i] = num;
 1a6:	00002617          	auipc	a2,0x2
 1aa:	e5a60613          	addi	a2,a2,-422 # 2000 <ptr>
 1ae:	6218                	ld	a4,0(a2)
 1b0:	973e                	add	a4,a4,a5
 1b2:	c304                	sw	s1,0(a4)
        for (int i = 0; i < 4096; i++) {
 1b4:	0791                	addi	a5,a5,4
 1b6:	fed79ce3          	bne	a5,a3,1ae <thread_sbrk+0x5a>
        }
    }

    while (ptr != 0) {
 1ba:	00002797          	auipc	a5,0x2
 1be:	e467b783          	ld	a5,-442(a5) # 2000 <ptr>
 1c2:	00002917          	auipc	s2,0x2
 1c6:	e3e90913          	addi	s2,s2,-450 # 2000 <ptr>
 1ca:	c799                	beqz	a5,1d8 <thread_sbrk+0x84>
        sleep(1);
 1cc:	4505                	li	a0,1
 1ce:	7fc000ef          	jal	9ca <sleep>
    while (ptr != 0) {
 1d2:	00093783          	ld	a5,0(s2)
 1d6:	fbfd                	bnez	a5,1cc <thread_sbrk+0x78>
{
 1d8:	3e800913          	li	s2,1000
    }

    // Local memory allocation
    for (int i = 0; i < 1000; i++) {
        int *p = (int *)malloc(4096);
 1dc:	6505                	lui	a0,0x1
 1de:	439000ef          	jal	e16 <malloc>
        if (p == 0) {
 1e2:	cd49                	beqz	a0,27c <thread_sbrk+0x128>
 1e4:	86aa                	mv	a3,a0
 1e6:	6705                	lui	a4,0x1
 1e8:	972a                	add	a4,a4,a0
 1ea:	87aa                	mv	a5,a0
            printf("Thread %lu malloc failed\n", num);
            exit(1);
        }
        for (int j = 0; j < 4096 / sizeof(int); j++) {
            p[j] = num;
 1ec:	c384                	sw	s1,0(a5)
        for (int j = 0; j < 4096 / sizeof(int); j++) {
 1ee:	0791                	addi	a5,a5,4
 1f0:	fee79ee3          	bne	a5,a4,1ec <thread_sbrk+0x98>
        }
        for (int j = 0; j < 4096 / sizeof(int); j++) {
            if (p[j] != num) {
 1f4:	4290                	lw	a2,0(a3)
 1f6:	08961d63          	bne	a2,s1,290 <thread_sbrk+0x13c>
        for (int j = 0; j < 4096 / sizeof(int); j++) {
 1fa:	0691                	addi	a3,a3,4 # 4004 <base+0x1fb4>
 1fc:	fee69ce3          	bne	a3,a4,1f4 <thread_sbrk+0xa0>
                printf("Thread %lu found %d\n", num, p[j]);
                exit(1);
            }
        }
        free(p);
 200:	395000ef          	jal	d94 <free>
    for (int i = 0; i < 1000; i++) {
 204:	397d                	addiw	s2,s2,-1
 206:	fc091be3          	bnez	s2,1dc <thread_sbrk+0x88>
    }
    printf("Thread %lu end\n", num);
 20a:	85a6                	mv	a1,s1
 20c:	00001517          	auipc	a0,0x1
 210:	dac50513          	addi	a0,a0,-596 # fb8 <thread_join+0x50>
 214:	34f000ef          	jal	d62 <printf>
    exit(0);
 218:	4501                	li	a0,0
 21a:	720000ef          	jal	93a <exit>
        printf("Thread %lu sbrk: old break = %p\n", num, old_break);
 21e:	862a                	mv	a2,a0
 220:	4581                	li	a1,0
 222:	00001517          	auipc	a0,0x1
 226:	e4650513          	addi	a0,a0,-442 # 1068 <thread_join+0x100>
 22a:	339000ef          	jal	d62 <printf>
        ptr = (int *)malloc(4096 * 4 * NUM_THREAD);
 22e:	6551                	lui	a0,0x14
 230:	3e7000ef          	jal	e16 <malloc>
 234:	00002917          	auipc	s2,0x2
 238:	dcc90913          	addi	s2,s2,-564 # 2000 <ptr>
 23c:	00a93023          	sd	a0,0(s2)
        printf("Thread %lu sbrk: increased break by %x\nnew break = %p\n", num, 4096 * 4 * NUM_THREAD, sbrk(0));
 240:	4501                	li	a0,0
 242:	780000ef          	jal	9c2 <sbrk>
 246:	86aa                	mv	a3,a0
 248:	6651                	lui	a2,0x14
 24a:	4581                	li	a1,0
 24c:	00001517          	auipc	a0,0x1
 250:	e4450513          	addi	a0,a0,-444 # 1090 <thread_join+0x128>
 254:	30f000ef          	jal	d62 <printf>
        sleep(50);
 258:	03200513          	li	a0,50
 25c:	76e000ef          	jal	9ca <sleep>
        printf("Thread %lu sbrk: free memory\n", num);
 260:	4581                	li	a1,0
 262:	00001517          	auipc	a0,0x1
 266:	e6650513          	addi	a0,a0,-410 # 10c8 <thread_join+0x160>
 26a:	2f9000ef          	jal	d62 <printf>
        free(ptr);
 26e:	00093503          	ld	a0,0(s2)
 272:	323000ef          	jal	d94 <free>
        ptr = 0;
 276:	00093023          	sd	zero,0(s2)
    while (ptr != 0) {
 27a:	bfb9                	j	1d8 <thread_sbrk+0x84>
            printf("Thread %lu malloc failed\n", num);
 27c:	85a6                	mv	a1,s1
 27e:	00001517          	auipc	a0,0x1
 282:	e8250513          	addi	a0,a0,-382 # 1100 <thread_join+0x198>
 286:	2dd000ef          	jal	d62 <printf>
            exit(1);
 28a:	4505                	li	a0,1
 28c:	6ae000ef          	jal	93a <exit>
                printf("Thread %lu found %d\n", num, p[j]);
 290:	85a6                	mv	a1,s1
 292:	00001517          	auipc	a0,0x1
 296:	e8e50513          	addi	a0,a0,-370 # 1120 <thread_join+0x1b8>
 29a:	2c9000ef          	jal	d62 <printf>
                exit(1);
 29e:	4505                	li	a0,1
 2a0:	69a000ef          	jal	93a <exit>

00000000000002a4 <thread_kill>:
}

// test#5
void
thread_kill(void *arg1, void *arg2)
{
 2a4:	1101                	addi	sp,sp,-32
 2a6:	ec06                	sd	ra,24(sp)
 2a8:	e822                	sd	s0,16(sp)
 2aa:	e426                	sd	s1,8(sp)
 2ac:	e04a                	sd	s2,0(sp)
 2ae:	1000                	addi	s0,sp,32
 2b0:	84aa                	mv	s1,a0
 2b2:	892e                	mv	s2,a1
    uint64 num = (uint64)arg1;
    uint64 pid = (uint64)arg2;
    printf("Thread %lu start, pid %lu\n", num, pid);
 2b4:	862e                	mv	a2,a1
 2b6:	85aa                	mv	a1,a0
 2b8:	00001517          	auipc	a0,0x1
 2bc:	e8050513          	addi	a0,a0,-384 # 1138 <thread_join+0x1d0>
 2c0:	2a3000ef          	jal	d62 <printf>
    if (num == 0) {
 2c4:	c091                	beqz	s1,2c8 <thread_kill+0x24>
        sleep(1);
        kill(pid);
    }
    else {
        while(1);
 2c6:	a001                	j	2c6 <thread_kill+0x22>
        sleep(1);
 2c8:	4505                	li	a0,1
 2ca:	700000ef          	jal	9ca <sleep>
        kill(pid);
 2ce:	0009051b          	sext.w	a0,s2
 2d2:	698000ef          	jal	96a <kill>
    }
    printf("Thread %lu end\n", num);
 2d6:	4581                	li	a1,0
 2d8:	00001517          	auipc	a0,0x1
 2dc:	ce050513          	addi	a0,a0,-800 # fb8 <thread_join+0x50>
 2e0:	283000ef          	jal	d62 <printf>
    exit(0);
 2e4:	4501                	li	a0,0
 2e6:	654000ef          	jal	93a <exit>

00000000000002ea <thread_exec>:
}

// test#6
void
thread_exec(void *arg1, void *arg2)
{
 2ea:	7139                	addi	sp,sp,-64
 2ec:	fc06                	sd	ra,56(sp)
 2ee:	f822                	sd	s0,48(sp)
 2f0:	f426                	sd	s1,40(sp)
 2f2:	f04a                	sd	s2,32(sp)
 2f4:	0080                	addi	s0,sp,64
 2f6:	84aa                	mv	s1,a0
    uint64 num = (uint64)arg1;
    printf("Thread %lu start\n", num);
 2f8:	85aa                	mv	a1,a0
 2fa:	00001517          	auipc	a0,0x1
 2fe:	ca650513          	addi	a0,a0,-858 # fa0 <thread_join+0x38>
 302:	261000ef          	jal	d62 <printf>
    if (num == 0) {
 306:	cc91                	beqz	s1,322 <thread_exec+0x38>
        printf("Executing...\n");
        //printf("exec returned %d\n", exec(pname, args));
        exec(pname, args);
    }
    else {
        sleep(20);
 308:	4551                	li	a0,20
 30a:	6c0000ef          	jal	9ca <sleep>
    }
    printf("Thread %lu end\n", num);
 30e:	85a6                	mv	a1,s1
 310:	00001517          	auipc	a0,0x1
 314:	ca850513          	addi	a0,a0,-856 # fb8 <thread_join+0x50>
 318:	24b000ef          	jal	d62 <printf>
    exit(0);
 31c:	4501                	li	a0,0
 31e:	61c000ef          	jal	93a <exit>
        sleep(1);
 322:	4505                	li	a0,1
 324:	6a6000ef          	jal	9ca <sleep>
        char *args[3] = {pname, "0", 0};
 328:	00001917          	auipc	s2,0x1
 32c:	e3090913          	addi	s2,s2,-464 # 1158 <thread_join+0x1f0>
 330:	fd243423          	sd	s2,-56(s0)
 334:	00001797          	auipc	a5,0x1
 338:	e3478793          	addi	a5,a5,-460 # 1168 <thread_join+0x200>
 33c:	fcf43823          	sd	a5,-48(s0)
 340:	fc043c23          	sd	zero,-40(s0)
        printf("Executing...\n");
 344:	00001517          	auipc	a0,0x1
 348:	e2c50513          	addi	a0,a0,-468 # 1170 <thread_join+0x208>
 34c:	217000ef          	jal	d62 <printf>
        exec(pname, args);
 350:	fc840593          	addi	a1,s0,-56
 354:	854a                	mv	a0,s2
 356:	61c000ef          	jal	972 <exec>
 35a:	bf55                	j	30e <thread_exec+0x24>

000000000000035c <main>:
}

int
main(int argc, char *argv[])
{
 35c:	7139                	addi	sp,sp,-64
 35e:	fc06                	sd	ra,56(sp)
 360:	f822                	sd	s0,48(sp)
 362:	f426                	sd	s1,40(sp)
 364:	f04a                	sd	s2,32(sp)
 366:	ec4e                	sd	s3,24(sp)
 368:	e852                	sd	s4,16(sp)
 36a:	e456                	sd	s5,8(sp)
 36c:	e05a                	sd	s6,0(sp)
 36e:	0080                	addi	s0,sp,64
    int i, pid;

    printf("\n[TEST#1]\n");
 370:	00001517          	auipc	a0,0x1
 374:	e1050513          	addi	a0,a0,-496 # 1180 <thread_join+0x218>
 378:	1eb000ef          	jal	d62 <printf>
    for (i = 0; i < NUM_THREAD; i++) {
 37c:	00002a17          	auipc	s4,0x2
 380:	cbca0a13          	addi	s4,s4,-836 # 2038 <threads>
    printf("\n[TEST#1]\n");
 384:	8952                	mv	s2,s4
 386:	4481                	li	s1,0
        threads[i] = thread_create(thread_basic, (void *)(uint64)i, 0);
 388:	00000a97          	auipc	s5,0x0
 38c:	c78a8a93          	addi	s5,s5,-904 # 0 <thread_basic>
    for (i = 0; i < NUM_THREAD; i++) {
 390:	4995                	li	s3,5
        threads[i] = thread_create(thread_basic, (void *)(uint64)i, 0);
 392:	4601                	li	a2,0
 394:	85a6                	mv	a1,s1
 396:	8556                	mv	a0,s5
 398:	377000ef          	jal	f0e <thread_create>
 39c:	00a92023          	sw	a0,0(s2)
    for (i = 0; i < NUM_THREAD; i++) {
 3a0:	0485                	addi	s1,s1,1
 3a2:	0911                	addi	s2,s2,4
 3a4:	ff3497e3          	bne	s1,s3,392 <main+0x36>
    }

    for (i = 0; i < NUM_THREAD; i++) {
 3a8:	4481                	li	s1,0
 3aa:	4915                	li	s2,5
        int ret = thread_join();
 3ac:	3bd000ef          	jal	f68 <thread_join>
        if (ret < 0) {
 3b0:	20054f63          	bltz	a0,5ce <main+0x272>
    for (i = 0; i < NUM_THREAD; i++) {
 3b4:	2485                	addiw	s1,s1,1
 3b6:	ff249be3          	bne	s1,s2,3ac <main+0x50>
            exit(1);
        }
    }

    //printf("status: %d\n", status);
    if (status != 1) {
 3ba:	00002717          	auipc	a4,0x2
 3be:	c4e72703          	lw	a4,-946(a4) # 2008 <status>
 3c2:	4785                	li	a5,1
 3c4:	20f71f63          	bne	a4,a5,5e2 <main+0x286>
        printf("TEST#1 Failed\n");
        exit(1);
    }
    printf("TEST#1 Passed\n");
 3c8:	00001517          	auipc	a0,0x1
 3cc:	df050513          	addi	a0,a0,-528 # 11b8 <thread_join+0x250>
 3d0:	193000ef          	jal	d62 <printf>
    
    printf("\n[TEST#2]\n");
 3d4:	00001517          	auipc	a0,0x1
 3d8:	df450513          	addi	a0,a0,-524 # 11c8 <thread_join+0x260>
 3dc:	187000ef          	jal	d62 <printf>
 3e0:	89d2                	mv	s3,s4
 3e2:	4901                	li	s2,0
 3e4:	4481                	li	s1,0
    for (i = 0; i < NUM_THREAD; i++) {
        threads[i] = thread_create(thread_inc, (void *)(uint64)i, (void *)(uint64)(i * 1000));
 3e6:	00000b17          	auipc	s6,0x0
 3ea:	c5cb0b13          	addi	s6,s6,-932 # 42 <thread_inc>
    for (i = 0; i < NUM_THREAD; i++) {
 3ee:	4a95                	li	s5,5
        threads[i] = thread_create(thread_inc, (void *)(uint64)i, (void *)(uint64)(i * 1000));
 3f0:	864a                	mv	a2,s2
 3f2:	85a6                	mv	a1,s1
 3f4:	855a                	mv	a0,s6
 3f6:	319000ef          	jal	f0e <thread_create>
 3fa:	00a9a023          	sw	a0,0(s3)
    for (i = 0; i < NUM_THREAD; i++) {
 3fe:	0485                	addi	s1,s1,1
 400:	3e890913          	addi	s2,s2,1000
 404:	0991                	addi	s3,s3,4
 406:	ff5495e3          	bne	s1,s5,3f0 <main+0x94>
    }

    for (i = 0; i < NUM_THREAD; i++) {
 40a:	4481                	li	s1,0
 40c:	4915                	li	s2,5
        int ret = thread_join();
 40e:	35b000ef          	jal	f68 <thread_join>
        if (ret < 0) {
 412:	1e054163          	bltz	a0,5f4 <main+0x298>
    for (i = 0; i < NUM_THREAD; i++) {
 416:	2485                	addiw	s1,s1,1
 418:	ff249be3          	bne	s1,s2,40e <main+0xb2>
 41c:	00002717          	auipc	a4,0x2
 420:	c0470713          	addi	a4,a4,-1020 # 2020 <expected>
 424:	4781                	li	a5,0
            printf("Thread %d join failed\n", i);
            exit(1);
        }
    }

    for (i = 0; i < NUM_THREAD; i++) {
 426:	4581                	li	a1,0
 428:	4515                	li	a0,5
        if (expected[i] != i * 1000) {
 42a:	4314                	lw	a3,0(a4)
 42c:	0007861b          	sext.w	a2,a5
 430:	1cc69c63          	bne	a3,a2,608 <main+0x2ac>
    for (i = 0; i < NUM_THREAD; i++) {
 434:	2585                	addiw	a1,a1,1
 436:	3e87879b          	addiw	a5,a5,1000
 43a:	0711                	addi	a4,a4,4
 43c:	fea597e3          	bne	a1,a0,42a <main+0xce>
            printf("Thread %d expected %d, but got %d\n", i, i * 1000, expected[i]);
            exit(1);
        }
    }
    printf("TEST#2 Passed\n");
 440:	00001517          	auipc	a0,0x1
 444:	dc050513          	addi	a0,a0,-576 # 1200 <thread_join+0x298>
 448:	11b000ef          	jal	d62 <printf>

    printf("\n[TEST#3]\n");
 44c:	00001517          	auipc	a0,0x1
 450:	dc450513          	addi	a0,a0,-572 # 1210 <thread_join+0x2a8>
 454:	10f000ef          	jal	d62 <printf>
 458:	8952                	mv	s2,s4
 45a:	4481                	li	s1,0
    for (i = 0; i < NUM_THREAD; i++) {
        threads[i] = thread_create(thread_fork, (void *)(uint64)i, 0);
 45c:	00000a97          	auipc	s5,0x0
 460:	c50a8a93          	addi	s5,s5,-944 # ac <thread_fork>
    for (i = 0; i < NUM_THREAD; i++) {
 464:	4995                	li	s3,5
        threads[i] = thread_create(thread_fork, (void *)(uint64)i, 0);
 466:	4601                	li	a2,0
 468:	85a6                	mv	a1,s1
 46a:	8556                	mv	a0,s5
 46c:	2a3000ef          	jal	f0e <thread_create>
 470:	00a92023          	sw	a0,0(s2)
    for (i = 0; i < NUM_THREAD; i++) {
 474:	0485                	addi	s1,s1,1
 476:	0911                	addi	s2,s2,4
 478:	ff3497e3          	bne	s1,s3,466 <main+0x10a>
    }
    for (i = 0; i < NUM_THREAD; i++) {
 47c:	4481                	li	s1,0
 47e:	4915                	li	s2,5
        int ret = thread_join();
 480:	2e9000ef          	jal	f68 <thread_join>
        if (ret < 0) {
 484:	18054b63          	bltz	a0,61a <main+0x2be>
    for (i = 0; i < NUM_THREAD; i++) {
 488:	2485                	addiw	s1,s1,1
 48a:	ff249be3          	bne	s1,s2,480 <main+0x124>
            printf("Thread %d join failed\n", i);
            exit(1);
        }
    }
    if (status != 2) {
 48e:	00002597          	auipc	a1,0x2
 492:	b7a5a583          	lw	a1,-1158(a1) # 2008 <status>
 496:	4789                	li	a5,2
 498:	18f59b63          	bne	a1,a5,62e <main+0x2d2>
        else {
            printf("TEST#3 Failed: Unexpected status %d\n", status);
        }
        exit(1);
    }
    printf("TEST#3 Passed\n");
 49c:	00001517          	auipc	a0,0x1
 4a0:	dec50513          	addi	a0,a0,-532 # 1288 <thread_join+0x320>
 4a4:	0bf000ef          	jal	d62 <printf>

    printf("\n[TEST#4]\n");
 4a8:	00001517          	auipc	a0,0x1
 4ac:	df050513          	addi	a0,a0,-528 # 1298 <thread_join+0x330>
 4b0:	0b3000ef          	jal	d62 <printf>
 4b4:	8952                	mv	s2,s4
 4b6:	4481                	li	s1,0
    for (i = 0; i < NUM_THREAD; i++) {
        threads[i] = thread_create(thread_sbrk, (void *)(uint64)i, (void *)(uint64)0);
 4b8:	00000a97          	auipc	s5,0x0
 4bc:	c9ca8a93          	addi	s5,s5,-868 # 154 <thread_sbrk>
    for (i = 0; i < NUM_THREAD; i++) {
 4c0:	4995                	li	s3,5
        threads[i] = thread_create(thread_sbrk, (void *)(uint64)i, (void *)(uint64)0);
 4c2:	4601                	li	a2,0
 4c4:	85a6                	mv	a1,s1
 4c6:	8556                	mv	a0,s5
 4c8:	247000ef          	jal	f0e <thread_create>
 4cc:	00a92023          	sw	a0,0(s2)
    for (i = 0; i < NUM_THREAD; i++) {
 4d0:	0485                	addi	s1,s1,1
 4d2:	0911                	addi	s2,s2,4
 4d4:	ff3497e3          	bne	s1,s3,4c2 <main+0x166>
    }
    for (i = 0; i < NUM_THREAD; i++) {
 4d8:	4481                	li	s1,0
 4da:	4915                	li	s2,5
        int ret = thread_join();
 4dc:	28d000ef          	jal	f68 <thread_join>
        if (ret < 0) {
 4e0:	16054a63          	bltz	a0,654 <main+0x2f8>
    for (i = 0; i < NUM_THREAD; i++) {
 4e4:	2485                	addiw	s1,s1,1
 4e6:	ff249be3          	bne	s1,s2,4dc <main+0x180>
            printf("Thread %d join failed\n", i);
            exit(1);
        }
    }

    printf("TEST#4 Passed\n");
 4ea:	00001517          	auipc	a0,0x1
 4ee:	dbe50513          	addi	a0,a0,-578 # 12a8 <thread_join+0x340>
 4f2:	071000ef          	jal	d62 <printf>
    
    printf("\n[TEST#5]\n");
 4f6:	00001517          	auipc	a0,0x1
 4fa:	dc250513          	addi	a0,a0,-574 # 12b8 <thread_join+0x350>
 4fe:	065000ef          	jal	d62 <printf>

    pid = fork();
 502:	430000ef          	jal	932 <fork>
 506:	84aa                	mv	s1,a0
    if (pid < 0) {
 508:	16054063          	bltz	a0,668 <main+0x30c>
        printf("Fork error\n");
        exit(1);
    } else if (pid == 0) {
 50c:	18051163          	bnez	a0,68e <main+0x332>
 510:	89d2                	mv	s3,s4
 512:	4901                	li	s2,0
        for (i = 0; i < NUM_THREAD; i++) {
            threads[i] = thread_create(thread_kill, (void *)(uint64)i, (void *)(uint64)getpid());
 514:	00000b17          	auipc	s6,0x0
 518:	d90b0b13          	addi	s6,s6,-624 # 2a4 <thread_kill>
        for (i = 0; i < NUM_THREAD; i++) {
 51c:	4a95                	li	s5,5
            threads[i] = thread_create(thread_kill, (void *)(uint64)i, (void *)(uint64)getpid());
 51e:	49c000ef          	jal	9ba <getpid>
 522:	862a                	mv	a2,a0
 524:	85ca                	mv	a1,s2
 526:	855a                	mv	a0,s6
 528:	1e7000ef          	jal	f0e <thread_create>
 52c:	00a9a023          	sw	a0,0(s3)
        for (i = 0; i < NUM_THREAD; i++) {
 530:	0905                	addi	s2,s2,1
 532:	0991                	addi	s3,s3,4
 534:	ff5915e3          	bne	s2,s5,51e <main+0x1c2>
        }
        for (i = 0; i < NUM_THREAD; i++) {
 538:	4915                	li	s2,5
            int ret = thread_join();
 53a:	22f000ef          	jal	f68 <thread_join>
            if (ret < 0) {
 53e:	12054e63          	bltz	a0,67a <main+0x31e>
        for (i = 0; i < NUM_THREAD; i++) {
 542:	2485                	addiw	s1,s1,1
 544:	ff249be3          	bne	s1,s2,53a <main+0x1de>
    } else {
        sleep(30);
        wait(0);
    }

    printf("TEST#5 Passed\n");
 548:	00001517          	auipc	a0,0x1
 54c:	d9050513          	addi	a0,a0,-624 # 12d8 <thread_join+0x370>
 550:	013000ef          	jal	d62 <printf>

    printf("\n[TEST#6]\n");
 554:	00001517          	auipc	a0,0x1
 558:	d9450513          	addi	a0,a0,-620 # 12e8 <thread_join+0x380>
 55c:	007000ef          	jal	d62 <printf>
    pid = fork();
 560:	3d2000ef          	jal	932 <fork>
 564:	84aa                	mv	s1,a0

    if (pid < 0) {
 566:	12054b63          	bltz	a0,69c <main+0x340>
        printf("Fork error\n");
        exit(1);
    } else if (pid == 0) {
 56a:	14051c63          	bnez	a0,6c2 <main+0x366>
 56e:	4901                	li	s2,0
        for (i = 0; i < NUM_THREAD; i++) {
            threads[i] = thread_create(thread_exec, (void *)(uint64)i, (void *)(uint64)0);
 570:	00000a97          	auipc	s5,0x0
 574:	d7aa8a93          	addi	s5,s5,-646 # 2ea <thread_exec>
        for (i = 0; i < NUM_THREAD; i++) {
 578:	4995                	li	s3,5
            threads[i] = thread_create(thread_exec, (void *)(uint64)i, (void *)(uint64)0);
 57a:	4601                	li	a2,0
 57c:	85ca                	mv	a1,s2
 57e:	8556                	mv	a0,s5
 580:	18f000ef          	jal	f0e <thread_create>
 584:	00aa2023          	sw	a0,0(s4)
        for (i = 0; i < NUM_THREAD; i++) {
 588:	0905                	addi	s2,s2,1
 58a:	0a11                	addi	s4,s4,4
 58c:	ff3917e3          	bne	s2,s3,57a <main+0x21e>
        }
        for (i = 0; i < NUM_THREAD; i++) {
 590:	4915                	li	s2,5
            int ret = thread_join();
 592:	1d7000ef          	jal	f68 <thread_join>
            if (ret < 0) {
 596:	10054c63          	bltz	a0,6ae <main+0x352>
        for (i = 0; i < NUM_THREAD; i++) {
 59a:	2485                	addiw	s1,s1,1
 59c:	ff249be3          	bne	s1,s2,592 <main+0x236>
    } else {
        sleep(30);
        wait(0);
    }

    printf("TEST#6 Passed\n");
 5a0:	00001517          	auipc	a0,0x1
 5a4:	d5850513          	addi	a0,a0,-680 # 12f8 <thread_join+0x390>
 5a8:	7ba000ef          	jal	d62 <printf>

    printf("\nAll tests passed. Great job!!\n");
 5ac:	00001517          	auipc	a0,0x1
 5b0:	d5c50513          	addi	a0,a0,-676 # 1308 <thread_join+0x3a0>
 5b4:	7ae000ef          	jal	d62 <printf>
    return 0;
 5b8:	4501                	li	a0,0
 5ba:	70e2                	ld	ra,56(sp)
 5bc:	7442                	ld	s0,48(sp)
 5be:	74a2                	ld	s1,40(sp)
 5c0:	7902                	ld	s2,32(sp)
 5c2:	69e2                	ld	s3,24(sp)
 5c4:	6a42                	ld	s4,16(sp)
 5c6:	6aa2                	ld	s5,8(sp)
 5c8:	6b02                	ld	s6,0(sp)
 5ca:	6121                	addi	sp,sp,64
 5cc:	8082                	ret
            printf("Thread %d join failed\n", i);
 5ce:	85a6                	mv	a1,s1
 5d0:	00001517          	auipc	a0,0x1
 5d4:	bc050513          	addi	a0,a0,-1088 # 1190 <thread_join+0x228>
 5d8:	78a000ef          	jal	d62 <printf>
            exit(1);
 5dc:	4505                	li	a0,1
 5de:	35c000ef          	jal	93a <exit>
        printf("TEST#1 Failed\n");
 5e2:	00001517          	auipc	a0,0x1
 5e6:	bc650513          	addi	a0,a0,-1082 # 11a8 <thread_join+0x240>
 5ea:	778000ef          	jal	d62 <printf>
        exit(1);
 5ee:	4505                	li	a0,1
 5f0:	34a000ef          	jal	93a <exit>
            printf("Thread %d join failed\n", i);
 5f4:	85a6                	mv	a1,s1
 5f6:	00001517          	auipc	a0,0x1
 5fa:	b9a50513          	addi	a0,a0,-1126 # 1190 <thread_join+0x228>
 5fe:	764000ef          	jal	d62 <printf>
            exit(1);
 602:	4505                	li	a0,1
 604:	336000ef          	jal	93a <exit>
            printf("Thread %d expected %d, but got %d\n", i, i * 1000, expected[i]);
 608:	00001517          	auipc	a0,0x1
 60c:	bd050513          	addi	a0,a0,-1072 # 11d8 <thread_join+0x270>
 610:	752000ef          	jal	d62 <printf>
            exit(1);
 614:	4505                	li	a0,1
 616:	324000ef          	jal	93a <exit>
            printf("Thread %d join failed\n", i);
 61a:	85a6                	mv	a1,s1
 61c:	00001517          	auipc	a0,0x1
 620:	b7450513          	addi	a0,a0,-1164 # 1190 <thread_join+0x228>
 624:	73e000ef          	jal	d62 <printf>
            exit(1);
 628:	4505                	li	a0,1
 62a:	310000ef          	jal	93a <exit>
        if (status == 3) {
 62e:	478d                	li	a5,3
 630:	00f58b63          	beq	a1,a5,646 <main+0x2ea>
            printf("TEST#3 Failed: Unexpected status %d\n", status);
 634:	00001517          	auipc	a0,0x1
 638:	c2c50513          	addi	a0,a0,-980 # 1260 <thread_join+0x2f8>
 63c:	726000ef          	jal	d62 <printf>
        exit(1);
 640:	4505                	li	a0,1
 642:	2f8000ef          	jal	93a <exit>
            printf("TEST#3 Failed: Child process referenced parent's memory\n");
 646:	00001517          	auipc	a0,0x1
 64a:	bda50513          	addi	a0,a0,-1062 # 1220 <thread_join+0x2b8>
 64e:	714000ef          	jal	d62 <printf>
 652:	b7fd                	j	640 <main+0x2e4>
            printf("Thread %d join failed\n", i);
 654:	85a6                	mv	a1,s1
 656:	00001517          	auipc	a0,0x1
 65a:	b3a50513          	addi	a0,a0,-1222 # 1190 <thread_join+0x228>
 65e:	704000ef          	jal	d62 <printf>
            exit(1);
 662:	4505                	li	a0,1
 664:	2d6000ef          	jal	93a <exit>
        printf("Fork error\n");
 668:	00001517          	auipc	a0,0x1
 66c:	c6050513          	addi	a0,a0,-928 # 12c8 <thread_join+0x360>
 670:	6f2000ef          	jal	d62 <printf>
        exit(1);
 674:	4505                	li	a0,1
 676:	2c4000ef          	jal	93a <exit>
                printf("Thread %d join failed\n", i);
 67a:	85a6                	mv	a1,s1
 67c:	00001517          	auipc	a0,0x1
 680:	b1450513          	addi	a0,a0,-1260 # 1190 <thread_join+0x228>
 684:	6de000ef          	jal	d62 <printf>
                exit(1);
 688:	4505                	li	a0,1
 68a:	2b0000ef          	jal	93a <exit>
        sleep(30);
 68e:	4579                	li	a0,30
 690:	33a000ef          	jal	9ca <sleep>
        wait(0);
 694:	4501                	li	a0,0
 696:	2ac000ef          	jal	942 <wait>
 69a:	b57d                	j	548 <main+0x1ec>
        printf("Fork error\n");
 69c:	00001517          	auipc	a0,0x1
 6a0:	c2c50513          	addi	a0,a0,-980 # 12c8 <thread_join+0x360>
 6a4:	6be000ef          	jal	d62 <printf>
        exit(1);
 6a8:	4505                	li	a0,1
 6aa:	290000ef          	jal	93a <exit>
                printf("Thread %d join failed\n", i);
 6ae:	85a6                	mv	a1,s1
 6b0:	00001517          	auipc	a0,0x1
 6b4:	ae050513          	addi	a0,a0,-1312 # 1190 <thread_join+0x228>
 6b8:	6aa000ef          	jal	d62 <printf>
                exit(1);
 6bc:	4505                	li	a0,1
 6be:	27c000ef          	jal	93a <exit>
        sleep(30);
 6c2:	4579                	li	a0,30
 6c4:	306000ef          	jal	9ca <sleep>
        wait(0);
 6c8:	4501                	li	a0,0
 6ca:	278000ef          	jal	942 <wait>
 6ce:	bdc9                	j	5a0 <main+0x244>

00000000000006d0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 6d0:	1141                	addi	sp,sp,-16
 6d2:	e406                	sd	ra,8(sp)
 6d4:	e022                	sd	s0,0(sp)
 6d6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 6d8:	c85ff0ef          	jal	35c <main>
  exit(0);
 6dc:	4501                	li	a0,0
 6de:	25c000ef          	jal	93a <exit>

00000000000006e2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 6e2:	1141                	addi	sp,sp,-16
 6e4:	e422                	sd	s0,8(sp)
 6e6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6e8:	87aa                	mv	a5,a0
 6ea:	0585                	addi	a1,a1,1
 6ec:	0785                	addi	a5,a5,1
 6ee:	fff5c703          	lbu	a4,-1(a1)
 6f2:	fee78fa3          	sb	a4,-1(a5)
 6f6:	fb75                	bnez	a4,6ea <strcpy+0x8>
    ;
  return os;
}
 6f8:	6422                	ld	s0,8(sp)
 6fa:	0141                	addi	sp,sp,16
 6fc:	8082                	ret

00000000000006fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6fe:	1141                	addi	sp,sp,-16
 700:	e422                	sd	s0,8(sp)
 702:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 704:	00054783          	lbu	a5,0(a0)
 708:	cb91                	beqz	a5,71c <strcmp+0x1e>
 70a:	0005c703          	lbu	a4,0(a1)
 70e:	00f71763          	bne	a4,a5,71c <strcmp+0x1e>
    p++, q++;
 712:	0505                	addi	a0,a0,1
 714:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 716:	00054783          	lbu	a5,0(a0)
 71a:	fbe5                	bnez	a5,70a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 71c:	0005c503          	lbu	a0,0(a1)
}
 720:	40a7853b          	subw	a0,a5,a0
 724:	6422                	ld	s0,8(sp)
 726:	0141                	addi	sp,sp,16
 728:	8082                	ret

000000000000072a <strlen>:

uint
strlen(const char *s)
{
 72a:	1141                	addi	sp,sp,-16
 72c:	e422                	sd	s0,8(sp)
 72e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 730:	00054783          	lbu	a5,0(a0)
 734:	cf91                	beqz	a5,750 <strlen+0x26>
 736:	0505                	addi	a0,a0,1
 738:	87aa                	mv	a5,a0
 73a:	86be                	mv	a3,a5
 73c:	0785                	addi	a5,a5,1
 73e:	fff7c703          	lbu	a4,-1(a5)
 742:	ff65                	bnez	a4,73a <strlen+0x10>
 744:	40a6853b          	subw	a0,a3,a0
 748:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 74a:	6422                	ld	s0,8(sp)
 74c:	0141                	addi	sp,sp,16
 74e:	8082                	ret
  for(n = 0; s[n]; n++)
 750:	4501                	li	a0,0
 752:	bfe5                	j	74a <strlen+0x20>

0000000000000754 <memset>:

void*
memset(void *dst, int c, uint n)
{
 754:	1141                	addi	sp,sp,-16
 756:	e422                	sd	s0,8(sp)
 758:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 75a:	ca19                	beqz	a2,770 <memset+0x1c>
 75c:	87aa                	mv	a5,a0
 75e:	1602                	slli	a2,a2,0x20
 760:	9201                	srli	a2,a2,0x20
 762:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 766:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 76a:	0785                	addi	a5,a5,1
 76c:	fee79de3          	bne	a5,a4,766 <memset+0x12>
  }
  return dst;
}
 770:	6422                	ld	s0,8(sp)
 772:	0141                	addi	sp,sp,16
 774:	8082                	ret

0000000000000776 <strchr>:

char*
strchr(const char *s, char c)
{
 776:	1141                	addi	sp,sp,-16
 778:	e422                	sd	s0,8(sp)
 77a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 77c:	00054783          	lbu	a5,0(a0)
 780:	cb99                	beqz	a5,796 <strchr+0x20>
    if(*s == c)
 782:	00f58763          	beq	a1,a5,790 <strchr+0x1a>
  for(; *s; s++)
 786:	0505                	addi	a0,a0,1
 788:	00054783          	lbu	a5,0(a0)
 78c:	fbfd                	bnez	a5,782 <strchr+0xc>
      return (char*)s;
  return 0;
 78e:	4501                	li	a0,0
}
 790:	6422                	ld	s0,8(sp)
 792:	0141                	addi	sp,sp,16
 794:	8082                	ret
  return 0;
 796:	4501                	li	a0,0
 798:	bfe5                	j	790 <strchr+0x1a>

000000000000079a <gets>:

char*
gets(char *buf, int max)
{
 79a:	711d                	addi	sp,sp,-96
 79c:	ec86                	sd	ra,88(sp)
 79e:	e8a2                	sd	s0,80(sp)
 7a0:	e4a6                	sd	s1,72(sp)
 7a2:	e0ca                	sd	s2,64(sp)
 7a4:	fc4e                	sd	s3,56(sp)
 7a6:	f852                	sd	s4,48(sp)
 7a8:	f456                	sd	s5,40(sp)
 7aa:	f05a                	sd	s6,32(sp)
 7ac:	ec5e                	sd	s7,24(sp)
 7ae:	1080                	addi	s0,sp,96
 7b0:	8baa                	mv	s7,a0
 7b2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7b4:	892a                	mv	s2,a0
 7b6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 7b8:	4aa9                	li	s5,10
 7ba:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 7bc:	89a6                	mv	s3,s1
 7be:	2485                	addiw	s1,s1,1
 7c0:	0344d663          	bge	s1,s4,7ec <gets+0x52>
    cc = read(0, &c, 1);
 7c4:	4605                	li	a2,1
 7c6:	faf40593          	addi	a1,s0,-81
 7ca:	4501                	li	a0,0
 7cc:	186000ef          	jal	952 <read>
    if(cc < 1)
 7d0:	00a05e63          	blez	a0,7ec <gets+0x52>
    buf[i++] = c;
 7d4:	faf44783          	lbu	a5,-81(s0)
 7d8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7dc:	01578763          	beq	a5,s5,7ea <gets+0x50>
 7e0:	0905                	addi	s2,s2,1
 7e2:	fd679de3          	bne	a5,s6,7bc <gets+0x22>
    buf[i++] = c;
 7e6:	89a6                	mv	s3,s1
 7e8:	a011                	j	7ec <gets+0x52>
 7ea:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7ec:	99de                	add	s3,s3,s7
 7ee:	00098023          	sb	zero,0(s3)
  return buf;
}
 7f2:	855e                	mv	a0,s7
 7f4:	60e6                	ld	ra,88(sp)
 7f6:	6446                	ld	s0,80(sp)
 7f8:	64a6                	ld	s1,72(sp)
 7fa:	6906                	ld	s2,64(sp)
 7fc:	79e2                	ld	s3,56(sp)
 7fe:	7a42                	ld	s4,48(sp)
 800:	7aa2                	ld	s5,40(sp)
 802:	7b02                	ld	s6,32(sp)
 804:	6be2                	ld	s7,24(sp)
 806:	6125                	addi	sp,sp,96
 808:	8082                	ret

000000000000080a <stat>:

int
stat(const char *n, struct stat *st)
{
 80a:	1101                	addi	sp,sp,-32
 80c:	ec06                	sd	ra,24(sp)
 80e:	e822                	sd	s0,16(sp)
 810:	e04a                	sd	s2,0(sp)
 812:	1000                	addi	s0,sp,32
 814:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 816:	4581                	li	a1,0
 818:	162000ef          	jal	97a <open>
  if(fd < 0)
 81c:	02054263          	bltz	a0,840 <stat+0x36>
 820:	e426                	sd	s1,8(sp)
 822:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 824:	85ca                	mv	a1,s2
 826:	16c000ef          	jal	992 <fstat>
 82a:	892a                	mv	s2,a0
  close(fd);
 82c:	8526                	mv	a0,s1
 82e:	134000ef          	jal	962 <close>
  return r;
 832:	64a2                	ld	s1,8(sp)
}
 834:	854a                	mv	a0,s2
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6902                	ld	s2,0(sp)
 83c:	6105                	addi	sp,sp,32
 83e:	8082                	ret
    return -1;
 840:	597d                	li	s2,-1
 842:	bfcd                	j	834 <stat+0x2a>

0000000000000844 <atoi>:

int
atoi(const char *s)
{
 844:	1141                	addi	sp,sp,-16
 846:	e422                	sd	s0,8(sp)
 848:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 84a:	00054683          	lbu	a3,0(a0)
 84e:	fd06879b          	addiw	a5,a3,-48
 852:	0ff7f793          	zext.b	a5,a5
 856:	4625                	li	a2,9
 858:	02f66863          	bltu	a2,a5,888 <atoi+0x44>
 85c:	872a                	mv	a4,a0
  n = 0;
 85e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 860:	0705                	addi	a4,a4,1
 862:	0025179b          	slliw	a5,a0,0x2
 866:	9fa9                	addw	a5,a5,a0
 868:	0017979b          	slliw	a5,a5,0x1
 86c:	9fb5                	addw	a5,a5,a3
 86e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 872:	00074683          	lbu	a3,0(a4)
 876:	fd06879b          	addiw	a5,a3,-48
 87a:	0ff7f793          	zext.b	a5,a5
 87e:	fef671e3          	bgeu	a2,a5,860 <atoi+0x1c>
  return n;
}
 882:	6422                	ld	s0,8(sp)
 884:	0141                	addi	sp,sp,16
 886:	8082                	ret
  n = 0;
 888:	4501                	li	a0,0
 88a:	bfe5                	j	882 <atoi+0x3e>

000000000000088c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 88c:	1141                	addi	sp,sp,-16
 88e:	e422                	sd	s0,8(sp)
 890:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 892:	02b57463          	bgeu	a0,a1,8ba <memmove+0x2e>
    while(n-- > 0)
 896:	00c05f63          	blez	a2,8b4 <memmove+0x28>
 89a:	1602                	slli	a2,a2,0x20
 89c:	9201                	srli	a2,a2,0x20
 89e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 8a2:	872a                	mv	a4,a0
      *dst++ = *src++;
 8a4:	0585                	addi	a1,a1,1
 8a6:	0705                	addi	a4,a4,1
 8a8:	fff5c683          	lbu	a3,-1(a1)
 8ac:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 8b0:	fef71ae3          	bne	a4,a5,8a4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 8b4:	6422                	ld	s0,8(sp)
 8b6:	0141                	addi	sp,sp,16
 8b8:	8082                	ret
    dst += n;
 8ba:	00c50733          	add	a4,a0,a2
    src += n;
 8be:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 8c0:	fec05ae3          	blez	a2,8b4 <memmove+0x28>
 8c4:	fff6079b          	addiw	a5,a2,-1 # 13fff <base+0x11faf>
 8c8:	1782                	slli	a5,a5,0x20
 8ca:	9381                	srli	a5,a5,0x20
 8cc:	fff7c793          	not	a5,a5
 8d0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8d2:	15fd                	addi	a1,a1,-1
 8d4:	177d                	addi	a4,a4,-1
 8d6:	0005c683          	lbu	a3,0(a1)
 8da:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8de:	fee79ae3          	bne	a5,a4,8d2 <memmove+0x46>
 8e2:	bfc9                	j	8b4 <memmove+0x28>

00000000000008e4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8e4:	1141                	addi	sp,sp,-16
 8e6:	e422                	sd	s0,8(sp)
 8e8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8ea:	ca05                	beqz	a2,91a <memcmp+0x36>
 8ec:	fff6069b          	addiw	a3,a2,-1
 8f0:	1682                	slli	a3,a3,0x20
 8f2:	9281                	srli	a3,a3,0x20
 8f4:	0685                	addi	a3,a3,1
 8f6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8f8:	00054783          	lbu	a5,0(a0)
 8fc:	0005c703          	lbu	a4,0(a1)
 900:	00e79863          	bne	a5,a4,910 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 904:	0505                	addi	a0,a0,1
    p2++;
 906:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 908:	fed518e3          	bne	a0,a3,8f8 <memcmp+0x14>
  }
  return 0;
 90c:	4501                	li	a0,0
 90e:	a019                	j	914 <memcmp+0x30>
      return *p1 - *p2;
 910:	40e7853b          	subw	a0,a5,a4
}
 914:	6422                	ld	s0,8(sp)
 916:	0141                	addi	sp,sp,16
 918:	8082                	ret
  return 0;
 91a:	4501                	li	a0,0
 91c:	bfe5                	j	914 <memcmp+0x30>

000000000000091e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 91e:	1141                	addi	sp,sp,-16
 920:	e406                	sd	ra,8(sp)
 922:	e022                	sd	s0,0(sp)
 924:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 926:	f67ff0ef          	jal	88c <memmove>
}
 92a:	60a2                	ld	ra,8(sp)
 92c:	6402                	ld	s0,0(sp)
 92e:	0141                	addi	sp,sp,16
 930:	8082                	ret

0000000000000932 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 932:	4885                	li	a7,1
 ecall
 934:	00000073          	ecall
 ret
 938:	8082                	ret

000000000000093a <exit>:
.global exit
exit:
 li a7, SYS_exit
 93a:	4889                	li	a7,2
 ecall
 93c:	00000073          	ecall
 ret
 940:	8082                	ret

0000000000000942 <wait>:
.global wait
wait:
 li a7, SYS_wait
 942:	488d                	li	a7,3
 ecall
 944:	00000073          	ecall
 ret
 948:	8082                	ret

000000000000094a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 94a:	4891                	li	a7,4
 ecall
 94c:	00000073          	ecall
 ret
 950:	8082                	ret

0000000000000952 <read>:
.global read
read:
 li a7, SYS_read
 952:	4895                	li	a7,5
 ecall
 954:	00000073          	ecall
 ret
 958:	8082                	ret

000000000000095a <write>:
.global write
write:
 li a7, SYS_write
 95a:	48c1                	li	a7,16
 ecall
 95c:	00000073          	ecall
 ret
 960:	8082                	ret

0000000000000962 <close>:
.global close
close:
 li a7, SYS_close
 962:	48d5                	li	a7,21
 ecall
 964:	00000073          	ecall
 ret
 968:	8082                	ret

000000000000096a <kill>:
.global kill
kill:
 li a7, SYS_kill
 96a:	4899                	li	a7,6
 ecall
 96c:	00000073          	ecall
 ret
 970:	8082                	ret

0000000000000972 <exec>:
.global exec
exec:
 li a7, SYS_exec
 972:	489d                	li	a7,7
 ecall
 974:	00000073          	ecall
 ret
 978:	8082                	ret

000000000000097a <open>:
.global open
open:
 li a7, SYS_open
 97a:	48bd                	li	a7,15
 ecall
 97c:	00000073          	ecall
 ret
 980:	8082                	ret

0000000000000982 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 982:	48c5                	li	a7,17
 ecall
 984:	00000073          	ecall
 ret
 988:	8082                	ret

000000000000098a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 98a:	48c9                	li	a7,18
 ecall
 98c:	00000073          	ecall
 ret
 990:	8082                	ret

0000000000000992 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 992:	48a1                	li	a7,8
 ecall
 994:	00000073          	ecall
 ret
 998:	8082                	ret

000000000000099a <link>:
.global link
link:
 li a7, SYS_link
 99a:	48cd                	li	a7,19
 ecall
 99c:	00000073          	ecall
 ret
 9a0:	8082                	ret

00000000000009a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 9a2:	48d1                	li	a7,20
 ecall
 9a4:	00000073          	ecall
 ret
 9a8:	8082                	ret

00000000000009aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 9aa:	48a5                	li	a7,9
 ecall
 9ac:	00000073          	ecall
 ret
 9b0:	8082                	ret

00000000000009b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 9b2:	48a9                	li	a7,10
 ecall
 9b4:	00000073          	ecall
 ret
 9b8:	8082                	ret

00000000000009ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 9ba:	48ad                	li	a7,11
 ecall
 9bc:	00000073          	ecall
 ret
 9c0:	8082                	ret

00000000000009c2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 9c2:	48b1                	li	a7,12
 ecall
 9c4:	00000073          	ecall
 ret
 9c8:	8082                	ret

00000000000009ca <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9ca:	48b5                	li	a7,13
 ecall
 9cc:	00000073          	ecall
 ret
 9d0:	8082                	ret

00000000000009d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 9d2:	48b9                	li	a7,14
 ecall
 9d4:	00000073          	ecall
 ret
 9d8:	8082                	ret

00000000000009da <clone>:
.global clone
clone:
 li a7, SYS_clone
 9da:	48d9                	li	a7,22
 ecall
 9dc:	00000073          	ecall
 ret
 9e0:	8082                	ret

00000000000009e2 <join>:
.global join
join:
 li a7, SYS_join
 9e2:	48dd                	li	a7,23
 ecall
 9e4:	00000073          	ecall
 ret
 9e8:	8082                	ret

00000000000009ea <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9ea:	1101                	addi	sp,sp,-32
 9ec:	ec06                	sd	ra,24(sp)
 9ee:	e822                	sd	s0,16(sp)
 9f0:	1000                	addi	s0,sp,32
 9f2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9f6:	4605                	li	a2,1
 9f8:	fef40593          	addi	a1,s0,-17
 9fc:	f5fff0ef          	jal	95a <write>
}
 a00:	60e2                	ld	ra,24(sp)
 a02:	6442                	ld	s0,16(sp)
 a04:	6105                	addi	sp,sp,32
 a06:	8082                	ret

0000000000000a08 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a08:	7139                	addi	sp,sp,-64
 a0a:	fc06                	sd	ra,56(sp)
 a0c:	f822                	sd	s0,48(sp)
 a0e:	f426                	sd	s1,40(sp)
 a10:	0080                	addi	s0,sp,64
 a12:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a14:	c299                	beqz	a3,a1a <printint+0x12>
 a16:	0805c963          	bltz	a1,aa8 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a1a:	2581                	sext.w	a1,a1
  neg = 0;
 a1c:	4881                	li	a7,0
 a1e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a22:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a24:	2601                	sext.w	a2,a2
 a26:	00001517          	auipc	a0,0x1
 a2a:	93a50513          	addi	a0,a0,-1734 # 1360 <digits>
 a2e:	883a                	mv	a6,a4
 a30:	2705                	addiw	a4,a4,1
 a32:	02c5f7bb          	remuw	a5,a1,a2
 a36:	1782                	slli	a5,a5,0x20
 a38:	9381                	srli	a5,a5,0x20
 a3a:	97aa                	add	a5,a5,a0
 a3c:	0007c783          	lbu	a5,0(a5)
 a40:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a44:	0005879b          	sext.w	a5,a1
 a48:	02c5d5bb          	divuw	a1,a1,a2
 a4c:	0685                	addi	a3,a3,1
 a4e:	fec7f0e3          	bgeu	a5,a2,a2e <printint+0x26>
  if(neg)
 a52:	00088c63          	beqz	a7,a6a <printint+0x62>
    buf[i++] = '-';
 a56:	fd070793          	addi	a5,a4,-48
 a5a:	00878733          	add	a4,a5,s0
 a5e:	02d00793          	li	a5,45
 a62:	fef70823          	sb	a5,-16(a4)
 a66:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a6a:	02e05a63          	blez	a4,a9e <printint+0x96>
 a6e:	f04a                	sd	s2,32(sp)
 a70:	ec4e                	sd	s3,24(sp)
 a72:	fc040793          	addi	a5,s0,-64
 a76:	00e78933          	add	s2,a5,a4
 a7a:	fff78993          	addi	s3,a5,-1
 a7e:	99ba                	add	s3,s3,a4
 a80:	377d                	addiw	a4,a4,-1
 a82:	1702                	slli	a4,a4,0x20
 a84:	9301                	srli	a4,a4,0x20
 a86:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a8a:	fff94583          	lbu	a1,-1(s2)
 a8e:	8526                	mv	a0,s1
 a90:	f5bff0ef          	jal	9ea <putc>
  while(--i >= 0)
 a94:	197d                	addi	s2,s2,-1
 a96:	ff391ae3          	bne	s2,s3,a8a <printint+0x82>
 a9a:	7902                	ld	s2,32(sp)
 a9c:	69e2                	ld	s3,24(sp)
}
 a9e:	70e2                	ld	ra,56(sp)
 aa0:	7442                	ld	s0,48(sp)
 aa2:	74a2                	ld	s1,40(sp)
 aa4:	6121                	addi	sp,sp,64
 aa6:	8082                	ret
    x = -xx;
 aa8:	40b005bb          	negw	a1,a1
    neg = 1;
 aac:	4885                	li	a7,1
    x = -xx;
 aae:	bf85                	j	a1e <printint+0x16>

0000000000000ab0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 ab0:	711d                	addi	sp,sp,-96
 ab2:	ec86                	sd	ra,88(sp)
 ab4:	e8a2                	sd	s0,80(sp)
 ab6:	e0ca                	sd	s2,64(sp)
 ab8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 aba:	0005c903          	lbu	s2,0(a1)
 abe:	26090863          	beqz	s2,d2e <vprintf+0x27e>
 ac2:	e4a6                	sd	s1,72(sp)
 ac4:	fc4e                	sd	s3,56(sp)
 ac6:	f852                	sd	s4,48(sp)
 ac8:	f456                	sd	s5,40(sp)
 aca:	f05a                	sd	s6,32(sp)
 acc:	ec5e                	sd	s7,24(sp)
 ace:	e862                	sd	s8,16(sp)
 ad0:	e466                	sd	s9,8(sp)
 ad2:	8b2a                	mv	s6,a0
 ad4:	8a2e                	mv	s4,a1
 ad6:	8bb2                	mv	s7,a2
  state = 0;
 ad8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 ada:	4481                	li	s1,0
 adc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 ade:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 ae2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 ae6:	06c00c93          	li	s9,108
 aea:	a005                	j	b0a <vprintf+0x5a>
        putc(fd, c0);
 aec:	85ca                	mv	a1,s2
 aee:	855a                	mv	a0,s6
 af0:	efbff0ef          	jal	9ea <putc>
 af4:	a019                	j	afa <vprintf+0x4a>
    } else if(state == '%'){
 af6:	03598263          	beq	s3,s5,b1a <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 afa:	2485                	addiw	s1,s1,1
 afc:	8726                	mv	a4,s1
 afe:	009a07b3          	add	a5,s4,s1
 b02:	0007c903          	lbu	s2,0(a5)
 b06:	20090c63          	beqz	s2,d1e <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 b0a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 b0e:	fe0994e3          	bnez	s3,af6 <vprintf+0x46>
      if(c0 == '%'){
 b12:	fd579de3          	bne	a5,s5,aec <vprintf+0x3c>
        state = '%';
 b16:	89be                	mv	s3,a5
 b18:	b7cd                	j	afa <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 b1a:	00ea06b3          	add	a3,s4,a4
 b1e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 b22:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 b24:	c681                	beqz	a3,b2c <vprintf+0x7c>
 b26:	9752                	add	a4,a4,s4
 b28:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 b2c:	03878f63          	beq	a5,s8,b6a <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 b30:	05978963          	beq	a5,s9,b82 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 b34:	07500713          	li	a4,117
 b38:	0ee78363          	beq	a5,a4,c1e <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 b3c:	07800713          	li	a4,120
 b40:	12e78563          	beq	a5,a4,c6a <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 b44:	07000713          	li	a4,112
 b48:	14e78a63          	beq	a5,a4,c9c <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 b4c:	07300713          	li	a4,115
 b50:	18e78a63          	beq	a5,a4,ce4 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 b54:	02500713          	li	a4,37
 b58:	04e79563          	bne	a5,a4,ba2 <vprintf+0xf2>
        putc(fd, '%');
 b5c:	02500593          	li	a1,37
 b60:	855a                	mv	a0,s6
 b62:	e89ff0ef          	jal	9ea <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 b66:	4981                	li	s3,0
 b68:	bf49                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 b6a:	008b8913          	addi	s2,s7,8
 b6e:	4685                	li	a3,1
 b70:	4629                	li	a2,10
 b72:	000ba583          	lw	a1,0(s7)
 b76:	855a                	mv	a0,s6
 b78:	e91ff0ef          	jal	a08 <printint>
 b7c:	8bca                	mv	s7,s2
      state = 0;
 b7e:	4981                	li	s3,0
 b80:	bfad                	j	afa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 b82:	06400793          	li	a5,100
 b86:	02f68963          	beq	a3,a5,bb8 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 b8a:	06c00793          	li	a5,108
 b8e:	04f68263          	beq	a3,a5,bd2 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 b92:	07500793          	li	a5,117
 b96:	0af68063          	beq	a3,a5,c36 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 b9a:	07800793          	li	a5,120
 b9e:	0ef68263          	beq	a3,a5,c82 <vprintf+0x1d2>
        putc(fd, '%');
 ba2:	02500593          	li	a1,37
 ba6:	855a                	mv	a0,s6
 ba8:	e43ff0ef          	jal	9ea <putc>
        putc(fd, c0);
 bac:	85ca                	mv	a1,s2
 bae:	855a                	mv	a0,s6
 bb0:	e3bff0ef          	jal	9ea <putc>
      state = 0;
 bb4:	4981                	li	s3,0
 bb6:	b791                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 bb8:	008b8913          	addi	s2,s7,8
 bbc:	4685                	li	a3,1
 bbe:	4629                	li	a2,10
 bc0:	000ba583          	lw	a1,0(s7)
 bc4:	855a                	mv	a0,s6
 bc6:	e43ff0ef          	jal	a08 <printint>
        i += 1;
 bca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 bcc:	8bca                	mv	s7,s2
      state = 0;
 bce:	4981                	li	s3,0
        i += 1;
 bd0:	b72d                	j	afa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 bd2:	06400793          	li	a5,100
 bd6:	02f60763          	beq	a2,a5,c04 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 bda:	07500793          	li	a5,117
 bde:	06f60963          	beq	a2,a5,c50 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 be2:	07800793          	li	a5,120
 be6:	faf61ee3          	bne	a2,a5,ba2 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 bea:	008b8913          	addi	s2,s7,8
 bee:	4681                	li	a3,0
 bf0:	4641                	li	a2,16
 bf2:	000ba583          	lw	a1,0(s7)
 bf6:	855a                	mv	a0,s6
 bf8:	e11ff0ef          	jal	a08 <printint>
        i += 2;
 bfc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 bfe:	8bca                	mv	s7,s2
      state = 0;
 c00:	4981                	li	s3,0
        i += 2;
 c02:	bde5                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 c04:	008b8913          	addi	s2,s7,8
 c08:	4685                	li	a3,1
 c0a:	4629                	li	a2,10
 c0c:	000ba583          	lw	a1,0(s7)
 c10:	855a                	mv	a0,s6
 c12:	df7ff0ef          	jal	a08 <printint>
        i += 2;
 c16:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 c18:	8bca                	mv	s7,s2
      state = 0;
 c1a:	4981                	li	s3,0
        i += 2;
 c1c:	bdf9                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 c1e:	008b8913          	addi	s2,s7,8
 c22:	4681                	li	a3,0
 c24:	4629                	li	a2,10
 c26:	000ba583          	lw	a1,0(s7)
 c2a:	855a                	mv	a0,s6
 c2c:	dddff0ef          	jal	a08 <printint>
 c30:	8bca                	mv	s7,s2
      state = 0;
 c32:	4981                	li	s3,0
 c34:	b5d9                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c36:	008b8913          	addi	s2,s7,8
 c3a:	4681                	li	a3,0
 c3c:	4629                	li	a2,10
 c3e:	000ba583          	lw	a1,0(s7)
 c42:	855a                	mv	a0,s6
 c44:	dc5ff0ef          	jal	a08 <printint>
        i += 1;
 c48:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 c4a:	8bca                	mv	s7,s2
      state = 0;
 c4c:	4981                	li	s3,0
        i += 1;
 c4e:	b575                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c50:	008b8913          	addi	s2,s7,8
 c54:	4681                	li	a3,0
 c56:	4629                	li	a2,10
 c58:	000ba583          	lw	a1,0(s7)
 c5c:	855a                	mv	a0,s6
 c5e:	dabff0ef          	jal	a08 <printint>
        i += 2;
 c62:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 c64:	8bca                	mv	s7,s2
      state = 0;
 c66:	4981                	li	s3,0
        i += 2;
 c68:	bd49                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 c6a:	008b8913          	addi	s2,s7,8
 c6e:	4681                	li	a3,0
 c70:	4641                	li	a2,16
 c72:	000ba583          	lw	a1,0(s7)
 c76:	855a                	mv	a0,s6
 c78:	d91ff0ef          	jal	a08 <printint>
 c7c:	8bca                	mv	s7,s2
      state = 0;
 c7e:	4981                	li	s3,0
 c80:	bdad                	j	afa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 c82:	008b8913          	addi	s2,s7,8
 c86:	4681                	li	a3,0
 c88:	4641                	li	a2,16
 c8a:	000ba583          	lw	a1,0(s7)
 c8e:	855a                	mv	a0,s6
 c90:	d79ff0ef          	jal	a08 <printint>
        i += 1;
 c94:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 c96:	8bca                	mv	s7,s2
      state = 0;
 c98:	4981                	li	s3,0
        i += 1;
 c9a:	b585                	j	afa <vprintf+0x4a>
 c9c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 c9e:	008b8d13          	addi	s10,s7,8
 ca2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 ca6:	03000593          	li	a1,48
 caa:	855a                	mv	a0,s6
 cac:	d3fff0ef          	jal	9ea <putc>
  putc(fd, 'x');
 cb0:	07800593          	li	a1,120
 cb4:	855a                	mv	a0,s6
 cb6:	d35ff0ef          	jal	9ea <putc>
 cba:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 cbc:	00000b97          	auipc	s7,0x0
 cc0:	6a4b8b93          	addi	s7,s7,1700 # 1360 <digits>
 cc4:	03c9d793          	srli	a5,s3,0x3c
 cc8:	97de                	add	a5,a5,s7
 cca:	0007c583          	lbu	a1,0(a5)
 cce:	855a                	mv	a0,s6
 cd0:	d1bff0ef          	jal	9ea <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 cd4:	0992                	slli	s3,s3,0x4
 cd6:	397d                	addiw	s2,s2,-1
 cd8:	fe0916e3          	bnez	s2,cc4 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 cdc:	8bea                	mv	s7,s10
      state = 0;
 cde:	4981                	li	s3,0
 ce0:	6d02                	ld	s10,0(sp)
 ce2:	bd21                	j	afa <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 ce4:	008b8993          	addi	s3,s7,8
 ce8:	000bb903          	ld	s2,0(s7)
 cec:	00090f63          	beqz	s2,d0a <vprintf+0x25a>
        for(; *s; s++)
 cf0:	00094583          	lbu	a1,0(s2)
 cf4:	c195                	beqz	a1,d18 <vprintf+0x268>
          putc(fd, *s);
 cf6:	855a                	mv	a0,s6
 cf8:	cf3ff0ef          	jal	9ea <putc>
        for(; *s; s++)
 cfc:	0905                	addi	s2,s2,1
 cfe:	00094583          	lbu	a1,0(s2)
 d02:	f9f5                	bnez	a1,cf6 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 d04:	8bce                	mv	s7,s3
      state = 0;
 d06:	4981                	li	s3,0
 d08:	bbcd                	j	afa <vprintf+0x4a>
          s = "(null)";
 d0a:	00000917          	auipc	s2,0x0
 d0e:	61e90913          	addi	s2,s2,1566 # 1328 <thread_join+0x3c0>
        for(; *s; s++)
 d12:	02800593          	li	a1,40
 d16:	b7c5                	j	cf6 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 d18:	8bce                	mv	s7,s3
      state = 0;
 d1a:	4981                	li	s3,0
 d1c:	bbf9                	j	afa <vprintf+0x4a>
 d1e:	64a6                	ld	s1,72(sp)
 d20:	79e2                	ld	s3,56(sp)
 d22:	7a42                	ld	s4,48(sp)
 d24:	7aa2                	ld	s5,40(sp)
 d26:	7b02                	ld	s6,32(sp)
 d28:	6be2                	ld	s7,24(sp)
 d2a:	6c42                	ld	s8,16(sp)
 d2c:	6ca2                	ld	s9,8(sp)
    }
  }
}
 d2e:	60e6                	ld	ra,88(sp)
 d30:	6446                	ld	s0,80(sp)
 d32:	6906                	ld	s2,64(sp)
 d34:	6125                	addi	sp,sp,96
 d36:	8082                	ret

0000000000000d38 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d38:	715d                	addi	sp,sp,-80
 d3a:	ec06                	sd	ra,24(sp)
 d3c:	e822                	sd	s0,16(sp)
 d3e:	1000                	addi	s0,sp,32
 d40:	e010                	sd	a2,0(s0)
 d42:	e414                	sd	a3,8(s0)
 d44:	e818                	sd	a4,16(s0)
 d46:	ec1c                	sd	a5,24(s0)
 d48:	03043023          	sd	a6,32(s0)
 d4c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 d50:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 d54:	8622                	mv	a2,s0
 d56:	d5bff0ef          	jal	ab0 <vprintf>
}
 d5a:	60e2                	ld	ra,24(sp)
 d5c:	6442                	ld	s0,16(sp)
 d5e:	6161                	addi	sp,sp,80
 d60:	8082                	ret

0000000000000d62 <printf>:

void
printf(const char *fmt, ...)
{
 d62:	711d                	addi	sp,sp,-96
 d64:	ec06                	sd	ra,24(sp)
 d66:	e822                	sd	s0,16(sp)
 d68:	1000                	addi	s0,sp,32
 d6a:	e40c                	sd	a1,8(s0)
 d6c:	e810                	sd	a2,16(s0)
 d6e:	ec14                	sd	a3,24(s0)
 d70:	f018                	sd	a4,32(s0)
 d72:	f41c                	sd	a5,40(s0)
 d74:	03043823          	sd	a6,48(s0)
 d78:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d7c:	00840613          	addi	a2,s0,8
 d80:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 d84:	85aa                	mv	a1,a0
 d86:	4505                	li	a0,1
 d88:	d29ff0ef          	jal	ab0 <vprintf>
}
 d8c:	60e2                	ld	ra,24(sp)
 d8e:	6442                	ld	s0,16(sp)
 d90:	6125                	addi	sp,sp,96
 d92:	8082                	ret

0000000000000d94 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d94:	1141                	addi	sp,sp,-16
 d96:	e422                	sd	s0,8(sp)
 d98:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d9a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d9e:	00001797          	auipc	a5,0x1
 da2:	2727b783          	ld	a5,626(a5) # 2010 <freep>
 da6:	a02d                	j	dd0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 da8:	4618                	lw	a4,8(a2)
 daa:	9f2d                	addw	a4,a4,a1
 dac:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 db0:	6398                	ld	a4,0(a5)
 db2:	6310                	ld	a2,0(a4)
 db4:	a83d                	j	df2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 db6:	ff852703          	lw	a4,-8(a0)
 dba:	9f31                	addw	a4,a4,a2
 dbc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 dbe:	ff053683          	ld	a3,-16(a0)
 dc2:	a091                	j	e06 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 dc4:	6398                	ld	a4,0(a5)
 dc6:	00e7e463          	bltu	a5,a4,dce <free+0x3a>
 dca:	00e6ea63          	bltu	a3,a4,dde <free+0x4a>
{
 dce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 dd0:	fed7fae3          	bgeu	a5,a3,dc4 <free+0x30>
 dd4:	6398                	ld	a4,0(a5)
 dd6:	00e6e463          	bltu	a3,a4,dde <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 dda:	fee7eae3          	bltu	a5,a4,dce <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 dde:	ff852583          	lw	a1,-8(a0)
 de2:	6390                	ld	a2,0(a5)
 de4:	02059813          	slli	a6,a1,0x20
 de8:	01c85713          	srli	a4,a6,0x1c
 dec:	9736                	add	a4,a4,a3
 dee:	fae60de3          	beq	a2,a4,da8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 df2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 df6:	4790                	lw	a2,8(a5)
 df8:	02061593          	slli	a1,a2,0x20
 dfc:	01c5d713          	srli	a4,a1,0x1c
 e00:	973e                	add	a4,a4,a5
 e02:	fae68ae3          	beq	a3,a4,db6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 e06:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 e08:	00001717          	auipc	a4,0x1
 e0c:	20f73423          	sd	a5,520(a4) # 2010 <freep>
}
 e10:	6422                	ld	s0,8(sp)
 e12:	0141                	addi	sp,sp,16
 e14:	8082                	ret

0000000000000e16 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e16:	7139                	addi	sp,sp,-64
 e18:	fc06                	sd	ra,56(sp)
 e1a:	f822                	sd	s0,48(sp)
 e1c:	f426                	sd	s1,40(sp)
 e1e:	ec4e                	sd	s3,24(sp)
 e20:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e22:	02051493          	slli	s1,a0,0x20
 e26:	9081                	srli	s1,s1,0x20
 e28:	04bd                	addi	s1,s1,15
 e2a:	8091                	srli	s1,s1,0x4
 e2c:	0014899b          	addiw	s3,s1,1
 e30:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 e32:	00001517          	auipc	a0,0x1
 e36:	1de53503          	ld	a0,478(a0) # 2010 <freep>
 e3a:	c915                	beqz	a0,e6e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e3c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e3e:	4798                	lw	a4,8(a5)
 e40:	08977a63          	bgeu	a4,s1,ed4 <malloc+0xbe>
 e44:	f04a                	sd	s2,32(sp)
 e46:	e852                	sd	s4,16(sp)
 e48:	e456                	sd	s5,8(sp)
 e4a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 e4c:	8a4e                	mv	s4,s3
 e4e:	0009871b          	sext.w	a4,s3
 e52:	6685                	lui	a3,0x1
 e54:	00d77363          	bgeu	a4,a3,e5a <malloc+0x44>
 e58:	6a05                	lui	s4,0x1
 e5a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 e5e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 e62:	00001917          	auipc	s2,0x1
 e66:	1ae90913          	addi	s2,s2,430 # 2010 <freep>
  if(p == (char*)-1)
 e6a:	5afd                	li	s5,-1
 e6c:	a081                	j	eac <malloc+0x96>
 e6e:	f04a                	sd	s2,32(sp)
 e70:	e852                	sd	s4,16(sp)
 e72:	e456                	sd	s5,8(sp)
 e74:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 e76:	00001797          	auipc	a5,0x1
 e7a:	1da78793          	addi	a5,a5,474 # 2050 <base>
 e7e:	00001717          	auipc	a4,0x1
 e82:	18f73923          	sd	a5,402(a4) # 2010 <freep>
 e86:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 e88:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 e8c:	b7c1                	j	e4c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 e8e:	6398                	ld	a4,0(a5)
 e90:	e118                	sd	a4,0(a0)
 e92:	a8a9                	j	eec <malloc+0xd6>
  hp->s.size = nu;
 e94:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e98:	0541                	addi	a0,a0,16
 e9a:	efbff0ef          	jal	d94 <free>
  return freep;
 e9e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ea2:	c12d                	beqz	a0,f04 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ea4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ea6:	4798                	lw	a4,8(a5)
 ea8:	02977263          	bgeu	a4,s1,ecc <malloc+0xb6>
    if(p == freep)
 eac:	00093703          	ld	a4,0(s2)
 eb0:	853e                	mv	a0,a5
 eb2:	fef719e3          	bne	a4,a5,ea4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 eb6:	8552                	mv	a0,s4
 eb8:	b0bff0ef          	jal	9c2 <sbrk>
  if(p == (char*)-1)
 ebc:	fd551ce3          	bne	a0,s5,e94 <malloc+0x7e>
        return 0;
 ec0:	4501                	li	a0,0
 ec2:	7902                	ld	s2,32(sp)
 ec4:	6a42                	ld	s4,16(sp)
 ec6:	6aa2                	ld	s5,8(sp)
 ec8:	6b02                	ld	s6,0(sp)
 eca:	a03d                	j	ef8 <malloc+0xe2>
 ecc:	7902                	ld	s2,32(sp)
 ece:	6a42                	ld	s4,16(sp)
 ed0:	6aa2                	ld	s5,8(sp)
 ed2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ed4:	fae48de3          	beq	s1,a4,e8e <malloc+0x78>
        p->s.size -= nunits;
 ed8:	4137073b          	subw	a4,a4,s3
 edc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ede:	02071693          	slli	a3,a4,0x20
 ee2:	01c6d713          	srli	a4,a3,0x1c
 ee6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ee8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 eec:	00001717          	auipc	a4,0x1
 ef0:	12a73223          	sd	a0,292(a4) # 2010 <freep>
      return (void*)(p + 1);
 ef4:	01078513          	addi	a0,a5,16
  }
}
 ef8:	70e2                	ld	ra,56(sp)
 efa:	7442                	ld	s0,48(sp)
 efc:	74a2                	ld	s1,40(sp)
 efe:	69e2                	ld	s3,24(sp)
 f00:	6121                	addi	sp,sp,64
 f02:	8082                	ret
 f04:	7902                	ld	s2,32(sp)
 f06:	6a42                	ld	s4,16(sp)
 f08:	6aa2                	ld	s5,8(sp)
 f0a:	6b02                	ld	s6,0(sp)
 f0c:	b7f5                	j	ef8 <malloc+0xe2>

0000000000000f0e <thread_create>:
#include "user/user.h"
#include "user/thread.h"
#include "kernel/riscv.h"

int thread_create(void (*start_routine)(void *, void *), void *arg1, void *arg2)
{
 f0e:	7179                	addi	sp,sp,-48
 f10:	f406                	sd	ra,40(sp)
 f12:	f022                	sd	s0,32(sp)
 f14:	ec26                	sd	s1,24(sp)
 f16:	e84a                	sd	s2,16(sp)
 f18:	e44e                	sd	s3,8(sp)
 f1a:	1800                	addi	s0,sp,48
 f1c:	84aa                	mv	s1,a0
 f1e:	892e                	mv	s2,a1
 f20:	89b2                	mv	s3,a2
  //printf("current process for clone: %d\n", getpid());
  // void *stack = sbrk(4096);
  void *stack = malloc(PGSIZE*2);
 f22:	6509                	lui	a0,0x2
 f24:	ef3ff0ef          	jal	e16 <malloc>

  if (stack == 0) {
 f28:	c105                	beqz	a0,f48 <thread_create+0x3a>
 f2a:	86aa                	mv	a3,a0
    printf("stack allocation failed\n");
    return -1;
  }

  int tid = clone(start_routine, arg1, arg2, stack);
 f2c:	864e                	mv	a2,s3
 f2e:	85ca                	mv	a1,s2
 f30:	8526                	mv	a0,s1
 f32:	aa9ff0ef          	jal	9da <clone>

  if (tid < 0) {
 f36:	02054163          	bltz	a0,f58 <thread_create+0x4a>
    printf("clone failed\n");
    return -1;
  }

  return tid;
}
 f3a:	70a2                	ld	ra,40(sp)
 f3c:	7402                	ld	s0,32(sp)
 f3e:	64e2                	ld	s1,24(sp)
 f40:	6942                	ld	s2,16(sp)
 f42:	69a2                	ld	s3,8(sp)
 f44:	6145                	addi	sp,sp,48
 f46:	8082                	ret
    printf("stack allocation failed\n");
 f48:	00000517          	auipc	a0,0x0
 f4c:	3e850513          	addi	a0,a0,1000 # 1330 <thread_join+0x3c8>
 f50:	e13ff0ef          	jal	d62 <printf>
    return -1;
 f54:	557d                	li	a0,-1
 f56:	b7d5                	j	f3a <thread_create+0x2c>
    printf("clone failed\n");
 f58:	00000517          	auipc	a0,0x0
 f5c:	3f850513          	addi	a0,a0,1016 # 1350 <thread_join+0x3e8>
 f60:	e03ff0ef          	jal	d62 <printf>
    return -1;
 f64:	557d                	li	a0,-1
 f66:	bfd1                	j	f3a <thread_create+0x2c>

0000000000000f68 <thread_join>:

int thread_join(){
 f68:	7179                	addi	sp,sp,-48
 f6a:	f406                	sd	ra,40(sp)
 f6c:	f022                	sd	s0,32(sp)
 f6e:	ec26                	sd	s1,24(sp)
 f70:	1800                	addi	s0,sp,48
  //printf("thread join executed\n");
  void *stack;

  int pid = join(&stack);
 f72:	fd840513          	addi	a0,s0,-40
 f76:	a6dff0ef          	jal	9e2 <join>

  if (pid < 0)
 f7a:	00054d63          	bltz	a0,f94 <thread_join+0x2c>
 f7e:	84aa                	mv	s1,a0
    return -1;

  free(stack);
 f80:	fd843503          	ld	a0,-40(s0)
 f84:	e11ff0ef          	jal	d94 <free>

  return pid;
 f88:	8526                	mv	a0,s1
 f8a:	70a2                	ld	ra,40(sp)
 f8c:	7402                	ld	s0,32(sp)
 f8e:	64e2                	ld	s1,24(sp)
 f90:	6145                	addi	sp,sp,48
 f92:	8082                	ret
    return -1;
 f94:	54fd                	li	s1,-1
 f96:	bfcd                	j	f88 <thread_join+0x20>
