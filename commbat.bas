DECLARE SUB FireShell (Where%)
DECLARE FUNCTION Rmd! (x%)
DECLARE SUB PlaceEnemy ()
DECLARE SUB FireDrone ()
DECLARE SUB DropDecoy ()
DECLARE SUB GetDecoy ()
DECLARE SUB DropMine (Howmany%)
DECLARE SUB GetShell (Howmany%)
DECLARE SUB GetLazer (Howmany%)
DECLARE SUB Msg (Txt$)
DECLARE SUB GetMine (Howmany%)
DECLARE SUB UpDateTank2 (V%)
DECLARE SUB UpDateBase ()
DECLARE SUB UpdateDecoy (Number%)
DECLARE SUB GetMap (Maps%)
DECLARE SUB DoCmd ()
DECLARE FUNCTION GetKey% ()
DECLARE SUB UpDateTank (Number%)
DECLARE SUB MoveText (OrgX1%, OrgY1%, OrgX2%, OrgY2%, NewX1%, NewY1%)
DECLARE SUB Clrtxt ()
DECLARE SUB Initgame ()
DECLARE SUB Cursor (a%, b%)
DECLARE SUB Views ()
DECLARE SUB Remote ()
DECLARE SUB EraseTank (Tank%)
DECLARE SUB Convert (Y%, x%, Map%)
DECLARE SUB Showtank (Tank%)
DECLARE SUB Tankview (Tank%)
DECLARE SUB Baseview ()
DECLARE SUB Decoyview (Decoy%)
DECLARE SUB Drawscr ()
DECLARE SUB Movetank (Direction%)
DECLARE SUB Box (Y1%, X1%, Y2%, X2%)
DECLARE SUB PrintAT (Row%, Column%, Text$)
DECLARE FUNCTION Badmove% (Direction%)
REM $INCLUDE: 'Baswiz.Bi'
CLS

REM *********************************************************************
REM ***Comm-Bat a two player tank game  by Jim Veneskey 12-18-89 (c)  ***
REM *********************************************************************

REM /* All Global Variables Are Defined Here */

DIM SHARED BigMap(84, 84) AS STRING * 1, MineField%(84, 84)
DIM SHARED BigWas(4) AS STRING * 25
DIM SHARED TankX%(8), TankY%(8), TankM%(8), Twas$(8), Hold%(8)
DIM SHARED DecoyX%(3), DecoyY%(3), DecoyM%(3), US$, Drones%, Nukes%
DIM SHARED Shields%(9), Mines%(11), Shells%(11), Lazers%(11), Dekes%(8), Map%
DIM SHARED BaseX%, BaseY%, BaseM%, RealX%, RealY%, ZX%, Tank%, Decoy%, Cmd$
DIM SHARED BaseRY%, BaseRX%, EBaseX%, EBaseY%, EBaseM%, EDecoyX%(3)
DIM SHARED EDecoyY%(3), EDecoyM%(3), ShellRange%, ETankX%(8), ETankY%(8)
DIM SHARED ETankM%(8), ETwas$(8)

DIM Loopy%, Loopx%, Keyin%

CONST UP = 1
CONST Down = 2
CONST Left = 3
CONST Right = 4
CONST MyMask = &HF
CONST EnemyMask = &HF0
DEF SEG = &HB800
Tank% = 1: Decoy% = 1: Map% = 1
ShellRange% = 3
US$ = "##  ##  # ### ### ### ###  #"

REM /* Initialize BigMap array to all blanks     */
	FOR Loopy% = 1 TO 84
	    FOR Loopx% = 1 TO 84
		  BigMap$(Loopy%, Loopx%) = " "
	    NEXT
	NEXT

REM *** Add Borders
	FOR Loopy% = 1 TO 2
	    FOR Loopx% = 1 TO 84
	       BigMap$(Loopy%, Loopx%) = "#"
	       BigMap$(Loopy% + 82, Loopx%) = "#"
	    NEXT
	NEXT


	FOR Loopx% = 1 TO 2
	   FOR Loopy% = 1 TO 84
	    BigMap$(Loopy%, Loopx%) = "#"
	    BigMap$(Loopy%, Loopx% + 82) = "#"
	    NEXT
	NEXT
	


	FOR Loopx% = 1 TO 8
	   Shields%(Loopx%) = 100
	   Hold%(Loopx%) = 300
	   Twas$(Loopx%) = "B"
	NEXT
	
	Shields%(0) = 500
	Mines%(0) = 300
	Shells%(0) = 300
	Lazers%(0) = 300
	Dekes%(0) = 3
	Drones% = 3
	Nukes% = 1


REM /*********** Main programming starts here ***********/


	CALL Drawscr
	CALL Initgame
	CALL Cursor(1, 0)
	CALL Views

REM Delete Following REMs for Drone Testing Only!     

REM FOR Y% = 5 TO 15
    REM     FOR x% = 25 TO 35
	REM         CALL convert(Y%, x%, 7)
	REM         BigMap$(RealY%, RealX%) = "J"
      REM   NEXT
REM NEXT



	WHILE (1 = 1)
	
	Keyin% = GetKey%
	SELECT CASE Keyin%
		
		CASE 172: CALL Movetank(UP)
		CASE 180: CALL Movetank(Down)
		CASE 175: CALL Movetank(Left)
		CASE 177: CALL Movetank(Right)
		CASE 182: CALL Clrtxt

	END SELECT
       
	CALL Remote
	WEND

CALL Cursor(12, 13): REM      /* Show Cursor */
REM is this the
END

FUNCTION Badmove% (Direction%)
REM /* This function tests the legality of a move - if it will hit a wall. */
CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))

SELECT CASE Direction%
CASE UP:    IF VAL(BigMap$(RealY% - 1, RealX%)) > 0 THEN Badmove% = 3: GOTO BadOut
CASE Down:  IF VAL(BigMap$(RealY% + 1, RealX%)) > 0 THEN Badmove% = 3: GOTO BadOut
CASE Left:  IF VAL(BigMap$(RealY%, RealX% - 1)) > 0 THEN Badmove% = 3: GOTO BadOut
CASE Right: IF VAL(BigMap$(RealY%, RealX% + 1)) > 0 THEN Badmove% = 3: GOTO BadOut
END SELECT

	IF (Direction% = Left AND TankX%(Tank%) > 1) THEN
	    Badmove% = 0: EXIT FUNCTION: REM  GOTO BadOut
	    END IF
       
	IF (Direction% = Left AND (1 - (TankM%(Tank%) MOD 2))) THEN
	      CALL EraseTank(Tank%)
	      TankX%(Tank%) = 40
	      TankM%(Tank%) = TankM%(Tank%) - 1
	      Badmove% = 2: EXIT FUNCTION: GOTO BadOut
	    END IF
	   
	    IF (Direction% = Left) THEN
	      Badmove% = 1: EXIT FUNCTION: GOTO BadOut
	      END IF

	IF (Direction% = Right AND TankX%(Tank%) < 40) THEN
	    Badmove% = 0: EXIT FUNCTION: GOTO BadOut
	    END IF

	IF (Direction% = Right AND (TankM%(Tank%) MOD 2)) THEN
	      CALL EraseTank(Tank%)
	      TankX%(Tank%) = 1
	      TankM%(Tank%) = TankM%(Tank%) + 1
	      Badmove% = 2: EXIT FUNCTION: GOTO BadOut
	     END IF

	IF (Direction% = Right) THEN
	      Badmove% = 1: EXIT FUNCTION: GOTO BadOut
	      END IF

	IF (Direction% = UP AND TankY%(Tank%) > 1) THEN
	      Badmove% = 0: EXIT FUNCTION: GOTO BadOut
	      END IF

	IF (Direction% = UP AND TankM%(Tank%) > 2) THEN
	      CALL EraseTank(Tank%)
	      TankY%(Tank%) = 20
	      TankM%(Tank%) = TankM%(Tank%) - 2
	      Badmove% = 2: EXIT FUNCTION: GOTO BadOut
	      END IF

	IF (Direction% = UP) THEN
	      Badmove% = 1: EXIT FUNCTION: GOTO BadOut
	      END IF


	IF (Direction% = Down AND TankY%(Tank%) < 20) THEN
	      Badmove% = 0: EXIT FUNCTION: GOTO BadOut
	      END IF

	IF (Direction% = Down AND TankM%(Tank%) < 7) THEN
	      CALL EraseTank(Tank%)
	      TankY%(Tank%) = 1
	      TankM%(Tank%) = TankM%(Tank%) + 2
	      Badmove% = 2: EXIT FUNCTION: GOTO BadOut
	      END IF
	      
	IF (Direction% = Down) THEN
	      Badmove% = 1: EXIT FUNCTION: GOTO BadOut
	      END IF

BadOut:
END FUNCTION

SUB Baseview
REM /* Update Base viewport */
       
	FOR x% = 0 TO 4
	   FOR Y% = 0 TO 4
	     LOCATE 17 + Y%, 17 + x%
	     PRINT BigMap$(BaseRY% - 2 + Y%, BaseRX% - 2 + x%);
	   NEXT
	NEXT

END SUB

SUB Clrtxt
REM /* This routine simply clears out the old messages */

	LOCATE 24, 3
	PRINT "                                            ";

END SUB

SUB Convert (Y%, x%, Map%)
REM /* Convert Tank Psuedo co-ords into actual BigMap Co-ords */
	IF (Map% MOD 2) THEN RealX% = x% + 2 ELSE RealX% = x% + 42
	RealY% = Y% + 2 + ((INT((Map% + 1) / 2) - 1) * 20)

END SUB

SUB Cursor (a%, b%)
REM /* Cursor - adjusts the size of cursor in scan lines */
REM char a,b;
REM
REM         union REGS r;
REM         r.h.ah = 1;
REM         r.h.ch = a;
REM         r.h.cl = b;
REM         int86(0x10,&r,&r);
REM         return(0);
REM

END SUB

SUB Decoyview (Decoy%)
REM /* Update Decoy viewport */
IF DecoyM%(Decoy%) = 0 THEN GOTO DecoyOut
	CALL Convert(DecoyY%(Decoy%), DecoyX%(Decoy%), DecoyM%(Decoy%))
	FOR x% = 0 TO 4
	   FOR Y% = 0 TO 4
	      LOCATE 17 + Y%, 5 + x%
	      PRINT BigMap$(RealY% - 2 + Y%, RealX% - 2 + x%);
	   NEXT
	NEXT
DecoyOut:
LOCATE 16, 8: PRINT CHR$(48 + Decoy%);
END SUB

SUB DoCmd
Ok% = 0
STATIC LastCmd$
LOCATE 14, 2
Cmd$ = LTRIM$(Cmd$)
LOCATE 14, 2: IF LEN(Cmd$) = 0 THEN CALL PrintAT(14, 2, "*** Invalid Command ***"): GOTO DoOut
Cmd$ = UCASE$(Cmd$)
IF Cmd$ = "QUIT" THEN STOP
IF Cmd$ = "R" THEN Cmd$ = LastCmd$
IF LEFT$(Cmd$, 2) = "SM" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 AND Parm% < 9 THEN CALL GetMap(Parm%): Ok% = 1
IF LEFT$(Cmd$, 2) = "ST" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 AND Parm% < 9 THEN Tank% = Parm%: CALL Views: CALL UpDateTank2(Tank%): Ok% = 1
IF LEFT$(Cmd$, 2) = "SD" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 AND Parm% < 4 THEN Decoy% = Parm%: CALL Views: CALL UpdateDecoy(Decoy%): Ok% = 1
IF LEFT$(Cmd$, 2) = "LM" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 THEN CALL GetMine(Parm%): Ok% = 1
IF LEFT$(Cmd$, 2) = "DM" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 THEN CALL DropMine(Parm%): Ok% = 1
IF LEFT$(Cmd$, 2) = "LS" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 THEN CALL GetShell(Parm%): Ok% = 1
IF LEFT$(Cmd$, 2) = "LL" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 THEN CALL GetLazer(Parm%): Ok% = 1
IF LEFT$(Cmd$, 2) = "LD" THEN CALL GetDecoy: Ok% = 1
IF LEFT$(Cmd$, 2) = "DD" THEN Ok% = 1: CALL DropDecoy: REM ELSE CALL Msg("No Decoys Carried!!!")
IF LEFT$(Cmd$, 2) = "FD" THEN Ok% = 1: CALL FireDrone
IF LEFT$(Cmd$, 2) = "FS" THEN Parm% = VAL(RIGHT$(Cmd$, 1)): IF Parm% > 0 THEN CALL FireShell(Parm%): Ok% = 1
LastCmd$ = Cmd$
IF Ok% = 0 THEN CALL PrintAT(14, 2, "*** Invalid Command ***"): GOTO DoOut
LOCATE 14, 2: PRINT "Command Processed      "
DoOut:
END SUB

SUB Drawscr
REM /*  This routine calls other routines to set up the main game screen */

	CALL Box(39, 1, 80, 22)
	CALL Box(4, 16, 10, 22)
	CALL Box(16, 16, 22, 22)
	CALL Box(28, 16, 34, 22)
	CALL Box(1, 1, 38, 15)
	CALL Box(2, 23, 79, 25)
	CALL PrintAT(1, 53, "[ Main Map ]")
	CALL PrintAT(22, 54, "[ Map # 1 ]")
	CALL PrintAT(1, 6, "[ Comm-Bat Command Listing ]")
	CALL PrintAT(23, 34, "[ Messages ]")
	CALL PrintAT(16, 5, "[D-1]")
	CALL PrintAT(16, 17, "[ B ]")
	CALL PrintAT(16, 29, "[ T ]")

LOCATE 2, 8: PRINT "XX  YY  M SHL MIN SHE LAZ DEC";
LOCATE 3, 2: PRINT "BASE  ##  ##  # ### ### ### ###  #";
LOCATE 4, 2: PRINT "TANK  ##  ##  # ### ### ### ###  #";
LOCATE 5, 2: PRINT "DECOY ##  ##  # ### ### ### ###  #";
LOCATE 7, 2: PRINT "DRONES #";
LOCATE 8, 2: PRINT "NUKES  #";
FOR scrs% = 1 TO 7
PCOPY 0, scrs%
SCREEN , , scrs%, scrs%
LOCATE 22, 62: PRINT CHR$(49 + scrs%);
NEXT
SCREEN , , 0, 0
END SUB

SUB DropDecoy

REM **** Is Tank Attempting to Drop Decoy Into Base? ****

IF (TankX%(Tank%) = BaseX%) AND (TankY%(Tank%) = BaseY%) AND (TankM%(Tank%) = BaseM%) THEN
    FOR d% = 1 TO 3
    IF (DecoyX%(d%) = Tank%) THEN Q% = d%
    NEXT d%
    IF Q% = 0 THEN CALL Msg("No Decoy Carried"): GOTO DropDOut
    Dekes%(Tank%) = 0: Dekes%(0) = Dekes%(0) + 1
    Hold%(Tank%) = Hold%(Tank%) + 200
    DecoyM%(Q%) = BaseM%: DecoyX%(Q%) = BaseX%: DecoyY%(Q%) = BaseY%
    REM CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
    IF Decoy% = Q% THEN CALL UpdateDecoy(Q%)
    CALL UpDateBase
    CALL UpDateTank2(Tank%)
    GOTO DropDOut
    END IF

REM **** Is Tank Attempting to Drop Decoy Into Another Decoy? ****

FOR d% = 1 TO 3
	IF (TankX%(Tank%) = DecoyX%(d%)) AND (TankY%(Tank%) = DecoyY%(d%)) AND (TankM%(Tank%) = DecoyM%(d%)) THEN Q% = d%
NEXT d%
IF Q% = 0 THEN GOTO DropDeke
CALL Msg("Cannot Store Decoys In Decoys!!!"): GOTO DropDOut

REM **** Tank Is Attempting to Drop Decoy in Open Area ****

DropDeke:
FOR d% = 1 TO 3
	IF (DecoyM%(d%) = 0) AND (DecoyX%(d%) = Tank%) THEN Q% = d%
NEXT d%
IF Q% = 0 THEN CALL Msg("Not Carrying A Decoy!!!"): GOTO DropDOut
DecoyX%(Q%) = TankX%(Tank%): DecoyY%(Q%) = TankY%(Tank%): DecoyM%(Q%) = TankM%(Tank%)
Twas$(Tank%) = "D"
Dekes%(Tank%) = 0
IF Q% = Decoy% THEN CALL UpdateDecoy(Q%)
CALL UpDateTank2(Tank%)
CALL Msg("Decoy Successfully Dropped")
Hold%(Tank%) = Hold%(Tank%) + 200
DropDOut:

END SUB

SUB DropMine (Howmany%)
IF (TankX%(Tank%) = BaseX%) AND (TankY%(Tank%) = BaseY%) AND (TankM%(Tank%) = BaseM%) THEN
    CALL Msg("Stored Mines In Base")
    IF Mines%(Tank%) < Howmany% THEN Howmany% = Mines%(Tank%)
    Mines%(Tank%) = Mines%(Tank%) - Howmany%: Mines%(0) = Mines%(0) + Howmany%
    Hold%(Tank%) = Hold%(Tank%) + 10 * Howmany%
    CALL UpDateBase
    CALL UpDateTank2(Tank%)
    GOTO DropOut
    END IF
FOR d% = 1 TO 3
	IF (TankX%(Tank%) = DecoyX%(d%)) AND (TankY%(Tank%) = DecoyY%(d%)) AND (TankM%(Tank%) = DecoyM%(d%)) THEN Q% = d%
NEXT d%
IF Q% = 0 THEN GOTO Dropped
CALL Msg("Stored Mines In Decoy")
IF Mines%(Tank%) < Howmany% THEN Howmany% = Mines%(Tank%)
Mines%(Tank%) = Mines%(Tank%) - Howmany%: Mines%(Q% + 8) = Mines%(Q% + 8) + Howmany%
Hold%(Tank%) = Hold%(Tank%) + 10 * Howmany%
IF Decoy% = Q% THEN CALL UpdateDecoy(Q%)
CALL UpDateTank2(Tank%)
GOTO DropOut
Dropped:  
REM  Not on the Base or a Decoy, must be making a minefield!
IF Howmany% > Mines%(Tank%) THEN Howmany% = Mines%(Tank%)
Mines%(Tank%) = Mines%(Tank%) - Howmany%
IF Howmany% = 0 THEN GOTO DropOut
CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))

REM My Mines are in the low nibble, minimum 0, Max 15
REM Enemy Mines are in High Nibble, same range.
REM If I allowed placement of 16+ mines they'd be in the high nibble
REM and would allow player to blow self up! (Lay enemies mines!)

IF (MineField%(RealY%, RealX%) AND MyMask) < 15 THEN
    MineField%(RealY%, RealX%) = MineField%(RealY%, RealX%) + 1
END IF

Twas$(Tank%) = "+": REM When Tank Moves It Updates the Viewing Map...
REM BigMap$(RealY%, RealX%) = "+"
Hold%(Tank%) = Hold%(Tank%) + 10 * Howmany%
CALL Msg("Mine Dropped Successfully.")
CALL UpDateTank2(Tank%)
DropOut:
END SUB

SUB EraseTank (Tank%)
REM /*  ERASETANK(tank #) - removes old image of tanks from screen */
	CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
	BigMap$(RealY%, RealX%) = Twas$(Tank%)
	IF (TankM%(Tank%) = Map%) THEN
	LOCATE TankY%(Tank%) + 1, TankX%(Tank%) + 39
	PRINT Twas$(Tank%);
	END IF

END SUB

SUB FireDrone
BB% = 0
IF Drones% = 0 THEN CALL Msg("All Out Of Drones!!!"): EXIT SUB
REM Parse Drone Target from Cmd$
Fs% = INSTR(Cmd$, " "): IF Fs% = 0 THEN CALL Msg("Use Correct Targetting Format!!!"): EXIT SUB
Fc% = INSTR(Cmd$, ","): IF Fc% = 0 THEN CALL Msg("Use Correct Targetting Format!!!"): EXIT SUB
Sc% = INSTR(Fc% + 1, Cmd$, ","): IF Fc% = 0 THEN CALL Msg("Use Correct Targetting Format!!!"): EXIT SUB

TX% = VAL(MID$(Cmd$, Fs%, Fc% - 1))
TY% = VAL(MID$(Cmd$, Fc% + 1, Sc% - 1))
Tm% = VAL(MID$(Cmd$, Sc% + 1))

IF TX% < 1 OR TX% > 40 THEN BB% = 1
IF TY% < 1 OR TY% > 20 THEN BB% = 1
IF Tm% < 1 OR Tm% > 8 THEN BB% = 1
IF BB% = 1 THEN CALL Msg("Use Correct Range For Co-Ordinates!!!"): EXIT SUB
REM /* Updates Display Using Remote Drone */
     
IF Tm% <> Map% THEN SCREEN , , Tm% - 1, Map% - 1
	IF (TX% = 1) THEN
	   a% = 0
	ELSEIF TX% = 2 THEN
	   a% = 1
	ELSE
	   a% = 2
	END IF

	IF (TX% = 40) THEN
	   c% = 0
	ELSEIF TX% = 39 THEN
	   c% = 1
	ELSE
	   c% = 2
	END IF

	IF (TY% = 1) THEN
	   b% = 0
	ELSEIF (TY% = 2) THEN
	   b% = 1
	ELSE
	   b% = 2
	END IF

	IF (TY% = 20) THEN
	   d% = 0
	ELSEIF (TY% = 19) THEN
	   d% = 1
	ELSE
	   d% = 2
	END IF

FOR ze% = TX% - a% TO TX% + c%
	FOR zf% = TY% - b% TO TY% + d%
		LOCATE zf% + 1, ze% + 39
		CALL Convert(zf%, ze%, Tm%)
		PRINT BigMap$(RealY%, RealX%);
		REM PRINT "*";
	NEXT
NEXT

SCREEN , , Map% - 1, Map% - 1
END SUB

SUB FireShell (Where%)
IF Shells%(Tank%) = 0 THEN CALL Msg("No Ammo!!!"): EXIT SUB
IF Where% > 0 AND (Where% AND 1) THEN CALL Msg("Illegal Direction Specified!!!"): EXIT SUB
Shells%(Tank%) = Shells%(Tank%) - 1
REM call UpdateTank2
CALL Msg("Shell Fired.")
CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
XDisp% = 0: YDisp% = 0
IF Where% = 8 THEN YDisp% = -1
IF Where% = 2 THEN YDisp% = 1
IF Where% = 4 THEN XDisp% = -1
IF Where% = 6 THEN XDisp% = 1
    
    
  FOR Range% = 1 TO ShellRange%
	NewX% = RealX% + XDisp% * Range%: NewY% = RealY% + YDisp% * Range%
	IF MineField%(NewY%, NewX%) > 15 THEN
	   MineField%(NewY%, NewX%) = MineField%(NewY%, NewX%) - 16
	   CALL Msg("Explosion Detected!"): EXIT FOR
	END IF
  NEXT

END SUB

SUB GetDecoy
IF (TankX%(Tank%) = BaseX%) AND (TankY%(Tank%) = BaseY%) AND (TankM%(Tank%) = BaseM%) THEN
    FOR d% = 1 TO 3
    IF (DecoyX%(d%) = BaseX%) AND (DecoyY%(d%) = BaseY%) AND (DecoyM%(d%) = BaseM%) THEN Q% = d%
    NEXT d%
    IF Q% = 0 THEN CALL Msg("No Decoys In Base"): GOTO DekeOut
    IF 200 > Hold%(Tank%) THEN CALL Msg("Decoys Take 200 Space, Tank Only Has" + STR$(Hold%(Tank%))): GOTO DekeOut
    Dekes%(Tank%) = 1: Dekes%(0) = Dekes%(0) - 1
    Hold%(Tank%) = Hold%(Tank%) - 200
    DecoyM%(Q%) = 0: DecoyX%(Q%) = Tank%
    CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
    IF Decoy% = Q% THEN CALL UpdateDecoy(Q%)
    CALL UpDateBase
    CALL UpDateTank2(Tank%)
    GOTO DekeOut
    END IF
FOR d% = 1 TO 3
	IF (TankX%(Tank%) = DecoyX%(d%)) AND (TankY%(Tank%) = DecoyY%(d%)) AND (TankM%(Tank%) = DecoyM%(d%)) THEN Q% = d%
NEXT d%
IF Q% = 0 THEN GOTO NoDekes
IF 200 > Hold%(Tank%) THEN CALL Msg("Decoys Take 200 Spaces, Tank Only Has" + STR$(Hold%(Tank%))): GOTO DekeOut
CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%)): Dekes%(Tank%) = 1: BigMap$(RealY%, RealX%) = CHR$(48 + Tank%): Twas$(Tank%) = " "
Hold%(Tank%) = Hold%(Tank%) - 200
DecoyM%(Q%) = 0: DecoyX%(Q%) = Tank%
IF Decoy% = Q% THEN CALL UpdateDecoy(Q%)
CALL UpDateTank2(Tank%)
GOTO DekeOut
NoDekes:  
CALL Msg(""): CALL Msg("No Decoys Out Here!!!")
DekeOut:

END SUB

FUNCTION GetKey%
j$ = INKEY$: IF j$ = "" THEN GetKey% = 255: GOTO GetKeyOut

IF LEN(j$) = 2 THEN
       j$ = RIGHT$(j$, 1)
       GetKey% = 100 + ASC(j$)
       LOCATE 1, 1
       PRINT ASC(j$);
       GOTO GetKeyOut
       END IF

IF j$ = CHR$(8) AND LEN(Cmd$) > 0 THEN Cmd$ = LEFT$(Cmd$, LEN(Cmd$) - 1): GetKey% = 0: GOTO ShowCmd
IF j$ = CHR$(13) THEN CALL DoCmd: Cmd$ = "": j$ = ""
IF LEN(Cmd$) = 20 THEN GOTO GetKeyOut
Cmd$ = Cmd$ + j$
ShowCmd:
LOCATE 13, 2: PRINT "Cmd>                     "; : LOCATE 13, 7: PRINT Cmd$; CHR$(95);
GetKeyOut:
END FUNCTION

SUB GetLazer (Howmany%)
IF (TankX%(Tank%) = BaseX%) AND (TankY%(Tank%) = BaseY%) AND (TankM%(Tank%) = BaseM%) THEN
    IF Howmany% * 30 > Hold%(Tank%) THEN CALL Msg("Space on Tank Only" + STR$(Hold%(Tank%))): GOTO GetMOut
    IF Lazers%(0) < Howmany% THEN Howmany% = Lazers%(0)
    Lazers%(Tank%) = Lazers%(Tank%) + Howmany%: Lazers%(0) = Lazers%(0) - Howmany%
    Hold%(Tank%) = Hold%(Tank%) - 30 * Howmany%
    CALL UpDateBase
    CALL UpDateTank2(Tank%)
    GOTO GetMOut
    END IF
FOR d% = 1 TO 3
	IF (TankX%(Tank%) = DecoyX%(d%)) AND (TankY%(Tank%) = DecoyY%(d%)) AND (TankM%(Tank%) = DecoyM%(d%)) THEN Q% = d%
NEXT d%
IF Q% = 0 THEN GOTO Bomber
IF Howmany% * 30 > Hold%(Tank%) THEN CALL Msg("Space On Tank Only" + STR$(Hold%(Tank%))): GOTO GetMOut
IF Lazers%(Q% + 8) < Howmany% THEN Howmany% = Lazers%(Q% + 8)
Lazers%(Tank%) = Lazers%(Tank%) + Howmany%: Lazers%(Q% + 8) = Lazers%(Q% + 8) - Howmany%
Hold%(Tank%) = Hold%(Tank%) - 30 * Howmany%
IF Decoy% = Q% THEN CALL UpdateDecoy(Q%)
CALL UpDateTank2(Tank%)
GOTO GetMOut
Bomber:  
CALL Msg(""): CALL Msg("LOAD LAZERS FROM DECOYS OR BASE ONLY!")
GetMOut:

END SUB

SUB GetMap (Mapps%)
 IF TankM%(Tank%) = Map% THEN
 IF TankX%(Tank%) THEN LOCATE TankY%(Tank%) + 1, TankX%(Tank%) + 39: PRINT Twas$(Tank%);
 END IF
 Map% = Mapps%
 SCREEN , , Mapps% - 1, Mapps% - 1
 CALL UpdateDecoy(Decoy%)
 CALL UpDateTank2(Tank%)
 CALL UpDateBase
 IF TankX%(Tank%) THEN CALL Views
END SUB

SUB GetMine (Howmany%)
IF (TankX%(Tank%) = BaseX%) AND (TankY%(Tank%) = BaseY%) AND (TankM%(Tank%) = BaseM%) THEN
    IF Howmany% * 10 > Hold%(Tank%) THEN CALL Msg("Space on Tank Only" + STR$(Hold%(Tank%))): GOTO GetMyOut
    IF Mines%(0) < Howmany% THEN Howmany% = Mines%(0)
    Mines%(Tank%) = Mines%(Tank%) + Howmany%: Mines%(0) = Mines%(0) - Howmany%
    Hold%(Tank%) = Hold%(Tank%) - 10 * Howmany%
    CALL UpDateBase
    CALL UpDateTank2(Tank%)
    GOTO GetMyOut
    END IF
FOR d% = 1 TO 3
	IF (TankX%(Tank%) = DecoyX%(d%)) AND (TankY%(Tank%) = DecoyY%(d%)) AND (TankM%(Tank%) = DecoyM%(d%)) THEN Q% = d%
NEXT d%
IF Q% = 0 THEN GOTO Bombed
IF Howmany% * 10 > Hold%(Tank%) THEN CALL Msg("Space On Tank Only" + STR$(Hold%(Tank%))): GOTO GetMyOut
IF Mines%(Q% + 8) < Howmany% THEN Howmany% = Mines%(Q% + 8)
Mines%(Tank%) = Mines%(Tank%) + Howmany%: Mines%(Q% + 8) = Mines%(Q% + 8) - Howmany%
Hold%(Tank%) = Hold%(Tank%) - 10 * Howmany%
IF Decoy% = Q% THEN CALL UpdateDecoy(Q%)
CALL UpDateTank2(Tank%)
GOTO GetMyOut
Bombed:     
CALL Msg(""): CALL Msg("LOAD MINES FROM DECOYS OR BASE ONLY!")
GetMyOut:
END SUB

SUB GetShell (Howmany%)
IF (TankX%(Tank%) = BaseX%) AND (TankY%(Tank%) = BaseY%) AND (TankM%(Tank%) = BaseM%) THEN
    IF Howmany% * 20 > Hold%(Tank%) THEN CALL Msg("Space on Tank Only" + STR$(Hold%(Tank%))): GOTO GetsOut
    IF Shells%(0) < Howmany% THEN Howmany% = Shells%(0)
    Shells%(Tank%) = Shells%(Tank%) + Howmany%: Shells%(0) = Shells%(0) - Howmany%
    Hold%(Tank%) = Hold%(Tank%) - 20 * Howmany%
    CALL UpDateBase
    CALL UpDateTank2(Tank%)
    GOTO GetsOut
    END IF
FOR d% = 1 TO 3
	IF (TankX%(Tank%) = DecoyX%(d%)) AND (TankY%(Tank%) = DecoyY%(d%)) AND (TankM%(Tank%) = DecoyM%(d%)) THEN Q% = d%
NEXT d%
IF Q% = 0 THEN GOTO Bombbed
IF Howmany% * 20 > Hold%(Tank%) THEN CALL Msg("Space On Tank Only" + STR$(Hold%(Tank%))): GOTO GetsOut
IF Shells%(Q% + 8) < Howmany% THEN Howmany% = Shells%(Q% + 8)
Shells%(Tank%) = Shells%(Tank%) + Howmany%: Shells%(Q% + 8) = Shells%(Q% + 8) - Howmany%
Hold%(Tank%) = Hold%(Tank%) - 20 * Howmany%
IF Decoy% = Q% THEN CALL UpdateDecoy(Q%)
CALL UpDateTank2(Tank%)
GOTO GetsOut
Bombbed:  
CALL Msg(""): CALL Msg("LOAD SHELLS FROM DECOYS OR BASE ONLY!")
GetsOut:

END SUB

SUB Initgame
REM /* Initialize game - get base co-ordinates  */
GetCords:
	LOCATE 2, 50
	PRINT "Enter base co-ords X,Y,Map";
	LOCATE 3, 50
	INPUT BaseX%, BaseY%, BaseM%
	LOCATE 2, 50: PRINT "                            ";
	LOCATE 3, 50: PRINT "                   ";
	IF BaseX% < 1 OR BaseX% > 40 THEN GOTO GetCords
	IF BaseY% < 1 OR BaseY% > 20 THEN GOTO GetCords
	IF BaseM% < 1 OR BaseM% > 8 THEN GOTO GetCords
	Map% = BaseM%: CALL GetMap(BaseM%)
	LOCATE 3, 8: PRINT USING "##  ##  #"; BaseX%; BaseY%; BaseM%
	CALL UpdateDecoy(Decoy%)
	LOCATE 13, 2: PRINT "Cmd>";
	CALL Convert(BaseY%, BaseX%, BaseM%)
	BaseRY% = RealY%: BaseRX% = RealX%
	BigMap$(BaseRY%, BaseRX%) = "B"
	FOR loop1% = 1 TO 8
	  
	   TankX%(loop1%) = BaseX%
	   TankY%(loop1%) = BaseY%
	   TankM%(loop1%) = BaseM%
	   IF loop1% < 4 THEN
	      DecoyX%(loop1%) = BaseX%
	      DecoyY%(loop1%) = BaseY%
	      DecoyM%(loop1%) = BaseM%
REM              CALL Convert(DecoyY%(loop1%), DecoyX%(loop1%), DecoyM%(loop1%))
REM              BigMap$(RealY%, RealX%) = "D"
	   END IF
	NEXT
CALL GetMap(BaseM%)
CALL UpDateTank(Tank%)
REM the following duplicates the enemy placing his base and Decoys.
EBaseX% = Rmd(40): EBaseY% = Rmd(20): EBaseM% = Rmd(8)
FOR j% = 1 TO 3
	EDecoyX%(j%) = Rmd(40)
	EDecoyY%(j%) = Rmd(20)
	EDecoyM%(j%) = Rmd(8)
NEXT j%
CALL PlaceEnemy
END SUB

SUB Movetank (Direction%)
REM /* this routine is responsible for moving the tank if it is ok to do so */

	IF Shields%(Tank%) = 0 THEN
	  CALL Msg("")
	  CALL Msg("That Tank is dead - immobile!")
	  GOTO MoveOut
	END IF

	zq = Badmove%(Direction%): REM  0=Normal, 1=RIP, 2=New Map, 3=No Go
       
	IF zq = 3 THEN
		    CALL Msg("")
		    CALL Msg("Tanks Cannot Stack!")
		    GOTO MoveOut
		    END IF
       
IF zq <> 2 THEN CALL EraseTank(Tank%)
       
	IF zq = 1 THEN
	  
	  Shields%(Tank%) = 0
	  CALL Msg("Tank has hit map edge and exploded!")
	  CALL Msg("")
	  CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
		IF (BigMap$(RealY%, RealX%) <> "B") AND (BigMap$(RealY%, RealX%) <> "D") THEN
		BigMap$(RealY%, RealX%) = "X"
		END IF
			IF TankM%(Tank%) = Map% THEN
			LOCATE TankY%(Tank%) + 1, TankX%(Tank%) + 39
			PRINT "X";
			END IF
       CALL Views
       GOTO MoveOut
       END IF
       
	IF zq = 2 THEN
	 CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
	  CALL UpDateTank(Tank%)
	  CALL Views
	  GOTO MoveOut
	END IF

	REM if proram gets here it must be a normal move
	SELECT CASE Direction%
	  
	  CASE UP: TankY%(Tank%) = TankY%(Tank%) - 1
	  CASE Down: TankY%(Tank%) = TankY%(Tank%) + 1
	  CASE Left: TankX%(Tank%) = TankX%(Tank%) - 1
	  CASE Right: TankX%(Tank%) = TankX%(Tank%) + 1
       
	END SELECT

	CALL UpDateTank(Tank%)
	CALL Views
	GOTO MoveOut:

MoveOut:

END SUB

SUB MoveText (X1%, Y1%, X2%, Y2%, X3%, Y3%)
DEF SEG = &HB800 + &H100 * (Map% - 1)
RealAdd% = (X1% - 1) * 2 + (Y1% - 1) * 160
NewAdd% = (X3% - 1) * 2 + (Y3% - 1) * 160
Reps% = X2% - X1% + 1: Rose% = Y2% - Y1% + 1
FOR Rows% = 1 TO Rose%
FOR Time% = 1 TO Reps%
	Byte% = PEEK(RealAdd% + (Time% - 1) * 2 + 160 * (Rows% - 1))
	POKE NewAdd% + (Time% - 1) * 2 + 160 * (Rows% - 1), Byte%
NEXT
NEXT
END SUB

SUB Msg (Txt$)
CALL Clrtxt
LOCATE 24, 3: PRINT Txt$;

END SUB

SUB PlaceEnemy
FOR g% = 1 TO 4
IF g% < 4 THEN TX% = EDecoyX%(g%): TY% = EDecoyY%(g%): Tm% = EDecoyM%(g%)
IF g% = 4 THEN TX% = EBaseX%: TY% = EBaseY%: Tm% = EBaseM%
	CALL Convert(TY%, TX%, Tm%)
	TY% = RealY%: TX% = RealX%
       
	IF (TX% = 3) THEN
	   a% = 0
	ELSEIF TX% = 4 THEN
	   a% = 1
	ELSE
	   a% = 2
	END IF

	IF (TX% = 82) THEN
	   c% = 0
	ELSEIF TX% = 81 THEN
	   c% = 1
	ELSE
	   c% = 2
	END IF

	IF (TY% = 3) THEN
	   b% = 0
	ELSEIF (TY% = 4) THEN
	   b% = 1
	ELSE
	   b% = 2
	END IF

	IF (TY% = 82) THEN
	   d% = 0
	ELSEIF (TY% = 81) THEN
	   d% = 1
	ELSE
	   d% = 2
	END IF
Q% = 0
FOR ze% = TX% - a% TO TX% + c%
	FOR zf% = TY% - b% TO TY% + d%
		Q% = Q% + 1
		REM PRINT BigMap$(RealY%, RealX%);
		REM PRINT "*";
		MID$(BigWas$(g%), Q%, 1) = BigMap$(zf%, ze%)
REM                 PRINT ASC(MID$(BigWas$(g%), Q%, 1));
		BigMap$(zf%, ze%) = "B"
	NEXT
NEXT

NEXT

REM Place Sample Test Mines All Along Maps 7 & 8

FOR MX% = 1 TO 80
	FOR MY% = 61 TO 80
	   MineField%(MY% + 2, MX% + 2) = MineField%(MY% + 2, MX% + 2) + (16 * Rmd(5))
	NEXT
NEXT

END SUB

SUB PrintAT (Column%, Row%, Text$)
REM /* a print @ type of routine            */
       
	LOCATE Column%, Row%
	PRINT Text$;
END SUB

SUB Remote
REM /* Remote - this simulates tasking in background */
STATIC ZX
	ZX = ZX + 1
	IF (ZX = 100) THEN ZX = 0
	LOCATE 10, 2
	REM PRINT "Count is"; ZX; "and counting.";
	REM PRINT Dekes%(0);
	REM IF Twas$(Tank%) <> " " THEN STOP
END SUB

FUNCTION Rmd (x%)
REM This Function Simulates Level II's RND function
Rmd = INT(x% * RND + 1)

END FUNCTION

SUB Showtank (Tank%)
REM /* Displays currently selected tank IF on current map */
       
IF (TankM%(Tank%) = Map%) THEN
	
	IF (TankX%(Tank%) = 1) THEN
	   a = 0
	ELSEIF TankX%(Tank%) = 2 THEN
	   a = 1
	ELSE
	   a = 2
	END IF

	IF (TankX%(Tank%) = 40) THEN
	   c = 0
	ELSEIF TankX%(Tank%) = 39 THEN
	   c = 1
	ELSE
	   c = 2
	END IF

	IF (TankY%(Tank%) = 1) THEN
	   b = 0
	ELSEIF (TankY%(Tank%) = 2) THEN
	   b = 1
	ELSE
	   b = 2
	END IF

	IF (TankY%(Tank%) = 20) THEN
	   d = 0
	ELSEIF (TankY%(Tank%) = 19) THEN
	   d = 1
	ELSE
	   d = 2
	END IF

CALL MoveText(31 - a, 19 - b, 31 + c, 19 + d, TankX%(Tank%) + 39 - a, TankY%(Tank%) + 1 - b)


END IF

END SUB

SUB Tankview (Tank%)
REM /* Update Tank viewport                     */
	CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
	FOR x% = 0 TO 4
	   FOR Y% = 0 TO 4
	      LOCATE 17 + Y%, 29 + x%
	      PRINT BigMap$(RealY% - 2 + Y%, RealX% - 2 + x%);
	   NEXT
	NEXT
	CALL Showtank(Tank%)

END SUB

SUB UpDateBase
LOCATE 3, 8: PRINT USING US$; BaseX%; BaseY%; BaseM%; Shields%(0); Mines%(0); Shells%(0); Lazers%(0); Dekes%(0);
LOCATE 7, 8: PRINT Drones%
LOCATE 8, 8: PRINT Nukes%
END SUB

SUB UpdateDecoy (Number%)
IF DecoyM%(Number%) = 0 THEN
	LOCATE 5, 8: PRINT "--  --  -";
	LOCATE 19, 5: PRINT "O-F-F";
	GOTO UpOut
	END IF
LOCATE 5, 8: PRINT USING US$; DecoyX%(Decoy%); DecoyY%(Decoy%); DecoyM%(Decoy%); Shi%; Mines%(Decoy% + 8); Shells%(Decoy% + 8); Lazers%(Decoy% + 8); Shi%

UpOut:
END SUB

SUB UpDateTank (Number%)
REM /*  UpdateTank(tank #) - updates display of tanks moves   */
	CALL Convert(TankY%(Tank%), TankX%(Tank%), TankM%(Tank%))
      
IF (MineField%(RealY%, RealX%) AND EnemyMask) THEN
	CALL Msg("You Hit An Enemy Mine!!!"): STOP
END IF

	Twas$(Tank%) = BigMap$(RealY%, RealX%)
	IF (Twas$(Tank%) <> "B") AND (Twas$(Tank%) <> "D") THEN
	BigMap$(RealY%, RealX%) = CHR$(48 + Tank%)
	END IF
LOCATE 4, 8: PRINT USING "##  ##  #"; TankX%(Tank%); TankY%(Tank%); TankM%(Tank%);

END SUB

SUB UpDateTank2 (V%)
LOCATE 4, 8: PRINT USING US$; TankX%(V%); TankY%(V%); TankM%(V%); Shields%(V%); Mines%(V%); Shells%(V%); Lazers%(V%); Dekes%(V%);
END SUB

SUB Views
REM /* Package all view handling nice and neat */
       
	CALL Tankview(Tank%)
	CALL Baseview
	CALL Decoyview(Decoy%)

END SUB

