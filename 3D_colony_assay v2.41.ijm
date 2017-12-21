macro "3D colony assay"{

//Ver 2.40
 /*
  * Ver 2.40 Update notes:
  * 
  * 1. Analysis now also includes the function Fill Holes
  * 
  * 2. Added Background Subtraction or Normalize Local Contrast method, watershed option, 
  *    exclude option, and fill holes option in optimization table. So users will
  *    know the exact parameters that were used not just the values now
  *    
  * 3. Optimization table now also includes the same table that comes up at the end
  *    when user finishes the optimization section
  */

//The 3D colony assay macro will measure all images located in a specified folder. 
//The files that are analyzed will be identified by a regular expression 
//as defined by the user.

//Installing this macro
// 1. On FIJI toolbar go to Plugins > Macros > Install
// 2. Select 3D_colony_assay.ijm and click Open
// 3. Go back to Plugins > Macros and you should now see the option of 3D colony assay
// 4. Select 3D colony assay and follow the prompts

/*
 * Contents
-------------------------------------
 Tutorial Section
 Background Subtraction Tutorial 001
 Normalize Local Contrast Tutorial 002
 Tutorial Optimization 003
 3D Colony Optimization 008
 3D Colony Analysis 013
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
	waitForUser("Thank you for choosing the tutorial","My name is Andy and I will help you analyze 3D colonies,\nsuch as a matrigel plug or tumour sphere assay. \n \nClick OK to continue.");
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
	if (type == "custom"){
			Dialog.create("Image name");
			Dialog.addMessage("Please type the word that is common in all images\n(Case sensitive)");
			Dialog.addString("Common letters/words", "");
			Dialog.show();
			word = Dialog.getString();
			for(i=0; i<1; i++){
			filename = dir + list[i];
				if (matches(filename, ".*"+word+".*")){
				open(filename);	
			}
				}
		}else { 
			for(i=0; i<1; i++){
				filename = dir + list[i];
				if (endsWith(filename, type)){
					open(filename);	
				}
				}
			}

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Background Subtraction Tutorial 001


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
	waitForUser("4. Remove the background","There are two methods that can be used to remove background; background subtraction and\nnormalize local contrast. We will try both methods to test which one is more suitable.\n \nClick OK to continue.");
	nameStore = getTitle();
	run("Duplicate...", " ");
	rename("Duplicate");
	run("Duplicate...", " ");
	rename("Test");
	waitForUser("5.Method 1 - Background subtraction","For the first method we will try a 'background subtraction'. A duplicate\nimage has been created to test which parameters are best for your images.\n \nCheck preview and test values between 0-100. Secondly, try testing \n'light background'. Once you have finished sampling your image, record\nthe background subtraction value as this will be required later.\n \nClick OK to continue.");
	run("Subtract Background...");
	waitForUser("6. Apply Gaussian blur to colonies","A Gaussian blur filter is applied to smooth out the edges of the colonies.\nIf you do not want this filter, enter 0 for 'sigma'. Click 'preview' to sample\nthe level of Gaussian blur.\n \nClick OK to continue.");
	run("Gaussian Blur...");
	selectWindow("Test");
	close();
	waitForUser("7. Return to the raw image","Now that the parameters have been optimized on the test image, we need to enter the\nparameters for the background subtraction and Gaussian blur on your original image.\n \nClick OK to continue.");
	selectWindow("Duplicate");
	Dialog.create("Remove background and smooth edges of colonies");
	Dialog.addMessage("Enter the background subtraction value.");
	Dialog.addNumber("     Radius (pixel):", 50);
	Dialog.addCheckbox("Light background", true);
	Dialog.addMessage("Gaussian Blur:");
	Dialog.addNumber("Sigma:", 2);
	Dialog.show();
	radius = Dialog.getNumber();
	light = Dialog.getCheckbox();
	sigma = Dialog.getNumber();
		if (light == true){
			run("Subtract Background...", "rolling=radius light");
		} else{
			run("Subtract Background...", "rolling=radius");
		}
	run("Gaussian Blur...", "sigma=sigma");
	run("8-bit");
	selectWindow("Duplicate");
	Dialog.create("Thresholding");
	Dialog.addMessage("Select automatic or manual threshold");
	Dialog.addChoice("", newArray("Automatic", "Manual"));
	Dialog.show();
	Thresh = Dialog.getChoice();
	if (Thresh == "Automatic"){
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
					run("Duplicate...", "title=Triangle");
					run("Auto Threshold", "method=Triangle white");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Yen");
					run("Auto Threshold", "method=Yen white");
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Triangle image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
					setSlice(3);
					setMetadata("Li");
					setSlice(4);
					setMetadata("Otsu");
					setSlice(5);
					setMetadata("Triangle");
					setSlice(6);
					setMetadata("Yen");
					run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
					Dialog.create("Thresholding");
					Dialog.addMessage("Select the automatic method");
					Dialog.addChoice("", newArray("Huang","Li","Otsu","Triangle","Yen"));
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
					if(method=="Triangle"){
						run("Auto Threshold", "method=Triangle white");
					}
					if(method=="Yen"){
						run("Auto Threshold", "method=Yen white");
					}
					waitForUser("8. Set an automatic threshold","A threshold will be applied to the images using the tools available\nin Image > Adjust > Auto Threshold. Once selected the threshold\nwill be adjusted on each image based on the method chosen.\n \nClick OK to continue.");
					Lower = "Auto="+method;
					Upper = "NaN";
					selectWindow("Duplicate");
					setThreshold(10, 255);
					if (light == true){
						run("Invert LUT");
						setThreshold(0, 254);
					}
				} else{
					selectWindow("Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					if(light== true){
						setThreshold(0, 150);
						waitForUser("8. Manual Threshold","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the bottom slide bar in the threshold window until most colonies have\nbeen selected. Selected colonies will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
						} else{
							setThreshold(50, 255);
							waitForUser("8. Manual Threshold","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the top slide bar in the threshold window until most colonies have\nbeen selected. Selected colonies will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
						}
					getThreshold(Lower,Upper);
					selectWindow("Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(10, 255);
				}
				run("Set Measurements...", "area shape limit redirect=None decimal=3");
				waitForUser("9. Exclusion for positive nuclei","To exclude small and large particle and background artifacts, you must now select an upper and lower\nsize exclusion. Test different size exclusion parameters to determine which work best for your images.\nTry a lower size exclusion of 150 pixels and an upper size exclusion of infinity as a starting point.\nYou can also apply a lower and upper circularity exclusion between 0 to 1, where 1 is a perfect circle.\n \nNuclei can be segmented by clicking the watershed checkbox.\n \nEdge exclusion can be included to omit any incomplete nuclei at the edge of the image.\n \nSelections with holes in the centre can also be filled.\n \nClick OK to continue."); 
				selectWindow("Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				roiManager("Reset");
				particle();
				function particle(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.addMessage("Would you like to fill holes?");
				Dialog.addCheckbox("fill holes", false);
				Dialog.show();
				lse = Dialog.getNumber();
				use = Dialog.getString();
				lce = Dialog.getNumber();
				uce = Dialog.getNumber();
				watershed = Dialog.getCheckbox();
				exclude = Dialog.getCheckbox();
				fillh = Dialog.getCheckbox();
				selectWindow("Duplicate");
				if (fillh == true){
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
					run("Fill Holes");
				}
				if (watershed == true){
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
				} else{
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
				}
					run("Watershed");
				}
				if (exclude == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
				} else {		'
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
				}
				rename("Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");
				setResult("Lower Size Exclusion",nResults-1,lse);
				setResult("Upper Size Exclusion",nResults-1,use);
				setResult("Lower Circularity Exclusion",nResults-1,lce);
				setResult("Upper Circularity Exclusion",nResults-1,uce);
				setResult("Watershed",nResults-1,watershed);
				setResult("Edge Exclusion",nResults-1,exclude);
				setResult("Fill Holes",nResults-1,fillh);
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
				if(retry=="no"){
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Mask");
					close();
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Duplicate");
					particle();
						} else{
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate");
							close();
							selectWindow("Duplicate2");
							rename("Duplicate");
							}
						} 
				}		
				lse = getResult("Lower Size Exclusion",nResults-1);
				use = getResult("Upper Size Exclusion",nResults-1);
				lce = getResult("Lower Circularity Exclusion",nResults-1);
				uce = getResult("Upper Circularity Exclusion",nResults-1);
				watershed = getResult("Watershed",nResults-1);
				exclude = getResult("Edge Exclusion",nResults-1);
				fillh = getResult("Fill Holes",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				waitForUser("10. Create an overlay image.", "With the exclusion complete, an overlay image will be produced\nfrom the original image to visualize the accuracy of your selection.\n \nClick OK to continue.");
				selectWindow("Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area shape limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");
				if(getResult('Area', nResults-1)!=0) {
					totalArea = getResult('Area', nResults-1);
				} else {
					totalArea = 0;
					}
				if(getResult('Circ.', nResults-1)!=0) {
					totalCirc = getResult('Circ.', nResults-1);
				} else {
					totalCirc = 0;
					}
				if (roiManager("count")!=0) {
					Count = roiManager("count");
					averageArea = totalArea/Count;
					averageCirc = totalCirc/Count;
					selectWindow(nameStore);
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "red");
					run("Flatten");
					rename("Background-Subtraction");
					selectWindow(nameStore);
					roiManager("Set Color", "yellow");
				} else {
					Count = 0;
					averageArea = 0;
					averageCirc = 0;
					}
				selectWindow("Duplicate");
				close();
				selectWindow("Mask");
				close();
				roiManager("Reset");

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Normalize Local Contrast Tutorial 002


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				selectWindow(nameStore);
				run("Duplicate...", " ");
				rename("Duplicate");
				run("Duplicate...", " ");
				rename("Test");
				waitForUser("11. Method 2 - Normalize Local Contrast","We will now test the 'normalise local contrast' method. This method balances out the\nbrightness of the background while maintaining the local contrast of the colonies.\nA duplicate image has been created to test the parameters of this method.\n \nRecommended: Use the same values for 'block radius x' and block radius y'. Try a value\nof 40 for both block radius x and y and a standard deviation of 3.\n \nEnsure you tick the 'center' and preview checkboxes to visualize the changes you have\nmade to the image. Once the parameters are optimized, record them as they will be\nused to apply to the raw images. \n \nClick OK to continue.");
				run("Normalize Local Contrast");
				waitForUser("12. Apply Gaussian blur to colonies","A Gaussian blur filter is applied to smooth out the edges of the colonies.\nIf you do not want this filter, enter 0 for 'sigma'. Click 'preview' to sample\nthe level of Gaussian blur.\n \nClick OK to continue.");
				run("Gaussian Blur...");
				selectWindow("Test");
				close();
				waitForUser("13. Return to the raw image","Now that the parameters have been optimized on the test image, we need to enter the\nparameters for the normalise local contrast and Gaussian blur on your original image.\n \nClick OK to continue.");
				selectWindow("Duplicate");
				Dialog.create("Remove background and smooth edges of colonies");
				Dialog.addMessage("Enter values to normalize local contrast.");
				Dialog.addNumber("block radius x:", 40);
				Dialog.addNumber("block radius y:", 40);
				Dialog.addCheckbox("center", true);
				Dialog.addMessage("Gaussian Blur:");
				Dialog.addNumber("Sigma:", 2);
				Dialog.show();
				x = Dialog.getNumber();
				y = Dialog.getNumber();
				center = Dialog.getCheckbox();
				sigma = Dialog.getNumber();
				if (center == true){
					run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=3 center");
				} else{
					run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=3");
				}
			run("Gaussian Blur...", "sigma=sigma");
			run("8-bit");
			selectWindow("Duplicate");
			Dialog.create("Thresholding");
			Dialog.addMessage("Select automatic or manual threshold");
			Dialog.addChoice("", newArray("Automatic", "Manual"));
			Dialog.show();
			Thresh = Dialog.getChoice();
			if (Thresh == "Automatic"){
					selectWindow("Duplicate");
					run("Duplicate...", "title=Original");
					selectWindow("Duplicate");
					run("Duplicate...", "title=Huang");
					run("Auto Threshold", "method=Huang white");
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
					run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
					setSlice(1); 
					setMetadata("Original");
					setSlice(2);
					setMetadata("Huang");
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
					Dialog.addChoice("", newArray("Huang","MaxEntropy","Otsu","Triangle","Yen"));
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
					waitForUser("14. Setting the automatic threshold","A threshold will be applied to the images using the tools available\nin Image > Adjust > Auto Threshold. Once selected the threshold\nwill be adjusted on each image based on the method chosen.\n \nClick OK to continue.");
					Lower = "Auto="+method;
					Upper = "NaN";
					selectWindow("Duplicate");
					run("Invert LUT");
					setThreshold(0, 254);
				} else{
					selectWindow("Duplicate");
					setAutoThreshold("Default dark");
					run("Threshold...");
					setThreshold(0, 150);
		  			waitForUser("14. Setting the manual threshold","A threshold will be applied by selecting a set value on each image. To do this,\nadjust the bottom slide bar in the threshold window until most nuclei have\nbeen selected. Selected nuclei will become red. Once an optimum threshold\nvalue has been selected click OK in this dialog box to apply.\n \n NOTE: Do not click anywhere else in the threshold window.");
					getThreshold(Lower,Upper);
					selectWindow("Duplicate");
					setOption("BlackBackground", true);
					run("Convert to Mask");
					setThreshold(1, 255);
				}
				run("Set Measurements...", "area shape limit redirect=None decimal=3");
				waitForUser("15. Exclusion of colonies","To exclude small and large particle and background artifacts, you must now select an upper and lower\nsize exclusion. Test different size exclusion parameters to determine which work best for your images.\nTry a lower size exclusion of 150 pixels and an upper size exclusion of infinity as a starting point.\nYou can also apply a lower and upper circularity exclusion between 0 to 1, where 1 is a perfect circle.\n \nColonies can be segmented by clicking the watershed checkbox.\n \nEdge exclusion can be included to omit any incomplete colonies at the edge of the image. \n \nClick OK to continue."); 
				selectWindow("Duplicate");
				run("Measure");
				IJ.deleteRows(nResults-1, nResults-1);
				roiManager("Reset");
				particle();
				function particle(){
				Dialog.create("Size and Circularity Exclusion");
				Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
				Dialog.addNumber("Lower size exclusion:", 0);
				Dialog.addString("Upper size exclusion:", "infinity");
				Dialog.addNumber("Lower circularity exclusion:", 0.00);
				Dialog.addNumber("Upper circularity exclusion:", 1.00);
				Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
				Dialog.addCheckbox("watershed", true);
				Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
				Dialog.addCheckbox("exclude", true);
				Dialog.addMessage("Would you like to fill holes?");
				Dialog.addCheckbox("fill holes", false);
				Dialog.show();
				lse = Dialog.getNumber();
				use = Dialog.getString();
				lce = Dialog.getNumber();
				uce = Dialog.getNumber();
				watershed = Dialog.getCheckbox();
				exclude = Dialog.getCheckbox();
				fillh = Dialog.getCheckbox();
				selectWindow("Duplicate");
				if (fillh == true){
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
					run("Fill Holes");
				}
				if (watershed == true){
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
				} else{
					selectWindow("Duplicate");
					run("Duplicate...", "title=Duplicate2");
				}
					run("Watershed");
				}
				if (exclude == true){
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
				} else {		'
					IJ.redirectErrorMessages();
					run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
				}
				rename("Mask");
				if(isOpen("Log")==1){
					selectWindow("Log");
					run("Close");
					}
				run("Measure");
				setResult("Lower Size Exclusion",nResults-1,lse);
				setResult("Upper Size Exclusion",nResults-1,use);
				setResult("Lower Circularity Exclusion",nResults-1,lce);
				setResult("Upper Circularity Exclusion",nResults-1,uce);
				setResult("Watershed",nResults-1,watershed);
				setResult("Edge Exclusion",nResults-1,exclude);
				setResult("Fill Holes",nResults-1,fillh);
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
				if(retry=="no"){
					IJ.deleteRows(nResults-1, nResults-1);
					selectWindow("Mask");
					close();
					if (isOpen("Duplicate2")==1){
					selectWindow("Duplicate2");
					close();
					}
					roiManager("Reset");
					selectWindow("Duplicate");
					particle();
						} else{
							if (isOpen("Duplicate2")==1){
							selectWindow("Duplicate");
							close();
							selectWindow("Duplicate2");
							rename("Duplicate");
							}
						} 
				}		
				lse = getResult("Lower Size Exclusion",nResults-1);
				use = getResult("Upper Size Exclusion",nResults-1);
				lce = getResult("Lower Circularity Exclusion",nResults-1);
				uce = getResult("Upper Circularity Exclusion",nResults-1);
				watershed = getResult("Watershed",nResults-1);
				exclude = getResult("Edge Exclusion",nResults-1);
				fillh = getResult("Fill Holes",nResults-1);
				IJ.deleteRows(nResults-1, nResults-1);
				selectWindow("Mask");
				setAutoThreshold("Default dark");
				//run("Threshold...");
				setThreshold(10, 255);
				run("Set Measurements...", "area shape limit redirect=None decimal=3");
				run("Set Scale...", "distance=0 known=0 unit=pixel");
				run("Measure");
				if(getResult('Area', nResults-1)!=0) {
					totalArea = getResult('Area', nResults-1);
				} else {
					totalArea = 0;
					}
				if(getResult('Circ.', nResults-1)!=0) {
					totalCirc = getResult('Circ.', nResults-1);
				} else {
					totalCirc = 0;
					}
				if (roiManager("count")!=0) {
					Count = roiManager("count");
					averageArea = totalArea/Count;
					averageCirc = totalCirc/Count;
					selectWindow(nameStore);
					roiManager("Show All without labels");
					roiManager("Set Fill Color", "blue");
					run("Flatten");
					rename("Normalize-Local-Contrast");
					selectWindow(nameStore);
					roiManager("Set Color", "yellow");
				} else {
					Count = 0;
					averageArea = 0;
					averageCirc = 0;
					}
				selectWindow("Duplicate");
				close();
				selectWindow("Mask");
				close();
				roiManager("Reset");
				selectWindow(nameStore);
				run("Duplicate...", " ");
				rename("Original");
				run("RGB Color");
				run("Concatenate...", "  title=Stacks image1=Original image2=Background-Subtraction image3=Normalize-Local-Contrast");
				setSlice(1); 
				setMetadata("Original");
				setSlice(2);
				setMetadata("Background-Subtraction");
				setSlice(3);
				setMetadata("Normalize-Local-Contrast");
				run("Make Montage...", "columns=3 rows=1 first=1 last=3 increment=1 border=0 font=25 label");
				waitForUser("16. Comparing the two methods of removing background","A montage has been created to compare both methods of removing background\nto determine the best method. Select the best method and now complete the\noptimization for the rest of the images in the test folder when you click OK.");
				selectWindow("Results");
				run("Close");
				if(isOpen("ROI Manager")==1){
					selectWindow("ROI Manager");
					run("Close");
					}
				run("Close All");
				waitForUser("17. Set the scale", "Optional: If you know the units for each pixel in the images you can now set the\nscale. For more detail refer to https://imagej.net/SpatialCalibration.\n \nWhen you click OK, a dialog box will appear for you to set the scale, if you do not\nknow the pixel length and distance simply click OK. You can also set a scale later\nduring analysis.\n \nClick OK to proceed.");
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


Tutorial Optimization 003


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
				sub = "Subtract Background";
				norm = "Normalize Local Contrast";
				Dialog.create("Method");
				Dialog.addMessage("Select method for removing background");
				Dialog.addChoice("Method:", newArray(sub, norm));
				Dialog.show();
				tech = Dialog.getChoice();
				if (tech == sub){
				tableTitle="3D Colony Optimization";
				tableTitle2="["+tableTitle+"]";
				run("Table...", "name="+tableTitle2+" width=400 height=250");
				print(tableTitle2,"\\Headings:Image name\tBackground Subtraction Radius\tGaussian Blur\tLower Threshold\tUpper Threshold\tLower Size Exclusion\tUpper Size Exclusion\tLower Circularity Exclusion\tUpper Circularity Exclusion\tWatershed\tEdge Exclusion\tFill Holes");		
				} else {
					tableTitle="3D Colony Optimization";
					tableTitle2="["+tableTitle+"]";
					run("Table...", "name="+tableTitle2+" width=400 height=250");
					print(tableTitle2,"\\Headings:Image name\tBlock Radius x\tBlock Radius y\tStandard Deviation\tGaussian Blur\tLower Threshold\tUpper Threshold\tLower Size Exclusion\tUpper Size Exclusion\tLower Circularity Exclusion\tUpper Circularity Exclusion\tWatershed\tEdge Exclusion\tFill Holes");		
				} 
				 if (type == "custom"){
					for(i=0; i<list.length; i++){
					filename = dir + list[i];
						if (matches(filename, ".*"+word+".*")){
						open(filename);
						if(tech==sub){
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Background Subtraction Adjustment 004


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Background subtraction","A duplicate image has been created to test which parameters are best for your images. Check\npreview and test values between 0-100. Secondly, try testing the 'light background' check box.\n \nOnce you have finished sampling your image, record the background subtraction values as\nthis will be required later.\n \nClick OK to continue.");
							run("Subtract Background...");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter the background subtraction value.");
							Dialog.addNumber("     Radius (pixel):", 50);
							Dialog.addCheckbox("Light background", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							radius = Dialog.getNumber();
							light = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
								if (light == true){
									run("Subtract Background...", "rolling=radius light");
								} else{
									run("Subtract Background...", "rolling=radius");
								}
							run("Gaussian Blur...", "sigma=sigma");
							run("8-bit");
							selectWindow("Duplicate");
							Dialog.create("Thresholding");
							Dialog.addMessage("Select automatic or manual threshold");
							Dialog.addChoice("", newArray("Automatic", "Manual"));
							Dialog.show();
							Thresh = Dialog.getChoice();
							if (Thresh == "Automatic"){
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
								run("Duplicate...", "title=Triangle");
								run("Auto Threshold", "method=Triangle white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Triangle");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Triangle","Yen"));
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
								if(method=="Triangle"){
									run("Auto Threshold", "method=Triangle white");
								}
								if(method=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								Lower = "Auto="+method;
								Upper = "NaN";
								selectWindow("Duplicate");
								setThreshold(10, 255);
								if (light == true){
									run("Invert LUT");
									setThreshold(0, 254);
								}
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								if(light== true){
									setThreshold(0, 150);
									waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
									} else{
										setThreshold(50, 255);
									waitForUser("Select for all colonies\nusing the top slide bar in the Threshold window. Click OK to proceed.");
									}
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "red");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Background-Subtraction");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
								run("Close All");
								if(isOpen("ROI Manager")==1){
									selectWindow("ROI Manager");
									run("Close");
									}
								setResult("Background Subtraction Radius",nResults-1,radius);
								setResult("Gaussian Blur",nResults-1,sigma);	
								setResult("Lower Threshold",nResults-1,Lower);
								setResult("Upper Threshold",nResults-1,Upper);	
								setResult("Lower Size Exclusion",nResults-1,lse);
								setResult("Upper Size Exclusion",nResults-1,use);
								setResult("Lower Circularity Exclusion",nResults-1,lce);
								setResult("Upper Circularity Exclusion",nResults-1,uce);
								setResult("Watershed",nResults-1,watershed);
								setResult("Edge Exclusion",nResults-1,exclude);
								setResult("Fill Holes",nResults-1,fillh);						
								updateResults();
								if(watershed==1){
								watershed = "TRUE";
								} else {
									watershed = "FALSE";
								}
								if(exclude==1){
									exclude = "TRUE";
								} else {
									exclude = "FALSE";
								}
								if(fillh==1){
									fillh = "TRUE";
								} else {
									fillh = "FALSE";
								}
								print(tableTitle2, nameStore + "\t"  + radius + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
						} else {
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Normalize Local Contrast Adjustment 005


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Normalize local contrast","A duplicate image has been created to test which parameters are best for your images.\nRecommended: Use the same values for 'block radius x' and block radius y'. Try a value\nof 40 for both block radius x and y and a standard deviation of 3.\n \nEnsure you tick the 'center' and preview checkboxes to visualize the changes you have\nmade to the image. Once the parameters are optimized, record them as they will be\nused to apply to the raw images. \n \nClick OK to continue.");
							run("Normalize Local Contrast");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter values to normalize local contrast.");
							Dialog.addNumber("block radius x:", 40);
							Dialog.addNumber("block radius y:", 40);
							Dialog.addNumber("standard deviation:", 3);
							Dialog.addCheckbox("center", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							con = Dialog.getChoice();
							x = Dialog.getNumber();
							y = Dialog.getNumber();
							std = Dialog.getNumber();
							center = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
							if (center == true){
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std center");
							} else{
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std");
							}
						run("Gaussian Blur...", "sigma=sigma");
						run("8-bit");
						selectWindow("Duplicate");
						Dialog.create("Thresholding");
						Dialog.addMessage("Select automatic or manual threshold");
						Dialog.addChoice("", newArray("Automatic", "Manual"));
						Dialog.show();
						Thresh = Dialog.getChoice();
						if (Thresh == "Automatic"){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
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
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
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
								Dialog.addChoice("", newArray("Huang","MaxEntropy","Otsu","Triangle","Yen"));
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
								selectWindow("Duplicate");
								run("Invert LUT");
								setThreshold(0, 254);
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
					  			waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(1, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "blue");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Normalize-Local-Contrast");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
							run("Close All");
							if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
								}
							setResult("Block Radius x",nResults-1,x);
							setResult("Block Radius y",nResults-1,y);
							setResult("Standard Deviation",nResults-1,std);
							setResult("Gaussian Blur",nResults-1,sigma);	
							setResult("Lower Threshold",nResults-1,Lower);
							setResult("Upper Threshold",nResults-1,Upper);	
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);						
							updateResults();
							if(watershed==1){
							watershed = "TRUE";
							} else {
								watershed = "FALSE";
							}
							if(exclude==1){
								exclude = "TRUE";
							} else {
								exclude = "FALSE";
							}
							if(fillh==1){
								fillh = "TRUE";
							} else {
								fillh = "FALSE";
							}
							print(tableTitle2, nameStore + "\t"  + x + "\t"  + y + "\t"  + std + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
						} 
					}//end of IF for matching word
						}//end of FOR
				}else { 
					for(i=0; i<list.length; i++){
						filename = dir + list[i];
						if (endsWith(filename, type)){
							open(filename);
							if(tech==sub){
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Background Subtraction Adjustment 006


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Background subtraction","A duplicate image has been created to test which parameters are best for your images. Check\npreview and test values between 0-100. Secondly, try testing the 'light background' check box.\n \nOnce you have finished sampling your image, record the background subtraction values as\nthis will be required later.\n \nClick OK to continue.");
							run("Subtract Background...");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter the background subtraction value.");
							Dialog.addNumber("     Radius (pixel):", 50);
							Dialog.addCheckbox("Light background", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							radius = Dialog.getNumber();
							light = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
								if (light == true){
									run("Subtract Background...", "rolling=radius light");
								} else{
									run("Subtract Background...", "rolling=radius");
								}
							run("Gaussian Blur...", "sigma=sigma");
							run("8-bit");
							selectWindow("Duplicate");
							Dialog.create("Thresholding");
							Dialog.addMessage("Select automatic or manual threshold");
							Dialog.addChoice("", newArray("Automatic", "Manual"));
							Dialog.show();
							Thresh = Dialog.getChoice();
							if (Thresh == "Automatic"){
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
								run("Duplicate...", "title=Triangle");
								run("Auto Threshold", "method=Triangle white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Triangle");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Triangle","Yen"));
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
								if(method=="Triangle"){
									run("Auto Threshold", "method=Triangle white");
								}
								if(method=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								Lower = "Auto="+method;
								Upper = "NaN";
								selectWindow("Duplicate");
								setThreshold(10, 255);
								if (light == true){
									run("Invert LUT");
									setThreshold(0, 254);
								}
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								if(light== true){
									setThreshold(0, 150);
									waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
									} else{
										setThreshold(50, 255);
										waitForUser("Select for all colonies\nusing the top slide bar in the Threshold window. Click OK to proceed.");
									}
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "red");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Background-Subtraction");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
								run("Close All");
								if(isOpen("ROI Manager")==1){
									selectWindow("ROI Manager");
									run("Close");
									}
								setResult("Background Subtraction Radius",nResults-1,radius);
								setResult("Gaussian Blur",nResults-1,sigma);	
								setResult("Lower Threshold",nResults-1,Lower);
								setResult("Upper Threshold",nResults-1,Upper);	
								setResult("Lower Size Exclusion",nResults-1,lse);
								setResult("Upper Size Exclusion",nResults-1,use);
								setResult("Lower Circularity Exclusion",nResults-1,lce);
								setResult("Upper Circularity Exclusion",nResults-1,uce);
								setResult("Watershed",nResults-1,watershed);
								setResult("Edge Exclusion",nResults-1,exclude);
								setResult("Fill Holes",nResults-1,fillh);						
								updateResults();
								if(watershed==1){
								watershed = "TRUE";
								} else {
									watershed = "FALSE";
								}
								if(exclude==1){
									exclude = "TRUE";
								} else {
									exclude = "FALSE";
								}
								if(fillh==1){
									fillh = "TRUE";
								} else {
									fillh = "FALSE";
								}
								print(tableTitle2, nameStore + "\t"  + radius + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
							} else {
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Normalize Local Contrast Adjustment 007


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/

							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Normalize local contrast","A duplicate image has been created to test which parameters are best for your images.\nRecommended: Use the same values for 'block radius x' and block radius y'. Try a value\nof 40 for both block radius x and y and a standard deviation of 3.\n \nEnsure you tick the 'center' and preview checkboxes to visualize the changes you have\nmade to the image. Once the parameters are optimized, record them as they will be\nused to apply to the raw images. \n \nClick OK to continue.");
							run("Normalize Local Contrast");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter values to normalize local contrast.");
							Dialog.addNumber("block radius x:", 40);
							Dialog.addNumber("block radius y:", 40);
							Dialog.addNumber("standard deviation:", 3);
							Dialog.addCheckbox("center", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							con = Dialog.getChoice();
							x = Dialog.getNumber();
							y = Dialog.getNumber();
							std = Dialog.getNumber();
							center = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
							if (center == true){
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std center");
							} else{
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std");
							}
						run("Gaussian Blur...", "sigma=sigma");
						run("8-bit");
						selectWindow("Duplicate");
						Dialog.create("Thresholding");
						Dialog.addMessage("Select automatic or manual threshold");
						Dialog.addChoice("", newArray("Automatic", "Manual"));
						Dialog.show();
						Thresh = Dialog.getChoice();
						if (Thresh == "Automatic"){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
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
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
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
								Dialog.addChoice("", newArray("Huang","MaxEntropy","Otsu","Triangle","Yen"));
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
								selectWindow("Duplicate");
								run("Invert LUT");
								setThreshold(0, 254);
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
					  			waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(1, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "blue");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Normalize-Local-Contrast");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
							run("Close All");
							if(isOpen("ROI Manager")==1){
							selectWindow("ROI Manager");
							run("Close");
							}
							setResult("Block Radius x",nResults-1,x);
							setResult("Block Radius y",nResults-1,y);
							setResult("Standard Deviation",nResults-1,std);
							setResult("Gaussian Blur",nResults-1,sigma);	
							setResult("Lower Threshold",nResults-1,Lower);
							setResult("Upper Threshold",nResults-1,Upper);	
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);						
							updateResults();
							if(watershed==1){
								watershed = "TRUE";
								} else {
									watershed = "FALSE";
								}
								if(exclude==1){
									exclude = "TRUE";
								} else {
									exclude = "FALSE";
								}
								if(fillh==1){
									fillh = "TRUE";
								} else {
									fillh = "FALSE";
								}
							print(tableTitle2, nameStore + "\t"  + x + "\t"  + y + "\t"  + std + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
							}	
							}
						}
						}
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
				selectWindow("3D Colony Optimization");
				waitForUser("Optimization table", "Finally, a table with the optimization parameters will be saved\nas an Excel spreadsheet in the test folder. These parameters will\nbe used in the analysis dialog boxes to analyze your images.\n \nClick OK to continue.");
				if(isOpen("Results")==1){
				selectWindow("Results");
				if (tech == sub){
					radius_mean=0;
					radius_total=0;
					for (a=0; a<nResults(); a++) {
					    radius_total=radius_total+getResult("Background Subtraction Radius",a);
					    radius_mean=radius_total/nResults;
					}
				} else {
					x_mean=0;
					x_total=0;
					for (a=0; a<nResults(); a++) {
					  	x_total=x_total+getResult("Block Radius x",a);
					    x_mean=x_total/nResults;
					}
					y_mean=0;
					y_total=0;
					for (a=0; a<nResults(); a++) {
					  	y_total=y_total+getResult("Block Radius y",a);
					    y_mean=y_total/nResults;
					}
					std_mean=0;
					std_total=0;
					for (a=0; a<nResults(); a++) {
					  	std_total=std_total+getResult("Standard Deviation",a);
					    std_mean=std_total/nResults;
					}   
				}
				sigma_mean=0;
				sigma_total=0;
				for (a=0; a<nResults(); a++) {
				    sigma_total=sigma_total+getResult("Gaussian Blur",a);
				    sigma_mean=sigma_total/nResults;
				}
				Lower_mean=0;
				Lower_total=0;
				for (a=0; a<nResults(); a++) {
				    Lower_total=Lower_total+getResult("Lower Threshold",a);
				    Lower_mean=Lower_total/nResults;
				}
				if(isNaN(Lower_mean)==true){
				Lower_mean=method;
				}
				Upper_mean=0;
				Upper_total=0;
				for (a=0; a<nResults(); a++) {
				    Upper_total=Upper_total+getResult("Upper Threshold",a);
				    Upper_mean=Upper_total/nResults;
				}
				lse_mean=0;
				lse_total=0;
				for (a=0; a<nResults(); a++) {
				    lse_total=lse_total+getResult("Lower Size Exclusion",a);
				    lse_mean=lse_total/nResults;
				}
				use_mean=0;
				use_total=0;
				for (a=0; a<nResults(); a++) {
				    use_total=use_total+getResult("Upper Size Exclusion",a);
				    use_mean=use_total/nResults;
				}
				if(isNaN(use_mean)==true){
				use_mean="infinity";
				}
				lce_mean=0;
				lce_total=0;
				for (a=0; a<nResults(); a++) {
				    lce_total=lce_total+getResult("Lower Circularity Exclusion",a);
				    lce_mean=lce_total/nResults;
				}
				uce_mean=0;
				uce_total=0;
				for (a=0; a<nResults(); a++) {
				    uce_total=uce_total+getResult("Upper Circularity Exclusion",a);
				    uce_mean=uce_total/nResults;
				}
				run("Close");
				}
				tableTitle5="3D Colony Optimization Summary";
				tableTitle6="["+tableTitle5+"]";
				run("Table...", "name="+tableTitle6+" width=400 height=500");
				if (tech == sub){
					print(tableTitle6,"Method = Background Subtraction");
					print(tableTitle6, "Threshold" + "\t" + Thresh);
					print(tableTitle6,"Average Background Subtraction Radius = "+radius_mean);
				} else {
					print(tableTitle6,"Method = Normalize Local Contrast");
					print(tableTitle6, "Threshold" + "\t" + Thresh);
					print(tableTitle6,"Average Block Radius x = "+x_mean);
					print(tableTitle6,"Average Block Radius y = "+y_mean);
					print(tableTitle6,"Average Standard Deviation = "+std_mean);
				}
				print(tableTitle6,"Average Gaussian Blur = "+sigma_mean);
				print(tableTitle6,"Average Lower Threshold = "+Lower_mean);
				print(tableTitle6,"Average Upper Threshold = "+Upper_mean);
				print(tableTitle6,"Average Lower Size Exclusion = "+lse_mean);
				print(tableTitle6,"Average Upper Size Exclusion = "+use_mean);
				print(tableTitle6,"Average Lower Circularity Exclusion = "+lce_mean);
				print(tableTitle6,"Average Upper Cirularity Exclusion = "+uce_mean);
				print(tableTitle6,"Watershed = "+watershed);
				print(tableTitle6,"Edge Exclusion = "+exclude);
				print(tableTitle6,"Fill Holes = "+fillh);
				if (tech == sub){
				print(tableTitle2, "Average" + "\t" + radius_mean + "\t" + sigma_mean + "\t" + Lower_mean + "\t" + Upper_mean + "\t" + lse_mean + "\t"  + use_mean + "\t" + lce_mean + "\t" + uce_mean + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);
				} else {
					print(tableTitle2, "Average" + "\t" + x_mean + "\t" + y_mean + "\t" + std_mean + "\t" + sigma_mean + "\t" + Lower_mean + "\t" + Upper_mean + "\t" + lse_mean + "\t"  + use_mean + "\t" + lce_mean + "\t" + uce_mean + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);
				}
				print(tableTitle2, " ");
				print(tableTitle2, "3D Colony Optimization" + "\t" + "Optimization");
				if (tech == sub){
				print(tableTitle2, "Method" + "\t" + "Background Subtraction");
				print(tableTitle2, "Threshold" + "\t" + Thresh);
				print(tableTitle2,"Average Background Subtraction Radius" + "\t" + radius_mean);
				} else {
					print(tableTitle2, "Method" + "\t" + "Normalize Local Contrast");
					print(tableTitle2, "Threshold" + "\t" + Thresh);
					print(tableTitle2,"Average Block Radius x" + "\t" + x_mean);
					print(tableTitle2,"Average Block Radius y" + "\t" + y_mean);
					print(tableTitle2,"Average Standard Deviation" + "\t" + std_mean);
				}
				print(tableTitle2,"Average Gaussian Blur" + "\t" + sigma_mean);
				print(tableTitle2,"Average Lower Threshold" + "\t" + Lower_mean);
				print(tableTitle2,"Average Upper Threshold" + "\t" + Upper_mean);
				print(tableTitle2,"Average Lower Size Exclusion" + "\t" + lse_mean);
				print(tableTitle2,"Average Upper Size Exclusion" + "\t" + use_mean);
				print(tableTitle2,"Average Lower Circularity Exclusion" + "\t" + lce_mean);
				print(tableTitle2,"Average Upper Circularity Exclusion" + "\t" + uce_mean);
				print(tableTitle2,"Watershed" + "\t" + watershed);
				print(tableTitle2,"Edge Exclusion" + "\t" + exclude);
				print(tableTitle2,"Fill Holes" + "\t" + fillh);
				if(isOpen("3D Colony Optimization")==1){
				selectWindow("3D Colony Optimization");
				saveAs("Results",  dir+tableTitle+".xls");
				selectWindow("3D Colony Optimization");
				run("Close");
				}
				if(isOpen("3D Colony Optimization Summary")==1){
				selectWindow("3D Colony Optimization Summary");
				}
				waitForUser("Analyze your images ", "Use the '3D Colony Optimization Summary' table to analyze your images.\n \nIf you are not happy with the optimization, you can repeat it by selecting\n‘Exit the macro and redo the optimization’ and then restarting the macro.\n \nClick OK to start the analysis.");
				ana = "Start the analysis with current adjustment";
				finish = "Exit the macro and redo the adjustment";
				Dialog.create("Next step!");
				Dialog.addMessage("Nice work! What would you like to do now?");
				Dialog.addChoice("Type:", newArray(ana, finish));
				Dialog.show();
				third = Dialog.getChoice();
				if(third == ana){
					waitForUser("Analysis section","Welcome to the analysis section. This section will ask you to input the\nadjustments you would like to use for the analysis of your images. Once\nthe analysis begins you may leave the computer to analyze all your images!\n \nBest of luck!!");
					Analysis();
				}
				if(third == finish){
					exit("If you plan to restart the adjustment, please ensure that the folder only contains your\ncopied sets of images. Any new files created during this tutorial can be deleted.\n \nNote: A quick way to delete everything that was created by the macro is to sort your\nfolder and arrange it based on the date that it was created/modified and that way\nyou can select for everything that was made most recently by the macro.\n \nAll the best!!");
				}
					
	}//end of tutorial

/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


3D Colony Optimization 008


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
				sub = "Subtract Background";
				norm = "Normalize Local Contrast";
				Dialog.create("Method");
				Dialog.addMessage("Select method for removing background");
				Dialog.addChoice("Method:", newArray(sub, norm));
				Dialog.show();
				tech = Dialog.getChoice();
				if (tech == sub){
				tableTitle="3D Colony Optimization";
				tableTitle2="["+tableTitle+"]";
				run("Table...", "name="+tableTitle2+" width=400 height=250");
				print(tableTitle2,"\\Headings:Image name\tBackground Subtraction Radius\tGaussian Blur\tLower Threshold\tUpper Threshold\tLower Size Exclusion\tUpper Size Exclusion\tLower Circularity Exclusion\tUpper Circularity Exclusion\tWatershed\tEdge Exclusion\tFill Holes");		
				} else {
					tableTitle="3D Colony Optimization";
					tableTitle2="["+tableTitle+"]";
					run("Table...", "name="+tableTitle2+" width=400 height=250");
					print(tableTitle2,"\\Headings:Image name\tBlock Radius x\tBlock Radius y\tStandard Deviation\tGaussian Blur\tLower Threshold\tUpper Threshold\tLower Size Exclusion\tUpper Size Exclusion\tLower Circularity Exclusion\tUpper Circularity Exclusion\tWatershed\tEdge Exclusion\tFill Holes");		
				}
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
						if(tech==sub){
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Background Subtraction Adjustment 009


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Background subtraction","A duplicate image has been created to test which parameters are best for your images. Check\npreview and test values between 0-100. Secondly, try testing the 'light background' check box.\n \nOnce you have finished sampling your image, record the background subtraction values as\nthis will be required later.\n \nClick OK to continue.");
							run("Subtract Background...");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter the background subtraction value.");
							Dialog.addNumber("     Radius (pixel):", 50);
							Dialog.addCheckbox("Light background", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							radius = Dialog.getNumber();
							light = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
								if (light == true){
									run("Subtract Background...", "rolling=radius light");
								} else{
									run("Subtract Background...", "rolling=radius");
								}
							run("Gaussian Blur...", "sigma=sigma");
							run("8-bit");
							selectWindow("Duplicate");
							Dialog.create("Thresholding");
							Dialog.addMessage("Select automatic or manual threshold");
							Dialog.addChoice("", newArray("Automatic", "Manual"));
							Dialog.show();
							Thresh = Dialog.getChoice();
							if (Thresh == "Automatic"){
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
								run("Duplicate...", "title=Triangle");
								run("Auto Threshold", "method=Triangle white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Triangle");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Triangle","Yen"));
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
								if(method=="Triangle"){
									run("Auto Threshold", "method=Triangle white");
								}
								if(method=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								Lower = "Auto="+method;
								Upper = "NaN";
								selectWindow("Duplicate");
								setThreshold(10, 255);
								if (light == true){
									run("Invert LUT");
									setThreshold(0, 254);
								}
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								if(light== true){
									setThreshold(0, 150);
									waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
									} else{
										setThreshold(50, 255);
										waitForUser("Select for all colonies\nusing the top slide bar in the Threshold window. Click OK to proceed.");
									}
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "red");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Background-Subtraction");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
								run("Close All");
								if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
								}
								setResult("Background Subtraction Radius",nResults-1,radius);
								setResult("Gaussian Blur",nResults-1,sigma);	
								setResult("Lower Threshold",nResults-1,Lower);
								setResult("Upper Threshold",nResults-1,Upper);	
								setResult("Lower Size Exclusion",nResults-1,lse);
								setResult("Upper Size Exclusion",nResults-1,use);
								setResult("Lower Circularity Exclusion",nResults-1,lce);
								setResult("Upper Circularity Exclusion",nResults-1,uce);
								setResult("Watershed",nResults-1,watershed);
								setResult("Edge Exclusion",nResults-1,exclude);
								setResult("Fill Holes",nResults-1,fillh);						
								updateResults();
								if(watershed==1){
								watershed = "TRUE";
								} else {
									watershed = "FALSE";
								}
								if(exclude==1){
									exclude = "TRUE";
								} else {
									exclude = "FALSE";
								}
								if(fillh==1){
									fillh = "TRUE";
								} else {
									fillh = "FALSE";
								}
								print(tableTitle2, nameStore + "\t"  + radius + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
						} else {
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Normalize Local Contrast Adjustment 010


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Normalize local contrast","A duplicate image has been created to test which parameters are best for your images.\nRecommended: Use the same values for 'block radius x' and block radius y'. Try a value\nof 40 for both block radius x and y and a standard deviation of 3.\n \nEnsure you tick the 'center' and preview checkboxes to visualize the changes you have\nmade to the image. Once the parameters are optimized, record them as they will be\nused to apply to the raw images. \n \nClick OK to continue.");
							run("Normalize Local Contrast");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter values to normalize local contrast.");
							Dialog.addNumber("block radius x:", 40);
							Dialog.addNumber("block radius y:", 40);
							Dialog.addNumber("standard deviation:", 3);
							Dialog.addCheckbox("center", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							con = Dialog.getChoice();
							x = Dialog.getNumber();
							y = Dialog.getNumber();
							std = Dialog.getNumber();
							center = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
							if (center == true){
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std center");
							} else{
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std");
							}
						run("Gaussian Blur...", "sigma=sigma");
						run("8-bit");
						selectWindow("Duplicate");
						Dialog.create("Thresholding");
						Dialog.addMessage("Select automatic or manual threshold");
						Dialog.addChoice("", newArray("Automatic", "Manual"));
						Dialog.show();
						Thresh = Dialog.getChoice();
						if (Thresh == "Automatic"){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
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
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
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
								Dialog.addChoice("", newArray("Huang","MaxEntropy","Otsu","Triangle","Yen"));
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
								selectWindow("Duplicate");
								run("Invert LUT");
								setThreshold(0, 254);
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
					  			waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(1, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "blue");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Normalize-Local-Contrast");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
							run("Close All");
							if(isOpen("ROI Manager")==1){
							selectWindow("ROI Manager");
							run("Close");
							}
							setResult("Block Radius x",nResults-1,x);
							setResult("Block Radius y",nResults-1,y);
							setResult("Standard Deviation",nResults-1,std);
							setResult("Gaussian Blur",nResults-1,sigma);	
							setResult("Lower Threshold",nResults-1,Lower);
							setResult("Upper Threshold",nResults-1,Upper);	
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);						
							updateResults();
							if(watershed==1){
								watershed = "TRUE";
								} else {
									watershed = "FALSE";
								}
								if(exclude==1){
									exclude = "TRUE";
								} else {
									exclude = "FALSE";
								}
								if(fillh==1){
									fillh = "TRUE";
								} else {
									fillh = "FALSE";
								}
							print(tableTitle2, nameStore + "\t"  + x + "\t"  + y + "\t"  + std + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
						} 
					}//end of IF for matching word
						}//end of FOR
				}else { 
					for(i=0; i<list.length; i++){
						filename = dir + list[i];
						if (endsWith(filename, type)){
							open(filename);
							if(tech==sub){							
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Background Subtraction Adjustment 011


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Background subtraction","A duplicate image has been created to test which parameters are best for your images. Check\npreview and test values between 0-100. Secondly, try testing the 'light background' check box.\n \nOnce you have finished sampling your image, record the background subtraction values as\nthis will be required later.\n \nClick OK to continue.");
							run("Subtract Background...");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter the background subtraction value.");
							Dialog.addNumber("     Radius (pixel):", 50);
							Dialog.addCheckbox("Light background", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							radius = Dialog.getNumber();
							light = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
								if (light == true){
									run("Subtract Background...", "rolling=radius light");
								} else{
									run("Subtract Background...", "rolling=radius");
								}
							run("Gaussian Blur...", "sigma=sigma");
							run("8-bit");
							selectWindow("Duplicate");
							Dialog.create("Thresholding");
							Dialog.addMessage("Select automatic or manual threshold");
							Dialog.addChoice("", newArray("Automatic", "Manual"));
							Dialog.show();
							Thresh = Dialog.getChoice();
							if (Thresh == "Automatic"){
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
								run("Duplicate...", "title=Triangle");
								run("Auto Threshold", "method=Triangle white");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Yen");
								run("Auto Threshold", "method=Yen white");
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=Li image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
								setSlice(3);
								setMetadata("Li");
								setSlice(4);
								setMetadata("Otsu");
								setSlice(5);
								setMetadata("Triangle");
								setSlice(6);
								setMetadata("Yen");
								run("Make Montage...", "columns=3 rows=2 scale=0.50 first=1 last=6 increment=1 border=0 font=50 label");
								Dialog.create("Thresholding");
								Dialog.addMessage("Select the automatic method");
								Dialog.addChoice("", newArray("Huang","Li","Otsu","Triangle","Yen"));
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
								if(method=="Triangle"){
									run("Auto Threshold", "method=Triangle white");
								}
								if(method=="Yen"){
									run("Auto Threshold", "method=Yen white");
								}
								Lower = "Auto="+method;
								Upper = "NaN";
								selectWindow("Duplicate");
								setThreshold(10, 255);
								if (light == true){
									run("Invert LUT");
									setThreshold(0, 254);
								}
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								if(light== true){
									setThreshold(0, 150);
									waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
									} else{
										setThreshold(50, 255);
										waitForUser("Select for all colonies\nusing the top slide bar in the Threshold window. Click OK to proceed.");
									}
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(10, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "red");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Background-Subtraction");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
								run("Close All");
								if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
								}
								setResult("Background Subtraction Radius",nResults-1,radius);
								setResult("Gaussian Blur",nResults-1,sigma);	
								setResult("Lower Threshold",nResults-1,Lower);
								setResult("Upper Threshold",nResults-1,Upper);	
								setResult("Lower Size Exclusion",nResults-1,lse);
								setResult("Upper Size Exclusion",nResults-1,use);
								setResult("Lower Circularity Exclusion",nResults-1,lce);
								setResult("Upper Circularity Exclusion",nResults-1,uce);
								setResult("Watershed",nResults-1,watershed);
								setResult("Edge Exclusion",nResults-1,exclude);
								setResult("Fill Holes",nResults-1,fillh);						
								updateResults();
								if(watershed==1){
								watershed = "TRUE";
								} else {
									watershed = "FALSE";
								}
								if(exclude==1){
									exclude = "TRUE";
								} else {
									exclude = "FALSE";
								}
								if(fillh==1){
									fillh = "TRUE";
								} else {
									fillh = "FALSE";
								}
								print(tableTitle2, nameStore + "\t"  + radius + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
							} else {
/*---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------


Normalize Local Contrast Adjustment 012


-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
							nameStore = getTitle();
							run("Duplicate...", " ");
							rename("Duplicate");
							run("Duplicate...", " ");
							rename("Test");
							waitForUser("Normalize local contrast","A duplicate image has been created to test which parameters are best for your images.\nRecommended: Use the same values for 'block radius x' and block radius y'. Try a value\nof 40 for both block radius x and y and a standard deviation of 3.\n \nEnsure you tick the 'center' and preview checkboxes to visualize the changes you have\nmade to the image. Once the parameters are optimized, record them as they will be\nused to apply to the raw images. \n \nClick OK to continue.");
							run("Normalize Local Contrast");
							run("Gaussian Blur...");
							selectWindow("Test");
							close();
							selectWindow("Duplicate");
							Dialog.create("Remove background and smooth edges of colonies");
							Dialog.addMessage("Enter values to normalize local contrast.");
							Dialog.addNumber("block radius x:", 40);
							Dialog.addNumber("block radius y:", 40);
							Dialog.addNumber("standard deviation:", 3);
							Dialog.addCheckbox("center", true);
							Dialog.addMessage("Gaussian Blur:");
							Dialog.addNumber("Sigma:", 2);
							Dialog.show();
							con = Dialog.getChoice();
							x = Dialog.getNumber();
							y = Dialog.getNumber();
							std = Dialog.getNumber();
							center = Dialog.getCheckbox();
							sigma = Dialog.getNumber();
							if (center == true){
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std center");
							} else{
								run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std");
							}
						run("Gaussian Blur...", "sigma=sigma");
						run("8-bit");
						selectWindow("Duplicate");
						Dialog.create("Thresholding");
						Dialog.addMessage("Select automatic or manual threshold");
						Dialog.addChoice("", newArray("Automatic", "Manual"));
						Dialog.show();
						Thresh = Dialog.getChoice();
						if (Thresh == "Automatic"){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Original");
								selectWindow("Duplicate");
								run("Duplicate...", "title=Huang");
								run("Auto Threshold", "method=Huang white");
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
								run("Concatenate...", "  title=Stacks image1=Original image2=Huang image3=MaxEntropy image4=Otsu image5=Triangle image6=Yen");
								setSlice(1); 
								setMetadata("Original");
								setSlice(2);
								setMetadata("Huang");
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
								Dialog.addChoice("", newArray("Huang","MaxEntropy","Otsu","Triangle","Yen"));
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
								selectWindow("Duplicate");
								run("Invert LUT");
								setThreshold(0, 254);
							} else{
								selectWindow("Duplicate");
								setAutoThreshold("Default dark");
								run("Threshold...");
								setThreshold(0, 150);
					  			waitForUser("Select for all colonies\nusing the bottom slide bar in the Threshold window. Click OK to proceed.");
								getThreshold(Lower,Upper);
								selectWindow("Duplicate");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								setThreshold(1, 255);
							}
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							selectWindow("Duplicate");
							run("Measure");
							IJ.deleteRows(nResults-1, nResults-1);
							roiManager("Reset");
							particle();
							function particle(){
							Dialog.create("Size and Circularity Exclusion");
							Dialog.addMessage("Please enter the value (in pixel size) for\nthe exclusion in the particle analysis");
							Dialog.addNumber("Lower size exclusion:", 0);
							Dialog.addString("Upper size exclusion:", "infinity");
							Dialog.addNumber("Lower circularity exclusion:", 0.00);
							Dialog.addNumber("Upper circularity exclusion:", 1.00);
							Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
							Dialog.addCheckbox("watershed", true);
							Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
							Dialog.addCheckbox("exclude", true);
							Dialog.addMessage("Would you like to fill holes?");
							Dialog.addCheckbox("fill holes", false);
							Dialog.show();
							lse = Dialog.getNumber();
							use = Dialog.getString();
							lce = Dialog.getNumber();
							uce = Dialog.getNumber();
							watershed = Dialog.getCheckbox();
							exclude = Dialog.getCheckbox();
							fillh = Dialog.getCheckbox();
							selectWindow("Duplicate");
							if (fillh == true){
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
								run("Fill Holes");
							}
							if (watershed == true){
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
							} else{
								selectWindow("Duplicate");
								run("Duplicate...", "title=Duplicate2");
							}
								run("Watershed");
							}
							if (exclude == true){
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks exclude add");
							} else {		'
								IJ.redirectErrorMessages();
								run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks add");
							}
							rename("Mask");
							if(isOpen("Log")==1){
								selectWindow("Log");
								run("Close");
								}
							run("Measure");
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);
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
							if(retry=="no"){
								IJ.deleteRows(nResults-1, nResults-1);
								selectWindow("Mask");
								close();
								if (isOpen("Duplicate2")==1){
								selectWindow("Duplicate2");
								close();
								}
								roiManager("Reset");
								selectWindow("Duplicate");
								particle();
									} else{
										if (isOpen("Duplicate2")==1){
										selectWindow("Duplicate");
										close();
										selectWindow("Duplicate2");
										rename("Duplicate");
										}
									} 
							}		
							lse = getResult("Lower Size Exclusion",nResults-1);
							use = getResult("Upper Size Exclusion",nResults-1);
							lce = getResult("Lower Circularity Exclusion",nResults-1);
							uce = getResult("Upper Circularity Exclusion",nResults-1);
							watershed = getResult("Watershed",nResults-1);
							exclude = getResult("Edge Exclusion",nResults-1);
							fillh = getResult("Fill Holes",nResults-1);
							IJ.deleteRows(nResults-1, nResults-1);
							selectWindow("Mask");
							setAutoThreshold("Default dark");
							//run("Threshold...");
							setThreshold(10, 255);
							run("Set Measurements...", "area shape limit redirect=None decimal=3");
							run("Set Scale...", "distance=0 known=0 unit=pixel");
							run("Measure");
							if(getResult('Area', nResults-1)!=0) {
								totalArea = getResult('Area', nResults-1);
							} else {
								totalArea = 0;
								}
							if(getResult('Circ.', nResults-1)!=0) {
								totalCirc = getResult('Circ.', nResults-1);
							} else {
								totalCirc = 0;
								}
							if (roiManager("count")!=0) {
								roiManager("Save",  dir+nameStore+" - Cells.zip");
								Count = roiManager("count");
								averageArea = totalArea/Count;
								selectWindow("Mask");
								saveAs("Tiff", dir+nameStore+" - Cell Mask");
								rename("Mask");
								selectWindow(nameStore);
								roiManager("Show All without labels");
								roiManager("Set Fill Color", "blue");
								run("Flatten");
								saveAs("Tiff", dir+nameStore+" - Cells Overlay");
								rename("Normalize-Local-Contrast");
								selectWindow(nameStore);
								roiManager("Set Color", "yellow");
							} else {
								Count = 0;
								averageArea = 0;
								averageCirc = 0;
								}
							run("Close All");
							if(isOpen("ROI Manager")==1){
								selectWindow("ROI Manager");
								run("Close");
							}
							setResult("Block Radius x",nResults-1,x);
							setResult("Block Radius y",nResults-1,y);
							setResult("Standard Deviation",nResults-1,std);
							setResult("Gaussian Blur",nResults-1,sigma);	
							setResult("Lower Threshold",nResults-1,Lower);
							setResult("Upper Threshold",nResults-1,Upper);	
							setResult("Lower Size Exclusion",nResults-1,lse);
							setResult("Upper Size Exclusion",nResults-1,use);
							setResult("Lower Circularity Exclusion",nResults-1,lce);
							setResult("Upper Circularity Exclusion",nResults-1,uce);
							setResult("Watershed",nResults-1,watershed);
							setResult("Edge Exclusion",nResults-1,exclude);
							setResult("Fill Holes",nResults-1,fillh);						
							updateResults();
							if(watershed==1){
								watershed = "TRUE";
								} else {
									watershed = "FALSE";
								}
								if(exclude==1){
									exclude = "TRUE";
								} else {
									exclude = "FALSE";
								}
								if(fillh==1){
									fillh = "TRUE";
								} else {
									fillh = "FALSE";
								}
							print(tableTitle2, nameStore + "\t"  + x + "\t"  + y + "\t"  + std + "\t"  + sigma + "\t"  + Lower + "\t"  + Upper + "\t"  + lse + "\t"  + use + "\t" + lce + "\t"  + uce + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);						
							}	
							}
						}
						}
				if(isOpen("Summary")==1){
				selectWindow("Summary");
				run("Close");
				}
				if(isOpen("Log")==1){
					selectWindow("Log");
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
				selectWindow("3D Colony Optimization");
				if(isOpen("Results")==1){
				selectWindow("Results");
				if (tech == sub){
					radius_mean=0;
					radius_total=0;
					for (a=0; a<nResults(); a++) {
					    radius_total=radius_total+getResult("Background Subtraction Radius",a);
					    radius_mean=radius_total/nResults;
					}
				} else {
					x_mean=0;
					x_total=0;
					for (a=0; a<nResults(); a++) {
					  	x_total=x_total+getResult("Block Radius x",a);
					    x_mean=x_total/nResults;
					}
					y_mean=0;
					y_total=0;
					for (a=0; a<nResults(); a++) {
					  	y_total=y_total+getResult("Block Radius y",a);
					    y_mean=y_total/nResults;
					}
					std_mean=0;
					std_total=0;
					for (a=0; a<nResults(); a++) {
					  	std_total=std_total+getResult("Standard Deviation",a);
					    std_mean=std_total/nResults;
					}   
				}
				sigma_mean=0;
				sigma_total=0;
				for (a=0; a<nResults(); a++) {
				    sigma_total=sigma_total+getResult("Gaussian Blur",a);
				    sigma_mean=sigma_total/nResults;
				}
				Lower_mean=0;
				Lower_total=0;
				for (a=0; a<nResults(); a++) {
				    Lower_total=Lower_total+getResult("Lower Threshold",a);
				    Lower_mean=Lower_total/nResults;
				}
				if(isNaN(Lower_mean)==true){
				Lower_mean=method;
				}
				Upper_mean=0;
				Upper_total=0;
				for (a=0; a<nResults(); a++) {
				    Upper_total=Upper_total+getResult("Upper Threshold",a);
				    Upper_mean=Upper_total/nResults;
				}
				lse_mean=0;
				lse_total=0;
				for (a=0; a<nResults(); a++) {
				    lse_total=lse_total+getResult("Lower Size Exclusion",a);
				    lse_mean=lse_total/nResults;
				}
				use_mean=0;
				use_total=0;
				for (a=0; a<nResults(); a++) {
				    use_total=use_total+getResult("Upper Size Exclusion",a);
				    use_mean=use_total/nResults;
				}
				if(isNaN(use_mean)==true){
				use_mean="infinity";
				}
				lce_mean=0;
				lce_total=0;
				for (a=0; a<nResults(); a++) {
				    lce_total=lce_total+getResult("Lower Circularity Exclusion",a);
				    lce_mean=lce_total/nResults;
				}
				uce_mean=0;
				uce_total=0;
				for (a=0; a<nResults(); a++) {
				    uce_total=uce_total+getResult("Upper Circularity Exclusion",a);
				    uce_mean=uce_total/nResults;
				}
				run("Close");
				}
				tableTitle5="3D Colony Optimization Summary";
				tableTitle6="["+tableTitle5+"]";
				run("Table...", "name="+tableTitle6+" width=400 height=500");
								if (tech == sub){
					print(tableTitle6,"Method = Background Subtraction");
					print(tableTitle6, "Threshold" + "\t" + Thresh);
					print(tableTitle6,"Average Background Subtraction Radius = "+radius_mean);
				} else {
					print(tableTitle6,"Method = Normalize Local Contrast");
					print(tableTitle6, "Threshold" + "\t" + Thresh);
					print(tableTitle6,"Average Block Radius x = "+x_mean);
					print(tableTitle6,"Average Block Radius y = "+y_mean);
					print(tableTitle6,"Average Standard Deviation = "+std_mean);
				}
				print(tableTitle6,"Average Gaussian Blur = "+sigma_mean);
				print(tableTitle6,"Average Lower Threshold = "+Lower_mean);
				print(tableTitle6,"Average Upper Threshold = "+Upper_mean);
				print(tableTitle6,"Average Lower Size Exclusion = "+lse_mean);
				print(tableTitle6,"Average Upper Size Exclusion = "+use_mean);
				print(tableTitle6,"Average Lower Circularity Exclusion = "+lce_mean);
				print(tableTitle6,"Average Upper Cirularity Exclusion = "+uce_mean);
				print(tableTitle6,"Watershed = "+watershed);
				print(tableTitle6,"Edge Exclusion = "+exclude);
				print(tableTitle6,"Fill Holes = "+fillh);
				if (tech == sub){
				print(tableTitle2, "Average" + "\t" + radius_mean + "\t" + sigma_mean + "\t" + Lower_mean + "\t" + Upper_mean + "\t" + lse_mean + "\t"  + use_mean + "\t" + lce_mean + "\t" + uce_mean + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);
				} else {
					print(tableTitle2, "Average" + "\t" + x_mean + "\t" + y_mean + "\t" + std_mean + "\t" + sigma_mean + "\t" + Lower_mean + "\t" + Upper_mean + "\t" + lse_mean + "\t"  + use_mean + "\t" + lce_mean + "\t" + uce_mean + "\t"  + watershed + "\t"  + exclude + "\t"  + fillh);
				}
				print(tableTitle2, " ");
				print(tableTitle2, "3D Colony Optimization" + "\t" + "Optimization");
				if (tech == sub){
				print(tableTitle2, "Method" + "\t" + "Background Subtraction");
				print(tableTitle2, "Threshold" + "\t" + Thresh);
				print(tableTitle2,"Average Background Subtraction Radius" + "\t" + radius_mean);
				} else {
					print(tableTitle2, "Method" + "\t" + "Normalize Local Contrast");
					print(tableTitle2, "Threshold" + "\t" + Thresh);
					print(tableTitle2,"Average Block Radius x" + "\t" + x_mean);
					print(tableTitle2,"Average Block Radius y" + "\t" + y_mean);
					print(tableTitle2,"Average Standard Deviation" + "\t" + std_mean);
				}
				print(tableTitle2,"Average Gaussian Blur" + "\t" + sigma_mean);
				print(tableTitle2,"Average Lower Threshold" + "\t" + Lower_mean);
				print(tableTitle2,"Average Upper Threshold" + "\t" + Upper_mean);
				print(tableTitle2,"Average Lower Size Exclusion" + "\t" + lse_mean);
				print(tableTitle2,"Average Upper Size Exclusion" + "\t" + use_mean);
				print(tableTitle2,"Average Lower Circularity Exclusion" + "\t" + lce_mean);
				print(tableTitle2,"Average Upper Circularity Exclusion" + "\t" + uce_mean);
				print(tableTitle2,"Watershed" + "\t" + watershed);
				print(tableTitle2,"Edge Exclusion" + "\t" + exclude);
				print(tableTitle2,"Fill Holes" + "\t" + fillh);
				if(isOpen("3D Colony Optimization")==1){
				selectWindow("3D Colony Optimization");
				saveAs("Results",  dir+tableTitle+".xls");
				selectWindow("3D Colony Optimization");
				run("Close");
				}
				if(isOpen("3D Colony Optimization Summary")==1){
				selectWindow("3D Colony Optimization Summary");
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
3D Colony Analysis 013
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------*/
if(second==ana){
Analysis();
function Analysis(){
	waitForUser("Selecting the folder","Select the source folder for all images to be analyzed.");
	dir = getDirectory("Select Analysis Folder");
	list = getFileList(dir);
	Array.sort(list);

		
	Dialog.create("Saving files");
	Dialog.addMessage("Select which files to be saved during analysis");
	Dialog.addCheckbox("Colony ROI", true);
	Dialog.addCheckbox("Colony Overlay", true);
	Dialog.addCheckbox("Colony Mask", false);
	Dialog.show();
	CR = Dialog.getCheckbox();
	CO = Dialog.getCheckbox();
	CM = Dialog.getCheckbox();

	
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

	sub = "Subtract Background";
	norm = "Normalize Local Contrast";
	Dialog.create("Method");
	Dialog.addMessage("Select method for removing background");
	Dialog.addChoice("Method:", newArray(sub, norm));
	Dialog.addMessage("Select automatic or manual threshold");
	Dialog.addChoice("", newArray("Automatic", "Manual"));
	Dialog.show();
	tech = Dialog.getChoice();
	thresh = Dialog.getChoice();

	if (tech == sub && thresh == "Automatic"){
		Dialog.create("Setting Parameters");
		Dialog.addMessage("Please enter the parameters for the background subtraction");
		Dialog.addNumber("Background Subtraction Radius:", 50);
		Dialog.addCheckbox("Light background for Background Subtraction", true);
		Dialog.addMessage("Gaussian Blur:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addMessage("Threshold Method:");
		Dialog.addChoice("", newArray("Huang","Li","Otsu","Triangle", "Yen"));
		Dialog.show();
		radius = Dialog.getNumber();
		light = Dialog.getCheckbox();
		sigma = Dialog.getNumber();
		method = Dialog.getChoice();
	} else if (tech == sub && thresh == "Manual"){
		Dialog.create("Setting Parameters");
		Dialog.addMessage("Please enter the parameters for the background subtraction");
		Dialog.addNumber("Background Subtraction Radius:", 50);
		Dialog.addCheckbox("Light background for Background Subtraction", true);
		Dialog.addMessage("Gaussian Blur:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addNumber("Lower Threshold:", 0);
		Dialog.addNumber("Upper Threshold", 150);
		Dialog.show();
		radius = Dialog.getNumber();
		light = Dialog.getCheckbox();
		sigma = Dialog.getNumber();
		Lower = Dialog.getNumber();
		Upper = Dialog.getNumber();		
	} else if (tech == norm && thresh == "Automatic"){
		Dialog.create("Setting Parameters");
		Dialog.addMessage("Please enter the parameters for the normalize local contrast");
		Dialog.addNumber("Block Radius x:", 40);
		Dialog.addNumber("Block Radius x:", 40);
		Dialog.addNumber("Standard Deviation:", 3);
		Dialog.addMessage("Gaussian Blur:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addMessage("Threshold Method:");
		Dialog.addChoice("", newArray("Huang","Li","Otsu","Triangle", "Yen"));
		Dialog.show();
		x = Dialog.getNumber();
		y = Dialog.getNumber();
		std = Dialog.getNumber();
		sigma = Dialog.getNumber();
		method = Dialog.getChoice();			
	} else if (tech == norm && thresh == "Manual"){
		Dialog.create("Setting Parameters");
		Dialog.addMessage("Please enter the parameters for the normalize local contrast");
		Dialog.addNumber("Block Radius x:", 40);
		Dialog.addNumber("Block Radius x:", 40);
		Dialog.addNumber("Standard Deviation:", 3);
		Dialog.addMessage("Gaussian Blur:");
		Dialog.addNumber("Sigma:", 2);
		Dialog.addNumber("Lower Threshold:", 0);
		Dialog.addNumber("Upper Threshold", 150);
		Dialog.show();
		x = Dialog.getNumber();
		y = Dialog.getNumber();
		std = Dialog.getNumber();
		light = Dialog.getCheckbox();
		sigma = Dialog.getNumber();
		Lower = Dialog.getNumber();
		Upper = Dialog.getNumber();	
	}
		Dialog.create("Setting Particle Exclusion");
		Dialog.addMessage("Please enter the value (in pixel size) for the exclusion\nof the cells in the particle analysis");
		Dialog.addNumber("Lower size exclusion:", 0);
		Dialog.addString("Upper size exclusion:", "infinity");
		Dialog.addNumber("Lower circularity exclusion:", 0.00);
		Dialog.addNumber("Upper circularity exclusion:", 1.00);
		Dialog.addMessage("Would you like to watershed (segment)\nthe colonies?");
		Dialog.addCheckbox("watershed", true);
		Dialog.addMessage("Would you like to exclude the colonies\nat the edges?");
		Dialog.addCheckbox("exclude", true);
		Dialog.addMessage("Would you like to fill holes?");
		Dialog.addCheckbox("fill holes", false);
		Dialog.show();
		lse = Dialog.getNumber();
		use = Dialog.getString();
		lce = Dialog.getNumber();
		uce = Dialog.getNumber();
		watershed = Dialog.getCheckbox();
		exclude = Dialog.getCheckbox();
		fillh = Dialog.getCheckbox();
		tableTitle3="3D colony summary";
		tableTitle4="["+tableTitle3+"]";
		run("Table...", "name="+tableTitle4+" width=400 height=250");
		print(tableTitle4,"\\Headings:Image name\tColony Counts\tTotal Area of All Colony\tAverage Area Per Colony\tAverage Circularity Per Colony\tAverage Aspect Ratio Per Colony");		
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
				if(tech==sub){
					Abackground();
				} else {
					Anormalize();
				} 
			}//end of IF for matching word
			}//end of FOR
				}else { 
					for(i=0; i<list.length; i++){
						filename = dir + list[i];
						if (endsWith(filename, type)){
							open(filename);
							if(tech==sub){
							Abackground();
							} else {
							Anormalize();
							}	
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
selectWindow("3D colony summary");
saveAs("Results",  dir+tableTitle3+".xls");
selectWindow("3D colony summary");
run("Close");

waitForUser("Finished!","The analysis is now complete. The new files are now saved in the target folder and\nthe results file is labeled '3D colony summary'.");
	}//end of function Analysis
}//end of IF second = ana

function Abackground(){

nameStore = getTitle();
run("Duplicate...", " ");
rename("Duplicate");
if (light == true){
		run("Subtract Background...", "rolling=radius light");
	} else{
		run("Subtract Background...", "rolling=radius");
}
run("Gaussian Blur...", "sigma=sigma");
run("8-bit");
if (thresh == "Automatic"){
	if(method=="Huang"){
		run("Auto Threshold", "method=Huang white");
	}
	if(method=="Li"){
		run("Auto Threshold", "method=Li white");
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
	setThreshold(10, 255);
	if (light == true){
		run("Invert LUT");
		setThreshold(0, 254);
	}
} else {
	setAutoThreshold("Default dark");
	run("Threshold...");
	setThreshold(Lower,Upper);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	setThreshold(1, 255);	
}
if (fillh == true){
	selectWindow("Duplicate");
	run("Fill Holes");
}
if (watershed == true){
	selectWindow("Duplicate");
	run("Watershed");
}
roiManager("Reset");
if (exclude == true){
	IJ.redirectErrorMessages();
	run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks display exclude add");
} else {		'
	IJ.redirectErrorMessages();
	run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks display add");
}
rename("Mask");
if(isOpen("Log")==1){
selectWindow("Log");
run("Close");
}
circularity_mean=0;
circularity_total=0;
for (a=0; a<nResults(); a++) {
	circularity_total=circularity_total+getResult("Circ.",a);
	circularity_mean=circularity_total/nResults;
}
aspect_mean=0;
aspect_total=0;
for (a=0; a<nResults(); a++) {
	aspect_total=aspect_total+getResult("AR",a);
	aspect_mean=aspect_total/nResults;
}
setAutoThreshold("Default dark");
//run("Threshold...");
setThreshold(10, 255);
run("Set Measurements...", "area shape limit redirect=None decimal=3");
run("Set Scale...", "distance=dist known=know unit=unit");
run("Measure");
if(getResult('Area', nResults-1)!=0) {
totalArea = getResult('Area', nResults-1);
} else {
	totalArea = 0;
}
if (roiManager("count")!=0) {
	Count = roiManager("count");
	averageArea = totalArea/Count;
	if (CR == true){
	roiManager("Save",  dir+nameStore+" - Cells.zip");
	}
	if (CM == true){
	selectWindow("Mask");
	saveAs("Tiff", dir+nameStore+" - Cell Mask");
	rename("Mask");
	}
	if (CO == true){
		selectWindow(nameStore);
		roiManager("Show All without labels");
		roiManager("Set Fill Color", "red");
		run("Flatten");
		saveAs("Tiff", dir+nameStore+" - Cells Overlay");
		rename("Background-Subtraction");
		selectWindow(nameStore);
		roiManager("Set Color", "yellow");
		} 
}	else {
			Count = 0;
			averageArea = 0;
			circularity_mean = 0;
			aspect_mean = 0;
		}
	run("Close All");
	if(isOpen("ROI Manager")==1){
selectWindow("ROI Manager");
run("Close");
}
	print(tableTitle4, nameStore + "\t"  + Count + "\t"  + totalArea + "\t"  + averageArea + "\t"  + circularity_mean + "\t"  + aspect_mean);						
}//end of function Abackground


function Anormalize() {
	
nameStore = getTitle();
run("Duplicate...", " ");
rename("Duplicate");
run("Normalize Local Contrast", "block_radius_x=x block_radius_y=y standard_deviations=std center");
run("Gaussian Blur...", "sigma=sigma");
run("8-bit");
if (thresh == "Automatic"){
	if(method=="Huang"){
		run("Auto Threshold", "method=Huang white");
	}
	if(method=="Li"){
		run("Auto Threshold", "method=Li white");
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
		selectWindow("Duplicate");
		run("Invert LUT");
		setThreshold(0, 254);
} else {
	setAutoThreshold("Default dark");
	run("Threshold...");
	setThreshold(Lower,Upper);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	setThreshold(1, 255);	
}
if (fillh == true){
	selectWindow("Duplicate");
	run("Fill Holes");
}
if (watershed == true){
	selectWindow("Duplicate");
	run("Watershed");
}
roiManager("Reset");
if (exclude == true){
	IJ.redirectErrorMessages();
	run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks display exclude clear add");
} else {		'
	IJ.redirectErrorMessages();
	run("Analyze Particles...", "size=lse-use pixel circularity=lce-uce show=Masks display clear add");
}
rename("Mask");
if(isOpen("Log")==1){
selectWindow("Log");
run("Close");
}
circularity_mean=0;
circularity_total=0;
for (a=0; a<nResults(); a++) {
	circularity_total=circularity_total+getResult("Circ.",a);
	circularity_mean=circularity_total/nResults;
}
aspect_mean=0;
aspect_total=0;
for (a=0; a<nResults(); a++) {
	aspect_total=aspect_total+getResult("AR",a);
	aspect_mean=aspect_total/nResults;
}
setAutoThreshold("Default dark");
//run("Threshold...");
setThreshold(10, 255);
run("Set Measurements...", "area shape limit redirect=None decimal=3");
run("Set Scale...", "distance=dist known=know unit=unit");
run("Measure");
if(getResult('Area', nResults-1)!=0) {
totalArea = getResult('Area', nResults-1);
} else {
	totalArea = 0;
}
if (roiManager("count")!=0) {
	Count = roiManager("count");
	averageArea = totalArea/Count;
	if (CR == true){
	roiManager("Save",  dir+nameStore+" - Cells.zip");
	}
	if (CM == true){
	selectWindow("Mask");
	saveAs("Tiff", dir+nameStore+" - Cell Mask");
	rename("Mask");
	}
	if (CO == true){
		selectWindow(nameStore);
		roiManager("Show All without labels");
		roiManager("Set Fill Color", "red");
		run("Flatten");
		saveAs("Tiff", dir+nameStore+" - Cells Overlay");
		rename("Normalize-Local-Contrast");
		selectWindow(nameStore);
		roiManager("Set Color", "yellow");
		} 
} else {
			Count = 0;
			averageArea = 0;
			circularity_mean = 0;
			aspect_mean = 0;
		}
	run("Close All");
if(isOpen("ROI Manager")==1){
selectWindow("ROI Manager");
run("Close");
}
print(tableTitle4, nameStore + "\t"  + Count + "\t"  + totalArea + "\t"  + averageArea + "\t"  + circularity_mean + "\t"  + aspect_mean);	
}//end of function Anormalize

}//end of macro "3D Colony Assay"