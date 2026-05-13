`timescale 1ns / 1ps

module cpu(
    input clk,
    input rst,
    
    output [15:0] w_ac_out,
    output w_halt_out,
    output w_ov_out,
    
    input [11:0] uart_addr,
    input [15:0] uart_data,
    input uart_we
    );

    wire [2:0] w_bus_sel;
    wire [3:0] w_alu_op;
    wire w_ld_pc, w_inc_pc, w_clr_pc;
    wire w_ld_ar, w_inc_ar, w_clr_ar;
    wire w_ld_ir;
    wire w_ld_dr, w_inc_dr, w_clr_dr;
    wire w_ld_ac, w_clr_ac;
    wire w_mem_write;

    wire [15:0] w_ir_out;
    wire [15:0] w_dr_out;
    wire w_e_out;
    
    wire [11:0] w_mem_addr;  
    wire [15:0] w_bus_data;  
    wire [15:0] w_mem_read_data; 
    
    wire w_mem_busy;
    wire w_mem_req;
    

    control u_control(
        .clk(clk),
        .rst(rst),
        .ir_in(w_ir_out),
        .zero_flag(w_ac_out == 16'b0), // AC가 0인지 체크
        .ac_in(w_ac_out),
        .e_in(w_e_out),
        .dr_in(w_dr_out),
        
        .wait_sig(w_mem_busy),
        .mem_req(w_mem_req), 
       
        .bus_sel(w_bus_sel),
        .alu_op(w_alu_op),
        .ld_pc(w_ld_pc), .inc_pc(w_inc_pc), .clr_pc(w_clr_pc),
        .ld_ar(w_ld_ar), .inc_ar(w_inc_ar), .clr_ar(w_clr_ar),
        .ld_ir(w_ld_ir),
        .ld_dr(w_ld_dr), .inc_dr(w_inc_dr), .clr_dr(w_clr_dr),
        .ld_ac(w_ld_ac), .clr_ac(w_clr_ac),
        .mem_write(w_mem_write),
        .halt_sig(w_halt_out)
    );

    register u_datapath(
        .clk(clk),
        .rst(rst),
        .bus_sel(w_bus_sel), 
        .alu_op(w_alu_op),  
        .ld_pc(w_ld_pc), .inc_pc(w_inc_pc), .clr_pc(w_clr_pc),
        .ld_ar(w_ld_ar), .inc_ar(w_inc_ar), .clr_ar(w_clr_ar),
        .ld_ir(w_ld_ir),
        .ld_dr(w_ld_dr), .inc_dr(w_inc_dr), .clr_dr(w_clr_dr),
        .ld_ac(w_ld_ac), .clr_ac(w_clr_ac),
        .mem_write(w_mem_write),
        .mem_in(w_mem_read_data), 
        .mem_addr(w_mem_addr),  
        .mem_out(w_bus_data),  
        .ir_out(w_ir_out),
        .ac_out(w_ac_out),
        .dr_out(w_dr_out),
        .e_out(w_e_out),
        .OV(w_ov_out)
    );
wire [31:0] axi_awaddr, axi_wdata, axi_araddr, axi_rdata;
    wire axi_awvalid, axi_awready, axi_wvalid, axi_wready;
    wire [1:0] axi_bresp, axi_rresp;
    wire axi_bvalid, axi_bready, axi_arvalid, axi_arready;
    wire axi_rvalid, axi_rready;
    wire [3:0] axi_wstrb;

    axi_master u_axi_master (
        .clk(clk), 
        .rst(rst),
        .cpu_addr(w_mem_addr),
        .cpu_wdata(w_bus_data),
        .cpu_we(w_mem_write),
        .cpu_req(w_mem_req),     // Control에서 오는 요청 신호
        .cpu_rdata(w_mem_read_data),
        .mem_busy(w_mem_busy),   // Control로 가는 대기 신호

        // AXI Master Ports
        .m_axi_awaddr(axi_awaddr), .m_axi_awvalid(axi_awvalid), .m_axi_awready(axi_awready),
        .m_axi_wdata(axi_wdata), .m_axi_wstrb(axi_wstrb), .m_axi_wvalid(axi_wvalid), .m_axi_wready(axi_wready),
        .m_axi_bresp(axi_bresp), .m_axi_bvalid(axi_bvalid), .m_axi_bready(axi_bready),
        .m_axi_araddr(axi_araddr), .m_axi_arvalid(axi_arvalid), .m_axi_arready(axi_arready),
        .m_axi_rdata(axi_rdata), .m_axi_rresp(axi_rresp), .m_axi_rvalid(axi_rvalid), .m_axi_rready(axi_rready)
    );
    
    
    wire bram_rst_a, bram_clk_a, bram_en_a;
    wire [3:0] bram_we_a;
    wire [14:0] bram_addr_a;
    wire [31:0] bram_wrdata_a, bram_rddata_a;

    wire [31:0] m00_axi_awaddr, m00_axi_wdata, m00_axi_araddr, m00_axi_rdata;
    wire m00_axi_awvalid, m00_axi_awready, m00_axi_wvalid, m00_axi_wready;
    wire [1:0]  m00_axi_bresp, m00_axi_rresp;
    wire m00_axi_bvalid, m00_axi_bready, m00_axi_arvalid, m00_axi_arready;
    wire m00_axi_rvalid, m00_axi_rready;
    wire [3:0]  m00_axi_wstrb;

    wire [31:0] m01_axi_awaddr, m01_axi_wdata, m01_axi_araddr, m01_axi_rdata;
    wire m01_axi_awvalid, m01_axi_awready, m01_axi_wvalid, m01_axi_wready;
    wire [1:0]  m01_axi_bresp, m01_axi_rresp;
    wire m01_axi_bvalid, m01_axi_bready, m01_axi_arvalid, m01_axi_arready;
    wire m01_axi_rvalid, m01_axi_rready;
    wire [3:0]  m01_axi_wstrb;

    interconnect u_interconnect (
        .aclk(clk), .aresetn(rst),
        .s_axi_awaddr(axi_awaddr), .s_axi_awvalid(axi_awvalid), .s_axi_awready(axi_awready),
        .s_axi_wdata(axi_wdata), .s_axi_wstrb(axi_wstrb), .s_axi_wvalid(axi_wvalid), .s_axi_wready(axi_wready),
        .s_axi_bresp(axi_bresp), .s_axi_bvalid(axi_bvalid), .s_axi_bready(axi_bready),
        .s_axi_araddr(axi_araddr), .s_axi_arvalid(axi_arvalid), .s_axi_arready(axi_arready),
        .s_axi_rdata(axi_rdata), .s_axi_rresp(axi_rresp), .s_axi_rvalid(axi_rvalid), .s_axi_rready(axi_rready),
        
        // M00_AXI (to BRAM 1)
        .m00_axi_awaddr(m00_axi_awaddr), .m00_axi_awvalid(m00_axi_awvalid), .m00_axi_awready(m00_axi_awready),
        .m00_axi_wdata(m00_axi_wdata), .m00_axi_wstrb(m00_axi_wstrb), .m00_axi_wvalid(m00_axi_wvalid), .m00_axi_wready(m00_axi_wready),
        .m00_axi_bresp(m00_axi_bresp), .m00_axi_bvalid(m00_axi_bvalid), .m00_axi_bready(m00_axi_bready),
        .m00_axi_araddr(m00_axi_araddr), .m00_axi_arvalid(m00_axi_arvalid), .m00_axi_arready(m00_axi_arready),
        .m00_axi_rdata(m00_axi_rdata), .m00_axi_rresp(m00_axi_rresp), .m00_axi_rvalid(m00_axi_rvalid), .m00_axi_rready(m00_axi_rready),
        
        // M01_AXI (to PIM Slave)
        .m01_axi_awaddr(m01_axi_awaddr), .m01_axi_awvalid(m01_axi_awvalid), .m01_axi_awready(m01_axi_awready),
        .m01_axi_wdata(m01_axi_wdata), .m01_axi_wstrb(m01_axi_wstrb), .m01_axi_wvalid(m01_axi_wvalid), .m01_axi_wready(m01_axi_wready),
        .m01_axi_bresp(m01_axi_bresp), .m01_axi_bvalid(m01_axi_bvalid), .m01_axi_bready(m01_axi_bready),
        .m01_axi_araddr(m01_axi_araddr), .m01_axi_arvalid(m01_axi_arvalid), .m01_axi_arready(m01_axi_arready),
        .m01_axi_rdata(m01_axi_rdata), .m01_axi_rresp(m01_axi_rresp), .m01_axi_rvalid(m01_axi_rvalid), .m01_axi_rready(m01_axi_rready)
    );

    axi_bram_ctrl_0 u_axi_ctrl (
        .s_axi_aclk(clk), 
        .s_axi_aresetn(rst),
        .s_axi_awaddr(m00_axi_awaddr[14:0]), 
        .s_axi_awprot(3'b000),          
        .s_axi_awvalid(m00_axi_awvalid), 
        .s_axi_awready(m00_axi_awready),
        .s_axi_wdata(m00_axi_wdata), 
        .s_axi_wstrb(m00_axi_wstrb), 
        .s_axi_wvalid(m00_axi_wvalid), 
        .s_axi_wready(m00_axi_wready),
        .s_axi_bresp(m00_axi_bresp), 
        .s_axi_bvalid(m00_axi_bvalid), 
        .s_axi_bready(m00_axi_bready),
        .s_axi_araddr(m00_axi_araddr[14:0]), 
        .s_axi_arprot(3'b000),            
        .s_axi_arvalid(m00_axi_arvalid), 
        .s_axi_arready(m00_axi_arready),
        .s_axi_rdata(m00_axi_rdata), 
        .s_axi_rresp(m00_axi_rresp), 
        .s_axi_rvalid(m00_axi_rvalid), 
        .s_axi_rready(m00_axi_rready),
        .bram_rst_a(bram_rst_a), 
        .bram_clk_a(bram_clk_a), 
        .bram_en_a(bram_en_a),
        .bram_we_a(bram_we_a), 
        .bram_addr_a(bram_addr_a), 
        .bram_wrdata_a(bram_wrdata_a), 
        .bram_rddata_a(bram_rddata_a)
    );

    wire [31:0] pim_bram_addr;
    wire        pim_bram_en;
    wire [31:0] pim_bram_rddata;

    pim_slave u_pim_slave (
        .aclk(clk), .aresetn(rst),
        .s_axi_awaddr(m01_axi_awaddr), .s_axi_awvalid(m01_axi_awvalid), .s_axi_awready(m01_axi_awready),
        .s_axi_wdata(m01_axi_wdata), .s_axi_wstrb(m01_axi_wstrb), .s_axi_wvalid(m01_axi_wvalid), .s_axi_wready(m01_axi_wready),
        .s_axi_bresp(m01_axi_bresp), .s_axi_bvalid(m01_axi_bvalid), .s_axi_bready(m01_axi_bready),
        .s_axi_araddr(m01_axi_araddr), .s_axi_arvalid(m01_axi_arvalid), .s_axi_arready(m01_axi_arready),
        .s_axi_rdata(m01_axi_rdata), .s_axi_rresp(m01_axi_rresp), .s_axi_rvalid(m01_axi_rvalid), .s_axi_rready(m01_axi_rready),
        
        .bram_addr(pim_bram_addr),
        .bram_en(pim_bram_en),
        .bram_rddata(pim_bram_rddata)
    );

    blk_mem_gen_1 u_pim_ram (
        .clka(clk),
        .wea(1'b0),             
        .addra(pim_bram_addr[14:2]),   
        .dina(32'd0),           
        .douta(pim_bram_rddata),

        .clkb(clk),
        .web(1'b0),
        .addrb(13'd0),
        .dinb(32'd0),
        .doutb()
    );
    
    
    
    blk_mem_gen_0 u_ram(
        .clka(bram_clk_a), 
        .wea(bram_we_a[0]),     
        
        .addra(bram_addr_a[14:2]), 
        
        .dina(bram_wrdata_a),
        .douta(bram_rddata_a),
        
        .clkb(~clk),
        .web(uart_we),
        .addrb({2'b00, uart_addr}),
        .dinb(uart_data),
        .doutb()   
    );

endmodule