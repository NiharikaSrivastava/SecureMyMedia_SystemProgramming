#!/bin/bash
#This program intends to provide password protection and encryption to a single file/folder inside a directory path
echo -e "\n**************************************** Protecting a Single File/Folder ****************************************\n"

createLog() #function for creating prefix of every log entry
{
	logPath="/var/log/secureMyMediaLogs.log" #storing log file in the default directory of linux where all log files are stored (/var/log)
	date=$(date +"%a  %b %d %T %Y")
	userName=$(whoami)
	userId=$(id -u)
	logPrefix=$date" "$userName"(uid="$userId		
}

moveToSecureFolder() #function for moving encrypted files to a secure location
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
	logEntry=$logPrefix"): Child 1 -> PATH: $secFolder -> Encrypted FILE: $encryptedTarget -> Moved to Secure Folder Succesfully"
	echo -e $logEntry >> $logPath
}

protectFile() #function to provide password protection and encryption to file
{
	gpg -c $target #gnu private guard, -c switch stands for symmetric encryption
	retCode=$?
	if [ $retCode -eq 0 ] #encryption successful
	then
		echo -e "Congratulations! The FILE $target has been succesfully encrypted\n"
		encryptedTarget="$target.gpg"
		echo -e "Your encrpyted file is now: $encryptedTarget\n"
		createLog
		logEntry=$logPrefix"): Child 1 -> PATH: $path -> FILE: $target -> Encrypted FILE: $encryptedTarget -> Succesfully Encrypted"
		echo -e $logEntry >> $logPath
		rm $target #Removing the original unencrypted target file from the given path 
		rm -rf ~/.local/share/Trash/* #Emptying the trash, so that the unencrypted target file cannot be accessed again
		
		echo -e "Do you want to move $encryptedTarget to the Secure Folder? (Yes=1/No=0) Enter 1/0: "
		read choice
		if [ $choice -eq 1 ]
		then 
			moveToSecureFolder $encryptedTarget
		fi
	else
		createLog
		logEntry=$logPrefix"): Child 1 -> PATH: $path -> FILE: $target -> Encryption Failed"
		echo -e $logEntry >> $logPath
	fi
}

protectDir() #function to convert directory into file and sending it as target to protectFile() function
{
	archivedFile="$target.tar"
	tar cvf $archivedFile $target #The gpg command only works on files, thus, converting the directory into file by archiving it 
	echo -e "The DIRECTORY $target has been archived and converted to: $archivedFile FILE\n"
	rm -r $target #Removing the original unarchived directory from the given path 
	target=$archivedFile #New target will be passed to protectFile()
	protectFile $target		
}

echo -e "\nEnter the directory path which contains the file/directory that needs to be provided password protection and encryption: "
read path
if [ -e $path ] #Directory path exists
then
	echo -e "\nListing all the files and folders in the given directory path ($path): \n"
	cd $path
	ls -l
	echo -e "\nPlease enter the desired filename/directory name which you wish to provide password protection and encryption: "
	read target
	if [ -f $target ] #Target is a file
	then 
		echo -e "\nPassword protecting and Encrypting FILE $target...\n"
		protectFile $target $path
	elif [ -d $target ] #Target is a directory
	then
		echo -e "\nPassword protecting and Encrypting DIRECTORY $target...\n"
		protectDir $target
	else
		echo -e "$target is not a valid filename/directory name in $path path. Sorry, cannot provide password protection and encryption.\n"
	fi
else
	echo -e "$path does not exist. Sorry, cannot provide password protection and encryption.\n"
fi

createLog
logEntry=$logPrefix"): Child 1 -> Sesssion Closed"
echo -e $logEntry >> $logPath