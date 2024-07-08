import numpy as np

def naiveFFT(x):
    ''' The naive implementation for comparison '''
    N = x.size
    X = np.ones(N)*(0+0j)

    for k in range(N):
        A = np.ones(N)*(0+0j)
        for n in range(N):
            A[n] = x[n]*np.exp(-complex(0, 2*np.pi*k*n/N))
        X[k] = sum(A)

    return X

def Rad2FFT(x):
    ''' Recursive radix-2 FFT'''
    x = np.array(x, dtype=float)
    N = int(x.size)
    # Use the naive version when the size is small enough
    if N <= 8:
        return naiveFFT(x)
    else:
        # Calculate first half of the W
        k = np.arange(N//2)
        W = np.exp(-2j*np.pi*k/N)
        evens = Rad2FFT(x[::2])
        odds = Rad2FFT(x[1::2])
        return np.concatenate([evens + (W * odds), evens - (W * odds)])
