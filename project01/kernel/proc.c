#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

/* project1 */
int sched_mode = 0;

// void fcfs_scheduler(void) __attribute__((noreturn));
// void mlfq_scheduler(void) __attribute__((noreturn));
// void scheduler(void) __attribute__((noreturn));

/* =========== */

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;
  p->pr = 3;
  p->lv = 0;
  p->tq = 0;
  p->time = ticks;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// assembled from ../user/initcode.S
// od -t xC ../user/initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;

  // initialize info related to mlfq
  np->tq = 0;
  np->lv = 0;
  np->time = ticks;
  np->pr = 3;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
/*
// 기존 scheduler
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();

  c->proc = 0;
  for(;;){
    // The most recent process to run may have had interrupts
    // turned off; enable them to avoid a deadlock if all
    // processes are waiting.
    intr_on();

    int found = 0;
    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
        found = 1;
      }
      release(&p->lock);
    }
    if(found == 0) {
      // nothing to run; stop running on this core until an interrupt.
      intr_on();
      asm volatile("wfi");
    }
  }
}
*/


// // FCFS scheduler
// void
// fcfs_scheduler(void)
// {
//   struct proc *p;
//   struct cpu *c = mycpu();

//   c->proc = 0;
//   for(;;){
//     intr_on();

//     struct proc *running_p = 0;

//     // 가장 작은 PID를 가진 RUNNABLE 프로세스를 선택
//     for(p = proc; p < &proc[NPROC]; p++) {
//       acquire(&p->lock);
//       if(p->state == RUNNABLE) {
//         if(running_p == 0 || p->pid < running_p->pid) {
//           running_p = p;
//         }
//       }
//       release(&p->lock);
//     }    

// 		// 선택된 프로세스를 실행
//     if(running_p) {
//       //printf("pid: %d | lv: %d | tq: %d | pr: %d | ticks: %d \n", running_p->pid, running_p->lv, running_p->tq, running_p->pr, ticks);
//       acquire(&running_p->lock);
//       running_p->state = RUNNING;
//       c->proc = running_p;
//       swtch(&c->context, &running_p->context);

//       // 프로세스 실행 종료 후 처리
//       c->proc = 0;
//       release(&running_p->lock);
//     } else {
//       // 실행할 게 없으면 대기
//       intr_on();
//       asm volatile("wfi");
//     }
//   }
// }

// // MLFQ scheduler
// void
// mlfq_scheduler(void) {
//   struct proc *p;
//   struct cpu *c = mycpu();

//   c->proc = 0;

//   for(;;) {
//     intr_on();

//     struct proc *running_p = 0;

//     // 1. 가장 우선적으로 처리해야 할 프로세스 선택
//     for(p = proc; p < &proc[NPROC]; p++) {
//       acquire(&p->lock);

//       if(p->state == RUNNABLE) {
//         if(running_p == 0) {
//           running_p = p;
//         } else {
//           // 1-1. lv이 낮은 프로세스부터 선택
//           if(running_p->lv > p->lv) {
//             running_p = p;
//           }
//           // 1-2. lv이 같을 때
//           else if(running_p->lv == p->lv) {
//             // L2: pr이 큰 프로세스부터 선택
//             if(running_p->lv == 2) {
//               if(running_p->pr < p->pr) {
//                 running_p = p;
//               } else if((running_p->pr == p->pr) && (running_p->tq > p->time)) {
//                 running_p = p;
//               }
//             }
//             // L0, L1: 도착한지 오래된 process, 즉 time (도착 당시의 tick 값)이 작은 것을 먼저 실행
//             else {
//               if(running_p->time > p->time) {
//                 running_p = p;
//               }
//             }
//           }
//         }
//       }

//       release(&p->lock);
//     }
    
//     // 2. 선택된 프로세스를 실행
//     if(running_p) {
//       printf("pid: %d | lv: %d | tq: %d | pr: %d | ticks: %d \n", running_p->pid, running_p->lv, running_p->tq, running_p->pr, ticks);

//       acquire(&running_p->lock);
//       running_p->state = RUNNING;
//       c->proc = running_p;
//       swtch(&c->context, &running_p->context);
//       running_p->time = ticks;

//       // 프로세스 실행 종료 후 처리
//       c->proc = 0;
//       release(&running_p->lock);
//     } else {
//       // 실행할 게 없으면 대기
//       intr_on();
//       asm volatile("wfi");
//     }

//     /*
//     g_ticks++;

//     // Priority boosting
//     if(g_ticks >= 50){
//       for(p = proc; p < &proc[NPROC]; p++) {
//         p->pr = 3;
//         p->lv = 0;
//         p->tq = 0;
//         p->time = 0;
//       }

//       g_ticks = 0;
//     }
//     */

//   }
// }

void
scheduler(void) {
  // if(sched_mode == 0){ // fcfs mode
  //   fcfs_scheduler();
  // }
  // else{ // mlfq mode
  //   mlfq_scheduler();
  // }

  struct proc *p;
  struct cpu *c = mycpu();

  c->proc = 0;
  for(;;){
    intr_on();

    struct proc *running_p = 0;

    // FCFS mode
    if(sched_mode == 0){
      for(p = proc; p < &proc[NPROC]; p++) {
        acquire(&p->lock);
        if(p->state == RUNNABLE) {
          if(running_p == 0 || p->pid < running_p->pid) {
            running_p = p;
          }
        }
        release(&p->lock);
      }  
    }
    // MLFQ mode
    else{
      for(p = proc; p < &proc[NPROC]; p++) {
        acquire(&p->lock);
  
        if(p->state == RUNNABLE) {
          if(running_p == 0) {
            running_p = p;
          } else {
            // 1-1. lv이 낮은 프로세스부터 선택
            if(running_p->lv > p->lv) {
              running_p = p;
            }
            // 1-2. lv이 같을 때
            else if(running_p->lv == p->lv) {
              // L2: pr이 큰 프로세스부터 선택
              if(running_p->lv == 2) {
                if(running_p->pr < p->pr) {
                  running_p = p;
                } else if((running_p->pr == p->pr) && (running_p->tq > p->time)) {
                  running_p = p;
                }
              }
              // L0, L1: 도착한지 오래된 process, 즉 time (도착 당시의 tick 값)이 작은 것을 먼저 실행
              else {
                if(running_p->time > p->time) {
                  running_p = p;
                }
              }
            }
          }
        }
  
        release(&p->lock);
      }
    }
      

		// 선택된 프로세스를 실행
    if(running_p) {
      //printf("pid: %d | lv: %d | tq: %d | pr: %d | time: %d | ticks: %d \n", running_p->pid, running_p->lv, running_p->tq, running_p->pr, running_p->time, ticks);
      acquire(&running_p->lock);
      running_p->state = RUNNING;
      c->proc = running_p;
      swtch(&c->context, &running_p->context);

      // 프로세스 실행 종료 후 처리
      c->proc = 0;
      release(&running_p->lock);
    } else {
      // 실행할 게 없으면 대기
      intr_on();
      asm volatile("wfi");
    }
  }
}

void
priority_boosting(void){
  //printf("===== priority boosting! =====\n");

  //acquire(&ptable_lock);

  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    p->pr = 3;
    p->lv = 0;
    p->tq = 0;
    p->time = ticks;
  }
  //release(&ptable_lock);
}

int
setpriority(int pid, int priority){
  struct proc* p;

  // 매칭되는 pid가 있는지 확인하는 변수
  int chk = 0;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);

    if(p->pid == pid){
      chk = 1;

      if(priority >= 0 && priority <= 3){
        p->pr = priority;
      }
      else{
        release(&p->lock);
        return -2;
      }
    }

    release(&p->lock);
  }

  if(chk == 0){
    return -1;
  }
      
  return 0;
}

int
getlev(void){
  if(sched_mode == 0){
    return 99;
  }
  else{
    return myproc()->lv;
  }
}

int
mlfqmode(void) {
  if(sched_mode == 1){ // 이미 mlfqmode인 경우
    return -1;
  }
  else{
    sched_mode = 1;

    ticks = 0;
    
    struct proc *p;

    for(p = proc; p < &proc[NPROC]; p++) {
      p->pr = 3;
      p->lv = 0;
      p->tq = 0;
      p->time = 0;
    }

    return 0;
  }
}

int
fcfsmode(void) {
  if(sched_mode == 0){ // 이미 fcfsmode인 경우
    return -1;
  }
  else{
    sched_mode = 0;

    ticks = 0;

    struct proc *p;

    for(p = proc; p < &proc[NPROC]; p++) {
      p->pr = -1;
      p->lv = -1;
      p->tq = -1;
      p->time = 0;
    }

    return 0;
  }
}


// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);

    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}
