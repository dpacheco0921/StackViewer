// This function will display a 3D image
args = getArgument()
args = split(args,"*") 
FileDir = args[0];
slice_n = args[1];
FNum = args[2];
imName1 = args[3];

// open files

open(FileDir + imName1);

run("Stack to Hyperstack...", "order=xyczt(default) channels=" + FNum + " slices=" + slice_n + " frames=1 display=Color");

Stack.setChannel(1);
run("Red");
Stack.setChannel(2);
run("Green");

Stack.setDisplayMode("composite");
run("Brightness/Contrast...");
run("Channels Tool...");
