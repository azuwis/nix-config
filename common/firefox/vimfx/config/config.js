// example: https://github.com/lydell/dotfiles/blob/master/.vimfx/config.js

const {classes: Cc, interfaces: Ci} = Components
const nsIEnvironment = Cc["@mozilla.org/process/environment;1"].getService(Ci.nsIEnvironment)
const nsIWindowWatcher = Cc["@mozilla.org/embedcomp/window-watcher;1"].getService(Ci.nsIWindowWatcher)
const ioService = Cc["@mozilla.org/network/io-service;1"].getService(Ci.nsIIOService);

const {AddonManager} = ChromeUtils.importESModule('resource://gre/modules/AddonManager.sys.mjs');
const {PopupNotifications} = ChromeUtils.importESModule('resource://gre/modules/PopupNotifications.sys.mjs');
const {Preferences} = ChromeUtils.importESModule('resource://gre/modules/Preferences.sys.mjs');

// helper functions
let {commands} = vimfx.modes.normal

let popup = (message, options) => {
    let window = nsIWindowWatcher.activeWindow
    if(!window)
        return
    let notify  = new PopupNotifications(window.gBrowser,
                                         window.document.getElementById('notification-popup'),
                                         window.document.getElementById('notification-popup-box'))
    let notification =  notify.show(window.gBrowser.selectedBrowser, 'notify',
                                    message, null, options, null, {
                                        popupIconURL: 'chrome://branding/content/icon128.png'
                                    })
    window.setTimeout(() => {
        notification.remove()
    }, 5000)
}

let set = (pref, valueOrFunction) => {
    let value = typeof valueOrFunction === 'function'
        ? valueOrFunction(vimfx.getDefault(pref))
        : valueOrFunction
    vimfx.set(pref, value)
}

let map = (shortcuts, command, custom=false) => {
    vimfx.set(`${custom ? 'custom.' : ''}mode.normal.${command}`, shortcuts)
}

let pathSearch = (bin) => {
    let file = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile)
    let pathListSep = (Services.appinfo.OS == 'WINNT') ? ';' : ':'
    let dirs = nsIEnvironment.get("PATH").split(pathListSep)
    for (let dir of dirs) {
        try {
            file.initWithPath(dir)
            file.appendRelativePath(bin)
            if (file.exists() && file.isFile() && file.isExecutable())
                return file
        } catch (e) {}
    }
    return null
}

let exec = (cmd, args, observer) => {
    let file = pathSearch(cmd)
    let process = Cc['@mozilla.org/process/util;1'].createInstance(Ci.nsIProcess)
    process.init(file)
    process.runAsync(args, args.length, observer)
}

let isUrl = (window, string) => {
    let url
    try {
        url = new window.URL(string)
    } catch (_) {
        return false
    }
    return url.protocol === "http:" || url.protocol === "https:"
}

let getConfigFile = (name) => {
    let file = ioService.newURI(__dirname, null, null).QueryInterface(Ci.nsIFileURL).file;
    file.append(name)
    return file.path
}

// options
set('prevent_autofocus', true)
// set('hints.chars', 'FJDKSLAGHRUEIWONC MV')
set('hints.sleep', -1)
set('prev_patterns', v => `[上前]\\s*一?\\s*[页张个篇章頁] ${v}`)
set('next_patterns', v => `[下后]\\s*一?\\s*[页张个篇章頁] ${v}`)

// shortcuts
map('', 'window_new')
map('q', 'tab_select_previous')
map('w', 'tab_select_next')
map('S', 'stop')

// commands
vimfx.addCommand({
    name: 'search_selected_text_or_open_focused_link',
    description: 'Search for the selected text or open focused link'
}, ({vim}) => {
    vimfx.send(vim, 'getInfo', null, ({href, selection}) => {
        if (selection) {
            if (isUrl(vim.window, selection)) {
                vim.window.switchToTabHavingURI(selection, true)
            } else {
                let {gURLBar} = vim.window
                gURLBar.value = `g ${selection}`
                gURLBar.handleCommand(new vim.window.KeyboardEvent('keydown', {altKey: true}))
            }
        } else if (href) {
            vim.window.switchToTabHavingURI(href, true)
        }
    })
})
map('s', 'search_selected_text_or_open_focused_link', true)

vimfx.addCommand({
    name: 'search_in_yuan',
    description: 'Search in yuan'
}, ({vim}) => {
    vimfx.send(vim, 'getInfo', null, ({selection}) => {
        let {gURLBar} = vim.window
        gURLBar.value = `g ${selection} usd in yuan`
        gURLBar.handleCommand(new vim.window.KeyboardEvent('keydown', {altKey: true}))
    })
})

map(',y', 'search_in_yuan', true)

vimfx.addCommand({
    name: 'goto_addons',
    description: 'Addons',
}, ({vim}) => {
    vim.window.switchToTabHavingURI('about:addons', true)
})
map(',a', 'goto_addons', true)

vimfx.addCommand({
    name: 'goto_config',
    description: 'Config',
}, ({vim}) => {
    vim.window.switchToTabHavingURI('about:config', true)
})
map(',c', 'goto_config', true)

vimfx.addCommand({
    name: 'goto_downloads',
    description: 'Downloads',
}, ({vim}) => {
    // vim.window.switchToTabHavingURI('about:downloads', true)
    vim.window.DownloadsPanel.showDownloadsHistory()
})
map(',d', 'goto_downloads', true)

vimfx.addCommand({
    name: 'goto_preferences',
    description: 'Preferences',
}, ({vim}) => {
    vim.window.openPreferences()
})
map(',s', 'goto_preferences', true)

vimfx.addCommand({
    name: 'mpv_current_href',
    description: 'Mpv play focused href',
}, ({vim}) => {
    let mpv_observer = {
        observe: (subject, topic) => {
            if (subject.exitValue !== 0)
                vim.notify('Mpv: No video')
        }
    }
    vimfx.send(vim, 'getInfo', null, ({href}) => {
        if (href && href.match('^https?://')) {
            let args = ['--profile=pseudo-gui', '--fs', href]
            exec('mpv', args, mpv_observer)
            vim.notify(`Mpv: ${href}`)
        } else {
            vim.notify('Mpv: No link')
        }
    })
})
map('b', 'mpv_current_href', true)

vimfx.addCommand({
    name: 'mpv_current_tab',
    description: 'Mpv play current tab',
}, ({vim}) => {
    let url = vim.window.gBrowser.selectedBrowser.currentURI.spec
    let args = ['--profile=pseudo-gui', '--fs', url]
    exec('mpv', args)
    vim.notify(`Mpv: ${url}`)
})
map(',m', 'mpv_current_tab', true)

vimfx.addCommand({
    name: 'search_tabs',
    description: 'Search tabs',
    category: 'location',
    order: commands.focus_location_bar.order + 1,
}, (args) => {
    commands.focus_location_bar.run(args)
    args.vim.window.gURLBar.value = '% '
})
map(',t', 'search_tabs', true)

vimfx.addCommand({
    name: 'toggle_https',
    description: 'Toggle HTTPS',
    category: 'location',
}, ({vim}) => {
    let url = vim.window.gBrowser.selectedBrowser.currentURI.spec
    if (url.startsWith('http://')) {
        url = url.replace(/^http:\/\//, 'https://')
    } else if (url.startsWith('https://')) {
        url = url.replace(/^https:\/\//, 'http://')
    }
    vim.window.gBrowser.loadURI(url, {triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal()})
})
map('gs', 'toggle_https', true)

vimfx.addCommand({
    name: 'org_capture',
    description: 'Capture the selected text using org-protocol'
}, ({vim}) => {
    vimfx.send(vim, 'getInfo', null, ({title, url, selection}) => {
        let org_url = `org-protocol://capture?template=b&url=${encodeURIComponent(url)}&title=${encodeURIComponent(title)}&body=${encodeURIComponent(selection)}`
        exec('emacsclient', [org_url])
    })
})
map(',b', 'org_capture', true)

let qrcode = (text) => {
    exec('sh', ['-c', `qrencode -o- '${text}' | pqiv -`])
}
vimfx.addCommand({
    name: 'qrcode',
    description: 'QRcode'
}, ({vim}) => {
    let url = vim.window.gBrowser.selectedBrowser.currentURI.spec
    qrcode(url)
})
map(',q', 'qrcode', true)

vimfx.addCommand({
    name: 'restart',
    description: 'Restart',
}, ({vim}) => {
    Services.startup.quit(Services.startup.eRestart | Services.startup.eAttemptQuit)
})
map(',R', 'restart', true)

vimfx.addCommand({
    name: 'ublock_bootstrap',
    description: 'uBlock Bootstrap',
}, ({vim}) => {
    let gBrowser = vim.window.gBrowser
    let url = gBrowser.selectedBrowser.currentURI.spec
    AddonManager.getAddonByID("uBlock0@raymondhill.net").then(ublock => {
        let ublockUrl = `${ublock.optionsURL}#3p-filters.html`
        if (url === ublockUrl) {
            vimfx.send(vim, 'ublockBootstrap', null, () => {
            })
        } else {
            vim.window.switchToTabHavingURI(ublockUrl, true)
        }
    })
})
map(',u', 'ublock_bootstrap', true)

let bootstrap = () => {
    // set font for different OSes
    switch (Services.appinfo.OS) {
    case 'Darwin':
        Preferences.set('font.name.monospace.x-western', 'Menlo')
        break
    case 'WINNT':
        Preferences.set('font.name.monospace.zh-CN', 'Consolas')
        Preferences.set('font.name.sans-serif.zh-CN', '微软雅黑')
        Preferences.set('font.name.serif.zh-CN', '微软雅黑')
        // whitelist frame.js in content sandbox
        let file = getConfigFile('frame.js')
        Preferences.set('security.sandbox.content.read_path_whitelist', file)
        break
    }
}
vimfx.addCommand({
    name: 'bootstrap',
    description: 'Bootstrap',
}, ({vim}) => {
    try {
        bootstrap()
    } catch (error) {
        vim.notify('Bootstrap failed')
        console.error(error)
        return
    }
    vim.notify('Bootstrap succeeded')
})
map(',B', 'bootstrap', true)

let bootstrapIfNeeded = () => {
    let bootstrapFile = getConfigFile('config.js')
    let bootstrapPref = "extensions.VimFx.bootstrapTime"
    let file = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile)
    file.initWithPath(bootstrapFile)
    if (file.exists() && file.isFile() && file.isReadable()) {
        let mtime = Math.floor(file.lastModifiedTime / 1000)
        let btime = Preferences.get(bootstrapPref)
        if (!btime || mtime > btime) {
            bootstrap()
            Preferences.set(bootstrapPref, Math.floor(Date.now() / 1000))
        }
    }
}
bootstrapIfNeeded()
