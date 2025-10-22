document.addEventListener('contextmenu', e => e.stopPropagation(), true);
document.addEventListener('selectstart', e => e.stopPropagation(), true);
document.addEventListener('mousedown', e => e.stopPropagation(), true);
document.addEventListener('copy', e => e.stopPropagation(), true);

const originalAddEventListener = EventTarget.prototype.addEventListener;
EventTarget.prototype.addEventListener = function(type, listener, options) {
  if (['contextmenu', 'selectstart', 'copy'].includes(type)) return;
  originalAddEventListener.call(this, type, listener, options);
};

const elements = document.querySelectorAll('*');
elements.forEach(el => {
  el.style.userSelect = 'auto';
  el.style.webkitUserSelect = 'auto';
  el.style.MozUserSelect = 'auto';
});

document.oncontextmenu = null;
document.onselectstart = null;
document.oncopy = null;

HTMLDocument.prototype.oncontextmenu = null;
HTMLElement.prototype.oncontextmenu = null;
HTMLElement.prototype.onselectstart = null;
