module exponential_LUT #(
    parameter P  =     , //! Number of data blocks
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

localparam INDX_WIDTH = P*NP;

reg [9              : 0] exp_real_part;
reg [9              : 0] exp_imag_part;
reg [INDX_WIDTH - 1 : 0] r_index;
reg [9              : 0] re_LUT16   [16*P   - 1 : 0];
reg [9              : 0] im_LUT16   [16*P   - 1 : 0];
reg [9              : 0] re_LUT32   [32*P   - 1 : 0];
reg [9              : 0] im_LUT32   [32*P   - 1 : 0];
reg [9              : 0] re_LUT64   [64*P   - 1 : 0];
reg [9              : 0] im_LUT64   [64*P   - 1 : 0];
reg [9              : 0] re_LUT128  [128*P  - 1 : 0];
reg [9              : 0] im_LUT128  [128*P  - 1 : 0];
reg [9              : 0] re_LUT256  [256*P  - 1 : 0];
reg [9              : 0] im_LUT256  [256*P  - 1 : 0];
reg [9              : 0] re_LUT512  [512*P  - 1 : 0];
reg [9              : 0] im_LUT512  [512*P  - 1 : 0];
reg [9              : 0] re_LUT1024 [1024*P - 1 : 0];
reg [9              : 0] im_LUT1024 [1024*P - 1 : 0];

always @(posedge clock) begin
    if (i_reset) begin
        r_index <= {INDX_WIDTH{1'b0}};
    end
    else if (i_enable == 1'b1 && i_m_axis_data_tvalid == 1'b1) begin
        r_index <= r_index + 1'b1;
        if (r_index == INDX_WIDTH - 1) begin
            r_index <= {INDX_WIDTH{1'b0}};
        end
        case (i_NFFT_sel)
            3'b000 : begin // 16
                exp_real_part <= re_LUT16[r_index];
                exp_imag_part <= im_LUT16[r_index];
            end 
            3'b001 : begin // 32
                exp_real_part <= re_LUT32[r_index];
                exp_imag_part <= im_LUT32[r_index];
            end
            3'b010 : begin // 64
                exp_real_part <= re_LUT64[r_index];
                exp_imag_part <= im_LUT64[r_index];
            end
            3'b011 : begin // 128
                exp_real_part <= re_LUT128[r_index];
                exp_imag_part <= im_LUT128[r_index];
            end 
            3'b100 : begin // 256
                exp_real_part <= re_LUT256[r_index];
                exp_imag_part <= im_LUT256[r_index];
            end
            3'b101 : begin // 512
                exp_real_part <= re_LUT512[r_index];
                exp_imag_part <= im_LUT512[r_index];
            end
            3'b110 : begin // 1024
                exp_real_part <= re_LUT1024[r_index];
                exp_imag_part <= im_LUT1024[r_index];
            end
            default: begin // 1024
                exp_real_part <= re_LUT1024[r_index];
                exp_imag_part <= im_LUT1024[r_index];
            end
        endcase
    end
    else begin
        r_index <= r_index;
    end
end

assign o_exp_sample_real = exp_real_part;
assign o_exp_sample_imag = exp_imag_part;

// LUTs
// NP = 16
assign re_LUT16[0] = 10'b0000000000; assign im_LUT16[0] = 10'b0000000000;
assign re_LUT16[1] = 10'b0000000000; assign im_LUT16[1] = 10'b0000000000;
assign re_LUT16[2] = 10'b0000000000; assign im_LUT16[2] = 10'b0000000000;
assign re_LUT16[3] = 10'b0000000000; assign im_LUT16[3] = 10'b0000000000;
assign re_LUT16[4] = 10'b0000000000; assign im_LUT16[4] = 10'b0000000000;
assign re_LUT16[5] = 10'b0000000000; assign im_LUT16[5] = 10'b0000000000;
 



endmodule