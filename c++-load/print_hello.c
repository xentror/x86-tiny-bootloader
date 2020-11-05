extern void print_hello(void)
{
    const short color = 0x0200;
    const char *hello = "Vas niquez ta mere en C !";
    short *vga_buffer = (short*)0xB8000 + 80; // max characters per row == 80

    for (int i = 0; hello[i]; i++) {
        vga_buffer[i] = hello[i] | color;
    }
}
