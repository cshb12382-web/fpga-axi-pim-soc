`timescale 1ns / 1ps

module control(
    input clk,
    input rst,

    input [15:0] ir_in,    
    input zero_flag,   
    
    input [15:0] ac_in,
    input e_in,
    input [15:0] dr_in,

    input wait_sig,      
    output wire mem_req, 

    output reg [2:0] bus_sel,
    output reg [3:0] alu_op,
    output reg ld_pc, inc_pc, clr_pc,
    output reg ld_ar, inc_ar, clr_ar,
    output reg ld_ir,
    output reg ld_dr, inc_dr, clr_dr,
    output reg ld_ac, clr_ac,
    output reg mem_write,   
    
    output reg halt_sig
    );

    reg [3:0] sc;  
    reg sc_clr;
    reg s;

    wire [2:0] opcode = ir_in[14:12];
    wire indirect = ir_in[15]; 

    parameter AND = 3'b000;
    parameter ADD = 3'b001;
    parameter LDA = 3'b010;
    parameter STA = 3'b011;
    parameter BUN = 3'b100;
    parameter BSA = 3'b101;
    parameter ISZ = 3'b110;

    assign mem_req = (bus_sel == 3'b110) || (mem_write == 1'b1);

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            sc <= 0;
            s <= 1;
        end
        else begin
            if(s==1) begin
                if(halt_sig==1)
                    s <= 0;
                else if(wait_sig == 1'b1) begin
                    sc <= sc;
                end
                else if(sc_clr==1) begin
                    sc <= 0;
                end
                else begin
                    sc <= sc + 1;
                end
            end 
        end
    end

    always @(*) begin
        bus_sel = 3'b000;
        alu_op  = 4'd0;
        ld_pc = 0; inc_pc = 0; clr_pc = 0;
        ld_ar = 0; inc_ar = 0; clr_ar = 0;
        ld_ir = 0;
        ld_dr = 0; inc_dr = 0; clr_dr = 0;
        ld_ac = 0; clr_ac = 0;
        mem_write = 0;
        sc_clr=0;
        halt_sig=0;

        case(sc)
            4'd0: begin // T0: AR <- PC
                bus_sel = 3'b010; 
                ld_ar   = 1;  
            end

            4'd1: begin // T1: IR <- M[AR], PC <- PC + 1
                bus_sel = 3'b110; 

                if (wait_sig == 1'b0) begin
                    ld_ir  = 1; 
                    inc_pc = 1;  
                end
                else begin
                    ld_ir  = 0;  
                    inc_pc = 0;  
                end
            end

            4'd2: begin // T2: Decode
                bus_sel = 3'b011; // Bus = IR
                ld_ar   = 1;
            end

            4'd3: begin // T3: Indirect or Execute
                if(opcode == 3'b111 && indirect ==0)begin
                    if (ir_in[11:5] != 0) begin
                        alu_op = 4'h7; 
                        ld_ac  = 1;    
                    end
                    if ((ir_in[11:0] ==  12'h010) && (ac_in[15] == 0)) inc_pc = 1;
                    if (ir_in[11:0] == 12'h008 && (ac_in[15] == 1)) inc_pc = 1;
                    if (ir_in[11:0] == 12'h004 && (ac_in == 16'b0)) inc_pc = 1;
                    if (ir_in[11:0]==12'h002 && (e_in == 0)) inc_pc = 1;
                    
                    if (ir_in[11:0]==12'h001) begin
                        ld_dr = 1;
                        bus_sel = 3'b101;
                    end
                    // HLT
                    if (ir_in[11:0]==12'h000) begin
                        halt_sig =1;
                    end
                    sc_clr = 1; 
                end
                else begin
                    if(indirect==1)begin
                        bus_sel = 3'b110; 
                        if (wait_sig == 0) ld_ar = 1; 
                        else               ld_ar = 0;
                    end
                end
            end

            4'd4: begin // T4
                case(opcode)
                    AND : begin
                        bus_sel = 3'b110; 
                        if (wait_sig == 1'b0) begin
                            ld_dr = 1;
                        end
                        else begin
                            ld_dr = 0;
                        end
                    end
                    ADD: begin
                        bus_sel = 3'b110;
                        if (wait_sig == 1'b0) begin
                            ld_dr = 1;
                        end
                        else begin
                            ld_dr = 0;
                        end
                    end
                    LDA: begin
                        bus_sel = 3'b110; 
                        if (wait_sig == 1'b0) begin
                            ld_dr = 1;
                        end
                        else begin
                            ld_dr = 0;
                        end
                    end
                    STA : begin
                        bus_sel = 3'b101; 
                        mem_write=1;
                        if (wait_sig == 1'b0) begin
                            sc_clr = 1;
                        end
                        else begin
                            sc_clr = 0;
                        end
                    end
                    BUN : begin
                        bus_sel = 3'b001;
                        ld_pc=1;
                        sc_clr=1;
                    end
                    BSA : begin
                        bus_sel = 3'b010;
                        mem_write=1;   
                        inc_ar=1;
                    end
                    ISZ : begin
                        bus_sel = 3'b110; 
                        if (wait_sig == 1'b0) begin
                            ld_dr = 1;
                        end
                        else begin
                            ld_dr = 0;
                        end
                    end
                    default : begin end
                endcase
            end

            4'd5 : begin // T5
                case(opcode)
                    AND : begin alu_op = 4'h0; ld_ac=1; sc_clr=1; end
                    ADD : begin alu_op = 4'h1; ld_ac=1; sc_clr=1; end
                    LDA : begin alu_op = 4'h2; ld_ac=1; sc_clr=1; end
                    BSA : begin
                        bus_sel = 3'b001;
                        ld_pc=1;
                        sc_clr=1;
                    end
                    ISZ : begin inc_dr=1; end
                    default : begin end
                endcase
            end

            4'd6 : begin // T6
                case(opcode)
                    ISZ : begin
                        bus_sel = 3'b100; 
                        mem_write=1;   
                        if(wait_sig == 1'b0) begin
                            if(dr_in == 0) inc_pc = 1;
                            sc_clr = 1;
                        end
                        else begin
                            inc_pc = 0;
                            sc_clr = 0;
                        end
                    end
                    default : begin end
                endcase
            end
            default : begin end
        endcase
    end
endmodule



/*`timescale 1ns / 1ps

module control(
    input clk,
    input rst,

    input [15:0] ir_in,      // 현재 명령어 (IR)
    input zero_flag,         // AC가 0인가? (Skip용)
    
    input [15:0] ac_in,
    input e_in,
    input [15:0] dr_in,


    output reg [2:0] bus_sel,
    output reg [3:0] alu_op,
    output reg ld_pc, inc_pc, clr_pc,
    output reg ld_ar, inc_ar, clr_ar,
    output reg ld_ir,
    output reg ld_dr, inc_dr, clr_dr,
    output reg ld_ac, clr_ac,
    output reg mem_write,     // 메모리 쓰기 신호
    
    output reg halt_sig
    );

    // --- 내부 신호 ---
    reg [3:0] sc;    // Sequence Counter (0~15) : T0, T1, T2... 시간 담당
    reg sc_clr;
    
    reg s;
    
    // 명령어 해석 (Decode)
    wire [2:0] opcode = ir_in[14:12]; // Opcode (3비트)
    wire indirect = ir_in[15];    // I 비트 (15번)

    // Opcode를 읽기 쉽게 정의 (파라미터)
    parameter AND = 3'b000;
    parameter ADD = 3'b001;
    parameter LDA = 3'b010;
    parameter STA = 3'b011;
    parameter BUN = 3'b100;
    parameter BSA = 3'b101;
    parameter ISZ = 3'b110;

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            sc <= 0;
            s<=1;
        end
        else begin
            if(s==1) begin
                if(halt_sig==1)
                    s<=0;
                else if(sc_clr==1)begin
                    sc<=0;
                end
                else begin
                    sc <= sc + 1;
                end
            end 
        end
    end


    always @(*) begin
        // [기본값 설정] (Latch 방지: 모든 신호를 일단 0으로 둠)
        bus_sel = 3'b000;
        alu_op  = 4'd0;
        ld_pc = 0; inc_pc = 0; clr_pc = 0;
        ld_ar = 0; inc_ar = 0; clr_ar = 0;
        ld_ir = 0;
        ld_dr = 0; inc_dr = 0; clr_dr = 0;
        ld_ac = 0; clr_ac = 0;
        mem_write = 0;
        sc_clr=0;
        halt_sig=0;


        case(sc)
            4'd0: begin // T0: AR <- PC
                bus_sel = 3'b010; // Bus = PC
                ld_ar   = 1;      // AR Load
            end

            4'd1: begin // T1: IR <- M[AR], PC <- PC + 1
                bus_sel = 3'b110; // Bus = Memory
                ld_ir   = 1;      // IR Load
                inc_pc  = 1;      // PC Increment
            end

            4'd2: begin // T2: Decode (Opcode 확인 & AR <- IR[11:0])
                bus_sel = 3'b011; // Bus = IR (하위 12비트)
                ld_ar   = 1;
            end

            4'd3: begin
                if(opcode == 3'b111 && indirect ==0)begin
                    if (ir_in[11:5] != 0) begin
                        alu_op = 4'h7; // ALU에게 "레지스터 연산해!" 지시
                        ld_ac  = 1;    // 결과 저장
                    end
            // SPA (Skip if Positive): AC[15]가 0이면 양수
                    if ((ir_in[11:0] ==  12'h010) && (ac_in[15] == 0)) begin
                        inc_pc = 1;
                    end          
            // SNA (Skip if Negative): AC[15]가 1이면 음수
                    if (ir_in[11:0] == 12'h008 && (ac_in[15] == 1)) begin
                        inc_pc = 1;
                    end           
            // SZA (Skip if Zero): AC가 0이면
                    if (ir_in[11:0] == 12'h004 && (ac_in == 16'b0)) begin
                        inc_pc = 1;
                    end     
            // SZE (Skip if Zero E): E가 0이면
                    if (ir_in[11:0]==12'h002 && (e_in == 0)) begin
                        inc_pc = 1;
                    end
                    if (ir_in[11:0]==12'h001) begin
                        ld_dr = 1;
                        bus_sel = 3'b101;
                    end
            // C. HLT (Halt) - IR[0]
                    if (ir_in[11:0]==12'h000) begin
                        halt_sig =1;
                    end

            // 명령 종료 -> SC 초기화 신호 발생
                     sc_clr = 1;
                end
                else begin
                    if(indirect==1)begin
                        bus_sel = 3'b110;
                        ld_ar = 1;
                    end
                    else begin
                    end
                end
            end
            4'd4: begin
                case(opcode)
                    AND : begin
                        bus_sel = 3'b110;
                        ld_dr=1;
                    end
                    ADD: begin
                        bus_sel = 3'b110;
                        ld_dr=1;
                    end
                    LDA: begin
                        bus_sel = 3'b110;
                        ld_dr=1;
                    end
                    STA : begin
                        bus_sel = 3'b101;
                        mem_write=1;
                        sc_clr=1;
                    end
                    BUN : begin
                        bus_sel = 3'b001;
                        ld_pc=1;
                        sc_clr=1;
                    end
                    BSA : begin
                        bus_sel = 3'b010;
                        mem_write=1;
                        inc_ar=1;
                    end
                    ISZ : begin
                        bus_sel = 3'b110;
                        ld_dr=1;
                    end  */
                  /*  SUB : begin
                        bus_sel = 3'b110;
                        ld_dr=1;
                    end */
     /*               default : begin
                    end
                endcase
            end
            4'd5 : begin
                case(opcode)
                    AND : begin
                        alu_op = 4'h0;
                        ld_ac=1;
                        sc_clr=1;
                    end
                    ADD : begin
                        alu_op = 4'h1;
                        ld_ac=1;
                        sc_clr=1;
                    end
                    LDA : begin
                        alu_op = 4'h2;
                        ld_ac=1;
                        sc_clr=1;
                    end
                    BSA : begin
                        bus_sel = 3'b001;
                        ld_pc=1;
                        sc_clr=1;
                    end
                    ISZ : begin
                        inc_dr=1;
                    end   */
                /*    SUB : begin
                        alu_op = 4'h15;
                        ld_ac=1;
                        sc_clr=1;
                    end  */
 /*                   default : begin
                    end
               endcase
            end
            4'd6 : begin
                case(opcode)
                    ISZ : begin
                        bus_sel = 3'b100;
                        mem_write=1;
                        if(dr_in == 0)
                            inc_pc=1;
                        sc_clr=1;
                    end
                    default : begin
                    end
                endcase
            end
        default : begin
        end
        endcase
    end
endmodule */