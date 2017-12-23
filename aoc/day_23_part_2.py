
a = 1
# set b 65
b = 65
# set c b
c = b
#jnz a 2
#jnz 1 5     <-- not used
if a:
    # mul b 100   <-- 3
    # sub b -100000
    b = b * 100 + 100000
    # set c b
    # sub c -17000
    c = b + 17000

h = 0

while True:
    #set f 1     <-- 32
    #set d 2
    f = 1
    d = 2
    while True:
        # set e 2     <-- 24
        e = 2
        while True:
            # set g d     <-- 20
            # mul g e
            # sub g b
            g = d * e - b
            # jnz g 2     <-- g = d * e - b = 0
            if g:
                # set f 0
                f = 0
            # sub e -1
            e += 1
            # set g e
            # sub g b     ==> add set g 0
            g = e - b
            # jnz g -8    <-- g = e - b
            if not g: break
        # sub d -1
        d += 1
        # set g d
        # sub g b     ==> add set g 0
        g = d - b
        # jnz g -13   <-- g = d * b
        if not g: break

    # jnz f 2     <-- f = 0 or 1
    if not f:
        # sub h -1    <-- count me!
        h += 1
    # set g b     <-- 25
    # sub g c
    g = b - c
    # jnz g 2     <-- g = b - c
    if not g:
        # jnz 1 3     <-- EXIT
        break
    # sub b -17   <-- 29   || 10.000 x
    b += 17
    # jnz 1 -23
print h