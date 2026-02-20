import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay", "feedDrawer", "sleepDrawer", "diaperDrawer"]

  connect() {
    this.drawers = {
      feed: this.hasFeedDrawerTarget ? this.feedDrawerTarget : null,
      sleep: this.hasSleepDrawerTarget ? this.sleepDrawerTarget : null,
      diaper: this.hasDiaperDrawerTarget ? this.diaperDrawerTarget : null
    }
  }

  open(event) {
    const type = event.currentTarget.dataset.type
    this.closeAllDrawers()
    
    if (this.drawers[type]) {
      this.drawers[type].classList.remove("translate-y-full")
      this.overlayTarget.classList.remove("hidden", "opacity-0")
      this.overlayTarget.classList.add("opacity-100")
    }
  }

  close() {
    this.closeAllDrawers()
    this.overlayTarget.classList.remove("opacity-100")
    this.overlayTarget.classList.add("opacity-0")
    setTimeout(() => {
      this.overlayTarget.classList.add("hidden")
    }, 300)
  }

  closeAllDrawers() {
    Object.values(this.drawers).forEach(drawer => {
      if (drawer) drawer.classList.add("translate-y-full")
    })
  }

  // Simulate logging an event and closing the drawer
  logAndClose(event) {
    const btn = event.currentTarget
    const originalText = btn.innerHTML
    
    // Simple visual feedback
    btn.innerHTML = `<span class="opacity-0">${originalText}</span><span class="absolute inset-0 flex items-center justify-center">✓ Logged</span>`
    btn.classList.add("bg-green-600", "text-white")
    
    setTimeout(() => {
      this.close()
      // reset after close animation
      setTimeout(() => {
        btn.innerHTML = originalText
        btn.classList.remove("bg-green-600", "text-white")
      }, 300)
    }, 600)
  }
}
