`timescale 1ns / 1ps

module FPGA(
    input clk,
    input rst,
    output [3:0] ssd_anode,
    output [6:0] ssd_seg,
    output reg [3:0] led,
    
    input rx,
    input [1:0]btn,
    output tx
    );
   
    wire [15:0] w_cpu_ac;  
    wire w_cpu_halt;      
    wire [3:0]hex_value;
    
    reg run;
    reg [11:0] uart_mem_addr;
    reg [15:0] shift_reg;
    reg [1:0] nibble_cnt;
    reg uart_we;
    wire cpu_rst = rst&run;
    wire w_ov_out;

    cpu u_cpu (
        .clk(clk),
        .rst(cpu_rst),
        .w_ac_out(w_cpu_ac),    
        .w_halt_out(w_cpu_halt),
        .w_ov_out(w_ov_out),
        .uart_addr(uart_mem_addr),
        .uart_data(shift_reg),
        .uart_we(uart_we)
    );
    wire btn_addr;
    wire btn_run;
    
    btn_unit btn0(.clk(clk),.rst(rst),.btn(btn),.btn_addr(btn_addr),.btn_run(btn_run));
   
    reg btn_addr_prev;
    reg btn_run_prev;
    wire btn_addr_pulse;
    wire btn_run_pulse;
    
    reg btn_addr_sync0;
    reg btn_run_sync0;
    reg [2:0] mode;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
           btn_addr_prev <= 0;
           btn_run_prev <=0;
           btn_addr_sync0 <= 0;
           btn_run_sync0 <=0;
        end
        else begin
        btn_addr_sync0 <= btn_addr;
        btn_run_sync0 <= btn_run;
        
        btn_addr_prev <= btn_addr_sync0;
        btn_run_prev <= btn_run_sync0;
        end
    end

    assign btn_addr_pulse = (btn_addr_sync0 == 1) && (btn_addr_prev == 0);
    assign btn_run_pulse  = (btn_run_sync0 == 1)  && (btn_run_prev == 0);
    wire w_valid;


    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            uart_mem_addr <= 12'd200;
            shift_reg <=0;
            nibble_cnt <=0;
            uart_we<=0;
            led<=4'b1111;
            mode <= 3'b001;
        end 
        else begin
            uart_we <= 0;
            if(run == 0) begin
                if(w_valid) begin
                    shift_reg <= {shift_reg[11:0], hex_value}; // 밀어넣기
                    nibble_cnt <= nibble_cnt + 1;
                    if(nibble_cnt == 2'd3) begin
                        uart_we <= 1;
                    end
                end
                if(btn_addr_pulse) begin
                    if(uart_mem_addr==12'd200)begin
                        mode <= shift_reg[2:0];
                     end
                     
                    uart_mem_addr <= uart_mem_addr + 2;
                    shift_reg <= 0;
                    nibble_cnt <= 0;
                    led<=led-1;
                    
                end
            end
            else begin
                if(w_ov_out==1)
                    led<=4'b0101;
                else if(mode == 3'd1)
                    led <= 4'b0111;
                else if(mode == 3'd2)
                    led <= 4'b1011;
                else if(mode == 3'd3)
                    led <= 4'b1101;
                else if(mode == 3'd4)
                    led <= 4'b1110;
                else if(mode == 3'd5)
                    led <= 4'b1100;
                else if(mode == 3'd6)
                    led <= 4'b1010;
                else
                    led<=4'b1111;
            end
        end
    end   
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            run <= 1;
        else if(btn_run_pulse)
            run <= ~run;
    end

    wire w_ready;

wire [7:0] w_dout;

    uart_wrap wrap0(
    .clk(clk),
    .reset(!rst),
    .DataIn(w_dout),
    .DataIn_valid(w_valid),
    .DataIn_ready(w_ready),
    .DataOut(w_dout),
    .DataOut_valid(w_valid),
    .DataOut_ready(w_ready),
    .uart_rx(rx),
    .uart_tx(tx) 
);

ascii_to_hex hex0 (
    .ascii_code(w_dout),
    .hex_value(hex_value)   
);


    reg [15:0] display_number;
    reg stop_flag; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            stop_flag <= 0;
        end 
        else if (w_cpu_halt) 
            stop_flag <= 1;
    end
   /* always @ (*)begin        // 깃발이 안 들려있을 때만 값 업데이트 (멈추면 업데이트 안 함 = 고정)
        if(run == 0) begin
            display_number = shift_reg; // 내가 치고 있는 값 보여주기
        end 
        else begin
            if (stop_flag) display_number = w_cpu_ac; // 멈췄으면 그 값 고정
            else display_number = w_cpu_ac;           // 실행 중엔 AC 값 실시간 출력
        end
    end*/
    always @(posedge clk or negedge rst) begin
    if(!rst)
        display_number <= 16'h0000;
    else if(run == 0)
        display_number <= shift_reg;
    else
        display_number <= w_cpu_ac;
    end

    io u_ssd (
        .clk(clk),
        .rst(rst),
        .number_in(display_number),
        .anode(ssd_anode),
        .seg(ssd_seg)
    );
    ila_0 your_ila (
    .clk(clk), //
    .probe0(u_cpu.u_axi_master.m_axi_araddr), 
    .probe1(u_cpu.u_axi_master.m_axi_arvalid),
    .probe2(u_cpu.u_axi_master.m_axi_arready),
    .probe3(u_cpu.u_control.sc),
    .probe4(w_cpu_ac),
    .probe5(u_cpu.u_axi_master.m_axi_awvalid),
    .probe6(u_cpu.u_axi_master.m_axi_wvalid),
    .probe7(u_cpu.u_axi_master.m_axi_awready),
    .probe8(u_cpu.u_axi_master.m_axi_wready),
    .probe9(u_cpu.u_axi_master.m_axi_bvalid),
    .probe10(u_cpu.u_pim_slave.write_accept),
    .probe11(u_cpu.u_axi_master.m_axi_wdata),
    .probe12(u_cpu.u_axi_master.m_axi_rdata),
    .probe13(u_cpu.u_axi_master.m_axi_awaddr)
);

endmodule 