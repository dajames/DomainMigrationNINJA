(*
the purpose of this script is to move the settings from a user's deleted profile into the re-created profile
:: Created by Daniel James February 12, 2015 at 11:51:01 AM CST  For the College of Applied Health Sciences :: 

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++ University of Illinois, Urbana-Champaign ++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*)



(*

READ ME!! FOR THE SAKE OF ALL THAT IS HOLY, READ ME!!  THIS IS AN EXTREMELY DESTRUCTIVE SCRIPT!!!


BEFORE YOU MOVE A PROFILE, YOU MUST DO THE FOLLOWING MANUALLY::

YOU MUST GO TO  -> PREFERENCES -> USERS AND ACCOUNTS AND DELETE THE ACCOUNT YOU ARE MOVING!!!!

WHEN YOU DELETE THIS ACCOUNT, YOU MUST CHOOSE TO LEAVE FILES IN PLACE.  DO NOT DELETE FILES!  JUST THE ACCOUNT!  I CANNOT STRESS THIS ENOUGH!  IF YOU DELETE FILES, IT'S ALL OVER!

WHEN THE FILES ARE IN PLACE, THE ACCOUNT IS FOLLOWED BY A SPACE AND (Deleted) WHICH IS WHAT MY SCRIPT IS LOOKING FOR!

THE SPACE AND PARENTHESES CAUSE ALL KINDS OF HAVOC WITH TERMINAL COMMANDS, THEREFORE MY CODE BELOW IS PARTICULARLY LOOKING FOR IT!  IT WILL NOT WORK ANY OTHER WAY.


AFTER THE ACCOUNT HAS BEEN DELETED, YOU MUST THEN JOIN THE MAC TO THE UOFI DOMAIN.  ONCE THE MAC HAS BEEN JOINED TO THE UOFI DOMAIN, THE USER MUST THEN LOG IN AND CREATE A "BLANK" ACCOUNT WITH UOFI CREDENTIALS.  LOG OUT OF THAT ACCOUNT.

IN A NUTSHELL, THE SCRIPTS BELOW TAKE THE OLD ACCOUNT AND MASH IT INTO THE NEW UOFI ACCOUNT.


*)



display dialog "Enter a UserName on this Mac for which we are going to transfer from UIUC to UOFI" default answer ""

-- here I define variables we use later
set punter to text returned of result -- because this is the punter we are looking at

set pittedDate to do shell script "date '+%Y%m%d'"
-- this is a variable that puts todays date in an ASCII friendly way
-- such as 20140812




-- First, let's undo an ugly trick that the MacOS does
-- When you delete a user, -- variable 'punter' -- but keep the files, the user's old folder will appear as 'punter (deleted)'
-- That space and those parentheses will wreck hell and choke many scripts
-- For simplicity sake, I will first rename punter (deleted) to punter_UIUC

try
	do shell script "mv /users/" & punter & "\\ \\(Deleted\\)/ /users/" & punter & "_UIUC" with administrator privileges
on error
	display dialog "We're looking for a deleted folder for the user: " & punter & ". That doesn't appear to be where it should be.  Double check, please."
	
end try



set UOFI to "/users/" & punter
-- the new profile, after rejoining to UOFI


set UIUC to "/users/" & punter & "_UIUC"
-- the old profile, hopefully helpfully changed with the underscore UIUC to make it all Posixy



--- Next, we make sure to make the Library folders are visible, as this will be crucial to transferring certain profiles

try
	do shell script "chflags nohidden " & UIUC & "/Library" with administrator privileges
on error
	display dialog "Looking for the Library folder for the deleted user: " & punter & ". That doesn't appear to be where it should be.  Double check, please."
end try

try
	do shell script "chflags nohidden " & UOFI & "/Library" with administrator privileges
on error
	display dialog "Looking for the Library folder for the new user: " & punter & ". That doesn't appear to be where it should be.  Double check, please."
end try

-- ++++++++++++++++++++++++++++++++++++++++++++++++++
-- take ownership of the old UIUC files
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

try
	do shell script "chown -R " & punter & space & UIUC & "/*" with administrator privileges
on error
	display dialog "Taking ownership of all the old files.  Something went wrong.   Check please."
end try

-- ++++++++++++++++++++++++++++++++++++++++++++++++++
-- this is moving the entire Kitten Kaboodle
-- ++++++++++++++++++++++++++++++++++++++++++++++++++
-- useful link http://www.cyberciti.biz/faq/unix-mv-command-examples/
-- remove everything from the UOFI account and make it a blank shell
try
	do shell script "rm -Rf " & UOFI & "/*" with administrator privileges
end try

try
	do shell script "mv" & space & UIUC & "/*" & space & UOFI with administrator privileges
end try

-- ++++++++++++++++++++++++++++++++++++++++++++++++++
-- Box is stubborn and will not sync properly
-- I am therefore leaving it back in the UIUC folder as Box Backup
-- ++++++++++++++++++++++++++++++++++++++++++++++++++


try
	do shell script "mv" & space & UOFI & "/Box\\ Sync/" & space & UIUC & "/BoxSync_Backup_" & punter & "_" & pittedDate with administrator privileges
end try



-- ++++++++++++++++++++++++++++++++++++++++++++++++++
--- Now I'm going to remove the Lync preferences.
--- This re-sets Lync, which avoids certain profile issues.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

try
	tell application "Microsoft Lync" to quit
end try

try
	do shell script "chflags nohidden " & UOFI & "/Library" with administrator privileges
on error
	display dialog "Looking for the Library folder for the new user: " & punter & ". That doesn't appear to be where it should be.  Double check, please."
end try


try
	do shell script "rm -Rf " & UOFI & "/Library/Caches/com.microsoft.Lync/*" with administrator privileges
end try

try
	do shell script "rm -Rf " & UOFI & "/Library/Preferences/ByHost/MicrosoftLyncRegistrationDB*" with administrator privileges
end try

try
	do shell script "rm -Rf " & UOFI & "/Library/Preferences/com.microsoft.Lync*" with administrator privileges
end try

try
	do shell script "rm -Rf " & UOFI & "/Library/Keychains/OC_KeyContainer*" with administrator privileges
end try


-- ++++++++++++++++++++++++++++++++++++++++++++++++++
--- To avoid certain complications, let's recreate the login keychain
--- We'll remove it, which will force it to be recreated on the next start or login.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

try
	set keychainFolder to "/users/" & UOFI & "/Library/Keychains/"
	try
		tell application "Finder" to set gaGa to name of first folder of keychainFolder
	end try
	-- if all goes correctly, this should be the long argle bargle folder with all annoying local settings
	-- has to be without administrator privileges.  I found doing it with admin privileges doesn't seem to to work correctly
end try




try
	do shell script "mv -R " & keychainFolder & "/" & gaGa & " /users/" & UIUC & "/KeychainDumpster_" & punter & "_" & pittedDate with administrator privileges
end try


-- ++++++++++++++++++++++++++++++++++++++++++++++++++
--- Lastly we'll properly hide the Library files again as should be
-- ++++++++++++++++++++++++++++++++++++++++++++++++++


try
	do shell script "chflags hidden " & UOFI & "/Library" with administrator privileges
end try


delay 1


display dialog "Done.  Remember, your Box Sync files will have to sync back down from the Cloud.  Backup copies of your files can be found in the " & UIUC & "/BoxSync_Backup folders."

-- ++++++++++++++++++++++++++++++++++++++++++++++++++
--- For Lync to work, we need to clear out Lync preferences
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

set reSpawn to "osascript -e 'tell app " & quote & "loginwindow" & quote & " to «event aevtrrst»'"

display dialog "Done.  Restart your Mac and this will hopefully do it." with icon note buttons {"Restart Now.", "D'oh. Too Busy. Let's Do It Later."}
if result = {button returned:"Restart Now."} then
	try
		do shell script reSpawn with administrator privileges
	end try
else if result = {button returned:"D'oh. Too Busy. Let's Do It Later."} then
	display dialog "OK. Restart at your own leisure, but Lync won't work until you do." giving up after 5 with icon note buttons {"Okay.", "Super Okay."}
end if

