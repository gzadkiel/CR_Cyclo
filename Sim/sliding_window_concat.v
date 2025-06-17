//! Concatenates outputs from input buffers to be stored in RAM.

module sliding_window_concat #(
    parameter NB_INPUT       = 16       , //! Number of bits of each data sample
    parameter NB_WINFRAME    = 1024 * 16, //! Number of bits of the entire window coefficient array
    parameter NB_CONCAT_PROD = 1024 * 16  //! Number of bits of the entire output product array
) (
    input                                    clock         , //! System clock
    input                                    i_reset       , //! Reset signal
    input                                    i_enable      , //! Enable signal
    input         [NB_WINFRAME      - 1 : 0] i_window_frame, //! Packed array with window coefficients
    input  signed [NB_INPUT         - 1 : 0] i_x_re        , //! Real data input
    input  signed [NB_INPUT         - 1 : 0] i_x_im        , //! Imaginary data input
    output        [2*NB_CONCAT_PROD - 1 : 0] o_concat_frame, //! Concatenated output products
    output                                   o_valid_frame   //! Valid output signal
);

// Localparam
localparam NP_FFT      = 1024           ; //! Number of samples per data block
localparam L           = NP_FFT/4       ; //! Decimation parameter L
localparam NB_SAMPLES  = 16             ; //! Number of bits of each data sample
localparam NBF_SAMPLES = NB_SAMPLES - 2 ; //! Number of frac bits of each data sample
localparam NB_OUTPUT   = 16             ; //! Number of bits of each output sample
localparam NBF_OUTPUT  = NB_OUTPUT - 2  ; //! Number of frac bits of each output sample
localparam NB_WIND     = 16             ; //! Number of bits of each window coeff
localparam NBF_WIND    = NB_WIND - 2    ; //! Number of frac bits of each window coeff

// Signals
wire signed [NB_CONCAT_PROD - 1 : 0] w_oprod_re; //! Wire with the real part product 
wire signed [NB_CONCAT_PROD - 1 : 0] w_oprod_im; //! Wire with the imag part product 

wire w_ovalid_re; //! Valid signal from each input_window module
wire w_ovalid_im; //! Valid signal from each input_window module

reg [2*NB_CONCAT_PROD - 1 : 0] r_concat_products; //! Register to store the concatenated products
reg                            r_valid_frame    ; //! Valid output signal

// Behavioral

always @(posedge clock) begin: Concat_SWindow_Prods
    if (w_ovalid_im == 1'b1 && w_ovalid_re == 1'b1) begin
        r_concat_products <= {w_oprod_im,w_oprod_re};
        r_valid_frame     <= 1'b1;
    end
    else begin
        r_concat_products <= {NB_CONCAT_PROD{1'b0}};
        r_valid_frame     <= 1'b0;
    end
end

assign o_concat_frame = r_concat_products;
assign o_valid_frame  = r_valid_frame;

input_window #( //! Sliding window that processes real part of the input signal
    .NP             (NP        ), .L              (L          ),
    .NB_SAMPLES     (NB_SAMPLES), .NBF_SAMPLES    (NBF_SAMPLES),
    .NB_WINDOWS     (NB_WINDOWS), .NBF_WINDOWS    (NBF_WINDOWS),
    .NB_OUTPUT      (NB_OUTPUT ), .NBF_OUTPUT     (NBF_OUTPUT ))
  Input_Window_RE (
    .clock      (clock         ),
    .i_reset    (i_reset       ),
    .i_enable   (i_enable      ),
    .i_x        (i_x_re        ),
    .i_windows  (i_window_frame),
    .o_product  (w_oprod_re    ),
    .o_valid    (w_ovalid_re   ));

input_window #( //! Sliding window that processes real part of the input signal
    .NP             (NP        ), .L              (L          ),
    .NB_SAMPLES     (NB_SAMPLES), .NBF_SAMPLES    (NBF_SAMPLES),
    .NB_WINDOWS     (NB_WINDOWS), .NBF_WINDOWS    (NBF_WINDOWS),
    .NB_OUTPUT      (NB_OUTPUT ), .NBF_OUTPUT     (NBF_OUTPUT ))
  Input_Window_IM ( 
    .clock      (clock         ),
    .i_reset    (i_reset       ),
    .i_enable   (i_enable      ),
    .i_x        (i_x_im        ),
    .i_windows  (i_window_frame),
    .o_product  (w_oprod_im    ),
    .o_valid    (w_ovalid_im   ));

endmodule
