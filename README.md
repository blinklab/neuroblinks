Neuroblinks 
===========

A program for doing eyeblink classical conditioning using Matlab and either Tucker Davis (TDT) or Arduino hardware. The TDT version also supports control of neurophysiological and optogenetic experiments. 

Please note that this page is a work in progress so there may be incomplete information. Please email us with questions. 

Authors: Shane Heiney & Shogo Ohmae, University of Pennsylvania

Copyright &copy; 2013


Requirements
------------

* Modern Windows computer (tested on Win7) with lots of RAM and multi-core processor (e.g. 8-16 GB RAM, Intel i7).
* Matlab v 2010b or later with the Image Acquisition and Image Processing toolboxes. Note that the code used to control the camera varies based on the particular release of Matlab because of changes in the Image Acquisition Toolbox. The current version of Neuroblinks works with Matlab 2014a but the source code comments contain code for some previous Matlab releases. 
* A high frame rate video camera (at least 200 FPS) supported by the Image Acquisition toolbox, for instance the Allied Vision Technologies [Prosilica GE680](http://www.alliedvisiontec.com/us/products/cameras/gigabit-ethernet/prosilica-ge/ge680.html). If you use a different camera you may need to modify the camera control code in Neuroblinks. We have only tested the Prosilica. 
* [Arduino microprocessor](http://arduino.cc/en/Main/arduinoBoardDue) or Tucker Davis Technologies [RZ5 Bioamplifier](http://www.tdt.com/rz5d-base-processor.html) (required to use neurophysiology features).


Instructions
------------

1. Configure your camera(s) to work with Matlab using the GigE adapter ("GigE Vision Hardware"). See this [document](https://docs.google.com/document/d/1jAP2g_fxNbUylIzeIvo7oRSLNTaUKlLlRVbz8Pwz39U/edit?usp=sharing) for detailed instructions. You can test whether your camera is properly configured to work with Neuroblinks by using `cameraTest()` in the "neuroblinks\Shared\Camera" directory. This is a standalone program that doesn't depend on Arduino or TDT being configured. 

2. Configure your hardware (Arduino or TDT). The necessary Arduino source code and TDT circuit files are included in the "private" directories of their respective subfolders under "neuroblinks". You will also need to configure the inputs and outputs. The code is written to work with the Arduino Due or TDT RZ5 processors but should be relatively easy to extend to other devices. Contact us if you have any questions about how to do this. 

3. Download or clone the "neuroblinks" project to your computer and add the main directory of the project (i.e., "neuroblinks") to your Matlab path. Do not include subfolders as these will be added automatically for you based whether you're using Arduino or TDT, as explained below. Manually adding subfolders below "neuroblinks" could result in unexpected behavior. 

4. Place the file "[neuroblinks_config.m](https://drive.google.com/file/d/0B4gSOteKRf_HV3ZzYmYyeXJhRVU/view?usp=sharing)" somewhere in your Matlab path outside the "neuroblinks" source tree, such as the Matlab startup folder, and modify it to match your particular configuration (see comments within the m-file).

5. Create a directory for your mouse, e.g. `<data root>\<animalID>` and make this your current directory in Matlab. For example, we use `data\MXXX`, where XXX is the unique mouse ID. Note that if you follow our naming conventions and start Neuroblinks from the root directory for a particular mouse, the metadata.mouse field will be automatically populated for you and the session directory will be automatically created as "YYMMDD", which is the current date (`datestr(now,'yymmdd')`. If you deviate from this naming convention and directory structure you will likely need to modify the code in "configure.m" and some of our analysis code might not work for you. 

6. Run `neuroblinks()` to start the main program (with optional arguments).

This [document](https://docs.google.com/document/d/1InIuTQ_H1JthY9_0v9BHR0_naf4_ief3BlzZlXbdtBc/edit?usp=sharing)  provides some brief instructions on using the Neuroblinks GUI to help get you started. The instructions are specfic to the Arduino version but will mostly apply to the TDT version as well. 

You'll want to set up the camera and IR light source so that the mouse's face is in frame and the entire eye is in focus. The IR light should be positioned to give good contrast between the iris/pupil and surrounding fur. See [Heiney et al, 2014b](http://www.ncbi.nlm.nih.gov/pubmed/25378152) for more information. 

The data for each trial, including a raw video of the trial and the metadata, will be stored in separate .MAT files within the session directory using the base name that you specify plus an auto-incremented suffix corresponding to the trial number. Contact us if you would like guidance on how to process these files to get calibrated eyelid traces and metadata in a format that's easier to analyze. 