(*                         _
 *   ___  __ _  __ _ _   _(_)
 *  / __|/ _` |/ _` | | | | |
 *  \__ \ (_| | (_| | |_| | |
 *  |___/\__,_|\__, |\__,_|_|
 *             |___/
 *
 *   –– a smart C library which helps you write quickly embedded HTTP servers.
 *
 * Copyright (c) 2012-2018 Silvio Clecio <silvioprog@gmail.com>
 *
 * This file is part of Sagui library.
 *
 * Sagui library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Sagui library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Sagui library.  If not, see <http://www.gnu.org/licenses/>.
 *)

{ Cross-platform low-level Pascal binding for the Sagui library. }

unit libsagui;

{$I libsagui.inc}

interface

uses
  SysUtils,
  StrUtils,
{$IFDEF FPC}
 {$IF DEFINED(UNIX)}
  UnixType,
 {$ELSEIF DEFINED(MSWINDOWS)}
  Windows,
 {$ENDIF}
  DynLibs,
{$ELSE}
 {$IF DEFINED(MSWINDOWS)}
  Winapi.Windows
 {$ELSEIF DEFINED(POSIX)}
  Posix.Dlfcn,
  Posix.SysTypes
 {$ENDIF},
{$ENDIF}
  SyncObjs;

const
{$IFDEF FPC}
 {$IFDEF VER3_0}
  NilHandle = DynLibs.NilHandle;
 {$ENDIF}
{$ELSE}
  NilHandle = HMODULE(0);
{$ENDIF}

{$IF (NOT DEFINED(FPC)) OR DEFINED(VER3_0)}
  SharedSuffix =
 {$IF DEFINED(MSWINDOWS)}
    'dll'
 {$ELSEIF DEFINED(MACOS)}
    'dylib'
 {$ELSE}
    'so'
 {$ENDIF};
{$ENDIF}

  SG_LIB_NAME = Concat(
{$IFDEF MSWINDOWS}
    'libsagui-0'
{$ELSE}
    'libsagui'
{$ENDIF}, '.', SharedSuffix);

resourcestring
  SSgLibraryNotLoaded = 'Library ''%s'' not loaded';
  SSgLibrarySymbolNotFound = 'Symbol ''%s'' not found';
{$IFDEF MSWINDOWS}
  SSgInvalidLibrary = 'Invalid library ''%s''';
{$ENDIF}

type
  Pcchar = MarshaledAString;
{$IF DEFINED(MSWINDOWS)}
  cbool = {$IFNDEF FPC}Winapi.{$ENDIF}Windows.BOOL;
  cuint16_t = UInt16;
  cint = {$IFNDEF FPC}Winapi.{$ENDIF}Windows.LONG;
  cuint = {$IFNDEF FPC}Winapi.{$ENDIF}Windows.UINT;
  cuint64_t = {$IFNDEF FPC}Winapi.{$ENDIF}Windows.ULONG64;
  csize_t = {$IFDEF FPC}System{$ELSE}Winapi.Windows{$ENDIF}.SIZE_T;
  cssize_t = {$IFDEF FPC}NativeInt{$ELSE}Winapi.Windows.SSIZE_T{$ENDIF};
  ctime_t = NativeUInt;
{$ELSEIF DEFINED(POSIX)}
  cbool = LongBool;
  cuint16_t = UInt16;
  cint = Integer;
  cuint = Cardinal;
  cuint64_t = UInt64;
  csize_t = Posix.SysTypes.size_t;
  cssize_t = Posix.SysTypes.ssize_t;
  ctime_t = Posix.SysTypes.time_t;
{$ELSEIF DEFINED(UNIX)}
  cbool = UnixType.cbool;
  cuint16_t = UnixType.cuint16;
  cint = UnixType.cint;
  cuint = UnixType.cuint;
  cuint64_t = UnixType.cuint64;
  csize_t = UnixType.size_t;
  cssize_t = UnixType.ssize_t;
  ctime_t = UnixType.time_t;
{$ELSE}
  cbool = LongBool;
  cuint16_t = UInt16;
  cint = Integer;
  cuint = Cardinal;
  cuint64_t = UInt64;
  csize_t = NativeUInt;
  cssize_t = NativeInt;
  ctime_t = NativeUInt;
{$ENDIF}
  Pcvoid = Pointer;
  PPcvoid = PPointer;
  cenum = cint;
  cva_list = Pointer;

{$IFDEF FPC}
 {$PACKRECORDS C}
 {$IFDEF VER3_0}
  TLibHandle = DynLibs.TLibHandle;
 {$ENDIF}
{$ELSE}
  TLibHandle = HMODULE;
{$ENDIF}

  ESgLibraryNotLoaded = class(EFileNotFoundException);

  ESgLibrarySymbolNotFound = class(EInvalidPointer);

type
  sg_err_cb = procedure(cls: Pcvoid; const err: Pcchar); cdecl;

  sg_write_cb = function(handle: Pcvoid; offset: cuint64_t; const buf: Pcchar;
    size: csize_t): csize_t; cdecl;

  sg_read_cb = function(handle: Pcvoid; offset: cuint64_t; buf: Pcchar;
    size: csize_t): cssize_t; cdecl;

  sg_free_cb = procedure(handle: Pcvoid); cdecl;

  sg_save_cb = function(handle: Pcvoid; overwritten: cbool): cint; cdecl;

  sg_save_as_cb = function(handle: Pcvoid; const path: Pcchar;
    overwritten: cbool): cint; cdecl;

var
  sg_version: function: cuint; cdecl;
  sg_version_str: function: Pcchar; cdecl;
  sg_alloc: function(size: csize_t): Pcvoid; cdecl;
  sg_free: procedure(ptr: Pcvoid); cdecl;
  sg_strerror: function(errnum: cint; buf: Pcchar; len: csize_t): Pcchar; cdecl;
  sg_is_post: function(const method: Pcchar): cbool; cdecl;
  sg_tmpdir: function: Pcchar; cdecl;

type
  Psg_str = ^sg_str;
  sg_str = record
  end;

var
  sg_str_new: function: Psg_str; cdecl;
  sg_str_free: procedure(str: Psg_str); cdecl;
  sg_str_write: function(str: Psg_str; const val: Pcchar;
    len: csize_t): cint; cdecl;
  sg_str_printf_va: function(str: Psg_str; const fmt: Pcchar;
    ap: cva_list): cint; cdecl;
  sg_str_printf: function(str: Psg_str; const fmt: Pcchar): cint; cdecl varargs;
  sg_str_content: function(str: Psg_str): Pcchar; cdecl;
  sg_str_length: function(str: Psg_str): csize_t; cdecl;
  sg_str_clear: function(str: Psg_str): cint; cdecl;

type
  PPsg_strmap = ^Psg_strmap;
  Psg_strmap = ^sg_strmap;
  sg_strmap = record
  end;

  sg_strmap_iter_cb = function(cls: Pcvoid; pair: Psg_strmap): cint; cdecl;

  sg_strmap_sort_cb = function(cls: Pcvoid; pair_a: Psg_strmap;
    pair_b: Psg_strmap): cint; cdecl;

var
  sg_strmap_name: function(pair: Psg_strmap): Pcchar; cdecl;
  sg_strmap_val: function(pair: Psg_strmap): Pcchar; cdecl;
  sg_strmap_add: function(map: PPsg_strmap; const name: Pcchar;
    const val: Pcchar): cint; cdecl;
  sg_strmap_set: function(map: PPsg_strmap; const name: Pcchar;
    const val: Pcchar): cint; cdecl;
  sg_strmap_find: function(map: Psg_strmap; const name: Pcchar;
    pair: PPsg_strmap): cint; cdecl;
  sg_strmap_get: function(map: Psg_strmap; const name: Pcchar): Pcchar; cdecl;
  sg_strmap_rm: function(map: PPsg_strmap; const name: Pcchar): cint; cdecl;
  sg_strmap_iter: function(map: Psg_strmap; cb: sg_strmap_iter_cb;
    cls: Pcvoid): cint; cdecl;
  sg_strmap_sort: function(map: PPsg_strmap; cb: sg_strmap_sort_cb;
    cls: Pcvoid): cint; cdecl;
  sg_strmap_count: function(map: Psg_strmap): cuint; cdecl;
  sg_strmap_next: function(next: PPsg_strmap): cint; cdecl;
  sg_strmap_cleanup: procedure(map: PPsg_strmap); cdecl;

type
  Psg_httpauth = ^sg_httpauth;
  sg_httpauth = record
  end;

  PPsg_httpupld = ^Psg_httpupld;
  Psg_httpupld = ^sg_httpupld;
  sg_httpupld = record
  end;

  Psg_httpreq = ^sg_httpreq;
  sg_httpreq = record
  end;

  Psg_httpres = ^sg_httpres;
  sg_httpres = record
  end;

  Psg_httpsrv = ^sg_httpsrv;
  sg_httpsrv = record
  end;

type
  sg_httpauth_cb = function(cls: Pcvoid; auth: Psg_httpauth; req: Psg_httpreq;
    res: Psg_httpres): cbool; cdecl;

  sg_httpupld_cb = function(cls: Pcvoid; handle: PPcvoid; const dir: Pcchar;
    const field: Pcchar; const name: Pcchar; const mime: Pcchar;
    const encoding: Pcchar): cint; cdecl;

  sg_httpuplds_iter_cb = function(cls: Pcvoid; upld: Psg_httpupld): cint; cdecl;

  sg_httpreq_cb = procedure(cls: Pcvoid; req: Psg_httpreq;
    res: Psg_httpres); cdecl;

var
  sg_httpauth_set_realm: function(auth: Psg_httpauth;
    const realm: Pcchar): cint; cdecl;
  sg_httpauth_realm: function(auth: Psg_httpauth): pcchar; cdecl;
  sg_httpauth_deny: function(auth: Psg_httpauth; const justification: Pcchar;
    const content_type: Pcchar): cint; cdecl;
  sg_httpauth_cancel: function(auth: Psg_httpauth): cint; cdecl;
  sg_httpauth_usr: function(auth: Psg_httpauth): Pcchar; cdecl;
  sg_httpauth_pwd: function(auth: Psg_httpauth): Pcchar; cdecl;

  sg_httpuplds_iter: function(uplds: Psg_httpupld; cb: sg_httpuplds_iter_cb;
    cls: Pcvoid): cint; cdecl;
  sg_httpuplds_next: function(upld: PPsg_httpupld): cint; cdecl;
  sg_httpuplds_count: function(uplds: Psg_httpupld): cint; cdecl;

  sg_httpupld_handle: function(uplds: Psg_httpupld): Pcvoid; cdecl;
  sg_httpupld_dir: function(uplds: Psg_httpupld): Pcchar; cdecl;
  sg_httpupld_field: function(uplds: Psg_httpupld): Pcchar; cdecl;
  sg_httpupld_name: function(uplds: Psg_httpupld): Pcchar; cdecl;
  sg_httpupld_mime: function(uplds: Psg_httpupld): Pcchar; cdecl;
  sg_httpupld_encoding: function(uplds: Psg_httpupld): Pcchar; cdecl;
  sg_httpupld_size: function(uplds: Psg_httpupld): cuint64_t; cdecl;
  sg_httpupld_save: function(upld: Psg_httpupld;
    overwritten: cbool): cint; cdecl;
  sg_httpupld_save_as: function(upld: Psg_httpupld; const path: Pcchar;
    overwritten: cbool): cint; cdecl;

  sg_httpreq_headers: function(req: Psg_httpreq): PPsg_strmap; cdecl;
  sg_httpreq_cookies: function(req: Psg_httpreq): PPsg_strmap; cdecl;
  sg_httpreq_params: function(req: Psg_httpreq): PPsg_strmap; cdecl;
  sg_httpreq_fields: function(req: Psg_httpreq): PPsg_strmap; cdecl;
  sg_httpreq_version: function(req: Psg_httpreq): Pcchar; cdecl;
  sg_httpreq_method: function(req: Psg_httpreq): Pcchar; cdecl;
  sg_httpreq_path: function(req: Psg_httpreq): Pcchar; cdecl;
  sg_httpreq_payload: function(req: Psg_httpreq): Psg_str; cdecl;
  sg_httpreq_uploading: function(req: Psg_httpreq): cbool; cdecl;
  sg_httpreq_uploads: function(req: Psg_httpreq): Psg_httpupld; cdecl;
  sg_httpreq_set_user_data: function(req: Psg_httpreq;
    data: Pcvoid): cint; cdecl;
  sg_httpreq_user_data: function(req: Psg_httpreq): Pcvoid; cdecl;

  sg_httpres_headers: function(res: Psg_httpres): PPsg_strmap; cdecl;
  sg_httpres_set_cookie: function(res: Psg_httpres; const name: Pcchar;
    const val: Pcchar): cint; cdecl;
  sg_httpres_sendbinary: function(res: Psg_httpres; buf: Pcvoid; size: size_t;
    const content_type: Pcchar; status: cuint): cint; cdecl;
  sg_httpres_sendfile: function(res: Psg_httpres; block_size: csize_t;
    max_size: cuint64_t; const filename: Pcchar; rendered: cbool;
    status: cuint): cint; cdecl;
  sg_httpres_sendstream: function(res: Psg_httpres; size: cuint64_t;
    block_size: csize_t; read_cb: sg_read_cb; handle: Pcvoid;
    flush_cb: sg_free_cb; status: cuint): cint; cdecl;

  sg_httpsrv_new2: function(auth_cb: sg_httpauth_cb; auth_cls: Pcvoid;
    req_cb: sg_httpreq_cb; req_cls: Pcvoid; err_cb: sg_err_cb;
    err_cls: Pcvoid): Psg_httpsrv; cdecl;
  sg_httpsrv_new: function(cb: sg_httpreq_cb; cls: Pcvoid): Psg_httpsrv; cdecl;
  sg_httpsrv_free: procedure(srv: Psg_httpsrv); cdecl;
  sg_httpsrv_listen: function(srv: Psg_httpsrv; port: cuint16_t;
    threaded: cbool): cbool; cdecl;
  sg_httpsrv_tls_listen: function(srv: Psg_httpsrv; const key: Pcchar;
    const cert: Pcchar; port: cuint16_t; threaded: cbool): cbool; cdecl;
  sg_httpsrv_shutdown: function(srv: Psg_httpsrv): cint; cdecl;
  sg_httpsrv_port: function(srv: Psg_httpsrv): cuint16_t; cdecl;
  sg_httpsrv_threaded: function(srv: Psg_httpsrv): cbool; cdecl;
  sg_httpsrv_set_upld_cbs: function(srv: Psg_httpsrv; cb: sg_httpupld_cb;
    cls: Pcvoid; write_cb: sg_write_cb; free_cb: sg_free_cb;
    save_cb: sg_save_cb; save_as_cb: sg_save_as_cb): cint; cdecl;
  sg_httpsrv_set_upld_dir: function(srv: Psg_httpsrv;
    const dir: Pcchar): cint; cdecl;
  sg_httpsrv_upld_dir: function(srv: Psg_httpsrv): Pcchar; cdecl;
  sg_httpsrv_set_post_buf_size: function(srv: Psg_httpsrv;
    size: csize_t): cint; cdecl;
  sg_httpsrv_post_buf_size: function(srv: Psg_httpsrv): csize_t; cdecl;
  sg_httpsrv_set_payld_limit: function(srv: Psg_httpsrv;
    limit: csize_t): cint; cdecl;
  sg_httpsrv_payld_limit: function(srv: Psg_httpsrv): csize_t; cdecl;
  sg_httpsrv_set_uplds_limit: function(srv: Psg_httpsrv;
    limit: cuint64_t): cint; cdecl;
  sg_httpsrv_uplds_limit: function(srv: Psg_httpsrv): cuint64_t; cdecl;
  sg_httpsrv_set_thr_pool_size: function(srv: Psg_httpsrv;
    size: cuint): cint; cdecl;
  sg_httpsrv_thr_pool_size: function(srv: Psg_httpsrv): cuint; cdecl;
  sg_httpsrv_set_con_timeout: function(srv: Psg_httpsrv;
    timeout: cuint): cint; cdecl;
  sg_httpsrv_con_timeout: function(srv: Psg_httpsrv): cuint; cdecl;
  sg_httpsrv_set_con_limit: function(srv: Psg_httpsrv;
    limit: cuint): cint; cdecl;
  sg_httpsrv_con_limit: function(srv: Psg_httpsrv): cuint; cdecl;

  sg_httpread_end: function(err: cbool): cssize_t; cdecl;

{ TODO: procedure SgAddUnloadLibraryProc }
function SgLoadLibrary(const AFileName: TFileName): TLibHandle;
function SgUnloadLibrary: TLibHandle;
procedure SgCheckLibrary;
procedure SgCheckLastError(ALastError: Integer);

implementation

var
  GSgLock: TCriticalSection = nil;
  GSgLibHandle: TLibHandle = NilHandle;
  GSgLastLibName: TFileName = SG_LIB_NAME;

function SgLoadLibrary(const AFileName: TFileName): TLibHandle;
begin
  GSgLock.Acquire;
  try
    if (GSgLibHandle <> NilHandle) or (AFileName = '') then
      Exit(GSgLibHandle);
    GSgLibHandle := SafeLoadLibrary(AFileName);
    if GSgLibHandle = NilHandle then
{$IFDEF MSWINDOWS}
      if GetLastError = ERROR_BAD_EXE_FORMAT then
      begin
        MessageBox(0, PChar(Format(SSgInvalidLibrary, [AFileName])), nil,
          MB_OK or MB_ICONERROR);
        Halt;
      end;
{$ELSE}
      Exit(NilHandle);
{$ENDIF}
    { TODO: check the library version }
    GSgLastLibName := AFileName;

    sg_version := GetProcAddress(GSgLibHandle, 'sg_version');
    sg_version_str := GetProcAddress(GSgLibHandle, 'sg_version_str');
    sg_alloc := GetProcAddress(GSgLibHandle, 'sg_alloc');
    sg_free := GetProcAddress(GSgLibHandle, 'sg_free');
    sg_strerror := GetProcAddress(GSgLibHandle, 'sg_strerror');
    sg_is_post := GetProcAddress(GSgLibHandle, 'sg_is_post');
    sg_tmpdir := GetProcAddress(GSgLibHandle, 'sg_tmpdir');

    sg_str_new := GetProcAddress(GSgLibHandle, 'sg_str_new');
    sg_str_free := GetProcAddress(GSgLibHandle, 'sg_str_free');
    sg_str_write := GetProcAddress(GSgLibHandle, 'sg_str_write');
    sg_str_printf_va := GetProcAddress(GSgLibHandle, 'sg_str_printf_va');
    sg_str_printf := GetProcAddress(GSgLibHandle, 'sg_str_printf');
    sg_str_content := GetProcAddress(GSgLibHandle, 'sg_str_content');
    sg_str_length := GetProcAddress(GSgLibHandle, 'sg_str_length');
    sg_str_clear := GetProcAddress(GSgLibHandle, 'sg_str_clear');

    sg_strmap_name := GetProcAddress(GSgLibHandle, 'sg_strmap_name');
    sg_strmap_val := GetProcAddress(GSgLibHandle, 'sg_strmap_val');
    sg_strmap_add := GetProcAddress(GSgLibHandle, 'sg_strmap_add');
    sg_strmap_set := GetProcAddress(GSgLibHandle, 'sg_strmap_set');
    sg_strmap_find := GetProcAddress(GSgLibHandle, 'sg_strmap_find');
    sg_strmap_get := GetProcAddress(GSgLibHandle, 'sg_strmap_get');
    sg_strmap_rm := GetProcAddress(GSgLibHandle, 'sg_strmap_rm');
    sg_strmap_iter := GetProcAddress(GSgLibHandle, 'sg_strmap_iter');
    sg_strmap_sort := GetProcAddress(GSgLibHandle, 'sg_strmap_sort');
    sg_strmap_count := GetProcAddress(GSgLibHandle, 'sg_strmap_count');
    sg_strmap_next := GetProcAddress(GSgLibHandle, 'sg_strmap_next');
    sg_strmap_cleanup := GetProcAddress(GSgLibHandle, 'sg_strmap_cleanup');

    sg_httpauth_set_realm := GetProcAddress(GSgLibHandle, 'sg_httpauth_set_realm');
    sg_httpauth_realm := GetProcAddress(GSgLibHandle, 'sg_httpauth_realm');
    sg_httpauth_deny := GetProcAddress(GSgLibHandle, 'sg_httpauth_deny');
    sg_httpauth_cancel := GetProcAddress(GSgLibHandle, 'sg_httpauth_cancel');
    sg_httpauth_usr := GetProcAddress(GSgLibHandle, 'sg_httpauth_usr');
    sg_httpauth_pwd := GetProcAddress(GSgLibHandle, 'sg_httpauth_pwd');

    sg_httpuplds_iter := GetProcAddress(GSgLibHandle, 'sg_httpuplds_iter');
    sg_httpuplds_next := GetProcAddress(GSgLibHandle, 'sg_httpuplds_next');
    sg_httpuplds_count := GetProcAddress(GSgLibHandle, '');

    sg_httpupld_handle := GetProcAddress(GSgLibHandle, 'sg_httpupld_handle');
    sg_httpupld_dir := GetProcAddress(GSgLibHandle, 'sg_httpupld_dir');
    sg_httpupld_field := GetProcAddress(GSgLibHandle, 'sg_httpupld_field');
    sg_httpupld_name := GetProcAddress(GSgLibHandle, 'sg_httpupld_name');
    sg_httpupld_mime := GetProcAddress(GSgLibHandle, 'sg_httpupld_mime');
    sg_httpupld_encoding := GetProcAddress(GSgLibHandle, 'sg_httpupld_encoding');
    sg_httpupld_size := GetProcAddress(GSgLibHandle, 'sg_httpupld_size');
    sg_httpupld_save := GetProcAddress(GSgLibHandle, 'sg_httpupld_save');
    sg_httpupld_save_as := GetProcAddress(GSgLibHandle, 'sg_httpupld_save_as');

    sg_httpreq_headers := GetProcAddress(GSgLibHandle, 'sg_httpreq_headers');
    sg_httpreq_cookies := GetProcAddress(GSgLibHandle, 'sg_httpreq_cookies');
    sg_httpreq_params := GetProcAddress(GSgLibHandle, 'sg_httpreq_params');
    sg_httpreq_fields := GetProcAddress(GSgLibHandle, 'sg_httpreq_fields');
    sg_httpreq_version := GetProcAddress(GSgLibHandle, 'sg_httpreq_version');
    sg_httpreq_method := GetProcAddress(GSgLibHandle, 'sg_httpreq_method');
    sg_httpreq_path := GetProcAddress(GSgLibHandle, 'sg_httpreq_path');
    sg_httpreq_payload := GetProcAddress(GSgLibHandle, 'sg_httpreq_payload');
    sg_httpreq_uploading := GetProcAddress(GSgLibHandle, 'sg_httpreq_uploading');
    sg_httpreq_uploads := GetProcAddress(GSgLibHandle, 'sg_httpreq_uploads');
    sg_httpreq_set_user_data := GetProcAddress(GSgLibHandle, 'sg_httpreq_set_user_data');
    sg_httpreq_user_data := GetProcAddress(GSgLibHandle, 'sg_httpreq_user_data');

    sg_httpres_headers := GetProcAddress(GSgLibHandle, 'sg_httpres_headers');
    sg_httpres_set_cookie := GetProcAddress(GSgLibHandle, 'sg_httpres_set_cookie');
    sg_httpres_sendbinary := GetProcAddress(GSgLibHandle, 'sg_httpres_sendbinary');
    sg_httpres_sendfile := GetProcAddress(GSgLibHandle, 'sg_httpres_sendfile');
    sg_httpres_sendstream := GetProcAddress(GSgLibHandle, 'sg_httpres_sendstream');

    sg_httpsrv_new2 := GetProcAddress(GSgLibHandle, 'sg_httpsrv_new2');
    sg_httpsrv_new := GetProcAddress(GSgLibHandle, 'sg_httpsrv_new');
    sg_httpsrv_free := GetProcAddress(GSgLibHandle, 'sg_httpsrv_free');
    sg_httpsrv_listen := GetProcAddress(GSgLibHandle, 'sg_httpsrv_listen');
    sg_httpsrv_tls_listen := GetProcAddress(GSgLibHandle, 'sg_httpsrv_tls_listen');
    sg_httpsrv_shutdown := GetProcAddress(GSgLibHandle, 'sg_httpsrv_shutdown');
    sg_httpsrv_port := GetProcAddress(GSgLibHandle, 'sg_httpsrv_port');
    sg_httpsrv_threaded := GetProcAddress(GSgLibHandle, 'sg_httpsrv_threaded');
    sg_httpsrv_set_upld_cbs := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_upld_cbs');
    sg_httpsrv_set_upld_dir := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_upld_dir');
    sg_httpsrv_upld_dir := GetProcAddress(GSgLibHandle, 'sg_httpsrv_upld_dir');
    sg_httpsrv_set_post_buf_size := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_post_buf_size');
    sg_httpsrv_post_buf_size := GetProcAddress(GSgLibHandle, 'sg_httpsrv_post_buf_size');
    sg_httpsrv_set_payld_limit := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_payld_limit');
    sg_httpsrv_payld_limit := GetProcAddress(GSgLibHandle, 'sg_httpsrv_payld_limit');
    sg_httpsrv_set_uplds_limit := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_uplds_limit');
    sg_httpsrv_uplds_limit := GetProcAddress(GSgLibHandle, 'sg_httpsrv_uplds_limit');
    sg_httpsrv_set_thr_pool_size := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_thr_pool_size');
    sg_httpsrv_thr_pool_size := GetProcAddress(GSgLibHandle, 'sg_httpsrv_thr_pool_size');
    sg_httpsrv_set_con_timeout := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_con_timeout');
    sg_httpsrv_con_timeout := GetProcAddress(GSgLibHandle, 'sg_httpsrv_con_timeout');
    sg_httpsrv_set_con_limit := GetProcAddress(GSgLibHandle, 'sg_httpsrv_set_con_limit');
    sg_httpsrv_con_limit := GetProcAddress(GSgLibHandle, 'sg_httpsrv_con_limit');

    sg_httpread_end := GetProcAddress(GSgLibHandle, 'sg_httpread_end');

    Result := GSgLibHandle;
  finally
    GSgLock.Release;
  end;
end;

function SgUnloadLibrary: TLibHandle;
begin
  GSgLock.Acquire;
  try
    if GSgLibHandle = NilHandle then
      Exit(NilHandle);
    if not FreeLibrary(GSgLibHandle) then
      Exit(GSgLibHandle);
    GSgLibHandle := NilHandle;
    GSgLastLibName := '';

    sg_version := nil;
    sg_version_str := nil;
    sg_alloc := nil;
    sg_free := nil;
    sg_strerror := nil;
    sg_is_post := nil;
    sg_tmpdir := nil;

    sg_str_new := nil;
    sg_str_free := nil;
    sg_str_write := nil;
    sg_str_printf_va := nil;
    sg_str_printf := nil;
    sg_str_content := nil;
    sg_str_length := nil;
    sg_str_clear := nil;

    sg_strmap_name := nil;
    sg_strmap_val := nil;
    sg_strmap_add := nil;
    sg_strmap_set := nil;
    sg_strmap_find := nil;
    sg_strmap_get := nil;
    sg_strmap_rm := nil;
    sg_strmap_iter := nil;
    sg_strmap_sort := nil;
    sg_strmap_count := nil;
    sg_strmap_next := nil;
    sg_strmap_cleanup := nil;

    sg_httpauth_set_realm := nil;
    sg_httpauth_realm := nil;
    sg_httpauth_deny := nil;
    sg_httpauth_cancel := nil;
    sg_httpauth_usr := nil;
    sg_httpauth_pwd := nil;

    sg_httpuplds_iter := nil;
    sg_httpuplds_next := nil;
    sg_httpuplds_count := nil;

    sg_httpupld_handle := nil;
    sg_httpupld_dir := nil;
    sg_httpupld_field := nil;
    sg_httpupld_name := nil;
    sg_httpupld_mime := nil;
    sg_httpupld_encoding := nil;
    sg_httpupld_size := nil;
    sg_httpupld_save := nil;
    sg_httpupld_save_as := nil;

    sg_httpreq_headers := nil;
    sg_httpreq_cookies := nil;
    sg_httpreq_params := nil;
    sg_httpreq_fields := nil;
    sg_httpreq_version := nil;
    sg_httpreq_method := nil;
    sg_httpreq_path := nil;
    sg_httpreq_payload := nil;
    sg_httpreq_uploading := nil;
    sg_httpreq_uploads := nil;
    sg_httpreq_set_user_data := nil;
    sg_httpreq_user_data := nil;

    sg_httpres_headers := nil;
    sg_httpres_set_cookie := nil;
    sg_httpres_sendbinary := nil;
    sg_httpres_sendfile := nil;
    sg_httpres_sendstream := nil;

    sg_httpsrv_new2 := nil;
    sg_httpsrv_new := nil;
    sg_httpsrv_free := nil;
    sg_httpsrv_listen := nil;
    sg_httpsrv_tls_listen := nil;
    sg_httpsrv_shutdown := nil;
    sg_httpsrv_port := nil;
    sg_httpsrv_threaded := nil;
    sg_httpsrv_set_upld_cbs := nil;
    sg_httpsrv_set_upld_dir := nil;
    sg_httpsrv_upld_dir := nil;
    sg_httpsrv_set_post_buf_size := nil;
    sg_httpsrv_post_buf_size := nil;
    sg_httpsrv_set_payld_limit := nil;
    sg_httpsrv_payld_limit := nil;
    sg_httpsrv_set_uplds_limit := nil;
    sg_httpsrv_uplds_limit := nil;
    sg_httpsrv_set_thr_pool_size := nil;
    sg_httpsrv_thr_pool_size := nil;
    sg_httpsrv_set_con_timeout := nil;
    sg_httpsrv_con_timeout := nil;
    sg_httpsrv_set_con_limit := nil;
    sg_httpsrv_con_limit := nil;

    sg_httpread_end := nil;

    Result := GSgLibHandle;
  finally
    GSgLock.Release;
  end;
end;

procedure SgCheckLibrary;
begin
  if GSgLibHandle = NilHandle then
    raise ESgLibraryNotLoaded.CreateResFmt(@SSgLibraryNotLoaded,
      [IfThen(GSgLastLibName = '', SG_LIB_NAME, GSgLastLibName)]);
end;

procedure SgCheckLastError(ALastError: Integer);
const
  BUF_LEN = 256;
var
  S: RawByteString;
  P: MarshaledAString;
begin
  if (ALastError = 0) or (not Assigned(sg_strerror)) then
    Exit;
  GetMem(P, BUF_LEN);
  try
    sg_strerror(ALastError, P, BUF_LEN);
    SetString(S, P, Length(P) - SizeOf(Byte));
    SetCodePage(RawByteString(S), CP_UTF8, False);
    raise EOSError.Create(string(S));
  finally
    FreeMem(P, BUF_LEN);
  end;
end;

initialization
  GSgLock := TCriticalSection.Create;
  SgLoadLibrary(SG_LIB_NAME);

finalization
  SgUnloadLibrary;
  FreeAndNil(GSgLock);

end.