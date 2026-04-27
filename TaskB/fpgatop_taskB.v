`timescale 1ns / 1ps

module fpgatop_taskB(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] sw,
    output wire [6:0] seg,
    output wire [3:0] an
);

    // =========================
    // CLOCK DIVIDER (slow CPU)
    // =========================
    reg [27:0] counter = 0;
    reg slow_clk = 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter  <= 0;
            slow_clk <= 0;
        end else begin
            if (counter == 28'd100_000_000) begin
                counter  <= 0;
                slow_clk <= ~slow_clk;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // =========================
    // CPU
    // =========================
    wire [15:0] leds_unused;

    TopLevelProcessor #(
        .MEMFILE("temp_warning_test.mem")
    ) cpu (
        .clk(slow_clk),
        .rst(rst),
        .sw(sw),
        .leds(leds_unused)
    );

    // =========================
    // TAP INTERNAL SIGNALS
    // =========================
    wire [4:0]  rd       = cpu.rd;
    wire [31:0] wdata    = cpu.WriteData;
    wire        regwrite = cpu.RegWrite;
    wire        lui      = cpu.Lui;

    // =========================
    // LIVE DISPLAY STORAGE
    // =========================
    reg [3:0] reg_tens;
    reg [3:0] reg_ones;
    reg [7:0] reg_val_disp;
    
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            reg_tens     <= 4'd0;
            reg_ones     <= 4'd0;
            reg_val_disp <= 8'h00;
        end 
        else if (regwrite && rd != 5'd0) begin
            reg_tens <= rd / 10;
            reg_ones <= rd % 10;
    
            if (lui)
                reg_val_disp <= wdata[31:24];
            else
                reg_val_disp <= wdata[7:0];
        end
    end
    
    // =========================
    // PACK INTO 4 DIGITS
    // =========================
    wire [15:0] display_data;

    assign display_data = {
        reg_tens,             // leftmost digit
        reg_ones,             // next digit
        reg_val_disp[7:4],    // value high nibble
        reg_val_disp[3:0]     // value low nibble
    };

    // =========================
    // 7-SEG DRIVER
    // =========================
    seven_seg ssd (
        .clk(clk),
        .data(display_data),
        .seg(seg),
        .an(an)
    );

endmodule