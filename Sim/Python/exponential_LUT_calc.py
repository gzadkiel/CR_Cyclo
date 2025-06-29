import numpy as np
from _fixedInt import *

NP = 1024
L = NP/4 
P = 512
exp_LUT = np.zeros((P, NP),'complex')
real_part = np.array([P,NP])
imag_part = np.array([P,NP])

for i in range(0,P):
    for k in range(0,NP):
        exp_LUT[i,k] = np.exp(-2j*np.pi*i*k*L/NP)
        # real_part[i,k] = np.real(exp_LUT[i,k])
        # imag_part[i,k] = np.imag(exp_LUT[i,k])
        real_part.append(np.real(exp_LUT[i,k]))
        imag_part.append(np.imag(exp_LUT[i,k]))
        # print(real_part[i,k])
        # print(imag_part[i,k])

array_real = arrayFixedInt(16,15,real_part,signedMode='S',saturateMode='saturate')
array_imag = arrayFixedInt(16,15,imag_part,signedMode='S',saturateMode='saturate')

with open("EXP_LUT_output.txt", "w") as file:
    for i in range(0,len(array_real)):
        # print('Valor real float: ', array_real[i].fValue)
        # print('Valor imag float: ', array_imag[i].fValue)
        # print('Valor real binario: ', bin(array_real[i].intvalue))
        # print('Valor imag binario: ', bin(array_imag[i].intvalue))
        # print('Valor real binario llevado a 10 bits: ', str(bin(array_real[i].intvalue)[2:]).zfill(16))
        # print('Valor imag binario llevado a 10 bits: ', str(bin(array_imag[i].intvalue)[2:]).zfill(16))
        file.write(f"{str(bin(array_real[i].intvalue)[2:]).zfill(10)}\t{str(bin(array_imag[i].intvalue)[2:]).zfill(10)}\n")
