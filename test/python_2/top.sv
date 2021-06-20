module top #(
    parameter DATA_W = 8,
    parameter BE_W = 2
)(
    input              clk,
    inout [DATA_W-1:0] data,
    output             oe_n,
    output             rd_n,
    output             wr_n,
    input              rxf_n,
    input              txe_n,
    inout  [BE_W-1:0]  be,
    output             led1,
    output             led2,
    output             led3
);

localparam BURST_SIZE  = 2048;
localparam SLLEP_TICKS = 65536;

// Synchronous active high reset
logic [5:0] reset_cnt = 0;
logic rst = 1;
always_ff @(posedge clk) begin
    if (reset_cnt < '1) begin
        rst       <= 1;
        reset_cnt <= reset_cnt + 1;
    end else begin
        rst       <= 0;
    end
end

assign oe_n = 1'b1;
assign rd_n = 1'b1;
assign be = {BE_W{~wr_n}};

tx_fsm #(
    .DATA_W      (DATA_W),
    .BURST_SIZE  (BURST_SIZE),
    .SLLEP_TICKS (SLLEP_TICKS)
) fsm (
    .clk    (clk),
    .rst    (rst),
    .txen   (txe_n),
    .wrn    (wr_n),
    .data   (data)
);

logic [25:0] led1_cnt;
always_ff @(posedge clk) begin
    if (rst) begin
        led1_cnt <= '0;
    end else begin
        led1_cnt <= led1_cnt + 1'b1;
    end
end

assign led1 = led1_cnt[25];
assign led2 = ~txe_n;
assign led3 = ~wr_n;

endmodule
