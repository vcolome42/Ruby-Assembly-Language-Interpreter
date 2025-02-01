# Ruby-Assembly-Language-Interpreter
An assembly language interpreter (ALI) for the Simple Assembly Language (SAL), developed with Ruby

This ALI project was created for my Object-Oriented Languages and Environments class, with a primary focus on exploring Ruby's symbols, and classes, as well as other features of object-oriented programming.

To use the program, simply follow these steps:

### STEP 1: Executing the program

- Ensure the ali.rb file is in the same folder as the .txt files with instructions written in the SAL. The program will only read .txt files from this folder. Three .txt files are present in the folder by default. The simple.txt file runs a basic set of instructions to add 10 and 20 together to get a result of 30. The input.txt file runs a slightly more advanced set of instructions to create a loop where the value 4 is added for a total of four times to get a result of 16. The infinite.txt file is exactly the same as input.txt except that JZS 23 has been changed to JZS 21, resulting in an infinite loop. 

<img width="554" alt="image" src="https://github.com/user-attachments/assets/4520c569-ff8b-4d84-988f-353c1b7c2d70" />

- Assuming your device is properly configured to work with Ruby, and you have Ruby installed, you can simply open the folder in your preferred IDE (VSCode, RubyMine, etc), and type "ruby ali.rb" in the terminal, followed by the "ENTER" key on your keyboard. 

<img width="599" alt="image" src="https://github.com/user-attachments/assets/f475563a-185a-49ef-8b8a-2e51ca8a78ae" />

### STEP 2: Navigating the program

- The program should display a short guide on how to use the program. Enter the name of the .txt file you would like to use. In the image below, I used simple.txt. After entering the chosen filename, you have the option of executing all instructions from the file with 'a', executing instructions one by one by pressing 's' until you have reached the end of the program, or quitting the program and closing the window with 'q'. Choosing either 'a' or 's' will also output the state of the ALI's data memory, shown as values, and their location in memory.  In this program, the ALI's memory is divided into two parts: Program Memory, which occupies memory cells 0-127 and is reserved for storing instructions derived from the .txt files, and Data Memory, located within memory cells 128-255, which holds symbols and values. When the ALI's memory is printed, all 256 memory locations are visible from the terminal's output, the majority of which will be zero, indicating unused cells in memory. 

<img width="676" alt="image" src="https://github.com/user-attachments/assets/23e1ed36-76b3-429a-a0c2-0a8b6e5aa452" />

- When the program has finished executing all instructions, simply enter 'q' to exit the program.
