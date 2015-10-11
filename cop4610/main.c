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
void synchronizedAccess(void (*function)(), bool randomAccessLock, bool isFull, bool isEmpty);
void setup();
void produce();
void consume();
void setSemVal(int semId, int semaphore, int value);
void assert(bool val, char*);
int getSemVal(int semId, int semaphore);
int canReadWrite();
void semIncrBy(int semId, int semaphore, int delta);
struct queue* getSharedQueue();
void printQueue();

struct queue* q;
struct queue* produceLocation;
struct queue* consumeLocation;
int semId;
key_t key = 680283; // Unique semaphore identifier
int shared_mem_id; // Stores the unique identifier of the shared memory segment
struct queue* shared_mem_ptr; // Stores the address of the shared memory segment

void setup() {
  if ((semId = semget(key, 3, 0600 | IPC_CREAT)) == -1) {
    printf("Error creating semaphore set\n");
    exit(11);
  }

  setSemVal(semId, 0, 0);
  setSemVal(semId, 1, 0);
  setSemVal(semId, 2, 0);
  // Create a segment of shared memory
  if((shared_mem_id = shmget(IPC_PRIVATE, QUEUE_SIZE, 0777)) == -1) {
    printf("Error: Failed to Create Shared Memory Segment");
    exit(12);
  }
  if((shared_mem_ptr = (struct queue*)shmat(shared_mem_id, (void *)0, 0)) == (void *)-1) {
    printf("Error: Failed to Create Shared Memory Segment");
    exit(9);
  }

  produceLocation = consumeLocation = q = createQueue(shared_mem_ptr);
  return;
}

int main(int argc, char *argv[] ) {
  assert(argc == 4, "You must provide producers, consumers, and an amount of elements to generate");

  setup();
  // Test the queue structure
  // assertValidQueue();
  // assertCanProduce();
  // assertCanRemove();

  int children[atoi(argv[1])];
  int i;
  for(i = 0; i < atoi(argv[1]); i++) {
    children[i] = 0;
    if((children[i] = fork()) == 0) { //child producers
      synchronizedAccess(&produce, false, false, false);
      synchronizedAccess(&produce, false, false, false);
      printf("  Child: ");
      printQueue();
      exit(0);
    } else { //parent
      sleep(2);
      printf("Parent: ");
      printQueue();
    }
  }
  exit(0);
}

void printQueue() {
  int i;
  printf("{");
  for( i = 0; i < ELEMENTS; i++ ){
    struct queue* current = (shared_mem_ptr+(i*sizeof(struct queue)));
    printf(" %d,", current->value);
  }
  printf(" }\n");
}

int canReadWrite() {
  return getSemVal(semId, 0) == getSemVal(semId, 1) == getSemVal(semId, 2) == 0;
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
  if(randomAccessLock) {
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
  setup();
  produce();
  produce();
  assert(q->value==something, "Production failed!");
  synchronizedAccess(&consume, false, false, false);
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
  synchronizedAccess(&produce, false, false, false);

  if(q->value != something) {
    printf("syncronized produce failed!");
    exit(6);
  }
  assert(q->next == produceLocation, "produce was not correct!");
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
  assert(consumeLocation == q->next, "Consume location was not set properly");
}

/*
 * as you might imagine, this creates a queue.
 * Although technically, it just returns a
 * pointer the first element to the LinkedList queue.
 */
struct queue* createQueue(struct queue* first) {
  struct queue* current = first;
  int i;
  for(i = 0; i < ELEMENTS-1; i++) {
    current->next = first + (i * sizeof(struct queue)) + sizeof(struct queue);
    current->position = i;
    current->value = nothing;
    current = current->next;
  }

  // circular linked list. Last next pointer goes to the first one! :D
  current->next = first;
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

  // test that queue is cirular and has ELEMENTS elements
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
      ->next == q,
      "Queue is not circular or does not contain 10 items!"
      );

  for(i = 0; i < ELEMENTS; i++) {
    if(current->value != nothing) {
      printf("All entries should be initialized to nothing");
      exit(2);
    }
    current = current->next;
  }
}
