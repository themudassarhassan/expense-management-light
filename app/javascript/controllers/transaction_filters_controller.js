import { Controller } from "@hotwired/stimulus"

// GET filter form: preset date ranges submit immediately; "custom" reveals date inputs + Apply.
export default class extends Controller {
  static targets = ["customFields", "fromInput", "toInput"]
  static values = { rangeCustom: { type: String, default: "custom" } }

  connect() {
    this.refresh()
  }

  dateRangeChanged() {
    this.refresh()
    const sel = this.selectElement
    if (!sel || sel.value === this.rangeCustomValue) return
    this.element.requestSubmit()
  }

  refresh() {
    this.toggleCustomVisibility()
    this.syncInputs()
  }

  get selectElement() {
    return this.element.querySelector("select[name='date_range']")
  }

  toggleCustomVisibility() {
    const sel = this.selectElement
    if (!this.hasCustomFieldsTarget || !sel) return
    const on = sel.value === this.rangeCustomValue
    this.customFieldsTarget.classList.toggle("hidden", !on)
  }

  syncInputs() {
    const sel = this.selectElement
    if (!sel) return
    const custom = sel.value === this.rangeCustomValue
    if (this.hasFromInputTarget) {
      this.fromInputTarget.disabled = !custom
      this.fromInputTarget.required = custom
    }
    if (this.hasToInputTarget) {
      this.toInputTarget.disabled = !custom
      this.toInputTarget.required = custom
    }
  }
}
