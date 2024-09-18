Project Structure:\
   | \
   |-- nes.cfg \
   |-- src \
   &nbsp;| \
   &nbsp;|-- constants.inc \
   &nbsp;|-- demo.s \
   &nbsp;|-- tiles.chr \

To assemble and link the code, use the following commands : \
&nbsp;ca65 src/demo.s \
&nbsp;ld65 src/demo.o -C nes.cfg -o demo.nes