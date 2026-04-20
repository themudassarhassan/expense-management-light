import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  change(event) {
    const type = event.target.dataset.typeValue
    const url = `/transactions/new?transaction_type=${encodeURIComponent(type)}`
    document.getElementById("dynamic_fields").src = url
  }
}

