#!/bin/bash
#This program intends to change the access permissions for one to multiple files/folders in a given path as per user's choice
echo -e "\n**************************************** Changing Permission of Multiple Files and Folders ****************************************\n"

createLog() #function for creating prefix of every log entry
{
	logPath="/var/log/secureMyMediaLogs.log"
	date=$(date +"%a  %b %d %T %Y")
	userName=$(whoami)
	userId=$(id -u)
	logPrefix=$date" "$userName"(uid="$userId		
}

changePermission()
{
	echo -e "\nFor USER: "
	echo "Read Access: (1/0)"
	read uR
	echo "Write Access: (1/0)"
	read uW
	echo "Execeute Access: (1/0)"
	read uX
	echo -e "\nFor GROUP: "
	echo "Read Access: (1/0)"
	read gR
	echo "Write Access: (1/0)"
	read gW
	echo "Execeute Access: (1/0)"
	read gX
	echo -e "\nFor OTHERS: "
	echo "Read Access: (1/0)"
	read oR
	echo "Write Access: (1/0)"
	read oW
	echo "Execeute Access: (1/0)"
	read oX
	userPerm=$uR$uW$uX #concatenating user permission
	decUserPerm=$((2#$userPerm)) #converting user permissions from binary to their decimal values
	groupPerm=$gR$gW$gX
	decGroupPerm=$((2#$groupPerm))
	otherPerm=$oR$oW$oX
	decOtherPerm=$((2#$otherPerm))
	fullPerm=$decUserPerm$decGroupPerm$decOtherPerm #concatenating decimal values of user, group and other permissions
	#echo -e "\nFull Permission: $fullPerm\n"	
	sudo chmod $fullPerm $target #changing permission
	echo -e "Permission Changed Successfully! New Permission for $target: "
	ls -l | grep $target | cut -d " " -f 1		
	newPerm=$(ls -l | grep $target | cut -d " " -f 1)		
	createLog
	logEntry=$logPrefix"): Child 4 -> PATH: $path -> FILE/FOLDER: $target -> Succesfully changed permission to: $newPerm (from old permission: $oldPerm)"
	echo -e $logEntry >> $logPath	
}

echo -e "\nEnter the directory path which contains the files/directories for which the permissions need to be changed: "
read path
if [ -e $path ] #Directory path exists
then
	cd $path
	choice=1
	i=1
	while [ $choice -eq 1 ]
	do
		echo -e "\nListing all the files and folders in the given directory path ($path): \n"
		ls -l
		echo -e "\nEnter filename/directory name $i to change it's permissions: "
		read target
		if [ -e $target ] #if file/folder exists
		then
			echo -e "\nCurrent permissions of file/directory: "
			ls -l | grep $target | cut -d " " -f 1				
			oldPerm=$(ls -l | grep $target | cut -d " " -f 1)				
			changePermission $target $path $oldPerm
			i=$((i+1))
		else
			echo -e "\n$target does not exist. Please enter a valid filename/directory name\n"
		fi
		echo -e "\nDo you want to change permissions of more files/directories? (Yes=1/No=0) Enter 1/0: "
		read choice
	done
else
	echo -e "$path does not exist. Sorry, we cannot provide decryption facility.\n"
fi

createLog
logEntry=$logPrefix"): Child 4 -> Sesssion Closed"
echo -e $logEntry >> $logPath