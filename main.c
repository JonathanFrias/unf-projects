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
void assertCanInsert();
void assertCanRemove();
void synchronizedAccess(void (*function)(), bool randomAccessLock, bool isFull, bool isEmpty);
void setup();
void insert();

void assert(bool val);

struct queue* q;
struct queue* first;
struct queue* insertLocation;
struct queue* consumeLocation;

void setup() {
  insertLocation = first = consumeLocation = q = createQueue();
}

int main() {
  assertValidQueue();
  assertCanInsert();
  assertCanRemove();
  exit(0);
}

void assertCanRemove() {
  setup();
  insert();
  assert(q->value==something);
  // synchronizedAccess(&remove, false, false, false);
  assert(false);

}

void assert(bool val) {
  if(!val) {
    printf("assertion failed!");
    exit(5);
  }
}

void assertCanInsert() {
  setup();
  synchronizedAccess(&insert, false, false, false);

  if(q->value != something) {
    printf("syncronized insert failed!");
    exit(5);
  }
}

/*
 * as you might imagine, this creates a queue.
 * Although technically, it just returns a
 * pointer the first element to the LinkedList queue.
 */
struct queue* createQueue() {
  struct queue* result = (struct queue*) malloc(sizeof(struct queue));

  struct queue* current = result; 
  int i;
  for(i = 0; i < 10; i++) {
    current->next = malloc(sizeof(struct queue));
    current->position = i;
    current->value = nothing;
    current = current->next;
  }

  // circular linked list. Last next pointer goes to the first one! :D
  current->next = result;
  return result;
}

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

/**
 *
 * Insert using the global insertLocation variable.
 *
 */
void insert() {
  if(insertLocation->value != nothing) {
    printf("cannot insert item at position %d that already exists!");
    exit(4);
  }
  insertLocation->value = something;

  // find next available insertLocation.
  // Although, it **SHOULD** always just be the next element
  while(insertLocation->value != nothing) {
    insertLocation = insertLocation->next;
  }
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

  for(i = 0; i < 10; i++) {
    if(current->position != i) {
      printf("queue does not contain exactly 10 elements. %d", i);
      exit(1);
    }
    if(current->value != nothing) {
      printf("All entries should be initialized to nothing");
      exit(2);
    }
    current = current->next;
  }
  struct queue* last = current->next;

  // after the for loop, current should be last.
  // Compare the last pointer with the first pointer
  if(last != q || current->position != 0) {
    printf("Queue is not circular!");
    exit(3);
  }
}
