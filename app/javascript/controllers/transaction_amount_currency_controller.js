import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["suffix"]

  static values = {
    mapping: Object
  }

  connect() {
    this._onChange = () => this.updateSuffix()
    this.element.addEventListener('change', this._onChange)
    this.updateSuffix()
  }

  disconnect() {
    this.element.removeEventListener('change', this._onChange)
  }

  updateSuffix() {
    if (!this.hasSuffixTarget) return
    const form = this.element
    const kind = this.transactionType(form)
    const id = this.dominantAccountId(form, kind)
    const map = this.mappingValue || {}
    const code = id && map[String(id)]
    this.suffixTarget.textContent = code ? ` (${code})` : ''
  }

  transactionType(form) {
    const checked = form.querySelector('input[name="transaction[transaction_type]"]:checked')
    return checked ? checked.value : 'expense'
  }

  dominantAccountId(form, kind) {
    const name =
      kind === 'income'
        ? 'transaction[debit_account_id]'
        : 'transaction[credit_account_id]'
    const select = form.querySelector(`select[name="${name}"]`)
    const value = select?.value
    return value && value !== '' ? value : null
  }
}
