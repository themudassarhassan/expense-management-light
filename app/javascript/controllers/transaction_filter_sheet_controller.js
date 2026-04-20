import { Controller } from "@hotwired/stimulus"

const MOBILE_SHEET_CLASSES = [
  "max-sm:flex",
  "max-sm:flex-col",
  "max-sm:fixed",
  "max-sm:inset-x-0",
  "max-sm:bottom-0",
  "max-sm:z-50",
  "max-sm:max-h-[85vh]",
  "max-sm:overflow-y-auto",
  "max-sm:rounded-t-xl",
  "max-sm:border",
  "max-sm:border-gray-200",
  "max-sm:bg-white",
  "max-sm:p-4",
  "max-sm:shadow-xl",
  "dark:max-sm:border-white/10",
  "dark:max-sm:bg-gray-900",
]

export default class extends Controller {
  static targets = ["panel", "backdrop", "openButton"]

  connect() {
    this._onResize = () => this.closeIfDesktop()
    window.addEventListener("resize", this._onResize)
    document.addEventListener("keydown", this._onEscape = this.closeOnEscape.bind(this))
    this.unlockScroll()
    this.closeIfDesktop()
  }

  disconnect() {
    window.removeEventListener("resize", this._onResize)
    document.removeEventListener("keydown", this._onEscape)
    this.unlockScroll()
  }

  open(event) {
    event?.preventDefault()
    if (!this.isMobileViewport()) return
    if (!this.hasPanelTarget) return
    this.panelTarget.classList.remove("max-sm:hidden")
    MOBILE_SHEET_CLASSES.forEach((c) => this.panelTarget.classList.add(c))
    if (this.hasBackdropTarget) this.backdropTarget.classList.remove("hidden")
    if (this.hasOpenButtonTarget) this.openButtonTarget.setAttribute("aria-expanded", "true")
    this.lockScroll()
  }

  close(event) {
    event?.preventDefault()
    if (!this.hasPanelTarget) return
    this.panelTarget.classList.add("max-sm:hidden")
    MOBILE_SHEET_CLASSES.forEach((c) => this.panelTarget.classList.remove(c))
    if (this.hasBackdropTarget) this.backdropTarget.classList.add("hidden")
    if (this.hasOpenButtonTarget) this.openButtonTarget.setAttribute("aria-expanded", "false")
    this.unlockScroll()
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

  lockScroll() {
    document.documentElement.classList.add("overflow-hidden")
  }

  unlockScroll() {
    document.documentElement.classList.remove("overflow-hidden")
  }
}
