import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    if (window.Turbo) {
      window.Turbo.visit(this.urlValue)
    } else {
      window.location.assign(this.urlValue)
    }
    this.element.remove()
  }
}
