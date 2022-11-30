unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Unit4, Vcl.ExtDlgs, System.Hash, QueueModule;
type
  TForm3 = class(TForm)
    OutputLabel: TLabel;
    NextElement: TButton;
    Label1: TLabel;
    AddElement: TButton;
    FirstElement: TButton;
    DeleteElement: TButton;
    LoadElements: TButton;
    SaveElements: TButton;
    SaveTextFileDialog1: TSaveTextFileDialog;
    OpenTextFileDialog1: TOpenTextFileDialog;
    procedure AddElementClick(Sender: TObject);
    procedure DeleteElementClick(Sender: TObject);
    procedure FirstElementClick(Sender: TObject);
    procedure NextElementClick(Sender: TObject);
    procedure SaveElementsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LoadElementsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}
var secureFilePassword:string;
  myQueue:QueueModule.Queue;

procedure TForm3.NextElementClick(Sender: TObject);
begin
//go throu queue
OutputLabel.Caption:=myQueue.GetCurrentElement;
NextElement.Enabled:=myQueue.SetNextElement;
end;

procedure TForm3.AddElementClick(Sender: TObject);
begin
//show input window
var form := Unit4.TForm5.Create(Form3);
if IsPositiveResult(form.ShowModal) then
  begin
    if form.Edit1.Text<>'' then
      begin
        myQueue.Add(form.Edit1.Text);
        if NextElement.Enabled=false then
          begin
            NextElement.Enabled:=true;
            OutputLabel.Caption:=form.Edit1.Text;
          end;
      end;
  end;
end;

procedure TForm3.FirstElementClick(Sender: TObject);
begin
//reset view
NextElement.Enabled:=myQueue.SetFirstElement;
OutputLabel.Caption:=myQueue.GetCurrentElement;
end;

procedure TForm3.DeleteElementClick(Sender: TObject);
begin
//delete
if myQueue.Remove then
  begin
    NextElement.Enabled:=myQueue.SetFirstElement;
    OutputLabel.Caption:=myQueue.GetCurrentElement;
  end;
end;
function validateSavedPass():boolean;
begin
Result:=true;
if myQueue.GetSavedState=false then
  if MessageDlg('Niezapisano kolejki! Czy aby napewno chcesz wczytaæ now¹ kolejkê?',TMsgDlgType.mtConfirmation,[TMsgDlgBtn.mbOK,TMsgDlgBtn.mbCancel],0)=mrCancel then
    Result:=false
end;
procedure TForm3.LoadElementsClick(Sender: TObject);
//open queue from file
begin

if validateSavedPass() then
begin
if OpenTextFileDialog1.Execute then
  begin
    var strList : TStringList;
    var hashString:string;
    strList:=TStringList.Create;
      try
        strList.LoadFromFile(OpenTextFileDialog1.FileName, TEncoding.UTF8);
        hashString:=strlist[strlist.Count-1];
        strlist.Delete(strlist.Count-1);
        if THashSHA2.GetHMAC(strList.DelimitedText,secureFilePassword) = hashString then
          begin
          while myQueue.Remove do begin end;
          while strList.Count<>0 do
            begin
              myQueue.Add(strList[0]);
              strlist.Delete(0)
            end;
          OutputLabel.Caption:=myQueue.GetCurrentElement;
          NextElement.Enabled:=true;
          myQueue.SetSaveState(true);
          end
        else
          ShowMessage('plik jest niebezpieczny');
      except
      on E:Exception do
        ShowMessage(E.Message)
      end;
    strList.Free;
  end;
end;
end;

procedure TForm3.SaveElementsClick(Sender: TObject);
//saving queue to file
begin
if myQueue.GetSavedState then
  ShowMessage('Nie mo¿na zapisaæ nieedytowanej kolejki')
else
  begin
    if myQueue.GetHasElements then
  begin
    if SaveTextFileDialog1.Execute then
      begin
        var strList : TStringList;
        strList:=TStringList.Create();
        myQueue.SetFirstElement;
        repeat
          strList.Add(myQueue.GetCurrentElement)
        until myQueue.SetNextElement=false;
        //i hate this
        strList.Delete(strList.Count-1);
        strList.Add(THashSHA2.GetHMAC(strList.DelimitedText,secureFilePassword));
        strList.SaveToFile(SaveTextFileDialog1.FileName,TEncoding.UTF8);
        myQueue.SetSaveState(true);
        strList.Free;
      end
    else
      ShowMessage('Plik niezosta³ utworzony');
  end
else
  ShowMessage('Nie mo¿na zapisaæ pustej kolejki');
end;
  end;


procedure TForm3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

if myQueue.GetSavedState=false then
  if MessageDlg('Niezapisano kolejki! Czy aby napewno chcesz zamkn¹æ?',TMsgDlgType.mtConfirmation,[TMsgDlgBtn.mbOK,TMsgDlgBtn.mbCancel],0)=mrCancel then
    CanClose:=false
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  secureFilePassword:='calkowiciebezpiecznysposobzabezpieczeniadanych';
end;

end.
