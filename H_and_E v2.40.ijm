macro "H&E"{

//Ver 2.40
 /*
  * Ver 2.40 Update notes:
  * 
  * 1. Analysis now also includes the function Fill Holes
  * 
  * 2. Added total and positive method, watershed option, 
  *    exclude option, and fill holes option in optimization table. So users will
  *    know the exact parameters that were used not just the values now
  *    
  * 3. Optimization table now also includes the same table that comes up at the end
  *    when user finishes the optimization section
  */
  
//The H&E macro will measure all H&E images located in a specified folder. 
//The files that are analyzed will be identified by a regular expression 
//or the file extension as defined by the user.

//Installing this macro
// 1. On FIJI toolbar go to Plugins > Macros > Install
// 2. Select H&E.ijm and click Open
// 3. Go back to Plugins > Macros and you should now see the option of H&E
// 4. Select H&E and follow the prompts


/*
 * Contents
-------------------------------------
 Tutorial Section
 Total Selection Tutorial 001
 Positive Selection Tutorial 002
 Total Selection Enhanced Tutorial 003
 Positive Selection Enhanced Tutorial 004
 Tutorial Optimization 005
 H&E Optimization 010
 H&E Analysis 015
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
	waitForUser("Thank you for choosing the tutorial","Greetings, my name is Andy and I'm going to help you analyze H&E images.\n \nClick OK to continue.");
	wait(1);
	waitForUser("Note","If you encounter any problems and you need to quit the macro, close any windows\nopened in FIJI and restart the macro. IMPORTANT! Prior to restarting, please delete\nany files that were created by the macro in the target folder otherwise an error will\noccur.\n \nClick OK to continue.");
  	wait(1);
	waitForUser("Note 2","When you run this macro please ensure that there are\nonly images in the target folder.\n \nNOTE: The macro will NOT modify your raw image files.\n \nClick OK to continue.");
	wait(1);
  	waitForUser("1. Create optimization folder","Create a test folder and copy 3-5 sample images representative\nof all images to be analyzed. This folder will be used to optimize\nthe image analysis parameters.\n \nClick OK when you are finished.");
	wait(1);
	waitForUser("2. Select the optimization folder","After you click OK a pop-up window will appear. Please locate\nand select the optimization folder in this window and click OK.");
  
	dir = getDirectory("Select Optimization Folder");
	list = getFileList(dir);
	Array.sort(list);
  	waitForUser("3. Selecting the image format or name", "After clicking OK, please select the file extension of your images. (e.g .tif, .jpg, .png.)\nNOTE: Each image must be in the same format with identical file extensions.\n \nAlternatively, You can also input any word that is in all your image names by selecting\n'custom'.\n \nClick OK to continue.");
	Dialog.create("Image format");
	Dialog.addMessage("What is the image format?");
	Dialog.addChoice("Type:", newArray("tif", "tiff", "jpg", "jpeg", "png", "gif", "bmp", "custom"));
	Dialog.show();
	type = Dialog.getChoice();
	if (type == "custom"){//opens image name based on user's input
		Dialog.create("Image name");
		Dialog.addMessage("Please type the word that is common in all images.");
		Dialog.addString("Common letters/words", "");
		Dialog.show();
		word = Dialog.getString();
		for(i=0; i<1; i++){
		filename = dir + list[i];
			if (matches(filename, ".*"+word+".*")){
			open(filename);	
		}
			}
	}else {//opens image based on file name extension
		for(i=0; i<1; i++){
			filename = dir + list[i];
			if (endsWith(filename, type)){
				open(filename);	
			}
			}
		}


/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Total Selection Tutorial 001


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
	nameStore = getTitle();
	waitForUser("4. Select the total area to be analysed","First we need to determine the number and area of the whole tissue.\n \nClick OK to continue.");
	selectWindow(nameStore);
	run("Duplicate...", " ");
	rename("Duplicate");
	waitForUser("5. Apply Gaussian blur to all tissue","A Gaussian blur filter is applied to smooth out the edges of the tissue.\nIf you do not want this filter, enter 0 for 'sigma'. Click 'preview' to sample\nthe level of Gaussian blur.\n \nClick OK to continue.");
	selectWindow("Duplicate");
	run("Gaussian Blur...");
	waitForUser("6. Set the image threshold for all tissue","A threshold is now applied to an 8-bit grayscale image. You may\nselect an automatic threshold parameter, or a set a manual threshold. \n \nClick OK to continue.");
	selectWindow("Duplicate");
	run("8-bit");
	selectWindow("Duplicate");
	Dialog.create("Thresholding");
	Dialog.addMessage("Select automatic or manual threshold");
	Dialog.addChoice("", newArray("Automatic", "Manual"));
	Dialog.show();
	Thresh = Dialog.getChoice();
	if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Huang");
					run("Auto Threshold", "method=Huang white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Li");
					run("Auto Threshold", "method=Li white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Shanbhag");
					run("Auto Threshold", "method=Shanbhag white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Li");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Shanbhag");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
					Dialog.show();
					method = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(method=="Huang"){
						run("Auto Threshold", "method=Huang white");
					}
					if(method=="Li"){
						run("Auto Threshold", "method=Li white");
					}
					if(method=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(method=="Shanbhag"){
						run("Auto Threshold", "method=Shanbhag white");
					}
					if(method=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					waitForUser("7. Set the automatic threshold to all tissue","A threshold will be applied to the images using the tools available\nin Image > Adjust > Auto Threshold. Once selected the threshold\nwill be adjusted on each image based on the method chosen.\n \nClick OK to continue.");
					Lower = "Auto="+method;
					Upper = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else{//manual threshold
					selectWindow("Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(0, 150);
		  			waitForUser("7. Set the manual threshold to all tissue","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the bottom slide bar in the threshold window until most tissue have\nbeen selected. Selected tissue will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
					getThreshold(Lower,Upper);
					selectWindow("Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(10, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				waitForUser("8. Exclusion for all nuclei","To exclude small and large particle and background artifacts, you must now select an upper and lower\nsize exclusion. Test different size exclusion parameters to determine which work best for your images.\nTry a lower size exclusion of 150 pixels and an upper size exclusion of infinity as a starting point.\nYou can also apply a lower and upper circularity exclusion between 0 to 1, where 1 is a perfect circle.\n \nTissue can be segmented by clicking the watershed checkbox.\n \nEdge exclusion can be included to omit any incomplete sections at the edge of the image.\n \nClick OK to continue."); 
				selectWindow("Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				roiManager("Reset");
				particleT();//particle analysis selection
				function particleT(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.addMessage("Would you like to fill holes?");
				Dialog.addCheckbox("fill holes", false);
				Dialog.show();
				lseT = Dialog.getNumber();
				useT = Dialog.getString();
				lceT = Dialog.getNumber();
				uceT = Dialog.getNumber();
				watershedT = Dialog.getCheckbox();
				excludeT = Dialog.getCheckbox();
				fillT = Dialog.getCheckbox();
				selectWindow("Duplicate");
				if (fillT == true){
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
					run("Fill Holes");
				}
				if (watershedT == true){
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
				} else{
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
				}
					run("Watershed");
				}
				if (excludeT == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks exclude add");
				} else {
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks add");
				}
				rename("Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Total Lower Size Exclusion",nResults-1,lseT);
				setResult("Total Upper Size Exclusion",nResults-1,useT);
				setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
				setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
				setResult("Total Watershed",nResults-1,watershedT);
				setResult("Total Edge Exclusion",nResults-1,excludeT);
				setResult("Total Fill Holes",nResults-1,fillT);
				updateResults();
				selectWindow(nameStore);
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow(nameStore);
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Mask");
					close();
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Duplicate");
					particleT();
						} else{
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate");
							close();
							selectWindow("Duplicate2");
							rename("Duplicate");
							}
						} 
				}		
				//records user's final inputs
				lseT = getResult("Total Lower Size Exclusion",nResults-1);
				useT = getResult("Total Upper Size Exclusion",nResults-1);
				lceT = getResult("Total Lower Circularity Exclusion",nResults-1);
				uceT = getResult("Total Upper Circularity Exclusion",nResults-1);
				watershedT = getResult("Total Watershed",nResults-1);
				excludeT = getResult("Total Edge Exclusion",nResults-1);
				fillT = getResult("Total Fill Holes",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				waitForUser("9. Create an overlay of the total tissue selection", "With the exclusion complete, a duplicate overlay image will be produced\nfrom the original image to visualize the accuracy of your selection.\n \nClick OK to continue.");
				selectWindow("Mask");
				if (roiManager("count")!=0) {
					selectWindow(nameStore);
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					rename("Total-Overlay");
					selectWindow(nameStore);
					roiManager("Set Color", "yellow");
				}
				selectWindow("Duplicate");
				close();
				selectWindow("Mask");
				close();
				if(isOpen("ROI Manager")==1){
					selectWindow("ROI Manager");
					run("Close");
				}


/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Positive Selection Tutorial 002


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				selectWindow(nameStore);
				run("Colour Deconvolution", "vectors=[H&E]");
				waitForUser("10. Perform a color deconvolution of the image", "To select for the positive tissue, a color deconvolution with a H&E vector permits the\ndiscrimination of the hematoxylin (purple) and eosinophilic tissue (pink). \n \nThe threshold and exclusion will be performed again to produce the overlay image.\n \nClick OK to continue.");
				wait(1);
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-(Colour_3)");
				close();
				selectWindow(nameStore+"-(Colour_2)");
				close();
				selectWindow(nameStore+"-(Colour_1)");
				rename("Duplicate");
				waitForUser("11. Apply Gaussian blur to positive tissue","A Gaussian blur filter is applied to smooth out the edges of the positive tissue.\nIf you do not want this filter, enter 0 for 'sigma'. Click 'preview' to sample\nthe level of Gaussian blur.\n \nClick OK to continue.");
				selectWindow("Duplicate");
				run("Gaussian Blur...");
				waitForUser("12. Set positive tissue threshold","Once we have applied the blur we will change it to an 8-bit grey-scale image and threshold it.\n \nClick OK to continue");
				run("8-bit");
				selectWindow("Duplicate");
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Huang");
					run("Auto Threshold", "method=Huang white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Li");
					run("Auto Threshold", "method=Li white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Shanbhag");
					run("Auto Threshold", "method=Shanbhag white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Li");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Shanbhag");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
					Dialog.show();
					method = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(method=="Huang"){
						run("Auto Threshold", "method=Huang white");
					}
					if(method=="Li"){
						run("Auto Threshold", "method=Li white");
					}
					if(method=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(method=="Shanbhag"){
						run("Auto Threshold", "method=Shanbhag white");
					}
					if(method=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					waitForUser("13. Set the automatic threshold to positive tissue","A threshold will be applied to the images using the tools available\nin Image > Adjust > Auto Threshold. Once selected the threshold\nwill be adjusted on each image based on the method chosen.\n \nClick OK to continue.");
					Lower = "Auto="+method;
					Upper = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else{//manual threshold
					selectWindow("Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(0, 150);
		  			waitForUser("13. Set the manual threshold to positive tissue","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the bottom slide bar in the threshold window until most tissue have\nbeen selected. Selected tissue will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
					getThreshold(Lower,Upper);
					selectWindow("Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(10, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				waitForUser("14. Exclusion for positive tissue","To exclude small and large particle and background artifacts, you must now select an upper and lower\nsize exclusion. Test different size exclusion parameters to determine which work best for your images.\nTry a lower size exclusion of 150 pixels and an upper size exclusion of infinity as a starting point.\nYou can also apply a lower and upper circularity exclusion between 0 to 1, where 1 is a perfect circle.\n \nTissue can be segmented by clicking the watershed checkbox.\n \nEdge exclusion can be included to omit any incomplete sections at the edge of the image.\n \nClick OK to continue."); 
				selectWindow("Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				roiManager("Reset");
				particleP();//particle analysis selection
				function particleP(){
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
				Dialog.addMessage("Would you like to fill holes?");
				Dialog.addCheckbox("fill holes", false);
				Dialog.show();
				lseP = Dialog.getNumber();
				useP = Dialog.getString();
				lceP = Dialog.getNumber();
				uceP = Dialog.getNumber();
				watershedP = Dialog.getCheckbox();
				excludeP = Dialog.getCheckbox();
				fillP = Dialog.getCheckbox();
				selectWindow("Duplicate");
				if (fillP == true){
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
					run("Fill Holes");
				}
				if (watershedP == true){
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
				} else{
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
				}
					run("Watershed");
				}
				if (excludeP == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks exclude add");
				} else {
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks add");
				}
				rename("Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Positive Lower Size Exclusion",nResults-1,lseP);
				setResult("Positive Upper Size Exclusion",nResults-1,useP);
				setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
				setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
				setResult("Positive Watershed",nResults-1,watershedP);
				setResult("Positive Edge Exclusion",nResults-1,excludeP);
				setResult("Positive Fill Holes",nResults-1,fillP);
				updateResults();
				selectWindow(nameStore);
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow(nameStore);
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Mask");
					close();
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Duplicate");
					particleP();
						} else{
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate");
							close();
							selectWindow("Duplicate2");
							rename("Duplicate");
							}
						} 
				}		
				//records user's final inputs
				lseP = getResult("Positive Lower Size Exclusion",nResults-1);
				useP = getResult("Positive Upper Size Exclusion",nResults-1);
				lceP = getResult("Positive Lower Circularity Exclusion",nResults-1);
				uceP = getResult("Positive Upper Circularity Exclusion",nResults-1);
				watershedP = getResult("Positive Watershed",nResults-1);
				excludeP = getResult("Positive Edge Exclusion",nResults-1);
				fillP = getResult("Positive Fill Holes",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Mask");
				run("Measure");
				if (roiManager("count")!=0) {
					selectWindow(nameStore);
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "green");
					run("Flatten");
					rename("Positive-Overlay");
					selectWindow(nameStore);
					roiManager("Set Color", "yellow");
				}
				selectWindow("Duplicate");
				close();
				selectWindow("Mask");
				close();
				if(isOpen("ROI Manager")==1){
					selectWindow("ROI Manager");
					run("Close");
				}



/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Total Selection Enhanced Tutorial 003


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				selectWindow(nameStore);
				waitForUser("15. Enhancing contrast","A color filter can be applied to enhance contrast and\nimprove color discrimination when selecting for all\ntissue and for positive tissue.\n \nClick OK to continue");
				wait(1);
				waitForUser("16. Apply a color filter to enhance contrast","For total tissue selection, a deuteranope filter and a color deconvolution is\napplied using 'FastRed FastBlue DAB', which will enhance the contrast\nbetween the darker hematoxylin stained section compared to background\neosinophilic tissue.\n \nClick OK to continue.");
				selectWindow(nameStore);
				run("Dichromacy", "simulate=Deuteranope create");
				run("Colour Deconvolution", "vectors=[FastRed FastBlue DAB]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_1)");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_3)");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_2)");
				rename("Duplicate");
				waitForUser("17. Apply Gaussian blur to all tissue","A Gaussian blur filter is applied to smooth out the edges of the tissue.\nIf you do not want this filter, enter 0 for 'sigma'. Click 'preview' to sample\nthe level of Gaussian blur.\n \nClick OK to continue.");
				selectWindow("Duplicate");
				run("Gaussian Blur...");
				run("8-bit");
				Dialog.create("Thresholding");
				Dialog.addMessage("Select automatic or manual threshold");
				Dialog.addChoice("", newArray("Automatic", "Manual"));
				Dialog.show();
				Thresh = Dialog.getChoice();
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Triangle");
					run("Auto Threshold", "method=Triangle white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Moments image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Moments");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Triangle");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Moments","MaxEntropy","Otsu","Triangle","Yen"));
					Dialog.show();
					method = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(method=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(method=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(method=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(method=="Triangle"){
						run("Auto Threshold", "method=Triangle white");
					}
					if(method=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					Lower = "Auto="+method;
					Upper = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else{//manual threshold
					selectWindow("Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(0, 150);
		  			waitForUser("Total Tissue Thresholding","Select for all tissue using the bottom slide bar in\nthe Threshold window. Click OK to proceed.");
					getThreshold(Lower,Upper);
					selectWindow("Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(10, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				selectWindow("Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				roiManager("Reset");
				particleT();//particle analysis selection
				function particleT(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.addMessage("Would you like to fill holes?");
				Dialog.addCheckbox("fill holes", false);
				Dialog.show();
				lseT = Dialog.getNumber();
				useT = Dialog.getString();
				lceT = Dialog.getNumber();
				uceT = Dialog.getNumber();
				watershedT = Dialog.getCheckbox();
				excludeT = Dialog.getCheckbox();
				fillT = Dialog.getCheckbox();
				selectWindow("Duplicate");
				if (fillT == true){
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
					run("Fill Holes");
				}
				if (watershedT == true){
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
				} else{
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
				}
					run("Watershed");
				}
				if (excludeT == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks exclude add");
				} else {
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks add");
				}
				rename("Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Total Lower Size Exclusion",nResults-1,lseT);
				setResult("Total Upper Size Exclusion",nResults-1,useT);
				setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
				setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
				setResult("Total Watershed",nResults-1,watershedT);
				setResult("Total Edge Exclusion",nResults-1,excludeT);
				setResult("Total Fill Holes",nResults-1,fillT);
				updateResults();
				selectWindow(nameStore);
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow(nameStore);
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Mask");
					close();
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Duplicate");
					particleT();
						} else{
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate");
							close();
							selectWindow("Duplicate2");
							rename("Duplicate");
							}
						} 
				}		
				//records user's final inputs
				lseT = getResult("Total Lower Size Exclusion",nResults-1);
				useT = getResult("Total Upper Size Exclusion",nResults-1);
				lceT = getResult("Total Lower Circularity Exclusion",nResults-1);
				uceT = getResult("Total Upper Circularity Exclusion",nResults-1);
				watershedT = getResult("Total Watershed",nResults-1);
				excludeT = getResult("Total Edge Exclusion",nResults-1);
				fillT = getResult("Total Fill Holes",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				run("Measure");
				if (roiManager("count")!=0) {
					selectWindow(nameStore);
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					rename("Total-Overlay-Enhanced");
					selectWindow(nameStore);
					roiManager("Set Color", "yellow");
				}
				selectWindow("Duplicate");
				close();
				selectWindow("Mask");
				close();
				if(isOpen("ROI Manager")==1){
					selectWindow("ROI Manager");
					run("Close");
					}

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Positive Selection Enhanced Tutorial 004


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				selectWindow(nameStore);
				waitForUser("18. Enhance image contrast for positive hematoxylin selection.","H&E staining can be quite varied and color discrimination can be challenging\nusing a simple color deconvolution. Thus, a tritanopia filter is applied to\nenhance the contrast between purple and pink before proceeding with the\ncolor deconvolution under the H&E DAB vector.\n \nClick OK to continue.");
				run("Dichromacy", "simulate=Tritanope create");
				run("Colour Deconvolution", "vectors=[H&E DAB]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_3)");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_2)");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_1)");
				rename("Duplicate");
				waitForUser("19. Apply Gaussian blur to positive tissue","A Gaussian blur filter is applied to smooth out the edges of the tissue.\nIf you do not want this filter, enter 0 for 'sigma'. Click 'preview' to sample\nthe level of Gaussian blur.\n \nClick OK to continue.");
				selectWindow("Duplicate");
				run("Gaussian Blur...");
				run("8-bit");
				if (Thresh == "Automatic"){//automatic threshold selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Intermodes");
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Intermodes image3=MaxEntropy image4=Otsu image5=Moments image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Intermodes");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Moments");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Intermodes","MaxEntropy","Otsu","Moments","Yen"));
					Dialog.show();
					method = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(method=="Intermodes"){
						run("Auto Threshold", "method=Intermodes white");
					}
					if(method=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(method=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(method=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(method=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					Lower = "Auto="+method;
					Upper = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else{//manual threshold
					selectWindow("Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(0, 150);
		  			waitForUser("Positive Tissue Thresholding","Select for positive tissue using the bottom slide\nbar in the Threshold window. Click OK to proceed."); 
					getThreshold(Lower,Upper);
					selectWindow("Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(10, 255);
				}
				run("Set Measurements...", "area limit redirect=None decimal=3");
				selectWindow("Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				roiManager("Reset");
				particleP();//particle analysis selection
				function particleP(){
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
				Dialog.addMessage("Would you like to fill holes?");
				Dialog.addCheckbox("fill holes", false);
				Dialog.show();
				lseP = Dialog.getNumber();
				useP = Dialog.getString();
				lceP = Dialog.getNumber();
				uceP = Dialog.getNumber();
				watershedP = Dialog.getCheckbox();
				excludeP = Dialog.getCheckbox();
				fillP = Dialog.getCheckbox();
				selectWindow("Duplicate");
				if (fillP == true){
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
					run("Fill Holes");
				}
				if (watershedP == true){
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
				} else{
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
				}
					run("Watershed");
				}
				if (excludeP == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks exclude add");
				} else {
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks add");
				}
				rename("Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");//records user's input
				setResult("Positive Lower Size Exclusion",nResults-1,lseP);
				setResult("Positive Upper Size Exclusion",nResults-1,useP);
				setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
				setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
				setResult("Positive Watershed",nResults-1,watershedP);
				setResult("Positive Edge Exclusion",nResults-1,excludeP);
				setResult("Positive Fill Holes",nResults-1,fillP);
				updateResults();
				selectWindow(nameStore);
				roiManager("Show All without labels");	
				Dialog.create("Retry exclusion?");
				Dialog.addMessage("Are you happy with the selection?");
				Dialog.addChoice("Type:", newArray("yes", "no"));
				Dialog.show();
				retry = Dialog.getChoice();
				selectWindow(nameStore);
				roiManager("Show None");
				if(retry=="no"){//removes user's inputs and restarts particle analysis
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Mask");
					close();
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Duplicate");
					particleP();
						} else{
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate");
							close();
							selectWindow("Duplicate2");
							rename("Duplicate");
							}
						} 
				}		
				//records user's final inputs
				lseP = getResult("Positive Lower Size Exclusion",nResults-1);
				useP = getResult("Positive Upper Size Exclusion",nResults-1);
				lceP = getResult("Positive Lower Circularity Exclusion",nResults-1);
				uceP = getResult("Positive Upper Circularity Exclusion",nResults-1);
				watershedP = getResult("Positive Watershed",nResults-1);
				excludeP = getResult("Positive Edge Exclusion",nResults-1);
				fillP = getResult("Positive Fill Holes",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				run("Measure");
				if (roiManager("count")!=0) {
					selectWindow(nameStore);
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "green");
					run("Flatten");
					rename("Positive-Overlay-Enhanced");
					selectWindow(nameStore);
					roiManager("Set Color", "yellow");
				}
				selectWindow("Duplicate");
				close();
				selectWindow("Mask");
				close();
				if(isOpen("ROI Manager")==1){
					selectWindow("ROI Manager");
					run("Close");
				}
				selectWindow(nameStore);
				run("Duplicate...", " ");
				rename("Original");
				run("RGB Color");
				run("Concatenate...", "  title=Stacks image1=Original image2=Total-Overlay image3=Positive-Overlay image4=Original image5=Total-Overlay-Enhanced image6=Positive-Overlay-Enhanced");
				setSlice(1); 
				setMetadata("Original");
				setSlice(2);
				setMetadata("Total-Overlay");
				setSlice(3);
				setMetadata("Positive-Overlay");
				setSlice(4);
				setMetadata("Original");
				setSlice(5);
				setMetadata("Total-Overlay-Enhanced");
				setSlice(6);
				setMetadata("Positive-Overlay-Enhanced");
				run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
				waitForUser("20. Compare basic and enhanced methods for selection", "Now compare the basic and enhanced methods of selection in the generated image montage.\n \nOnce you have selected the best method, the tutorial will guide you through testing the remaining\nimages in the test folder.\n \nClick OK to proceed.");
				if(isOpen("Results")==1){
				selectWindow("Results");
				run("Close");
				}
				if(isOpen("ROI Manager")==1){
					selectWindow("ROI Manager");
					run("Close");
				}
				run("Close All");				
				waitForUser("21. Set the scale", "Optional: If you know the units for each pixel in the images you can now set the\nscale. For more detail refer to https://imagej.net/SpatialCalibration.\n \nWhen you click OK, a dialog box will appear for you to set the scale, if you do not\nknow the pixel length and distance simply click OK. You can also set a scale later\nduring analysis.\n \nClick OK to proceed.");
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


Tutorial Optimization 005


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
Dialog.create("Selection method");
Dialog.addMessage("Select basic or enhanced method for selection");
Dialog.addChoice("Total selection:", newArray("Basic", "Enhanced"));
Dialog.addChoice("Positive selection", newArray("Basic", "Enhanced"));
Dialog.show();
total = Dialog.getChoice();
positive = Dialog.getChoice();
tableTitle="H&E Optimization";
tableTitle2="["+tableTitle+"]";
run("Table...", "name="+tableTitle2+" width=400 height=250");
print(tableTitle2,"\\Headings:Image name\tTotal Selection\tPositive Selection\tThreshold\tTotal Gaussian Blur\tTotal Lower Threshold\tTotal Upper Threshold\tTotal Lower Size Exclusion\tTotal Upper Size Exclusion\tTotal Lower Circularity Exclusion\tTotal Upper Circularity Exclusio\tTotal Watershed\tTotal Edge Exclusion\tTotal Fill Holes\tPositive Gaussian Blur\tPositive Lower Threshold\tPositive Upper Threshold\tPositive Lower Size Exclusion\tPositive Upper Size Exclusion\tPositive Lower Circularity Exclusion\tPositive Upper Circularity Exclusion\tPositive Watershed\tPositive Edge Exclusion\tPositive Fill Holes");
if (type == "custom"){
	
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Total Selection Optimization 006


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/	
	for(i=0; i<list.length; i++){
		filename = dir + list[i];
		if (matches(filename, ".*"+word+".*")){
			open(filename);
			nameStore = getTitle();
			if(total=="Enhanced"){//if "enhanced" was selected for total selection
				run("Dichromacy", "simulate=Deuteranope create");
				run("Colour Deconvolution", "vectors=[FastRed FastBlue DAB]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_1)");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_3)");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_2)");
				rename("Duplicate");
			} else {//if "basic" was selected for total selection
				run("Duplicate...", " ");
				rename("Duplicate");
			}
			selectWindow("Duplicate");
			run("Gaussian Blur...");	
			sigmaT = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
			run("8-bit");
			selectWindow("Duplicate");
			Dialog.create("Thresholding");
			Dialog.addMessage("Select automatic or manual threshold");
			Dialog.addChoice("", newArray("Automatic", "Manual"));
			Dialog.show();
			Thresh = Dialog.getChoice();
			if (Thresh == "Automatic"){//automatic threshold selection
				if(total=="Enhanced"){//if "enhanced" was selected for total selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Triangle");
					run("Auto Threshold", "method=Triangle white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Moments image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Moments");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Triangle");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Moments","MaxEntropy","Otsu","Triangle","Yen"));
					Dialog.show();
					methodT = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodT=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodT=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodT=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodT=="Triangle"){
						run("Auto Threshold", "method=Triangle white");
					}
					if(methodT=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerT = "Auto="+methodT;
					UpperT = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for total selection
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Li");
								run("Auto Threshold", "method=Li white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Otsu");
								run("Auto Threshold", "method=Otsu white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Shanbhag");
								run("Auto Threshold", "method=Shanbhag white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Shanbhag");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
								Dialog.show();
								methodT = Dialog.getChoice();
								selectWindow("Montage");
								close();
								selectWindow("Stacks");
								close();
								selectWindow("Duplicate");
								if(methodT=="Huang"){
									run("Auto Threshold", "method=Huang white");
								}
								if(methodT=="Li"){
									run("Auto Threshold", "method=Li white");
								}
								if(methodT=="Otsu"){
									run("Auto Threshold", "method=Otsu white");
								}
								if(methodT=="Shanbhag"){
									run("Auto Threshold", "method=Shanbhag white");
								}
								if(methodT=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								LowerT = "Auto="+methodT;
								UpperT = "NaN";
									run("Invert LUT");
									setThreshold(0, 254);
				}
			} else{//manual threshold
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
								waitForUser("Total Tissue Thresholding","Select for all tissue using the bottom slide bar in\nthe Threshold window. Click OK to proceed.");
								getThreshold(LowerT,UpperT);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
				}
								run("Set Measurements...", "area limit redirect=None decimal=3");
								selectWindow("Duplicate");
								run("Measure");
								IJ.deleteRows(nResults-1, nResults-1);
								roiManager("Reset");
								particleT();//particle analysis selection
								function particleT(){
								Dialog.create("Size and Circularity Exclusion");
								Dialog.addMessage("Enter the value (in pixel size) for\nthe exclusion in the particle analysis");
								Dialog.addNumber("Lower size exclusion:", 0);
								Dialog.addString("Upper size exclusion:", "infinity");
								Dialog.addNumber("Lower circularity exclusion:", 0.00);
								Dialog.addNumber("Upper circularity exclusion:", 1.00);
								Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
								Dialog.addCheckbox("watershed", true);
								Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
								Dialog.addCheckbox("exclude", true);
								Dialog.addMessage("Would you like to fill holes?");
								Dialog.addCheckbox("fill holes", false);
								Dialog.show();
								lseT = Dialog.getNumber();
								useT = Dialog.getString();
								lceT = Dialog.getNumber();
								uceT = Dialog.getNumber();
								watershedT = Dialog.getCheckbox();
								excludeT = Dialog.getCheckbox();
								fillT = Dialog.getCheckbox();
								selectWindow("Duplicate");
								if (fillT == true){
									selectWindow("Duplicate");
									run("Duplicate...", "title=Duplicate2");
									run("Fill Holes");
								}
								if (watershedT == true){
									if (isOpen("Duplicate2")==1){
									selectWindow("Duplicate2");
								} else{
									selectWindow("Duplicate");
									run("Duplicate...", "title=Duplicate2");
								}
									run("Watershed");
								}
								if (excludeT == true){
									IJ.redirectErrorMessages();
									run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks exclude add");
								} else {
									IJ.redirectErrorMessages();
									run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks add");
								}
								rename("Mask");
								if(isOpen("Log")==1){
									selectWindow("Log");
									run("Close");
									}
								run("Measure");//records user's input
								setResult("Total Lower Size Exclusion",nResults-1,lseT);
								setResult("Total Upper Size Exclusion",nResults-1,useT);
								setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
								setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
								setResult("Total Watershed",nResults-1,watershedT);
								setResult("Total Edge Exclusion",nResults-1,excludeT);
								setResult("Total Fill Holes",nResults-1,fillT);
								updateResults();
								selectWindow(nameStore);
								roiManager("Show All without labels");	
								Dialog.create("Retry exclusion?");
								Dialog.addMessage("Are you happy with the selection?");
								Dialog.addChoice("Type:", newArray("yes", "no"));
								Dialog.show();
								retry = Dialog.getChoice();
								selectWindow(nameStore);
								roiManager("Show None");
								if(retry=="no"){//removes user's inputs and restarts particle analysis
									IJ.deleteRows(nResults-1, nResults-1);
									selectWindow("Mask");
									close();
									if (isOpen("Duplicate2")==1){
									selectWindow("Duplicate2");
									close();
									}
									roiManager("Reset");
									selectWindow("Duplicate");
									particleT();
										} else{
											if (isOpen("Duplicate2")==1){
											selectWindow("Duplicate");
											close();
											selectWindow("Duplicate2");
											rename("Duplicate");
											}
										} 
								}		
								//records user's final inputs
								lseT = getResult("Total Lower Size Exclusion",nResults-1);
								useT = getResult("Total Upper Size Exclusion",nResults-1);
								lceT = getResult("Total Lower Circularity Exclusion",nResults-1);
								uceT = getResult("Total Upper Circularity Exclusion",nResults-1);
								watershedT = getResult("Total Watershed",nResults-1);
								excludeT = getResult("Total Edge Exclusion",nResults-1);
								fillT = getResult("Total Fill Holes",nResults-1);
								IJ.deleteRows(nResults-1, nResults-1);
								run("Measure");
								if (roiManager("count")!=0) {
									roiManager("Save",  dir+nameStore+" - Total.zip");
									selectWindow("Mask");
									rename("Mask");
									selectWindow(nameStore);
									roiManager("Show All without labels");
									roiManager("Set Fill Color", "red");
									run("Flatten");
									saveAs("Tiff", dir+nameStore+" - Total Overlay");
									selectWindow(nameStore);
									roiManager("Set Color", "yellow");
									}
								selectWindow(nameStore);
								close("\\Others");
								if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
								}
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
			
			
			
Positive Selection Optimization 007
			
			
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
			selectWindow(nameStore);
			IJ.deleteRows(nResults-1, nResults-1);
			if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
				run("Dichromacy", "simulate=Tritanope create");
				run("Colour Deconvolution", "vectors=[H&E DAB]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_3)");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_2)");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_1)");
				rename("Duplicate");
			} else {//if "basic" was selected for positive selection
				run("Colour Deconvolution", "vectors=[H&E]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-(Colour_3)");
				close();
				selectWindow(nameStore+"-(Colour_2)");
				close();
				selectWindow(nameStore+"-(Colour_1)");
				rename("Duplicate");
			}
			
			selectWindow("Duplicate");
			run("Gaussian Blur...");	
			sigmaP = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
			run("8-bit");
			selectWindow("Duplicate");
			if (Thresh == "Automatic"){//automatic threshold selection
				if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Intermodes");
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Intermodes image3=MaxEntropy image4=Otsu image5=Moments image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Intermodes");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Moments");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Intermodes","MaxEntropy","Otsu","Moments","Yen"));
					Dialog.show();
					methodP = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodP=="Intermodes"){
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodP=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodP=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodP=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodP=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerP = "Auto="+methodP;
					UpperP = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for positive selection
					selectWindow("Duplicate");
							run("Duplicate...", "title=Original");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Huang");
							run("Auto Threshold", "method=Huang white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Li");
							run("Auto Threshold", "method=Li white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Otsu");
							run("Auto Threshold", "method=Otsu white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Shanbhag");
							run("Auto Threshold", "method=Shanbhag white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Yen");
							run("Auto Threshold", "method=Yen white");
							run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
							setSlice(1); 
							setMetadata("Original");
							setSlice(2);
							setMetadata("Huang");
							setSlice(3);
							setMetadata("Li");
							setSlice(4);
							setMetadata("Otsu");
							setSlice(5);
							setMetadata("Shanbhag");
							setSlice(6);
							setMetadata("Yen");
							run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
							Dialog.create("Thresholding");
							Dialog.addMessage("Please select the automatic methodP that you\nwould like to use");
							Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
							Dialog.show();
							methodP = Dialog.getChoice();
							selectWindow("Montage");
							close();
							selectWindow("Stacks");
							close();
							selectWindow("Duplicate");
							if(methodP=="Huang"){
								run("Auto Threshold", "method=Huang white");
							}
							if(methodP=="Li"){
								run("Auto Threshold", "method=Li white");
							}
							if(methodP=="Otsu"){
								run("Auto Threshold", "method=Otsu white");
							}
							if(methodP=="Shanbhag"){
								run("Auto Threshold", "method=Shanbhag white");
							}
							if(methodP=="Yen"){
								run("Auto Threshold", "method=Yen white");
							}
							LowerP = "Auto="+methodP;
							UpperP = "NaN";
								run("Invert LUT");
								setThreshold(0, 254);
					}//end of else for 'basic' auto threshold of positive 
						}else{//manual threshold
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
								waitForUser("Positive Tissue Thresholding","Select for positive tissue using the bottom slide\nbar in the Threshold window. Click OK to proceed."); 
								getThreshold(LowerP,UpperP);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
							}
							run("Set Measurements...", "area limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particleP();//particle analysis selection
							function particleP(){
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
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lseP = Dialog.getNumber();
							useP = Dialog.getString();
							lceP = Dialog.getNumber();
							uceP = Dialog.getNumber();
							watershedP = Dialog.getCheckbox();
							excludeP = Dialog.getCheckbox();
							fillP = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillP == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershedP == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (excludeP == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks exclude add");
							} else {
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");//records user's input
							setResult("Positive Lower Size Exclusion",nResults-1,lseP);
							setResult("Positive Upper Size Exclusion",nResults-1,useP);
							setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
							setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
							setResult("Positive Watershed",nResults-1,watershedP);
							setResult("Positive Edge Exclusion",nResults-1,excludeP);
							setResult("Positive Fill Holes",nResults-1,fillP);
							updateResults();
							selectWindow(nameStore);
							roiManager("Show All without labels");	
							Dialog.create("Retry exclusion?");
							Dialog.addMessage("Are you happy with the selection?");
							Dialog.addChoice("Type:", newArray("yes", "no"));
							Dialog.show();
							retry = Dialog.getChoice();
							selectWindow(nameStore);
							roiManager("Show None");
							if(retry=="no"){//removes user's inputs and restarts particle analysis
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particleP();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							//records user's final inputs
							lseP = getResult("Positive Lower Size Exclusion",nResults-1);
							useP = getResult("Positive Upper Size Exclusion",nResults-1);
							lceP = getResult("Positive Lower Circularity Exclusion",nResults-1);
							uceP = getResult("Positive Upper Circularity Exclusion",nResults-1);
							watershedP = getResult("Positive Watershed",nResults-1);
							excludeP = getResult("Positive Edge Exclusion",nResults-1);
							fillP = getResult("Positive Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							run("Measure");
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Positive.zip");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "green");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Positive Overlay");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							}
							run("Close All");
							if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
								}
			//prints out user's adjustment in results table and in adjustment table	
				setResult("Total Gaussian Blur",nResults-1,sigmaT);
				setResult("Total Lower Threshold",nResults-1,LowerT);
				setResult("Total Upper Threshold",nResults-1,UpperT);
				setResult("Total Lower Size Exclusion",nResults-1,lseT);
				setResult("Total Upper Size Exclusion",nResults-1,useT);
				setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
				setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
				setResult("Total Watershed",nResults-1,watershedT);
				setResult("Total Edge Exclusion",nResults-1,excludeT);
				setResult("Total Fill Holes",nResults-1,fillT);
				setResult("Positive Gaussian Blur",nResults-1,sigmaP);
				setResult("Positive Lower Threshold",nResults-1,LowerP);
				setResult("Positive Upper Threshold",nResults-1,UpperP);
				setResult("Positive Lower Size Exclusion",nResults-1,lseP);
				setResult("Positive Upper Size Exclusion",nResults-1,useP);
				setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
				setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
				setResult("Positive Watershed",nResults-1,watershedP);
				setResult("Positive Edge Exclusion",nResults-1,excludeP);
				setResult("Positive Fill Holes",nResults-1,fillP);
				updateResults();
				if(watershedT==1){
				watershedT = "TRUE";
				} else {
					watershedT = "FALSE";
				}
				if(excludeT==1){
					excludeT = "TRUE";
				} else {
					excludeT = "FALSE";
				}
				if(fillT==1){
					fillT = "TRUE";
				} else {
					fillT = "FALSE";
				}
				if(watershedP==1){
					watershedP = "TRUE";
				} else {
					watershedP = "FALSE";
				}
				if(excludeP==1){
					excludeP = "TRUE";
				} else {
					excludeP = "FALSE";
				}
				if(fillP==1){
					fillP = "TRUE";
				} else {
					fillP = "FALSE";
				}
				print(tableTitle2, nameStore + "\t"  + total + "\t"  + positive + "\t"  + Thresh + "\t"  + sigmaT + "\t"  + LowerT + "\t"  + UpperT + "\t"  + lseT + "\t"  + useT + "\t"  + lceT + "\t" + uceT + "\t"  + watershedT + "\t"  + excludeT + "\t"  + fillT + "\t"  + sigmaP + "\t"  + LowerP + "\t"  + UpperP + "\t"  + lseP + "\t"  + useP + "\t"  + lceP + "\t"  + uceP + "\t"  + watershedP + "\t"  + excludeP + "\t"  + fillP);	
							}//end of if condition for opening files based on custom name
					}//end of for loop 
	}else {//opens image based on file name extension
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Total Selection Optimization 008


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/		
		for(i=0; i<list.length; i++){
			filename = dir + list[i];
			if (endsWith(filename, type)){
				open(filename);	
				nameStore = getTitle();
		if(total=="Enhanced"){//if "enhanced" was selected for total selection
			run("Dichromacy", "simulate=Deuteranope create");
			run("Colour Deconvolution", "vectors=[FastRed FastBlue DAB]");
			selectWindow("Colour Deconvolution");
			close();
			selectWindow(nameStore+"-Deuteranope-(Colour_1)");
			close();
			selectWindow(nameStore+"-Deuteranope-(Colour_3)");
			close();
			selectWindow(nameStore+"-Deuteranope-(Colour_2)");
			rename("Duplicate");
		} else {//if "basic" was selected for total selection
			run("Duplicate...", " ");
			rename("Duplicate");
		}
		selectWindow("Duplicate");
		run("Gaussian Blur...");	
		sigmaT = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
		run("8-bit");
		selectWindow("Duplicate");
		Dialog.create("Thresholding");
		Dialog.addMessage("Select automatic or manual threshold");
		Dialog.addChoice("", newArray("Automatic", "Manual"));
		Dialog.show();
		Thresh = Dialog.getChoice();
		if (Thresh == "Automatic"){//automatic threshold selection
				if(total=="Enhanced"){//if "enhanced" was selected for total selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Triangle");
					run("Auto Threshold", "method=Triangle white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Moments image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Moments");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Triangle");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Moments","MaxEntropy","Otsu","Triangle","Yen"));
					Dialog.show();
					methodT = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodT=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodT=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodT=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodT=="Triangle"){
						run("Auto Threshold", "method=Triangle white");
					}
					if(methodT=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerT = "Auto="+methodT;
					UpperT = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for total selection
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Li");
								run("Auto Threshold", "method=Li white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Otsu");
								run("Auto Threshold", "method=Otsu white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Shanbhag");
								run("Auto Threshold", "method=Shanbhag white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Shanbhag");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
								Dialog.show();
								methodT = Dialog.getChoice();
								selectWindow("Montage");
								close();
								selectWindow("Stacks");
								close();
								selectWindow("Duplicate");
								if(methodT=="Huang"){
									run("Auto Threshold", "method=Huang white");
								}
								if(methodT=="Li"){
									run("Auto Threshold", "method=Li white");
								}
								if(methodT=="Otsu"){
									run("Auto Threshold", "method=Otsu white");
								}
								if(methodT=="Shanbhag"){
									run("Auto Threshold", "method=Shanbhag white");
								}
								if(methodT=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								LowerT = "Auto="+methodT;
								UpperT = "NaN";
									run("Invert LUT");
									setThreshold(0, 254);
				}
		} else{//manual threshold
							selectWindow("Duplicate");
							setAutoThreshold("Default dark");
							run("Threshold...");
							setThreshold(0, 150);
							waitForUser("Total Tissue Thresholding","Select for all tissue using the bottom slide bar in\nthe Threshold window. Click OK to proceed.");
							getThreshold(LowerT,UpperT);
							selectWindow("Duplicate");
							setOption("BlackBackground", true);
							run("Convert to Mask");
							setThreshold(10, 255);
			}
							run("Set Measurements...", "area limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particleT();//particle analysis selection
							function particleT(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lseT = Dialog.getNumber();
							useT = Dialog.getString();
							lceT = Dialog.getNumber();
							uceT = Dialog.getNumber();
							watershedT = Dialog.getCheckbox();
							excludeT = Dialog.getCheckbox();
							fillT = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillT == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershedT == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (excludeT == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks exclude add");
							} else {
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");//records user's input
							setResult("Total Lower Size Exclusion",nResults-1,lseT);
							setResult("Total Upper Size Exclusion",nResults-1,useT);
							setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
							setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
							setResult("Total Watershed",nResults-1,watershedT);
							setResult("Total Edge Exclusion",nResults-1,excludeT);
							setResult("Total Fill Holes",nResults-1,fillT);
							updateResults();
							selectWindow(nameStore);
							roiManager("Show All without labels");	
							Dialog.create("Retry exclusion?");
							Dialog.addMessage("Are you happy with the selection?");
							Dialog.addChoice("Type:", newArray("yes", "no"));
							Dialog.show();
							retry = Dialog.getChoice();
							selectWindow(nameStore);
							roiManager("Show None");
							if(retry=="no"){//removes user's inputs and restarts particle analysis
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particleT();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							//records user's final inputs
							lseT = getResult("Total Lower Size Exclusion",nResults-1);
							useT = getResult("Total Upper Size Exclusion",nResults-1);
							lceT = getResult("Total Lower Circularity Exclusion",nResults-1);
							uceT = getResult("Total Upper Circularity Exclusion",nResults-1);
							watershedT = getResult("Total Watershed",nResults-1);
							excludeT = getResult("Total Edge Exclusion",nResults-1);
							fillT = getResult("Total Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							run("Measure");
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Total.zip");
								selectWindow("Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "red");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Total Overlay");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
								}
							selectWindow(nameStore);
							close("\\Others");
							if(isOpen("ROI Manager")==1){
							selectWindow("ROI Manager");
							run("Close");
							}
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
		
		
		
Positive Selection Optimization 009
		
		
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
		selectWindow(nameStore);
		IJ.deleteRows(nResults-1, nResults-1);
		if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
			run("Dichromacy", "simulate=Tritanope create");
			run("Colour Deconvolution", "vectors=[H&E DAB]");
			selectWindow("Colour Deconvolution");
			close();
			selectWindow(nameStore+"-Tritanope-(Colour_3)");
			close();
			selectWindow(nameStore+"-Tritanope-(Colour_2)");
			close();
			selectWindow(nameStore+"-Tritanope-(Colour_1)");
			rename("Duplicate");
		} else {//if "basic" was selected for positive selection
			run("Colour Deconvolution", "vectors=[H&E]");
			selectWindow("Colour Deconvolution");
			close();
			selectWindow(nameStore+"-(Colour_3)");
			close();
			selectWindow(nameStore+"-(Colour_2)");
			close();
			selectWindow(nameStore+"-(Colour_1)");
			rename("Duplicate");
		}
		
		selectWindow("Duplicate");
		run("Gaussian Blur...");	
		sigmaP = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
		run("8-bit");
		selectWindow("Duplicate");
		if (Thresh == "Automatic"){//automatic threshold selection
			if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Intermodes");
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Intermodes image3=MaxEntropy image4=Otsu image5=Moments image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Intermodes");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Moments");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Intermodes","MaxEntropy","Otsu","Moments","Yen"));
					Dialog.show();
					methodP = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodP=="Intermodes"){
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodP=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodP=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodP=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodP=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerP = "Auto="+methodP;
					UpperP = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for positive selection
					selectWindow("Duplicate");
							run("Duplicate...", "title=Original");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Huang");
							run("Auto Threshold", "method=Huang white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Li");
							run("Auto Threshold", "method=Li white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Otsu");
							run("Auto Threshold", "method=Otsu white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Shanbhag");
							run("Auto Threshold", "method=Shanbhag white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Yen");
							run("Auto Threshold", "method=Yen white");
							run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
							setSlice(1); 
							setMetadata("Original");
							setSlice(2);
							setMetadata("Huang");
							setSlice(3);
							setMetadata("Li");
							setSlice(4);
							setMetadata("Otsu");
							setSlice(5);
							setMetadata("Shanbhag");
							setSlice(6);
							setMetadata("Yen");
							run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
							Dialog.create("Thresholding");
							Dialog.addMessage("Please select the automatic methodP that you\nwould like to use");
							Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
							Dialog.show();
							methodP = Dialog.getChoice();
							selectWindow("Montage");
							close();
							selectWindow("Stacks");
							close();
							selectWindow("Duplicate");
							if(methodP=="Huang"){
								run("Auto Threshold", "method=Huang white");
							}
							if(methodP=="Li"){
								run("Auto Threshold", "method=Li white");
							}
							if(methodP=="Otsu"){
								run("Auto Threshold", "method=Otsu white");
							}
							if(methodP=="Shanbhag"){
								run("Auto Threshold", "method=Shanbhag white");
							}
							if(methodP=="Yen"){
								run("Auto Threshold", "method=Yen white");
							}
							LowerP = "Auto="+methodP;
							UpperP = "NaN";
								run("Invert LUT");
								setThreshold(0, 254);
					}//end of else for 'basic' auto threshold of positive 
				}else{//manual threshold
							selectWindow("Duplicate");
							setAutoThreshold("Default dark");
							run("Threshold...");
							setThreshold(0, 150);
							waitForUser("Positive Tissue Thresholding","Select for positive tissue using the bottom slide\nbar in the Threshold window. Click OK to proceed."); 
							getThreshold(LowerP,UpperP);
							selectWindow("Duplicate");
							setOption("BlackBackground", true);
							run("Convert to Mask");
							setThreshold(10, 255);
			}
			
						run("Set Measurements...", "area limit redirect=None decimal=3");
						selectWindow("Duplicate");
						run("Measure");
						IJ.deleteRows(nResults-1, nResults-1);
						roiManager("Reset");
						particleP();//particle analysis selection
						function particleP(){
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
						Dialog.addMessage("Would you like to fill holes?");
						Dialog.addCheckbox("fill holes", false);
						Dialog.show();
						lseP = Dialog.getNumber();
						useP = Dialog.getString();
						lceP = Dialog.getNumber();
						uceP = Dialog.getNumber();
						watershedP = Dialog.getCheckbox();
						excludeP = Dialog.getCheckbox();
						fillP = Dialog.getCheckbox();
						selectWindow("Duplicate");
						if (fillP == true){
							selectWindow("Duplicate");
							run("Duplicate...", "title=Duplicate2");
							run("Fill Holes");
						}
						if (watershedP == true){
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate2");
						} else{
							selectWindow("Duplicate");
							run("Duplicate...", "title=Duplicate2");
						}
							run("Watershed");
						}
						if (excludeP == true){
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks exclude add");
						} else {
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks add");
						}
						rename("Mask");
						if(isOpen("Log")==1){
							selectWindow("Log");
							run("Close");
							}
						run("Measure");//records user's input
						setResult("Positive Lower Size Exclusion",nResults-1,lseP);
						setResult("Positive Upper Size Exclusion",nResults-1,useP);
						setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
						setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
						setResult("Positive Watershed",nResults-1,watershedP);
						setResult("Positive Edge Exclusion",nResults-1,excludeP);
						setResult("Positive Fill Holes",nResults-1,fillP);
						updateResults();
						selectWindow(nameStore);
						roiManager("Show All without labels");	
						Dialog.create("Retry exclusion?");
						Dialog.addMessage("Are you happy with the selection?");
						Dialog.addChoice("Type:", newArray("yes", "no"));
						Dialog.show();
						retry = Dialog.getChoice();
						selectWindow(nameStore);
						roiManager("Show None");
						if(retry=="no"){//removes user's inputs and restarts particle analysis
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							close();
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate2");
							close();
							}
							roiManager("Reset");
							selectWindow("Duplicate");
							particleP();
								} else{
									if (isOpen("Duplicate2")==1){
									selectWindow("Duplicate");
									close();
									selectWindow("Duplicate2");
									rename("Duplicate");
									}
								} 
						}		
						//records user's final inputs
						lseP = getResult("Positive Lower Size Exclusion",nResults-1);
						useP = getResult("Positive Upper Size Exclusion",nResults-1);
						lceP = getResult("Positive Lower Circularity Exclusion",nResults-1);
						uceP = getResult("Positive Upper Circularity Exclusion",nResults-1);
						watershedP = getResult("Positive Watershed",nResults-1);
						excludeP = getResult("Positive Edge Exclusion",nResults-1);
						fillP = getResult("Positive Fill Holes",nResults-1);
						IJ.deleteRows(nResults-1, nResults-1);
						run("Measure");
						if (roiManager("count")!=0) {
							roiManager("Save",  dir+nameStore+" - Positive.zip");
							selectWindow(nameStore);
							roiManager("Show All without labels");
							roiManager("Set Fill Color", "green");
							run("Flatten");
							saveAs("Tiff", dir+nameStore+" - Positive Overlay");
							selectWindow(nameStore);
							roiManager("Set Color", "yellow");
						}
						run("Close All");
						if(isOpen("ROI Manager")==1){
							selectWindow("ROI Manager");
							run("Close");
							}
		//prints out user's adjustment in results table and in adjustment table	
				setResult("Total Gaussian Blur",nResults-1,sigmaT);
				setResult("Total Lower Threshold",nResults-1,LowerT);
				setResult("Total Upper Threshold",nResults-1,UpperT);
				setResult("Total Lower Size Exclusion",nResults-1,lseT);
				setResult("Total Upper Size Exclusion",nResults-1,useT);
				setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
				setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
				setResult("Total Watershed",nResults-1,watershedT);
				setResult("Total Edge Exclusion",nResults-1,excludeT);
				setResult("Total Fill Holes",nResults-1,fillT);
				setResult("Positive Gaussian Blur",nResults-1,sigmaP);
				setResult("Positive Lower Threshold",nResults-1,LowerP);
				setResult("Positive Upper Threshold",nResults-1,UpperP);
				setResult("Positive Lower Size Exclusion",nResults-1,lseP);
				setResult("Positive Upper Size Exclusion",nResults-1,useP);
				setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
				setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
				setResult("Positive Watershed",nResults-1,watershedP);
				setResult("Positive Edge Exclusion",nResults-1,excludeP);
				setResult("Positive Fill Holes",nResults-1,fillP);
				updateResults();
				if(watershedT==1){
				watershedT = "TRUE";
				} else {
					watershedT = "FALSE";
				}
				if(excludeT==1){
					excludeT = "TRUE";
				} else {
					excludeT = "FALSE";
				}
				if(fillT==1){
					fillT = "TRUE";
				} else {
					fillT = "FALSE";
				}
				if(watershedP==1){
					watershedP = "TRUE";
				} else {
					watershedP = "FALSE";
				}
				if(excludeP==1){
					excludeP = "TRUE";
				} else {
					excludeP = "FALSE";
				}
				if(fillP==1){
					fillP = "TRUE";
				} else {
					fillP = "FALSE";
				}
				print(tableTitle2, nameStore + "\t"  + total + "\t"  + positive + "\t"  + Thresh + "\t"  + sigmaT + "\t"  + LowerT + "\t"  + UpperT + "\t"  + lseT + "\t"  + useT + "\t"  + lceT + "\t" + uceT + "\t"  + watershedT + "\t"  + excludeT + "\t"  + fillT + "\t"  + sigmaP + "\t"  + LowerP + "\t"  + UpperP + "\t"  + lseP + "\t"  + useP + "\t"  + lceP + "\t"  + uceP + "\t"  + watershedP + "\t"  + excludeP + "\t"  + fillP);	
					}//end of if condition for opening files based on extension
				}//end of for loop
			}//end of else for opening image based on file name extension			

  	waitForUser("ROI zip file","We have now completed the optimization. An overlay image and an ROI zip file will be saved in the\ntest folder. The zip file is FIJI compatible and permits additional measurements, such as circularity\nor intensity.\n \nThe ROI can be used to overlay onto the original images. To overlay the ROI, open the ROI manager by\ndragging the zip file into Fiji and select ‘Show All’ and ‘Labels’. For additional measurements select\n'Set Measurement' under the 'Analyze' tab on FIJI. Check the boxes for additional measurements desired\nand then return to the ROI manager and click 'Measure'.\n \nClick OK to continue.");
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
	waitForUser("Optimization table", "Finally, a table with the optimization parameters will be saved\nas an Excel spreadsheet in the test folder. These parameters will\nbe used in the analysis dialog boxes to analyze your images.\n \nClick OK to continue.");
	if(isOpen("Results")==1){
		selectWindow("Results");
		sigmaT_mean=0;
		sigmaT_total=0;
		for (a=0; a<nResults(); a++) {
		    sigmaT_total=sigmaT_total+getResult("Total Gaussian Blur",a);
		    sigmaT_mean=sigmaT_total/nResults;
		}
		LowerT_mean=0;
		LowerT_total=0;
		for (a=0; a<nResults(); a++) {
		    LowerT_total=LowerT_total+getResult("Total Lower Threshold",a);
		    LowerT_mean=LowerT_total/nResults;
		}
		if(isNaN(LowerT_mean)==true){
		LowerT_mean=methodT;
		}
		UpperT_mean=0;
		UpperT_total=0;
		for (a=0; a<nResults(); a++) {
		    UpperT_total=UpperT_total+getResult("Total Upper Threshold",a);
		    UpperT_mean=UpperT_total/nResults;
		}
		lseT_mean=0;
		lseT_total=0;
		for (a=0; a<nResults(); a++) {
		    lseT_total=lseT_total+getResult("Total Lower Size Exclusion",a);
		    lseT_mean=lseT_total/nResults;
		}
		useT_mean=0;
		useT_total=0;
		for (a=0; a<nResults(); a++) {
		    useT_total=useT_total+getResult("Total Upper Size Exclusion",a);
		    useT_mean=useT_total/nResults;
		}
		if(isNaN(useT_mean)==true){
		useT_mean="infinity";
		}
		lceT_mean=0;
		lceT_total=0;
		for (a=0; a<nResults(); a++) {
		    lceT_total=lceT_total+getResult("Total Lower Circularity Exclusion",a);
		    lceT_mean=lceT_total/nResults;
		}
		uceT_mean=0;
		uceT_total=0;
		for (a=0; a<nResults(); a++) {
		    uceT_total=uceT_total+getResult("Total Upper Circularity Exclusion",a);
		    uceT_mean=uceT_total/nResults;
		}
		sigmaP_mean=0;
		sigmaP_total=0;
		for (a=0; a<nResults(); a++) {
		    sigmaP_total=sigmaP_total+getResult("Positive Gaussian Blur",a);
		    sigmaP_mean=sigmaP_total/nResults;
		}
		LowerP_mean=0;
		LowerP_total=0;
		for (a=0; a<nResults(); a++) {
		    LowerP_total=LowerP_total+getResult("Positive Lower Threshold",a);
		    LowerP_mean=LowerP_total/nResults;
		}
		if(isNaN(LowerP_mean)==true){
		LowerP_mean=methodP;
		}
		UpperP_mean=0;
		UpperP_total=0;
		for (a=0; a<nResults(); a++) {
		    UpperP_total=UpperP_total+getResult("Positive Upper Threshold",a);
		    UpperP_mean=UpperP_total/nResults;
		}
		lseP_mean=0;
		lseP_total=0;
		for (a=0; a<nResults(); a++) {
		    lseP_total=lseP_total+getResult("Positive Lower Size Exclusion",a);
		    lseP_mean=lseP_total/nResults;
		}
		useP_mean=0;
		useP_total=0;
		for (a=0; a<nResults(); a++) {
		    useP_total=useP_total+getResult("Positive Upper Size Exclusion",a);
		    useP_mean=useP_total/nResults;
		}
		if(isNaN(useP_mean)==true){
		useP_mean="infinity";
		}
		lceP_mean=0;
		lceP_total=0;
		for (a=0; a<nResults(); a++) {
		    lceP_total=lceP_total+getResult("Positive Lower Circularity Exclusion",a);
		    lceP_mean=lceP_total/nResults;
		}
		uceP_mean=0;
		uceP_total=0;
		for (a=0; a<nResults(); a++) {
		    uceP_total=uceP_total+getResult("Positive Upper Circularity Exclusion",a);
		    uceP_mean=uceP_total/nResults;
		}
		run("Close");
		}//end of IF results table is open
		tableTitle5="H&E Optimization Summary";//creates adjustment summary table and prints out average values
		tableTitle6="["+tableTitle5+"]";
		run("Table...", "name="+tableTitle6+" width=400 height=500");
		print(tableTitle6,"Total Selection = "+total);
		print(tableTitle6,"Positive Selection = "+positive);
		print(tableTitle6,"Threshold = "+Thresh);
		print(tableTitle6,"Average Total Gaussian Blur = "+sigmaT_mean);
		print(tableTitle6,"Average Total Lower Threshold = "+LowerT_mean);
		print(tableTitle6,"Average Total Upper Threshold = "+UpperT_mean);
		print(tableTitle6,"Average Total Lower Size Exclusion = "+lseT_mean);
		print(tableTitle6,"Average Total Upper Size Exclusion = "+useT_mean);
		print(tableTitle6,"Average Total Lower Circularity Exclusion = "+lceT_mean);
		print(tableTitle6,"Average Total Upper Cirularity Exclusion = "+uceT_mean);
		print(tableTitle6,"Total Watershed = "+watershedT);
		print(tableTitle6,"Total Edge Exclusion = "+excludeT);
		print(tableTitle6,"Total Fill Holes = "+fillT);
		print(tableTitle6,"Average Positive Gaussian Blur = "+sigmaP_mean);
		print(tableTitle6,"Average Positive Lower Threshold = "+LowerP_mean);
		print(tableTitle6,"Average Positive Upper Threshold = "+UpperP_mean);
		print(tableTitle6,"Average Positive Lower Size Exclusion = "+lseP_mean);
		print(tableTitle6,"Average Positive Upper Size Exclusion = "+useP_mean);
		print(tableTitle6,"Average Positive Lower Circularity Exclusion = "+lceP_mean);
		print(tableTitle6,"Average Positive Upper Cirularity Exclusion = "+uceP_mean);
		print(tableTitle6,"Positive Watershed = "+watershedP);
		print(tableTitle6,"Positive Edge Exclusion = "+excludeP);
		print(tableTitle6,"Positive Fill Holes = "+fillP);
		print(tableTitle2, "Average" + "\t" + total + "\t" + positive + "\t" + Thresh + "\t" + sigmaT_mean + "\t" + LowerT_mean + "\t" + UpperT_mean + "\t" + lseT_mean + "\t" + useT_mean + "\t" + lceT_mean + "\t"  + uceT_mean + "\t" + watershedT + "\t" + excludeT + "\t" + fillT + "\t" + sigmaP_mean + "\t" + LowerP_mean + "\t" + UpperP_mean + "\t" + lseP_mean + "\t" + useP_mean + "\t"  + lceP_mean + "\t" + uceP_mean + "\t" + watershedP + "\t" + excludeP + "\t" + fillP);
		print(tableTitle2, " ");
		print(tableTitle2, "H&E Optimization" + "\t" + "Optimization");
		print(tableTitle2, "Total Selection" + "\t" + total);
		print(tableTitle2, "Positive Selection" + "\t" + positive);
		print(tableTitle2, "Threshold" + "\t" + Thresh);
		print(tableTitle2,"Average Total Gaussian Blur" + "\t" + sigmaT_mean);
		print(tableTitle2,"Average Total Lower Threshold" + "\t" + LowerT_mean);
		print(tableTitle2,"Average Total Upper Threshold" + "\t" + UpperT_mean);
		print(tableTitle2,"Average Total Lower Size Exclusion" + "\t" + lseT_mean);
		print(tableTitle2,"Average Total Upper Size Exclusion" + "\t" + useT_mean);
		print(tableTitle2,"Average Total Lower Circularity Exclusion" + "\t" + lceT_mean);
		print(tableTitle2,"Average Total Upper Circularity Exclusion" + "\t" + uceT_mean);
		print(tableTitle2,"Total Watershed" + "\t" + watershedT);
		print(tableTitle2,"Total Edge Exclusion" + "\t" + excludeT);
		print(tableTitle2,"Total Fill Holes" + "\t" + fillT);
		print(tableTitle2,"Average Positive Gaussian Blur" + "\t" + sigmaP_mean);
		print(tableTitle2,"Average Positive Lower Threshold" + "\t" + LowerP_mean);
		print(tableTitle2,"Average Positive Upper Threshold" + "\t" + UpperP_mean);
		print(tableTitle2,"Average Positive Lower Size Exclusion" + "\t" + lseP_mean);
		print(tableTitle2,"Average Positive Upper Size Exclusion" + "\t" + useP_mean);
		print(tableTitle2,"Average Positive Lower Circularity Exclusion" + "\t" + lceP_mean);
		print(tableTitle2,"Average Positive Upper Circularity Exclusion" + "\t" + uceP_mean);
		print(tableTitle2,"Positive Watershed" + "\t" + watershedP);
		print(tableTitle2,"Positive Edge Exclusion" + "\t" + excludeP);
		print(tableTitle2,"Positive Fill Holes" + "\t" + fillP);		
		if(isOpen("H&E Optimization")==1){
		selectWindow("H&E Optimization");
		saveAs("Results",  dir+tableTitle+".xls");
		selectWindow("H&E Optimization");
		run("Close");
		}
		if(isOpen("H&E Optimization Summary")==1){
		selectWindow("H&E Optimization Summary");
		}
		waitForUser("Analyze your images ", "Use the 'H&E Optimization Summary' table to analyze your images.\n \nIf you are not happy with the optimization, you can repeat it by selecting\n'Exit the macro and redo the optimization' and then restarting the macro.\n \nClick OK to start the analysis.");
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


H&E Optimization 010


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
	waitForUser("Create and select optimization folder","Create a folder and copy 3-5 sample images representative from\nthe set of images that you want to analyze. This folder will be used\nto optimize the image analysis parameters.\n \nClick OK when you are finished to select the folder containing the\nsample images for optimization.");
	dir = getDirectory("Select Optimization Folder");
	list = getFileList(dir);
	Array.sort(list);
	Dialog.create("Selection method");
	Dialog.addMessage("Select basic or enhanced method for selection");
	Dialog.addChoice("Total selection:", newArray("Basic", "Enhanced"));
	Dialog.addChoice("Positive selection", newArray("Basic", "Enhanced"));
	Dialog.show();
	total = Dialog.getChoice();
	positive = Dialog.getChoice();	
	tableTitle="H&E Optimization";
	tableTitle2="["+tableTitle+"]";
	run("Table...", "name="+tableTitle2+" width=400 height=250");
	print(tableTitle2,"\\Headings:Image name\tTotal Selection\tPositive Selection\tThreshold\tTotal Gaussian Blur\tTotal Lower Threshold\tTotal Upper Threshold\tTotal Lower Size Exclusion\tTotal Upper Size Exclusion\tTotal Lower Circularity Exclusion\tTotal Upper Circularity Exclusio\tTotal Watershed\tTotal Edge Exclusion\tTotal Fill Holes\tPositive Gaussian Blur\tPositive Lower Threshold\tPositive Upper Threshold\tPositive Lower Size Exclusion\tPositive Upper Size Exclusion\tPositive Lower Circularity Exclusion\tPositive Upper Circularity Exclusion\tPositive Watershed\tPositive Edge Exclusion\tPositive Fill Holes");
	Dialog.create("Image format");
	Dialog.addMessage("What is the image format?");
	Dialog.addChoice("Type:", newArray("tif", "tiff", "jpg", "jpeg", "png", "gif", "bmp", "custom"));
	Dialog.show();
	type = Dialog.getChoice();
	if (type == "custom"){
		Dialog.create("Image name");
		Dialog.addMessage("Please type the word that is common in all images\n(Case sensitive)");
		Dialog.addString("Common letters/words", "");
		Dialog.show();
		word = Dialog.getString();
		for(i=0; i<list.length; i++){
		filename = dir + list[i];
		if (matches(filename, ".*"+word+".*")){
			open(filename);
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Total Selection Optimization 011


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/	
			nameStore = getTitle();
			if(total=="Enhanced"){//if "enhanced" was selected for total selection
				run("Dichromacy", "simulate=Deuteranope create");
				run("Colour Deconvolution", "vectors=[FastRed FastBlue DAB]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_1)");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_3)");
				close();
				selectWindow(nameStore+"-Deuteranope-(Colour_2)");
				rename("Duplicate");
			} else {//if "basic" was selected for total selection
				run("Duplicate...", " ");
				rename("Duplicate");
			}
			selectWindow("Duplicate");
			run("Gaussian Blur...");	
			sigmaT = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
			run("8-bit");
			selectWindow("Duplicate");
			Dialog.create("Thresholding");
			Dialog.addMessage("Select automatic or manual threshold");
			Dialog.addChoice("", newArray("Automatic", "Manual"));
			Dialog.show();
			Thresh = Dialog.getChoice();
			if (Thresh == "Automatic"){//automatic threshold selection
				if(total=="Enhanced"){//if "enhanced" was selected for total selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Triangle");
					run("Auto Threshold", "method=Triangle white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Moments image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Moments");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Triangle");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Moments","MaxEntropy","Otsu","Triangle","Yen"));
					Dialog.show();
					methodT = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodT=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodT=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodT=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodT=="Triangle"){
						run("Auto Threshold", "method=Triangle white");
					}
					if(methodT=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerT = "Auto="+methodT;
					UpperT = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for total selection
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Li");
								run("Auto Threshold", "method=Li white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Otsu");
								run("Auto Threshold", "method=Otsu white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Shanbhag");
								run("Auto Threshold", "method=Shanbhag white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Shanbhag");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
								Dialog.show();
								methodT = Dialog.getChoice();
								selectWindow("Montage");
								close();
								selectWindow("Stacks");
								close();
								selectWindow("Duplicate");
								if(methodT=="Huang"){
									run("Auto Threshold", "method=Huang white");
								}
								if(methodT=="Li"){
									run("Auto Threshold", "method=Li white");
								}
								if(methodT=="Otsu"){
									run("Auto Threshold", "method=Otsu white");
								}
								if(methodT=="Shanbhag"){
									run("Auto Threshold", "method=Shanbhag white");
								}
								if(methodT=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								LowerT = "Auto="+methodT;
								UpperT = "NaN";
									run("Invert LUT");
									setThreshold(0, 254);
				}
			} else{//manual threshold
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
								waitForUser("Total Tissue Thresholding","Select for all tissue using the bottom slide bar in\nthe Threshold window. Click OK to proceed.");
								getThreshold(LowerT,UpperT);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
				}
								run("Set Measurements...", "area limit redirect=None decimal=3");
								selectWindow("Duplicate");
								run("Measure");
								IJ.deleteRows(nResults-1, nResults-1);
								roiManager("Reset");
								particleT();//particle analysis selection
								function particleT(){
								Dialog.create("Size and Circularity Exclusion");
								Dialog.addMessage("Enter the value (in pixel size) for\nthe exclusion in the particle analysis");
								Dialog.addNumber("Lower size exclusion:", 0);
								Dialog.addString("Upper size exclusion:", "infinity");
								Dialog.addNumber("Lower circularity exclusion:", 0.00);
								Dialog.addNumber("Upper circularity exclusion:", 1.00);
								Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
								Dialog.addCheckbox("watershed", true);
								Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
								Dialog.addCheckbox("exclude", true);
								Dialog.addMessage("Would you like to fill holes?");
								Dialog.addCheckbox("fill holes", false);
								Dialog.show();
								lseT = Dialog.getNumber();
								useT = Dialog.getString();
								lceT = Dialog.getNumber();
								uceT = Dialog.getNumber();
								watershedT = Dialog.getCheckbox();
								excludeT = Dialog.getCheckbox();
								fillT = Dialog.getCheckbox();
								selectWindow("Duplicate");
								if (fillT == true){
									selectWindow("Duplicate");
									run("Duplicate...", "title=Duplicate2");
									run("Fill Holes");
								}
								if (watershedT == true){
									if (isOpen("Duplicate2")==1){
									selectWindow("Duplicate2");
								} else{
									selectWindow("Duplicate");
									run("Duplicate...", "title=Duplicate2");
								}
									run("Watershed");
								}
								if (excludeT == true){
									IJ.redirectErrorMessages();
									run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks exclude add");
								} else {
									IJ.redirectErrorMessages();
									run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks add");
								}
								rename("Mask");
								if(isOpen("Log")==1){
									selectWindow("Log");
									run("Close");
									}
								run("Measure");//records user's input
								setResult("Total Lower Size Exclusion",nResults-1,lseT);
								setResult("Total Upper Size Exclusion",nResults-1,useT);
								setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
								setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
								setResult("Total Watershed",nResults-1,watershedT);
								setResult("Total Edge Exclusion",nResults-1,excludeT);
								setResult("Total Fill Holes",nResults-1,fillT);
								updateResults();
								selectWindow(nameStore);
								roiManager("Show All without labels");	
								Dialog.create("Retry exclusion?");
								Dialog.addMessage("Are you happy with the selection?");
								Dialog.addChoice("Type:", newArray("yes", "no"));
								Dialog.show();
								retry = Dialog.getChoice();
								selectWindow(nameStore);
								roiManager("Show None");
								if(retry=="no"){//removes user's inputs and restarts particle analysis
									IJ.deleteRows(nResults-1, nResults-1);
									selectWindow("Mask");
									close();
									if (isOpen("Duplicate2")==1){
									selectWindow("Duplicate2");
									close();
									}
									roiManager("Reset");
									selectWindow("Duplicate");
									particleT();
										} else{
											if (isOpen("Duplicate2")==1){
											selectWindow("Duplicate");
											close();
											selectWindow("Duplicate2");
											rename("Duplicate");
											}
										} 
								}		
								//records user's final inputs
								lseT = getResult("Total Lower Size Exclusion",nResults-1);
								useT = getResult("Total Upper Size Exclusion",nResults-1);
								lceT = getResult("Total Lower Circularity Exclusion",nResults-1);
								uceT = getResult("Total Upper Circularity Exclusion",nResults-1);
								watershedT = getResult("Total Watershed",nResults-1);
								excludeT = getResult("Total Edge Exclusion",nResults-1);
								fillT = getResult("Total Fill Holes",nResults-1);
								IJ.deleteRows(nResults-1, nResults-1);
								run("Measure");
								if (roiManager("count")!=0) {
									roiManager("Save",  dir+nameStore+" - Total.zip");
									selectWindow("Mask");
									rename("Mask");
									selectWindow(nameStore);
									roiManager("Show All without labels");
									roiManager("Set Fill Color", "red");
									run("Flatten");
									saveAs("Tiff", dir+nameStore+" - Total Overlay");
									selectWindow(nameStore);
									roiManager("Set Color", "yellow");
									}
								selectWindow(nameStore);
								close("\\Others");
								if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
								}
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
			
			
			
Positive Selection Optimization 012
			
			
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
			selectWindow(nameStore);
			IJ.deleteRows(nResults-1, nResults-1);
			if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
				run("Dichromacy", "simulate=Tritanope create");
				run("Colour Deconvolution", "vectors=[H&E DAB]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_3)");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_2)");
				close();
				selectWindow(nameStore+"-Tritanope-(Colour_1)");
				rename("Duplicate");
			} else {//if "basic" was selected for positive selection
				run("Colour Deconvolution", "vectors=[H&E]");
				selectWindow("Colour Deconvolution");
				close();
				selectWindow(nameStore+"-(Colour_3)");
				close();
				selectWindow(nameStore+"-(Colour_2)");
				close();
				selectWindow(nameStore+"-(Colour_1)");
				rename("Duplicate");
			}
			
			selectWindow("Duplicate");
			run("Gaussian Blur...");	
			sigmaP = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
			run("8-bit");
			selectWindow("Duplicate");
			if (Thresh == "Automatic"){//automatic threshold selection
				if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Intermodes");
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Intermodes image3=MaxEntropy image4=Otsu image5=Moments image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Intermodes");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Moments");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Intermodes","MaxEntropy","Otsu","Moments","Yen"));
					Dialog.show();
					methodP = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodP=="Intermodes"){
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodP=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodP=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodP=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodP=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerP = "Auto="+methodP;
					UpperP = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for positive selection
					selectWindow("Duplicate");
							run("Duplicate...", "title=Original");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Huang");
							run("Auto Threshold", "method=Huang white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Li");
							run("Auto Threshold", "method=Li white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Otsu");
							run("Auto Threshold", "method=Otsu white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Shanbhag");
							run("Auto Threshold", "method=Shanbhag white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Yen");
							run("Auto Threshold", "method=Yen white");
							run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
							setSlice(1); 
							setMetadata("Original");
							setSlice(2);
							setMetadata("Huang");
							setSlice(3);
							setMetadata("Li");
							setSlice(4);
							setMetadata("Otsu");
							setSlice(5);
							setMetadata("Shanbhag");
							setSlice(6);
							setMetadata("Yen");
							run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
							Dialog.create("Thresholding");
							Dialog.addMessage("Please select the automatic methodP that you\nwould like to use");
							Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
							Dialog.show();
							methodP = Dialog.getChoice();
							selectWindow("Montage");
							close();
							selectWindow("Stacks");
							close();
							selectWindow("Duplicate");
							if(methodP=="Huang"){
								run("Auto Threshold", "method=Huang white");
							}
							if(methodP=="Li"){
								run("Auto Threshold", "method=Li white");
							}
							if(methodP=="Otsu"){
								run("Auto Threshold", "method=Otsu white");
							}
							if(methodP=="Shanbhag"){
								run("Auto Threshold", "method=Shanbhag white");
							}
							if(methodP=="Yen"){
								run("Auto Threshold", "method=Yen white");
							}
							LowerP = "Auto="+methodP;
							UpperP = "NaN";
								run("Invert LUT");
								setThreshold(0, 254);
					}//end of else for 'basic' auto threshold of positive 
						}else{//manual threshold
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
								waitForUser("Positive Tissue Thresholding","Select for positive tissue using the bottom slide\nbar in the Threshold window. Click OK to proceed."); 
								getThreshold(LowerP,UpperP);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
							}
							run("Set Measurements...", "area limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particleP();//particle analysis selection
							function particleP(){
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
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lseP = Dialog.getNumber();
							useP = Dialog.getString();
							lceP = Dialog.getNumber();
							uceP = Dialog.getNumber();
							watershedP = Dialog.getCheckbox();
							excludeP = Dialog.getCheckbox();
							fillP = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillP == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershedP == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (excludeP == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks exclude add");
							} else {
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");//records user's input
							setResult("Positive Lower Size Exclusion",nResults-1,lseP);
							setResult("Positive Upper Size Exclusion",nResults-1,useP);
							setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
							setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
							setResult("Positive Watershed",nResults-1,watershedP);
							setResult("Positive Edge Exclusion",nResults-1,excludeP);
							setResult("Positive Fill Holes",nResults-1,fillP);
							updateResults();
							selectWindow(nameStore);
							roiManager("Show All without labels");	
							Dialog.create("Retry exclusion?");
							Dialog.addMessage("Are you happy with the selection?");
							Dialog.addChoice("Type:", newArray("yes", "no"));
							Dialog.show();
							retry = Dialog.getChoice();
							selectWindow(nameStore);
							roiManager("Show None");
							if(retry=="no"){//removes user's inputs and restarts particle analysis
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particleP();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							//records user's final inputs
							lseP = getResult("Positive Lower Size Exclusion",nResults-1);
							useP = getResult("Positive Upper Size Exclusion",nResults-1);
							lceP = getResult("Positive Lower Circularity Exclusion",nResults-1);
							uceP = getResult("Positive Upper Circularity Exclusion",nResults-1);
							watershedP = getResult("Positive Watershed",nResults-1);
							excludeP = getResult("Positive Edge Exclusion",nResults-1);
							fillP = getResult("Positive Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							run("Measure");
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Positive.zip");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "green");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Positive Overlay");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							}
							run("Close All");
							if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
								}
			//prints out user's adjustment in results table and in adjustment table	
				setResult("Total Gaussian Blur",nResults-1,sigmaT);
				setResult("Total Lower Threshold",nResults-1,LowerT);
				setResult("Total Upper Threshold",nResults-1,UpperT);
				setResult("Total Lower Size Exclusion",nResults-1,lseT);
				setResult("Total Upper Size Exclusion",nResults-1,useT);
				setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
				setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
				setResult("Total Watershed",nResults-1,watershedT);
				setResult("Total Edge Exclusion",nResults-1,excludeT);
				setResult("Total Fill Holes",nResults-1,fillT);
				setResult("Positive Gaussian Blur",nResults-1,sigmaP);
				setResult("Positive Lower Threshold",nResults-1,LowerP);
				setResult("Positive Upper Threshold",nResults-1,UpperP);
				setResult("Positive Lower Size Exclusion",nResults-1,lseP);
				setResult("Positive Upper Size Exclusion",nResults-1,useP);
				setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
				setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
				setResult("Positive Watershed",nResults-1,watershedP);
				setResult("Positive Edge Exclusion",nResults-1,excludeP);
				setResult("Positive Fill Holes",nResults-1,fillP);
				updateResults();
				if(watershedT==1){
				watershedT = "TRUE";
				} else {
					watershedT = "FALSE";
				}
				if(excludeT==1){
					excludeT = "TRUE";
				} else {
					excludeT = "FALSE";
				}
				if(fillT==1){
					fillT = "TRUE";
				} else {
					fillT = "FALSE";
				}
				if(watershedP==1){
					watershedP = "TRUE";
				} else {
					watershedP = "FALSE";
				}
				if(excludeP==1){
					excludeP = "TRUE";
				} else {
					excludeP = "FALSE";
				}
				if(fillP==1){
					fillP = "TRUE";
				} else {
					fillP = "FALSE";
				}
				print(tableTitle2, nameStore + "\t"  + total + "\t"  + positive + "\t"  + Thresh + "\t"  + sigmaT + "\t"  + LowerT + "\t"  + UpperT + "\t"  + lseT + "\t"  + useT + "\t"  + lceT + "\t" + uceT + "\t"  + watershedT + "\t"  + excludeT + "\t"  + fillT + "\t"  + sigmaP + "\t"  + LowerP + "\t"  + UpperP + "\t"  + lseP + "\t"  + useP + "\t"  + lceP + "\t"  + uceP + "\t"  + watershedP + "\t"  + excludeP + "\t"  + fillP);								}//end of if condition for opening files based on custom name
					}//end of for loop 
	}else {//opens image based on file name extension
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Total Selection Optimization 013


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/		
		for(i=0; i<list.length; i++){
			filename = dir + list[i];
			if (endsWith(filename, type)){
				open(filename);	
				nameStore = getTitle();
		if(total=="Enhanced"){//if "enhanced" was selected for total selection
			run("Dichromacy", "simulate=Deuteranope create");
			run("Colour Deconvolution", "vectors=[FastRed FastBlue DAB]");
			selectWindow("Colour Deconvolution");
			close();
			selectWindow(nameStore+"-Deuteranope-(Colour_1)");
			close();
			selectWindow(nameStore+"-Deuteranope-(Colour_3)");
			close();
			selectWindow(nameStore+"-Deuteranope-(Colour_2)");
			rename("Duplicate");
		} else {//if "basic" was selected for total selection
			run("Duplicate...", " ");
			rename("Duplicate");
		}
		selectWindow("Duplicate");
		run("Gaussian Blur...");	
		sigmaT = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
		run("8-bit");
		selectWindow("Duplicate");
		Dialog.create("Thresholding");
		Dialog.addMessage("Select automatic or manual threshold");
		Dialog.addChoice("", newArray("Automatic", "Manual"));
		Dialog.show();
		Thresh = Dialog.getChoice();
		if (Thresh == "Automatic"){//automatic threshold selection
				if(total=="Enhanced"){//if "enhanced" was selected for total selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Triangle");
					run("Auto Threshold", "method=Triangle white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Moments image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Moments");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Triangle");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Moments","MaxEntropy","Otsu","Triangle","Yen"));
					Dialog.show();
					methodT = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodT=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodT=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodT=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodT=="Triangle"){
						run("Auto Threshold", "method=Triangle white");
					}
					if(methodT=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerT = "Auto="+methodT;
					UpperT = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for total selection
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Li");
								run("Auto Threshold", "method=Li white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Otsu");
								run("Auto Threshold", "method=Otsu white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Shanbhag");
								run("Auto Threshold", "method=Shanbhag white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Shanbhag");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
								Dialog.show();
								methodT = Dialog.getChoice();
								selectWindow("Montage");
								close();
								selectWindow("Stacks");
								close();
								selectWindow("Duplicate");
								if(methodT=="Huang"){
									run("Auto Threshold", "method=Huang white");
								}
								if(methodT=="Li"){
									run("Auto Threshold", "method=Li white");
								}
								if(methodT=="Otsu"){
									run("Auto Threshold", "method=Otsu white");
								}
								if(methodT=="Shanbhag"){
									run("Auto Threshold", "method=Shanbhag white");
								}
								if(methodT=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								LowerT = "Auto="+methodT;
								UpperT = "NaN";
									run("Invert LUT");
									setThreshold(0, 254);
				}
		} else{//manual threshold
							selectWindow("Duplicate");
							setAutoThreshold("Default dark");
							run("Threshold...");
							setThreshold(0, 150);
							waitForUser("Total Tissue Thresholding","Select for all tissue using the bottom slide bar in\nthe Threshold window. Click OK to proceed.");
							getThreshold(LowerT,UpperT);
							selectWindow("Duplicate");
							setOption("BlackBackground", true);
							run("Convert to Mask");
							setThreshold(10, 255);
			}
							run("Set Measurements...", "area limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particleT();//particle analysis selection
							function particleT(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe nuclei?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the nuclei\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lseT = Dialog.getNumber();
							useT = Dialog.getString();
							lceT = Dialog.getNumber();
							uceT = Dialog.getNumber();
							watershedT = Dialog.getCheckbox();
							excludeT = Dialog.getCheckbox();
							fillT = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillT == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershedT == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (excludeT == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks exclude add");
							} else {
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");//records user's input
							setResult("Total Lower Size Exclusion",nResults-1,lseT);
							setResult("Total Upper Size Exclusion",nResults-1,useT);
							setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
							setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
							setResult("Total Watershed",nResults-1,watershedT);
							setResult("Total Edge Exclusion",nResults-1,excludeT);
							setResult("Total Fill Holes",nResults-1,fillT);
							updateResults();
							selectWindow(nameStore);
							roiManager("Show All without labels");	
							Dialog.create("Retry exclusion?");
							Dialog.addMessage("Are you happy with the selection?");
							Dialog.addChoice("Type:", newArray("yes", "no"));
							Dialog.show();
							retry = Dialog.getChoice();
							selectWindow(nameStore);
							roiManager("Show None");
							if(retry=="no"){//removes user's inputs and restarts particle analysis
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particleT();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							//records user's final inputs
							lseT = getResult("Total Lower Size Exclusion",nResults-1);
							useT = getResult("Total Upper Size Exclusion",nResults-1);
							lceT = getResult("Total Lower Circularity Exclusion",nResults-1);
							uceT = getResult("Total Upper Circularity Exclusion",nResults-1);
							watershedT = getResult("Total Watershed",nResults-1);
							excludeT = getResult("Total Edge Exclusion",nResults-1);
							fillT = getResult("Total Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							run("Measure");
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Total.zip");
								selectWindow("Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "red");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Total Overlay");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
								}
							selectWindow(nameStore);
							close("\\Others");
							if(isOpen("ROI Manager")==1){
							selectWindow("ROI Manager");
							run("Close");
							}
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
		
		
		
Positive Selection Optimization 014
		
		
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
		selectWindow(nameStore);
		IJ.deleteRows(nResults-1, nResults-1);
		if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
			run("Dichromacy", "simulate=Tritanope create");
			run("Colour Deconvolution", "vectors=[H&E DAB]");
			selectWindow("Colour Deconvolution");
			close();
			selectWindow(nameStore+"-Tritanope-(Colour_3)");
			close();
			selectWindow(nameStore+"-Tritanope-(Colour_2)");
			close();
			selectWindow(nameStore+"-Tritanope-(Colour_1)");
			rename("Duplicate");
		} else {//if "basic" was selected for positive selection
			run("Colour Deconvolution", "vectors=[H&E]");
			selectWindow("Colour Deconvolution");
			close();
			selectWindow(nameStore+"-(Colour_3)");
			close();
			selectWindow(nameStore+"-(Colour_2)");
			close();
			selectWindow(nameStore+"-(Colour_1)");
			rename("Duplicate");
		}
		
		selectWindow("Duplicate");
		run("Gaussian Blur...");	
		sigmaP = getNumber("Please enter the value you had\njust entered for the Gaussian Blur",0);
		run("8-bit");
		selectWindow("Duplicate");
		if (Thresh == "Automatic"){//automatic threshold selection
			if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Intermodes");
					run("Auto Threshold", "method=Intermodes white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=MaxEntropy");
					run("Auto Threshold", "method=MaxEntropy white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Otsu");
					run("Auto Threshold", "method=Otsu white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Moments");
					run("Auto Threshold", "method=Moments white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Intermodes image3=MaxEntropy image4=Otsu image5=Moments image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Intermodes");
					setSlice(3);
					setMetadata("MaxEntropy");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Moments");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Intermodes","MaxEntropy","Otsu","Moments","Yen"));
					Dialog.show();
					methodP = Dialog.getChoice();
					selectWindow("Montage");
					close();
					selectWindow("Stacks");
					close();
					selectWindow("Duplicate");
					if(methodP=="Intermodes"){
						run("Auto Threshold", "method=Intermodes white");
					}
					if(methodP=="MaxEntropy"){
						run("Auto Threshold", "method=MaxEntropy white");
					}
					if(methodP=="Otsu"){
						run("Auto Threshold", "method=Otsu white");
					}
					if(methodP=="Moments"){
						run("Auto Threshold", "method=Moments white");
					}
					if(methodP=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					LowerP = "Auto="+methodP;
					UpperP = "NaN";
						run("Invert LUT");
						setThreshold(0, 254);
				} else {//if "basic" was selected for positive selection
					selectWindow("Duplicate");
							run("Duplicate...", "title=Original");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Huang");
							run("Auto Threshold", "method=Huang white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Li");
							run("Auto Threshold", "method=Li white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Otsu");
							run("Auto Threshold", "method=Otsu white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Shanbhag");
							run("Auto Threshold", "method=Shanbhag white");
							selectWindow("Duplicate");
							run("Duplicate...", "title=Yen");
							run("Auto Threshold", "method=Yen white");
							run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Shanbhag image6=Yen");
							setSlice(1); 
							setMetadata("Original");
							setSlice(2);
							setMetadata("Huang");
							setSlice(3);
							setMetadata("Li");
							setSlice(4);
							setMetadata("Otsu");
							setSlice(5);
							setMetadata("Shanbhag");
							setSlice(6);
							setMetadata("Yen");
							run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
							Dialog.create("Thresholding");
							Dialog.addMessage("Please select the automatic methodP that you\nwould like to use");
							Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
							Dialog.show();
							methodP = Dialog.getChoice();
							selectWindow("Montage");
							close();
							selectWindow("Stacks");
							close();
							selectWindow("Duplicate");
							if(methodP=="Huang"){
								run("Auto Threshold", "method=Huang white");
							}
							if(methodP=="Li"){
								run("Auto Threshold", "method=Li white");
							}
							if(methodP=="Otsu"){
								run("Auto Threshold", "method=Otsu white");
							}
							if(methodP=="Shanbhag"){
								run("Auto Threshold", "method=Shanbhag white");
							}
							if(methodP=="Yen"){
								run("Auto Threshold", "method=Yen white");
							}
							LowerP = "Auto="+methodP;
							UpperP = "NaN";
								run("Invert LUT");
								setThreshold(0, 254);
					}//end of else for 'basic' auto threshold of positive 
				}else{//manual threshold
							selectWindow("Duplicate");
							setAutoThreshold("Default dark");
							run("Threshold...");
							setThreshold(0, 150);
							waitForUser("Positive Tissue Thresholding","Select for positive tissue using the bottom slide\nbar in the Threshold window. Click OK to proceed."); 
							getThreshold(LowerP,UpperP);
							selectWindow("Duplicate");
							setOption("BlackBackground", true);
							run("Convert to Mask");
							setThreshold(10, 255);
			}
			
						run("Set Measurements...", "area limit redirect=None decimal=3");
						selectWindow("Duplicate");
						run("Measure");
						IJ.deleteRows(nResults-1, nResults-1);
						roiManager("Reset");
						particleP();//particle analysis selection
						function particleP(){
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
						Dialog.addMessage("Would you like to fill holes?");
						Dialog.addCheckbox("fill holes", false);
						Dialog.show();
						lseP = Dialog.getNumber();
						useP = Dialog.getString();
						lceP = Dialog.getNumber();
						uceP = Dialog.getNumber();
						watershedP = Dialog.getCheckbox();
						excludeP = Dialog.getCheckbox();
						fillP = Dialog.getCheckbox();
						selectWindow("Duplicate");
						if (fillP == true){
							selectWindow("Duplicate");
							run("Duplicate...", "title=Duplicate2");
							run("Fill Holes");
						}
						if (watershedP == true){
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate2");
						} else{
							selectWindow("Duplicate");
							run("Duplicate...", "title=Duplicate2");
						}
							run("Watershed");
						}
						if (excludeP == true){
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks exclude add");
						} else {
							IJ.redirectErrorMessages();
							run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks add");
						}
						rename("Mask");
						if(isOpen("Log")==1){
							selectWindow("Log");
							run("Close");
							}
						run("Measure");//records user's input
						setResult("Positive Lower Size Exclusion",nResults-1,lseP);
						setResult("Positive Upper Size Exclusion",nResults-1,useP);
						setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
						setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
						setResult("Positive Watershed",nResults-1,watershedP);
						setResult("Positive Edge Exclusion",nResults-1,excludeP);
						setResult("Positive Fill Holes",nResults-1,fillP);
						updateResults();
						selectWindow(nameStore);
						roiManager("Show All without labels");	
						Dialog.create("Retry exclusion?");
						Dialog.addMessage("Are you happy with the selection?");
						Dialog.addChoice("Type:", newArray("yes", "no"));
						Dialog.show();
						retry = Dialog.getChoice();
						selectWindow(nameStore);
						roiManager("Show None");
						if(retry=="no"){//removes user's inputs and restarts particle analysis
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							close();
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate2");
							close();
							}
							roiManager("Reset");
							selectWindow("Duplicate");
							particleP();
								} else{
									if (isOpen("Duplicate2")==1){
									selectWindow("Duplicate");
									close();
									selectWindow("Duplicate2");
									rename("Duplicate");
									}
								} 
						}		
						//records user's final inputs
						lseP = getResult("Positive Lower Size Exclusion",nResults-1);
						useP = getResult("Positive Upper Size Exclusion",nResults-1);
						lceP = getResult("Positive Lower Circularity Exclusion",nResults-1);
						uceP = getResult("Positive Upper Circularity Exclusion",nResults-1);
						watershedP = getResult("Positive Watershed",nResults-1);
						excludeP = getResult("Positive Edge Exclusion",nResults-1);
						fillP = getResult("Positive Fill Holes",nResults-1);
						IJ.deleteRows(nResults-1, nResults-1);
						run("Measure");
						if (roiManager("count")!=0) {
							roiManager("Save",  dir+nameStore+" - Positive.zip");
							selectWindow(nameStore);
							roiManager("Show All without labels");
							roiManager("Set Fill Color", "green");
							run("Flatten");
							saveAs("Tiff", dir+nameStore+" - Positive Overlay");
							selectWindow(nameStore);
							roiManager("Set Color", "yellow");
						}
						run("Close All");
						if(isOpen("ROI Manager")==1){
							selectWindow("ROI Manager");
							run("Close");
							}
		//prints out user's adjustment in results table and in adjustment table	
				setResult("Total Gaussian Blur",nResults-1,sigmaT);
				setResult("Total Lower Threshold",nResults-1,LowerT);
				setResult("Total Upper Threshold",nResults-1,UpperT);
				setResult("Total Lower Size Exclusion",nResults-1,lseT);
				setResult("Total Upper Size Exclusion",nResults-1,useT);
				setResult("Total Lower Circularity Exclusion",nResults-1,lceT);
				setResult("Total Upper Circularity Exclusion",nResults-1,uceT);
				setResult("Total Watershed",nResults-1,watershedT);
				setResult("Total Edge Exclusion",nResults-1,excludeT);
				setResult("Total Fill Holes",nResults-1,fillT);
				setResult("Positive Gaussian Blur",nResults-1,sigmaP);
				setResult("Positive Lower Threshold",nResults-1,LowerP);
				setResult("Positive Upper Threshold",nResults-1,UpperP);
				setResult("Positive Lower Size Exclusion",nResults-1,lseP);
				setResult("Positive Upper Size Exclusion",nResults-1,useP);
				setResult("Positive Lower Circularity Exclusion",nResults-1,lceP);
				setResult("Positive Upper Circularity Exclusion",nResults-1,uceP);
				setResult("Positive Watershed",nResults-1,watershedP);
				setResult("Positive Edge Exclusion",nResults-1,excludeP);
				setResult("Positive Fill Holes",nResults-1,fillP);
				updateResults();
				if(watershedT==1){
				watershedT = "TRUE";
				} else {
					watershedT = "FALSE";
				}
				if(excludeT==1){
					excludeT = "TRUE";
				} else {
					excludeT = "FALSE";
				}
				if(fillT==1){
					fillT = "TRUE";
				} else {
					fillT = "FALSE";
				}
				if(watershedP==1){
					watershedP = "TRUE";
				} else {
					watershedP = "FALSE";
				}
				if(excludeP==1){
					excludeP = "TRUE";
				} else {
					excludeP = "FALSE";
				}
				if(fillP==1){
					fillP = "TRUE";
				} else {
					fillP = "FALSE";
				}
				print(tableTitle2, nameStore + "\t"  + total + "\t"  + positive + "\t"  + Thresh + "\t"  + sigmaT + "\t"  + LowerT + "\t"  + UpperT + "\t"  + lseT + "\t"  + useT + "\t"  + lceT + "\t" + uceT + "\t"  + watershedT + "\t"  + excludeT + "\t"  + fillT + "\t"  + sigmaP + "\t"  + LowerP + "\t"  + UpperP + "\t"  + lseP + "\t"  + useP + "\t"  + lceP + "\t"  + uceP + "\t"  + watershedP + "\t"  + excludeP + "\t"  + fillP);						}//end of if condition for opening files based on extension
				}//end of for loop
			}//end of else for opening image based on file name extension			

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
	if(isOpen("Results")==1){
		selectWindow("Results");
		sigmaT_mean=0;
		sigmaT_total=0;
		for (a=0; a<nResults(); a++) {
		    sigmaT_total=sigmaT_total+getResult("Total Gaussian Blur",a);
		    sigmaT_mean=sigmaT_total/nResults;
		}
		LowerT_mean=0;
		LowerT_total=0;
		for (a=0; a<nResults(); a++) {
		    LowerT_total=LowerT_total+getResult("Total Lower Threshold",a);
		    LowerT_mean=LowerT_total/nResults;
		}
		if(isNaN(LowerT_mean)==true){
		LowerT_mean=methodT;
		}
		UpperT_mean=0;
		UpperT_total=0;
		for (a=0; a<nResults(); a++) {
		    UpperT_total=UpperT_total+getResult("Total Upper Threshold",a);
		    UpperT_mean=UpperT_total/nResults;
		}
		lseT_mean=0;
		lseT_total=0;
		for (a=0; a<nResults(); a++) {
		    lseT_total=lseT_total+getResult("Total Lower Size Exclusion",a);
		    lseT_mean=lseT_total/nResults;
		}
		useT_mean=0;
		useT_total=0;
		for (a=0; a<nResults(); a++) {
		    useT_total=useT_total+getResult("Total Upper Size Exclusion",a);
		    useT_mean=useT_total/nResults;
		}
		if(isNaN(useT_mean)==true){
		useT_mean="infinity";
		}
		lceT_mean=0;
		lceT_total=0;
		for (a=0; a<nResults(); a++) {
		    lceT_total=lceT_total+getResult("Total Lower Circularity Exclusion",a);
		    lceT_mean=lceT_total/nResults;
		}
		uceT_mean=0;
		uceT_total=0;
		for (a=0; a<nResults(); a++) {
		    uceT_total=uceT_total+getResult("Total Upper Circularity Exclusion",a);
		    uceT_mean=uceT_total/nResults;
		}
		sigmaP_mean=0;
		sigmaP_total=0;
		for (a=0; a<nResults(); a++) {
		    sigmaP_total=sigmaP_total+getResult("Positive Gaussian Blur",a);
		    sigmaP_mean=sigmaP_total/nResults;
		}
		LowerP_mean=0;
		LowerP_total=0;
		for (a=0; a<nResults(); a++) {
		    LowerP_total=LowerP_total+getResult("Positive Lower Threshold",a);
		    LowerP_mean=LowerP_total/nResults;
		}
		if(isNaN(LowerP_mean)==true){
		LowerP_mean=methodP;
		}
		UpperP_mean=0;
		UpperP_total=0;
		for (a=0; a<nResults(); a++) {
		    UpperP_total=UpperP_total+getResult("Positive Upper Threshold",a);
		    UpperP_mean=UpperP_total/nResults;
		}
		lseP_mean=0;
		lseP_total=0;
		for (a=0; a<nResults(); a++) {
		    lseP_total=lseP_total+getResult("Positive Lower Size Exclusion",a);
		    lseP_mean=lseP_total/nResults;
		}
		useP_mean=0;
		useP_total=0;
		for (a=0; a<nResults(); a++) {
		    useP_total=useP_total+getResult("Positive Upper Size Exclusion",a);
		    useP_mean=useP_total/nResults;
		}
		if(isNaN(useP_mean)==true){
		useP_mean="infinity";
		}
		lceP_mean=0;
		lceP_total=0;
		for (a=0; a<nResults(); a++) {
		    lceP_total=lceP_total+getResult("Positive Lower Circularity Exclusion",a);
		    lceP_mean=lceP_total/nResults;
		}
		uceP_mean=0;
		uceP_total=0;
		for (a=0; a<nResults(); a++) {
		    uceP_total=uceP_total+getResult("Positive Upper Circularity Exclusion",a);
		    uceP_mean=uceP_total/nResults;
		}
		run("Close");
		}//end of IF results table is open
		tableTitle5="H&E Optimization Summary";//creates adjustment summary table and prints out average values
		tableTitle6="["+tableTitle5+"]";
		run("Table...", "name="+tableTitle6+" width=400 height=500");
		print(tableTitle6,"Total Selection = "+total);
		print(tableTitle6,"Positive Selection = "+positive);
		print(tableTitle6,"Threshold = "+Thresh);
		print(tableTitle6,"Average Total Gaussian Blur = "+sigmaT_mean);
		print(tableTitle6,"Average Total Lower Threshold = "+LowerT_mean);
		print(tableTitle6,"Average Total Upper Threshold = "+UpperT_mean);
		print(tableTitle6,"Average Total Lower Size Exclusion = "+lseT_mean);
		print(tableTitle6,"Average Total Upper Size Exclusion = "+useT_mean);
		print(tableTitle6,"Average Total Lower Circularity Exclusion = "+lceT_mean);
		print(tableTitle6,"Average Total Upper Cirularity Exclusion = "+uceT_mean);
		print(tableTitle6,"Total Watershed = "+watershedT);
		print(tableTitle6,"Total Edge Exclusion = "+excludeT);
		print(tableTitle6,"Total Fill Holes = "+fillT);
		print(tableTitle6,"Average Positive Gaussian Blur = "+sigmaP_mean);
		print(tableTitle6,"Average Positive Lower Threshold = "+LowerP_mean);
		print(tableTitle6,"Average Positive Upper Threshold = "+UpperP_mean);
		print(tableTitle6,"Average Positive Lower Size Exclusion = "+lseP_mean);
		print(tableTitle6,"Average Positive Upper Size Exclusion = "+useP_mean);
		print(tableTitle6,"Average Positive Lower Circularity Exclusion = "+lceP_mean);
		print(tableTitle6,"Average Positive Upper Cirularity Exclusion = "+uceP_mean);
		print(tableTitle6,"Positive Watershed = "+watershedP);
		print(tableTitle6,"Positive Edge Exclusion = "+excludeP);
		print(tableTitle6,"Positive Fill Holes = "+fillP);
		print(tableTitle2, "Average" + "\t" + total + "\t" + positive + "\t" + Thresh + "\t" + sigmaT_mean + "\t" + LowerT_mean + "\t" + UpperT_mean + "\t" + lseT_mean + "\t" + useT_mean + "\t" + lceT_mean + "\t"  + uceT_mean + "\t" + watershedT + "\t" + excludeT + "\t" + fillT + "\t" + sigmaP_mean + "\t" + LowerP_mean + "\t" + UpperP_mean + "\t" + lseP_mean + "\t" + useP_mean + "\t"  + lceP_mean + "\t" + uceP_mean + "\t" + watershedP + "\t" + excludeP + "\t" + fillP);
		print(tableTitle2, " ");
		print(tableTitle2, "H&E Optimization" + "\t" + "Optimization");
		print(tableTitle2, "Total Selection" + "\t" + total);
		print(tableTitle2, "Positive Selection" + "\t" + positive);
		print(tableTitle2, "Threshold" + "\t" + Thresh);
		print(tableTitle2,"Average Total Gaussian Blur" + "\t" + sigmaT_mean);
		print(tableTitle2,"Average Total Lower Threshold" + "\t" + LowerT_mean);
		print(tableTitle2,"Average Total Upper Threshold" + "\t" + UpperT_mean);
		print(tableTitle2,"Average Total Lower Size Exclusion" + "\t" + lseT_mean);
		print(tableTitle2,"Average Total Upper Size Exclusion" + "\t" + useT_mean);
		print(tableTitle2,"Average Total Lower Circularity Exclusion" + "\t" + lceT_mean);
		print(tableTitle2,"Average Total Upper Circularity Exclusion" + "\t" + uceT_mean);
		print(tableTitle2,"Total Watershed" + "\t" + watershedT);
		print(tableTitle2,"Total Edge Exclusion" + "\t" + excludeT);
		print(tableTitle2,"Total Fill Holes" + "\t" + fillT);
		print(tableTitle2,"Average Positive Gaussian Blur" + "\t" + sigmaP_mean);
		print(tableTitle2,"Average Positive Lower Threshold" + "\t" + LowerP_mean);
		print(tableTitle2,"Average Positive Upper Threshold" + "\t" + UpperP_mean);
		print(tableTitle2,"Average Positive Lower Size Exclusion" + "\t" + lseP_mean);
		print(tableTitle2,"Average Positive Upper Size Exclusion" + "\t" + useP_mean);
		print(tableTitle2,"Average Positive Lower Circularity Exclusion" + "\t" + lceP_mean);
		print(tableTitle2,"Average Positive Upper Circularity Exclusion" + "\t" + uceP_mean);
		print(tableTitle2,"Positive Watershed" + "\t" + watershedP);
		print(tableTitle2,"Positive Edge Exclusion" + "\t" + excludeP);
		print(tableTitle2,"Positive Fill Holes" + "\t" + fillP);
		if(isOpen("H&E Optimization")==1){
		selectWindow("H&E Optimization");
		saveAs("Results",  dir+tableTitle+".xls");
		selectWindow("H&E Optimization");
		run("Close");
		}
		if(isOpen("H&E Optimization Summary")==1){
		selectWindow("H&E Optimization Summary");
		}
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
	}//end of IF second = adj
}//end of IF first = no


/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
H&E Analysis 015
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/

if(second==ana){
Analysis();
}
function Analysis(){

	waitForUser("Selecting the folder","Select the source folder for all images to be analyzed.");
	dir = getDirectory("Select Analysis Folder");
	list = getFileList(dir);
	Array.sort(list);

	Dialog.create("Saving files");
	Dialog.addMessage("Select which files to be saved during analysis");
	Dialog.addMessage("Total:");
	Dialog.addCheckbox("Total ROI", false);
	Dialog.addCheckbox("Total Overlay", true);
	Dialog.addCheckbox("Total Mask", false);
	Dialog.addMessage("Positive:");
	Dialog.addMessage("");
	Dialog.addCheckbox("Positive ROI", false);
	Dialog.addCheckbox("Positive Overlay", true);
	Dialog.addCheckbox("Positive Mask", false);
	Dialog.show();
	TR = Dialog.getCheckbox();
	TO = Dialog.getCheckbox();
	TM = Dialog.getCheckbox();
	PR = Dialog.getCheckbox();
	PO = Dialog.getCheckbox();
	PM = Dialog.getCheckbox();
	
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
	
	Dialog.create("Selection method");
	Dialog.addMessage("Select basic or enhanced method for selection");
	Dialog.addChoice("Total selection:", newArray("Basic", "Enhanced"));
	Dialog.addChoice("Positive selection", newArray("Basic", "Enhanced"));
	Dialog.addMessage("Select automatic or manual threshold");
	Dialog.addChoice("", newArray("Automatic", "Manual"));
	Dialog.show();
	total = Dialog.getChoice();
	positive = Dialog.getChoice();
	thresh = Dialog.getChoice();
	if (thresh == "Automatic"){
		if (total == "Basic"){
		Dialog.create("Total Selection");
		Dialog.addMessage("Gaussian blur for total selection:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addMessage("Threshold method for total selection:");
		Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
		Dialog.show();
		sigmaT = Dialog.getNumber();
		methodT = Dialog.getChoice();
		} else if (total == "Enhanced"){
		Dialog.create("Total selection");
		Dialog.addMessage("Gaussian blur for total selection:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addMessage("Threshold method for total selection:");
		Dialog.addChoice("", newArray("Moments","MaxEntropy","Otsu","Triangle","Yen"));
		Dialog.show();
		sigmaT = Dialog.getNumber();
		methodT = Dialog.getChoice();
	}
	}else {
		Dialog.create("Total selection");
		Dialog.addMessage("Gaussian blur for total selection:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addNumber("Total lower threshold:", 0);
		Dialog.addNumber("Total upper threshold", 150);
		Dialog.show();
		sigmaT = Dialog.getNumber();
		LowerT = Dialog.getNumber();
		UpperT = Dialog.getNumber();
	}
	Dialog.create("Setting Particle Exclusion");
	Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the nuclei in the particle analysis");
	Dialog.addNumber("Total lower size exclusion:", 0);
	Dialog.addString("Total upper size exclusion:", "infinity");
	Dialog.addNumber("Total lower circularity exclusion:", 0.00);
	Dialog.addNumber("Total upper circularity exclusion:", 1.00);
	Dialog.addMessage("Would you like to watershed (segment)\nthe tissue?");
	Dialog.addCheckbox("watershed", false);
	Dialog.addMessage("Would you like to exclude the tissue\nat the edges?");
	Dialog.addCheckbox("exclude", false);
	Dialog.addMessage("Would you like to fill holes?");
	Dialog.addCheckbox("fill holes", false);
	Dialog.show();
	lseT = Dialog.getNumber();
	useT = Dialog.getString();
	lceT = Dialog.getNumber();
	uceT = Dialog.getNumber();
	watershedT = Dialog.getCheckbox();	
	excludeT = Dialog.getCheckbox();
	fillT = Dialog.getCheckbox();
	if (thresh == "Automatic"){
		if (positive == "Basic"){
		Dialog.create("Positive selection");
		Dialog.addMessage("Gaussian blur for positive selection:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addMessage("Threshold method for positive selection:");
		Dialog.addChoice("", newArray("Huang","Li","Otsu","Shanbhag","Yen"));
		Dialog.show();
		sigmaP = Dialog.getNumber();
		methodP = Dialog.getChoice();
		} else if (positive == "Enhanced"){
		Dialog.create("Positive selection");
		Dialog.addMessage("Gaussian blur for positive selection:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addMessage("Threshold method for positive selection:");
		Dialog.addChoice("", newArray("Intermodes","MaxEntropy","Otsu","Moments","Yen"));
		Dialog.show();
		sigmaP = Dialog.getNumber();
		methodP = Dialog.getChoice();
	}
	}else {
		Dialog.create("Positive selection");
		Dialog.addMessage("Gaussian blur for positive selection:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addNumber("Positive lower threshold:", 0);
		Dialog.addNumber("Positive upper threshold", 150);
		Dialog.show();
		sigmaP = Dialog.getNumber();
		LowerP = Dialog.getNumber();
		UpperP = Dialog.getNumber();
	}
	Dialog.create("Setting Particle Exclusion");
	Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the nuclei in the particle analysis");
	Dialog.addNumber("Positive lower size exclusion:", 0);
	Dialog.addString("Positive upper size exclusion:", "infinity");
	Dialog.addNumber("Positive lower circularity exclusion:", 0.00);
	Dialog.addNumber("Positive upper circularity exclusion:", 1.00);
	Dialog.addMessage("Would you like to watershed (segment)\nthe tissue?");
	Dialog.addCheckbox("watershed", false);
	Dialog.addMessage("Would you like to exclude the tissue\nat the edges?");
	Dialog.addCheckbox("exclude", false);
	Dialog.addMessage("Would you like to fill holes?");
	Dialog.addCheckbox("fill holes", false);
	Dialog.show();
	lseP = Dialog.getNumber();
	useP = Dialog.getString();
	lceP = Dialog.getNumber();
	uceP = Dialog.getNumber();
	watershedP = Dialog.getCheckbox();
	excludeP = Dialog.getCheckbox();
	fillP = Dialog.getCheckbox();

	tableTitle3="H&E Summary";
	tableTitle4="["+tableTitle3+"]";
	run("Table...", "name="+tableTitle4+" width=600 height=250");
	print(tableTitle4,"\\Headings:Image name\tTotal Count\tPositive Count\tPercent Count\tTotal Area\tPositive Area\tPercent Area");

	Dialog.create("Image format");
	Dialog.addMessage("What is the image format?");
	Dialog.addChoice("Type:", newArray("tif", "tiff", "jpg", "jpeg", "png", "gif", "bmp", "custom"));
	Dialog.show();
	type = Dialog.getChoice();
	if (type == "custom"){
		Dialog.create("Image name");
		Dialog.addMessage("Please type the word that is common in all images\n(Case sensitive)");
		Dialog.addString("Common letters/words", "");
		Dialog.show();
		word = Dialog.getString();
		for(i=0; i<list.length; i++){
		filename = dir + list[i];
		if (matches(filename, ".*"+word+".*")){
			open(filename);
			HEAnalysis();
		}//end of IF for matching word
		}//end of FOR
			}else { 
				for(i=0; i<list.length; i++){
					filename = dir + list[i];
					if (endsWith(filename, type)){
						open(filename);
						HEAnalysis();
					}//end of IF for matching file extension
				}//end of FOR
			}//end of ELSE for selecting file based on file type
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
selectWindow("H&E Summary");
saveAs("Results",  dir+tableTitle3+".xls");
selectWindow("H&E Summary");
run("Close");

waitForUser("Finished!","The analysis is now complete. The new files are now saved in the target folder and\nthe results file is labeled 'H&E Summary'.");
}//end of function Analysis
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
		
		
		
Total Analysis 016

		
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
function HEAnalysis(){
nameStore = getTitle();
if(total=="Enhanced"){//if "enhanced" was selected for total selection
	run("Dichromacy", "simulate=Deuteranope create");
	run("Colour Deconvolution", "vectors=[FastRed FastBlue DAB]");
	selectWindow("Colour Deconvolution");
	close();
	selectWindow(nameStore+"-Deuteranope-(Colour_1)");
	close();
	selectWindow(nameStore+"-Deuteranope-(Colour_3)");
	close();
	selectWindow(nameStore+"-Deuteranope-(Colour_2)");
	rename("Duplicate");
} else {//if "basic" was selected for total selection
	run("Duplicate...", " ");
	rename("Duplicate");
}
selectWindow("Duplicate");
run("Gaussian Blur...", "sigma=sigmaT");
run("8-bit");
selectWindow("Duplicate");
if (thresh == "Automatic"){//automatic threshold for total selection
	if(total== "Basic"){//automatic threshold for basic total selection
		if(methodT=="Huang"){
			run("Auto Threshold", "method=Huang white");
			}
		if(methodT=="Li"){
			run("Auto Threshold", "method=Li white");
			}
		if(methodT=="Otsu"){
			run("Auto Threshold", "method=Otsu white");
			}
		if(methodT=="Shanbhag"){
			run("Auto Threshold", "method=Shanbhag white");
			}
		if(methodT=="Yen"){
			run("Auto Threshold", "method=Yen white");
			}
			run("Invert LUT");
			setThreshold(0, 254);
	} else {//automatic threshold for enhanced total selection
		if(methodT=="Moments"){
			run("Auto Threshold", "method=Moments white");
			}
		if(methodT=="MaxEntropy"){
			run("Auto Threshold", "method=MaxEntropy white");
			}
		if(methodT=="Otsu"){
			run("Auto Threshold", "method=Otsu white");
			}
		if(methodT=="Triangle"){
			run("Auto Threshold", "method=Triangle white");
			}
		if(methodT=="Yen"){
			run("Auto Threshold", "method=Yen white");
			}
			run("Invert LUT");
			setThreshold(0, 254);
		}//end of ELSE for automatic threshold for enhanced total selection
	} else {//manual thresholding		
	setAutoThreshold("Default dark");
	run("Threshold...");
	setThreshold(LowerT,UpperT);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	setThreshold(1, 255);	
		}
	if (fillT == true){
		selectWindow("Duplicate");
		run("Fill Holes");
	}
	if (watershedT == true){
		selectWindow("Duplicate");
		run("Watershed");
	}
	roiManager("Reset");
	if (excludeT == true){
		IJ.redirectErrorMessages();
		run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks exclude add");
	} else {		'
		IJ.redirectErrorMessages();
		run("Analyze Particles...", "size=lseT-useT pixel circularity=lceT-uceT show=Masks add");
	}
	rename("Mask");
	if(isOpen("Log")==1){
	selectWindow("Log");
	run("Close");
	}
	setAutoThreshold("Default dark");
	//run("Threshold...");
	setThreshold(10, 255);
	run("Set Measurements...", "area limit redirect=None decimal=3");
	run("Set Scale...", "distance=dist known=know unit=unit");
	run("Measure");
	if(getResult('Area', nResults-1)!=0) {
	totalArea = getResult('Area', nResults-1);
	} else {
		totalArea = 0;
	}
	if (roiManager("count")!=0) {
		totalCount = roiManager("count");
		if (TR == true){
		roiManager("Save",  dir+nameStore+" - Total.zip");
		}
		if (TM == true){
		selectWindow("Mask");
		saveAs("Tiff", dir+nameStore+" - Total Mask");
		rename("Mask");
		}
		if (TO == true){
			selectWindow(nameStore);
			roiManager("Show All without labels");
			roiManager("Set Fill Color", "red");
			run("Flatten");
			saveAs("Tiff", dir+nameStore+" - Total Overlay");
			selectWindow(nameStore);
			roiManager("Set Color", "yellow");
			} 
	}	else {
				totalCount = 0;
			}
	if(isOpen("ROI Manager")==1){
		selectWindow("ROI Manager");
		run("Close");
	}
	selectWindow(nameStore);	
	close("\\Others");




/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
		
		
		
Positive Analysis 017

		
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
	selectWindow(nameStore);
	if(positive=="Enhanced"){//if "enhanced" was selected for positive selection
		run("Dichromacy", "simulate=Tritanope create");
		run("Colour Deconvolution", "vectors=[H&E DAB]");
		selectWindow("Colour Deconvolution");
		close();
		selectWindow(nameStore+"-Tritanope-(Colour_3)");
		close();
		selectWindow(nameStore+"-Tritanope-(Colour_2)");
		close();
		selectWindow(nameStore+"-Tritanope-(Colour_1)");
		rename("Duplicate");
	} else {//if "basic" was selected for positive selection
		run("Colour Deconvolution", "vectors=[H&E]");
		selectWindow("Colour Deconvolution");
		close();
		selectWindow(nameStore+"-(Colour_3)");
		close();
		selectWindow(nameStore+"-(Colour_2)");
		close();
		selectWindow(nameStore+"-(Colour_1)");
		rename("Duplicate");
	}	
	selectWindow("Duplicate");
	run("Gaussian Blur...", "sigma=sigmaP");
	run("8-bit");
	selectWindow("Duplicate");
	if (thresh == "Automatic"){//automatic threshold for positive selection
		if(positive== "Basic"){//automatic threshold for basic positive selection
			if(methodP=="Huang"){
				run("Auto Threshold", "method=Huang white");
				}
			if(methodP=="Li"){
				run("Auto Threshold", "method=Li white");
				}
			if(methodP=="Otsu"){
				run("Auto Threshold", "method=Otsu white");
				}
			if(methodP=="Shanbhag"){
				run("Auto Threshold", "method=Shanbhag white");
				}
			if(methodP=="Yen"){
				run("Auto Threshold", "method=Yen white");
				}
			run("Invert LUT");
			setThreshold(0, 254);
		} else {//automatic threshold for enhanced positive selection
			if(methodP=="Intermodes"){
				run("Auto Threshold", "method=Intermodes white");
				}
			if(methodP=="MaxEntropy"){
				run("Auto Threshold", "method=MaxEntropy white");
				}
			if(methodP=="Otsu"){
				run("Auto Threshold", "method=Otsu white");
				}
			if(methodP=="Moments"){
				run("Auto Threshold", "method=Moments white");
				}
			if(methodP=="Yen"){
				run("Auto Threshold", "method=Yen white");
				}
			run("Invert LUT");
			setThreshold(0, 254);
		}//end of ELSE for automatic threshold for enhanced total selection
	} else {//manual thresholding
		setAutoThreshold("Default dark");
		run("Threshold...");
		setThreshold(LowerP,UpperP);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		setThreshold(1, 255);	
		}
	if (fillP == true){
		selectWindow("Duplicate");
		run("Fill Holes");
	}
	if (watershedP == true){
		selectWindow("Duplicate");
		run("Watershed");
	}
	roiManager("Reset");
	if (excludeP == true){
		IJ.redirectErrorMessages();
		run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks exclude add");
	} else {		'
		IJ.redirectErrorMessages();
		run("Analyze Particles...", "size=lseP-useP pixel circularity=lceP-uceP show=Masks add");
	}
	rename("Mask");
	if(isOpen("Log")==1){
	selectWindow("Log");
	run("Close");
	}
	
	setAutoThreshold("Default dark");
	//run("Threshold...");
	setThreshold(10, 255);	
	run("Set Measurements...", "area limit redirect=None decimal=3");
	run("Set Scale...", "distance=dist known=know unit=unit");
	run("Measure");
	if(getResult('Area', nResults-1)!=0) {
	positiveArea = getResult('Area', nResults-1);
	} else {
		positiveArea = 0;
	}
	if (roiManager("count")!=0) {
		positiveCount = roiManager("count");
		if (PR == true){
			roiManager("Save",  dir+nameStore+" - Positive.zip");
		}
		if (PM == true){
			selectWindow("Mask");
			saveAs("Tiff", dir+nameStore+" - Positive Mask");
			rename("Mask");
		}
		if (PO == true){
			selectWindow(nameStore);
			roiManager("Show All without labels");
			roiManager("Set Fill Color", "green");
			run("Flatten");
			saveAs("Tiff", dir+nameStore+" - Positive Overlay");
			selectWindow(nameStore);
			roiManager("Set Color", "yellow");
			} 
	}	else {
				positiveCount = 0;
			}
	if(isOpen("ROI Manager")==1){
		selectWindow("ROI Manager");
		run("Close");
	}
	run("Close All");
	percentCount = (positiveCount/totalCount)*100;
	percentArea = (positiveArea/totalArea)*100;
	print(tableTitle4, nameStore + "\t"  + totalCount + "\t" + positiveCount + "\t"  + percentCount + "\t"  + totalArea + "\t"  + positiveArea + "\t" + percentArea);
	}//end of function HEAnalysis




}//end of macro "H&E"
