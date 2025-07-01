// 3-D Ram Inference Example (Simple Dual port)
// File:rams_sdp_3d.sv

module rams_sdp_3d #(
    parameter P       = , 
    parameter NP      = 1024, 
    parameter NB_DATA = 16
) (
    input                          clock,        //! System clock
    input                          i_enable,     //! RAM enable signal
    input                          i_out_enable, //! Output enable signal, READ operation
    input                          i_wenable,    //! Input enable signal, WRITE operation
    input      [$clog(P)  - 1 : 0] i_address_P,  //! Row address input
    input      [$clog(NP) - 1 : 0] i_address_NP  //! Column address input
    input      [NB_DATA   - 1 : 0] i_data_in,    //! Input data sample
    output reg [NB_DATA   - 1 : 0] o_data_out    //! Output data sample
    // For true dual port design, different address for READ/WRITE are needed:
    // input      [$clog(P)  - 1 : 0] i_read_addr_P,   //! Row address input for READ
    // input      [$clog(NP) - 1 : 0] i_read_addr_NP,  //! Column address input for READ
    // input      [$clog(P)  - 1 : 0] i_writ_addr_P,   //! Row address input for WRITE
    // input      [$clog(NP) - 1 : 0] i_writr_addr_NP, //! Column address input for WRITE
);

reg [NB_DATA - 1 : 0] mem [P - 1 : 0][NP - 1 : 0]; //! RAM matrix. 2D unpacked array of P*NP, NB_DATA bit vectors.
// Access order in P -> NP -> NB_DATA

// PORT_A
always @ (posedge clock) begin: RAM_Write_Management
    if (i_enable) begin
        if(i_wenable) begin
            // Each clock cycle the RAM gets the address [Pi,NPi] to write if i_wenable    
            mem[i_address_P][i_address_NP] <= i_data_in;
        end
    end
end

// PORT_B
always @ (posedge clkb) begin: RAM_Read_Management
    if (i_enable) begin
        if (i_out_enable) begin
            // Each clock cycle the RAM gets address [Pi,NPi] and outputs the selected data
            o_data_out <= mem[i_address_P][i_address_NP]; 
        end
    end
end

endmodule
