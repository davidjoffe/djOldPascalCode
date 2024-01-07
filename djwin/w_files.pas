{$G+}
unit w_files;
{ David Joffe '94/12
{ Standard file object. (esp. for DJWIN}

interface

uses w_filePr;

type
  {File checking uses directory in FilePath as well as in current path}
  PFile=^TFile;
  TFile=object
    FileNameAssigned: boolean;
    FileOpen: boolean;

    NameOfFile: string[13];
    FilePath: string[128];
    FileHandle: integer;

    constructor init;

    procedure AssignFile(iFileName: string);

    function FileExist: boolean;

    {use FileName rather than read NameOfFile yourself, since this}
    {returns 'NoFile' if a file name has not been assigned}
    function FileName: string;
    function FullFileName: string;  {path+name}

    procedure ReadFileAt(FilePos: integer; var Buf);
    procedure ReadFileRel(FilePos: integer; var Buf);

    procedure ReadFile(var Buf; Bufsize: integer);

    procedure OpenFile;
    procedure CloseFile;
    procedure CreateFile;
    procedure WriteFile(var Buffer; Leng: word);

    procedure move_file_pointer(new_file_pointer: longint);

  end;

implementation

constructor TFile.init;
begin
  FileNameAssigned:=false;
  FileOpen:=false;
end;
procedure TFile.move_file_pointer(new_file_pointer: longint);
begin
  if not fileopen then EXIT;
  wMoveFilePointer(FileHandle,0,new_file_pointer);
end;
procedure TFile.AssignFile(iFileName: string);
begin
  if FileOpen then CloseFile;
  FileNameAssigned:=true;
  NameOfFile:=iFileName;

{  if not FileExist then begin
    FileNameAssigned:=false;
    NameOfFile:='';
  end;}
end;
procedure TFile.WriteFile(var Buffer; Leng: word);
begin
  if not FileOpen then exit;
  wWriteFile(FileHandle,@Buffer,Leng);
end;
procedure TFile.ReadFile(var Buf; BufSize: integer);
begin
  if not FileOpen then exit;
  wReadFile(FileHandle,@Buf,BufSize);
end;

procedure TFile.CreateFile;
begin
  if FileOpen then CloseFile;
  if not FileNameAssigned then exit;
  wCreateFile(NameOfFile);
end;

procedure TFile.OpenFile;
begin
  if not FileNameAssigned then exit;
  if FileOpen then CloseFile;
  if not FileExist then CreateFile;
  {CreateFile;}

  FileHandle:=wNextHandle;
  wOpenFile(NameOfFile,FileHandle);
  FileOpen:=true;

end;
procedure TFile.CloseFile;
begin
  if not FileOpen then exit;
  wCloseFile(FileHandle);
  FileOpen:=false;
end;

procedure TFile.ReadFileAt(FilePos: integer; var Buf);
  var Siz: word;
begin
  if not FileNameAssigned then exit;
  { if not FileOpened}
  Siz:=SizeOf(Buf);

end;
procedure TFile.ReadFileRel(FilePos: integer; var Buf);
  var Siz: word;
begin
  if not FileNameAssigned then exit;
  { if not FileOpened}
  Siz:=SizeOf(Buf);


end;


function TFile.FileExist: boolean;
  var TempBool: boolean;
begin
  TempBool:=false;
  if FileNameAssigned then begin
    TempBool:=(wFileExist(NameOfFile){ or wFileExist(FilePath+NameOfFile)});
  end;
  FileExist:=TempBool;
end;

function TFile.FileName: string;
  var TempStr: string;
begin
  TempStr:='NoFile';
  if FileNameAssigned then begin
    TempStr:=NameOfFile;
  end;
  FileName:=TempStr;
end;

function TFile.FullFileName: string;
  var TempStr: string;
begin
  TempStr:='NoFile';
  if FileNameAssigned then begin
    TempStr:=FilePath+NameOfFile;
  end;
  FullFileName:=TempStr;
end;




end.