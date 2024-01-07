{$G+}
unit w_filePR;
{========================================================}
{  David Joffe '94/12                                    }
{  Contains some simple file-handling routines for DJWIN }
{========================================================}
interface

var
  FileHandleArray:    array[0..255] of word;
  FileReturnCode:     word;
  FileErrorCode:      word;
  LoopVar           : integer;

{----------------------------------------------------------------------
  FileReturnCode:
  Meanings of FileReturnCode:

  000 : Operation successful
  001 : Actual file error - 'FileErrorCode' contains DOS return code
  002 : File number out of range
  003 : On OpenFile : File number already in use
  004 : File number not in use
  005 : MoveFilePointer - Invalid movement code
----------------------------------------------------------------------}

{ NextHandle returns the first number for a file that is not in use }
function  wNextHandle: word;

function  wFileExist(FileName: string): boolean;

{ If file exists it is opened and truncated to size zero. }
procedure wCreateFile(FileName: string);

procedure wOpenFile(FileName: string;
                   FileNumber: integer);

procedure wCloseFile(FileNumber: integer);

procedure wReadFile(FileNumber: integer;
                   BufferAddress: pointer;
                   Length: word);

procedure wReadFileAt(FileNumber: integer;
                     BufferAddress: pointer;
                     Position: longint;
                     Length: word);

procedure wWriteFile(FileNumber: integer;
                    BufferAddress: pointer;
                    Length: word);

procedure wMoveFilePointer(FileNumber, MoveCode: integer; Distance: longint);
  { movement code: 0 = Move relative to beginning of file
                   1 = Move relative to current pointer location
                   2 = Move relative to end of file
  !NOTE! : change to function to return new location
   or make function GetFilePointer.
  }
{procedure CloseAllFiles...}
{procedure CreateFile...}

{function FileExist(FileName: string);}
  { Returns TRUE if file exists }

{=================================================================}

implementation

function  wNextHandle: word;
begin
  for LoopVar:=0 to 255 do
    if FileHandleArray[LoopVar]=0 then begin
      wNextHandle:=LoopVar;
      Exit;
    end;
end;

function wFileExist(FileName: string): boolean;
var
  FOfs,FSeg : word;
  TempFlag  : boolean;
begin
  FileName:=FileName+#0;
  FSeg:=seg(FileName); FOfs:=ofs(FileName);
  asm
    mov TempFlag,0
    push ds
    mov dx,FOfs
    inc dx
    mov ax,FSeg
    mov ds,ax

    xor cx,cx
    mov ah,4Eh
    int 21h
    pop ds
    adc TempFlag,0
    not TempFlag
    and TempFlag,1
{    jc @FileNotFound
    mov TempFlag,1
    jmp @PastFileNotFound
  @FileNotFound:
    mov TempFlag,0
  @PastFileNotFound:}
  end;
  wFileExist:=TempFlag;
{  asm
    mov ah,2Fh
    push ds

    push es
    pop ds
    mov si,bx
    mov ax,0B800h
    mov es,ax
    xor di,di

    mov ah,4Eh
    mov cx,43
  @WriteDTAloop:
    lodsb
    stosw
    loop @WriteDTAloop

    pop ds

  end;}
end;

procedure wCreateFile(FileName: string);
var
  FileNameOfs, FileNameSeg: word;
begin
  FileName:=FileName+#0;
  FileNameSeg:=seg(FileName); FileNameOfs:=ofs(FileName);
  FileReturnCode:=0; FileErrorCode:=0;
  asm
    push ds
    mov dx,FileNameOfs
    inc dx
    mov ax,FileNameseg
    mov ds,ax
    mov ah,3Ch
    xor cx,cx
    int $21
    jc @FileError

    mov bx,ax {close file}
    mov ah,3Eh
    int 21h

    pop ds
    jmp @PastFileError
  @FileError:
    pop ds
    mov FileReturnCode,1
    mov FileErrorCode,ax
  @PastFileError:
  end;
end;

procedure wOpenFile(FileName: string;
                   FileNumber: integer);
var
  FileNameOfs, FileNameSeg: word;
begin
{ ensure ASCIIZ filename }
  FileName:=FileName+#0;
  FileNameSeg:=seg(FileName); FileNameOfs:=ofs(FileName);
  FileReturnCode:=0; FileErrorCode:=0;
  if (FileNumber<0) or (FileNumber>255) then begin
    FileReturnCode:=2; exit;
  end;
  if (FileHandleArray[FileNumber]<>0) then begin
    FileReturnCode:=3; exit;
  end;
  asm
    push ds
    mov dx,FileNameOfs
    inc dx
    mov ax,FileNameseg
    mov ds,ax
    mov ax,$3D02
    int $21
    jc @FileError
    pop ds
    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    mov [bx],ax
    jmp @PastFileError
  @FileError:
    pop ds
    mov FileReturnCode,1
    mov FileErrorCode,ax
  @PastFileError:
  end;
end;

procedure wCloseFile(FileNumber: integer);
begin
  FileReturnCode:=0; FileErrorCode:=0;
  if (FileNumber<0) or (FileNumber>255) then begin
    FileReturnCode:=2; exit;
  end;
  if (FileHandleArray[FileNumber]=0) then begin
    FileReturnCode:=4; exit;
  end;
  asm
    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    mov ax,[bx]
    mov bx,ax
    mov ah,$3E
    int $21
    jc @FileError
    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    xor cx,cx
    mov [bx],cx
    jmp @PastFileError
  @FileError:
    mov FileReturnCode,1
    mov FileErrorCode,ax
  @PastFileError:
  end;
end;

procedure wReadFile(FileNumber: integer;
                   BufferAddress: pointer;
                   Length: word);
begin
  FileReturnCode:=0; FileErrorCode:=0;
  if (FileNumber<0) or (FileNumber>255) then begin
    FileReturnCode:=2; exit;
  end;
  if (FileHandleArray[FileNumber]=0) then begin
    FileReturnCode:=4; exit;
  end;
  asm
    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    mov bx,[bx]
   { mov bx,ax }

    mov cx,Length
    push ds
    cld
    lds dx,BufferAddress

    mov ah,$3F

    int $21
    jc @FileError
    pop ds
    jmp @PastFileError
  @FileError:
    pop ds
    mov FileReturnCode,1
    mov FileErrorCode,ax
  @PastFileError:
  end;
end;

procedure wReadFileAt(FileNumber: integer; BufferAddress: pointer; Position: longint; Length: word);
begin
  FileReturnCode:=0; FileErrorCode:=0;
  if (FileNumber<0) or (FileNumber>255) then begin
    FileReturnCode:=2; exit;
  end;
  if (FileHandleArray[FileNumber]=0) then begin
    FileReturnCode:=4; exit;
  end;

  asm
    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    mov ax,[bx]
    mov bx,ax



    xor al,al
    mov ah,$42
    mov cx,word ptr Position+2
    mov dx,word ptr Position

    int $21
    jc @FileError

{    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    mov ax,[bx]
    mov bx,ax}

    mov cx,Length
    push ds
    cld
    lds dx,BufferAddress

    mov ah,$3F

    int $21
    jc @FileError
    pop ds
    jmp @PastFileError
  @FileError:
    pop ds
    mov FileReturnCode,1
    mov FileErrorCode,ax
  @PastFileError:
  end;



end;


procedure wWriteFile(FileNumber: integer; BufferAddress: pointer; Length: word);
begin
  FileReturnCode:=0; FileErrorCode:=0;
  if (FileNumber<0) or (FileNumber>255) then begin
    FileReturnCode:=2; exit;
  end;
  if (FileHandleArray[FileNumber]=0) then begin
    FileReturnCode:=4; exit;
  end;
  asm
    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    mov ax,[bx]
    mov bx,ax

    mov cx,Length
    push ds
    cld
    lds dx,BufferAddress

    mov ah,$40

    int $21
    jc @FileError
    pop ds
    jmp @PastFileError
  @FileError:
    pop ds
    mov FileReturnCode,1
    mov FileErrorCode,ax
  @PastFileError:
  end;
end;

procedure wMoveFilePointer(FileNumber, MoveCode: integer; Distance: longint);
begin
  FileReturnCode:=0; FileErrorCode:=0;
  if (FileNumber<0) or (FileNumber>255) then begin
    FileReturnCode:=2; exit;
  end;
  if (FileHandleArray[FileNumber]=0) then begin
    FileReturnCode:=4; exit;
  end;
  if (MoveCode<0) or (MoveCode>2) then begin
    FileReturnCode:=5; exit;
  end;
  asm
    mov bx,offset FileHandleArray
    add bx,FileNumber
    add bx,FileNumber
    mov ax,[bx]
    mov bx,ax

    mov ax,MoveCode
    mov ah,$42
    mov cx,word ptr Distance+2
    mov dx,word ptr Distance

    int $21
    jc @FileError
    jmp @PastFileError
  @FileError:
    mov FileReturnCode,1
    mov FileErrorCode,ax
  @PastFileError:
  end;
end;


begin
  for LoopVar:=0 to 255 do FileHandleArray[LoopVar]:=0;

end.