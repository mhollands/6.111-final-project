// Compute the intersection of two lines in Hesse normal form
module intersection(input clk,
                    input start,
                    input [7:0] theta1, theta0,
                    input signed [10:0] r1, r0,
                    output reg done,
                    output reg error,
                    output reg [9:0] x,
                    output reg [8:0] y);
     
    reg [2:0] state;
    
    parameter STATE_WAIT_TRIG = 2'b00;
    parameter STATE_WAIT_NUMERDENOM = 2'b01;
    parameter STATE_WAIT_DIV = 2'b10;
    parameter STATE_READY = 2'b11;
    
    reg [3:0] divwait; // Wait 8 slow-clock cycles for width-26 restoring divide to complete
    
    // Formula for the intersection:
    // x = (r_1*sin(theta_0) - r_0*sin(theta_1))/sin(theta_0 - theta_1)
    // y = (r_0*cos(theta_1) - r_1*cos(theta_0))/sin(theta_0 - theta_1)
    // Due to the structure of our LUT, both numerator and denominator are multiplied by 2^12
    
    reg signed [13:0] sintheta1, sintheta0, costheta1, costheta0, sintheta_next1, sintheta_next0, costheta_next1, costheta_next0;
    wire [12:0] mag_sintheta1, mag_sintheta0, mag_costheta1, mag_costheta0;
    wire neg_sintheta1, neg_sintheta0, neg_costheta1, neg_costheta0;
    sin_lookup sin_lut1(.angle(theta1), .answer(mag_sintheta1), .negative(neg_sintheta1));
    sin_lookup sin_lut0(.angle(theta0), .answer(mag_sintheta0), .negative(neg_sintheta0));
    cos_lookup cos_lut1(.angle(theta1), .answer(mag_costheta1), .negative(neg_costheta1));
    cos_lookup cos_lut0(.angle(theta0), .answer(mag_costheta0), .negative(neg_costheta0));
    
    always @(*) begin
        if (neg_sintheta1 == 1) begin
            sintheta_next1 = -1*mag_sintheta1;
        end
        else begin
            sintheta_next1 = mag_sintheta1;
        end
        if (neg_costheta1 == 1) begin
            costheta_next1 = -1*mag_costheta1;
        end
        else begin
            costheta_next1 = mag_costheta1;
        end
        if (neg_sintheta0 == 1) begin
            sintheta_next0 = -1*mag_sintheta0;
        end
        else begin
            sintheta_next0 = mag_sintheta0;
        end
        if (neg_costheta0 == 1) begin
            costheta_next0 = -1*mag_costheta0;
        end
        else begin
            costheta_next0 = mag_costheta0;
        end
    end
    
    reg [7:0] denom_angle;
    reg signed [13:0] denom_ans;
    wire [12:0] mag_denom;
    wire neg_denom;
    reg flip; // Only put positive angles into the LUT; flip if necessary (since sin is an odd function)
    sin_lookup denom_lut(.angle(denom_angle), .answer(mag_denom), .negative(neg_denom));
    
    always @(*) begin
        if (theta0 > theta1) begin
            denom_angle = theta0 - theta1;
            flip = 0;
        end
        else begin
            denom_angle = theta1 - theta0;
            flip = 1;
        end
    end
    
    always @(*) begin
        if (neg_denom ^ flip == 1) begin
            denom_ans = -1*mag_denom;
        end
        else begin
            denom_ans = mag_denom;
        end
    end
    
    wire signed [25:0] numerx, numery, denom;
    wire signed [25:0] ansx, ansy;
    reg divstart;
    divider #(.WIDTH(26)) divx(.clk(clk), .sign(1'b1), .start(divstart), .dividend(numerx), .divider(denom), .quotient(ansx));
    divider #(.WIDTH(26)) divy(.clk(clk), .sign(1'b1), .start(divstart), .dividend(numery), .divider(denom), .quotient(ansy));
    
    wire signed [25:0] numerxscratch, numeryscratch, denomxscratch, denomyscratch;
    assign numerxscratch = r1*sintheta0;
    assign numerx = numerxscratch - r0*sintheta1;
    
    assign numeryscratch = r0*costheta1;
    assign numery = numeryscratch - r1*costheta0;
    
    assign denom = denom_ans;
    
    // Run this module on a slow (quarter-speed) clock
    reg [1:0] clock_counter;
    always @(posedge clk) begin
        clock_counter <= clock_counter + 1;
    end
    reg slow_start; // Save a start pulse until the next slow-clock edge
    
    initial begin
        clock_counter = 0;
        done = 0;
        error = 0;
        slow_start = 0;
    end
    
    always @(posedge clk) begin
        if (clock_counter == 0) begin
            if (start == 1 || slow_start == 1) begin
                slow_start <= 0;
                if (theta1 == theta0) begin
                    done <= 1;
                    error <= 1;
                    state <= STATE_READY;
                end
                else begin
                    done <= 0;
                    error <= 0;
                    state <= STATE_WAIT_TRIG;
                end
            end
            else if (state == STATE_WAIT_TRIG) begin
                sintheta1 <= sintheta_next1;
                costheta1 <= costheta_next1;
                sintheta0 <= sintheta_next0;
                costheta0 <= costheta_next0;
                state <= STATE_WAIT_NUMERDENOM;
            end
            else if (state == STATE_WAIT_NUMERDENOM) begin
                divstart <= 1;
                state <= STATE_WAIT_DIV;
                divwait <= 8;
            end
            else if (state == STATE_WAIT_DIV) begin
                if (divwait == 0) begin
                    if (ansx < 0 || ansx > 640 || ansy < 0 || ansy > 480) begin // Answer out of bounds
                        done <= 1;
                        error <= 1;
                        state <= STATE_READY;
                    end
                    else begin
                        x <= ansx;
                        y <= ansy;
                        done <= 1;
                        state <= STATE_READY;
                    end
                end
                else begin
                    divwait <= divwait - 1;
                end
            end
        end
        else begin
            if (start == 1) begin // Catch start signals for later
                slow_start <= 1;
            end
            if (done == 1) begin // Clean up a done pulse
                done <= 0;
            end
            if (divstart == 1) begin // Clean up a start-division pulse, because the divider uses the fast clock
                divstart <= 0;
            end
        end
    end
endmodule

// Compute the orientation of a given triangle
// formula: sign of (x_2-x_1)*(y_3-y_1) - (x_3-x_1)*(y_2-y_1)
// see http://algs4.cs.princeton.edu/91primitives/
// Internal delay of 3 clock cycles
module orientation(input clk,
                   input [9:0] x1, x2, x3,
                   input [8:0] y1, y2, y3,
                   output orient);
    
    wire signed [10:0] x3s, x2s, x1s;
    wire signed [9:0] y3s, y2s, y1s;
    assign x3s = x3;
    assign x2s = x2;
    assign x1s = x1;
    assign y3s = y3;
    assign y2s = y2;
    assign y1s = y1;
    
    reg signed [10:0] x2minusx1, x3minusx1;
    reg signed [9:0] y2minusy1, y3minusy1;
    
    reg signed [19:0] mult1, mult2;
    reg signed [20:0] ans;
    
    always @(posedge clk) begin
        x2minusx1 <= x2s - x1s;
        x3minusx1 <= x3s - x1s;
        y2minusy1 <= y2s - y1s;
        y3minusy1 <= y3s - y1s;
        
        mult1 <= x2minusx1*y3minusy1;
        mult2 <= x3minusx1*y2minusy1;
        
        ans <= mult1-mult2;
    end
    
    assign orient = ans[20];
    
endmodule

// Determines whether a quadrilateral is convex and non-self-intersecting
// Given a quad ABCD, triangles ABC, BCD, CDA, and DAB must all have the same orientation for this to hold
// Internal delay of 5 clock cycles
module valid_quad(input clk,
                  input [9:0] x1, x2, x3, x4,
                  input [8:0] y1, y2, y3, y4,
                  output reg valid);
                  
    wire orient1, orient2, orient3, orient4;

    orientation orientation1(.clk(clk),
                   .x1(x1),
                   .x2(x2),
                   .x3(x3),
                   .y1(y1),
                   .y2(y2),
                   .y3(y3),
                   .orient(orient1));
    
    orientation orientation2(.clk(clk),
                   .x1(x2),
                   .x2(x3),
                   .x3(x4),
                   .y1(y2),
                   .y2(y3),
                   .y3(y4),
                   .orient(orient2));
                   
    orientation orientation3(.clk(clk),
                   .x1(x3),
                   .x2(x4),
                   .x3(x1),
                   .y1(y3),
                   .y2(y4),
                   .y3(y1),
                   .orient(orient3));
                   
    orientation orientation4(.clk(clk),
                   .x1(x4),
                   .x2(x1),
                   .x3(x2),
                   .y1(y4),
                   .y2(y1),
                   .y3(y2),
                   .orient(orient4));

    always @(*) begin
        valid = 0;
        if (orient1 == orient2 && orient2 == orient3 && orient3 == orient4) begin
            valid = 1;
        end
    end
    
endmodule

module corners_from_lines(input clk,
                          input start,
                          input [7:0] theta0, theta1, theta2, theta3,
                          input signed [10:0] r0, r1, r2, r3,
                          output reg done,
                          output reg [9:0] corner1x, corner2x, corner3x, corner4x,
                          output reg [8:0] corner1y, corner2y, corner3y, corner4y);
    
    reg [2:0] state;
    
    parameter STATE_READY = 3'b000;
    parameter STATE_WAIT_INTER = 3'b001;
    parameter STATE_WAIT_VALID1 = 3'b010;
    parameter STATE_WAIT_VALID2 = 3'b011;
    parameter STATE_WAIT_VALID3 = 3'b100;
    parameter STATE_DONE = 3'b111;
    
    reg [2:0] validwait;
    
    // Given four lines, there are three possible 'quadrilaterals' that can be generated
    // Only one should be convex and non-self-intersecting
    // When computing the orientation of three consecutive vertices of the correct quad, the answer should always be the same
    // This is not true of the incorrect quads
    
    wire [9:0] x01, x02, x03, x12, x13, x23;
    wire [8:0] y01, y02, y03, y12, y13, y23;
    wire done01, done02, done03, done12, done13, done23;
    reg [5:0] inter_done; // Persistent storage for done signals
    wire error01, error02, error03, error12, error13, error23;
    reg [5:0] inter_error; // Persistent storage for error signals
    reg interstart;
    
    intersection inter01(.clk(clk),
                    .start(interstart),
                    .theta1(theta1),
                    .theta0(theta0),
                    .r1(r1),
                    .r0(r0),
                    .done(done01),
                    .error(error01),
                    .x(x01),
                    .y(y01));
                    
    intersection inter02(.clk(clk),
                    .start(interstart),
                    .theta1(theta2),
                    .theta0(theta0),
                    .r1(r2),
                    .r0(r0),
                    .done(done02),
                    .error(error02),
                    .x(x02),
                    .y(y02));
                    
    intersection inter03(.clk(clk),
                    .start(interstart),
                    .theta1(theta3),
                    .theta0(theta0),
                    .r1(r3),
                    .r0(r0),
                    .done(done03),
                    .error(error03),
                    .x(x03),
                    .y(y03));
                    
    intersection inter12(.clk(clk),
                    .start(interstart),
                    .theta1(theta2),
                    .theta0(theta1),
                    .r1(r2),
                    .r0(r1),
                    .done(done12),
                    .error(error12),
                    .x(x12),
                    .y(y12));
                    
    intersection inter13(.clk(clk),
                    .start(interstart),
                    .theta1(theta3),
                    .theta0(theta1),
                    .r1(r3),
                    .r0(r1),
                    .done(done13),
                    .error(error13),
                    .x(x13),
                    .y(y13));
    
    intersection inter23(.clk(clk),
                    .start(interstart),
                    .theta1(theta3),
                    .theta0(theta2),
                    .r1(r3),
                    .r0(r2),
                    .done(done23),
                    .error(error23),
                    .x(x23),
                    .y(y23));
    
    reg [9:0] valid_x1, valid_x2, valid_x3, valid_x4;
    reg [8:0] valid_y1, valid_y2, valid_y3, valid_y4;
    wire valid;
    
    valid_quad validator(.clk(clk),
                  .x1(valid_x1),
                  .x2(valid_x2),
                  .x3(valid_x3),
                  .x4(valid_x4),
                  .y1(valid_y1),
                  .y2(valid_y2),
                  .y3(valid_y3),
                  .y4(valid_y4),
                  .valid(valid));
    
    initial begin
        done <= 0;
    end
    
    always @(posedge clk) begin
        if (start == 1) begin
            done <= 0;
            interstart <= 1;
            state <= STATE_WAIT_INTER;
        end
        else if (state == STATE_WAIT_INTER) begin
            if (interstart == 1) begin
                interstart <= 0;
            end
            
            if (done01 == 1) begin
                inter_done[0] <= 1;
                inter_error[0] <= error01;
            end
            if (done02 == 1) begin
                inter_done[1] <= 1;
                inter_error[1] <= error02;
            end
            if (done03 == 1) begin
                inter_done[2] <= 1;
                inter_error[2] <= error03;
            end
            if (done12 == 1) begin
                inter_done[3] <= 1;
                inter_error[3] <= error12;
            end
            if (done13 == 1) begin
                inter_done[4] <= 1;
                inter_error[4] <= error13;
            end
            if (done23 == 1) begin
                inter_done[5] <= 1;
                inter_error[5] <= error23;
            end
            
            if (inter_done == 6'b111111) begin
                state <= STATE_WAIT_VALID1;
                valid_x1 <= x01;
                valid_x2 <= x12;
                valid_x3 <= x23;
                valid_x4 <= x03;
                valid_y1 <= y01;
                valid_y2 <= y12;
                valid_y3 <= y23;
                valid_y4 <= y03;
                validwait <= 7;
            end
        end
        else if (state == STATE_WAIT_VALID1) begin
            // If there was an out of bounds on any of the vertices OR the validator has rejected this quad, move on
            if (inter_error[0] || inter_error[2] || inter_error[3] || inter_error[5] || (validwait == 0 && !valid)) begin
                state <= STATE_WAIT_VALID2;
                valid_x1 <= x01;
                valid_x2 <= x13;
                valid_x3 <= x23;
                valid_x4 <= x02;
                valid_y1 <= y01;
                valid_y2 <= y13;
                valid_y3 <= y23;
                valid_y4 <= y02;
                validwait <= 7;
            end
            else if (validwait > 0) begin
                validwait <= validwait - 1;
            end
            else begin
                corner1x <= valid_x1;
                corner2x <= valid_x2;
                corner3x <= valid_x3;
                corner4x <= valid_x4;
                corner1y <= valid_y1;
                corner2y <= valid_y2;
                corner3y <= valid_y3;
                corner4y <= valid_y4;
                done <= 1;
                state <= STATE_DONE;
            end
        end
        else if (state == STATE_WAIT_VALID2) begin
            // If there was an out of bounds on any of the vertices OR the validator has rejected this quad, move on
            if (inter_error[0] || inter_error[1] || inter_error[4] || inter_error[5] || (validwait == 0 && !valid)) begin
                state <= STATE_WAIT_VALID3;
                valid_x1 <= x02;
                valid_x2 <= x12;
                valid_x3 <= x13;
                valid_x4 <= x03;
                valid_y1 <= y02;
                valid_y2 <= y12;
                valid_y3 <= y13;
                valid_y4 <= y03;
                validwait <= 7;
            end
            else if (validwait > 0) begin
                validwait <= validwait - 1;
            end
            else begin
                corner1x <= valid_x1;
                corner2x <= valid_x2;
                corner3x <= valid_x3;
                corner4x <= valid_x4;
                corner1y <= valid_y1;
                corner2y <= valid_y2;
                corner3y <= valid_y3;
                corner4y <= valid_y4;
                done <= 1;
                state <= STATE_DONE;
            end
        end
        else if (state == STATE_WAIT_VALID3) begin
            // If there was an out of bounds on any of the vertices OR the validator has rejected this quad, use corners of screen
            if (inter_error[1] || inter_error[2] || inter_error[3] || inter_error[4] || (validwait == 0 && !valid)) begin
                corner1x <= 0;
                corner2x <= 0;
                corner3x <= 640;
                corner4x <= 640;
                corner1y <= 0;
                corner2y <= 480;
                corner3y <= 480;
                corner4y <= 0;
                done <= 1;
                state <= STATE_DONE;
            end
            else if (validwait > 0) begin
                validwait <= validwait - 1;
            end
            else begin
                corner1x <= valid_x1;
                corner2x <= valid_x2;
                corner3x <= valid_x3;
                corner4x <= valid_x4;
                corner1y <= valid_y1;
                corner2y <= valid_y2;
                corner3y <= valid_y3;
                corner4y <= valid_y4;
                done <= 1;
                state <= STATE_DONE;
            end
        end
        else if (state == STATE_DONE) begin
            done <= 0;
            state <= STATE_READY;
        end
    end
    
endmodule
