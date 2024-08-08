module game (
    output [1:0] player1_pos,
    output [1:0] player2_pos,

    input player1_kick,
    input player1_punch,
    input player1_waiting,
    input player1_jump,
    input player1_forward,
    input player1_back,

    input player2_kick,
    input player2_punch,
    input player2_waiting,
    input player2_jump,
    input player2_forward,
    input player2_back,
    input CLK,

    output reg[7:0]SEG_DATA,
    output reg[4:0]SEG_SEL

);

    // _ _ _ | _ _ _
    // 0 1 2   2 1 0
    // prstate = {pos1, pos2, wait1, wait2, health1, health2}
    reg [9:0] prstate = 10'b0000001111;
    reg [1:0] nxtpos1 = 2'b00, nxtpos2 = 2'b00;
    reg nxtwait1 = 1'b0, nxtwait2 = 1'b0;
    reg [1:0] nxthealth1 = 2'b11, nxthealth2 = 2'b11;
    wire [2:0] dis; // 4
    wire [9:0] nxtstate;

    wire [1:0]player1_health;
    wire [1:0]player2_health;

    assign nxtstate = {nxtpos1, nxtpos2, nxtwait1, nxtwait2, nxthealth1, nxthealth2};
    assign dis = 3'b010 - nxtpos2 + 3'b010 - nxtpos1;
    // output
    assign player1_pos = prstate[9:8];
    assign player2_pos = prstate[7:6];
    assign player1_health = prstate[3:2];
    assign player2_health = prstate[1:0];

    // freqDivider regs
    reg [31:0] counter = 0;
    reg CLK2;

    //freqDivider
    always @(posedge CLK) begin
        if(counter == 20000000)
            begin
                counter <= 0;
                CLK2 <= ~CLK2;
            end
        else 
            begin
                counter <= counter + 1;
            end
    end

    // flip flop
    always @(posedge CLK2) begin
        prstate = nxtstate;    
    end
    // logic
    always @(prstate or player1_back or player1_forward or player2_back or player2_forward or player1_punch or player2_punch) begin
        nxtpos1 = prstate[9:8];
        nxtpos2 = prstate[7:6];
        nxthealth1 = prstate[3:2];
        nxthealth2 = prstate[1:0];
        nxtwait1 = prstate[4];
        nxtwait2 = prstate[5];
        // movement
        if (player1_forward & nxtpos1 != 2'b10)
            nxtpos1 = nxtpos1 + 2'b01;
        if (player1_back & nxtpos1 != 2'b00)
            nxtpos1 = nxtpos1 - 2'b01;

        if (player2_forward & nxtpos2 != 2'b10)
            nxtpos2 = nxtpos2 + 2'b01;
        if (player2_back & nxtpos2 != 2'b00)
            nxtpos2 = nxtpos2 - 2'b01;

        //wait
        if(~player1_waiting)
            nxtwait1=1'b0;
        if(~player2_waiting)
            nxtwait2=1'b0;
        if(player1_waiting)begin    
            if(nxtwait1)
                nxthealth1=nxthealth1+2'b01;
            nxtwait1=~nxtwait1;
        end
        if(player2_waiting)begin    
            if(nxtwait2)
                nxthealth2=nxthealth2+2'b01;
            nxtwait2=~nxtwait2;
        end

        // punch
        if (dis == 3'b000) begin
            if (player1_punch & ~player2_punch & ~player2_jump) begin
                if (nxthealth2 == 2'b11)
                    nxthealth2 = 2'b01;
                else
                    nxthealth2 = 2'b00;
            end 
            if (player2_punch & ~player1_punch & ~player1_jump) begin
                if (nxthealth1 == 2'b11)
                    nxthealth1 = 2'b01;
                else
                    nxthealth1 = 2'b00;
            end
            if (player1_punch & player2_punch) begin//knock back
                nxtpos1 = nxtpos1 - 2'b01;
                nxtpos2 = nxtpos2 - 2'b01;
            end
             if (player1_kick & ~player2_jump & ~player2_kick & ~player2_punch )begin
                if(nxthealth2!=2'b00)
                    nxthealth2 = nxthealth2 - 2'b01;
                else
                    nxthealth2 = 2'b00;
            end
            if (player2_kick & ~player1_jump & ~player1_kick & ~player1_punch)begin
                if(nxthealth1!=2'b00)
                    nxthealth1 = nxthealth1 - 2'b01;
                else
                    nxthealth1 = 2'b00;
            end
            if (player1_kick & player2_kick)begin//knock back
                nxtpos1 = nxtpos1 - 2'b01;
                nxtpos2 = nxtpos2 - 2'b01;
            end
        end
        //kick
        if(dis == 3'b001 )begin
            if (player1_kick & ~player2_jump & ~player2_kick)begin
                if(nxthealth2!=2'b00)
                    nxthealth2 = nxthealth2 - 2'b01;
                else
                    nxthealth2 = 2'b00;
            end
            if (player2_kick & ~player1_jump & ~player1_kick)begin
                if(nxthealth1!=2'b00)
                    nxthealth1 = nxthealth1 - 2'b01;
                else
                    nxthealth1 = 2'b00;
            end
            if (player1_kick & player2_kick)begin//knock back
                nxtpos1 = nxtpos1 - 2'b01;
                nxtpos2 = nxtpos2 - 2'b01;
            end
        end
    end

    // seven segment updater
    always @(posedge clk ) begin
        case(player1_health)
            2'b00: SEG_DATA = 8'b01111111;
            2'b01: SEG_DATA = 8'b00000110;
            2'b10: SEG_DATA = 8'b01011011;
            2'b11: SEG_DATA = 8'b01001111;
        endcase
        assign SEG_SEL = 5'b00001;
    end
    
    always @(negedge clk ) begin
        case(player2_health)
        2'b00: SEG_DATA = 8'b01111111;
        2'b01: SEG_DATA = 8'b00000110;
        2'b10: SEG_DATA = 8'b01011011;
        2'b11: SEG_DATA = 8'b01001111;
        endcase
        assign SEG_SEL = 5b'00010;
    end
endmodule