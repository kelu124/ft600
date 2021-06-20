module tx_fsm #(
    parameter DATA_W      = 8,
    parameter BURST_SIZE  = 256,
    parameter SLLEP_TICKS = 65536
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              txen,
    output logic              wrn,
    output logic [DATA_W-1:0] data
);

enum {
    WAIT_TXE_S,
    SEND_CYCLE_S,
    SEND_WORD_S,
    SLEEP_S
} fsm_state, fsm_next;

logic wrn_next;
logic [DATA_W-1:0] data_next;
logic [$clog2(BURST_SIZE)-1:0] burst_word_cnt, burst_word_cnt_next;
logic [DATA_W-1:0] burst_cycle_cnt, burst_cycle_cnt_next;
logic [$clog2(SLLEP_TICKS)-1:0] sleep_cnt, sleep_cnt_next;

always_comb begin
    wrn_next             = wrn;
    data_next            = data;
    burst_word_cnt_next  = burst_word_cnt;
    burst_cycle_cnt_next = burst_cycle_cnt;
    sleep_cnt_next       = sleep_cnt;
    fsm_next             = fsm_state;

    case (fsm_state)
        WAIT_TXE_S: begin
            if (!txen) begin // fifo is not full
                fsm_next = SEND_CYCLE_S;
            end
        end

        SEND_CYCLE_S: begin
            wrn_next             = 1'b0;
            data_next            = burst_cycle_cnt;
            burst_cycle_cnt_next = (burst_cycle_cnt == '1) ? 1 : burst_cycle_cnt + 1'b1;
            fsm_next             = SEND_WORD_S;
        end

        SEND_WORD_S: begin
            wrn_next = 1'b0;
            data_next = {burst_word_cnt[DATA_W-1:1], 1'b1};
            if (burst_word_cnt == (BURST_SIZE-1)) begin
                burst_word_cnt_next = '0;
                fsm_next            = SLEEP_S;
            end else begin
                burst_word_cnt_next = burst_word_cnt + 1'b1;
            end
        end

        SLEEP_S: begin
            wrn_next = 1'b1;
            if (sleep_cnt == (SLLEP_TICKS-1)) begin
                sleep_cnt_next = '0;
                fsm_next       = WAIT_TXE_S;
            end else begin
                sleep_cnt_next = sleep_cnt + 1'b1;
            end
        end
    endcase
end

always_ff @(posedge clk) begin
    if (rst) begin
        fsm_state       <= WAIT_TXE_S;
        burst_cycle_cnt <= 1;
        burst_word_cnt  <= '0;
        sleep_cnt       <= '0;
        data            <= '0;
        wrn             <= 1'b1;
    end else begin
        burst_cycle_cnt <= burst_cycle_cnt_next;
        burst_word_cnt  <= burst_word_cnt_next;
        sleep_cnt       <= sleep_cnt_next;
        data            <= data_next;
        wrn             <= wrn_next;
        fsm_state       <= fsm_next;
    end
end

endmodule
