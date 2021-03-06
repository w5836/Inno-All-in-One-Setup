;
; Inno Setup 5.1.5
;
;
; Portion of code Renato Cazzaro
; http://news.jrsoftware.org/news/innosetup.code/msg03380.html
;

[Setup]
AppName=FileTimeV5
AppVerName=FileTimeV5
Uninstallable=false
UpdateUninstallLogAppName=false
DisableDirPage=true
DisableProgramGroupPage=true
DefaultDirName={pf}\FileTimeV5
DisableStartupPrompt=true
OutputBaseFilename=Test Install
OutputDir=userdocs:Inno Setup Examples Output

#include "LangLib.ish"

[Code]

type

//TFileTime = Record
//    lowdatatime: longint;
//    highdatatime: longint;
//End;

TSystemTime = record
    wYear : Word;
    wMonth : Word;
    wDayOfWeek : Word;
    wDay : Word;
    wHour : Word;
    wMinute : Word;
    wSecond : Word;
    wMilliseconds : Word;
end;

function GetFileTime(hfile: longint; var lpcreation,lpaccess,lpwrite:TFileTime): boolean;
external 'GetFileTime@kernel32.dll stdcall';

function FileTimeToSystemTime(var tftm: TFileTime; var systm: TSystemTime): boolean;
external 'FileTimeToSystemTime@kernel32.dll stdcall';

function FileTimeToLocalFileTime( utct: TFileTime; var loct: TFileTime): boolean;
external 'FileTimeToLocalFileTime@kernel32.dll stdcall';

function GetDateFormat(Locale: Integer;dwFlags: LongInt;
   var lpDate: TSystemTime; lpFormat: PChar; lpDateStr: String;
   cchDate: Integer): Integer; external
   'GetDateFormat{#A}@kernel32.dll';

function GetTimeFormat(Locale: Integer;dwFlags: LongInt;
   var lpTime: TSystemTime;lpFormat: PChar;lpTimeStr: String;
   cchDate: Integer): Integer; external
   'GetTimeFormat{#A}@kernel32.dll';

function FormattedTime( t: TSystemTime ) : String;
var
	s, fmt: String;
begin

		fmt := StringOfChar(' ',64);
		GetDateFormat( GetUserDefaultLCID , DATE_LONGDATE, t, '' , fmt ,63);
		fmt := CastIntegerToString( CastStringToInteger(fmt) );

		s := fmt;

		fmt := StringOfChar(' ',64);
		GetTimeFormat( GetUserDefaultLCID , 0, t , '' , fmt ,63);
		fmt := CastIntegerToString( CastStringToInteger(fmt) );

		s := s + ' ' + fmt;

    Result := s;
end;


Function GetFileSysTime( nomef: String ; var stime: String; idx : Integer  ): TSystemTime;
Var
	fs: TFileStream;
	risul: TSystemTime;
	creat, access, write, local: TFileTime;
Begin
	fs := TFileStream.Create(nomef,fmOpenRead);
	GetFileTime(fs.handle,creat,access,write);
	fs.Free;
	if idx = 1 then FileTimeToLocalFileTime(creat,local);
	if idx = 2 then FileTimeToLocalFileTime(access,local);
	if idx = 3 then FileTimeToLocalFileTime(write,local);
	FileTimeToSystemTime(local,risul);
	stime := FormattedTime( risul );
	Result := risul;
End;

var
  lbFile: TLabel;
  lbDateCreated: TLabel;
  lbDateModified: TLabel;
  Label2: TLabel;
  butChoose: TButton;
  edFile: TEdit;
  edCreTime: TEdit;
  edModTime: TEdit;
  edAccessTime: TEdit;


procedure ChooseFile(Sender: TObject);
var
	filename, s : String;
	t  : TSystemTime;
begin

	if GetOpenFileName( 'Choose a file', filename,
		GetShellFolder( false, sfDocs ) , 'Text files (*.txt)|*.txt|All files (*.*)|*.*' , '*.txt') then
	begin

		edFile.text := filename;
		t := GetFileSysTime(filename, s, 1 );
		edCreTime.text := s;
		t := GetFileSysTime(filename, s, 2 );
    edAccessTime.text := s;
    t := GetFileSysTime(filename, s, 3 );
    edModTime.text := s;

	end;

end;


function FileTime_CreatePage(PreviousPageId: Integer): Integer;
var
  Page: TWizardPage;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    ExpandConstant('Time of a file'),
    ExpandConstant('Date and time of a file')
  );

  { lbFile }
  lbFile := TLabel.Create(Page);
  with lbFile do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 56;
    Width := 415; Height := 13;
    AutoSize := False;
    Caption := 'File selected:';
  end;

  { lbDateCreated }
  lbDateCreated := TLabel.Create(Page);
  with lbDateCreated do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 104;
    Width := 199;  Height := 13;
    AutoSize := False;
    Caption := 'Creation Time';
  end;

  { lbDateModified }
  lbDateModified := TLabel.Create(Page);
  with lbDateModified do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 152;
    Width := 199;  Height := 13;
    AutoSize := False;
    Caption := 'Modification Time';
  end;

  { Label2 }
  Label2 := TLabel.Create(Page);
  with Label2 do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 192;
    Width := 199;  Height := 13;
    AutoSize := False;
    Caption := 'Access Time';
  end;

  { butChoose }
  butChoose := TButton.Create(Page);
  with butChoose do
  begin
    Parent := Page.Surface;
    Left := 88;  Top := 16;
    Width := 233;  Height := 25;
    Caption := 'Choose a file...';
    TabOrder := 0;
    OnClick := @ChooseFile;
  end;

  { edFile }
  edFile := TEdit.Create(Page);
  with edFile do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 72;
    Width := 409;  Height := 21;
    TabStop := False;
    ReadOnly := True;
    TabOrder := 1;
  end;

  { edCreTime }
  edCreTime := TEdit.Create(Page);
  with edCreTime do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 120;
    Width := 201;  Height := 21;
    TabStop := False;
    ReadOnly := True;
    TabOrder := 2;
  end;

  { edModTime }
  edModTime := TEdit.Create(Page);
  with edModTime do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 168;
    Width := 201;  Height := 21;
    TabStop := False;
    ReadOnly := True;
    TabOrder := 3;
  end;

  { edAccessTime }
  edAccessTime := TEdit.Create(Page);
  with edAccessTime do
  begin
    Parent := Page.Surface;
    Left := 0;  Top := 208;
    Width := 201;  Height := 21;
    TabStop := False;
    ReadOnly := True;
    TabOrder := 4;
  end;

  Result := Page.ID;
end;

procedure InitializeWizard();
begin
	FileTime_CreatePage(wpWelcome);
end;

