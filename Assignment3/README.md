## Assignment Question 1: Array.asm => implement many array functionalities in MIPS Assembly
## Assignment Question 2: countourfill.asm => implement an algorithm that fills any contour.

Here is the pseudocode for the algorithm I wrote to solve fillregion. 
I think I commented my code enough for you to understand what i'm doing
just by reading the code, but my algorithm pseudocode makes it even clearer.

############################################################################
# Algorithm for fillregion:

``` 
t5 -> index of seedpoint in 2D array ((i*50) + j)
t6 -> 0 (counter)

Loop:
	if t5 pixel is white (value of t5 in 2D array == 0) 
		color pixel at index black (=1)
		
	t7 -> neighbor at t5+t6 (see "Logic for recursion photo")
		
	if t7 pixel is white (value of t7 in 2D array == 0)
		push t5,t6 to stack
		t5 -> t7
		t6 -> 0
		goto Loop
		
	if t7 pixel is black (value of t7 in 2D array == 1)
		t6 -> t6 +1	//increment t6
		
	if t6 > 7
		t6 = get from stack
		t5 = get from stack
		if stack is empty end algorithm
		goto Loop
```
		
############################################################################

To check if the stack is empty, I saved the address of the sp after storing $ra into it
and then compared the saved register value with the sp address. If these addresses are 
the same, then the stack is empty, and the algorithm terminates.

## Note: Before running, must change the seed (starting x and y coordinates) to point inside a region you want to fill, if this seed is not inside a closed region, the program will fill in the entire background. Must also change the filenames at the top of the fillregion.asm file to match the file you would like to modify

## Here are the results of running fillregion.asm on a test file:
![alt_text](https://user-images.githubusercontent.com/50206147/111051230-91ce4880-841f-11eb-81c1-ad84bad64ed4.png)
![alt_text](https://user-images.githubusercontent.com/50206147/111051235-985cc000-841f-11eb-9d77-661a63419647.png)
