
user/_test_mlfq:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fork_children>:
#define NUM_THREAD 4
#define MAX_LEVEL 3
int parent;

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
   c:	5e2000ef          	jal	5ee <fork>
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
  1a:	fea52503          	lw	a0,-22(a0) # 1000 <parent>
}
  1e:	60e2                	ld	ra,24(sp)
  20:	6442                	ld	s0,16(sp)
  22:	64a2                	ld	s1,8(sp)
  24:	6105                	addi	sp,sp,32
  26:	8082                	ret
      sleep(10);
  28:	4529                	li	a0,10
  2a:	65c000ef          	jal	686 <sleep>
      return getpid();
  2e:	648000ef          	jal	676 <getpid>
  32:	b7f5                	j	1e <fork_children+0x1e>

0000000000000034 <fork_children2>:


int fork_children2()
{
  34:	1101                	addi	sp,sp,-32
  36:	ec06                	sd	ra,24(sp)
  38:	e822                	sd	s0,16(sp)
  3a:	e426                	sd	s1,8(sp)
  3c:	e04a                	sd	s2,0(sp)
  3e:	1000                	addi	s0,sp,32
  int i, p;
  for (i = 0; i < NUM_THREAD; i++)
  40:	4481                	li	s1,0
  42:	4911                	li	s2,4
  {
    if ((p = fork()) == 0)
  44:	5aa000ef          	jal	5ee <fork>
  48:	c10d                	beqz	a0,6a <fork_children2+0x36>
      fprintf(1, "after sleep pid: %d, lv: %d\n", pid, getlev());
      return getpid();
    }
    else
    {
      setpriority(p, i);
  4a:	85a6                	mv	a1,s1
  4c:	64a000ef          	jal	696 <setpriority>
  for (i = 0; i < NUM_THREAD; i++)
  50:	2485                	addiw	s1,s1,1
  52:	ff2499e3          	bne	s1,s2,44 <fork_children2+0x10>
    }
  }
  return parent;
  56:	00001517          	auipc	a0,0x1
  5a:	faa52503          	lw	a0,-86(a0) # 1000 <parent>
}
  5e:	60e2                	ld	ra,24(sp)
  60:	6442                	ld	s0,16(sp)
  62:	64a2                	ld	s1,8(sp)
  64:	6902                	ld	s2,0(sp)
  66:	6105                	addi	sp,sp,32
  68:	8082                	ret
      int pid = getpid();
  6a:	60c000ef          	jal	676 <getpid>
  6e:	84aa                	mv	s1,a0
      fprintf(1, "before sleep pid: %d, lv: %d\n", pid, getlev());
  70:	62e000ef          	jal	69e <getlev>
  74:	86aa                	mv	a3,a0
  76:	8626                	mv	a2,s1
  78:	00001597          	auipc	a1,0x1
  7c:	b7858593          	addi	a1,a1,-1160 # bf0 <malloc+0x106>
  80:	4505                	li	a0,1
  82:	18b000ef          	jal	a0c <fprintf>
      sleep(5);
  86:	4515                	li	a0,5
  88:	5fe000ef          	jal	686 <sleep>
      fprintf(1, "after sleep pid: %d, lv: %d\n", pid, getlev());
  8c:	612000ef          	jal	69e <getlev>
  90:	86aa                	mv	a3,a0
  92:	8626                	mv	a2,s1
  94:	00001597          	auipc	a1,0x1
  98:	b8458593          	addi	a1,a1,-1148 # c18 <malloc+0x12e>
  9c:	4505                	li	a0,1
  9e:	16f000ef          	jal	a0c <fprintf>
      return getpid();
  a2:	5d4000ef          	jal	676 <getpid>
  a6:	bf65                	j	5e <fork_children2+0x2a>

00000000000000a8 <exit_children>:

void exit_children()
{
  a8:	1101                	addi	sp,sp,-32
  aa:	ec06                	sd	ra,24(sp)
  ac:	e822                	sd	s0,16(sp)
  ae:	e426                	sd	s1,8(sp)
  b0:	1000                	addi	s0,sp,32
  if (getpid() != parent) {
  b2:	5c4000ef          	jal	676 <getpid>
  b6:	00001797          	auipc	a5,0x1
  ba:	f4a7a783          	lw	a5,-182(a5) # 1000 <parent>
    exit(0);
  }
  while (wait(0) != -1);
  be:	54fd                	li	s1,-1
  if (getpid() != parent) {
  c0:	00a79c63          	bne	a5,a0,d8 <exit_children+0x30>
  while (wait(0) != -1);
  c4:	4501                	li	a0,0
  c6:	538000ef          	jal	5fe <wait>
  ca:	fe951de3          	bne	a0,s1,c4 <exit_children+0x1c>
}
  ce:	60e2                	ld	ra,24(sp)
  d0:	6442                	ld	s0,16(sp)
  d2:	64a2                	ld	s1,8(sp)
  d4:	6105                	addi	sp,sp,32
  d6:	8082                	ret
    exit(0);
  d8:	4501                	li	a0,0
  da:	51c000ef          	jal	5f6 <exit>

00000000000000de <main>:

int main(int argc, char* argv[])
{
  de:	715d                	addi	sp,sp,-80
  e0:	e486                	sd	ra,72(sp)
  e2:	e0a2                	sd	s0,64(sp)
  e4:	fc26                	sd	s1,56(sp)
  e6:	f84a                	sd	s2,48(sp)
  e8:	f44e                	sd	s3,40(sp)
  ea:	f052                	sd	s4,32(sp)
  ec:	ec56                	sd	s5,24(sp)
  ee:	0880                	addi	s0,sp,80
  f0:	84ae                	mv	s1,a1
  parent = getpid();
  f2:	584000ef          	jal	676 <getpid>
  f6:	00001797          	auipc	a5,0x1
  fa:	f0a7a523          	sw	a0,-246(a5) # 1000 <parent>

  fprintf(1, "MLFQ test start\n");
  fe:	00001597          	auipc	a1,0x1
 102:	b3a58593          	addi	a1,a1,-1222 # c38 <malloc+0x14e>
 106:	4505                	li	a0,1
 108:	105000ef          	jal	a0c <fprintf>
  int i = 0, pid = 0;
  int count[MAX_LEVEL] = { 0, 0, 0 };
 10c:	fa042823          	sw	zero,-80(s0)
 110:	fa042a23          	sw	zero,-76(s0)
 114:	fa042c23          	sw	zero,-72(s0)
  char cmd = argv[1][0];
 118:	649c                	ld	a5,8(s1)
 11a:	0007c783          	lbu	a5,0(a5)
  switch (cmd) {
 11e:	03200713          	li	a4,50
 122:	0ce78063          	beq	a5,a4,1e2 <main+0x104>
 126:	03300713          	li	a4,51
 12a:	16e78463          	beq	a5,a4,292 <main+0x1b4>
 12e:	03100713          	li	a4,49
 132:	22e79c63          	bne	a5,a4,36a <main+0x28c>
  case '1':
    fprintf(1, "[Test 1] default\n");
 136:	00001597          	auipc	a1,0x1
 13a:	b1a58593          	addi	a1,a1,-1254 # c50 <malloc+0x166>
 13e:	4505                	li	a0,1
 140:	0cd000ef          	jal	a0c <fprintf>
    pid = fork_children();
 144:	ebdff0ef          	jal	0 <fork_children>
 148:	89aa                	mv	s3,a0

    if (pid != parent)
 14a:	00001797          	auipc	a5,0x1
 14e:	eb67a783          	lw	a5,-330(a5) # 1000 <parent>
 152:	06a78363          	beq	a5,a0,1b8 <main+0xda>
 156:	64e1                	lui	s1,0x18
 158:	6a048493          	addi	s1,s1,1696 # 186a0 <base+0x17690>
    {
      for (i = 0; i < NUM_LOOP; i++)
      {
        int x = getlev();
        if (x < 0 || x > 2)
 15c:	4909                	li	s2,2
        int x = getlev();
 15e:	540000ef          	jal	69e <getlev>
        if (x < 0 || x > 2)
 162:	0005079b          	sext.w	a5,a0
 166:	06f96363          	bltu	s2,a5,1cc <main+0xee>
        {
          fprintf(1, "Wrong level: %d\n", x);
          exit(0);
        }
        count[x]++;
 16a:	050a                	slli	a0,a0,0x2
 16c:	fc050793          	addi	a5,a0,-64
 170:	00878533          	add	a0,a5,s0
 174:	ff052783          	lw	a5,-16(a0)
 178:	2785                	addiw	a5,a5,1
 17a:	fef52823          	sw	a5,-16(a0)
      for (i = 0; i < NUM_LOOP; i++)
 17e:	34fd                	addiw	s1,s1,-1
 180:	fcf9                	bnez	s1,15e <main+0x80>
      }
      fprintf(1, "Process %d\n", pid);
 182:	864e                	mv	a2,s3
 184:	00001597          	auipc	a1,0x1
 188:	afc58593          	addi	a1,a1,-1284 # c80 <malloc+0x196>
 18c:	4505                	li	a0,1
 18e:	07f000ef          	jal	a0c <fprintf>
      for (i = 0; i < MAX_LEVEL; i++)
 192:	fb040913          	addi	s2,s0,-80
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 196:	00001a97          	auipc	s5,0x1
 19a:	afaa8a93          	addi	s5,s5,-1286 # c90 <malloc+0x1a6>
      for (i = 0; i < MAX_LEVEL; i++)
 19e:	4a0d                	li	s4,3
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 1a0:	00092703          	lw	a4,0(s2)
 1a4:	86a6                	mv	a3,s1
 1a6:	864e                	mv	a2,s3
 1a8:	85d6                	mv	a1,s5
 1aa:	4505                	li	a0,1
 1ac:	061000ef          	jal	a0c <fprintf>
      for (i = 0; i < MAX_LEVEL; i++)
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0911                	addi	s2,s2,4
 1b4:	ff4496e3          	bne	s1,s4,1a0 <main+0xc2>
    }
    exit_children();
 1b8:	ef1ff0ef          	jal	a8 <exit_children>
    fprintf(1, "[Test 1] finished\n");
 1bc:	00001597          	auipc	a1,0x1
 1c0:	aec58593          	addi	a1,a1,-1300 # ca8 <malloc+0x1be>
 1c4:	4505                	li	a0,1
 1c6:	047000ef          	jal	a0c <fprintf>
    break;
 1ca:	a27d                	j	378 <main+0x29a>
          fprintf(1, "Wrong level: %d\n", x);
 1cc:	862a                	mv	a2,a0
 1ce:	00001597          	auipc	a1,0x1
 1d2:	a9a58593          	addi	a1,a1,-1382 # c68 <malloc+0x17e>
 1d6:	4505                	li	a0,1
 1d8:	035000ef          	jal	a0c <fprintf>
          exit(0);
 1dc:	4501                	li	a0,0
 1de:	418000ef          	jal	5f6 <exit>

  case '2':
    fprintf(1, "[Test 2] yield\n");
 1e2:	00001597          	auipc	a1,0x1
 1e6:	ade58593          	addi	a1,a1,-1314 # cc0 <malloc+0x1d6>
 1ea:	4505                	li	a0,1
 1ec:	021000ef          	jal	a0c <fprintf>
    pid = fork_children2();
 1f0:	e45ff0ef          	jal	34 <fork_children2>
 1f4:	89aa                	mv	s3,a0

    if (pid != parent)
 1f6:	00001797          	auipc	a5,0x1
 1fa:	e0a7a783          	lw	a5,-502(a5) # 1000 <parent>
 1fe:	06a78563          	beq	a5,a0,268 <main+0x18a>
 202:	6495                	lui	s1,0x5
 204:	e2048493          	addi	s1,s1,-480 # 4e20 <base+0x3e10>
    {
      for (i = 0; i < NUM_YIELD; i++)
      {
        int x = getlev();
        if (x < 0 || x > 2)
 208:	4909                	li	s2,2
        int x = getlev();
 20a:	494000ef          	jal	69e <getlev>
        if (x < 0 || x > 2)
 20e:	0005079b          	sext.w	a5,a0
 212:	06f96563          	bltu	s2,a5,27c <main+0x19e>
        {
          fprintf(1, "Wrong level: %d\n", x);
          exit(0);
        }
        count[x]++;
 216:	050a                	slli	a0,a0,0x2
 218:	fc050793          	addi	a5,a0,-64
 21c:	00878533          	add	a0,a5,s0
 220:	ff052783          	lw	a5,-16(a0)
 224:	2785                	addiw	a5,a5,1
 226:	fef52823          	sw	a5,-16(a0)
        yield();
 22a:	47c000ef          	jal	6a6 <yield>
      for (i = 0; i < NUM_YIELD; i++)
 22e:	34fd                	addiw	s1,s1,-1
 230:	fce9                	bnez	s1,20a <main+0x12c>
      }
      fprintf(1, "Process %d\n", pid);
 232:	864e                	mv	a2,s3
 234:	00001597          	auipc	a1,0x1
 238:	a4c58593          	addi	a1,a1,-1460 # c80 <malloc+0x196>
 23c:	4505                	li	a0,1
 23e:	7ce000ef          	jal	a0c <fprintf>
      for (i = 0; i < MAX_LEVEL; i++)
 242:	fb040913          	addi	s2,s0,-80
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 246:	00001a97          	auipc	s5,0x1
 24a:	a4aa8a93          	addi	s5,s5,-1462 # c90 <malloc+0x1a6>
      for (i = 0; i < MAX_LEVEL; i++)
 24e:	4a0d                	li	s4,3
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 250:	00092703          	lw	a4,0(s2)
 254:	86a6                	mv	a3,s1
 256:	864e                	mv	a2,s3
 258:	85d6                	mv	a1,s5
 25a:	4505                	li	a0,1
 25c:	7b0000ef          	jal	a0c <fprintf>
      for (i = 0; i < MAX_LEVEL; i++)
 260:	2485                	addiw	s1,s1,1
 262:	0911                	addi	s2,s2,4
 264:	ff4496e3          	bne	s1,s4,250 <main+0x172>

    }
    exit_children();
 268:	e41ff0ef          	jal	a8 <exit_children>
    fprintf(1, "[Test 2] finished\n");
 26c:	00001597          	auipc	a1,0x1
 270:	a6458593          	addi	a1,a1,-1436 # cd0 <malloc+0x1e6>
 274:	4505                	li	a0,1
 276:	796000ef          	jal	a0c <fprintf>
    break;
 27a:	a8fd                	j	378 <main+0x29a>
          fprintf(1, "Wrong level: %d\n", x);
 27c:	862a                	mv	a2,a0
 27e:	00001597          	auipc	a1,0x1
 282:	9ea58593          	addi	a1,a1,-1558 # c68 <malloc+0x17e>
 286:	4505                	li	a0,1
 288:	784000ef          	jal	a0c <fprintf>
          exit(0);
 28c:	4501                	li	a0,0
 28e:	368000ef          	jal	5f6 <exit>

  case '3':
    fprintf(1, "[Test 3] sleep\n");
 292:	00001597          	auipc	a1,0x1
 296:	a5658593          	addi	a1,a1,-1450 # ce8 <malloc+0x1fe>
 29a:	4505                	li	a0,1
 29c:	770000ef          	jal	a0c <fprintf>
    pid = fork_children2();
 2a0:	d95ff0ef          	jal	34 <fork_children2>
 2a4:	89aa                	mv	s3,a0
    if (pid != parent)
 2a6:	00001797          	auipc	a5,0x1
 2aa:	d5a7a783          	lw	a5,-678(a5) # 1000 <parent>
 2ae:	08a78963          	beq	a5,a0,340 <main+0x262>
    {
      int my_pid = getpid();
 2b2:	3c4000ef          	jal	676 <getpid>
 2b6:	8a2a                	mv	s4,a0
      fprintf(1, "pid: %d fork: %d\n", my_pid, getlev());
 2b8:	3e6000ef          	jal	69e <getlev>
 2bc:	86aa                	mv	a3,a0
 2be:	8652                	mv	a2,s4
 2c0:	00001597          	auipc	a1,0x1
 2c4:	a3858593          	addi	a1,a1,-1480 # cf8 <malloc+0x20e>
 2c8:	4505                	li	a0,1
 2ca:	742000ef          	jal	a0c <fprintf>
 2ce:	1f400493          	li	s1,500

      for (i = 0; i < NUM_SLEEP; i++)
      {
        int x = getlev();
        if (x < 0 || x > 2)
 2d2:	4909                	li	s2,2
        int x = getlev();
 2d4:	3ca000ef          	jal	69e <getlev>
        if (x < 0 || x > 2)
 2d8:	0005079b          	sext.w	a5,a0
 2dc:	06f96c63          	bltu	s2,a5,354 <main+0x276>
        {
          fprintf(1, "Wrong level: %d\n", x);
          exit(0);
        }
        count[x]++;
 2e0:	00251613          	slli	a2,a0,0x2
 2e4:	fc060793          	addi	a5,a2,-64
 2e8:	00878633          	add	a2,a5,s0
 2ec:	ff062783          	lw	a5,-16(a2)
 2f0:	2785                	addiw	a5,a5,1
 2f2:	fef62823          	sw	a5,-16(a2)
        sleep(1);
 2f6:	4505                	li	a0,1
 2f8:	38e000ef          	jal	686 <sleep>
      for (i = 0; i < NUM_SLEEP; i++)
 2fc:	34fd                	addiw	s1,s1,-1
 2fe:	f8f9                	bnez	s1,2d4 <main+0x1f6>
      }
      sleep(my_pid * 3);
 300:	450d                	li	a0,3
 302:	0345053b          	mulw	a0,a0,s4
 306:	380000ef          	jal	686 <sleep>
      fprintf(1, "Process %d\n", pid);
 30a:	864e                	mv	a2,s3
 30c:	00001597          	auipc	a1,0x1
 310:	97458593          	addi	a1,a1,-1676 # c80 <malloc+0x196>
 314:	4505                	li	a0,1
 316:	6f6000ef          	jal	a0c <fprintf>
      for (i = 0; i < MAX_LEVEL; i++)
 31a:	fb040913          	addi	s2,s0,-80
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 31e:	00001a97          	auipc	s5,0x1
 322:	972a8a93          	addi	s5,s5,-1678 # c90 <malloc+0x1a6>
      for (i = 0; i < MAX_LEVEL; i++)
 326:	4a0d                	li	s4,3
        fprintf(1, "Process %d , L%d: %d\n", pid, i, count[i]);
 328:	00092703          	lw	a4,0(s2)
 32c:	86a6                	mv	a3,s1
 32e:	864e                	mv	a2,s3
 330:	85d6                	mv	a1,s5
 332:	4505                	li	a0,1
 334:	6d8000ef          	jal	a0c <fprintf>
      for (i = 0; i < MAX_LEVEL; i++)
 338:	2485                	addiw	s1,s1,1
 33a:	0911                	addi	s2,s2,4
 33c:	ff4496e3          	bne	s1,s4,328 <main+0x24a>

    }
    exit_children();
 340:	d69ff0ef          	jal	a8 <exit_children>
    fprintf(1, "[Test 3] finished\n");
 344:	00001597          	auipc	a1,0x1
 348:	9cc58593          	addi	a1,a1,-1588 # d10 <malloc+0x226>
 34c:	4505                	li	a0,1
 34e:	6be000ef          	jal	a0c <fprintf>
    break;
 352:	a01d                	j	378 <main+0x29a>
          fprintf(1, "Wrong level: %d\n", x);
 354:	862a                	mv	a2,a0
 356:	00001597          	auipc	a1,0x1
 35a:	91258593          	addi	a1,a1,-1774 # c68 <malloc+0x17e>
 35e:	4505                	li	a0,1
 360:	6ac000ef          	jal	a0c <fprintf>
          exit(0);
 364:	4501                	li	a0,0
 366:	290000ef          	jal	5f6 <exit>

  default:
    fprintf(1, "wrong cmd\n");
 36a:	00001597          	auipc	a1,0x1
 36e:	9be58593          	addi	a1,a1,-1602 # d28 <malloc+0x23e>
 372:	4505                	li	a0,1
 374:	698000ef          	jal	a0c <fprintf>
    break;
  }

  fprintf(1, "done\n");
 378:	00001597          	auipc	a1,0x1
 37c:	9c058593          	addi	a1,a1,-1600 # d38 <malloc+0x24e>
 380:	4505                	li	a0,1
 382:	68a000ef          	jal	a0c <fprintf>
  exit(0);
 386:	4501                	li	a0,0
 388:	26e000ef          	jal	5f6 <exit>

000000000000038c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e406                	sd	ra,8(sp)
 390:	e022                	sd	s0,0(sp)
 392:	0800                	addi	s0,sp,16
  extern int main();
  main();
 394:	d4bff0ef          	jal	de <main>
  exit(0);
 398:	4501                	li	a0,0
 39a:	25c000ef          	jal	5f6 <exit>

000000000000039e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3a4:	87aa                	mv	a5,a0
 3a6:	0585                	addi	a1,a1,1
 3a8:	0785                	addi	a5,a5,1
 3aa:	fff5c703          	lbu	a4,-1(a1)
 3ae:	fee78fa3          	sb	a4,-1(a5)
 3b2:	fb75                	bnez	a4,3a6 <strcpy+0x8>
    ;
  return os;
}
 3b4:	6422                	ld	s0,8(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret

00000000000003ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3c0:	00054783          	lbu	a5,0(a0)
 3c4:	cb91                	beqz	a5,3d8 <strcmp+0x1e>
 3c6:	0005c703          	lbu	a4,0(a1)
 3ca:	00f71763          	bne	a4,a5,3d8 <strcmp+0x1e>
    p++, q++;
 3ce:	0505                	addi	a0,a0,1
 3d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3d2:	00054783          	lbu	a5,0(a0)
 3d6:	fbe5                	bnez	a5,3c6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3d8:	0005c503          	lbu	a0,0(a1)
}
 3dc:	40a7853b          	subw	a0,a5,a0
 3e0:	6422                	ld	s0,8(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <strlen>:

uint
strlen(const char *s)
{
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e422                	sd	s0,8(sp)
 3ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3ec:	00054783          	lbu	a5,0(a0)
 3f0:	cf91                	beqz	a5,40c <strlen+0x26>
 3f2:	0505                	addi	a0,a0,1
 3f4:	87aa                	mv	a5,a0
 3f6:	86be                	mv	a3,a5
 3f8:	0785                	addi	a5,a5,1
 3fa:	fff7c703          	lbu	a4,-1(a5)
 3fe:	ff65                	bnez	a4,3f6 <strlen+0x10>
 400:	40a6853b          	subw	a0,a3,a0
 404:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret
  for(n = 0; s[n]; n++)
 40c:	4501                	li	a0,0
 40e:	bfe5                	j	406 <strlen+0x20>

0000000000000410 <memset>:

void*
memset(void *dst, int c, uint n)
{
 410:	1141                	addi	sp,sp,-16
 412:	e422                	sd	s0,8(sp)
 414:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 416:	ca19                	beqz	a2,42c <memset+0x1c>
 418:	87aa                	mv	a5,a0
 41a:	1602                	slli	a2,a2,0x20
 41c:	9201                	srli	a2,a2,0x20
 41e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 422:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 426:	0785                	addi	a5,a5,1
 428:	fee79de3          	bne	a5,a4,422 <memset+0x12>
  }
  return dst;
}
 42c:	6422                	ld	s0,8(sp)
 42e:	0141                	addi	sp,sp,16
 430:	8082                	ret

0000000000000432 <strchr>:

char*
strchr(const char *s, char c)
{
 432:	1141                	addi	sp,sp,-16
 434:	e422                	sd	s0,8(sp)
 436:	0800                	addi	s0,sp,16
  for(; *s; s++)
 438:	00054783          	lbu	a5,0(a0)
 43c:	cb99                	beqz	a5,452 <strchr+0x20>
    if(*s == c)
 43e:	00f58763          	beq	a1,a5,44c <strchr+0x1a>
  for(; *s; s++)
 442:	0505                	addi	a0,a0,1
 444:	00054783          	lbu	a5,0(a0)
 448:	fbfd                	bnez	a5,43e <strchr+0xc>
      return (char*)s;
  return 0;
 44a:	4501                	li	a0,0
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
  return 0;
 452:	4501                	li	a0,0
 454:	bfe5                	j	44c <strchr+0x1a>

0000000000000456 <gets>:

char*
gets(char *buf, int max)
{
 456:	711d                	addi	sp,sp,-96
 458:	ec86                	sd	ra,88(sp)
 45a:	e8a2                	sd	s0,80(sp)
 45c:	e4a6                	sd	s1,72(sp)
 45e:	e0ca                	sd	s2,64(sp)
 460:	fc4e                	sd	s3,56(sp)
 462:	f852                	sd	s4,48(sp)
 464:	f456                	sd	s5,40(sp)
 466:	f05a                	sd	s6,32(sp)
 468:	ec5e                	sd	s7,24(sp)
 46a:	1080                	addi	s0,sp,96
 46c:	8baa                	mv	s7,a0
 46e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 470:	892a                	mv	s2,a0
 472:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 474:	4aa9                	li	s5,10
 476:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 478:	89a6                	mv	s3,s1
 47a:	2485                	addiw	s1,s1,1
 47c:	0344d663          	bge	s1,s4,4a8 <gets+0x52>
    cc = read(0, &c, 1);
 480:	4605                	li	a2,1
 482:	faf40593          	addi	a1,s0,-81
 486:	4501                	li	a0,0
 488:	186000ef          	jal	60e <read>
    if(cc < 1)
 48c:	00a05e63          	blez	a0,4a8 <gets+0x52>
    buf[i++] = c;
 490:	faf44783          	lbu	a5,-81(s0)
 494:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 498:	01578763          	beq	a5,s5,4a6 <gets+0x50>
 49c:	0905                	addi	s2,s2,1
 49e:	fd679de3          	bne	a5,s6,478 <gets+0x22>
    buf[i++] = c;
 4a2:	89a6                	mv	s3,s1
 4a4:	a011                	j	4a8 <gets+0x52>
 4a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4a8:	99de                	add	s3,s3,s7
 4aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 4ae:	855e                	mv	a0,s7
 4b0:	60e6                	ld	ra,88(sp)
 4b2:	6446                	ld	s0,80(sp)
 4b4:	64a6                	ld	s1,72(sp)
 4b6:	6906                	ld	s2,64(sp)
 4b8:	79e2                	ld	s3,56(sp)
 4ba:	7a42                	ld	s4,48(sp)
 4bc:	7aa2                	ld	s5,40(sp)
 4be:	7b02                	ld	s6,32(sp)
 4c0:	6be2                	ld	s7,24(sp)
 4c2:	6125                	addi	sp,sp,96
 4c4:	8082                	ret

00000000000004c6 <stat>:

int
stat(const char *n, struct stat *st)
{
 4c6:	1101                	addi	sp,sp,-32
 4c8:	ec06                	sd	ra,24(sp)
 4ca:	e822                	sd	s0,16(sp)
 4cc:	e04a                	sd	s2,0(sp)
 4ce:	1000                	addi	s0,sp,32
 4d0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4d2:	4581                	li	a1,0
 4d4:	162000ef          	jal	636 <open>
  if(fd < 0)
 4d8:	02054263          	bltz	a0,4fc <stat+0x36>
 4dc:	e426                	sd	s1,8(sp)
 4de:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4e0:	85ca                	mv	a1,s2
 4e2:	16c000ef          	jal	64e <fstat>
 4e6:	892a                	mv	s2,a0
  close(fd);
 4e8:	8526                	mv	a0,s1
 4ea:	134000ef          	jal	61e <close>
  return r;
 4ee:	64a2                	ld	s1,8(sp)
}
 4f0:	854a                	mv	a0,s2
 4f2:	60e2                	ld	ra,24(sp)
 4f4:	6442                	ld	s0,16(sp)
 4f6:	6902                	ld	s2,0(sp)
 4f8:	6105                	addi	sp,sp,32
 4fa:	8082                	ret
    return -1;
 4fc:	597d                	li	s2,-1
 4fe:	bfcd                	j	4f0 <stat+0x2a>

0000000000000500 <atoi>:

int
atoi(const char *s)
{
 500:	1141                	addi	sp,sp,-16
 502:	e422                	sd	s0,8(sp)
 504:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 506:	00054683          	lbu	a3,0(a0)
 50a:	fd06879b          	addiw	a5,a3,-48
 50e:	0ff7f793          	zext.b	a5,a5
 512:	4625                	li	a2,9
 514:	02f66863          	bltu	a2,a5,544 <atoi+0x44>
 518:	872a                	mv	a4,a0
  n = 0;
 51a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 51c:	0705                	addi	a4,a4,1
 51e:	0025179b          	slliw	a5,a0,0x2
 522:	9fa9                	addw	a5,a5,a0
 524:	0017979b          	slliw	a5,a5,0x1
 528:	9fb5                	addw	a5,a5,a3
 52a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 52e:	00074683          	lbu	a3,0(a4)
 532:	fd06879b          	addiw	a5,a3,-48
 536:	0ff7f793          	zext.b	a5,a5
 53a:	fef671e3          	bgeu	a2,a5,51c <atoi+0x1c>
  return n;
}
 53e:	6422                	ld	s0,8(sp)
 540:	0141                	addi	sp,sp,16
 542:	8082                	ret
  n = 0;
 544:	4501                	li	a0,0
 546:	bfe5                	j	53e <atoi+0x3e>

0000000000000548 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 548:	1141                	addi	sp,sp,-16
 54a:	e422                	sd	s0,8(sp)
 54c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 54e:	02b57463          	bgeu	a0,a1,576 <memmove+0x2e>
    while(n-- > 0)
 552:	00c05f63          	blez	a2,570 <memmove+0x28>
 556:	1602                	slli	a2,a2,0x20
 558:	9201                	srli	a2,a2,0x20
 55a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 55e:	872a                	mv	a4,a0
      *dst++ = *src++;
 560:	0585                	addi	a1,a1,1
 562:	0705                	addi	a4,a4,1
 564:	fff5c683          	lbu	a3,-1(a1)
 568:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 56c:	fef71ae3          	bne	a4,a5,560 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 570:	6422                	ld	s0,8(sp)
 572:	0141                	addi	sp,sp,16
 574:	8082                	ret
    dst += n;
 576:	00c50733          	add	a4,a0,a2
    src += n;
 57a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 57c:	fec05ae3          	blez	a2,570 <memmove+0x28>
 580:	fff6079b          	addiw	a5,a2,-1
 584:	1782                	slli	a5,a5,0x20
 586:	9381                	srli	a5,a5,0x20
 588:	fff7c793          	not	a5,a5
 58c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 58e:	15fd                	addi	a1,a1,-1
 590:	177d                	addi	a4,a4,-1
 592:	0005c683          	lbu	a3,0(a1)
 596:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 59a:	fee79ae3          	bne	a5,a4,58e <memmove+0x46>
 59e:	bfc9                	j	570 <memmove+0x28>

00000000000005a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5a0:	1141                	addi	sp,sp,-16
 5a2:	e422                	sd	s0,8(sp)
 5a4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5a6:	ca05                	beqz	a2,5d6 <memcmp+0x36>
 5a8:	fff6069b          	addiw	a3,a2,-1
 5ac:	1682                	slli	a3,a3,0x20
 5ae:	9281                	srli	a3,a3,0x20
 5b0:	0685                	addi	a3,a3,1
 5b2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5b4:	00054783          	lbu	a5,0(a0)
 5b8:	0005c703          	lbu	a4,0(a1)
 5bc:	00e79863          	bne	a5,a4,5cc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5c0:	0505                	addi	a0,a0,1
    p2++;
 5c2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5c4:	fed518e3          	bne	a0,a3,5b4 <memcmp+0x14>
  }
  return 0;
 5c8:	4501                	li	a0,0
 5ca:	a019                	j	5d0 <memcmp+0x30>
      return *p1 - *p2;
 5cc:	40e7853b          	subw	a0,a5,a4
}
 5d0:	6422                	ld	s0,8(sp)
 5d2:	0141                	addi	sp,sp,16
 5d4:	8082                	ret
  return 0;
 5d6:	4501                	li	a0,0
 5d8:	bfe5                	j	5d0 <memcmp+0x30>

00000000000005da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5da:	1141                	addi	sp,sp,-16
 5dc:	e406                	sd	ra,8(sp)
 5de:	e022                	sd	s0,0(sp)
 5e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5e2:	f67ff0ef          	jal	548 <memmove>
}
 5e6:	60a2                	ld	ra,8(sp)
 5e8:	6402                	ld	s0,0(sp)
 5ea:	0141                	addi	sp,sp,16
 5ec:	8082                	ret

00000000000005ee <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5ee:	4885                	li	a7,1
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5f6:	4889                	li	a7,2
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <wait>:
.global wait
wait:
 li a7, SYS_wait
 5fe:	488d                	li	a7,3
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 606:	4891                	li	a7,4
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <read>:
.global read
read:
 li a7, SYS_read
 60e:	4895                	li	a7,5
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <write>:
.global write
write:
 li a7, SYS_write
 616:	48c1                	li	a7,16
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <close>:
.global close
close:
 li a7, SYS_close
 61e:	48d5                	li	a7,21
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <kill>:
.global kill
kill:
 li a7, SYS_kill
 626:	4899                	li	a7,6
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <exec>:
.global exec
exec:
 li a7, SYS_exec
 62e:	489d                	li	a7,7
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <open>:
.global open
open:
 li a7, SYS_open
 636:	48bd                	li	a7,15
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 63e:	48c5                	li	a7,17
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 646:	48c9                	li	a7,18
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 64e:	48a1                	li	a7,8
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <link>:
.global link
link:
 li a7, SYS_link
 656:	48cd                	li	a7,19
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 65e:	48d1                	li	a7,20
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 666:	48a5                	li	a7,9
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <dup>:
.global dup
dup:
 li a7, SYS_dup
 66e:	48a9                	li	a7,10
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 676:	48ad                	li	a7,11
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 67e:	48b1                	li	a7,12
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 686:	48b5                	li	a7,13
 ecall
 688:	00000073          	ecall
 ret
 68c:	8082                	ret

000000000000068e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 68e:	48b9                	li	a7,14
 ecall
 690:	00000073          	ecall
 ret
 694:	8082                	ret

0000000000000696 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 696:	48d9                	li	a7,22
 ecall
 698:	00000073          	ecall
 ret
 69c:	8082                	ret

000000000000069e <getlev>:
.global getlev
getlev:
 li a7, SYS_getlev
 69e:	48e1                	li	a7,24
 ecall
 6a0:	00000073          	ecall
 ret
 6a4:	8082                	ret

00000000000006a6 <yield>:
.global yield
yield:
 li a7, SYS_yield
 6a6:	48dd                	li	a7,23
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <mlfqmode>:
.global mlfqmode
mlfqmode:
 li a7, SYS_mlfqmode
 6ae:	48e5                	li	a7,25
 ecall
 6b0:	00000073          	ecall
 ret
 6b4:	8082                	ret

00000000000006b6 <fcfsmode>:
.global fcfsmode
fcfsmode:
 li a7, SYS_fcfsmode
 6b6:	48e9                	li	a7,26
 ecall
 6b8:	00000073          	ecall
 ret
 6bc:	8082                	ret

00000000000006be <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6be:	1101                	addi	sp,sp,-32
 6c0:	ec06                	sd	ra,24(sp)
 6c2:	e822                	sd	s0,16(sp)
 6c4:	1000                	addi	s0,sp,32
 6c6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6ca:	4605                	li	a2,1
 6cc:	fef40593          	addi	a1,s0,-17
 6d0:	f47ff0ef          	jal	616 <write>
}
 6d4:	60e2                	ld	ra,24(sp)
 6d6:	6442                	ld	s0,16(sp)
 6d8:	6105                	addi	sp,sp,32
 6da:	8082                	ret

00000000000006dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6dc:	7139                	addi	sp,sp,-64
 6de:	fc06                	sd	ra,56(sp)
 6e0:	f822                	sd	s0,48(sp)
 6e2:	f426                	sd	s1,40(sp)
 6e4:	0080                	addi	s0,sp,64
 6e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6e8:	c299                	beqz	a3,6ee <printint+0x12>
 6ea:	0805c963          	bltz	a1,77c <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6ee:	2581                	sext.w	a1,a1
  neg = 0;
 6f0:	4881                	li	a7,0
 6f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6f8:	2601                	sext.w	a2,a2
 6fa:	00000517          	auipc	a0,0x0
 6fe:	64e50513          	addi	a0,a0,1614 # d48 <digits>
 702:	883a                	mv	a6,a4
 704:	2705                	addiw	a4,a4,1
 706:	02c5f7bb          	remuw	a5,a1,a2
 70a:	1782                	slli	a5,a5,0x20
 70c:	9381                	srli	a5,a5,0x20
 70e:	97aa                	add	a5,a5,a0
 710:	0007c783          	lbu	a5,0(a5)
 714:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 718:	0005879b          	sext.w	a5,a1
 71c:	02c5d5bb          	divuw	a1,a1,a2
 720:	0685                	addi	a3,a3,1
 722:	fec7f0e3          	bgeu	a5,a2,702 <printint+0x26>
  if(neg)
 726:	00088c63          	beqz	a7,73e <printint+0x62>
    buf[i++] = '-';
 72a:	fd070793          	addi	a5,a4,-48
 72e:	00878733          	add	a4,a5,s0
 732:	02d00793          	li	a5,45
 736:	fef70823          	sb	a5,-16(a4)
 73a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 73e:	02e05a63          	blez	a4,772 <printint+0x96>
 742:	f04a                	sd	s2,32(sp)
 744:	ec4e                	sd	s3,24(sp)
 746:	fc040793          	addi	a5,s0,-64
 74a:	00e78933          	add	s2,a5,a4
 74e:	fff78993          	addi	s3,a5,-1
 752:	99ba                	add	s3,s3,a4
 754:	377d                	addiw	a4,a4,-1
 756:	1702                	slli	a4,a4,0x20
 758:	9301                	srli	a4,a4,0x20
 75a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 75e:	fff94583          	lbu	a1,-1(s2)
 762:	8526                	mv	a0,s1
 764:	f5bff0ef          	jal	6be <putc>
  while(--i >= 0)
 768:	197d                	addi	s2,s2,-1
 76a:	ff391ae3          	bne	s2,s3,75e <printint+0x82>
 76e:	7902                	ld	s2,32(sp)
 770:	69e2                	ld	s3,24(sp)
}
 772:	70e2                	ld	ra,56(sp)
 774:	7442                	ld	s0,48(sp)
 776:	74a2                	ld	s1,40(sp)
 778:	6121                	addi	sp,sp,64
 77a:	8082                	ret
    x = -xx;
 77c:	40b005bb          	negw	a1,a1
    neg = 1;
 780:	4885                	li	a7,1
    x = -xx;
 782:	bf85                	j	6f2 <printint+0x16>

0000000000000784 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 784:	711d                	addi	sp,sp,-96
 786:	ec86                	sd	ra,88(sp)
 788:	e8a2                	sd	s0,80(sp)
 78a:	e0ca                	sd	s2,64(sp)
 78c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 78e:	0005c903          	lbu	s2,0(a1)
 792:	26090863          	beqz	s2,a02 <vprintf+0x27e>
 796:	e4a6                	sd	s1,72(sp)
 798:	fc4e                	sd	s3,56(sp)
 79a:	f852                	sd	s4,48(sp)
 79c:	f456                	sd	s5,40(sp)
 79e:	f05a                	sd	s6,32(sp)
 7a0:	ec5e                	sd	s7,24(sp)
 7a2:	e862                	sd	s8,16(sp)
 7a4:	e466                	sd	s9,8(sp)
 7a6:	8b2a                	mv	s6,a0
 7a8:	8a2e                	mv	s4,a1
 7aa:	8bb2                	mv	s7,a2
  state = 0;
 7ac:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 7ae:	4481                	li	s1,0
 7b0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 7b2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 7b6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 7ba:	06c00c93          	li	s9,108
 7be:	a005                	j	7de <vprintf+0x5a>
        putc(fd, c0);
 7c0:	85ca                	mv	a1,s2
 7c2:	855a                	mv	a0,s6
 7c4:	efbff0ef          	jal	6be <putc>
 7c8:	a019                	j	7ce <vprintf+0x4a>
    } else if(state == '%'){
 7ca:	03598263          	beq	s3,s5,7ee <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 7ce:	2485                	addiw	s1,s1,1
 7d0:	8726                	mv	a4,s1
 7d2:	009a07b3          	add	a5,s4,s1
 7d6:	0007c903          	lbu	s2,0(a5)
 7da:	20090c63          	beqz	s2,9f2 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 7de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7e2:	fe0994e3          	bnez	s3,7ca <vprintf+0x46>
      if(c0 == '%'){
 7e6:	fd579de3          	bne	a5,s5,7c0 <vprintf+0x3c>
        state = '%';
 7ea:	89be                	mv	s3,a5
 7ec:	b7cd                	j	7ce <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 7ee:	00ea06b3          	add	a3,s4,a4
 7f2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 7f6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 7f8:	c681                	beqz	a3,800 <vprintf+0x7c>
 7fa:	9752                	add	a4,a4,s4
 7fc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 800:	03878f63          	beq	a5,s8,83e <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 804:	05978963          	beq	a5,s9,856 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 808:	07500713          	li	a4,117
 80c:	0ee78363          	beq	a5,a4,8f2 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 810:	07800713          	li	a4,120
 814:	12e78563          	beq	a5,a4,93e <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 818:	07000713          	li	a4,112
 81c:	14e78a63          	beq	a5,a4,970 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 820:	07300713          	li	a4,115
 824:	18e78a63          	beq	a5,a4,9b8 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 828:	02500713          	li	a4,37
 82c:	04e79563          	bne	a5,a4,876 <vprintf+0xf2>
        putc(fd, '%');
 830:	02500593          	li	a1,37
 834:	855a                	mv	a0,s6
 836:	e89ff0ef          	jal	6be <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 83a:	4981                	li	s3,0
 83c:	bf49                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 83e:	008b8913          	addi	s2,s7,8
 842:	4685                	li	a3,1
 844:	4629                	li	a2,10
 846:	000ba583          	lw	a1,0(s7)
 84a:	855a                	mv	a0,s6
 84c:	e91ff0ef          	jal	6dc <printint>
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
 854:	bfad                	j	7ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 856:	06400793          	li	a5,100
 85a:	02f68963          	beq	a3,a5,88c <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 85e:	06c00793          	li	a5,108
 862:	04f68263          	beq	a3,a5,8a6 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 866:	07500793          	li	a5,117
 86a:	0af68063          	beq	a3,a5,90a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 86e:	07800793          	li	a5,120
 872:	0ef68263          	beq	a3,a5,956 <vprintf+0x1d2>
        putc(fd, '%');
 876:	02500593          	li	a1,37
 87a:	855a                	mv	a0,s6
 87c:	e43ff0ef          	jal	6be <putc>
        putc(fd, c0);
 880:	85ca                	mv	a1,s2
 882:	855a                	mv	a0,s6
 884:	e3bff0ef          	jal	6be <putc>
      state = 0;
 888:	4981                	li	s3,0
 88a:	b791                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 88c:	008b8913          	addi	s2,s7,8
 890:	4685                	li	a3,1
 892:	4629                	li	a2,10
 894:	000ba583          	lw	a1,0(s7)
 898:	855a                	mv	a0,s6
 89a:	e43ff0ef          	jal	6dc <printint>
        i += 1;
 89e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 8a0:	8bca                	mv	s7,s2
      state = 0;
 8a2:	4981                	li	s3,0
        i += 1;
 8a4:	b72d                	j	7ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 8a6:	06400793          	li	a5,100
 8aa:	02f60763          	beq	a2,a5,8d8 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 8ae:	07500793          	li	a5,117
 8b2:	06f60963          	beq	a2,a5,924 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 8b6:	07800793          	li	a5,120
 8ba:	faf61ee3          	bne	a2,a5,876 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8be:	008b8913          	addi	s2,s7,8
 8c2:	4681                	li	a3,0
 8c4:	4641                	li	a2,16
 8c6:	000ba583          	lw	a1,0(s7)
 8ca:	855a                	mv	a0,s6
 8cc:	e11ff0ef          	jal	6dc <printint>
        i += 2;
 8d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 8d2:	8bca                	mv	s7,s2
      state = 0;
 8d4:	4981                	li	s3,0
        i += 2;
 8d6:	bde5                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 8d8:	008b8913          	addi	s2,s7,8
 8dc:	4685                	li	a3,1
 8de:	4629                	li	a2,10
 8e0:	000ba583          	lw	a1,0(s7)
 8e4:	855a                	mv	a0,s6
 8e6:	df7ff0ef          	jal	6dc <printint>
        i += 2;
 8ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 8ec:	8bca                	mv	s7,s2
      state = 0;
 8ee:	4981                	li	s3,0
        i += 2;
 8f0:	bdf9                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 8f2:	008b8913          	addi	s2,s7,8
 8f6:	4681                	li	a3,0
 8f8:	4629                	li	a2,10
 8fa:	000ba583          	lw	a1,0(s7)
 8fe:	855a                	mv	a0,s6
 900:	dddff0ef          	jal	6dc <printint>
 904:	8bca                	mv	s7,s2
      state = 0;
 906:	4981                	li	s3,0
 908:	b5d9                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 90a:	008b8913          	addi	s2,s7,8
 90e:	4681                	li	a3,0
 910:	4629                	li	a2,10
 912:	000ba583          	lw	a1,0(s7)
 916:	855a                	mv	a0,s6
 918:	dc5ff0ef          	jal	6dc <printint>
        i += 1;
 91c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 91e:	8bca                	mv	s7,s2
      state = 0;
 920:	4981                	li	s3,0
        i += 1;
 922:	b575                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 924:	008b8913          	addi	s2,s7,8
 928:	4681                	li	a3,0
 92a:	4629                	li	a2,10
 92c:	000ba583          	lw	a1,0(s7)
 930:	855a                	mv	a0,s6
 932:	dabff0ef          	jal	6dc <printint>
        i += 2;
 936:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 938:	8bca                	mv	s7,s2
      state = 0;
 93a:	4981                	li	s3,0
        i += 2;
 93c:	bd49                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 93e:	008b8913          	addi	s2,s7,8
 942:	4681                	li	a3,0
 944:	4641                	li	a2,16
 946:	000ba583          	lw	a1,0(s7)
 94a:	855a                	mv	a0,s6
 94c:	d91ff0ef          	jal	6dc <printint>
 950:	8bca                	mv	s7,s2
      state = 0;
 952:	4981                	li	s3,0
 954:	bdad                	j	7ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 956:	008b8913          	addi	s2,s7,8
 95a:	4681                	li	a3,0
 95c:	4641                	li	a2,16
 95e:	000ba583          	lw	a1,0(s7)
 962:	855a                	mv	a0,s6
 964:	d79ff0ef          	jal	6dc <printint>
        i += 1;
 968:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 96a:	8bca                	mv	s7,s2
      state = 0;
 96c:	4981                	li	s3,0
        i += 1;
 96e:	b585                	j	7ce <vprintf+0x4a>
 970:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 972:	008b8d13          	addi	s10,s7,8
 976:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 97a:	03000593          	li	a1,48
 97e:	855a                	mv	a0,s6
 980:	d3fff0ef          	jal	6be <putc>
  putc(fd, 'x');
 984:	07800593          	li	a1,120
 988:	855a                	mv	a0,s6
 98a:	d35ff0ef          	jal	6be <putc>
 98e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 990:	00000b97          	auipc	s7,0x0
 994:	3b8b8b93          	addi	s7,s7,952 # d48 <digits>
 998:	03c9d793          	srli	a5,s3,0x3c
 99c:	97de                	add	a5,a5,s7
 99e:	0007c583          	lbu	a1,0(a5)
 9a2:	855a                	mv	a0,s6
 9a4:	d1bff0ef          	jal	6be <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9a8:	0992                	slli	s3,s3,0x4
 9aa:	397d                	addiw	s2,s2,-1
 9ac:	fe0916e3          	bnez	s2,998 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 9b0:	8bea                	mv	s7,s10
      state = 0;
 9b2:	4981                	li	s3,0
 9b4:	6d02                	ld	s10,0(sp)
 9b6:	bd21                	j	7ce <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 9b8:	008b8993          	addi	s3,s7,8
 9bc:	000bb903          	ld	s2,0(s7)
 9c0:	00090f63          	beqz	s2,9de <vprintf+0x25a>
        for(; *s; s++)
 9c4:	00094583          	lbu	a1,0(s2)
 9c8:	c195                	beqz	a1,9ec <vprintf+0x268>
          putc(fd, *s);
 9ca:	855a                	mv	a0,s6
 9cc:	cf3ff0ef          	jal	6be <putc>
        for(; *s; s++)
 9d0:	0905                	addi	s2,s2,1
 9d2:	00094583          	lbu	a1,0(s2)
 9d6:	f9f5                	bnez	a1,9ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 9d8:	8bce                	mv	s7,s3
      state = 0;
 9da:	4981                	li	s3,0
 9dc:	bbcd                	j	7ce <vprintf+0x4a>
          s = "(null)";
 9de:	00000917          	auipc	s2,0x0
 9e2:	36290913          	addi	s2,s2,866 # d40 <malloc+0x256>
        for(; *s; s++)
 9e6:	02800593          	li	a1,40
 9ea:	b7c5                	j	9ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 9ec:	8bce                	mv	s7,s3
      state = 0;
 9ee:	4981                	li	s3,0
 9f0:	bbf9                	j	7ce <vprintf+0x4a>
 9f2:	64a6                	ld	s1,72(sp)
 9f4:	79e2                	ld	s3,56(sp)
 9f6:	7a42                	ld	s4,48(sp)
 9f8:	7aa2                	ld	s5,40(sp)
 9fa:	7b02                	ld	s6,32(sp)
 9fc:	6be2                	ld	s7,24(sp)
 9fe:	6c42                	ld	s8,16(sp)
 a00:	6ca2                	ld	s9,8(sp)
    }
  }
}
 a02:	60e6                	ld	ra,88(sp)
 a04:	6446                	ld	s0,80(sp)
 a06:	6906                	ld	s2,64(sp)
 a08:	6125                	addi	sp,sp,96
 a0a:	8082                	ret

0000000000000a0c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a0c:	715d                	addi	sp,sp,-80
 a0e:	ec06                	sd	ra,24(sp)
 a10:	e822                	sd	s0,16(sp)
 a12:	1000                	addi	s0,sp,32
 a14:	e010                	sd	a2,0(s0)
 a16:	e414                	sd	a3,8(s0)
 a18:	e818                	sd	a4,16(s0)
 a1a:	ec1c                	sd	a5,24(s0)
 a1c:	03043023          	sd	a6,32(s0)
 a20:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a24:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a28:	8622                	mv	a2,s0
 a2a:	d5bff0ef          	jal	784 <vprintf>
}
 a2e:	60e2                	ld	ra,24(sp)
 a30:	6442                	ld	s0,16(sp)
 a32:	6161                	addi	sp,sp,80
 a34:	8082                	ret

0000000000000a36 <printf>:

void
printf(const char *fmt, ...)
{
 a36:	711d                	addi	sp,sp,-96
 a38:	ec06                	sd	ra,24(sp)
 a3a:	e822                	sd	s0,16(sp)
 a3c:	1000                	addi	s0,sp,32
 a3e:	e40c                	sd	a1,8(s0)
 a40:	e810                	sd	a2,16(s0)
 a42:	ec14                	sd	a3,24(s0)
 a44:	f018                	sd	a4,32(s0)
 a46:	f41c                	sd	a5,40(s0)
 a48:	03043823          	sd	a6,48(s0)
 a4c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a50:	00840613          	addi	a2,s0,8
 a54:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a58:	85aa                	mv	a1,a0
 a5a:	4505                	li	a0,1
 a5c:	d29ff0ef          	jal	784 <vprintf>
}
 a60:	60e2                	ld	ra,24(sp)
 a62:	6442                	ld	s0,16(sp)
 a64:	6125                	addi	sp,sp,96
 a66:	8082                	ret

0000000000000a68 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a68:	1141                	addi	sp,sp,-16
 a6a:	e422                	sd	s0,8(sp)
 a6c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a6e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a72:	00000797          	auipc	a5,0x0
 a76:	5967b783          	ld	a5,1430(a5) # 1008 <freep>
 a7a:	a02d                	j	aa4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a7c:	4618                	lw	a4,8(a2)
 a7e:	9f2d                	addw	a4,a4,a1
 a80:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a84:	6398                	ld	a4,0(a5)
 a86:	6310                	ld	a2,0(a4)
 a88:	a83d                	j	ac6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a8a:	ff852703          	lw	a4,-8(a0)
 a8e:	9f31                	addw	a4,a4,a2
 a90:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a92:	ff053683          	ld	a3,-16(a0)
 a96:	a091                	j	ada <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a98:	6398                	ld	a4,0(a5)
 a9a:	00e7e463          	bltu	a5,a4,aa2 <free+0x3a>
 a9e:	00e6ea63          	bltu	a3,a4,ab2 <free+0x4a>
{
 aa2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aa4:	fed7fae3          	bgeu	a5,a3,a98 <free+0x30>
 aa8:	6398                	ld	a4,0(a5)
 aaa:	00e6e463          	bltu	a3,a4,ab2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aae:	fee7eae3          	bltu	a5,a4,aa2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 ab2:	ff852583          	lw	a1,-8(a0)
 ab6:	6390                	ld	a2,0(a5)
 ab8:	02059813          	slli	a6,a1,0x20
 abc:	01c85713          	srli	a4,a6,0x1c
 ac0:	9736                	add	a4,a4,a3
 ac2:	fae60de3          	beq	a2,a4,a7c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 ac6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 aca:	4790                	lw	a2,8(a5)
 acc:	02061593          	slli	a1,a2,0x20
 ad0:	01c5d713          	srli	a4,a1,0x1c
 ad4:	973e                	add	a4,a4,a5
 ad6:	fae68ae3          	beq	a3,a4,a8a <free+0x22>
    p->s.ptr = bp->s.ptr;
 ada:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 adc:	00000717          	auipc	a4,0x0
 ae0:	52f73623          	sd	a5,1324(a4) # 1008 <freep>
}
 ae4:	6422                	ld	s0,8(sp)
 ae6:	0141                	addi	sp,sp,16
 ae8:	8082                	ret

0000000000000aea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 aea:	7139                	addi	sp,sp,-64
 aec:	fc06                	sd	ra,56(sp)
 aee:	f822                	sd	s0,48(sp)
 af0:	f426                	sd	s1,40(sp)
 af2:	ec4e                	sd	s3,24(sp)
 af4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 af6:	02051493          	slli	s1,a0,0x20
 afa:	9081                	srli	s1,s1,0x20
 afc:	04bd                	addi	s1,s1,15
 afe:	8091                	srli	s1,s1,0x4
 b00:	0014899b          	addiw	s3,s1,1
 b04:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b06:	00000517          	auipc	a0,0x0
 b0a:	50253503          	ld	a0,1282(a0) # 1008 <freep>
 b0e:	c915                	beqz	a0,b42 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b10:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b12:	4798                	lw	a4,8(a5)
 b14:	08977a63          	bgeu	a4,s1,ba8 <malloc+0xbe>
 b18:	f04a                	sd	s2,32(sp)
 b1a:	e852                	sd	s4,16(sp)
 b1c:	e456                	sd	s5,8(sp)
 b1e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 b20:	8a4e                	mv	s4,s3
 b22:	0009871b          	sext.w	a4,s3
 b26:	6685                	lui	a3,0x1
 b28:	00d77363          	bgeu	a4,a3,b2e <malloc+0x44>
 b2c:	6a05                	lui	s4,0x1
 b2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b36:	00000917          	auipc	s2,0x0
 b3a:	4d290913          	addi	s2,s2,1234 # 1008 <freep>
  if(p == (char*)-1)
 b3e:	5afd                	li	s5,-1
 b40:	a081                	j	b80 <malloc+0x96>
 b42:	f04a                	sd	s2,32(sp)
 b44:	e852                	sd	s4,16(sp)
 b46:	e456                	sd	s5,8(sp)
 b48:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 b4a:	00000797          	auipc	a5,0x0
 b4e:	4c678793          	addi	a5,a5,1222 # 1010 <base>
 b52:	00000717          	auipc	a4,0x0
 b56:	4af73b23          	sd	a5,1206(a4) # 1008 <freep>
 b5a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b5c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b60:	b7c1                	j	b20 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b62:	6398                	ld	a4,0(a5)
 b64:	e118                	sd	a4,0(a0)
 b66:	a8a9                	j	bc0 <malloc+0xd6>
  hp->s.size = nu;
 b68:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b6c:	0541                	addi	a0,a0,16
 b6e:	efbff0ef          	jal	a68 <free>
  return freep;
 b72:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b76:	c12d                	beqz	a0,bd8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b7a:	4798                	lw	a4,8(a5)
 b7c:	02977263          	bgeu	a4,s1,ba0 <malloc+0xb6>
    if(p == freep)
 b80:	00093703          	ld	a4,0(s2)
 b84:	853e                	mv	a0,a5
 b86:	fef719e3          	bne	a4,a5,b78 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b8a:	8552                	mv	a0,s4
 b8c:	af3ff0ef          	jal	67e <sbrk>
  if(p == (char*)-1)
 b90:	fd551ce3          	bne	a0,s5,b68 <malloc+0x7e>
        return 0;
 b94:	4501                	li	a0,0
 b96:	7902                	ld	s2,32(sp)
 b98:	6a42                	ld	s4,16(sp)
 b9a:	6aa2                	ld	s5,8(sp)
 b9c:	6b02                	ld	s6,0(sp)
 b9e:	a03d                	j	bcc <malloc+0xe2>
 ba0:	7902                	ld	s2,32(sp)
 ba2:	6a42                	ld	s4,16(sp)
 ba4:	6aa2                	ld	s5,8(sp)
 ba6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 ba8:	fae48de3          	beq	s1,a4,b62 <malloc+0x78>
        p->s.size -= nunits;
 bac:	4137073b          	subw	a4,a4,s3
 bb0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bb2:	02071693          	slli	a3,a4,0x20
 bb6:	01c6d713          	srli	a4,a3,0x1c
 bba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bbc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bc0:	00000717          	auipc	a4,0x0
 bc4:	44a73423          	sd	a0,1096(a4) # 1008 <freep>
      return (void*)(p + 1);
 bc8:	01078513          	addi	a0,a5,16
  }
}
 bcc:	70e2                	ld	ra,56(sp)
 bce:	7442                	ld	s0,48(sp)
 bd0:	74a2                	ld	s1,40(sp)
 bd2:	69e2                	ld	s3,24(sp)
 bd4:	6121                	addi	sp,sp,64
 bd6:	8082                	ret
 bd8:	7902                	ld	s2,32(sp)
 bda:	6a42                	ld	s4,16(sp)
 bdc:	6aa2                	ld	s5,8(sp)
 bde:	6b02                	ld	s6,0(sp)
 be0:	b7f5                	j	bcc <malloc+0xe2>
