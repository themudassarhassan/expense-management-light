import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dashboardContext: String }

  change(event) {
    const type = event.target.dataset.typeValue
    let url = `/transactions/new?transaction_type=${encodeURIComponent(type)}`
    if (this.dashboardContextValue) {
      url += `&dashboard_context=${encodeURIComponent(this.dashboardContextValue)}`
    }
    document.getElementById("dynamic_fields").src = url
  }
}

