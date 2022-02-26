vimfx.listen('getInfo', (data, callback) => {
    let {document} = content
    let title = document.title
    let url = document.URL
    let selection = content.getSelection().toString()
    let {href} = document.activeElement
    if (!href) {
        let a = document.querySelector('a:hover')
        if (a)
            href = a.href
    }
    callback({title, url, selection, href})
})

vimfx.listen('ublockBootstrap', (data, callback) => {
    let filters = {
        'easyprivacy': true,
        'easylist': true,
        'CHN-0': true,
        'https://github.com/azuwis/org/raw/master/adblock-filters.txt': true,
    }
    let {document} = content
    document = document.querySelector('iframe').contentWindow.document
    let lists = document.querySelectorAll('#lists div.listEntry:not(.unused)')
    let handledFilters = []
    for (let item of lists) {
        let key = item.getAttribute('data-listkey')
        if (filters.hasOwnProperty(key)) {
            item.querySelector('input[type="checkbox"]').checked = filters[key]
            if (key.startsWith('https://')) {
                handledFilters.push(key)
            }
        }
    }
    let importCheckbox = document.querySelector('#importLists')
    if (!importCheckbox.checked) {
        importCheckbox.click()
    }
    let externalLists = document.querySelector('#externalLists')
    let externalListsString = Object.keys(filters).filter(e => e.startsWith('https://') && !handledFilters.includes(e)).join("\n")
    externalLists.value = externalListsString
    let buttonApply = document.querySelector('#buttonApply')
    buttonApply.classList.remove('disabled')
    buttonApply.click()
    // let buttonUpdate = document.querySelector('#buttonUpdate')
    // buttonUpdate.classList.remove('disabled')
    // buttonUpdate.click()
})
