`timescale 1ns / 1ps

module pim_slave (
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
    
    output reg [31:0] bram_addr, 
    output reg        bram_en, 
    input  wire [31:0] bram_rddata
);

    reg [31:0] slv_reg0_ctrl; 
    reg [31:0] slv_reg1_status; 
    reg [31:0] slv_reg2_result;
    reg write_accept;

    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            write_accept <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            s_axi_bresp   <= 2'b00; 
        end else begin
            if (s_axi_awvalid && s_axi_wvalid && !s_axi_awready && !s_axi_wready) begin
                s_axi_awready <= 1'b1;
                s_axi_wready  <= 1'b1; 
                write_accept  <= 1'b1;

                case (s_axi_awaddr[7:0])
                    8'h00: slv_reg0_ctrl <= s_axi_wdata; 
                endcase
            end 
            else begin
                s_axi_awready <= 1'b0;
                s_axi_wready  <= 1'b0;
                write_accept <= 1'b0;
            end
            
            if (write_accept && !s_axi_bvalid) begin
                s_axi_bvalid <= 1'b1;
            end
            else if (s_axi_bready && s_axi_bvalid) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    always @(posedge aclk) begin
        if (!aresetn) begin
            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rresp   <= 2'b00;
            s_axi_rdata   <= 32'd0;
        end else begin
            if (s_axi_arvalid && !s_axi_arready) begin
                s_axi_arready <= 1'b1;
                s_axi_rvalid  <= 1'b1;
                
                case (s_axi_araddr[7:0])
                    8'h00: s_axi_rdata <= slv_reg0_ctrl;
                    8'h10: s_axi_rdata <= slv_reg1_status;
                    8'h20: s_axi_rdata <= slv_reg2_result; 
                    default: s_axi_rdata <= 32'd0;
                endcase
            end 
            else begin
                s_axi_arready <= 1'b0;
            end

            if (s_axi_rready && s_axi_rvalid) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

    parameter IDLE     = 3'd0;
    parameter READ_MEM = 3'd1; 
    parameter CALC     = 3'd2;
    parameter  READ_2    = 3'd3;
    parameter CALC2    = 3'd4;
    parameter DONE     = 3'd5;

    reg [2:0]  state;
    reg [31:0] calc_sum;      
    reg [31:0] data_count;
    reg [31:0] mac_res;
    reg [31:0] mac_reg;
always @(posedge aclk) begin
        if (!aresetn) begin
            state <= IDLE;
            slv_reg1_status <= 32'd0; 
            slv_reg2_result <= 32'd0;
            bram_addr <= 32'd0;
            bram_en   <= 1'b1;
            calc_sum  <= 32'd0;
            data_count <= 32'd0;
            mac_res <= 32'd0;
            mac_reg <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (slv_reg0_ctrl == 32'd1 || slv_reg0_ctrl == 32'd2 || slv_reg0_ctrl == 32'd3) begin
                        state <= READ_MEM;
                        slv_reg1_status <= 32'd1;
                        bram_addr <= 32'd0;
                        calc_sum <= 32'd0;
                        data_count <= 32'd0;
                        mac_res <= 32'd0;
                        mac_reg <= 32'd0;
                    end
                end
                READ_MEM: begin
                    state <= CALC;
                end
                CALC: begin
                if(slv_reg0_ctrl == 32'd1 || slv_reg0_ctrl == 32'd2) begin
                    calc_sum <= calc_sum + bram_rddata; 
                    
                    data_count <= data_count + 1;
                    if (data_count == 32'd9) begin
                        state <= DONE;
                    end 
                    else begin
                        bram_addr <= bram_addr + 32'd4; 
                        state <= READ_MEM;
                    end
                end
                else if(slv_reg0_ctrl == 32'd3)begin
                    mac_reg <= bram_rddata;
                    bram_addr <= bram_addr + 32'd4;
                    state <= READ_2;
                end    
                end
                READ_2 : begin
                    state <= CALC2;
                end
                CALC2 : begin
                    mac_res <= mac_res + (mac_reg*bram_rddata);
                    data_count <= data_count +1;
                    if (data_count == 32'd49) begin
                        state <= DONE;
                    end 
                    else begin
                        bram_addr <= bram_addr + 32'd4;
                        state <= READ_MEM; 
                    end
                end
                DONE: begin
                    if (slv_reg0_ctrl == 32'd1) begin
                        slv_reg2_result <= calc_sum;  
                    end
                    else if (slv_reg0_ctrl == 32'd2) begin
                        slv_reg2_result <= calc_sum / 10;
                    end
                    else if (slv_reg0_ctrl == 32'd3)begin
                        slv_reg2_result <= mac_res;
                    end
                    slv_reg1_status <= 32'd2;                  
                    if (slv_reg0_ctrl == 32'd0) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule