#include <stdio.h>
#include <stdlib.h>

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
void assertValidQueue(struct queue* p);

struct queue* q;
struct queue* first;
struct queue* insertLocation;
struct queue* consumeLocation;

int main() {
  insertLocation = consumeLocation = q = createQueue();
  assertValidQueue(q);
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

/**
 *
 * Insert using the global insertLocation variable.
 *
 */
void insert() {
  // TODO needs to block here until the fullLock is released.
  // That way we don't lock the queue and then fail to insert

  // TODO it needs to lock access to the qeueu

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
  //TODO unlock access to queue
}

/*
 * Valid Queue is defined as a queue that contains
 * a LinkedList of Queue structs, in ASC order by q->position.
 * Also last->next->position == first->position
 */
void assertValidQueue(struct queue* first) {
  int i;
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
