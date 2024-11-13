lbi r1, 1
lbi r2, 2
add r3, r1, r2
beqz r3, .label2
addi r4, r4, 4
halt

.label2:
halt