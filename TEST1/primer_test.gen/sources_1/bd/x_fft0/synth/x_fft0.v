//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
//Date        : Sun Jul  6 21:05:06 2025
//Host        : Geronimo running 64-bit major release  (build 9200)
//Command     : generate_target x_fft0.bd
//Design      : x_fft0
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "x_fft0,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=x_fft0,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "x_fft0.hwdef" *) 
module x_fft0
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK_0, ASSOCIATED_BUSIF M_AXIS_DATA_0:S_AXIS_CONFIG_0:S_AXIS_DATA_0, CLK_DOMAIN x_fft0_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.EVENT_DATA_IN_CHANNEL_HALT_0 INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.EVENT_DATA_IN_CHANNEL_HALT_0, PortWidth 1, SENSITIVITY EDGE_RISING" *) output event_data_in_channel_halt_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.EVENT_DATA_OUT_CHANNEL_HALT_0 INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.EVENT_DATA_OUT_CHANNEL_HALT_0, PortWidth 1, SENSITIVITY EDGE_RISING" *) output event_data_out_channel_halt_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.EVENT_FRAME_STARTED_0 INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.EVENT_FRAME_STARTED_0, PortWidth 1, SENSITIVITY EDGE_RISING" *) output event_frame_started_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.EVENT_STATUS_CHANNEL_HALT_0 INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.EVENT_STATUS_CHANNEL_HALT_0, PortWidth 1, SENSITIVITY EDGE_RISING" *) output event_status_channel_halt_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.EVENT_TLAST_MISSING_0 INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.EVENT_TLAST_MISSING_0, PortWidth 1, SENSITIVITY EDGE_RISING" *) output event_tlast_missing_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.EVENT_TLAST_UNEXPECTED_0 INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.EVENT_TLAST_UNEXPECTED_0, PortWidth 1, SENSITIVITY EDGE_RISING" *) output event_tlast_unexpected_0;
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

  wire aclk_0_1;
  wire m_axis_data_tready_0_1;
  wire [39:0]s_axis_config_tdata_0_1;
  wire s_axis_config_tvalid_0_1;
  wire [31:0]s_axis_data_tdata_0_1;
  wire s_axis_data_tlast_0_1;
  wire s_axis_data_tvalid_0_1;
  wire xfft_0_event_data_in_channel_halt;
  wire xfft_0_event_data_out_channel_halt;
  wire xfft_0_event_frame_started;
  wire xfft_0_event_status_channel_halt;
  wire xfft_0_event_tlast_missing;
  wire xfft_0_event_tlast_unexpected;
  wire [31:0]xfft_0_m_axis_data_tdata;
  wire xfft_0_m_axis_data_tlast;
  wire xfft_0_m_axis_data_tvalid;
  wire xfft_0_s_axis_config_tready;
  wire xfft_0_s_axis_data_tready;

  assign aclk_0_1 = aclk_0;
  assign event_data_in_channel_halt_0 = xfft_0_event_data_in_channel_halt;
  assign event_data_out_channel_halt_0 = xfft_0_event_data_out_channel_halt;
  assign event_frame_started_0 = xfft_0_event_frame_started;
  assign event_status_channel_halt_0 = xfft_0_event_status_channel_halt;
  assign event_tlast_missing_0 = xfft_0_event_tlast_missing;
  assign event_tlast_unexpected_0 = xfft_0_event_tlast_unexpected;
  assign m_axis_data_tdata_0[31:0] = xfft_0_m_axis_data_tdata;
  assign m_axis_data_tlast_0 = xfft_0_m_axis_data_tlast;
  assign m_axis_data_tready_0_1 = m_axis_data_tready_0;
  assign m_axis_data_tvalid_0 = xfft_0_m_axis_data_tvalid;
  assign s_axis_config_tdata_0_1 = s_axis_config_tdata_0[39:0];
  assign s_axis_config_tready_0 = xfft_0_s_axis_config_tready;
  assign s_axis_config_tvalid_0_1 = s_axis_config_tvalid_0;
  assign s_axis_data_tdata_0_1 = s_axis_data_tdata_0[31:0];
  assign s_axis_data_tlast_0_1 = s_axis_data_tlast_0;
  assign s_axis_data_tready_0 = xfft_0_s_axis_data_tready;
  assign s_axis_data_tvalid_0_1 = s_axis_data_tvalid_0;
  x_fft0_xfft_0_0 xfft_0
       (.aclk(aclk_0_1),
        .event_data_in_channel_halt(xfft_0_event_data_in_channel_halt),
        .event_data_out_channel_halt(xfft_0_event_data_out_channel_halt),
        .event_frame_started(xfft_0_event_frame_started),
        .event_status_channel_halt(xfft_0_event_status_channel_halt),
        .event_tlast_missing(xfft_0_event_tlast_missing),
        .event_tlast_unexpected(xfft_0_event_tlast_unexpected),
        .m_axis_data_tdata(xfft_0_m_axis_data_tdata),
        .m_axis_data_tlast(xfft_0_m_axis_data_tlast),
        .m_axis_data_tready(m_axis_data_tready_0_1),
        .m_axis_data_tvalid(xfft_0_m_axis_data_tvalid),
        .s_axis_config_tdata(s_axis_config_tdata_0_1),
        .s_axis_config_tready(xfft_0_s_axis_config_tready),
        .s_axis_config_tvalid(s_axis_config_tvalid_0_1),
        .s_axis_data_tdata(s_axis_data_tdata_0_1),
        .s_axis_data_tlast(s_axis_data_tlast_0_1),
        .s_axis_data_tready(xfft_0_s_axis_data_tready),
        .s_axis_data_tvalid(s_axis_data_tvalid_0_1));
endmodule
