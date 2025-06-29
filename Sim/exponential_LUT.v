module exponential_LUT #(
    parameter P  = 1024, //! Number of data blocks
    parameter NP = 1024, //! Number of data samples per block
) (
    input           clock,                //! System clock     
    input           i_reset,              //! System reset
    input           i_enable,             //! Enable signal
    input   [2 : 0] i_NFFT_sel,           //! Input to select the number of FFT points
    input           i_m_axis_data_tvalid, //! Asserted by the core to signal that it is able to provide sample data
    output  [9 : 0] o_exp_sample_real,    //! Output for real part of the exponential coefficient 
    output  [9 : 0] o_exp_sample_imag     //! Output for imag part of the exponential coefficient
);
    
// exp(-i2pimpL/Np)
// L  : decimation parameter (4, 8, 16, ... , 256)
// Np : number of data samples per block (16, 32, 64, ... , 1024)
// m  : index for each sample on the data block (0, 1, 2, ... , Np - 1)
// p  : index for each data block (0, 1, 2, ... , P - 1)

localparam INDX_P_WIDTH  = $clog(P);
localparam INDX_NP_WIDTH = $clog(NP);
localparam NB_EXP_COEFFS = ;

reg [NB_EXP_COEFFS     : 0] exp_real_part;
reg [NB_EXP_COEFFS     : 0] exp_imag_part;
reg [INDX_P_WIDTH  - 1 : 0] r_P_index;
reg [INDX_NP_WIDTH - 1 : 0] r_NP_index;
reg [NB_EXP_COEFFS     : 0] re_LUT1024 [1024*P - 1 : 0];
reg [NB_EXP_COEFFS     : 0] im_LUT1024 [1024*P - 1 : 0];

always @(posedge clock) begin: LUT_Index_Management
    if (i_reset) begin
        r_P_index  <= {INDX_P_WIDTH{1'b0}};
        r_NP_index <= {INDX_NP_WIDTH{1'b0}};
    end
    else if (i_enable == 1'b1 && i_m_axis_data_tvalid == 1'b1) begin
        // Increase NP index on each clock cycle
        r_NP_index <= r_NP_index + 1'b1;
        if (r_NP_index == NP - 1) begin
            // Once NP samples, reset NP index to 0 and increase P index to start the next samples block
            r_NP_index <= {INDX_NP_WIDTH{1'b0}};
            r_P_index  <= r_P_index + 1'b1;
            if (r_P_index == P - 1) begin
                // Once P blocks, reset both indexes
                r_P_index  <= {INDX_P_WIDTH{1'b0}};
                r_NP_index <= {INDX_NP_WIDTH{1'b0}};
            end
        end
        exp_real_part <= re_LUT1024[r_P_index][r_NP_index];
        exp_imag_part <= im_LUT1024[r_P_index][r_NP_index];
    end
    else begin
        r_index <= r_index;
    end
end

assign o_exp_sample_real = exp_real_part;
assign o_exp_sample_imag = exp_imag_part;

// LUTs
// Row P = 0 - LUT16[0][NPi]
assign re_LUT16[0   ][0   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][0   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][1   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][1   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][3   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][3   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][4   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][4   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][5   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][5   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][6   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][6   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][7   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][7   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][8   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][8   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][9   ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][9   ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][10  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][10  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][11  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][11  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][12  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][12  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][13  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][13  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][14  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][14  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][15  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][15  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][16  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][16  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][17  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][17  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][18  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][18  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][19  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][19  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][20  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][20  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][21  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][21  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][22  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][22  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][23  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][23  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][24  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][24  ] = NB_EXP_COEFFS'b;
assign re_LUT16[0   ][25  ] = NB_EXP_COEFFS'b; assign im_LUT16[0   ][25  ] = NB_EXP_COEFFS'b;
// .......................

endmodule
