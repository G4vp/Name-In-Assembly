Project Structure:
   |
   |-- nes.cfg
   |-- src
      |
      |-- constants.inc
      |-- demo.s
      |-- tiles.chr

To assemble and link the code, use the following commands :
   ca65 src/demo.s
   ld65 src/demo.o -C nes.cfg -o demo.nes