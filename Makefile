CC=gcc

expr.o: expr.c
	gcc -c -o $@ $<
machine.o:machine.c
	gcc -c -DDO_DEBUG -lm -o $@ $<
%.yy.c : %.lex %.tab.c
	flex -o $@ $<

%.tab.c: %.y
	bison -d -v -o $@ $<

%.tab.o: %.tab.c
	gcc -c -o $@ $<

%.yy.o: %.yy.c
	gcc -c -o $@ $<


%.out: %.yy.o %.tab.o expr.o machine.o
	gcc -o $@ $^ -lfl -ly -lm

%.result : %.out %.input
	./$< < $(word 2,$^) > $@ && cat $@
clean :
	rm -f *.o *.out *~ *.# *.result *.output *.tab.h
