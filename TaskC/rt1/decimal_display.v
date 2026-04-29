module decimal_display(
    input  [15:0] cpu_out,
    output [15:0] display_data
);

        //split into 2 parts
    wire [3:0] i_val = cpu_out[15:12]; //val of factorial
    wire [11:0] fact = cpu_out[11:0]; //reuslt of it
    
    //brwaking it, 120 becomes 1 2 0
    wire [3:0] hundreds = fact / 100;
    wire [3:0] tens     = (fact % 100) / 10;
    wire [3:0] ones     = fact % 10;

    //join them phir to show 
    assign display_data = {
        i_val,
        hundreds,
        tens,
        ones
    };

endmodule