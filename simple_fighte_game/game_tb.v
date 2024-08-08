`include "game.v"
`default_nettype none

module tb_game;

    wire [1:0] player1_pos;
    wire [1:0] player2_pos;
    wire [1:0] player1_health;
    wire [1:0] player2_health;
    reg player1_kick;
    reg player1_punch;
    reg player1_waiting;
    reg player1_jump;
    reg player1_forward;
    reg player1_back;

    reg player2_kick;
    reg player2_punch;
    reg player2_waiting;
    reg player2_jump;
    reg player2_forward;
    reg player2_back;
    reg CLK;

    game g(
        player1_pos,
        player2_pos,
        player1_health,
        player2_health,
        player1_kick,
        player1_punch,
        player1_waiting,
        player1_jump,
        player1_forward,
        player1_back,
        player2_kick,
        player2_punch,
        player2_waiting,
        player2_jump,
        player2_forward,
        player2_back,
        CLK
    );

    initial begin
        CLK = 1'b0;
        repeat (200)
            #100 CLK = ~CLK;
    end

    initial begin
        $dumpfile("tb_game.vcd");
        $dumpvars(0, tb_game);

        player1_kick = 1'b0;
        player1_punch = 1'b0;
        player1_waiting = 1'b0;
        player1_jump = 1'b0;
        player1_forward = 1'b0;
        player1_back = 1'b0;

        player2_kick = 1'b0;
        player2_punch = 1'b0;
        player2_waiting = 1'b0;
        player2_jump = 1'b0;
        player2_forward = 1'b0;
        player2_back = 1'b0;

        player1_forward = 1'b1;
        player2_forward = 1'b1;
        #200
        player1_forward = 1'b1;
        player2_forward = 1'b1;
        #200
        player1_forward = 1'b0;
        player2_forward = 1'b0;
        player1_punch = 1'b1;
        player2_punch = 1'b1;
        #200
        player1_punch = 1'b0;
        player2_punch = 1'b0;
        player1_kick = 1'b1;
        player2_forward = 1'b1;
        #200
        player1_kick = 1'b0;
        player2_forward = 1'b0;
        player1_forward = 1'b1;
        player2_punch = 1'b1;
        #200
        player1_forward = 1'b0;
        player2_punch = 1'b0;
        player1_waiting = 1'b1;
        player2_waiting = 1'b1;
        #200
        player1_waiting = 1'b1;
        player2_waiting = 1'b1;
        #200
        player1_waiting = 1'b0;
        player2_waiting = 1'b0;
        player1_punch = 1'b1;
        player2_kick = 1'b1;
        #200
        player1_punch = 1'b0;
        player2_kick = 1'b0;
        player1_jump = 1'b1;
        player2_punch = 1'b1;
    end
endmodule