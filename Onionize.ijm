/*
This program will create onion layers stacks (x,y,ol) from a series of time points stacks (x,y,z). It requires an 
Euclidean Distance transformed shell EDT.tif stack. It works with 8-bit images and to three-channels stacks 
where the third channel is the bright field.


Author: Guillaume Balavoine, Institut Jacques Monod Paris


*/

// You have to enter the path to your series of stacks and the path to the output files. 
// Be careful not to forget the final "/" and to use "\ " for a space in folder names.

inpath = "/Users/bala2/Desktop/Eve/Article\ Wnt/H2A-CAAX/22_2_16\ 26h-73h\ tres\ bon/Normalized/";
outpath = "/Users/bala2/Desktop/Eve/Article\ Wnt/H2A-CAAX/22_2_16\ 26h-73h\ tres\ bon/essai/";

// You have to indicate the corename of your files.
// Dont forget "_t" at the end unless it is a single frame 

corename = "caax-Hist26hpf-1cell_2016_02_19__21_43_40_t";

// The macro reslices all stacks to cubic voxels (x=y=z). 
// This is equal to the (x:y) pixel size indicated by >Image >Properties 

getPixelSize(dummy, voxel, dummy);

// This is the mumber of onion layers you want. Max is 255 (central dot). 

numberlayers = 200;


// This the main loop to treat all the frames. Indicate the start (usually 1) and the end frame number.
// put nframes = 1 for a single stack

nframes = 41;

for (frame = 1; frame <= nframes; frame++) {
	filename = corename + frame +".tif"; if (nframes==1) {filename = corename +".tif";}
	open(inpath + filename);	
	getDimensions(width, height, dummy, dummy, dummy);
	run("Split Channels");
	selectWindow("C3-" + filename);
	run("Reslice Z", "new=" + voxel);
	rename("white");
	selectWindow("C3-" + filename);
	close();
	selectWindow("C1-" + filename);
	run("Reslice Z", "new=" + voxel);
	rename("red");
	selectWindow("C1-" + filename);
	close();
	selectWindow("C2-" + filename);
	run("Reslice Z", "new=" + voxel);
	rename("green");
	selectWindow("C2-" + filename);
	close();
	onionfile = "Ol-" + filename;
	newImage(onionfile, "8-bit color-mode", width, height, 3, numberlayers, 1);

	for (depth = 1; depth <= numberlayers; depth++) {
		selectWindow("EDT.tif");
		run("Duplicate...", "duplicate");
		setAutoThreshold("Default dark");
		run("Threshold...");
		setThreshold(depth, depth);
		run("Convert to Mask", "method=Default background=Dark");
                imageCalculator("AND create stack", "red","EDT-1.tif");
                imageCalculator("AND create stack", "green","EDT-1.tif");
		imageCalculator("AND create stack", "white","EDT-1.tif");
		close("EDT-1.tif"); 
		selectWindow("Result of red");
		run("Z Project...", "projection=[Max Intensity]");
		run("Select All");
		run("Copy");
		selectWindow(onionfile);
		Stack.setChannel(1);
		Stack.setSlice(depth);
		run("Paste");
		selectWindow("Result of green");
		run("Z Project...", "projection=[Max Intensity]");
		run("Select All");
		run("Copy");
		selectWindow(onionfile);
		Stack.setChannel(2);
		Stack.setSlice(depth);
		run("Paste");
		selectWindow("Result of white");
		run("Z Project...", "projection=[Max Intensity]");
		run("Select All");
		run("Copy");
		selectWindow(onionfile);
		Stack.setChannel(3);
		Stack.setSlice(depth);
		run("Paste");
		close("Result of red"); close("Result of green"); close("Result of white");
		close("MAX_Result of red"); close("MAX_Result of green"); close("MAX_Result of white");
		}
	selectWindow(onionfile);
	saveAs("Tiff", outpath + onionfile);
	close(onionfile); close("red"); close("green"); close("white");

 	}
exit();
