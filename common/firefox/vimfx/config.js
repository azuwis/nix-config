// example: https://github.com/lydell/dotfiles/blob/master/.vimfx/config.js

const {classes: Cc, interfaces: Ci, utils: Cu} = Components
const nsIEnvironment = Cc["@mozilla.org/process/environment;1"].getService(Ci.nsIEnvironment)
const nsIWindowWatcher = Cc["@mozilla.org/embedcomp/window-watcher;1"].getService(Ci.nsIWindowWatcher)
const {OS} = Cu.import('resource://gre/modules/osfile.jsm')

Cu.import('resource://gre/modules/XPCOMUtils.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'AddonManager', 'resource://gre/modules/AddonManager.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'PopupNotifications', 'resource://gre/modules/PopupNotifications.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'Preferences', 'resource://gre/modules/Preferences.jsm')

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
    if (OS.Path.split(bin).absolute)
        return bin
    let pathListSep = (Services.appinfo.OS == 'WINNT') ? ';' : ':'
    let dirs = nsIEnvironment.get("PATH").split(pathListSep)
    let file = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile)
    for (let dir of dirs) {
        let path = OS.Path.join(dir, bin)
        file.initWithPath(path)
        if (file.exists() && file.isFile() && file.isExecutable())
            return path
    }
    return null
}

let exec = (cmd, args, observer) => {
    let file = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile)
    file.initWithPath(pathSearch(cmd))
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
    name: 'search_selected_text',
    description: 'Search for the selected text'
}, ({vim}) => {
    vimfx.send(vim, 'getInfo', null, ({selection}) => {
        let {gURLBar} = vim.window
        if (isUrl(vim.window, selection)) {
            vim.window.switchToTabHavingURI(selection, true)
        } else {
            gURLBar.value = `g ${selection}`
            gURLBar.handleCommand(new vim.window.KeyboardEvent('keydown', {altKey: true}))
        }
    })
})
map('s', 'search_selected_text', true)

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
    vim.window.BrowserOpenAddonsMgr()
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
    // whitelist frame.js in content sandbox
    Preferences.set('security.sandbox.content.mac.testing_read_path1', OS.Path.fromFileURI(`${__dirname}/frame.js`))
    Preferences.set('security.sandbox.content.read_path_whitelist', OS.Path.fromFileURI(`${__dirname}/frame.js`))
    // set font for different OSes
    switch (Services.appinfo.OS) {
    case 'Darwin':
        Preferences.set('font.name.monospace.x-western', 'Menlo')
        break
    case 'WINNT':
        Preferences.set('font.name.monospace.zh-CN', 'Consolas')
        Preferences.set('font.name.sans-serif.zh-CN', '微软雅黑')
        Preferences.set('font.name.serif.zh-CN', '微软雅黑')
        break
    }
    // install addons
    let addons = [
        // {id: 'uBlock0@raymondhill.net', url: 'ublock-origin'},
        // {id: 'jid1-BoFifL9Vbdl2zQ@jetpack', url: 'decentraleyes'}
    ]
    addons.forEach((element) => {
        AddonManager.getAddonByID(element.id, (addon) => {
            if(!addon) {
                let url = element.url
                if(!url.startsWith('https://')) {
                    url = 'https://addons.mozilla.org/firefox/downloads/latest/' + url
                }
                AddonManager.getInstallForURL(url, (aInstall) => {
                    aInstall.install()
                }, 'application/x-xpinstall')
            }
        })
    })
    // Open about:support to see list of addons
    // disable addons
    let disabled_addons = [
        'addons-search-detection@mozilla.com',
        'gmp-gmpopenh264',
        'webcompat-reporter@mozilla.org',
        'webcompat@mozilla.org',
    ]
    disabled_addons.forEach((element) => {
        AddonManager.getAddonByID(element, (addon) => {
            addon.disable()
        })
    })
    // add custom search engine keywords
    let search_engines = [
        {alias: 'g', name:'Google', url: 'https://www.google.com/search?q={searchTerms}&ion=0&safe=off&lr=lang_zh-CN|lang_zh-TW|lang_en'},
        {alias: 'ddg', name:'DuckDuckGo', url: 'https://duckduckgo.com/?q={searchTerms}&kf=fw&kj=b2&ks=t&kw=n&ka=g&ko=s&kt=Lucida%20Grande&km=m&k1=-1&kv=1'},
        {alias: 'd', name: 'Debian packages', url: 'https://packages.debian.org/search?keywords={searchTerms}'},
        {alias: 'df', name: 'Debian File', url: 'https://packages.debian.org/search?searchon=contents&mode=filename&keywords={searchTerms}'},
        {alias: 'dfl', name: 'Debian File List', url: 'https://packages.debian.org/sid/all/{searchTerms}/filelist'},
        {alias: 'db', name: 'Debian Bugs', url: 'https://bugs.debian.org/cgi-bin/bugreport.cgi?bug={searchTerms}'},
    ]
    Services.search.init().then(function() {
        search_engines.forEach((e) => {
            let engine = Services.search.getEngineByName(e.name)
            if (engine) {
                engine.alias = e.alias
            } else {
                Services.search.addUserEngine(e.name, e.url, e.alias)
            }
        })
    })
    // popup('Bootstrap succeeded.', {
    //     label: 'Open Addons',
    //     accessKey: 'A',
    //     callback: () => {
    //         nsIWindowWatcher.activeWindow.BrowserOpenAddonsMgr()
    //     }
    // })
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
    let bootstrapFile = OS.Path.fromFileURI(`${__dirname}/config.js`)
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
