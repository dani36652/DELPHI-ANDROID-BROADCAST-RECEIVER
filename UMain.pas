unit UMain;

interface

uses
  Androidapi.JNI.Webkit, FMX.Dialogs.Android,
  Androidapi.JNI.Print, Androidapi.JNI.Bluetooth,
  Androidapi.jni,fmx.helpers.android, Androidapi.Jni.app,
  Androidapi.Jni.GraphicsContentViewText, Androidapi.JniBridge,
  Androidapi.JNI.Os, Androidapi.Jni.Telephony,
  Androidapi.JNI.JavaTypes,Androidapi.Helpers,
  Androidapi.JNI.Widget,System.Permissions,
  Androidapi.Jni.Provider,Androidapi.Jni.Net,
  fmx.TextLayout,AndroidAPI.JNI.Support, Androidapi.Jni.Embarcadero,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TCustomBroadcastReceiver_Listener = class(TJavaLocal, JFMXBroadcastReceiverListener)
  private
  public
    constructor Create;
    procedure onReceive(context: JContext; intent: JIntent); cdecl;
  end;

type
  TfrmMain = class(TForm)
    rectToolBar: TRectangle;
    lblTitle: TLabel;
    lblMsg: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FListener: TCustomBroadcastReceiver_Listener;
    FBroadcastReceiver: JFMXBroadcastReceiver;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

{ TCustomBroadcastReceiver_Listener }

constructor TCustomBroadcastReceiver_Listener.Create;
begin
  inherited;
end;

procedure TCustomBroadcastReceiver_Listener.onReceive(context: JContext;
  intent: JIntent);
var
  NivelBateria, EscalaBateria, PorcentajeBateria, Cargando: Integer;
  BtState: Integer;
begin
  if intent.getAction.equals(TJIntent.JavaClass.ACTION_BATTERY_CHANGED) then
  begin
    NivelBateria:= Intent.getIntExtra(StringToJString('level'), 0);
    EscalaBateria:= Intent.getIntExtra(StringToJString('scale'), 100);
    PorcentajeBateria:= (NivelBateria * 100) div EscalaBateria;
    Cargando:= Intent.getIntExtra(StringToJString('plugged'), -1);

    frmMain.lblMsg.Text:= 'Batería restante: ' + IntToStr(PorcentajeBateria) + '%' +
    sLineBreak;

    if Cargando = 0 then
      frmMain.lblMsg.Text:= frmMain.lblMsg.Text + 'Cargador no conectado'
    else
      frmMain.lblMsg.Text:= frmMain.lblMsg.Text + 'Cargando...';
  end
  else
  if intent.getAction.equals(TJIntent.JavaClass.ACTION_USER_PRESENT) or
  intent.getAction.equals(TJIntent.JavaClass.ACTION_SCREEN_ON) then 
    frmMain.lblMsg.Text:= 'Pantalla desbloqueada por el usuario'
  else 
  if intent.getAction.equals(TJBluetoothAdapter.JavaClass.ACTION_STATE_CHANGED) then 
  begin
    BtState:= intent.getIntExtra(TJBluetoothAdapter.JavaClass.EXTRA_STATE,
    TJBluetoothAdapter.JavaClass.ERROR);

    if BtState = TJBluetoothAdapter.JavaClass.STATE_ON then 
      frmMain.lblMsg.Text:= 'Bluetooth encendido' 
    else
    if BtState = TJBluetoothAdapter.JavaClass.STATE_OFF then 
      frmMain.lblMsg.Text:= 'Bluetooth apagado';        
  end;  

  frmMain.Invalidate;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  Filter: JIntentFilter;
  Window: JWindow;
begin
  FListener := TCustomBroadcastReceiver_Listener.Create;
  FBroadcastReceiver := TJFMXBroadcastReceiver.JavaClass.init(FListener);

  Filter := TJIntentFilter.JavaClass.init;
  Filter.addAction(TJIntent.JavaClass.ACTION_BATTERY_CHANGED);
  Filter.addAction(TJIntent.JavaClass.ACTION_USER_PRESENT);
  Filter.addAction(TJIntent.JavaClass.ACTION_SCREEN_ON);
  Filter.addAction(TJBluetoothAdapter.JavaClass.ACTION_STATE_CHANGED);
  TAndroidHelper.Context.registerReceiver(FBroadcastReceiver, Filter);

  Window:= TAndroidHelper.Activity.getWindow;
  Window.setStatusBarColor(TAndroidHelper.AlphaColorToJColor(rectToolBar.Fill.Color));
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FListener) then
    FreeAndNil(FListener);
end;

end.
