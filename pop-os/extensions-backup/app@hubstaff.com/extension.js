/* exported init */

/*
 * Hubstaff GNOME Shell extension for Application Tracing.
 * (C) Netsoft 2022
 * Licsense: GNU GPLv2+
 */
const { GLib, Gio, Shell } = imports.gi;

function get_active(app) {
    let windows = app.get_windows();
    for (let j = 0; j < windows.length; ++j) {
        if (windows[j].appears_focused) {
            let info = app.get_app_info();
            let exec = "";
            if (info !== null) {
                // NOTE: get_executable() will return "the first word in an exec line (ie: the binary name)."
                //    This also means that it will return the "parent" executable in some cases, i.e. when a program is called via env:
                //    `env SET_FOO=foo chromium` will return `env` instead of `chromium`
                exec = info.get_executable();
            }
            else {
                // It's not well documented how is this possible.
                // We are returning a PID, so, caller can maybe
                // get some info from it...
            }
            return {
                name: app.get_name(),
                executable: exec,
                title: windows[j].title,
                pid: app.get_pids()[0]
            };
        }
    }
    return null;
}

function find_active_app() {
    const none = { name: "", executable: "", title: "", pid: 0 };
    let app_info = null;
    let fapp = Shell.WindowTracker.get_default().focus_app;
    if (fapp) {
        app_info = get_active(fapp);
    }
    else {
        // We probably don't need this, but let's be paranoid for now...
        log("window tracker shows no focused app... let's check");
        let apps = Shell.AppSystem.get_default().get_running();
        for (let i = 0; (i < apps.length) && (app_info === null); ++i) {
            app_info = get_active(apps[i]);
        }
    }
    if (app_info === null) {
        app_info = none;
    }
    return app_info;
}

const ifaceXml = `
<node>
  <interface name="com.hubstaff.app">
    <method name="GetActiveWindowTitle">
      <arg type="s" direction="out" name="title"/>
    </method>
    <method name="GetActiveApp">
      <arg type="s" direction="out" name="name"/>
      <arg type="s" direction="out" name="executable"/>
      <arg type="s" direction="out" name="title"/>
      <arg type="x" direction="out" name="pid"/>
    </method>
    <method name="Screenshot">
      <arg type="s" direction="in" name="path"/>
      <arg type="s" direction="out" name="result"/>
    </method>
  </interface>
</node>`;

class Service {
    constructor() {
        this.dbus = Gio.DBusExportedObject.wrapJSObject(ifaceXml, this);
    }

    _handleError(invocation, error) {
        if (error === null)
            return false;

        if (error instanceof GLib.Error) {
            invocation.return_gerror(error);
        } else {
            let name = error.name;
            if (!name.includes('.')) // likely a normal JS error
                name = `org.gnome.gjs.JSError.${name}`;
            invocation.return_dbus_error(name, error.message);
        }

        return true;
    }
    
    GetActiveWindowTitle() {
        return find_active_app().title;
    }

    GetActiveApp() {
        let info = find_active_app();
        return [info.name, info.executable, info.title, info.pid];
    }
    
    async ScreenshotAsync(params, invocation) {
		// Depends on Shell API Shell.Screenshot (https://gjs-docs.gnome.org/shell12~12-screenshot/) which may not be stable across versions
		// The screenshot service called by the portal calls the shutter and this API.
        // Using our own "service", allows us to directly call this API, without calling the shutter.
        try {
            const [path] = params;
            const file = Gio.File.new_for_path(path);
            const fileStream = file.create(Gio.FileCreateFlags.NONE, null);

            let promise = new Promise((resolve, reject) => {
                const screenshot = new Shell.Screenshot();
                screenshot.screenshot(false, fileStream, (source_object, res, data) => {
                    const [ok, area] = screenshot.screenshot_finish(res);
                    if (ok)
                        resolve();
                    else
                        reject(new Error("Screenshot failed"));
                });
            });
            await promise;
            invocation.return_value(new GLib.Variant('(s)', [path]));
        } catch (error) {
            this._handleError(invocation, error);
        }
    }
};


function onNameAcquired(connection, name) {
    log("app@hubstaff.com onNameAcquired");
}

function onNameLost(connection, name) {
    log("app@hubstaff.com onNameLost");
}


let serviceObj;
let dbusOwnerId;

const hubstaff_app_extension_path = '/com/hubstaff/app';

class Extension {

    enable() {
        log("app@hubstaff.com enable");

        serviceObj = new Service();
        serviceObj.dbus.export(Gio.DBus.session, hubstaff_app_extension_path);

        dbusOwnerId = Gio.DBus.session.own_name(
          'com.hubstaff.app',
          Gio.BusNameOwnerFlags.NONE,
          onNameAcquired,
          onNameLost
        );
    }

    disable() {
        log("app@hubstaff.com disable");
        Gio.bus_unown_name(dbusOwnerId);
        serviceObj.dbus.unexport();
        serviceObj = null;
    }
}

function init() {
    log("app@hubstaff.com init");
    return new Extension();
}
