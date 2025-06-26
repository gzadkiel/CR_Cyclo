module first_stage_control # (
    parameter P       =     , //! Number of data blocks
    parameter NP      = 1024, //! Number of data samples per block
    parameter NB_DATA = 16    //! Number of bits per sample
) (
    input                      clock                        , //! System clock
    input                      i_reset                      , //! System reset
    input                      i_enable                     , //! Enable signal
    input  [NB_DATA   - 1 : 0] i_X_re                       , //! Real data input
    input  [NB_DATA   - 1 : 0] i_X_im                       , //! Imaginary data input
    input  [1             : 0] i_window_sel                 , //! Window select input
    input  [2             : 0] i_NFFT_sel                   , //! Input to select the number of FFT points
    input  [6             : 0] i_CP_LEN_sel                 , //! Input to adjust the Cyclic Prefix of the FFT
    output [2*NB_DATA - 1 : 0] o_m_axis_data_tdata          , //! Data output of the FFT in format: [X_im,X_re]
    output [15            : 0] o_m_axis_data_tuser          , //! Per-frame status information output for downstream slaves
    output                     o_m_axis_data_tlast          , //! Asserted by the core on the last sample of the frame
    output                     o_m_axis_data_tready         , //! Asserted by the external slave to signal thatit is ready to accept data
    output                     o_m_axis_data_tvalid         , //! Asserted by the core to signal that it is able to provide sample data
    output                     o_event_data_in_channel_halt , //! Event signal for error on FFT Module 
    output                     o_event_data_out_channel_halt, //! Event signal for error on FFT Module
    output                     o_event_frame_started        , //! Event signal for error on FFT Module
    output                     o_event_status_channel_halt  , //! Event signal for error on FFT Module
    output                     o_event_tlast_missing        , //! Event signal for error on FFT Module
    output                     o_event_tlast_unexpected       //! Event signal for error on FFT Module
);  

// Localparam
localparam ADDR_WIDTH   = $clog(P)  ; //! Number of bits used for the block Address
localparam NB_WIN_FRAME = NP*NB_DATA; //! Number of bits of the entire window array
localparam NB_CONC_PROD = NP*NB_DATA; //! Number of bits of the entire product array

// Signals
wire [2*NP - 1 : 0][NB_DATA - 1 : 0] w_concat_frame; //! Wire connecting the concatenated output frame from the window to the RAM
wire 							     w_write_enable; //! Wire connecting o_valid_frame to the write enable signal of the RAM
wire [2*NP - 1 : 0][NB_DATA - 1 : 0] w_ram_data_out; //! Wire connecting the RAM output to the FFT input buffer
wire [NP*10                 - 1 : 0] w_window_coeff; //! Wire output from the window coefficients LUT      

reg  [2*NB_DATA             - 1 : 0] r_fft_data_in    ; //! FFT sample input [imag,real]
reg  [$clog(P)              - 1 : 0] r_write_addr0    ; //! Register that stores the current RAM Address to write 
reg  [$clog(P)              - 1 : 0] r_read_addr0     ; //! Register that stores the current RAM Address to read
reg  [2*NP - 1 : 0][NB_DATA - 1 : 0] r_fft_buffer     ; //! Buffer that stores the current data block being fed to the FFT module
reg  [$clog(NP)             - 1 : 0] r_index          ; //! Index to feed samples from Buffer to FFT Module
reg                                  s_axis_data_tlast; //! T_LAST signal for FFT Module - End of data block
reg                                  r_ram_enable     ; //! Signal to enable the RAM Module for sync purposes

integer                              ptr_buffer; //! Buffer pointer to operate with the samples

// FFT Module Config Signals
reg [23                        : 0] s_axis_config_tdata ; //! Config NFFT, CP_LEN, FWD/INV and SCALE_SCH
reg [7                         : 0] NFFT                ; //! Number of points used for FFT
reg [7                         : 0] CP_LEN              ; //! Cyclic Prefix length for FFT
reg [2                         : 0] FWD_INV             ; //! Selects FWD or INV transform
reg []                              SCALE_SCH           ;
reg                                 s_axis_data_tready  ; //! Used by the core to signal that it is ready to accept data 
reg                                 s_axis_data_tvalid  ; //! Asserted by the upstream master to signal that it is able to provide data
reg                                 s_axis_config_tready; //! Asserted by the core to signal that it is able to accept data
reg                                 s_axis_config_tvalid; //! Asserted by the external master to signal that it is able to provide data

wire m_axis_data_tvalid //! Asserted by the core to signal that it is able to provide sample data
wire m_axis_data_tlast  //! Asserted by the core on the last sample of the frame
wire m_axis_data_tready //! Asserted by the external slave to signal that it is ready to accept data

// Behavioral

// FFT Module Configuration/Setup
// --------------------------------------------------------------------------------------
case (i_NFFT_sel) // Select FFT Points 
    3'b000 : NFFT = 8'b00000100; // NP = 16
    3'b001 : NFFT = 8'b00000101; // NP = 32
    3'b010 : NFFT = 8'b00000110; // NP = 64
    3'b011 : NFFT = 8'b00000111; // NP = 128
    3'b100 : NFFT = 8'b00001000; // NP = 256
    3'b101 : NFFT = 8'b00001001; // NP = 512
    3'b110 : NFFT = 8'b00001010; // NP = 1024
    default: NFFT = 8'b00001010; // NP = 1024
endcase

assign CP_LEN  = {0,i_CP_LEN_sel}; // Add padding to input CP_LEN
assign FWD_INV = 3'b100          ; // Select FWD FFT Mode

// SCALE_SCH conservative schedule for N = 1024
// Radix-4 Burst I/O  :  [10 10 10 10 11]
// Pipelined Stream I/O : [10 10 10 10 11]
// Radix-2 Burst I/O or Lie : [01 01 01 01 01 01 01 01 01 10]

case (i_NFFT_sel)  // VER COMO SIMULAR ESTO O SINO NO SE
    3'b000 : SCALE_SCH = ;
    3'b001 : SCALE_SCH = ;
    3'b010 : SCALE_SCH = ;
    3'b011 : SCALE_SCH = ;
    3'b100 : SCALE_SCH = ;
    3'b101 : SCALE_SCH = ;
    3'b110 : SCALE_SCH = ; 
    default: SCALE_SCH = ;
endcase

// TVALID is driven by the source (master) side of the channel and TREADY is driven by the receiver (slave)
// TVALID indicates that the value in the payload fields (TDATA, TUSER and TLAST) is valid
// TREADY indicates that the slave is ready to receive data
// When both TVALID and TREADY are TRUE in a cycle, a transfer occurs

// s_axis_config_tdata is an AXI channel that carries the fields: NFFT, CP_LEN, FWD_INV and SCALE_SCH
// The configuration fields are packed into the s_axis_config_tdata vector in the following order (starting from the LSB):
// s_axis_config_tdata[MSB downto 0]
// [PAD][SCALE_SCH] | [FWD_INV] | [PAD][CP_LEN] | [PAD][NFFT]


always @(posedge clock) begin: BasicHandshake_FFT_Axis_Initial_Config
    if (i_reset) begin
        s_axis_config_tvalid <= 1'b0;
    end
    if (i_enable) begin
        s_axis_config_tvalid <= 1'b1;
        if (s_axis_config_tready == 1'b1) begin
            s_axis_config_tdata <= {5'b0,FWD_INV,CP_LEN,NFFT};
        end
    end
    else begin
        s_axis_config_tvalid <= s_axis_config_tvalid;
    end
end
// --------------------------------------------------------------------------------------

// Window coefficients selector
// --------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------
// v0
// always @(posedge w_write_enable) begin: Write_Address_Management
// 	if (i_reset) begin
// 		r_write_addr <= {ADDR_WIDTH{1'b0}};
// 	end
// 	if (i_enable) begin
// 		r_write_addr <= r_write_addr + 1'b1;
// 		if (r_write_addr == P - 1) begin
// 			r_write_addr <= {ADDR_WIDTH{1'b0}};
// 		end
// 	end
// 	else begin
// 		r_write_addr <= r_write_addr;
// 	end
// end

// v1 
always @(posedge clock) begin: Write_Address_Management
	if (i_reset) begin
		r_write_addr <= {ADDR_WIDTH{1'b0}};
	end
	if (i_enable) begin
        if (w_write_enable) begin
          	r_write_addr <= r_write_addr + 1'b1;
		    if (r_write_addr == P - 1) begin
			    r_write_addr <= {ADDR_WIDTH{1'b0}};
		    end  
        end
	end
	else begin
		r_write_addr <= r_write_addr;
	end
end

always @(posedge clock) begin: Read_And_Load_FFT
    if (i_reset) begin
        r_read_addr0      <= {ADDR_WIDTH{1'b0}};
        r_index           <= {$clog(NP){1'b0}};
        s_axis_data_tlast <= 1'b0;
        for (ptr_buffer = 0 ; ptr_buffer < 2*NP ; ptr_buffer = ptr_buffer + 1) begin
            r_fft_buffer[ptr_buffer] <= {NB_DATA{1'b0}}; 
        end   
    end
    if (i_enable && s_axis_data_tready) begin
        r_fft_buffer  <= w_ram_dataout;
        r_fft_data_in <= {r_fft_buffer[2*NP - (1 + r_index)],r_fft_buffer[NP - (1 + r_index)]};
        // Have to add padding if sample size is smaller than 16 bits
        r_index       <= r_index + 1'b1;
        if (r_index == NP - 1) begin
            r_index           <= {$clog(NP){1'b0}};
            s_axis_data_tlast <= 1'b1;
            r_read_addr0      <= r_read_addr0 + 1'b1;
            if (r_read_addr0 == P - 1) begin
                r_read_addr0 <= {ADDR_WIDTH{1'b0}};
            end    
        end
        else begin
            r_index           <= r_index;
            s_axis_data_tlast <= 1'b0;
            r_read_addr0      <= r_read_addr0;
        end
    end
end

sliding_window_concat # (
    .NB_INPUT       (NB_DATA     ),
    .NB_WINFRAME    (NB_WIN_FRAME),
    .NB_CONCAT_PROD (NB_CONC_PROD))
sliding_window_concat_inst (
    .clock          (clock         ),
    .i_reset        (i_reset       ),
    .i_enable       (i_enable      ),
    .i_window_frame (w_window_coeff),
    .i_x_re         (r_x_re0       ), 
    .i_x_im         (r_x_im0       ),
    .o_concat_frame (w_concat_frame), 
    .o_valid_frame  (w_write_enable));

dual_port_RAM3D # (
    .P       (P      ),
    .NP      (NP     ),
    .NB_DATA (NB_DATA))
dual_port_RAM3D_inst (
    .clock       (clock         ),
    .i_wenable   (w_write_enable), 
    .i_enable    (i_enable      ),
    .i_read_addr (r_read_addr0  ),
    .i_write_addr(r_write_addr  ),
    .i_data      (w_concat_frame),
    .o_data      (w_ram_dataout ));

window_selector_LUT # (
    .NP (NP))
window_selector_LUT_inst (
    .i_NFFT_sel (i_NFFT_sel    ),
    .i_WIND_sel (i_window_sel  ),
    .o_window   (w_window_coeff));

FFT_xfft_0_2 xfft_0 (
    .aclk                          (clock                        ), 
    .event_data_in_channel_halt    (o_event_data_in_channel_halt ), // Asserted on every cycle where the core needs data from the Data Input channel and no data is available
    .event_data_out_channel_halt   (o_event_data_out_channel_halt), // Asserted on every cycle where the core needs to write data to the Data Output channel but cannot because the buffers in the channel are full
    .event_frame_started           (o_event_frame_started        ), // Asserted for a single clock cycle when the core starts to process a new frame
    .event_status_channel_halt     (o_event_status_channel_halt  ), // Asserted on every cycle where the core needs to write data to the Status channel but cannot because the buffers on the channel are full
    .event_tlast_missing           (o_event_tlast_missing        ), // Asserted for a single clock cycle when s_axis_data_tlast is Low on a last incoming data sample of a frame
    .event_tlast_unexpected        (o_event_tlast_unexpected     ), // Asserted for a single clock cycle when the core sees s_axis_data_tlast High on any incoming data sample that is not the last one in a frame
    .m_axis_data_tdata             (o_m_axis_data_tdata          ),
    .m_axis_data_tlast             (o_m_axis_data_tlast          ),
    .m_axis_data_tready            (o_m_axis_data_tready         ),
    .m_axis_data_tvalid            (o_m_axis_data_tvalid         ),
    .s_axis_config_tdata           (s_axis_config_tdata          ),
    .s_axis_config_tready          (s_axis_config_tready         ),
    .s_axis_config_tvalid          (s_axis_config_tvalid         ),
    .s_axis_data_tdata             (r_fft_data_in                ),
    .s_axis_data_tlast             (s_axis_data_tlast            ),
    .s_axis_data_tready            (s_axis_data_tready           ),
    .s_axis_data_tvalid            (s_axis_data_tvalid           )); 


endmodule
