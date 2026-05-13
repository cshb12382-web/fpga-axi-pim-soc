`timescale 1ns / 1ps

module axi_master(
    input clk,
    input rst, 
    input [11:0] cpu_addr,
    input [15:0] cpu_wdata,
    input cpu_we,
    input cpu_req,          
    output [15:0] cpu_rdata, 
    output mem_busy,

    output reg [31:0] m_axi_awaddr, output reg m_axi_awvalid, input m_axi_awready,
    output reg [31:0] m_axi_wdata, output reg [3:0] m_axi_wstrb, output reg m_axi_wvalid, input m_axi_wready,
    input [1:0] m_axi_bresp, input m_axi_bvalid, output reg m_axi_bready,
    output reg [31:0] m_axi_araddr, output reg m_axi_arvalid, input m_axi_arready,
    input [31:0] m_axi_rdata, input [1:0] m_axi_rresp, input m_axi_rvalid, output reg m_axi_rready
);

    parameter IDLE       = 3'd0;
    parameter WRITE_ADDR = 3'd1;
    parameter WRITE_RESP = 3'd3;
    parameter READ_ADDR  = 3'd4;
    parameter READ_DATA  = 3'd5;
    parameter WAIT_CPU   = 3'd6; 
    
    reg [2:0] state;
    reg [15:0] rdata_reg;

    assign cpu_rdata = rdata_reg;

    assign mem_busy = (!rst) ? 1'b1 : 
                      (state == WAIT_CPU) ? 1'b0 : 
                      (cpu_req || state != IDLE);   //axi에서 받아오는 동안 cpu 멈춤(rst,req) 그냥 idel, wait상태선 동작

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            state <= IDLE;
            rdata_reg <= 0;
            m_axi_awvalid <= 0; m_axi_wvalid <= 0; m_axi_bready <= 0;
            m_axi_arvalid <= 0; m_axi_rready <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    if(cpu_req) begin
                        if(cpu_we) begin
                            state <= WRITE_ADDR;
                            m_axi_awaddr <= {18'b0, cpu_addr, 2'b00}; m_axi_awvalid <= 1;
                            m_axi_wdata  <= {16'b0, cpu_wdata}; m_axi_wvalid <= 1;
                            m_axi_wstrb  <= 4'b0011; 
                            m_axi_bready <= 1;
                        end
                        else begin
                            state <= READ_ADDR;
                            m_axi_araddr <= {18'b0, cpu_addr, 2'b00}; 
                            m_axi_arvalid <= 1;
                            m_axi_rready <= 1;
                        end
                    end
                end
                
                WRITE_ADDR: begin
                    if(m_axi_awready) 
                        m_axi_awvalid <= 0;
                    if(m_axi_wready) 
                        m_axi_wvalid <= 0;
                    if((m_axi_awready || !m_axi_awvalid) && (m_axi_wready || !m_axi_wvalid))
                        state <= WRITE_RESP;
                end
                WRITE_RESP: begin
                    if(m_axi_bvalid) begin
                        m_axi_bready <= 0;
                        state <= WAIT_CPU;
                    end
                end

                READ_ADDR: begin
                    if(m_axi_arready) begin
                        m_axi_arvalid <= 0;
                        state <= READ_DATA;
                    end
                end
                READ_DATA: begin
                    if(m_axi_rvalid) begin
                        m_axi_rready <= 0;
                        rdata_reg <= m_axi_rdata[15:0]; 
                        state <= WAIT_CPU;
                    end
                end

                WAIT_CPU: begin
                    state <= IDLE; 
                end 

                default: state <= IDLE;
            endcase
        end
    end
endmodule