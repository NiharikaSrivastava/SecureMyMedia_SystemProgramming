#include<stdio.h>
#include<unistd.h>
#include<sys/stat.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h> 
#include<signal.h>
#include<time.h>
#include<unistd.h>
#include <fcntl.h>

#define READ 0 //macros for ease of using file descriptor in pipes
#define WRITE 1

char*  from_child1_ack ="Positive Acknowledgement (Child 1) - Password Protecting and Encrpyting a File/Folder"; //acknowledgements from child processes
char*  from_child2_ack ="Positive Acknowledgement (Child 2) - Password Protecting and Encrpyting Multiple Files/Folders";
char*  from_child3_ack ="Positive Acknowledgement (Child 3) - Decrypting Multiple Files/Folders";
char*  from_child4_ack ="Positive Acknowledgement (Child 4) - Changing Permissions for Multiple Files/Folders";
char*  from_child5_ack ="Positive Acknowledgement (Child 5) - Multiple Files/Folders will been hidden/unhidden";
void (*oldHandler)();
char timestamp[26];
char *createLog(const char* logData) //creating logs with appropriate prefix for desired log statements
{
	time_t t;
    time(&t);
    char* rawTimestamp=ctime(&t);
    strncpy(timestamp,rawTimestamp,strlen(rawTimestamp)-1); //storing timestamp
    char* userName=getenv("USER"); //storing username with the help of environment variable
    int userId=getuid(); //storing userID
    char sUserID[10];
    sprintf(sUserID,"%d",userId);
    char logStatement[200];
    strcpy(logStatement,timestamp);
    strcat(logStatement," ");
    strcat(logStatement, userName);
    strcat(logStatement,"(uid=");
	strcat(logStatement, sUserID);    
	strcat(logStatement,"): "); //uptill here log prefix
	strcat(logStatement,logData); //actual log statement
    static char returnLog[200]; //log to be returned for writing to log file stored in this variable
    strcpy(returnLog,"");
    strcat(returnLog,logStatement);
    return returnLog;
}

int main(int argc, char* argv[])
{
	char* logData="Session Opened"; //first log statement whenever program is executed
	char* logStatement=createLog(logData);
	FILE* fileDesc; //file descriptor for log file
	char* logFile="/var/log/secureMyMediaLogs.log";
	fileDesc = fopen(logFile,"a"); //opening file in append mode(writing at the end, if file does'nt exist it creates file)
	if(ferror(fileDesc))
		printf("Couldn't open log file: %s",logFile);
	else
	{
		fputs(logStatement, fileDesc); //add entry in the log file
		fputs("\n",fileDesc);
		fflush(fileDesc);
	}

	int choice1=0, choice2=0, choice3=0, choice4=0, choice5=0;
	char message1[100], message2[100], message3[100], message4[100], message5[100];
	int status;
	int fd1[2],fd2[2],fd3[2],fd4[2],fd5[2];
	pipe(fd1); //Child 1 writer, parent reader
	pipe(fd2); //Child 2 writer, parent reader
	pipe(fd3); //Child 3 writer, parent reader
	pipe(fd4); //Child 4 writer, parent reader
	pipe(fd5); //Child 5 writer, parent reader

	oldHandler=signal(SIGINT, SIG_IGN); //Protecting Selection Code from CTRL+C Attack
	printf("\n**************************************** Secure My Media ****************************************\n");
	printf("1. Password Protect and Encrypt a Single File or Folder\n");
	printf("2. Password Protect and Encrypt Multiple Files and Folders\n");
	printf("3. Decrypt Multiple Files and Folders\n");
	printf("4. Change Permissions For Multiple Files and Folders\n");
	printf("5. Hide or Unhide Multiple Files and Folders\n");

	printf("\nDo you want option 1 (yes=1/no=0): ");
	scanf("%d",&choice1);
	printf("Do you want option 2 (yes=1/no=0): ");
	scanf("%d",&choice2);
	printf("Do you want option 3 (yes=1/no=0): ");
	scanf("%d",&choice3);
	printf("Do you want option 4 (yes=1/no=0): ");
	scanf("%d",&choice4);
	printf("Do you want option 5 (yes=1/no=0): ");
	scanf("%d",&choice5);
	signal(SIGINT, oldHandler); //Can be CTRL+C'ed again
	
	int child1 = fork();
	if ( child1 == 0 )  // First Child Process
	{
		printf("\nChild 1 (PID = %d) Executing...\n",getpid());
		if(choice1==1)
		{
			close(fd1[READ]);
			write(fd1[WRITE], from_child1_ack, strlen(from_child1_ack)+1); //sending acknowledgement to parent
			close(fd1[WRITE]);
			system("gnome-terminal -- sh -c './2_protectFileFolder.sh; exec bash;'"); //launching a new terminal such that output of this process doesn't get intermingeled with output of other processes 
			exit(0); 
		}
		else
			exit(0);
	}
	else
	{
		int child2 = fork();
		if(child2 == 0) // Second Child Process
		{
			printf("\nChild 2 (PID = %d) Executing...\n",getpid());
			if(choice2==1)
			{
				close(fd2[READ]);
				write(fd2[WRITE], from_child2_ack, strlen(from_child2_ack)+1);
				close(fd2[WRITE]);
				system("gnome-terminal -- sh -c './3_protectMultipleMedia.sh; exec bash;'"); //system("gnome-terminal -- sh -c './protectFileFolder.sh folderPath; exec bash;'"); //can pass static value to shell script from here also
				exit(0);
			}
			else
				exit(0);	
		}
		else
		{
			int child3 = fork();
			if(child3==0) //Third Child Process
			{
				printf("\nChild 3 (PID = %d) Executing...\n",getpid());
				if(choice3==1)
				{
					close(fd3[READ]);
					write(fd3[WRITE], from_child3_ack, strlen(from_child3_ack)+1);
					close(fd3[WRITE]);
					system("gnome-terminal -- sh -c './4_decryptingMultipleMedia.sh; exec bash;'");
					exit(0);
				}
				else
					exit(0);
			}
			else
			{
				int child4 = fork();
				if(child4==0) //Fourth Child Process
				{
					printf("\nChild 4 (PID = %d) Executing...\n",getpid());
					if(choice4==1)
					{
						close(fd4[READ]);
						write(fd4[WRITE], from_child4_ack, strlen(from_child4_ack)+1);
						close(fd4[WRITE]);
						system("gnome-terminal -- sh -c './5_changeMediaPermission.sh; exec bash;'");
						exit(0);
					}
					else
						exit(0);
				}
				else
				{
					int child5 = fork();
					if(child5==0) //Fifth Child Process
					{
						printf("\nChild 5 (PID = %d) Executing...\n",getpid());
						if(choice5==1)
						{
							close(fd5[READ]);
							write(fd5[WRITE], from_child5_ack, strlen(from_child5_ack)+1);
							close(fd5[WRITE]);
							system("gnome-terminal -- sh -c './6_hideUnhideMedia.sh; exec bash;'");
							exit(0);
						}
						else
							exit(0);
					}
					else 
					{
						int parentPID=getpid();
						printf("\nParent (PID = %d) Executing...\n",parentPID);
						
						if(choice1==1)
						{
							close(fd1[WRITE]);
							int bytesRead1 = read(fd1[READ], message1, 100); // Receiving Acknowledgement from first child
							printf("\nParent Process - Received Acknowledgement:  %s, Bytes Read: %d\n\n", message1, bytesRead1);
							close(fd1[READ]);
							logData=from_child1_ack; 
							logStatement=createLog(logData);
							fputs(logStatement, fileDesc); //add entry in the log file for first child
							fputs("\n",fileDesc);
							fflush(fileDesc);
						}
						int p1=wait(&status); //wait for child such that it doesn't become orphan
						printf("\nChild with PID = %d has Terminated...\n",p1); 
						
						if(choice2==1)
						{
							close(fd2[WRITE]);
							int bytesRead2 = read(fd2[READ], message2, 100);  
							printf("\nParent Process - Received Acknowledgement:  %s, Bytes Read: %d\n\n", message2, bytesRead2);
							close(fd2[READ]);
							logData=from_child2_ack;
							logStatement=createLog(logData);
							fputs(logStatement, fileDesc); //add entry in the log file for second child
							fputs("\n",fileDesc);
							fflush(fileDesc);
						}
						int p2=wait(&status);
						printf("\nChild with PID = %d has Terminated...\n",p2); 
						
						if(choice3==1)
						{
							close(fd3[WRITE]);
							int bytesRead3 = read(fd3[READ], message3, 100);  
							printf("\nParent Process - Received Acknowledgement:  %s, Bytes Read: %d\n\n", message3, bytesRead3);
							close(fd3[READ]);
							logData=from_child3_ack;
							logStatement=createLog(logData);
							fputs(logStatement, fileDesc); //add entry in the log file for third child
							fputs("\n",fileDesc);
							fflush(fileDesc);
						}
						int p3=wait(&status);
						printf("\nChild with PID = %d has Terminated...\n",p3); 
						
						if(choice4==1)
						{
							close(fd4[WRITE]);
							int bytesRead4 = read(fd4[READ], message4, 100);  
							printf("\nParent Process - Received Acknowledgement:  %s, Bytes Read: %d\n\n", message4, bytesRead4);
							close(fd4[READ]);
							logData=from_child4_ack;
							logStatement=createLog(logData);
							fputs(logStatement, fileDesc); //add entry in the log file for fourth child
							fputs("\n",fileDesc);
							fflush(fileDesc);
						}
						int p4=wait(&status);
						printf("\nChild with PID = %d has Terminated...\n",p4); 
						
						if(choice5==1)
						{
							close(fd5[WRITE]);
							int bytesRead5 = read(fd5[READ], message5, 100);  
							printf("\nParent Process - Received Acknowledgement:  %s, Bytes Read: %d\n\n", message5, bytesRead5);
							close(fd5[READ]);
							logData=from_child5_ack;
							logStatement=createLog(logData);
							fputs(logStatement, fileDesc); //add entry in the log file for fifth child
							fputs("\n",fileDesc);
							fflush(fileDesc);
						}
						int p5=wait(&status);
						printf("\nChild with PID = %d has Terminated...\n",p5); 
						fclose(fileDesc);
						printf("\nParent Process with PID = %d has Terminated...\n",parentPID); 
						exit(0);
					}		 
				} 		
			}
		}
	}
}