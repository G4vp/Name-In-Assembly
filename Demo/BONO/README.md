### Project Structure:\
   | \
   |-- nes.cfg \
   |-- src \
   &nbsp;&nbsp;&nbsp;&nbsp;| \
   &nbsp;&nbsp;&nbsp;&nbsp;|-- constants.inc \
   &nbsp;&nbsp;&nbsp;&nbsp;|-- demo.s \
   &nbsp;&nbsp;&nbsp;&nbsp;|-- tiles.chr \

### To assemble and link the code, use the following commands : \
&nbsp;&nbsp;&nbsp;&nbsp;$ ca65 src/demo.s \
&nbsp;&nbsp;&nbsp;&nbsp;$ ld65 src/demo.o -C nes.cfg -o demo.nes
