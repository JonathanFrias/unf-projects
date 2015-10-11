#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <unistd.h>
#include <sys/wait.h>

#define ELEMENTS 10
#define QUEUE_SIZE sizeof(struct queue) * ELEMENTS
#define CRITICAL 0
#define PRODUCER 1
#define CONSUMER 2

struct queue {
  int value;
  int position;
  struct queue *next;
};

enum states {
  nothing,
  something,
  queueFull,
  queueEmpty,
};

struct queue* createQueue();
void assertValidQueue();
void assertCanProduce();
void assertCanRemove();
void synchronizedAccess(void (*function)(), bool randomAccessLock, bool produce);
void setup();
void produce();
void consume();
void setSemVal(int semId, int semaphore, int value);
void assert(bool val, char*);
int getSemVal(int semId, int semaphore);
void semIncrBy(int semId, int semaphore, int delta);
int isQueueFull();
int isQueueEmpty();
void assertFullQueue();

struct queue* q;
struct queue* produceLocation;
struct queue* consumeLocation;
int semId;
key_t key = 680283; // Unique semaphore identifier
key_t key2 = 680284; // Unique semaphore identifier
int shared_mem_id; // Stores the unique identifier of the shared memory segment
struct queue* shared_mem_ptr; // Stores the address of the shared memory segment

void setup() {
  assert((semId = semget(key, 3, 0600 | IPC_CREAT)) != -1, "Error creating semaphore set\n");

  setSemVal(semId, 0, 1);
  setSemVal(semId, 1, 9);
  setSemVal(semId, 2, 0);
  // Create a segment of shared memory
  assert(((shared_mem_id = shmget(IPC_PRIVATE, QUEUE_SIZE+4, 0777))) != -1, "Error: Failed to Create Shared Memory Segment");
  assert((shared_mem_ptr = (struct queue*)shmat(shared_mem_id, (void *)0, 0)) != (void *)-1,
    "Error: Failed to get Memeory Segment Pointer");

  produceLocation = consumeLocation = q = createQueue(shared_mem_ptr);
  (q+10)->value = 0;
  (q+11)->value = 0;
  (q+12)->value = 0;
}

int main(int argc, char* argv[]) {
  shmctl(shared_mem_id, IPC_RMID, 0);
  assert(argc == 4, "You must provide producers, consumers, and an amount of elements to generate");

  setup();
  // Test the queue structure
  // assertValidQueue();
  // assertCanProduce();
  // assertCanRemove();
  // assertFullQueue();
  // assertEmptyQueue();

  int producerChildren[atoi(argv[1])];
  int consumerChildren[atoi(argv[2])];
  int exitCode;
  int i;

  int producers = atoi(argv[1]);
  int consumers = atoi(argv[2]);
  int numItmes = atoi(argv[3]);

  for(i = 0; i < producers; i++) {
    if((producerChildren[i] = fork()) == 0) { //child producers

      int j;
      for(j = 0; j < atoi(argv[3]); j++) {
        synchronizedAccess(&produce, true, true);
      }
      printf("producer exit\n");
      exit(0);
    }
  }

  for(i = 0; i < atoi(argv[2]); i++) {
    if((consumerChildren[i] = fork()) == 0) {
      // child
      while(! isQueueEmpty()) {
        synchronizedAccess(&consume, true, false);
      }
      usleep((100000000ULL * rand() / RAND_MAX)*2);
      while(! isQueueEmpty()) {
        synchronizedAccess(&consume, true, false);
      }
      printf("consumer exit\n");
      exit(0);
    }
  }

  for(i = 0 ; i < atoi(argv[1]); i++) {
    waitpid(producerChildren[i], &exitCode, 0);
  }
  for(i = 0 ; i < atoi(argv[2]); i++) {
    waitpid(consumerChildren[i], &exitCode, 0);
  }

  shmctl(shared_mem_id, 0, IPC_RMID);
  semctl(semId, 0, IPC_RMID);
  exit(0);
}

int isQueueFull() {
  int i = 0;
  struct queue* current = q;
  for(; i < ELEMENTS; i++) {
    if(current->value == nothing) {
      return 0;
    }
    current = current->next;
  }
  return 1;
}

int isQueueEmpty() {
  int i = 0;
  struct queue* current = q;
  for(; i < ELEMENTS; i++) {
    if(current->value == something) {
      return 0;
    }
    current = current->next;
  }
  return 1;
}

/**
 * provides synchronizedAccess based on current semaphore lock values: randomAccessLock, isFull, isEmpty
 */
void synchronizedAccess(void (*function)(), bool randomAccessLock, bool produce) {
  if(produce) {
    semIncrBy(semId, PRODUCER, -1);
    semIncrBy(semId, CRITICAL, -1);

    (*function)(); // produce or consume

    semIncrBy(semId, CRITICAL, 1);
    semIncrBy(semId, CONSUMER, 1);
  } else {
    semIncrBy(semId, CONSUMER, -1);
    semIncrBy(semId, CRITICAL, -1);

    (*function)(); // produce or consume

    semIncrBy(semId, CRITICAL, 1);
    semIncrBy(semId, PRODUCER, 1);
  }
}

void semIncrBy(int semId, int semaphore, int delta) {
  struct sembuf data = {semaphore, delta, 0};
  semop(semId, &data, 1); // Update the selected semaphore (increment/decrement)
}

int getSemVal(int semId, int semaphore) {
  return semctl(semId, semaphore, GETVAL);
}

void setSemVal(int semId, int semaphore, int value) {
  if (semctl(semId, semaphore, SETVAL, value) == -1) {
    printf("Error setting semaphore %d with value %d\n", semaphore, value);
    exit(8);
  }
}

void assertCanRemove() {
  produce();
  produce();
  assert(q->value==something, "Production failed!");
  synchronizedAccess(&consume, false, false);
  assert(q->value == nothing, "Queue must have values initialized to nothing!");
  assert(q->next == consumeLocation, "The consumeLocation was not set after consume");
}

void assert(bool val, char* msg) {
  if(!val) {
    printf("assertion failed: %s\n", msg);
    exit(5);
  }
}

void assertCanProduce() {
  synchronizedAccess(&produce, false, true);

  assert(q->value == something, "syncronized produce failed!");
  assert(q->next == produceLocation, "produce was not correct!");
  assert(q->next->position == produceLocation->position, "produce was not correct!");
}

/**
 * Produce using the global produceLocation variable.
 */
void produce() {
  // find next available produceLocation.
  while(produceLocation->value == something) {
    produceLocation = produceLocation->next;
  }
  produceLocation->value = something;
  printf("produced at %d\n", produceLocation->position);
}

/*
 * This function is the inverse of produce().
 */
void consume() {
  int i = 0;
  while(consumeLocation->value == nothing && !isQueueEmpty()) {
    consumeLocation = consumeLocation->next;
  }
  if(consumeLocation->value == something) {
    consumeLocation->value = nothing;
  }

  (q+10)->value += 1;
  printf("%7d %7d %7d %7d %7d %7d   consume %7d %14d\n",
      getpid(),
      consumeLocation->value,
      q,
      semctl(semId, 0, GETVAL),
      semctl(semId, 1, GETVAL) + 1,
      semctl(semId, 2, GETVAL) + 1,
      (q+10)->value,
      (q+11)->value
  );
}

/*
 * as you might imagine, this creates a queue.
 * Although technically, it just returns a
 * pointer the first element to the LinkedList queue.
 */
struct queue* createQueue(struct queue* first) {
  struct queue* current = first;
  int i;
  for(i = 0; i < ELEMENTS; i++) {
    current->next = first + i + 1;
    current->position = i;

    if(i == ELEMENTS-1) {
      current->next = first;
    }
    current = current->next;
  }

  assert(current == first, "Queue is not circular");
  return first;
}

/*
 * Valid Queue is defined as a queue that contains
 * a LinkedList of Queue structs, in ASC order by q->position.
 * Also last->next->position == first->position
 */
void assertValidQueue() {
  int i;
  struct queue* first = q;
  struct queue* current = first;

  assert((q+9)->next == q, "Queue is not circular or does not contain 10 items!");

  for(i = 0; i < ELEMENTS; i++) {
    assert(current->value == nothing, "All entries should be initialized to nothing");
    assert(current->position == i, "Position is not correct");
    current = current->next;
  }
}

void assertFullQueue() {
  // fill queue
  int i;
  if(fork() == 0) {
    for(i = 0; i < ELEMENTS; i++) {
      synchronizedAccess(&produce, true, true);
      sleep(1);
    }
    exit(0);
  }
  sleep(10);
  // test that isFullQueue is true!
  assert(isQueueFull() == 1, "Queue expected to report full!");
}
