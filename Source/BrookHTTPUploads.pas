unit BrookHTTPUploads;

{$I Brook.inc}

interface

uses
  SysUtils,
  Marshalling,
  libbrook,
  BrookUtils,
  BrookHandledClasses;

type
  TBrookHTTPUploads = class;

  TBrookHTTPUpload = record
  private
    FHandle: Pbk_httpupld;
    FStreamHandle: Pointer;
    FDirectory: string;
    FField: string;
    FName: string;
    FMime: string;
    FEncoding: string;
    FSize: UInt64;
    function GetHandle: Pointer;
  public
    constructor Create(AHandle: Pointer);
    function TrySave(AOverwritten: Boolean; out AError: string): Boolean; overload;
    function TrySave(out AError: string): Boolean; overload;
    procedure Save(AOverwritten: Boolean); overload;
    procedure Save; overload;
    function TrySaveAs(const APath: TFileName; AOverwritten: Boolean;
      out AError: string): Boolean; overload;
    function TrySaveAs(const APath: TFileName;
      out AError: string): Boolean; overload;
    procedure SaveAs(const APath: TFileName; AOverwritten: Boolean); overload;
    procedure SaveAs(const APath: TFileName); overload;
    property Handle: Pointer read GetHandle;
    property StreamHandle: Pointer read FStreamHandle;
    property Directory: string read FDirectory;
    property Field: string read FField;
    property Name: string read FName;
    property Mime: string read FMime;
    property Encoding: string read FEncoding;
    property Size: UInt64 read FSize;
  end;

  TBrookHTTPUploadsEnumerator = class
  private
    FUploads: TBrookHTTPUploads;
    FCurr: TBrookHTTPUpload;
    FBOF: Boolean;
  public
    constructor Create(AUploads: TBrookHTTPUploads);
    function GetCurrent: TBrookHTTPUpload;
    function MoveNext: Boolean;
    property Current: TBrookHTTPUpload read GetCurrent;
  end;

  TBrookHTTPUploads = class(TBrookHandledPersistent)
  private
    FHandle: Pbk_httpupld;
    FCurr: Pbk_httpupld;
    function GetCount: Integer;
    function GetCurr: Pointer;
  protected
    property Curr: Pointer read GetCurr;
  public
    constructor Create(AHandle: Pointer); virtual;
    function GetHandle: Pointer; override;
    function GetEnumerator: TBrookHTTPUploadsEnumerator;
    { TODO: Iterate::bk_httpuplds_iter() }
    procedure First(out AUpload: TBrookHTTPUpload); virtual;
    procedure Next(out AUpload: TBrookHTTPUpload); virtual;
    function IsEOF: Boolean; virtual;
    property EOF: Boolean read IsEOF;
    property Count: Integer read GetCount;
  end;

implementation

{ TBrookHTTPUploadsEnumerator }

constructor TBrookHTTPUploadsEnumerator.Create(AUploads: TBrookHTTPUploads);
begin
  inherited Create;
  FUploads := AUploads;
  FUploads.First(FCurr);
  FBOF := True;
end;

function TBrookHTTPUploadsEnumerator.GetCurrent: TBrookHTTPUpload;
begin
  Result := FCurr;
end;

function TBrookHTTPUploadsEnumerator.MoveNext: Boolean;
begin
  if FBOF then
    FBOF := False
  else
    FUploads.Next(FCurr);
  Result := not FUploads.EOF;
end;

{ TBrookHTTPUpload }

constructor TBrookHTTPUpload.Create(AHandle: Pointer);
begin
  FHandle := AHandle;
  FStreamHandle := bk_httpupld_handle(FHandle);
  FDirectory := TMarshal.ToString(bk_httpupld_dir(FHandle));
  FField := TMarshal.ToString(bk_httpupld_field(FHandle));
  FName := TMarshal.ToString(bk_httpupld_name(FHandle));
  FMime := TMarshal.ToString(bk_httpupld_mime(FHandle));
  FEncoding := TMarshal.ToString(bk_httpupld_encoding(FHandle));
  FSize := bk_httpupld_size(FHandle);
end;

function TBrookHTTPUpload.TrySave(AOverwritten: Boolean;
  out AError: string): Boolean;
var
  R: cint;
begin
  BkCheckLibrary;
  R := bk_httpupld_save(FHandle, AOverwritten);
  Result := R = 0;
  if not Result then
    AError := BrookStrError(-R);
end;

function TBrookHTTPUpload.TrySave(out AError: string): Boolean;
begin
  Result := TrySave(True, AError);
end;

procedure TBrookHTTPUpload.Save(AOverwritten: Boolean);
begin
  BkCheckLibrary;
  BkCheckLastError(-bk_httpupld_save(FHandle, AOverwritten));
end;

procedure TBrookHTTPUpload.Save;
begin
  Save(True);
end;

function TBrookHTTPUpload.TrySaveAs(const APath: TFileName;
  AOverwritten: Boolean; out AError: string): Boolean;
var
  R: cint;
  M: TMarshaller;
begin
  BkCheckLibrary;
  R := bk_httpupld_save_as(FHandle, M.ToCString(APath), AOverwritten);
  Result := R = 0;
  if not Result then
    AError := BrookStrError(-R);
end;

function TBrookHTTPUpload.TrySaveAs(const APath: TFileName;
  out AError: string): Boolean;
begin
  Result := TrySaveAs(APath, True, AError);
end;

procedure TBrookHTTPUpload.SaveAs(const APath: TFileName; AOverwritten: Boolean);
var
  M: TMarshaller;
begin
  BkCheckLibrary;
  BkCheckLastError(-bk_httpupld_save_as(FHandle, M.ToCString(APath),
    AOverwritten));
end;

procedure TBrookHTTPUpload.SaveAs(const APath: TFileName);
begin
  SaveAs(APath, True);
end;

function TBrookHTTPUpload.GetHandle: Pointer;
begin
  Result := FHandle;
end;

{ TBrookHTTPUploads }

constructor TBrookHTTPUploads.Create(AHandle: Pointer);
begin
  inherited Create;
  FHandle := AHandle;
end;

function TBrookHTTPUploads.GetHandle: Pointer;
begin
  Result := FHandle;
end;

function TBrookHTTPUploads.GetEnumerator: TBrookHTTPUploadsEnumerator;
begin
  Result := TBrookHTTPUploadsEnumerator.Create(Self);
end;

procedure TBrookHTTPUploads.First(out AUpload: TBrookHTTPUpload);
begin
  BkCheckLibrary;
  FCurr := FHandle;
  AUpload := TBrookHTTPUpload.Create(FCurr);
end;

procedure TBrookHTTPUploads.Next(out AUpload: TBrookHTTPUpload);
begin
  BkCheckLibrary;
  BkCheckLastError(-bk_httpuplds_next(@FCurr));
  AUpload := TBrookHTTPUpload.Create(FCurr);
end;

function TBrookHTTPUploads.IsEOF: Boolean;
begin
  Result := not Assigned(FCurr);
end;

function TBrookHTTPUploads.GetCount: Integer;
begin
  BkCheckLibrary;
  Result := bk_httpuplds_count(FHandle);
end;

function TBrookHTTPUploads.GetCurr: Pointer;
begin
  Result := FCurr;
end;

end.