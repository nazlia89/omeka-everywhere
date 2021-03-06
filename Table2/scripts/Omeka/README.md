Installer Developer’s Guide
To help with installation of apps we have created an installer script template to use with Nullsoft Scriptable Install System (NSIS) together with our internal tech WatchDog for kiosk modes on our tables. This guide is to help get your built application an installer to give to the client.


What you will need:
Nullsoft Scriptable Install System (NSIS) http://nsis.sourceforge.net/Download


Step 1: Get the Installer Scripts
Go to our GitHub repository and clone the cs-installer-scripts repo to your C:\repo folder.
In the folder you will find:
* Installer.nsi
* files Folder 
* watchdog Folder
* ideum2017.pfx 
* installer_icon.ico 
* sign_core.bat 


Step 2: Copy your application to the files folder
The Installer script will use the files within the files folder to compile your application into an installation executable. 


-For QT Quick Applications: Make sure to name the folder your .exe is in Executable. There is a Macro setting for QT applications that looks for the Executable folder.


Step 3: Setup your watchdogconfig.xml file
Go into the watchdog folder and edit the watchdogconfig.xml file. If you need you can use the WatchDog-Config by double clicking the WatchDog.exe (when the shortcut isn’t available) and use that interface. 


Add the program name that will run from the WatchDog (ex. Huey.exe). Since the WatchDog.exe is presumed to be in the same folder as the exe you don’t need to put the full path just the name of the exe.

Add any parameters to the item that will be needed in the arg attribute (ex. arg="-multidisplay") so that they may be passed when opening your program.

Save the file.


Step 4: Edit the Installer.nsi file
First you will want to change the NAME macro on line 2 to the name of your exe (ex. “Huey.exe”) this will set the appropriate paths and filenames throughout the Installer script.


If you are installing a QT Application you will want to uncomment line 3 (!define QT_APP "1" ) this will point the paths to NAME/Executable/ instead of just NAME/.


If you have dependencies (ex. vcredist_x86.exe) you will want to put them in the dependencies section of the Installer template. Add these files to the /dependecies folder and update the dependencies templates in the nsi script.


Save and close the file.


Step 5: Compile
Right-Click on the Installer.nsi file and click Compile. This will compile the code and give you a new installer with the files you supplied in the files folder. If there are errors within your script it will tell you in the console log of the NSIS Compile Window. This process may take a few minutes.

**NOTE** If you are getting errors in the compiler the code may have switched encodings!!!!!!
Open up a text editor (NotePad++ allows for encoding changes) and switch the encoding
to UTF-8. Save and try compiling again.


Step 6: (Optional) Code Sign the Installer
Requirements - Windows 8 developer SDK


Edit the sign_core.bat file. In there you will want to change the exe at the end to your application installer exe name (ex Huey_Installer.exe). Save the file.


Double click the file and it will come up with a command prompt that will sign your Installer with the Ideum credentials from the ideum2017.pfx file.


Step 7: Test
Make sure your installer works. The installer should be able to create a desktop shortcut, uninstaller, set whether or not to use the WatchDog, set the WatchDog pin, and start the application once finished installing. 


It will also create the watchdogconfig.xml and watchdogpin.txt for the WatchDog in Documents\Ideum\WatchDog\AppName\



******************************
02-20-2017 v 1.0.3
*Added a "BackDoor" Pin as 2469 so Ideum users can get into any exhibit.

08-05-2016 v 1.0.2
*Added the ability to pass parameters to program in watchdog in the config window and xml. 
*Updated installer script so the Startup Shortcut will set the correct Start In for non QT Applicaitons.

07-05-2016 v 1.0.1
*Added dependencies folder and updated installer script for easier additional installers (ex. Visual Studio Runtime)
