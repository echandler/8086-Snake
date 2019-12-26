# 8086-Snake
Purchased "Progamming Boot Sector Games" by Oscar Toledo after watching a video by 8-bit Guy on youtube, this is the first game after reading (about half of) the book.

![Snake.jpg](https://raw.githubusercontent.com/echandler/8086-Snake/master/snake.JPG)

### How to compile:
1) Install Nasm.
2) Install Bochs or Oracle VM VirtualBox (tested on both).
3) Compile with Nasm on the cmd line: nasm snake.asm -f bin -o snake.img
4) Create a virtual machine and "insert" the snake.img file into the virtual floppy drive.
