Run "name-convention-check"
Run "vcheck-all.sh"
Test "wsrun.pl -prog ../tests/simple_test/add_0.asm  proc_hier_bench *.v"
demo2 test .asm: 
    1. go to demo2 folder
    2. type "wsrun.pl -wave -pipe -prog /u/s/w/swamit/public/html/courses/cs552/fall2024/handouts/testprograms/public/inst_tests/add_0.asm proc_hier_pbench verilog/*.v"
demo2 test all: 
    1. go to demo2 folder
    2. type either
        a. "wsrun.pl -wave -pipe -list //u/s/w/swamit/public/html/courses/cs552/fall2024/handouts/testprograms/public/inst_tests/all.list proc_hier_pbench verilog/*.v"
        b. "run-phase2-almostAll.sh"

demo3 stallmem (change seed for different rand patterns): 
    1. wsrun.pl -wave -pipe -seed 0 -prog /u/s/w/swamit/public/html/courses/cs552/fall2024/handouts/testprograms/public/inst_tests/ld_3.asm proc_hier_pbench verilog/*.v

demo3 check: wsrun.pl -pipe -list /u/s/w/swamit/public/html/courses/cs552/fall2024/handouts/testprograms/public/complex_demofinal/all.list proc_hier_pbench verilog/*.v