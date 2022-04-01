class StateIcon extends Polymer.Element {
  set hass(hass) {
    this.content.hass = hass;
  }

  setConfig(config) {
    if (!this.content) {
      this.content = document.createElement('hui-state-icon-element');
      this.appendChild(this.content);
    }
    this.content.setConfig(config);
    this.content.updateComplete.then(() => {
      const style = document.createElement('style');
      style.innerHTML = `
ha-icon[data-domain="climate"][data-state="cool"],
ha-icon[data-domain="climate"][data-state="heat"],
ha-icon[data-domain="media_player"][data-state="on"],
ha-icon[data-domain="sensor"]:not([data-state^="0"])
{
  color: var(--paper-item-icon-active-color);
}
`;
      this.content.shadowRoot.querySelector('state-badge').shadowRoot.appendChild(style);
    });
  }
}

customElements.define('state-icon', StateIcon);
