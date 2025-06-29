module conjugate_and_store #(
    parameter NP      = 1024,
    parameter NB_DATA = 16
) (
    input                    clock,          //!
    input                    i_reset,        //!
    input                    i_enable,       //!
    input  [NB_DATA - 1 : 0] i_X_re,         //!
    input  [NB_DATA - 1 : 0] i_X_im,         //!
    input  [1           : 0] i_window_sel,   //!
    input  [2           : 0] i_NFFT_sel,     //!
    input  [6           : 0] i_CP_LEN_sel,   //!
    output                   o_storage_ready //!         
);

// Localparam
localparam ADDR_WIDTH = $clog(P);           //! Number of bits for the memory address

// Signals
reg  signed [NB_DATA    - 1 : 0] r_shiftreg_real [NP - 1 : 0];      //! Buffer to store the transformed data block (real)
reg  signed [NB_DATA    - 1 : 0] r_shiftreg_imag [NP - 1 : 0];      //! Buffer to store the transformed data block (imag)
reg  signed [NB_DATA    - 1 : 0] r_shiftreg_real_conj [NP - 1 : 0]; //! Buffer to store the conjugate transformed data block (real)
reg  signed [NB_DATA    - 1 : 0] r_shiftreg_imag_conj [NP - 1 : 0]; //! Buffer to store the conjugate transformed data block (imag)
reg         [ADDR_WIDTH - 1 : 0] r_write_addr;                      //! Register to store the current write address for RAM management
reg                              r_storage_ready;

wire signed [NB_DATA    - 1 : 0] w_downshifted_transform_sample_real; 
wire signed [NB_DATA    - 1 : 0] w_downshifted_transform_sample_imag;

integer ptr_SR;

// Behavioral
always @(posedge clock or posedge i_reset) begin: Shift_Registers_Implementation
    if (i_reset) begin 
        // If reset both registers are flushed
        for (ptr_SR = 0 ; ptr_SR < NP ; ptr_SR = ptr_SR + 1) begin
            r_shiftreg_real[ptr_SR] <= {NB_DATA{1'b0}};
            r_shiftreg_imag[ptr_SR] <= {NB_DATA{1'b0}};
        end        
    end
    else if (i_enable == 1'b1 && w_m_axis_data_tvalid == 1'b1 && w_m_axis_data_tlast == 1'b0) begin 
        // Shift registers and store new data samples from FFT output
        for (ptr_SR = 0 ; ptr_SR < (NP - 1) ; ptr_SR = ptr_SR + 1) begin
            r_shiftreg_real[ptr_SR + 1] <= r_shiftreg_real[ptr_SR];
            r_shiftreg_imag[ptr_SR + 1] <= r_shiftreg_imag[ptr_SR];       
        end 
        r_shiftreg_real[0] <= w_downshifted_transform_sample_real;     
        r_shiftreg_imag[0] <= w_downshifted_transform_sample_imag;                        
    end
    else begin 
        // Shiftregs not enabled
        for (ptr_SR = 0 ; ptr_SR < NP ; ptr_SR = ptr_SR + 1) begin
            r_shiftreg_real[ptr_SR] <= r_shiftreg_real[ptr_SR];
            r_shiftreg_imag[ptr_SR] <= r_shiftreg_imag[ptr_SR];
        end
    end 
end

genvar pointer;
generate
    for (pointer = 0; pointer < NP; pointer = pointer + 1) begin: Conjugate_Loop
        assign r_shiftreg_real_conj[pointer] = r_shiftreg_real[pointer];
        assign r_shiftreg_imag_conj[pointer] = -r_shiftreg_imag[pointer];
    end
endgenerate


always @(posedge clock) begin: Write_Address_Management
	if (i_reset) begin
		r_write_addr    <= {ADDR_WIDTH{1'b0}};
        r_storage_ready <= 1'b0;
	end
	if (i_enable) begin
        if (w_m_axis_data_tlast) begin
          	r_write_addr <= r_write_addr + 1'b1;
		    if (r_write_addr == P - 1) begin
			    r_write_addr    <= {ADDR_WIDTH{1'b0}};
                r_storage_ready <= 1'b1;
		    end  
        end
	end
	else begin
		r_write_addr <= r_write_addr;
	end
end

assign o_storage_ready = r_storage_ready;

dual_port_RAM3D # (
    .P          (P      ),
    .NP         (NP     ),
    .NB_DATA    (NB_DATA))
complex_demodulate_RAM (
    .clock          (clock                            ),  //
    .i_wenable      (w_m_axis_data_tvalid             ),  // Write enable when TVALID from FFT
    .i_enable       (i_enable                         ),  //
    .i_read_addr    (i_read_addr                      ),  // Not used
    .i_write_addr   (r_write_addr                     ),  //
    .i_data         ({r_shiftreg_imag,r_shiftreg_real}),  // check best way to store !!!!!!!!!!!!
    .o_data         (o_data                           )); //

dual_port_RAM3D # (
    .P          (P      ),
    .NP         (NP     ),
    .NB_DATA    (NB_DATA))
conjugate_complex_demodulate_RAM (
    .clock          (clock                                      ),  //
    .i_wenable      (w_m_axis_data_tvalid                       ),  // Write enable when TVALID from FFT
    .i_enable       (i_enable                                   ),  //
    .i_read_addr    (i_read_addr                                ),  // Not used
    .i_write_addr   (r_write_addr                               ),  //
    .i_data         ({r_shiftreg_imag_conj,r_shiftreg_real_conj}),  // check best way to store !!!!!!!!!!!!
    .o_data         (o_data                                     )); //

complex_demodulator # (
    .P          (P      ),
    .NP         (NP     ),
    .NB_DATA    (NB_DATA))
complex_demodulator_inst (
    .clock                                  (clock                              ),
    .i_reset                                (i_reset                            ),
    .i_enable                               (i_enable                           ),
    .i_X_re                                 (i_X_re                             ),
    .i_X_im                                 (i_X_im                             ),
    .i_window_sel                           (i_window_sel                       ),
    .i_NFFT_sel                             (i_NFFT_sel                         ),
    .i_CP_LEN_sel                           (i_CP_LEN_sel                       ),
    .o_downshifted_transform_sample_real    (w_downshifted_transform_sample_real),
    .o_downshifted_transform_sample_imag    (w_downshifted_transform_sample_imag),
    .o_m_axis_data_tuser                    (o_m_axis_data_tuser                ),
    .o_m_axis_data_tlast                    (w_m_axis_data_tlast                ),
    .o_m_axis_data_tready                   (o_m_axis_data_tready               ),
    .o_m_axis_data_tvalid                   (w_m_axis_data_tvalid               ),
    .o_event_data_in_channel_halt           (o_event_data_in_channel_halt       ),
    .o_event_data_out_channel_halt          (o_event_data_out_channel_halt      ),
    .o_event_frame_started                  (o_event_frame_started              ),
    .o_event_status_channel_halt            (o_event_status_channel_halt        ),
    .o_event_tlast_missing                  (o_event_tlast_missing              ),
    .o_event_tlast_unexpected               (o_event_tlast_unexpected           ));

endmodule