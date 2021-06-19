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

localparam SPAM_MODE = 1'b1;

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

if (SPAM_MODE == 1) begin // spaming with data all the time
    assign wr_n = rst;

    logic [DATA_W-1:0] data_cnt;
    always_ff @(posedge clk) begin
        if (rst) begin
            data_cnt <= 0;
        end else begin
            data_cnt <= data_cnt + 1;
        end
    end
    assign data = {data_cnt[DATA_W-1:1], 1'b1};

end else begin // transfer the data with respect to TXEn
    logic wr_drv;
    always_ff @(posedge clk) begin
        if (rst) begin
            wr_drv <= 1;
        end else begin
            wr_drv <= txe_n;
        end
    end
    assign wr_n = wr_drv;

    logic [DATA_W-1:0] data_cnt;
    always_ff @(posedge clk) begin
        if (rst) begin
            data_cnt <= 0;
        end else if (!wr_drv) begin
            data_cnt <= data_cnt + 1;
        end
    end
    assign data = data_cnt;
end

logic [25:0] led1_cnt;
always_ff @(posedge clk) begin
    if (rst) begin
        led1_cnt <= '0;
    end else begin
        led1_cnt <= led1_cnt + 1'b1;
    end
end

assign led1 = led1_cnt[25];



assign led2 = SPAM_MODE;
assign led3 = ~SPAM_MODE;

endmodule
