`timescale 1ns / 1ps

module adressdecoder(
    input [31:0] address,

    output DataMemSelect,
    output LEDSelect,
    output SwitchSelect
);

assign DataMemSelect = (address[9:8] == 2'b00);
assign LEDSelect     = (address[9:8] == 2'b01);
assign SwitchSelect  = (address[9:8] == 2'b10);

endmodule