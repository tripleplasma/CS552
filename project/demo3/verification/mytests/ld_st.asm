lbi  r1, 0     //mem location tests first mem location
lbi  r2, 8      //value to store
lbi  r3, 0      //clear r3
st   r2, r1, 0  //store at mem location
ld   r3, r1, 0  //load from mem location
add  r1, r3, r2
add  r1, r3, r2