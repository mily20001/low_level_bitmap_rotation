# Low level bitmap rotation tools
Written as university project, most in assembly language. All versions allow you rotating bmp files with graduation of 90°.

### MIPS architecture
- Works in MARS emulator
- Reading, editing and writing BMP header done in asm
- Optimized memory usage at the expense of speed (project requirement)

### Intel architecture (x86/x64)
- Displays rotated image using SFML
- BMP header handled in C++
- Both x86 and x64 versions
- Optimized speed
