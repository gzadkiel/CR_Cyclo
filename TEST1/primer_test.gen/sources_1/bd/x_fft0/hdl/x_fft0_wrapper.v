//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
//Date        : Sun Jul  6 21:05:06 2025
//Host        : Geronimo running 64-bit major release  (build 9200)
//Command     : generate_target x_fft0_wrapper.bd
//Design      : x_fft0_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module x_fft0_wrapper
   (aclk_0,
    event_data_in_channel_halt_0,
    event_data_out_channel_halt_0,
    event_frame_started_0,
    event_status_channel_halt_0,
    event_tlast_missing_0,
    event_tlast_unexpected_0,
    m_axis_data_tdata_0,
    m_axis_data_tlast_0,
    m_axis_data_tready_0,
    m_axis_data_tvalid_0,
    s_axis_config_tdata_0,
    s_axis_config_tready_0,
    s_axis_config_tvalid_0,
    s_axis_data_tdata_0,
    s_axis_data_tlast_0,
    s_axis_data_tready_0,
    s_axis_data_tvalid_0);
  input aclk_0;
  output event_data_in_channel_halt_0;
  output event_data_out_channel_halt_0;
  output event_frame_started_0;
  output event_status_channel_halt_0;
  output event_tlast_missing_0;
  output event_tlast_unexpected_0;
  output [31:0]m_axis_data_tdata_0;
  output m_axis_data_tlast_0;
  input m_axis_data_tready_0;
  output m_axis_data_tvalid_0;
  input [39:0]s_axis_config_tdata_0;
  output s_axis_config_tready_0;
  input s_axis_config_tvalid_0;
  input [31:0]s_axis_data_tdata_0;
  input s_axis_data_tlast_0;
  output s_axis_data_tready_0;
  input s_axis_data_tvalid_0;

  wire aclk_0;
  wire event_data_in_channel_halt_0;
  wire event_data_out_channel_halt_0;
  wire event_frame_started_0;
  wire event_status_channel_halt_0;
  wire event_tlast_missing_0;
  wire event_tlast_unexpected_0;
  wire [31:0]m_axis_data_tdata_0;
  wire m_axis_data_tlast_0;
  wire m_axis_data_tready_0;
  wire m_axis_data_tvalid_0;
  wire [39:0]s_axis_config_tdata_0;
  wire s_axis_config_tready_0;
  wire s_axis_config_tvalid_0;
  wire [31:0]s_axis_data_tdata_0;
  wire s_axis_data_tlast_0;
  wire s_axis_data_tready_0;
  wire s_axis_data_tvalid_0;

  x_fft0 x_fft0_i
       (.aclk_0(aclk_0),
        .event_data_in_channel_halt_0(event_data_in_channel_halt_0),
        .event_data_out_channel_halt_0(event_data_out_channel_halt_0),
        .event_frame_started_0(event_frame_started_0),
        .event_status_channel_halt_0(event_status_channel_halt_0),
        .event_tlast_missing_0(event_tlast_missing_0),
        .event_tlast_unexpected_0(event_tlast_unexpected_0),
        .m_axis_data_tdata_0(m_axis_data_tdata_0),
        .m_axis_data_tlast_0(m_axis_data_tlast_0),
        .m_axis_data_tready_0(m_axis_data_tready_0),
        .m_axis_data_tvalid_0(m_axis_data_tvalid_0),
        .s_axis_config_tdata_0(s_axis_config_tdata_0),
        .s_axis_config_tready_0(s_axis_config_tready_0),
        .s_axis_config_tvalid_0(s_axis_config_tvalid_0),
        .s_axis_data_tdata_0(s_axis_data_tdata_0),
        .s_axis_data_tlast_0(s_axis_data_tlast_0),
        .s_axis_data_tready_0(s_axis_data_tready_0),
        .s_axis_data_tvalid_0(s_axis_data_tvalid_0));
endmodule
