module complex_demodulator #(
    parameter P       =     , //! Number of data blocks
    parameter NP      = 1024, //! Number of data samples per block
    parameter NB_DATA = 16    //! Number of bits per sample
) (
    input                    clock,                               //!
    input                    i_reset,                             //!
    input                    i_enable,                            //!            
    input  [NB_DATA - 1 : 0] i_X_re,                              //!                
    input  [NB_DATA - 1 : 0] i_X_im,                              //!                 
    input  [1           : 0] i_window_sel,                        //!
    input  [2           : 0] i_NFFT_sel,                          //!
    input  [6           : 0] i_CP_LEN_sel,                        //!
    output [NB_DATA - 1 : 0] o_downshifted_transform_sample_real, //! 
    output [NB_DATA - 1 : 0] o_downshifted_transform_sample_imag, //!
    output [15          : 0] o_m_axis_data_tuser,                 //!
    output                   o_m_axis_data_tlast,                 //!
    output                   o_m_axis_data_tready,                //!
    output                   o_m_axis_data_tvalid,                //!
    output                   o_event_data_in_channel_halt,        //! 
    output                   o_event_data_out_channel_halt,       //!     
    output                   o_event_frame_started,               //!
    output                   o_event_status_channel_halt,         //!
    output                   o_event_tlast_missing,               //!
    output                   o_event_tlast_unexpected             //!
);

// Localparam
localparam NB_EXP     = 10;                 //! Number of bits of exponential coefficient
localparam NBF_EXP    = NB_EXP - 3;         //! Number of frac bits of exponential coefficient
localparam NBF_DATA   = NB_DATA - 1;        //! Number of frac bits of data sample
localparam NB_PROD    = NB_DATA + NB_EXP;   //! Number of bits of the resulting downshifted sample
localparam NBF_PROD   = NBF_DATA + NBF_EXP; //! Number of frac bits of the resulting downshifted sample

// Signals
wire signed [NB_DATA  - 1 : 0] w_m_axis_data_tdata_real_part; //! Wire for the real part of the FFT output sample
wire signed [NB_DATA  - 1 : 0] w_m_axis_data_tdata_imag_part; //! Wire for the imag part of the FFT output sample
wire signed [NB_EXP   - 1 : 0] w_real_exp_part;               //! Wire fot the real part of the exponential coefficient
wire signed [NB_EXP   - 1 : 0] w_imag_exp_part;               //! Wire fot the imag part of the exponential coefficient
wire                           w_m_axis_data_tvalid;          //! Wire for the TVALID output signal from FFT module
wire                           w_m_axis_data_tlast;           //! Wire for the TLAST output signal from FFT module

reg  signed [NB_PROD    - 1 : 0] r_downshifted_sample_real_part;    //! Real part of the resulting product
reg  signed [NB_PROD    - 1 : 0] r_downshifted_sample_imag_part;    //! Imag part of the resulting product

// Behavioral
// if this doesnt directly work, try setting up the axis handshake

always @(posedge clock) begin: Downshift_Operation
    if (i_enable == 1'b1 && w_m_axis_data_tvalid == 1'b1) begin
        r_downshifted_sample_real_part <= w_m_axis_data_tdata_real_part * w_real_exp_part;
        r_downshifted_sample_imag_part <= w_m_axis_data_tdata_imag_part * w_imag_exp_part;
    end
end

assign o_downshifted_transform_sample_real = r_downshifted_sample_real_part;
assign o_downshifted_transform_sample_imag = r_downshifted_sample_imag_part;
assign o_m_axis_data_tvalid = w_m_axis_data_tvalid;
assign o_m_axis_data_tlast = w_m_axis_data_tlast;

exponential_LUT # (
    .P  (P ),
    .NP (NP))
exponential_LUT_inst (
    .clock                  (clock               ),
    .i_reset                (i_reset             ),
    .i_enable               (i_enable            ),
    .i_NFFT_sel             (i_NFFT_sel          ),
    .i_m_axis_data_tvalid   (w_m_axis_data_tvalid),
    .o_exp_sample_real      (w_real_exp_part     ),
    .o_exp_sample_imag      (w_imag_exp_part     ));

first_stage_control # (
    .P          (P       ),
    .NP         (NP      ),
    .NB_DATA    (NB_DATA))
first_stage_control_inst (
    .clock                          (clock                                                        ),
    .i_reset                        (i_reset                                                      ),
    .i_enable                       (i_enable                                                     ),
    .i_X_re                         (i_x_real                                                     ),
    .i_X_im                         (i_x_imag                                                     ),
    .i_window_sel                   (i_window_sel                                                 ),
    .i_NFFT_sel                     (i_NFFT_sel                                                   ),
    .i_CP_LEN_sel                   (i_CP_LEN_sel                                                 ),
    .o_m_axis_data_tdata            ({w_m_axis_data_tdata_imag_part,w_m_axis_data_tdata_real_part}),
    .o_m_axis_data_tuser            (o_m_axis_data_tuser                                          ),
    .o_m_axis_data_tlast            (w_m_axis_data_tlast                                          ),
    .o_m_axis_data_tready           (o_m_axis_data_tready                                         ),
    .o_m_axis_data_tvalid           (w_m_axis_data_tvalid                                         ),
    .o_event_data_in_channel_halt   (o_event_data_in_channel_halt                                 ),
    .o_event_data_out_channel_halt  (o_event_data_out_channel_halt                                ),
    .o_event_frame_started          (o_event_frame_started                                        ),
    .o_event_status_channel_halt    (o_event_status_channel_halt                                  ),
    .o_event_tlast_missing          (o_event_tlast_missing                                        ),
    .o_event_tlast_unexpected       (o_event_tlast_unexpected                                     ));

endmodule