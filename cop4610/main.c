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

#define ELEMENTS 10
#define QUEUE_SIZE sizeof(struct queue) * 10

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
void synchronizedAccess(void (*function)(), bool randomAccessLock, bool isFull, bool isEmpty);
void setup();
void produce();
void consume();
void setSemVal(int semId, int semaphore, int value);
void assert(bool val);
int getSemVal(int semId, int semaphore);
int canReadWrite();
void semIncrBy(int semId, int semaphore, int delta);

struct queue* q;
struct queue* produceLocation;
struct queue* consumeLocation;
int semId;
key_t key = 680283; // Unique semaphore identifier
int shared_mem_id, // Stores the unique identifier of the shared memory segment
    *shared_mem_ptr; // Stores the address of the shared memory segment

void setup() {
  produceLocation = consumeLocation = q = createQueue();
  if ((semId = semget(key, 3, 0600 | IPC_CREAT)) == -1) {
    printf("Error creating semaphore set\n");
    exit(1);
  }

  setSemVal(semId, 0, 0);
  setSemVal(semId, 1, 0);
  setSemVal(semId, 2, 0);
  // Create a segment of shared memory
  if((shared_mem_id = shmget(IPC_PRIVATE, QUEUE_SIZE, 0777)) == -1)
    printf("Error: Failed to Create Shared Memory Segment"), exit(1);
  if((shared_mem_ptr = (int *)shmat(shared_mem_id, (void *)0, 0)) == (void *)-1)
    printf("Error: Failed to Create Shared Memory Segment"), exit(1);
}

int main() {
  setup();
  // assertValidQueue();
  // assertCanProduce();
  // assertCanRemove();

  synchronizedAccess(&produce, true, false, false);
  exit(0);
}


int canReadWrite() {
  return (int) getSemVal(semId, 0) == 0 && getSemVal(semId, 1) == 0 && getSemVal(semId, 2) == 0;
}

/**
 * provides synchronizedAccess based on current semaphore lock values: randomAccessLock, isFull, isEmpty
 */
void synchronizedAccess(void (*function)(), bool randomAccessLock, bool isFull, bool isEmpty) {

  if(randomAccessLock) {
    while(! canReadWrite()) {
      sleep(1);
    }
    semIncrBy(semId, 0, 1);
  }

  // call function
  (*function)();

  // decrement back to 0
  semIncrBy(semId, 0, -1);
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
  setup();
  produce();
  produce();
  assert(q->value==something);
  synchronizedAccess(&consume, false, false, false);
  assert(q->value == nothing);
  assert(q->next == consumeLocation);
}

void assert(bool val) {
  if(!val) {
    printf("assertion failed!");
    exit(5);
  }
}

void assertCanProduce() {
  synchronizedAccess(&produce, false, false, false);

  if(q->value != something) {
    printf("syncronized produce failed!");
    exit(6);
  }
  assert(q->next == produceLocation);
}

/**
 * Produce using the global produceLocation variable.
 */
void produce() {
  if(produceLocation->value != nothing) {
    printf("cannot produce item at position %d that already exists!", produceLocation->position);
    exit(4);
  }
  produceLocation->value = something;

  // find next available produceLocation.
  // Although, it **SHOULD** always just be the next element
  while(produceLocation->value == something) {
    produceLocation = produceLocation->next;
  }
}

/*
 * This function is the inverse of produce().
 */
void consume() {
  if(consumeLocation->value != something) {
    printf("cannot remove nothing from item at position %d that already exists!", consumeLocation->position);
    exit(7);
  }
  consumeLocation->value = nothing;

  while(consumeLocation->value == nothing) {
    consumeLocation = consumeLocation->next;
  }
  assert(consumeLocation == q->next);
}

/*
 * as you might imagine, this creates a queue.
 * Although technically, it just returns a
 * pointer the first element to the LinkedList queue.
 */
struct queue* createQueue() {
  struct queue* result = (struct queue*) malloc(QUEUE_SIZE);

  struct queue* current = result;
  int i;
  for(i = 0; i < ELEMENTS; i++) {
    current->next = result + (i * sizeof(struct queue));
    current->position = i;
    current->value = nothing;
    current = current->next;
  }

  // circular linked list. Last next pointer goes to the first one! :D
  current->next = result;
  return result;
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

  // test that queue is cirular and has 10 elements
  assert(q
      ->next
      ->next
      ->next
      ->next
      ->next
      ->next
      ->next
      ->next
      ->next
      ->next == q);

  for(i = 0; i < 10; i++) {
    if(current->value != nothing) {
      printf("All entries should be initialized to nothing");
      exit(2);
    }
    current = current->next;
  }
}
