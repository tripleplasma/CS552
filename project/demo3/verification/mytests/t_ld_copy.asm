lbi r0, 64 // icount 0
slbi r0, 246 // icount 1
lbi r1, 201 // icount 2
slbi r1, 168 // icount 3
lbi r2, 39 // icount 4
slbi r2, 75 // icount 5
lbi r3, 50 // icount 6
slbi r3, 158 // icount 7
lbi r4, 65 // icount 8
slbi r4, 36 // icount 9
lbi r5, 114 // icount 10
slbi r5, 44 // icount 11
lbi r6, 230 // icount 12
slbi r6, 204 // icount 13
lbi r7, 1 // icount 14
slbi r7, 18 // icount 15
andni r2, r2, 1 // icount 16
ld r5, r2, 8 // icount 17
andni r0, r0, 1 // icount 18
ld r2, r0, 12 // icount 19
andni r1, r1, 1 // icount 20
ld r5, r1, 2 // icount 21
andni r5, r5, 1 // icount 22