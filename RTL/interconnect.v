`timescale 1ns / 1ps

module interconnect (
    input wire aclk,
    input wire aresetn,

    input  wire [31:0] s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output reg         s_axi_awready,

    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output reg         s_axi_wready,

    output reg  [1:0]  s_axi_bresp,
    output reg         s_axi_bvalid,
    input  wire        s_axi_bready,

    input  wire [31:0] s_axi_araddr,
    input  wire        s_axi_arvalid,
    output reg         s_axi_arready,

    output reg  [31:0] s_axi_rdata,
    output reg  [1:0]  s_axi_rresp,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready,

    output wire [31:0] m00_axi_awaddr,
    output wire        m00_axi_awvalid,
    input  wire        m00_axi_awready,
    
    output wire [31:0] m00_axi_wdata,
    output wire [3:0]  m00_axi_wstrb,
    output wire        m00_axi_wvalid,
    input  wire        m00_axi_wready,
    
    input  wire [1:0]  m00_axi_bresp,
    input  wire        m00_axi_bvalid,
    output wire        m00_axi_bready,
    
    output wire [31:0] m00_axi_araddr,
    output wire        m00_axi_arvalid,
    input  wire        m00_axi_arready,
    
    input  wire [31:0] m00_axi_rdata,
    input  wire [1:0]  m00_axi_rresp,
    input  wire        m00_axi_rvalid,
    output wire        m00_axi_rready,

    output wire [31:0] m01_axi_awaddr,
    output wire        m01_axi_awvalid,
    input  wire        m01_axi_awready,
    
    output wire [31:0] m01_axi_wdata,
    output wire [3:0]  m01_axi_wstrb,
    output wire        m01_axi_wvalid,
    input  wire        m01_axi_wready,
    
    input  wire [1:0]  m01_axi_bresp,
    input  wire        m01_axi_bvalid,
    output wire        m01_axi_bready,
    
    output wire [31:0] m01_axi_araddr,
    output wire        m01_axi_arvalid,
    input  wire        m01_axi_arready,
    
    input  wire [31:0] m01_axi_rdata,
    input  wire [1:0]  m01_axi_rresp,
    input  wire        m01_axi_rvalid,
    output wire        m01_axi_rready
);
    
    wire is_write_for_pim = (s_axi_awaddr >= 32'h0000_2000); 
    wire is_read_for_pim  = (s_axi_araddr >= 32'h0000_2000);

    reg write_target_pim; // 0: BRAM, 1: PIM
    reg read_target_pim; 

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            write_target_pim <= 1'b0;
            read_target_pim  <= 1'b0;
        end else begin
            if (s_axi_awvalid && s_axi_awready) 
                write_target_pim <= is_write_for_pim;

            if (s_axi_arvalid && s_axi_arready) 
                read_target_pim <= is_read_for_pim;
        end
    end

    assign m00_axi_awvalid = s_axi_awvalid && (!is_write_for_pim);
    assign m01_axi_awvalid = s_axi_awvalid && (is_write_for_pim);
    
    assign m00_axi_awaddr  = s_axi_awaddr;
    assign m01_axi_awaddr  = s_axi_awaddr;

    always @(*) begin
        if (is_write_for_pim) s_axi_awready = m01_axi_awready;
        else                  s_axi_awready = m00_axi_awready;
    end

    assign m00_axi_wvalid = s_axi_wvalid && (!is_write_for_pim);
    assign m01_axi_wvalid = s_axi_wvalid && (is_write_for_pim);
    
    assign m00_axi_wdata  = s_axi_wdata;
    assign m01_axi_wdata  = s_axi_wdata;
    assign m00_axi_wstrb  = s_axi_wstrb;
    assign m01_axi_wstrb  = s_axi_wstrb;

    always @(*) begin
        if (is_write_for_pim) s_axi_wready = m01_axi_wready;
        else                  s_axi_wready = m00_axi_wready;
    end

    assign m00_axi_bready = s_axi_bready && (!write_target_pim);
    assign m01_axi_bready = s_axi_bready && (write_target_pim);

    always @(*) begin
        if (write_target_pim) begin
            s_axi_bvalid = m01_axi_bvalid;
            s_axi_bresp  = m01_axi_bresp;
        end else begin
            s_axi_bvalid = m00_axi_bvalid;
            s_axi_bresp  = m00_axi_bresp;
        end
    end

    assign m00_axi_arvalid = s_axi_arvalid && (!is_read_for_pim);
    assign m01_axi_arvalid = s_axi_arvalid && (is_read_for_pim);
    
    assign m00_axi_araddr  = s_axi_araddr;
    assign m01_axi_araddr  = s_axi_araddr;

    always @(*) begin
        if (is_read_for_pim) s_axi_arready = m01_axi_arready;
        else                 s_axi_arready = m00_axi_arready;
    end

    assign m00_axi_rready = s_axi_rready && (!read_target_pim);
    assign m01_axi_rready = s_axi_rready && (read_target_pim);

    always @(*) begin
        if (read_target_pim) begin
            s_axi_rvalid = m01_axi_rvalid;
            s_axi_rdata  = m01_axi_rdata;
            s_axi_rresp  = m01_axi_rresp;
        end else begin
            s_axi_rvalid = m00_axi_rvalid;
            s_axi_rdata  = m00_axi_rdata;
            s_axi_rresp  = m00_axi_rresp;
        end
    end

endmodule