#!/bin/bash
#This program intends to provide password protection and encryption to multiple files/folders inside a directory path
echo -e "\n**************************************** Protecting Multiple Files and Folders ****************************************\n"

createLog() #function for creating prefix of every log entry
{
	logPath="/var/log/secureMyMediaLogs.log"
	date=$(date +"%a  %b %d %T %Y")
	userName=$(whoami)
	userId=$(id -u)
	logPrefix=$date" "$userName"(uid="$userId		
}

moveToSecureFolder() #function for moving encrypted media to a secure location
{
	cd ~ #Secure Folder is located in the home directory
	secFolder="SecureFolder"
	if [ -d $secFolder ]
	then
		echo -e "$secFolder exists, Moving $encryptedTarget inside it..\n"
	else
		mkdir $secFolder
		echo -e "$secFolder created succesfully, Moving $encryptedTarget inside it..\n"
	fi	
	cd $path
	chmod 000 $encryptedTarget #Removing all permissions for the encrypted file
	mv $encryptedTarget ~/$secFolder
	echo -e "Congratulations! Your Encrypted FILE $encryptedTarget has been succesfully moved to the Secure Folder ($secFolder)"
	createLog
	logEntry=$logPrefix"): Child 2 -> PATH: $secFolder -> Encrypted FILE: $encryptedTarget -> Moved to Secure Folder Succesfully"
	echo -e $logEntry >> $logPath
}

protectMedia() #function to provide password protection and encryption to multiple files/folders inside a directory (convert it to file for encryption)
{
	echo -e "Enter the directory name in which you want to move all selected files/folders and protect them together: "
	read folderName
	archivedFile="$folderName.tar"
	tar cvf $archivedFile $allTargets #The gpg command only works on files, thus, converting the directory into file by archiving it 
	echo -e "The DIRECTORY $folderName has been archived and converted to: $archivedFile FILE\n"
	for value in $allTargets
	do
		rm -r $value #removing all original unencrypted files/directories
	done
	gpg -c $archivedFile #gnu private guard, -c switch stands for symmetric encryption
	retCode=$?
	if [ $retCode -eq 0 ] #encryption successful
	then
		echo -e "Congratulations! The FILE $archivedFile has been succesfully encrypted\n"
		encryptedTarget="$archivedFile.gpg"
		echo -e "Your encrpyted file is now: $encryptedTarget\n"
		createLog
		logEntry=$logPrefix"): Child 2 -> PATH: $path -> FILE(s): $allTargets -> Encrypted FILE: $encryptedTarget -> Succesfully Encrypted"
		echo -e $logEntry >> $logPath
		rm $archivedFile #Removing the original unencrypted file from the given path 
		rm -rf ~/.local/share/Trash/* #Emptying the trash, so that the unencrypted target file cannot be accessed again

		echo "Do you want to move $encryptedTarget to the Secure Folder? (Yes=1/No=0) Enter 1/0: "
		read choice
		if [ $choice -eq 1 ]
		then 
			moveToSecureFolder $encryptedTarget
		fi
	else
		createLog
		logEntry=$logPrefix"): Child 2 -> PATH: $path -> FILE: $archivedFile -> Encryption Failed"
		echo -e $logEntry >> $logPath
	fi
}

echo -e "\nEnter the directory path which contains the files/directories that need to be provided password protection and encryption: "
read path
if [ -e $path ] #Directory path exists
then
	echo -e "\nListing all the files and folders in the given directory path ($path): \n"
	cd $path
	ls -l
	choice=1
	i=1
	allTargets=""
	while [ $choice -eq 1 ]
	do
		echo -e "\nEnter filename/directory name $i to protect it: "
		read target
		if [ -e $target ] #if file/folder exists
		then
			allTargets+="$target " #concatenating all targets
			i=$((i+1))
		else
			echo -e "\n$target does not exist. Please enter a valid filename/directory name\n"
		fi
		echo -e "\nDo you want to protect more files/directories? (Yes=1/No=0) Enter 1/0: "
		read choice
	done
	echo -e "\nThe following files/directories will be protected: $allTargets\n"
	protectMedia $allTargets $path
else
	echo -e "$path does not exist. Sorry, cannot provide password protection and encryption.\n"
fi

createLog
logEntry=$logPrefix"): Child 2 -> Sesssion Closed"
echo -e $logEntry >> $logPath