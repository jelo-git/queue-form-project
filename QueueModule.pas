unit QueueModule;

interface
  type Queue = class
    procedure Add(data:string);
    function Remove():boolean;
    function GetCurrentElement():string;
    function SetNextElement():boolean;
    function SetFirstElement():boolean;
    function GetSavedState():boolean;
    procedure SetSaveState(state:boolean);
    function GetHasElements():boolean;
  end;

implementation
//TYPES
type
  queuePointer = ^elementOfQueue;
  elementOfQueue = record
    data: string;
    nextData: queuePointer;
  end;
//VARIABLES
var
  aQueue,zQueue,viewQueue:queuePointer;
  textHolder:string;
  isSaved:boolean=true;
  isFirst:boolean=true;
//OBJECTS

//private
procedure addToQueue(dataInput: string; var endOfQueue: queuePointer;var beginningOfQueue: queuePointer; var viewOfQueue: queuePointer);
var point:queuePointer;
begin
  point:=endOfQueue;
  New(endOfQueue);
  with endOfQueue^ do
  begin
    data:=dataInput;
    nextData:=nil;
  end;
  if point<>nil then
    begin
      point^.nextData:=endOfQueue;
    end
  else
    isFirst:=false;
  if isSaved then
    isSaved:=false;
  if aQueue=nil then
        begin
          aQueue:=zQueue;
          viewQueue:=aQueue;
        end;
end;
procedure removeFromQueue(var firstQueuePointVariable:queuePointer);
var point:queuePointer;
begin
if firstQueuePointVariable<>nil then
  begin
    with firstQueuePointVariable^ do
      begin
        point:=nextData;
      end;
    Dispose(firstQueuePointVariable);
    firstQueuePointVariable:=point;
    if isSaved then
      isSaved:=false
  end
else
  isFirst:=true;
end;
//public
procedure Queue.Add(data:string);
begin
  //add data public
  addToQueue(data,zQueue,aQueue,viewQueue);
end;
function Queue.Remove():boolean;
begin
  //remove data public
  Result:=true;
  if aQueue=nil then
    begin
      zQueue:=nil;
      Result:=false
    end
  else
      removeFromQueue(aQueue);
end;
function Queue.GetCurrentElement():string;
begin
  //get current view public
  if isFirst then
    viewQueue:=aQueue;
  Result:='';
  if viewQueue<>nil then
    with viewQueue^ do
      Result:=data
end;
function Queue.SetNextElement():boolean;
var point:queuePointer;
begin
  //switch to next element public
  Result:=false;
  if viewQueue<>nil then
    begin
      with viewQueue^ do
        begin
          point:=nextData;
        end;
      viewQueue:=point;
      Result:=true;
    end;
end;
function Queue.SetFirstElement():boolean;
begin
  Result:=false;
  viewQueue:=aQueue;
  if viewQueue<>nil then
    Result:=true;
end;
function Queue.GetSavedState():boolean;
begin
  Result:=isSaved;
end;
procedure Queue.SetSaveState(state:boolean);
begin
  isSaved:=state;
end;
function Queue.GetHasElements():boolean;
begin
  Result:=false;
  if aQueue<>nil then
    Result:=true
end;
end.
