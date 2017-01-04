--アドオン名（大文字）
local addonName = "TEMPLATE";
local addonNameLower = string.lower(addonName);
--作者名
local author = "AUTHOR";

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][author] = _G["ADDONS"][author] or {};
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {};
local g = _G["ADDONS"][author][addonName];

--設定ファイル保存先
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

--ライブラリ読み込み
local acutil = require('acutil');

--デフォルト設定
if not g.loaded then
  g.settings = {
    --有効/無効
    enable = true,
    --フレーム表示場所
    position = {
      x = 0,
      y = 0
    }
  };
end

--lua読み込み時のメッセージ
CHAT_SYSTEM(string.format("%s.lua is loaded", addonName));

function TEMPLATE_SAVESETTINGS()
  acutil.saveJSON(g.settingsFileLoc, g.settings);
end


--マップ読み込み時処理（1度だけ）
function TEMPLATE_ON_INIT(addon, frame)
  g.addon = addon;
  g.frame = frame;

  frame:ShowWindow(0);
  --acutil.slashCommand("/"..addonNameLower, TEMPLATE_PROCESS_COMMAND);
  if not g.loaded then
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
    if err then
      --設定ファイル読み込み失敗時処理
      CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName));
    else
      --設定ファイル読み込み成功時処理
      g.settings = t;
    end
    g.loaded = true;
  end

  --設定ファイル保存処理
  TEMPLATE_SAVESETTINGS();
  --メッセージ受信登録処理
  --addon:RegisterMsg("メッセージ", "内部処理");

  --コンテキストメニュー
  frame:SetEventScript(ui.RBUTTONDOWN, "TEMPLATE_CONTEXT_MENU");
  --ドラッグ
  frame:SetEventScript(ui.LBUTTONUP, "TEMPLATE_END_DRAG");

  --フレーム初期化処理
  TEMPLATE_INIT_FRAME(frame);

  --再表示処理
  if g.settings.enable then
    frame:ShowWindow(1);
  else
    frame:ShowWindow(0);
  end
  --Moveではうまくいかないので、OffSetを使用する…
  frame:Move(0, 0);
  frame:SetOffset(g.settings.position.x, g.settings.position.y);
end

function TEMPLATE_INIT_FRAME(frame)
  --XMLに記載するとデザイン調整時にクライアント再起動が必要になるため、luaに書き込むことをオススメする
  --フレーム初期化処理
  local text = frame:CreateOrGetControl("richtext", "text", 0, 0, 0, 0);
  text:SetText(addonName);
end

--コンテキストメニュー表示処理
function TEMPLATE_CONTEXT_MENU(frame, msg, clickedGroupName, argNum)
  local context = ui.CreateContextMenu("TEMPLATE_RBTN", "Template", 0, 0, 300, 100);
  ui.AddContextMenuItem(context, "Hide", "TEMPLATE_TOGGLE_FRAME()");
  context:Resize(300, context:GetHeight());
  ui.OpenContextMenu(context);
end

--表示非表示切り替え処理
function TEMPLATE_TOGGLE_FRAME()
  if g.frame:IsVisible() == 0 then
    --非表示->表示
    g.frame:ShowWindow(1);
    g.settings.enable = true;
  else
    --表示->非表示
    g.frame:ShowWindow(0);
    g.settings.show = false;
  end

  TEMPLATE_SAVESETTINGS();
end

--フレーム場所保存処理
function TEMPLATE_END_DRAG()
  g.settings.position.x = g.frame:GetX();
  g.settings.position.y = g.frame:GetY();
  TEMPLATE_SAVESETTINGS();
end

--チャットコマンド処理（acutil使用時）
function TEMPLATE_PROCESS_COMMAND(command)
  local cmd = "";

  if #command > 0 then
    cmd = table.remove(command, 1);
  else
    local msg = "ヘルプメッセージなど"
    return ui.MsgBox(msg,"","Nope")
  end

  if cmd == "on" then
    --有効
    g.settings.enable = true;
    CHAT_SYSTEM(string.format("[%s] is enable", addonName));
    TEMPLATE_SAVESETTINGS();
    return;
  elseif cmd == "off" then
    --無効
    g.settings.enable = false;
    CHAT_SYSTEM(string.format("[%s] is disable", addonName));
    TEMPLATE_SAVESETTINGS();
    return;
  end
  CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
end

