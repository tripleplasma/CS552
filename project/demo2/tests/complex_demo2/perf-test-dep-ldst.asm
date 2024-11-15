lbi r0, 0       //x2
lbi r5, 43      
lbi r6, 43      //x6
lbi r7, 43        
ld r1, r0, 5    //xa
st r5, r1, 6
ld r1, r0, 2    //xe
st r6, r1, 1    //x10
ld r1, r0, 4    //x12
st r7, r1, 1    //x14
halt
