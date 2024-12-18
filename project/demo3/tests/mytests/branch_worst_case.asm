lbi r1, 1
bnez r1, .L1
lbi r2, 0
j .L2

.L3:
lbi r3, 0
bnez r3, .L4
lbi r3, 1
j .L4

.L5:
lbi r5, 0
bnez r5, .L2
lbi r5, 1
j .L2

.L4:
lbi r4, 1
bnez r4, .L5
lbi r4, 0
j .L2

.L1:
lbi r2,1
bnez r2, .L3

.L2:
halt

