import numpy as np
import FFT
import generate_OFDM
import matplotlib.pyplot as plt
import scipy

# MAC Unit
def MAC(vector1,vector2):
    result = 0
    for i in range(0,len(vector1)):
        result += vector1[i]*vector2[i]
    result = result/len(vector1)
    return result

# Segun el paper, la ecuacion para F(k) es:
# F(k) = (1/N) * sum{0,N-1,F}, donde F es x(n)x*(n-t)e^-j2pikn/N 

def SSCFD():
    # Signal and ACM
    tau     = 4                                         # PARAMETRO PARA EL DELAY
    x       = generate_OFDM.generate_ODFM()             # OFDM PARAMETRIZABLE
    noise   = np.random.normal(0,0.5,80)                # AWGN AGREGADO
    x       = np.add(x,noise)                       
    x_delay = np.zeros(len(x))                      
    for i in range(0,len(x)-tau):
        x_delay[i] = x[i+tau]
    x_delay = np.conjugate(x_delay)
    ACM_out = x*x_delay                             

    # FFT 
    F_k     = FFT.Rad2FFT(ACM_out)                      # Radix-2 FFT
    F_k     = F_k/len(ACM_out)                          # OBTENER F(K) = R(alpha,tau)

    # Calculate Sigma Matrix (Covariance)           
    # Obtain real and imag parts of F_k = Xk + Yk*j
    X_k     = np.real(F_k)                          
    Y_k     = np.imag(F_k)
    # Obtain W = XX
    W       = MAC(X_k,X_k)
    print('Elemento de matriz covarianza W: ', W)
    # Obtain X = Y = XY
    XY      = MAC(X_k,Y_k)
    print('Elemento de matriz covarianza XY: ', XY)
    # Obtain Z
    Z       = MAC(Y_k,Y_k)
    print('Elemento de matriz covarianza Z: ', Z)
    Sigma   = [[W,XY],[XY,Z]]

    # FSM
    # Taps F_k until value is different than 0          # REVISAR: ME DAN TODOS DIF DE 0, POSIBLE ARRASTRE DE ERROR
    index   = np.nonzero(F_k)                           # BUSCA INDICE DEL BIN DIFERENTE DE 0     
    r       = F_k[index[0][0]]                          # SE OBTIENE el vector r = F(alpha)
    print('El F(alpha) after tapping es: ', r)
    r1      = np.real(r)
    r2      = np.imag(r)
    rr      = [r1, r2]

    # Obtain Test Statistic Tc
    num     = r1*r1*Z + r2*r2*W - 2*r1*r2*XY            
    den     = W*Z - XY*XY
    Tc      = num/den

    # Calculate Threshold
    # Degree of freedom, 2 for this case
    grad    = 2
    # Cumulative probability for which you want to find the quantile 
    q       = 0.95                                      
    # OPCION POSIBLE PARA DEFINIR:
    # Hypothesis Testing: In hypothesis testing, you might want to determine the critical value of the chi-square 
    # distribution to decide whether to reject the null hypothesis. Common significance levels (α) used in hypothesis 
    # testing are 0.01, 0.05, and 0.10, which correspond to cumulative probabilities of 0.99, 0.95, and 0.90, respectively.
    
    # Quantile (inverse CDF) for the given q
    F_1     = scipy.stats.chi2.ppf(q, grad)
    Pfa     = 0.2
    net     = F_1*(1-Pfa)                               # VALOR DEL UMBRAL DE COMPARACION

    if(Tc > net):
        print('Test statistic Tc: ', Tc)
        print('Threshold: ', net)
        print('Canal Ocupado')
        estado_ocupado = True
    elif(Tc < net):
        print('Test statistic Tc: ', Tc)
        print('Threshold: ', net)
        print('Canal Libre')
        estado_ocupado = False
    return estado_ocupado


# Test con 100 intentos de sensado
contador = 0
for i in range (0,100):
    estado_canal = SSCFD()
    if(estado_canal == True):
        # Canal ocupado
        contador = contador
    elif(estado_canal == False):
        # Canal libre
        contador += 1

print('Cantidad de veces que el canal estaba libre: ', contador)
