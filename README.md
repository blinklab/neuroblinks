Neuroblinks 
===========

A program for doing eyeblink classical conditioning using Matlab and either Tucker Davis (TDT) or Arduino hardware. The TDT version also supports control of neurophysiological and optogenetic experiments. 

Authors: Shane Heiney & Shogo Ohmae, University of Pennsylvania

Copyright &copy; 2013


Requirements
------------

* Modern Windows computer (tested on Win7) with lots of RAM and multi-core processor (e.g. 8-16 GB RAM, Intel i7).
* Matlab v 2010b or later with the Image Acquisition and Image Processing toolboxes.
* A video camera supported by the Image Acquisition toolbox, for instance the Allied Vision Technologies Prosilica GE680.
* Arduino microprocessor or Tucker Davis Technologies RZ5 Bioamplifier (required to use neurophysiology features).


Instructions
------------

1. Make sure your system meets the Requirements.

2. Download or clone "neuroblinks" project to your computer and add the main directory of the project to your Matlab path.

3. Modify "Arduino\config.m" or "TDT\config.m" to match your particular configuration (see comments within the m-files).

4. Modify "neuroblinks.m" to call the right "Launch" m-file based on whether you're using Arduino or TDT.

5. Create a session directory, e.g. `<data root>\<animalID>\<sessionID>` and make this your current directory in Matlab.

6. Run "neuroblinks.m" to start the main program.

7. Pray that it works. *Seriously*, there's almost no chance that it will work right out of the box and you'll probably need to tweak it for your needs. Contact us with questions. 


