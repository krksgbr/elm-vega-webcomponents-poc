import * as vega from "vega";

class VegaElement extends HTMLElement {
  connectedCallback() {
    const d = this.getAttribute("spec");
    const spec = JSON.parse(d);
    const view = new vega.View(vega.parse(spec), {
      renderer: "svg",
      container: this,
      hover: true
    });

    view.run();
    view.addEventListener("click", (event, item) => {
      this.dispatchEvent(
        new CustomEvent("datumClicked", {
          detail: item.datum
        })
      );
    });

    this.view = view;
  }

  static get observedAttributes() {
    return ["spec"];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case "spec": {
        if (this.view) {
          const spec = JSON.parse(newValue);
          spec.data.forEach(({ name, values }) => this.view.data(name, values));
          this.view.run();
        }
        break;
      }
    }
  }
}

window.customElements.define("vega-element", VegaElement);
