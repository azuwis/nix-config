class GlanceCard extends Polymer.Element {
  set hass(hass) {
    this.content.hass = hass;
  }

  setConfig(config) {
    if (!this.content) {
      this.content = document.createElement('hui-glance-card');
      this.appendChild(this.content);
    }
    this.content.setConfig(config);
    this.content.updateComplete.then(() => {
      this.content.shadowRoot.querySelector('ha-card').querySelectorAll('state-badge').forEach(element => {
        let style = document.createElement('style');
        style.innerHTML = `
ha-icon[data-domain="media_player"][data-state="on"],
ha-icon[data-domain="climate"][data-state="cool"],
ha-icon[data-domain="climate"][data-state="heat"]
{
  color: var(--paper-item-icon-active-color);
}
`;
        element.shadowRoot.appendChild(style);
      });
    });
  }
}

customElements.define('glance-card', GlanceCard);
