`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:59:14 04/01/2013 
// Design Name: 
// Module Name:    lock 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define zero	7'b0000001 //or 'O'
`define one 	7'b1001111
`define two 	7'b0010010
`define three 	7'b0000110
`define four 	7'b1001100
`define five 	7'b0100100 //or 's' 
`define six 	7'b0100000
`define seven 	7'b0001111
`define eight 	7'b0000000
`define nine 	7'b0000100
`define minus 	7'b1111110


`define achar	7'b0001000
`define bchar 	7'b1100000
`define cchar 	7'b0110001
`define dchar 	7'b1000010
`define echar 	7'b0110000
`define fchar	7'b0111000


`define lchar 	7'b1110001
`define uchar  7'b1000001
`define nchar	7'b1101010
`define pchar  7'b0011000

`define firstdigit   8'b00000001
`define seconddigit  8'b00000010
`define thirddigit   8'b00000100
`define fourthdigit  8'b00001000
`define enterdigit   4
`define mvstate      7
module lock(
anodes,cathodes,leds,
sw,btns,clk );

//input declarations
input[7:0] sw;
input[3:0]btns;
input clk;

//ouput declarations
output[3:0] anodes;
output[6:0]cathodes;
output[7:0]leds;

//ports
reg[3:0]anodes;
reg[6:0]cathodes;
//variables
reg[1:0]state,state_next; //00: locked, 01:digit, 10:unlocked, 11 paused
reg[3:0]curbtns;
reg[3:0]prevbtns;
reg slow_clock,sec_clock;
reg[4:0]counter, counter_next;

//digits
reg[3:0]firstdigit,seconddigit,thirddigit,fourthdigit;
reg[1:0]digitpos;
reg[1:0]prevdigitpos;
reg[15:0]digit;

//timer variable
reg[4:0]ten_seconds;
assign leds=sw;

initial
begin
counter = 0;
counter_next = 0;
prevbtns=0;
curbtns=0;
end

/*
always @(firstdigit or seconddigit or thirddigit or fourthdigit)
begin
	digit = {fourthdigit,thirddigit,seconddigit,firstdigit};	
end
*/	

always @(counter or ten_seconds or sw or digit or state)
begin
	case(state)
	2'b00:begin //locked
		if(sw[1]==1)
			state_next = 2'b01;
		else
			state_next = state;
	end
	2'b01:begin
	end
	2'b10:begin
	end
	2'b11:begin
	end	
	endcase

end



always @(counter or counter_next or sw or digitpos or digit)
begin
		if(sw[3]==1 && (counter !=counter_next))//fourthdigit
		begin
			fourthdigit = ((4'b0001 << digitpos)^(digit[15:12])) ;
			thirddigit =(digit[11:8]);
			seconddigit =(digit[7:4]);
			firstdigit =(digit[3:0]);
		end	
		else if(sw[2]==1 && (counter !=counter_next))//fourthdigit
		begin
			fourthdigit = (digit[15:11]);
			thirddigit = ((4'b0001 << digitpos)^(digit[11:8])) ;
			seconddigit =(digit[7:4]);
			firstdigit =(digit[3:0]);
		end	
		else if(sw[1]==1 && (counter !=counter_next))//fourthdigit
		begin
			fourthdigit = (digit[15:11]);
			thirddigit =(digit[11:8]);
			seconddigit = ((4'b0001 << digitpos)^(digit[7:4])) ;
			firstdigit =(digit[3:0]);
		end	
		else if(sw[0]==1 && (counter !=counter_next))//fourthdigit 
		begin
			fourthdigit = (digit[15:11]);
			thirddigit =(digit[11:8]);
			seconddigit =(digit[7:4]);
			firstdigit = ((4'b0001 << digitpos)^(digit[3:0])) ;
		end
		else
		begin
			{fourthdigit,thirddigit,seconddigit,firstdigit}=digit;	
		end	
end


always @(curbtns or prevbtns or counter)
begin
	if( prevbtns==0 && curbtns!=0)
	begin
	if(counter >= 25)
		counter_next = 1;
	else
		counter_next = counter + 5'b00001;
	end
	else
		counter_next = counter;
	
end

always @(btns or prevbtns or prevdigitpos)
begin

case(btns )
	4'b0001:curbtns=4'b0001;
	4'b0010:curbtns=4'b0010;
	4'b0100:curbtns=4'b0100;
	4'b1000:curbtns=4'b1000;
	4'b0000:curbtns=4'b0000;
	default:curbtns = prevbtns;	
endcase


case(btns )
	4'b0001:digitpos=4'b00;
	4'b0010:digitpos=4'b01;
	4'b0100:digitpos=4'b10;
	4'b1000:digitpos=4'b11;
	default:digitpos=prevdigitpos;	
endcase


end

	
always @( posedge slow_clock  )	
begin	
	update_screen(anodes,ten_seconds,0,cathodes);
//	show_digits(anodes,digit,cathodes);
	
end	

always @( posedge sec_clock  )	
begin	
	if(ten_seconds >=10)
		ten_seconds <=0;
	else
		ten_seconds <= ten_seconds+1;
	//update_screen(anodes,ten_seconds,0,cathodes);	
end	

always @(posedge clk)
begin
	counter =counter_next;
	prevbtns =curbtns;
	prevdigitpos=digitpos;
	digit = {fourthdigit,thirddigit,seconddigit,firstdigit};	
	create_slow_clock(clk,slow_clock);
	create_sec_clock(clk,sec_clock);
end

//For strobing
task create_slow_clock;
input clock;
inout slow_clock;
integer count;
begin
	if (count > 100000)
	begin
		count=0;
		slow_clock = ~slow_clock;
	end
	count = count+1;
end
endtask

//For strobing
task create_sec_clock;
input clock;
inout sec_clock;
integer count;
begin
	if (count >= 50000000)
	begin
		sec_clock = ~sec_clock;
		count=0;
	end
	count = count+1;
end
endtask




task show_locked;

inout anodes;
output cathodes;


reg[3:0]anodes;
reg[6:0]cathodes;

begin
	case (anodes)
	4'b1111:anodes=4'b0111;
	4'b0111:anodes=4'b1011;
	4'b1011:anodes=4'b1101;
	4'b1101:anodes=4'b1110;
	4'b1110:anodes=4'b1111;
	default:anodes=4'b1111;
	endcase	

	case (anodes)
	4'b0111:cathodes=`lchar;
	4'b1011:cathodes=`zero;
	4'b1101:cathodes=`cchar;
	4'b1110:cathodes=`zero;
	default:cathodes=0;
	endcase	

end

endtask



task show_unlocked;

inout anodes;
output cathodes;


reg[3:0]anodes;
reg[6:0]cathodes;

begin
	case (anodes)
	4'b1111:anodes=4'b0111;
	4'b0111:anodes=4'b1011;
	4'b1011:anodes=4'b1101;
	4'b1101:anodes=4'b1110;
	4'b1110:anodes=4'b1111;
	default:anodes=4'b1111;
	endcase	

	case (anodes)
	4'b0111:cathodes=`uchar;
	4'b1011:cathodes=`nchar;
	4'b1101:cathodes=`lchar;
	4'b1110:cathodes=`cchar;
	default:cathodes=0;
	endcase	

end

endtask


task show_paused;

inout anodes;
output cathodes;


reg[3:0]anodes;
reg[6:0]cathodes;

begin
	case (anodes)
	4'b1111:anodes=4'b0111;
	4'b0111:anodes=4'b1011;
	4'b1011:anodes=4'b1101;
	4'b1101:anodes=4'b1110;
	4'b1110:anodes=4'b1111;
	default:anodes=4'b1111;
	endcase	

	case (anodes)
	4'b0111:cathodes=`pchar;
	4'b1011:cathodes=`achar;
	4'b1101:cathodes=`uchar;
	4'b1110:cathodes=`five;
	default:cathodes=0;
	endcase	

end

endtask

task show_digits;
inout anodes;
input[15:0] digits;
output cathodes;

reg[3:0]anodes;
reg[6:0]cathodes;
//contains four 4 digits numbers
begin
	case (anodes)
	4'b1111:anodes=4'b0111;
	4'b0111:anodes=4'b1011;
	4'b1011:anodes=4'b1101;
	4'b1101:anodes=4'b1110;
	4'b1110:anodes=4'b1111;
	default:anodes=4'b1111;
	endcase	

	case (anodes)
	4'b0111:cathodes=give_rep(digits[15:12]);
	4'b1011:cathodes=give_rep(digits[11:8]);
	4'b1101:cathodes=give_rep(digits[7:4]);
	4'b1110:cathodes=give_rep(digits[3:0]);
	default:cathodes=0;
	endcase	

end
endtask

//this function take a decimal digit and return corresponding pattern on
//seven segment display
function  [6:0] give_rep;
input number;
reg[3:0] number;
begin
	case(number)
	0:give_rep=`zero;
	1:give_rep=`one;
	2:give_rep=`two;
	3:give_rep=`three;
	4:give_rep=`four;
	5:give_rep=`five;
	6:give_rep=`six;
	7:give_rep=`seven;
	8:give_rep=`eight;
	9:give_rep=`nine;
	default:give_rep=`minus;
	endcase 
end
endfunction


//Task Update SevenSegment
task update_screen;
inout anodes;
input[4:0] magnitude;
input sign;

output cathodes;

reg[3:0]anodes;
reg[6:0]cathodes;

reg[4:0] magnitude;
reg sign;
reg[4:0] first_part;
reg[4:0] second_part;

begin
	first_part = {4'b0000,magnitude[4]};
	second_part = {1'b0,magnitude[3:0]};

case(anodes)
	4'b1111:begin
		if(sign==1'b1)
			anodes= 4'b1011;
		else
			anodes= 4'b1101;
	end
	4'b1011:anodes=4'b1101;
	4'b1101:anodes=4'b1110;
	4'b1110:begin
		if(sign==1'b1)
			anodes= 4'b1011;
		else
			anodes= 4'b1101;
	end
	default:anodes=4'b1111;
	endcase
	
	case(anodes)
	4'b1011:cathodes=give_repnew(5'b10000);
	4'b1101:cathodes=give_repnew(first_part);
	4'b1110:cathodes=give_repnew(second_part);
	default:cathodes=0;
	endcase
end

endtask

//this function take a decimal digit and return corresponding pattern on
//seven segment display
function  [6:0] give_repnew;
input number;
reg[4:0] number;
begin
	case(number)
	0:give_repnew=`zero;
	1:give_repnew=`one;
	2:give_repnew=`two;
	3:give_repnew=`three;
	4:give_repnew=`four;
	5:give_repnew=`five;
	6:give_repnew=`six;
	7:give_repnew=`seven;
	8:give_repnew=`eight;
	9:give_repnew=`nine;
	10:give_repnew=`achar;
	11:give_repnew=`bchar;
	12:give_repnew=`cchar;
	13:give_repnew=`dchar;
	14:give_repnew=`echar;
	15:give_repnew=`fchar;	
	default:give_repnew=`minus;
	endcase 
end
endfunction

endmodule
