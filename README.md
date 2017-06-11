# Andy-s-Algorithm
These scripts were created to simplify the automated analysis of biological assays.

The macros that are available here include
1. IHC
2. Proximity Ligation Assays (PLA)
3. H&E
4. 3D colony assays

Method

1.	Download and install FIJI or update FIJI (version 1.51k or later) [https://fiji.sc]
2.	Download Andy’s Algorithms (eg DAB_IHC.ijm, PLA.ijm, HandE.ijm and 3D_colony.ijm) 
3.	Go to Plugins > Macros > Install the Algorithm of choice in the menu bar of FIJI
4.	Select the Andy’s Algorithm preference (eg IHC.ijm) to install the algorithm
5.	Go to Plugins > Macros. An option to select the algorithm will now be in the dropdown menu

The algorithm will be temporally installed into the toolbar of FIJI and closes when FIJI is exited. Simply reinstall the algorithm when you open FIJI again. The algorithm is designed for single images and not Z-stacks. Please convert image stacks to single files before running each algorithm. Sample images are provided at https://github.com/andlaw1841/Andy-s-Algorithm to assist users with the optimization of the image processing and analysis settings.



Troubleshooting

All - No values in dialogue box
When the user is prompted to enter a value in the dialogue box and a value within the dialogue box is deleted and no value is entered an Error with the following message will display.


                                     Macro Error
            Numberic value expected in run() function

            Dialog box title: "[Title of dialog where the value is deleted]"
            Key: "[Section where value was deleted]"
            Value or variable name: "[A variable name]"


This error will only occur if the user deletes a value and leaves it blank before proceeding with the next step. If the error occurs the user will have to close everything that is opened within FIJI and restart the macro. To avoid this error ensure that no parameters are empty or is left blank throughout the macro.





PLA - PC hidden files
1. When running the PLA Algorithm in Windows, hidden files (such as desktop.ini) in the image folder can cause an error message to display with either 'There are no images open' or 'Index (X) out of range in line 4278'. To correct this, in the image folder click on the View tab and select the Advanced settings. Check the "Show hidden files, folder or drives" and uncheck the "Hide protected operating system files" boxes and click OK. This will reveal the hidden files that are within the image folder and you can temporarily move those hidden files to another folder before you proceed with the PLA image analysis. Once the analysis is complete you can move the hidden files back into the folder and go back to the Advanced settings in the View tab and uncheck the "Show hidden files, folder or drives" and check the "Hide protected operating system files" boxes.
