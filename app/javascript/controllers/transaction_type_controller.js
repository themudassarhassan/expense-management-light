import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  change(event) {
    const type = event.target.dataset.typeValue

    document.getElementById("dynamic_fields").src = `/transactions/new?type=${type}`
  }
}
