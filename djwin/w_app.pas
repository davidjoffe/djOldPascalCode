{ David Joffe '94/12 }
{ Standard App definition }
unit w_app;
{$G+}

interface

uses crt,uo_obj,w_item,w_items,w_win;

type

  PApp=^TApp; {A TApp is a normal window }
  TApp=object(TWindow) {abstract}

    next: PApp;
    NumWin: integer;

    Owner: integer;
       {true number of owner app in list of open windows (for }
       { AppWin) number displayed is arbitrary (is num1)}

    {windowlist?}
    constructor Init;
    procedure InitWindow; virtual;

    {override: sometimes (if using windows)}
    procedure HandleAppWin(WinNum,WinCmd: integer); virtual;

    procedure Show;
    destructor done; virtual;
  end;
  PAppWin=^TAppWin;
  TAppWin=object(TApp) { A TAppWin is a child window of a TApp }
    constructor Init(x1,y1,x2,y2: integer);
  end;

implementation
{--------------------------------------------------------------------}
uses graph;

constructor TAppWin.Init(x1,y1,x2,y2: integer);
begin
  NumWin:=0; {in future create proper nesting levels}
  WinType:=WinTypeAppWin;
  r.SetXYXY(x1,y1,x2,y2);
  InitWindow;
end;
constructor TApp.Init;
begin
  NumWin:=0;
  WinType:=WinTypeApp;
  InitWindow;
end;
procedure TApp.InitWindow;
begin
{  RunError(211);}
  items := nil;
  Title := 'No title';
  r.setXYXY(30,30,getmaxx-30,getmaxy-30);
{ An App must override this method and insert here
    size init, title init, itemlist etc.         }
end;
procedure TApp.Show;
begin
  RunError(211); {Call to abstract method}
end;
procedure TApp.HandleAppWin(WinNum,WinCmd: integer);
begin
end;
destructor TApp.done;
begin
end;
{--------------------------------------------------------------------}
end.