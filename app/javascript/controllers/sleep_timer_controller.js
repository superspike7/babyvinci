import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["elapsed"]
  static values = {
    startedAt: Number,
    prefix: { type: String, default: "Started" },
    includeAgo: { type: Boolean, default: true }
  }

  connect() {
    this.updateElapsed()
    this.interval = setInterval(() => this.updateElapsed(), 60000) // Update every minute
  }

  disconnect() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  updateElapsed() {
    const startedAt = new Date(this.startedAtValue * 1000)
    const now = new Date()
    const diffMs = now - startedAt
    const diffMinutes = Math.floor(diffMs / 60000)

    let elapsedText
    if (diffMinutes < 1) {
      elapsedText = this.includeAgoValue ? "just now" : "0 min"
    } else if (diffMinutes < 60) {
      elapsedText = `${diffMinutes} min`
    } else {
      const hours = Math.floor(diffMinutes / 60)
      const mins = diffMinutes % 60
      if (mins === 0) {
        elapsedText = `${hours} hr`
      } else {
        elapsedText = `${hours} hr ${mins} min`
      }
    }

    if (this.includeAgoValue && elapsedText !== "just now") {
      elapsedText = `${elapsedText} ago`
    }

    this.elapsedTarget.textContent = `${this.prefixValue} ${elapsedText}`.trim()
  }
}
