import { Controller } from "@hotwired/stimulus"

// Fetches the next page as a turbo-stream via fetch (not Turbo Drive), so the global
// progress bar does not start/stick on stream-only responses. Applies the stream with Turbo.renderStreamMessage.
export default class extends Controller {
  static targets = ["label", "spinner"]

  connect() {
    this.busy = false
  }

  async fetchNext(event) {
    event.preventDefault()
    if (this.busy) return

    const link = event.currentTarget
    const turbo = window.Turbo
    if (!turbo?.renderStreamMessage) {
      window.location.assign(link.getAttribute("href"))
      return
    }

    this.busy = true
    link.setAttribute("aria-busy", "true")
    link.classList.add("pointer-events-none", "opacity-60")
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.remove("hidden")
    if (this.hasLabelTarget) this.labelTarget.classList.add("opacity-80")

    try {
      const response = await fetch(link.href, {
        headers: { Accept: "text/vnd.turbo-stream.html" },
        credentials: "same-origin",
      })
      if (!response.ok) throw new Error(response.statusText)

      const html = await response.text()
      turbo.renderStreamMessage(html)
    } catch {
      this.busy = false
      link.removeAttribute("aria-busy")
      link.classList.remove("pointer-events-none", "opacity-60")
      if (this.hasSpinnerTarget) this.spinnerTarget.classList.add("hidden")
      if (this.hasLabelTarget) this.labelTarget.classList.remove("opacity-80")
    }
  }
}
