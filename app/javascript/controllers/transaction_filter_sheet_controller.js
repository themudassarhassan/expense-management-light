import { Controller } from "@hotwired/stimulus"

// Mobile: filters expand in the document flow (not position: fixed) so native pickers
// behave. After Turbo updates the `transactions_index` frame, we re-open the panel
// if the user had it open (see session key below). Desktop: panel always in the bar.
const MOBILE_OPEN_PANEL_CLASSES = [
  "max-sm:mt-2",
  "max-sm:rounded-lg",
  "max-sm:border",
  "max-sm:border-gray-200",
  "max-sm:p-4",
  "max-sm:shadow-md",
  "max-sm:bg-white",
  "dark:max-sm:border-white/10",
  "dark:max-sm:bg-gray-900",
]

const PANEL_OPEN_STORAGE_KEY = "transaction-filters-open"

export default class extends Controller {
  static targets = ["panel", "openButton"]

  connect() {
    this._onResize = () => this.closeIfDesktop()
    window.addEventListener("resize", this._onResize)
    document.addEventListener("keydown", (this._onEscape = this.closeOnEscape.bind(this)))
    this.closeIfDesktop()
    this.restoreMobilePanelIfNeeded()
  }

  disconnect() {
    window.removeEventListener("resize", this._onResize)
    document.removeEventListener("keydown", this._onEscape)
  }

  open(event) {
    event?.preventDefault()
    if (!this.isMobileViewport()) return
    if (!this.hasPanelTarget) return
    this.applyPanelOpen()
    if (this.hasOpenButtonTarget) this.openButtonTarget.setAttribute("aria-expanded", "true")
    this.setPanelOpenStorage(true)
  }

  close(event) {
    event?.preventDefault()
    if (!this.hasPanelTarget) return
    this.applyPanelClose()
    if (this.hasOpenButtonTarget) this.openButtonTarget.setAttribute("aria-expanded", "false")
    this.setPanelOpenStorage(false)
  }

  applyPanelOpen() {
    this.panelTarget.classList.remove("max-sm:hidden")
    MOBILE_OPEN_PANEL_CLASSES.forEach((c) => this.panelTarget.classList.add(c))
  }

  applyPanelClose() {
    this.panelTarget.classList.add("max-sm:hidden")
    MOBILE_OPEN_PANEL_CLASSES.forEach((c) => this.panelTarget.classList.remove(c))
  }

  setPanelOpenStorage(open) {
    try {
      if (open) {
        window.sessionStorage.setItem(PANEL_OPEN_STORAGE_KEY, "1")
      } else {
        window.sessionStorage.removeItem(PANEL_OPEN_STORAGE_KEY)
      }
    } catch (_) {
      // sessionStorage may be unavailable
    }
  }

  restoreMobilePanelIfNeeded() {
    if (!this.isMobileViewport() || !this.hasPanelTarget) return
    try {
      if (window.sessionStorage.getItem(PANEL_OPEN_STORAGE_KEY) !== "1") return
      this.applyPanelOpen()
      if (this.hasOpenButtonTarget) {
        this.openButtonTarget.setAttribute("aria-expanded", "true")
      }
    } catch (_) {}
  }

  closeIfDesktop() {
    if (!this.isMobileViewport() && this.hasPanelTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key !== "Escape") return
    if (!this.hasPanelTarget || this.panelTarget.classList.contains("max-sm:hidden")) return
    if (!this.isMobileViewport()) return
    this.close()
  }

  isMobileViewport() {
    return window.matchMedia("(max-width: 639px)").matches
  }
}
