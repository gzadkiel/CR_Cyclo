# OFDM Signal
# Based on https://dspillustrations.com/pages/posts/misc/python-ofdm-example.html
# b --> S/P --> Mapping --> IDFT --> P/S --> Add CP

import numpy as np
import matplotlib.pyplot as plt

K = 64 # number of OFDM subcarriers
CP = K//4  # length of the cyclic prefix: 25% of the block
P = 8 # number of pilot carriers per OFDM block
pilotValue = 3+3j # The known value each pilot transmits
allCarriers = np.arange(K)  # indices of all subcarriers ([0, 1, ... K-1])

pilotCarriers = allCarriers[::K//P] # Pilots is every (K/P)th carrier.

# For convenience of channel estimation, let's make the last carriers also be a pilot
pilotCarriers = np.hstack([pilotCarriers, np.array([allCarriers[-1]])])
P = P+1

# data carriers are all remaining carriers
dataCarriers = np.delete(allCarriers, pilotCarriers)

mu = 4 # bits per symbol (i.e. 16QAM)
payloadBits_per_OFDM = len(dataCarriers)*mu  # number of payload bits per OFDM symbol

# print ("allCarriers:   %s" % allCarriers)
# print ("pilotCarriers: %s" % pilotCarriers)
# print ("dataCarriers:  %s" % dataCarriers)
#plt.plot(pilotCarriers, np.zeros_like(pilotCarriers), 'bo', label='pilot')
#plt.plot(dataCarriers, np.zeros_like(dataCarriers), 'ro', label='data')

mapping_table = {
    (0,0,0,0) : -3-3j,
    (0,0,0,1) : -3-1j,
    (0,0,1,0) : -3+3j,
    (0,0,1,1) : -3+1j,
    (0,1,0,0) : -1-3j,
    (0,1,0,1) : -1-1j,
    (0,1,1,0) : -1+3j,
    (0,1,1,1) : -1+1j,
    (1,0,0,0) :  3-3j,
    (1,0,0,1) :  3-1j,
    (1,0,1,0) :  3+3j,
    (1,0,1,1) :  3+1j,
    (1,1,0,0) :  1-3j,
    (1,1,0,1) :  1-1j,
    (1,1,1,0) :  1+3j,
    (1,1,1,1) :  1+1j
}
for b3 in [0, 1]:
    for b2 in [0, 1]:
        for b1 in [0, 1]:
            for b0 in [0, 1]:
                B = (b3, b2, b1, b0)
                Q = mapping_table[B]
                #plt.plot(Q.real, Q.imag, 'bo')
                #plt.text(Q.real, Q.imag+0.2, "".join(str(x) for x in B), ha='center')


## MODULO GENERADOR 

bits = np.random.binomial(n=1, p=0.5, size=(payloadBits_per_OFDM, ))
# print ("Bits count: ", len(bits))
# print ("First 20 bits: ", bits[:20])
# print ("Mean of bits (should be around 0.5): ", np.mean(bits))

def SP(bits):
    return bits.reshape((len(dataCarriers), mu))
bits_SP = SP(bits)
#print ("First 5 bit groups")
#print (bits_SP[:5,:])

def Mapping(bits):
    return np.array([mapping_table[tuple(b)] for b in bits])
QAM = Mapping(bits_SP)
#print ("First 5 QAM symbols and bits:")
#print (bits_SP[:5,:])
#print (QAM[:5])

def OFDM_symbol(QAM_payload):
    symbol = np.zeros(K, dtype=complex) # the overall K subcarriers
    symbol[pilotCarriers] = pilotValue  # allocate the pilot subcarriers 
    symbol[dataCarriers] = QAM_payload  # allocate the pilot subcarriers
    return symbol
OFDM_data = OFDM_symbol(QAM)
#print ("Number of OFDM carriers in frequency domain: ", len(OFDM_data))

def IDFT(OFDM_data):
    return np.fft.ifft(OFDM_data)
OFDM_time = IDFT(OFDM_data)
#print ("Number of OFDM samples in time-domain before CP: ", len(OFDM_time))

def addCP(OFDM_time):
    cp = OFDM_time[-CP:]               # take the last CP samples ...
    return np.hstack([cp, OFDM_time])  # ... and add them to the beginning
OFDM_withCP = addCP(OFDM_time)
#print ("Number of OFDM samples in time domain with CP: ", len(OFDM_withCP))

## SHORTCUT 
def generate_ODFM():
    bits_SP = SP(bits)
    QAM = Mapping(bits_SP)
    OFDM_data = OFDM_symbol(QAM)
    OFDM_time = IDFT(OFDM_data)
    OFDM_withCP = addCP(OFDM_time)
    return OFDM_withCP
