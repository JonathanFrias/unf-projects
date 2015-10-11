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
#define QUEUE_SIZE sizeof(struct queue) * ELEMENTS

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
void synchronizedAccess(void (*function)(), bool randomAccessLock);
void setup();
void produce();
void consume();
void setSemVal(int semId, int semaphore, int value);
void assert(bool val, char*);
int getSemVal(int semId, int semaphore);
int canReadWrite();
void semIncrBy(int semId, int semaphore, int delta);
void printQueue(struct queue* toPrint);
int isQueueFull();
int isQueueEmpty();
void assertFullQueue();

struct queue* q;
struct queue* produceLocation;
struct queue* consumeLocation;
int semId;
key_t key = 680284; // Unique semaphore identifier
int shared_mem_id; // Stores the unique identifier of the shared memory segment
struct queue* shared_mem_ptr; // Stores the address of the shared memory segment

void setup() {
  assert((semId = semget(key, 3, 0600 | IPC_CREAT)) != -1, "Error creating semaphore set\n");

  setSemVal(semId, 0, 0);
  setSemVal(semId, 1, 0);
  setSemVal(semId, 2, 0);
  // Create a segment of shared memory
  assert(((shared_mem_id = shmget(IPC_PRIVATE, QUEUE_SIZE, 0777))) != -1, "Error: Failed to Create Shared Memory Segment");
  assert((shared_mem_ptr = (struct queue*)shmat(shared_mem_id, (void *)0, 0)) != (void *)-1,
    "Error: Failed to get Mmeory Segment Pointer");

  produceLocation = consumeLocation = q = createQueue(shared_mem_ptr);
}

int main(int argc, char *argv[] ) {
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
  int i;
  printf("Parent: ");
  printQueue(q);
  for(i = 0; i < atoi(argv[1]); i++) {
    if((producerChildren[i] = fork()) == 0) { //child producers

      int j;
      for(j = 0; j < atoi(argv[3]); j++) {
        synchronizedAccess(&produce, true);
        printf("P Child: ");
        printQueue(q);
      }
      printf("producer exit\n");
      exit(0);
    }
  }

  for(i = 0; i < atoi(argv[2]); i++) {
    if(consumerChildren[i] = fork() == 0) {
      // child
      while(! isQueueEmpty()) {
        synchronizedAccess(&consume, true);
      }
      printf("C Child: ");
      printQueue(q);
      printf("child exit\n");
      exit(0);
    }
  }
  sleep(50);
  printf("Parent: ");
  printQueue(q);

  exit(0);
}

void printQueue(struct queue* toPrint) {
  int i;
  printf("[\n");
  struct queue* current = toPrint;
  for( i = 0; i < ELEMENTS; i++ ) {
    printf("    %lu: { value: %d,  nextPosition: %lu },\n", current, current->value, current->next);
    current = current->next;
  }
  printf("]\n");
}

int canReadWrite() {
  return getSemVal(semId, 0) == getSemVal(semId, 1) == getSemVal(semId, 2) == 0;
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
void synchronizedAccess(void (*function)(), bool randomAccessLock) {

  if(randomAccessLock) {
    while(! canReadWrite()) {
      usleep(50);
    }
    semIncrBy(semId, 0, 1);

    if(isQueueFull()) {
      semIncrBy(semId, 1, 1);
    }
    if(isQueueEmpty()) {
      semIncrBy(semId, 2, 1);
    }
  }

  // call function
  (*function)();

  // decrement back to 0
  if(randomAccessLock) {
    if(! isQueueFull()) {
      setSemVal(semId, 1, 0);
    }
    if(! isQueueEmpty()) {
      setSemVal(semId, 2, 0);
    }

    semIncrBy(semId, 0, -1);
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
  synchronizedAccess(&consume, false);
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
  synchronizedAccess(&produce, false);

  assert(q->value == something, "syncronized produce failed!");
  assert(q->next == produceLocation, "produce was not correct!");
  assert(q->next->position == produceLocation->position, "produce was not correct!");
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

  int i = 0;
  // find next available produceLocation.
  // Although, it **SHOULD** always just be the next element
  while(produceLocation->value == something && i < 12) {
    produceLocation = produceLocation->next;
    usleep(900);
    i += 1;
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
  printf("consumed '%d'\n", consumeLocation->position);

  int i = 0;
  while(consumeLocation->value == nothing && i < 12) {
    consumeLocation = consumeLocation->next;
    usleep(900);
    i += 1;
  }
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
      synchronizedAccess(&produce, true);
      printQueue(q);
      sleep(1);
    }
    exit(0);
  }
  sleep(10);
  printQueue(q);
  // test that isFullQueue is true!
  assert(isQueueFull() == 1, "Queue expected to report full!");
}
