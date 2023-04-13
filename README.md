# TensegrityAnalyser

TensegrityAnalyser is a MATLAB application that allows users to analyze the natural frequencies of tensegrity structures. The application consists of several classes, grouped into two main sections:

1. **Structure Loader and Tensegrity Components**: These classes deal with the modeling and geometry of the structure.
   - *StructureLoader*: Allows users to load and save structures from and to Excel files.
   - *TensegrityComponents*: Handles the creation and manipulation of nodes and members within the structure.
   
2. **Natural Frequencies, Stiffness Matrix, and Tensegrity Modelling**: These classes perform frequency analysis of the structure.
   - *NaturalFrequencies*: Calculates the natural frequencies of the tensegrity structure.
   - *StiffnessMatrix*: Computes the stiffness matrix of the structure.
   - *TensegrityModelling*: Contains functions to model and analyze the tensegrity structure.

There are also files **Tensegrity_Experiment.xlsx** and **Blank_Structure.xlsx**. **Tensegrity_Experiment.xlsx** contains a the information to import a structure (the one from my dissertation) and **Blank_Structure.xlsx** holds a blank table to lay out a new structure. num2roman.m and roman2num.m are MATLAB functions to convert numbers to roman numerals and back (found https://uk.mathworks.com/matlabcentral/fileexchange/26161-roman2num-and-num2roman-modern-roman-numerals, written by François Beauducel).

## Getting Started

To use the TensegrityAnalyser, open the main application file (`TenStruct.mlapp`) in MATLAB and run it. The application allows users to:

1. Upload nodes in their Cartesian coordinates.
2. Upload members by specifying the nodes that connect them along with their material properties.
3. Plot the structure.

The application currently assumes gravity is acting on the system. The input force button allows users to set the direction of the force acting on the structure (X-axis, Y-axis, or Z-axis).

There are two example Excel files provided with the application for loading structures: one with a preloaded structure and another blank file for creating new structures.

## Areas for Improvement

- Add more force cases, such as no external force.
- Implement visualization of the fundamental modes of the structure.
- Compile the application and run it through remote servers.
- Improve the application's aesthetics.

## Other Files

Contained within this repo is also a file to plot the first five natural frequencies and then an average contour of all natural frequencies.

## Conclusion

TensegrityAnalyser is a promising tool for analyzing tensegrity structures. With further development and improvements, it can become an even more versatile and user-friendly application.
