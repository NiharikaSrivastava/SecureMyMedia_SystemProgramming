#!/bin/bash
#This program intends to decrypt one to multiple files/folders inside a directory path which has been previously encrypted using the gpg command and a password
echo -e "\n**************************************** Decrypting Multiple Files and Folders ****************************************\n"

createLog() #function for creating prefix of every log entry
{
	logPath="/var/log/secureMyMediaLogs.log"
	date=$(date +"%a  %b %d %T %Y")
	userName=$(whoami)
	userId=$(id -u)
	logPrefix=$date" "$userName"(uid="$userId		
}

decryptFiles() #function for decrypting files
{
	echo -e "\nThe following files will be decrypted: $fileTargets\n"
	for value in $fileTargets
	do
		echo -e "Enter password for decryption of file: $value \n"
		gpg $value #decrypting every file 
		returnVal=$?
		if [ $returnVal -eq 0 ] #decryption successful, correct password entered 
		then
			rm $value #removing original encrypted file
		else
			createLog
			logEntry=$logPrefix"): Child 3 -> PATH: $path -> FILE(s): $value -> Decryption Failed"
			echo -e $logEntry >> $logPath	
			return 2
		fi
	done
	echo -e "Congratulations! All files have been decrypted succesfully\n"
	createLog
	logEntry=$logPrefix"): Child 3 -> PATH: $path -> FILE(s): $fileTargets -> Succesfully Decrypted"
	echo -e $logEntry >> $logPath	
	rm -rf ~/.local/share/Trash/* #Emptying the trash, so that the encrypted target file cannot be accessed again
}

decryptDirectories() #function for decrypting directories
{
	echo -e "\nThe following directories will be decrypted: $directoryTargets\n"
	for value in $directoryTargets
	do
		echo -e "Enter password for decryption of directory: $value \n"
		originalValue=$value
		gpg $value #decrypting every directory
		returnVal=$?
		if [ $returnVal -eq 0 ] #decryption successfulful, correct password entered 
		then
			DATA=$value
			pattern=".gpg"
			DATA=${DATA/$pattern/}
			DATA=${DATA}
			tar xvf $DATA #extracting all contents of the tar file
			rm $originalValue #removing original encrypted file
			rm $DATA #removing tar file
		else
			createLog
			logEntry=$logPrefix"): Child 3 -> PATH: $path -> FILE(s): $value -> Decryption Failed"
			echo -e $logEntry >> $logPath	
			return 2
		fi
	done
	echo -e "Congratulations! All directories have been decrypted succesfully\n"
	createLog
	logEntry=$logPrefix"): Child 3 -> PATH: $path -> FILE(s): $directoryTargets -> Succesfully Decrypted"
	echo -e $logEntry >> $logPath	
	rm -rf ~/.local/share/Trash/* #Emptying the trash, so that the encrypted target file cannot be accessed again
}

moveBackFromSecureFolder() #moving encrypted folders back from the secure folder to a new folder
{
	echo -e "\nEnter New Folder Path where you want to move all target files/directories into, from the Secure Folder"
	read newPath
	if [ -e $newPath ]
	then
		echo -e "\nNew Path Set..\n"
	else
		mkdir $newPath
	fi
	cd ~/$secFolder #Secure Folder is located in the home directory
	echo -e "Listing all files and folders in $secFolder.. \n"
	ls -l
	choiceMv=1
	i=1
	while [ $choiceMv -eq 1 ]
	do
		echo -e "\nEnter filename/directory name $i to move it to $newPath: "
		read targetMv
		if [ -e $targetMv ] #if file/folder exists
		then
			chmod 755 $targetMv #providing default access permission
			mv $targetMv ~/$newPath
			createLog
			logEntry=$logPrefix"): Child 3 -> PATH: $newPath -> FILE: $targetMv -> Moved back from $secFolder to $newPath"
			echo -e $logEntry >> $logPath	
			i=$((i+1))
		else
			echo -e "\n$targetMv does not exist. Please enter a valid filename/directory name\n"
		fi
		echo -e "\nDo you want to move more files/directories? (Yes=1/No=0) Enter 1/0: "
		read choiceMv
	done
	echo -e "Congratulations! All files/directories have been moved from Secure Folder($secFolder) to The New Folder($newPath)"
	cd ~ #go back to home folder
}

echo -e "\nEnter the directory path which contains the files/directories that need to be decrypted: "
read path
if [ -e $path ] #Directory path exists
then
	secFolder="SecureFolder"
	if [ $path == $secFolder ]
	then
		echo -e "Secure Folder has been accessed, please move desired files/folders for decryption to a new directory first..\n"
		moveBackFromSecureFolder $secFolder
		path=$newPath #changing path for further decryption process		
	fi
	echo -e "\nListing all the files and folders in the given directory path ($path): \n"
	cd $path
	ls -l
	choice=1
	i=1
	fileTargets=""
	directoryTargets=""
	while [ $choice -eq 1 ]
	do
		echo -e "\nEnter filename/directory name $i to decrypt it: "
		read target
		if [ -e $target ] #if file/folder exists
		then
			if grep -q "tar" <<< "$target"; 
			then
				directoryTargets+="$target "
			else
				fileTargets+="$target "
			fi
			i=$((i+1))
		else
			echo -e "\n$target does not exist. Please enter a valid filename/directory name\n"
		fi
		echo -e "\nDo you want to decrypt more files/directories? (Yes=1/No=0) Enter 1/0: "
		read choice
	done
	if [ ! -z $fileTargets ] #fileTargets variable should not be empty
	then
		decryptFiles $fileTargets
	fi
	if [ ! -z $directoryTargets ] #directoryTargets variable should not be empty
	then
		decryptDirectories $directoryTargets
	fi
else
	echo -e "$path does not exist. Sorry, we cannot provide decryption facility.\n"
fi

createLog
logEntry=$logPrefix"): Child 3 -> Sesssion Closed"
echo -e $logEntry >> $logPath