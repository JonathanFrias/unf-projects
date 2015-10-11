/*
 * main.c
 * Authored By: Johnathan Frias and Nagavarun Kanaparthy
 * Date: 10/10/2015
 * 
 */
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>

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
//queque Commands
struct queue* createQueue();
void addItem(int semSetId);
void removeItem(int semSetId);
//producer and consumer functions
void produce(int semSetId);
void consume(int semSetId);
//Semaphore Methods
void intializeSems(int semSetId);
//Sempahores Permit, Release, and Check functions
//access
void queueAccessPermit(int semSetdId);
void queueAccessRelease(int semSetdId);
int queueAccessCheck(int semSetdId);
//addition
void queueAdditionPermit(int semSetdId);
void queueAdditionRelease(int semSetdId);
int queueAdditionCheck(int semSetdId);
//removal
void queueRemovalPermit(int semSetdId);
void queueRemovalRelease(int semSetdId);
int queueRemovalCheck(int semSetdId);
//clean up
void releaseSharedResources(int semIds[], int shmIds[]);
void assert(bool val);

struct queue* q;
int* producerCount;
int* consumerCount;

int main( int argc, char *argv[] ) {
  //Ids and Keys
  int key = 680283;
  int semId;
  int qId;
  int pCountId;
  int cCountId;
  int status;
  //Commandline values
  int numProducers = atoi(argv[1]);
  int numConsumers = atoi(argv[2]);
  int producersRange = atoi(argv[3]);  
  //Producer and Consumer ids;
  int producerIds[numProducers];
  int consumerIds[numConsumers];
  //load queque and sembufs controls
  //load queque in Shared Memory
  if((qId = shmget(IPC_PRIVATE, 10*sizeof(struct queue), 0777)) == -1)
		printf("/nError: Failed to Create Shared Memory Segment/n"), exit(1);
  q = shmat(qId, NULL, 0);
  q = createQueue();
  //load count variables into Shared Memory
  if((pCountId = shmget(IPC_PRIVATE, sizeof(int), 0777)) == -1)
		printf("/nError: Failed to Create Shared Memory Segment/n"), exit(1);
  producerCount = shmat(pCountId, NULL, 0);
  if((cCountId = shmget(IPC_PRIVATE, sizeof(int), 0777)) == -1)
		printf("/nError: Failed to Create Shared Memory Segment/n"), exit(1);
  consumerCount = shmat(cCountId, NULL, 0);
  //create semaphore set 
  if ((semId = semget(key, 3, IPC_CREAT | 0600)) == -1) {
    printf("Failed");
  }
  //intialize semaphores
  intializeSems(semId);
  printf("Process ID\tNew Product\tAddress\t\t\tAccess\t\tEmpty\t\tOccupied\tAction\t\tTotal Produced\t\tTotal Consumed\n");
  //for creating producers
  for(int i = 0; i < numProducers; i++){
	  if ((producerIds[i] = fork()) == 0){
		for(int j = 0;j < producersRange;j++){
			produce(semId);
		}
	  }
  }
  //for creating consumers
  for(int i = 0; i < numConsumers; i++){
	  if ((consumerIds[i] = fork()) == 0){
		  *producerCount ++;
			consume(semId);
	  }
  }
  //wait for parent to complete
  //for creating producers
  for(int i = 0; i < numProducers; i++){
	  if ((waitpid(producerIds[i], &status, 0) == -1))
		printf("\nError Waiting for Producer to Terminate\n"), exit(1);
  }
  //for creating consumers
  for(int i = 0; i < numConsumers; i++){
	  *consumerCount ++;
	  if ((waitpid(consumerIds[i], &status, 0) == -1))
		printf("\nError Waiting for Consumer to Terminate\n"), exit(1);
  }
  //clean up
  int shmIds[] = {qId,pCountId,cCountId};
  int semIds[] = {semId};
  releaseSharedResources(semIds , shmIds);
  exit(0);
}
void intializeSems(int semSetId){
	//Initial value for semaphores
	// Initialize semaphore in the set (sem_0)
	/**
	 * sem0 – Controls access to the critical space
	 *  1 – A producer/consumer can access the critical space
	 *	0 – A producer/consumer is blocked until the critical space is accessible
	 */
    if (semctl(semSetId, 0, SETVAL, 1) == -1) {
        printf("\nError initializing semaphore %d with value %d\n", 0, 1);
        exit(1);
    }
	// Initialize semaphore in the set (sem_1)
	/**
	 * sem1 – IsFull flag for producers
	 * > 0 – The queue is not full, and a producer can add an item
	 * 0 – The queue is full, and a producer is blocked until the queue is no longer full
	 */
    if (semctl(semSetId, 1, SETVAL, 10) == -1) {
        printf("\nError initializing semaphore %d with value %d\n", 0, 9);
        exit(1);
    }
	// Initialize semaphore in the set (sem_2)
	/**
	 * sem2 – IsEmpty flag for consumers
	 * > 0 – The queue is not empty, and a consumer can remove an item
	 * 0 – The queue is empty, and a consumer is blocked until the queue is no longer empty
	 */
    if (semctl(semSetId, 2, SETVAL, 0) == -1) {
        printf("\nError initializing semaphore %d with value %d\n", 0, 0);
        exit(1);
    }
}
void queueAccessPermit(int semSetId){
	struct sembuf dec = {0,-1,0};
	semop(semSetId, &dec, 1);
}
void queueAccessRelease(int semSetId){
	struct sembuf inc = {0,1,0};
	semop(semSetId, &inc, 1);
}
int queueAccessCheck(int semSetId){
	return semctl(semSetId, 0, GETVAL, 0);
}
void queueAdditionPermit(int semSetId){
	struct sembuf dec = {1,-1,0};
	semop(semSetId, &dec, 1);
}
void queueAdditionRelease(int semSetId){
	struct sembuf inc = {1,1,0};
	semop(semSetId, &inc, 1);
}
int queueAdditionCheck(int semSetId){
	return semctl(semSetId, 1, GETVAL, 0);
}
void queueRemovalPermit(int semSetId){
	struct sembuf dec = {2,-1,0};
	semop(semSetId, &dec, 1);
}
void queueRemovalRelease(int semSetId){
	struct sembuf inc = {2,1,0};
	semop(semSetId, &inc, 1);
}
int queueRemovalCheck(int semSetId){
	return semctl(semSetId, 2, GETVAL, 0);
}
/**
 * Produce using the global produceLocation variable.
 */
void produce(int semSetId) {
	//Access and Permit
	queueAdditionPermit(semSetId);
	queueAccessPermit(semSetId);
	addItem(semSetId);
	//Lift queue usage and let consumer consume
	queueRemovalRelease(semSetId);
	queueAccessRelease(semSetId);
}

/*
 * This function is the inverse of produce().
 */
void consume(int semSetId) {
  //Access and Permit
	queueRemovalPermit(semSetId);
	queueAccessPermit(semSetId);
	removeItem(semSetId);
	//Lift queue usage and let consumer consume
	queueAdditionRelease(semSetId);
	queueAccessRelease(semSetId);
}

void addItem(int semSetId){
	struct queue* current = q;
	for(int i = 0; i < 10;i++){
		if(current->value == 0){
			current->value = rand();
			if(current->value == 0){
				current->value = 1;
			}
			printf("%d\t\t%d\t\t%d\t\t%d\t\t%d\t\t%d\t\tproduced\t\t%d\t\t%d\n", getpid(), current->value, current->position,
                       queueAccessCheck(semSetId), queueAdditionCheck(semSetId), queueRemovalCheck(semSetId), *producerCount, *consumerCount);
			return;
		}
		current = current->next;
	}
}
void removeItem(int semSetId){
	struct queue* current = q;
	for(int i = 0; i < 10;i++){
		if(current->value != 0){
			printf("%d\t\t%d\t\t%d\t\t%d\t\t%d\t\t%d\t\tconsumed\t\t%d\t\t%d\n", getpid(), current->value, current->position,
                       queueAccessCheck(semSetId), queueAdditionCheck(semSetId), queueRemovalCheck(semSetId), *producerCount, *consumerCount);
			current->value = 0;
			return;
		}
		current = current->next;
	}
}
void releaseSharedResources(int semIds[], int shmIds[]){
	for(int i = 0; i < (sizeof(semIds)/sizeof(int));i++){
		if (semctl(semIds[i], IPC_RMID, 0) == -1) {
    	  printf("error in semctl");
		exit(1);
		}
	}
	for(int i = 0; i < (sizeof(shmIds)/sizeof(int));i++){
		if (shmctl(shmIds[i], IPC_RMID, 0) == -1) {
    	  printf("error in semctl");
		exit(1);
		}
	}
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
