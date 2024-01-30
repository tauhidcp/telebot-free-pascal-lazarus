unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, fpjson,
  jsonparser, fphttpclient, opensslsockets, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

  rawData       : ansistring;
  JsonPar       : TJSONParser;
  jsonDoc     : TJSONObject;
  TELEGRAM_BOT_URL : string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
idchat, pesan, username : string;
i : integer;
begin
  TELEGRAM_BOT_URL := 'https://api.telegram.org/'+Edit1.Text+'/getUpdates';
   try
    rawData := TFPHTTPClient.SimpleGet(TELEGRAM_BOT_URL);
  except
    on E: Exception do
    begin
      ShowMessage('Gagal membaca sumber data: ' + E.Message);
      Exit;
    end;
  end;

  try
    JsonPar := TJSONParser.Create(rawData);
    JsonDoc := TJSONObject(JsonPar.Parse);
  except
    on E: Exception do
    begin
      ShowMessage('Informasi tidak valid: ' + E.Message);
      Exit;
    end;
  end;

   if  jsonDoc.findpath('ok').AsBoolean then
     begin

       if (jsonDoc.findpath('result').Count <> 0) then
       begin

         if (jsonDoc.findpath('result').Items[0].FindPath('message').FindPath('chat').FindPath('username') <> nil) then
         username := jsonDoc.findpath('result').Items[0].FindPath('message').FindPath('chat').FindPath('username').AsString
         else
         begin
         if (jsonDoc.findpath('result').Items[0].FindPath('message').FindPath('chat').FindPath('first_name') <> nil) then
         username := jsonDoc.findpath('result').Items[0].FindPath('message').FindPath('chat').FindPath('first_name').AsString
         else
         username := 'Anonim';
         end;

         for i := 0 to jsonDoc.findpath('result').Count-1 do
         begin

            if (jsonDoc.findpath('result').Items[i].FindPath('message').FindPath('text') <> nil) then
            pesan := jsonDoc.findpath('result').Items[i].FindPath('message').FindPath('text').AsString
            else pesan := 'Bukan Pesan Teks';

            idchat     := jsonDoc.findpath('result').Items[i].FindPath('message').FindPath('chat').FindPath('id').AsString;

            if (jsonDoc.findpath('result').Items[i].FindPath('message').FindPath('chat').FindPath('username') <> nil) then
            username := jsonDoc.findpath('result').Items[i].FindPath('message').FindPath('chat').FindPath('username').AsString;

           ListBox1.Items.Add(idchat+' | '+username+' ('+pesan+')');
       end;

       end;
       end;
     end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if not (Edit2.Text='') and not (Memo1.Text='') then
  begin
     TELEGRAM_BOT_URL := 'https://api.telegram.org/'+Edit1.Text+'/sendMessage?chat_id='+Edit2.Text+'&text='+Memo1.Text;
      try
      rawData := TFPHTTPClient.SimpleGet(TELEGRAM_BOT_URL);
    except
      on E: Exception do
      begin
        ShowMessage('Gagal membaca sumber data: ' + E.Message);
        Exit;
      end;
    end;

    try
      JsonPar := TJSONParser.Create(rawData);
      JsonDoc := TJSONObject(JsonPar.Parse);
    except
      on E: Exception do
      begin
        ShowMessage('Informasi tidak valid: ' + E.Message);
        Exit;
      end;
    end;
     // Message Sent
     if jsonDoc.findpath('ok').AsBoolean then ShowMessage('Pesan Terkirim!');
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  id, first_name, username : string;
begin

  TELEGRAM_BOT_URL := 'https://api.telegram.org/'+Edit1.Text+'/getMe';
     try
      rawData := TFPHTTPClient.SimpleGet(TELEGRAM_BOT_URL);
    except
      on E: Exception do
      begin
        ShowMessage('Gagal membaca sumber data: ' + E.Message);
        Exit;
      end;
    end;

    try
      JsonPar := TJSONParser.Create(rawData);
      JsonDoc := TJSONObject(JsonPar.Parse);
    except
      on E: Exception do
      begin
        ShowMessage('Informasi tidak valid: ' + E.Message);
        Exit;
      end;
    end;

     if  jsonDoc.findpath('ok').AsBoolean then
       begin

         if (jsonDoc.findpath('result').Count <> 0) then
         begin

           if (jsonDoc.findpath('result').FindPath('id') <> nil) then
              id := jsonDoc.findpath('result').FindPath('id').AsString;
           if (jsonDoc.findpath('result').FindPath('first_name') <> nil) then
              first_name := jsonDoc.findpath('result').FindPath('first_name').AsString;
           if (jsonDoc.findpath('result').FindPath('username') <> nil) then
              username := jsonDoc.findpath('result').FindPath('username').AsString;

           ShowMessage('Bot ID : '+id+sLineBreak+'Bot Name : '+first_name+sLineBreak+'Username : '+username);
         end;
         end;
       end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
var
  VText: string;
  VIndex: NativeInt;
begin
  VText := ListBox1.GetSelectedText;
  VIndex := Pos('|', VText);
  if (VIndex > 0) then
  begin
    Edit2.Text := Copy(VText, 0, Pos('|', VText)-2);
  end;
end;


end.

