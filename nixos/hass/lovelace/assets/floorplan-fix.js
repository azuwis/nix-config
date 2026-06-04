/**
 * floorplan-fix.js
 *
 * Patches hui-image.willUpdate() to preserve _loadedImageSrc and _loadState
 * across disconnect and reconnect rebuild. Only targets instances with both
 * image and aspect_ratio set. Those use CSS background-image where the fix
 * eliminates the white flash entirely.
 *
 * Also applies a CSS filter to the floorplan image when Home Assistant dark
 * mode is active.
 */
(function () {
  customElements.whenDefined("hui-image").then(() => {
    const HuiImage = customElements.get("hui-image");
    const orig = HuiImage.prototype.willUpdate;
    HuiImage.prototype.willUpdate = function (changedProps) {
      const saved = this._loadedImageSrc;
      orig.call(this, changedProps);
      if (!this.image || !this.aspectRatio) return;
      if (saved) {
        this._loadedImageSrc = saved;
        this._loadState = 2;
      } else if (this._resolvedImageSrc) {
        this._loadedImageSrc = this.hass
          ? this.hass.hassUrl(this._resolvedImageSrc)
          : this._resolvedImageSrc;
        this._loadState = 2;
      }

      this.style.filter = this.hass?.themes?.darkMode
        ? 'invert(1) hue-rotate(180deg) brightness(0.7)'
        : '';
    };
  });
})();
