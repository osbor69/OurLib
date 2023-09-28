unit Tone; {$S-,R-,D-,L-}

(* TONE.PAS - Sound Module for Turbo Pascal 6.0 - Turbo Vision
 * Written by Richard R. Sands
 * Compuserve ID 70274,103
 * January 1991
 *
 * NOTE: Do Not Overlay
 *)

interface

uses Windows,SysUtils,ExtCtrls;

const
	// Кузнечик
  aSndSmith: array[1..8*8*4] of ShortInt =
    // В тра-
    (10, 0,-1, 0
    //ве         си-         дел         куз-        не-         чик                     сов-
    , 5, 0,-1, 0,10, 0,-1, 0, 5, 0,-1, 0,10, 0,-1, 0, 9, 0,-1, 0, 9, 0, 0, 0,-1, 0, 0, 0, 9, 0,-1, 0
    //сем        как         о-          гу-         ре-         чик                     сов-
    , 5, 0,-1, 0, 9, 0,-1, 0, 5, 0,-1, 0, 9, 0,-1, 0,10, 0,-1, 0,10, 0, 0, 0,-1, 0, 0, 0,10, 0,-1, 0
    //сем        как         о-          гу-         ре-         чик                     зе-
    , 5, 0,-1, 0,10, 0,-1, 0, 5, 0,-1, 0,10, 0,-1, 0, 9, 0,-1, 0, 9, 0, 0, 0,-1, 0, 0, 0, 9, 0,-1, 0
    //ле-        нень-       кий         он          был                                 пред-
    , 5, 0,-1, 0, 9, 0,-1, 0, 5, 0,-1, 0, 9, 0,-1, 0,10, 0, 0, 0, 0, 0, 0, 0,-1, 0, 0, 0,10, 0,-1, 0
    //ставь-     те    се-   бе          пред-       ставь-      те    се-   бе          сов-
    ,12, 0,-1, 0,12,-1,12,-1,12, 0,-1, 0,12, 0,-1, 0,13, 0,-1, 0,13,-1,13,-1,13, 0,-1, 0,13, 0,-1, 0
    //сем        как         о-          гу-         ре-         чик                     пред-
    ,13, 0,-1, 0,12, 0,-1, 0,10, 0,-1, 0, 9, 0,-1, 0,10, 0,-1, 0,10, 0, 0, 0,-1, 0, 0, 0,10, 0,-1, 0
    //ставь-     те    се-   бе          пред-       ставь-      те    се-   бе          зе-
    ,12, 0,-1, 0,12,-1,12,-1,12, 0,-1, 0,12, 0,-1, 0,13, 0,-1, 0,13,-1,13,-1,13, 0,-1, 0,13, 0,-1, 0
    //ле-        нень-       кий         он          был
    ,13, 0,-1, 0,12, 0,-1, 0,10, 0,-1, 0, 9, 0,-1, 0,10, 0, 0, 0, 0, 0, 0, 0,-1, 0, 0, 0
    );

   Procedure Sound(Hz:Word);
   Procedure NoSound;
   Procedure Delay(MS : Word);

   Procedure Beep(Hz, MS:Word);
     { Same as
               Sound(Hz);
               Delay(MS);
               NoSound;       ...but with more efficient code. }

   Procedure BoundsBeep;
     { Used for signalling a boundry or invalid command }

   Procedure ErrorBeep;
     { Used for signalling an error condition }

   Procedure AttentionBeep;
     { Used for signalling the user }

procedure MelodyOn(const a: array of ShortInt);
procedure MelodyOff;

var MsgSound: boolean = true;

implementation

uses MyTypes,My_pr;

type
	TNone = class(TObject)
  private
		class procedure TimerSound(Sender: TObject);
		class procedure TimerSoundNT(Sender: TObject);
  end;

const
  aTone: array[1..36] of Word =
	  (131,139,147,156,165,175,185,196,208,220,233,247
    ,262,277,294,311,330,349,370,392,415,440,466,494
    ,523,554,587,622,659,698,740,784,831,880,932,988
    );

  VAR
    OneMS : Word;
    tm: TTimer;
		nSnd: longint;
    aSnd: TArrShortInt;

{ ------------------------------------------------------------- }
Procedure Beep(Hz, MS:Word); assembler;
     { Make the Sound at Frequency Hz for MS milliseconds }
  ASM
    MOV  BX,Hz
    MOV  AX,34DDH
    MOV  DX,0012H
    CMP  DX,BX
    JNC  @Stop
    DIV  BX
    MOV  BX,AX
    IN	  AL,61H
    TEST AL,3
    JNZ  @99
    OR	  AL,3
    OUT  61H,AL
    MOV  AL,0B6H
    OUT  43H,AL
 @99:
    MOV  AL,BL
    OUT  42H,AL
    MOV  AL,BH
    OUT  42H,AL
 @Stop:
 {$IFOPT G+}
    PUSH MS
 {$ELSE }
    MOV  AX, MS   { push delay time }
    PUSH AX
  {$ENDIF }
    CALL Delay    { and wait... }

    IN   AL, $61  { Now turn off the speaker }
    AND  AL, $FC
    OUT  $61, AL
  end;

{ ------------------------------------------------------------- }
Procedure BoundsBeep; assembler;
  asm
  {$IFOPT G+ }
     PUSH 1234      { Pass the Frequency }
     PUSH 10        { Pass the delay time }
  {$ELSE}
     MOV  AX, 1234  { Pass the Frequency }
     PUSH AX
     MOV  AX, 10    { Pass the delay time }
     PUSH AX
   {$ENDIF }
     CALL Beep
  end;

{ ------------------------------------------------------------- }
Procedure ErrorBeep; assembler;
  asm
  {$IFOPT G+ }
     PUSH 800   { Pass the Frequency }
     PUSH 75    { Pass the delay time }
  {$ELSE}
     MOV  AX, 800  { Pass the Frequency }
     PUSH AX
     MOV  AX, 75   { Pass the delay time }
     PUSH AX
  {$ENDIF }
     CALL Beep
  end;

{ -------------------------------------------------------------- }
Procedure AttentionBeep; assembler;
  asm
  {$IFOPT G+ }
     PUSH 660   { Pass the Frequency }
     PUSH 100    { Pass the delay time }
  {$ELSE}
     MOV  AX, 660  { Pass the Frequency }
     PUSH AX
     MOV  AX, 100   { Pass the delay time }
     PUSH AX
  {$ENDIF }
     CALL Beep
  end;

{ ------------------------------------------------------------- }
Procedure Sound(Hz:Word); assembler;
   ASM
      MOV  BX,Hz
      MOV  AX,34DDH
      MOV  DX,0012H
      CMP  DX,BX
      JNC  @DONE
      DIV  BX
      MOV  BX,AX
      IN   AL,61H
      TEST AL,3
      JNZ  @99
      OR   AL,3
      OUT  61H,AL
      MOV  AL,0B6H
      OUT  43H,AL
@99:  MOV  AL,BL
      OUT  42H,AL
      MOV  AL,BH
      OUT  42H,AL
@DONE:
  end;

{ ------------------------------------------------------------- }
Procedure NoSound; assembler;
  asm
     IN   AL, $61
     AND  AL, $FC
     OUT  $61, AL
  end;

{ ------------------------------------------------------------- }
procedure DelayOneMS; assembler;
  asm
     PUSH CX         { Save CX }
     MOV  CX, OneMS  { Loop count into CX }
  @1:
     LOOP @1         { Wait one millisecond }
     POP  CX         { Restore CX }
  end;

{ ------------------------------------------------------------- }
Procedure Delay(ms:Word); assembler;
  asm
     MOV  CX, ms
     JCXZ @2
  @1:
     CALL DelayOneMS
     LOOP @1
  @2:
  end;

{ ------------------------------------------------------------- }
Procedure Calibrate_Delay; assembler;
  asm
     MOV  AX,40h
     MOV  ES,AX
     MOV  DI,6Ch     { ES:DI is the low word of BIOS timer count }
     MOV  OneMS,55   { Initial value for One MS's time }
     XOR  DX,DX      { DX = 0 }
     MOV  AX,ES:[DI] { AX = low word of timer }
  @1:
     CMP  AX,ES:[DI] { Keep looking at low word of timer }
     JE   @1         { until its value changes... }
     MOV  AX,ES:[DI] { ...then save it }
  @2:
     CAll DelayOneMs { Delay for a count of OneMS (55) }
     INC  DX         { Increment loop counter }
     CMP  AX,ES:[DI] { Keep looping until the low word }
     JE   @2         { of the timer count changes again }
     MOV  OneMS, DX  { DX has new OneMS }
  end;

procedure MelodyOn;
var i,j: longint;
begin
	AddStack('Tone.MelodyOn');
  if MsgSound then begin
  	SetLength(aSnd,Length(a)); j:=low(aSnd);
    for i:=low(a) to high(a) do begin
    	aSnd[j]:=a[i]; Inc(j);
    end;
    tm:=TTimer.Create(nil); nSnd:=low(aSnd);
    if Win32Platform=VER_PLATFORM_WIN32_NT then begin
      tm.Interval:=50; tm.OnTimer:=TNone.TimerSoundNT;
    end
    else begin
      tm.Interval:=30; tm.OnTimer:=TNone.TimerSound;
    end;
  end;
  DelStack;
end;

procedure MelodyOff;
begin
	AddStack('Tone.MelodyOff');
  FreeAndNil(tm);
  if MsgSound and (Win32Platform<>VER_PLATFORM_WIN32_NT) then NoSound;
  DelStack;
end;

class procedure TNone.TimerSound;
begin
  AddStack('TNone.TimerSound');
  with TTimer(Sender) do begin
    Enabled:=false;
    if aSnd[nSnd]>0 then Sound(aTone[12+aSnd[nSnd]])
    else if aSnd[nSnd]<0 then NoSound;
    if nSnd=high(aSnd) then nSnd:=low(aSnd) else Inc(nSnd);
  	Enabled:=true;
  end;
  DelStack;
end;

class procedure TNone.TimerSoundNT;
var n: longint;
begin
	AddStack('TNone.TimerSoundNT');
  if aSnd[nSnd]>0 then with TTimer(Sender) do begin
  	Enabled:=false; n:=nSnd;
    while (nSnd<=high(aSnd)) and (aSnd[nSnd]>=0) do Inc(nSnd);
    Windows.Beep(aTone[12+aSnd[n]],Interval*longword(nSnd-n));
    if nSnd>high(aSnd) then nSnd:=low(aSnd);
  	Enabled:=true;
  end
  else Inc(nSnd);
  DelStack;
end;

initialization
  //Calibrate_Delay
end.
