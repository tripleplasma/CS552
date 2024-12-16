lbi  r1, 0     //mem location tests first mem location
lbi  r2, 8      //value to store
lbi  r3, 5      //clear r3
st   r2, r1, 3  //store at mem location
add  r2, r2, r3
st   r2, r1, 5
ld   r4, r1, 3  //load from mem location
st   r4, r2, 5
ld   r5, r2, 5
add  r6, r4, r5
