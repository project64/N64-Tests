# Sort Triangle By Y Coordinates (Highest To Lowest)
# IF Coordinate 0 & 1 Share Same Y: Sort By X Coordinates (Lowest To Highest)
# IF Coordinate 1 & 2 Share Same Y: Sort By X Coordinates (Highest To Lowest)

#tri = (68.0, 129.0), (83.0, 114.0), (68.0, 114.0) # Y Sorted Triangle
#tri = (68.0, 130.0), (83.0, 130.0), (83.0, 115.0) # Y Sorted Triangle

#tri = (144.0, 129.0), (175.0, 98.0), (144.0, 98.0) # Y Sorted Triangle
#tri = (144.0, 130.0), (175.0, 130.0), (175.0, 99.0) # Y Sorted Triangle

#tri = (228.0, 129.0), (291.0, 66.0), (228.0, 66.0) # Y Sorted Triangle
tri = (228.0, 130.0), (291.0, 130.0), (291.0, 67.0) # Y Sorted Triangle

triwinding = (tri[0][0]*tri[1][1] - tri[1][0]*tri[0][1]) + (tri[1][0]*tri[2][1] - tri[2][0]*tri[1][1]) + (tri[2][0]*tri[0][1] - tri[0][0]*tri[2][1]) # (X0*Y1 - X1*Y0) + (X1*Y2 - X2*Y1) + (X2*Y0 - X0*Y2)
if triwinding > 0.0: dir = 0 # IF (Triangle Winding == Clockwise) Left Major Triangle (Direction Flag = 0)
else: dir = 1 # Else Right Major Triangle (Direction Flag = 1)
print ("Triangle Direction = %i\n" % dir)

YL = tri[0][1] # YL = tri[0].y
YM = tri[1][1] # YM = tri[1].y
YH = tri[2][1] # YH = tri[2].y
print ("YL = %f" % YL)
print ("YM = %f" % YM)
print ("YH = %f\n" % YH)

XL = tri[1][0] # XL = X Value Of Vertex With Middle Y Value (YM) (tri[1].x)
XM = tri[2][0] # XM/XH = X Value Of Vertex With Lowest Y Value (YH) (tri[2].x)
print ("XL = %f" % XL)
print ("XM = %f" % XM)
print ("XH = %f\n" % XM)

if (tri[0][1] - tri[1][1]) != 0: DxLDy = (tri[0][0] - tri[1][0]) / (tri[0][1] - tri[1][1]) # DxLDy = YL - XL
else: DxLDy = 0.0
if (tri[1][1] - tri[2][1]) != 0: DxMDy = (tri[1][0] - tri[2][0]) / (tri[1][1] - tri[2][1]) # DxMDy = XL - XM
else: DxMDy = 0.0
if (tri[0][1] - tri[2][1]) != 0: DxHDy = (tri[0][0] - tri[2][0]) / (tri[0][1] - tri[2][1]) # DxHDy = YL - XM
else: DxHDy = 0.0
print ("DxLDy = %f" % DxLDy)
print ("DxMDy = %f" % DxMDy)
print ("DxHDy = %f\n" % DxHDy)

YL *= 4.0 # Convert YL Into 11.2 Fixed Point Format
YM *= 4.0 # Convert YM Into 11.2 Fixed Point Format
YH *= 4.0 # Convert YH Into 11.2 Fixed Point Format
XLf = (XL % 1) * 65536 # Convert XL 16-Bit Fraction
XMf = (XM % 1) * 65536 # Convert XM 16-Bit Fraction
if (DxLDy < 0.0) and (DxLDy > -1.0): DxLDy -= 1.0 # Convert DxLDy 16-Bit Signed Integer
if (DxMDy < 0.0) and (DxMDy > -1.0): DxMDy -= 1.0 # Convert DxMDy 16-Bit Signed Integer
if (DxHDy < 0.0) and (DxHDy > -1.0): DxHDy -= 1.0 # Convert DxHDy 16-Bit Signed Integer
DxLDyf = (DxLDy % 1) * 65536 # Convert DxLDy 16-Bit Fraction
DxMDyf = (DxMDy % 1) * 65536 # Convert DxMDy 16-Bit Fraction
DxHDyf = (DxHDy % 1) * 65536 # Convert DxHDy 16-Bit Fraction
print ("Texture_Triangle %i, 0, 0, %i,%i,%i, %i,%i, %i,%i, %i,%i, %i,%i, %i,%i, %i,%i" % (dir, YL,YM,YH, XL,XLf, DxLDy,DxLDyf, XM,XMf, DxHDy,DxHDyf, XM,XMf, DxMDy,DxMDyf))
