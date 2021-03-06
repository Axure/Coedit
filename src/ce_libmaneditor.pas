unit ce_libmaneditor;

{$I ce_defines.inc}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, ComCtrls, Buttons, ce_widget;

type

  TCELibManEditorWidget = class(TCEWidget)
    btnMoveDown: TBitBtn;
    btnMoveUp: TBitBtn;
    btnSelFile: TBitBtn;
    btnAddLib: TBitBtn;
    btnRemLib: TBitBtn;
    btnEditAlias: TBitBtn;
    btnSelfoldOfFiles: TBitBtn;
    btnSelRoot: TBitBtn;
    List: TListView;
    Panel1: TPanel;
    procedure btnAddLibClick(Sender: TObject);
    procedure btnEditAliasClick(Sender: TObject);
    procedure btnRemLibClick(Sender: TObject);
    procedure btnSelFileClick(Sender: TObject);
    procedure btnSelfoldOfFilesClick(Sender: TObject);
    procedure btnSelRootClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure ListEdited(Sender: TObject; Item: TListItem; var AValue: string);
  private
    procedure dataToGrid;
    procedure gridToData;
  protected
    procedure DoShow; override;
  public
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.lfm}

uses
  ce_libman;

const
  notav: string = '< n/a >';

constructor TCELibManEditorWidget.Create(aOwner: TComponent);
var
  png: TPortableNetworkGraphic;
begin
  inherited;
  png := TPortableNetworkGraphic.Create;
  try
    png.LoadFromLazarusResource('arrow_down');
    btnMoveDown.Glyph.Assign(png);
    png.LoadFromLazarusResource('arrow_up');
    btnMoveUp.Glyph.Assign(png);
    png.LoadFromLazarusResource('book_add');
    btnAddLib.Glyph.Assign(png);
    png.LoadFromLazarusResource('book_delete');
    btnRemLib.Glyph.Assign(png);
    png.LoadFromLazarusResource('book_edit');
    btnEditAlias.Glyph.Assign(png);
    png.LoadFromLazarusResource('folder_brick');
    btnSelFile.Glyph.Assign(png);
    png.LoadFromLazarusResource('bricks');
    btnSelfoldOfFiles.Glyph.Assign(png);
    png.LoadFromLazarusResource('folder_add');
    btnSelRoot.Glyph.Assign(png);
  finally
    png.Free;
  end;
end;

procedure TCELibManEditorWidget.ListEdited(Sender: TObject; Item: TListItem; var AValue: string);
begin
  gridToData;
end;

procedure TCELibManEditorWidget.btnAddLibClick(Sender: TObject);
var
  itm: TListItem;
begin
  itm := List.Items.Add;
  itm.Caption := notav;
  itm.SubItems.Add(notav);
  itm.SubItems.Add(notav);
  SetFocus;
  itm.Selected := True;
end;

procedure TCELibManEditorWidget.btnEditAliasClick(Sender: TObject);
var
  al: string;
begin
  if List.Selected = nil then
    exit;
  al := List.Selected.Caption;
  if inputQuery('library alias', '', al) then
    List.Selected.Caption := al;
  gridToData;
end;

procedure TCELibManEditorWidget.btnRemLibClick(Sender: TObject);
begin
  if List.Selected = nil then
    exit;
  List.Items.Delete(List.Selected.Index);
  gridToData;
end;

procedure TCELibManEditorWidget.btnSelFileClick(Sender: TObject);
var
  ini: string;
begin
  if List.Selected = nil then
    exit;
  if List.Selected.SubItems.Count > 0 then
    ini := List.Selected.SubItems[0]
  else
  begin
    ini := '';
    List.Selected.SubItems.Add(ini);
  end;
  with TOpenDialog.Create(nil) do
    try
      filename := ini;
      if Execute then
      begin
        if not fileExists(filename) then
          List.Selected.SubItems[0] := extractFilePath(filename)
        else
        begin
          List.Selected.SubItems[0] := filename;
          if (List.Selected.Caption = '') or (List.Selected.Caption = notav) then
            List.Selected.Caption := ChangeFileExt(extractFileName(filename), '');
        end;
      end;
    finally
      Free;
    end;
  gridToData;
end;

procedure TCELibManEditorWidget.btnSelfoldOfFilesClick(Sender: TObject);
var
  dir, outdir: string;
begin
  if List.Selected = nil then
    exit;
  if List.Selected.SubItems.Count > 0 then
    dir := List.Selected.SubItems[0]
  else
  begin
    dir := '';
    List.Selected.SubItems.Add(dir);
  end;
  if selectDirectory('folder of static libraries', dir, outdir, True, 0) then
    List.Selected.SubItems[0] := outdir;
  gridToData;
end;

procedure TCELibManEditorWidget.btnSelRootClick(Sender: TObject);
var
  dir, outdir: string;
begin
  if List.Selected = nil then
    exit;
  if List.Selected.SubItems.Count > 1 then
    dir := List.Selected.SubItems[1]
  else
  begin
    dir := '';
    while List.Selected.SubItems.Count < 2 do
      List.Selected.SubItems.Add(dir);
  end;
  if selectDirectory('sources root', dir, outdir, True, 0) then
    List.Selected.SubItems[1] := outdir;
  gridToData;
end;

procedure TCELibManEditorWidget.btnMoveUpClick(Sender: TObject);
begin
  if list.Selected = nil then
    exit;
  if list.Selected.Index = 0 then
    exit;
  //
  list.Items.Exchange(list.Selected.Index, list.Selected.Index - 1);
  gridToData;
end;

procedure TCELibManEditorWidget.btnMoveDownClick(Sender: TObject);
begin
  if list.Selected = nil then
    exit;
  if list.Selected.Index = list.Items.Count - 1 then
    exit;
  //
  list.Items.Exchange(list.Selected.Index, list.Selected.Index + 1);
  gridToData;
end;

procedure TCELibManEditorWidget.DoShow;
begin
  inherited;
  dataToGrid;
end;

procedure TCELibManEditorWidget.dataToGrid;
var
  itm: TLibraryItem;
  row: TListItem;
  i: NativeInt;
begin
  List.Clear;
  if LibMan = nil then
    exit;
  for i := 0 to LibMan.libraries.Count - 1 do
  begin
    itm := TLibraryItem(LibMan.libraries.Items[i]);
    row := List.Items.Add;
    row.Caption := itm.libAlias;
    row.SubItems.Add(itm.libFile);
    row.SubItems.Add(itm.libSourcePath);
  end;
end;

procedure TCELibManEditorWidget.gridToData;
var
  itm: TLibraryItem;
  row: TListItem;
begin
  if LibMan = nil then
    exit;
  LibMan.libraries.Clear;
  for row in List.Items do
  begin
    itm := TLibraryItem(LibMan.libraries.Add);
    itm.libAlias := row.Caption;
    itm.libFile := row.SubItems.Strings[0];
    itm.libSourcePath := row.SubItems.Strings[1];
  end;
  LibMan.updateDCD;
end;

end.
