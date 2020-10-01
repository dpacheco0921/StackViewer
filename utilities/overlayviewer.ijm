// This function will overlay floating vs ref images
// it plots up to 9 images (1 reference image + 8 floating images)

args = getArgument()
args = split(args,"*") 
slice_n = args[0];
FNum = args[1];
EditGate = args[2];
// get ref Im dir
refDir = args[3];
// get ref Im name
imName1 = args[4];

// get float Im-1 dir
floatDir2 = args[5];
//floating Im dir
imName2 = args[6];

// get float Im-2 dir
floatDir3 = args[7];
//floating Im dir
imName3 = args[8];

// get float Im-3 dir
floatDir4 = args[9];
//floating Im dir
imName4 = args[10];

// get float Im-4 dir
floatDir5 = args[11];
//floating Im dir
imName5 = args[12];

// get float Im-5 dir
floatDir6 = args[13];
//floating Im dir
imName6 = args[14];

// get float Im-6 dir
floatDir7 = args[15];
//floating Im dir
imName7 = args[16];

// get float Im-7 dir
floatDir8 = args[17];
//floating Im dir
imName8 = args[18];

// get float Im-8 dir
floatDir9 = args[19];
//floating Im dir
imName9 = args[20];

repoDir = args[21];

// open files
str2print = "Initial number of images : " + FNum;
print(str2print)
for (im_i=1; im_i<=FNum; im_i++) {
    print(args[im_i + 4]);
}

open(refDir + imName1);
run("16-bit");

open(floatDir2 + imName2);
run("16-bit");

if (FNum>=3){
    open(floatDir3 + imName3);
    run("16-bit");
}

if (FNum>=4){
    open(floatDir4 + imName4);
    run("16-bit");
}

if (FNum>=5){
    open(floatDir5 + imName5);
    run("16-bit");
}

if (FNum>=6){
    open(floatDir6 + imName6);
    run("16-bit");
}

if (FNum>=7){
    open(floatDir7 + imName7);
    run("16-bit");
}

if (FNum>=8){
    open(floatDir8 + imName8);
    run("16-bit");
}

if (FNum>=9){
    open(floatDir9 + imName9);
    run("16-bit");
}

// Adjust bits
selectWindow(imName1);
run("16-bit");

// concatenate ref to warp and affine reg image
if (FNum==3){
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=" + imName3);
} else if (FNum==4){
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=" + imName3 + " image4=" + imName4);
} else if (FNum==5){
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=" + imName3 + " image4=" + imName4 + " image5=" + imName5);
} else if (FNum==6){
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=" + imName3 + " image4=" + imName4 + " image5=" + imName5 + " image6=" + imName6);
} else if (FNum==7){
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=" + imName3 + " image4=" + imName4 + " image5=" + imName5 + " image6=" + imName6 + " image7=" + imName7);
} else if (FNum==8){
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=" + imName3 + " image4=" + imName4 + " image5=" + imName5 + " image6=" + imName6 + " image7=" + imName7 + " image8=" + imName8);
} else if (FNum==9){
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=" + imName3 + " image4=" + imName4 + " image5=" + imName5 + " image6=" + imName6 + " image7=" + imName7 + " image8=" + imName8 + " image9=" + imName9);
} else {
    run("Concatenate...", "  title=[Concatenated Stacks] image1=" + imName1 + " image2=" + imName2 + " image3=[-- None --]");
}

// arrange concatenated stacks to channels
selectWindow("Concatenated Stacks");
run("Stack to Hyperstack...", "order=xyzct channels=" + FNum + " slices=" + slice_n + " frames=1 display=Color");

// set color of each channel
if (FNum<=2){
    if (EditGate==2){
        Stack.setChannel(1);
        run("Grays");
        Stack.setChannel(2);
        run("Rainbow RGB");
    } else {
        Stack.setChannel(1);
        run("Grays");
        Stack.setChannel(2);
        run("Red");        
    }
} else {
    Stack.setChannel(1);
    run("Grays");
    Stack.setChannel(2);
    run("Red");

    if (FNum>=3){
        Stack.setChannel(3);
        run("Green");
    } 
    if (FNum>=4){
        Stack.setChannel(4);
        run("Cyan");
    }
    if (FNum>=5){
        Stack.setChannel(5);
        run("Magenta"); 
    }
    if (FNum>=6){
        Stack.setChannel(6);
        run("Blue"); 
    } 
    if (FNum>=7){
        Stack.setChannel(7);
        run("Yellow"); 
    }  
    if (FNum>=8){
        Stack.setChannel(8);
        run("Red"); 
    }
    if (FNum>=9){
        Stack.setChannel(9);
        run("Green"); 
    }
}

// display color options
Stack.setDisplayMode("composite");
run("Brightness/Contrast...");
run("Channels Tool...");

// to comment
if (EditGate>=1){
    run("Edit...", "open=" + repoDir + "\\makevideoIV.ijm");
}
