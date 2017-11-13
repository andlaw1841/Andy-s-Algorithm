macro "PLA"{

//Ver 2.40
/*
  * Ver 2.40 Update notes:
  * 
  * 1. Added watershed and exclusion in optimization table
  * 
  * 2. Added Gaussian Blur feature in Foci selection to increase accuracy
  *    by removing multiple counts in one foci
  *    
  * 3. Measurement of nuclear and cytoplasmic signal is now based on ROI
  *    and not mask. This removes the issue associated with a signal that
  *    is right in between the nucleus and the cytoplasm that gets counted
  *    twice in both regions
  * 
  * 4. Foci overlay has larger marking (line width change from 0 to 5)
  *    to make it easier to see the selection
  * 
  * 5. Error for incomplete image sets have been added to tutorial and 
  *    optimization section
  * 
   */
	
//The PLA macro will measure all sets of PLA images located in a specified folder. 
//The files that are analyzed will be identified by a regular expression 
//as defined by the user.

//Installing this macro
// 1. On FIJI toolbar go to Plugins > Macros > Install
// 2. Select PLA.ijm and click Open
// 3. Go back to Plugins > Macros and you should now see the option of PLA
// 4. Select PLA and follow the prompts

/*
 * Contents
-------------------------------------
 Tutorial Section
 Nucleus Tutorial No Cyto 001
 Foci Tutorial No Cyto 002
 Nucleus Tutorial 003
 Foci Tutorial 004
 Cytoplasmic Tutorial 005
 Tutorial Optimization 006
 PLA Unit Optimization 012
 PLA Analysis 018
-------------------------------------
 * 
 */

 //Author: Andrew Law
//a.law@garvan.org.au
//Tumour Development Lab
//Garvan Institute of Medical Research
//384 Victoria St. Darlinghurst NSW 2010

 
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Opening Dialogue


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/

run("Options...", "iterations=1 count=1 black edm=Overwrite do=Nothing");

yes = "Run the tutorial";
no = "Proceed straight to analysis";
Dialog.create("Greetings");
Dialog.addMessage("Would you like to run the tutorial?");
Dialog.addChoice("Type:", newArray(yes, no));
Dialog.show();
first = Dialog.getChoice();
second="none";


/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Tutorial Section


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/

if(first == yes){
	waitForUser("Thank you for choosing the tutorial","My name is Andy and I'm here to assist you in the analysis of a PLA assay.\nIn this tutorial we will look at how to analyze PLA images in three channels\nfor nuclei, foci, and/or cytoplasm.");
	wait(1);
	waitForUser("Note","If you encounter any problems and you need to quit the macro, close any windows\nopened in FIJI and restart the macro. IMPORTANT! Prior to restarting, please delete\nany files that were created by the macro in the target folder otherwise an error will\noccur.\n \nClick OK to continue.");
  	wait(1);
	waitForUser("Note2","When you run the tutorial or analysis, please ensure there are only images\nin the folder. The folder must only contain sets of images (nuclei, foci, and/or\ncytoplasm) and they must be in tandem, eg:\n \nNuclei01\nFoci01\nNuclei02\nFoci02\n \nIf there are other files or any of the image set are incomplete, then the macro\nwill not work properly.\n \nAdditionally, this macro will not modify your raw files.\n \nClick OK to continue.");
	wait(1);
  	waitForUser("1. Create optimization folder","Create a test folder and copy 3-5 sets of PLA images representative\nof all images to be analyzed. This folder will be used to optimize the\nimage analysis parameters.\n \nClick OK when you are finished.");
	wait(1);
	waitForUser("2. Select the optimization folder","After you click OK a pop-up window will appear. Please locate\nand select the optimization folder in this window and click OK.");

	dir = getDirectory("Select Optimization Folder");
	list = getFileList(dir);
	Array.sort(list);
	waitForUser("3. Assign the identifier for each channel", "Enter the file name identifier that is unique for each channel. For example, if all nuclei\nimages have ch00 in the file name and foci have ch01 in their file name, then type\nch00 and ch01 for nuclei and foci respectively and the macro will select all of these to\nanalyse from the selected folder.\n \nNote: If there are no cytoplasmic images, leave as 'NoCyto'.\n \nClick OK to continue.");
	Dialog.create("Channel names");
	Dialog.addMessage("Please type in the unique name for (case sensitive):");
	Dialog.addString("Nuclei", "");
	Dialog.addString("Foci", "");
	Dialog.addString("Cytoplasm", "NoCyto");
	Dialog.addMessage("Note: If there are no cytoplasmic images,\nplease leave as NoCyto.");
	Dialog.show();
	nuc = Dialog.getString();
	foci = Dialog.getString();
	cyto = Dialog.getString();
		if (cyto == "NoCyto"){
		check = list.length/2;
		error= round(check);
		if(error!=check){
			Dialog.create("Error: Number of files in directory");
			Dialog.addMessage("ERROR: Please ensure that there are complete PLA sets in your analysis folder.");
			Dialog.addMessage("Remove any other files or folders that may be in the analysis folder or");
			Dialog.addMessage("an error will occur at the end of the analysis.");
			Dialog.addMessage("Click 'Cancel' to exit analysis or 'OK' to proceed with the analysis");
			Dialog.show();
			
		}
	} else {
		check = list.length/3;
		error= round(check);
		if(error!=check){
			Dialog.create("Error: Number of files in directory");
			Dialog.addMessage("ERROR: Please ensure that there are complete PLA sets in your analysis folder.");
			Dialog.addMessage("Remove any other files or folders that may be in the analysis folder or");
			Dialog.addMessage("an error will occur at the end of the analysis.");
			Dialog.addMessage("Click 'Cancel' to exit analysis or 'OK' to proceed with the analysis");
			Dialog.show();
	}
	}
	tableTitle="PLA Optimization";
	tableTitle2="["+tableTitle+"]";
	run("Table...", "name="+tableTitle2+" width=400 height=250");
	print(tableTitle2,"\\Headings:Image name\tThreshold\tNucleus Bright Radius\tNucleus Bright Threshold\tNucleus Dark Radius\tNucleus Dark Threshold\tNucleus Gaussian Blur\tNucleus Lower Threshold\tNucleus Upper Threshold\tNucleus Lower Size Exclusion\tNucleus Upper Size Exclusion\tNucleus Lower Circularity Exclusion\tNucleus Upper Circularity Exclusion\tNucleus Watershed\tNucleus Edge Exclusion\tFoci Gaussian Blur\tFoci Maxima Value\tCytoplasm Bright Radius\tCytoplasm Bright Threshold\tCytoplasm Dark Radius\tCytoplasm Dark Threshold\tCytoplasm Gaussian Blur\tCytoplasm Lower Threshold\tCytoplasm Upper Threshold\tCytoplasm Lower Size Exclusion\tCytoplasm Upper Size Exclusion\tCytoplasm Lower Circularity Exclusion\tCytoplasm Upper Circularity Exclusion\tCytoplasm Watershed\tCytoplasm Edge Exclusion");		
	//tutorial section for no cytoplasmic images
	if (cyto == "NoCyto"){
		brC = "NaN";
		btC = "NaN";
		drC = "NaN";
		dtC = "NaN";
		sigC = "NaN";
		LowerCyto = "NaN";
		UpperCyto = "NaN";
		lseC = "NaN";
		useC = "NaN";
		lceC = "NaN";
		uceC = "NaN";
		watershedC = "NaN";
		excludeC = "NaN";
		CytoArea = "NaN";
		AverageCytoArea = "NaN";
		AverageCytoArea = "NaN";
		NonCytoSignal = "NaN";
		CytoSignal = "NaN";
		AverageSignalPerCyto = "NaN";
		PercentCytoSignal = "NaN";
		IntracellularSignal = "NaN";
		ExtracellularSignal = "NaN";
		for(i=0; i<2; i+=2){
			filename = dir + list[i];
			filename2 = dir + list[i+1];

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Tutorial No Cyto 001


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
			nucTutorialNoCyto(); //open nuclei images
	
				function nucTutorialNoCyto(){
					if (matches(filename, ".*"+nuc+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+nuc+".*")){
						open(filename2);
					}
				}
nameStore0 = getTitle();
				rename("Nucleus");
				waitForUser("4. Nuclear analysis","First we need to determine the number and area of all nuclei in each image. \n \nClick OK to continue.");
				selectWindow("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				waitForUser("5. Enhance nuclei contrast and remove background","The nuclear image will go through a process called 'Enhance Contrast' to\nenhance contrast in images with low brightness.\n \nThen we will remove the background to clean up the images.\n \nClick OK to continue.");
				selectWindow("Nuclei-Duplicate");
				run("Duplicate...", "title=Test");
				waitForUser("6. Remove outliers", "A duplicate image has been created to test which parameters are best for removing the\nbackground in your image. Select preview and start with a value of 10 for 'radius' and\n50 for 'threshold' and try selecting both 'bright' and 'dark'. \n \nIf the images have no background and does not require modification then put '0' in the\nradius. Once you have finished sampling your image, record the values for input later.\n \nClick OK to proceed.");
				selectWindow("Test");
				run("Remove Outliers...");
				waitForUser("7. Apply gaussian blur","Using the duplicate image again, apply a gaussian blur filter to smooth out the\nedges of the nuclei. If you do not want this filter, enter 0 for 'sigma'. Click\n'preview' to sample the level of gaussian blur.\n \nClick OK to continue.");
				selectWindow("Test");
				run("Gaussian Blur...");
				selectWindow("Test");
				close();
				waitForUser("8. Return to the raw image","Now that the parameters have been optimized on the test image, enter the\nparameters again to apply it on your original image. If you do not want to\napply any changes, then enter 0 for all parameters.\n \nClick OK to continue.");
				selectWindow("Nuclei-Duplicate");
				Dialog.create("Removing background and smoothing the edges");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 20);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				selectWindow("Nuclei-Duplicate");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				Dialog.create("Thresholding");
				Dialog.addMessage("Select automatic or manual threshold");
				Dialog.addChoice("", newArray("Automatic", "Manual"));
				Dialog.show();
				Thresh = Dialog.getChoice();
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Huang");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Huang white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Intermodes");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Otsu");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=RenyiEntropy");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=RenyiEntropy white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Intermodes");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("RenyiEntropy");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
					Dialog.show();
					methodN = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Nuclei-Duplicate");
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					waitForUser("9. Set the automatic threshold for nuclei","A threshold will be applied to the images using the tools available\nin Image > Adjust > Auto Threshold. Once selected the threshold\nwill be adjusted on each image based on the method chosen.\n \nClick OK to continue.");
					LowerNuc = "Auto="+methodN;
					UpperNuc = "NaN";
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					selectWindow("Nuclei-Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(50, 255);
					selectWindow("Nuclei-Duplicate");
					run("Threshold...");
		  			waitForUser("9. Set the manual threshold for nuclei","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the top slide bar in the threshold window until all nuclei have\nbeen selected. Selected nuclei will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
					getThreshold(LowerNuc,UpperNuc);
					selectWindow("Nuclei-Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				waitForUser("10. Background particle exclusion","To exclude small and large particle and background artifacts, you must now select an upper and lower\nsize exclusion. Test different size exclusion parameters to determine which work best for your images.\nTry a lower size exclusion of 150 pixels and an upper size exclusion of infinity as a starting point.\nYou can also apply a lower and upper circularity exclusion between 0 to 1, where 1 is a perfect circle.\n \nNuclei can be segmented using watershed.\n \nEdge exclusion can be included to omit any incomplete nuclei at the edge of the image.\n \nClick OK to continue."); 
				selectWindow("Nuclei-Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				particleN();//analyse particle selection
				function particleN(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				selectWindow("Nuclei-Duplicate");
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Nuclei-Duplicate2");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's inputs 
				setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
				setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
				setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
				setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
				setResult("Nucleus Watershed",nResults-1,watershedN);
				setResult("Nucleus Exclusion",nResults-1,excludeN);
				updateResults();
				selectWindow("Nucleus");
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow("Nucleus");
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts the particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Nuclei-Mask");
					close();
					if (isOpen("Nuclei-Duplicate2")==1){
					selectWindow("Nuclei-Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Nuclei-Duplicate");
					particleN();
						} else{//proceeds with analysis
							if (isOpen("Nuclei-Duplicate2")==1){
							selectWindow("Nuclei-Duplicate");
							close();
							selectWindow("Nuclei-Duplicate2");
							rename("Nuclei-Duplicate");
							}
						}
				}//records user's final inputs
				lseN = getResult("Nucleus Lower Size Exclusion",nResults-1);
				useN = getResult("Nucleus Upper Size Exclusion",nResults-1);
				lceN = getResult("Nucleus Lower Circularity Exclusion",nResults-1);
				uceN = getResult("Nucleus Upper Circularity Exclusion",nResults-1);
				watershedN = getResult("Nucleus Watershed",nResults-1);
				excludeN = getResult("Nucleus Exclusion",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Nuclei-Mask");
				waitForUser("11. Create an overlaying of the nuclear selection.", "With the exclusion complete, a duplicate overlay image will be produced\nfrom the original image to visualize the accuracy of your selection.\n \nClick OK to continue.");
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");//making measurements
				if(getResult('Area', nResults-1)!=0) {
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
					}
				selectWindow("Nuclei-Duplicate");
				close();

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Tutorial No Cyto 002


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				fociTutorialNoCyto();//opens foci image
				
				function fociTutorialNoCyto(){
					if (matches(filename, ".*"+foci+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+foci+".*")){
						open(filename2);
					}
				}
nameStore1 = getTitle();
				rename("Foci");
				waitForUser("12. Analyze PLA foci","For the selection of PLA foci, we can apply a Gaussian blur to reduce\nthe noise in the image and improve the accuracy of the foci selection.\nTry a sigma radius of '1'.\n \nClick OK to continue.");
				selectWindow("Foci");
				run("Gaussian Blur...");
				sigF = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
				waitForUser("13. PLA foci selection","We must now determine the value for the noise tolerance to accurately\nselect PLA foci. Select preview image and try a starting with a value of\n10 for noise tolerance. The higher the number the fewer foci selected.\n \nIMPORTANT: Once you've set the value, select 'Single Points' in the\nOutput type and press OK.\n \nClick OK to continue.");
				selectWindow("Foci");
				run("Find Maxima...");
				rename("Foci-Points");
				roiManager("Reset");
				max = getNumber("Please enter the value you had\njust entered for the noise tolerance",0);
				waitForUser("14. Create an overlay of PLA foci selection ","A duplicate overlay image will be produced showing the foci selection on\nthe original image to visualize the accuracy of your selection.\n \nClick OK to continue.");
				selectWindow("Foci-Points");
				if(is("binary")==true){//makes image into single points if it was not selected
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				} else {
					selectWindow("Foci-Points");
					rename("Foci");
					selectWindow("Foci");
					run("Find Maxima...", "output=[Single Points]");
					rename("Foci-Points");
					roiManager("Reset");
					selectWindow("Foci-Points");
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				}
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {//counting total signal
					TotalSignal = roiManager("count");
					roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					} else {
						TotalSignal = 0;
					}
				imageCalculator("Add create", "Foci-Points","Nuclei-Mask");
				roiManager("Reset");
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {
					NonNuclearSignal = roiManager("count");
				} else {
					NonNuclearSignal = 0;
					}
				close();
				NuclearSignal = TotalSignal-NonNuclearSignal;
				if (NucleusCount!=0) {
					AverageSignalPerNucleus = NuclearSignal/NucleusCount;
				} else{
					AverageSignalPerNucleus = 0;
				}
				if (TotalSignal!=0) {
					PercentNuclearSignal = (NuclearSignal/TotalSignal)*100;
				} else{
					PercentNuclearSignal = 0;
				}
						if(isOpen("ROI Manager")==1){
						selectWindow("ROI Manager");
						run("Close");
						}
						run("Close All");
						
				}//ending of the FOR loop for nuclei and foci in tutorial
			} else { //tutorial section with cytoplasmic images
				for(i=0; i<3; i+=3){
					filename = dir + list[i];
					filename2 = dir + list[i+1];
					filename3 = dir + list[i+2];
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Tutorial 003


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
					nucTutorial(); //open nuclei images
			
						function nucTutorial(){
							if (matches(filename, ".*"+nuc+".*")){
								open(filename);
							}
							if (matches(filename2, ".*"+nuc+".*")){
								open(filename2);
							}
							if (matches(filename3, ".*"+nuc+".*")){
								open(filename3);
							}
						}
nameStore0 = getTitle();
				rename("Nucleus");
				waitForUser("4. Nuclear analysis","First we need to determine the number and area of all nuclei in each image. \n \nClick OK to continue.");
				selectWindow("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				waitForUser("5. Enhance nuclei contrast and remove background","The nuclear image will go through a process called 'Enhance Contrast' to\nenhance contrast in images with low brightness.\n \nThen we will remove the background to clean up the images.\n \nClick OK to continue.");
				selectWindow("Nuclei-Duplicate");
				run("Duplicate...", "title=Test");
				waitForUser("6. Remove outliers", "A duplicate image has been created to test which parameters are best for removing the\nbackground in your image. Select preview and start with a value of 10 for 'radius' and\n50 for 'threshold' and try selecting both 'bright' and 'dark'. \n \nIf the images have no background and does not require modification then put '0' in the\nradius. Once you have finished sampling your image, record the values for input later.\n \nClick OK to proceed.");
				selectWindow("Test");
				run("Remove Outliers...");
				waitForUser("7. Apply gaussian blur","Using the duplicate image again, apply a gaussian blur filter to smooth out the\nedges of the nuclei. If you do not want this filter, enter 0 for 'sigma'. Click\n'preview' to sample the level of gaussian blur.\n \nClick OK to continue.");
				selectWindow("Test");
				run("Gaussian Blur...");
				selectWindow("Test");
				close();
				waitForUser("8. Return to the raw image","Now that the parameters have been optimized on the test image, enter the\nparameters again to apply it on your original image. If you do not want to\napply any changes, then enter 0 for all parameters.\n \nClick OK to continue.");
				selectWindow("Nuclei-Duplicate");
				Dialog.create("Removing background and smoothing the edges");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 20);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				selectWindow("Nuclei-Duplicate");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				Dialog.create("Thresholding");
				Dialog.addMessage("Select automatic or manual threshold");
				Dialog.addChoice("", newArray("Automatic", "Manual"));
				Dialog.show();
				Thresh = Dialog.getChoice();
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Huang");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Huang white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Intermodes");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Otsu");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=RenyiEntropy");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=RenyiEntropy white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Intermodes");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("RenyiEntropy");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
					Dialog.show();
					methodN = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Nuclei-Duplicate");
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					waitForUser("9. Set the automatic threshold for nuclei","A threshold will be applied to the images using the tools available\nin Image > Adjust > Auto Threshold. Once selected the threshold\nwill be adjusted on each image based on the method chosen.\n \nClick OK to continue.");
					LowerNuc = "Auto="+methodN;
					UpperNuc = "NaN";
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					selectWindow("Nuclei-Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(50, 255);
					selectWindow("Nuclei-Duplicate");
					run("Threshold...");
		  			waitForUser("9. Set the manual threshold for nuclei","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the top slide bar in the threshold window until all nuclei have\nbeen selected. Selected nuclei will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
					getThreshold(LowerNuc,UpperNuc);
					selectWindow("Nuclei-Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				waitForUser("10. Background particle exclusion","To exclude small and large particle and background artifacts, you must now select an upper and lower\nsize exclusion. Test different size exclusion parameters to determine which work best for your images.\nTry a lower size exclusion of 150 pixels and an upper size exclusion of infinity as a starting point.\nYou can also apply a lower and upper circularity exclusion between 0 to 1, where 1 is a perfect circle.\n \nNuclei can be segmented using watershed.\n \nEdge exclusion can be included to omit any incomplete nuclei at the edge of the image.\n \nClick OK to continue."); 
				selectWindow("Nuclei-Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				particleN();//analyse particle selection
				function particleN(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				selectWindow("Nuclei-Duplicate");
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Nuclei-Duplicate2");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's inputs
				setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
				setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
				setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
				setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
				setResult("Nucleus Watershed",nResults-1,watershedN);
				setResult("Nucleus Exclusion",nResults-1,excludeN);
				updateResults();
				selectWindow("Nucleus");
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow("Nucleus");
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Nuclei-Mask");
					close();
					if (isOpen("Nuclei-Duplicate2")==1){
					selectWindow("Nuclei-Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Nuclei-Duplicate");
					particleN();
						} else{
							if (isOpen("Nuclei-Duplicate2")==1){
							selectWindow("Nuclei-Duplicate");
							close();
							selectWindow("Nuclei-Duplicate2");
							rename("Nuclei-Duplicate");
							}
						}
				}//records user's final inputs
				lseN = getResult("Nucleus Lower Size Exclusion",nResults-1);
				useN = getResult("Nucleus Upper Size Exclusion",nResults-1);
				lceN = getResult("Nucleus Lower Circularity Exclusion",nResults-1);
				uceN = getResult("Nucleus Upper Circularity Exclusion",nResults-1);
				watershedN = getResult("Nucleus Watershed",nResults-1);
				excludeN = getResult("Nucleus Exclusion",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Nuclei-Mask");
				waitForUser("11. Create an overlaying of the nuclear selection.", "With the exclusion complete, a duplicate overlay image will be produced\nfrom the original image to visualize the accuracy of your selection.\n \nClick OK to continue.");
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");//making measurements
				if(getResult('Area', nResults-1)!=0) {
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
					}
				selectWindow("Nuclei-Duplicate");
				close();
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Tutorial 004


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
						fociTutorial();//opens foci image

						function fociTutorial(){
							if (matches(filename, ".*"+foci+".*")){
								open(filename);
							}
							if (matches(filename2, ".*"+foci+".*")){
								open(filename2);
							}
							if (matches(filename3, ".*"+foci+".*")){
								open(filename3);
							}
						}
				nameStore1 = getTitle();
				rename("Foci");
				waitForUser("12. Analyze PLA foci","For the selection of PLA foci, we can apply a Gaussian blur to reduce\nthe noise in the image and improve the accuracy of the foci selection.\nTry a sigma radius of '1'.\n \nClick OK to continue.");
				selectWindow("Foci");
				run("Gaussian Blur...");
				sigF = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
				waitForUser("13. PLA foci selection","We must now determine the value for the noise tolerance to accurately\nselect PLA foci. Select preview image and try a starting with a value of\n10 for noise tolerance. The higher the number the fewer foci selected.\n \nIMPORTANT: Once you've set the value, select 'Single Points' in the\nOutput type and press OK.\n \nClick OK to continue.");
				selectWindow("Foci");
				run("Find Maxima...");
				rename("Foci-Points");
				roiManager("Reset");
				max = getNumber("Please enter the value you had\njust entered for the noise tolerance",0);
				waitForUser("14. Create an overlay of PLA foci selection ","A duplicate overlay image will be produced showing the foci selection on\nthe original image to visualize the accuracy of your selection.\n \nClick OK to continue.");
				selectWindow("Foci-Points");
				if(is("binary")==true){
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				} else {//makes image into single points if it was not selected
					selectWindow("Foci-Points");
					rename("Foci");
					selectWindow("Foci");
					run("Find Maxima...", "output=[Single Points]");
					rename("Foci-Points");
					roiManager("Reset");
					selectWindow("Foci-Points");
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				}
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {
					TotalSignal = roiManager("count");
					roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					} else {
						TotalSignal = 0;
					}
				imageCalculator("Add create", "Foci-Points","Nuclei-Mask");
				roiManager("Reset");
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {
					NonNuclearSignal = roiManager("count");
				} else {
					NonNuclearSignal = 0;
					}
				close();
				NuclearSignal = TotalSignal-NonNuclearSignal;
				if (NucleusCount!=0) {
					AverageSignalPerNucleus = NuclearSignal/NucleusCount;
				} else{
					AverageSignalPerNucleus = 0;
				}
				if (TotalSignal!=0) {
					PercentNuclearSignal = (NuclearSignal/TotalSignal)*100;
				} else{
					PercentNuclearSignal = 0;
				}
						roiManager("Reset");
						

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Cytoplasmic Tutorial 005


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
						cytoTutorial();//opens cytoplasm image

							function cytoTutorial(){
								if (matches(filename, ".*"+cyto+".*")){
									open(filename);
								}
								if (matches(filename2, ".*"+cyto+".*")){
									open(filename2);
								}	
								if (matches(filename3, ".*"+cyto+".*")){
									open(filename3);
								}
							}			
nameStore2 = getTitle();
						rename("Cytoplasm");
						run("Duplicate...", "title=Cytoplasm-Duplicate");
						run("Enhance Contrast...", "saturated=0.01");
						waitForUser("15. Cytoplasm analysis","We will now determine the area of all the cytoplasm in each image.\n \nClick OK to continue.");
						selectWindow("Cytoplasm-Duplicate");
						run("Duplicate...", "title=Test");
						waitForUser("16. Remove outliers", "A duplicate image has been created to test which parameters are best for removing the\nbackground in your image. Select preview and start with a value of 10 for 'radius' and\n50 for 'threshold' and try selecting both 'bright' and 'dark'. \n \nIf the images have no background and does not require modification then put '0' in the\nradius. Once you have finished sampling your image, record the values for input later.\n \nClick OK to proceed.");
						selectWindow("Test");
						run("Remove Outliers...");
						waitForUser("17. Apply a gaussian blur","Using the duplicate image again, apply a gaussian blur filter to smooth out the\nedges of the cytoplasm. If you do not want this filter, enter 0 for 'sigma'. Click\n'preview' to sample the level of gaussian blur.\n \nClick OK to continue.");
						selectWindow("Test");
						run("Gaussian Blur...");
						selectWindow("Test");
						close();
						waitForUser("18. Return to the raw image","Now that the parameters have been optimized on the test image, enter the\nparameters again to apply it on your original image. If you do not want to\napply any changes, then enter 0 for all parameters.\n \nClick OK to continue.");
						selectWindow("Cytoplasm-Duplicate");
						Dialog.create("Removing background and smoothing the edges");
						Dialog.addMessage("Please enter the values for removing background:");
						Dialog.addMessage("Bright:");
						Dialog.addNumber("Radius:", 5);
						Dialog.addNumber("Threshold", 50);
						Dialog.addMessage("Dark:");
						Dialog.addNumber("Radius:", 5);
						Dialog.addNumber("Threshold", 20);
						Dialog.addMessage("Gaussian Blur:");
						Dialog.addNumber("Sigma:", 2);
						Dialog.show();
						brC = Dialog.getNumber();
						btC = Dialog.getNumber();
						drC = Dialog.getNumber();
						dtC = Dialog.getNumber();
						sigC = Dialog.getNumber();
						selectWindow("Cytoplasm-Duplicate");
						run("Remove Outliers...","radius=brC threshold=btC which=Bright");
						run("Remove Outliers...","radius=drC threshold=dtC which=Dark");
						run("Gaussian Blur...", "sigma=sigC");
						run("8-bit");
						if (Thresh == "Automatic"){//automatic threshold selection
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Original");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Huang");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Huang white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Intermodes");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Intermodes white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Otsu");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Otsu white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=RenyiEntropy");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=RenyiEntropy white");
							run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
							setSlice(1); 
							setMetadata("Original");
							setSlice(2);
							setMetadata("Huang");
							setSlice(3);
							setMetadata("Intermodes");
							setSlice(4);
							setMetadata("Otsu");
							setSlice(5);
							setMetadata("RenyiEntropy");
							run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
							Dialog.create("Thresholding");
							Dialog.addMessage("Select the automatic method");
							Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
							Dialog.show();
							methodC = Dialog.getChoice();
							selectWindow("Montage");
							close();
							selectWindow("Stacks");
							close();
							selectWindow("Cytoplasm-Duplicate");
								if(methodC=="Huang"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Huang white");
								}
								if(methodC=="Intermodes"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Intermodes white");
								}
								if(methodC=="Otsu"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Otsu white");
								}
								if(methodC=="RenyiEntropy"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=RenyiEntropy white");
								}
							waitForUser("19. Set the automatic threshold for cytoplasm","A threshold will be applied to the images using the tools available\nin Image > Adjust > Auto Threshold. Once selected the threshold\nwill be adjusted on each image based on the method chosen.\n \nClick OK to continue.");
							LowerCyto = "Auto="+methodC;
							UpperCyto = "NaN";
							selectWindow("Cytoplasm-Duplicate");
							setThreshold(1, 255);
						} else{//manual threshold
							selectWindow("Cytoplasm-Duplicate");
							setAutoThreshold("Default dark");
							run("Threshold...");
							setThreshold(50, 255);
							selectWindow("Cytoplasm-Duplicate");
							run("Threshold...");
				  			waitForUser("19. Set the manual threshold for cytoplasm","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the top slide bar in the threshold window until all cytoplasm have\nbeen selected. Selected cytoplasm will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
							getThreshold(LowerCyto,UpperCyto);
							setOption("BlackBackground", true);
							run("Convert to Mask");
							setThreshold(1, 255);
						}
						run("Set Measurements...", "area limit redirect=None decimal=3");
						waitForUser("20. Background particle exclusion","To exclude small and large particle and background artifacts, you must now select an upper and lower\nsize exclusion. Test different size exclusion parameters to determine which work best for your images.\nTry a lower size exclusion of 150 pixels and an upper size exclusion of infinity as a starting point.\nYou can also apply a lower and upper circularity exclusion between 0 to 1, where 1 is a perfect circle.\n \nNuclei can be segmented using watershed.\n \nEdge exclusion can be included to omit any incomplete nuclei at the edge of the image.\n \nClick OK to continue."); 
						selectWindow("Cytoplasm-Duplicate");
						roiManager("Reset");
						run("Measure");
						IJ.deleteRows(nResults-1, nResults-1);
						particleC();//particle analysis selection
						function particleC(){
						Dialog.create("Size and Circularity Exclusion");
						Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
						Dialog.addNumber("Lower size exclusion:", 0);
						Dialog.addString("Upper size exclusion:", "infinity");
						Dialog.addNumber("Lower circularity exclusion:", 0.00);
						Dialog.addNumber("Upper circularity exclusion:", 1.00);
						Dialog.addMessage("Would you like to watershed (segment)\nthe cytoplasm?");
						Dialog.addCheckbox("watershed", false);
						Dialog.addMessage("Would you like to exclude the cytoplasm\nat the edges?");
						Dialog.addCheckbox("exclude", true);
						Dialog.show();
						lseC = Dialog.getNumber();
						useC = Dialog.getString();
						lceC = Dialog.getNumber();
						uceC = Dialog.getNumber();
						watershedC = Dialog.getCheckbox();
						excludeC = Dialog.getCheckbox();
						selectWindow("Cytoplasm-Duplicate");
						if (watershedC == true){
							run("Duplicate...", "title=Cytoplasm-Duplicate2");
							run("Watershed");
						}
						if (excludeC == true){
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks exclude add");
						} else {		
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks add");
						}
						rename("Cytoplasm Mask");
						if(isOpen("Log")==1){
							selectWindow("Log");
							run("Close");
						}
						run("Measure");//records user's inputs
						setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
						setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
						setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
						setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
						setResult("Cytoplasm Watershed",nResults-1,watershedC);
						setResult("Cytoplasm Exclusion",nResults-1,excludeC);
						updateResults();
						selectWindow("Cytoplasm");
						roiManager("Show All without labels");	
						Dialog.create("Retry exclusion?");
						Dialog.addMessage("Are you happy with the selection?");
						Dialog.addChoice("Type:", newArray("yes", "no"));
						Dialog.show();
						retry = Dialog.getChoice();
						selectWindow("Cytoplasm");
						roiManager("Show None");
						if(retry=="no"){//removes user's inputs and restarts particle analysis
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Cytoplasm Mask");
							close();
							if (isOpen("Cytoplasm-Duplicate2")==1){
							selectWindow("Cytoplasm-Duplicate2");
							close();
							}
							roiManager("Reset");
							selectWindow("Cytoplasm-Duplicate");
							particleC();
								} else{
									if (isOpen("Cytoplasm-Duplicate2")==1){
									selectWindow("Cytoplasm-Duplicate");
									close();
									selectWindow("Cytoplasm-Duplicate2");
									rename("Cytoplasm-Duplicate");
									}
								}
						}//records user's final inputs
						lseC = getResult("Cytoplasm Lower Size Exclusion",nResults-1);
						useC = getResult("Cytoplasm Upper Size Exclusion",nResults-1);
						lceC = getResult("Cytoplasm Lower Circularity Exclusion",nResults-1);
						uceC = getResult("Cytoplasm Upper Circularity Exclusion",nResults-1);
						watershedC = getResult("Cytoplasm Watershed",nResults-1);
						excludeC = getResult("Cytoplasm Exclusion",nResults-1);
						IJ.deleteRows(nResults-1, nResults-1);
						selectWindow("Cytoplasm Mask");
						imageCalculator("Subtract create", "Cytoplasm Mask","Nuclei-Mask");
						rename("Cytoplasm Mask2");
						selectWindow("Cytoplasm Mask");
						close();
						selectWindow("Cytoplasm Mask2");
						rename("Cytoplasm Mask");
						setAutoThreshold("Default dark");
						//run("Threshold...");
						setThreshold(10, 255);
						waitForUser("21. Create an overlay of the cytoplasm selection.", "With the exclusion complete, an duplicate overlay image will be produced\nfrom the original image to visualize the accuracy of your selection.\n \nClick OK to continue.");
						selectWindow("Cytoplasm Mask");
						run("Set Measurements...", "area limit redirect=None decimal=3");
						run("Set Scale...", "distance=0 known=0 unit=pixel");
						run("Measure");//makes measurements
						if(getResult('Area', nResults-1)!=0) {
							CytoArea = getResult('Area', nResults-1);
						} else {
							CytoArea = 0;
						}
						IJ.deleteRows(nResults-1, nResults-1);
						if (roiManager("count")!=0) {
							roiManager("Save",  dir+nameStore2+" - Cytoplasm.zip");
							selectWindow("Cytoplasm Mask");
							saveAs("Tiff", dir+nameStore2+" - Cytoplasm Mask");
							rename("Cytoplasm Mask");
							selectWindow("Cytoplasm");
							roiManager("Show All without labels");	
							roiManager("Set Fill Color", "blue");
							run("Flatten");
							saveAs("Tiff", dir+nameStore2+" - Cytoplasm Overlay");
							close();
							roiManager("Set Color", "yellow");
						} else {
							AverageCytoArea = 0;
						}
						run("Close All");
						if(isOpen("ROI Manager")==1){
							selectWindow("ROI Manager");
							run("Close");
							}
				}//ending of the ELSE for nuclei, foci and cyto for the first set of images in tutorial
			}//ending of the first set of images for tutorial
	if(useN==NaN){
		useN = "infinity";
	}
	if(cyto!="NoCyto" && useC == NaN){
		useC = "infinity";
	}//prints out user's adjustment in results table and in adjustment table
	setResult("Nucleus Bright Radius",nResults-1,brN);
	setResult("Nucleus Bright Threshold",nResults-1,btN);	
	setResult("Nucleus Dark Radius",nResults-1,drN);
	setResult("Nucleus Dark Threshold",nResults-1,dtN);	
	setResult("Nucleus Gaussian Blur",nResults-1,sigN);
	setResult("Nucleus Lower Threshold",nResults-1,LowerNuc);
	setResult("Nucleus Upper Threshold",nResults-1,UpperNuc);
	setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
	setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
	setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
	setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
	setResult("Nucleus Watershed",nResults-1,watershedN);
	setResult("Nucleus Exclusion",nResults-1,excludeN);
	setResult("Foci Gaussian Blur",nResults-1,sigF);
	setResult("Foci Maxima Value",nResults-1,max);
	setResult("Cytoplasm Bright Radius",nResults-1,brC);
	setResult("Cytoplasm Bright Threshold",nResults-1,btC);
	setResult("Cytoplasm Dark Radius",nResults-1,drC);
	setResult("Cytoplasm Dark Threshold",nResults-1,dtC);
	setResult("Cytoplasm Gaussian Blur",nResults-1,sigC);
	setResult("Cytoplasm Lower Threshold",nResults-1,LowerCyto);
	setResult("Cytoplasm Upper Threshold",nResults-1,UpperCyto);
	setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
	setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
	setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
	setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
	setResult("Cytoplasm Watershed",nResults-1,watershedC);
	setResult("Cytoplasm Exclusion",nResults-1,excludeC);
	updateResults();
	if(watershedN==1){
		watershedN = "TRUE";
	} else {
		watershedN = "FALSE";
	}
	if(excludeN==1){
		excludeN = "TRUE";
	} else {
		excludeN = "FALSE";
	}
	if(watershedC==1){
		watershedC = "TRUE";
	} else if (watershedC==0) {
		watershedC = "FALSE";
	}
	if(excludeC==1){
		excludeC = "TRUE";
	} else if (excludeC==0){
		excludeC = "FALSE";
	}
	print(tableTitle2, nameStore0 + "\t"  + Thresh + "\t"  + brN + "\t"  + btN + "\t"  + drN + "\t"  + dtN + "\t"  + sigN + "\t"  + LowerNuc + "\t" + UpperNuc + "\t"  + lseN + "\t"  + useN + "\t"  + lceN + "\t"  + uceN + "\t"  + watershedN + "\t"  + excludeN + "\t"  + sigF + "\t"  + max + "\t"  + brC + "\t"  + btC + "\t"  + drC + "\t"  + dtC + "\t"  + sigC + "\t"  + LowerCyto + "\t"  + UpperCyto + "\t"  + lseC + "\t"  + useC + "\t"  + lceC + "\t"  + uceC + "\t"  + watershedC + "\t"  + excludeC);	
	selectWindow("PLA Optimization");
	waitForUser("Set the scale", "Optional: If you know the units for each pixel in the images you can now set the\nscale. For more detail refer to https://imagej.net/SpatialCalibration.\n \nWhen you click OK, a dialog box will appear for you to set the scale, if you do not\nknow the pixel length and distance simply click OK. You can also set a scale later\nduring analysis.\n \nClick OK to proceed.");
	Dialog.create("Setting a scale");
	Dialog.addMessage("Please set a scale for the measurement.\nIf no scale is set then the measurments\nwill be made in pixel size.");
	Dialog.addNumber("Distance in pixels:", 0);
	Dialog.addNumber("Known distance:", 0);
	Dialog.addString("Unit of length: pixel/", "pixel");
	Dialog.addMessage("For details to set scale refer to\nhttps://imagej.net/SpatialCalibration");
	Dialog.show();
	dist = Dialog.getNumber();
	know = Dialog.getNumber();
	unit = Dialog.getString();

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Tutorial Optimization 006


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
	waitForUser("Optimize the remaining test images","We will now complete the optimization for the rest\nof the images in the test folder when you click OK.");
	if (cyto == "NoCyto"){//adjustment of rest of images with no cyto
		for(i=2; i<list.length; i+=2){
			filename = dir + list[i];
			filename2 = dir + list[i+1];
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Threshold No Cyto After Tutorial 007


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
			nucNoTutorialNoCyto();//opens nuclei image
			
			nameStore0 = getTitle();
				rename("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				selectWindow("Nuclei-Duplicate");
				run("Duplicate...", "title=Test");
				waitForUser("Test image for nuclei", "A duplicate image has been created to test which parameters are best for removing the background\nin your image. Select preview and try starting with a value of 10 for 'radius' and 50 for 'threshold'\nand try selecting both both 'bright' and 'dark'. nIf the image shows no background, then the image\nis unaffected by this process. If the images have no background and do not require modification\nthen put '0' in the radius.\n \nOnce you have finished sampling your image, record the values for input later.\n \nClick OK to proceed.");
				selectWindow("Test");
				run("Remove Outliers...");
				selectWindow("Test");
				run("Gaussian Blur...");
				selectWindow("Test");
				close();
				Dialog.create("Removing background and smoothing the edges");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 20);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				selectWindow("Nuclei-Duplicate");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				Dialog.create("Thresholding");
				Dialog.addMessage("Select automatic or manual threshold");
				Dialog.addChoice("", newArray("Automatic", "Manual"));
				Dialog.show();
				Thresh = Dialog.getChoice();
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Huang");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Huang white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Intermodes");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Otsu");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=RenyiEntropy");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=RenyiEntropy white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Intermodes");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("RenyiEntropy");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
					Dialog.show();
					methodN = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Nuclei-Duplicate");
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					LowerNuc = "Auto="+methodN;
					UpperNuc = "NaN";
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(50, 255);
					selectWindow("Nuclei-Duplicate");
					run("Threshold...");
		  			waitForUser("Select for all nuclei using the top slide bar in\nthe Threshold window. Click OK to proceed.");
					getThreshold(LowerNuc,UpperNuc);
					selectWindow("Nuclei-Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				selectWindow("Nuclei-Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				particleN();//analyse particle selection
				function particleN(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				selectWindow("Nuclei-Duplicate");
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Nuclei-Duplicate2");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
				setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
				setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
				setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
				setResult("Nucleus Watershed",nResults-1,watershedN);
				setResult("Nucleus Exclusion",nResults-1,excludeN);
				updateResults();
				selectWindow("Nucleus");
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow("Nucleus");
				roiManager("Show None");
				if(retry=="no"){//removes user's input and restarts analyse particle
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Nuclei-Mask");
					if (isOpen("Nuclei-Duplicate2")==1){
					selectWindow("Nuclei-Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Nuclei-Duplicate");
					particleN();
						} else{
							if (isOpen("Nuclei-Duplicate2")==1){
							selectWindow("Nuclei-Duplicate");
							close();
							selectWindow("Nuclei-Duplicate2");
							rename("Nuclei-Duplicate");
							}
						}
				}//records user's final input
				lseN = getResult("Nucleus Lower Size Exclusion",nResults-1);
				useN = getResult("Nucleus Upper Size Exclusion",nResults-1);
				lceN = getResult("Nucleus Lower Circularity Exclusion",nResults-1);
				uceN = getResult("Nucleus Upper Circularity Exclusion",nResults-1);
				watershedN = getResult("Nucleus Watershed",nResults-1);
				excludeN = getResult("Nucleus Exclusion",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");//makes measurement
				if(getResult('Area', nResults-1)!=0) {
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
					}
				selectWindow("Nuclei-Duplicate");
				close();
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Threshold No Cyto After Tutorial 008


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				fociNoTutorialNoCyto();//opens foci open

				nameStore1 = getTitle();
				rename("Foci");
				selectWindow("Foci");
				run("Gaussian Blur...");
				sigF = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
				selectWindow("Foci");
				run("Find Maxima...");
				rename("Foci-Points");
				roiManager("Reset");
				max = getNumber("Please enter the value you had\njust entered for the noise tolerance",0);
				if(is("binary")==true){//makes image into single points if it was not selected
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				} else {
					selectWindow("Foci-Points");
					rename("Foci");
					selectWindow("Foci");
					run("Find Maxima...", "output=[Single Points]");
					rename("Foci-Points");
					roiManager("Reset");
					selectWindow("Foci-Points");
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				}
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {//measures total signal
					TotalSignal = roiManager("count");
					roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					} else {
						TotalSignal = 0;
					}
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}			
				run("Close All");
				brC = "NaN";
				btC = "NaN";
				drC = "NaN";
				dtC = "NaN";
				sigC = "NaN";
				LowerCyto = "NaN";
				UpperCyto = "NaN";
				lseC = "NaN";
				useC = "NaN";
				lceC = "NaN";
				uceC = "NaN";
				watershedC = "NaN";
				excludeC = "NaN";
				CytoArea = "NaN";
				AverageCytoArea = "NaN";
				AverageCytoArea = "NaN";
				NonCytoSignal = "NaN";
				CytoSignal = "NaN";
				AverageSignalPerCyto = "NaN";
				PercentCytoSignal = "NaN";
				IntracellularSignal = "NaN";
				ExtracellularSignal = "NaN";
				if(useN==NaN){
					useN = "infinity";
				}
				if(cyto!="NoCyto" && useC == NaN){
					useC = "infinity";
				}
			//prints user's adjustments in results table and adjustment table
			setResult("Nucleus Bright Radius",nResults-1,brN);
			setResult("Nucleus Bright Threshold",nResults-1,btN);	
			setResult("Nucleus Dark Radius",nResults-1,drN);
			setResult("Nucleus Dark Threshold",nResults-1,dtN);	
			setResult("Nucleus Gaussian Blur",nResults-1,sigN);
			setResult("Nucleus Lower Threshold",nResults-1,LowerNuc);
			setResult("Nucleus Upper Threshold",nResults-1,UpperNuc);
			setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
			setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
			setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
			setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
			setResult("Nucleus Watershed",nResults-1,watershedN);
			setResult("Nucleus Exclusion",nResults-1,excludeN);
			setResult("Foci Gaussian Blur",nResults-1,sigF);
			setResult("Foci Maxima Value",nResults-1,max);
			setResult("Lower Cytoplasm",nResults-1,LowerCyto);
			setResult("Upper Cytoplasm",nResults-1,UpperCyto);
			setResult("Cytoplasm Bright Radius",nResults-1,brC);
			setResult("Cytoplasm Bright Threshold",nResults-1,btC);
			setResult("Cytoplasm Dark Radius",nResults-1,drC);
			setResult("Cytoplasm Dark Threshold",nResults-1,dtC);
			setResult("Cytoplasm Gaussian Blur",nResults-1,sigC);
			setResult("Cytoplasm Lower Threshold",nResults-1,LowerCyto);
			setResult("Cytoplasm Upper Threshold",nResults-1,UpperCyto);
			setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
			setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
			setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
			setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
			setResult("Cytoplasm Watershed",nResults-1,watershedC);
			setResult("Cytoplasm Exclusion",nResults-1,excludeC);
			updateResults();
			if(watershedN==1){
				watershedN = "TRUE";
			} else {
				watershedN = "FALSE";
			}
			if(excludeN==1){
				excludeN = "TRUE";
			} else {
				excludeN = "FALSE";
			}
			if(watershedC==1){
				watershedC = "TRUE";
			} else if (watershedC==0) {
				watershedC = "FALSE";
			}
			if(excludeC==1){
				excludeC = "TRUE";
			} else if (excludeC==0){
				excludeC = "FALSE";
			}
			print(tableTitle2, nameStore0 + "\t"  + Thresh + "\t"  + brN + "\t"  + btN + "\t"  + drN + "\t"  + dtN + "\t"  + sigN + "\t"  + LowerNuc + "\t" + UpperNuc + "\t"  + lseN + "\t"  + useN + "\t"  + lceN + "\t"  + uceN + "\t"  + watershedN + "\t"  + excludeN + "\t"  + sigF + "\t"  + max + "\t"  + brC + "\t"  + btC + "\t"  + drC + "\t"  + dtC + "\t"  + sigC + "\t"  + LowerCyto + "\t"  + UpperCyto + "\t"  + lseC + "\t"  + useC + "\t"  + lceC + "\t"  + uceC + "\t"  + watershedC + "\t"  + excludeC);	
			print(tableTitle4, nameStore0 + "\t"  + NucleusCount + "\t"  + NucleiArea + "\t"  + AverageNucleiArea + "\t"  + TotalSignal + "\t"  + NuclearSignal + "\t"  + NonNuclearSignal + "\t"  + PercentNuclearSignal + "\t"  + AverageSignalPerNucleus + "\t"  + CytoArea + "\t"  + AverageCytoArea + "\t"  + CytoSignal + "\t"  + NonCytoSignal + "\t"  + PercentCytoSignal + "\t"  + AverageSignalPerCyto + "\t"  + IntracellularSignal + "\t"  + ExtracellularSignal);
		
		}//end of FOR loop for nuclei and foci
	} else {//adjustment with cytoplasmic images
		for(i=3; i<list.length; i+=3){
			filename = dir + list[i];
			filename2 = dir + list[i+1];
			filename3 = dir + list[i+2];

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Threshold 009


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				nucNoTutorial();//open nuclei images
			function nucNoTutorial(){
				if (matches(filename, ".*"+nuc+".*")){
					open(filename);
				}
				if (matches(filename2, ".*"+nuc+".*")){
					open(filename2);
				}
				if (matches(filename3, ".*"+nuc+".*")){
					open(filename3);
				}	
			}
				nameStore0 = getTitle();
				rename("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				selectWindow("Nuclei-Duplicate");
				run("Duplicate...", "title=Test");
				waitForUser("Test image for nuclei", "A duplicate image has been created to test which parameters are best for removing the background\nin your image. Select preview and try starting with a value of 10 for 'radius' and 50 for 'threshold'\nand try selecting both both 'bright' and 'dark'. If the image shows no background, then the image is\nunaffected by this process.\n \nPut '0' in radius if no modification is required.\n \nOnce you have finished sampling your image, record the values for input later.\n \nClick OK to proceed.");
				selectWindow("Test");
				run("Remove Outliers...");
				selectWindow("Test");
				run("Gaussian Blur...");
				selectWindow("Test");
				close();
				Dialog.create("Removing background and smoothing the edges");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 20);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				selectWindow("Nuclei-Duplicate");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				Dialog.create("Thresholding");
				Dialog.addMessage("Select automatic or manual threshold");
				Dialog.addChoice("", newArray("Automatic", "Manual"));
				Dialog.show();
				Thresh = Dialog.getChoice();
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Huang");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Huang white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Intermodes");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Otsu");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=RenyiEntropy");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=RenyiEntropy white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Intermodes");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("RenyiEntropy");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
					Dialog.show();
					methodN = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Nuclei-Duplicate");
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					LowerNuc = "Auto="+methodN;
					UpperNuc = "NaN";
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(50, 255);
					selectWindow("Nuclei-Duplicate");
					run("Threshold...");
		  			waitForUser("Select for all nuclei using the top slide bar in\nthe Threshold window. Click OK to proceed.");
					getThreshold(LowerNuc,UpperNuc);
					selectWindow("Nuclei-Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				selectWindow("Nuclei-Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				particleN();//analyse particle selection
				function particleN(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				selectWindow("Nuclei-Duplicate");
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Nuclei-Duplicate2");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
				setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
				setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
				setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
				setResult("Nucleus Watershed",nResults-1,watershedN);
				setResult("Nucleus Exclusion",nResults-1,excludeN);
				updateResults();
				selectWindow("Nucleus");
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow("Nucleus");
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts analyse particle
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Nuclei-Mask");
					close();
					if (isOpen("Nuclei-Duplicate2")==1){
					selectWindow("Nuclei-Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Nuclei-Duplicate");
					particleN();
						} else{
							if (isOpen("Nuclei-Duplicate2")==1){
							selectWindow("Nuclei-Duplicate");
							close();
							selectWindow("Nuclei-Duplicate2");
							rename("Nuclei-Duplicate");
							}
						}
				}//records user's final input
				lseN = getResult("Nucleus Lower Size Exclusion",nResults-1);
				useN = getResult("Nucleus Upper Size Exclusion",nResults-1);
				lceN = getResult("Nucleus Lower Circularity Exclusion",nResults-1);
				uceN = getResult("Nucleus Upper Circularity Exclusion",nResults-1);
				watershedN = getResult("Nucleus Watershed",nResults-1);
				excludeN = getResult("Nucleus Exclusion",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");
				if(getResult('Area', nResults-1)!=0) {
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
					}
				selectWindow("Nuclei-Duplicate");
				close();
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Threshold 010


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				fociNoTutorial();//opens foci image
				function fociNoTutorial(){
					if (matches(filename, ".*"+foci+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+foci+".*")){
						open(filename2);
					}
					if (matches(filename3, ".*"+foci+".*")){
						open(filename3);
					}
				}
				nameStore1 = getTitle();
				rename("Foci");
				selectWindow("Foci");
				run("Gaussian Blur...");
				sigF = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
				selectWindow("Foci");
				run("Find Maxima...");
				rename("Foci-Points");
				roiManager("Reset");
				max = getNumber("Please enter the value you had\njust entered for the noise tolerance",0);
					if(is("binary")==true){//makes image into single points if it was not selected
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				} else {
					selectWindow("Foci-Points");
					rename("Foci");
					selectWindow("Foci");
					run("Find Maxima...", "output=[Single Points]");
					rename("Foci-Points");
					roiManager("Reset");
					selectWindow("Foci-Points");
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				}
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {//measures total signal
					TotalSignal = roiManager("count");
					roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					} else {
						TotalSignal = 0;
					}
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Cytoplasm Threshold 011


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				cytoNoTutorial();//opens cytoplasm image
				function cytoNoTutorial(){
					if (matches(filename, ".*"+cyto+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+cyto+".*")){
						open(filename2);
					}	
					if (matches(filename3, ".*"+cyto+".*")){
						open(filename3);
					}
				}
						nameStore2 = getTitle();
						rename("Cytoplasm");
						run("Duplicate...", "title=Cytoplasm-Duplicate");
						run("Enhance Contrast...", "saturated=0.01");
						run("Duplicate...", "title=Test");
						waitForUser("Test image for cytoplasm", "A duplicate image has been created to test which parameters are best for removing the background\nin your image. Select preview and try starting with a value of 10 for 'radius' and 50 for 'threshold'\nand try selecting both both 'bright' and 'dark'. If the image shows no background, then the image is\nunaffected by this process.\n \nPut '0' in radius if no modification is required.\n \nOnce you have finished sampling your image, record the values for input later.\n \nClick OK to proceed."); 
						selectWindow("Test");
						run("Remove Outliers...");
						selectWindow("Test");
						run("Gaussian Blur...");
						selectWindow("Test");
						close();
						Dialog.create("Removing background and smoothing the edges");
						Dialog.addMessage("Please enter the values for removing background:");
						Dialog.addMessage("Bright:");
						Dialog.addNumber("Radius:", 5);
						Dialog.addNumber("Threshold", 50);
						Dialog.addMessage("Dark:");
						Dialog.addNumber("Radius:", 5);
						Dialog.addNumber("Threshold", 20);
						Dialog.addMessage("Gaussian Blur:");
						Dialog.addNumber("Sigma:", 2);
						Dialog.show();
						brC = Dialog.getNumber();
						btC = Dialog.getNumber();
						drC = Dialog.getNumber();
						dtC = Dialog.getNumber();
						sigC = Dialog.getNumber();
						selectWindow("Cytoplasm-Duplicate");
						run("Remove Outliers...","radius=brC threshold=btC which=Bright");
						run("Remove Outliers...","radius=drC threshold=dtC which=Dark");
						run("Gaussian Blur...", "sigma=sigC");
						run("8-bit");
						if (Thresh == "Automatic"){//automatic threshold selection
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Original");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Huang");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Huang white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Intermodes");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Intermodes white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Otsu");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Otsu white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=RenyiEntropy");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=RenyiEntropy white");
							run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
							setSlice(1); 
							setMetadata("Original");
							setSlice(2);
							setMetadata("Huang");
							setSlice(3);
							setMetadata("Intermodes");
							setSlice(4);
							setMetadata("Otsu");
							setSlice(5);
							setMetadata("RenyiEntropy");
							run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
							Dialog.create("Thresholding");
							Dialog.addMessage("Select the automatic method");
							Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
							Dialog.show();
							methodC = Dialog.getChoice();
							selectWindow("Montage");
							close();
							selectWindow("Stacks");
							close();
							selectWindow("Cytoplasm-Duplicate");
								if(methodC=="Huang"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Huang white");
								}
								if(methodC=="Intermodes"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Intermodes white");
								}
								if(methodC=="Otsu"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Otsu white");
								}
								if(methodC=="RenyiEntropy"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=RenyiEntropy white");
								}
							LowerCyto = "Auto="+methodC;
							UpperCyto = "NaN";
							selectWindow("Cytoplasm-Duplicate");
							setThreshold(1, 255);
						} else{//manual threshold
							setAutoThreshold("Default dark");
							run("Threshold...");
							setThreshold(50, 255);
							selectWindow("Cytoplasm-Duplicate");
							run("Threshold...");
							waitForUser("Select for all cytoplasm using the top slide bar in\nthe Threshold window. Click OK to proceed.");
							getThreshold(LowerCyto,UpperCyto);
							setOption("BlackBackground", true);
							run("Convert to Mask");
							setThreshold(1, 255);
						}
						run("Set Measurements...", "area limit redirect=None decimal=3");
						roiManager("Reset");
						run("Measure");
						IJ.deleteRows(nResults-1, nResults-1);
						particleC();//analyse particle selection
						function particleC(){
						Dialog.create("Size and Circularity Exclusion");
						Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
						Dialog.addNumber("Lower size exclusion:", 0);
						Dialog.addString("Upper size exclusion:", "infinity");
						Dialog.addNumber("Lower circularity exclusion:", 0.00);
						Dialog.addNumber("Upper circularity exclusion:", 1.00);
						Dialog.addMessage("Would you like to watershed (segment)\nthe cytoplasm?");
						Dialog.addCheckbox("watershed", false);
						Dialog.addMessage("Would you like to exclude the cytoplasm\nat the edges?");
						Dialog.addCheckbox("exclude", true);
						Dialog.show();
						lseC = Dialog.getNumber();
						useC = Dialog.getString();
						lceC = Dialog.getNumber();
						uceC = Dialog.getNumber();
						watershedC = Dialog.getCheckbox();
						excludeC = Dialog.getCheckbox();
						selectWindow("Cytoplasm-Duplicate");
						if (watershedC == true){
							run("Duplicate...", "title=Cytoplasm-Duplicate2");
							run("Watershed");
						}
						if (excludeC == true){
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks exclude add");
						} else {		
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks add");
						}
						rename("Cytoplasm Mask");
						if(isOpen("Log")==1){
							selectWindow("Log");
							run("Close");
						}
						run("Measure");//records user's input
						setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
						setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
						setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
						setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
						setResult("Cytoplasm Watershed",nResults-1,watershedC);
						setResult("Cytoplasm Exclusion",nResults-1,excludeC);
						updateResults();
						selectWindow("Cytoplasm");
						roiManager("Show All without labels");	
						Dialog.create("Retry exclusion?");
						Dialog.addMessage("Are you happy with the selection?");
						Dialog.addChoice("Type:", newArray("yes", "no"));
						Dialog.show();
						retry = Dialog.getChoice();
						selectWindow("Cytoplasm");
						roiManager("Show None");
						if(retry=="no"){//removes user's inputs and restarts particle analysis
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Cytoplasm Mask");
							close();
							if (isOpen("Cytoplasm-Duplicate2")==1){
							selectWindow("Cytoplasm-Duplicate2");
							close();
							}
							roiManager("Reset");
							selectWindow("Cytoplasm-Duplicate");
							particleC();
								} else{
									if (isOpen("Cytoplasm-Duplicate2")==1){
									selectWindow("Cytoplasm-Duplicate");
									close();
									selectWindow("Cytoplasm-Duplicate2");
									rename("Cytoplasm-Duplicate");
									}
								}
						}//records user's final inputs
						lseC = getResult("Cytoplasm Lower Size Exclusion",nResults-1);
						useC = getResult("Cytoplasm Upper Size Exclusion",nResults-1);
						lceC = getResult("Cytoplasm Lower Circularity Exclusion",nResults-1);
						uceC = getResult("Cytoplasm Upper Circularity Exclusion",nResults-1);
						watershedC = getResult("Cytoplasm Watershed",nResults-1);
						excludeC = getResult("Cytoplasm Exclusion",nResults-1);
						IJ.deleteRows(nResults-1, nResults-1);
						selectWindow("Cytoplasm Mask");
						imageCalculator("Subtract create", "Cytoplasm Mask","Nuclei-Mask");
						rename("Cytoplasm Mask2");
						selectWindow("Cytoplasm Mask");
						close();
						selectWindow("Cytoplasm Mask2");
						rename("Cytoplasm Mask");
						setAutoThreshold("Default dark");
						//run("Threshold...");
						setThreshold(10, 255);
						run("Set Measurements...", "area limit redirect=None decimal=3");
						run("Set Scale...", "distance=0 known=0 unit=pixel");
						run("Measure");//makes measurements
						if(getResult('Area', nResults-1)!=0) {
							CytoArea = getResult('Area', nResults-1);
						} else {
							CytoArea = 0;
						}
						IJ.deleteRows(nResults-1, nResults-1);
						if (roiManager("count")!=0) {
							roiManager("Save",  dir+nameStore2+" - Cytoplasm.zip");
							selectWindow("Cytoplasm Mask");
							saveAs("Tiff", dir+nameStore2+" - Cytoplasm Mask");
							rename("Cytoplasm Mask");
							selectWindow("Cytoplasm");
							roiManager("Show All without labels");	
							roiManager("Set Fill Color", "blue");
							run("Flatten");
							saveAs("Tiff", dir+nameStore2+" - Cytoplasm Overlay");
							close();
							roiManager("Set Color", "yellow");
						} else {
							AverageCytoArea = 0;
						}

			run("Close All");
			if(useN==NaN){
				useN = "infinity";
			}
			if(cyto!="NoCyto" && useC == NaN){
				useC = "infinity";
			}
			//prints user's adjustment in results table and adjustment table
			setResult("Nucleus Bright Radius",nResults-1,brN);
			setResult("Nucleus Bright Threshold",nResults-1,btN);	
			setResult("Nucleus Dark Radius",nResults-1,drN);
			setResult("Nucleus Dark Threshold",nResults-1,dtN);	
			setResult("Nucleus Gaussian Blur",nResults-1,sigN);
			setResult("Nucleus Lower Threshold",nResults-1,LowerNuc);
			setResult("Nucleus Upper Threshold",nResults-1,UpperNuc);
			setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
			setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
			setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
			setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
			setResult("Nucleus Watershed",nResults-1,watershedN);
			setResult("Nucleus Exclusion",nResults-1,excludeN);
			setResult("Foci Gaussian Blur",nResults-1,sigF);
			setResult("Foci Maxima Value",nResults-1,max);
			setResult("Lower Cytoplasm",nResults-1,LowerCyto);
			setResult("Upper Cytoplasm",nResults-1,UpperCyto);
			setResult("Cytoplasm Bright Radius",nResults-1,brC);
			setResult("Cytoplasm Bright Threshold",nResults-1,btC);
			setResult("Cytoplasm Dark Radius",nResults-1,drC);
			setResult("Cytoplasm Dark Threshold",nResults-1,dtC);
			setResult("Cytoplasm Gaussian Blur",nResults-1,sigC);
			setResult("Cytoplasm Lower Threshold",nResults-1,LowerCyto);
			setResult("Cytoplasm Upper Threshold",nResults-1,UpperCyto);
			setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
			setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
			setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
			setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
			setResult("Cytoplasm Watershed",nResults-1,watershedC);
			setResult("Cytoplasm Exclusion",nResults-1,excludeC);
			updateResults();
			if(watershedN==1){
				watershedN = "TRUE";
			} else {
				watershedN = "FALSE";
			}
			if(excludeN==1){
				excludeN = "TRUE";
			} else {
				excludeN = "FALSE";
			}
			if(watershedC==1){
				watershedC = "TRUE";
			} else if (watershedC==0) {
				watershedC = "FALSE";
			}
			if(excludeC==1){
				excludeC = "TRUE";
			} else if (excludeC==0){
				excludeC = "FALSE";
			}
			print(tableTitle2, nameStore0 + "\t"  + Thresh + "\t"  + brN + "\t"  + btN + "\t"  + drN + "\t"  + dtN + "\t"  + sigN + "\t"  + LowerNuc + "\t" + UpperNuc + "\t"  + lseN + "\t"  + useN + "\t"  + lceN + "\t"  + uceN + "\t"  + watershedN + "\t"  + excludeN + "\t"  + sigF + "\t"  + max + "\t"  + brC + "\t"  + btC + "\t"  + drC + "\t"  + dtC + "\t"  + sigC + "\t"  + LowerCyto + "\t"  + UpperCyto + "\t"  + lseC + "\t"  + useC + "\t"  + lceC + "\t"  + uceC + "\t"  + watershedC + "\t"  + excludeC);	
			print(tableTitle4, nameStore0 + "\t"  + NucleusCount + "\t"  + NucleiArea + "\t"  + AverageNucleiArea + "\t"  + TotalSignal + "\t"  + NuclearSignal + "\t"  + NonNuclearSignal + "\t"  + PercentNuclearSignal + "\t"  + AverageSignalPerNucleus + "\t"  + CytoArea + "\t"  + AverageCytoArea + "\t"  + CytoSignal + "\t"  + NonCytoSignal + "\t"  + PercentCytoSignal + "\t"  + AverageSignalPerCyto + "\t"  + IntracellularSignal + "\t"  + ExtracellularSignal);
		
					}//ending of the FOR loop for nuclei, foci, and cytoplasm
	}//ending of the else nuclei, foci, cytoplasm for rest of images in tutorial
		waitForUser("ROI zip file","We have now completed the optimization. An overlay image and an ROI zip file will be saved in the\ntest folder. The zip file is FIJI compatible and permits additional measurements, such as circularity\nor intensity.\n \nThe ROI can be used to overlay onto the original images. To overlay the ROI, open the ROI manager by\ndragging the zip file into Fiji and select ‘Show All’ and ‘Labels’. For additional measurements select\n'Set Measurement' under the 'Analyze' tab on FIJI. Check the boxes for additional measurements desired\nand then return to the ROI manager and click 'Measure'.\n \nClick OK to continue.");
		wait(1);
		waitForUser("Optimization table", "Finally, the table with the optimization parameters will be saved\nas an Excel spreadsheet in the test folder. These parameters will\nbe used in the analysis dialog boxes to analyze your images.\n \nClick OK to continue.");
		if(isOpen("Summary")==1){
		selectWindow("Summary");
		run("Close");
		}
		if(isOpen("ROI Manager")==1){
		selectWindow("ROI Manager");
		run("Close");
		}
		if(isOpen("Threshold")==1){
		selectWindow("Threshold");
		run("Close");
		}
		if(isOpen("Results")==1){//works out average of adjustments
		selectWindow("Results");
		brN_mean=0;
		brN_total=0;
		for (a=0; a<nResults(); a++) {
		    brN_total=brN_total+getResult("Nucleus Bright Radius",a);
		    brN_mean=brN_total/nResults;
		}
		btN_mean=0;
		btN_total=0;
		for (a=0; a<nResults(); a++) {
		    btN_total=btN_total+getResult("Nucleus Bright Threshold",a);
		    btN_mean=btN_total/nResults;
		}
		drN_mean=0;
		drN_total=0;
		for (a=0; a<nResults(); a++) {
		    drN_total=drN_total+getResult("Nucleus Dark Radius",a);
		    drN_mean=drN_total/nResults;
		}
		dtN_mean=0;
		dtN_total=0;
		for (a=0; a<nResults(); a++) {
		    dtN_total=dtN_total+getResult("Nucleus Dark Threshold",a);
		    dtN_mean=dtN_total/nResults;
		}
		sigN_mean=0;
		sigN_total=0;
		for (a=0; a<nResults(); a++) {
		    sigN_total=sigN_total+getResult("Nucleus Gaussian Blur",a);
		    sigN_mean=sigN_total/nResults;
		}
		LN_mean=0;
		LN_total=0;
		for (a=0; a<nResults(); a++) {
		    LN_total=LN_total+getResult("Nucleus Lower Threshold",a);
		    LN_mean=LN_total/nResults;
		}
		if(isNaN(LN_mean)==true){
		LN_mean=methodN;
		}
		UN_mean=0;
		UN_total=0;
		for (a=0; a<nResults(); a++) {
		    UN_total=UN_total+getResult("Nucleus Upper Threshold",a);
		    UN_mean=UN_total/nResults;
		}
		lseN_mean=0;
		lseN_total=0;
		for (a=0; a<nResults(); a++) {
		    lseN_total=lseN_total+getResult("Nucleus Lower Size Exclusion",a);
		    lseN_mean=lseN_total/nResults;
		}
		useN_mean=0;
		useN_total=0;
		for (a=0; a<nResults(); a++) {
		    useN_total=useN_total+getResult("Nucleus Upper Size Exclusion",a);
		    useN_mean=useN_total/nResults;
		}
		if(isNaN(useN_mean)==true){
		useN_mean="infinity";
		}
		lceN_mean=0;
		lceN_total=0;
		for (a=0; a<nResults(); a++) {
		    lceN_total=lceN_total+getResult("Nucleus Lower Circularity Exclusion",a);
		    lceN_mean=lceN_total/nResults;
		}
		uceN_mean=0;
		uceN_total=0;
		for (a=0; a<nResults(); a++) {
		    uceN_total=uceN_total+getResult("Nucleus Upper Circularity Exclusion",a);
		    uceN_mean=uceN_total/nResults;
		}
		sigF_mean=0;
		sigF_total=0;
		for (a=0; a<nResults(); a++) {
		    sigF_total=sigF_total+getResult("Foci Gaussian Blur",a);
		    sigF_mean=sigF_total/nResults;
		}
		max_mean=0;
		max_total=0;
		for (a=0; a<nResults(); a++) {
		    max_total=max_total+getResult("Foci Maxima Value",a);
		    max_mean=max_total/nResults;
		}
		brC_mean=0;
		brC_total=0;
		for (a=0; a<nResults(); a++) {
		    brC_total=brC_total+getResult("Cytoplasm Bright Radius",a);
		    brC_mean=brC_total/nResults;
		}
		btC_mean=0;
		btC_total=0;
		for (a=0; a<nResults(); a++) {
		    btC_total=btC_total+getResult("Cytoplasm Bright Threshold",a);
		    btC_mean=btC_total/nResults;
		}
		drC_mean=0;
		drC_total=0;
		for (a=0; a<nResults(); a++) {
		    drC_total=drC_total+getResult("Cytoplasm Dark Radius",a);
		    drC_mean=drC_total/nResults;
		}
		dtC_mean=0;
		dtC_total=0;
		for (a=0; a<nResults(); a++) {
		    dtC_total=dtC_total+getResult("Cytoplasm Dark Threshold",a);
		    dtC_mean=dtC_total/nResults;
		}
		sigC_mean=0;
		sigC_total=0;
		for (a=0; a<nResults(); a++) {
		    sigC_total=sigC_total+getResult("Cytoplasm Gaussian Blur",a);
		    sigC_mean=sigC_total/nResults;
		}
		LC_mean=0;
		LC_total=0;
		for (a=0; a<nResults(); a++) {
		    LC_total=LC_total+getResult("Cytoplasm Lower Threshold",a);
		    LC_mean=LC_total/nResults;
		}
		if(isNaN(LC_mean)==true){
			if(cyto == "NoCyto"){
				LC_mean="NaN";
			} else{
			LC_mean=methodC;
			}
		}
		UC_mean=0;
		UC_total=0;
		for (a=0; a<nResults(); a++) {
		    UC_total=UC_total+getResult("Cytoplasm Upper Threshold",a);
		    UC_mean=UC_total/nResults;
		}
		lseC_mean=0;
		lseC_total=0;
		for (a=0; a<nResults(); a++) {
		    lseC_total=lseC_total+getResult("Cytoplasm Lower Size Exclusion",a);
		    lseC_mean=lseC_total/nResults;
		}
		useC_mean=0;
		useC_total=0;
		for (a=0; a<nResults(); a++) {
		    useC_total=useC_total+getResult("Cytoplasm Upper Size Exclusion",a);
		    useC_mean=useC_total/nResults;
		}
		if(isNaN(useC_mean)==true){
			if(cyto == "NoCyto"){
				LC_mean="NaN";
			} else{
			useC_mean="infinity";
			}
		}
		lceC_mean=0;
		lceC_total=0;
		for (a=0; a<nResults(); a++) {
		    lceC_total=lceC_total+getResult("Cytoplasm Lower Circularity Exclusion",a);
		    lceC_mean=lceC_total/nResults;
		}
		uceC_mean=0;
		uceC_total=0;
		for (a=0; a<nResults(); a++) {
		    uceC_total=uceC_total+getResult("Cytoplasm Upper Circularity Exclusion",a);
		    uceC_mean=uceC_total/nResults;
		}
		if(watershedN==1){
			watershedN = "TRUE";
		} else {
			watershedN = "FALSE";
		}
		if(excludeN==1){
			excludeN = "TRUE";
		} else {
			excludeN = "FALSE";
		}
		if(watershedC==1){
			watershedC = "TRUE";
		} else {
			watershedC = "FALSE";
		}
		if(excludeC==1){
			excludeC = "TRUE";
		} else {
			excludeC = "FALSE";
		}
		run("Close");
		}//end of IF results table is open
		tableTitle5="PLA Optimization Summary";//creates adjustment summary table and prints out average values
		tableTitle6="["+tableTitle5+"]";
		run("Table...", "name="+tableTitle6+" width=400 height=620");
		print(tableTitle6,"Threshold = "+Thresh);
		print(tableTitle6,"Average Nucleus Bright Radius = "+brN_mean);
		print(tableTitle6,"Average Nucleus Bright Threshold = "+btN_mean);
		print(tableTitle6,"Average Nucleus Dark Radius = "+drN_mean);
		print(tableTitle6,"Average Nucleus Dark Threshold = "+dtN_mean);
		print(tableTitle6,"Average Nucleus Gaussian Blur = "+sigN_mean);
		print(tableTitle6,"Average Nucleus Lower Threshold = "+LN_mean);
		print(tableTitle6,"Average Nucleus Upper Threshold = "+UN_mean);
		print(tableTitle6,"Average Nucleus Lower Size Exclusion = "+lseN_mean);
		print(tableTitle6,"Average Nucleus Upper Size Exclusion = "+useN_mean);
		print(tableTitle6,"Average Nucleus Lower Circularity Exclusion = "+lceN_mean);
		print(tableTitle6,"Average Nucleus Upper Cirularity Exclusion = "+uceN_mean);
		print(tableTitle6,"Nucleus Watershed = "+watershedN);
		print(tableTitle6,"Nucleus Edge Exclusion = "+excludeN);
		print(tableTitle6,"Average Foci Gaussian Blur = "+sigF_mean);
		print(tableTitle6,"Average Foci Maxima Value = "+max_mean);
		print(tableTitle6,"Average Cytoplasm Bright Radius = "+brC_mean);
		print(tableTitle6,"Average Cytoplasm Bright Threshold = "+btC_mean);
		print(tableTitle6,"Average Cytoplasm Dark Radius = "+drC_mean);
		print(tableTitle6,"Average Cytoplasm Dark Threshold = "+dtC_mean);
		print(tableTitle6,"Average Cytoplasm Gaussian Blur = "+sigC_mean);
		print(tableTitle6,"Average Cytoplasm Lower Threshold = "+LC_mean);
		print(tableTitle6,"Average Cytoplasm Upper Threshold = "+UC_mean);
		print(tableTitle6,"Average Cytoplasm Lower Size Exclusion = "+lseC_mean);
		print(tableTitle6,"Average Cytoplasm Upper Size Exclusion = "+useC_mean);
		print(tableTitle6,"Average Cytoplasm Lower Circularity Exclusion = "+lceC_mean);
		print(tableTitle6,"Average Cytoplasm Upper Cirularity Exclusion = "+uceC_mean);
		print(tableTitle6,"Cytoplasm Watershed = "+watershedC);
		print(tableTitle6,"Cytoplasm Edge Exclusion = "+excludeC);
		print(tableTitle2, "Average" + "\t" + Thresh + "\t" + brN_mean + "\t" + btN_mean + "\t" + drN_mean + "\t" + dtN_mean + "\t" + sigN_mean + "\t"  + LN_mean + "\t" + UN_mean + "\t" + lseN_mean + "\t" + useN_mean + "\t" + lceN_mean + "\t" + uceN_mean + "\t"  + watershedN + "\t"  + excludeN + "\t"  + sigF + "\t"  + max_mean+ "\t" + brC_mean + "\t" + btC_mean + "\t" + drC_mean + "\t" + dtC_mean + "\t" + sigC_mean + "\t"  + LC_mean + "\t" + UC_mean + "\t" + lseC_mean + "\t" + useC_mean + "\t" + lceC_mean + "\t" + uceC_mean + "\t"  + watershedC + "\t"  + excludeC);
		print(tableTitle2, " ");
		print(tableTitle2, "PLA Optimization" + "\t" + "Optimization");
		print(tableTitle2, "Threshold" + "\t" + Thresh);
		print(tableTitle2, "Average Nucleus Bright Radius" + "\t" + brN_mean);
		print(tableTitle2, "Average Nucleus Bright Threshold" + "\t" + btN_mean);
		print(tableTitle2, "Average Nucleus Dark Radius" + "\t" + drN_mean);
		print(tableTitle2, "Average Nucleus Dark Threshold" + "\t" + dtN_mean);
		print(tableTitle2, "Average Nucleus Gaussian Blur" + "\t" + sigN_mean);
		print(tableTitle2, "Average Nucleus Lower Threshold" + "\t" + LN_mean);
		print(tableTitle2, "Average Nucleus Upper Threshold" + "\t" + UN_mean);
		print(tableTitle2, "Average Nucleus Lower Size Exclusion" + "\t" + lseN_mean);
		print(tableTitle2, "Average Nucleus Upper Size Exclusion" + "\t" + useN_mean);
		print(tableTitle2, "Average Nucleus Lower Circularity Exclusion" + "\t" + lceN_mean);
		print(tableTitle2, "Average Nucleus Upper Circularity Exclusion" + "\t" + lceN_mean);
		print(tableTitle2, "Nucleus Watershed" + "\t" + watershedN);
		print(tableTitle2, "Nucleus Edge Exclusion" + "\t" + excludeN);
		print(tableTitle2, "Average Foci Gaussian Blur" + "\t" + sigF_mean);
		print(tableTitle2, "Average Foci Maxima Value" + "\t" + max_mean);
		print(tableTitle2, "Average Cytoplasm Bright Radius" + "\t" + brC_mean);
		print(tableTitle2, "Average Cytoplasm Bright Threshold" + "\t" + btC_mean);
		print(tableTitle2, "Average Cytoplasm Dark Radius" + "\t" + drC_mean);
		print(tableTitle2, "Average Cytoplasm Dark Threshold" + "\t" + dtC_mean);
		print(tableTitle2, "Average Cytoplasm Gaussian Blur" + "\t" + sigC_mean);
		print(tableTitle2, "Average Cytoplasm Lower Threshold" + "\t" + LC_mean);
		print(tableTitle2, "Average Cytoplasm Upper Threshold" + "\t" + UC_mean);
		print(tableTitle2, "Average Cytoplasm Lower Size Exclusion" + "\t" + lseC_mean);
		print(tableTitle2, "Average Cytoplasm Upper Size Exclusion" + "\t" + useC_mean);
		print(tableTitle2, "Average Cytoplasm Lower Circularity Exclusion" + "\t" + lceC_mean);
		print(tableTitle2, "Average Cytoplasm Upper Circularity Exclusion" + "\t" + lceC_mean);
		print(tableTitle2, "Cytoplasm Watershed" + "\t" + watershedC);
		print(tableTitle2, "Cytoplasm Edge Exclusion" + "\t" + excludeC);	
		if(isOpen("PLA Optimization")==1){
		selectWindow("PLA Optimization");
		saveAs("Results",  dir+tableTitle+".xls");
		selectWindow("PLA Optimization");
		run("Close");
		}
		if(isOpen("PLA Optimization Summary")==1){
		selectWindow("PLA Optimization Summary");
		}
		waitForUser("Analyze your images", "Use the 'PLA Optimization Summary' table to analyze your images.\n \nIf you are not happy with the optimization, you can repeat it by selecting\n‘Exit the macro and redo the optimization’ and then restarting the macro.\n \nClick OK to start the analysis.");
		ana = "Start the analysis with current settings";
		finish = "Exit the macro and redo the optimization";
		Dialog.create("Next step");
		Dialog.addMessage("What would you like to do now?");
		Dialog.addChoice("Type:", newArray(ana, finish));
		Dialog.show();
		third = Dialog.getChoice();
		if(third == ana){
			waitForUser("Analysis section","Welcome to image analysis. This section will prompt you to input the\nparameters for image analysis. Once the analysis begins, no further\nuser input is required until it is complete.\n \nGood luck!");
			Analysis();
		}
		if(third == finish){
			exit("If you want to restart the optimization, please remove all new files created in the test folder\nand restart this macro.\n \nNote: A quick way to delete everything that was created is to sort your folder by the\ncreated/modified date and select all new files and delete.\n \nClick OK to finish.");
		}
}//ending of the tutorial







/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
PLA Unit Optimization 012
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/


if(first == no){
	
adj = "Optimization and image analysis";
ana = "Image analysis only";
Dialog.create("Greetings");
Dialog.addMessage("What would you like to do?");
Dialog.addChoice("Type:", newArray(adj, ana));
Dialog.show();
second = Dialog.getChoice();
if(second == adj){
	waitForUser("Create and select optimization folder","Create a folder and copy 3-5 sets of PLA images representative\nfrom the folder that you want to analyze. This folder will be\nused to optimize the image analysis parameters.\n \nClick OK when you are finished to select the folder containing\nthe sample images for optimization.");
	dir = getDirectory("Select Optimization Folder");
	list = getFileList(dir);
	Array.sort(list);
	Dialog.create("Channel names");
	Dialog.addMessage("Please type in the unique name for (case sensitive):");
	Dialog.addString("Nuclei", "");
	Dialog.addString("Foci", "");
	Dialog.addString("Cytoplasm", "NoCyto");
	Dialog.addMessage("Note: If there are no cytoplasmic images,\nplease leave as NoCyto.");
	Dialog.show();
	nuc = Dialog.getString();
	foci = Dialog.getString();
	cyto = Dialog.getString();
		if (cyto == "NoCyto"){
		check = list.length/2;
		error= round(check);
		if(error!=check){
			Dialog.create("Error: Number of files in directory");
			Dialog.addMessage("ERROR: Please ensure that there are complete PLA sets in your analysis folder.");
			Dialog.addMessage("Remove any other files or folders that may be in the analysis folder or");
			Dialog.addMessage("an error will occur at the end of the analysis.");
			Dialog.addMessage("Click 'Cancel' to exit analysis or 'OK' to proceed with the analysis");
			Dialog.show();
			
		}
	} else {
		check = list.length/3;
		error= round(check);
		if(error!=check){
			Dialog.create("Error: Number of files in directory");
			Dialog.addMessage("ERROR: Please ensure that there are complete PLA sets in your analysis folder.");
			Dialog.addMessage("Remove any other files or folders that may be in the analysis folder or");
			Dialog.addMessage("an error will occur at the end of the analysis.");
			Dialog.addMessage("Click 'Cancel' to exit analysis or 'OK' to proceed with the analysis");
			Dialog.show();
	}
	}
	tableTitle="PLA Optimization";
	tableTitle2="["+tableTitle+"]";
	run("Table...", "name="+tableTitle2+" width=400 height=250");
	print(tableTitle2,"\\Headings:Image name\tThreshold\tNucleus Bright Radius\tNucleus Bright Threshold\tNucleus Dark Radius\tNucleus Dark Threshold\tNucleus Gaussian Blur\tNucleus Lower Threshold\tNucleus Upper Threshold\tNucleus Lower Size Exclusion\tNucleus Upper Size Exclusion\tNucleus Lower Circularity Exclusion\tNucleus Upper Circularity Exclusion\tNucleus Watershed\tNucleus Edge Exclusion\tFoci Gaussian Blur\tFoci Maxima Value\tCytoplasm Bright Radius\tCytoplasm Bright Threshold\tCytoplasm Dark Radius\tCytoplasm Dark Threshold\tCytoplasm Gaussian Blur\tCytoplasm Lower Threshold\tCytoplasm Upper Threshold\tCytoplasm Lower Size Exclusion\tCytoplasm Upper Size Exclusion\tCytoplasm Lower Circularity Exclusion\tCytoplasm Upper Circularity Exclusion\tCytoplasm Watershed\tCytoplasm Edge Exclusion");		
	if (cyto == "NoCyto"){//adjustment for no cytoplasmic images
		for(i=0; i<list.length; i+=2){
			filename = dir + list[i];
			filename2 = dir + list[i+1];
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Threshold No Cytoplasm 013


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
			nucNoTutorialNoCyto();//opens nuclei images

			function nucNoTutorialNoCyto(){
				if (matches(filename, ".*"+nuc+".*")){
					open(filename);
				}
				if (matches(filename2, ".*"+nuc+".*")){
					open(filename2);
				}	
			}
				nameStore0 = getTitle();
				rename("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				selectWindow("Nuclei-Duplicate");
				run("Duplicate...", "title=Test");
				waitForUser("Test image for nuclei", "A duplicate image has been created to test which parameters are best for removing the background\nin your image. Select preview and try starting with a value of 10 for 'radius' and 50 for 'threshold'\nand try selecting both both 'bright' and 'dark'. If the image shows no background, then the image is\nunaffected by this process.\n \nPut '0' in radius if no modification is required.\n \nOnce you have finished sampling your image, record the values for input later.\n \nClick OK to proceed.");
				selectWindow("Test");
				run("Remove Outliers...");
				selectWindow("Test");
				run("Gaussian Blur...");
				selectWindow("Test");
				close();
				Dialog.create("Removing background and smoothing the edges");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 20);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				selectWindow("Nuclei-Duplicate");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				Dialog.create("Thresholding");
				Dialog.addMessage("Select automatic or manual threshold");
				Dialog.addChoice("", newArray("Automatic", "Manual"));
				Dialog.show();
				Thresh = Dialog.getChoice();
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Huang");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Huang white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Intermodes");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Otsu");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=RenyiEntropy");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=RenyiEntropy white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Intermodes");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("RenyiEntropy");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
					Dialog.show();
					methodN = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Nuclei-Duplicate");
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					LowerNuc = "Auto="+methodN;
					UpperNuc = "NaN";
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(50, 255);
					selectWindow("Nuclei-Duplicate");
					run("Threshold...");
		  			waitForUser("Select for all nuclei using the top slide bar in\nthe Threshold window. Click OK to proceed.");
					getThreshold(LowerNuc,UpperNuc);
					selectWindow("Nuclei-Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				selectWindow("Nuclei-Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				particleN();//analyse particle selection
				function particleN(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				selectWindow("Nuclei-Duplicate");
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Nuclei-Duplicate2");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
				setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
				setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
				setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
				setResult("Nucleus Watershed",nResults-1,watershedN);
				setResult("Nucleus Exclusion",nResults-1,excludeN);
				updateResults();
				selectWindow("Nucleus");
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow("Nucleus");
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Nuclei-Mask");
					close();
					if (isOpen("Nuclei-Duplicate2")==1){
					selectWindow("Nuclei-Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Nuclei-Duplicate");
					particleN();
						} else{
							if (isOpen("Nuclei-Duplicate2")==1){
							selectWindow("Nuclei-Duplicate");
							close();
							selectWindow("Nuclei-Duplicate2");
							rename("Nuclei-Duplicate");
							}
						}
				}
				//records user's final input
				lseN = getResult("Nucleus Lower Size Exclusion",nResults-1);
				useN = getResult("Nucleus Upper Size Exclusion",nResults-1);
				lceN = getResult("Nucleus Lower Circularity Exclusion",nResults-1);
				uceN = getResult("Nucleus Upper Circularity Exclusion",nResults-1);
				watershedN = getResult("Nucleus Watershed",nResults-1);
				excludeN = getResult("Nucleus Exclusion",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");//makes measurements
				if(getResult('Area', nResults-1)!=0) {
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
					}
				selectWindow("Nuclei-Duplicate");
				close();

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Threshold No Cytoplasm 014


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/

				fociNoTutorialNoCyto();//opens foci image
				
				function fociNoTutorialNoCyto(){
					if (matches(filename, ".*"+foci+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+foci+".*")){
						open(filename2);
					}	
				}

				nameStore1 = getTitle();
				rename("Foci");
				selectWindow("Foci");
				run("Gaussian Blur...");
				sigF = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
				selectWindow("Foci");
				run("Find Maxima...");
				rename("Foci-Points");
				roiManager("Reset");
				max = getNumber("Please enter the value you had\njust entered for the noise tolerance",0);
				if(is("binary")==true){//makes image into single points if it was not selected
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				} else {
					selectWindow("Foci-Points");
					rename("Foci");
					selectWindow("Foci");
					run("Find Maxima...", "output=[Single Points]");
					rename("Foci-Points");
					roiManager("Reset");
					selectWindow("Foci-Points");
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				}
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {//measures total signal
					TotalSignal = roiManager("count");
					roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					} else {
						TotalSignal = 0;
					}
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}
				run("Close All");
				brC = "NaN";
				btC = "NaN";
				drC = "NaN";
				dtC = "NaN";
				sigC = "NaN";
				LowerCyto = "NaN";
				UpperCyto = "NaN";
				lseC = "NaN";
				useC = "NaN";
				lceC = "NaN";
				uceC = "NaN";
				watershedC = "NaN";
				excludeC = "NaN";
				CytoArea = "NaN";
				AverageCytoArea = "NaN";
				AverageCytoArea = "NaN";
				NonCytoSignal = "NaN";
				CytoSignal = "NaN";
				AverageSignalPerCyto = "NaN";
				PercentCytoSignal = "NaN";
				IntracellularSignal = "NaN";
				ExtracellularSignal = "NaN";

				if(useN==NaN){
					useN = "infinity";
				}
				if(cyto!="NoCyto" && useC == NaN){
					useC = "infinity";
				}
				//prints user's adjustment in results table and adjustment table
				setResult("Nucleus Bright Radius",nResults-1,brN);
				setResult("Nucleus Bright Threshold",nResults-1,btN);	
				setResult("Nucleus Dark Radius",nResults-1,drN);
				setResult("Nucleus Dark Threshold",nResults-1,dtN);	
				setResult("Nucleus Gaussian Blur",nResults-1,sigN);
				setResult("Nucleus Lower Threshold",nResults-1,LowerNuc);
				setResult("Nucleus Upper Threshold",nResults-1,UpperNuc);
				setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
				setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
				setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
				setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
				setResult("Nucleus Watershed",nResults-1,watershedN);
				setResult("Nucleus Exclusion",nResults-1,excludeN);
				setResult("Foci Gaussian Blur",nResults-1,sigF);
				setResult("Foci Maxima Value",nResults-1,max);
				setResult("Cytoplasm Bright Radius",nResults-1,brC);
				setResult("Cytoplasm Bright Threshold",nResults-1,btC);
				setResult("Cytoplasm Dark Radius",nResults-1,drC);
				setResult("Cytoplasm Dark Threshold",nResults-1,dtC);
				setResult("Cytoplasm Gaussian Blur",nResults-1,sigC);
				setResult("Cytoplasm Lower Threshold",nResults-1,LowerCyto);
				setResult("Cytoplasm Upper Threshold",nResults-1,UpperCyto);
				setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
				setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
				setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
				setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
				setResult("Cytoplasm Watershed",nResults-1,watershedC);
				setResult("Cytoplasm Exclusion",nResults-1,excludeC);
				updateResults();
				if(watershedN==1){
					watershedN = "TRUE";
				} else {
					watershedN = "FALSE";
				}
				if(excludeN==1){
					excludeN = "TRUE";
				} else {
					excludeN = "FALSE";
				}
				if(watershedC==1){
					watershedC = "TRUE";
				} else if (watershedC==0) {
					watershedC = "FALSE";
				}
				if(excludeC==1){
					excludeC = "TRUE";
				} else if (excludeC==0){
					excludeC = "FALSE";
				}
				print(tableTitle2, nameStore0 + "\t"  + Thresh + "\t"  + brN + "\t"  + btN + "\t"  + drN + "\t"  + dtN + "\t"  + sigN + "\t"  + LowerNuc + "\t" + UpperNuc + "\t"  + lseN + "\t"  + useN + "\t"  + lceN + "\t"  + uceN + "\t"  + watershedN + "\t"  + excludeN + "\t"  + sigF + "\t"  + max + "\t"  + brC + "\t"  + btC + "\t"  + drC + "\t"  + dtC + "\t"  + sigC + "\t"  + LowerCyto + "\t"  + UpperCyto + "\t"  + lseC + "\t"  + useC + "\t"  + lceC + "\t"  + uceC + "\t"  + watershedC + "\t"  + excludeC);	
		}
	} else {//adjustment with cytoplasmic image
		for(i=0; i<list.length; i+=3){
			filename = dir + list[i];
			filename2 = dir + list[i+1];
			filename3 = dir + list[i+2];
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Threshold 015


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
			nucNoTutorial();//opens nuclei image
			function nucNoTutorial(){
				if (matches(filename, ".*"+nuc+".*")){
					open(filename);
				}
				if (matches(filename2, ".*"+nuc+".*")){
					open(filename2);
				}
				if (matches(filename3, ".*"+nuc+".*")){
					open(filename3);
				}	
			}
				nameStore0 = getTitle();
				rename("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				selectWindow("Nuclei-Duplicate");
				run("Duplicate...", "title=Test");
				waitForUser("Test image for nuclei", "A duplicate image has been created to test which parameters are best for removing the background\nin your image. Select preview and try starting with a value of 10 for 'radius' and 50 for 'threshold'\nand try selecting both both 'bright' and 'dark'. If the image shows no background, then the image is\nunaffected by this process.\n \nPut '0' in radius if no modification is required.\n \nOnce you have finished sampling your image, record the values for input later.\n \nClick OK to proceed.");
				selectWindow("Test");
				run("Remove Outliers...");
				selectWindow("Test");
				run("Gaussian Blur...");
				selectWindow("Test");
				close();
				Dialog.create("Removing background and smoothing the edges");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 20);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				selectWindow("Nuclei-Duplicate");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				Dialog.create("Thresholding");
				Dialog.addMessage("Select automatic or manual threshold");
				Dialog.addChoice("", newArray("Automatic", "Manual"));
				Dialog.show();
				Thresh = Dialog.getChoice();
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Huang");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Huang white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Intermodes");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Otsu");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=RenyiEntropy");
					setOption("BlackBackground", true);
					run("Auto Threshold", "method=RenyiEntropy white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Intermodes");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("RenyiEntropy");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
					Dialog.show();
					methodN = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Nuclei-Duplicate");
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					LowerNuc = "Auto="+methodN;
					UpperNuc = "NaN";
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(50, 255);
					selectWindow("Nuclei-Duplicate");
					run("Threshold...");
		  			waitForUser("Select for all nuclei using the top slide bar in\nthe Threshold window. Click OK to proceed.");
					getThreshold(LowerNuc,UpperNuc);
					selectWindow("Nuclei-Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				selectWindow("Nuclei-Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				particleN();//particle analysis selection
				function particleN(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				selectWindow("Nuclei-Duplicate");
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Duplicate...", "title=Nuclei-Duplicate2");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
				setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
				setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
				setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
				setResult("Nucleus Watershed",nResults-1,watershedN);
				setResult("Nucleus Exclusion",nResults-1,excludeN);
				updateResults();
				selectWindow("Nucleus");
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow("Nucleus");
				roiManager("Show None");
				if(retry=="no"){//remove user's input and restarts particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Nuclei-Mask");
					close();
					if (isOpen("Nuclei-Duplicate2")==1){
					selectWindow("Nuclei-Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Nuclei-Duplicate");
					particleN();
						} else{
							if (isOpen("Nuclei-Duplicate2")==1){
							selectWindow("Nuclei-Duplicate");
							close();
							selectWindow("Nuclei-Duplicate2");
							rename("Nuclei-Duplicate");
							}
						}
				}
				//records user's final input
				lseN = getResult("Nucleus Lower Size Exclusion",nResults-1);
				useN = getResult("Nucleus Upper Size Exclusion",nResults-1);
				lceN = getResult("Nucleus Lower Circularity Exclusion",nResults-1);
				uceN = getResult("Nucleus Upper Circularity Exclusion",nResults-1);
				watershedN = getResult("Nucleus Watershed",nResults-1);
				excludeN = getResult("Nucleus Exclusion",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");
				if(getResult('Area', nResults-1)!=0) {//make measurements
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
					}
				selectWindow("Nuclei-Duplicate");
				close();
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Threshold 016


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				fociNoTutorial();//opens foci image
				function fociNoTutorial(){
					if (matches(filename, ".*"+foci+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+foci+".*")){
						open(filename2);
					}
					if (matches(filename3, ".*"+foci+".*")){
						open(filename3);
					}
				}
				nameStore1 = getTitle();
				rename("Foci");
				selectWindow("Foci");
				run("Gaussian Blur...");
				sigF = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
				selectWindow("Foci");
				run("Find Maxima...");
				rename("Foci-Points");
				roiManager("Reset");
				max = getNumber("Please enter the value you had\njust entered for the noise tolerance",0);
				if(is("binary")==true){
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				} else {//makes image into single points if it was not selected
					selectWindow("Foci-Points");
					rename("Foci");
					selectWindow("Foci");
					run("Find Maxima...", "output=[Single Points]");
					rename("Foci-Points");
					roiManager("Reset");
					selectWindow("Foci-Points");
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
				}
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {//measures total signal
					TotalSignal = roiManager("count");
					roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					} else {
						TotalSignal = 0;
					}
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Cytoplasm Threshold 017


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				cytoNoTutorial();//opens cytoplasm image
				function cytoNoTutorial(){
					if (matches(filename, ".*"+cyto+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+cyto+".*")){
						open(filename2);
					}	
					if (matches(filename3, ".*"+cyto+".*")){
						open(filename3);
					}
				}
						nameStore2 = getTitle();
						rename("Cytoplasm");
						run("Duplicate...", "title=Cytoplasm-Duplicate");
						run("Enhance Contrast...", "saturated=0.01");
						run("Duplicate...", "title=Test");
						waitForUser("Test image for cytoplasm", "A duplicate image has been created to test which parameters are best for removing the background\nin your image. Select preview and try starting with a value of 10 for 'radius' and 50 for 'threshold'\nand try selecting both both 'bright' and 'dark'. If the image shows no background, then the image is\nunaffected by this process.\n \nPut '0' in radius if no modification is required.\n \nOnce you have finished sampling your image, record the values for input later.\n \nClick OK to proceed."); 
						selectWindow("Test");
						run("Remove Outliers...");
						selectWindow("Test");
						run("Gaussian Blur...");
						selectWindow("Test");
						close();
						Dialog.create("Removing background and smoothing the edges");
						Dialog.addMessage("Please enter the values for removing background:");
						Dialog.addMessage("Bright:");
						Dialog.addNumber("Radius:", 5);
						Dialog.addNumber("Threshold", 50);
						Dialog.addMessage("Dark:");
						Dialog.addNumber("Radius:", 5);
						Dialog.addNumber("Threshold", 20);
						Dialog.addMessage("Gaussian Blur:");
						Dialog.addNumber("Sigma:", 2);
						Dialog.show();
						brC = Dialog.getNumber();
						btC = Dialog.getNumber();
						drC = Dialog.getNumber();
						dtC = Dialog.getNumber();
						sigC = Dialog.getNumber();
						selectWindow("Cytoplasm-Duplicate");
						run("Remove Outliers...","radius=brC threshold=btC which=Bright");
						run("Remove Outliers...","radius=drC threshold=dtC which=Dark");
						run("Gaussian Blur...", "sigma=sigC");
						run("8-bit");
						if (Thresh == "Automatic"){//automatic threshold selection
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Original");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Huang");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Huang white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Intermodes");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Intermodes white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=Otsu");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Otsu white");
							selectWindow("Cytoplasm-Duplicate");
							run("Duplicate...", "title=RenyiEntropy");
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=RenyiEntropy white");
							run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Intermodes image4=Otsu image5=RenyiEntropy");
							setSlice(1); 
							setMetadata("Original");
							setSlice(2);
							setMetadata("Huang");
							setSlice(3);
							setMetadata("Intermodes");
							setSlice(4);
							setMetadata("Otsu");
							setSlice(5);
							setMetadata("RenyiEntropy");
							run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=5 increment=1 border=0 font=50 label");
							Dialog.create("Thresholding");
							Dialog.addMessage("Select the automatic method");
							Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
							Dialog.show();
							methodC = Dialog.getChoice();
							selectWindow("Montage");
							close();
							selectWindow("Stacks");
							close();
							selectWindow("Cytoplasm-Duplicate");
								if(methodC=="Huang"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Huang white");
								}
								if(methodC=="Intermodes"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Intermodes white");
								}
								if(methodC=="Otsu"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=Otsu white");
								}
								if(methodC=="RenyiEntropy"){
									setOption("BlackBackground", true);
									run("Auto Threshold", "method=RenyiEntropy white");
								}
							LowerCyto = "Auto="+methodC;
							UpperCyto = "NaN";
							selectWindow("Cytoplasm-Duplicate");
							setThreshold(1, 255);
						} else{//manual threshold
							setAutoThreshold("Default dark");
							run("Threshold...");
							setThreshold(50, 255);
							selectWindow("Cytoplasm-Duplicate");
							run("Threshold...");
							waitForUser("Select for all cytoplasm using the top slide bar in\nthe Threshold window. Click OK to proceed.");
							getThreshold(LowerCyto,UpperCyto);
							setOption("BlackBackground", true);
							run("Convert to Mask");
							setThreshold(1, 255);
						}
						run("Set Measurements...", "area limit redirect=None decimal=3");
						roiManager("Reset");
						run("Measure");
						IJ.deleteRows(nResults-1, nResults-1);
						particleC();//particle analysis selection
						function particleC(){
						Dialog.create("Size and Circularity Exclusion");
						Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
						Dialog.addNumber("Lower size exclusion:", 0);
						Dialog.addString("Upper size exclusion:", "infinity");
						Dialog.addNumber("Lower circularity exclusion:", 0.00);
						Dialog.addNumber("Upper circularity exclusion:", 1.00);
						Dialog.addMessage("Would you like to watershed (segment)\nthe cytoplasm?");
						Dialog.addCheckbox("watershed", false);
						Dialog.addMessage("Would you like to exclude the cytoplasm\nat the edges?");
						Dialog.addCheckbox("exclude", true);
						Dialog.show();
						lseC = Dialog.getNumber();
						useC = Dialog.getString();
						lceC = Dialog.getNumber();
						uceC = Dialog.getNumber();
						watershedC = Dialog.getCheckbox();
						excludeC = Dialog.getCheckbox();
						selectWindow("Cytoplasm-Duplicate");
						if (watershedC == true){
							run("Duplicate...", "title=Cytoplasm-Duplicate2");
							run("Watershed");
						}
						if (excludeC == true){
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks exclude add");
						} else {		
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks add");
						}
						rename("Cytoplasm Mask");
						if(isOpen("Log")==1){
							selectWindow("Log");
							run("Close");
						}
						run("Measure");//records user's input
						setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
						setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
						setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
						setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
						setResult("Cytoplasm Watershed",nResults-1,watershedC);
						setResult("Cytoplasm Exclusion",nResults-1,excludeC);
						updateResults();
						selectWindow("Cytoplasm");
						roiManager("Show All without labels");	
						Dialog.create("Retry exclusion?");
						Dialog.addMessage("Are you happy with the selection?");
						Dialog.addChoice("Type:", newArray("yes", "no"));
						Dialog.show();
						retry = Dialog.getChoice();
						selectWindow("Cytoplasm");
						roiManager("Show None");
						if(retry=="no"){//removes user's input and restarts particle analysis
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Cytoplasm Mask");
							close();
							if (isOpen("Cytoplasm-Duplicate2")==1){
							selectWindow("Cytoplasm-Duplicate2");
							close();
							}
							roiManager("Reset");
							selectWindow("Cytoplasm-Duplicate");
							particleC();
								} else{
									if (isOpen("Cytoplasm-Duplicate2")==1){
									selectWindow("Cytoplasm-Duplicate");
									close();
									selectWindow("Cytoplasm-Duplicate2");
									rename("Cytoplasm-Duplicate");
									}
								}
						}
						//records user's input
						lseC = getResult("Cytoplasm Lower Size Exclusion",nResults-1);
						useC = getResult("Cytoplasm Upper Size Exclusion",nResults-1);
						lceC = getResult("Cytoplasm Lower Circularity Exclusion",nResults-1);
						uceC = getResult("Cytoplasm Upper Circularity Exclusion",nResults-1);
						watershedC = getResult("Cytoplasm Watershed",nResults-1);
						excludeC = getResult("Cytoplasm Exclusion",nResults-1);
						IJ.deleteRows(nResults-1, nResults-1);
						selectWindow("Cytoplasm Mask");
						imageCalculator("Subtract create", "Cytoplasm Mask","Nuclei-Mask");
						rename("Cytoplasm Mask2");
						selectWindow("Cytoplasm Mask");
						close();
						selectWindow("Cytoplasm Mask2");
						rename("Cytoplasm Mask");
						setAutoThreshold("Default dark");
						//run("Threshold...");
						setThreshold(10, 255);
						run("Set Measurements...", "area limit redirect=None decimal=3");
						run("Set Scale...", "distance=0 known=0 unit=pixel");
						run("Measure");
						if(getResult('Area', nResults-1)!=0) {
							CytoArea = getResult('Area', nResults-1);
						} else {
							CytoArea = 0;
						}
						IJ.deleteRows(nResults-1, nResults-1);
						if (roiManager("count")!=0) {
							roiManager("Save",  dir+nameStore2+" - Cytoplasm.zip");
							selectWindow("Cytoplasm Mask");
							saveAs("Tiff", dir+nameStore2+" - Cytoplasm Mask");
							rename("Cytoplasm Mask");
							selectWindow("Cytoplasm");
							roiManager("Show All without labels");	
							roiManager("Set Fill Color", "blue");
							run("Flatten");
							saveAs("Tiff", dir+nameStore2+" - Cytoplasm Overlay");
							close();
							roiManager("Set Color", "yellow");
						} else {
							AverageCytoArea = 0;
						}
						run("Close All");
						if(isOpen("ROI Manager")==1){
						selectWindow("ROI Manager");
						run("Close");
						}
						if(useN==NaN){
							useN = "infinity";
						}
						if(cyto!="NoCyto" && useC == NaN){
							useC = "infinity";
						}
						//prints user's adjustment in results table and adjustment table
						setResult("Nucleus Bright Radius",nResults-1,brN);
						setResult("Nucleus Bright Threshold",nResults-1,btN);	
						setResult("Nucleus Dark Radius",nResults-1,drN);
						setResult("Nucleus Dark Threshold",nResults-1,dtN);	
						setResult("Nucleus Gaussian Blur",nResults-1,sigN);
						setResult("Nucleus Lower Threshold",nResults-1,LowerNuc);
						setResult("Nucleus Upper Threshold",nResults-1,UpperNuc);
						setResult("Nucleus Lower Size Exclusion",nResults-1,lseN);
						setResult("Nucleus Upper Size Exclusion",nResults-1,useN);
						setResult("Nucleus Lower Circularity Exclusion",nResults-1,lceN);
						setResult("Nucleus Upper Circularity Exclusion",nResults-1,uceN);
						setResult("Nucleus Watershed",nResults-1,watershedN);
						setResult("Nucleus Exclusion",nResults-1,excludeN);
						setResult("Foci Gaussian Blur",nResults-1,sigF);
						setResult("Foci Maxima Value",nResults-1,max);
						setResult("Cytoplasm Bright Radius",nResults-1,brC);
						setResult("Cytoplasm Bright Threshold",nResults-1,btC);
						setResult("Cytoplasm Dark Radius",nResults-1,drC);
						setResult("Cytoplasm Dark Threshold",nResults-1,dtC);
						setResult("Cytoplasm Gaussian Blur",nResults-1,sigC);
						setResult("Cytoplasm Lower Threshold",nResults-1,LowerCyto);
						setResult("Cytoplasm Upper Threshold",nResults-1,UpperCyto);
						setResult("Cytoplasm Lower Size Exclusion",nResults-1,lseC);
						setResult("Cytoplasm Upper Size Exclusion",nResults-1,useC);
						setResult("Cytoplasm Lower Circularity Exclusion",nResults-1,lceC);
						setResult("Cytoplasm Upper Circularity Exclusion",nResults-1,uceC);
						setResult("Cytoplasm Watershed",nResults-1,watershedC);
						setResult("Cytoplasm Exclusion",nResults-1,excludeC);
						updateResults();
						if(watershedN==1){
							watershedN = "TRUE";
						} else {
							watershedN = "FALSE";
						}
						if(excludeN==1){
							excludeN = "TRUE";
						} else {
							excludeN = "FALSE";
						}
						if(watershedC==1){
							watershedC = "TRUE";
						} else if (watershedC==0) {
							watershedC = "FALSE";
						}
						if(excludeC==1){
							excludeC = "TRUE";
						} else if (excludeC==0){
							excludeC = "FALSE";
						}
						print(tableTitle2, nameStore0 + "\t"  + Thresh + "\t"  + brN + "\t"  + btN + "\t"  + drN + "\t"  + dtN + "\t"  + sigN + "\t"  + LowerNuc + "\t" + UpperNuc + "\t"  + lseN + "\t"  + useN + "\t"  + lceN + "\t"  + uceN + "\t"  + watershedN + "\t"  + excludeN + "\t"  + sigF + "\t"  + max + "\t"  + brC + "\t"  + btC + "\t"  + drC + "\t"  + dtC + "\t"  + sigC + "\t"  + LowerCyto + "\t"  + UpperCyto + "\t"  + lseC + "\t"  + useC + "\t"  + lceC + "\t"  + uceC + "\t"  + watershedC + "\t"  + excludeC);	
		} //ends for nuclei, cyto, foci
	} //ends for PLA adjustment ELSE
				

//Closes remaining tables at the end of the macro

if(isOpen("Results")==1){//works out average of adjustments
selectWindow("Results");
brN_mean=0;
brN_total=0;
for (a=0; a<nResults(); a++) {
    brN_total=brN_total+getResult("Nucleus Bright Radius",a);
    brN_mean=brN_total/nResults;
}
btN_mean=0;
btN_total=0;
for (a=0; a<nResults(); a++) {
    btN_total=btN_total+getResult("Nucleus Bright Threshold",a);
    btN_mean=btN_total/nResults;
}
drN_mean=0;
drN_total=0;
for (a=0; a<nResults(); a++) {
    drN_total=drN_total+getResult("Nucleus Dark Radius",a);
    drN_mean=drN_total/nResults;
}
dtN_mean=0;
dtN_total=0;
for (a=0; a<nResults(); a++) {
    dtN_total=dtN_total+getResult("Nucleus Dark Threshold",a);
    dtN_mean=dtN_total/nResults;
}
sigN_mean=0;
sigN_total=0;
for (a=0; a<nResults(); a++) {
    sigN_total=sigN_total+getResult("Nucleus Gaussian Blur",a);
    sigN_mean=sigN_total/nResults;
}
LN_mean=0;
LN_total=0;
for (a=0; a<nResults(); a++) {
    LN_total=LN_total+getResult("Nucleus Lower Threshold",a);
    LN_mean=LN_total/nResults;
}
if(isNaN(LN_mean)==true){
	LN_mean=methodN;
}
UN_mean=0;
UN_total=0;
for (a=0; a<nResults(); a++) {
    UN_total=UN_total+getResult("Nucleus Upper Threshold",a);
    UN_mean=UN_total/nResults;
}
lseN_mean=0;
lseN_total=0;
for (a=0; a<nResults(); a++) {
    lseN_total=lseN_total+getResult("Nucleus Lower Size Exclusion",a);
    lseN_mean=lseN_total/nResults;
}
useN_mean=0;
useN_total=0;
for (a=0; a<nResults(); a++) {
    useN_total=useN_total+getResult("Nucleus Upper Size Exclusion",a);
    useN_mean=useN_total/nResults;
}
if(isNaN(useN_mean)==true){
	useN_mean="infinity";
}
lceN_mean=0;
lceN_total=0;
for (a=0; a<nResults(); a++) {
    lceN_total=lceN_total+getResult("Nucleus Lower Circularity Exclusion",a);
    lceN_mean=lceN_total/nResults;
}
uceN_mean=0;
uceN_total=0;
for (a=0; a<nResults(); a++) {
    uceN_total=uceN_total+getResult("Nucleus Upper Circularity Exclusion",a);
    uceN_mean=uceN_total/nResults;
}
sigF_mean=0;
sigF_total=0;
for (a=0; a<nResults(); a++) {
	sigF_total=sigF_total+getResult("Foci Gaussian Blur",a);
	sigF_mean=sigF_total/nResults;
}
max_mean=0;
max_total=0;
for (a=0; a<nResults(); a++) {
    max_total=max_total+getResult("Foci Maxima Value",a);
    max_mean=max_total/nResults;
}
brC_mean=0;
brC_total=0;
for (a=0; a<nResults(); a++) {
    brC_total=brC_total+getResult("Cytoplasm Bright Radius",a);
    brC_mean=brC_total/nResults;
}
btC_mean=0;
btC_total=0;
for (a=0; a<nResults(); a++) {
    btC_total=btC_total+getResult("Cytoplasm Bright Threshold",a);
    btC_mean=btC_total/nResults;
}
drC_mean=0;
drC_total=0;
for (a=0; a<nResults(); a++) {
    drC_total=drC_total+getResult("Cytoplasm Dark Radius",a);
    drC_mean=drC_total/nResults;
}
dtC_mean=0;
dtC_total=0;
for (a=0; a<nResults(); a++) {
    dtC_total=dtC_total+getResult("Cytoplasm Dark Threshold",a);
    dtC_mean=dtC_total/nResults;
}
sigC_mean=0;
sigC_total=0;
for (a=0; a<nResults(); a++) {
    sigC_total=sigC_total+getResult("Cytoplasm Gaussian Blur",a);
    sigC_mean=sigC_total/nResults;
}
LC_mean=0;
LC_total=0;
for (a=0; a<nResults(); a++) {
    LC_total=LC_total+getResult("Cytoplasm Lower Threshold",a);
    LC_mean=LC_total/nResults;
}
if(isNaN(LC_mean)==true){
	if(cyto == "NoCyto"){
		LC_mean="NaN";
	} else{
	LC_mean=methodC;
	}
}
UC_mean=0;
UC_total=0;
for (a=0; a<nResults(); a++) {
    UC_total=UC_total+getResult("Cytoplasm Upper Threshold",a);
    UC_mean=UC_total/nResults;
}
lseC_mean=0;
lseC_total=0;
for (a=0; a<nResults(); a++) {
    lseC_total=lseC_total+getResult("Cytoplasm Lower Size Exclusion",a);
    lseC_mean=lseC_total/nResults;
}
useC_mean=0;
useC_total=0;
for (a=0; a<nResults(); a++) {
    useC_total=useC_total+getResult("Cytoplasm Upper Size Exclusion",a);
    useC_mean=useC_total/nResults;
}
if(isNaN(useC_mean)==true){
	if(cyto == "NoCyto"){
		LC_mean="NaN";
	} else{
	useC_mean="infinity";
	}
}
lceC_mean=0;
lceC_total=0;
for (a=0; a<nResults(); a++) {
    lceC_total=lceC_total+getResult("Cytoplasm Lower Circularity Exclusion",a);
    lceC_mean=lceC_total/nResults;
}
uceC_mean=0;
uceC_total=0;
for (a=0; a<nResults(); a++) {
    uceC_total=uceC_total+getResult("Cytoplasm Upper Circularity Exclusion",a);
    uceC_mean=uceC_total/nResults;
}

run("Close");
}
tableTitle5="PLA Optimization Summary";//prints out unit summary table with average values
tableTitle6="["+tableTitle5+"]";
run("Table...", "name="+tableTitle6+" width=400 height=620");
print(tableTitle6,"Threshold = "+Thresh);
print(tableTitle6,"Average Nucleus Bright Radius = "+brN_mean);
print(tableTitle6,"Average Nucleus Bright Threshold = "+btN_mean);
print(tableTitle6,"Average Nucleus Dark Radius = "+drN_mean);
print(tableTitle6,"Average Nucleus Dark Threshold = "+dtN_mean);
print(tableTitle6,"Average Nucleus Gaussian Blur = "+sigN_mean);
print(tableTitle6,"Average Nucleus Lower Threshold = "+LN_mean);
print(tableTitle6,"Average Nucleus Upper Threshold = "+UN_mean);
print(tableTitle6,"Average Nucleus Lower Size Exclusion = "+lseN_mean);
print(tableTitle6,"Average Nucleus Upper Size Exclusion = "+useN_mean);
print(tableTitle6,"Average Nucleus Lower Circularity Exclusion = "+lceN_mean);
print(tableTitle6,"Average Nucleus Upper Cirularity Exclusion = "+uceN_mean);
print(tableTitle6,"Nucleus Watershed = "+watershedN);
print(tableTitle6,"Nucleus Edge Exclusion = "+excludeN);
print(tableTitle6,"Average Foci Gaussian Blur = "+sigF_mean);
print(tableTitle6,"Average Foci Maxima Value = "+max_mean);
print(tableTitle6,"Average Cytoplasm Bright Radius = "+brC_mean);
print(tableTitle6,"Average Cytoplasm Bright Threshold = "+btC_mean);
print(tableTitle6,"Average Cytoplasm Dark Radius = "+drC_mean);
print(tableTitle6,"Average Cytoplasm Dark Threshold = "+dtC_mean);
print(tableTitle6,"Average Cytoplasm Gaussian Blur = "+sigC_mean);
print(tableTitle6,"Average Cytoplasm Lower Threshold = "+LC_mean);
print(tableTitle6,"Average Cytoplasm Upper Threshold = "+UC_mean);
print(tableTitle6,"Average Cytoplasm Lower Size Exclusion = "+lseC_mean);
print(tableTitle6,"Average Cytoplasm Upper Size Exclusion = "+useC_mean);
print(tableTitle6,"Average Cytoplasm Lower Circularity Exclusion = "+lceC_mean);
print(tableTitle6,"Average Cytoplasm Upper Cirularity Exclusion = "+uceC_mean);
print(tableTitle6,"Cytoplasm Watershed = "+watershedC);
print(tableTitle6,"Cytoplasm Edge Exclusion = "+excludeC);
print(tableTitle2, "Average" + "\t" + Thresh + "\t" + brN_mean + "\t" + btN_mean + "\t" + drN_mean + "\t" + dtN_mean + "\t" + sigN_mean + "\t"  + LN_mean + "\t" + UN_mean + "\t" + lseN_mean + "\t" + useN_mean + "\t" + lceN_mean + "\t" + uceN_mean + "\t"  + watershedN + "\t"  + excludeN + "\t"  + sigF + "\t"  + max_mean+ "\t" + brC_mean + "\t" + btC_mean + "\t" + drC_mean + "\t" + dtC_mean + "\t" + sigC_mean + "\t"  + LC_mean + "\t" + UC_mean + "\t" + lseC_mean + "\t" + useC_mean + "\t" + lceC_mean + "\t" + uceC_mean + "\t"  + watershedC + "\t"  + excludeC);
print(tableTitle2, " ");
print(tableTitle2, "PLA Optimization" + "\t" + "Optimization");
print(tableTitle2, "Threshold" + "\t" + Thresh);
print(tableTitle2, "Average Nucleus Bright Radius" + "\t" + brN_mean);
print(tableTitle2, "Average Nucleus Bright Threshold" + "\t" + btN_mean);
print(tableTitle2, "Average Nucleus Dark Radius" + "\t" + drN_mean);
print(tableTitle2, "Average Nucleus Dark Threshold" + "\t" + dtN_mean);
print(tableTitle2, "Average Nucleus Gaussian Blur" + "\t" + sigN_mean);
print(tableTitle2, "Average Nucleus Lower Threshold" + "\t" + LN_mean);
print(tableTitle2, "Average Nucleus Upper Threshold" + "\t" + UN_mean);
print(tableTitle2, "Average Nucleus Lower Size Exclusion" + "\t" + lseN_mean);
print(tableTitle2, "Average Nucleus Upper Size Exclusion" + "\t" + useN_mean);
print(tableTitle2, "Average Nucleus Lower Circularity Exclusion" + "\t" + lceN_mean);
print(tableTitle2, "Average Nucleus Upper Circularity Exclusion" + "\t" + lceN_mean);
print(tableTitle2, "Nucleus Watershed" + "\t" + watershedN);
print(tableTitle2, "Nucleus Edge Exclusion" + "\t" + excludeN);
print(tableTitle2, "Average Foci Gaussian Blur" + "\t" + sigF_mean);
print(tableTitle2, "Average Foci Maxima Value" + "\t" + max_mean);
print(tableTitle2, "Average Cytoplasm Bright Radius" + "\t" + brC_mean);
print(tableTitle2, "Average Cytoplasm Bright Threshold" + "\t" + btC_mean);
print(tableTitle2, "Average Cytoplasm Dark Radius" + "\t" + drC_mean);
print(tableTitle2, "Average Cytoplasm Dark Threshold" + "\t" + dtC_mean);
print(tableTitle2, "Average Cytoplasm Gaussian Blur" + "\t" + sigC_mean);
print(tableTitle2, "Average Cytoplasm Lower Threshold" + "\t" + LC_mean);
print(tableTitle2, "Average Cytoplasm Upper Threshold" + "\t" + UC_mean);
print(tableTitle2, "Average Cytoplasm Lower Size Exclusion" + "\t" + lseC_mean);
print(tableTitle2, "Average Cytoplasm Upper Size Exclusion" + "\t" + useC_mean);
print(tableTitle2, "Average Cytoplasm Lower Circularity Exclusion" + "\t" + lceC_mean);
print(tableTitle2, "Average Cytoplasm Upper Circularity Exclusion" + "\t" + lceC_mean);
print(tableTitle2, "Cytoplasm Watershed" + "\t" + watershedC);
print(tableTitle2, "Cytoplasm Edge Exclusion" + "\t" + excludeC);	
if(isOpen("Summary")==1){
selectWindow("Summary");
run("Close");
}
if(isOpen("ROI Manager")==1){
selectWindow("ROI Manager");
run("Close");
}
if(isOpen("Threshold")==1){
selectWindow("Threshold");
run("Close");
}
selectWindow("PLA Optimization");
saveAs("Results",  dir+tableTitle+".xls");
selectWindow("PLA Optimization");
run("Close");

ana = "Start the analysis with current settings";
finish = "Exit the macro and redo the optimization";
Dialog.create("Next step");
Dialog.addMessage("What would you like to do now?");
Dialog.addChoice("Type:", newArray(ana, finish));
Dialog.show();
third = Dialog.getChoice();
if(third == ana){
	waitForUser("Analysis section","Welcome to image analysis. This section will prompt you to input the\nparameters for image analysis. Once the analysis begins, no further\nuser input is required until it is complete.\n \nGood luck!");
	Analysis();
	}
if(third == finish){
	exit("If you want to restart the optimization, please remove all new files created in the test folder\nand restart this macro.\n \nNote: A quick way to delete everything that was created is to sort your folder by the\ncreated/modified date and select all new files and delete.\n \nClick OK to finish.");
	}

} //End of adjustment macro
}//End of if(first==no)

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
PLA Analysis 018
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
if(second==ana){
Analysis();
function Analysis(){
	waitForUser("Select the analysis folder","Please select the folder with the PLA images you wish to analyze.\n \nNote: Ensure only sets of images (nuclei, foci, and/or cytoplasm)\nare present in the folder and that they are labeled in tandem,\neg ch00, ch01 and ch02.\n \nIf there are any other files or if any sets of images are incomplete\nin the analysis folder then the analysis will not work.");
	dir = getDirectory("Select Analysis Folder");
	list = getFileList(dir);
	Array.sort(list);
	Dialog.create("Channel names");
	Dialog.addMessage("Please type in the unique name for (case sensitive):");
	Dialog.addString("Nuclei", "");
	Dialog.addString("Foci", "");
	Dialog.addString("Cytoplasm", "NoCyto");
	Dialog.addMessage("Note: If there are no cytoplasmic images,\nplease leave as NoCyto.");
	Dialog.show();
	nuc = Dialog.getString();
	foci = Dialog.getString();
	cyto = Dialog.getString();
	if (cyto == "NoCyto"){
		check = list.length/2;
		error= round(check);
		if(error!=check){
			Dialog.create("Error: Number of files in directory");
			Dialog.addMessage("ERROR: Please ensure that there are complete PLA sets in your analysis folder.");
			Dialog.addMessage("Remove any other files or folders that may be in the analysis folder or");
			Dialog.addMessage("an error will occur at the end of the analysis.");
			Dialog.addMessage("Click 'Cancel' to exit analysis or 'OK' to proceed with the analysis");
			Dialog.show();
			
		}
	} else {
		check = list.length/3;
		error= round(check);
		if(error!=check){
			Dialog.create("Error: Number of files in directory");
			Dialog.addMessage("ERROR: Please ensure that there are complete PLA sets in your analysis folder.");
			Dialog.addMessage("Remove any other files or folders that may be in the analysis folder or");
			Dialog.addMessage("an error will occur at the end of the analysis.");
			Dialog.addMessage("Click 'Cancel' to exit analysis or 'OK' to proceed with the analysis");
			Dialog.show();
	}
	}
	list = getFileList(dir);
	Array.sort(list);
	tableTitle3="PLA Summary";
	tableTitle4="["+tableTitle3+"]";
	run("Table...", "name="+tableTitle4+" width=600 height=250");
	print(tableTitle4,"\\Headings:Image name\tNucleus Count\tTotal Nuclei Area\tAverage Nuclei Area\tTotal Signal\tNuclear Signal\tNonNuclear Signal\tPercent Nuclear Signal\tAverage Signal per Nucleus\tCytoplasm Area\tAverage Cytoplasmic Area\tCytoplasmic Signal\tNon Cytoplasmic Signal\tPercent Cytoplasmic Signal\tAverage Signal per Cytoplasm\tIntracellular Signal\tExtracellular Signal");
	if (cyto == "NoCyto"){
	Dialog.create("Saving files");
	Dialog.addMessage("Select which files to be saved during analysis");
	Dialog.addMessage("Nucleus:");
	Dialog.addCheckbox("Nuclei ROI", true);
	Dialog.addCheckbox("Nuclei Overlay", true);
	Dialog.addCheckbox("Nuclei Mask", false);
	Dialog.addMessage("Foci:");
	Dialog.addCheckbox("Foci ROI", true);
	Dialog.addCheckbox("Foci Overlay", true);
	Dialog.show();
	NR = Dialog.getCheckbox();
	NO = Dialog.getCheckbox();
	NM = Dialog.getCheckbox();
	FR = Dialog.getCheckbox();
	FO = Dialog.getCheckbox();
	CR = false;
	CO = false;
	CM = false;
	} else{
	Dialog.create("Saving files");
	Dialog.addMessage("Select which files to be saved during analysis");
	Dialog.addMessage("Nucleus:");
	Dialog.addCheckbox("Nuclei ROI", true);
	Dialog.addCheckbox("Nuclei Overlay", true);
	Dialog.addCheckbox("Nuclei Mask", false);
	Dialog.addMessage("Foci:");
	Dialog.addCheckbox("Foci ROI", true);
	Dialog.addCheckbox("Foci Overlay", true);
	Dialog.addMessage("Cytoplasm:");
	Dialog.addCheckbox("Cytoplasm ROI", true);
	Dialog.addCheckbox("Cytoplasm Overlay", true);
	Dialog.addCheckbox("Cytoplasm Mask", false);
	Dialog.show();
	NR = Dialog.getCheckbox();
	NO = Dialog.getCheckbox();
	NM = Dialog.getCheckbox();
	FR = Dialog.getCheckbox();
	FO = Dialog.getCheckbox();
	CR = Dialog.getCheckbox();
	CO = Dialog.getCheckbox();
	CM = Dialog.getCheckbox();
	}
	Dialog.create("Setting a scale");
	Dialog.addMessage("Please set a scale for the measurement.\nIf no scale is set then the measurments\nwill be made in pixel size.");
	Dialog.addNumber("Distance in pixels:", 0);
	Dialog.addNumber("Known distance:", 0);
	Dialog.addString("Unit of length: pixel/", "pixel");
	Dialog.addMessage("For details to set scale refer to\nhttps://imagej.net/SpatialCalibration");
	Dialog.show();
	dist = Dialog.getNumber();
	know = Dialog.getNumber();
	unit = Dialog.getString();
	Dialog.create("Thresholding");
	Dialog.addMessage("Select automatic or manual threshold");
	Dialog.addChoice("", newArray("Automatic", "Manual"));
	Dialog.show();
	Thresh = Dialog.getChoice();
	if (cyto == "NoCyto"){
		if (Thresh == "Automatic"){
				Dialog.create("Setting Nuclei Parameters");
				Dialog.addMessage("Please enter the parameters for the analysis of nuclei images");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.addMessage("Nuclei Threshold Method:");
				Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				methodN = Dialog.getChoice();
				Dialog.create("Setting Nuclei Particle Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the nuclei in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				Dialog.create("Setting Foci Maxima");
				Dialog.addMessage("Please enter the value for Foci Gaussian Blur");
				Dialog.addNumber("Foci Gaussian Blur", 0);
				Dialog.addMessage("Please enter the maxima values for selecting the foci");
				Dialog.addNumber("Foci Maxima Value", 0);
				Dialog.show();
				sigF = Dialog.getNumber();
				max = Dialog.getNumber();
		} else {
				Dialog.create("Setting Nuclei Parameters");
				Dialog.addMessage("Please enter the parameters for the analysis of nuclei images");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.addMessage("Nuclei Threshold Value:");
				Dialog.addNumber("Lower Threshold:", 50);
				Dialog.addNumber("Upper Threshold", 255);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				LN = Dialog.getNumber();
				UN = Dialog.getNumber();
				Dialog.create("Setting Nuclei Particle Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the nuclei in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				Dialog.create("Setting Foci Maxima");
				Dialog.addMessage("Please enter the value for Foci Gaussian Blur");
				Dialog.addNumber("Foci Gaussian Blur", 0);
				Dialog.addMessage("Please enter the maxima values for selecting the foci");
				Dialog.addNumber("Foci Maxima Value", 0);
				Dialog.show();
				sigF = Dialog.getNumber();
				max = Dialog.getNumber();
		}//end of else for setting parameters for manual or auto threshold for no cyto
		} else {
			if (Thresh == "Automatic"){
				Dialog.create("Setting Nuclei Parameters");
				Dialog.addMessage("Please enter the parameters for the analysis of nuclei images");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.addMessage("Nuclei Threshold Method:");
				Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				methodN = Dialog.getChoice();
				Dialog.create("Setting Nuclei Particle Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the nuclei in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				Dialog.create("Setting Foci Maxima");
				Dialog.addMessage("Please enter the value for Foci Gaussian Blur");
				Dialog.addNumber("Foci Gaussian Blur", 0);
				Dialog.addMessage("Please enter the maxima values for selecting the foci");
				Dialog.addNumber("Foci Maxima Value", 0);
				Dialog.show();
				sigF = Dialog.getNumber();
				max = Dialog.getNumber();
				Dialog.create("Setting Cytoplasm Parameters");
				Dialog.addMessage("Please enter the parameters for the analysis of cytoplasmic images");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.addMessage("Cytoplasmic Threshold Method:");
				Dialog.addChoice("", newArray("Huang","Intermodes","Otsu","RenyiEntropy"));
				Dialog.show();
				brC = Dialog.getNumber();
				btC = Dialog.getNumber();
				drC = Dialog.getNumber();
				dtC = Dialog.getNumber();
				sigC = Dialog.getNumber();
				methodC = Dialog.getChoice();
				Dialog.create("Setting Cytoplasmic Particle Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the cytoplasm in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe cytoplasm?");
				Dialog.addCheckbox("watershed", false);
				Dialog.addMessage("Would you like to exclude the cytoplasm\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseC = Dialog.getNumber();
				useC = Dialog.getString();
				lceC = Dialog.getNumber();
				uceC = Dialog.getNumber();
				watershedC = Dialog.getCheckbox();
				excludeC = Dialog.getCheckbox();
			} else {
				Dialog.create("Setting Nuclei Parameters");
				Dialog.addMessage("Please enter the parameters for the analysis of nuclei images");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.addMessage("Nuclei Threshold Value:");
				Dialog.addNumber("Lower Threshold:", 50);
				Dialog.addNumber("Upper Threshold", 255);
				Dialog.show();
				brN = Dialog.getNumber();
				btN = Dialog.getNumber();
				drN = Dialog.getNumber();
				dtN = Dialog.getNumber();
				sigN = Dialog.getNumber();
				LN = Dialog.getNumber();
				UN = Dialog.getNumber();
				Dialog.create("Setting Nuclei Particle Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the nuclei in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseN = Dialog.getNumber();
				useN = Dialog.getString();
				lceN = Dialog.getNumber();
				uceN = Dialog.getNumber();
				watershedN = Dialog.getCheckbox();
				excludeN = Dialog.getCheckbox();
				Dialog.create("Setting Foci Maxima");
				Dialog.addMessage("Please enter the value for Foci Gaussian Blur");
				Dialog.addNumber("Foci Gaussian Blur", 0);
				Dialog.addMessage("Please enter the maxima values for selecting the foci");
				Dialog.addNumber("Foci Maxima Value", 0);
				Dialog.show();
				sigF = Dialog.getNumber();
				max = Dialog.getNumber();
				Dialog.create("Setting Cytoplasm Parameters");
				Dialog.addMessage("Please enter the parameters for the analysis of cytoplasmic images");
				Dialog.addMessage("Please enter the values for removing background:");
				Dialog.addMessage("Bright:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Dark:");
				Dialog.addNumber("Radius:", 5);
				Dialog.addNumber("Threshold", 50);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.addMessage("Cytoplasmic Threshold Value:");
				Dialog.addNumber("Lower Threshold:", 50);
				Dialog.addNumber("Upper Threshold", 255);
				Dialog.show();
				brC = Dialog.getNumber();
				btC = Dialog.getNumber();
				drC = Dialog.getNumber();
				dtC = Dialog.getNumber();
				sigC = Dialog.getNumber();
				LC = Dialog.getNumber();
				UC = Dialog.getNumber();
				Dialog.create("Setting Cytoplasmic Particle Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the cytoplasm in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe cytoplasm?");
				Dialog.addCheckbox("watershed", false);
				Dialog.addMessage("Would you like to exclude the cytoplasm\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.show();
				lseC = Dialog.getNumber();
				useC = Dialog.getString();
				lceC = Dialog.getNumber();
				uceC = Dialog.getNumber();
				watershedC = Dialog.getCheckbox();
				excludeC = Dialog.getCheckbox();
			}//end of else for setting parameters for manual threshold with cyto
	}//end of else for setting parameters for manual or auto threshold with cyto
	if(isOpen("PLA Optimization Summary")==1){
		selectWindow("PLA Optimization Summary");
		run("Close");
		}
	if (cyto == "NoCyto"){//analysis with no cytoplasmic image
		for(i=0; i<list.length; i+=2){
			filename = dir + list[i];
			filename2 = dir + list[i+1];
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Analysis No Cyto 019


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				AnucNoCyto();//opens nuclei image
				function AnucNoCyto(){
				if (matches(filename, ".*"+nuc+".*")){
					open(filename);
				}
				if (matches(filename2, ".*"+nuc+".*")){
					open(filename2);
				}
				}
				nameStore0 = getTitle();
				rename("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				selectWindow("Nuclei-Duplicate");
				if (Thresh == "Automatic"){//automatic threshold
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(LN, UN);
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
				}
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=dist known=know unit=unit");
				run("Measure");//makes measurements and saves masks and overlays
				if(getResult('Area', nResults-1)!=0) {
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					if (NR == true){
						roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					}
					if (NM == true){
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					}
					if (NO == true){
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
					}
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
				}
				selectWindow("Nuclei-Duplicate");
				close();

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Analysis No Cyto 020


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				AfociNoCyto();//opens foci image
				
				function AfociNoCyto(){
					if (matches(filename, ".*"+foci+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+foci+".*")){
						open(filename2);
					}	
				}
				
				nameStore1 = getTitle();
				rename("Foci");
				selectWindow("Foci");
				run("Gaussian Blur...", "sigma=sigF");
				run("Find Maxima...", "noise=max output=[Single Points]");
				rename("Foci-Points");
				roiManager("Reset");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {//makes measurements and saves overlay
					TotalSignal = roiManager("count");
					if (FR == true){
						roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					}
					if (FO == true){
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					}
				} else {
						TotalSignal = 0;
					}
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}
				if(isOpen("Results")==1){
				selectWindow("Results");
				run("Close");
				}
				selectWindow("Nuclei-Mask");
				setThreshold(10, 255);
				IJ.redirectErrorMessages();
				run("Analyze Particles...", "size=0-infinity pixel show=Nothing clear add");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
				}
				if (roiManager("count")!=0) {
				selectWindow("Foci-Points");
				roiManager("Show All without labels");
				run("Set Measurements...", "area integrated redirect=None decimal=1");
				roiManager("Measure");
				SignalperNucleus=0;
				for (a=0; a<nResults(); a++) {
					SignalperNucleus=getResult("RawIntDen",a)/255;
					setResult("NuclearSignal",a,SignalperNucleus);
				}
				NuclearSignal=0;
				for (a=0; a<nResults(); a++) {
					NuclearSignal = NuclearSignal + getResult("NuclearSignal",a);
				}
				NonNuclearSignal = TotalSignal-NuclearSignal;
				if (NucleusCount!=0) {
					AverageSignalPerNucleus = NuclearSignal/NucleusCount;
				} else{
					AverageSignalPerNucleus = 0;
				}
				if (TotalSignal!=0) {
					PercentNuclearSignal = (NuclearSignal/TotalSignal)*100;
				} else{
					PercentNuclearSignal = 0;
				}	
				} else {
					NuclearSignal = 0;
					NonNuclearSignal = TotalSignal;
					AverageSignalPerNucleus = 0;
					PercentNuclearSignal = 0;
				}
				run("Close All");
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}
				CytoArea = "NaN";
				AverageCytoArea = "NaN";
				AverageCytoArea = "NaN";
				NonCytoSignal = "NaN";
				CytoSignal = "NaN";
				AverageSignalPerCyto = "NaN";
				PercentCytoSignal = "NaN";
				IntracellularSignal = "NaN";
				ExtracellularSignal = "NaN";
				print(tableTitle4, nameStore0 + "\t"  + NucleusCount + "\t"  + NucleiArea + "\t"  + AverageNucleiArea + "\t"  + TotalSignal + "\t"  + NuclearSignal + "\t"  + NonNuclearSignal + "\t"  + PercentNuclearSignal + "\t"  + AverageSignalPerNucleus + "\t"  + CytoArea + "\t"  + AverageCytoArea + "\t"  + CytoSignal + "\t"  + NonCytoSignal + "\t"  + PercentCytoSignal + "\t"  + AverageSignalPerCyto + "\t"  + IntracellularSignal + "\t"  + ExtracellularSignal);
			}//end of analysis for no cyto
		} else {//analysis with cytoplasmic image
			for(i=0; i<list.length; i+=3){
			filename = dir + list[i];
			filename2 = dir + list[i+1];
			filename3 = dir + list[i+2];
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Nucleus Analysis 021


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
			Anuc();	//opens nuclei image
			function Anuc(){
				if (matches(filename, ".*"+nuc+".*")){
					open(filename);
				}
				if (matches(filename2, ".*"+nuc+".*")){
					open(filename2);
				}
				if (matches(filename3, ".*"+nuc+".*")){
					open(filename3);
				}
			}
				nameStore0 = getTitle();
				rename("Nucleus");
				run("Duplicate...", "title=Nuclei-Duplicate");
				run("Enhance Contrast...", "saturated=0.01");
				run("Remove Outliers...","radius=brN threshold=btN which=Bright");
				run("Remove Outliers...","radius=drN threshold=dtN which=Dark");
				run("Gaussian Blur...", "sigma=sigN");
				run("8-bit");
				selectWindow("Nuclei-Duplicate");
				if (Thresh == "Automatic"){//automatic threshold
					if(methodN=="Huang"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Huang white");
					}
					if(methodN=="Intermodes"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodN=="Otsu"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodN=="RenyiEntropy"){
						setOption("BlackBackground", true);
						run("Auto Threshold", "method=RenyiEntropy white");
					}
					selectWindow("Nuclei-Duplicate");
					setThreshold(1, 255);
				} else{//manual threshold
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(LN, UN);
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				if (watershedN == true){
					selectWindow("Nuclei-Duplicate");
					run("Watershed");
				}
				if (excludeN == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks exclude add");
				} else {		
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseN-useN pixel circularity=lceN-uceN show=Masks add");
				}
				rename("Nuclei-Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
				}
				selectWindow("Nuclei-Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area limit redirect=None decimal=3");
				run("Set Scale...", "distance=dist known=know unit=unit");
				run("Measure");//makes measurements and saves mask and overlay
				if(getResult('Area', nResults-1)!=0) {
					NucleiArea = getResult('Area', nResults-1);
				} else {
					NucleiArea = 0;
					}
				if (roiManager("count")!=0) {
					NucleusCount = roiManager("count");
					AverageNucleiArea = NucleiArea/NucleusCount;
					if (NR == true){
						roiManager("Save",  dir+nameStore0+" - Nuclei.zip");
					}
					if (NM == true){
					selectWindow("Nuclei-Mask");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Mask");
					rename("Nuclei-Mask");
					}
					if (NO == true){
					selectWindow("Nucleus");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					saveAs("Tiff", dir+nameStore0+" - Nuclei Overlay");
					close();
					roiManager("Set Color", "yellow");
					}
				} else {
					NucleusCount = 0;
					AverageNucleiArea = 0;
				}
				selectWindow("Nuclei-Duplicate");
				close();
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Foci Analysis 022


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				Afoci();//opens foci image
				function Afoci(){
					if (matches(filename, ".*"+foci+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+foci+".*")){
						open(filename2);
					}
					if (matches(filename3, ".*"+foci+".*")){
						open(filename3);
					}
				}
				nameStore1 = getTitle();
				rename("Foci");
				selectWindow("Foci");
				run("Gaussian Blur...", "sigma=sigF");
				run("Find Maxima...", "noise=max output=[Single Points]");
				rename("Foci-Points");
				roiManager("Reset");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Analyze Particles...", "size=0-2 pixel show=Nothing add");
				if (roiManager("count")!=0) {//makes measurements and saves overlay
					TotalSignal = roiManager("count");
					if (FR == true){
						roiManager("Save",  dir+nameStore1+" - All Foci.zip");
					}
					if (FO == true){
					selectWindow("Foci");
					roiManager("Show All without labels");
					roiManager("Set Color", "magenta");
					roiManager("Set Line Width", 5);
					run("Flatten");
					saveAs("Tiff", dir+nameStore1+" - All Foci Overlay");
					close();
					roiManager("Set Color", "yellow");
					}
				} else {
						TotalSignal = 0;
					}
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}
				if(isOpen("Results")==1){
				selectWindow("Results");
				run("Close");
				}
				selectWindow("Nuclei-Mask");
				setThreshold(10, 255);
				IJ.redirectErrorMessages();
				run("Analyze Particles...", "size=0-infinity pixel show=Nothing clear add");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
				}
				if (roiManager("count")!=0) {
				selectWindow("Foci-Points");
				roiManager("Show All without labels");
				run("Set Measurements...", "area integrated redirect=None decimal=1");
				roiManager("Measure");
				SignalperNucleus=0;
				for (a=0; a<nResults(); a++) {
					SignalperNucleus=getResult("RawIntDen",a)/255;
					setResult("NuclearSignal",a,SignalperNucleus);
				}
				NuclearSignal=0;
				for (a=0; a<nResults(); a++) {
					NuclearSignal = NuclearSignal + getResult("NuclearSignal",a);
				}
				NonNuclearSignal = TotalSignal-NuclearSignal;
				if (NucleusCount!=0) {
					AverageSignalPerNucleus = NuclearSignal/NucleusCount;
				} else{
					AverageSignalPerNucleus = 0;
				}
				if (TotalSignal!=0) {
					PercentNuclearSignal = (NuclearSignal/TotalSignal)*100;
				} else{
					PercentNuclearSignal = 0;
				}	
				} else {
					NuclearSignal = 0;
					NonNuclearSignal = TotalSignal;
					AverageSignalPerNucleus = 0;
					PercentNuclearSignal = 0;
				}
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Cytooplasm Analysis 023


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				Acyto();//opens cytoplasmic image
				function Acyto(){
					if (matches(filename, ".*"+cyto+".*")){
						open(filename);
					}
					if (matches(filename2, ".*"+cyto+".*")){
						open(filename2);
					}	
					if (matches(filename3, ".*"+cyto+".*")){
						open(filename3);
					}
				}
				nameStore2 = getTitle();
					rename("Cytoplasm");
					run("Duplicate...", "title=Cytoplasm-Duplicate");
					run("Enhance Contrast...", "saturated=0.01");
					run("Remove Outliers...","radius=brC threshold=btC which=Bright");
					run("Remove Outliers...","radius=drC threshold=dtC which=Dark");
					run("Gaussian Blur...", "sigma=sigC");
					run("8-bit");
					selectWindow("Cytoplasm-Duplicate");
					if (Thresh == "Automatic"){//automatic threshold
						if(methodC=="Huang"){
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Huang white");
						}
						if(methodC=="Intermodes"){
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Intermodes white");
						}
						if(methodC=="Otsu"){
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=Otsu white");
						}
						if(methodC=="RenyiEntropy"){
							setOption("BlackBackground", true);
							run("Auto Threshold", "method=RenyiEntropy white");
						}
						selectWindow("Cytoplasm-Duplicate");
						setThreshold(1, 255);
					} else{//manual threshold
						setAutoThreshold("Default dark");
						run("Threshold...");
						setThreshold(LC, UC);
						setOption("BlackBackground", true);
						run("Convert to Mask");
						setThreshold(1, 255);
					}
					if (watershedC == true){
						selectWindow("Cytoplasm-Duplicate");
						run("Watershed");
					}
					if (excludeC == true){
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks exclude add");
						} else {		
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseC-useC pixel circularity=lceC-uceC show=Masks add");
						}
					rename("Cytoplasm Mask");
					if(isOpen("Log")==1){
						selectWindow("Log");
						run("Close");
					}
					imageCalculator("Subtract create", "Cytoplasm Mask","Nuclei-Mask");
					rename("Cytoplasm Mask2");
					selectWindow("Cytoplasm Mask");
					close();
					selectWindow("Cytoplasm Mask2");
					rename("Cytoplasm Mask");
					setAutoThreshold("Default dark");
					//run("Threshold...");
					setThreshold(10, 255);
					run("Set Measurements...", "area limit redirect=None decimal=3");
					run("Set Scale...", "distance=dist known=know unit=unit");
					run("Measure");//makes measurements and saves mask and overlay
					if(getResult('Area', nResults-1)!=0) {
							CytoArea = getResult('Area', nResults-1);
						} else {
							CytoArea = 0;
						}
					if (roiManager("count")!=0) {
					AverageCytoArea = CytoArea/NucleusCount;
					if (CR == true){
						roiManager("Save",  dir+nameStore2+" - Cytoplasm.zip");
					}
					if (CM == true){
					selectWindow("Cytoplasm Mask");
					saveAs("Tiff", dir+nameStore2+" - Cytoplasm Mask");
					rename("Cytoplasm Mask");
					}
					if (CO == true){
					selectWindow("Cytoplasm");
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "blue");
					run("Flatten");
					saveAs("Tiff", dir+nameStore2+" - Cytoplasm Overlay");
					close();
					roiManager("Set Color", "yellow");
					}
				} else {
					AverageCytoArea = 0;
					}
					if(isOpen("Results")==1){
						selectWindow("Results");
						run("Close");
						}
					if (roiManager("count")!=0) {
					selectWindow("Foci-Points");
					roiManager("Show All without labels");
					run("Set Measurements...", "area integrated redirect=None decimal=1");
					roiManager("Measure");
					SignalperCyto=0;
					for (a=0; a<nResults(); a++) {
						SignalperCyto=getResult("RawIntDen",a)/255;
						setResult("CytoSignal",a,SignalperCyto);
					}
					CytoSignal2=0;
					for (a=0; a<nResults(); a++) {
						CytoSignal2 = CytoSignal2 + getResult("CytoSignal",a);
					}
					CytoSignal = CytoSignal2 - NuclearSignal;
					NonCytoSignal = TotalSignal-CytoSignal;
					if (NucleusCount!=0) {
						AverageSignalPerCyto = CytoSignal/NucleusCount;
					} else{
						AverageSignalPerCyto = 0;
					}
					if (TotalSignal!=0) {
						PercentCytoSignal = (CytoSignal/TotalSignal)*100;
					} else{
						PercentCytoSignal = 0;
					}	
					} else {
						CytoSignal = 0;
						NonCytoSignal = TotalSignal;
						AverageSignalPerCyto = 0;
						PercentCytoSignal = 0;
					}
					IntracellularSignal = CytoSignal + NuclearSignal;
					ExtracellularSignal = TotalSignal - IntracellularSignal;	
				run("Close All");
				if(isOpen("ROI Manager")==1){
				selectWindow("ROI Manager");
				run("Close");
				}
				print(tableTitle4, nameStore0 + "\t"  + NucleusCount + "\t"  + NucleiArea + "\t"  + AverageNucleiArea + "\t"  + TotalSignal + "\t"  + NuclearSignal + "\t"  + NonNuclearSignal + "\t"  + PercentNuclearSignal + "\t"  + AverageSignalPerNucleus + "\t"  + CytoArea + "\t"  + AverageCytoArea + "\t"  + CytoSignal + "\t"  + NonCytoSignal + "\t"  + PercentCytoSignal + "\t"  + AverageSignalPerCyto + "\t"  + IntracellularSignal + "\t"  + ExtracellularSignal);	
			}//end of analysis for nuc, foci and cyto
		}//end of else for analysis
if(isOpen("Summary")==1){
selectWindow("Summary");
run("Close");
}
print(tableTitle4,"Units are in "+unit);
if(isOpen("Results")==1){
selectWindow("Results");
run("Close");
}
if(isOpen("ROI Manager")==1){
selectWindow("ROI Manager");
run("Close");
}
if(isOpen("Threshold")==1){
selectWindow("Threshold");
run("Close");
}
selectWindow("PLA Summary");
saveAs("Results",  dir+tableTitle3+".xls");
selectWindow("PLA Summary");
run("Close");
waitForUser("Finished!","The analysis is now complete. The new files are now saved in the target folder and\nthe results file is labeled 'PLA Summary'.");
}//end of function Analysis
}//end of If for analysis
}//end of macro "PLA"