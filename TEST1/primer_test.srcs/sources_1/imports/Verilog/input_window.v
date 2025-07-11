//! Shift-register that receives and stores samples from input signal i_x. The buffer stores Np samples that are then multiplied with the 
//! desired input window and sent to the FFT Module. Once L new samples are received the process repeats itself. 

module input_window #(
    parameter NP          = 1024, //! Input buffer width Np
    parameter L           = 256 , //! L decimation parameter
    parameter NB_SAMPLES  = 16  , //! Number of bits of input sample (i_x)
    parameter NBF_SAMPLES = 15  , //! Number of frac bits of input sample (i_x)
    parameter NB_WINDOWS  = 10  , //! Number of bits of win coeff (i_windows)
    parameter NBF_WINDOWS = 7   , //! Number of frac bits of win coeffs (i_windows)
    parameter NB_OUTPUT   = 16  , //! Number of bits of output product (o_product)
    parameter NBF_OUTPUT  = 15    //! Number of frac bits of output product (o_product)
) ( 
    input                                   clock    , //! System clock
    input                                   i_reset  , //! System reset
    input                                   i_enable , //! Module enable signal
    input  signed [NB_SAMPLES      - 1 : 0] i_x      , //! Data sample input
    input         [(NB_WINDOWS*NP) - 1 : 0] i_windows, //! Window coefficients input
    output        [(NB_OUTPUT*NP)  - 1 : 0] o_product, //! Np samples with applied window output
    output                                  o_valid    //! Valid output signal
);

// Localparameters
localparam NB_PROD   = NB_SAMPLES  + NB_WINDOWS                             ; //! Number of bits of product signal (r_prod)
localparam NBF_PROD  = NBF_SAMPLES + NBF_WINDOWS                            ; //! Number of frac bits of product signal (r_prod)
localparam NBI_TRUNC = (NB_PROD - NBF_PROD) - ((NB_OUTPUT - NBF_OUTPUT) - 1); //! Bits to analize in order to trunc output 
                                                                              //  (NBI_TRUNC generalized to fit other quantizations)
// Signals
reg  signed [NB_SAMPLES     - 1 : 0] r_shiftreg [NP - 1 : 0]; //! Shiftreg to store the incoming samples
reg  signed [NB_PROD        - 1 : 0] r_prod     [NP - 1 : 0]; //! Array with product between window and samples
reg                                  r_outenable            ; //! Internal output enable signal
reg                                  r_out_valid            ; //! External output valid signal
reg         [(NB_OUTPUT*NP) - 1 : 0] r_outprod              ; //! 1D packed register to store the output array
reg         [$clog2(L)      - 1 : 0] contador               ; //! Counter to count L input samples

wire signed [NB_WINDOWS     - 1 : 0] w_window   [NP - 1 : 0]; //! Wire array with window coeffs

// Variables (32 bit, adjust to smaller counters depending on the values L, Np, etc...)
integer ptr_SRx ; //! Shiftregister pointer
integer ptr_Prod; //! Product matrix pointer

// Could be implemented directly with a for cycle - check later !!
// Create array of window coefficients from i_windows input (unpack 1D array into 2D array)
generate 
    genvar pointer;
    for (pointer = 0 ; pointer < NP ; pointer = pointer + 1) begin:assignWinCoeffs          
        assign w_window[pointer] = i_windows[(pointer + 1)*NB_WINDOWS - 1 -: NB_WINDOWS];
    end
endgenerate

always @(posedge clock or posedge i_reset) begin : Shift_Register_Implementation // Shifregister to store incoming samples
    if (i_reset) begin //! If reset the entire buffer is cleared
        for (ptr_SRx = 0 ; ptr_SRx < NP ; ptr_SRx = ptr_SRx + 1) begin
            r_shiftreg[ptr_SRx] <= {NB_SAMPLES{1'b0}}; 
            end        
        contador    <= 3'b000;
        r_outenable <= 1'b0;
        end
    else if (i_enable == 1'b1 && r_outenable == 1'b0) begin //! Shift register and store new data sample
        for (ptr_SRx = 0 ; ptr_SRx < (NP - 1) ; ptr_SRx = ptr_SRx + 1) begin
            r_shiftreg[ptr_SRx + 1] <= r_shiftreg[ptr_SRx];     
            end 
        r_shiftreg[0]   <= i_x;                                 
        contador        <= contador + 1'b1;
        if (contador == L - 1) begin
            contador    <= 0;
            r_outenable <= ~r_outenable;
        end                                                        
    end
    else begin //! Shiftreg not enabled
        for (ptr_SRx = 0 ; ptr_SRx < NP ; ptr_SRx = ptr_SRx + 1) begin
            r_shiftreg[ptr_SRx] <= r_shiftreg[ptr_SRx];
            end                            
        contador        <= contador;
        r_outenable     <= 1'b0; // revisar!
    end 
end

// Could be implemented with a generate - check later !!
always @(*) begin : Output_Product_Conditioning // Once L new samples are stored generate product matrix and pack it into 1D vector
    if (r_outenable) begin
        for (ptr_Prod = 0 ; ptr_Prod < NP ; ptr_Prod = ptr_Prod + 1) begin                                  
            r_prod[ptr_Prod] <= w_window[ptr_Prod]*r_shiftreg[ptr_Prod];    
            r_outprod[(ptr_Prod + 1)*NB_OUTPUT - 1 -: NB_OUTPUT] <= (~|r_prod[ptr_Prod][NB_PROD - 1 -: NBI_TRUNC] || &r_prod[ptr_Prod][NB_PROD - 1 -: NBI_TRUNC]) ?  
                                                                    r_prod[ptr_Prod][NB_PROD - NBI_TRUNC -: NB_OUTPUT] : (r_prod[ptr_Prod][NB_PROD - 1]) ? 
                                                                    {1'b1,{NB_OUTPUT - 1{1'b0}}} : {1'b0,{NB_OUTPUT - 1{1'b1}}};
        end
        r_outenable <= 1'b0;                           
    end
end

always @(posedge clock) begin : Output_Valid_Signal_Gen
    if (i_reset) begin
        r_out_valid <= 1'b0;
    end
    else if (i_enable) begin
        if (contador == L - 1) begin
            r_out_valid <= 1'b1;
        end
        else begin
            r_out_valid <= 1'b0;
        end
    end
    else begin
        r_out_valid <= 1'b0;
    end
end

assign o_product = r_outprod;
assign o_valid   = r_out_valid;

endmodule