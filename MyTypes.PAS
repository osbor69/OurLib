unit MyTypes;
// type1,const1,type2,const2,var1

interface

{$I LIBTEST}
uses Windows,Controls,DateUtils,Forms,Graphics,Classes,DB,Math,SysUtils,Messages,StdConvs,WinSock,
  pQRCode,pPDF417Custom,Printers,ComCtrls,Grids,DBGrids,StdCtrls,SciLexerMod,SciLexerMemo,Buttons,
  Dialogs;

type //type1
  TProcNone = procedure; TArrProcNone = array of TProcNone;
  TProcObjNone = procedure of object;
	TTransEvent = function(Sender: TObject; const Value: string; Size: longint): string of object;
	TStringEvent = function(Sender: TObject = nil): string of object;
	TStringEvent0 = function: string of object;
	TProcString = function: string;
	TMaxLengthEvent = function(Sender: TObject): longint of object;
	TProcValid = function(Sender: TObject = nil): boolean of object;
	TProcValid0 = function: boolean of object;
	TFuncBool = function: boolean;
  TButClickEvent = function(Sender: TObject; lEval: boolean): string of object;
  TReplaceProc = function(const av: array of variant): TModalResult;
  TListMoveItemProc = procedure(oi,ni: longint; const av: array of variant) of object;
	TProcStrComp = function(const s1,s2: string): boolean;
  TMyMask = (mskNone,mskX,msk9,msk0,msk9X,msk0X,mskUser);
  TRszMouse = set of (rmResize,rmRemove);
  T16Colors = 0..39;
  PStringList = ^TStringList;
  PFileName = ^TFileName;
  PObject = ^TObject;
  PComponent = ^TComponent;
  PBookMark = ^TBookMark;
  TNamePrimList = 1..2;
  PNamePrimStr = ^TNamePrimStr; TNamePrimStr = array[TNamePrimList] of string;
  PArrNamePrimStr = ^TArrNamePrimStr; TArrNamePrimStr = array of TNamePrimStr;
  TMonth = 1..MonthsPerYear;
  TProcent = 0..100;
  TPrivProc = procedure(const Priv: string; var result: boolean);
  TSelProcKey = function(const s: string): string;

  TBSetList = (bsetNone,bsetFalse,bsetTrue);
  TBSetStr = array[TBSetList] of string;

  TSvScroll = record
    aobj: array of record
      obj: TScrollingWinControl;
      HorzVisible,VertVisible: boolean;
      HorzPos,VertPos: longint;
    end;
    AutoScroll: boolean;
    WindowState: TWindowState;
  end;

  PBoolSet = ^TBoolSet; TBoolSet = set of boolean;
  PByteSet = ^TByteSet; TByteSet = set of byte;
                        TCharSet = set of char;

  PArrStr  = ^TArrStr       ; TArrStr        = array of string;
                              TArrChar       = array of char;
                              TArrCard       = array of longword;
  PArrVar  = ^TArrVar       ; TArrVar        = array of variant;
  PArrBool = ^TArrBool      ; TArrBool       = array of boolean;
  PArrDbl  = ^TArrDbl       ; TArrDbl        = array of Double;
  PArrInt  = ^TArrInt       ; TArrInt        = array of longint;
                              TArrWord       = array of Word;
                              TArrByte       = array of Byte;
                              TArrShortInt   = array of ShortInt;
  PArrDate = ^TArrDate      ; TArrDate       = array of TDateTime;
                              TArrPoint      = array of TPoint;
                              TArrSize       = array of TSize;
                              TArrObject     = array of TObject;
                              TArrComponent  = array of TComponent;
                              TArrFont       = array of TFont;
  PArrStrList = ^TArrStrList; TArrStrList    = array of TStringList;
                              TArrBookMark   = array of TBookMark;
                              TArrFieldType  = array of TFieldType;
  PArrBoolSet = ^TArrBoolSet; TArrBoolSet    = array of TBoolSet;
                              TArrByteSet    = array of TByteSet;
                              TArrPointer    = array of pointer;

  PArrBoolStr     = ^TArrBoolStr      ; TArrBoolStr         = array[boolean] of string;
                                        TArrBoolChr         = array[boolean] of char;
                                        TArrBoolInt         = array[boolean] of longint;
                                        TArrBoolByte        = array[boolean] of byte;
                                        TArrBoolWord        = array[boolean] of Word;
                                        TArrBoolSign        = array[boolean] of TValueSign;
                                        TArrBoolDbl         = array[boolean] of Double;
                                        TArrBoolDate        = array[boolean] of TDateTime;
                                        TArrBoolByteSet     = array[boolean] of TByteSet;
                                        TArrBoolVar         = array[boolean] of variant;
  PArrBoolStrList = ^TArrBoolStrList  ; TArrBoolStrList     = array[boolean] of TStringList;
                                        TArrBoolField       = array[boolean] of TField;
                                        TArrBoolDateField   = array[boolean] of TDateTimeField;
                                        TArrBoolColor       = array[boolean] of TColor;
                                        TArrBoolArrStr      = array[boolean] of TArrStr;
  PArrBoolArrInt  = ^TArrBoolArrInt   ; TArrBoolArrInt      = array[boolean] of TArrInt;
                                        TArrBoolNamePrimStr = array[boolean] of TNamePrimStr;
                                        TArrBoolBoolStr     = array[boolean] of TArrBoolStr;
  PArrBoolBoolInt = ^TArrBoolBoolInt  ; TArrBoolBoolInt     = array[boolean] of TArrBoolInt;
                                        TArrBoolBoolByte    = array[boolean] of TArrBoolByte;

  PArrArrStr  = ^TArrArrStr       ; TArrArrStr     = array of TArrStr;
  PArrArrVar  = ^TArrArrVar       ; TArrArrVar     = array of TArrVar;
                                    TArrArrDbl     = array of TArrDbl;
                                    TArrArrInt     = array of TArrInt;
  PArrArrBool = ^TArrArrBool      ; TArrArrBool    = array of TArrBool;
                                    TArrArrBoolDbl = array of TArrBoolDbl;

  TArrByteStr = array[byte] of string;
  TAlgmStr = array[TAlignment] of string;

  TValueSignBool = array[TValueSign] of boolean;

	TFIniType = (fiSave,fiSchem,fiPPDoc);

  TApplHintInfo = record
  	HintStr: string;
    CanShow: Boolean;
  	HintInfo: THintInfo;
  end;

  THelpOper = (hlpFile,hlpVar,hlpTrns,hlpAdd,hlpFillType,hlpLinkObj);
  THelpFillType = (hlpftDefault,hlpftBefore,hlpftAfter);

  THelpFile = record
    sFile,sPage: string;
  end;

  THelpFileList = (hlpfBase,hlpfPrm,hlpfVar);
  THelpFileArr = array[THelpFileList] of THelpFile;

  THelpFileContext = record
    lEdit: boolean;
    f: THelpFileArr;
    Prm: variant;
  end;

  PHelpArr = ^THelpArr;
  THelpArr = array of record
    part,txt: string;
    avk: TArrVar;
  end;

  PHelpLinkList = ^THelpLinkList;
  THelpLinkList = (hlnkLink,hlnkVar,hlnkTbl,hlnkGet,hlnkTblFix,hlnkInterMemo,hlnkDfrm, {для ПМ_ВЫД(,,Вид) добавлять сюда}
    hlnkVarVal,hlnkLinkObj,hlnkFuncPart);

  THelpTbl = record
    Head,Dat0: string;
    Dat: TArrArrStr;
  end;

  THelpTblProc = procedure(const Name: string; var result: variant);

  THelpCnt = record
    lv: byte;
    nFile: longint;
    Vid: THelpLinkList;
    anm: TNamePrimStr;
    hint: string;
    FixPos: boolean;
  end;
  THelpCntArr = record
    a: array of THelpCnt;
    l: longint;
    lvbeg: byte;
  end;

  TCtrlInfOper = (ctiCount,ctiItem);

  TCalcOper = (clcBegin,clcEnd,clcGet,clcSet,clcCanSet);

  PExeInfo = ^TExeInfo;
  TExeInfo = record
  	Major,Minor,Release,Build: Word;
    ProductName,RegVers,MainVers: string;
    IsGGI: boolean;
  end;

	TDefFont = record
    Name: TFontDataName;
    Color: TColor;
    Size: longint;
    Style: TFontStyles;
    CharSet: TFontCharSet;
  end;

  TUnicodeSize = 1..2;

  PFmtZeroEmp = ^TFmtZeroEmp;
  TFmtZeroEmp = record
    l: boolean;
    s: string;
  end;

  TFracEmpList = (frempYes,frempNo,frempNoRight0);

  PFmtNum = ^TFmtNum;
  TFmtNum = record
  	FracDlm,DigDlm: Char;
    FracEmp: TFracEmpList;
    DigIsDlm: boolean;
    AllCnt,FracCnt: Byte;
    ZeroEmp: TFmtZeroEmp;
  end;

  TFmtDate = record
  	Dlm: Char;
    NYear: Byte;
    MMYY: boolean;
    ZeroEmp: TFmtZeroEmp;
  end;

  PPosLen = ^TPosLen;
  TPosLen = record
    Pos,Len: longint;
  end;
  TArrPosLen = array of TPosLen;

  TFormAction = (faAdd,faEdit,faCopy,faView);

  TQuartMonth = 1..3;

  TDWSearchType = (dwsFldName,dwsFldCapt,dwsFldMask,dwsZgl,dwsForm,dwsGF);

  TGFSearchType = (gfsAlg,gfsAlgDop,gfsAlgMouse,gfsObjText,gfsObjIdent,gfsObjPart,gfsObjCol,gfsWPrm,gfsWDat,gfsWDop);
  TGFSearchStr = array[TGFSearchType] of string;

  PDWSearchInfo = ^TDWSearchInfo;
  TDWSearchInfo = record
		TypeObj: TDWSearchType;
		GFType: TGFSearchType;
    NumObj,NumPage: longint;
    Text: string;
  end;
  TDWSearchAInfo = array of TDWSearchInfo;

  TGFSearchInfo = record
		TypeObj,DWGFType: TGFSearchType;
    DWType: TDWSearchType;
    NumLeaf,NumObj: longint;
    Text: string;
  end;
  TGFSearchAInfo = array of TGFSearchInfo;
  TGFSearchCnt = array[TGFSearchType] of longint;

  TWord2DWord = record
    case boolean of
      false: (w1,w2: Word);
      true: (dw: longword);
  end;

  TResProcessList = (resIntrbase,resFirebird);
  TResProcessStr = array[TResProcessList] of string;

  PIPTbl = ^TIPTbl;
  TIPTbl = packed record
    dwNumEntries: longword;
    a: packed array[0..0] of packed record
      dwAddr,dwIndex,dwMask,dwBCastAddr,dwReasmSize: longword;
      unused1,wType: WORD;
    end;
  end;
  TNetInterface = record
    niAddrStr,niBroadcast: string;
    niAddr,niMask: u_long;
  end;
  TANI = array of TNetInterface;

  TSortID = (sort1MORE2,sortEXCHANGE);

  TBMList = (bmNone,bmDown,bmUp,bmLeft,bmRight,bmLeft_Right,bmPlus,bmEval,
    bmFill_Top,bmFill_Bottom,bmFill_Left,bmFill_Right,bmFill_Out,bmFill_None,
    bmGF_Top_Left,bmGF_Top_Right,bmGF_Bot_Left,bmGF_Bot_Right,
    bmGF_SortCop,bmGF_NoSortCop,bmGF_NoEcon,bmGF_EconVert,bmGF_EconFull,
    bmGF_OR_Portrait,bmGF_OR_Landscape,bmGF_Book,bmGF_Book1,bmGF_NoBook,
    bmVTabl_Std,bmVTabl_1,bmVTabl_2,bmCheck,bmCheck_Emp,bmNoCheck,bmNoCheck_Emp,bmDown_List,bmDDat,
    bmPswd_Hide,bmPswd_Show,bmConnect,bmNoAllowed);

  TSLObjIndProc = procedure(oi,ni: longint) of object;
  TSLObjIndProc1 = procedure(oi,ni: longint; p: pointer = nil);

	TAdrList = (adrSpreg,adrSpnp,adrSpul,adrLand,adrInd,adrKr,adrRn1,adrRn,adrCity1,adrCity,
	  adrNp1,adrNp,adrUl1,adrUl,adrDom,adrKor1,adrKor,adrKv,adrFiasHouse,adrFias);
  TAdrStr = array[TAdrList] of string;

	TAdr1List = (adr1Spreg,adr1Spnp,adr1Spul,adr1Land,adr1Ind,adr1Kr,adr1Rn,adr1City,
    adr1Np,adr1Ul,adr1Dom,adr1Kor,adr1Kv,adr1FiasHouse,adr1Fias);
  TAdr1Str = array[TAdr1List] of string;

  TAdrCDList0 = (acdNone,acdNp,acdUl,acdKor,acdRn,acdCity);
	TAdrCDList = Succ(acdNone)..high(TAdrCDList0);
  TAdrCDStr = array[TAdrCDList] of string;

  TAdrSpList = (aspReg,aspNp,aspUl);
  TAdrSpStr = array[TAdrSpList] of string;

  TAnkList = (ankCor,ankEmp,ankNoEmp,ankErr,ankNopr);

	TMulQueryMulPar = class(TStringList);

  TUnionDefRec = record
  	table,fld,where,group: string;
  end;
  TUnionDef = array of TUnionDefRec;

  TVarToSList = (vsQQ,vsDateWithTime); TVarToSOpt = set of TVarToSList;
  TFldInSelOpt = set of (fselNot,fselList,fselNoClr,fselFromCur);

  TUnBookMark = record
    bm: TBookMark;
    pi,ri: longint;
  end;

  TUnQueryDef = array of record
    table,where,o_list,g_list: string;
    c_list: TArrVar;
  end;

  PPMQFieldInfo = ^PMQFieldInfo;
  PMQFieldInfo = ^TMQFieldInfo;
  TMQFieldInfo = record
    DataType: TFieldType;
    Options: set of (mqfNotNull,mqfBool);
    Size: Word;
    KeyOrd: byte;
    Prim: string;
  end;

  PDriverInfo = ^TDriverInfo;
	TDriverInfo = record
    aSQL,aCan: TArrStr;
		ListName: TStringList;
	end;

  EDBTextError = class(Exception);
  EFileBufXmlError = class(Exception);
  EReadDBFError = class(Exception);
  ESummException = class(Exception);
	EInterException=class(Exception);
	EInterAbortError=class(Exception);
	EPrnError = class(Exception);
  EDcmFormError = class(Exception);
  EDcmPartError = class(Exception);
	ECopyTableError = class(Exception);
  EGoto = class(Exception);

  PArrField = ^TArrField; TArrField = array of TField;

  PArrSQLPath = ^TArrSQLPath;
  TArrSQLPath = record
    IP,Port,Drv,Path: string;
  end;

  TPrimTrans = function(const Prim: string): string;

  TFldInListList = (flsNot,flsUnique); TFldInListOpt = set of TFldInListList;

  TLogMsgProc = procedure(const aMsgTxt: array of string; aResult: longint=mrNone) of object;

  TRunExeList = (runNoConsole,runWin,runVisible,runConcole); TRunExeOpt = set of TRunExeList;

  TSaveType = (stShortInt,stSmallInt,stInteger,stByte,stWord,
  	stBoolean,stLongWord,stReal,stDouble,stInt64,stChar);

	TSaveRec = record
  	case TSaveType of
	  	stShortInt: (sh: ShortInt);
	  	stSmallInt: (sm: SmallInt);
	  	stInteger: (i: LongInt);
	  	stByte: (b: Byte);
	  	stWord: (w: Word);
	  	stBoolean: (l: Boolean);
      stLongWord: (crd: longword);
      stReal: (real: Single);
      stDouble: (dbl: Double);
	  	stInt64: (i64: Int64);
      stChar: (s: array[1..8] of char);
  end;

  TClipboardType = (cbrdGFObj,cbrdDWVid,cbrdDWFld);

	TButtonType = (btnStandart,btnEllipse,btnDown,btnSwitch,btnBullet,btnRounded,btnPoly,btnTumb);
  TButtonTypeStr = array[TButtonType] of string;

  TButtonAtrType = (btfWinActFreeAction,btfWinActPressAction,btfWinNotActFreeAction,
  	btfWinNotActPressAction,btfHotKey);

  TButtonRec = record
    btnType: TButtonType;
    aFont: array[TButtonAtrType] of TDefFont;
    aColor: array[TButtonAtrType] of TColor;
    aPrm: TButtonTypeStr;
    Width: longint;
    Inverted,UnderBut: boolean;
    Alignment: TAlignment;
  end;

  TButtonOpt = set of (butDown,butWinActive);

  TDopHeader = record
    dhName,dhPrim,dhProgs: string;
    dhRecVers,dhVers: longint;
  end;

	TSumType = (s_num,s_string);

	Rsumm = double;
  TArrRsumm = array of Rsumm;

  TSummLineCol = (s_line,s_col);

  PSummColInf = ^TSummColInf;
  TSummColInf = record
    index: longint;
		rtype: TSumType;
  end;
  TArrSummColInf = array of TSummColInf;
  TArrBoolSummColInf = array[boolean] of TSummColInf;

  TSummSumList = (smsDec,smsMore1); TSummSumOpt = set of TSummSumList;

  TSummArrVid = (smaArr,smaFirst,smaCnt);
  
  TFormSummHead = procedure(PrmHead: pointer; lc: TSummLineCol; var head: string);

	TVarevent=function (const v,index:variant; lSave: boolean):variant;
	TFuncevent=function (var av: array of variant):variant;

  Pvarrec = ^varrec;
	varrec = record
    name,hint,types: string;
    proc: TVarevent;
    index: variant;
    Enabled,ReadOnly: boolean;
    slPars: TStringList;
    aPars: array of record
      vriEnabled,vriReadOnly: boolean; // для GetVar'a
      vriHint,vriTypes: string;
      vriProc:TVarevent;
      vriIndex:variant;
      vriBP: TArrStr;
    end;
  end;
  PArrVarRec = ^TArrVarRec; TArrVarRec = array of varrec;

  PVarHelp = ^TVarHelp;
  TVarHelp = record
    help: THelpContext;
    hlpfile,hlpname: string;
  end;

	TProcDopGetVarAdd = procedure(const Aname,Ahint: string; const Atypes: string = '';
  	const AReadOnly: boolean = false);

  TVarPathList = 1..10;
  TVarPathStr = array[TVarPathList] of string;

  TProcDopGetVarEqual = function(const name: string; const av: array of variant): boolean;
	TProcDopGetVarsAdd = procedure(ProcDopGetVarAdd: TProcDopGetVarAdd) of object;
	TProcDopGetVarIgnore = function(const aPath: TVarPathStr): boolean of object;

  Pfuncrec = ^funcrec;
	funcrec = record
    name,hint,types,hlpfile: string;
    aPrm: array of array[1..2] of string;
    proc:Tfuncevent;
    index:variant;
    help,nBuiltIn:longint; // Последний nBuiltIn=0
  end;
  
	operrec = record
    help,oplev:longint; //-1-невыполнимый оператор, 0 текущий уровень 1-увел 2 уменьшает 3 как ИНАЧЕ
    name,hint,optext,hlpfile,nmhelp:string;
  end;
  
  TInterCurMode = (modeNone,modeVar,modeFunc,modeBuiltIn);
  TInterCurVF = record
    mode: TInterCurMode;
    n: longint;
  end;

  TInterVarType = (ivtVar,ivtTmpVar); TInterVarTypes = set of TInterVarType;

  TInterVarPos = (ivpDefine,ivpRepeat,ipvPrefNoCor,ivpText);

  TInterCheckResultProc = procedure(const result: variant);

  TFuncPrimType = array[1..2] of string;

  {коды ошибок}
  PInterError = ^TInterError;
  TInterError = (E_NO,E_OPER,E_SCONST,E_CLOSE,E_NAME,E_VAR,E_FUNC,E_END,E_DIV0,E_INV_OP,
    E_OVER_FL,E_UNDER_FL,E_MANYLV,E_VARIANT,E_CONVERT,E_CONST,E_COMMENT,E_RETURN,E_ARRDIM,
    E_ARRLOC,E_ANY,E_ABORT,E_SUMM,E_MANYST,E_STRUCT);

  TInterMsgErrorProc = procedure(const ExcMsg: string; error:TInterError; var serror: string);

	TPozList = (plDown,plUp);

  TRowMoveEvent = procedure(Sender: TObject; Index: longint) of object;

	TPackInfo = record
		szFiles,szPck: Int64;
		cntVol: byte;
  end;

  TPaintCtlOper = (pcmNoPaint,pcmTabOrdCtl,pcmCanvas);

	TSortMode = (smDefault,smColumns,smRows);

  PPSortObj = ^TPsortObj;
	TPsortObj = record
  	Obj: TComponent;
		Left,Top,Width,Height: longint;
  end;
  TArrPSortObj = array of TPsortObj;
  PArrPPSortObj = ^TArrPPSortObj; TArrPPSortObj = array of PPSortObj;
  TBoolPPSortObj = array[boolean] of TArrPPSortObj;

  TPSortOper = (swmNoSorted,swmFocusControl,swmColWidthAll,swmColHeightAll,swmSortInfo,swmSayRight);

  PPSortInfo = ^TPSortInfo;
  TPSortInfo = record
    Mode: TSortMode;
    Width,Height: longint;
  end;

  TSaveIniOper = (opsCanSave,opsSave,opsRest);

	TKeyProc = procedure(key: longint; tw: TWinControl) of object;

  TKeyEvalProc = procedure(Key: longint; tw: TWinControl; var lBreak: boolean);
  TKeyEvalProcArr = array of TKeyEvalProc;

  PKeyBut = ^TKeyBut;
	TKeyBut = record
  	Key,keyhelp: Word;
    Part: longint;
  	Caption,Hint,NmParent,Priv: string;
		kProc: TKeyProc;
		p: TPoint;
    Size: TSize;
    NoEval,Visible,Pressed: boolean;
  end;
  TArrKeyBut = array of TKeyBut;

  TKeyLbNmProc = class(TStringList);

  TMsOffOper = (msoInit,msoEnter,msoExit,msoExec);

	TMSOEditorList0 = (msoEdDefine,msoEdExcel,msoEdWord);
	TMSOEditorList = Succ(msoEdDefine)..high(TMSOEditorList0);

	TMSOFmtList0 = (msoFmtNone,msoFmtDefault,msoFmtHtml,msoFmtRtf,msoFmtXls);
  TMSOFmtList = Succ(msoFmtNone)..high(TMSOFmtList0);
  TMSOFmtStr = array[TMSOFmtList] of string;

	TMSOTrnType0 = (msoTwNone,msoTwTable,msoTwText);
  TMSOTrnType = Succ(msoTwNone)..high(TMSOTrnType0);

  PMSOExec = ^TMSOExec;
  TMSOExec = record
    tw: TWinControl;
    FileName: TFileName;
    Editor: TMSOEditorList0;
    Fmt: TMSOFmtList;
    Trn: TMSOTrnType;
    Leaf: variant;
  end;

  TCngNumOptions = set of (cngSayCapt,cngNoLockEdConf,cngNoLockMono,cngFusion);
	TCngNumValid = procedure(const oldnum: string; Options: TCngNumOptions; var result: boolean) of object;

	TVarParam = (dwvName,dwvSvType,dwvType,dwvCod,dwvLen,dwvDec,dwvFillType,dwvFillChr,
  	dwvDDatType,dwvDDatD2,dwvValue,dwvPrim,dwvDop,dwvSel,dwvSelType);

	TDWFldType0 = (dwtNone,dwtString,dwtFloat,dwtDate,dwtBool,dwtMemo,dwtArray,dwtManyStr,dwtSel,dwtMany);
  TDWFldType = Succ(dwtNone)..high(TDWFldType0);
  TDWFldTypeStr = array[TDWFldType] of string;
  TDWFldTypeChr = array[TDWFldType] of char;
  TDWFldSetType = set of TDWFldType;

	TDWFillList0 = (dwftNone,dwftRight,dwftLeft); TDWFillList = Succ(dwftNone)..high(TDWFillList0);

  TDWSaveType = (dwsNoFix,dwsFix,dwsDyn);
  TDWSaveStr = array[TDWSaveType] of string;

  TDDatType = (ddtDay,ddtMonth,ddtQuart,ddtYear);
  TDDatStr = array[TDDatType] of string;

  TDDatD2 = (dd2Default,dd2Big,dd2Period,dd2All);

  TDDatZnType = (ddznSimple,ddznSel);
  TDDatZnStr = array[TDDatZnType] of string;

  TSelType = (selStr,selInt);

	PDWVidRec = ^TDWVidRec;
	TDWVidRec = record
  	Name,dwCod,AValue,Prim,DopPrm,SelVid,SelVName,SelPrm: string;
    SvType: TDWSaveType;
    AType: TDWFldType;
    Len,Dec: Word;
    FillType: TDWFillList;
    FillChr: char;
    DDatType: TDDatType;
    DDatD2: TDDatD2;
    SelType: TSelType;
  end;
  PDWArrVidRec = ^TDWArrVidRec; TDWArrVidRec = array of TDWVidRec;

	TFldAttr = (faNormal,faLong,faDef,faMemo,faDefMemo,faFix,faFixMemo,faFixArray,faManyStr,faSel,faFixSel,faMany);
  TFldAttrs = set of TFldAttr;
  TFldMemoAttr = (famMemo,famArray,famSel);
  TFldMemoAttrStr = array[TFldMemoAttr] of string;
  TFldMemoAttrInt = array[TFldMemoAttr] of longint;
  TFldMemoAttrBool = array[TFldMemoAttr] of boolean;
  TFldMemoAttrArrStr = array[TFldMemoAttr] of TArrStr;
  TFldMemoAttrArrInt = array[TFldMemoAttr] of TArrInt;
  TFldMemoAttrSet = set of TFldMemoAttr;
  TFldMemoAttrArr = array of TFldMemoAttr;

  TFldVal = record
  	nm: string;
    v,ov: variant;
    gk: longword;
  end;
  TArrFldVal = array of TFldVal;
  TArrArrFldVal = array of TArrFldVal;

  TRecGetValueList = (rgvValue,rgvGetValueNum,rgvSetValueNum,rgvNumFromName,rgvFldDef);

  TFldOper = (foOpenRec,foCloseRec,foDestroy);

  TLogPrimOptions = set of (logpMod,logpKey,logpNoKey,logpNoLogFields,logpFixCnt);

  TKodCheckOptions = set of (chkNoEmpty,chkNoSpace);

  TRecValPrm = record
    AName,APrim: string;
    AType: TFieldType;
    ASize: longint;
    AValue: variant;
  end;

  TMemGkDefOption = (mgdAll,mgdNone);

  PMemGkSet = ^TMemGkSet;
  TMemGkSet = array of record
    nmf: string;
    gk: longword;
  end;

  TRDBDelList = (delNoMemo,delMsg,delLog); TRDBDelOpt = set of TRDBDelList;
  TRDBSeekOpt = set of (seekDescending,seekNoMemo);
  TRDBAddCListOpt = set of (addclSet,addclNoAlias);
  TRDBNewList = (newrCopy,newrNoDoNewRec); TRDBNewOpt = set of TRDBNewList;

  TDWCanDelEvent = function(Sender: TObject; const VarName,MsgName: string): boolean of object;
  TDWCngNameEvent = procedure(Sender: TObject; const OldName,NewName: string;
  	var result: boolean) of object;
  TProcVarValidName = procedure(var Name: string);
  TProcVarValid = procedure(const r: TDWVidRec; var result: boolean; const Wnd,Name: string;
  	ProcName: TProcVarValidName = nil);
  TDWVarValidEvent = procedure(Sender: TObject; Proc: TProcVarValid; const r: TDWVidRec;
  	var result: boolean) of object;
	TDWTransEvent = procedure(Sender: TObject; var sTrans: string;
  	lSave: boolean) of object;

  TDWFldArrSeek = array of record
  	defD,defW: string;
    lWin: boolean;
  end;

	TDWFldProcAdd = procedure(var a: TDWFldArrSeek; const defD: string;
  	const defW: string = ''; lWin: boolean = false);
  TDWFldSeekEvent = procedure(Sender: TObject; var a: TDWFldArrSeek; prAdd: TDWFldProcAdd) of object;

  TDWFldInfo = record
    FieldClass: TFieldClass;
  	Size: longint;
    Alignment: TAlignment;
  	DisplayLabel: string;
    Visible: boolean;
    r: TDWVidRec;
  end;

  PRDBArrDef = ^TRDBArrDef;
  TRDBArrDef = record
  	aDat: TDWArrVidRec;
  	Dat,Wnd,FDel: string;
  end;

  TDDatBeforeModifyEvent = procedure(Sender: TObject; const kv: string; var result: boolean) of object;
  TDDatModifyEvent = procedure(Sender: TObject; const kv: string) of object;

  TDWPostList = (postDat,postWin);

  TLogCompareItemList = (clogKey,clogNoKey,clogPrn);

  PChkLogPrm = ^TChkLogPrm;
  TChkLogPrm = record
    a: TArrStr;
    Invert: boolean;
  end;

  PDDatKvInfo = ^TDDatKvInfo;
  TDDatKvInfo = record
    valdef: variant;
    tp: TDDatType;
    td2: TDDatD2;
    ft: TFieldType;
    Len: longint;
    Dec: Word;
    tzn: TDDatZnType;
    SelVid,SelVName: string;
    ValueEqTrue: boolean;
  end;

  PDDatLastInfo = ^TDDatLastInfo;
  TDDatLastInfo = record
    d1,d2: TDateTime;
    val: variant;
  end;

  TDDatValues = array of record
    kv: string;
    d: TDateTime;
    zn: variant;
  end;

  TDDatLsOper = (ddoCreate,ddoBeforeShow,ddoShow,ddoHide,ddoDop);

  TDDatSetValOper = (dsvEqDel,dsvCanCng,dsvUpdate,dsvCalculate);
  TDDatLsProc = procedure(var result: boolean; Sender: TObject; op: TDDatLsOper; p: pointer = nil);

  TDDatSetValProc = procedure(op: TDDatSetValOper; var result: boolean);

	TDWForm = (dwfShow,dwfHide,dwfEnter,dwfExit,dwfChange,dwfCheck,dwfValid,dwfEscape,dwfAfterEscape,
    dwfAskCancel,dwfSetting,dwfHelp);
                                  TDWFormStr      = array[TDWForm] of string;
  PDWFormHelp     = ^TDWFormHelp; TDWFormHelp     = array[TDWForm] of THelpContext;
  TDWFormHelpFileProc = function(nf: TDWForm; Prm: pointer; var hf: THelpFile): boolean of object;

  TDWFldListProc = procedure(var sDat,sWnd: string) of object;

  TVarNmRec = TNamePrimStr;

  TDWWinRdbDefOpt = (dwdefNone,dwdefGotoRec,dwdefSeek,dwdefRestVal);

  TDWParamFunc = (dwprPrm,dwprName,dwprOther);

  TDWActionList = (dwaAdd,dwaCopy,dwaEdit);

  TEdTextList = (edtxtReadOnly,edtxtWordWrap,edtxtNoChkFml); TEdTextOpt = set of TEdTextList;
  TEdTextType = (edtpText,edtpInter,edtpHelp);

	TDEPrmList0 = (deNone,deCaption,deNameRec,deNameRecFld,deVid,deVName,deMask,deMaxLen,deCharCase,
    deAutoSel,dePassword,deNoReadOnly,deReadOnlyNoVsbl,deTag,deSayHint,deGetHint,deRelation,
    deWidth,deHeight,deNoVisible,deNewPage,deSayRight,deTrimLeft,deAddDyn);
  TDEPrmList = Succ(deNone)..high(TDEPrmList0);
	PDEPrmStr = ^TDEPrmStr; TDEPrmStr = array[TDEPrmList] of string;
  PDEPrmVar = ^TDEPrmVar; TDEPrmVar = array[TDEPrmList] of variant;
  PDEPrmArrStr = ^TDEPrmArrStr; TDEPrmArrStr = array of TDEPrmStr;

  TGetOption = (ogAutoSelect,ogPassword,ogReadOnly,ogReadOnlyNoVsbl,ogAutoSize,ogTrimLeft);
  TGetOptions = set of TGetOption;

  TGetRestValType = (grvNoAsk,grvAsk,grvNone);

  //TFldRelation = (frNormal,frMain,frSubject);
  TFldRelation = (frNormal,frMain);

  TFEChangeEvent = procedure(Sender: TObject; const OldVal: variant; FromShow: boolean) of object;

  TFEUpdateOper = (feuBeforeValid,feuAfterValid,feuBeforeUpd,feuAfterUpd);

  TMaskHelp = record
    hf: THelpFile;
    RVid: string;
  end;

  TFESizeAutoOpt = set of (tfszWidth,tfszHeight);

  TMaskPropOpt = set of (mskFormWnd,mskSearch);

  TFEReadList = (ferdSvOld,ferdFromShow); TFEReadOpt = set of TFEReadList;

  TFldValue = class
  public
    Value: string;
  end;

  TFEChangeWhere = (fcwShow,fcwEdit,fcwValid,fcwEsc);

  TStdGetStateOpt = set of (stdgAfter,stdgStd);

  TDWVidCodList = (dwcNoFix,dwcNoFixMemo,dwcFixStr,dwcFixFloat,dwcFixDate,
  	dwcFixMemo,dwcFixArray,dwcDyn,dwcFixSel,dwcMany);
  TDWVidCodStr = array[TDWVidCodList] of string;

  TChangeDatWhereProc = procedure(lUpd: boolean; var a: TArrStr);

  TDWVidForm = (dwfNormal,dwfArray,dwfFixArray);

	TGFAlgmList =
    (algmTopLeft   ,algmTopCenter   ,algmTopRight
    ,algmCenterLeft,algmCenter      ,algmCenterRight
    ,algmBottomLeft,algmBottomCenter,algmBottomRight); // Разместить
  TGFAlgmStr = array[TGFAlgmList] of string;

  THVAlignment = record
  	HorzAlignment,VertAlignment: TAlignment;
  end;

  TFeedList0 = (FeedNone,FeedAuto,FeedHand,FeedRool); TFeedList = Succ(FeedNone)..high(TFeedList0);
  TGFStrList0 = (GFStrNone,GFStrAll,GFStrCur,GFStrNum); TGFStrList = Succ(GFStrNone)..high(TGFStrList0);
  TGFEvenList0 = (GFEvenNone,GFEvenAll,GFEvenNoEven,GFEvenEven); TGFEvenList = Succ(GFEvenNone)..high(TGFEvenList0);
  TGFEconList0 = (GFEconNo,GFEconNone,GFEconVert,GFEconFull); TGFEconList = Succ(GFEconNo)..high(TGFEconList0);

	TGFFrmList0 = (frmNone,frmA3,frmA4,frmA5,frmA3A,frmA4A,frmA5A,frmNoLim);
  TGFFrmList = Succ(frmNone)..high(TGFFrmList0);
  TGFFrmStr = array[TGFFrmList] of string;

  TGFTypeObjList0  = (toNone,toText,toForm,toBmp,toCalc,toGet,toSay,toCalcBmp);
  TGFTypeObjList = Succ(toNone)..high(TGFTypeObjList0);
  TGFTypeObjStr = array[TGFTypeObjList] of string;

  TGFPropObjList0 = (vgfoNone,vgfoAlignment,vgfoPin,vgfoColor,vgfoVOut,vgfoOnly1,vgfoMMetr,
    vgfoMinWidth,vgfoMinHeight,vgfoFont,vgfoIdent,vgfoTypeObj,vgfoParams);
  TGFPropObjList = Succ(vgfoNone)..high(TGFPropObjList0);
  TGFPropObjStr = array[TGFPropObjList] of string;

  TGFPropLineType = (vgflnWidth,vgflnColor);

  TPrinterOrientationStr = array[TPrinterOrientation] of string;

  TGFFontType = (fptNormal,fptSepstr,fptBarCode,fptQRCode,fptPDF417); // Тип шрифта

	TGFVOList = (voBeg,voEnd,voAll); // Вывод содержимого объекта на листах одной страницы
  TGFVOStr = array[TGFVOList] of string;

	TGFPinList = (pinTopLeft,pinTopRight,pinBottomLeft,pinBottomRight); // Прижать
  TGFPinStr = array[TGFPinList] of string;

  TGFPropLineList = (vgflTop,vgflBottom,vgflLeft,vgflRight);
  TGFPropLineStr = array[TGFPropLineList] of string;

  TVarCurGFFill = record
    case boolean of
      false: (tp: TGFPropLineType; pl: TGFPropLineList);
      true: (w: Word);
  end;

  PGFPackFontPropDop = ^TGFPackFontPropDop;
  TGFPackFontPropDop = record
    case ShortInt of
      -1: (s: array[0..11] of char);
      byte(fptNormal):
        (OnlyDig: boolean
        ;RowBetween: ShortInt
        ;WidthTextAll,OnWidth,ALine: boolean
        ;Unused1,PrcSpMin: Word
        ;ChrFill: char
        );
      byte(fptSepstr):
        (sepstrOnlyDig,MMetr: boolean
        ;Width,Height: byte
        );
      byte(fptBarCode): (Koef: ShortInt);
      byte(fptQRCode):
        (qrECCLevel: TQRCode_ECCLevel
        ;qrModule: byte
        );
      byte(fptPDF417):
        (pdf417ECCLevel: TPDF417_EccLevel
        ;pdf417Module: byte
        ;pdf417RowHeight: TPDF417_RowHeight
        );
  end;

  TGFObjState = (osShow,osHide,osLong,osHead,osFoot,osSave,osSpace);

  PGFObj = ^TGFObj;
  TGFObj = record
    Text,Part,Col,Ident: string;
  	LnLeft,LnTop,LnRight,LnBottom,Color,Font: Byte;
    Pin: TGFPinList;
    Alignment: TGFAlgmList;
    TypeObj: TGFTypeObjList;
    VOut: TGFVOList;
    MMetr,Selected,Only1: boolean;
    State: TGFObjState;
  	Left,Top,Right,Bottom: Word;
    Order: longint;
    MinWidth,MinHeight: Double;
    DopObj: Pointer;
  end;
  TArrGFObj = array of TGFObj;
  TArrPGFObj = array of PGFObj;

  TGFReplaceList = (gfrNoIdent,gfrNoOnlyFml); TGFReplaceOpt = set of TGFReplaceList;

  TModelPrim = array of record
  	NumSave: longint;
    Date: TDateTime;
    Autor,Prim: string;
    Themes: TArrStr;
  end;

	TPageSave = packed record
    OffSet,PgLong,PgSmall,ObjCount,WidthMm,HeightMm: LongInt;
    ColCount,RowCount: Word;
    CurParams: byte;
    Modified: boolean;
    Text: string;
  end;
  PPages = ^TPages;
	TPages = packed record
  	sv: TPageSave;
    av: TArrGFObj;
  end;
  TArrPages = array of TPages;

  TGFWinList = (gfwDat,gfwPrm,gfwDop);
  TGFWinStr = array[TGFWinList] of string;

  TGFGraphObjEvent = function(Sender: TObject; const v: TGFObj): TGraphic of object;

  TGFHeadFoot = (gfHead,gfFoot,gfPrimBeg,gfPrim);

  TEdSchemOper = (eschCreate,eschSave,eschDef);

  TArrTreeNode = array of TTreeNode;

  TTreeDirOptions = set of (dtoCanEdit);

  TDirExecOper = (dirBeforeShow,dirAfterEnter,dirAfterExit,dirAfterShow);
  TDirExecProc = procedure(Sender: TObject; Oper: TDirExecOper) of object;

	TPrFind = function(Sender: TControl; const sf: string): boolean of object;

  TFindOption = (fnoRegistr,fnoWord,fnoDirection,fnoAll,fnoReplace,fnoSave,fnoContinue);
  TFindOptions = set of TFindOption;

  TFindDirection = (fndForward,fndBack,fndAll);

  PFindProperty = ^TFindProperty;
  TFindProperty = record
    Registr,Word,Replace: boolean;
    Direction: TFindDirection;
    sr: string;
  end;

  TPrnPrmList = (pprmStr,pprmCntCop,pprmSortCop,pprmEcon,pprmVIntv,pprmHIntv,pprmBook,pprmFeed,
    pprmNoNewPg,pprmMirror);
  TPrnPrmVar = array[TPrnPrmList] of variant;
  TPrnPrmSet = set of TPrnPrmList;

	TIEKey = (ieEnter,ieEsc);
	TIEKeys = set of TIEKey;

  TLockLstOptions = set of (lockReplF10,lockCanDel,lockNoShow,lockNoFree);

  TNumEdOpt = set of (numReadOnly,numInverted);

	TCodeTypeEdit = (cteCod,cteName,ctePrim);

  TSQLExecType = (sqeUpdate,sqeInsert,sqeDelete);
  TSQLExecTypes = set of TSQLExecType;
  TSQLExecStr = array[TSQLExecType] of string;
  PSQLExecArrStr = ^TSQLExecArrStr; TSQLExecArrStr = array[TSQLExecType] of TArrStr;

  PPswdPrm = ^TPswdPrm;
  TPswdPrm = record
    DBMain: TComponent;
    nTrns: longint;
    UserNum,UserCnt,RepDeadLock: Word;
    SuperUser,NoSciLexer,BrFindAll,NoTrnsStart: boolean;
    lsTblSQL: PSQLExecArrStr;
    aqTrns: array of array[1..2] of string;
  end;

  PPLogKeysSave = ^PLogKeysSave; PLogKeysSave = ^TLogKeysSave;
  TLogKeysSave = array of record
    key: longint;
    val: string;
  end;

  TResProcServerList = 1..2;

  TTrnsEndList = (trnsCommit,trnsSetDBS); TTrnsEndOpt = set of TTrnsEndList;

  TProtocolFileList0 = (protUnDef,protProg,protDebug,protSQL,protProv);
  TProtocolFileList = Succ(low(TProtocolFileList0))..high(TProtocolFileList0);
  TProtocolAddList = (protStack,protNoDo); TProtocolAddOpt = set of TProtocolAddList;

  TSpGkTblDef = record
    tbl,nmf,key: string;
    rows,minrow: longint;
  end;
  TArrSpGkTblDef = array of TSpGkTblDef;

  TSpGkList = (spgkPrim,spgkRows,spgkCols,spgkWndName,spgkMinRow);
  PSpGkStr = ^TSpGkStr; TSpGkStr = array[TSpGkList] of string;

  TSpGkLog = record
    Keys: PLogKeysSave;
    PrimDop: string;
  end;

  PArrWndDef = ^TArrWndDef;
	TArrWndDef = array of record
  	Def,Prim: string;
  end;

  TInterbaseExt = (ibpeGDB,ibpeFDB);

  TBrAppList = (brappCopy,brappNoGoRecCopy,brappNoDoNewRec,brappDefFromSelf);
  TBrAppOpt = set of TBrAppList;

  TButGetPrm = record
    Capt,Mask: string;
  end;

  TRGArrangeList = (rgaCol,rgaRow);

  TMenuGetList = (mngCod,mngName,mngNum);
  TMenuGetStr = array[TMenuGetList] of string;
  TMenuGetOpt = set of TMenuGetList;

	TMenuGetPrm = record
  	Opt: TMenuGetOpt;
    sItems: string;
    LenCod: longint;
	end;

  TCGSeekOptions = set of (cdgBufAll,cdgNoSQL,cdgNoTrans);

	TListF2Result = class(TStringList)
  public
    SelectStr: longint;
  end;

  TSchFontList = (dFont1,dFont2,dFontW);
  TSchFont = array[TSchFontList] of TFont;

  TDECanShow = (desAlways,desVisible,desNoReadOnly,desNever);

  TDEEdFormEdList = (defrmSetMod,defrmCrt); TDEEdFormEdOpt = set of TDEEdFormEdList;

  TDECharCase0 = (deccNo,deccNone,deccUpper,deccLower); TDECharCase = Succ(deccNo)..high(TDECharCase0);

  TCopyFileOption = (cfNoSetAttr,cfStat,cfNoEsc,cfMsg); TCopyFileOptions = set of TCopyFileOption;

  TDiskWaitList = (dskwXDel,dskwVer); TDiskWaitOpt = set of TDiskWaitList;

	TFdpState = (fdpView,fdpForm,fdpPrint);
  TFdpOptions = set of(fdoSaveDcm,fdoSayStat,fdoReadOnly,fdoNoEdo);

  TVarCurGFList = (vgfNameCol,vgfNamePart,vgfCurPageName,vgfLeaf,vgfPage,vgfFootPage,vgfHeadPage,
    vgfPrimBegPage,vgfPrimPage,vgfDateTimeBeg,vgfDateTimeBegStr,vgfCurLine,
    vgfSpLeftMm,vgfSpRightMm,vgfSpTopMm,vgfSpBottomMm,vgfWidthMm,vgfHeightMm,
    vgfStdFormat,vgfNFormat,vgfOrientation,vgfGridLineWidth,vgfDateTime,
    vgfNumFracDlm,vgfNumAllCnt,vgfNumFracCnt,vgfNumFracEmp,vgfNumDigIsDlm,vgfNumDigDlm,vgfNumZeroEmp,vgfNumsZero,
    vgfDateDlm,vgfDateNYear,vgfDateMMYY,vgfDateZeroEmp,vgfDatesZero,vgfCurPagePart,vgfCurPageFirst,
    vgfCurParams,vgfVArrPart,vgfDcmLeaf,vgfNSumm,vgfGridLineMin,vgfHorzBreak,vgfVertBreak,
    vgfHorzWidth,vgfVertWidth,vgfDynAnyLevel,vgfBlockLeaf,vgfAutoNewPageObjSpace,vgfSpotPrn);

  TRbPanelPlace = (rpTop,rpBottom,rpLeft,rpRight,rpNone);

  PDefMenuShow = ^TDefMenuShow;
  TDefMenuShow = record
    lRect: boolean;
    case boolean of
      false: (p: TPoint);
      true: (r: TRect);
  end;

  TStrBrInfZn = record
    aName: TArrStr;
  	nmFld: string;
  	LenData: longint;
    Alignment: TAlignment;
    lMax: boolean;
  end;

  TMaskPropList = (mpEdit,mpSpin,mpBool,mpRadio,mpBut,mpButForm,mpMemo,mpMenu,mpCombo,mpMulti,mpDate,mpCustom);

	TSpinGetPrm = record
    MaxValue,MinValue,Increment: longint;
    ReadOnly: boolean;
  end;

  TBrEditProc = function(Sender: TObject; lApp: boolean; const Capt: TCaption;
    const glkey,nmfCode,dwValue,dwNameWnd,dwNameScr: string; var Modified: boolean): boolean;

  TDWFldDefaultProc = procedure(const r: TDWVidRec; var a: TDEPrmStr);

  TBuiltInList0 =
    (biNone
    ,biReplicate      //ПОВТОРИТЬ
    ,biEmpty          //ПУСТО
    ,biMRound         //ОКРУГЛИТЬ
    ,biPrc            //ПРОЦЕНТ
    ,biVarType        //ТИП
    ,biSetByte        //ОТМ_ПОЗИЦИЯ
    ,biGetByteArr     //ОТМ_МАССИВ
    ,biTrimLeft       //ПРОБЕЛЫ_СЛЕВА
    ,biTrimRight      //ПРОБЕЛЫ_СПРАВА
    ,biTrim           //ПРОБЕЛЫ_УБРАТЬ
    ,biStrFind        //СТРОКА_ПОИСК
    ,biFloat0         //ЧИСЛО
    ,biIif            //ВЫБОР
    ,biStrMask        //СТРОКА_МАСКА
    ,biLen            //ДЛИНА
    ,biArray          //МАССИВ
    ,biAIns           //МАС_ВСТАВИТЬ
    ,biAAdd           //МАС_ДОБАВИТЬ
    ,biADel           //МАС_УДАЛИТЬ
    ,biAScan          //МАС_ПОИСК
    ,biAddArr         //МАС_СЛОЖИТЬ
    ,biAddEnd         //МАС_ДОПОЛНИТЬ
    ,biAFill          //МАС_ЗАПОЛНИТЬ
    ,biARaspr         //МАС_РАСПРЕД
    ,biAIf            //МАС_ВЫБОР
    ,biASort          //МАС_СОРТ
    ,biASub           //МАС_ЧАСТЬ
    ,biAVal           //МАС_ЗНАЧЕНИЕ
    ,biADef           //МАС_УМОЛЧ
    ,biListAsArray    //СТРОКА_МАССИВ
    ,biArrayAsList    //МАССИВ_СТРОКА
    ,biCopy           //ПОДСТРОКА
    ,biZpp            //ПОДЧЕРКНУТЬ
    ,biZppl           //ПОДЧЕРКНУТЬ_СЛЕВА
    ,biZppr           //ПОДЧЕРКНУТЬ_СПРАВА
    ,biZppc           //ПОДЧЕРКНУТЬ_ЦЕНТР
    ,biUpper          //ПРЕОБР_БОЛЬШИЕ
    ,biFrup           //ПРЕОБР_БОЛЬШОЙ
    ,biLower          //ПРЕОБР_МАЛЫЕ
    ,biDelTrim        //ПРОБЕЛЫ_СЖАТЬ
    ,biPadl           //СИМВОЛЫ_СЛЕВА
    ,biPadr           //СИМВОЛЫ_СПРАВА
    ,biPadc           //СИМВОЛЫ_ЦЕНТР
    ,biStr            //СТРОКА
    ,biNumStr         //СТРОКА_0
    ,biSastolin       //СТРОКА_РАЗБИТЬ
    ,biSnastolin      //СТРОКА_ЧАСТЬ
    ,biCenaProp       //СУММА_ПРОПИСЬЮ
    ,biWinToDos       //СТРОКА_DOS
    ,biDosToWin       //СТРОКА_WIN
    ,biStuff          //СТРОКА_ВСТАВКА
    ,biOrd            //СИМВОЛ_КОД
    ,biChr            //КОД_СИМВОЛ
    ,biEqualShape     //СТРОКА_ШАБЛОН
    ,biFmtPrm         //ФОРМАТ_ПАРАМЕТР
    ,biFmtStr         //ФОРМАТ_СТРОКА
    ,biDlmBetween     //РАЗД_МЕЖДУ
    ,biDlmCopy        //РАЗД_ПОДСТРОКА
    ,biDigRoman       //ЧИСЛО_РИМСК
    ,biTrimMemoStr    //СТРОКА_БЕЗ_ПРВ
    ,biIntToHex       //СТРОКА_16
    ,biTrunc          //ЦЕЛАЯ_ЧАСТЬ
    ,biMax            //МАКСИМУМ
    ,biMin            //МИНИМУМ
    ,biAbs            //МОДУЛЬ
    ,biDiv            //ЦЕЛ_ДЕЛИТЬ
    ,biMod            //ЦЕЛ_ОСТАТОК
    ,biRandom         //СЛУЧАЙНОЕ_ЧИСЛО
    ,biEoy            //ГОД_КОНЕЦ
    ,biBoy            //ГОД_НАЧАЛО
    ,biYear           //ДАТА_ГОД
    ,biDay            //ДАТА_ДЕНЬ
    ,biMonth          //ДАТА_МЕСЯЦ
    ,biOurDtoc        //ДАТА_ПРОПИСЬЮ
    ,biDtoc           //ДАТА_ЦИФРАМИ
    ,biEom            //МЕС_КОНЕЦ
    ,biBom            //МЕС_НАЧАЛО
    ,biOurMtoc        //МЕСЯЦ_ГОД
    ,biPerNToMes      //ПЕРИОД_МЕС
    ,biIncMonth       //ПЛЮС_МЕСЯЦ
    ,biCtod           //СТРОКА_ДАТА
    ,biDton           //РАЗНОСТЬ_МЕС
    ,biDtos           //ДАТА_СТРОКА
    ,biDecodeDateTime //ДАТА_ВРЕМЯ
    ,biDayOfWeek      //ДЕНЬ_НЕДЕЛИ
    ,biRun            //ВЫПОЛНИТЬ
    ,biPrm            //ПАРАМЕТР
    ,biSaveIni        //SaveIni
    ,biMessOk         //СООБЩЕНИЕ
    ,biAsk            //ЗАПРОС
    ,biStProc         //ИНД_ПРОЦЕНТ
    ,biProfile        //Profile
    ,biDbgMessOk      //СООБЩЕНИЕ_ОТЛ
    ,biFmtClr         //ФОРМАТ_ОБНУЛИТЬ
    ,biTransLit       //ТРАНСЛИТ
    ,biMDLoad         //ДОБАВИТЬ_ИЗ_ОСНОВЫ
    ,biHelpStr        //ПМ_ВЫД
    ,biKeyLb          //KeyLb
    ,biWinToUtf8      //СТРОКА_WIN_UTF8
    ,biUtf8ToWin      //СТРОКА_UTF8_WIN
    ,biPDF417         //НД_PDF417
    ,biLogWrite       //ЖУРНАЛ_ЗАПИСАТЬ
    ,biSpCopy         //СПИСОК_КОП
    ,biArrDebug       //ArrDebug
    ,biPriv           //ПРАВА
    ,biTabu           //ДОП_ПРАВА
    ,biStruct         //СТРУКТУРА
    ,biInRange        //МЕЖДУ
    ,biEnsureRange    //ГРАНИЦЫ
    ,biReplVar        //ЗАМЕНИТЬ
    ,biPadegFIO       //ПАДЕЖ_ФИО
    ,biPadegPodr      //ПАДЕЖ_ПОДР
    ,biPadegDolg      //ПАДЕЖ_ДОЛЖ
    ,biPartsFIO       //ФИО_ЧАСТИ
    );
  TBuiltInList = Succ(biNone)..high(TBuiltInList0);

  TMDInterVarCreate = procedure(var Prm: pointer; lAfter: boolean);

  TProcLock = function(flLock: longint): boolean;

  TPswdGetList = (pswdRead,pswdWrite,pswdRepl);
  TPswdGetStr = array[TPswdGetList] of string;

  TDWTypeManyOper = (dwtoIs,dwtoClick,dwtoVidCod,dwtoUsed,dwtoGetValue,dwtoSetValue,
    dwtoBeforeUpd,dwtoAfterUpd,dwtoMemPrepare,dwtoMemOpen,dwtoMemLoad,dwtoMemClose,dwtoAppCod);

  TDWTypeManyProc = procedure(Oper: TDWTypeManyOper; const av: array of variant);

  TFontIndexSave = array of record
    n: byte;
    o: TObject;
  end;

  TStrTableFillList = (tbfNoFill,tbfTopLeft); TStrTableFillOpt = set of TStrTableFillList;

  TBuiltInProc = procedure(var stack: array of variant; n1: longint; var lStd: boolean);

	TUpdateFldList = (mgCreate,mgDestroy,mgReCreate,mgArrCng,mgArrDel);

  TIndFileType = (iftMain,iftReg); TIndFileTypes = set of TIndFileType;

  TPdgList = 1..6;
  TPdgStr = array[TPdgList] of string;

  TSexList0 = (sexAll,sexMan,sexWoman);
  TSexList = Succ(sexAll)..high(TSexList0);
  TSexStr = array[TSexList] of string;

  TEdoExeType = (edoexePodp,edoexeChk,edoexeShifr);
  TEdoExeTypeStr = array[TEdoExeType] of string;

  TEdoExeIO = (edoexeIn,edoexeOutTrue,edoexeOut,edoexeOutMsg);

  TEdoExeCtrl = (edoctlIn,edoctlOut,edoctlLogin,edoctlPswd,edoctlCert);
  TEdoExeCtrlStr = array[TEdoExeCtrl] of string;

  TEdoOper = (edoVdCanDel,edoVdTbl,edoVdCngNum,edoGetPrm,edoDokVdNames,edoFdpPrepare,edoCod,
    edoOrgLs,edoOrgValid,edoOrgGet,edoOrgsGet,edoOrgDef,edoOrgTabu,
    edoFmlEnter,edoFmlExit,edoFmlPrm,edoSend,edoVdOrg,edoVdPath);
  TEdoProc = procedure(Oper: TEdoOper; const av: array of variant; var result: variant;
    var lBreak: boolean);
  
  TRegsDelProc = procedure(const SDateReg: string);

  TInvalidFileName = array[0..8] of string;

  TFio = (fioFamil,fioName1,fioName2);
  TFioStr = array[TFio] of string;
  TFioByte = array[TFio] of byte;
  TFioSummColInf = array[TFio] of TSummColInf;

const //const1
  CRLF = #13#10; 			  	// Перевод строки
  lCRLF = Length(CRLF); lCRLF1=lCRLF+1;

  TAB = #9; // Табуляция

  BoolSetAll = [false,true];

	WM_MYMSG 				= (WM_USER+2222);
	WM_SCHEM 				= WM_MYMSG;					// Установка схем
	WM_GETCHANGED 	= WM_MYMSG+1;				// Смена типа ввода
  WM_REBUILD 			= WM_MYMSG+2;				// Перестройка формы
  WM_FLDACTIVE 		= WM_MYMSG+3;				// Активность поля ввода
  WM_CALC 				= WM_MYMSG+4;       // Калькулятор
  WM_FLD 					= WM_MYMSG+5;       // Удаление или добавление TFld
  WM_APPLHINT			= WM_MYMSG+6;       // Изменение вывода Hint
  WM_SCHEMNAME 		= WM_MYMSG+7;       // Наименование схемы
  WM_WHMIN 				= WM_MYMSG+8;       // Простановка WMin и HMin у TRbPanel
  WM_INSMODECNG		= WM_MYMSG+9;       // Изменение режима "ВСТАВКА/ЗАМЕНА"
  WM_PSORT			  = WM_MYMSG+10;      // Сообщения сортировки
  WM_NOSETREDRAW	= WM_MYMSG+11;      // Не может быть изменён флаг перерисовки
  WM_ACTFORM			= WM_MYMSG+12;      // Установка активности/неактивности формы
  WM_CNGPRIV			= WM_MYMSG+13;      // Изменение прав пользователя
  WM_CNGTABU			= WM_MYMSG+14;      // Изменение дополнительных прав пользователя
  WM_SAVEINI			= WM_MYMSG+15;      // Сохранение/восстановление свойств в SAVE.INI
  WM_CLOSEFORM    = WM_MYMSG+16;      // Alt+F4
  WM_KEYRBMENU    = WM_MYMSG+17;      // Пересылка клавиши другим RbMenu в пределах RbPage
  WM_KEYINITPROG  = WM_MYMSG+18;      // Выполнение клавиши при загрузке программы
  WM_CTRLINF      = WM_MYMSG+19;      // ControlCount,Contols[i]
  WM_MSOFF        = WM_MYMSG+20;      // Для перекачки в Microsoft Office
  WM_ARRCHANGE    = WM_MYMSG+21;      // Изменение описания массива
  WM_FORMLIMIT    = WM_MYMSG+22;      // Превышение макс.кол-ва форм
  WM_GFSEEKOBJ    = WM_MYMSG+23;      // Поиск объекта в редактировании формы
  WM_GFCNGOBJ     = WM_MYMSG+24;      // Изменение объекта в редактировании формы
  WM_PAINTCTL     = WM_MYMSG+25;      // Сообщения TPaintControl
  WM_KEYLBVISIBLE = WM_MYMSG+26;      // Изменение видимости KeyLb
  WM_BROWLFORM    = WM_MYMSG+27;      // Browl для формы
  WM_GETUPD       = WM_MYMSG+28;      // Принят флаг изменений от других пользователей
  WM_NETSEL       = WM_MYMSG+29;      // Отметка в сети
  WM_NOCNGWSTATE  = WM_MYMSG+30;      // Не изменять WindowState
  WM_LASTCNGMOD   = WM_MYMSG+31;      // Модифицированы последние изменения
  WM_PROTSAVE     = WM_MYMSG+32;      // Сохранение в протокол
  WM_HELPFILL     = WM_MYMSG+33;      // Заполнение страницы помощи
  WM_USPRM        = WM_MYMSG+34;      // Параметры пользователей
  WM_FLDVAR       = WM_MYMSG+35;      // Наименование переменной для поля ввода
  WM_INTERR       = WM_MYMSG+36;      // Ошибка выполнения формулы
  WM_FROMCALC     = WM_MYMSG+37;      // Число из калькулятора
  WM_BRFIND       = WM_MYMSG+38;      // Поиск в TBrQuery
  WM_PLACETOCTRL  = WM_MYMSG+39;      // Размещение окна рядом с объектом
  WM_EDOAPPLTITLE = WM_MYMSG+40;      // Фокусировка внимания дла подписания ЭДО
  //WM_CNGCLPBRD    = WM_MYMSG+40;      // Изменение содержимого буфера обмена

  WM_USERPROG     = WM_MYMSG+41;      // Для сообщений разработчиков

  crOurLeft   = 1;
  crOurRight  = 2;
  crOurUp     = 3;
  crOurDown   = 4;
  crOurWLeft  = 5;
  crOurWRight = 6;
  crOurWUp    = 7;
  crOurWDown  = 8;
  crOurLLine  = 9;
  crOurRLine  = 10;
  crOurULine  = 11;
  crOurDLine  = 12;

  crOurCount  = 12;

  PROG_FILEID_EXT = 'DBF';
  PROG_FILEID_ZPN = 'GLOB2';
  PROG_FILEID_ZPW = 'ZPW';
  PROG_FILEID_BW = 'BW';
  PROG_FILEID_AP = 'AP';
  PROG_FILEID_TEST = 'TEST';
  PROG_FILEID_DOC = 'DOCS';

  UnDelim = '#';					// Универсальный разделитель
  lUnDelim = Length(UnDelim); lUnDelim1=lUnDelim+1;

	I_TAB = 2; 							// Ширина табуляции

	SGLOBKEY = 'globkey';		// Параметр GlobKey
  qGlobKey = '{'+SGLOBKEY+'}';

  SegmMaxCnt = 32;				// Максимальное количество сегментов строки

  bFalse='F'  ; bTrue='T' ; bStr: TArrBoolChr = (bFalse,bTrue);
  vFalse='НЕТ'; vTrue='ДА'; bVar: TArrBoolStr = (vFalse,vTrue);
  bRus: TArrBoolStr = ('Нет','Да');

  MmInInch = MetersPerInch*1000;				// Количество мм в дюйме

  TwipsInInch = 1440;     // Количество twips в дюйме

  FileRestart = '_RESTART';
  cTmpFile = 'TMP';
  HelpFileStd = 'STD';
  PrmAutor = 'AUTOR';

  DateEmpty: TDateTime = 0.0;
  DateEmpty1: TDateTime = 1.0;
  DateBig: TDateTime  = 402133; { ctod('31.12.3000') }

  MaxLineWidth = 15;		// Макс.толщина линий объектов

  MaxChr = Chr(MaxByte);

  IntNil = Longint(nil);
  Object0     = Pointer(0);
  ObjectNeg   = Pointer(-1);
  ObjectFalse = Pointer(false);
  ObjectTrue  = Pointer(true);

  KByte = 1024;
  MByte = KByte*KByte;

  aProtFile: array[TProtocolFileList] of TNamePrimStr =
    (('PROGRAM','Ошибки в программе')
    ,('PROTDEB','Ошибки в алгоритмах')
    ,('PROTSQL','Запросы к данным')
    ,('PROVDAT','Проверка данных')
    );
  aProtFileExt: array[0..2] of string = ('DPQ','DER','DRD');

  AColor: array[T16Colors] of TColor =
		(clBlack,clMaroon,clGreen,clOlive,clNavy,clPurple,clTeal,clGray,
    clSilver,clRed,clLime,clYellow,clBlue,clFuchsia,clAqua,clWhite,
    clScrollBar,clBackground,clActiveCaption,
    clInactiveCaption,clMenu,clWindow,clWindowFrame,clMenuText,clWindowText,
    clCaptionText,clActiveBorder,clInactiveBorder,
    clAppWorkSpace,clHighlight,clHighlightText,clBtnFace,
    clBtnShadow,clGrayText,clBtnText,clInactiveCaptionText,
    clBtnHighlight,clNone,clInfoText,clInfoBk);
  ANmColor: array[T16Colors] of string =
		('Чёрный','Малиновый','Зеленый','Оливковый','Темно-синий','Сиреневый','Бирюзовый','Темно-серый',
    'Светло-серый','Красный','Салатовый','Желтый','Синий','Розовый','Голубой','Белый',
    'Полоса прокрутки','Фон рабочего стола','Фон заголовка активного окна',
    'Фон заголовка неактивного окна','Фон меню','Фон окна','Рамки окна','Текст меню','Текст окна',
    'Текст заголовка активного окна','Границы активного окна','Границы неактивного окна',
    'Рабочая область приложения','Фон выделенного текста','Выделенный текст','Фон кнопки',
    'Тень кнопки','Неактивный текст','Текст кнопки','Текст заголовка неактивного окна',
    'Фон яркой кнопки','Основной фон','Информационный текст','Информационный фон');

  aclBtn: TArrBoolColor = (clBtnShadow,clBtnHighlight);

  aRegRootKey: array[1..7] of record
    Name: string;
    Key: HKEY;
  end =
    ((Name:'HKEY_CLASSES_ROOT'    ; Key:HKEY_CLASSES_ROOT)
    ,(Name:'HKEY_CURRENT_USER'    ; Key:HKEY_CURRENT_USER)
    ,(Name:'HKEY_LOCAL_MACHINE'   ; Key:HKEY_LOCAL_MACHINE)
    ,(Name:'HKEY_USERS'           ; Key:HKEY_USERS)
    ,(Name:'HKEY_PERFORMANCE_DATA'; Key:HKEY_PERFORMANCE_DATA)
    ,(Name:'HKEY_CURRENT_CONFIG'  ; Key:HKEY_CURRENT_CONFIG)
    ,(Name:'HKEY_DYN_DATA'        ; Key:HKEY_DYN_DATA)
    );

  TCP    = 'tcp';

  FloatMaxLen = 30;
  FloatMaxDec = 7;

	BevelFld = 3;
	BevelFld2 = BevelFld shl 1;

  ByteFalse = byte(false);
  ByteTrue  = byte(true);
  sblAll = [false..true];
  LenBool = ByteTrue-ByteFalse+1;

  ExeMenu    = 'MENU.EXE';

  MSecsPerMin = MSecsPerSec*SecsPerMin;

  BMPref = 'Ourl_';
  
	QQ='~';

	stpSection     = 'SETUP';
  stpReg         = stpSection+'.REG';
  stpConfig      = 'Config';
  stpDatType     = 'Type';
  stpDatDriver   = 'Driver';
  stpDatAlias    = 'Alias';
  stpDatPswd     = 'Password';
  stpIDUpd       = 'IDUpd';
  stpIBrUpd      = 'IBrUpd';
  stpLastUser    = 'LastUser';

  drvINTRBASE   = 'INTRBASE';

  ibpServerName = 'SERVER NAME';
  ibpUserName   = 'USER NAME';
  ibpPassword   = 'PASSWORD';
  ibpPath       = 'IBPATH';
  ibpExt        = 'IBEXT';
  ibpPort       = 'IBPORT';
  ibpIP         = 'IP_ADR';
  ibpDrv        = 'DRV';
  ibpType       = 'IBTYPE';
  ibpFIBDll     = 'FIBDLL';
  {
Для отказа от выбора GDS32/Firebird с поиском fbclient.dll по Program Files
надо собрать DP со всеми fbclient.dll по всем версиям Firebird и 32/64,
а выбор делать между ними c учётом IsWow64Process
Поискать по исходникам ibpFIBDll и исправить на множественный выбор
  }
  ibpFBLocal    = 'FBLOCAL';
  ibpFIBNoGC    = 'FIBNOGC';

  FILE_GDS32 = 'gds32.dll';

  drvSTANDARD      = 'STANDARD';

  stpPath          = 'PATH';
  stpDefaultDriver = 'DEFAULT DRIVER';

  sAND = ' and '; lAND=Length(sAND); lAND1=lAND+1;
  sOR  = ' or ' ; lOR =Length(sOR) ; lOR1 =lOR +1;

	DBTextExt = '.DBT';

  MaxLenSQLText = 63*KByte;

	sMemo		 = 'MEM_'     ; lMemo1=Length(sMemo)+1;
	sDefMemo = sMemo+'DEF';
	sFixMemo = sMemo+'FIX';
	sFix  	 = 'FIX_';
	sArray	 = 'ARR_';
	sSel  	 = 'SEL_';
	sFixSel	 = sSel+'FIX';
  sLong    = 'DOP_';

  sDyn = 'DYN_'; lDyn1=Length(sDyn)+1;

	DBInsPostfix = '_I'; lDBInsPostfix = Length(DBInsPostfix);

  tARR    ='ARR'    ; fARRV='KA'; fARR='KA';
  tARRV   ='ARRV'   ; fArrvFDEL=sMemo+'FDEL';
  tCDADR  ='CDADR'  ; fCdadrGK='GK'; fCdadrKA='KA';
  tDBREG  ='DBREG'  ; fDBREG='CODE';
  tDBS    ='DBS'    ; fDbsTABLE='TABLE_NAME'; fDbsFIELD='FLD_NAME'; fDbsVERS ='VERS';
  tDCM    ='DCM'    ; fDCM='FDCM'; fDcmDCM=sMemo+'DCM';
  tDCMBMP ='DCMBMP' ; fDcmBmpCOD='COD'; fDcmBmpPART='PARTINI'; fDCMBMP=sMemo+'BMP';
  tDDAT   ='DDAT'   ; fDDCod='COD'; fDDVid='VID'; fDDKv='KV'; fDDD1='D1'; fDDZN='ZN';
  tDER    ='DER'    ;
  tDFRM   ='DFRM'   ; fDfrmNF='NF'; fDfrmKF='KF';
  tDOCPRM ='DOCPRM' ; fFDTG='FDTG';
  tDWND   ='DWND'   ; fDWND='KW';
  tEDO    ='EDO'    ;
  tEDOAPP ='EDOAPP' ;
  tEDOEXE ='EDOEXE' ; fEDOEXE='KE';
  tEDOIN  ='EDOIN'  ; fEDOIN='UN';
  tEDOORD ='EDOORD' ; fEDOORD='ORD'; fEdoORG='ORGNO'; fEdoNC='NC'; 
  tEDOUS  ='EDOUS'  ;
  tEDOVD  ='EDOVD'  ; fEDOVD='KV';
  tFAQ    ='FAQ'    ;
  tFILES  ='FILES'  ;
  tGLOB   ='GLOB'   ;
  tGLOBSET='GLOBSET'; 
  tINFO   ='INFO'   ;
  tLASTCNG='LASTCNG'; fLastcngVERS='VERSCONF';
  tLOG    ='LOG'    ; fLogD='D'; fLogUN='UN'; fLogNPRIM='NPRIM';
  tMAXFLD ='MAXFLD' ;
  tMDLIST ='MDLIST' ; 
  tMEMO   ='MEMO'   ; fMGK='GK'; fMNPP='NPP'; fMZN='ZN';
  tMODEL  ='MODEL'  ; fMDPrefix='PREFIX';
  tMSGS   ='MSGS'   ; fMsgsDRFROM='DRFROM'; fMsgsDSEND='DSEND';
  tNOTE   ='NOTE'   ; fNoteD='D'; fNoteT='T'; fNoteSYSNUM='SYSNUM';
  tREGS   ='REGS'   ; fREGS='DR';
  tSEL    ='SEL'    ; fSelFLT='FLT_';
  tSETDBS ='SETDBS' ;
  tSPDB   ='SPDB'   ; fSpGK='SPGK';
  tSPNP   ='SPNP'   ;
  tSPREG  ='SPREG'  ; fSPREG='KR';
  tSPUL   ='SPUL'   ;
  tTABU   ='TABU'   ; fTabuZN='ZN';
  tUSERS  ='USERS'  ;
  tUSPRM  ='USPRM'  ; fUSPRM=sMemo+'VAL';

  fSpCODE='CODE';
  fFAMIL='FAMIL';
  fFNAME='FNAME';
  fIP='IP';
  fMODEL='MODEL';
  fNAME='NAME';
  fNAME1='NAME1';
  fNAME2='NAME2';
  fNMODEL='NMODEL';
	fRECNO='RECNO';
	fRECNO_I=fRECNO+DBInsPostfix;
  fTXT='TXT';
  fUPNAME='UPNAME';
  fUSERNAME='USERNAME';
  fUSERNUM='USERNUM';
  fFRM=sMemo+'FRM';

  aDbsTbl: array[boolean] of record
    dbs,glob: string;
  end =
    ((dbs:tDBS   ; glob:tGLOB)
    ,(dbs:tSETDBS; glob:tGLOBSET)
    );

  sCOUNTZV       = 'count(*)';
  sTABLE         = 'table';
  sC_LIST        = 'c_list';
  sV_LIST        = 'v_list';
  sO_LIST        = 'o_list';
  sG_LIST        = 'g_list';
  sWHERE         = 'where';
  sHAVE          = 'have';
  sSELECT_WHERE  = 'select_where';
  sSELECT_WGROUP = 'select_wgroup';
  sSELECT_GROUP  = 'select_group';
  sSELECT_WORDER = 'select_worder';
  sSELECT_ORDER  = 'select_order';
  sSELECT_FLIST  = 'select_flist';
  sSEL_GH        = 'sel_gh';
  sSEL_WGH       = 'sel_wgh';
  sSELECT_ALL    = 'select*';
  sSELECT        = 'select';
  sUNION         = ' union ';
  sLIKE          = ' like ';
  sNOT           = ' not ';
  sNULL          = 'null';
  sISNULL        = ' is '+sNULL;
  sIN            = ' in ';
  sDW_TABLE      = 'dw_table';
  sD_TABLE       = 'd_table';
  sUW_TABLE      = 'uw_table';
  sU_TABLE       = 'u_table';
  sIS_TABLE      = 'is_table';
  sI_TABLE       = 'i_table';

  aPartWOGH: array[boolean,boolean,boolean,boolean] of string =
    (((('sel_wgho','select_wgrorder'),(sSELECT_WORDER,sSELECT_WORDER))
     ,((sSEL_WGH  ,sSELECT_WGROUP   ),(sSELECT_WHERE ,sSELECT_WHERE))
     )
    ,((('sel_gho' ,'select_grorder' ),(sSELECT_ORDER ,sSELECT_ORDER))
     ,((sSEL_GH   ,sSELECT_GROUP    ),(sSELECT_FLIST ,sSELECT_FLIST))
     )
    );

	AskiX = 10;
	AskiY = 10;

  amsDel: array[1..2] of string = ('Вы уверены,','что нужно удалить ?');
  amsExitProg: array[1..1] of string = ('Выйти из программы ?');
  amsSaveCng: array[1..1] of string = ('Сохранить изменения ?');
  amsSel: TArrBoolStr = ('Снять отметку со всех','Отметить все');

  DOP_PREFIX = 'dp_';
  
  XLS_EOF                  = $000A;
  XLS_CALCCOUNT            = $000C;
  XLS_CALCMODE             = $000D;
  XLS_PRECISION            = $000E;
  XLS_REFMODE              = $000F;
  XLS_DELTA                = $0010;
  XLS_ITERATION            = $0011;
  XLS_PROTECT              = $0012;
  XLS_PASSWORD             = $0013;
  XLS_HEADER               = $0014;
  XLS_FOOTER               = $0015;
  XLS_EXTERNSHEET          = $0017;
  XLS_NAME                 = $0018;
  XLS_WINDOWPROTECT        = $0019;
  XLS_VERTICALPAGEBREAKS   = $001A;
  XLS_HORIZONTALPAGEBREAKS = $001B;
  XLS_SELECTION            = $001D;
  XLS_1904                 = $0022;
  XLS_LEFTMARGIN           = $0026;
  XLS_RIGHTMARGIN          = $0027;
  XLS_TOPMARGIN            = $0028;
  XLS_BOTTOMMARGIN         = $0029;
  XLS_PRINTHEADERS         = $002A;
  XLS_PRINTGRIDLINES       = $002B;
  //XLS_FILEPASS             = $002F;
  XLS_FONT                 = $0031;
  XLS_CONTINUE             = $003C;
  XLS_WINDOW1              = $003D;
  XLS_BACKUP               = $0040;
  XLS_CODEPAGE             = $0042;
  XLS_PLS                  = $004D;
  XLS_DEFCOLWIDTH          = $0055;
  XLS_WRITEACCESS          = $005C;
  XLS_SAVERECALC           = $005F;
  XLS_COLINFO              = $007D;
  XLS_GUTS                 = $0080;
  XLS_WSBOOL               = $0081;
  XLS_GRIDSET              = $0082;
  XLS_HCENTER              = $0083;
  XLS_VCENTER              = $0084;
  XLS_BOUNDSHEET           = $0085;
  XLS_COUNTRY              = $008C;
  XLS_HIDEOBJ              = $008D;
  XLS_PALETTE              = $0092;
  XLS_FNGROUPCOUNT         = $009C;
  XLS_SETUP                = $00A1;
  XLS_MULRK                = $00BD;
  XLS_MULBLANK             = $00BE;
  XLS_ADDDELMENU           = $00C1;
  XLS_DBCELL               = $00D7;
  XLS_BOOKBOOL             = $00DA;
  XLS_XF                   = $00E0;
  XLS_INTERFACEHDR         = $00E1;
  XLS_INTERFACEEND         = $00E2;
  XLS_MERGEDCELLS          = $00E5;
  XLS_MSODRAWINGGROUP      = $00EB;
  XLS_MSODRAWING           = $00EC;
  XLS_MSODRAWINGSELECTION  = $00ED;
  XLS_PHONETIC             = $00EF;
  XLS_SST                  = $00FC;
  XLS_LABELSST             = $00FD;
  XLS_EXTSST               = $00FF;
  XLS_TABID                = $013D;
  XLS_USESELFS             = $0160;
  XLS_DSF                  = $0161;
  XLS_SUPBOOK              = $01AE;
  XLS_PROT4REV             = $01AF;
  XLS_REFRESHALL           = $01B7;
  XLS_PROT4REVPASS         = $01BC;
  XLS_EXCEL9FILE           = $01C0;
  XLS_RECALCID             = $01C1;
  XLS_DIMENSIONS           = $0200;
  XLS_BLANK                = $0201;
  XLS_NUMBER               = $0203;
  XLS_ROW                  = $0208;
  XLS_INDEX                = $020B;
  XLS_DEFAULTROWHEIGHT     = $0225;
  XLS_WINDOW2              = $023E;
  XLS_RK                   = $027E;
  XLS_STYLE                = $0293;
  XLS_FORMAT               = $041E;
  XLS_BOF                  = $0809;
  XLS_BOOKEXT              = $0863;

// Максимальное количество параметров
	MAX_PRM=32;
// Разделитель для примечания к разделу
  iChrPrim=#31;

{типы переменной variant}
	V_NULL  = varNull;
	V_INT   = varInteger;
	V_BOOL  = varBoolean;
	V_FLOAT = varDouble;
	V_DATE  = varDate;
	V_STRING= varString;

  svConst = 'Константы';
  svGF = 'Генератор форм';
  svGFAlgm = 'Разместить';
  svGFPin = 'Прижать';
  svGFVO = 'Вывод содержимого объекта';
  svGFTypeObj = 'Тип объекта';
  svPdg = 'Падежи';

  HelpFileUser = 'USER';

  FileKatDiff = 'KATDIFF.DNF';

  IndFile = 'IND.DFM';

  LastCngFmtD = 'dd/mm/yyddd hh:nn';

	K_ALL   = 0;

	K_F1    = 1;
	K_F2    = 2;
	K_F3    = 3;
	K_F4    = 4;
	K_F5    = 5;
	K_F6    = 6;
	K_F7    = 7;
	K_F8    = 8;
	K_F9    = 9;
	K_F10   = 10;
	K_F11   = 11;
	K_F12   = 12;
	K_ENTER = 13;
	K_ESC   = 14;
	K_TAB   = 15;
	K_SPACE = 16;
	K_HOME  = 17;
	K_END   = 18;
	K_INS   = 19;
	K_DEL   = 20;
  K_PGUP  = 21;
  K_PGDN  = 22;
  K_UP    = 23;
  K_DOWN  = 24;
  K_LEFT  = 25;
  K_RIGHT = 26;
  K_BS    = 27;
  K_A     = 28;
  K_B	    = 29;
  K_C	    = 30;
  K_D	    = 31;
  K_E	    = 32;
  K_F	    = 33;
  K_G	    = 34;
  K_H	    = 35;
  K_I	    = 36;
  K_J	    = 37;
  K_K	    = 38;
  K_L	    = 39;
  K_M	    = 40;
  K_N	    = 41;
  K_O	    = 42;
  K_P	    = 43;
  K_Q	    = 44;
  K_R	    = 45;
  K_S	    = 46;
  K_T	    = 47;
  K_U	    = 48;
  K_V	    = 49;
  K_W	    = 50;
  K_X	    = 51;
  K_Y	    = 52;
  K_Z	    = 53;
  K_0     = 54;
  K_1     = 55;
  K_2     = 56;
  K_3     = 57;
  K_4     = 58;
  K_5     = 59;
  K_6     = 60;
  K_7     = 61;
  K_8     = 62;
  K_9     = 63;
  K_ZPT   = 64;
  K_POINT = 65;
  K_PLUS  = 66;
  K_MINUS = 67;
  K_MULT  = 68;
  K_DIV   = 69;

	KEY_CNT = 69;

  kshCtrl  = 1;
  kshAlt   = 2;
  kshShift = 3;

  kshCnt   = 3;

	KEY_USER = KEY_CNT*(kshCnt+1);

  K_CTRL_F1    = KEY_CNT*kshCtrl+K_F1;
  K_CTRL_F2    = KEY_CNT*kshCtrl+K_F2;
  K_CTRL_F3    = KEY_CNT*kshCtrl+K_F3;
  K_CTRL_F4    = KEY_CNT*kshCtrl+K_F4;
  K_CTRL_F5    = KEY_CNT*kshCtrl+K_F5;
  K_CTRL_F6    = KEY_CNT*kshCtrl+K_F6;
  K_CTRL_F7    = KEY_CNT*kshCtrl+K_F7;
  K_CTRL_F8    = KEY_CNT*kshCtrl+K_F8;
  K_CTRL_F9    = KEY_CNT*kshCtrl+K_F9;
  K_CTRL_F10   = KEY_CNT*kshCtrl+K_F10;
  K_CTRL_F11   = KEY_CNT*kshCtrl+K_F11;
  K_CTRL_F12   = KEY_CNT*kshCtrl+K_F12;
  K_CTRL_ENTER = KEY_CNT*kshCtrl+K_ENTER;
  K_CTRL_ESC   = KEY_CNT*kshCtrl+K_ESC;
  K_CTRL_TAB   = KEY_CNT*kshCtrl+K_TAB;
  K_CTRL_SPACE = KEY_CNT*kshCtrl+K_SPACE;
  K_CTRL_HOME  = KEY_CNT*kshCtrl+K_HOME;
  K_CTRL_END   = KEY_CNT*kshCtrl+K_END;
  K_CTRL_INS   = KEY_CNT*kshCtrl+K_INS;
  K_CTRL_DEL   = KEY_CNT*kshCtrl+K_DEL;
  K_CTRL_PGUP  = KEY_CNT*kshCtrl+K_PGUP;
  K_CTRL_PGDN  = KEY_CNT*kshCtrl+K_PGDN;
  K_CTRL_UP    = KEY_CNT*kshCtrl+K_UP;
  K_CTRL_DOWN  = KEY_CNT*kshCtrl+K_DOWN;
  K_CTRL_LEFT  = KEY_CNT*kshCtrl+K_LEFT;
  K_CTRL_RIGHT = KEY_CNT*kshCtrl+K_RIGHT;
  K_CTRL_BS    = KEY_CNT*kshCtrl+K_BS;
  K_CTRL_A     = KEY_CNT*kshCtrl+K_A;
  K_CTRL_B	   = KEY_CNT*kshCtrl+K_B;
  K_CTRL_C	   = KEY_CNT*kshCtrl+K_C;
  K_CTRL_D	   = KEY_CNT*kshCtrl+K_D;
  K_CTRL_E	   = KEY_CNT*kshCtrl+K_E;
  K_CTRL_F	   = KEY_CNT*kshCtrl+K_F;
  K_CTRL_G	   = KEY_CNT*kshCtrl+K_G;
  K_CTRL_H	   = KEY_CNT*kshCtrl+K_H;
  K_CTRL_I	   = KEY_CNT*kshCtrl+K_I;
  K_CTRL_J	   = KEY_CNT*kshCtrl+K_J;
  K_CTRL_K	   = KEY_CNT*kshCtrl+K_K;
  K_CTRL_L	   = KEY_CNT*kshCtrl+K_L;
  K_CTRL_M	   = KEY_CNT*kshCtrl+K_M;
  K_CTRL_N	   = KEY_CNT*kshCtrl+K_N;
  K_CTRL_O	   = KEY_CNT*kshCtrl+K_O;
  K_CTRL_P	   = KEY_CNT*kshCtrl+K_P;
  K_CTRL_Q	   = KEY_CNT*kshCtrl+K_Q;
  K_CTRL_R	   = KEY_CNT*kshCtrl+K_R;
  K_CTRL_S	   = KEY_CNT*kshCtrl+K_S;
  K_CTRL_T	   = KEY_CNT*kshCtrl+K_T;
  K_CTRL_U	   = KEY_CNT*kshCtrl+K_U;
  K_CTRL_V	   = KEY_CNT*kshCtrl+K_V;
  K_CTRL_W	   = KEY_CNT*kshCtrl+K_W;
  K_CTRL_X	   = KEY_CNT*kshCtrl+K_X;
  K_CTRL_Y	   = KEY_CNT*kshCtrl+K_Y;
  K_CTRL_Z	   = KEY_CNT*kshCtrl+K_Z;
  K_CTRL_0	   = KEY_CNT*kshCtrl+K_0;
  K_CTRL_1	   = KEY_CNT*kshCtrl+K_1;
  K_CTRL_2	   = KEY_CNT*kshCtrl+K_2;
  K_CTRL_3	   = KEY_CNT*kshCtrl+K_3;
  K_CTRL_4	   = KEY_CNT*kshCtrl+K_4;
  K_CTRL_5	   = KEY_CNT*kshCtrl+K_5;
  K_CTRL_6	   = KEY_CNT*kshCtrl+K_6;
  K_CTRL_7	   = KEY_CNT*kshCtrl+K_7;
  K_CTRL_8	   = KEY_CNT*kshCtrl+K_8;
  K_CTRL_9	   = KEY_CNT*kshCtrl+K_9;
  K_CTRL_ZPT   = KEY_CNT*kshCtrl+K_ZPT;
  K_CTRL_POINT = KEY_CNT*kshCtrl+K_POINT;
  K_CTRL_PLUS  = KEY_CNT*kshCtrl+K_PLUS;
  K_CTRL_MINUS = KEY_CNT*kshCtrl+K_MINUS;
  K_CTRL_MULT  = KEY_CNT*kshCtrl+K_MULT;
  K_CTRL_DIV   = KEY_CNT*kshCtrl+K_DIV;

  K_ALT_F1    = KEY_CNT*kshAlt+K_F1;
  K_ALT_F2    = KEY_CNT*kshAlt+K_F2;
  K_ALT_F3    = KEY_CNT*kshAlt+K_F3;
  K_ALT_F4    = KEY_CNT*kshAlt+K_F4;
  K_ALT_F5    = KEY_CNT*kshAlt+K_F5;
  K_ALT_F6    = KEY_CNT*kshAlt+K_F6;
  K_ALT_F7    = KEY_CNT*kshAlt+K_F7;
  K_ALT_F8    = KEY_CNT*kshAlt+K_F8;
  K_ALT_F9    = KEY_CNT*kshAlt+K_F9;
  K_ALT_F10   = KEY_CNT*kshAlt+K_F10;
  K_ALT_F11   = KEY_CNT*kshAlt+K_F11;
  K_ALT_F12   = KEY_CNT*kshAlt+K_F12;
  K_ALT_ENTER = KEY_CNT*kshAlt+K_ENTER;
  K_ALT_ESC   = KEY_CNT*kshAlt+K_ESC;
  K_ALT_TAB   = KEY_CNT*kshAlt+K_TAB;
  K_ALT_SPACE = KEY_CNT*kshAlt+K_SPACE;
  K_ALT_HOME  = KEY_CNT*kshAlt+K_HOME;
  K_ALT_END   = KEY_CNT*kshAlt+K_END;
  K_ALT_INS   = KEY_CNT*kshAlt+K_INS;
  K_ALT_DEL   = KEY_CNT*kshAlt+K_DEL;
  K_ALT_PGUP  = KEY_CNT*kshAlt+K_PGUP;
  K_ALT_PGDN  = KEY_CNT*kshAlt+K_PGDN;
  K_ALT_UP    = KEY_CNT*kshAlt+K_UP;
  K_ALT_DOWN  = KEY_CNT*kshAlt+K_DOWN;
  K_ALT_LEFT  = KEY_CNT*kshAlt+K_LEFT;
  K_ALT_RIGHT = KEY_CNT*kshAlt+K_RIGHT;
  K_ALT_BS    = KEY_CNT*kshAlt+K_BS;
  K_ALT_A     = KEY_CNT*kshAlt+K_A;
  K_ALT_B	    = KEY_CNT*kshAlt+K_B;
  K_ALT_C	    = KEY_CNT*kshAlt+K_C;
  K_ALT_D	    = KEY_CNT*kshAlt+K_D;
  K_ALT_E	    = KEY_CNT*kshAlt+K_E;
  K_ALT_F	    = KEY_CNT*kshAlt+K_F;
  K_ALT_G	    = KEY_CNT*kshAlt+K_G;
  K_ALT_H	    = KEY_CNT*kshAlt+K_H;
  K_ALT_I	    = KEY_CNT*kshAlt+K_I;
  K_ALT_J	    = KEY_CNT*kshAlt+K_J;
  K_ALT_K	    = KEY_CNT*kshAlt+K_K;
  K_ALT_L	    = KEY_CNT*kshAlt+K_L;
  K_ALT_M	    = KEY_CNT*kshAlt+K_M;
  K_ALT_N	    = KEY_CNT*kshAlt+K_N;
  K_ALT_O	    = KEY_CNT*kshAlt+K_O;
  K_ALT_P	    = KEY_CNT*kshAlt+K_P;
  K_ALT_Q	    = KEY_CNT*kshAlt+K_Q;
  K_ALT_R	    = KEY_CNT*kshAlt+K_R;
  K_ALT_S	    = KEY_CNT*kshAlt+K_S;
  K_ALT_T	    = KEY_CNT*kshAlt+K_T;
  K_ALT_U	    = KEY_CNT*kshAlt+K_U;
  K_ALT_V	    = KEY_CNT*kshAlt+K_V;
  K_ALT_W	    = KEY_CNT*kshAlt+K_W;
  K_ALT_X	    = KEY_CNT*kshAlt+K_X;
  K_ALT_Y	    = KEY_CNT*kshAlt+K_Y;
  K_ALT_Z	    = KEY_CNT*kshAlt+K_Z;
  K_ALT_0	    = KEY_CNT*kshAlt+K_0;
  K_ALT_1	    = KEY_CNT*kshAlt+K_1;
  K_ALT_2	    = KEY_CNT*kshAlt+K_2;
  K_ALT_3	    = KEY_CNT*kshAlt+K_3;
  K_ALT_4	    = KEY_CNT*kshAlt+K_4;
  K_ALT_5	    = KEY_CNT*kshAlt+K_5;
  K_ALT_6	    = KEY_CNT*kshAlt+K_6;
  K_ALT_7	    = KEY_CNT*kshAlt+K_7;
  K_ALT_8	    = KEY_CNT*kshAlt+K_8;
  K_ALT_9	    = KEY_CNT*kshAlt+K_9;
  K_ALT_ZPT   = KEY_CNT*kshAlt+K_ZPT;
  K_ALT_POINT = KEY_CNT*kshAlt+K_POINT;
  K_ALT_PLUS  = KEY_CNT*kshAlt+K_PLUS;
  K_ALT_MINUS = KEY_CNT*kshAlt+K_MINUS;
  K_ALT_MULT  = KEY_CNT*kshAlt+K_MULT;
  K_ALT_DIV   = KEY_CNT*kshAlt+K_DIV;

  K_SHIFT_F1    = KEY_CNT*kshShift+K_F1;
  K_SHIFT_F2    = KEY_CNT*kshShift+K_F2;
  K_SHIFT_F3    = KEY_CNT*kshShift+K_F3;
  K_SHIFT_F4    = KEY_CNT*kshShift+K_F4;
  K_SHIFT_F5    = KEY_CNT*kshShift+K_F5;
  K_SHIFT_F6    = KEY_CNT*kshShift+K_F6;
  K_SHIFT_F7    = KEY_CNT*kshShift+K_F7;
  K_SHIFT_F8    = KEY_CNT*kshShift+K_F8;
  K_SHIFT_F9    = KEY_CNT*kshShift+K_F9;
  K_SHIFT_F10   = KEY_CNT*kshShift+K_F10;
  K_SHIFT_F11   = KEY_CNT*kshShift+K_F11;
  K_SHIFT_F12   = KEY_CNT*kshShift+K_F12;
  K_SHIFT_ENTER = KEY_CNT*kshShift+K_ENTER;
  K_SHIFT_ESC   = KEY_CNT*kshShift+K_ESC;
  K_SHIFT_TAB   = KEY_CNT*kshShift+K_TAB;
  K_SHIFT_SPACE = KEY_CNT*kshShift+K_SPACE;
  K_SHIFT_HOME  = KEY_CNT*kshShift+K_HOME;
  K_SHIFT_END   = KEY_CNT*kshShift+K_END;
  K_SHIFT_INS   = KEY_CNT*kshShift+K_INS;
  K_SHIFT_DEL   = KEY_CNT*kshShift+K_DEL;
  K_SHIFT_PGUP  = KEY_CNT*kshShift+K_PGUP;
  K_SHIFT_PGDN  = KEY_CNT*kshShift+K_PGDN;
  K_SHIFT_UP    = KEY_CNT*kshShift+K_UP;
  K_SHIFT_DOWN  = KEY_CNT*kshShift+K_DOWN;
  K_SHIFT_LEFT  = KEY_CNT*kshShift+K_LEFT;
  K_SHIFT_RIGHT = KEY_CNT*kshShift+K_RIGHT;
  K_SHIFT_BS    = KEY_CNT*kshShift+K_BS;
  K_SHIFT_A     = KEY_CNT*kshShift+K_A;
  K_SHIFT_B     = KEY_CNT*kshShift+K_B;
  K_SHIFT_C     = KEY_CNT*kshShift+K_C;
  K_SHIFT_D     = KEY_CNT*kshShift+K_D;
  K_SHIFT_E     = KEY_CNT*kshShift+K_E;
  K_SHIFT_F     = KEY_CNT*kshShift+K_F;
  K_SHIFT_G	    = KEY_CNT*kshShift+K_G;
  K_SHIFT_H	    = KEY_CNT*kshShift+K_H;
  K_SHIFT_I	    = KEY_CNT*kshShift+K_I;
  K_SHIFT_J	    = KEY_CNT*kshShift+K_J;
  K_SHIFT_K	    = KEY_CNT*kshShift+K_K;
  K_SHIFT_L	    = KEY_CNT*kshShift+K_L;
  K_SHIFT_M	    = KEY_CNT*kshShift+K_M;
  K_SHIFT_N	    = KEY_CNT*kshShift+K_N;
  K_SHIFT_O	    = KEY_CNT*kshShift+K_O;
  K_SHIFT_P	    = KEY_CNT*kshShift+K_P;
  K_SHIFT_Q	    = KEY_CNT*kshShift+K_Q;
  K_SHIFT_R	    = KEY_CNT*kshShift+K_R;
  K_SHIFT_S	    = KEY_CNT*kshShift+K_S;
  K_SHIFT_T	    = KEY_CNT*kshShift+K_T;
  K_SHIFT_U	    = KEY_CNT*kshShift+K_U;
  K_SHIFT_V	    = KEY_CNT*kshShift+K_V;
  K_SHIFT_W	    = KEY_CNT*kshShift+K_W;
  K_SHIFT_X	    = KEY_CNT*kshShift+K_X;
  K_SHIFT_Y	    = KEY_CNT*kshShift+K_Y;
  K_SHIFT_Z	    = KEY_CNT*kshShift+K_Z;
  K_SHIFT_0	    = KEY_CNT*kshShift+K_0;
  K_SHIFT_1	    = KEY_CNT*kshShift+K_1;
  K_SHIFT_2	    = KEY_CNT*kshShift+K_2;
  K_SHIFT_3	    = KEY_CNT*kshShift+K_3;
  K_SHIFT_4	    = KEY_CNT*kshShift+K_4;
  K_SHIFT_5	    = KEY_CNT*kshShift+K_5;
  K_SHIFT_6	    = KEY_CNT*kshShift+K_6;
  K_SHIFT_7	    = KEY_CNT*kshShift+K_7;
  K_SHIFT_8	    = KEY_CNT*kshShift+K_8;
  K_SHIFT_9	    = KEY_CNT*kshShift+K_9;
  K_SHIFT_ZPT   = KEY_CNT*kshShift+K_ZPT;
  K_SHIFT_POINT = KEY_CNT*kshShift+K_POINT;
  K_SHIFT_PLUS  = KEY_CNT*kshShift+K_PLUS;
  K_SHIFT_MINUS = KEY_CNT*kshShift+K_MINUS;
  K_SHIFT_MULT  = KEY_CNT*kshShift+K_MULT;
  K_SHIFT_DIV   = KEY_CNT*kshShift+K_DIV;

	kmNone    = -1;
  kmFile    = 10;   // 1
  kmEdit    = 20;   // 2
  kmList    = 30;   // 3
  kmServic  = 40;   // 4
  kmCalc    = 50;   // 5
  kmPage    = 60;   // 6
  kmGenForm = 70;   // 7
  kmArhiv   = 80;   // 8
  kmDesign  = 90;   // 9
  kmHelp    = 100;  // 10
  kmExit    = 200;  // 11

  aKeyListDown: array[0..1] of longint = (K_F2,K_Alt_Down);
  aKeyFind: array[0..1] of longint = (K_F6,K_Ctrl_F);

  cKeyLbFunc = 'KeyLb';

  SCE_OURLIB_DEFAULT	               = 0;
  SCE_OURLIB_COMMENT_LINE	           = 1;
  SCE_OURLIB_COMMENT_LINE_FROM_BEGIN = 2;
  SCE_OURLIB_COMMENT_BLOCK	         = 3;
  SCE_OURLIB_PREPROCESSOR	           = 4;
  SCE_OURLIB_NUMBER	                 = 5;
  SCE_OURLIB_FLOAT	                 = 6;
  SCE_OURLIB_STRING	                 = 7;
  SCE_OURLIB_STRING2	               = 8;
  SCE_OURLIB_OPERATOR	               = 9;
  SCE_OURLIB_WORD	                   = 10;

  SCE_OURLIB_WORD_FIRST              = 11;

  SCE_OURLIB_WORD_FOLD_BEGIN	       = 11;
  SCE_OURLIB_WORD_FOLD_END	         = 12;
  SCE_OURLIB_WORD_PREPROC_DEF	       = 13;
  SCE_OURLIB_WORD_OPERATOR	         = 14; kwOperator = SCE_OURLIB_WORD_OPERATOR-SCE_OURLIB_WORD_FIRST;

  SCE_OURLIB_WORD_USER_FIRST         = 15;

  SCE_OURLIB_WORD1                   = 15;
  SCE_OURLIB_WORD2	                 = 16;
  SCE_OURLIB_WORD3	                 = 17;
  SCE_OURLIB_WORD4                   = 18;
  SCE_OURLIB_WORD5                   = 19;
  SCE_OURLIB_WORD6                   = 20;
  SCE_OURLIB_WORD7                   = 21;
  SCE_OURLIB_WORD8                   = 22;
  SCE_OURLIB_WORD9                   = 23;
  SCE_OURLIB_WORD10	                 = 24;
  SCE_OURLIB_WORD11	                 = 25;
  SCE_OURLIB_WORD12	                 = 26;
  SCE_OURLIB_WORD13	                 = 27;
  SCE_OURLIB_WORD14	                 = 28;
  SCE_OURLIB_WORD15	                 = 29;

  SCE_OURLIB_RESERVED	               = 30;
  SCE_OURLIB_DATE	                   = 31;

  SCE_OURLIB_HELP_BEG  = SCE_OURLIB_WORD1;

  SCE_OURLIB_HELP_PART = SCE_OURLIB_WORD1;
  SCE_OURLIB_HELP_HEAD = SCE_OURLIB_WORD2;
  SCE_OURLIB_HELP_BOLD = SCE_OURLIB_WORD3; SCE_OURLIB_HELP_DEF = SCE_OURLIB_HELP_BOLD;
  SCE_OURLIB_HELP_PRIM = SCE_OURLIB_WORD4;
  SCE_OURLIB_HELP_LINK = SCE_OURLIB_WORD6;

  SCE_OURLIB_HELP_END  = SCE_OURLIB_WORD6;

  HelpFromHelp = 6010;
  cHlpFunc = 'ПМ_ВЫД';
  cHlpVarPref = 'ПМ_';
  cHlpVarDef = 'ВЫД';
  sHelpTblVar = 'ПМТБЛ_';

	aDWHelp: TDWFormHelp = (0,0,6003,6003,6005,6006,6007,0,0,6009,0,HelpFromHelp);
  aDWActHelp: TDWFormHelp = (6301,6301,6303,6303,6305,6306,6307,6301,6301,6309,6301,HelpFromHelp);

  {LenRVid   = 40;
  LenRVName = 40;}

  GFWMaxMax = 99;		// Макс.толщина линий

  kmGFKbd = 25;		// Меню отметки
  kmGFObj = 26;		// Меню объектов

  GFFontPrimLen = 20;

	MDLenFile  = 8;
	MDLenName  = 50;
	DirModel   = 'MODELS';
	DirModels  = DirModel+PathDelim;

  LogCRLF = '~';
  LogDlm = '; '; lLogDlm = Length(LogDlm);

  logvNone    = 0;
  logvAppRec  = 1;
  logvEditRec = 2;
  logvDelRec  = 3;
  logvCngNum  = 4;
  logvMDLoad  = 5;
  logvDcmForm = 6;
  logvInter   = 7;
  logvLastVers= 8;

  logvCnt     = 8;

  logkNone    = 0;

  logkCnt     = 0;

  aActionLogVid: array[TFormAction] of longint = (logvAppRec,logvEditRec,logvAppRec,logvNone);
  aEdAppLog: TArrBoolInt = (logvEditRec,logvAppRec);

	NewExeName  = 'NEW.EXE';
	New1ExeName = 'NEW1.EXE';
  updCodeGet  = 'UCDGET';
  updArrDef   = 'UARRDEF';
  updDDat     = 'UDDAT';
  updTabu     = 'UTABU';
  updFormuls  = 'UFORMULS';
  updUserBmp  = 'UUSERBMP';

/////////////////////////////////////////////////////////////
// Используется только в программе SETUP.EXE и драйвере MYSQL
// Можно потом попытаться удалить
{ $IFDEF OLDCNF
	cnfServer = 1;
	cnfClient = 2;

	cnfCnt    = 2;
{$ENDIF}
/////////////////////////////////////////////////////////////

	DirDATA  = 'DATA';
	DirDATAs = DirDATA+PathDelim;

  sSYSDBA    = 'SYSDBA';
  smasterkey = 'masterkey';

  StLongProcess =
    UnDelim+'ВНИМАНИЕ!'+
    UnDelim+'Процесс может занять достаточно много времени.'+
    UnDelim+'Выключение или перезагрузка компьютера приведёт к потере данных.'+
    UnDelim+'Настоятельно рекомендуется дождаться окончания процесса.';

  SCod_C='cod_c'; qCod_C=sLIKE+'{'+SCod_C+'}';

	sDEDlm = '~';

  cQQ = '"';

  aInList: array[boolean,1..2] of string =
    ((sOR ,''  )
    ,(sAND,sNOT)
    );

  mniDlm='^'; lmniDlm=Length(mniDlm); lmniDlm1=lmniDlm+1;

  cRdBeg = '@NB';
	cRdArrange = '@A';
  aRdArrange: array[TRGArrangeList] of char = ('C','R');

	cChkPictPlace = '@P';
  cppLeft   = 'L';
  cppRight  = 'R';
  cppTop    = 'T';
  cppBottom = 'B';

  cMnCod    = '@C';
  cMnNoName = '@N';
  cMnNoNum  = '@S';

  aMnOpt: TMenuGetStr = (cMnCod,cMnNoName,cMnNoNum);
  MnOptInv = [mngName,mngNum];

  cCdName     = '@N';
  cCdCod      = '@C';
  cCdNameOnly = '@T';
  cCd0        = '@0';
  cCdAny      = '@X';

  cBoolSay  = '@S';
  cBoolLeft = '@L';

  cOnlyList = '@L';

	cDtMY   = 'MM.YY';
  cDtDay  = 'DD';
  cDtYear = 'DD.MM.YYYY';
  cDtYYYY = 'YYYY';
  cDtEnd  = '@END';
  cDtWeek = '@WEEK';

	bfgReadOnly = '@R';
  
	cButFormMax = '@';

  cButCapt ='@H';

  cAtPartEnd ='@';

  PosToAlgm: array[0..2] of TAlignment = (taLeftJustify,taCenter,taRightJustify);

  cBoldDlm = #31;
  cBoldVid = #30;
  cBoldRow = #29;
  cBoldCol = #28;
  cGetPrim = #27;
  cLink    = #26;

	btCrlf = '`';

  cMaxW = 'W';
  cMaxH = 'Sy';

  aDDatMemoAttr: array[TDDatZnType] of TFldMemoAttr = (famMemo,famSel);
  lDDatMemo = Length(aDDatMemoAttr);

  LastVersDefEditPages = '1';

  FldMemoAttrAll = [low(TFldMemoAttr)..high(TFldMemoAttr)];

  wallLow     = -2;

  wallNoSay   = -2;
  wallDefault = -1;

  NegDef = -1;

  sDots = '...'; lDots=Length(sDots);

  SelNoUsedKey: TKeyBut = (key:K_Shift_F8; Part:kmList; Hint:'Отметить неиспользуемые');
  
  aPdgName: TPdgStr = ('именительный','родительный','дательный','винительный','творительный','предложный');
  aPdgVar : TPdgStr = ('ПАДЕЖ_ИМЕНИТ','ПАДЕЖ_РОДИТ','ПАДЕЖ_ДАТ','ПАДЕЖ_ВИНИТ','ПАДЕЖ_ТВОРИТ','ПАДЕЖ_ПРЕДЛ');

  aSex: TSexStr = ('М','Ж');
  aSexName: TSexStr = ('мужской','женский');
  
  aBuiltIn: array[TBuiltInList] of record
    name,PrmType,PrmPrim: string;
  end =
    ((name:'ПОВТОРИТЬ'         ;PrmType:'C^N'             ;PrmPrim:'Стр: строка^КолПовт: целое')
    ,(name:'ПУСТО'                                        ;PrmPrim:'[Знач: любое]')
    ,(name:'ОКРУГЛИТЬ'         ;PrmType:'N^NU^LU'         ;PrmPrim:'Знач: число^[Точность: целое = 0]^[Вверх: логическое = '+vFalse+']')
    ,(name:'ПРОЦЕНТ'           ;PrmType:'N^N^NU^LU'       ;PrmPrim:'Сумма: число^Проц: число^[Точность: целое]^[Вверх: логическое = '+vFalse+']')
    ,(name:'ТИП'               ;PrmType:'^LU'             ;PrmPrim:'[Знач: любое]^[ЦелДроб: логическое = '+vFalse+']')
    ,(name:'ОТМ_ПОЗИЦИЯ'       ;PrmType:'CN^N^LU^NU'      ;PrmPrim:'Стр: строка|целое^Поз: целое^[Знач: логическое]^[Часть: целое = 1]')
    ,(name:'ОТМ_МАССИВ'        ;PrmType:'C^NU^NU'         ;PrmPrim:'Стр: строка~Стр: строка~Стр: строка^~КолЧастей: целое~Нач: целое^~КолПоз: целое')
    ,(name:'ПРОБЕЛЫ_СЛЕВА'     ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'ПРОБЕЛЫ_СПРАВА'    ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'ПРОБЕЛЫ_УБРАТЬ'    ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'СТРОКА_ПОИСК'      ;PrmType:'C^CA^CAU'        ;PrmPrim:'Стр: строка^Поиск: строка|массив^[Замена: строка|массив]')
    ,(name:'ЧИСЛО'             ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'ВЫБОР'             ;PrmType:'L'               ;PrmPrim:'Усл: логическое^[Выражение1: любое]^[Выражение2: любое]')
    ,(name:'СТРОКА_МАСКА'      ;PrmType:'C^C^CU'          ;PrmPrim:'Стр: строка^Маска: строка^[Разд: строка]')
    ,(name:'ДЛИНА'             ;PrmType:'CA'              ;PrmPrim:'Знач: строка|массив')
    ,(name:'МАССИВ'            ;PrmType:'N^NU^NU^NU^NU'   ;PrmPrim:'Разм1: целое^[Разм2: целое]^[Разм3: целое]^[Разм4: целое]^[Разм5: целое]')
    ,(name:'МАС_ВСТАВИТЬ'      ;PrmType:'A^N'             ;PrmPrim:'Мас: массив^Номер: целое^[Знач: любое]')
    ,(name:'МАС_ДОБАВИТЬ'      ;PrmType:'A'               ;PrmPrim:'Мас: массив^[Знач: любое]^[ВидПоиска: логическое|целое|строка]')
    ,(name:'МАС_УДАЛИТЬ'       ;PrmType:'A^N'             ;PrmPrim:'Мас: массив^Номер: целое')
    ,(name:'МАС_ПОИСК'         ;PrmType:'A^^LNCU'         ;PrmPrim:'Мас: массив^[Знач: любое]^[Вид: логическое|целое|строка = 0]')
    ,(name:'МАС_СЛОЖИТЬ'       ;PrmType:'AU'              ;PrmPrim:'[Мас%d: массив]')
    ,(name:'МАС_ДОПОЛНИТЬ'     ;PrmType:'A^N^^LU'         ;PrmPrim:'Мас: массив^Длина: целое^[Заполн: любое]^[ЗапСтр: логическое = '+vTrue+']')
    ,(name:'МАС_ЗАПОЛНИТЬ'     ;PrmType:'AN^^NU^NU'       ;PrmPrim:'Мас: массив|целое^[Заполн: любое]^[Начало: целое = 1]^[Кол: целое = ДЛИНА(Мас)]')
    ,(name:'МАС_РАСПРЕД'       ;PrmType:'A^N^NA^ALU^LU'   ;PrmPrim:'Мас: массив^Точн: целое^Сумма: число~Сумма: массив^[Оптим: логическое = '+vFalse+']~[Приор: массив]^[Знак: логическое = '+vFalse+']')
    ,(name:'МАС_ВЫБОР'         ;PrmType:'^A^A'            ;PrmPrim:'[Усл: любое = '+vTrue+']^МасУсл: массив^МасЗн: массив^[Умолч: любое]')
    ,(name:'МАС_СОРТ'          ;PrmType:'A^^'             ;PrmPrim:'Мас: массив^[Вид: любое]^[Пар%d: любое]')
    ,(name:'МАС_ЧАСТЬ'         ;PrmType:'A^NU^NU^LU'      ;PrmPrim:'Мас: массив^[Номер: целое = 1]^[Длина: целое = ДЛИНА(Мас)]^[Отриц: логическое = '+vFalse+']')
    ,(name:'МАС_ЗНАЧЕНИЕ'      ;PrmType:'A^N'             ;PrmPrim:'Мас: массив^Номер: целое')
    ,(name:'МАС_УМОЛЧ'                                    ;PrmPrim:'[Знач: любое]')
    ,(name:'СТРОКА_МАССИВ'     ;PrmType:'C^CU^LU^LU'      ;PrmPrim:'Стр: строка^[Рзд: строка = ","]^[Кон: логическое = '+vTrue+']^[Числ: логическое = '+vFalse+']')
    ,(name:'МАССИВ_СТРОКА'     ;PrmType:'A^CU^LU'         ;PrmPrim:'Мас: массив^[Рзд: строка = ","]^[Посл: логическое = '+vTrue+']')
    ,(name:'ПОДСТРОКА'         ;PrmType:'C^NU^NU^LU'      ;PrmPrim:'Стр: строка^[Начало: целое = 1]^[Длина: целое = ДЛИНА(Стр)]^[Отриц: логическое = '+vFalse+']')
    ,(name:'ПОДЧЕРКНУТЬ'       ;PrmType:'C^NU'            ;PrmPrim:'Стр: строка^[Длина: целое = ДЛИНА(Стр)]')
    ,(name:'ПОДЧЕРКНУТЬ_СЛЕВА' ;PrmType:'C^NU'            ;PrmPrim:'Стр: строка^[Длина: целое = ДЛИНА(Стр)]')
    ,(name:'ПОДЧЕРКНУТЬ_СПРАВА';PrmType:'C^NU'            ;PrmPrim:'Стр: строка^[Длина: целое = ДЛИНА(Стр)]')
    ,(name:'ПОДЧЕРКНУТЬ_ЦЕНТР' ;PrmType:'C^NU'            ;PrmPrim:'Стр: строка^[Длина: целое = ДЛИНА(Стр)]')
    ,(name:'ПРЕОБР_БОЛЬШИЕ'    ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'ПРЕОБР_БОЛЬШОЙ'    ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'ПРЕОБР_МАЛЫЕ'      ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'ПРОБЕЛЫ_СЖАТЬ'     ;PrmType:'C^CU'            ;PrmPrim:'Стр: строка^[Символы: строка]')
    ,(name:'СИМВОЛЫ_СЛЕВА'     ;PrmType:'C^N^CU'          ;PrmPrim:'Стр: строка^Длина: целое^[Заполн: строка = " "]')
    ,(name:'СИМВОЛЫ_СПРАВА'    ;PrmType:'C^N^CU'          ;PrmPrim:'Стр: строка^Длина: целое^[Заполн: строка = " "]')
    ,(name:'СИМВОЛЫ_ЦЕНТР'     ;PrmType:'C^N^CU'          ;PrmPrim:'Стр: строка^Длина: целое^[Заполн: строка = " "]')
    ,(name:'СТРОКА'            ;PrmType:'NCU^NAU^NU^NU^CU';PrmPrim:'[Знач: число|строка]^[Длина: целое]~[ФмтЧисл: массив]^[Точность: целое = 0]^[ВидТочн: целое = 0]^[Разделитель: строка = ","]')
    ,(name:'СТРОКА_0'          ;PrmType:'NCU^NU'          ;PrmPrim:'[Знач: целое|строка]^[Длина: целое]')
    ,(name:'СТРОКА_РАЗБИТЬ'    ;PrmType:'C^N^NU^LU^LU'    ;PrmPrim:'Стр: строка^Высота: целое^[Длина: целое = 0]^[Выровнять: логическое = '+vFalse+']^[УбрПроб: логическое = '+vFalse+']')
    ,(name:'СТРОКА_ЧАСТЬ'      ;PrmType:'C^N^NU^N^LU'     ;PrmPrim:'Стр: строка^Высота: целое^[Длина: целое = 0]^Номер: целое^[Выровнять: логическое = '+vFalse+']')
    ,(name:'СУММА_ПРОПИСЬЮ'    ;PrmType:'N^NU'            ;PrmPrim:'Сумма: число^[Род: целое]')
    ,(name:'СТРОКА_DOS'        ;PrmType:'C^LU'            ;PrmPrim:'Стр: строка^[ТолькоАлфавит: логическое = '+vFalse+']')
    ,(name:'СТРОКА_WIN'        ;PrmType:'C^LU'            ;PrmPrim:'Стр: строка^[ТолькоАлфавит: логическое = '+vFalse+']')
    ,(name:'СТРОКА_ВСТАВКА'    ;PrmType:'C^N^N^C'         ;PrmPrim:'Стр: строка^Начало: целое^Длина: целое^Замена: строка')
    ,(name:'СИМВОЛ_КОД'        ;PrmType:'C'               ;PrmPrim:'Симв: строка')
    ,(name:'КОД_СИМВОЛ'        ;PrmType:'N'               ;PrmPrim:'Код: целое')
    ,(name:'СТРОКА_ШАБЛОН'     ;PrmType:'C^C'             ;PrmPrim:'Стр: строка^Шабл: строка')
    ,(name:'ФОРМАТ_ПАРАМЕТР'   ;PrmType:'N'               ;PrmPrim:'Номер: целое^[Знач: любое]')
    ,(name:'ФОРМАТ_СТРОКА'     ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'РАЗД_МЕЖДУ'        ;PrmType:'CAU^CU^CLU^LU'   ;PrmPrim:'[Стр1: строка]~Мас: массив^[Стр2: строка]~Разд: строка^[Разд: строка]~[БезПроб: логическое = '+vTrue+']^[БезПроб: логическое = '+vTrue+']')
    ,(name:'РАЗД_ПОДСТРОКА'    ;PrmType:'C^NU^NU^CU^LU'   ;PrmPrim:'Стр: строка^[Начало: целое = 1]^[Длина: целое]^[Разд: строка = ","]^[Отриц: логическое = '+vFalse+']')
    ,(name:'ЧИСЛО_РИМСК'       ;PrmType:'N'               ;PrmPrim:'Знач: целое')
    ,(name:'СТРОКА_БЕЗ_ПРВ'    ;PrmType:'C^N^N'           ;PrmPrim:'Стр: строка^КолСтр: целое^КолСимв: целое')
    ,(name:'СТРОКА_16'         ;PrmType:'NC^N'            ;PrmPrim:'Знач: целое|строка^Длина: целое')
    ,(name:'ЦЕЛАЯ_ЧАСТЬ'       ;PrmType:'N'               ;PrmPrim:'Знач: число')
    ,(name:'МАКСИМУМ'          ;PrmType:'NDA^NDU'         ;PrmPrim:'Знач1: число|дата~Знач: массив^Знач2: число|дата')
    ,(name:'МИНИМУМ'           ;PrmType:'NDA^NDU'         ;PrmPrim:'Знач1: число|дата~Знач: массив^Знач2: число|дата')
    ,(name:'МОДУЛЬ'            ;PrmType:'N'               ;PrmPrim:'Знач: число')
    ,(name:'ЦЕЛ_ДЕЛИТЬ'        ;PrmType:'N^N'             ;PrmPrim:'Делимое: целое^Делитель: целое')
    ,(name:'ЦЕЛ_ОСТАТОК'       ;PrmType:'N^N'             ;PrmPrim:'Делимое: целое^Делитель: целое')
    ,(name:'СЛУЧАЙНОЕ_ЧИСЛО'   ;PrmType:'N^N'             ;PrmPrim:'НижГран: целое^ВерхГран: целое')
    ,(name:'ГОД_КОНЕЦ'         ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'ГОД_НАЧАЛО'        ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'ДАТА_ГОД'          ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'ДАТА_ДЕНЬ'         ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'ДАТА_МЕСЯЦ'        ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'ДАТА_ПРОПИСЬЮ'     ;PrmType:'D^CU'            ;PrmPrim:'Знач: дата^[Формат: строка = «d mmmm yyyy"г."»]')
    ,(name:'ДАТА_ЦИФРАМИ'      ;PrmType:'D^LU^CU'         ;PrmPrim:'Знач: дата^[ГодПолн: логическое = '+vFalse+']^[Разд: строка]')
    ,(name:'МЕС_КОНЕЦ'         ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'МЕС_НАЧАЛО'        ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'МЕСЯЦ_ГОД'         ;PrmType:'D^LU'            ;PrmPrim:'Знач: дата^[МесРод: логическое]')
    ,(name:'ПЕРИОД_МЕС'        ;PrmType:'D^D'             ;PrmPrim:'Мес1: дата^Мес2: дата')
    ,(name:'ПЛЮС_МЕСЯЦ'        ;PrmType:'D^NU'            ;PrmPrim:'Знач: дата^[КолМес: целое = 1]')
    ,(name:'СТРОКА_ДАТА'       ;PrmType:'CNA'             ;PrmPrim:'Знач: строка|число|массив')
    ,(name:'РАЗНОСТЬ_МЕС'      ;PrmType:'D^D'             ;PrmPrim:'ДатаБольш: дата^ДатаМеньш: дата')
    ,(name:'ДАТА_СТРОКА'       ;PrmType:'DN'              ;PrmPrim:'Знач: дата|число')
    ,(name:'ДАТА_ВРЕМЯ'        ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'ДЕНЬ_НЕДЕЛИ'       ;PrmType:'D'               ;PrmPrim:'Знач: дата')
    ,(name:'ВЫПОЛНИТЬ'         ;PrmType:'C^CU^CU^LU'      ;PrmPrim:'Файл: строка^[Парам: строка = ""]^[Папка: строка]^[Win: логическое]')
    ,(name:'ПАРАМЕТР'          ;PrmType:'N'               ;PrmPrim:'Номер: число')
    ,(name:'SaveIni'           ;PrmType:'C^C^CU^CU'       ;PrmPrim:'Секция: строка^Идент: строка^[ПоУмолч: строка = ""]^[Знач: строка]')
    ,(name:'СООБЩЕНИЕ'         ;PrmType:''                ;PrmPrim:'НеИспольз: пусто~Знач1: строка|число|дата|логическое|массив^[Стр: любое]~[Знач%d1: любое]^[Загл: строка = ""]^[Прижать: логическое]')
    ,(name:'ЗАПРОС'            ;PrmType:'^LNU^CU^LU'      ;PrmPrim:'[Стр: любое]^[Актив: логическое|целое = '+vTrue+']^[Загл: строка = ""]^[Прижать: логическое]')
    ,(name:'ИНД_ПРОЦЕНТ'       ;PrmType:'ACU^NU^CU'       ;PrmPrim:'[Сообщ: массив|строка = ""]^[Процент: число]^[Загл: строка = ""]')
    ,(name:'Profile'           ;PrmType:'CU'              ;PrmPrim:'[Заголовок: строка = ""]')
    ,(name:'СООБЩЕНИЕ_ОТЛ'                                ;PrmPrim:'НеИспольз: пусто~Знач1: строка|число|дата|логическое|массив^[Стр: любое]~[Знач%d1: любое]^[Загл: строка = ""]^[Прижать: логическое]')
    ,(name:'ФОРМАТ_ОБНУЛИТЬ')
    ,(name:'ТРАНСЛИТ'          ;PrmType:'C^LU^LU'         ;PrmPrim:'Стр: строка^[ЛатРус: логическое = '+vFalse+']^[РусЛат: логическое = '+vFalse+']')
    ,(name:'ДОБАВИТЬ_ИЗ_ОСНОВЫ';PrmType:'C^C^CU'          ;PrmPrim:'Вид: строка^Основа: строка^[Код: строка = Основа]')
    ,(name:cHlpFunc            ;PrmType:'CAU^NCALU^CNU'   ;PrmPrim:'Стр: строка~[Стр: строка]~Стр: строка~Раздел: массив^[Шрифт: целое = '+cHlpVarPref+cHlpVarDef+']~Страница: строка~[Раздел: массив|строка|логическое]~^~[Файл: строка]~Вид: целое~')
    ,(name:cKeyLbFunc          ;PrmType:'N'               ;PrmPrim:'Клавиша: целое')
    ,(name:'СТРОКА_WIN_UTF8'   ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'СТРОКА_UTF8_WIN'   ;PrmType:'C'               ;PrmPrim:'Стр: строка')
    ,(name:'НД_PDF417'         ;PrmType:'CU^CU'           ;PrmPrim:'[Файл: строка]^[НаимНИ: строка]')
    ,(name:'ЖУРНАЛ_ЗАПИСАТЬ'   ;PrmType:'C^AU'            ;PrmPrim:'Информ: строка^[Ключ: массив]')
    ,(name:'СПИСОК_КОП'        ;PrmType:'C^C^LU'          ;PrmPrim:'КлючОткуда: строка^КлючКуда: строка^[Удал: логическое = '+vFalse+']')
    ,(name:'ArrDebug'          ;PrmType:'A'               ;PrmPrim:'Мас: массив')
    ,(name:'ПРАВА'             ;PrmType:'C'               ;PrmPrim:'Право: строка')
    ,(name:'ДОП_ПРАВА'         ;PrmType:'AC^CU'           ;PrmPrim:'Право: массив|строка^[Код: строка]')
    ,(name:'СТРУКТУРА'         ;PrmType:'C'               ;PrmPrim:'Наим: строка')
    ,(name:'МЕЖДУ'             ;PrmType:'NCD^NCD^NCD^NCDU';PrmPrim:'Знач: число|строка|дата~Нижн1: число|строка|дата^НижнГран: число|строка|дата~Верх1: число|строка|дата^ВерхГран: число|строка|дата~Нижн2: число|строка|дата^~Верх2: число|строка|дата')
    ,(name:'ГРАНИЦЫ'           ;PrmType:'NCD^NCD^NCD'     ;PrmPrim:'Знач: число|строка|дата^НижнГран: число|строка|дата^ВерхГран: число|строка|дата')
    ,(name:'ЗАМЕНИТЬ'                                     ;PrmPrim:'[Знач: любое]^[Что: любое]^[НаЧто: любое]')
    ,(name:'ПАДЕЖ_ФИО'         ;PrmType:'CA^N^CU'         ;PrmPrim:'Знач: строка|массив^Падеж: целое^[Пол: строка]')
    ,(name:'ПАДЕЖ_ПОДР'        ;PrmType:'C^N'             ;PrmPrim:'Знач: строка^Падеж: целое')
    ,(name:'ПАДЕЖ_ДОЛЖ'        ;PrmType:'C^N'             ;PrmPrim:'Знач: строка^Падеж: целое')
    ,(name:'ФИО_ЧАСТИ'         ;PrmType:'C'               ;PrmPrim:'Знач: строка')
    );

  aEdoExeType: TEdoExeTypeStr = ('Подписание','Проверка','Шифрование');
  aEdoExeIO: array[TEdoExeIO] of record
    nm: string;
    bool: boolean;
  end =
    ((nm:'командная строка')
    ,(nm:'успешный результат')
    ,(nm:'выходной файл')
    ,(nm:'вывод результата выполнения'; bool:true)
    );
  aEdoExeCtrl: TEdoExeCtrlStr = ('%fin','','%n','%p','%sh');
  
  EdoFmtDate = 'dd/mm/yyyy hh:nn';
  
  lUN=10;

  InvalidFileName: TInvalidFileName = ('/',PathDelim,DriveDelim,'*','?','"','<','>','|');
  
  aFio: array[TFio] of record
    f,nm: string;
  end =
    ((f:fFAMIL; nm:'фамилия' )
    ,(f:fNAME1; nm:'имя'     )
    ,(f:fNAME2; nm:'отчество')
    );
  LenFio = Length(aFio);

type //type2
  THelpCntAddProc = procedure(var result: THelpCntArr;
    clv: byte; const nm: string; const pg: string = ''; nf: longint = NegDef;
    AVid: THelpLinkList = low(THelpLinkList); const AHint: string = ''; Fix: boolean = false);
  THelpCntProc = procedure(var result: THelpCntArr; const Name: string; PrAdd: THelpCntAddProc);

  THelpLinkOper = (hlpLinkTrns,hlpLinkAdd);
  THelpLinkProc = procedure(Vid: THelpLinkList; Oper: THelpLinkOper; const name: string; p: pointer);

  TWMApplHint = record
   	Msg: longint;
    NoUsed: Word;
		Info: ^TApplHintInfo;
    Result: LongInt;
  end;

  TWMKeyInitProg = record
   	Msg,Key: longint;
    lExec: boolean;
   	Result: LongInt;
  end;

	TWMHelpFill = record
   	Msg: longint;
    Oper: THelpOper;
    case THelpOper of
      hlpFile: (pFile: ^THelpFileContext; ResFile: boolean);
      hlpVar: (pVar: PVariant; ResVar: boolean);
      hlpTrns,hlpAdd: (pArr: PHelpArr);
      hlpFillType: (pFillType: PHelpArr; ResFillType: THelpFillType);
      hlpLinkObj: (pLinkObj: PString);
	end;

  TWMCtrlInf = record
    Msg: longint;
    Oper: TCtrlInfOper;
    case TCtrlInfOper of
      ctiCount: (Count: PLongint);
      ctiItem: (Index: Longint; Item: TControl);
  end;

  TWMProtSave = record
   	Msg,Length: LongInt;
    FileName: PFileName;
    ResNoUsed: LongInt;
  end;

	TWMCalc = record
		Msg: longint;
		Operation: TCalcOper;
		ps: PDouble;
		Result: LongInt;
	end;

  TWMPaintCtl = record
    Msg: longint;
    Oper: TPaintCtlOper;
    NoUsed: longint;
    case TPaintCtlOper of
      pcmNoPaint: (NoPaint: boolean);
      pcmTabOrdCtl: (TabOrderControl: TComponent);
      pcmCanvas: (Canvas: TCanvas);
  end;

	TWMPSort = record
   	Msg: longint;
    Oper: TPSortOper;
		si: PPSortInfo;
    Result: LongInt;
	end;

	TWMSaveIni = record
   	Msg: longword;
    Oper: TSaveIniOper;
		pSection: PString;
    Result: LongInt;
  end;
  
  TWMGFSeek = record
   	Msg: longint;
		TypeObj: TGFSearchType;
    NumObj,Result: LongInt;
  end;

  TWMGetUpd = record
    Msg,UnUsed: longint;
    nmMsg: PString;
    ResUnUsed: longint;
  end;

	TWMActForm = record
   	Msg: longint;
    Visible: WordBool;
    NoUsed,Result: LongInt;
	end;

  TWMArrChange = record
    Msg: longint;
    pKa: PString;
    NoUsed,Result: longint;
  end;

  TSchemNameOper = (snGetSchem,snSetSchem);
	TWMSchemName = record
   	Msg: longint;
    Oper: TSchemNameOper;
		SchemName: PString;
    Result: LongInt;
	end;

  TBrFindOper = (brfindStr,brfindRow,brfindUpd);

  PBrFindUpd = ^TBrFindUpd;
  TBrFindUpd = record
    tr: longint;
    v: variant;
    f: TField;
  end;

	TWMBrFind = record
   	Msg: longint;
    Oper: TBrFindOper;
    case TBrFindOper of
      brfindStr: (Str: PString; Result: LongInt);
      brfindUpd: (Upd: PBrFindUpd);
	end;

  PFromCalcPrm = ^TFromCalcPrm;
  TFromCalcPrm = record
    d: Double;
    x,y: longint;
  end;

  TWMFromCalc = record
   	Msg,UnUsed: longint;
    Prm: PFromCalcPrm;
    Result: LongInt;
  end;

  TWMPlaceToCtrl = record
   	Msg,UnUsed: longint;
    Sender: ^PComponent;
    Result: LongInt;
  end;

	TWMEdoApplTitle = record
   	Msg: longint;
    case boolean of
      false: (UnUsed1,UnUsed2,Result: LongInt);
      true: (Blinked,UnUsed3,ReDef: WordBool);
	end;

	TSegmList = 1..SegmMaxCnt;
	TSegmStr = array[TSegmList] of string;

  TLineWidth = 1..MaxLineWidth;
  TLineNulWidth = 0..MaxLineWidth+1;

  TFloatChar = array[0..FloatMaxLen] of Char;

  PInterPrmArrVar = ^TInterPrmArrVar; TInterPrmArrVar = array[0..MAX_PRM] of variant;

  TKeyShftList  = 1..kshCnt;
  TKeyShftList0 = 0..kshCnt;

  TKeyList = 1..KEY_CNT;
	TKeyInt = array[TKeyList] of longint;
	TKeyStr = array[TKeyList] of string;

  TDWPostPrc = array[TDWPostList] of TProcent;

  THelpStyleList = SCE_OURLIB_HELP_BEG..SCE_OURLIB_HELP_END;

	TModelFile = string[MDLenFile];
	TModelName = string[MDLenName];

  TGFPackFontProp = record
    Prim: string[GFFontPrimLen];
    AType: TGFFontType;
    Width,Height: Double;
    Angle: Word;
    Dop: TGFPackFontPropDop;
  end;

  PGFParamItem = ^TGFParamItem;
  TGFParamItem = record
  	StdFormat: boolean;
  	NFormat: TGFFrmList;
    Orientation: TPrinterOrientation;
    GridLineWidth,GridLineMin: 1..GFWMaxMax;
    aBreak,aWidth: TBoolSet;
    PrmNum: TFmtNum;
    PrmDate: TFmtDate;
  	SpotMm: TRect;
    SizeMm: TSize;
    Name: string;
  end;

  TArrGFParam = array of TGFParamItem;

  TGFParams = record
    DateTime: boolean;
    Arr: TArrGFParam;
  end;

  TPPDocRec = record
  	Params: TGFParams;
    Fonts: string;
  end;

  TGFLine = record
  	Width: TLineWidth;
    Color: TColor;
  end;
  TGFLines = array[Byte] of TGFLine;

  TRVid = string{[LenRVid]};
  TRVName = string{[LenRVName]};

{ $IFDEF OLDCNF
	TConfigList = 1..cnfCnt;
  TConfigArr = array[TConfigList] of string;
  TConfigStr = string[cnfCnt];
{$ENDIF}

const //const2
  aSign: TArrBoolSign = (1,-1);

  lDefFont = SizeOf(TDefFont);

  asFormCaption: array[TFormAction] of string = ('Добавление','Редактирование','Копирование','Просмотр');

  Bool2BSet: array[boolean] of TBSetList = (bsetFalse,bsetTrue);

  aResProcessName: TResProcessStr = ('Interbase Server','Firebird');

  aBMName: array[TBMList] of string =
  	('None','Down','Up','Left','Right','Left_Right','Plus','Eval',
    'Fill_Top','Fill_Bottom','Fill_Left','Fill_Right','Fill_Out','Fill_None',
    'GF_Top_Left','GF_Top_Right','GF_Bot_Left','GF_Bot_Right',
    'GF_SortCop','GF_NoSortCop','GF_NoEcon','GF_EconVert','GF_EconFull',
    'GF_OR_Portrait','GF_OR_Landscape','GF_Book','GF_Book1','GF_NoBook',
    'VTabl_Std','VTabl_1','VTabl_2','Check','Check_Emp','NoCheck','NoCheck_Emp','Down_List','DDat',
    'Pswd_Hide','Pswd_Show','Connect','NoAllowed');

  aqEq: TArrBoolStr = ('<>','=');

  aAbr1Beg: array[boolean] of TAdr1Str =
    (('','','','','','','','','','','дом','','кв.','','')
    ,('','','','','','','','','','','д.' ,'','кв.','','')
    );

  SizeOfVar: array[TSaveType] of longint =
    (SizeOf(ShortInt),SizeOf(SmallInt),SizeOf(LongInt),SizeOf(Byte),SizeOf(Word),
    SizeOf(Boolean),SizeOf(longword),SizeOf(Single),SizeOf(Double),SizeOf(Int64),SizeOf(Char));

  aKeyPrmDef: TButtonTypeStr =
    ('3'+UnDelim+'0'+UnDelim+'да'
    ,'да'
    ,'1'+UnDelim+'5'+UnDelim+'3'+UnDelim+'0'+UnDelim+'нет'+UnDelim+'да'+UnDelim+'да'+UnDelim+'да'
    ,'0'+UnDelim+'0'+UnDelim+'60'+UnDelim+'5'+UnDelim+'нет'+UnDelim+'да'
    ,'2'+UnDelim+'0'+UnDelim+'Влево'+UnDelim+'да'
    ,'Выпуклый'+UnDelim+'10'+UnDelim+'10'+UnDelim+'да'
    ,'Ромб'+UnDelim+'0'+UnDelim+'0'+UnDelim+'да'+UnDelim+'10'+UnDelim+'нет'+UnDelim+'оба'
    ,'нет'+UnDelim+'вдавлена'+UnDelim+'7'+UnDelim+'7'+UnDelim+'3'+UnDelim+'3'+UnDelim+'справа'
    );

  aKeyLab: TKeyInt =
    (VK_F1,VK_F2,VK_F3,VK_F4,VK_F5,VK_F6,VK_F7,VK_F8,
    VK_F9,VK_F10,VK_F11,VK_F12,VK_RETURN,VK_ESCAPE,
    VK_TAB,VK_SPACE,VK_HOME,VK_END,VK_INSERT,VK_DELETE,
    VK_PRIOR,VK_NEXT,VK_UP,VK_DOWN,VK_LEFT,VK_RIGHT,VK_BACK,
    Word('A'),Word('B'),Word('C'),Word('D'),Word('E'),Word('F'),
    Word('G'),Word('H'),Word('I'),Word('J'),Word('K'),Word('L'),
    Word('M'),Word('N'),Word('O'),Word('P'),Word('Q'),Word('R'),
    Word('S'),Word('T'),Word('U'),Word('V'),Word('W'),Word('X'),
    Word('Y'),Word('Z'),Word('0'),Word('1'),Word('2'),Word('3'),
    Word('4'),Word('5'),Word('6'),Word('7'),Word('8'),Word('9'),
    188,190,187,189,Word('*'),Word('/'));

  DWsetLen = [dwtString,dwtFloat,dwtManyStr];

  aDWSvTypeNm: TDWSaveStr = ('нефиксированный','фиксированный','динамический');
  aDWSvTypeChr: TDWSaveStr = ('','X','Z');

  aDWDDatType: TDDatStr = ('день','месяц','квартал','год');

  aDWDDatD2: array[TDDatD2] of string = ('Вводится начало и конец периода',
    'Конец периода равен наибольшей дате','Значения изменяются каждый период','Период не вводится');

  aDWFld: array[TDWFldType] of record
    c: char;
    nm: string;
    tp: TFieldType;
  end =
    ((c:'S'; nm:'строка'    ; tp:ftString)
    ,(c:'N'; nm:'число'     ; tp:ftFloat)
    ,(c:'D'; nm:'дата'      ; tp:ftDateTime)
    ,(c:'L'; nm:'логическое'; tp:ftBoolean)
    ,(c:'M'; nm:'текст'     ; tp:ftMemo)
    ,(c:'A'; nm:'массив'    ; tp:ftArray)
    ,(c:'T'; nm:'строки'    ; tp:ftString)
    ,(c:'C'; nm:'выбор'     ; tp:ftMemo)
    ,(c:'U'; nm:'составной' ; tp:ftMemo)
    );

  setDBReal = [faNormal,faMemo,faSel];
	setDBDupl = [faDefMemo,faFix,faFixMemo,faFixSel];
	setDBDef  = setDBDupl+[faDef,faFixArray];

  aMemoDwt: array[TFldMemoAttr] of TDWFldType = (dwtMemo,dwtArray,dwtSel);
  aBegMem: TFldMemoAttrStr = (sMemo,sArray,sSel);
  aBegMemFix: TFldMemoAttrStr = (sFixMemo,sArray,sFixSel);

  aDWPost: array[TDWPostList] of record
    post: char;
    nm: string;
  end =
    ((post:'D';nm:'данные')
    ,(post:'W';nm:'окно ввода')
    );
  DWPostLen = Length(aDWPost);

  aDWActionPrm: array[TDWActionList] of char = ('Д','К','Р');
  
  aGFAlgm: TGFAlgmStr =
    ('сверху,слева'
    ,'сверху,в центре'
    ,'сверху,справа'
    ,'в центре,слева'
    ,'в центре'
    ,'в центре,справа'
    ,'снизу,слева'
    ,'снизу,в центре'
    ,'снизу,справа'
    );
    
	aGFWtoS: array[TGFWinList] of TGFSearchType = (gfsWDat,gfsWPrm,gfsWDop);

  aDECharCase: array[TDECharCase] of string = ('[нет]','в большие','в малые');

var //var1
  ExeDir,CurrentDir,MaxMonth,IconFileName,PrivDesign,ScrConsole,LogPrimBeg,LogPrimEnd,
    NotePrivModelLoad,sMDKey: string;
  TmpFile: string = cTmpFile;
  InterCurHelpFile: string = HelpFileStd;
  FormWndDestroying,InsModeOverride,ApplMinimizing,MessagesHidden,isCalculator,EdTextInitFind,
    MustReboot,FdpFormOnView,SimpleForm,ProfSwitch: boolean;
  FormsFree: boolean = true;
  NormalExit: boolean = true;
  ChrCheck: char = ' ';
	nPrnHead: byte = 0;
  LastKey,KeyActive: longint;
  FormLimit: longint = 30;
  FormLimTime: longint = 10;
  DWPageNumEdit: longint = -1;
  NulFloat: Extended;
  VBMName,VAKeys,VAShftKeys,VARusPart: variant;
  SystemRoot,FileServices,FileHosts: TFileName;
  //MainHookProc: TWindowHook;
  Rect0: TRect;
  PUserWorkArea: PRect;
  //SysOSR2: boolean = false;
	LsCustomRec: TStringList;
  LsFormWnd: TList;
  aFld1CDAdr: array[TAdr1List] of TAdrCDList0;
  MessagesOkHidden: TBoolSet = [true];
  GlobButtonRec: TButtonRec;
  aGFLines: ^TGFLines;
  aGFStoW: array[TGFSearchType] of TGFWinList;
  aGFLtoW: array[boolean] of array of TGFWinList;
  aBuiltInProc: array[TBuiltInList] of record // Не удалось объединить с aBuiltIn, не компилируется GGMaster
    Proc: TBuiltInProc;
    aPrmType,aPrmPrim: TArrStr;
  end;
  FindProperty: TFindProperty;
  aPrnPrmDef: array[TPrnPrmList] of record
  	lSave: boolean;
    Def: variant;
  end;
  sPrnPrmBool: TPrnPrmSet;
  CheckSize: TSize;
  FEChangeWhere: TFEChangeWhere;
	setDEDlm: set of TDEPrmList;
  FldLsCurVR: TDWVidRec;
  aPrnHead: array[1..20] of string;
  AlgmToPos: array[TAlignment] of byte;
  aDDatZnFld: array[TDDatZnType] of variant;
  DataWinFree,HelpLsLoad,DfrmClearCod {$IFDEF PROF},ProfOn {$ENDIF},UserBmpClear: TProcNone;
  UpdArrGet,DDatLsExec: TNotifyEvent;
  c_dwnd,c_edfile,c_dbopen,c_dbclose,c_createtable: TFuncevent;
  c_EdFormEd: function(lSetMod: boolean): boolean;
  PrivProc: TPrivProc;
  PrimTrans,DerTrans: TPrimTrans;
  nUserGGProc: procedure(var nGG: longint);
  LogMsgProc: TLogMsgProc = nil;
  //ProcInterCompOper: procedure(c: char; var oper: byte);
  //ProcInterEvalOper: procedure(oper: byte; var stack: array of variant; var ist: longint; var EvalStd: boolean);
  InterMsgErrorProc: TInterMsgErrorProc;
  AddKeyStackProc: procedure(const skey: string) of object;
  DDatSetValProc: TDDatSetValProc;
  LogActive: TFuncBool;
  DWCanDelProc: TDWCanDelEvent;
  DWCngNameProc: TDWCngNameEvent;
  DDGetValue: function(vid: longint; const kv: string; lDop: boolean = false): variant;
  DDSetValue: function(vid: longint; const kv: string; const zn: variant): boolean;
  //DDGetKvInfo: function(vid: longint; const kv: string; var inf: PDDatKvInfo): boolean;
  DDSelCodeGet: procedure(vid: longint; const kv: string; var SelVid,SelVName: string);
  PrStdGetState: procedure(var v: variant; Opt: TStdGetStateOpt);
  //PrGFTextRect: procedure(Canvas: TCanvas; const Rect: TRect; X,Y: longint; const Text: string);
  LockLstCngFldProc: procedure(Sender: TObject; lBefore: boolean; var fqNAME: TField) of object;
  LogFltMaskFldProc: procedure(const NmFld: string; var Mask: string) of object;
  mess_ok: procedure(const a: array of string; const Capt: TCaption = '';
  	Algm: TAlignment = taCenter; lDbg: boolean = false);
  ask: function(const a: array of string; State: boolean = true;
  	const Capt: TCaption = ''; Algm: TAlignment = taCenter): boolean;
  CreateForm: function(ComponentClass: TComponentClass; var Reference;
    lNoLimit: boolean = true): boolean;
  FormFree: function(var f): boolean;
  BeforeShowOther,LastForm: function: TForm;
	AfterShowOther: procedure(f: TForm);
  IsLastForm: function(var f: TForm): boolean;
  FormSummExec: procedure(const sl: string = ''; const sc: string = ''; const Capt: string = '';
    const CaptX: string = ''; const CaptY: string = '';
    ProcHead: TFormSummHead = nil; PrmHead: pointer = nil; PrmNum: PFmtNum = nil; Sender: TObject = nil;
    ProcShow: TNotifyEvent = nil; NoColWidthsCorr: boolean = false);
  LockExec: function(const Capt: string; ProgPswd: TObject;
    Options: TLockLstOptions = []; const Head: string = '';
    const where: string = ''; PrUsl: TProcValid = nil): boolean;
  PrnTxtExec: procedure(const txt: string; const sel: string = ''; DefFont: TFont = nil);
  PrnTxtHeadExec: procedure(const aHead: array of string;
    const txt: string; const sel: string = ''; DefFont: TFont = nil);
  DirExec: function(Sender: TComponent; const Capt,Root,Ident: string;
    var Directory: string; OpenDialog: TOpenDialog = nil; Options: TTreeDirOptions = [];
    Proc: TDirExecProc = nil): Boolean;
  FileExec: function(const Ident: string; OpenDialog: TOpenDialog;
    Sender: TComponent = nil; Options: TTreeDirOptions = []; const Root: string = '';
    const Capt: string = ''; Proc: TDirExecProc = nil): boolean;
	EdTextExec: function(const capt: string; var txt: string;
    const dname: string = ''; dfunc: TKeyProc = nil; Opt: TEdTextOpt = []; EdType: TEdTextType = edtpText;
    crStart: longint = 0; crLen: longint = 0; const InfStr: string = '';
    hc: THelpContext = 0; AfterShow: TNotifyEvent = nil; const MsgErrBig: string = '';
    PrEditIfError: TNotifyEvent = nil; pav: PArrVar = nil; const FileName: TFileName = '';
    BeforeShow: TNotifyEvent = nil; ChangeFileName: TNotifyEvent = nil; HelpProc: TWndMethod = nil;
    PrMaxLength: TMaxLengthEvent = nil): boolean;
  DDBufClearAll: procedure(lCodLoad: boolean = false);
  DDGetTrans: procedure(inf: PDDatKvInfo; const v: variant; var s: string; var Default: boolean);
  DWValStrTrans: procedure(const v: variant; var s: string; var Default: boolean);
  DataWinCreate: function: TObject;
  DataWinFields: function(Sender: TObject; const Wnd: string): string;
  DataWinSearchIdent: function(Sender: TObject; const s,sSubStr: string; var aInfo: TDWSearchAInfo;
    lIdent: boolean = true): boolean;
  DataWinReplaceIdent: function(Sender: TObject; var s: string; const stSource,sRepl: string;
    Opt: TGFReplaceOpt = []; PrRepl: TReplaceProc = nil; pav: PVariant = nil): longint;
  GetButton: procedure(Canvas: TCanvas; const FirstPos: TPoint; const txtAction,txtHotKey: String;
  	Opt: TButtonOpt; var result: TSize; const GlobButtonRec: TButtonRec; bm: TBitMap = nil);
  GlobButtonDef: function: TButtonRec;
  CopyFileOpt: function(const fFrom,fTo: TFileName; Options: TCopyFileOptions = []; Attr: longword = 0;
    UserAbort: PBoolean = nil; const Capt: TCaption = ''): boolean;
  ProtocolStrAdd: procedure(const FileName: variant; const s: string;
    Opt: TProtocolAddOpt = []; paTbl: PArrStr = nil); 
  ProtSQLStrAdd: procedure(const s: string; lStack: boolean = false); 
  WinFind: function(Sender: TControl; prf: TPrFind; opt: TFindOptions = []; const Capt: string = ''): boolean;
  WinFindKey: function(Key: longint; Sender: TControl; prf: TPrFind; opt: TFindOptions = []; const Capt: string = ''): boolean;
  WinFindSayStat: function(const Prc: variant): boolean;
  PswdSendUpd: procedure(const nmMsg: string; lSelf: boolean = false);
  LogWrite: procedure(const tbl: string = ''; const prim: string = '');
  DiskWait: function(const cpTo,cpFrom: TFileName; const cnmf: variant; Opt: TDiskWaitOpt = []): boolean;
  DWTypeManyProc: TDWTypeManyProc;
  PswdPrm: function: PPswdPrm;
  RbPagePgActive: procedure(tw: TWinControl);
  TrnsStart: function(const aTable: array of string; flLock: longint = 0;
  	ProcLock: TProcLock = nil; lSetDBS: boolean = false): boolean;
  TrnsEnd: procedure(Opt: TTrnsEndOpt = []; ProcUnLock: TProcNone = nil);
{$IFDEF PROF}
  ProfOut: procedure (const Capt: TCaption = '');
  ProfAddTime: procedure(FuncName: PString; const FuncAdd: string; oTime: longword; lIncCnt: boolean);
{$ENDIF}
  GetUsPrm: function(const Index: string; const cName: string = ''): string;
  SetUsPrm: procedure(Sender: TControl; const Index,Val: string; const cName: string = '');
  GetLogVid: function: longint;
  SetLogVid: procedure(Value: longint = logvNone);
  CngLogVid: function(Value: longint; OnlyCng: boolean = false): longint;
  GetFieldInfo: function (const tbl,nmf: string): PMQFieldInfo;
  HelpReBoldStr: function(const st: string): string;
  //DocPrmDWSeek: procedure(Sender: TObject; var Prm: pointer; lAfter: boolean);
  {aSetNewExeVers,}aCngPriv,aCngSelfPriv,aNetSelProc: TArrProcNone;
  aBrEditProc: array of TBrEditProc;
  aWndKeyProc,aPswdKeyProc: TKeyEvalProcArr;
  aDWFldDefaultProc: array of TDWFldDefaultProc;
  aHelpTblProc: array of THelpTblProc;
  aHelpCntProc: array of THelpCntProc;
  aHelpLinkProc: array of THelpLinkProc;
  aModelGetCreate: array of TMDInterVarCreate;
  aRegsDelProc: array of TRegsDelProc;
  aDDatLsProc: array of TDDatLsProc;

implementation

initialization
  aPrnPrmDef[pprmStr].Def:=GFStrAll; aPrnPrmDef[pprmCntCop].Def:=1; aPrnPrmDef[pprmSortCop].Def:=true;
  aPrnPrmDef[pprmEcon].Def:=GFEconNone; aPrnPrmDef[pprmVIntv].Def:=3; aPrnPrmDef[pprmHIntv].Def:=3;
  aPrnPrmDef[pprmBook].Def:=0; aPrnPrmDef[pprmFeed].Def:=1; aPrnPrmDef[pprmNoNewPg].Def:=false;
  aPrnPrmDef[pprmMirror].Def:=false;
  ZeroMemory(@Rect0,SizeOf(Rect0));
  NulFloat:=IntPower(10,-FloatMaxDec)-IntPower(10,-FloatMaxDec-1);
end.
