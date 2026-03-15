`timescale 1ns / 1ps

module debouncer #(parameter N = 10,       
                   parameter K = 4)(
    input clk,                           
    input noisy,                 
    output debounced         
    );

    reg [K-1:0] cnt;                    
    always @ (posedge clk)            
    begin
        if(noisy)                  
        cnt <= cnt + 1'b1;          
        else                        
        cnt <= 0;                 
    end

    assign debounced = (cnt == N) ? 1'b1 : 1'b0; 

endmodule