unit Unit1;

{$MODE Delphi}

interface

{$I CnPack.inc}

uses
  LCLIntf, LCLType, LMessages, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Clipbrd;

type
  TFormCrypt = class(TForm)
    PageControl1: TPageControl;
    tsDES: TTabSheet;
    tsMD5: TTabSheet;
    grpdES: TGroupBox;
    lbl1: TLabel;
    lblKey: TLabel;
    lblCode: TLabel;
    lblOrigin: TLabel;
    edtDesFrom: TEdit;
    edtDESKey: TEdit;
    btnDesCrypt: TButton;
    edtDESCode: TEdit;
    btnDesDecrypt: TButton;
    edtDesOrigin: TEdit;
    grpMd5: TGroupBox;
    lblfROM: TLabel;
    edtMD5: TEdit;
    btnMd5: TButton;
    pnlMd5: TPanel;
    tsBase64: TTabSheet;
    GroupBox1: TGroupBox;
    lbl2: TLabel;
    edtBase64from: TEdit;
    Button1: TButton;
    edtBase64Result: TEdit;
    lbl3: TLabel;
    btnBase64Decode: TButton;
    edtBase64Decode: TEdit;
    lbl4: TLabel;
    tsCRC32: TTabSheet;
    grpCRC32: TGroupBox;
    lblCRC: TLabel;
    edtCRC32: TEdit;
    btnCRC32: TButton;
    pnlCRC32: TPanel;
    btnMd5File: TButton;
    OpenDialog1: TOpenDialog;
    btnFileCRC32: TButton;
    tsCRC64: TTabSheet;
    grp1: TGroupBox;
    lbl5: TLabel;
    edtCRC64: TEdit;
    btnCRC64: TButton;
    pnlCRC64: TPanel;
    btnFileCRC64: TButton;
    tsSha1: TTabSheet;
    grpSha1: TGroupBox;
    lblSha1: TLabel;
    edtSha1: TEdit;
    btnSha1: TButton;
    pnlSha1: TPanel;
    btnFileSha1: TButton;
    tsSM3: TTabSheet;
    grpSM3: TGroupBox;
    lblSM3: TLabel;
    edtSM3: TEdit;
    btnSM3: TButton;
    btnFileSM3: TButton;
    lblSm3Result: TLabel;
    tsSM4: TTabSheet;
    grpSM4: TGroupBox;
    lblSm4: TLabel;
    edtSm4: TEdit;
    btnSm4: TButton;
    edtSm4Key: TEdit;
    lblSm4Key: TLabel;
    edtSm4Dec: TEdit;
    btnSm4Dec: TButton;
    lblSm4Dec: TLabel;
    edtSm4Code: TEdit;
    lblSm4Code: TLabel;
    rbSm4Ecb: TRadioButton;
    rbSm4Cbc: TRadioButton;
    tsAES: TTabSheet;
    grpAes: TGroupBox;
    lblAesFrom: TLabel;
    lblAesKey: TLabel;
    lblAesOrigin: TLabel;
    lblAesCode: TLabel;
    edtAes: TEdit;
    btnAesEncrypt: TButton;
    edtAesKey: TEdit;
    edtAesDecrypt: TEdit;
    btnAesDecrypt: TButton;
    edtAesResult: TEdit;
    rbAesecb: TRadioButton;
    rbAescbc: TRadioButton;
    cbbAesKeyBitType: TComboBox;
    lblKeyBit: TLabel;
    tsSHA256: TTabSheet;
    grpSHA256: TGroupBox;
    lblSHA256: TLabel;
    edtSHA256: TEdit;
    btnSHA256: TButton;
    pnlSHA256: TPanel;
    btnFileSHA256: TButton;
    tsSHA224: TTabSheet;
    grpSHA224: TGroupBox;
    lblSHA224: TLabel;
    edtSHA224: TEdit;
    btnSHA224: TButton;
    pnlSHA224: TPanel;
    btnSHA224File: TButton;
    tsSHA512: TTabSheet;
    grpSHA512: TGroupBox;
    lblSHA512: TLabel;
    edtSHA512: TEdit;
    btnSHA512: TButton;
    btnSHA512File: TButton;
    lblSHA512Result: TLabel;
    tsSHA384: TTabSheet;
    grpSHA384: TGroupBox;
    lblSHA384: TLabel;
    lblSHA384Result: TLabel;
    edtSHA384: TEdit;
    btnSHA384: TButton;
    btnSHA384File: TButton;
    tsSHA3_224: TTabSheet;
    grpSHA3_224: TGroupBox;
    lblSHA3_224: TLabel;
    edtSHA3_224: TEdit;
    btnSHA3_224: TButton;
    pnlSHA3_224: TPanel;
    btnSHA3_224File: TButton;
    tsSHA3_256: TTabSheet;
    grpSHA3_256: TGroupBox;
    lblSHA3_256: TLabel;
    edtSHA3_256: TEdit;
    btnSHA3_256: TButton;
    pnlSHA3_256: TPanel;
    btnFileSHA3_256: TButton;
    tsSHA3_384: TTabSheet;
    grpSHA3_384: TGroupBox;
    lblSHA3_384: TLabel;
    lblSHA3_384Result: TLabel;
    edtSHA3_384: TEdit;
    btnSHA3_384: TButton;
    btnSHA3_384File: TButton;
    tsSHA3_512: TTabSheet;
    grpSHA3_512: TGroupBox;
    lblSHA3_512: TLabel;
    edtSHA3_512: TEdit;
    btnSHA3_512: TButton;
    btnSHA3_512File: TButton;
    lblSHA3_512Result: TLabel;
    tsZUC: TTabSheet;
    grpZuc: TGroupBox;
    lblZuc1: TLabel;
    btnZUC1: TButton;
    btnZUCEIA31: TButton;
    btnZUC2: TButton;
    btnZUC3: TButton;
    btnZUC4: TButton;
    btnZUCEIA32: TButton;
    btnZUCEEA31: TButton;
    lblSHA224HmacKey: TLabel;
    edtSHA224HmacKey: TEdit;
    btnSHA224Hmac: TButton;
    lblSHA256HmacKey: TLabel;
    edtSHA256HmacKey: TEdit;
    btnSHA256Hmac: TButton;
    lblSHA384HmacKey: TLabel;
    edtSHA384HmacKey: TEdit;
    btnSHA384Hmac: TButton;
    lblSHA512HmacKey: TLabel;
    edtSHA512HmacKey: TEdit;
    btnSHA512Hmac: TButton;
    lblSHA3_224HmacKey: TLabel;
    edtSHA3_224HmacKey: TEdit;
    btnSHA3_224Hmac: TButton;
    lblSHA3_256HmacKey: TLabel;
    edtSHA3_256HmacKey: TEdit;
    btnSHA3_256Hmac: TButton;
    lblSHA3_384HmacKey: TLabel;
    edtSHA3_384HmacKey: TEdit;
    btnSHA3_384Hmac: TButton;
    lblSHA3_512HmacKey: TLabel;
    edtSHA3_512HmacKey: TEdit;
    btnSHA3_512Hmac: TButton;
    edtSHA1HMacKey: TEdit;
    btnSHA1Hmac: TButton;
    lblSHA1HmacKey: TLabel;
    lblMD5HmacKey: TLabel;
    edtMD5HmacKey: TEdit;
    btnMD5Hmac: TButton;
    lblSM3HmacKey: TLabel;
    edtSM3HMacKey: TEdit;
    btnSM3Hmac: TButton;
    lblCRC32HmacKey: TLabel;
    edtCRC32HmacKey: TEdit;
    btnCRC32Hmac: TButton;
    btnCRC64Hmac: TButton;
    edtCRC64HmacKey: TEdit;
    lblCRC64HmacKey: TLabel;
    btnUMd5: TButton;
    btnUSHA1: TButton;
    btnUSM3: TButton;
    btnUSHA224: TButton;
    btnUSHA256: TButton;
    btnUSHA384: TButton;
    btnUSHA512: TButton;
    btnUSHA3_224: TButton;
    btnUSHA3_256: TButton;
    btnUSHA3_384: TButton;
    btnUSHA3_512: TButton;
    btnBase64File: TButton;
    btnDeBase64File: TButton;
    dlgSave: TSaveDialog;
    tsTEA: TTabSheet;
    grpTea: TGroupBox;
    edtTeaKey1: TEdit;
    edtTeaKey2: TEdit;
    edtTeaKey3: TEdit;
    edtTeaKey4: TEdit;
    lblTeaKey1: TLabel;
    lblTeaKey2: TLabel;
    lblTeaKey3: TLabel;
    lblTeaKey4: TLabel;
    edtTeaData1: TEdit;
    edtTeaData2: TEdit;
    lblTeaData: TLabel;
    btnTeaEnc: TButton;
    edtTeaEnc1: TEdit;
    edtTeaEnc2: TEdit;
    btnTeaDec: TButton;
    btnXTeaEnc: TButton;
    edtXTeaEnc1: TEdit;
    edtXTeaEnc2: TEdit;
    btnXTeaDec: TButton;
    btnXXTeaEnc: TButton;
    edtXXTeaEnc1: TEdit;
    edtXXTeaEnc2: TEdit;
    btnXXTeaDec: TButton;
    bvl1: TBevel;
    lblAesIv: TLabel;
    edtAesIv: TEdit;
    lblSM4Iv: TLabel;
    edtSM4Iv: TEdit;
    lblDESIv: TLabel;
    edtDESIv: TEdit;
    rbDESCbc: TRadioButton;
    rbDESEcb: TRadioButton;
    ts3DES: TTabSheet;
    grp3Des: TGroupBox;
    lbl3DesFrom: TLabel;
    lbl3DesKey: TLabel;
    lbl3DesCode: TLabel;
    lbl3DesOrigin: TLabel;
    lbl3DesIv: TLabel;
    edt3DesFrom: TEdit;
    edt3DesKey: TEdit;
    btn3DesCrypt: TButton;
    edt3DesCode: TEdit;
    btn3DesDecrypt: TButton;
    edt3DesOrigin: TEdit;
    edt3DesIv: TEdit;
    rb3DesCBC: TRadioButton;
    rb3DesECB: TRadioButton;
    chkSM4UseTBytes: TCheckBox;
    chkDESUseTBytes: TCheckBox;
    chk3DESUseTBytes: TCheckBox;
    chkBase64UseTBytes: TCheckBox;
    chkAESUseTBytes: TCheckBox;
    btnCRC16: TButton;
    btnFileCRC16: TButton;
    btnCRC8: TButton;
    btnFileCRC8: TButton;
    lblSm4Padding: TLabel;
    cbbSm4Padding: TComboBox;
    cbbDesPadding: TComboBox;
    lblDesPadding: TLabel;
    cbb3DesPadding: TComboBox;
    lbl3DesPadding: TLabel;
    cbbAesPadding: TComboBox;
    lblAesPadding: TLabel;
    rbAescfb: TRadioButton;
    rbAesofb: TRadioButton;
    rbSm4Cfb: TRadioButton;
    rbSm4Ofb: TRadioButton;
    procedure btnMd5Click(Sender: TObject);
    procedure btnDesCryptClick(Sender: TObject);
    procedure btnDesDecryptClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnBase64DecodeClick(Sender: TObject);
    procedure btnCRC32Click(Sender: TObject);
    procedure btnMd5FileClick(Sender: TObject);
    procedure btnFileCRC32Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCRC64Click(Sender: TObject);
    procedure btnFileCRC64Click(Sender: TObject);
    procedure btnSha1Click(Sender: TObject);
    procedure btnFileSha1Click(Sender: TObject);
    procedure btnSM3Click(Sender: TObject);
    procedure btnFileSM3Click(Sender: TObject);
    procedure btnSm4Click(Sender: TObject);
    procedure btnSm4DecClick(Sender: TObject);
    procedure btnAesEncryptClick(Sender: TObject);
    procedure btnAesDecryptClick(Sender: TObject);
    procedure ResultDblClick(Sender: TObject);
    procedure btnSHA256Click(Sender: TObject);
    procedure btnFileSHA256Click(Sender: TObject);
    procedure btnSHA224Click(Sender: TObject);
    procedure btnSHA224FileClick(Sender: TObject);
    procedure btnSHA512Click(Sender: TObject);
    procedure btnSHA512FileClick(Sender: TObject);
    procedure btnSHA384Click(Sender: TObject);
    procedure btnSHA384FileClick(Sender: TObject);
    procedure btnZUC1Click(Sender: TObject);
    procedure btnZUCEIA31Click(Sender: TObject);
    procedure btnZUC2Click(Sender: TObject);
    procedure btnZUC3Click(Sender: TObject);
    procedure btnZUC4Click(Sender: TObject);
    procedure btnZUCEIA32Click(Sender: TObject);
    procedure btnZUCEEA31Click(Sender: TObject);
    procedure btnSHA256HmacClick(Sender: TObject);
    procedure btnSHA224HmacClick(Sender: TObject);
    procedure btnSHA384HmacClick(Sender: TObject);
    procedure btnSHA512HmacClick(Sender: TObject);
    procedure btnSHA1HmacClick(Sender: TObject);
    procedure btnMD5HmacClick(Sender: TObject);
    procedure btnSM3HmacClick(Sender: TObject);
    procedure btnCRC32HmacClick(Sender: TObject);
    procedure btnCRC64HmacClick(Sender: TObject);
    procedure btnSHA3_256Click(Sender: TObject);
    procedure btnFileSHA3_256Click(Sender: TObject);
    procedure btnSHA3_224Click(Sender: TObject);
    procedure btnSHA3_224FileClick(Sender: TObject);
    procedure btnSHA3_512Click(Sender: TObject);
    procedure btnSHA3_512FileClick(Sender: TObject);
    procedure btnSHA3_384Click(Sender: TObject);
    procedure btnSHA3_384FileClick(Sender: TObject);
    procedure btnSHA3_256HmacClick(Sender: TObject);
    procedure btnSHA3_224HmacClick(Sender: TObject);
    procedure btnSHA3_384HmacClick(Sender: TObject);
    procedure btnSHA3_512HmacClick(Sender: TObject);
    procedure btnUMd5Click(Sender: TObject);
    procedure btnUSHA1Click(Sender: TObject);
    procedure btnUSM3Click(Sender: TObject);
    procedure btnUSHA224Click(Sender: TObject);
    procedure btnUSHA256Click(Sender: TObject);
    procedure btnUSHA384Click(Sender: TObject);
    procedure btnUSHA512Click(Sender: TObject);
    procedure btnUSHA3_224Click(Sender: TObject);
    procedure btnUSHA3_256Click(Sender: TObject);
    procedure btnUSHA3_384Click(Sender: TObject);
    procedure btnUSHA3_512Click(Sender: TObject);
    procedure btnBase64FileClick(Sender: TObject);
    procedure btnDeBase64FileClick(Sender: TObject);
    procedure btnTeaEncClick(Sender: TObject);
    procedure btnXTeaEncClick(Sender: TObject);
    procedure btnTeaDecClick(Sender: TObject);
    procedure btnXTeaDecClick(Sender: TObject);
    procedure btnXXTeaEncClick(Sender: TObject);
    procedure btnXXTeaDecClick(Sender: TObject);
    procedure btn3DesCryptClick(Sender: TObject);
    procedure btn3DesDecryptClick(Sender: TObject);
    procedure btnCRC16Click(Sender: TObject);
    procedure btnFileCRC16Click(Sender: TObject);
    procedure btnCRC8Click(Sender: TObject);
    procedure btnFileCRC8Click(Sender: TObject);
  private
    { Private declarations }
    procedure InitTeaKeyData;
    function ToHex(Buffer: PAnsiChar; Length: Integer): AnsiString;
    function FromHex(const Hex: string): AnsiString;
{$IFDEF TBYTES_DEFINED}
    function BytesToHex(Data: TBytes): AnsiString;
    function HexToBytes(const Hex: string): TBytes;
{$ENDIF}
  public
    { Public declarations }
  end;

var
  FormCrypt: TFormCrypt;

implementation

uses
  CnMD5, CnDES, CnBase64, CnCRC32, CnSHA1, CnSM3, CnSM4, CnAES, CnSHA2, CnZUC,
  CnSHA3, CnTEA, CnPemUtils;

{$R *.lfm}

var
  TeaKey: TCnTeaKey;
  TeaData: TCnTeaData;
  TeaEnc: TCnTeaData;

  DesIv: array[0..7] of Byte = (
    $01, $23, $45, $67, $89, $AB, $CD, $EF
  );

  Sm4Iv: array[0..15] of Byte = (
    $01, $23, $45, $67, $89, $AB, $CD, $EF,
    $FE, $DC, $BA, $98, $76, $54, $32, $10
  );

  AesIv: TAESBuffer = (
    $01, $23, $45, $67, $89, $AB, $CD, $EF,
    $FE, $DC, $BA, $98, $76, $54, $32, $10
  );

function HexToInt(const Hex: AnsiString): Integer;
var
  I, Res: Integer;
  ch: AnsiChar;
begin
  Res := 0;
  for I := 0 to Length(Hex) - 1 do
  begin
    ch := Hex[I + 1];
    if (ch >= '0') and (ch <= '9') then
      Res := Res * 16 + Ord(ch) - Ord('0')
    else if (ch >= 'A') and (ch <= 'F') then
      Res := Res * 16 + Ord(ch) - Ord('A') + 10
    else if (ch >= 'a') and (ch <= 'f') then
      Res := Res * 16 + Ord(ch) - Ord('a') + 10
    else
      raise Exception.Create('Error: not a Hex String');
  end;
  Result := Res;
end;

function TFormCrypt.FromHex(const Hex: string): AnsiString;
var
  S: string;
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(Hex) div 2 - 1 do
  begin
    S := Copy(Hex, I * 2 + 1, 2);
    Result := Result + AnsiChar(HexToInt(S));
  end;
end;

function TFormCrypt.ToHex(Buffer: PAnsiChar; Length: Integer): AnsiString;
const
  Digits: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
                                  '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  I: Integer;
  B: Byte;
begin
  Result := '';
  for I := 0 to Length - 1 do
  begin
    B := PByte(Integer(Buffer) + I)^;
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}
      (Digits[(B shr 4) and $0F] + Digits[B and $0F]);
  end;
end;

{$IFDEF TBYTES_DEFINED}

function TFormCrypt.BytesToHex(Data: TBytes): AnsiString;
const
  Digits: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
                                  '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  I, Len: Integer;
  B: Byte;
  Buffer: PAnsiChar;
begin
  Result := '';
  Len := Length(Data);
  if Len = 0 then
    Exit;

  Buffer := @Data[0];
  for I := 0 to Len - 1 do
  begin
    B := PByte(Integer(Buffer) + I)^;
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}
      (Digits[(B shr 4) and $0F] + Digits[B and $0F]);
  end;
end;

function TFormCrypt.HexToBytes(const Hex: string): TBytes;
var
  S: string;
  I: Integer;
begin
  if Hex = '' then
  begin
    Result := nil;
    Exit;
  end;

  SetLength(Result, (Length(Hex) + 1) div 2);
  for I := 0 to Length(Hex) div 2 - 1 do
  begin
    S := Copy(Hex, I * 2 + 1, 2);
    Result[I] := HexToInt(S);
  end;
end;

{$ENDIF}

procedure TFormCrypt.btnMd5Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlMd5.Caption := MD5Print(MD5StringA(AnsiString(edtMD5.Text)));
{$ELSE}
  pnlMd5.Caption := MD5Print(MD5String(edtMD5.Text));
{$ENDIF}
end;

procedure TFormCrypt.btnDesCryptClick(Sender: TObject);
var
  Output: AnsiString;
  Len: Integer;
  TmpDesIv: array[0..7] of Byte;
  IvStr: AnsiString;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes, DataBytes: TBytes;
{$ENDIF}
begin
  Len := Length(AnsiString(edtDesFrom.Text));
  if Len < 8 then
    Len := 8
  else
    Len := (((Len - 1) div 8) + 1) * 8;
  SetLength(Output, Len);
  ZeroMemory(@(Output[1]), Len);

  if rbDESEcb.Checked then
  begin
    if chkDESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtDESKey.Text);
      DataBytes := TEncoding.Default.GetBytes(edtDesFrom.Text);
      if cbbDesPadding.ItemIndex = 1 then
        BytesAddPKCS7Padding(DataBytes, DES_BLOCKSIZE);

      ResBytes := DESEncryptEcbBytes(KeyBytes, DataBytes);
      edtDESCode.Text := BytesToHex(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      if cbbDesPadding.ItemIndex = 1 then
        DESEncryptEcbStr(edtDESKey.Text, StrAddPKCS7Padding(edtDesFrom.Text, DES_BLOCKSIZE), @(Output[1]))
      else
        DESEncryptEcbStr(edtDESKey.Text, edtDesFrom.Text, @(Output[1]));
    end;
      
  end
  else
  begin
    IvStr := FromHex(edtDESIv.Text);
    if Length(IvStr) <> SizeOf(TmpDesIv) then
    begin
      ShowMessage('Invalid DES Iv, Use Our Default Iv.');
      CopyMemory(@(TmpDesIv[0]), @(DesIv[0]), SizeOf(DesIv));
    end
    else
      CopyMemory(@(TmpDesIv[0]), @IvStr[1], SizeOf(DesIv));

    if chkDESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtDESKey.Text);
      IvBytes := TEncoding.Default.GetBytes(IvStr);
      DataBytes := TEncoding.Default.GetBytes(edtDesFrom.Text);
      if cbbDesPadding.ItemIndex = 1 then
        BytesAddPKCS7Padding(DataBytes, DES_BLOCKSIZE);

      ResBytes := DESEncryptCbcBytes(KeyBytes, IvBytes, DataBytes);
      edtDESCode.Text := BytesToHex(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      if cbbDesPadding.ItemIndex = 1 then
        DESEncryptCbcStr(edtDESKey.Text, PAnsiChar(@(TmpDesIv[0])),
          StrAddPKCS7Padding(edtDesFrom.Text, DES_BLOCKSIZE), @(Output[1]))
      else
        DESEncryptCbcStr(edtDESKey.Text, PAnsiChar(@(TmpDesIv[0])), edtDesFrom.Text, @(Output[1]));
    end;
  end;
  edtDESCode.Text := ToHex(@(Output[1]), Length(Output));

  // edtDESCode.Text := DESEncryptStrToHex(edtDesFrom.Text, edtDESKey.Text);
end;

procedure TFormCrypt.btnDesDecryptClick(Sender: TObject);
var
  S, IvStr: AnsiString;
  Output: AnsiString;
  Len: Integer;
  TmpDesIv: array[0..7] of Byte;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes: TBytes;
{$ENDIF}
begin
  S := AnsiString(FromHex(edtDESCode.Text));
  Len := Length(S);
  if Len < 8 then
    Len := 8
  else
    Len := (((Len - 1) div 8) + 1) * 8;
  SetLength(Output, Len);
  ZeroMemory(@(Output[1]), Len);

  if rbDESEcb.Checked then
  begin
    if chkDESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtDESKey.Text);
      ResBytes := DESDecryptEcbBytes(KeyBytes, HexToBytes(edtDESCode.Text));
      if cbbDesPadding.ItemIndex = 1 then
        BytesRemovePKCS7Padding(ResBytes);
      edtDesOrigin.Text := TEncoding.Default.GetString(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      DESDecryptEcbStr(edtDESKey.Text, S, @(Output[1]));
      if cbbDesPadding.ItemIndex = 1 then
        Output := StrRemovePKCS7Padding(Output);
    end;
  end
  else
  begin
    IvStr := FromHex(edtDESIv.Text);
    if Length(IvStr) <> SizeOf(TmpDesIv) then
    begin
      ShowMessage('Invalid DES Iv, Use Our Default Iv.');
      CopyMemory(@(TmpDesIv[0]), @(DesIv[0]), SizeOf(DesIv));
    end
    else
      CopyMemory(@(TmpDesIv[0]), @IvStr[1], SizeOf(DesIv));

    if chkDESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtDESKey.Text);
      IvBytes := TEncoding.Default.GetBytes(IvStr);
      ResBytes := DESDecryptCbcBytes(KeyBytes, IvBytes, HexToBytes(edtDESCode.Text));
      if cbbDesPadding.ItemIndex = 1 then
        BytesRemovePKCS7Padding(ResBytes);
      edtDesOrigin.Text := TEncoding.Default.GetString(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      DESDecryptCbcStr(edtDESKey.Text, PAnsiChar(@(TmpDesIv[0])), S, @(Output[1]));
      if cbbDesPadding.ItemIndex = 1 then
        Output := StrRemovePKCS7Padding(Output);
    end;
  end;
  edtDesOrigin.Text := Output;

  // edtDesOrigin.Text := DESDecryptStrFromHex(edtDESCode.Text, edtDESKey.Text);
end;

procedure TFormCrypt.Button1Click(Sender: TObject);
var
  S: string;
begin
  if chkBase64UseTBytes.Checked then
  begin
{$IFDEF TBYTES_DEFINED}
    Base64Encode(TEncoding.Default.GetBytes(edtBase64from.Text), S);
{$ENDIF}
  end
  else
    Base64Encode(edtBase64from.Text, S);
  edtBase64Result.Text := S;
end;

procedure TFormCrypt.btnBase64DecodeClick(Sender: TObject);
var
  S: AnsiString;
{$IFDEF TBYTES_DEFINED}
  Res: TBytes;
{$ENDIF}
begin
  if chkBase64UseTBytes.Checked then
  begin
{$IFDEF TBYTES_DEFINED}
    Base64Decode(edtBase64Result.Text, Res);
    S := TEncoding.Default.GetString(Res);
{$ENDIF}
  end
  else
    Base64Decode(edtBase64Result.Text, S);
  edtbase64Decode.Text := S;
end;

procedure TFormCrypt.btnCRC32Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlCRC32.Caption := IntToHex(StrCRC32A(0, AnsiString(edtCRC32.Text)), 2);
{$ELSE}
  pnlCRC32.Caption := IntToHex(StrCRC32(0, edtCRC32.Text), 2);
{$ENDIF}
end;

procedure TFormCrypt.btnMd5FileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    pnlMd5.Caption := MD5Print(MD5File(OpenDialog1.FileName));
end;

procedure TFormCrypt.btnFileCRC32Click(Sender: TObject);
var
  Crc: DWORD;
begin
  Crc := 0;
  if OpenDialog1.Execute then
    if FileCRC32(OpenDialog1.FileName, Crc) then
      pnlCRC32.Caption := IntToHex(Crc, 2);
end;

procedure TFormCrypt.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  cbbAesKeyBitType.ItemIndex := 0;
  Application.Title := Caption;

  cbbSm4Padding.ItemIndex := 0;
  cbbDesPadding.ItemIndex := 0;
  cbb3DesPadding.ItemIndex := 0;
  cbbAesPadding.ItemIndex := 0;

{$IFNDEF TBYTES_DEFINED}
  chkSM4UseTBytes.Visible := False;
  chkDESUseTBytes.Visible := False;
  chk3DESUseTBytes.Visible := False;
  chkBase64UseTBytes.Visible := False;
  chkAESUseTBytes.Visible := False;
{$ENDIF}
end;

procedure TFormCrypt.btnCRC64Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlCRC64.Caption := IntToHex(StrCRC64A(0, AnsiString(edtCRC64.Text)), 2);
{$ELSE}
  pnlCRC64.Caption := IntToHex(StrCRC64(0, edtCRC64.Text), 2);
{$ENDIF}
end;

procedure TFormCrypt.btnFileCRC64Click(Sender: TObject);
var
  Crc: Int64;
begin
  Crc := 0;
  if OpenDialog1.Execute then
    if FileCRC64(OpenDialog1.FileName, Crc) then
      pnlCRC64.Caption := IntToHex(Crc, 2);
end;

procedure TFormCrypt.btnSha1Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlSha1.Caption := SHA1Print(SHA1StringA(AnsiString(edtSha1.Text)));
{$ELSE}
  pnlSha1.Caption := SHA1Print(SHA1String(edtSha1.Text));
{$ENDIF}
end;

procedure TFormCrypt.btnFileSha1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    pnlSha1.Caption := SHA1Print(SHA1File(OpenDialog1.FileName));
end;

procedure TFormCrypt.btnSM3Click(Sender: TObject);
var
  S: string;
begin
{$IFDEF UNICODE}
  S := SM3Print(SM3StringA(AnsiString(edtSm3.Text)));
{$ELSE}
  S := SM3Print(SM3String(edtSm3.Text));
{$ENDIF}
  Insert(#13#10, S, 33);
  lblSm3Result.Caption := S;
end;

procedure TFormCrypt.btnFileSM3Click(Sender: TObject);
var
  S: string;
begin
  if OpenDialog1.Execute then
  begin
    S := SM3Print(SM3File(OpenDialog1.FileName));
    Insert(#13#10, S, 33);
    lblSm3Result.Caption := S;
  end;
end;

procedure TFormCrypt.btnSm4Click(Sender: TObject);
var
  Output: AnsiString;
  Len: Integer;
  TmpSm4Iv: array[0..15] of Byte;
  IvStr: AnsiString;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes, DataBytes: TBytes;
{$ENDIF}
begin
  Len := Length(AnsiString(edtSm4.Text));
  if Len < 16 then
    Len := 16
  else
    Len := (((Len - 1) div 16) + 1) * 16;
  SetLength(Output, Len);
  ZeroMemory(@(Output[1]), Len);

  if rbSm4Ecb.Checked then
  begin
    if chkSM4UseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtSm4Key.Text);
      DataBytes := TEncoding.Default.GetBytes(edtSm4.Text);
      if cbbSm4Padding.ItemIndex = 1 then
        BytesAddPKCS7Padding(DataBytes, SM4_BLOCKSIZE);

      ResBytes := SM4EncryptEcbBytes(KeyBytes, DataBytes);
      edtSm4Code.Text := BytesToHex(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      if cbbSm4Padding.ItemIndex = 1 then
        SM4EncryptEcbStr(edtSm4Key.Text, StrAddPKCS7Padding(edtSm4.Text, SM4_BLOCKSIZE), @(Output[1]))
      else // 末尾补 0 的对齐
        SM4EncryptEcbStr(edtSm4Key.Text, edtSm4.Text, @(Output[1]));
    end;
  end
  else if rbSm4Cbc.Checked or rbSm4Cfb.Checked or rbSm4Ofb.Checked then
  begin
    IvStr := FromHex(edtSM4Iv.Text);
    if Length(IvStr) <> SizeOf(TmpSm4Iv) then
    begin
      ShowMessage('Invalid SM4 Iv, Use Our Default Iv.');
      CopyMemory(@(TmpSm4Iv[0]), @(Sm4Iv[0]), SizeOf(Sm4Iv));
    end
    else
      CopyMemory(@(TmpSm4Iv[0]), @IvStr[1], SizeOf(Sm4Iv));

{$IFDEF TBYTES_DEFINED}
    KeyBytes := TEncoding.Default.GetBytes(edtSm4Key.Text);
    IvBytes := TEncoding.Default.GetBytes(IvStr);
    DataBytes := TEncoding.Default.GetBytes(edtSm4.Text);

    if rbSm4Cbc.Checked and (cbbSm4Padding.ItemIndex = 1) then
      BytesAddPKCS7Padding(DataBytes, SM4_BLOCKSIZE);
{$ENDIF}

    if chkSM4UseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      if rbSm4Cbc.Checked then
        ResBytes := SM4EncryptCbcBytes(KeyBytes, IvBytes, DataBytes)
      else if rbSm4Cfb.Checked then
        ResBytes := SM4EncryptCfbBytes(KeyBytes, IvBytes, DataBytes)
      else if rbSm4Ofb.Checked then
        ResBytes := SM4EncryptOfbBytes(KeyBytes, IvBytes, DataBytes);

      edtSm4Code.Text := BytesToHex(ResBytes);
      Exit;
{$ENDIF}
    end
    else if rbSm4Cbc.Checked then
    begin
      if cbbSm4Padding.ItemIndex = 1 then
        SM4EncryptCbcStr(edtSm4Key.Text, PAnsiChar(@(TmpSm4Iv[0])),
          StrAddPKCS7Padding(edtSm4.Text, SM4_BLOCKSIZE), @(Output[1]))
      else
        SM4EncryptCbcStr(edtSm4Key.Text, PAnsiChar(@(TmpSm4Iv[0])), edtSm4.Text, @(Output[1]))
    end
    else if rbSm4Cfb.Checked then
    begin
      SM4EncryptCfbStr(edtSm4Key.Text, PAnsiChar(@(TmpSm4Iv[0])), edtSm4.Text, @(Output[1]))
    end
    else if rbSm4Ofb.Checked then
    begin
      SM4EncryptOfbStr(edtSm4Key.Text, PAnsiChar(@(TmpSm4Iv[0])), edtSm4.Text, @(Output[1]))
    end
  end;
  edtSm4Code.Text := ToHex(@(Output[1]), Length(Output));
end;

procedure TFormCrypt.btnSm4DecClick(Sender: TObject);
var
  S, IvStr: AnsiString;
  Output: AnsiString;
  Len: Integer;
  TmpSm4Iv: array[0..15] of Byte;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes: TBytes;
{$ENDIF}
begin
  S := AnsiString(FromHex(edtSm4Code.Text));
  Len := Length(S);
  if Len < 16 then
    Len := 16
  else
    Len := (((Len - 1) div 16) + 1) * 16;
  SetLength(Output, Len);
  ZeroMemory(@(Output[1]), Len);

  if rbSm4Ecb.Checked then
  begin
    if chkSM4UseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtSm4Key.Text);
      ResBytes := SM4DecryptEcbBytes(KeyBytes, HexToBytes(edtSm4Code.Text));
      if cbbSm4Padding.ItemIndex = 1 then
        BytesRemovePKCS7Padding(ResBytes);
      edtSm4Dec.Text := TEncoding.Default.GetString(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      SM4DecryptEcbStr(edtSm4Key.Text, S, @(Output[1]));
      if cbbSm4Padding.ItemIndex = 1 then
        Output := StrRemovePKCS7Padding(Output);
    end;
  end
  else if rbSm4Cbc.Checked or rbSm4Cfb.Checked or rbSm4Ofb.Checked then
  begin
    IvStr := FromHex(edtSM4Iv.Text);
    if Length(IvStr) <> SizeOf(TmpSm4Iv) then
    begin
      ShowMessage('Invalid SM4 Iv, Use Our Default Iv.');
      CopyMemory(@(TmpSm4Iv[0]), @(Sm4Iv[0]), SizeOf(Sm4Iv));
    end
    else
      CopyMemory(@(TmpSm4Iv[0]), @IvStr[1], SizeOf(Sm4Iv));


    if chkSM4UseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtSm4Key.Text);
      IvBytes := TEncoding.Default.GetBytes(IvStr);
      if rbSm4Cbc.Checked then
        ResBytes := SM4DecryptCbcBytes(KeyBytes, IvBytes, HexToBytes(edtSm4Code.Text))
      else if rbSm4Cfb.Checked then
        ResBytes := SM4DecryptCfbBytes(KeyBytes, IvBytes, HexToBytes(edtSm4Code.Text))
      else if rbSm4Ofb.Checked then
        ResBytes := SM4DecryptOfbBytes(KeyBytes, IvBytes, HexToBytes(edtSm4Code.Text));

      if rbSm4Cbc.Checked and (cbbSm4Padding.ItemIndex = 1) then
        BytesRemovePKCS7Padding(ResBytes);

      edtSm4Dec.Text := TEncoding.Default.GetString(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      if rbSm4Cbc.Checked then
      begin
        SM4DecryptCbcStr(edtSm4Key.Text, PAnsiChar(@(TmpSm4Iv[0])), S, @(Output[1]));
        if cbbSm4Padding.ItemIndex = 1 then
          Output := StrRemovePKCS7Padding(Output);
      end
      else if rbSm4Cfb.Checked then
        SM4DecryptCfbStr(edtSm4Key.Text, PAnsiChar(@(TmpSm4Iv[0])), S, @(Output[1]))
      else if rbSm4Ofb.Checked then
        SM4DecryptOfbStr(edtSm4Key.Text, PAnsiChar(@(TmpSm4Iv[0])), S, @(Output[1]));
    end;
  end;
  edtSm4Dec.Text := Output;
end;

procedure TFormCrypt.btnAesEncryptClick(Sender: TObject);
var
  TmpAesIv: TAESBuffer;
  IvStr: AnsiString;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes, DataBytes: TBytes;
{$ENDIF}
begin
  if rbAesecb.Checked then
  begin
    if chkAESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtAesKey.Text);
      DataBytes := TEncoding.Default.GetBytes(edtAes.Text);
      if cbbAesPadding.ItemIndex = 1 then
        BytesAddPKCS7Padding(DataBytes, AES_BLOCKSIZE);

      case cbbAesKeyBitType.ItemIndex of
        0:
          ResBytes := AESEncryptEcbBytes(DataBytes, KeyBytes, kbt128);
        1:
          ResBytes := AESEncryptEcbBytes(DataBytes, KeyBytes, kbt192);
        2:
          ResBytes := AESEncryptEcbBytes(DataBytes, KeyBytes, kbt256);
      end;
      edtAesResult.Text := BytesToHex(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      if cbbAesPadding.ItemIndex = 1 then
      begin
        case cbbAesKeyBitType.ItemIndex of
          0:
            edtAesResult.Text := AESEncryptEcbStrToHex(StrAddPKCS7Padding(edtAes.Text,
              AES_BLOCKSIZE), edtAesKey.Text, kbt128);
          1:
            edtAesResult.Text := AESEncryptEcbStrToHex(StrAddPKCS7Padding(edtAes.Text,
              AES_BLOCKSIZE), edtAesKey.Text, kbt192);
          2:
            edtAesResult.Text := AESEncryptEcbStrToHex(StrAddPKCS7Padding(edtAes.Text,
              AES_BLOCKSIZE), edtAesKey.Text, kbt256);
        end;
      end
      else
      begin
        case cbbAesKeyBitType.ItemIndex of
          0:
            edtAesResult.Text := AESEncryptEcbStrToHex(edtAes.Text, edtAesKey.Text, kbt128);
          1:
            edtAesResult.Text := AESEncryptEcbStrToHex(edtAes.Text, edtAesKey.Text, kbt192);
          2:
            edtAesResult.Text := AESEncryptEcbStrToHex(edtAes.Text, edtAesKey.Text, kbt256);
        end;
      end;
    end;
  end
  else if rbAescbc.Checked or rbAescfb.Checked or rbAesofb.Checked then // 这仨都需要初始化向量
  begin
    IvStr := FromHex(edtAesIv.Text);
    if Length(IvStr) <> SizeOf(TAESBuffer) then
    begin
      ShowMessage('Invalid AES Iv, Use Our Default Iv.');
      CopyMemory(@TmpAesIv, @AesIv, SizeOf(TmpAesIv));
    end
    else
      CopyMemory(@TmpAesIv, @IvStr[1], SizeOf(TmpAesIv));

{$IFDEF TBYTES_DEFINED}
    if chkAESUseTBytes.Checked then
    begin
      KeyBytes := TEncoding.Default.GetBytes(edtAesKey.Text);
      IvBytes := TEncoding.Default.GetBytes(IvStr);
      DataBytes := TEncoding.Default.GetBytes(edtAes.Text);

      if rbAescbc.Checked and (cbbAesPadding.ItemIndex = 1) then // CBC 需要对齐
        BytesAddPKCS7Padding(DataBytes, AES_BLOCKSIZE);
    end;
{$ENDIF}

    if rbAescbc.Checked then
    begin
      if chkAESUseTBytes.Checked then
      begin
{$IFDEF TBYTES_DEFINED}
        case cbbAesKeyBitType.ItemIndex of
          0:
            ResBytes := AESEncryptCbcBytes(DataBytes, KeyBytes, IvBytes, kbt128);
          1:
            ResBytes := AESEncryptCbcBytes(DataBytes, KeyBytes, IvBytes, kbt192);
          2:
            ResBytes := AESEncryptCbcBytes(DataBytes, KeyBytes, IvBytes, kbt256);
        end;
        edtAesResult.Text := BytesToHex(ResBytes);
        Exit;
{$ENDIF}
      end
      else
      begin
        if cbbAesPadding.ItemIndex = 1 then
        begin
          case cbbAesKeyBitType.ItemIndex of
            0:
              edtAesResult.Text := AESEncryptCbcStrToHex(StrAddPKCS7Padding(edtAes.Text,
                AES_BLOCKSIZE), edtAesKey.Text, TmpAesIv, kbt128);
            1:
              edtAesResult.Text := AESEncryptCbcStrToHex(StrAddPKCS7Padding(edtAes.Text,
                AES_BLOCKSIZE), edtAesKey.Text, TmpAesIv, kbt192);
            2:
              edtAesResult.Text := AESEncryptCbcStrToHex(StrAddPKCS7Padding(edtAes.Text,
                AES_BLOCKSIZE), edtAesKey.Text, TmpAesIv, kbt256);
          end;
        end
        else
        begin
          case cbbAesKeyBitType.ItemIndex of
            0:
              edtAesResult.Text := AESEncryptCbcStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt128);
            1:
              edtAesResult.Text := AESEncryptCbcStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt192);
            2:
              edtAesResult.Text := AESEncryptCbcStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt256);
          end;
        end;
      end;
    end
    else if rbAescfb.Checked then
    begin
      if chkAESUseTBytes.Checked then
      begin
{$IFDEF TBYTES_DEFINED}
        case cbbAesKeyBitType.ItemIndex of
          0:
            ResBytes := AESEncryptCfbBytes(DataBytes, KeyBytes, IvBytes, kbt128);
          1:
            ResBytes := AESEncryptCfbBytes(DataBytes, KeyBytes, IvBytes, kbt192);
          2:
            ResBytes := AESEncryptCfbBytes(DataBytes, KeyBytes, IvBytes, kbt256);
        end;
        edtAesResult.Text := BytesToHex(ResBytes);
        Exit;
{$ENDIF}
      end
      else
      begin
        // CFB 不需要 Padding
        case cbbAesKeyBitType.ItemIndex of
          0:
            edtAesResult.Text := AESEncryptCfbStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt128);
          1:
            edtAesResult.Text := AESEncryptCfbStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt192);
          2:
            edtAesResult.Text := AESEncryptCfbStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt256);
        end;
      end;
    end
    else if rbAesofb.Checked then
    begin
      if chkAESUseTBytes.Checked then
      begin
{$IFDEF TBYTES_DEFINED}
        case cbbAesKeyBitType.ItemIndex of
          0:
            ResBytes := AESEncryptOfbBytes(DataBytes, KeyBytes, IvBytes, kbt128);
          1:
            ResBytes := AESEncryptOfbBytes(DataBytes, KeyBytes, IvBytes, kbt192);
          2:
            ResBytes := AESEncryptOfbBytes(DataBytes, KeyBytes, IvBytes, kbt256);
        end;
        edtAesResult.Text := BytesToHex(ResBytes);
        Exit;
{$ENDIF}
      end
      else
      begin
        // OFB 不需要 Padding
        case cbbAesKeyBitType.ItemIndex of
          0:
            edtAesResult.Text := AESEncryptOfbStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt128);
          1:
            edtAesResult.Text := AESEncryptOfbStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt192);
          2:
            edtAesResult.Text := AESEncryptOfbStrToHex(edtAes.Text, edtAesKey.Text, TmpAesIv, kbt256);
        end;
      end;
    end;
  end;
end;

procedure TFormCrypt.btnAesDecryptClick(Sender: TObject);
var
  TmpAesIv: TAESBuffer;
  IvStr: AnsiString;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes, DataBytes: TBytes;
{$ENDIF}
begin
  if rbAesecb.Checked then
  begin
    if chkAESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edtAesKey.Text);
      case cbbAesKeyBitType.ItemIndex of
        0:
          ResBytes := AESDecryptEcbBytes(HexToBytes(edtAesResult.Text), KeyBytes, kbt128);
        1:
          ResBytes := AESDecryptEcbBytes(HexToBytes(edtAesResult.Text), KeyBytes, kbt192);
        2:
          ResBytes := AESDecryptEcbBytes(HexToBytes(edtAesResult.Text), KeyBytes, kbt256);
      end;
      if cbbAesPadding.ItemIndex = 1 then
        BytesRemovePKCS7Padding(ResBytes);
      edtAesDecrypt.Text := TEncoding.Default.GetString(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      case cbbAesKeyBitType.ItemIndex of
        0:
          edtAesDecrypt.Text := AESDecryptEcbStrFromHex(edtAesResult.Text, edtAesKey.Text, kbt128);
        1:
          edtAesDecrypt.Text := AESDecryptEcbStrFromHex(edtAesResult.Text, edtAesKey.Text, kbt192);
        2:
          edtAesDecrypt.Text := AESDecryptEcbStrFromHex(edtAesResult.Text, edtAesKey.Text, kbt256);
      end;
      if cbbAesPadding.ItemIndex = 1 then
        edtAesDecrypt.Text := StrRemovePKCS7Padding(edtAesDecrypt.Text);
    end;
  end
  else if rbAescbc.Checked or rbAescfb.Checked or rbAesofb.Checked then
  begin
    IvStr := FromHex(edtAesIv.Text);
    if Length(IvStr) <> SizeOf(TAESBuffer) then
    begin
      ShowMessage('Invalid AES Iv, Use Our Default Iv.');
      CopyMemory(@TmpAesIv, @AesIv, SizeOf(TmpAesIv));
    end
    else
      CopyMemory(@TmpAesIv, @IvStr[1], SizeOf(TmpAesIv));

{$IFDEF TBYTES_DEFINED}
    if chkAESUseTBytes.Checked then
    begin
      KeyBytes := TEncoding.Default.GetBytes(edtAesKey.Text);
      IvBytes := TEncoding.Default.GetBytes(IvStr);
      DataBytes := TEncoding.Default.GetBytes(edtAes.Text);

      if rbAescbc.Checked and (cbbAesPadding.ItemIndex = 1) then // CBC 需要对齐
        BytesAddPKCS7Padding(DataBytes, AES_BLOCKSIZE);
    end;
{$ENDIF}

    if rbAescbc.Checked then
    begin
      if chkAESUseTBytes.Checked then
      begin
{$IFDEF TBYTES_DEFINED}
        case cbbAesKeyBitType.ItemIndex of
          0:
            ResBytes := AESDecryptCbcBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt128);
          1:
            ResBytes := AESDecryptCbcBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt192);
          2:
            ResBytes := AESDecryptCbcBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt256);
        end;
        if cbbAesPadding.ItemIndex = 1 then
          BytesRemovePKCS7Padding(ResBytes);
        edtAesDecrypt.Text := TEncoding.Default.GetString(ResBytes);
        Exit;
{$ENDIF}
      end
      else
      begin
        case cbbAesKeyBitType.ItemIndex of
          0:
            edtAesDecrypt.Text := AESDecryptCbcStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt128);
          1:
            edtAesDecrypt.Text := AESDecryptCbcStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt192);
          2:
            edtAesDecrypt.Text := AESDecryptCbcStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt256);
        end;
        if cbbAesPadding.ItemIndex = 1 then
          edtAesDecrypt.Text := StrRemovePKCS7Padding(edtAesDecrypt.Text);
      end;
    end
    else if rbAescfb.Checked then
    begin
      if chkAESUseTBytes.Checked then
      begin
{$IFDEF TBYTES_DEFINED}
        case cbbAesKeyBitType.ItemIndex of
          0:
            ResBytes := AESDecryptCfbBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt128);
          1:
            ResBytes := AESDecryptCfbBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt192);
          2:
            ResBytes := AESEncryptCfbBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt256);
        end;
        edtAesDecrypt.Text := TEncoding.Default.GetString(ResBytes);
        Exit;
{$ENDIF}
      end
      else
      begin
        // CFB 不需要 Padding
        case cbbAesKeyBitType.ItemIndex of
          0:
            edtAesDecrypt.Text := AESDecryptCfbStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt128);
          1:
            edtAesDecrypt.Text := AESDecryptCfbStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt192);
          2:
            edtAesDecrypt.Text := AESDecryptCfbStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt256);
        end;
      end;
    end
    else if rbAesofb.Checked then
    begin
      if chkAESUseTBytes.Checked then
      begin
{$IFDEF TBYTES_DEFINED}
        case cbbAesKeyBitType.ItemIndex of
          0:
            ResBytes := AESDecryptOfbBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt128);
          1:
            ResBytes := AESDecryptOfbBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt192);
          2:
            ResBytes := AESEncryptOfbBytes(HexToBytes(edtAesResult.Text), KeyBytes, IvBytes, kbt256);
        end;
        edtAesDecrypt.Text := TEncoding.Default.GetString(ResBytes);
        Exit;
{$ENDIF}
      end
      else
      begin
        // CFB 不需要 Padding
        case cbbAesKeyBitType.ItemIndex of
          0:
            edtAesDecrypt.Text := AESDecryptOfbStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt128);
          1:
            edtAesDecrypt.Text := AESDecryptOfbStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt192);
          2:
            edtAesDecrypt.Text := AESDecryptOfbStrFromHex(edtAesResult.Text, edtAesKey.Text, TmpAesIv, kbt256);
        end;
      end;
    end;
  end;
end;

procedure TFormCrypt.ResultDblClick(Sender: TObject);
begin
  if Sender is TPanel then
    Clipboard.AsText := (Sender as TPanel).Caption
  else if Sender is TLabel then
    Clipboard.AsText := (Sender as TLabel).Caption;
end;

procedure TFormCrypt.btnSHA256Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlSha256.Caption := SHA256Print(SHA256StringA(AnsiString(edtSha256.Text)));
{$ELSE}
  pnlSha256.Caption := SHA256Print(SHA256String(edtSha256.Text));
{$ENDIF}
end;

procedure TFormCrypt.btnFileSHA256Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    pnlSha256.Caption := SHA256Print(SHA256File(OpenDialog1.FileName));
end;

procedure TFormCrypt.btnSHA224Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlSha224.Caption := SHA224Print(SHA224StringA(AnsiString(edtSha224.Text)));
{$ELSE}
  pnlSha224.Caption := SHA224Print(SHA224String(edtSha224.Text));
{$ENDIF}
end;

procedure TFormCrypt.btnSHA224FileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    pnlSha224.Caption := SHA224Print(SHA224File(OpenDialog1.FileName));
end;

procedure TFormCrypt.btnSHA512Click(Sender: TObject);
var
  S: string;
begin
{$IFDEF UNICODE}
  S := SHA512Print(SHA512StringA(AnsiString(edtSha512.Text)));
{$ELSE}
  S := SHA512Print(SHA512String(edtSha512.Text));
{$ENDIF}
  Insert(#13#10, S, 65);
  lblSHA512Result.Caption := S;
end;

procedure TFormCrypt.btnSHA512FileClick(Sender: TObject);
var
  S: string;
begin
  if OpenDialog1.Execute then
  begin
    S := SHA512Print(SHA512File(OpenDialog1.FileName));
    Insert(#13#10, S, 65);
    lblSHA512Result.Caption := S;
  end;
end;

procedure TFormCrypt.btnSHA384Click(Sender: TObject);
var
  S: string;
begin
{$IFDEF UNICODE}
  S := SHA384Print(SHA384StringA(AnsiString(edtSha384.Text)));
{$ELSE}
  S := SHA384Print(SHA384String(edtSha384.Text));
{$ENDIF}
  Insert(#13#10, S, 49);
  lblSHA384Result.Caption := S;
end;

procedure TFormCrypt.btnSHA384FileClick(Sender: TObject);
var
  S: string;
begin
  if OpenDialog1.Execute then
  begin
    S := SHA384Print(SHA384File(OpenDialog1.FileName));
    Insert(#13#10, S, 49);
    lblSHA384Result.Caption := S;
  end;
end;

//输入:
// 密钥 k:      00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
// 初始向量 iv: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
//输出:
// z1: 27bede74
// z2: 018082da
procedure TFormCrypt.btnZUC1Click(Sender: TObject);
var
  Key, IV: array[0..15] of Byte;
  KeyStream: array[0..1] of DWORD;
  List: TStringList;
  I: Integer;
begin
  FillChar(Key[0], SizeOf(Key), 0);
  FillChar(IV[0], SizeOf(IV), 0);
  ZUC(PByte(@Key[0]), PByte(@IV[0]), PLongWord(@KeyStream[0]), 2);

  List := TStringList.Create;
  for I := Low(KeyStream) to High(KeyStream) do
    List.Add('$' + IntToHex(KeyStream[I], 2));

  ShowMessage(List.Text);
  List.Free;
end;

//输入:
//  密钥 k:      ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
//  初始向量 iv: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
//输出:
//  z1: 0657cfa0
//  z2: 7096398b
procedure TFormCrypt.btnZUC2Click(Sender: TObject);
var
  Key, IV: array[0..15] of Byte;
  KeyStream: array[0..1] of DWORD;
  List: TStringList;
  I: Integer;
begin
  FillChar(Key[0], SizeOf(Key), $FF);
  FillChar(IV[0], SizeOf(IV), $FF);
  ZUC(PByte(@Key[0]), PByte(@IV[0]), PLongWord(@KeyStream[0]), 2);

  List := TStringList.Create;
  for I := Low(KeyStream) to High(KeyStream) do
    List.Add('$' + IntToHex(KeyStream[I], 2));

  ShowMessage(List.Text);
  List.Free;
end;

//输入:
//  密钥 k:      3d 4c 4b e9 6a 82 fd ae b5 8f 64 1d b1 7b 45 5b
//  初始向量 iv: 84 31 9a a8 de 69 15 ca 1f 6b da 6b fb d8 c7 66
//输出:
//  z1: 14f1c272
//  z2: 3279c419
procedure TFormCrypt.btnZUC3Click(Sender: TObject);
const
  Key: array[0..15] of Byte = ($3d, $4c, $4b, $e9, $6a, $82, $fd, $ae, $b5, $8f,
    $64, $1d, $b1, $7b, $45, $5b);
  IV: array[0..15] of Byte = ($84, $31, $9a, $a8, $de, $69, $15, $ca, $1f, $6b,
    $da, $6b, $fb, $d8, $c7, $66);
var
  KeyStream: array[0..1] of DWORD;
  List: TStringList;
  I: Integer;
begin
  ZUC(PByte(@Key[0]), PByte(@IV[0]), PLongWord(@KeyStream[0]), 2);

  List := TStringList.Create;
  for I := Low(KeyStream) to High(KeyStream) do
    List.Add('$' + IntToHex(KeyStream[I], 2));

  ShowMessage(List.Text);
  List.Free;
end;

//输入:
// Key: 4d 32 0b fa d4 c2 85 bf d6 b8 bd 00 f3 9d 8b 41
// IV: 52 95 9d ab a0 bf 17 6e ce 2d c3 15 04 9e b5 74
//输出:
// z1: ed4400e7
// z2: 0633e5c5
//……
// Z2000: 7a574cdb
procedure TFormCrypt.btnZUC4Click(Sender: TObject);
const
  Key: array[0..15] of Byte = ($4d, $32, $0b, $fa, $d4, $c2, $85, $bf, $d6, $b8,
    $bd, $00, $f3, $9d, $8b, $41);
  IV: array[0..15] of Byte = ($52, $95, $9d, $ab, $a0, $bf, $17, $6e, $ce, $2d,
    $c3, $15, $04, $9e, $b5, $74);
var
  KeyStream: array[0..1999] of DWORD;
  List: TStringList;
begin
  ZUC(PByte(@Key[0]), PByte(@IV[0]), PLongWord(@KeyStream[0]), 2000);

  List := TStringList.Create;
  List.Add('$' + IntToHex(KeyStream[0], 2));
  List.Add('$' + IntToHex(KeyStream[1], 2));
  List.Add('...');
  List.Add('$' + IntToHex(KeyStream[1999], 2));

  ShowMessage(List.Text);
  List.Free;
end;

//Test Set 1
//Key = (hex) 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
//Count = (hex) 0
//Bearer = (hex) 0
//Direction = (hex) 0
//Length = 1 bits
//Message:
//(hex) 00000000
//MAC: (hex) c8a9595e
procedure TFormCrypt.btnZUCEIA31Click(Sender: TObject);
var
  Key: array[0..15] of Byte;
  Msg: Byte;
  Mac: DWORD;
begin
  FillChar(Key[0], SizeOf(Key), 0);
  Msg := 0;
  ZUCEIA3(PByte(@Key[0]), 0, 0, 0, @Msg, 1, @Mac);
  ShowMessage('$' + IntToHex(Mac, 2));
end;

//Test Set 2
//Key = 47 05 41 25 56 1e b2 dd a9 40 59 da 05 09 78 50
//Count = 561eb2dd
//Bearer = 14
//Direction = 0
//Length = 90 bits
//Message:
//00000000 00000000 00000000
//MAC: 6719a088
procedure TFormCrypt.btnZUCEIA32Click(Sender: TObject);
const
  Key: array[0..15] of Byte = ($47, $05, $41, $25, $56, $1e, $b2, $dd, $a9, $40,
    $59, $da, $05, $09, $78, $50);
var
  Msg: array[0..20] of Byte;  // Enough for 90 bits
  Mac: DWORD;
begin
  // FIXME: NOT Ready now.
  FillChar(Msg[0], SizeOf(Msg), 0);
  ZUCEIA3(PByte(@Key[0]), $561eb2dd, $14, 0, @(Msg[0]), 90, @Mac);
  ShowMessage('$' + IntToHex(Mac, 2));
end;

//Key = (hex) 17 3d 14 ba 50 03 73 1d 7a 60 04 94 70 f0 0a 29
//Count = (hex) 66035492
//Bearer = (hex) f
//Direction = (hex) 0
//Length = 193 bits
//Plaintext:
//(hex) 6cf65340 735552ab 0c9752fa 6f9025fe 0bd675d9 005875b2 00000000
//Ciphertext:
//(hex) a6c85fc6 6afb8533 aafc2518 dfe78494 0ee1e4b0 30238cc8 00000000
procedure TFormCrypt.btnZUCEEA31Click(Sender: TObject);
const
  Key: array[0..15] of Byte = ($17, $3d, $14, $ba, $50, $03, $73, $1d, $7a, $60,
    $04, $94, $70, $f0, $0a, $29);
  Plain: array[0..6] of DWORD = ($6cf65340, $735552ab, $0c9752fa, $6f9025fe,
    $0bd675d9, $005875b2, 0);
var
  Cipher: array[0..6] of DWORD;
  List: TStringList;
  I: Integer;
begin
  FillChar(Cipher[0], SizeOf(Cipher), 0);
  ZUCEEA3(PByte(@Key[0]), $66035492, $F, 0, PByte(@Plain[0]), 193, PByte(@Cipher[0]));

  List := TStringList.Create;
  for I := Low(Cipher) to High(Cipher) do
    List.Add('$' + IntToHex(Cipher[I], 2));
  ShowMessage(List.Text);
  List.Free;
end;

procedure TFormCrypt.btnSHA256HmacClick(Sender: TObject);
var
  Output: TSHA256Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA256HmacKey.Text);
  S := AnsiString(edtSHA256.Text);
  SHA256Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  pnlSHA256.Caption := SHA256Print(Output);
end;

procedure TFormCrypt.btnSHA224HmacClick(Sender: TObject);
var
  Output: TSHA224Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA224HmacKey.Text);
  S := AnsiString(edtSHA224.Text);
  SHA224Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  pnlSHA224.Caption := SHA224Print(Output);
end;

procedure TFormCrypt.btnSHA384HmacClick(Sender: TObject);
var
  Output: TSHA384Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA384HmacKey.Text);
  S := AnsiString(edtSHA384.Text);
  SHA384Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  S := SHA384Print(Output);
  Insert(#13#10, S, 49);
  lblSHA384Result.Caption := S;
end;

procedure TFormCrypt.btnSHA512HmacClick(Sender: TObject);
var
  Output: TSHA512Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA512HmacKey.Text);
  S := AnsiString(edtSHA512.Text);
  SHA512Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  S := SHA512Print(Output);
  Insert(#13#10, S, 65);
  lblSHA512Result.Caption := S;
end;

procedure TFormCrypt.btnSHA1HmacClick(Sender: TObject);
var
  Output: TSHA1Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA1HmacKey.Text);
  S := AnsiString(edtSHA1.Text);
  SHA1Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  pnlSHA1.Caption := SHA1Print(Output);
end;

procedure TFormCrypt.btnMD5HmacClick(Sender: TObject);
var
  Output: TMD5Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtMD5HmacKey.Text);
  S := AnsiString(edtMD5.Text);
  MD5Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  pnlMD5.Caption := MD5Print(Output);
end;

procedure TFormCrypt.btnSM3HmacClick(Sender: TObject);
var
  Output: TSM3Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSM3HmacKey.Text);
  S := AnsiString(edtSM3.Text);
  SM3Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  lblSm3Result.Caption := SM3Print(Output);
end;

procedure TFormCrypt.btnCRC32HmacClick(Sender: TObject);
var
  Output: DWORD;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtCRC32HmacKey.Text);
  S := AnsiString(edtCRC32.Text);
  Output := CRC32Hmac(@Key[1], Length(Key), @S[1], Length(S));
  pnlCRC32.Caption := IntToHex(Output, 2);
end;

procedure TFormCrypt.btnCRC64HmacClick(Sender: TObject);
var
  Output: Int64;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtCRC64HmacKey.Text);
  S := AnsiString(edtCRC64.Text);
  Output := CRC64Hmac(@Key[1], Length(Key), @S[1], Length(S));
  pnlCRC64.Caption := IntToHex(Output, 2);
end;

procedure TFormCrypt.btnFileSHA3_256Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    pnlSha3_256.Caption := SHA3_256Print(SHA3_256File(OpenDialog1.FileName));
end;

procedure TFormCrypt.btnSHA3_224Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlSHA3_224.Caption := SHA3_224Print(SHA3_224StringA(AnsiString(edtSha3_224.Text)));
{$ELSE}
  pnlSHA3_224.Caption := SHA3_224Print(SHA3_224String(edtSha3_224.Text));
{$ENDIF}
end;

procedure TFormCrypt.btnSHA3_224FileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    pnlSha3_224.Caption := SHA3_224Print(SHA3_224File(OpenDialog1.FileName));
end;

procedure TFormCrypt.btnSHA3_224HmacClick(Sender: TObject);
var
  Output: TSHA3_224Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA3_224HmacKey.Text);
  S := AnsiString(edtSHA3_224.Text);
  SHA3_224Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  pnlSHA3_224.Caption := SHA3_224Print(Output);
end;

procedure TFormCrypt.btnSHA3_256Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlSHA3_256.Caption := SHA3_256Print(SHA3_256StringA(AnsiString(edtSha3_256.Text)));
{$ELSE}
  pnlSHA3_256.Caption := SHA3_256Print(SHA3_256String(edtSha3_256.Text));
{$ENDIF}
end;

procedure TFormCrypt.btnSHA3_256HmacClick(Sender: TObject);
var
  Output: TSHA3_256Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA3_256HmacKey.Text);
  S := AnsiString(edtSHA3_256.Text);
  SHA3_256Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  pnlSHA3_256.Caption := SHA3_256Print(Output);
end;

procedure TFormCrypt.btnSHA3_384Click(Sender: TObject);
var
  S: string;
begin
{$IFDEF UNICODE}
  S := SHA3_384Print(SHA3_384StringA(AnsiString(edtSha3_384.Text)));
{$ELSE}
  S := SHA3_384Print(SHA3_384String(edtSha3_384.Text));
{$ENDIF}
  Insert(#13#10, S, 49);
  lblSHA3_384Result.Caption := S;
end;

procedure TFormCrypt.btnSHA3_384FileClick(Sender: TObject);
var
  S: string;
begin
  if OpenDialog1.Execute then
  begin
    S := SHA3_384Print(SHA3_384File(OpenDialog1.FileName));
    Insert(#13#10, S, 49);
    lblSHA3_384Result.Caption := S;
  end;
end;

procedure TFormCrypt.btnSHA3_384HmacClick(Sender: TObject);
var
  Output: TSHA3_384Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA3_384HmacKey.Text);
  S := AnsiString(edtSHA3_384.Text);
  SHA3_384Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  S := SHA3_384Print(Output);
  Insert(#13#10, S, 49);
  lblSHA3_384Result.Caption := S;
end;

procedure TFormCrypt.btnSHA3_512Click(Sender: TObject);
var
  S: string;
begin
{$IFDEF UNICODE}
  S := SHA3_512Print(SHA3_512StringA(AnsiString(edtSha3_512.Text)));
{$ELSE}
  S := SHA3_512Print(SHA3_512String(edtSha3_512.Text));
{$ENDIF}
  Insert(#13#10, S, 65);
  lblSHA3_512Result.Caption := S;
end;

procedure TFormCrypt.btnSHA3_512FileClick(Sender: TObject);
var
  S: string;
begin
  if OpenDialog1.Execute then
  begin
    S := SHA3_512Print(SHA3_512File(OpenDialog1.FileName));
    Insert(#13#10, S, 65);
    lblSHA3_512Result.Caption := S;
  end;
end;

procedure TFormCrypt.btnSHA3_512HmacClick(Sender: TObject);
var
  Output: TSHA3_512Digest;
  S, Key: AnsiString;
begin
  Key := AnsiString(edtSHA3_512HmacKey.Text);
  S := AnsiString(edtSHA3_512.Text);
  SHA3_512Hmac(@Key[1], Length(Key), @S[1], Length(S), Output);
  S := SHA3_512Print(Output);
  Insert(#13#10, S, 65);
  lblSHA3_512Result.Caption := S;
end;

procedure TFormCrypt.btnUMd5Click(Sender: TObject);
begin
  pnlMd5.Caption := MD5Print(MD5UnicodeString(edtMD5.Text));
end;

procedure TFormCrypt.btnUSHA1Click(Sender: TObject);
begin
  pnlSha1.Caption := SHA1Print(SHA1UnicodeString(edtSha1.Text));
end;

procedure TFormCrypt.btnUSM3Click(Sender: TObject);
var
  S: string;
begin
  S := SM3Print(SM3UnicodeString(edtSm3.Text));
  Insert(#13#10, S, 33);
  lblSm3Result.Caption := S;
end;

procedure TFormCrypt.btnUSHA224Click(Sender: TObject);
begin
  pnlSha224.Caption := SHA224Print(SHA224UnicodeString(edtSha224.Text));
end;

procedure TFormCrypt.btnUSHA256Click(Sender: TObject);
begin
  pnlSha256.Caption := SHA256Print(SHA256UnicodeString(edtSha256.Text));
end;

procedure TFormCrypt.btnUSHA384Click(Sender: TObject);
var
  S: string;
begin
  S := SHA384Print(SHA384UnicodeString(edtSha384.Text));
  Insert(#13#10, S, 49);
  lblSHA384Result.Caption := S;
end;

procedure TFormCrypt.btnUSHA512Click(Sender: TObject);
var
  S: string;
begin
  S := SHA512Print(SHA512UnicodeString(edtSha512.Text));
  Insert(#13#10, S, 65);
  lblSHA512Result.Caption := S;
end;

procedure TFormCrypt.btnUSHA3_224Click(Sender: TObject);
begin
  pnlSHA3_224.Caption := SHA3_224Print(SHA3_224UnicodeString(edtSha3_224.Text));
end;

procedure TFormCrypt.btnUSHA3_256Click(Sender: TObject);
begin
  pnlSHA3_256.Caption := SHA3_256Print(SHA3_256UnicodeString(edtSha3_256.Text));
end;

procedure TFormCrypt.btnUSHA3_384Click(Sender: TObject);
var
  S: string;
begin
  S := SHA3_384Print(SHA3_384UnicodeString(edtSha3_384.Text));
  Insert(#13#10, S, 49);
  lblSHA3_384Result.Caption := S;
end;

procedure TFormCrypt.btnUSHA3_512Click(Sender: TObject);
var
  S: string;
begin
  S := SHA3_512Print(SHA3_512UnicodeString(edtSha3_512.Text));
  Insert(#13#10, S, 65);
  lblSHA3_512Result.Caption := S;
end;

procedure TFormCrypt.btnBase64FileClick(Sender: TObject);
var
  M: TFileStream;
  S: string;
begin
  if OpenDialog1.Execute then
  begin
    M := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
    if Base64Encode(M, S) = Base64_OK then
      edtBase64Result.Text := S;
    M.Free;
  end;
end;

procedure TFormCrypt.btnDeBase64FileClick(Sender: TObject);
var
  Stream: TMemoryStream;
begin
  if dlgSave.Execute then
  begin
    Stream := TMemoryStream.Create;
    Base64Decode(edtBase64Result.Text, Stream, False);
    Stream.SaveToFile(dlgSave.FileName);
  end;
end;

procedure TFormCrypt.InitTeaKeyData;
begin
  TeaKey[0] := HexToInt(edtTeaKey1.Text);
  TeaKey[1] := HexToInt(edtTeaKey2.Text);
  TeaKey[2] := HexToInt(edtTeaKey3.Text);
  TeaKey[3] := HexToInt(edtTeaKey4.Text);
  TeaData[0] := HexToInt(edtTeaData1.Text);
  TeaData[1] := HexToInt(edtTeaData2.Text);
end;

procedure TFormCrypt.btnTeaEncClick(Sender: TObject);
begin
  InitTeaKeyData;
  CnTeaEncrypt(TeaKey, TeaData);
  edtTeaEnc1.Text := IntToHex(TeaData[0], 2);
  edtTeaEnc2.Text := IntToHex(TeaData[1], 2);
end;

procedure TFormCrypt.btnXTeaEncClick(Sender: TObject);
begin
  InitTeaKeyData;
  CnXTeaEncrypt(TeaKey, TeaData);
  edtXTeaEnc1.Text := IntToHex(TeaData[0], 2);
  edtXTeaEnc2.Text := IntToHex(TeaData[1], 2);
end;

procedure TFormCrypt.btnTeaDecClick(Sender: TObject);
begin
  InitTeaKeyData;
  TeaEnc[0] := HexToInt(edtTeaEnc1.Text);
  TeaEnc[1] := HexToInt(edtTeaEnc2.Text);
  CnTeaDecrypt(TeaKey, TeaEnc);
  edtTeaEnc1.Text := IntToHex(TeaEnc[0], 2);
  edtTeaEnc2.Text := IntToHex(TeaEnc[1], 2);
end;

procedure TFormCrypt.btnXTeaDecClick(Sender: TObject);
begin
  InitTeaKeyData;
  TeaEnc[0] := HexToInt(edtXTeaEnc1.Text);
  TeaEnc[1] := HexToInt(edtXTeaEnc2.Text);
  CnXTeaDecrypt(TeaKey, TeaEnc);
  edtXTeaEnc1.Text := IntToHex(TeaEnc[0], 2);
  edtXTeaEnc2.Text := IntToHex(TeaEnc[1], 2);
end;

procedure TFormCrypt.btnXXTeaEncClick(Sender: TObject);
begin
  InitTeaKeyData;
  CnXXTeaEncrypt(TeaKey, @TeaData[0], 2);
  edtXXTeaEnc1.Text := IntToHex(TeaData[0], 2);
  edtXXTeaEnc2.Text := IntToHex(TeaData[1], 2);
end;

procedure TFormCrypt.btnXXTeaDecClick(Sender: TObject);
begin
  InitTeaKeyData;
  TeaEnc[0] := HexToInt(edtXXTeaEnc1.Text);
  TeaEnc[1] := HexToInt(edtXXTeaEnc2.Text);
  CnXXTeaDecrypt(TeaKey, @TeaEnc[0], 2);
  edtXXTeaEnc1.Text := IntToHex(TeaEnc[0], 2);
  edtXXTeaEnc2.Text := IntToHex(TeaEnc[1], 2);
end;

procedure TFormCrypt.btn3DesCryptClick(Sender: TObject);
var
  Output: AnsiString;
  Len: Integer;
  TmpDesIv: array[0..7] of Byte;
  IvStr: AnsiString;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes, DataBytes: TBytes;
{$ENDIF}
begin
  Len := Length(AnsiString(edt3DesFrom.Text));
  if Len < 8 then
    Len := 8
  else
    Len := (((Len - 1) div 8) + 1) * 8;
  SetLength(Output, Len);
  ZeroMemory(@(Output[1]), Len);

  if rb3DESEcb.Checked then
  begin
    if chk3DESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edt3DESKey.Text);
      DataBytes := TEncoding.Default.GetBytes(edt3DesFrom.Text);
      if cbb3DesPadding.ItemIndex = 1 then
        BytesAddPKCS7Padding(DataBytes, TRIPLE_DES_BLOCKSIZE);

      ResBytes := TripleDESEncryptEcbBytes(KeyBytes, DataBytes);
      edt3DESCode.Text := BytesToHex(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      if cbb3DesPadding.ItemIndex = 1 then
        TripleDESEncryptEcbStr(edt3DESKey.Text,
          StrAddPKCS7Padding(edt3DesFrom.Text, TRIPLE_DES_BLOCKSIZE), @(Output[1]))
      else
        TripleDESEncryptEcbStr(edt3DESKey.Text, edt3DesFrom.Text, @(Output[1]));
    end;
  end
  else
  begin
    IvStr := FromHex(edt3DESIv.Text);
    if Length(IvStr) <> SizeOf(TmpDesIv) then
    begin
      ShowMessage('Invalid 3DES Iv, Use Our Default Iv.');
      CopyMemory(@(TmpDesIv[0]), @(DesIv[0]), SizeOf(DesIv));
    end
    else
      CopyMemory(@(TmpDesIv[0]), @IvStr[1], SizeOf(DesIv));

    if chk3DESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edt3DESKey.Text);
      IvBytes := TEncoding.Default.GetBytes(IvStr);
      DataBytes := TEncoding.Default.GetBytes(edt3DesFrom.Text);
      if cbb3DesPadding.ItemIndex = 1 then
        BytesAddPKCS7Padding(DataBytes, TRIPLE_DES_BLOCKSIZE);

      ResBytes := TripleDESEncryptCbcBytes(KeyBytes, IvBytes, DataBytes);
      edt3DESCode.Text := BytesToHex(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      if cbb3DesPadding.ItemIndex = 1 then
        TripleDESEncryptCbcStr(edt3DESKey.Text, PAnsiChar(@(TmpDesIv[0])),
          StrAddPKCS7Padding(edt3DesFrom.Text, TRIPLE_DES_BLOCKSIZE), @(Output[1]))
      else
        TripleDESEncryptCbcStr(edt3DESKey.Text, PAnsiChar(@(TmpDesIv[0])), edt3DesFrom.Text, @(Output[1]));
    end;
  end;
  edt3DESCode.Text := ToHex(@(Output[1]), Length(Output));

  // edt3DESCode.Text := TripleDESEncryptStrToHex(edt3DesFrom.Text, edt3DESKey.Text);
end;

procedure TFormCrypt.btn3DesDecryptClick(Sender: TObject);
var
  S, IvStr: AnsiString;
  Output: AnsiString;
  Len: Integer;
  TmpDesIv: array[0..7] of Byte;
{$IFDEF TBYTES_DEFINED}
  KeyBytes, IvBytes, ResBytes: TBytes;
{$ENDIF}
begin
  S := AnsiString(FromHex(edt3DESCode.Text));
  Len := Length(S);
  if Len < 8 then
    Len := 8
  else
    Len := (((Len - 1) div 8) + 1) * 8;
  SetLength(Output, Len);
  ZeroMemory(@(Output[1]), Len);

  if rb3DESEcb.Checked then
  begin
    if chk3DESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edt3DESKey.Text);
      ResBytes := TripleDESDecryptEcbBytes(KeyBytes, HexToBytes(edt3DESCode.Text));
      if cbb3DesPadding.ItemIndex = 1 then
        BytesRemovePKCS7Padding(ResBytes);
      edt3DesOrigin.Text := TEncoding.Default.GetString(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      TripleDESDecryptEcbStr(edt3DESKey.Text, S, @(Output[1]));
      if cbb3DesPadding.ItemIndex = 1 then
        Output := StrRemovePKCS7Padding(Output);
    end;
  end
  else
  begin
    IvStr := FromHex(edt3DESIv.Text);
    if Length(IvStr) <> SizeOf(TmpDesIv) then
    begin
      ShowMessage('Invalid 3DES Iv, Use Our Default Iv.');
      CopyMemory(@(TmpDesIv[0]), @(DesIv[0]), SizeOf(DesIv));
    end
    else
      CopyMemory(@(TmpDesIv[0]), @IvStr[1], SizeOf(DesIv));

    if chk3DESUseTBytes.Checked then
    begin
{$IFDEF TBYTES_DEFINED}
      KeyBytes := TEncoding.Default.GetBytes(edt3DESKey.Text);
      IvBytes := TEncoding.Default.GetBytes(IvStr);
      ResBytes := TripleDESDecryptCbcBytes(KeyBytes, IvBytes, HexToBytes(edt3DESCode.Text));
      if cbb3DesPadding.ItemIndex = 1 then
        BytesRemovePKCS7Padding(ResBytes);
      edt3DesOrigin.Text := TEncoding.Default.GetString(ResBytes);
      Exit;
{$ENDIF}
    end
    else
    begin
      TripleDESDecryptCbcStr(edt3DESKey.Text, PAnsiChar(@(TmpDesIv[0])), S, @(Output[1]));
      if cbb3DesPadding.ItemIndex = 1 then
        Output := StrRemovePKCS7Padding(Output);
    end;
  end;
  edt3DesOrigin.Text := Output;

  // edt3DesOrigin.Text := TripleDESDecryptStrFromHex(edt3DESCode.Text, edt3DESKey.Text);
end;

procedure TFormCrypt.btnCRC16Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlCRC32.Caption := IntToHex(StrCRC16A(0, AnsiString(edtCRC32.Text)), 2);
{$ELSE}
  pnlCRC32.Caption := IntToHex(StrCRC16(0, edtCRC32.Text), 2);
{$ENDIF}
end;

procedure TFormCrypt.btnFileCRC16Click(Sender: TObject);
var
  Crc: WORD;
begin
  Crc := 0;
  if OpenDialog1.Execute then
    if FileCRC16(OpenDialog1.FileName, Crc) then
      pnlCRC32.Caption := IntToHex(Crc, 2);
end;

procedure TFormCrypt.btnCRC8Click(Sender: TObject);
begin
{$IFDEF UNICODE}
  pnlCRC32.Caption := IntToHex(StrCRC8A(0, AnsiString(edtCRC32.Text)), 2);
{$ELSE}
  pnlCRC32.Caption := IntToHex(StrCRC8(0, edtCRC32.Text), 2);
{$ENDIF}
end;

procedure TFormCrypt.btnFileCRC8Click(Sender: TObject);
var
  Crc: Byte;
begin
  Crc := 0;
  if OpenDialog1.Execute then
    if FileCRC8(OpenDialog1.FileName, Crc) then
      pnlCRC32.Caption := IntToHex(Crc, 2);
end;

end.
