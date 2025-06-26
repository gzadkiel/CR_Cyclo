import numpy as np 
from _fixedInt import *

window = np.kaiser(1024,14)
window_str = ''
window_hex = ''
print(window)

array = arrayFixedInt(10,7,window,signedMode='S',saturateMode='saturate')
print(array)
for i in range(0,len(array)):
    print('Valor float: ', array[i].fValue)
    print('Valor binario: ', bin(array[i].intvalue))
    print('Valor binario llevado a 10 bits: ', str(bin(array[i].intvalue)[2:]).zfill(10))
    window_str = window_str + str(bin(array[i].intvalue)[2:].zfill(10))

print(window_str)
