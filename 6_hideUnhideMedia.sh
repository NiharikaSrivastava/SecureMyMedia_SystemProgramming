#!/bin/bash
#This program intends to hide or unhide one to multiple files/folders in a given path as per user's choice
echo -e "\n**************************************** Hide/Unhide Multiple Files and Folders ****************************************\n"

createLog() #function for creating prefix of every log entry
{
	logPath="/var/log/secureMyMediaLogs.log"
	date=$(date +"%a  %b %d %T %Y")
	userName=$(whoami)
	userId=$(id -u)
	logPrefix=$date" "$userName"(uid="$userId		
}

hideMedia()
{
	echo -e "\nHiding media $hideTarget.. \n"
	originalHideTarget=$hideTarget
	newHideTarget=.$hideTarget #prefixing . in front of a file/directory hides it
	mv $hideTarget $newHideTarget #renaming
	echo -e "Congratulations! $originalHideTarget has been hidden successfully and renamed to: $newHideTarget\n"
	createLog
	logEntry=$logPrefix"): Child 5 -> PATH: $path -> FILE/FOLDER: $hideTarget -> Succesfully hidden as $newHideTarget"
	echo -e $logEntry >> $logPath
}

unhideMedia()
{
	echo -e "\nUnhiding media $unhideTarget.. \n"
	mediaName=$unhideTarget
	prefix="."
	mediaName=${mediaName#$prefix} #remove prefix
	newUnhideTarget=${mediaName}
	mv $unhideTarget $newUnhideTarget #renaming
	echo -e "Congratulations! $newUnhideTarget is unhidden now!\n"
	createLog
	logEntry=$logPrefix"): Child 5 -> PATH: $path -> FILE/FOLDER: $unhideTarget -> Succesfully unhidden as $newUnhideTarget"
	echo -e $logEntry >> $logPath		
}

echo -e "\nEnter the directory path which contains the file/directory that require hiding/unhiding: "
read path
if [ -e $path ] #Directory path exists
then
	cd $path
	choice=1
	while [ $choice -eq 1 ]
	do
		echo -e "\nListing all the files and folders in the given directory path ($path): \n"
		ls -la
		echo -e "\nDo you want to hide or unhide any file/directory? (Hide=1/Unhide=2) Enter 1/2: "
		read hideChoice
		if [ $hideChoice -eq 1 ] #HIDE Media
		then
			echo -e "\nEnter filename/directory name to hide it: "
			read hideTarget
			if [ -e $hideTarget ] #if file/folder exists
			then
				hideMedia $hideTarget $path
			else
				echo -e "\n$hideTarget does not exist. Please enter a valid filename/directory name\n"
			fi
		elif [ $hideChoice -eq 2 ] #UNHIDE Media
		then
			echo -e "\nEnter filename/directory name to unhide it: "
			read unhideTarget
			if [ -e $unhideTarget ] #if file/folder exists
			then
				unhideMedia $unhideTarget $path
			else
				echo -e "\n$unhideTarget does not exist. Please enter a valid filename/directory name\n"
			fi
		else
			echo -e "\nIncorrect Choice, please select (Hide=1/Unhide=2)" 
		fi
		echo -e "\nDo you want to hide/unhide more files/directories? (Yes=1/No=0) Enter 1/0: "
		read choice
	done
else
	echo -e "$path does not exist. Sorry, we cannot provide decryption facility.\n"
fi

createLog
logEntry=$logPrefix"): Child 5 -> Sesssion Closed"
echo -e $logEntry >> $logPath