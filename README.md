Neuroblinks 
===========

A program for doing eyeblink classical conditioning using Matlab and either Tucker Davis (TDT) or Arduino hardware. The TDT version also supports control of neurophysiological and optogenetic experiments. 

Please note that this page is a work on progress so there are missing links below. Please email us with questions. 

Authors: Shane Heiney & Shogo Ohmae, University of Pennsylvania

Copyright &copy; 2013


Requirements
------------

* Modern Windows computer (tested on Win7) with lots of RAM and multi-core processor (e.g. 8-16 GB RAM, Intel i7).
* Matlab v 2010b or later with the Image Acquisition and Image Processing toolboxes. Note that the code used to control the camera varies based on the particular release of Matlab because of changes in the Image Acquisition Toolbox. The current version of Neuroblinks works with Matlab 2014a but the source code comments contain code for some previous Matlab releases. 
* A high frame rate video camera (at least 200 FPS) supported by the Image Acquisition toolbox, for instance the Allied Vision Technologies Prosilica GE680 [link]. If you use a different camera you may need to modify the camera control code in Neuroblinks. We have only tested the Prosilica. 
* Arduino microprocessor [link] or Tucker Davis Technologies RZ5 Bioamplifier [link] (required to use neurophysiology features).


Instructions
------------

1. Configure your camera(s) to work with Matlab using the GigE adapter ("GigE Vision Hardware"). See this page [link] for detailed instructions. You can test whether your camera is properly configured to work with Neuroblinks by using `cameraTest()` in the "neuroblinks\Shared\Camera" directory. 

2. Configure your hardware (Arduino or TDT) using the instructions here [link]. Note that if you choose to use TDT the configuration will be considerably more complicated (and expensive) than if you use Arduino, so we recommend TDT only if you need to do neurophysiological recording. 

3. Download or clone "neuroblinks" project to your computer and add the main directory of the project (i.e., "neuroblinks") to your Matlab path. Do not include subfolders as these will be added automatically for you based whether you're using Arduino or TDT, as explained below. Manually adding subfolders below "neuroblinks" could result in unexpected behavior. 

4. Modify "Arduino\config.m" or "TDT\config.m" to match your particular configuration (see comments within the m-files).

5. Modify "neuroblinks.m" to set up your path to call the right "Launch" m-file based on whether you're using Arduino or TDT. See this page [link] for information about configuring your Arduino or TDT hardware (e.g. pinouts, settings). If you plan to use both TDT and Arduino on the same computer you can call Neuroblinks with the particular option, e.g. "neuroblinks('arduino',1)", where the number specifies the device ID of the camera you wish to use (returned by `imaqhwinfo('gige')`),  without modifying the code in "neuroblinks.m". 

6. Create a directory for your mouse, e.g. `<data root>\<animalID>` and make this your current directory in Matlab. For example, we use `data\MXXX`, where XXX is the unique mouse ID. Note that if you follow our naming conventions and start Neuroblinks from the root directory for a particular mouse, the metadata.mouse field will be automatically populated for you and the session directory will be automatically created as "YYMMDD", which is the current date (`datestr(now,'yymmdd')`. If you deviate from this naming convention and directory structure you will likely need to modify the code in "Launch.m". 

7. Run `neuroblinks()` to start the main program (with optional arguments).

This page [link] provides some brief instructions on using the Neuroblinks GUI to help get you started. 