import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["elapsed"]
  static values = {
    startedAt: Number
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
      elapsedText = "just now"
    } else if (diffMinutes < 60) {
      elapsedText = `${diffMinutes} min ago`
    } else {
      const hours = Math.floor(diffMinutes / 60)
      const mins = diffMinutes % 60
      if (mins === 0) {
        elapsedText = `${hours} hr ago`
      } else {
        elapsedText = `${hours} hr ${mins} min ago`
      }
    }

    this.elapsedTarget.textContent = `Started ${elapsedText}`
  }
}
