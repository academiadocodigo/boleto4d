{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatu� - SP - 18270-170         }
{******************************************************************************}
{                                                                              }
{  Algumas fun�oes dessa Unit foram extraidas de outras Bibliotecas, veja no   }
{ cabe�alho das Fun�oes no c�digo abaixo a origem das informa�oes, e autores...}
{                                                                              }
{******************************************************************************} 

{$I ACBr.inc}

unit ACBrImage;

interface

uses
  Classes, SysUtils
  {$IfNDef NOGUI}
   {$IfDef FPC}
    ,LCLType, InterfaceBase
   {$Else}
    {$IfDef MSWINDOWS}
     ,windows
    {$EndIf}
   {$EndIf}
   {$IfDef FMX}
    ,FMX.Graphics, System.UITypes, FMX.Types
   {$Else}
    ,Graphics
   {$EndIf}
  {$EndIf}
  ,ACBrBase;

const
  cErrImgPCXMono = 'Imagem n�o � PCX Monocrom�tica';
  cErrImgBMPMono = 'Imagem n�o � BMP Monocrom�tica';
  C_LUMINOSITY_THRESHOLD = 127;

type
  EACBrImage = class(Exception);

function IsPCX(S: TStream; CheckIsMono: Boolean = True): Boolean;
function IsBMP(S: TStream; CheckIsMono: Boolean = True): Boolean;

procedure RasterStrToAscII(const ARasterStr: AnsiString; AWidth: Integer;
  InvertImg: Boolean; AscIIArtLines: TStrings);
procedure AscIIToRasterStr(AscIIArtLines: TStrings; out AWidth: Integer;
  out AHeight: Integer; out ARasterStr: AnsiString);

procedure RasterStrToColumnStr(const ARasterStr: AnsiString; AWidth: Integer;
  ColumnSliceLines: TAnsiStringList; BytesPerSlice: Integer = 3);
procedure AscIIToColumnStr(AscIIArtLines: TStrings; out AWidth: Integer;
  out AHeight: Integer; ColumnSliceLines: TAnsiStringList; BytesPerSlice: Integer = 3);

procedure BMPMonoToRasterStr(ABMPStream: TStream; InvertImg: Boolean; out AWidth: Integer;
  out AHeight: Integer; out ARasterStr: AnsiString);
procedure RasterStrToBMPMono(const ARasterStr: AnsiString; AWidth: Integer;
  InvertImg: Boolean; ABMPStream: TStream);

{$IfNDef NOGUI}
procedure BitmapToRasterStr(ABmpSrc: TBitmap; InvertImg: Boolean;
  out AWidth: Integer; out AHeight: Integer; out ARasterStr: AnsiString;
  LuminosityThreshold: Byte = C_LUMINOSITY_THRESHOLD);
{$EndIf}

implementation

uses
// DEBUG
// {$IfDef ANDROID}
// System.IOUtils,
// {$EndIf}
  math, strutils,
  ACBrUtil, ACBrConsts;

function IsPCX(S: TStream; CheckIsMono: Boolean): Boolean;
var
  p: Int64;
  b, bColorPlanes, bBitsPerPixel: Byte;
begin
  // https://stackoverflow.com/questions/1689715/image-data-of-pcx-file
  p := S.Position;
  S.Position := 0;
  b := 0;
  S.ReadBuffer(b,1);
  Result := (b = 10);

  if Result and CheckIsMono then
  begin
    // Lendo as cores
    bBitsPerPixel := 0; bColorPlanes := 0;
    S.Position := 3;
    S.ReadBuffer(bBitsPerPixel, 1);
    S.Position := 65;
    S.ReadBuffer(bColorPlanes, 1);
    Result := (bColorPlanes = 1) and (bBitsPerPixel = 1);
  end;

  S.Position := p;
end;

function IsBMP(S: TStream; CheckIsMono: Boolean): Boolean;
var
  Buffer: array[0..1] of AnsiChar;
  bColorPlanes, bBitsPerPixel: Word;
  p: Int64;
begin
  //https://en.wikipedia.org/wiki/BMP_file_format
  p := S.Position;
  S.Position := 0;
  Buffer[0] := ' ';
  S.ReadBuffer(Buffer, 2);
  Result := (Buffer = 'BM');

  if Result and CheckIsMono then
  begin
    // Lendo as cores
    bColorPlanes := 0; bBitsPerPixel := 0;
    S.Position := 26;
    S.ReadBuffer(bColorPlanes, 2);
    S.ReadBuffer(bBitsPerPixel, 2);
    Result := (bColorPlanes = 1) and (bBitsPerPixel = 1);
  end;

  S.Position := p;
end;

procedure BMPMonoToRasterStr(ABMPStream: TStream; InvertImg: Boolean; out
  AWidth: Integer; out AHeight: Integer; out ARasterStr: AnsiString);
var
  bPixelOffset, bSizePixelArr, bWidth, bHeight: LongWord;
  bPixel, PadByte: Byte;
  StreamLastPos, RowStart, BytesPerRow, i, RealWidth: Int64;
  IsPadByte, HasPadBits: Boolean;
  BytesPerWidth, PadBits, j: Integer;
  WidthExtended: Extended;
begin
  // Inspira��o:
  // http://www.nonov.io/convert_bmp_to_ascii
  // https://en.wikipedia.org/wiki/BMP_file_format
  // https://github.com/asharif/img2grf/blob/master/src/main/java/org/orphanware/App.java

  if not IsBMP(ABMPStream, True) then
    raise EACBrImage.Create(ACBrStr(cErrImgBMPMono));

  // Lendo posi��o do Off-set da imagem
  ABMPStream.Position := 10;
  bPixelOffset := 0;
  ABMPStream.ReadBuffer(bPixelOffset, 4);

  // Lendo Tamanho do Pixel array
  ABMPStream.Position := 34;
  bSizePixelArr := 0;
  ABMPStream.ReadBuffer(bSizePixelArr, 4);

  // Lendo dimens�es da imagem
  ABMPStream.Position := 18;
  bWidth := 0; bHeight := 0;
  ABMPStream.ReadBuffer(bWidth, 4);
  ABMPStream.ReadBuffer(bHeight, 4);

  AHeight := bHeight;
  //AWidth := bWidth;
  ARasterStr := '';
  if (AHeight < 1) then
    raise EACBrImage.Create(ACBrStr(Format('Altura do Bitmap [%d] inv�lida',[AHeight])));

  // BMP � organizado da Esquerda para a Direita e de Baixo para cima.. serializando..
  BytesPerRow := ceil(bWidth / 8);
  HasPadBits := (BytesPerRow > (trunc(bWidth/8)));
  BytesPerRow := ceil(bWidth / 8);
  AWidth := BytesPerRow*8;
  PadByte := 0;
  if HasPadBits then
  begin
    PadBits := Cardinal(AWidth) - bWidth;
    PadByte := 1;
    for j := 2 to PadBits do
    begin
      PadByte := PadByte shl 1;
      PadByte := PadByte + 1;
    end;
  end;

  if (bSizePixelArr <= 0) then
    bSizePixelArr := ABMPStream.Size-bPixelOffset;

  WidthExtended := (bSizePixelArr*8)/bHeight;
  RealWidth := trunc(WidthExtended);
  BytesPerWidth := ceil(RealWidth / 8);
  if RealWidth < WidthExtended then
    bSizePixelArr := (BytesPerWidth * bHeight) ;

  StreamLastPos := min(Int64(bPixelOffset + bSizePixelArr - 1), ABMPStream.Size-1);

  while (StreamLastPos >= bPixelOffset) do
  begin
    RowStart := StreamLastPos - (BytesPerWidth - 1);
    i := 1;
    ABMPStream.Position := RowStart;
    while (i <= BytesPerRow) do
    begin
      IsPadByte := HasPadBits and (i = BytesPerRow);
      bPixel := 0;
      ABMPStream.ReadBuffer(bPixel,1);
      if IsPadByte then
        bPixel := bPixel or PadByte;

      if InvertImg then
        bPixel := bPixel xor $FF;

      ARasterStr := ARasterStr + AnsiChr(bPixel);
      inc(i);
    end;
    StreamLastPos := RowStart-1;
  end;

  //DEBUG
  //{$IfDef ANDROID}
  //WriteToFile( TPath.Combine( TPath.GetSharedDocumentsPath, 'Raster.txt'), ARasterStr );
  //{$Else}
  //WriteToFile('c:\temp\Raster.txt', ARasterStr);
  //{$EndIf}
end;

procedure RasterStrToAscII(const ARasterStr: AnsiString; AWidth: Integer;
  InvertImg: Boolean; AscIIArtLines: TStrings);
var
  BytesPerRow, LenRaster, i: Integer;
  ALine: String;
  AByte: Byte;
begin
  AscIIArtLines.Clear;
  if (AWidth <= 0) then
    raise EACBrImage.Create(ACBrStr('RasterStrToAscII: AWidth � obrigat�rio'));

  BytesPerRow := ceil(AWidth / 8);

  ALine := '';
  LenRaster := Length(ARasterStr);
  for i := 1 to LenRaster do
  begin
    AByte := ord(ARasterStr[i]);
    if InvertImg then
      AByte := AByte xor $FF;

    ALine := ALine + IntToBin(AByte, 8);
    if ((i mod BytesPerRow) = 0) then
    begin
      AscIIArtLines.Add(ALine);
      ALine := '';
    end;
  end;
end;

procedure AscIIToRasterStr(AscIIArtLines: TStrings; out AWidth: Integer; out
  AHeight: Integer; out ARasterStr: AnsiString);
var
  BytesPerRow, RealWidth, i, j: Integer;
  ALine, BinaryByte: String;
begin
  AWidth := 0;
  ARasterStr := '';
  AHeight := AscIIArtLines.Count;
  if AHeight < 1 then
    Exit;

  AWidth := Length(AscIIArtLines[1]);
  BytesPerRow := ceil(AWidth / 8);
  RealWidth := BytesPerRow * 8;

  for i := 0 to AHeight-1 do
  begin
    if AWidth = RealWidth then
      ALine := AscIIArtLines[i]
    else
      ALine := PadRight(AscIIArtLines[i], RealWidth, '0');

    j := 1;
    while J < RealWidth do
    begin
      BinaryByte := copy(ALine,j,8);
      ARasterStr := ARasterStr + AnsiChr(BinToInt(BinaryByte));
      inc(j,8);
    end;
  end;
end;

procedure RasterStrToColumnStr(const ARasterStr: AnsiString; AWidth: Integer;
  ColumnSliceLines: TAnsiStringList; BytesPerSlice: Integer);
var
  SL: TStringList;
  AHeight: Integer;
begin
  SL := TStringList.Create;
  try
    RasterStrToAscII(ARasterStr, AWidth, False, SL);
    AscIIToColumnStr(SL, AWidth, AHeight, ColumnSliceLines, BytesPerSlice);
  finally
    SL.Free;
  end;
end;

//https://bitbucket.org/bernd_summerswell/delphi_escpos_bitmap/overview
procedure AscIIToColumnStr(AscIIArtLines: TStrings; out AWidth: Integer; out
  AHeight: Integer; ColumnSliceLines: TAnsiStringList; BytesPerSlice: Integer);
var
  SliceStart, Col, Row, RealHeight, RealWidth, BitsPerSlice: Integer;
  ByteStr: String;
  AColumn: AnsiString;

  function GetBit(Row, Col: Integer): Char;
  var
    ALine: String;
  begin
    Result := '0';
    if Row <= AscIIArtLines.Count then
    begin
      ALine := AscIIArtLines[Row-1];
      if (Col <= Length(ALine)) then
        Result := ALine[Col];
    end;
  end;

begin
  AWidth := 0;
  ColumnSliceLines.Clear;
  AHeight := AscIIArtLines.Count;
  if AHeight < 1 then
    Exit;

  AWidth := Length(AscIIArtLines[0]);
  RealWidth := ceil(AWidth / 8) * 8;

  if (BytesPerSlice = 0) or (BytesPerSlice > AHeight) then
    BytesPerSlice := ceil(AHeight / 8);

  BitsPerSlice := BytesPerSlice * 8;
  RealHeight := ceil(AHeight/BitsPerSlice)*BitsPerSlice;

  SliceStart := 0;
  while SliceStart < RealHeight do
  begin
    AColumn := '';
    ByteStr := '';

    for Col := 1 to RealWidth do
    begin
      for Row := 1 to BitsPerSlice do
      begin
        ByteStr := ByteStr + GetBit(SliceStart+Row, Col);
        if ((Row mod 8) = 0) then
        begin
          AColumn := AColumn + AnsiChr(BinToInt(ByteStr));
          ByteStr := '';
        end;
      end;
    end;

    ColumnSliceLines.Add(AColumn);
    Inc(SliceStart, BitsPerSlice);
  end;
end;

procedure RasterStrToBMPMono(const ARasterStr: AnsiString; AWidth: Integer;
  InvertImg: Boolean; ABMPStream: TStream);
var
  AByte: Byte;
  AWord: Word;
  ALongWord: LongWord;
  LenPixArrIn, LenPixArrOut, BytesPerRowIn, BytesPerRowOut, RowStart: Integer;
  AHeight, i, p, b: Integer;
  PixArr: array of Byte;
  BMSig: array[0..1] of AnsiChar;
begin
  BytesPerRowIn := ceil(AWidth / 8);
  LenPixArrIn := Length(ARasterStr);
  AHeight := Trunc(LenPixArrIn / BytesPerRowIn);

  // O BMP deve estar em blocos de DWORD(32bits), calculando a Largura multiplo de 32
  BytesPerRowOut := ceil(AWidth / 32) * 4;
  LenPixArrOut := BytesPerRowOut * AHeight;
  SetLength(PixArr,LenPixArrOut);

  // BMP � organizado da Esquerda para a Direita e de Baixo para cima.. serializando..
  b := 0;
  p := LenPixArrIn-1;
  while (p > 0) do
  begin
    RowStart := p - (BytesPerRowIn - 1);
    i := 1;
    while (i <= BytesPerRowOut) do
    begin
      if i > BytesPerRowIn then
        AByte := 0
      else
      begin
        AByte := ord(ARasterStr[RowStart+i]);
        if InvertImg then
          AByte := AByte xor $FF;
      end;

      PixArr[b] := AByte;
      inc(i);
      inc(b);
    end;
    p := RowStart-1;
  end;

  with ABMPStream do
  begin
    Size := 0;  // Trunc Stream

    BMSig[0] := 'B';
    BMSig[1] := 'M';
    // BMP header   14 bytes
    WriteBuffer(BMSig,2);    // BitMap signature
    ALongWord := 14 + 40 + 8 + LenPixArrOut ;
    WriteBuffer(ALongWord, 4);  // Tamanho do arquivo
    ALongWord := 0;
    WriteBuffer(ALongWord, 4);  // Reservado para a aplica��o
    ALongWord := 62;
    WriteBuffer(ALongWord, 4);  // Inicio do Pixel array

    //DIB Header    40 bytes
    ALongWord := 40;
    WriteBuffer(ALongWord, 4);  // Tamanho do cabe�alho DIB
    ALongWord := AWidth;
    WriteBuffer(ALongWord, 4); // Largura
    ALongWord := AHeight;
    WriteBuffer(ALongWord, 4);  // Altura
    AWord := 1;
    WriteBuffer(AWord, 2);      // Numero de Planos
    WriteBuffer(AWord, 2);      // Numero de Bits (1bpp)
    ALongWord := 0;
    WriteBuffer(ALongWord, 4);  // M�todo de Compress�o
    ALongWord := LenPixArrOut;
    WriteBuffer(ALongWord, 4);  // Tamanho do Pixel array
    ALongWord := 0 ;
    WriteBuffer(ALongWord, 4);  // Print resolution of the image, 72DPI - H
    WriteBuffer(ALongWord, 4);  // Print resolution of the image, 72DPI - V
    ALongWord := 2;
    WriteBuffer(ALongWord, 4);  // Numero de cores na paleta
    ALongWord := 0;
    WriteBuffer(ALongWord, 4);  // Numero de cores importantes

    // Tabela de Cores    8 bytes
    ALongWord := 0;
    WriteBuffer(ALongWord, 4);  // Cor Preta
    ALongWord := $ffffff;
    WriteBuffer(ALongWord, 4);  // Cor Branca

    // Pixel array
    Write(Pointer(PixArr)^, LenPixArrOut);
    //Write(PAnsiChar(ARasterStr)^, LenPixArrIn);
    Position := 0;
  end;
end;

{$IfNDef NOGUI}
{$IfNDef FPC}
procedure RedGreenBlue(rgb: TColorRef; out Red, Green, Blue: Byte);
begin
  Red := rgb and $000000ff;
  Green := (rgb shr 8) and $000000ff;
  Blue := (rgb shr 16) and $000000ff;
end;
{$EndIf}

procedure BitmapToRasterStr(ABmpSrc: TBitmap; InvertImg: Boolean; out
  AWidth: Integer; out AHeight: Integer; out ARasterStr: AnsiString;
  LuminosityThreshold: Byte);
var
  MS: TMemoryStream;
  Row, Col: Integer;
  cRed, cGreen, cBlue: Byte;
  Luminosity: Int64;
  ByteStr: String;
  Bit: Boolean;
  {$IfDef FMX}
   BitMapData: TBitmapData;
   APixel: TAlphaColor;
  {$Else}
   APixel: TColor;
  {$EndIf}
begin
  AWidth := 0; AHeight := 0; ARasterStr := '';

  if (ABmpSrc.PixelFormat = {$IfDef FMX}TPixelFormat.RGB{$Else}pf1bit{$EndIf}) then  // J� � Mono ?
  begin
    MS := TMemoryStream.Create;
    try
      ABmpSrc.SaveToStream(MS);
      BMPMonoToRasterStr(MS, True, AWidth, AHeight, ARasterStr);
    finally
      MS.Free;
    end;

    Exit;
  end;

  AWidth := ABmpSrc.Width;
  AHeight := ABmpSrc.Height;
  for Row := 0 to AHeight - 1 do
  begin
    ByteStr := '';

    {$IfDef FMX}
    if ABmpSrc.Map(TMapAccess.Read, BitMapData) then
    try
    {$EndIf}
      for Col := 0 to AWidth - 1 do
      begin
        {$IfDef FMX}
        APixel := BitMapData.GetPixel(Col, Row);
        {$Else}
        APixel := ABmpSrc.Canvas.Pixels[Col, Row];
        {$EndIf}
        cRed := 0; cGreen := 0; cBlue := 0;
        RedGreenBlue(APixel, cRed, cGreen, cBlue);
        Luminosity := Trunc( ( cRed * 0.3 ) + ( cGreen  * 0.59 ) + ( cBlue * 0.11 ) );
        Bit := ( Luminosity > LuminosityThreshold );
        if InvertImg then
          Bit := not Bit;

        ByteStr := ByteStr + ifthen(Bit,'1','0');
        if (Length(ByteStr) = 8) then
        begin
          ARasterStr := ARasterStr + AnsiChr(BinToInt(ByteStr));
          ByteStr := '';
        end;
      end;
    {$IfDef FMX}
    finally
      ABmpSrc.Unmap(BitMapData);
    end;
    {$EndIf}

    if (Length(ByteStr) > 0) then
      ARasterStr := ARasterStr + AnsiChr(BinToInt(PadRight(ByteStr, 8, '0')));
  end;
end;
{$EndIf}

end.

