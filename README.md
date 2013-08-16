FMSCore Killer
================

Adobe Connect Issue And Fix: Lingering Fmscore.exe Processes

We’ve setup Connect to expire the FMSCore processes after 2 hours,
but if someone is still connected to a recording,
it will keep the old zombie FMSCore process until that person disconnects.

It often happens that doesn’t work – and there’s seemingly no garbage collection in place to clean up old FMSCore.

So we created a simple AutoIt script which can be compiled to an EXE which works, but it has some dependancies…

The following dependencies / commands must all be in place:

* c:\Windows\system32\pv.exe
* c:\Windows\system32\pslist.exe
* c:\Windows\system32\pskill.exe

How it works
------------------

* the script uses pv.exe to find all FMS Core processes which have a command line argument that includes “flvplayerapp” (which is only for recorded courses)
* for each of the returned process ids
* it uses pslist to list details which include the age of the process
* it uses a regex match find the “hours it’s been running”
* if longer than 5 hours (a configurable parameter) it uses pskill to kill the process.

So we set this up on an hourly scheduled task and it handles garbage collection for us.

Installation / Usage
-----------------

* Install AutoIt http://www.autoitscript.com/site/autoit/
* Then but the dependencies (listed above) in the right place.
* Then put this script somewhere.
* Edit the script and put in the Administrator account password
* Run it manually and make sure it works...
* Finally, setup a schedualed task - run it as often as you like



