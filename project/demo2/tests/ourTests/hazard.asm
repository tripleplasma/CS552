lbi r1, 1
lbi r2, 2
slt r3, r2, r1
beqz r3, .label2 //sets r3 to 1 if r2 < r1, so r3 == 0 and thus does the r4 == 3   
add r4, r2, r1
halt

.label2:
halt