#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

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

void assert(bool val);

struct queue* q;
struct queue* produceLocation;
struct queue* consumeLocation;

void setup() {
  produceLocation = consumeLocation = q = createQueue();
}

int main() {
  assertValidQueue();
  assertCanProduce();
  assertCanRemove();
  exit(0);
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
  setup();
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
  int elements = 10;
  struct queue* result = (struct queue*) malloc(elements*sizeof(struct queue));

  struct queue* current = result;
  int i;
  for(i = 0; i < elements; i++) {
    current->next = result + (i * sizeof(struct queue));
    current->position = i;
    current->value = nothing;
    current = current->next;
  }

  // circular linked list. Last next pointer goes to the first one! :D
  current->next = result;
  return result;
}

/**
 * provides synchronizedAccess based on current semaphore lock values: randomAccessLock, isFull, isEmpty
 */
void synchronizedAccess(void (*function)(), bool randomAccessLock, bool isFull, bool isEmpty) {
  if(randomAccessLock) {
    // TODO randomAccessLock();
  }
  if(isFull) {
    //TODO wait until not full
    //randomAccessLock();
  }
  if(isEmpty) {
    //TODO wait until not full
    //randomAccessLock()
  }

  // call function
  (*function)();


  // TODO
  // set full lock if full
  // set empty lock if empty
}

/*
 * Valid Queue is defined as a queue that contains
 * a LinkedList of Queue structs, in ASC order by q->position.
 * Also last->next->position == first->position
 */
void assertValidQueue() {
  setup();
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
