module powertrigger
(
    input clock,
    input enable,
    input reset,
    input [31:0] sample,
    input [15:0] threshold,
    input [15:0] cooldown,
    input [31:0] skip,
    output reg trigger
);

// The I part of the I/Q sample.
wire[15:0] i = sample[31:16];

// The absolute value of I.
reg[15:0] abs_i;

// Tracks how many more cycles to cool down before entereing `LOOKING` state
// again, after triggering.
reg[15:0] cd_timer;

// Tracks how many clock cycles we skipped so far.
reg[15:0] skipped;

localparam SKIP = 0;
localparam LOOKING = 1;
localparam COOLDOWN = 2;

reg[1:0] state;


always @(posedge clock) begin

    if (reset) begin
        $strobe("RESET Powertrigger. threshold: %d, cooldown: %d, nb_skip: %d",
            threshold, cooldown, skip);

        trigger <= 0;
        abs_i <= 0;
        state <= SKIP;
        skipped <= 0;
        cd_timer <= 0;

    end else if (enable) begin

        case (state)

            SKIP: begin
                $strobe("SKIP: skipped: %d", skipped);
                if (skipped > skip) begin
                    state <= LOOKING;
                end
                else begin
                    skipped <= skipped + 1;
                end
            end

            LOOKING: begin
                $strobe("LOOKING");
                trigger <= 0;
                abs_i = i[15] ? ~i + 1 : i;
                if (abs_i > threshold) begin
                    trigger <= 1;
                    state = COOLDOWN;
                end
            end

            COOLDOWN: begin
                $strobe("COOLDOWN");
                if (cd_timer > cooldown) begin
                    state <= LOOKING;
                    cd_timer <= 0;
                end
                else begin
                    cd_timer += 1;
                end
            end

        endcase

    end
end
endmodule
