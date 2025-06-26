//! 3D Ram Inference (Dual port). Stores P packed arrays of NP x NB_DATA. 

module dual_port_RAM3D #(
    parameter P       = 2   , //! Number of RAM Blocks
    parameter NP      = 1024, //! Number of samples on each RAM block 
    parameter NB_DATA = 32    //! Number of bits of each sample
) (
    input                                    clock       , //! System clock
    input                                    i_wenable   , //! Write enable signal
    input                                    i_enable    , //! RAM enable signal
    input      [$clog(P)            - 1 : 0] i_read_addr , //! RAM block READ Address signal
    input      [$clog(P)            - 1 : 0] i_write_addr, //! RAM block WRITE Address signal
    input      [NP - 1 : 0][NB_DATA - 1 : 0] i_data      , //! Input data block
    output reg [NP - 1 : 0][NB_DATA - 1 : 0] o_data        //! Output data block
);

reg [NP - 1 : 0][NB_DATA - 1 : 0] mem [P - 1 : 0]; //! RAM matrix
// Access order in P -> NP -> NB_DATA

// WRITE_PORT
genvar i;
generate
    for(i = 0 ; i < P ; i = i + 1) begin
        always @(posedge clock) begin
            if (i_enable) begin
                if(i_wenable) begin
                    mem[i_addr] <= i_data;
                end
                //o_data <= mem[i_addr];
            end
        end
    end
endgenerate

// READ_PORT
generate
    for(i = 0 ; i < P ; i = i + 1) begin
        always @ (posedge clock) begin
            if (i_enable) begin
                o_data <= mem[i_addr];
            end
        end
    end
endgenerate

endmodule