`timescale 1ns / 1ps

module freq_div_100(      
    input clk_ref,    
    input rst,       
    output reg clk_div     
    );

    reg [5:0] cnt;   

    always @ (posedge clk_ref or posedge rst)    
    begin
        if(rst)                                  
        begin                                       
            cnt <= 6'd0;                         
            clk_div <= 1'd0;                 
        end
        else                        
        begin
            if(cnt == 6'd49)             
            begin
                cnt <= 6'd0;              
                clk_div <= ~clk_div;      
            end
            else                            
            begin
                cnt <= cnt + 1'b1;             
            end
        end
    end
    
endmodule