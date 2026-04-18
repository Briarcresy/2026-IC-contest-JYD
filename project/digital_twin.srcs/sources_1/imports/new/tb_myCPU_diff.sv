`timescale 1ns / 1ps

module tb_myCPU_diff;
    localparam [31:0] IROM_BASE = 32'h8000_0000;
    localparam [31:0] IROM_END = 32'h8000_3FFF;
    localparam [31:0] DRAM_BASE = 32'h8010_0000;
    localparam [31:0] DRAM_END = 32'h8013_FFFF;

    localparam integer IROM_WORDS = 4096;
    localparam integer DRAM_WORDS = 65536;

    logic          clk;
    logic          rst;

    logic   [31:0] irom_addr_pipe;
    logic   [31:0] irom_data_pipe;
    logic   [31:0] perip_addr_pipe;
    logic          perip_wen_pipe;
    logic   [ 1:0] perip_mask_pipe;
    logic   [31:0] perip_wdata_pipe;
    logic   [31:0] perip_rdata_pipe;

    logic   [31:0] irom_addr_ref;
    logic   [31:0] irom_data_ref;
    logic   [31:0] perip_addr_ref;
    logic          perip_wen_ref;
    logic   [ 1:0] perip_mask_ref;
    logic   [31:0] perip_wdata_ref;
    logic   [31:0] perip_rdata_ref;

    logic   [31:0] irom_mem         [0:IROM_WORDS-1];
    logic   [31:0] dram_pipe        [0:DRAM_WORDS-1];
    logic   [31:0] dram_ref         [0:DRAM_WORDS-1];

    logic   [31:0] seg_pipe;
    logic   [31:0] seg_ref;
    logic   [31:0] led_pipe;
    logic   [31:0] led_ref;
    logic   [31:0] counter_pipe;
    logic   [31:0] counter_ref;
    logic          done_pipe;
    logic          done_ref;

    logic   [31:0] shadow_pipe      [          0:31];
    logic   [31:0] shadow_ref       [          0:31];

    integer        cycle_count;
    integer        mismatch_count;
    integer        i;
    integer        trace_cycles;
    integer        max_cycles;

    myCPU dut_pipe (
        .cpu_rst    (rst),
        .cpu_clk    (clk),
        .irom_addr  (irom_addr_pipe),
        .irom_data  (irom_data_pipe),
        .perip_addr (perip_addr_pipe),
        .perip_wen  (perip_wen_pipe),
        .perip_mask (perip_mask_pipe),
        .perip_wdata(perip_wdata_pipe),
        .perip_rdata(perip_rdata_pipe)
    );

    myCPU_sc_ref dut_ref (
        .cpu_rst    (rst),
        .cpu_clk    (clk),
        .irom_addr  (irom_addr_ref),
        .irom_data  (irom_data_ref),
        .perip_addr (perip_addr_ref),
        .perip_wen  (perip_wen_ref),
        .perip_mask (perip_mask_ref),
        .perip_wdata(perip_wdata_ref),
        .perip_rdata(perip_rdata_ref)
    );

    function automatic logic [31:0] irom_read(input logic [31:0] addr);
        integer idx;
        begin
            if ((addr >= IROM_BASE) && (addr <= IROM_END)) begin
                idx = (addr - IROM_BASE) >> 2;
                irom_read = irom_mem[idx];
            end else begin
                irom_read = 32'h0000_0013;
            end
        end
    endfunction

    function automatic logic [31:0] dram_read_pipe(input logic [31:0] addr);
        integer idx;
        logic [31:0] raw;
        begin
            if ((addr >= DRAM_BASE) && (addr <= DRAM_END)) begin
                idx = (addr - DRAM_BASE) >> 2;
                raw = dram_pipe[idx];
                dram_read_pipe = raw >> (addr[1:0] * 8);
            end else begin
                dram_read_pipe = 32'b0;
            end
        end
    endfunction

    function automatic logic [31:0] dram_read_ref(input logic [31:0] addr);
        integer idx;
        logic [31:0] raw;
        begin
            if ((addr >= DRAM_BASE) && (addr <= DRAM_END)) begin
                idx = (addr - DRAM_BASE) >> 2;
                raw = dram_ref[idx];
                dram_read_ref = raw >> (addr[1:0] * 8);
            end else begin
                dram_read_ref = 32'b0;
            end
        end
    endfunction

    task automatic dram_write_pipe(input logic [31:0] addr, input logic [1:0] mask,
                                   input logic [31:0] wdata);
        integer idx;
        logic [31:0] oldv;
        logic [31:0] newv;
        begin
            if ((addr >= DRAM_BASE) && (addr <= DRAM_END)) begin
                idx  = (addr - DRAM_BASE) >> 2;
                oldv = dram_pipe[idx];
                newv = oldv;
                case (mask)
                    2'b00: begin
                        case (addr[1:0])
                            2'b00: newv[7:0] = wdata[7:0];
                            2'b01: newv[15:8] = wdata[7:0];
                            2'b10: newv[23:16] = wdata[7:0];
                            2'b11: newv[31:24] = wdata[7:0];
                        endcase
                    end
                    2'b01: begin
                        if (addr[1]) newv[31:16] = wdata[15:0];
                        else newv[15:0] = wdata[15:0];
                    end
                    default: begin
                        newv = wdata;
                    end
                endcase
                dram_pipe[idx] = newv;
            end
        end
    endtask

    task automatic dram_write_ref(input logic [31:0] addr, input logic [1:0] mask,
                                  input logic [31:0] wdata);
        integer idx;
        logic [31:0] oldv;
        logic [31:0] newv;
        begin
            if ((addr >= DRAM_BASE) && (addr <= DRAM_END)) begin
                idx  = (addr - DRAM_BASE) >> 2;
                oldv = dram_ref[idx];
                newv = oldv;
                case (mask)
                    2'b00: begin
                        case (addr[1:0])
                            2'b00: newv[7:0] = wdata[7:0];
                            2'b01: newv[15:8] = wdata[7:0];
                            2'b10: newv[23:16] = wdata[7:0];
                            2'b11: newv[31:24] = wdata[7:0];
                        endcase
                    end
                    2'b01: begin
                        if (addr[1]) newv[31:16] = wdata[15:0];
                        else newv[15:0] = wdata[15:0];
                    end
                    default: begin
                        newv = wdata;
                    end
                endcase
                dram_ref[idx] = newv;
            end
        end
    endtask

    always @(*) begin
        irom_data_pipe = irom_read(irom_addr_pipe);
        irom_data_ref  = irom_read(irom_addr_ref);

        if ((perip_addr_pipe >= DRAM_BASE) && (perip_addr_pipe <= DRAM_END))
            perip_rdata_pipe = dram_read_pipe(perip_addr_pipe);
        else if (perip_addr_pipe == 32'h8020_0020) perip_rdata_pipe = seg_pipe;
        else if (perip_addr_pipe == 32'h8020_0050) perip_rdata_pipe = counter_pipe;
        else perip_rdata_pipe = 32'b0;

        if ((perip_addr_ref >= DRAM_BASE) && (perip_addr_ref <= DRAM_END))
            perip_rdata_ref = dram_read_ref(perip_addr_ref);
        else if (perip_addr_ref == 32'h8020_0020) perip_rdata_ref = seg_ref;
        else if (perip_addr_ref == 32'h8020_0050) perip_rdata_ref = counter_ref;
        else perip_rdata_ref = 32'b0;
    end

    always @(posedge clk) begin
        if (!rst) begin
            if (cycle_count < trace_cycles) begin
                $display("[TRACE][C%0d] pipe_pc=%08x pipe_ins=%08x | ref_pc=%08x ref_ins=%08x",
                         cycle_count, dut_pipe.pcF, irom_data_pipe, dut_ref.pc, irom_data_ref);
            end

            if (dut_pipe.regWriteW && (dut_pipe.rdW != 5'd0)) begin
                shadow_pipe[dut_pipe.rdW] <= dut_pipe.wbData;
                if (cycle_count < trace_cycles) begin
                    $display("[TRACE][C%0d] pipe_wb x%0d=%08x", cycle_count, dut_pipe.rdW,
                             dut_pipe.wbData);
                end
            end

            if (dut_ref.RegWrite && (dut_ref.instr[11:7] != 5'd0)) begin
                shadow_ref[dut_ref.instr[11:7]] <= dut_ref.wdata;
                if (cycle_count < trace_cycles) begin
                    $display("[TRACE][C%0d] ref_wb  x%0d=%08x", cycle_count, dut_ref.instr[11:7],
                             dut_ref.wdata);
                end
            end

            if (perip_wen_pipe) begin
                if ((perip_addr_pipe >= DRAM_BASE) && (perip_addr_pipe <= DRAM_END)) begin
                    dram_write_pipe(perip_addr_pipe, perip_mask_pipe, perip_wdata_pipe);
                end else if (perip_addr_pipe == 32'h8020_0020) begin
                    seg_pipe <= perip_wdata_pipe;
                end else if (perip_addr_pipe == 32'h8020_0040) begin
                    led_pipe <= perip_wdata_pipe;
                end else if (perip_addr_pipe == 32'h8020_0050) begin
                    counter_pipe <= perip_wdata_pipe;
                    if (perip_wdata_pipe == 32'hFFFF_FFFF) done_pipe <= 1'b1;
                end
            end

            if (perip_wen_ref) begin
                if ((perip_addr_ref >= DRAM_BASE) && (perip_addr_ref <= DRAM_END)) begin
                    dram_write_ref(perip_addr_ref, perip_mask_ref, perip_wdata_ref);
                end else if (perip_addr_ref == 32'h8020_0020) begin
                    seg_ref <= perip_wdata_ref;
                end else if (perip_addr_ref == 32'h8020_0040) begin
                    led_ref <= perip_wdata_ref;
                end else if (perip_addr_ref == 32'h8020_0050) begin
                    counter_ref <= perip_wdata_ref;
                    if (perip_wdata_ref == 32'hFFFF_FFFF) done_ref <= 1'b1;
                end
            end
        end
    end

    task automatic compare_state;
        integer j;
        begin
            mismatch_count = 0;

            for (j = 0; j < 32; j = j + 1) begin
                if (shadow_pipe[j] !== shadow_ref[j]) begin
                    mismatch_count = mismatch_count + 1;
                    $display("[DIFF][REG] x%0d pipe=%08x ref=%08x", j, shadow_pipe[j],
                             shadow_ref[j]);
                end
            end

            for (j = 0; j < DRAM_WORDS; j = j + 1) begin
                if (dram_pipe[j] !== dram_ref[j]) begin
                    mismatch_count = mismatch_count + 1;
                    if (mismatch_count <= 64) begin
                        $display("[DIFF][DRAM] word%0d pipe=%08x ref=%08x", j, dram_pipe[j],
                                 dram_ref[j]);
                    end
                end
            end

            if (seg_pipe !== seg_ref) begin
                mismatch_count = mismatch_count + 1;
                $display("[DIFF][MMIO] SEG pipe=%08x ref=%08x", seg_pipe, seg_ref);
            end
            if (led_pipe !== led_ref) begin
                mismatch_count = mismatch_count + 1;
                $display("[DIFF][MMIO] LED pipe=%08x ref=%08x", led_pipe, led_ref);
            end
            if (counter_pipe !== counter_ref) begin
                mismatch_count = mismatch_count + 1;
                $display("[DIFF][MMIO] COUNTER pipe=%08x ref=%08x", counter_pipe, counter_ref);
            end

            if (mismatch_count == 0)
                $display("[DIFF][PASS] pipeline equals single-cycle reference");
            else $display("[DIFF][FAIL] mismatch_count=%0d", mismatch_count);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        string irom_file;
        string dram_file;

        clk = 1'b0;
        rst = 1'b1;
        done_pipe = 1'b0;
        done_ref = 1'b0;
        seg_pipe = 32'b0;
        seg_ref = 32'b0;
        led_pipe = 32'b0;
        led_ref = 32'b0;
        counter_pipe = 32'b0;
        counter_ref = 32'b0;
        cycle_count = 0;
        trace_cycles = 0;
        max_cycles = 300000;

        for (i = 0; i < IROM_WORDS; i = i + 1) irom_mem[i] = 32'h0000_0013;
        for (i = 0; i < DRAM_WORDS; i = i + 1) begin
            dram_pipe[i] = 32'b0;
            dram_ref[i]  = 32'b0;
        end
        for (i = 0; i < 32; i = i + 1) begin
            shadow_pipe[i] = 32'b0;
            shadow_ref[i]  = 32'b0;
        end

        if (!$value$plusargs("IROM_HEX=%s", irom_file)) irom_file = "project/IROM.mif";
        if (!$value$plusargs("DRAM_HEX=%s", dram_file)) dram_file = "project/DRAM.mif";
        void'($value$plusargs("TRACE_CYCLES=%d", trace_cycles));
        void'($value$plusargs("MAX_CYCLES=%d", max_cycles));

        $display("[DIFF] load IROM from %s", irom_file);
        $display("[DIFF] load DRAM from %s", dram_file);
        $readmemb(irom_file, irom_mem);
        $readmemb(dram_file, dram_pipe);
        $readmemb(dram_file, dram_ref);

        repeat (5) @(posedge clk);
        rst = 1'b0;

        while (cycle_count < max_cycles) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            if (done_pipe && done_ref) begin
                $display("[DIFF] both cores reached stop condition at cycle=%0d", cycle_count);
                compare_state();
                if (mismatch_count == 0) $finish;
                else $fatal(1);
            end
        end

        $display("[DIFF][TIMEOUT] cycle=%0d max=%0d", cycle_count, max_cycles);
        compare_state();
        if (mismatch_count == 0) $finish;
        else $fatal(1);
    end
endmodule
