unit Cpu;

interface

  procedure CpuReset;
  function CpuRun : integer;


implementation

  uses Def, Decoder, Srcdst;


  procedure CpuReset;
  begin
    cpuctrl := $0500;
    RTT_flag := false;
    WAIT_flag := false;
    STEP_flag := false;
    RESET_flag := true;
    HALT_i := false;
    EVNT_i := false;
    cpc := cpc and $FFFE;
{ reset vector }
    loc := $0000 + (SEL and $FF00);
    ptrw(@reg[R7])^ := ptrw(SrcPtr)^ and $FFFE;
    Inc (loc, 2);
    psw := ptrw(SrcPtr)^;
  end {CpuReset};


{ execute a single instruction, returns the number of clock cycles }
  function CpuRun : integer;
  var
    vector: word;
  begin
{ optional clock frequency divider }
    if (cpuctrl and $0800) = 0 then CpuRun := 8 else CpuRun := 1;
{ start the CPU clock when any key pressed }
    if (KeyCode1 <> 0) or (KeyCode2 <> 0) then
        cpuctrl := cpuctrl or $0400;
{ CPU clock running? }
    if (cpuctrl and $0400) = 0 then exit;
{ pending hardware interrupt? }
    if HALT_i or EVNT_i then WAIT_flag := false;
    if STEP_flag or ((psw and H_bit) <> 0) then HALT_i := false;
    STEP_flag := false;
    if WAIT_flag then exit;

{ handle the EVNT interrupt }
    if EVNT_i and ((psw and I_bit) = 0) then
    begin
      vector := $0040;
      EVNT_i := false;
    end
    else
    begin

{ handle the HALT interrupt }
      if HALT_i then
      begin
        code := $0000;			{ instruction HALT }
        HALT_i := false;
      end
      else
      begin
        opt := WORDSIZE;
        GetLoc ($17);
        code := ptrw(SrcPtr)^;		{ instruction pointed to by the PC }
      end {if};

{ execute the instruction }
      vector := Make_DC0;
      ptrw(@reg[R7])^ := ptrw(@reg[R7])^ and $FFFE;
{ trace mode? }
      if ((psw and T_bit) <> 0) and (vector = 0) and not RTT_flag then
	vector := $000C;
    end {if};

{ execute an optional trap }
    if vector <> 0 then
    begin
      opt := WORDSIZE;
      GetLoc ($26);				{ SP <- SP-2 }
      loc := loc and $FFFE;
      ptrw(DstPtr)^ := psw;			{ (SP) <- PSW }
      GetLoc ($26);				{ SP <- SP-2 }
      ptrw(DstPtr)^ := ptrw(@reg[R7])^;		{ (SP) <- PC }
      loc := vector and $FFFE;
      if (psw and H_bit) <> 0 then Inc (loc, SEL and $FF00);
      ptrw(@reg[R7])^ := ptrw(SrcPtr)^ and $FFFE; { PC <- (vector) }
      Inc (loc, 2);
      psw := ptrw(SrcPtr)^;			{ PSW <- (vector+2) }
    end {if};

    RTT_flag := false;
  end {CpuRun};

end.
